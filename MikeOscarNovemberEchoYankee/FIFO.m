//
//  FIFO.c
//  MikeOscarNovemberEchoYankee
//
//  Created by Jeffrey Drake on 11-06-27.
//  Copyright 2011 N/A. All rights reserved.
//

#include "FIFO.h"

FIFO *FIFO_alloc(size_t length) {
    FIFO *restrict ptr = NULL;
    
    ptr = (FIFO*)calloc(1, sizeof(FIFO));
    if (ptr == NULL) {
        return NULL;
    }
    
    ptr->buffer = (float*)calloc(length, sizeof(float));
    if (ptr->buffer == NULL) {
        free(ptr);
        return NULL;
    }
    
    ptr->end = ptr->buffer;
    ptr->max_length = length;
    
    return ptr;
}

void FIFO_release(FIFO *fifo) {
    if (fifo) {
        free(fifo->buffer);
        free(fifo);
    }
}

bool FIFO_push(FIFO *restrict fifo, const float *restrict data, size_t count) {
    if (!fifo || !data || count == 0) return false;
    
    // test for the length available
    if (fifo->max_length - (int)(fifo->end - fifo->buffer) < count) {
        return false;
    }
    
    memcpy(fifo->end, data, count*sizeof(float));
    fifo->end += count;
    
    return true;
}

bool FIFO_pop(FIFO *restrict fifo, float *restrict data, size_t count) {
    if (!fifo || !data) return false;
    if (count == 0 || FIFO_size(fifo) < count) return false;
    
    // move count items from the buffer
    memcpy(data, fifo->buffer, count*sizeof(float));
    // move empty space back to the beginning
    memmove(fifo->buffer, fifo->buffer + count, (fifo->end - fifo->buffer - count) * sizeof(float));
    
    // reposition end pointer
    fifo->end -= count;
    
    return true;
}

size_t FIFO_size(const FIFO *fifo) {
    if (fifo) {
        return (size_t)(fifo->end - fifo->buffer);
    }
    
    return 0;
}

size_t FIFO_maxsize(const FIFO *fifo) {
    if (fifo) {
        return fifo->max_length;
    }
    
    return 0;
}
