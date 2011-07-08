//
//  WaveForm.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-03.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Sample.h"


@implementation Sample

- (Sample*) multiplyBy: (Sample*) sample {
    // returns self
    
    if (sample.count != self.count) {
        @throw [NSException exceptionWithName: NSRangeException 
                                       reason: 
                [NSString stringWithFormat: @"You wanted to multiply %d samples by %d samples, they must be equal.", self.count, sample.count] 
                                     userInfo: nil];
    }
    // vmulq_f32  float32x4_t   float32x4x2_t vld2q_f32(__transfersize(8) float32_t const * ptr); 
//    catlas_saxpby(sample.count / 2, 1.0, sample->buffer, 1, 1.0, self->buffer, 1);
//    vDSP_vmul FTW!
    
    vDSP_vmul(self->buffer, 1, sample->buffer, 1, self->buffer, 1, [self count]);
    
    return self;
}

- (id) init {
    self = [super init];
    
    if (self) {
        self->buffer = NULL;
        self->end = NULL;
        self->max_length = 0;
    }
    
    return self;
}
                  
- (Sample*)copy {
<<<<<<< HEAD
    Sample *ret = [[Sample alloc] initWithLength: [self capacity]];
=======
    Sample *ret = [[Sample alloc] initWithCapacity: [self capacity]];
>>>>>>> Fixed some memory management issues
    
    memcpy(ret->buffer, self->buffer, self.count);
    ret->end = ret->buffer + (ret->end - ret->buffer);
    ret->max_length = self->max_length;
    
    return ret;
}
                

- (id) initWithCapacity: (size_t) capacity {
    self = [self init];
    
    if (self) {
        self->buffer = malloc(capacity * sizeof(float));
        
        if (buffer == NULL) {
            [self release];
            return nil;
        }
        
        self->end = buffer;
        
        self->max_length = capacity;
    }
    
    return self;
}

- (void) dealloc {
    if (self->buffer != NULL) {
        free(self->buffer);
    }
    
    [super dealloc];

}

+ (Sample*) sampleWithCapacity: (size_t) capacity {
    Sample *sample = [[Sample alloc] initWithCapacity: capacity];
    
    return [sample autorelease];
}

- (size_t) count {
    NSAssert(buffer != NULL, @"Structure not allocated");
    
    return (size_t)(end - buffer);
}

- (size_t) capacity {
    return max_length;
}

- (size_t) available {
    return self.capacity - self.count;
}

- (Sample*) dequeue: (size_t) count {

    // Test 1: Do we have the samples
    if (self.count > count) {
        // We do not have the samples
        @throw [NSException exceptionWithName:NSRangeException 
                                       reason: [NSString stringWithFormat: @"You wanted %d samples, there are only %d samples.", count, 
                                                [self count]] 
                                     userInfo: nil];
    }
    
    Sample *sample = [[Sample alloc] initWithCapacity: count];
    
    if (sample) {
        [sample enqueueSamples: buffer count: count];
        [self removeSamples: count];
    }
    
    return [sample autorelease];
}

- (void) dequeueSamples: (float*) samples count: (size_t) count {
    NSAssert(buffer != NULL, @"Structure not allocated");
    NSAssert(samples != NULL, @"destination is not allocated");
    
    if (self.count < count) {
        @throw [NSException exceptionWithName:NSRangeException 
                                       reason: [NSString stringWithFormat: @"You wanted to copy %d samples, but there are only %d samples.", count, self.count] 
                                     userInfo: nil];
    }
    
    memcpy(samples, self->buffer, count);
    
    [self removeSamples: count];
}


- (void) enqueue: (Sample*) samples {
    NSAssert(buffer != NULL, @"Structure not allocated");
    
    [self enqueueSamples: samples->buffer count: [samples count]];
}

- (void) enqueueSamples: (float*) samples count: (size_t) length {
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
    memcpy(self->end, samples, length);
    
    self->end += length;
}

- (void) removeSamples: (size_t) count {
    NSAssert(buffer != NULL, @"Structure not allocated");
    
    // Do we have the samples to remove?
    if (self.count <= count) {
        // yes
        size_t delta = self.count - count;
        
        memmove(buffer, end - delta, delta);
        
        end -= delta;
    }
    else {
        // no
        @throw [NSException exceptionWithName:NSRangeException 
                                       reason: [NSString stringWithFormat: @"You wanted to remove %d samples, but there are only %d samples.", count, [self count]] 
                                     userInfo: nil];
    }
}

@end
