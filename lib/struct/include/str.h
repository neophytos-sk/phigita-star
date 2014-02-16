#ifndef __STR_H__
#define __STR_H__

#include "common.h"
#include "bool.h"
#include "object.h"


/* Extend object_t with string-specific fields, e.g. string_length, string_nbytes. */

static inline object_t *const string_new(const char *value, int nbytes) 
{

    /* nbytes is the string size in bytes and that is
     * diferent than what we pass to object_new(),
     * which is the size of the reference pointer to the string
     */

    object_t *objPtr = object_new(sizeof(const char *));

    object_set(objPtr, &value);

    objPtr->internalRep.longValue = nbytes;  // length of the string

    return objPtr;
}


/* number of bytes excluding the terminating character */
static inline size_t string_size(const object_t *objPtr)
{
    long n = objPtr->internalRep.longValue;
    if (n == -1) {
        const char *p = objPtr->bytes;
        while (*p != '\0')
            p++;

        n = p - objPtr->bytes;
    }
    return n;
    
}

/* string_length is reserved for the number of characters, e.g. in utf-8 encoding */
static inline size_t string_length(const object_t *objPtr)
{
    assert(false);  /* not implemented yet */
    return 0;
}

static inline const char *string_value(const object_t *const objPtr)
{
    if (!objPtr) {
        return 0;
    }

    const char **p = (const char **) object_value(objPtr);
    return *p;
}

/* copy constructor */
static inline object_t *string_copy(const char *bytes, int nbytes)
{
    /* will leak memory if not used with out own data structures */
    char *str = ckalloc(nbytes+1);
    memcpy(str, bytes, nbytes);
    str[nbytes] = '\0';
    // DBG(printf("nbytes=%d str=%.*s\n", nbytes, nbytes, bytes));
    return string_new(str, nbytes);

}

static inline object_t *string_duplicate(const object_t *const objPtr)
{
    return string_copy(string_value(objPtr), string_size(objPtr)); 
}

static inline void string_free(object_t *objPtr)
{
    object_free((object_t *) objPtr);
}

static inline bool_t string_empty(const object_t *objPtr)
{
    return !string_size(objPtr);
}



typedef unsigned int uint;

typedef struct {
    const char *data;
    uint length;
} string_t;


static inline bool_t StringEmpty(const string_t *const str) {
    return !str->length;
}

static inline void StringInit(string_t *str) {

    str->data = NULL;
    str->length = 0;

}

static inline void StringFree(string_t *str) {
    // do nothing
}

static inline void StringAssign(string_t *str, const char *data, uint length) {
    str->data = data;
    str->length = length;
}

static inline uint StringLength(const string_t *const str) {
    return str->length;
}

static inline const char *StringData(const string_t *const str) {
    return str->data;
}



#endif /* __STR_H__ */



