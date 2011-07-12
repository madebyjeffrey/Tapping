//
//  Note.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "AudioUnit.h"

@interface Note : AudioOutput {
    double sampleRate, frequency, theta, deltaTheta, amplitude;
    double phaseAngle;
}

+ (id) noteWithFrequency: (double) frequency;

@property (retain) Sample *buffer;
@property (retain) NSThread *thread;
@property (retain) NSCondition *condition;
@property (assign) BOOL needsAudio;

@end
