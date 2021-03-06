//
//  WaveForm.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-03.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Sample.h"

/* 
 
 Update to limit access to low level fields to specific methods.
 Then get everyone else to use those methods for everything else.
 
 */
 
 

@implementation Sample

/*- (Sample*) multiplyBy: (Sample*) sample {
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
}*/

- (Sample*) fill: (float) sample {
    if (!buffer) return self;
    
    memset_pattern4(buffer, &sample, max_length * sizeof(float));
    end = buffer + max_length;
    
    return self;
}

- (id) init {
    return [self initWithCapacity: 2048];
}
                  
- (Sample*)copy {
    Sample *ret = [[Sample alloc] initWithCapacity: [self capacity]];
    
    memcpy(ret->buffer, buffer, self.count);
    ret->end = ret->buffer + (ret->end - ret->buffer);
    ret->max_length = max_length;
    
    return ret;
}
                

- (id) initWithCapacity: (size_t) capacity {
//    self = [self init];
    self = [super init];
    
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

+ (id) sampleWithCapacity: (size_t) capacity {
    return [[[Sample alloc] initWithCapacity: capacity] autorelease];
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

- (Sample*) dequeue: (size_t) count error: (NSError**) error {

    // Test 1: Do we have the samples
    if ([self count] < count) {
        if (error) { 
            
            // We do not have the samples
            *error = [NSError errorWithDomain: @"RangeError" 
                                         code: 1 
                                     userInfo: [NSDictionary dictionaryWithObject: 
                                                [NSString stringWithFormat: @"You wanted %d samples, there are only %d samples.", count, [self count]]
                                                                           forKey: NSLocalizedDescriptionKey]];

            return nil;
        }
    }
    
    Sample *sample = [[Sample alloc] initWithCapacity: count];
    
    if (sample) {
        [sample enqueueSamples: buffer count: count error: nil];
        [self removeSamples: count error: error];
    }
    
    return [sample autorelease];
}

- (BOOL) dequeueSamples: (float*) samples count: (size_t) count error: (NSError**) error {
    NSAssert(buffer != NULL, @"Structure not allocated");
    NSAssert(samples != NULL, @"destination is not allocated");
    
    if ([self count] < count) {
        if (error) { 
            
            // We do not have the samples
            *error = [NSError errorWithDomain: @"RangeError" 
                                         code: 1 
                                     userInfo: [NSDictionary dictionaryWithObject: 
                                                [NSString stringWithFormat: @"You wanted %d samples, there are only %d samples.", count, [self count]]
                                                                           forKey: NSLocalizedDescriptionKey]];
            
            return NO;
        }
    }
    
    memcpy(samples, self->buffer, count);
    
    [self removeSamples: count error: nil];
    
    return YES;
}


- (BOOL) enqueue: (Sample*) samples error: (NSError**) error {
    
    return [self enqueueSamples: samples->buffer count: [samples count] error: error];
}

- (BOOL) enqueueSamples: (float*) samples count: (size_t) length error: (NSError**) error {
    NSAssert(buffer != NULL, @"Structure not allocated");
    
    // Test 2: Do we have the space?
    size_t delta = self.capacity - self.count;
    if (length > delta) {
        // We do not - make it expand in future?
        if (error) { 
            
            // We do not have the samples
            *error = [NSError errorWithDomain: @"RangeError" 
                                         code: 1 
                                     userInfo: [NSDictionary dictionaryWithObject: 
                                                [NSString stringWithFormat: @"You wanted to import %d samples, but there is only room for %d samples.", length, delta]
                                                                    forKey: NSLocalizedDescriptionKey]];
            

        }
        return NO; 

    }    
    
    // no way to check if worked or failed
    memcpy(self->end, samples, length);
    
    self->end += length;
    
    return YES;
}

- (BOOL) removeSamples: (size_t) count error: (NSError**) error {
    NSAssert(buffer != NULL, @"Structure not allocated");
    
    // Do we have the samples to remove?
    if (self.count <= count) {
        // yes
        size_t delta = self.count - count;
        
        memmove(buffer, end - delta, delta);
        
        end -= delta;

        return YES;
    }
    else {
        // no
        if (error) { 
            
            // We do not have the samples
            *error = [NSError errorWithDomain: @"RangeError" 
                                         code: 1 
                                     userInfo: [NSDictionary dictionaryWithObject: 
                                                [NSString stringWithFormat: @"You wanted to remove %d samples, but there are only %d samples.", count, [self count]]
                                                                           forKey: NSLocalizedDescriptionKey]];
            
        }
        return NO;

    }
}

@end
