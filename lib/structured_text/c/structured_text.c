#include "structured_text.h"

#include "bool.h"
#include "str.h"
#include "stack.h"
#include "queue.h"

#include <string.h>  /* For memrchr, strdup, strncmp, memcpy */

#define FLAG_HREF  1
#define FLAG_MEDIA 2
#define FLAG_STYLE 4
#define FLAG_HEADING 8
#define FLAG_MATH 16
#define FLAG_PRE  32
#define FLAG_CODE 64
#define FLAG_IMAGE 128
#define FLAG_VIDEO 256
#define FLAG_EMBED 512

#define FLAGS 0xff
#define FLAGS_MINITEXT ((FLAGS^FLAG_MEDIA)^FLAG_HEADING)
#define FLAGS_PREFORMATTED ((FLAGS^FLAG_MEDIA)^FLAG_HEADING)
#define FLAGS_CODE ((((FLAGS^FLAG_HREF)^FLAG_MEDIA)^FLAG_STYLE)^FLAG_HEADING)
#define FLAGS_CAPTION (FLAG_STYLE|FLAG_HREF)


#define ALLOW_HREF(x) ((x)&FLAG_HREF)
#define ALLOW_MEDIA(x) ((x)&FLAG_MEDIA)
#define ALLOW_STYLE(x) ((x)&FLAG_STYLE)
#define ALLOW_HEADING(x) ((x)&FLAG_HEADING)
#define ALLOW_MATH(x) ((x)&FLAG_MATH)

#define SET_FLAG(x,y) (*x)|=(y);

#define DQ_CH '"'
// 0x01
#define SQ_CH '\''
// 0x02
#define LT_CH '<'
// 0x03
#define GT_CH '>'
//0x04

enum {
  NONE        = 0,
  BOLD        = 1,
  ITALIC      = 2,
  UNDERLINE   = 3,
  HIGHLIGHT   = 4,
  INCLUDELET = 5,
  EQUATION    = 6,
  HEADING     = 7,
  INCLUDE     = 8,
  UL          = 9,
  OL          = 10,
  DL          = 11,
  HR          = 12,
  HREF_TEXT   = 13,
  HREF_NOTEXT = 14,
  BLOCKQUOTE  = 15,
  BOLDITALIC  = 16
};


#define MAX_ARGS 4
typedef struct st_md_T { 
  const char *ptr[MAX_ARGS]; 
} st_md_t;


const char kHorizontalRuleHTML[] = "<div style=\"width:100%;text-align:center;margin:10px 0px 10px 0px;\"><span style=\"width:100px;height:1px;margin:5px 0px 5px 0px;border-bottom:1px solid #000;position:relative;top:7px;display:inline-block;\">&nbsp;</span><img src=\"//static.phigita.net/graphics/divider.png\" style=\"width:55px;height:12px;margin:0px 5px 0px 5px;\" /><span style=\"width:100px;height:1px;margin:5px 0px 5px 0px;border-bottom:1px solid #000;position:relative;top:7px;display:inline-block;\">&nbsp;</span></div>";

const char kMarkupSymbol[] = "*_\"\'$";


static void BlockToHtml(Tcl_DString *dsPtr, int *outflags, const char flags, const char *begin, const char*const end);


static inline
void DStringAppendUnquoted(Tcl_DString *dsPtr, const char *string, int length) {
    while (length--) {
        switch (*string) {

            case LT_CH:
            Tcl_DStringAppend(dsPtr, "<", 1);
            break;

            case GT_CH:
            Tcl_DStringAppend(dsPtr, ">", 1);
            break;

            case SQ_CH:
            Tcl_DStringAppend(dsPtr, "'", 1);
            break;

            case DQ_CH:
            Tcl_DStringAppend(dsPtr, "\"", 1);
            break;

            default:
            Tcl_DStringAppend(dsPtr, string, 1);
            break;
        }
        ++string;
    }
}

static inline
void DStringAppendPreformatted(Tcl_DString *dsPtr, const char *begin, int length) {
    const char *iter = begin;
    const char *stop = begin+length;
    for(; iter != stop; ++iter) {
        switch(*iter) {
            case '\n':
                Tcl_DStringAppend(dsPtr, "<br />", 6);
                break;
            case '\t':
                Tcl_DStringAppend(dsPtr, "&nbsp; &nbsp; &nbsp; &nbsp; ", 28);
            case '<':
                Tcl_DStringAppend(dsPtr, "&lt;",4);
                break;
            case '>':
                Tcl_DStringAppend(dsPtr, "&gt;",4);
                break;
            default:
                Tcl_DStringAppend(dsPtr, iter, 1);
                break;
        }
    }
}

static
void DStringAppendQuoted(Tcl_DString *dsPtr, const char *string, int length) {
    size_t skipchars = 0;
    while (length--) {
        switch (*string) {

            case '<':
                if (skipchars) Tcl_DStringAppend(dsPtr, string-skipchars, skipchars);
                skipchars = 0;
                Tcl_DStringAppend(dsPtr, "&lt;",4);
                break;

            case '>':
                if (skipchars) Tcl_DStringAppend(dsPtr, string-skipchars, skipchars);
                skipchars = 0;
                Tcl_DStringAppend(dsPtr, "&gt;",4);
                break;

            case '\'':
                if (skipchars) Tcl_DStringAppend(dsPtr, string-skipchars, skipchars);
                skipchars = 0;
                Tcl_DStringAppend(dsPtr, "&#39;",5);
                break;

            case '"':
                if (skipchars) Tcl_DStringAppend(dsPtr, string-skipchars, skipchars);
                skipchars = 0;
                Tcl_DStringAppend(dsPtr, "&#34;",5);
                break;
    
            case '&':
                if (skipchars) Tcl_DStringAppend(dsPtr, string-skipchars, skipchars);
                skipchars = 0;
                Tcl_DStringAppend(dsPtr, "&amp;",5);
                break;

            default:
            /* Tcl_DStringAppend(dsPtr, string, 1); */
            ++skipchars;
            break;
        }
        ++string;
    }
    if (skipchars) Tcl_DStringAppend(dsPtr, string-skipchars, skipchars);
}

