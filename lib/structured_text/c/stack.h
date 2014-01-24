#ifndef __STACK_H__
#define __STACK_H__


#include <assert.h>  /* for assert */
#include <string.h>  /* for memcpy */

#include "common.h"

typedef struct {
    void *elems;
    int elemSize;
    int logLength;
    int allocLength;
} stack;



#define kInitialAllocationSize 4

static inline void StackInit(stack *const s, int elemSize)
{
    assert(elemSize > 0);
    s->elemSize = elemSize;
    s->logLength = 0;
    s->allocLength = kInitialAllocationSize;
    s->elems = ckalloc(kInitialAllocationSize * elemSize);
    assert(s->elems != NULL);
}

static inline void StackFree(stack *const s) {
    ckfree(s->elems);
}

static inline int StackEmpty(const stack *const s) {
    return !s->logLength;
}

static inline void StackPush(stack *const s, const void *const elemPtr) 
{
    if (s->logLength == s->allocLength) {
        s->allocLength *= 2;
        s->elems = ckrealloc(s->elems, s->allocLength * s->elemSize);
        assert(s->elems != NULL);
    }

    void *const destPtr = (char *)s->elems + s->logLength * s->elemSize;
    memcpy(destPtr,elemPtr,s->elemSize);
    s->logLength++;
}

static inline void StackPop(stack *const s)
{
    assert(!StackEmpty(s));
    s->logLength--;
}

static inline const void *StackTop(const stack *const s)
{
    assert(!StackEmpty(s));
    void *const sourcePtr = (char *) s->elems + (s->logLength - 1) * s->elemSize;
    return sourcePtr;

}


#endif /* __STACK_H__ */



