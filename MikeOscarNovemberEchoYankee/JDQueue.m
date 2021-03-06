//
//  JDQueue.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-12.
//  Copyright 2011 N/A. All rights reserved.
//

#import "JDQueue.h"

@implementation JDQueue

- (id)init
{
    return [self initWithCapacity: 2048];
}

- (id) initWithCapacity: (int) length {
    self = [super init];
    
    if (self) {
        location = malloc(length * sizeof(TYPE));
        
        if (!location) {
            return nil;
        }
        
        capacity = length;
        tail = 0;
    }
    
    return self;
}

- (void) dealloc {
    if (location) {
        free(location);
    }
    
    [super dealloc];
}

- (BOOL) enqueue: (TYPE*) items count: (int) length {
    if (length + tail <= capacity) {
        memcpy(location + (tail * sizeof(TYPE)), items, length * sizeof(TYPE));
        tail += length;
        return YES;
    }
    return NO;
}

- (BOOL) dequeue: (TYPE*) items count: (int) length {
    if (length == 0) return YES;  // it is not a failure to dequeue 0 items
    printf("Taking out %d items\n", length);
    if (tail >= length) {
        printf("Copy from %p to %p length %d (amount left: %ul)\n", location, items, length * sizeof(TYPE), self.available);
        memcpy(items, location, length * sizeof(TYPE));
        printf("Move from %p to %p length %d\n", location + length * sizeof(TYPE), location, tail - length);
        memmove(location, location + length * sizeof(TYPE), tail - length);
//        memmove(location, location + (tail * sizeof(TYPE)), (capacity - length) * sizeof(TYPE));
//        memcpy(items, location, length);
//        memmove(location, location + tail, capacity - length); // capacity - length should be amount left, verify
        
        tail -= length;
        
        return YES;
    }
    
    return NO;
}

@dynamic count, capacity, available;

- (int) count {
    return tail;    
}

- (int) capacity {
    return capacity;
}

- (int) available {
    return capacity - tail;
}

- (NSString*) description {
    NSMutableString *string = [NSMutableString string];
    
    for (int i = 0; i < tail; i++) {
        [string appendFormat: @" %5f, ", location[i]];   
    }
    
    return string;
}
@end

@interface JDQueue (Extended) 


@end

@implementation JDQueue (Extended)



@end
