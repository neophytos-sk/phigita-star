/* $Id: dbg.c,v 1.3 2002/10/19 08:30:57 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * dbg.c: debug functions for bmf.
 */

#include "config.h"
#include "dbg.h"
#include <stdarg.h>


uint g_verbose = 0;

void verbose( int level, const char* fmt, ... )
{
    if( g_verbose >= level )
    {
        char str[4096];
        va_list v;
        va_start( v, fmt );
        vsnprintf( str, sizeof(str)-1, fmt, v );
        str[sizeof(str)-1] = '\0';
#ifdef _UNIX
        fputs( str, stderr );
#endif
#ifdef _WIN32
        ::OutputDebugString( str );
#endif
    }
}

#ifndef NDEBUG

void dbgout( const char* fmt, ... )
{
    char str[4096];
    va_list v;
    va_start( v, fmt );
    vsnprintf( str, sizeof(str)-1, fmt, v );
    str[sizeof(str)-1] = '\0';
#ifdef _UNIX
    fputs( str, stderr );
#endif
#ifdef _WIN32
    ::OutputDebugString( str );
#endif
}

/*
 * Heap management routines.  These routines use unbalanced binary trees to
 * keep track of allocations in an attempt to make them fast yet simple.
 *
 * Each block of memory consists of an alloc_node header, the requested
 * memory block, and guard bytes before and after the requested memory
 * block.  The requested memory block is filled with a semi-random byte
 * value to ensure that the caller does not rely on any particular initial
 * bit pattern (eg. a block of zeros or NULLs).  It is refilled with a
 * (possibly different) byte value after deallocation to ensure that the
 * caller doesn't attempt to use the freed memory.
 */

/* we need to use the real malloc and free */
#undef malloc
#undef free

typedef struct _alloc_node
{
    struct _alloc_node* lptr;
    struct _alloc_node* rptr;
    size_t              len;
    cpchar              file;
    uint                line;
} alloc_node;

static alloc_node* g_heap = NULL;

/* Our magic guard bytes */
static byte g_guard[] =
{
    0xDE, 0xAD, 0xBE, 0xEF, 0xDE, 0xAD, 0xBE, 0xEF,
    0xDE, 0xAD, 0xBE, 0xEF, 0xDE, 0xAD, 0xBE, 0xEF
};

void* debug_malloc( cpchar file, uint line, size_t n, int fill )
{
    byte* pmem = NULL;
    alloc_node* pnode;

    pmem = NULL;
    if( n == 0 )
    {
        n = 1;
    }
    pnode = (alloc_node*)malloc( n + 2*sizeof(g_guard) + sizeof(alloc_node) );
    if( pnode != NULL )
    {
        alloc_node** ppuplink;
        alloc_node* pcur;

        pmem = (byte*)pnode + sizeof(alloc_node) + sizeof(g_guard);
        memcpy( pmem - sizeof(g_guard), g_guard, sizeof(g_guard) );
        memset( pmem, fill, n );
        memcpy( pmem + n, g_guard, sizeof(g_guard) );

        pnode->lptr = pnode->rptr = NULL;
        pnode->len = n;
        pnode->file = file;
        pnode->line = line;
        ppuplink = &g_heap;
        pcur = g_heap;
        while( pcur != NULL )
        {
            if( pnode == pcur )
            {
                dbgout( "%s(%u): *** FATAL: duplicate memory allocated ***\n", file, line );
                assert( false );
                exit( -1 );
            }
            if( pnode < pcur )
            {
                ppuplink = &pcur->lptr;
                pcur = pcur->lptr;
            }
            else
            {
                ppuplink = &pcur->rptr;
                pcur = pcur->rptr;
            }
        }
        *ppuplink = pnode;
    }

    return pmem;
}