/* 
static
void DStringAppendQuoted2(Tcl_DString *dsPtr, const char *begin, const char *end) {
    const char *next = NULL;
    const char *p = begin;
    while (p && p<end) {
        switch (*p) {

            case '<':
                Tcl_DStringAppend(dsPtr, "&lt;",4);
                break;

            case '>':
                Tcl_DStringAppend(dsPtr, "&gt;",4);
                break;

            case '\'':
                Tcl_DStringAppend(dsPtr, "&#39;",5);
                break;

            case '"':
                Tcl_DStringAppend(dsPtr, "&#34;",5);
                break;
    
            case '&':
                Tcl_DStringAppend(dsPtr, "&amp;",5);
                break;

            default:
                next = Tcl_UtfNext(p);
                Tcl_DStringAppend(dsPtr, p, next-p);
                p=next;
                continue;
                break;
        }
        ++p;
    }
}
*/

#ifndef __USE_GNU
/*
 * Reverse memchr()
 * Find the last occurrence of 'c' in the buffer 's' of size 'n'.
 */
void *
memrchr(s, c, n)
    const void *s;
    int c;
    size_t n;
{
    const unsigned char *cp;

    if (n != 0) {
    cp = (unsigned char *)s + n;
    do {
        if (*(--cp) == (unsigned char)c)
        return((void *)cp);
    } while (--n != 0);
    }
    return((void *)0);
}
#endif

static inline
const char *rfind_char(const char* begin, const char* end, char ch) {
    return (char *) memrchr(begin,ch,end-begin);
}


static
void DStringAppendShortUrl(Tcl_DString *dsPtr, const char *url, int length, int left_index, int right_index) {
  /* TODO:
   * handle urlencode / urldecode 
   * handle utf8
   * until then, we just return the url as is
   */

  if (left_index + right_index > length) {

    DStringAppendQuoted(dsPtr, url, length);

  } else {

    const char *pos = rfind_char(url, url+left_index, '/');
    if (pos) {
        DStringAppendQuoted(dsPtr, url, (pos-url) + 1);
        Tcl_DStringAppend(dsPtr, "...", 3);
    } else {
        Tcl_DStringAppend(dsPtr, url, left_index);
    }

    //return shortline(url,left_index,right_index);

  }
}

static inline
void st_init(st_md_t *md) {
  int i;
  for (i = 0; i < MAX_ARGS; ++i)
    md->ptr[i] = NULL;

}

// is_traling_char
// is_leading_char

static inline
int is_digit(const char*const ch) {
  return (*ch >='0' && *ch<='9');
}

static
inline int is_space(const char*const ch) {
  return (*ch == ' '  || 
	  *ch == '\t');
}

static
inline int is_newline(const char*const ch) {
  return (*ch == '\r' || *ch == '\n');
}

static
inline int is_space_or_newline(const char*const ch) {
  return (is_space(ch) || is_newline(ch));
}

static
inline int is_invisible_char(const char*const ch) {
  return is_space_or_newline(ch);
}


static
inline int is_boundary_char(const char*const ch, const char*const end) {
  return (ch == end || is_space_or_newline(ch) || 
	  *ch == ',' ||
	  *ch == '.' ||
	  *ch == ':' ||
	  *ch == ';' ||
	  *ch == '!' ||
	  *ch == '?' ||
	  *ch == '(' || *ch == ')' ||
	  *ch == '[' || *ch == ']' ||
	  *ch == '{' || *ch == '}' ||
	  *ch == DQ_CH);
}

static
inline int is_markup_symbol(const char*const ch) {
  return (*ch == '*'  ||
	  *ch == '\'' ||
	  *ch == DQ_CH ||
	  *ch == '_'  ||
	  *ch == '='  ||
	  *ch == '$');
}


static
inline bool_t is_math_symbol(const char*const ch) {
  return ((*ch >= 'a' && *ch <= 'z') ||
	  (*ch >= '0' && *ch <= '9') ||
	  (*ch >= '<' && *ch <= '>') ||
	  (*ch >= '(' && *ch <= '/') ||
	  (*ch == '^') ||
	  (*ch == '\\'));


}


static
const char *find_char(const char*const begin, const char*const end, char ch) {
  return (const char *) memchr(begin,ch,end-begin);
  /*
  while (begin != end && *begin != ch) ++begin;
  if (begin != end)
    return begin;
  else
    return NULL;
  */
}


static
const char *find_char_neq(const char *begin, const char*const end, char ch) {
  while (begin != end && *begin == ch) ++begin;
  if (begin != end)
    return begin;
  else
    return NULL;
}

/*
static
const char *next_boundary(const char *ch, const char*const end) {
  const char *stop = ch + 1000; // max lookahead 1000 chars
  stop = stop < end ? stop : end;
  while (ch != stop)
    if (is_boundary_char(ch,end))
      return ch;
    else
      ++ch;

  return ch;
}
*/


#define HTTP_PROTO(ch) ('h' == *(ch) && 't' == *((ch) + 1) && 't' == *((ch) + 2) && 'p' == *((ch) + 3) && ':' == *((ch) + 4) && '/' == *((ch) + 5) && '/' == *((ch) + 6))
#define HTTPS_PROTO(ch) ('h' == *(ch) && 't' == *((ch) + 1) && 't' == *((ch) + 2) && 'p' == *((ch) + 3) && 's' == *((ch) + 4) && ':' == *((ch) + 5) && '/' == *((ch) + 6) && '/' == *((ch) + 7))

