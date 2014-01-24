#ifndef __QUEUE_H
#define __QUEUE_H__

#include <assert.h>  /* for assert */
#include <string.h>  /* for memcpy */

#include "common.h"

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
        ckfree((char *) curr->data);
        ckfree((char *) curr);
        curr = next;
    }
}

static inline int QueueEmpty(const queue *const q) {
    return !q->logLength;
}

static inline void QueuePush(queue *const q, const void *const elemPtr) 
{
    queue_item_t *itemPtr = (queue_item_t *) ckalloc(sizeof(queue_item_t));
    itemPtr->next = NULL;
    itemPtr->data = ckalloc(q->elemSize);
    memcpy(itemPtr->data, elemPtr, q->elemSize);
    assert(itemPtr->data != NULL);
    q->logLength++;

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
    ckfree((char *) itemPtr);

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



