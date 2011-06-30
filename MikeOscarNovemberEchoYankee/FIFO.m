//
//  FIFO.c
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-27.
//  Copyright 2011 N/A. All rights reserved.
//

#include "FIFO.h"

struct FIFO {
    float *buffer;
    int max_length;
    
    float *end;
};

struct FIFO *FIFO_alloc(int length) {
    struct FIFO *restrict ptr = NULL;
    
    ptr = (struct FIFO*)calloc(1, sizeof(struct FIFO));
    
    ptr->buffer = (float*)calloc(length, sizeof(float));
    ptr->end = ptr->buffer;
    
    ptr->max_length = length;
    
    return ptr;
}

void FIFO_release(struct FIFO *fifo) {
    free(fifo->buffer);
    free(fifo);
}

bool FIFO_push(struct FIFO *restrict fifo, float *restrict data, int count) {
    if (!fifo || !data) return false;
    
    // test for the length available
    if ((fifo->max_length - (int)(fifo->end - fifo->buffer)) < (count * sizeof(float))) {
        NSLog(@"FIFO_push: not enough space to place data in buffer");
        
        return false;
    }
    
    memcpy(fifo->end, data, count*sizeof(float));
    fifo->end += count*sizeof(float);
    
//    if (errno == 0) return true;
//    else return false;
    
    return true;
}

bool FIFO_pop(struct FIFO *restrict fifo, float *restrict data, int count) {
    // move count items from the buffer
    memcpy(data, fifo->buffer, count*sizeof(float));
    // move empty space back to the beginning
    memmove(fifo->buffer, fifo->buffer + count*sizeof(float), fifo->end - (fifo->buffer + count * sizeof(float)));
    
    // reposition end pointer
    fifo->end = (float*)((unsigned int)fifo->end - (unsigned int)fifo->buffer + count*sizeof(float));
    
    return true;
}

int FIFO_size(struct FIFO *restrict fifo) {
    if (fifo) {
        int delta = fifo->end - fifo->buffer;
        
        if (delta % sizeof(float) != 0) {
            NSLog(@"FIFO_size: Panic -> buffer size is not a multiple of float size.");
            
            return 0;
        }
        
        return delta / 4;
    }
    
    return 0;
}

int FIFO_maxsize(struct FIFO *restrict fifo) {
    if (fifo) {
        int max_size = fifo->max_length;
        if (max_size % sizeof(float) != 0) {
            NSLog(@"FIFO_size: Panic -> max buffer size is not a multiple of float size.");
            
            return 0;
        }
        
        return max_size / 4;
    }
    
    return 0;
}
