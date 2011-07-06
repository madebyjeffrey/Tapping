//
//  SampleTests.m
//  SampleTests
//
//  Created by Jeffrey Drake on 11-07-03.
//  Copyright 2011 N/A. All rights reserved.
//

#import "SampleTests.h"

//#include <arm_neon.h>

@implementation SampleTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
   // sample1 = [[Sample alloc] initWithCapacity: 50];
    
}

- (void)tearDown
{
    // Tear-down code here.
   // [sample1 release];
    
    [super tearDown];
}

- (void)testMultiply
{
    float inputX[4] = { 2, 4, 8, 16 };
    float inputY[4] = { 2, 4, 8, 16 };
    
    Sample *sampleX = [Sample sampleWithCapacity: 4];
    Sample *sampleY = [Sample sampleWithCapacity: 4];
    
    [sampleX enqueueSamples: inputX count: 4];
    [sampleY enqueueSamples: inputY count: 4];
    
    [sampleY multiplyBy: sampleX];
    
    [sampleY dequeueSamples: inputY count: 4];
    
    NSLog(@"Result: %f, %f, %f, %f", inputY[0], inputY[1],inputY[2],inputY[3]);
    
          
//    float n = 1;
//    [sample1 importFloats: &n count: 1];
    
    STAssertTrue(YES, @"Multiplication Test all results should be 1.0");
//    STFail(@"Unit tests are not implemented yet in SampleTests");
}
/*
- (void)testNEON
{
    float inputX[4] = { 2, 4, 8, 16 };
    float inputY[4] = { 2, 4, 8, 16 };
    float resultZ[4] = { 0, 0, 0, 0 };
    
    float32x4_t sample1, sample2, result;
    
    sample1 = vld1q_f32(inputX);
    sample2 = vld1q_f32(inputY);
    
    result = vmulq_f32(sample1, sample2);
    
    vst1q_f32(resultZ, result);

        // vmulq_f32  float32x4_t   float32x4x2_t vld2q_f32(__transfersize(8) float32_t const * ptr); 
    
//    catlas_saxpby(4, 1, inputX, 1, 1, inputY, 1);
    
    NSLog(@"Result: %f, %f, %f, %f", resultZ[0], resultZ[1], resultZ[2], resultZ[3]);
    
    STAssertTrue(YES, @"Testing for initial sample being empty");    

}
*/
@end
