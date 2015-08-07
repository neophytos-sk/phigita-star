#include "common.h"
#include "murmur_hash2.h"

static int 
murmur_hashCmd (
    ClientData  clientData, 
    Tcl_Interp *interp, 
    int objc, 
    Tcl_Obj * const objv[] 
) {
    DBG(fprintf(stderr,"murmur_hashCmd\n"));

    CheckArgs(3,3,1,"key seed");
    
    int len;
    const char * key;
    key = Tcl_GetStringFromObj(objv[1], &len);

    int seed;
    if (TCL_OK != Tcl_GetIntFromObj(interp,objv[2],&seed)) {
        return TCL_ERROR; 
    }

    fprintf(stderr,"key=%s\n",key);

    uint32_t hash = MurmurHash2(key,len,seed);

    Tcl_SetObjResult(interp, Tcl_NewIntObj(hash));

    return TCL_OK;
}