static
const char *match_href(const char*const ch, const char*const begin, const char*const end) {
  if ( ch+7 >= end) return NULL;
  //  && (*r=ch-1)
  // (ch>begin && 
  int secure=0;
  if (HTTP_PROTO(ch) || (secure=HTTPS_PROTO(ch))) {
    //fprintf(stderr,"secure=%d\n",secure);
    const char *boundary = ch+(7+secure);
    while (boundary && boundary != end && !is_space_or_newline(boundary) && *boundary != DQ_CH) boundary++;

    //while (boundary && boundary+1 < end && !is_space_or_newline(boundary)) {
    //  boundary = next_boundary(boundary+1, end);
    //}
    //  printf("%td ~~~ %.*s ~~~",boundary-ch, boundary-ch,ch);
    while (boundary && is_boundary_char(boundary,end)) --boundary;

    return boundary+1;
  }
  return NULL;
}

/*
static
const char *match_spaces(const char*const begin, const char*const end) {
  const char *p = begin;
  while (p!=end && *p == ' ') ++p;
  return p;
}
*/


static
int only_spaces(const char*const begin, const char*const end) {
  const char *p = begin;
  while (p!=end)
    if (*p != ' ')
      return 0;
    else
      ++p;
  return 1;
}


static
const char *match_divider(const char* begin, const char*const end, const char **stop_of_curr) {

  while (begin < end && is_space(begin))
    ++begin;

  const char *p = begin;
  while (p!=end && *p == '-') 
    ++p;

  if (p-begin>=5) {
    *stop_of_curr=begin;
    return p;
  }
  return NULL;
}

static
const char *match_integer(const char*const begin, const char*const end, st_md_t *md) {
  const char *ch = begin;
  while (ch != end && *ch >= '0' && *ch <= '9') {
    ++ch;
  }
  if (ch != begin) 
    return ch;
  else
    return NULL;
}

static
const char *match_image(const char*const begin, const char*const last_char, st_md_t *md) {
  const char *end = last_char + 1;
  if (begin+7 >= end) return 0;
  if ( '{' == *begin     &&
       'i' == *(begin+1) &&
       'm' == *(begin+2) &&
       'a' == *(begin+3) &&
       'g' == *(begin+4) &&
       'e' == *(begin+5) &&
       ':' == *(begin+6) ) {

    const char *ch;
    if ((ch=match_integer(begin+7,end,md))) {
      md->ptr[0] = ch;
      //printf("HERE: %.*s\n",10,ch);
      //++ch;
      //if(md->ptr[2] = find_char(ch,end,'}')) 
      if (last_char && *last_char == '}' && (md->ptr[2]=last_char)) {
	md->ptr[1] = find_char(ch,md->ptr[2],'|');
	return md->ptr[2]+1;
      } else {
	md->ptr[0] = NULL;
	md->ptr[1] = NULL;
	md->ptr[2] = NULL;
      }
    }
  }
  return NULL;
}


static
const char *match_video(const char*const begin, const char*const last_char, st_md_t *md) {
  const char *end = last_char + 1;

  if (begin+7 >= end) return 0;
  if ( '{' == *begin     &&
       'v' == *(begin+1) &&
       'i' == *(begin+2) &&
       'd' == *(begin+3) &&
       'e' == *(begin+4) &&
       'o' == *(begin+5) &&
       ':' == *(begin+6) ) {

    // {video:abc123_456def.youtube center | hello world}
    //        ^begin+7             ^ptr[0] ^ptr[1]      ^ptr[2]

    //if(md->ptr[2] = find_char(begin+7,end,'}'))
    if (last_char && *last_char == '}' && (md->ptr[2]=last_char)) {
      md->ptr[1] = find_char(begin+7,md->ptr[2],'|');
      const char *ch = md->ptr[1];
      if (!ch) ch = md->ptr[2];
      if (!(md->ptr[0] = find_char(begin+7,ch,' '))) {
	md->ptr[0] = ch; // TODO: check if -1 not sure
      }

      //printf("HERE: %p %p %p\n",md->ptr[0],md->ptr[1],md->ptr[2]);

      return md->ptr[2]+1;
    } else {
      md->ptr[0] = NULL;
      md->ptr[1] = NULL;
      md->ptr[2] = NULL;
    }
  }
  return NULL;
}


static
const char *match_embed(const char*const begin, const char*const last_char, st_md_t *md) {
  const char *end = last_char + 1;

  if (begin+8 >= end) return 0;
  if ( '{' == *begin     &&
       'h' == *(begin+1) &&
       't' == *(begin+2) &&
       't' == *(begin+3) &&
       'p' == *(begin+4) &&
       ':' == *(begin+5) &&
       '/' == *(begin+6) &&
       '/' == *(begin+7) ) {

    // {http://www.youtube.com/watch?v=zDFcDFpL4U center | hello world}
    //        ^begin+7                           ^ptr[0] ^ptr[1]      ^ptr[2]

    if (last_char && *last_char == '}' && (md->ptr[2]=last_char)) {
      md->ptr[1] = find_char(begin+8,md->ptr[2],'|');
      const char *ch = md->ptr[1];
      if (!ch) ch = md->ptr[2];
      if (!(md->ptr[0] = find_char(begin+8,ch,' '))) {
	md->ptr[0] = ch; // TODO: check if -1 not sure
      }

      // printf("HERE: %p %p %p\n",md->ptr[0],md->ptr[1],md->ptr[2]);

      return md->ptr[2]+1;
    } else {
      md->ptr[0] = NULL;
      md->ptr[1] = NULL;
      md->ptr[2] = NULL;
    }
  }
  return NULL;
}



static
bool_t match_heading(const char*const begin, const char*const end, const char **stop_of_curr) {
  const char *p = begin;
  if (*p == '=' && *(p+1) == '=') {
    p = end-1;
    while (p>begin && is_space_or_newline(p))
      --p;

    //printf("HERE: %.*sX%d char(%c)\n",p-begin,begin,is_invisible_char(p),*p);

    // TODO: also check that it contains no newline between the open/close markers

    if (p > begin+4 && *(p-1) == '=' && *p == '=') {
      *stop_of_curr = p-1;
      return true;
    }
  }
  return false;
}


