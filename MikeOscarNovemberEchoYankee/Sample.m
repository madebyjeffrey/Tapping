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

- (Sample*) sampleWithLength: (size_t) samples {
    Sample *sample = [[Sample alloc] initWithLength: samples];
    
    return [sample autorelease];
}

- (size_t) count {
    if (self->buffer) {
        return (size_t)(self->end - self->buffer);
    }

    @throw NSInvalidArgumentException;
    return 0;
}

- (size_t) capacity {
    return self->max_length;
}


- (Sample*) extract: (size_t) samples {
    // Test 1: Do we have the samples
    if ([self count] > samples) {
        // We do not have the samples
        @throw NSRangeException;
    }
    
    Sample *sample = [[Sample alloc] init];
    
    if (sample) {

    }
    
    return nil;
}

- (void) importFloats: (float*) floats count: (size_t) length {
    // Test 1: Are we initialized?
    if (self->buffer == NULL) {
        // We are not
        @throw NSInvalidArgumentException;
    }
    // Test 2: Do we have the space?
    size_t delta = self.capacity - self.count;
    if (delta > length) {
        // We do not - make it expand?
        @throw NSRangeException;
    }
    
    // no way to check if worked or failed
    memcpy(self->end, floats, length);
}

@end
