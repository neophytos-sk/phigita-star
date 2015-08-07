#include "common.h"
#include "bloom.h"
#include "murmur_hash2.h"

static Tcl_ObjType bloom_filter_type;

// freeInternalRepProc
// * invoked when unset is called
static void
bf_free_rep(Tcl_Obj *obj)
{
    DBG(fprintf(stderr,"bf_free_rep\n"));
    bloom_filter_t *bf = (bloom_filter_t *) obj->internalRep.otherValuePtr;
    bf_free(bf);
}

// dupInternalRepProc
static void
bf_dup_rep(Tcl_Obj *obj, Tcl_Obj *dup)
{
    DBG(fprintf(stderr,"bf_dup_rep\n"));

    bloom_filter_t *bf = (bloom_filter_t *) obj->internalRep.otherValuePtr;
    dup->internalRep.otherValuePtr = Tcl_Alloc(sizeof(bf));
    memcpy(dup->internalRep.otherValuePtr, bf, sizeof(bf));
    dup->typePtr = &bloom_filter_type;
}

static void
bf_string_rep(Tcl_Obj *obj)
{
    DBG(fprintf(stderr,"bf_string_rep\n"));

    if (0) {
        bloom_filter_t *bf;
        bf = (bloom_filter_t *) obj->internalRep.otherValuePtr;
        obj->bytes = Tcl_Alloc(20);
        sprintf(obj->bytes, "_BF_%p", bf);
        obj->length = strlen(obj->bytes);
        // DBG(fprintf(stderr,"%s\n",obj->bytes));
    }


/* 
    num_bytes = (bf->num_bits / CHAR_BIT) + (bf->num_bits % CHAR_BIT ? 1 : 0);

    temp = Tcl_NewByteArrayObj(bf->bytes, num_bytes);
    Tcl_IncrRefCount(temp);
    str = Tcl_GetStringFromObj(temp, &obj->length);
    obj->bytes = Tcl_Alloc(obj->length + 1);
    memcpy(obj->bytes, str, obj->length + 1);
    Tcl_DecrRefCount(temp);
*/

}

static int
bf_from_any(Tcl_Interp *interp, Tcl_Obj *obj)
{
    // assert(0);
    return TCL_ERROR;
}

static Tcl_ObjType bloom_filter_type = {
    "bloom_filter_type",
    bf_free_rep,
    bf_dup_rep,
    bf_string_rep,
    bf_from_any
};



static int 
bf_CreateCmd (
    ClientData  clientData, 
    Tcl_Interp *interp, 
    int objc, 
    Tcl_Obj * const objv[] 
) {
    DBG(fprintf(stderr,"CreateCmd\n"));

    CheckArgs(3,3,1,"items_estimate false_positive_prob");

    int items_estimate;
    Tcl_GetIntFromObj(interp, objv[1], &items_estimate);
    double false_positive_prob;
    Tcl_GetDoubleFromObj(interp, objv[2], &false_positive_prob);

    Tcl_Obj *obj;
    bloom_filter_t *bf;

    obj = Tcl_NewObj();
    bf = Tcl_Alloc(sizeof(bloom_filter_t));

    bf_init(bf, MurmurHash2, items_estimate, false_positive_prob);

    // Tcl_InvalidateStringRep(obj);
    // obj->bytes = Tcl_Alloc(10);
    // sprintf(obj->bytes, "_BF_%p", bf);
    // DBG(fprintf(stderr,"%s\n",obj->bytes));
    obj->internalRep.otherValuePtr = bf;
    obj->typePtr = &bloom_filter_type;

    Tcl_SetObjResult(interp, obj);
    return TCL_OK;

}


static int 
bf_DestroyCmd (
    ClientData  clientData, 
    Tcl_Interp *interp, 
    int objc, 
    Tcl_Obj * const objv[] 
) {
    DBG(fprintf(stderr,"DestroyCmd\n"));

    CheckArgs(1,1,1,"bloom_filter_obj");

    bloom_filter_t *bf;
    bf = objv[1]->internalRep.otherValuePtr;
    bf_free(bf); // free(bf->bytes)
    Tcl_Free((char *) bf);

    return TCL_OK;

}

static int
bf_MayContainCmd (
    ClientData  clientData, 
    Tcl_Interp *interp, 
    int objc, 
    Tcl_Obj * const objv[] 
) {
    DBG(fprintf(stderr,"MayContainCmd\n"));

    CheckArgs(3,3,1,"bloom_filter_obj key");

    bloom_filter_t *bf;
    int len;
    const char *key;
    int may_contain_p;

    bf = objv[1]->internalRep.otherValuePtr;

    key = Tcl_GetStringFromObj(objv[2],&len);

    may_contain_p = bf_may_contain(bf,key,len);

    Tcl_SetObjResult(interp, Tcl_NewIntObj(may_contain_p));

    return TCL_OK;
}

static int
bf_InsertCmd (
    ClientData  clientData, 
    Tcl_Interp *interp, 
    int objc, 
    Tcl_Obj * const objv[] 
) {
    DBG(fprintf(stderr,"InsertCmd\n"));

    CheckArgs(3,3,1,"bloom_filter_obj key");

    bloom_filter_t *bf;
    int len;
    const char *key;

    bf = objv[1]->internalRep.otherValuePtr;

    key = Tcl_GetStringFromObj(objv[2],&len);

    bf_insert(bf,key,len);

    return TCL_OK;
}


#define CHAR_BIT 8

static int
bf_GetBytesCmd (
    ClientData  clientData, 
    Tcl_Interp *interp, 
    int objc, 
    Tcl_Obj * const objv[] 
) {
    DBG(fprintf(stderr,"GetBytesCmd\n"));

    CheckArgs(2,2,1,"bloom_filter_obj");

    bloom_filter_t *bf;
    int num_bytes;
    Tcl_Obj *obj;

    bf = objv[1]->internalRep.otherValuePtr;

    num_bytes = (bf->num_bits / CHAR_BIT) + (bf->num_bits % CHAR_BIT ? 1 : 0);

    uint8_t *newbytes;
    newbytes = Tcl_Alloc(num_bytes);
    bf_get_bytes(bf,newbytes);

    obj = Tcl_NewByteArrayObj(newbytes, num_bytes);
    Tcl_SetObjResult(interp, obj);
    return TCL_OK;
}

static int
bf_SetBytesCmd (
    ClientData  clientData, 
    Tcl_Interp *interp, 
    int objc, 
    Tcl_Obj * const objv[] 
) {
    DBG(fprintf(stderr,"SetBytesCmd\n"));

    CheckArgs(3,3,1,"bloom_filter_obj bytes");

    bloom_filter_t *bf;
    int num_bytes;
    Tcl_Obj *obj;

    bf = objv[1]->internalRep.otherValuePtr;

    num_bytes = (bf->num_bits / CHAR_BIT) + (bf->num_bits % CHAR_BIT ? 1 : 0);

    uint8_t *newbytes;
    int len;
    newbytes = Tcl_GetByteArrayFromObj(objv[2], &len);

    if (len != num_bytes) {
        DBG(fprintf(stderr, "len=%d num_bits=%d, num_bytes=%d\n", len, bf->num_bits, num_bytes));
        Tcl_AddErrorInfo(interp, "number of bytes in bloom filter does not match with given input");
        return TCL_ERROR;
    }

    bf_set_bytes(bf, newbytes, len);

    obj = Tcl_NewIntObj(num_bytes);
    Tcl_SetObjResult(interp, obj);
    return TCL_OK;
}


