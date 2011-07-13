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

- (void) dealloc {
    self.buffer = nil;
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
        
        note.buffer = [[[JDQueue alloc] initWithCapacity: 2048] autorelease];
        
        note.needsAudio = YES;
        note.condition = [[[NSCondition alloc] init] autorelease];
        
        note.thread = [[[NSThread alloc] initWithTarget: note selector: @selector(fillBuffer:) object: nil] autorelease];

        [note.thread start];
    }
    
    return [note autorelease];
}

- (void) fillBuffer: (id) anObject {
    
    @autoreleasepool {
//        NSArray *documentsdir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  //      NSString *documents = [documentsdir objectAtIndex: 0];
        
    //    NSLog(@"%@", documents);
      //  NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath: [NSString stringWithFormat: @"%@/sine%d.txt", documents, rand() % 1000]];
        
        
        while (![[NSThread currentThread] isCancelled]) {
            [self.condition lock];
            
            while (!self.needsAudio) {
                [self.condition wait];
            }
            
            
            int samplesNeeded = self.buffer.available;
            
            float *buf = malloc(sizeof(float) * samplesNeeded);
            
            printf("Samples needed: %d,  theta: %f   \n", samplesNeeded, theta);
            
            NSAssert(buf != NULL, @"No memory allocated in buffer");
            
            for (size_t frame = 0; frame < samplesNeeded; frame++) {
                buf[frame] = sin(theta + phaseAngle);
                
            //    [file writeData: [NSString stringWithFormat: @"%f\n", buf[frame]]];
                
               // printf("%f\n", buf[frame]);
                theta += deltaTheta;
                
                if (theta > (2*M_PI)) theta -= 2 * M_PI;
            }

            
            printf("Buffer first sample: %f\n", buf[0]);
            [self.buffer enqueue: buf count: samplesNeeded];
            
            
            free(buf);
            
            needsAudio = NO;
             
            [self.condition unlock];
        }
                 
          //       [file closeFile];
    }
}

- (JDQueue*) renderSamples:(size_t)count {
    [self.condition lock];
    
    float *buf = malloc(count * sizeof(float));
    
    [self.buffer dequeue: buf count: count];
    
    JDQueue *buf2 = [[JDQueue alloc] initWithCapacity: count];
    
    [buf2 enqueue: buf count: count];
    
    free(buf);
    
//        Sample *samples = [self.buffer dequeue: count error: nil]; 
    
    self.needsAudio = YES;
    
    [self.condition signal];
    [self.condition unlock];
    
//        return samples;
    return [buf2 autorelease];
}


@end
