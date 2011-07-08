//
//  Board-Events.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-15.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Board-Events.h"
#import "BoardView-Private.h"

@implementation BoardView (Events)

- (int) insideButton: (CGPoint) p {
    CGAffineTransform centre = CGAffineTransformMakeTranslation(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    for (int i = 0; i < 6; i++) {
        CAShapeLayer *shape = [self.slices objectAtIndex: i];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithCGPath: shape.path];
        [path applyTransform: centre];
        
        if ([path containsPoint: p]) {
            return i;
        }
    }
    
    return -1; // @throw ist verboten!
}

- (BOOL) isInsideSlice: (UITouch*) touch {
    CGAffineTransform centre = CGAffineTransformMakeTranslation(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    for (CAShapeLayer *shape in self.slices) {
        UIBezierPath *path = [UIBezierPath bezierPathWithCGPath: shape.path];
        [path applyTransform: centre];
        
        if ([path containsPoint: [touch locationInView: self]]) {
            return YES;
        }
    }
    
    return NO;
}

/*
 *  If the touch starts on a slice, then it will be tracked. Otherwise ignored.
 *
 *  When the touch ends or is cancelled its tracking/ignoring is over.
 *
 *  After all of these events the slices are updated to their state.
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // touches over a button go in trackedTouches others in ignoredTouches
    
    for (UITouch *touch in touches) {
        if ([self isInsideSlice: touch])
            [self.trackedTouches addObject: touch];
        else
            [self.ignoredTouches addObject: touch];
    }
    
    [self updateSlices];
}    

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self updateSlices];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //
    for (UITouch *touch in touches) {
        [self.trackedTouches removeObject: touch];
        [self.ignoredTouches removeObject: touch];
    }
    
    [self updateSlices];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [self.trackedTouches removeObject: touch];
        [self.ignoredTouches removeObject: touch];
    }
    
    [self updateSlices];
}

- (void) updateSlices {
    // determines what has changed, and sends events
    
    NSMutableArray *sliceChanges = [NSMutableArray arrayWithCapacity: 6];
    
    int i;
    
    for (i = 0; i < 6; i++) {
        [sliceChanges addObject: [NSNumber numberWithBool: NO]];
    }
    
    for (UITouch *touch in self.trackedTouches) {
        CGPoint p = [touch locationInView: self];
        
        int button = [self insideButton: p];
        
        if (button != -1) {
            [sliceChanges replaceObjectAtIndex: button withObject: [NSNumber numberWithBool: YES]];
        }
    }
    
    if (self.slicePreviousStatus == nil) {
        // if no previous state, only send presses
        
        for (i = 0; i < 6; i++) {
            if ([[sliceChanges objectAtIndex: i] boolValue]) {
                [self setButtonPressed: i];
                [self.delegate sliceTouched: i];
            }
        }
        


    }
    else {
        // if we have previous state compare the two and send changes
        for (i = 0; i< 6; i++) {
            if ([[sliceChanges objectAtIndex: i] boolValue] != [[self.slicePreviousStatus objectAtIndex: i] boolValue]) {
                if ([[sliceChanges objectAtIndex: i] boolValue]) {
                    [self setButtonPressed: i];
                    [self.delegate sliceTouched: i];
                }
                else {
                    [self setButtonNormal: i];
                    [self.delegate sliceUntouched: i];
                }
            }
        }

    }
    
    // set previous state
    self.slicePreviousStatus = sliceChanges;
    
//    NSLog(@"Number of items in array: %d, %d", [self.trackedTouches count], [self.ignoredTouches count]);
}
@end