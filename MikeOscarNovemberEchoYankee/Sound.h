//
//  Sound.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-08.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Sample.h"

@protocol Sound

- (void) play;
- (void) stop;

@end

@interface Note : NSObject <Sound> {}

+ (id) noteWithFrequency: (float) f;

- (void) play;
- (void) stop;

@property (assign) float frequency;

@end