//
//  Slice.h
//  DigiBellum
//
//  Created by Jeffrey Drake on 11-06-10.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>

#include <math.h>

extern const double PI;

CGPoint CGPointAdd(CGPoint a, CGPoint b);
CGPoint positionFromAngle(double theta, double distance, double radius);
double angleFromPosition(CGPoint pos);
