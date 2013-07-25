/* $Id: lex.c,v 1.18 2002/10/20 20:29:15 tommy Exp $ */

/*
 * Copyright (c) 2002 Tom Marshall <tommy@tig-grr.com>
 *
 * This program is free software.  It may be distributed under the terms
 * in the file LICENSE, found in the top level of the distribution.
 *
 * lex.c: generate token stream for bmf.
 */

#include "config.h"
#include "dbg.h"
#include "str.h"
#include "lex.h"

static cpchar g_htmltags[] =
{
    "abbr",
    "above",
    "accesskey",
    "acronym",
    "align",
    "alink",
    "all",
    "alt",
    "applet",
    "archive",
    "axis",
    "basefont",
    "baseline",
    "below",
    "bgcolor",
    "big",
    "body",
    "border",
    "bottom",
    "box",
    "button",
    "cellpadding",
    "cellspacing",
    "center",
    "char",
    "charoff",
    "charset",
    "circle",
    "cite",
    "class",
    "classid",
    "clear",
    "codebase",
    "codetype",
    "color",
    "cols",
    "colspan",
    "compact",
    "content",
    "coords",
    "data",
    "datetime",
    "declare",
    "default",
    "defer",
    "dfn",
    "dir",
    "disabled",
    "face",
    "font",
    "frameborder",
    "groups",
    "head",
    "headers",
    "height",
    "href",
    "hreflang",
    "hsides",
    "hspace",
    "http-equiv",
    "iframe",
    "img",
    "input",
    "ismap",
    "justify",
    "kbd",
    "label",
    "lang",
    "language",
    "left",
    "lhs",
    "link",
    "longdesc",
    "map",
    "marginheight",
    "marginwidth",
    "media",
    "meta",
    "middle",
    "multiple",
    "name",
    "nohref",
    "none",
    "noresize",
    "noshade",
    "nowrap",
    "object",
    "onblur",
    "onchange",
    "onclick",
    "ondblclick",
    "onfocus",
    "onkeydown",
    "onkeypress",
    "onkeyup",
    "onload",
    "onmousedown",
    "onmousemove",
    "onmouseout",
    "onmouseover",
    "onmouseup",
    "onselect",
    "onunload",
    "param",
    "poly",
    "profile",
    "prompt",
    "readonly",
    "rect",
    "rel",
    "rev",
    "rhs",
    "right",
    "rows",
    "rowspan",
    "rules",
    "samp",
    "scheme",
    "scope",
    "script",
    "scrolling",
    "select",
    "selected",
    "shape",
    "size",
    "small",
    "span",
    "src",
    "standby",
    "strike",
    "strong",
    "style",
    "sub",
    "summary",
    "sup",
    "tabindex",
    "table",
    "target",
    "textarea",
    "title",
    "top",
    "type",
    "usemap",
    "valign",
    "value",
    "valuetype",
    "var",
    "vlink",
    "void",
    "vsides",
    "vspace",
    "width"
};
static const uint g_nhtmltags = sizeof(g_htmltags)/sizeof(cpchar);

static cpchar g_ignoredheaders[] =
{
    "Date:",
    "Delivery-date:",
    "Message-ID:",
    "X-Sorted:",
    "X-Spam-"
};
static const uint g_nignoredheaders = sizeof(g_ignoredheaders)/sizeof(cpchar);

static inline bool_t is_whitespace( int c )
{
    return ( c == ' ' || c == '\t' || c == '\r' );
}

static inline bool_t is_base64char(c)
{
    return ( isalnum(c) || (c == '/' || c == '+') );
}

static inline bool_t is_wordmidchar(c)
{
    return ( isalnum(c) || c == '$' || c == '\'' || c == '.' || c == '-' );
}

static inline bool_t is_wordendchar(c)
{
    return ( isalnum(c) || c == '$' );
}