static
const char *match_equation(const char *begin, const char*const end) {
  if (begin == end) return NULL;

  while (begin != end && is_math_symbol(begin)) ++begin;
  if (begin != end)
    return NULL;
  else
    return end;
}

static
void transform_image(Tcl_DString *dsPtr, int *outflags, const char*const p, st_md_t *md) {

  Tcl_DStringAppend(dsPtr, "<__image__ id=\"", 15);
  DStringAppendQuoted(dsPtr, p+7, (int)(md->ptr[0]-(p+7)));
  Tcl_DStringAppend(dsPtr, "\"", 1);

  const char *inner_text_end = md->ptr[2];
  if (md->ptr[1]) {   
    inner_text_end = md->ptr[1];
  }

  if (!only_spaces(md->ptr[0],inner_text_end)) {
    Tcl_DStringAppend(dsPtr, " align=\"", 8);
    // TODO: check valid values
    DStringAppendQuoted(dsPtr, md->ptr[0], (int)(inner_text_end-md->ptr[0]));
    Tcl_DStringAppend(dsPtr, "\"", 1);      
  }
  Tcl_DStringAppend(dsPtr, ">", 1);

  if (md->ptr[1]) {
    BlockToHtml(dsPtr, outflags, FLAGS_CAPTION, md->ptr[1]+1, md->ptr[2]);
  }
  Tcl_DStringAppend(dsPtr, "</__image__>", 12);

  md->ptr[0] = NULL;
  md->ptr[1] = NULL;
  md->ptr[2] = NULL;
}



static
void transform_video(Tcl_DString *dsPtr, int *outflags, const char*const p, st_md_t *md) {

  Tcl_DStringAppend(dsPtr, "<__video__ id=\"", 15);
  DStringAppendQuoted(dsPtr, p+7, (int)(md->ptr[0]-(p+7)));
  Tcl_DStringAppend(dsPtr, "\"", 1);

  const char *inner_text_end = md->ptr[2];
  if (md->ptr[1]) {
    inner_text_end = md->ptr[1];
  }

  if (!only_spaces(md->ptr[0],inner_text_end)) {
    Tcl_DStringAppend(dsPtr, " align=\"", 8);
    DStringAppendQuoted(dsPtr, md->ptr[0], (int)(inner_text_end-md->ptr[0]));
    Tcl_DStringAppend(dsPtr, "\"", 1); 
  }
  Tcl_DStringAppend(dsPtr, ">", 1);     

  if (md->ptr[1]) {
    BlockToHtml(dsPtr, outflags, FLAGS_CAPTION,md->ptr[1]+1,md->ptr[2]);
  }
  Tcl_DStringAppend(dsPtr, "</__video__>", 12);

  md->ptr[0] = NULL;
  md->ptr[1] = NULL;
  md->ptr[2] = NULL;
}


static
void transform_embed(Tcl_DString *dsPtr, int *outflags, const char*const p, st_md_t *md) {

  Tcl_DStringAppend(dsPtr, "<__embed__ url=\"", 16);
  DStringAppendQuoted(dsPtr, p+1, (int)(md->ptr[0]-(p+1)));
  Tcl_DStringAppend(dsPtr, "\"", 1);

  const char *inner_text_end = md->ptr[2];
  if (md->ptr[1]) {
    inner_text_end = md->ptr[1];
  }

  if (!only_spaces(md->ptr[0],inner_text_end)) {
    Tcl_DStringAppend(dsPtr, " align=\"", 8);
    DStringAppendQuoted(dsPtr, md->ptr[0], (int)(inner_text_end-md->ptr[0]));
    Tcl_DStringAppend(dsPtr, "\"", 1); 
  }
  Tcl_DStringAppend(dsPtr, ">", 1);     

  if (md->ptr[1]) {
    BlockToHtml(dsPtr, outflags, FLAGS_CAPTION, md->ptr[1]+1, md->ptr[2]);
  }
  Tcl_DStringAppend(dsPtr, "</__embed__>", 12);

  md->ptr[0] = NULL;
  md->ptr[1] = NULL;
  md->ptr[2] = NULL;
}





static
int compute_para_indent(const char *begin, const char *end) {

  const size_t kMaxSize = (size_t) -1;
  size_t count, result = kMaxSize;
  const char *p = begin;
  while (p != end) {
    count = 0;
    while (p != end-1 && is_space(p)) {
      count += (*p == '\t' ? 4 : 1);
      ++p;
    }

    /* Check that it's not a blank line by checking that there exists a visible
     * character after the spaces-indent. 
     */
    if (!is_space_or_newline(p))
      if (count < result)
	result = count;

    /* advance to the next line of the paragraph */
    if ((p=find_char(p,end,'\n'))) 
      ++p;
    else
      break;
  }
  return result;
}


static
const char *find_next_para(const char *begin, const char *end_of_text) {

  //*end_of_curr = end_of_text;

  if (!begin) return NULL;

  const char *p1 = begin, *p2 = NULL;

  while (p1!=end_of_text 
	 && (p1 = find_char(p1,end_of_text,'\n')) 
	 && (p2 = find_char(p1+1,end_of_text,'\n'))) {

    while (p1 != end_of_text && is_invisible_char(p1)) ++p1;

    if (p1>=p2) {
      //if (*end_of_curr == end_of_text) *end_of_curr = p1;  // first newline
      while(!is_newline(p1)) --p1;  // find last newline
      return p1+1;  // first character after the last newline
    } else {
      p1=p2;
    }

  }

  return end_of_text;

}


