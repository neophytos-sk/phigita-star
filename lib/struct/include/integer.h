/*
 * =====================================================================================
 *
 *       Filename:  integer.h
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  02/01/2014 02:00:45 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Neophytos Demetriou (), 
 *   Organization:  
 *
 * =====================================================================================
 */

#ifndef __INTEGER_H__
#define __INTEGER_H__

#include "object.h"

object_t *const integer_new(int value) 
{
    object_t *objPtr = object_new(sizeof(int));

    object_set(objPtr, &value);

    return objPtr;
}

int integer_value(const object_t *const objPtr)
{
    if (!objPtr) {
        return 0;
    }

    const char *bytes;

    bytes = object_value(objPtr);
    if (!bytes) {
        return 0;
    }

    return *((int *) bytes);
}

void integer_free(object_t *objPtr)
{
    object_free((object_t *) objPtr);
}

#endif
