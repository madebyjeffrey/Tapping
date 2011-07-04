//
//  SampleTests.m
//  SampleTests
//
//  Created by Jeffrey Drake on 11-07-03.
//  Copyright 2011 N/A. All rights reserved.
//

#import "SampleTests.h"



@implementation SampleTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    sample1 = [[Sample alloc] initWithLength: 50];
    
}

- (void)tearDown
{
    // Tear-down code here.
    [sample1 release];
    
    [super tearDown];
}

- (void)testExample
{
    float n = 1;
    [sample1 importFloats: &n count: 1];
    
    STAssertTrue(sample1.count == 1, @"Testing for initial sample being empty");
//    STFail(@"Unit tests are not implemented yet in SampleTests");
}

- (void)testExample2
{
    STAssertTrue(sample1.count == 0, @"Testing for initial sample being empty");    

}

@end
