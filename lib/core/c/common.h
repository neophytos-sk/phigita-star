#ifndef _COMMON_H_
#define _COMMON_H_

#ifdef DEBUG
# include <stdio.h>
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

// standard typedefs
typedef signed char schar;
typedef signed char int8;
typedef short int16;
typedef int int32;
typedef long long int64;

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;
typedef unsigned long long uint64;

#undef _LONGLONG
#undef _ULONGLONG
#undef _LL_FORMAT

#define _LONGLONG(x) x##LL
#define _ULONGLONG(x) x##LL
#define _LL_FORMAT "ll"  // as in printf("%lld", ...)
#define _LL_FORMAT_W L"ll"

#ifdef __SOMETHING__
const uint8 kuint8max = (uint8) 0xFF;
const uint16 kuint16max = (uint16) 0xFFFF;
const uint32 kuint32max = (uint32) 0xFFFFFFFF;
const uint64 kuint64max = (uint64) _LONGLONG(0x7FFFFFFFFFFFFFFF);

const int8 kint8min = (int8) 0x80;
const int8 kint8max = (int8) 0x7F;
const int16 kint16min = (int16) 0x8000;
const int16 kint16max = (int16) 0x7FFF;
const int32 kint32min = (int32) 0x80000000;
const int32 kint32max = (int32) 0x7FFFFFFF;
const int64 kint64min = (int64) _LONGLONG(0x8000000000000000);
const int64 kint64max = (int64) _LONGLONG(0x7FFFFFFFFFFFFFFF);
#endif


#endif // _COMMON_H_