void debug_free( cpchar file, uint line, void* p )
{
    alloc_node** ppuplink;
    alloc_node* pcur;

    if( p == NULL )
    {
        return;
    }
    if( g_heap == NULL )
    {
        dbgout( "%s(%u): *** FATAL: delete with empty heap ***\n", file, line );
        assert( false );
        exit( -1 );
    }

    ppuplink = &g_heap;
    pcur = g_heap;
    while( pcur != NULL )
    {
        void* pcurblk = (char*)pcur + sizeof(alloc_node) + sizeof(g_guard);
        if( p == pcurblk )
        {
            byte* pmem = (byte*)p;
            if( memcmp( pmem - sizeof(g_guard), g_guard, sizeof(g_guard) ) != 0 ||
                memcmp( pmem + pcur->len, g_guard, sizeof(g_guard) ) != 0 )
            {
                dbgout( "%s(%u): *** FATAL: corrupted memory at %p\n", file, line, p );
                assert( false );
                exit( -1 );
            }
            memset( pmem, rand(), pcur->len );
            if( pcur->lptr && pcur->rptr )
            {
                /*
                 * node has both ptrs so replace it with left child and move
                 * right child to bottom right of left child's tree
                 */
                alloc_node* pend = pcur->lptr;
                while( pend->rptr ) pend = pend->rptr;
                *ppuplink = pcur->lptr;
                pend->rptr = pcur->rptr;
            }
            else
            {
                /* move child up */
                *ppuplink = (pcur->lptr) ? pcur->lptr : pcur->rptr;
            }
            free( pcur );
            return;
        }
        if( p < pcurblk )
        {
            ppuplink = &pcur->lptr;
            pcur = pcur->lptr;
        }
        else
        {
            ppuplink = &pcur->rptr;
            pcur = pcur->rptr;
        }
    }

    dbgout( "%s(%u): *** FATAL: delete on unalloced memory ***\n", file, line );
    assert( false );
    exit( -1 );
}

void* debug_realloc( cpchar file, uint line, void* p, size_t n )
{
    void* pnew;

    if( p == NULL )
    {
        pnew = debug_malloc( file, line, n, rand() );
    }
    else if( n == 0 )
    {
        debug_free( file, line, p );
        pnew = NULL;
    }
    else
    {
        alloc_node* pnode = (alloc_node*)((char*)p-sizeof(g_guard)-sizeof(alloc_node));
        pnew = debug_malloc( file, line, n, rand() );
        if( pnew != NULL )
        {
            memcpy( pnew, p, pnode->len );
            debug_free( file, line, p );
        }
    }

    return pnew;
}

char* debug_strdup( cpchar file, uint line, cpchar s )
{
    char* s2;
    uint sl = strlen(s);

    s2 = (char*)debug_malloc( file, line, sl+1, 0 );
    memcpy( s2, s, sl );
    s2[sl] = '\0';

    return s2;
}

char* debug_strndup( cpchar file, uint line, cpchar s, size_t n )
{
    char* s2;
    uint sl = strlen(s);

    sl = min( n-1, sl );
    s2 = (char*)debug_malloc( file, line, sl+1, 0 );
    memcpy( s2, s, sl );
    s2[sl] = '\0';

    return s2;
}

static void walk_alloc_tree( alloc_node* pcur, size_t* pttl )
{
    if( pcur != NULL )
    {
        walk_alloc_tree( pcur->lptr, pttl );
        dbgout( "%s(%u): %u bytes at %p\n", pcur->file, pcur->line,
                pcur->len, pcur+sizeof(alloc_node)+sizeof(g_guard) );
        *pttl += pcur->len;
        walk_alloc_tree( pcur->rptr, pttl );
    }
}

void dump_alloc_heap( void )
{
    if( g_heap != NULL )
    {
        size_t ttl = 0;
        dbgout( "\n" );
        dbgout( "Memory leaks detected\n" );
        dbgout( "=====================\n" );
        dbgout( "\n" );
        walk_alloc_tree( g_heap, &ttl );
        dbgout( "\n" );
        dbgout( "=====================\n" );
        dbgout( "Total bytes: %u\n", ttl );
        dbgout( "=====================\n" );
    }
}

#else /* ndef NDEBUG */

void dbgout( const char* fmt, ... )
{
    /* empty */
}

void dump_alloc_heap( void )
{
    /* empty */
}

#endif /* ndef NDEBUG */
