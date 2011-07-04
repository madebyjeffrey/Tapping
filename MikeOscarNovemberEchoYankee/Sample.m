//
//  WaveForm.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-03.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Sample.h"


@implementation Sample

- (id) init {
    self = [super init];
    
    if (self) {
        self->buffer = NULL;
        self->end = NULL;
        self->max_length = 0;
    }
    
    return self;
}

- (id) initWithLength: (size_t) length {
    self = [self init];
    
    if (self) {
        self->buffer = malloc(length * sizeof(float));
        self->end = buffer;
        
        self->max_length = length;
    }
    
    return self;
}

- (void) dealloc {
    if (self->buffer != NULL) {
        free(self->buffer);
    }
    
    [super dealloc];

}

+ (Sample*) sampleWithLength: (size_t) samples {
    Sample *sample = [[Sample alloc] initWithLength: samples];
    
    return [sample autorelease];
}

- (size_t) count {
    NSAssert(buffer != NULL, @"Structure not allocated");
    
    return (size_t)(end - buffer);
}

- (size_t) capacity {
    return max_length;
}


- (Sample*) extract: (size_t) samples {

    // Test 1: Do we have the samples
    if ([self count] > samples) {
        // We do not have the samples
        @throw [NSException exceptionWithName:NSRangeException 
                                       reason: [NSString stringWithFormat: @"You wanted %d samples, there are only %d samples.", samples, [self count]] 
                                     userInfo: nil];
    }
    
    Sample *sample = [[Sample alloc] initWithLength: samples];
    
    if (sample) {
        [sample importFloats: buffer count: samples];
        [self removeSamples: samples];
    }
    
    return [sample autorelease];
}

- (void) append: (Sample*) samples {
    NSAssert(buffer != NULL, @"Structure not allocated");
    
    [self importFloats: samples->buffer count: [samples count]];
}

- (void) removeSamples: (size_t) samples {
    NSAssert(buffer != NULL, @"Structure not allocated");
    
    // Do we have the samples to remove?
    if (self.count <= samples) {
        // yes
        size_t delta = self.count - samples;
        
        memmove(buffer, end - delta, delta);
        
        end -= delta;
    }
    else {
        // no
        @throw [NSException exceptionWithName:NSRangeException 
                                       reason: [NSString stringWithFormat: @"You wanted to remove %d samples, but there are only %d samples.", samples, [self count]] 
                                     userInfo: nil];
    }
}

- (void) importFloats: (float*) floats count: (size_t) length {
       NSAssert(buffer != NULL, @"Structure not allocated");

    // Test 2: Do we have the space?
    size_t delta = self.capacity - self.count;
    if (length > delta) {
        // We do not - make it expand in future?
        @throw [NSException exceptionWithName:NSRangeException 
                                       reason: 
                [NSString stringWithFormat: @"You wanted to import %d samples, but there is only room for %d samples.", length, delta] 
                                     userInfo: nil];
    }    
    
    // no way to check if worked or failed
    memcpy(self->end, floats, length);
    
    self->end += length;
}

- (void) copyToBuffer: (float*)destination count: (size_t) amount {
    NSAssert(buffer != NULL, @"Structure not allocated");
    NSAssert(destination != NULL, @"destination is not allocated");
    
    if ([self count] < amount) {
        @throw [NSException exceptionWithName:NSRangeException 
                                       reason: [NSString stringWithFormat: @"You wanted to copy %d samples, but there are only %d samples.", amount, [self count]] 
                                     userInfo: nil];
    }
    
    memcpy(destination, self->buffer, amount);
}

@end
