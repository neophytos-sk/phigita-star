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
    int refCount;  /* when zero the object will be freed */
    char *bytes;
    int nbytes;

    union {                     /* The internal representation: */
        long longValue;         /*   - a long integer value. */
        double doubleValue;     /*   - a double-precision floating value. */
        void *otherValuePtr;    /*   - another, type-specific value. */
        /*WideInt wideValue;*/  /*   - a long long value. */
        struct {                /*   - internal rep as two pointers. */
            void *ptr1;
            void *ptr2;
        } twoPtrValue;
        struct {                /*   - internal rep as a wide int, tightly
                                 *     packed fields. */
            void *ptr;          /* Pointer to digits. */
            unsigned long value;/* Alloc, used, and signum packed into a
                                 * single word. */
        } ptrAndLongRep;

    } internalRep;

} object_t;

static inline object_t *object_alloc()
{
    return (object_t *) ckalloc(sizeof(object_t));
}

static inline object_t *object_new(int nbytes)
{
    object_t *objPtr = object_alloc();

    /* If nbytes is 0, then malloc() returns either NULL,
     * or a unique pointer that can later be successfully
     * passed to free()
     */
    objPtr->bytes = (char *) ckalloc(nbytes);

    objPtr->nbytes = nbytes;

    objPtr->refCount = 0;

    return objPtr;
}

static inline size_t object_size(const object_t *objPtr)
{
    return objPtr->nbytes;
}

static inline void object_cleanup(object_t *objPtr)
{
    if (object_size(objPtr)) {
        ckfree(objPtr->bytes);
    }
}

static inline void object_free(object_t *objPtr)
{
    assert(objPtr->refCount == 0);

    // DBG(printf("object_free: %p\n", objPtr));
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

    // DBG(printf("decr_ref_count: objPtr=%p refCount=%d\n", objPtr, objPtr->refCount));

    if (--objPtr->refCount == 0) {
        object_free(objPtr);
    }

}

static inline void incr_ref_count(object_t *objPtr)
{
    objPtr->refCount++;    
}

#endif
