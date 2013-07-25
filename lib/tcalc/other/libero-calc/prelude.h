/*  ----------------------------------------------------------------<Prolog>-
    Name:       prelude.h
    Title:      Universal Header File for C programming
    Package:    Standard Function Library (SFL)

    Written:    93/03/29
    Revised:    96/05/29

    Version:    1.11
    <TABLE>
    1.11_PA     Added <iostream.h> if included in C++ program
    1.10_EDM    Changes for OS/2, define __OS2__
    1.09_PH     Added <sys/ioctl.h>, <sys/file.h> if __UNIX__
    1.08_PH     Added uid_t and gid_t if not __UNIX__
    1.07_PH     Removed <param.h> if __VMS__
    1.06_PH     Added <pwd.h> and <grp.h> if __UNIX__, FOREVER macro
    1.05_PH     Added <dirent.h> if __UNIX__, <dir.h> if __TURBOC__
    1.04_PH     Added sleep() macro for Windows
    </TABLE>

    Synopsis:   This header file encapsulates many generally-useful include
                files and defines lots of good stuff.  The intention of this
                header file is to hide the messy #ifdef's that you typically
                need to make real programs compile & run.  To use, specify
                as the first include file in your program.

    Notes:      Main contributors were:
                PH   Pieter Hintjens    <ph@imatix.com>
                PA   Pascal Anntonaux   <pascal@imatix.com>
                EDM  Ewen McNeill       <ewen@naos.co.nzo>

    Copyright:  Copyright (c) 1991-1996 iMatix N.V.
    License:    This is free software; you can redistribute it and/or modify
                it under the terms of the SFL License Agreement as provided
                in the file LICENSE.TXT.  This software is distributed in
                the hope that it will be useful, but without any warranty.
 ------------------------------------------------------------------</Prolog>-*/

#ifndef _PRELUDE_INCLUDED               /*  Allow multiple inclusions        */
#define _PRELUDE_INCLUDED


/*- Establish the compiler and computer system ------------------------------*/
/*
 *  Defines zero or more of these symbols, for use in any non-portable
 *  code:
 *
 *  __WINDOWS__         Microsoft C/C++ with Windows calls
 *  __MSDOS__           System is MS-DOS (set if __WINDOWS__ set)
 *  __VMS__             System is VAX/VMS or Alpha/OpenVMS
 *  __UNIX__            System is UNIX
 *  __OS2__             System is OS/2
 *  __MAC__             System is Mac/OS
 *
 *  __32BIT__           OS/compiler is 32 bits
 *  __64BIT__           OS/compiler is 64 bits
 *
 *  When __UNIX__ is defined, we also define exactly one of these:
 *
 *  __UTYPE_AUX         Apple AUX
 *  __UTYPE_DECALPHA    Digital UNIX (Alpha)
 *  __UTYPE_HPUX        HP/UX
 *  __UTYPE_IBMAIX      IBM RS/6000 AIX
 *  __UTYPE_LINUX       Linux
 *  __UTYPE_MIPS        MIPS (BSD 4.3/System V mixture)
 *  __UTYPE_NETBSD      NetBSD
 *  __UTYPE_NEXT        NeXT
 *  __UTYPE_SCO         SCO Unix
 *  __UTYPE_SUNOS       SunOS
 *  __UTYPE_SUNSOLARIS  Sun Solaris
 *                      ... these are the ones I know about so far.
 *  __UTYPE_GENERIC     Any other UNIX
 */

// #define __32BIT__                       /*  Assume 32-bit OS/compiler        */

#if (defined (WIN32) || defined (WINDOWS))
#   undef __WINDOWS__
#   define __WINDOWS__
#   undef __MSDOS__
#   define __MSDOS__
#endif

/*  MSDOS               Microsoft C                                          */
/*  _MSC_VER            Microsoft C                                          */
/*  __TURBOC__          Borland Turbo C                                      */
#if (defined (MSDOS) || defined (_MSC_VER) || defined (__TURBOC__))
#   undef __MSDOS__
#   define __MSDOS__
#endif

