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


@interface Sample : NSObject {
    float *buffer;
    float *end;
    size_t max_length;
}

- (Sample*) multiplyBy: (Sample*) sample;

// Initialize with size
- (id) initWithCapacity: (size_t) capacity;
+ (id) sampleWithCapacity: (size_t) capacity;


// Append another sample to the end
- (BOOL) enqueue: (Sample*) samples error: (NSError**) error;

// add floats to the end of the structure
- (BOOL) enqueueSamples: (float*) samples count: (size_t) length error: (NSError**) error;

// take samples from the beginning in a new Sample
- (Sample*) dequeue: (size_t) count error: (NSError**) error;

// copies samples to a buffer
- (BOOL) dequeueSamples: (float*) samples count: (size_t) count error: (NSError**) error;



// Remove samples
- (BOOL) removeSamples: (size_t) count error: (NSError**) error;

// Max size
- (size_t) capacity;

// Current size
- (size_t) count;

- (size_t) available;

@end
