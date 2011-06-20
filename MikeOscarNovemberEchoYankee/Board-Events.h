//
//  Board-Events.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-15.
//  Copyright 2011 N/A. All rights reserved.
//

#import "BoardView.h"

@interface BoardView (Events)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (BOOL) isInsideSlice: (UITouch*) touch;
- (int) insideButton: (CGPoint) p;

- (void) updateSlices;

@end
