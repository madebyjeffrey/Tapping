//
//  BoardController.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-13.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BoardView.h"

#import "Tone.h"

@interface BoardController : UIViewController <BoardDelegate>{
    
}

@property (assign) BoardView *board;

- (void) sliceTouched: (int) n;

//@property (retain) Tone *tone;


@end
