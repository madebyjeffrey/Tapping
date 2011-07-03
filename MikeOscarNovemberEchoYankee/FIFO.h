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

//#import <Foundation/Foundation.h>
#include <stdbool.h>

typedef struct {
    float *buffer;
    float *end;
    size_t max_length;
} FIFO;


FIFO *FIFO_alloc(size_t length);
void FIFO_release(FIFO *fifo);
bool FIFO_push(FIFO *restrict fifo, const float *restrict data, size_t count);
bool FIFO_pop(FIFO *restrict fifo, float *restrict data, size_t count);
size_t FIFO_size(const FIFO *fifo);
size_t FIFO_maxsize(const FIFO *fifo);