/*  EDM 96/05/28                                                             */
/*  __OS2__    Triggered by __EMX__ define and __i386__ define to avoid      */
/*             manual definition (eg, makefile) even though __EMX__ and      */
/*             __i386__ can be used on a MSDOS machine as well.  Here        */
/*             the same work is required at present.                         */
#if (defined (__EMX__) && defined (__i386__))
#   undef __OS2__
#   define __OS2__
#endif

/*  VMS                 VAX C (VAX/VMS)                                      */
/*  __VMS               Dec C (Alpha/OpenVMS)                                */
/*  __vax__             gcc                                                  */
#if (defined (VMS) || defined (__VMS) || defined (__vax__))
#   undef __VMS__
#   define __VMS__
#endif

/*  Untested                                                                 */
#if (defined (_MAC))
#   undef __MAC__
#   define __MAC__
#endif

/*  Try to define a __UTYPE_xxx symbol...                                    */
/*  unix                SunOS at least                                       */
/*  __unix__            gcc                                                  */
/*  _POSIX_SOURCE is various UNIX systems, maybe also VAX/VMS                */
#if (defined (unix) || defined (__unix__) || defined (_POSIX_SOURCE))
#   if (!defined (__VMS__))
#       undef __UNIX__
#       define __UNIX__
#       if (defined (__alpha))          /*  Digital UNIX is 64-bit           */
#           undef  __32BIT__
#           define __64BIT__
#           define __UTYPE_DECALPHA
#       endif
#   endif
#endif

#if (defined (_AUX))
#   define __UTYPE_AUX
#   define __UNIX__
#elif (defined (__hpux))
#   define __UTYPE_HPUX
#   define __UNIX__
#   define _INCLUDE_HPUX_SOURCE
#   define _INCLUDE_XOPEN_SOURCE
#   define _INCLUDE_POSIX_SOURCE
#elif (defined (_AIX) || defined (AIX))
#   define __UTYPE_IBMAIX
#   define __UNIX__
#elif (defined (linux))
#   define __UTYPE_LINUX
#   define __UNIX__
#elif (defined (Mips))
#   define __UTYPE_MIPS
#   define __UNIX__
#elif (defined (NetBSD))
#   define __UTYPE_NETBSD
#   define __UNIX__
#elif (defined (NeXT))
#   define __UTYPE_NEXT
#   define __UNIX__
#elif (defined (sco))
#   define __UTYPE_SCO
#   define __UNIX__
#elif (defined (SUNOS) || defined (SUN) || defined (sun))
#   define __UTYPE_SUNOS
#   define __UNIX__
#elif (defined (SOLARIS))
#   define __UTYPE_SUNSOLARIS
#   define __UNIX__
#elif (defined __UNIX__)
#   define __UTYPE_GENERIC
#endif


/*- Standard ANSI include files ---------------------------------------------*/

#ifdef __cplusplus
#include <iostream>
using namespace std;
#endif

#include <ctype.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <time.h>
#include <signal.h>
#include <errno.h>
#include <float.h>
#include <math.h>
#include <setjmp.h>


/*- System-specific include files -------------------------------------------*/

#if (defined (__MSDOS__))
#   if (defined (__WINDOWS__))          /*  When __WINDOWS__ is defined,     */
#       include <windows.h>             /*    so is __MSDOS__                */
#   endif
#   if (defined (__TURBOC__))
#       include <dir.h>
#   endif
#   include <dos.h>
#   include <io.h>
#   include <fcntl.h>
#   include <malloc.h>
#   include <sys\types.h>
#   include <sys\stat.h>
#endif

