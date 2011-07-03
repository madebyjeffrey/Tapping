//
//  Tone.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-21.
//  Copyright 2011 N/A. All rights reserved.
//

/* Mark 3 Design:
 
    Have a thread generate the sound samples and fill a circular buffer.
    The sound render thread will just memcpy it.
 */

#import "Tone.h"

@interface Tone (Private)

- (void) createToneUnit;
@end 

@implementation Tone

@synthesize generator, state, playing, buffer, condition, needsAudio, thread;

- (id) init {
    self = [super init];
    
    if (self) {
        toneUnit = NULL;
        self.generator = nil;
        self.state = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                      [NSNumber numberWithDouble: 44100], @"Sample Rate", 
                      nil];
        self.playing = NO;
        self.buffer = FIFO_alloc(2048); // buffer for 100 ms
        self.condition = [[[NSCondition alloc] init] autorelease];
        self.needsAudio = YES; // queue it up right away
        self.thread = [[NSThread alloc] initWithTarget: self selector: @selector(toneThread:) object: nil];
    }
    
    return self;
}

- (void) activateAudio {
	AudioSessionSetActive(true);    
}

- (void) deactivateAudio {
    AudioSessionSetActive(false);
}

- (void) toneThread: (id) anObject {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    while ([[NSThread currentThread] isCancelled] == NO) {
        [self.condition lock];
        
        while (self.needsAudio == NO) {
            [self.condition wait];
        }
        
        FIFO *thebuffer = self.buffer;
        
        int samples_needed = FIFO_maxsize(thebuffer) - FIFO_size(thebuffer);
        
        float *samples = malloc(samples_needed * sizeof(float));
        
        if (samples == NULL) {
            // no memory?
            NSLog(@"toneThread: malloc failed, NOMEM? %s", (errno == ENOMEM ? "YES" : "NO"));
            self.needsAudio = NO; // if the malloc failed once, it will likely again
        }
        else {
        
            // generate samples needed
            BOOL result = self.generator(self.state, samples_needed, samples);
            
            // if generated right
            if (result == YES) {
                // copy results into the buffer
                /*result =*/ FIFO_push(thebuffer, samples, samples_needed);
            
                
                // we do not need any more data
                self.needsAudio = NO;
                
                // deallocate the buffer
                free(samples);
            }
        }
        
        [self.condition unlock];
    }
    
    [pool drain];
}

+ (Tone*) toneWithFrequency: (double) frequency phase: (double) angle {
    Tone *this = [[Tone alloc] init];
    
    if (this) {
        [this.state setObject: [NSNumber numberWithDouble: frequency] forKey: @"Frequency"];
        [this.state setObject: [NSNumber numberWithDouble: angle] forKey: @"Phase Angle"];

        [this createToneUnit];
        
        this.generator =  ^ BOOL(NSDictionary *state, int nframes, float*sample) {
            double sampleRate, frequency, theta, deltaTheta, amplitude;
            double phaseAngle;

            id val = nil;
            
            if (sample == NULL) 
                return NO;
            
            if ((val = [state objectForKey: @"Sample Rate"]) != nil)
                sampleRate = [val doubleValue];    
            else
                return NO;
            
            if ((val = [state objectForKey: @"Frequency"]) != nil)
                frequency = [val doubleValue];
            else
                return NO;
            
            if ((val = [state objectForKey: @"Phase Angle"]) != nil)
                phaseAngle = [val doubleValue];
            else 
                return NO;
            
            theta = (val = [state objectForKey: @"Theta"]) == nil ? 0 : [val doubleValue];
            
//            NSLog(@"Frequency: %f   Sample Rate: %f   2pi: %f  %f", frequency, sampleRate, 2*M_PI, M_2_PI);
            deltaTheta = 2 * M_PI * (frequency / sampleRate);
            
            amplitude = 0.25;
            
            for (int frame = 0; frame < nframes; frame++) {
                sample[frame] = sin(theta + phaseAngle) * amplitude;
                
                theta += deltaTheta;
                if (theta > 2 * M_PI) theta -= 2 * M_PI;
            }
            
            [state setValue: [NSNumber numberWithDouble: theta] forKey: @"Theta"];
                       
            return YES;
            };
    }
    
    [this.thread start]; // buffer
    
    return [this autorelease];
    
}
+ (Tone*) toneWithFrequency: (double) frequency duration: (double) seconds {
    return nil;
}
- (void) play {
    if (self.playing == YES) return;
    
    [self activateAudio];

    OSErr err = AudioUnitInitialize(toneUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
    
    // Start playback
    err = AudioOutputUnitStart(toneUnit);
    NSAssert1(err == noErr, @"Error starting unit: %ld", err);
    
    self.playing = YES;

}


- (void) stop {
    if (self.playing == NO) return;
    OSErr err = AudioOutputUnitStop(toneUnit);
    NSAssert1(err == noErr, @"Error stopping unit: %ld", err);
    
    err = AudioUnitUninitialize(toneUnit);
    NSAssert1(err == noErr, @"Error uninitializing unit: %ld", err);
    
    self.playing = NO;
}
- (void) playForDuration: (double) seconds {
    //
}

@end


OSStatus RenderTone(
                    void *inRefCon, 
                    AudioUnitRenderActionFlags 	*ioActionFlags, 
                    const AudioTimeStamp 		*inTimeStamp, 
                    UInt32 						inBusNumber, 
                    UInt32 						inNumberFrames, 
                    AudioBufferList 			*ioData)

{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // take inNumberFrames samples
    Tone *this = (Tone*)inRefCon;
    
    [this.condition lock];
    


    int samples_available = FIFO_size(this.buffer);

    // check available
    if (samples_available < inNumberFrames) { // buffer underrun
        NSLog(@"RenderTone: Buffer underrun! Need %lu more samples", inNumberFrames - samples_available);
        
        FIFO_pop(this.buffer, ioData->mBuffers[0].mData, samples_available);
        // duplicate 0.0f for the rest
        
    }
    // we have enough samples
    else {
        FIFO_pop(this.buffer, ioData->mBuffers[0].mData, inNumberFrames);
    }
        
    this.needsAudio = YES;
    [this.condition signal];
    [this.condition unlock];

    [pool drain];
    
    return noErr;
}


@implementation Tone (Private)

- (void) createToneUnit {
    // Configure the search parameters to find the default playback output unit
	// (called the kAudioUnitSubType_RemoteIO on iOS but
	// kAudioUnitSubType_DefaultOutput on Mac OS X)
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
    
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	NSAssert1(toneUnit, @"Error creating unit: %ld", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
	input.inputProc = RenderTone;
	input.inputProcRefCon = self;
    
	err = AudioUnitSetProperty(toneUnit, 
                               kAudioUnitProperty_SetRenderCallback, 
                               kAudioUnitScope_Input,
                               0, 
                               &input, 
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = [[self.state objectForKey: @"Sample Rate"] doubleValue];
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;	
	streamFormat.mBytesPerFrame = four_bytes_per_float;		
	streamFormat.mChannelsPerFrame = 1;	
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %ld", err);
}
                          


@end
