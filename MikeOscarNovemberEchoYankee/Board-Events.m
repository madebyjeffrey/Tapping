//
//  Board-Events.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-15.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Board-Events.h"

@implementation BoardView (Events)

- (int) insideButton: (CGPoint) p {
    CGAffineTransform centre = CGAffineTransformMakeTranslation(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    for (int i = 0; i < 6; i++) {
        CAShapeLayer *shape = [self.slices objectAtIndex: i];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithCGPath: shape.path];
        [path applyTransform: centre];
        
        if ([path containsPoint: p] == YES) {
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
        
        if ([path containsPoint: [touch locationInView: self]] == YES) {
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
        if ([self isInsideSlice: touch] == YES)
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
    
    
    for (i = 0; i< 6; i++) {
        if ([sliceChanges objectAtIndex: i] == [NSNumber numberWithBool: YES]) {
            [self setButtonPressed: i];
            [self.delegate sliceTouched: i];
        }
        else {
            [self setButtonNormal: i];
            [self.delegate sliceUntouched: i];
        }
    }
    
    NSLog(@"Number of items in array: %d, %d", [self.trackedTouches count], [self.ignoredTouches count]);
}
@end