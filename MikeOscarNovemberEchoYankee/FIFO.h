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

struct FIFO {
    float *buffer;
    float *end;
    size_t max_length;
};


struct FIFO *FIFO_alloc(size_t length);
void FIFO_release(struct FIFO *fifo);
bool FIFO_push(struct FIFO *restrict fifo, const float *restrict data, size_t count);
bool FIFO_pop(struct FIFO *restrict fifo, float *restrict data, size_t count);
size_t FIFO_size(const struct FIFO *fifo);
size_t FIFO_maxsize(const struct FIFO *fifo);