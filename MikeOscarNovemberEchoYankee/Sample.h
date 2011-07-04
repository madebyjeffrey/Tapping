//
//  WaveForm.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-07-03.
//  Copyright 2011 N/A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FIFO.h"

@interface WaveForm : NSObject {
    FIFO *wavedata;
}

+ waveWithFrequency: (float) f;

@end
