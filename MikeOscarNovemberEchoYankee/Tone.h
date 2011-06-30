//
//  Tone.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-21.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>

#import "FIFO.h"

typedef BOOL (^ToneGenerator)(NSDictionary*, int, float*);


@interface Tone : NSObject {
    AudioComponentInstance toneUnit;

}
+ (Tone*) toneWithFrequency: (double) frequency;
+ (Tone*) toneWithFrequency: (double) frequency duration: (double) seconds;
- (void) play;
- (void) stop;
- (void) playForDuration: (double) seconds;

- (void) activateAudio;
- (void) deactivateAudio;
- (void) toneThread: (id) anObject;

@property (copy) ToneGenerator generator; 
@property (retain) NSMutableDictionary *state;
@property (assign) BOOL playing;

@property (assign) struct FIFO *buffer;
@property (retain) NSCondition *condition;
@property (assign) BOOL needsAudio;
@property (retain) NSThread *thread;
@end
