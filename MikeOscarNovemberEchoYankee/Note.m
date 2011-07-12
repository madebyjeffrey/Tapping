//
//  Note.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-11.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Note.h"

@implementation Note

@synthesize buffer, condition, thread, needsAudio;

- (id)init
{
    self = [super init];
    if (self) {
     
        
        
    }
    
    return self;
}



+ (id) noteWithFrequency:(double)frequency {
    Note *note = [[Note alloc] init];
    
    if (note) {
        note->sampleRate = 44100;
        note->frequency = frequency;
        note->theta = 0;
        note->deltaTheta = 2 * M_PI * (note->frequency / note->sampleRate);
        note->amplitude = 1;
        note->phaseAngle = 0;
        
        note.buffer = [Sample sampleWithCapacity: 2048];
        
        note.needsAudio = YES;
        note.condition = [[[NSCondition alloc] init] autorelease];
        
        note.thread = [[[NSThread alloc] initWithTarget: note selector: @selector(fillBuffer:) object: nil] autorelease];

        [note.thread start];
    }
    
    return [note autorelease];
}

- (void) fillBuffer: (id) anObject {
    @autoreleasepool {
        while (![[NSThread currentThread] isCancelled]) {
            [self.condition lock];
            
            while (!self.needsAudio) {
                [self.condition wait];
            }
            
            int samplesNeeded = self.buffer.available;
            
            float *buf = malloc(sizeof(float) * samplesNeeded);
            
            NSAssert(buf != NULL, @"No memory allocated in buffer");
            
            for (size_t frame = 0; frame < samplesNeeded; frame++) {
                buf[frame] = sin(theta + phaseAngle);
                
                theta += deltaTheta;
                
                if (theta > (2*M_PI)) theta -= 2 * M_PI;
            }
            
            NSError *error = nil; 
            
            [self.buffer enqueueSamples: buf count: samplesNeeded error: &error];
            
            if (error)
                NSLog(@"Error: %@", error);
             
            
            //NSLog(@"Render %lu samples from %f to %f", count, theta1, theta2);
            
            free(buf);
            
            needsAudio = NO;
             
            [self.condition unlock];
        }
    }
}

- (Sample*) renderSamples:(size_t)count {
    @autoreleasepool {
        [self.condition lock];
        
        Sample *samples = [self.buffer dequeue: count error: nil]; 
        
        self.needsAudio = YES;
        
        [self.condition signal];
        [self.condition unlock];
        
        return samples;
    }

}


@end