/*
// convert symbol characters using special characters in order to
// be able to distinguish them from characters we generate during
// the transformation of the structured text to html
//
static
void EscapeSymbols(char *begin, const char *end) {

  char *ch = begin;
  while (ch != end) {
    switch(*ch) {
        case '"':
          *ch = DQ_CH;
          break;
        case '\'':
          *ch = SQ_CH;
          break;
        case '<':
          *ch = LT_CH;
          break;
        case '>':
          *ch = GT_CH;
          break;
        default:
          break;
    }
    ++ch;
  }

}


static
void UnescapeSymbols(char *begin, const char *end) {

  char *ch = begin;
  while (ch != end) {
    switch(*ch) {
        case DQ_CH:
          *ch = '"';
          break;
        case SQ_CH:
          *ch = '\'';
          break;
        case LT_CH:
          *ch = '<';
          break;
        case GT_CH:
          *ch = '>';
          break;
        default:
          break;
    }
    ++ch;
  }

}
*/

static
int trailing_markup(const char*const ch, const char*const end) {
  if (ch+1 == end)
    return (*ch == '*') ? ITALIC 
      : (*ch == '_') ? UNDERLINE
      : (*ch == '$') ? EQUATION
      : NONE;
  else
    // maybe INCLUDELET if it starts with a left angle bracket and then "video:" or "image:" or "http://"
    return ((ch+5)<end && *ch == '{'  && *(ch+5) ==':') ? INCLUDELET
      : ((ch+6)<end && *ch == '{'  && *(ch+6) ==':') ? INCLUDELET
      : ((ch+2)<end && *ch == '*'  && *(ch+1) == '*' && *(ch+2) == '*' && is_boundary_char(ch+3,end)) ? BOLDITALIC
      : (*ch == DQ_CH  && *(ch+1) == ':') ? HREF_TEXT
      : (*ch == ':'  && *(ch+1) == '/') ? HREF_NOTEXT
      : (*ch == '*'  && *(ch+1) == '*'  && is_boundary_char(ch+2,end)) ? BOLD
      : (*ch == SQ_CH && *(ch+1) == SQ_CH && is_boundary_char(ch+2,end)) ? HIGHLIGHT
      : (*ch == '='  && *(ch+1) == '='  && is_boundary_char(ch+2,end)) ? HEADING
      : (*ch == '_'  && is_boundary_char(ch+1,end)) ? UNDERLINE
      : (*ch == '*'  && is_boundary_char(ch+1,end)) ? ITALIC
      : (*ch == '$'  && is_boundary_char(ch+1,end)) ? EQUATION
      : NONE;
}

static
const char *find_first_true(const char *begin, const char*const end, 
			    int(*fp)(const char *,const char *)) {

  while (begin != end && !fp(begin,end)) ++begin;
  if (begin != end)
    return begin;
  else
    return end;

}


static
const char *rfind_str(const char*const begin, const char*const end, const char*const str, size_t n) {

    size_t i;
  const char *p = end;
  const char ch = str[n-1];
  bool_t found_p = false;

  while (p>begin && (p= rfind_char(begin,p,ch)) && (size_t)(p-begin+1) >= n-1 && !found_p) {
    found_p = true;
    for(i=1; i<n; ++i) {
      if (str[n-1-i] != *(p-i)) {
	found_p = false;
	break;
      }
    }
    if (found_p) return p;
  }
  return NULL;
}


/* Helps us find the preformatted text marker "::" followed by spaces or newlines. */
static
const char *rfind_str_if(const char*const begin, const char*const end, const char*const str, size_t n) {

  size_t i;
  const char *p = end-1;

  while (p>begin && is_space_or_newline(p)) p--;

  if ((size_t) (p-begin+1) < n) return NULL;

  for(i=0; i<n; ++i) {
    if (str[n-1-i] != *(p-i)) {
      return NULL;
    }
  }
  return p;

}



/* decorate, font emphasis (bold,italic,highlight)
 * paragraph to html, in the future maybe section to html, we'll see...
 */
