//
//  ToneKit.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-19.
//  Copyright 2011 N/A. All rights reserved.
//

#import "ToneKit.h"

static ToneKit *sharedInstance = nil;
static BOOL audioInit = NO;
static OSStatus ToneProxy(void *, AudioUnitRenderActionFlags*, const AudioTimeStamp *, UInt32, UInt32, AudioBufferList*);

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
}

@interface ToneKit (Private)

- (void) createToneUnit;

@end

@implementation ToneKit

@synthesize sampleRate, frequency, theta;

+ (ToneKit*) sharedToneKit {
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (void)release {
    // do nothing
}

- (id)autorelease {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax; // This is sooo not zero
}

- (id)init
{
    @synchronized(self) {
        [super init];
        if (audioInit == NO) {
            OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, self);
            
            if (result == kAudioSessionNoError)
            {
                UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
                AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
            }
            
            self.sampleRate = 44100;
            
            audioInit = YES;
        }

        return self;
    }
}

- (void) activateAudio {
	AudioSessionSetActive(true);    
}

- (void) deactivateAudio {
    AudioSessionSetActive(false);
}

- (void) playTone: (double) f {
    self.frequency = f;
    [self activateAudio];
    
    [self createToneUnit];
    
    OSErr err = AudioUnitInitialize(toneUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
    
    // Start playback
    err = AudioOutputUnitStart(toneUnit);
    NSAssert1(err == noErr, @"Error starting unit: %ld", err);
}

- (void) stop {
    AudioOutputUnitStop(toneUnit);
    AudioUnitUninitialize(toneUnit);
    AudioComponentInstanceDispose(toneUnit);
    toneUnit = nil;
    
    [self deactivateAudio];
}
    
    
@end

static OSStatus RenderTone(
                           void *inRefCon, 
                           AudioUnitRenderActionFlags 	*ioActionFlags, 
                           const AudioTimeStamp 		*inTimeStamp, 
                           UInt32 						inBusNumber, 
                           UInt32 						inNumberFrames, 
                           AudioBufferList 			*ioData);

@implementation ToneKit (Private)

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
	streamFormat.mSampleRate = self.sampleRate;
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

OSStatus RenderTone(
                    void *inRefCon, 
                    AudioUnitRenderActionFlags 	*ioActionFlags, 
                    const AudioTimeStamp 		*inTimeStamp, 
                    UInt32 						inBusNumber, 
                    UInt32 						inNumberFrames, 
                    AudioBufferList 			*ioData)

{
	// Fixed amplitude is good enough for our purposes
	const double amplitude = 0.25;
    
	// Get the tone parameters out of the tone kit
	ToneKit *kit = (ToneKit *)inRefCon;
	double theta = kit.theta;
	double theta_increment = 2.0 * M_PI * kit.frequency / kit.sampleRate;
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++) 
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	kit.theta = theta;
    
	return noErr;
}


