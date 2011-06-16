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



// does not use the above function yet
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    int i = 0;
    
    CGAffineTransform centre = CGAffineTransformMakeTranslation(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    for (UITouch *touch in touches) {
        CGPoint p = [touch locationInView: self];
        
        for (i = 0; i < 6; i++) {
            CAShapeLayer *shape = [self.slices objectAtIndex: i];
            
            UIBezierPath *path = [UIBezierPath bezierPathWithCGPath: shape.path];
            [path applyTransform: centre];
            
            if ([path containsPoint: p] == YES) {
                if (self.delegate != nil) {
                    TrackedLocation *loc = [TrackedLocation location];
                    loc.location = p;
                    loc.button = i;
                    
                    [self.trackedTouches addObject: loc];
                    
                    [self.delegate sliceTouched: i];
                }
            }
        }
    }
}    

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableArray *changedTouches = [NSMutableArray arrayWithCapacity: 3];
    
    // find moved touches that we are tracking, and update them
    for (UITouch *touch in touches) {
        for (int i = 0; i < [self.trackedTouches count]; i++) {
            TrackedLocation *location = [self.trackedTouches objectAtIndex: i];
            
            if (CGPointEqualToPoint([touch previousLocationInView: self], location.location) == YES) {
                location.location = [touch locationInView: self];
                [changedTouches addObject: location];
            }
        }
    }
    
    // if moved touch is in a new button send message
    for (TrackedLocation *location in changedTouches) {
        int button = [self insideButton: location.location];
        
        // no change
        if (button == location.button)
            continue;   
        // not inside a button
        else if (button == -1) {
            [self.delegate sliceUntouched: location.button];
            location.button = -1;
        }   // now inside of a button
        else {
            [self.delegate sliceTouched: button];
            location.button = button;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSMutableArray *changedTouches = [NSMutableArray arrayWithCapacity: 3];
    
    // Find the touches we are tracking that are done
    for (UITouch *touch in touches) {
        for (int i = 0; i < [self.trackedTouches count]; i++) {
            TrackedLocation *location = [self.trackedTouches objectAtIndex: i];
            
            if (CGPointEqualToPoint([touch previousLocationInView: self], location.location) == YES) {
                location.location = [touch previousLocationInView: self];
                [changedTouches addObject: location];
            }
            [self.trackedTouches removeObject: location];            
        }    
    }
    
    // Send out signals
    for (TrackedLocation *location in changedTouches) {
        int button = [self insideButton: location.location];
        
        if (button != -1)
            [self.delegate sliceUntouched: button];
        
    }
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

@end