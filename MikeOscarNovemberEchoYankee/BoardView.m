//
//  Boardview.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-13.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Boardview.h"
#import "Slice.h"

#import "BoardView-Private.h"

@implementation TrackedLocation

@synthesize location, button;

+ (TrackedLocation*) location {
    return [[[self alloc] init] autorelease];
}

@end



@implementation BoardView


@synthesize innerRadius, outerRadius, separation;
@synthesize slices, sliceColours, slicePositions;
@synthesize slicePreviousStatus;
@synthesize delegate;
@synthesize trackedTouches, ignoredTouches;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = nil;
        
        self.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
        
        self.sliceColours = [NSMutableArray arrayWithObjects: [UIColor redColor],
                                                              [UIColor yellowColor],
                                                              [UIColor greenColor],
                                                              [UIColor cyanColor],
                                                              [UIColor blueColor],
                                                              [UIColor purpleColor],
                                                              nil];
        
        
        self.slicePositions = [NSMutableArray arrayWithObjects: [NSValue valueWithCGPoint: CGPointMake(0, 50)], 
                                                                [NSValue valueWithCGPoint: CGPointMake(0, 50)],
                                                                [NSValue valueWithCGPoint: CGPointMake(0, 50)],
                                                                [NSValue valueWithCGPoint: CGPointMake(0, -50)],
                                                                [NSValue valueWithCGPoint: CGPointMake(0, -50)],
                                                                [NSValue valueWithCGPoint: CGPointMake(0, -50)], nil];  
        
        self.trackedTouches = [NSMutableArray arrayWithCapacity: 4];
        
        self.slicePreviousStatus = nil;
        
        self.multipleTouchEnabled = YES;

        self.slices = [self makeSlices];
        
        for (int i = 0; i < 6; i++) {
            [self setButtonNormal: i];
        }
        
        CGRect bounds = self.bounds;
        CGAffineTransform t = CGAffineTransformMakeTranslation(bounds.size.width / 2, bounds.size.height / 2);
        
        for (CAShapeLayer *s in self.slices) {
            [s setAffineTransform: t];
            [self.layer addSublayer: s];
            
        }
        
    }
    return self;
}

- (void)dealloc
{
    self.slices = nil;    
    [super dealloc];
}

- (void) setButtonPressed: (int) n {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CAShapeLayer *layer = [self.slices objectAtIndex: n];
    UIColor *colour = [self.sliceColours objectAtIndex: n];
    
    layer.strokeColor = [UIColor blackColor].CGColor;
    layer.fillColor = colour.CGColor;
    
    layer.position = CGPointMake(0, 2);
    //CGPointAdd([[self.slicePositions objectAtIndex: n] CGPointValue], CGPointMake(0, 2));
    
    
    
    layer.shadowRadius = 4;
    layer.shadowOpacity = 0.8;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowColor = [UIColor blackColor].CGColor;
    
    [CATransaction commit];
}

- (void) setButtonNormal: (int) n {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    CAShapeLayer *layer = [self.slices objectAtIndex: n];
    UIColor *colour = [self.sliceColours objectAtIndex: n];
    
    layer.strokeColor = [UIColor blackColor].CGColor;
    layer.fillColor = colour.CGColor;
    
//    CGPoint p = layer.position;
    layer.position = CGPointMake(0, 0); //[[self.slicePositions objectAtIndex: n] CGPointValue];

    
    layer.shadowRadius = 6;
    layer.shadowOpacity = 0.8;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowColor = [UIColor blackColor].CGColor;
    
    [CATransaction commit];
}

// Change implementation to use a CFArray with no callbacks (no retain!)
// then use the UITouch objects to track them

- (void)layoutSubviews {

    
    CGRect bounds = self.bounds;
    CGAffineTransform t = CGAffineTransformMakeTranslation(bounds.size.width / 2, bounds.size.height / 2);
    
    for (CAShapeLayer *s in self.slices) {
        [s setAffineTransform: t];
        [self.layer addSublayer: s];
        
    }

}

- (NSMutableArray*) makeSlices {
    NSMutableArray *s = [NSMutableArray arrayWithCapacity: 6];
    CAShapeLayer *l = nil;
   
    self.innerRadius = 50;
    self.outerRadius = 300;
    self.separation = 10;

    
    for (int i = 0; i < 6; i++) {
        l = [CAShapeLayer layer];
        UIBezierPath *path = [self sliceFrom: i*M_PI/3 to: i*M_PI/3+M_PI/3];

        CGPoint p = [[self.slicePositions objectAtIndex: i] CGPointValue];
        
        CGAffineTransform t = CGAffineTransformMakeTranslation(p.x, p.y);
        [path applyTransform: t];
        
        l.path = path.CGPath;
        
        l.shadowPath = l.path;
        [s addObject: l];
    }
    
    return s;
}

- (UIBezierPath*) sliceFrom: (double) start to: (double) end {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint A = positionFromAngle(start, self.separation, self.innerRadius);
    CGPoint B = positionFromAngle(end, -self.separation, self.innerRadius);
    CGPoint C = positionFromAngle(start, self.separation, self.outerRadius);
    CGPoint D = positionFromAngle(end, -self.separation, self.outerRadius);
    
    double angleA = angleFromPosition(A);
    double angleB = angleFromPosition(B);
    double angleC = angleFromPosition(C);
    double angleD = angleFromPosition(D);
    
    /* Draw arc from A to B, 
     line from B to D,
     arc from D to C,
     line back to A */
    
    [path setLineWidth: 1.0];
    [path moveToPoint: A];
    [path addArcWithCenter: CGPointZero radius: 50 startAngle: angleA endAngle:angleB clockwise:YES];
    
    [path addLineToPoint: D];
    [path addArcWithCenter: CGPointZero radius: 300 startAngle: angleD endAngle:angleC clockwise:NO];
    
    
    [path addLineToPoint: A];
    [path closePath];
    
    return path;
}




@end