#if (defined (__UNIX__))
#   include <fcntl.h>
#   include <netdb.h>
#   include <unistd.h>
#   include <dirent.h>
#   include <pwd.h>
#   include <grp.h>
#   include <sys/types.h>
#   include <sys/param.h>
#   include <sys/socket.h>
#   include <sys/time.h>
#   include <sys/stat.h>
#   include <sys/ioctl.h>
#   include <sys/file.h>
#   include <netinet/in.h>
/*  Specific #include's for UNIX varieties                                   */
#   if (defined (__UTYPE_IBMAIX))
#       include <sys/select.h>
#   endif
#endif

#if (defined (__VMS__))
#   if (!defined (vaxc))
#       include <fcntl.h>               /*  Not provided by Vax C            */
#   endif
#   include <netdb.h>
#   include <unixio.h>
#   include <types.h>
#   include <socket.h>
#   include <time.h>
#   include <stat.h>
#   include <in.h>
#endif


/*- Data types --------------------------------------------------------------*/

typedef int             Bool;           /*  Boolean TRUE / FALSE value       */
typedef unsigned char   byte;           /*  Single unsigned byte = 8 bits    */
typedef unsigned short  dbyte;          /*  Double byte = 16 bits            */
typedef unsigned short  word;           /*  Alternative for double-byte      */


typedef uint32_t   qbyte;          /*  Quad byte = 32 bits              */



typedef void (*function) (void);        /*  Address of simple function       */
#define local static void               /*  Shorthand for local functions    */



/*- Check compiler data type sizes ------------------------------------------*/

#if (UCHAR_MAX != 0xFF)
#   error "Cannot compile: must change definition of 'byte'."
#endif
#if (USHRT_MAX != 0xFFFFU)
#   error "Cannot compile: must change definition of 'dbyte'."
#endif
#if (defined (__32BIT__))
#   if (ULONG_MAX != 0xFFFFFFFFUL)
#       error "Cannot compile: must change definition of 'qbyte'."
#   endif
#else
#   if (UINT_MAX != 0xFFFFFFFFU)
#       error "Cannot compile: must change definition of 'qbyte'."
#   endif
#endif


/*- Pseudo-functions --------------------------------------------------------*/

#define FOREVER         for (;;)            /*  FOREVER { ... }              */
#define until(expr)     while (!(expr))     /*  do { ... } until (expr)      */
#define streq(s1,s2)    (!strcmp ((s1), (s2)))
#define strneq(s1,s2)   (strcmp ((s1), (s2)))
#define strused(s)      (*(s) != 0)
#define strnull(s)      (*(s) == 0)
#define strclr(s)       (*(s) = 0)
#define strlast(s)      (s [strlen (s) - 1])
#define strterm(s)      (s [strlen (s)])

#define bit_msk(bit)    (1 << (bit))
#define bit_set(x,bit)  ((x) |=  bit_msk (bit))
#define bit_clr(x,bit)  ((x) &= ~bit_msk (bit))
#define bit_tst(x,bit)  ((x) &   bit_msk (bit))

#define tblsize(x)      (sizeof (x) / sizeof ((x) [0]))
#define tbllast(x)      (x [tblsize (x) - 1])

#if (defined (random))
#   undef random
#   undef randomize
#endif
#if (defined (min))
#   undef min
#   undef max
#endif

#if (defined (__32BIT__))
#define random(num)     (int) ((long) rand () % (num))
#else
#define random(num)     (int) ((int)  rand () % (num))
#endif
#define randomize()     srand ((unsigned) time (NULL))
#define min(a,b)        (((a) < (b))? (a): (b))
#define max(a,b)        (((a) > (b))? (a): (b))


/*- ASSERT ------------------------------------------------------------------*/

#if (defined (DEBUG))
    /*  Define _Assert function here locally                                 */
    local _Assert (char *File, unsigned Line)
    {
        fflush  (stdout);
        fprintf (stderr, "\nAssertion failed: %s, line %u\n", File, Line);
        fflush  (stderr);
        abort   ();
    }
