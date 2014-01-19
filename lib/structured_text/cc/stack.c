#include <assert.h>

#include <stdlib.h>  // for memcpy
#include <string.h>  // for malloc, free

#include "stack.h"

#define kInitialAllocationSize 4

void StackInit(stack *s, int elemSize)
{
    assert(elemSize > 0);
    s->elemSize = elemSize;
    s->logLength = 0;
    s->allocLength = kInitialAllocationSize;
    s->elems = malloc(kInitialAllocationSize * elemSize);
    assert(s->elems != NULL);
}

void StackFree(stack *s) {
    free(s->elems);
}

int StackEmpty(stack *s) {
    return !s->logLength;
}

void StackPush(stack *s, const void *elemPtr) 
{
    void *destPtr;
    if (s->logLength == s->allocLength) {
        s->allocLength *= 2;
        s->elems = realloc(s->elems, s->allocLength * s->elemSize);
        assert(s->elems != NULL);
    }

    destPtr = (char *)s->elems + s->logLength * s->elemSize;
    memcpy(destPtr, elemPtr, s->elemSize);
    s->logLength++;
}

void StackPop(stack *s)
{
    assert(!StackEmpty(s));
    s->logLength--;
}

const void *StackTop(stack *s)
{
    assert(!StackEmpty(s));
    const void *sourcePtr;
    sourcePtr = (const char *) s->elems + s->logLength * s->elemSize;
    return sourcePtr;

}

