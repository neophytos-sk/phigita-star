#ifndef __COMMON_H__
#define __COMMON_H__


#ifndef _TCL
#include <string.h>  // for malloc, free
#define ckalloc(x) malloc(x)
#define ckfree(x) free(x)
#define ckrealloc(x,y) realloc(x,y)
#endif


#endif /* __COMMON_H__ */



