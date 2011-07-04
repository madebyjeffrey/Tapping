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

// Initialize with size
- (id) initWithLength: (size_t) length;
+ (Sample*) sampleWithLength: (size_t) samples;


// Append another sample to the end
- (void) append: (Sample*) samples;

// add floats to the end of the structure
- (void) importFloats: (float*) floats count: (size_t) length;

// take samples from the beginning in a new Sample
- (Sample*) extract: (size_t) samples;

// Remove samples
- (void) removeSamples: (size_t) samples;

// Max size
- (size_t) capacity;

// Current size
- (size_t) count;

// copies samples to a buffer
- (void) copyToBuffer: (float*)destination count: (size_t) amount;

@end
