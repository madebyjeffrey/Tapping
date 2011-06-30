//
//  FIFO.h
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-27.
//  Copyright 2011 N/A. All rights reserved.
//

#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#import <Foundation/Foundation.h>


struct FIFO *FIFO_alloc(int length);
void FIFO_release(struct FIFO *fifo);
bool FIFO_push(struct FIFO *restrict fifo, float *restrict data, int count);
bool FIFO_pop(struct FIFO *restrict fifo, float *restrict data, int count);
int FIFO_size(struct FIFO *restrict fifo);
int FIFO_maxsize(struct FIFO *restrict fifo);