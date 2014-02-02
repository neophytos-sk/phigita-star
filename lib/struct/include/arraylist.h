#ifndef __ARRAYLIST_H_
#define __ARRAYLIST_H__


#include <assert.h>  /* for assert */
#include <string.h>  /* for memcpy */

#include "common.h"
#include "object.h"

typedef struct {
    void *elems;
    int elemSize;
    int logLength;
    int allocLength;
} arraylist_t;

static inline void arraylist_foreach(arraylist_t *const list, void (fn)(char *));

static inline arraylist_t *arraylist_alloc()
{
    return (arraylist_t *) ckalloc(sizeof(arraylist_t));
}
static inline void arraylist_init(arraylist_t *const list, int initialAllocationSize, int elemSize)
{
    assert(elemSize > 0);
    list->elemSize = elemSize;
    list->logLength = 0;
    list->allocLength = initialAllocationSize;
    list->elems = ckalloc(initialAllocationSize * elemSize);
    assert(list->elems != NULL);
}

static inline void arraylist_cleanup(arraylist_t *const list) {
    arraylist_foreach(list, decr_ref_count);
    ckfree(list->elems);
}

static inline arraylist_t *const arraylist_new(int initialAllocationSize, int elemSize) {
    arraylist_t *list = arraylist_alloc();
    arraylist_init(list, initialAllocationSize, elemSize);
    return list;
}

static inline void arraylist_free(arraylist_t *list) {
    arraylist_cleanup(list);
    ckfree(list);
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
    assert(n > 0);
    list->allocLength = n;
    list->elems = ckrealloc(list->elems, n * list->elemSize);
    assert(list->elems != NULL);

}

static inline int arraylist_get(const arraylist_t *const list, size_t index, void **elemPtrPtr)
{
    assert(!arraylist_empty(list));
    assert(index >= 0 && index < arraylist_length(list));
    void *const sourcePtr = (char *) list->elems + index * list->elemSize;
    memcpy(elemPtrPtr, sourcePtr, sizeof(void *));
    return 1; // OK
}

static inline void arraylist_set(arraylist_t *const list, size_t index, void *const elemPtr)
{
    assert(index > 0 && index < arraylist_capacity(list));
    void *const destPtr = (char *)list->elems + index * list->elemSize;

    incr_ref_count(elemPtr);
    memcpy(destPtr, &elemPtr, list->elemSize);

    if (index > list->logLength) {
        list->logLength = index+1;
    }

}

static inline void arraylist_append(arraylist_t *const list, void *const elemPtr) 
{
    if (list->logLength == list->allocLength) {
        arraylist_resize(list, list->allocLength * 2);
    }


    arraylist_set(list, list->logLength, elemPtr);
    list->logLength++;
}

/* 
static inline int arraylist_top(const arraylist_t *const list, void **elemPtrPtr)
{
    arraylist_get(list, list->logLength - 1, elemPtrPtr);
    return 1;
}


static inline void arraylist_pop(arraylist_t *const list)
{
    assert(!arraylist_empty(list));
    // TODO: decr_ref_count
    list->logLength--;
}
*/

static inline void *arraylist_begin(arraylist_t *list)
{
    return list->elems;
}

static inline const void *arraylist_cbegin(const arraylist_t *const list)
{
    return list->elems;
}

static inline const void *arraylist_cend(const arraylist_t *const list)
{
    return (char *) list->elems + list->logLength * list->elemSize;
}

static inline void arraylist_foreach(arraylist_t *const list, void (fn)(char *))
{
   char **iter = arraylist_begin(list);
   const void *const end = arraylist_cend(list); 
   for (; iter != end; ++iter) {
       // DBG(printf("iter=%p\n",iter));
       if (*((char **) iter)) {
           fn(*((char **) iter));
       }
   }
}

#endif /* __ARRAYLIST_H__ */



