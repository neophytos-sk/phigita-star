#ifndef __ARRAYLIST_H_
#define __ARRAYLIST_H__


#include <assert.h>  /* for assert */
#include <string.h>  /* for memcpy */

#include "common.h"

typedef struct {
    void *elems;
    int elemSize;
    int logLength;
    int allocLength;
} arraylist_t;



#define kInitialAllocationSize 4

static inline void arraylist_init(arraylist_t *const list, int elemSize)
{
    assert(elemSize > 0);
    list->elemSize = elemSize;
    list->logLength = 0;
    list->allocLength = kInitialAllocationSize;
    list->elems = ckalloc(kInitialAllocationSize * elemSize);
    assert(list->elems != NULL);
}

static inline void arraylist_free(arraylist_t *const list) {
    ckfree(list->elems);
}

static inline int arraylist_empty(const arraylist_t *const list) {
    return !list->logLength;
}

static inline int arraylist_length(const arraylist_t *const list) {
    return list->logLength;
}

static inline int arraylist_capacity(const arraylist_t *const list) {
    return list->allocLength;
}

static inline void arraylist_resize(arraylist_t *const list, size_t n)
{
    list->allocLength = n;
    list->elems = ckrealloc(list->elems, n * list->elemSize);
    assert(list->elems != NULL);

    // size_t n = (index - list->logLength) * list->elemSize;
    // memset((char *) list->elems + list->logLength * list->elemSize, 0, n);
    // list->logLength = index + 1;

}

static inline const void *arraylist_get(const arraylist_t *const list, size_t index)
{
    assert(!arraylist_empty(list));
    assert(index >= 0 && index < arraylist_length(list));
    void *const sourcePtr = (char *) list->elems + index * list->elemSize;
    return sourcePtr;
}

static inline void arraylist_set(arraylist_t *const list, size_t index, const void *const elemPtr)
{
    assert(index > 0 && index < arraylist_capacity(list));
    void *const destPtr = (char *)list->elems + index * list->elemSize;
    memcpy(destPtr,elemPtr,list->elemSize);
    if (index > list->logLength) {
        list->logLength = index+1;
    }

}

static inline void arraylist_push(arraylist_t *const list, const void *const elemPtr) 
{
    if (list->logLength == list->allocLength) {
        arraylist_resize(list, list->allocLength * 2);
    }

    arraylist_set(list, list->logLength, elemPtr);
    list->logLength++;
}

static inline void arraylist_pop(arraylist_t *const list)
{
    assert(!arraylist_empty(list));
    list->logLength--;
}



#endif /* __ARRAYLIST_H__ */



