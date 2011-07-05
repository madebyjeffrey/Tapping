//
//  WaveForm.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-03.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include <stdbool.h>
#include <stdargs.h>

@interface Sample : NSObject {
    float *buffer;
    float *end;
    size_t max_length;
}

+ (Sample*) multiplySamples: (Sample*) sample, ...;

// Initialize with size
- (id) initWithLength: (size_t) length;
+ (Sample*) sampleWithLength: (size_t) samples;


// Append another sample to the end
- (void) enqueue: (Sample*) samples;

// add floats to the end of the structure
- (void) enqueueSamples: (float*) samples count: (size_t) count;

// take samples from the beginning in a new Sample
- (Sample*) dequeue: (size_t) count;

// copies samples to a buffer
- (void) dequeueSamples: (float*) samples count: (size_t) count;



// Remove samples
- (void) removeSamples: (size_t) count;

// Max size
- (size_t) capacity;

// Current size
- (size_t) count;

- (size_t) available;

@end
