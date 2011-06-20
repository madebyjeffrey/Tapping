//
//  AudioKit.m
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-19.
//  Copyright 2011 N/A. All rights reserved.
//

#import "AudioKit.h"


@implementation AKManager

- (id) init {
    self = [super init];
    
//    ALenum error;
    
    device = alcOpenDevice(NULL); // default device

    if (device == NULL) 
        goto deviceError;
    
    context = alcCreateContext(device, 0);
    
    if (context == NULL)
        goto contextError;
    
    alcMakeContextCurrent(context);

contextError:
    alcCloseDevice(device);
    
    
deviceError:
    return NULL;
}

- (void) dealloc {
    [super dealloc];
}

@end