static inline bool_t is_htmltag( cpchar p, uint len, uint* ptoklen )
{
    int lo, hi, mid, minlen, cmp;

    *ptoklen = 0;

    hi = g_nhtmltags-1;
    lo = -1;
    while( hi-lo > 1 )
    {
        mid = (hi+lo)/2;
        minlen = min( strlen(g_htmltags[mid]), len );
        cmp = strncmp( g_htmltags[mid], p, minlen );
        if( cmp > 0 || (cmp == 0 && minlen < len && !islower(p[minlen])) )
            hi = mid;
        else
            lo = mid;
    }
    minlen = min( strlen(g_htmltags[hi]), len );
    if( len == minlen || strncmp(g_htmltags[hi], p, minlen) != 0 )
    {
        return false;
    }

    /* check if is_word() will have a longer match */
    if( is_wordendchar(p[minlen]) )
    {
        return false;
    }
    if( is_wordmidchar(p[minlen]) && is_wordendchar(p[minlen+1]) )
    {
        return false;
    }

    *ptoklen = strlen(g_htmltags[hi]);

    return true;
}

static inline bool_t is_htmlcomment( cpchar p, uint len, uint* ptoklen )
{
    *ptoklen = 0;

    if( len >=4 && memcmp( p, "<!--", 4 ) == 0 )
    {
        *ptoklen = 4;
        return true;
    }
    if( len >= 3 && memcmp( p, "-->", 3 ) == 0 )
    {
        *ptoklen = 3;
        return true;
    }

    return false;
}

static inline bool_t is_base64( cpchar p, uint len, uint* ptoklen )
{
    *ptoklen = 0;
    while( len > 0 )
    {
        if( *p != '\n' && *p != '\r' && !is_base64char(*p) )
        {
            return false;
        }
        p++;
        len--;
        (*ptoklen)++;
    }
    return true;
}

static inline bool_t is_mimeboundary( cpchar p, uint len, uint* ptoklen )
{
    *ptoklen = 0;

    if( len < 3 || p[0] != '-' || p[1] != '-' )
    {
        return false;
    }
    p += 2;
    len -= 2;
    *ptoklen += 2;
    while( len > 0 )
    {
        if( is_whitespace(*p) )
        {
            return false;
        }
        if( *p == '\n' || *p == '\r' )
        {
            break;
        }
        p++;
        len--;
        (*ptoklen)++;
    }
    return true;
}

static inline bool_t is_ipaddr( cpchar p, uint len, uint* ptoklen )
{
    uint noctets, ndigits;

    *ptoklen = 0;

    noctets = 0;
    while( len > 0 && noctets < 4 )
    {
        ndigits = 0;
        while( len > 0 && isdigit(*p) )
        {
            ndigits++;
            p++;
            len--;
            (*ptoklen)++;
        }
        if( ndigits == 0 || ndigits > 3 )
        {
            return false;
        }
        noctets++;
        if( noctets < 4 )
        {
            if( *p != '.' )
            {
                return false;
            }
            p++;
            len--;
            (*ptoklen)++;
        }
    }
    if( noctets < 4 )
    {
        return false;
    }
    return true;
}

static inline bool_t is_word( cpchar p, uint len, uint* ptoklen )
{
    if( len < 3 )
    {
        return false;
    }
    if( !(isalpha(*p) || *p == '$') )
    {
        return false;
    }
    *ptoklen = 1;
    p++;
    len--;
    while( len > 0 )
    {
        if( !is_wordmidchar(*p) )
        {
            break;
        }
        (*ptoklen)++;
        p++;
        len--;
    }
    while( *ptoklen >= 3 && !is_wordendchar(*(p-1)) )
    {
        (*ptoklen)--;
        p--;
        len++;
    }
    if( *ptoklen < 3 )
    {
        return false;
    }

    return true;
}

static inline bool_t is_ignoredheader( cpchar p, uint len, uint* ptoklen )
{
    int lo, hi, mid, minlen, cmp;

    hi = g_nignoredheaders-1;
    lo = -1;
    while( hi-lo > 1 )
    {
        mid = (hi+lo)/2;
        minlen = min( strlen(g_ignoredheaders[mid]), len );
        cmp = strncasecmp( g_ignoredheaders[mid], p, minlen );
        if( cmp >= 0 )
            hi = mid;
        else
            lo = mid;
    }
    minlen = min( strlen(g_ignoredheaders[hi]), len );
    if( len == minlen || strncasecmp(g_ignoredheaders[hi], p, minlen) != 0 )
    {
        return false;
    }
    *ptoklen = len;
    return true;
}

