
#define CheckArgs(min,max,n,msg)		\
  if ((objc < min) || (objc >max)) {		\
    Tcl_WrongNumArgs(interp, n, objv, msg);	\
    return TCL_ERROR;				\
  }
