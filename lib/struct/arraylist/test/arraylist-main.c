/*
 * =====================================================================================
 *
 *       Filename:  test-arraylist.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  01/31/2014 11:39:57 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  YOUR NAME (), 
 *   Organization:  
 *
 * =====================================================================================
 */

#include "arraylist.h"
#include "integer.h"

#include <stdio.h>


int main(void) {
    int i, len;

    arraylist_t *listPtr = arraylist_new(6, sizeof(object_t *));

    object_t *x = integer_new(5);
    object_t *y = integer_new(7);
    incr_ref_count(x);
    incr_ref_count(y);

    arraylist_set(listPtr, 1, x);
    arraylist_set(listPtr, 3, y);
    arraylist_append(listPtr, x);
    arraylist_append(listPtr, integer_new(12));
    arraylist_append(listPtr, integer_new(23));
    arraylist_append(listPtr, integer_new(45));
   
    for (i = 0, len = arraylist_length(listPtr); i < len; i++) {
        object_t *objPtr;
        arraylist_get(listPtr, i, &objPtr);
        // printf("len=%d %p %p\n", len, x, objPtr);
        printf("len=%d %p %p %d refCount=%d\n", len, x, objPtr, integer_value(objPtr), objPtr ? objPtr->refCount: 0);
    }

    arraylist_free(listPtr);
    decr_ref_count(x);
    decr_ref_count(y);
}
