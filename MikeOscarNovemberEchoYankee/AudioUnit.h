//
//  AudioUnit.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-08.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>

@interface AUAudioUnit : NSObject {
    AudioComponentInstance unit;
}

@end

@protocol Source

- (Sample*) samples: (size_t) count;

@end

@interface AudioOutput : AUAudioUnit {}

+ (id) audioOutput;
- (void) setFormatWithSampleRate: (float) sampleRate stereo: (BOOL) stereo;

- (void) initialize;
- (void) uninitialize;

@property (retain) id<Source> source;

@end