#   define ASSERT(f)    \
        if (f)          \
            ;           \
        else            \
            _Assert (__FILE__, __LINE__)
#else
#   define ASSERT(f)
#endif


/*- Boolean operators and constants -----------------------------------------*/

#if (!defined (TRUE))
#    define TRUE        1               /*  ANSI standard                    */
#    define FALSE       0
#endif


/*- Symbolic constants ------------------------------------------------------*/

#define FORK_ERROR      -1              /*  Return codes from fork()         */
#define FORK_CHILD      0

#if (!defined (LINE_MAX))               /*  Length of line from text file    */
#   define LINE_MAX     255             /*    if not previously #define'd    */
#endif
#if (!defined (PATH_MAX))               /*  Length of path variable          */
#   define PATH_MAX     2048            /*    if not previously #define'd    */
#endif                                  /*  EDM 96/05/28                     */


/*- System-specific definitions ---------------------------------------------*/

/*  On most systems, main() returns 0 for Okay, 1+ for error.  On VAX/VMS
 *  this is more-or-less reversed.  We define RET_OKAY and RET_ERROR for
 *  use in main() functions:                                                 */

#if (defined (__VMS__))
#   define RET_OKAY     1               /*  Return codes for main()          */
#   define RET_ERROR    0               /*  VMS does it its own way.         */
#else
#   define RET_OKAY     0               /*  On non-VMS systems 0 is okay,    */
#   define RET_ERROR    1               /*    and 1 is an error.             */
#endif

/*  UNIX defines sleep() in terms of second; Windows defines Sleep() in
 *  terms of milliseconds.  We want to be able to use sleep() anywhere:      */

#if (defined (__WINDOWS__))
#   define sleep(a)     Sleep(a*1000)   /*  UNIX sleep() is seconds          */
#endif

/*  On SunOs, the ANSI C compiler costs extra, so many people install gcc
 *  but using the standard non-ANSI C library.  We have to make a few extra
 *  definitions for this case.  (Here we defined just what we needed for
 *  Libero -- we'll add code as required.)                                   */

#if (defined (__UTYPE_SUNOS))
#   if (!defined (_SIZE_T))             /*  Non-ANSI headers/libraries       */
#       define strerror(n)      sys_errlist [n]
#       define memmove(d,s,l)   bcopy (s,d,l)
        extern char *sys_errlist [];
#   endif
#endif

/*  We define constants for the way the current system formats filenames;
 *  we assume that the system has some type of path concept.  This code
 *  does not handle mixed-case filenames on Windows 95 or Windows NT.        */

#if (defined (__MSDOS__))               /*  Includes all Windows platforms   */
#   define PATHSEP      ";"             /*  Separates path components        */
#   define PATHEND      '\\'            /*  Delimits directory and filename  */
#   define PATHFOLD     TRUE            /*  Convert pathvalue to uppercase?  */
#   define NAMEFOLD     TRUE            /*  Convert filenames to uppercase?  */
#elif (defined (__VMS__))
#   define PATHSEP      ","
#   define PATHEND      ':'
#   define PATHFOLD     TRUE
#   define NAMEFOLD     TRUE
#elif (defined (__UNIX__))
#   define PATHSEP      ":"
#   define PATHEND      '/'
#   define PATHFOLD     FALSE
#   define NAMEFOLD     FALSE
#elif (defined (__OS2__))               /*  EDM 96/05/28                     */
#   define PATHSEP      ";"
#   define PATHEND      '\\'
#   define PATHFOLD     FALSE
#   define NAMEFOLD     FALSE
#else
#   error "No definitions for PATH constants"
#endif

/*  UNIX defines uid_t and gid_t; we need these at the portable level        */

#if !(defined (__UNIX__))
typedef int             gid_t;          /*  Group id type                    */
typedef int             uid_t;          /*  User id type                     */
#endif

#endif                                  /*  Include PRELUDE.H                */

