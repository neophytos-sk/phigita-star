#include "tcl.h"

int persistence_GetData(Tcl_Interp *interp, Tcl_Obj *pathPtr, Tcl_Obj *content) {

  Tcl_Channel channel = Tcl_FSOpenFileChannel(interp,pathPtr,"r",0644);
  if (!channel) {
    return TCL_ERROR;
  }

  Tcl_ReadChars(channel,content,-1,0);

  Tcl_Close(interp,channel);

  return TCL_OK;
}