static
void BlockToHtml(Tcl_DString *dsPtr, int *outflags, const char flags, const char *begin, const char*const end) {

  const char *p = begin, *q = NULL, *r = NULL, *temp = NULL, *s = NULL;

  st_md_t md ;
  st_init(&md);

  while (p < end && begin < end) {

    q = find_first_true(p,end,trailing_markup);

    /*
    printf("p=%p q=%p",p,q);
    printf("%.*s\n",q-p,p);
    */

    s = NULL;
    switch(trailing_markup(q,end)) {
    case HREF_NOTEXT:
      if (ALLOW_HREF(flags)) {
        /* fprintf(stderr,"try href_notext\n"); */
        /* handle http vs https case */
        if ('s' == *(q-1))
          r = q-5;
        else
          r = q-4;

        if (r >= begin && (s = match_href(r,begin,end))) {
          /* check that this is not an href inside the quotes of an href_text */
          if ( r > begin && s < end-1 && *(r-1)==DQ_CH && *s==DQ_CH && *(s+1)==':') break;
          if ( r > begin ) {
            DStringAppendQuoted(dsPtr, begin, r-begin);
          }

          Tcl_DStringAppend(dsPtr, "<a href=\"", 9);
          DStringAppendQuoted(dsPtr, r, s-r);
          Tcl_DStringAppend(dsPtr, "\">", 2);
          DStringAppendShortUrl(dsPtr, r, s-r, /* left_index */ 40, /* right_index */ 10);
          Tcl_DStringAppend(dsPtr, "</a>", 4); 

          begin = s;
          p = s;
          SET_FLAG(outflags,FLAG_HREF);
          continue;
        }
      }
      break;
    case HREF_TEXT:
      if (ALLOW_HREF(flags)) {
        r=q+2;
        if (r <end && (temp = match_href(r,begin,end)) && (s = rfind_char(begin,q,DQ_CH))) {
          if ( s > begin ) {
            DStringAppendQuoted(dsPtr, begin, s - begin);
          }
          Tcl_DStringAppend(dsPtr, "<a href=\"", 9);
          DStringAppendQuoted(dsPtr, r, temp - r);
          Tcl_DStringAppend(dsPtr, "\">", 2);
          DStringAppendQuoted(dsPtr, s+1, q - (s+1));
          Tcl_DStringAppend(dsPtr, "</a>", 4); 
          begin = temp;
          p = temp;
          SET_FLAG(outflags,FLAG_HREF);
          continue;
        }
      }
      break;
    case ITALIC:
      if (ALLOW_STYLE(flags)) {
        if ((s=rfind_char(begin,q,'*')) && q-(s+1)>0 && (s==begin || *(s-1)!='*')) {
          if ( s > begin ) {
            DStringAppendQuoted(dsPtr, begin,s-begin);
          }
          Tcl_DStringAppend(dsPtr, "<span class=\"italic\">", 21);
          DStringAppendQuoted(dsPtr, s+1, q-(s+1));
          Tcl_DStringAppend(dsPtr, "</span>", 7);
          begin = q+1;
          p = q+1;
          SET_FLAG(outflags,FLAG_STYLE);
          continue;
        }
      }
      break;
    case UNDERLINE:
      if (ALLOW_STYLE(flags)) {
        if ((s=rfind_char(begin,q,'_'))) {
          if ( s > begin ) {
            DStringAppendQuoted(dsPtr, begin, s-begin);
          }
          Tcl_DStringAppend(dsPtr, "<u>", 3);
          DStringAppendQuoted(dsPtr, s+1, q-(s+1));
          Tcl_DStringAppend(dsPtr, "</u>", 4);
          begin = q+1;
          p = q+1;
          SET_FLAG(outflags,FLAG_STYLE);
          continue;
        }
      }
      break;
    case EQUATION:
      if (ALLOW_MATH(flags)) {
        if ((temp=rfind_char(begin,q,'$')) && (s=match_equation(temp+1,q)) ) {
          if ( temp > begin ) {
            DStringAppendQuoted(dsPtr, begin,temp-p);
          }
          Tcl_DStringAppend(dsPtr, "<__math__>", 10);
          DStringAppendQuoted(dsPtr, temp+1, q-(temp+1));
          Tcl_DStringAppend(dsPtr, "</__math__>", 11);
          begin = q+1;
          p = q+1;
          SET_FLAG(outflags,FLAG_MATH);
          continue;
        }
      }
      break;
    case BOLDITALIC:
      if (ALLOW_STYLE(flags)) {
        if ((s=rfind_str(begin,q,"***",3))) {
          if ( s-2 > begin ) {
            DStringAppendQuoted(dsPtr, begin, (s-2)-begin);
          }
          Tcl_DStringAppend(dsPtr, "<span class=\"z-bold z-italic\">", 30);
          DStringAppendQuoted(dsPtr, s+1, q-(s+1));
          Tcl_DStringAppend(dsPtr, "</span>", 7);
          begin = q+3;
          p = q+3;
          SET_FLAG(outflags,FLAG_STYLE);
          continue;
        }
      }
      break;
    case BOLD:
      if (ALLOW_STYLE(flags)) {
        if ((s=rfind_str(begin,q,"**",2))) {
          if ( s-1 > begin ) {
            DStringAppendQuoted(dsPtr, begin,(s-1)-begin);
          }
          Tcl_DStringAppend(dsPtr, "<span class=\"z-bold\">", 21);
          DStringAppendQuoted(dsPtr, s+1, q-(s+1));
          Tcl_DStringAppend(dsPtr, "</span>", 7);
          begin = q+2;
          p = q+2;
          SET_FLAG(outflags,FLAG_STYLE);
          continue;
        }
      }
      break;
    case HIGHLIGHT:
      if (ALLOW_STYLE(flags)) {
        if (((s=rfind_str(begin,q,"\x01\x02",2)))) {
          if ( s-1 > begin ) {
            DStringAppendQuoted(dsPtr, begin, (s-1)-begin);
          }
          Tcl_DStringAppend(dsPtr, "<span class=\"z-highlight\">", 26);
          DStringAppendQuoted(dsPtr, s+1, q-(s+1));
          Tcl_DStringAppend(dsPtr, "</span>", 7);
          begin = q+2;
          p = q+2;
          SET_FLAG(outflags,FLAG_STYLE);
          continue;
        }
      }
      break;
    case HEADING:
      if (ALLOW_HEADING(flags)) {
        if ((s=rfind_str(begin,q,"==",2))) {
          if ( s-1 > begin ) {
            DStringAppendQuoted(dsPtr, begin, (s-1)-begin);
          }
          Tcl_DStringAppend(dsPtr, "<h3>", 4);
          DStringAppendQuoted(dsPtr, s+1, q-(s+1));
          Tcl_DStringAppend(dsPtr, "</h3>", 5);
          begin = q+2;
          p = q+2;
          SET_FLAG(outflags,FLAG_HEADING);
          continue;
        }
      }
      break;
    case INCLUDELET:
      if (ALLOW_MEDIA(flags)) {
        if ((s=find_char(q,end,'}'))) {
          if (match_image(q,s,&md)) {
                if ( q > begin ) {
                  DStringAppendQuoted(dsPtr, begin, q-begin);
                }
                transform_image(dsPtr, outflags, q, &md);
                begin=s+1;
                p = s+1;
                SET_FLAG(outflags,FLAG_MEDIA);
                SET_FLAG(outflags,FLAG_IMAGE);
                continue;
          } else if (match_video(q,s,&md)) {
                if ( q > begin ) {
                    DStringAppendQuoted(dsPtr, begin, q-begin);
                }
                transform_video(dsPtr, outflags, q, &md);
                begin=s+1;
                p = s+1;
                SET_FLAG(outflags,FLAG_MEDIA);
                SET_FLAG(outflags,FLAG_VIDEO);
                continue;
          } else if (match_embed(q,s,&md)) {
                if ( q > begin ) {
                    DStringAppendQuoted(dsPtr, begin, q-begin);
                }
                transform_embed(dsPtr, outflags, q, &md);
                begin=s+1;
                p = s+1;
                SET_FLAG(outflags,FLAG_MEDIA);
                SET_FLAG(outflags,FLAG_EMBED);
                continue;
          }
        }
      }
      break;
    }

    /* if none activated, fallback case is here */
    if (!s && begin < end) {
      DStringAppendQuoted(dsPtr, begin, q-begin);
      begin = q;
    }

    /* use two variables, one to keep track the search, and one to show the last processed character */
    if (q != end)
      p=q+1;
    else
      break;

  } /* while */


}


