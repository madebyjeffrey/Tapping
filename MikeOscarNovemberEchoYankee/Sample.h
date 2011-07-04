//
//  WaveForm.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-03.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <stdbool.h>

@interface Sample : NSObject {
    float *buffer;
    float *end;
    size_t max_length;
}

- (id) initWithLength: (size_t) length;
- (Sample*) sampleWithLength: (size_t) samples;
- (void) importFloats: (float*) floats count: (size_t) length;
- (Sample*) extract: (size_t) samples;
- (size_t) capacity;
- (size_t) count;
- (void) removeSamples: (size_t) samples;
@end
