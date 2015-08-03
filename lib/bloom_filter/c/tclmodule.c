#include "common.h"
#include "bloom.h"
#include "murmur_hash2.h"

static int 
bf_CreateCmd (
    ClientData  clientData, 
    Tcl_Interp *interp, 
    int objc, 
    Tcl_Obj * const objv[] 
) {
    DBG(fprintf(stderr,"CreateCmd\n"));

    CheckArgs(2,3,1,"items_estimate false_positive_prob ?newObjVar?");

    size_t items_estimate = 1000000;
    double false_positive_prob = 0.1;

    bloom_filter_t *bf = malloc(sizeof(bloom_filter_t));
    bf_init(bf, MurmurHash2, items_estimate, false_positive_prob);
    free(bf);

    return TCL_OK;

    #ifdef __SOMETHING__
    if (objc == 3) {
        newObjName = objv[2];
        setVariable = 1;
    }

    cbt_InternalType *internal = cbt_AllocInternal(interp);
    if (internal == NULL) {
        return TCL_ERROR;
    }

    Tcl_GetIntFromObj(interp,objv[1],&(internal->dataPtr->keylen));
    DBG(fprintf(stderr,"keylen=%d\n",internal->dataPtr->keylen));
    return cbt_ReturnHandle(interp,  internal, setVariable, newObjName);
    #endif // __SOMETHING__
}


