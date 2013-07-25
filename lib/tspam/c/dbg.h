/* $Id: dbg.h,v 1.1 2002/10/14 07:09:51 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 */

#ifndef _DBG_H
#define _DBG_H

extern uint g_verbose;

void verbose( int level, const char* fmt, ... );

void dbgout( const char* fmt, ... );
void dump_alloc_heap( void );

#ifndef NDEBUG
void* debug_malloc  ( cpchar file, uint line, size_t n, int fill );
void  debug_free    ( cpchar file, uint line, void* p );
void* debug_realloc ( cpchar file, uint line, void* p, size_t n );
char* debug_strdup  ( cpchar file, uint line, cpchar s );
char* debug_strndup ( cpchar file, uint line, cpchar s, size_t n );

#define malloc(n)       debug_malloc    (__FILE__,__LINE__,n,rand())
#define calloc(n)       debug_calloc    (__FILE__,__LINE__,n,0)
#define free(p)         debug_free      (__FILE__,__LINE__,p)
#define realloc(p,n)    debug_realloc   (__FILE__,__LINE__,p,n)
#define strdup(s)       debug_strdup    (__FILE__,__LINE__,s)
#define strndup(s,n)    debug_strndup   (__FILE__,__LINE__,s,n)
#endif /* ndef NDEBUG */

#endif /* ndef _DBG_H */