static inline bool_t is_mailerid( cpchar p, uint len, uint* ptoklen )
{
    if( len < 4 || strncmp( p, "\tid ", 4 ) != 0 )
    {
        return false;
    }
    *ptoklen = len;
    return true;
}

static inline bool_t is_spamtext( cpchar p, uint len, uint* ptoklen )
{
    if( len < 5 || strncmp( p, "SPAM:", 5 ) != 0 )
    {
        return false;
    }
    *ptoklen = len;
    return true;
}

static inline bool_t is_smtpid( cpchar p, uint len, uint* ptoklen )
{
    if( len < 8 || strncmp( p, "SMTP id ", 8 ) != 0 )
    {
        return false;
    }
    *ptoklen = len;
    return true;
}

static inline bool_t is_boundaryequal( cpchar p, uint len, uint* ptoklen )
{
    if( len < 9 || strncmp( p, "boundary=", 9 ) != 0 )
    {
        return false;
    }
    *ptoklen = len;
    return true;
}

static inline bool_t is_nameequal( cpchar p, uint len, uint* ptoklen )
{
    if( len < 6 || strncmp( p, "name=\"", 6 ) != 0 )
    {
        return false;
    }
    *ptoklen = 6;
    return true;
}

static inline bool_t is_filenameequal( cpchar p, uint len, uint* ptoklen )
{
    if( len < 10 || strncmp( p, "filename=\"", 10 ) != 0 )
    {
        return false;
    }
    *ptoklen = 10;
    return true;
}

static inline bool_t is_from( cpchar p, uint len, uint* ptoklen )
{
    if( len < 5 || strncmp( p, "From ", 5 ) != 0 )
    {
        return false;
    }
    *ptoklen = 5;
    return true;
}



static char *decode64(const char *in, int len, int *outlen)
{
    char *out, *buf;
    int i, d = 0, dlast = 0, phase = 0;
    static int table[256] = {
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 00-0F */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 10-1F */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, /* 20-2F */
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, /* 30-3F */
        -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,   /* 40-4F */
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, /* 50-5F */
        -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, /* 60-6F */
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1, /* 70-7F */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 80-8F */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* 90-9F */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* A0-AF */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* B0-BF */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* C0-CF */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* D0-DF */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, /* E0-EF */
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1  /* F0-FF */
    };

    out = buf = malloc((unsigned) len + 1);
    *outlen = 0;

    for (i = 0; i < len; ++i) {
        if (in[i] == '\n' || in[i] == '\r') {
            continue;
        }
        d = table[(unsigned char) in[i]];
        if (d != -1) {
            switch (phase) {
            case 0:
                ++phase;
                break;
            case 1:
                *out++ = ((dlast << 2) | ((d & 0x30) >> 4));
                ++phase;
                break;
            case 2:
                *out++ = (((dlast & 0xf) << 4) | ((d & 0x3c) >> 2));
                ++phase;
                break;
            case 3:
                *out++ = (((dlast & 0x03) << 6) | d);
                phase = 0;
                break;
            }
            dlast = d;
        }
    }
    *out = 0;
    *outlen = out - buf;
    return buf;
}




/*****************************************************************************/

void lex_create( lex_t* pthis, mbox_t mboxtype )
{
    pthis->mboxtype = mboxtype;
    pthis->section = envelope;
    pthis->pos = 0;
    pthis->bom = 0;
    pthis->eom = 0;
    pthis->lineend = 0;
    pthis->buflen = 0;
    pthis->pbuf = NULL;
}

void lex_destroy( lex_t* pthis )
{
    free( pthis->pbuf );
}

