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
                 (q.count == 5) &&    // size is 5
                 (q.location[0] == 1) && // entries are 1,2,3,4,5
                 (q.location[1] == 2) &&
                 (q.location[2] == 3) &&
                 (q.location[3] == 4) &&
                 (q.location[4] == 5),
                 @"result is %d, size of queue is %d should be 5, entries are is %f, %f, %f, %f, %f should be 1.0, 2.0, 3.0, 4.0, 5.0", 
                    result, q.count, q.location[0], q.location[1], q.location[2], q.location[3], q.location[4]); 
    
}

// Enqueue 10 with capacity 5     { } -> { }                                       NO

- (void) testEnqueue10Capacity5 {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 5];
    
    float n[10] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    
    BOOL result = [q enqueue: n count: 10];
    
    STAssertTrue(!result &&          // result bad
                 (q.count == 0),     // size is 0
                 @"result is %d (should be 0), size of queue is %d should be 0", 
                 result, q.count); 
}


// Dequeue 0 Empty                { }  -> { } /  { }                               YES

- (void) testDequeue0Empty {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 5];
    
    float n[5] = { 0, 0, 0, 0, 0 };
    
    BOOL result = [q dequeue: n count: 0];
    
    STAssertTrue(result &&          // result good
                 (q.count == 0),    // size is 0
                 @"result is %d (should be 1), size of queue is %d should be 0", 
                 result, q.count); 
}

// Dequeue 0 From 1               { 0 } -> { 0 }   /  { }                          YES

- (void) testDequeue0From1 {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 5];
    
    float n[5] = { 1, 0, 0, 0, 0 };
    
    [q enqueue: n count: 1];
    
    BOOL result = [q dequeue: n count: 0];
    
    STAssertTrue(result &&          // result good
                 (q.count == 1) &&    // size is 1
                 (q.location[0] == 1), 
                 @"result is %d (should be 1), size of queue is %d should be 1, element present is %f should be 1 ", 
                 result, q.count, q.location[0]); 
}



// Dequeue 0 From 5               { 1 2 3 4 5 } -> { 1 2 3 4 5 } / { }             YES

- (void) testDequeue0From5 {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 5];
    
    float n[5] = { 1, 2, 3, 4, 5 };
    
    [q enqueue: n count: 5];
    
    BOOL result = [q dequeue: n count: 0];
    
    STAssertTrue(result &&          // result good
                 (q.count == 5) &&    // size is 5
                 (q.location[0] == 1), 
                 @"result is %d (should be 1), size of queue is %d should be 5, elements are %f, %f, %f, %f, %f should be 1, 2, 3, 4, 5. ", 
                 result, q.count, q.location[0], q.location[1], q.location[2], q.location[3], q.location[4]); 
}

// Dequeue 0 From 10              { 1 .. 10 } -> { 1 .. 10 } /  { }	               YES

- (void) testDequeue0From10 {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 10];
    
    float n[10] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    
    [q enqueue: n count: 10];
    
    BOOL result = [q dequeue: n count: 0];
    
    STAssertTrue(result && (q.count == 10), @"result is %d, size of queue is %d should be 10", result, q.count);
}



// Dequeue 1 From Empty           { } -> { } / { }	                               NO

- (void) testDequeue1FromEmpty {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 10];
    
    float n[10] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    
//    [q enqueue: n count: 10];
    
    BOOL result = [q dequeue: n count: 1];
    
    STAssertTrue(!result && (q.count == 0), @"result is %d (should be 0), size of queue is %d should be 0", result, q.count);
}


// Dequeue 1 From 5               { 1 2 3 4 5 } -> { 2 3 4 5 } / { 1 }	           YES

- (void) testDequeue1From5 {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 10];
    
    float n[5] = { 1, 2, 3, 4, 5 };
    
    [q enqueue: n count: 5];
    
    float m[6] = { 0, 0, 0, 0, 0, 0 };
    
    BOOL result = [q dequeue: m count: 1];
    
    STAssertTrue(result && (q.count == 4) && m[0] == 1.0, @"result is %d (should be 0), size of queue is %d should be 4, dequeued a %f should be 1.0", result, q.count, m[0]);
}


// Dequeue 5 From 6               { 1 2 3 4 5 6 } -> { 6 } / { 1 2 3 4 5 }         YES

- (void) testDequeue5From6 {
    JDQueue *q = [[JDQueue alloc] initWithCapacity: 10];
    
    float n[6] = { 1, 2, 3, 4, 5, 6 };
    
    [q enqueue: n count: 6];
    
    float m[6] = { 0, 0, 0, 0, 0, 0 };
    
    BOOL result = [q dequeue: m count: 5];
    
    STAssertTrue(result && (q.count == 1) && m[3] == 4.0, @"result is %d (should be 0), size of queue is %d should be 4, dequeued a %f should be 4.0 in fourth position", result, q.count, m[3]);
}





@end
