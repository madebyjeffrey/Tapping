//
//  Slice.m
//  DigiBellum
//
//  Created by Jeffrey Drake on 11-06-10.
//  Copyright 2011 N/A. All rights reserved.
//

#include "Slice.h"

CGPoint CGPointAdd(CGPoint a, CGPoint b) {
    a.x += b.x;
    a.y += b.y;
    return a;
}

CGPoint positionFromAngle(double theta, double distance, double radius) {
    CGPoint onTheta = CGPointMake(radius * cos(theta), radius * sin(theta));
    CGPoint offTheta = CGPointMake(distance * -sin(theta), distance * cos(theta));
    
    return CGPointAdd(onTheta, offTheta);
}

double angleFromPosition(CGPoint pos) {
    return atan2(pos.y, pos.x);
}
