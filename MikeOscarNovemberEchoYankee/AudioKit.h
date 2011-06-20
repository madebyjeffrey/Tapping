//
//  AudioKit.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-19.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>


@interface AKManager : NSObject {
    ALCdevice *device;
    ALCcontext *context;
}


- (id) init;


@end
