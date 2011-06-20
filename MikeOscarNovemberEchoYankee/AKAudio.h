//
//  Audio.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-19.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface AKAudio : NSObject {
    ALuint source;
    ALuint buffer;
    
    ALsizei outDataSize;
    ALenum  outDataFormat;
    ALsizei outSampleRate;
    
    void *sound_data;
}

- (id) init;
+ (AKAudio*) audioWithPath: (NSString*) path;
- (void) openAudioWithPath: (NSString*) path;
- (void) buffer;
- (void) source;
- (void) play;

@end
