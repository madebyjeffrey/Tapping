//
//  Sound.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-08.
//  Copyright 2011 N/A. All rights reserved.
//

#import "Sound.h"

@interface Note ()

@property (retain) Sample *buffer;

@end

@implementation Note

@synthesize buffer, frequency;

- (id) initWithFrequency: (float) f {
    self = [super init];
    
    if (self) {
        self.frequency = f;
    }
    
    return self;
}

- (id) init {
    return [self initWithFrequency: 440]; // default A note
}

+ (id) noteWithFrequency: (float) f {
    return [[[self alloc] initWithFrequency: f] autorelease];
}

- (void) play {
    
}

- (void) stop {
    
}



@end