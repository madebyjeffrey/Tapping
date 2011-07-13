//
//  JDQueueTests.m
//  JDQueueTests
//
//  Created by Jeffrey Drake on 11-07-03.
//  Copyright 2011 N/A. All rights reserved.
//

#import "JDQueueTests.h"

//#include <arm_neon.h>

@interface JDQueue (Testing)

@property (readonly) TYPE *location;

@end

@implementation JDQueue (Testing)

@dynamic location;

- (TYPE*) location {
    return location;
}

@end

@implementation JDQueueTests

- (void)setUp
{
    [super setUp];
    
}

- (void)tearDown
{

    [super tearDown];
}

/* Test Basic Set */



// Comment Format
// Test	                          { starting } -> { queue } / {dequeued}	       Result (Success)

// Enqueue 0                      { }  -> { }	                                   YES

- (void) testEnqueue0 {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 10];
    
    float n = 5;
    
    BOOL result = [q enqueue: &n count: 0];
    
    STAssertTrue(result &&          // result good
                 (q.count == 0),    // size is 0
                 @"size of queue is %d should be 0", q.count); 
    
}

// Enqueue 1                      { } -> { 1 }                                     YES

- (void) testEnqueue1 {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 10];
    
    float n = 1;
    
    BOOL result = [q enqueue: &n count: 1];
    
    STAssertTrue(result &&          // result good
                 (q.count == 1) &&    // size is 1
                 (q.location[0] == 1), // first entry is 1
                 @"result is %d, size of queue is %d should be 1, first entry is %f should be 1.0", result, q.count, q.location[0]); 
    
}


// Enqueue 5                      { } -> { 1 2 3 4 5 }	                           YES

- (void) testEnqueue5 {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 10];
    
    float n[5] = { 1, 2, 3, 4, 5 };
    
    BOOL result = [q enqueue: n count: 5];
    
    STAssertTrue(result &&          // result good
                 (q.count == 5) &&    // size is 1
                 (q.location[0] == 1) && // entries are 1,2,3,4,5
                 (q.location[1] == 2) &&
                 (q.location[2] == 3) &&
                 (q.location[3] == 4) &&
                 (q.location[4] == 5),
                 @"result is %d, size of queue is %d should be 1, entries are is %f, %f, %f, %f, %f should be 1.0, 2.0, 3.0, 4.0, 5.0", 
                    result, q.count, q.location[0], q.location[1], q.location[2], q.location[3], q.location[4]); 
    
}



// Enqueue 10 with capacity 5     { } -> { }                                       NO

// Dequeue 0 Empty                { }  -> { } /  { }                               YES
// Dequeue 0 From 1               { 0 } -> { 0 }   /  { }                          YES
// Dequeue 0 From 5               { 1 2 3 4 5 } -> { 1 2 3 4 5 } / { }             YES
// Dequeue 0 From 10              { 1 .. 10 } -> { 1 .. 10 } /  { }	               YES
// Dequeue 1 From Empty           { } -> { } / { }	                               NO
// Dequeue 1 From 1               { 1 } -> { } / { 1 }                             YES
// Dequeue 1 From 5               { 1 2 3 4 5 } -> { 2 3 4 5 } / { 1 }	           YES
// Dequeue 1 From 10              { 1 2 3 4 5 6 7 8 9 10 } -> { 2 .. 10 } / { 1 }  YES
// Dequeue 5 From Empty           { } -> { } / { }                                 NO
// Dequeue 5 From 1               { 1 } -> { 1 } / { }                             NO
// Dequeue 5 From 5               { 1 2 3 4 5 } -> { } / { 1 2 3 4 5 }             YES
// Dequeue 5 From 6               { 1 2 3 4 5 6 } -> { 6 } / { 1 2 3 4 5 }         YES
// Dequeue 5 From 10              { 1 .. 10 } -> { 6 .. 10 } / { 1 .. 5 }          YES




@end
