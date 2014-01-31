

#ifdef DEBUG
# define DBG(x) x
#else
# define DBG(x) 
#endif

#define CheckArgs(min,max,n,msg)		\
  if ((objc < min) || (objc >max)) {		\
    Tcl_WrongNumArgs(interp, n, objv, msg);	\
    return TCL_ERROR;				\
  }

#ifndef _TCL
#include <string.h>  // for malloc, free
#define ckalloc(x) malloc(x)
#define ckfree(x) free(x)
#define ckrealloc(x,y) realloc(x,y)
#endif