bool_t lex_load( lex_t* pthis, int fd )
{
    uint    nalloc;
    ssize_t nread;

    nalloc = IOBUFSIZE;
    pthis->pbuf = (char*)malloc( IOBUFSIZE );
    if( pthis->pbuf == NULL )
    {
        return false;
    }

    while( (nread = read( fd, pthis->pbuf + pthis->buflen, nalloc - pthis->buflen )) > 0 )
    {
        pthis->buflen += nread;
        if( pthis->buflen == nalloc )
        {
            char* pnewbuf;
            nalloc += IOBUFSIZE;
            pnewbuf = (char*)realloc( pthis->pbuf, nalloc );
            if( pnewbuf == NULL )
            {
                free( pthis->pbuf );
                pthis->pbuf = NULL;
                return false;
            }
            pthis->pbuf = pnewbuf;
        }
    }
    if( nread < 0 )
    {
        free( pthis->pbuf );
        pthis->pbuf = NULL;
        return false;
    }
    if( pthis->mboxtype == detect )
    {
        if( pthis->buflen > 5 && memcmp( pthis->pbuf, "From ", 5 ) == 0 )
        {
	  //verbose( 1, "Input looks like an mbox\n" );
            pthis->mboxtype = mbox;
        }
        else
        {
	  //verbose( 1, "Input looks like a maildir\n" );
            pthis->mboxtype = maildir;
        }
    }

    return true;
}

static bool_t lex_nextline( lex_t* pthis )
{
    cpchar  pbuf;
    uint    len;
    uint    toklen;

again:
    /* XXX: use and update pthis->section */
    pthis->pos = pthis->lineend;
    if( pthis->lineend == pthis->buflen )
    {
        return false;
    }

    pbuf = pthis->pbuf + pthis->pos;
    len = 0;
    while( pthis->pos + len < pthis->buflen && pbuf[len] != '\n' )
    {
        len++;
    }
    if( pthis->pos + len < pthis->buflen )
    {
        len++; /* bump past the LF */
    }

    pthis->lineend = pthis->pos + len;

    if ( is_mimeboundary( pbuf, len, &toklen ) ) {

      if (pthis->section == mime_part) {
	// printf("------> end of mime part: len=%d toklen=%d\n",len,toklen);
	pthis->section = body;
      } else {
	// printf("ignore (%d): %.*s\n",toklen,toklen,pbuf);
	pthis->section = mime_part;
      }

      /* ignore line */
      pthis->pos += toklen;
      goto again;
    }


    /* check beginning-of-line patterns */
    if( pthis->section = mime_part && is_base64( pbuf, len, &toklen ) ) {

      int outlen=-1;
      char *decoded_str = decode64(pbuf,len,&outlen);
      // printf("is_base64: outlen=%d decoded_str=%s\n",outlen,decoded_str);
      free(decoded_str);

      pthis->pos += toklen;
    }

    if( is_ignoredheader( pbuf, len, &toklen )  ||
        is_mailerid( pbuf, len, &toklen )       ||
        is_spamtext( pbuf, len, &toklen ) )
    {

        /* ignore line */
        pthis->pos += toklen;
        goto again;
    }

    return true;
}


void lex_nexttoken( lex_t* pthis, tok_t* ptok )
{
    cpchar  pbuf;
    uint    len;
    uint    toklen;

    assert( pthis->pbuf != NULL );

    if( pthis->pos == pthis->eom )
    {
        pthis->bom = pthis->pos;
    }

again:
    /* skip whitespace between tokens */
    while( pthis->pos != pthis->lineend && is_whitespace(pthis->pbuf[pthis->pos]) )
    {
        pthis->pos++;
    }

    pbuf = pthis->pbuf + pthis->pos;
    len = pthis->lineend - pthis->pos;

    /* possibilities: end-of-line, html-comment, ipaddr, word, junk */

    if( pthis->pos == pthis->lineend )
    {
        if( !lex_nextline( pthis ) )
        {
            pthis->eom = pthis->pos;
            ptok->tt = eof;
            return;
        }

        pbuf = pthis->pbuf + pthis->pos;
        len = pthis->lineend - pthis->pos;

	if( pthis->section == mime_part ) {
	  // printf("mime part, toklen=%d\n",len);
	  // check content type, if not plain text or html, then skip to next mime
	  // lex_mime(pthis);

	  // pthis->section = body;
	}

        if( pthis->mboxtype == mbox )
        {
            if( is_from( pbuf, len, &toklen ) )
            {
                pthis->eom = pthis->pos;
                ptok->tt = from;
                ptok->p = pthis->pbuf + pthis->pos;
                ptok->len = toklen;
                pthis->pos += toklen;
                return;
            }
        }

        goto again; /* skip lws */
    }

    if( is_htmltag( pbuf, len, &toklen )        ||
        is_htmlcomment( pbuf, len, &toklen )    ||
        is_smtpid( pbuf, len, &toklen )         ||
        is_boundaryequal( pbuf, len, &toklen )  ||
        is_nameequal( pbuf, len, &toklen )      ||
        is_filenameequal( pbuf, len, &toklen ) )
    {

        /* ignore it */
        pthis->pos += toklen;
        goto again;
    }

    if( is_ipaddr( pbuf, len, &toklen ) )
    {
        ptok->tt = word;
        ptok->p = pthis->pbuf + pthis->pos;
        ptok->len = toklen;
        pthis->pos += toklen;
        return;
    }
    if( is_word( pbuf, len, &toklen ) )
    {
        ptok->tt = word;
        ptok->p = pthis->pbuf + pthis->pos;
        ptok->len = toklen;
        pthis->pos += toklen;
        if( toklen > MAXWORDLEN )
        {
            goto again;
        }
        return;
    }

    /* junk */
    pthis->pos++;
    goto again;
}

