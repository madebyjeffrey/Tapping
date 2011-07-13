//
//  JDQueue.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-12.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <strings.h>

#define TYPE float

@interface JDQueue : NSObject {
    @private
    
    TYPE *location;
    int capacity;       // total size of queue 
    int tail;           // index to 1 element past last item
}

- (id) initWithCapacity: (int) length;
- (BOOL) enqueue: (TYPE*) items count: (int) length;
- (BOOL) dequeue: (TYPE*) items count: (int) length;

@property (readonly) int count;
@property (readonly) int capacity;
@property (readonly) int available;
@end
