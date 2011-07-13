//
//  AudioUnit.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-08.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

#import "JDQueue.h"

@interface AUAudioUnit : NSObject {
    AudioComponentInstance unit;
}

@end

@interface AudioOutput : AUAudioUnit {}

+ (id) audioOutput;
- (void) setFormatWithSampleRate: (float) sampleRate stereo: (BOOL) stereo;

- (void) initialize;
- (void) uninitialize;

- (JDQueue*) renderSamples: (size_t) count;

- (void) play;
- (void) stop;

@end


