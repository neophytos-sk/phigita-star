

#ifdef DEBUG
# define DBG(x) x
#else
# define DBG(x) 
#endif

#ifndef NULL
#define NULL ((void *) 0)
#endif

#ifdef _TCL
#define CheckArgs(min,max,n,msg)		\
  if ((objc < min) || (objc >max)) {		\
    Tcl_WrongNumArgs(interp, n, objv, msg);	\
    return TCL_ERROR;				\
  }
#endif

#ifndef _TCL
#include <stdlib.h>  /* for malloc, free */
#define ckalloc(x) malloc(x)
#define ckfree(x) free(x)
#define ckrealloc(x,y) realloc(x,y)
#endif

