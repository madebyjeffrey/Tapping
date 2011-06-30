//
//  ToneKit.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-19.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ToneKit : NSObject {
    AudioComponentInstance toneUnit;
}

+ (ToneKit*) sharedToneKit;

- (void) activateAudio;
- (void) deactivateAudio;

@property (assign) double sampleRate;
@property (assign) double frequency;
@property (assign) double theta;

- (void) playTone: (double) f;
- (void) stop;


@end