//
//  MikeOscarNovemberEchoYankeeAppDelegate.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-13.
//  Copyright 2011 N/A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BoardController.h"

@interface AppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) UIWindow *window;
@property (retain) BoardController *board;
@end
