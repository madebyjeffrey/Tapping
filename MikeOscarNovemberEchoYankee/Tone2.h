//
//  Tone2.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-08.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>

#import "FIFO.h"

#import "Sample.h"

typedef BOOL (^ToneGenerator)(NSDictionary*, int, float*);

@interface FrequencyWave : NSObject {
    double sampleRate, frequency, theta, deltaTheta, amplitude;
    double phaseAngle;
}

@property (retain) Sample *buffer;
@property (assign) BOOL enabled;

- (void) fillBuffer;

@end

@interface Tone2 : NSObject {
    AudioComponentInstance toneUnit;
    
}
//+ (Tone*) toneWithFrequency: (double) frequency;
+ (Tone2*) toneWithFrequency: (double) frequency phase: (double) angle;
+ (Tone2*) toneWithFrequency: (double) frequency duration: (double) seconds;
- (void) play;
- (void) stop;
- (void) playForDuration: (double) seconds;

- (void) activateAudio;
- (void) deactivateAudio;
- (void) toneThread: (id) anObject;

@property (copy) ToneGenerator generator; 
@property (retain) NSMutableDictionary *state;
@property (assign) BOOL playing;

@property (assign) FIFO *buffer;
@property (retain) NSCondition *condition;
@property (assign) BOOL needsAudio;
@property (retain) NSThread *thread;

@property (retain) NSMutableDictionary *units;

@end
