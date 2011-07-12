//
//  AudioUnit.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-08.
//  Copyright 2011 N/A. All rights reserved.
//

#import "AudioUnit.h"


@implementation AUAudioUnit

- (id)init
{
    self = [super init];
    if (self) {
        unit = NULL;
    }
    
    return self;
}

@end


/*
 
 
 Idea: Make the audio output unit to be the superclass of the note.
 
 */

static OSStatus RenderOutput(
                           void *inRefCon, 
                           AudioUnitRenderActionFlags 	*ioActionFlags, 
                           const AudioTimeStamp 		*inTimeStamp, 
                           UInt32 						inBusNumber, 
                           UInt32 						inNumberFrames, 
                           AudioBufferList 			*ioData)

{
    @autoreleasepool {

        
        // take inNumberFrames samples
        AudioOutput *self = (__bridge AudioOutput*)inRefCon;
        
/*        if (!self.source) {
            NSLog(@"RenderOutput: no buffer source.");
            return -1;
        }
  */      
        Sample *samples = [self renderSamples: inNumberFrames];
        
        if ([samples count] < inNumberFrames)
            NSLog(@"Buffer under run!");
//        samples = [self.source samples: inNumberFrames];             // errors to be caught inside this function

        NSError *error = nil;
        
        [samples dequeueSamples: ioData->mBuffers[0].mData count: [samples count] error: &error];
        
        if (error) {
            NSLog(@"Buffer: %@", [error localizedDescription]);
        }
    }

    return noErr;
}

@implementation AudioOutput

- (id) init {
    self = [super init];
    
    if (self) {
        AudioComponentDescription defaultOutputDescription = {
            .componentType = kAudioUnitType_Output,
            .componentSubType = kAudioUnitSubType_RemoteIO,
            .componentManufacturer = kAudioUnitManufacturer_Apple,
            .componentFlags = 0,
            .componentFlagsMask = 0
        };
        
        // finds the default playback output unit
        AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
        NSAssert(defaultOutput, @"Can't find default output");
        
        // Instanciates a new output unit
        OSErr err = AudioComponentInstanceNew(defaultOutput, &unit);
        NSAssert1(unit, @"Error creating unit: %ld", err);
        
        AURenderCallbackStruct input = {
            .inputProc = RenderOutput,
            .inputProcRefCon = (__bridge void*)self
        };
        
        // Set render callback
        err = AudioUnitSetProperty(unit,
                                   kAudioUnitProperty_SetRenderCallback,
                                   kAudioUnitScope_Input,
                                   0,
                                   &input,
                                   sizeof(input));
        NSAssert1(err == noErr, @"Error setting callback: %ld", err);
        
        // Set the format to 32 bit, single channel, floating point, linear PCM
        [self setFormatWithSampleRate: 44100 stereo: NO];
    }
    
    return self;
}
                                   
- (void) setFormatWithSampleRate: (float) sampleRate stereo: (BOOL) stereo {
    AudioStreamBasicDescription streamFormat = {
        .mSampleRate = sampleRate,
        .mFormatID = kAudioFormatLinearPCM,
        .mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved,
        .mBytesPerPacket = sizeof(float),
        .mFramesPerPacket = 1,
        .mBytesPerFrame = sizeof(float),
        .mChannelsPerFrame = 1,
        .mBitsPerChannel = sizeof(float) * 8
    };
    
    OSErr err = AudioUnitSetProperty(unit,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Input,
                                     0,
                                     &streamFormat, 
                                     sizeof(streamFormat));
    
    NSAssert(err == noErr, @"Error setting stream format");
    
}

- (void) initialize {
    if (unit) {
        OSErr err = AudioUnitInitialize(unit);
        NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
    }
}

- (void) uninitialize {
    if (unit) {
        OSErr err = AudioUnitUninitialize(unit);
        NSAssert1(err == noErr, @"Error uninitializing unit: %ld", err);
    }
}

- (void) play {
    [self initialize];
    
    
    OSStatus err = AudioOutputUnitStart(unit);
    NSAssert1(err == noErr, @"Error starting unit: %ld", err);

}

- (void) stop {
    OSErr err = AudioOutputUnitStop(unit);
    NSAssert1(err == noErr, @"Error stopping unit: %ld", err);
    
    [self uninitialize];
}

+ (id) audioOutput {
    return [[[self alloc] init] autorelease];
}

- (Sample*) renderSamples: (size_t) count {
    // default renders a zero pattern
    return [[Sample sampleWithCapacity: count] fill: 0.0];
}

@end