#define IS_PREFORMATTED_MARKER(p) ((*p) == ':' && (*(p+1)) == ':')
#define IS_CODE_MARKER(p) ((*p) == '%' && (*(p+1)) == '%')

    
static
void SpecialToHtml(Tcl_DString *dsPtr, int *outflags, const char *specialTextMarkerPtr, queue *special_text_queuePtr) {

  if (IS_PREFORMATTED_MARKER(specialTextMarkerPtr)) {

    SET_FLAG(outflags,FLAG_PRE);

    Tcl_DStringAppend(dsPtr, "<div class=\"z-pre\">", 19);

    const string_t *p;

    bool_t empty_p = QueueEmpty(special_text_queuePtr);
    while (!empty_p) {
      p = (const string_t *) QueueFront(special_text_queuePtr);

      Tcl_DString dsSpecialHtml;
      Tcl_DStringInit(&dsSpecialHtml);
      BlockToHtml(&dsSpecialHtml, outflags, FLAGS_PREFORMATTED, p->data, p->data + p->length);

      Tcl_DStringAppend(dsPtr, Tcl_DStringValue(&dsSpecialHtml), Tcl_DStringLength(&dsSpecialHtml));
      Tcl_DStringFree(&dsSpecialHtml);
      QueuePop(special_text_queuePtr);
      if (!(empty_p=QueueEmpty(special_text_queuePtr))) {
        Tcl_DStringAppend(dsPtr, "<br /><br />", 12);  /* new paragraph/block in special text */
      }

    }

    Tcl_DStringAppend(dsPtr, "</div>\n\n", 8);

  } else if (IS_CODE_MARKER(specialTextMarkerPtr)) {

    SET_FLAG(outflags,FLAG_CODE);

    Tcl_DStringAppend(dsPtr, "<div class=\"z-code\"><pre><code>", 31);
    const string_t *p;

    bool_t empty_p = QueueEmpty(special_text_queuePtr);
    while (!empty_p) {
      p = (const string_t *) QueueFront(special_text_queuePtr);

      /* FLAGS_CODE */
      // DStringAppendUnquoted(dsPtr, p->data, p->length);
      Tcl_DStringAppend(dsPtr, p->data, p->length);

      QueuePop(special_text_queuePtr);
      if (!(empty_p=QueueEmpty(special_text_queuePtr))) {
        Tcl_DStringAppend(dsPtr, "\n\n", 2);  /* new paragraph/block in special text */
      }

    }

    Tcl_DStringAppend(dsPtr, "</code></pre></div>\n\n", 21);
  }

  /*
    switch -exact -- ${handler} {
    {::} {
    Special_Text_Handler=Preformatted ${edit_p} str
    }
    {%%} {
    Special_Text_Handler=Code str
    }
    {$$} {
    Special_Text_Handler=Math str
    }
    {||} {
    Special_Text_Handler=Table str
    }
    {##} {
    Special_Text_Handler=Data_Source str
    }
    }
  */
}



static
int isIncompatibleCloseTag(int indent, int indent_stack_top,const string_t *ctagPtr, const string_t *ctag_stack_top) {

    /* printf("indent=%d indent_stack_top=%d ctag=%s ctag_stack_top=%s",indent, indent_stack_top, StringData(ctagPtr), StringData(ctag_stack_top)); */

  if (indent < indent_stack_top) return 1;

  /* it is implied that ctagPtr has greater indent than ctag_stack_top */
  if (0==strcmp(StringData(ctagPtr), StringData(ctag_stack_top))) {
    return 0;
  } else if (0==strncmp(StringData(ctagPtr),"</ul>",5) && 0==strncmp(StringData(ctag_stack_top), "</ol>", 5)) {
    return 0;
  } else if (0==strncmp(StringData(ctagPtr), "</ol>",5) && 0==strncmp(StringData(ctag_stack_top), "</ul>", 5)) {
    return 0;
  } else if (indent==indent_stack_top && StringEmpty(ctagPtr) && 0==strncmp(StringData(ctag_stack_top),"</ol>", 5)) {
    return 0;
  } else if (indent==indent_stack_top && StringEmpty(ctagPtr) && 0==strncmp(StringData(ctag_stack_top),"</ul>", 5)) {
    return 0;
  } else {
    return 1;
  }
}

