//
//  Boardview.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-13.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol BoardDelegate

- (void) sliceTouched: (int) n;
- (void) sliceUntouched: (int) n;

@end

@interface TrackedLocation : NSObject
{}
@property (assign) CGPoint location;
@property (assign) int button;

+ (TrackedLocation*) location;
@end

@interface BoardView : UIView {
    
}

@property (retain) NSMutableArray *slices;
@property (retain) NSMutableArray *sliceColours;
@property (retain) NSMutableArray *slicePositions;
@property (retain) NSMutableArray *slicePreviousStatus;

@property (retain) NSMutableArray *trackedTouches;
@property (retain) NSMutableArray *ignoredTouches;


@property (assign) double innerRadius;
@property (assign) double outerRadius;
@property (assign) double separation;
@property (assign) id<BoardDelegate> delegate;


- (UIBezierPath*) sliceFrom: (double) start to: (double) end;
- (NSMutableArray*) makeSlices;
- (void) setButtonPressed: (int) n;
- (void) setButtonNormal: (int) n;


@end