/* SpamAssassin style passthru */
void lex_passthru( lex_t* pthis, bool_t is_spam, double hits )
{
    char   szbuf[256];
    bool_t in_headers = true;

    assert( pthis->bom < pthis->buflen && pthis->eom <= pthis->buflen );
    assert( pthis->bom <= pthis->eom );

    pthis->pos = pthis->bom;
    if( is_spam )
    {
        sprintf( szbuf, "X-Spam-Status: Yes, hits=%f required=%f, tests=bmf\n"
                        "X-Spam-Flag: YES\n",
                        hits, SPAM_CUTOFF );
    }
    else
    {
        sprintf( szbuf, "X-Spam-Status: No, hits=%f required=%f\n",
                        hits, SPAM_CUTOFF );
    }

    /* existing headers */
    while( in_headers && pthis->pos < pthis->eom )
    {
        cpchar pbuf = pthis->pbuf + pthis->pos;
        uint len = 0;
        while( pthis->pos + len < pthis->buflen && pbuf[len] != '\n' )
        {
            len++;
        }
        if( pthis->pos + len < pthis->buflen )
        {
            len++; /* bump past the LF */
        }

        /* check for end of headers */
        if( pbuf[0] == '\n' || (pbuf[0] == '\r' && pbuf[1] == '\n') )
        {
            /* end of headers */
            break;
        }
 
        /* write header, ignoring existing spam headers */
        if( strncasecmp( pbuf, "X-Spam-", 7 ) != 0 )
        {
            write( STDOUT_FILENO, pbuf, len );
        }

        pthis->pos += len;
    }

    /* new headers */
    write( STDOUT_FILENO, szbuf, strlen(szbuf) );

    /* remainder */
    if( pthis->pos < pthis->eom )
    {
        write( STDOUT_FILENO, pthis->pbuf+pthis->pos, pthis->eom-pthis->pos );
    }
    pthis->bom = pthis->eom;
}

#ifdef UNIT_TEST

int main( int argc, char** argv )
{
    int     fd;
    lex_t   lex;
    tok_t   tok;

    fd = STDIN_FILENO;
    if( argc == 2 )
    {
        fd = open( argv[1], O_RDONLY );
    }

    lex_create( &lex, detect );
    if( ! lex_load( &lex, fd ) )
    {
        fprintf( stderr, "cannot load file\n" );
        exit( 1 );
    } 

    lex_nexttoken( &lex, &tok );
    while( tok.tt != eof )
    {
        char sztok[64];
        if( tok.len > MAXWORDLEN )
        {
            printf( "*** token too long! ***\n" );
            exit( 1 );
        }

        memcpy( sztok, tok.p, tok.len );
        strlwr( sztok );
        sztok[tok.len] = '\0';
        printf( "get_token: %d '%s'\n", tok.tt, sztok );

        lex_nexttoken( &lex, &tok );
    }

    lex_destroy( &lex );
    return 0;
}

#endif /* def UNIT_TEST */