int StxToHtml(Tcl_DString *dsPtr, int *outflags, const char *text) {

  const size_t size = strlen(text);
  char *begin = strndup(text,size);
  const char *end = begin + size;

  int indent = 0, prev_indent = 0, tag = NONE;
  bool_t preformatted_p = false, prev_preformatted_p = false;
  /* points to special text marker, i.e. ::, %%, etc */
  const char *specialTextMarkerPtr = NULL;

  string_t otag, ctag;
  stack indent_stack;
  stack ctag_stack;
  queue special_text_queue;

  const char *curr = begin;
  const char *end_of_curr; /* end of current paragraph */
  const char *stop_of_curr;  /* skip chars after this point, e.g. special text markers, */
  const char *next = NULL;

  // EscapeSymbols(begin, end);

  StringInit(&otag);
  StringInit(&ctag);
  StackInit(&indent_stack, sizeof(int));

  StackInit(&ctag_stack, sizeof(string_t));

  QueueInit(&special_text_queue, sizeof(string_t));


  while (curr && curr != end) {
    /* DO NOT TOUCH - START */
    next = find_next_para(curr,end);
    end_of_curr = next;
    while (curr!=end_of_curr && is_space_or_newline(end_of_curr-1)) --end_of_curr;
    /* DO NOT TOUCH - END */

    stop_of_curr = end_of_curr;
    indent = compute_para_indent(curr,end_of_curr);

    /* printf("preformatted_p=%d prev_indent=%d indent=%d\n",preformatted_p,prev_indent,indent); */
    /*    || next == end */
    if (preformatted_p && (prev_indent < indent)) {
      if (curr < end_of_curr) {
          string_t special_text;
          StringInit(&special_text);
          StringAssign(&special_text, curr, end_of_curr - curr);
          QueuePush(&special_text_queue, &special_text);
      }
      prev_preformatted_p = true;
      curr = next;
      continue;
    } else {
      tag = NONE;

      /* ^[ \t\n]*([*o\-\#])([ \t\n]+[^\0]*)} */
      const char *symbol = NULL;
      if ((symbol=find_char_neq(curr,end_of_curr,' '))) {
        if (*symbol == '-' && match_divider(symbol,end_of_curr,&stop_of_curr)) {
          tag = HR;
          StringAssign(&otag, kHorizontalRuleHTML, strlen(kHorizontalRuleHTML));
          StringAssign(&ctag, "\n\n", 2);
          curr = stop_of_curr;
        } else if ((*symbol == '*' || *symbol == '-' || *symbol == 'o' || *symbol == '+') && is_space(symbol+1)) {
          tag = UL;
          StringAssign(&otag, "<ul>", 4);
          StringAssign(&ctag, "</ul>", 5);
          curr = symbol+2;
        } else if ( (*symbol == '#' &&  is_space(symbol+1)) 
                /*
                || (is_digit(symbol) && *(symbol+1)=='.') 
                || (is_digit(symbol) && is_digit(symbol+1) && *(symbol+2)=='.')
                */ ) {
          tag = OL;
          StringAssign(&otag, "<ol>", 4);
          StringAssign(&ctag, "</ol>", 5);
          curr = symbol+2;
        } else if (*symbol == '=' && match_heading(symbol,end_of_curr,&stop_of_curr)) {
          tag = HEADING;
          StringAssign(&otag, "<h3>", 4);
          StringAssign(&ctag, "</h3>", 5);
          curr = symbol+2;
        } else {
          tag = NONE;
          StringAssign(&otag, "", 0);
          StringAssign(&ctag, "", 0);
        }
      } 


    }


    while (!StackEmpty(&indent_stack)) {
        int indentTop = *((const int *) StackTop(&indent_stack));
        if (isIncompatibleCloseTag(indent, indentTop, &ctag, (const string_t *) StackTop(&ctag_stack))) {
            Tcl_DStringAppend(dsPtr, StringData((const string_t *) StackTop(&ctag_stack)), StringLength((const string_t *) StackTop(&ctag_stack)));
            StackPop(&ctag_stack);
            StackPop(&indent_stack);
        } else {
            break;
        }
    }

    if (prev_preformatted_p && specialTextMarkerPtr) {
      SpecialToHtml(dsPtr, outflags, specialTextMarkerPtr, &special_text_queue);
      prev_preformatted_p = false;
      preformatted_p=false;
    }


    const char *marker;

    if ((marker=rfind_str_if(curr, end_of_curr, "::", 2))
	|| (marker=rfind_str_if(curr, end_of_curr, "%%", 2))
	|| (marker=rfind_str_if(curr, end_of_curr, "##", 2))) {

      specialTextMarkerPtr = marker-1;
      preformatted_p = true;
      stop_of_curr = marker-1;
    } else {
      specialTextMarkerPtr = NULL;
    }

    if ( (StackEmpty(&indent_stack) && StackEmpty(&ctag_stack)) 
	 || indent > *((int *) StackTop(&indent_stack)) 
	 || 0 != strncmp(StringData(&ctag), StringData((const string_t *) StackTop(&ctag_stack)), StringLength(&ctag))) {
      Tcl_DStringAppend(dsPtr, StringData(&otag), StringLength(&otag));
      StackPush(&indent_stack, &indent);
      StackPush(&ctag_stack, &ctag);
    }

    switch (tag) {
    case UL:
    case OL:
    case DL:
      Tcl_DStringAppend(dsPtr, "<li>", 3);
      BlockToHtml(dsPtr, outflags, FLAGS, curr, stop_of_curr);
      Tcl_DStringAppend(dsPtr, "</li>", 4);
      break;
    case HEADING:
      DStringAppendQuoted(dsPtr, curr, stop_of_curr-curr);
      break;
    case HR:
      break;
    default:
      if (curr != stop_of_curr) {
        Tcl_DStringAppend(dsPtr, "<p>", 3);
        BlockToHtml(dsPtr, outflags, FLAGS, curr, stop_of_curr);
        Tcl_DStringAppend(dsPtr, "</p>\n\n", 6);  /* remove the newlines when done testing */
      }
      break;
    }
    prev_indent = indent;


    curr = next;
  }


  if ( prev_preformatted_p ) {
    SpecialToHtml(dsPtr, outflags, specialTextMarkerPtr, &special_text_queue);
    prev_preformatted_p = false;
    preformatted_p=false;
  }

  while(!StackEmpty(&ctag_stack)) {
    Tcl_DStringAppend(dsPtr, StringData((const string_t *) StackTop(&ctag_stack)), StringLength((const string_t *) StackTop(&ctag_stack)));
    StackPop(&ctag_stack);
  }

  StackFree(&indent_stack);
  StackFree(&ctag_stack);
  QueueFree(&special_text_queue);

  /* special symbols are unescaped in DStringAppendQuoted */
  // UnescapeSymbols(begin,end);

  return 0;

}

/* TODO: parse twitter-like addressing, e.g. @k2pts */
int MinitextToHtml(Tcl_DString *dsPtr, int *outflags, const char *text) {
  const char *begin = text;  /* pointer to an internal array containing the same content as the string */
  const size_t size = strlen(text);
  const char *end = begin + size;

  BlockToHtml(dsPtr, outflags, FLAGS_MINITEXT, begin, end);

  return 0;

}

