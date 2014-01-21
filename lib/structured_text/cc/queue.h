#ifndef __QUEUE_H
#define __QUEUE_H__

#include <assert.h>  // for assert
#include <stdlib.h>  // for memcpy
#include <string.h>  // for malloc, free

typedef struct queue_itemT {
    struct queue_itemT *next;
    void *data;
} queue_item_t;


typedef struct {
    queue_item_t *front;
    queue_item_t *back;
    int elemSize;
    int logLength;
} queue;


static inline void QueueInit(queue *const q, int elemSize)
{
    assert(elemSize > 0);
    q->elemSize = elemSize;
    q->logLength = 0;
    q->front = NULL;
    q->back = NULL;
}


static inline void QueueFree(queue *const q) {
    queue_item_t *curr = q->front;
    while(curr && curr != q->back) {
        queue_item_t *next = curr->next;
        free(curr->data);
        free(curr);
        curr = next;
    }
}

static inline int QueueEmpty(const queue *const q) {
    return !q->logLength;
}

static inline void QueuePush(queue *const q, const void *const elemPtr) 
{
    void *destPtr;
    destPtr = malloc(q->elemSize);
    memcpy(destPtr, elemPtr, q->elemSize);
    q->logLength++;

    queue_item_t *itemPtr = (queue_item_t *) malloc(sizeof(queue_item_t));
    itemPtr->data = destPtr;
    itemPtr->next = NULL;
    assert(itemPtr->data != NULL);

    if (q->back) {
        q->back->next = itemPtr;
    }
    q->back = itemPtr;
    
    if (q->front == NULL) {
        q->front = q->back;
    }
}

static inline void QueuePop(queue *const q)
{
    assert(!QueueEmpty(q));

    queue_item_t * itemPtr = q->front;
    q->front = q->front->next;
    free(itemPtr);

    if (q->front == NULL) {
        q->back = NULL;
    }

    q->logLength--;
}

const void *QueueFront(queue *q)
{
    assert(!QueueEmpty(q));
    return q->front->data;
}


#endif /* __QUEUE_H__ */



