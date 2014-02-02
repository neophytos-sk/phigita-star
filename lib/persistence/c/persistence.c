#include "tcl.h"

int persistence_GetData(Tcl_Interp *interp, Tcl_Obj *pathPtr, Tcl_Obj *content) {

  Tcl_Channel channel = Tcl_FSOpenFileChannel(interp,pathPtr,"r",0644);
  if (!channel) {
    return TCL_ERROR;
  }

  // TODO: get file size and use it in readchars (safer that way)
  Tcl_ReadChars(channel,content,-1,0);

  Tcl_Close(interp,channel);

  return TCL_OK;
}


int persistence_SetData(Tcl_Interp *interp, Tcl_Obj *pathPtr, Tcl_Obj *content) {

  Tcl_Channel channel = Tcl_FSOpenFileChannel(interp,pathPtr,"w",0644);
  if (!channel) {
printf("error opening file\n");
    return TCL_ERROR;
  }
printf("so far so good\n");

  int bytesToWrite = 0;
  const char *charBuf = Tcl_GetStringFromObj(content, &bytesToWrite);
  Tcl_WriteChars(channel, charBuf, bytesToWrite);

  Tcl_Close(interp,channel);

  return TCL_OK;
}

