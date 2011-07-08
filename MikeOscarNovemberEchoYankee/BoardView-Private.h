//
//  BoardView-Private.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-08.
//  Copyright 2011 N/A. All rights reserved.
//

@interface BoardView ()

@property (retain) NSMutableArray *slices;
@property (retain) NSMutableArray *sliceColours;
@property (retain) NSMutableArray *slicePositions;
@property (retain) NSMutableArray *slicePreviousStatus;

@property (retain) NSMutableArray *trackedTouches;
@property (retain) NSMutableArray *ignoredTouches;


@end