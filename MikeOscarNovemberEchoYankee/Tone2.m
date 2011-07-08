//
//  Tone2.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-08.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Tone2.h"

/* Mark 3 Design:
 
 Have a thread generate the sound samples and fill a circular buffer.
 The sound render thread will just memcpy it.
 */

@interface Tone2 (Private)

- (void) createToneUnit;
@end 


@implementation FrequencyWave

@synthesize buffer, enabled;

+ (FrequencyWave*) frequencyWave: (float) f {
    FrequencyWave *fw = [[FrequencyWave alloc] init];
    
    if (fw) {
        fw->sampleRate = 44100;
        fw->frequency = f;
        fw->theta = 0;
        fw->deltaTheta = 2 * M_PI * (fw->frequency / fw->sampleRate);
        fw->amplitude = 1;
        fw->phaseAngle = 0;
        
        fw.buffer = [Sample sampleWithCapacity: 2048];
        fw.enabled = YES;
    }
    
    return [fw autorelease];
}

- (void) dealloc {
    self.buffer = nil;
    
    [super dealloc];
}

- (void) fillBuffer {
    size_t count = self.buffer.available;
    
    float *buf = malloc(sizeof(float) * count);
    
    NSAssert(buf != NULL, @"No memory allocated in buffer");
    
    for (size_t frame = 0; frame < count; frame++) {
        buf[frame] = sin(theta + phaseAngle);
        
        theta += deltaTheta;
        if (theta > (2*M_PI)) theta -= 2 * M_PI;
    }
    
    [self.buffer enqueueSamples: buf count: count];
    
    free(buf);
    
}

@end

/* Update Tone to use new FrequencyWave:
 1. Update all existing code to use Sample
 2. Convert it to use FrequencyWave
 3. Change it into a more generic generator that multiplies a set of frequencywave classes together
 4. Give the frequency wave class a better name and base class that they will all work with
 5. ???
 6. Work with a dynamic queue to have worker threads
 
 */

@implementation Tone2

@synthesize generator, state, playing, buffer, condition, needsAudio, thread, units;

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
        self.thread = [[[NSThread alloc] initWithTarget: self selector: @selector(toneThread:) object: nil] autorelease];
        
        
        // elements will go in here, can be individually added and removed
        self.units = [NSMutableDictionary dictionaryWithCapacity: 4]; // elements
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

+ (Tone2*) toneWithFrequency: (double) frequency phase: (double) angle {
    Tone2 *this = [[Tone2 alloc] init];
    
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
+ (Tone2*) toneWithFrequency: (double) frequency duration: (double) seconds {
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


static OSStatus RenderTone(
                    void *inRefCon, 
                    AudioUnitRenderActionFlags 	*ioActionFlags, 
                    const AudioTimeStamp 		*inTimeStamp, 
                    UInt32 						inBusNumber, 
                    UInt32 						inNumberFrames, 
                    AudioBufferList 			*ioData)

{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // take inNumberFrames samples
    Tone2 *this = (__bridge Tone2*)inRefCon;
    
    [this.condition lock];
    
    
    
    int samples_available = FIFO_size(this.buffer);
    
    // check available
    if (samples_available < inNumberFrames) { // buffer underrun
        NSLog(@"RenderTone: Buffer underrun! Need %lu more samples", inNumberFrames - samples_available);
        // [this.buffer dequeueSamples: ioData->mBuffers[0].mData count: samples_available];
        FIFO_pop(this.buffer, ioData->mBuffers[0].mData, samples_available);
        // duplicate 0.0f for the rest
        
    }
    // we have enough samples
    else {
        // [this.buffer dequeueSamples: ioData->mBuffers[0].mData count: inNumberFrames];
        FIFO_pop(this.buffer, ioData->mBuffers[0].mData, inNumberFrames);
    }
    
    this.needsAudio = YES;
    [this.condition signal];
    [this.condition unlock];
    
    [pool drain];
    
    return noErr;
}


@implementation Tone2 (Private)

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
	input.inputProcRefCon = (__bridge void*)self;
    
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
