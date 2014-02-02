/*
 * =====================================================================================
 *
 *       Filename:  object.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  02/01/2014 12:20:59 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Neophytos Demetriou (), 
 *   Organization:  
 *
 * =====================================================================================
 */

#ifndef __OBJECT_H__
#define __OBJECT_H__

typedef struct {
    char *bytes;
    int nbytes;
    int refCount;

} object_t;

static inline object_t *object_alloc()
{
    return (object_t *) ckalloc(sizeof(object_t));
}

static inline object_t *object_new(int nbytes)
{
    object_t *objPtr = object_alloc();

    objPtr->bytes = (char *) ckalloc(nbytes);

    objPtr->nbytes = nbytes;

    objPtr->refCount = 0;

    return objPtr;
}

static inline void object_cleanup(object_t *objPtr)
{
    ckfree(objPtr->bytes);
}

static inline void object_free(object_t *objPtr)
{
    assert(objPtr->refCount == 0);

    DBG(printf("object_free: %p\n", objPtr));
    object_cleanup(objPtr); 
    ckfree(objPtr);
}

static inline void object_set(object_t *objPtr, void *bytes)
{
    memcpy(objPtr->bytes, bytes, objPtr->nbytes);
}

static inline const char *object_value(const object_t *const objPtr)
{
    return objPtr->bytes;
}

static inline void decr_ref_count(object_t *objPtr)
{
    assert(objPtr->refCount > 0);

    printf("decr_ref_count: objPtr=%p refCount=%d\n", objPtr, objPtr->refCount);

    if (--objPtr->refCount == 0) {
        object_free(objPtr);
    }

}

static inline void incr_ref_count(object_t *objPtr)
{
    objPtr->refCount++;    
}

#endif
