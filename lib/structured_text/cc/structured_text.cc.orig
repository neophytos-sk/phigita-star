#include "structured_text.h"

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


#define DQ_CH 0x01
#define SQ_CH 0x02
#define LT_CH 0x03
#define GT_CH 0x04




std::string shortline(const std::string& text, int left_index = 100, int right_index = 30) {
  size_t length = text.size();
  if (left_index + right_index > length) {
    return text;
  } else {
    std::string result = text.substr(0,left_index+1);
    result += "...";
    result += text.substr(length-right_index);
    return result;
  }
}

std::string shorturl(const std::string& url, int left_index = 40, int right_index = 10) {
  // TODO: 
  // * handle urlencode / urldecode 
  // * handle utf8
  // until then, we just return the url as is

  size_t length = url.size();
  if (left_index + right_index > length) {
    return url;
  } else {
    /* skip protocol slashes after http or https */
    const size_t skip_proto_pos = 10;

    int found = url.find_last_of('/', left_index);
    if (found != -1 && found > skip_proto_pos) { left_index = found; }
    //return shortline(url,left_index,right_index);
    return shortline(url,left_index,0);
  }
}

void st_init(st_md_t *md) {
  int i;
  for (i = 0; i < MAX_ARGS; ++i)
    md->ptr[i] = NULL;

}

// is_traling_char
// is_leading_char

inline int is_digit(const char*const ch) {
  return (*ch >='0' && *ch<='9');
}

inline int is_space(const char*const ch) {
  return (*ch == ' '  || 
	  *ch == '\t');
}

inline int is_newline(const char*const ch) {
  return (*ch == '\r' || *ch == '\n');
}

inline int is_space_or_newline(const char*const ch) {
  return (is_space(ch) || is_newline(ch));
}

inline int is_invisible_char(const char*const ch) {
  return is_space_or_newline(ch);
}


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

inline int is_markup_symbol(const char*const ch) {
  return (*ch == '*'  ||
	  *ch == '\'' ||
	  *ch == DQ_CH ||
	  *ch == '_'  ||
	  *ch == '='  ||
	  *ch == '$');
}


inline bool is_math_symbol(const char*const ch) {
  return ((*ch >= 'a' && *ch <= 'z') ||
	  (*ch >= '0' && *ch <= '9') ||
	  (*ch >= '<' && *ch <= '>') ||
	  (*ch >= '(' && *ch <= '/') ||
	  (*ch == '^') ||
	  (*ch == '\\'));


}


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

const char *rfind_char(const char*const begin, const char*const end, char ch) {
  return (const char *) memrchr(begin,ch,end-begin);
}


const char *find_char_neq(const char *begin, const char*const end, char ch) {
  while (begin != end && *begin == ch) ++begin;
  if (begin != end)
    return begin;
  else
    return NULL;
}

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


#define HTTP_PROTO(ch) ('h' == *(ch) && 't' == *((ch) + 1) && 't' == *((ch) + 2) && 'p' == *((ch) + 3) && ':' == *((ch) + 4) && '/' == *((ch) + 5) && '/' == *((ch) + 6))
#define HTTPS_PROTO(ch) ('h' == *(ch) && 't' == *((ch) + 1) && 't' == *((ch) + 2) && 'p' == *((ch) + 3) && 's' == *((ch) + 4) && ':' == *((ch) + 5) && '/' == *((ch) + 6) && '/' == *((ch) + 7))

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


const char *match_spaces(const char*const begin, const char*const end) {
  const char *p = begin;
  while (p!=end && *p == ' ') ++p;
  return p;
}

int only_spaces(const char*const begin, const char*const end) {
  const char *p = begin;
  while (p!=end)
    if (*p != ' ')
      return 0;
    else
      ++p;
  return 1;
}


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
    if (ch=match_integer(begin+7,end,md)) {
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



bool match_heading(const char*const begin, const char*const end, const char **stop_of_curr) {
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


const char *match_equation(const char *begin, const char*const end) {
  if (begin == end) return NULL;

  while (begin != end && is_math_symbol(begin)) ++begin;
  if (begin != end)
    return NULL;
  else
    return end;
}

void structured_text::transform_image(const char*const p, st_md_t *md, std::string& html, int *outflags) {

  std::string image_id(p+7,(int)(md->ptr[0]-(p+7)));

  html += "<__image__ id=\"" + image_id + "\"";

  const char *inner_text_end = md->ptr[2];
  if (md->ptr[1]) {   
    inner_text_end = md->ptr[1];
  }

  if (!only_spaces(md->ptr[0],inner_text_end)) {
    html += " align=\"" + std::string(md->ptr[0],(int)(inner_text_end-md->ptr[0])) + "\"";      
  }
  html += ">";

  if (md->ptr[1]) {
    block_to_html(FLAGS_CAPTION,md->ptr[1]+1,md->ptr[2],html,outflags);
  }
  html += "</__image__>";

  md->ptr[0] = NULL;
  md->ptr[1] = NULL;
  md->ptr[2] = NULL;
}



void structured_text::transform_video(const char*const p, st_md_t *md, std::string& html, int *outflags) {

  std::string clip_id(p+7,(int)(md->ptr[0]-(p+7)));

  html += "<__video__ id=\"" + clip_id + "\"";

  const char *inner_text_end = md->ptr[2];
  if (md->ptr[1]) {
    inner_text_end = md->ptr[1];
  }

  if (!only_spaces(md->ptr[0],inner_text_end)) {
    html += " align=\"" + std::string(md->ptr[0],(int)(inner_text_end-md->ptr[0])) + "\""; 
  }
  html += ">";     

  if (md->ptr[1]) {
    block_to_html(FLAGS_CAPTION,md->ptr[1]+1,md->ptr[2],html,outflags);
  }
  html += "</__video__>";

  md->ptr[0] = NULL;
  md->ptr[1] = NULL;
  md->ptr[2] = NULL;
}


void structured_text::transform_embed(const char*const p, st_md_t *md, std::string& html, int *outflags) {

  // std::string url(p+8,(int)(md->ptr[0]-(p+8)));
  std::string url(p+1,(int)(md->ptr[0]-(p+1)));

  html += "<__embed__ url=\"" + url + "\"";

  const char *inner_text_end = md->ptr[2];
  if (md->ptr[1]) {
    inner_text_end = md->ptr[1];
  }

  if (!only_spaces(md->ptr[0],inner_text_end)) {
    html += " align=\"" + std::string(md->ptr[0],(int)(inner_text_end-md->ptr[0])) + "\""; 
  }
  html += ">";     

  if (md->ptr[1]) {
    block_to_html(FLAGS_CAPTION,md->ptr[1]+1,md->ptr[2],html,outflags);
  }
  html += "</__embed__>";

  md->ptr[0] = NULL;
  md->ptr[1] = NULL;
  md->ptr[2] = NULL;
}





int compute_para_indent(const char *begin, const char *end) {

  int count, result = INT_MAX;
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
    if (p=find_char(p,end,'\n')) 
      ++p;
    else
      break;
  }
  return result;
}


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


// copies quoted HTML to given string
std::string quotehtml(const char *begin, const char *end) {
  std::string out;

  const char *ch = begin;
  while (ch != end) {
    switch(*ch) {
    case '"':
      out += DQ_CH;
      break;
    case '\'':
      out += SQ_CH;
      break;
    case '<':
      out += LT_CH;
      break;
    case '>':
      out += GT_CH;
      break;
    case '&':
      out += "&amp;";
      break;
    default:
      out += *ch;
      break;
    }
    ++ch;
  }
  return out;
}

std::string quotehtml(const std::string& text) {
  const char *begin = text.data();
  const char *end = begin+text.size();
  return quotehtml(begin,end);
}

std::string quotehtml(const char *text) {
  const char *begin = text;
  const char *end = begin+strlen(text);
  return quotehtml(begin,end);
}

void sanitizehtml(std::string& html) {
  html.resize(html.size()+5);
  int count=0;
  size_t pos=0;
  std::string::iterator ch= html.begin();
  std::string::iterator end= html.end();
  while (ch != end) {
    //printf("ch=%zd togo=%zd\n",ch-html.begin(),html.end()-ch);
    switch(*ch) {
    case DQ_CH:
      html.replace(ch,ch+1,"&#34;");
      ch = html.begin()+pos;
      end = html.end();
      break;
    case SQ_CH:
      html.replace(ch,ch+1,"&#39;");
      ch = html.begin()+pos;
      end = html.end();
      break;
    case LT_CH:
      html.replace(ch,ch+1,"&lt;");
      ch = html.begin()+pos;
      end = html.end();
      break;
    case GT_CH:
      html.replace(ch,ch+1,"&gt;");
      ch = html.begin()+pos;
      end = html.end();
      break;
    }
    ++ch;
    ++pos;
  }
}

structured_text::structured_text(const char*const text) : text_(quotehtml(text)) {
  //printf("text length=%zd\n",text_.size());
}

inline void change_state_pointer(const char*const q, const char*const p, std::string& output) {
  if (q) output += std::string(q,p-q);
}


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

const char *find_first_true(const char *begin, const char*const end, 
			    int(*fp)(const char *,const char *)) {

  while (begin != end && !fp(begin,end)) ++begin;
  if (begin != end)
    return begin;
  else
    return end;

}


const char *rfind_str(const char*const begin, const char*const end, const char*const str, size_t n) {
  const char *p = end;
  const char ch = str[n-1];
  bool found_p = false;

  while (p>begin && (p= (const char *) memrchr(begin,ch,p-begin)) && p-begin+1 >= n-1 && !found_p) {
    found_p = true;
    for(size_t i=1; i<n; ++i) {
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
const char *rfind_str_if(const char*const begin, const char*const end, const char*const str, size_t n) {
  const char *p = end-1;

  while (p>begin && is_space_or_newline(p)) p--;

  if (p-begin+1 < n) return NULL;

  for(size_t i=0; i<n; ++i) {
    if (str[n-1-i] != *(p-i)) {
      return NULL;
    }
  }
  return p;

}



// decorate, font emphasis (bold,italic,highlight)
// paragraph to html, in the future maybe section to html, we'll see...
void structured_text::block_to_html(const char flags, const char *begin, const char*const end, std::string& html, int *outflags) {

  const char *p = begin, *q = NULL, *r = NULL, *temp = NULL, *s = NULL;

  st_md_t md ;
  st_init(&md);

  while (p < end && begin < end) {

    q = find_first_true(p,end,trailing_markup);
    // html += "X"; // TODO: remove me

    s = NULL;
    switch(trailing_markup(q,end)) {
    case HREF_NOTEXT:
      if (ALLOW_HREF(flags)) {
	//fprintf(stderr,"try href_notext\n");
	// handle http vs https case
	if ('s' == *(q-1))
	  r = q-5;
	else
	  r = q-4;

	if (r >= begin && (s = match_href(r,begin,end))) {
	  // check that this is not an href inside the quotes of an href_text
	  if ( r > begin && s < end-1 && *(r-1)==DQ_CH && *s==DQ_CH && *(s+1)==':') break;
	  if ( r > begin ) html += std::string(begin,r-begin);
	  std::string href(r,s-r);
	  html +=  "<a href=\"" + href + "\">" + shorturl(href) + "</a>"; 
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
	//fprintf(stderr,"try href_text %.*s\n",10,r);
	if (r <end && (temp = match_href(r,begin,end)) && (s = rfind_char(begin,q,DQ_CH))) {
	  if ( s > begin ) html += std::string(begin,s-begin);
	  std::string href(r,temp-r);
	  std::string href_text(s+1,q-(s+1));
	  html +=  "<a href=\"" + href + "\">" + href_text + "</a>"; 
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
	  if ( s > begin ) html += std::string(begin,s-begin);
	  html += "<span class=\"italic\">" + std::string(s+1, q-(s+1)) + "</span>";
	  begin = q+1;
	  p = q+1;
	  SET_FLAG(outflags,FLAG_STYLE);
	  continue;
	}
      }
      break;
    case UNDERLINE:
      if (ALLOW_STYLE(flags)) {
	if (s=rfind_char(begin,q,'_')) {
	  if ( s > begin ) html += std::string(begin,s-begin);
	  html += "<u>" + std::string(s+1, q-(s+1)) + "</u>";
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
	  if ( temp > begin ) html += std::string(begin,temp-p);
	  html += "<__math__>" + std::string(temp+1, q-(temp+1)) + "</__math__>";
	  begin = q+1;
	  p = q+1;
	  SET_FLAG(outflags,FLAG_MATH);
	  continue;
	}
      }
      break;
    case BOLDITALIC:
      if (ALLOW_STYLE(flags)) {
	if (s=rfind_str(begin,q,"***",3)) {
	  if ( s-2 > begin ) html += std::string(begin,(s-2)-begin);
	  html += "<span class=\"z-bold z-italic\">" + std::string(s+1, q-(s+1)) + "</span>";
	  begin = q+3;
	  p = q+3;
	  SET_FLAG(outflags,FLAG_STYLE);
	  continue;
	}
      }
      break;
    case BOLD:
      if (ALLOW_STYLE(flags)) {
	if (s=rfind_str(begin,q,"**",2)) {
	  if ( s-1 > begin ) html += std::string(begin,(s-1)-begin);
	  html += "<span class=\"z-bold\">" + std::string(s+1, q-(s+1)) + "</span>";
	  begin = q+2;
	  p = q+2;
	  SET_FLAG(outflags,FLAG_STYLE);
	  continue;
	}
      }
      break;
    case HIGHLIGHT:
      if (ALLOW_STYLE(flags)) {
	if (s=rfind_str(begin,q,"\x01\x02",2)) {
	  if ( s-1 > begin ) html += std::string(begin,(s-1)-begin);
	  html += "<span class=\"z-highlight\">" + std::string(s+1, q-(s+1)) + "</span>";
	  begin = q+2;
	  p = q+2;
	  SET_FLAG(outflags,FLAG_STYLE);
	  continue;
	}
      }
      break;
    case HEADING:
      if (ALLOW_HEADING(flags)) {
	if (s=rfind_str(begin,q,"==",2)) {
	  if ( s-1 > begin ) html += std::string(begin,(s-1)-begin);
	  html += "<h3>" + std::string(s+1, q-(s+1)) + "</h3>";
	  begin = q+2;
	  p = q+2;
	  SET_FLAG(outflags,FLAG_HEADING);
	  continue;
	}
      }
      break;
    case INCLUDELET:
      if (ALLOW_MEDIA(flags)) {
	if (s=find_char(q,end,'}')) {
	  if (match_image(q,s,&md)) {
	    if ( q > begin ) html += std::string(begin,q-begin);
	    transform_image(q,&md,html,outflags);
	    begin=s+1;
	    p = s+1;
	    SET_FLAG(outflags,FLAG_MEDIA);
	    SET_FLAG(outflags,FLAG_IMAGE);
	    continue;
	  } else if (match_video(q,s,&md)) {
	    if ( q > begin ) html += std::string(begin,q-begin);
	    transform_video(q,&md,html,outflags);
	    begin=s+1;
	    p = s+1;
	    SET_FLAG(outflags,FLAG_MEDIA);
	    SET_FLAG(outflags,FLAG_VIDEO);
	    continue;
	  } else if (match_embed(q,s,&md)) {
	    if ( q > begin ) html += std::string(begin,q-begin);
	    transform_embed(q,&md,html,outflags);
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

    // if none activated, fallback case is here
    if (!s && begin < end) {
      html += std::string(begin,q-begin);
      begin = q;
    }

    // use two variables, one to keep track the search, and one to show the last processed character
    if (q != end)
      p=q+1;
    else
      break;

  } // while


}



void structured_text::special_to_html(const std::string& marker, std::queue<std::pair<const char*,size_t> >& special_text_queue, std::string& html, int *outflags) {
  if (marker == "::") {

    SET_FLAG(outflags,FLAG_PRE);

    html += "<div class=\"z-pre\">";

    std::pair<const char*,size_t> p;
    const char *iter;
    const char * stop;

    bool empty_p = special_text_queue.empty();
    while (!empty_p) {
      p = special_text_queue.front();

      std::string special_html;
      //      printf("%zd\n",p.second);

      special_html.reserve(p.second);
      //printf("flags=%d flags_preformatted=%d\n",FLAGS,FLAGS_PREFORMATTED);
      block_to_html(FLAGS_PREFORMATTED,p.first,p.first+p.second,special_html,outflags);

      iter = special_html.data();
      stop = iter + special_html.size();

      for(; iter != stop; ++iter)
	if (*iter == '\n')
	  html += "<br />";
	else if (*iter == '\t')
	  html += "&nbsp; &nbsp; &nbsp; &nbsp; ";
	else
	  html += *iter;

      special_text_queue.pop();
      if (!(empty_p=special_text_queue.empty()))
	html += "<br /><br />";  // new paragraph/block in special text

    }

    html += "</div>\n\n";

  } else if (marker == "%%") {

    SET_FLAG(outflags,FLAG_CODE);

    //html += "<pre><div class=\"code\">";
    html += "<div class=\"z-code\"><pre><code>";
    std::pair<const char*,size_t> p;
    const char *iter;
    const char * stop;

    bool empty_p = special_text_queue.empty();
    while (!empty_p) {
      p = special_text_queue.front();
      iter = p.first;
      stop = p.first + p.second;

      // FLAGS_CODE
      html += std::string(p.first,p.second);

      special_text_queue.pop();
      if (!(empty_p=special_text_queue.empty()))
	html += "\n\n";  // new paragraph/block in special text

    }

    html += "</code></pre></div>\n\n";
    //html += "</div><pre>\n\n";
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



int incompatible_close_tag(int indent, int indent_stack_top,const std::string& ctag, const std::string& ctag_stack_top) {

  if (indent < indent_stack_top) return 1;

  /* it is implied that ctag has greater indent than ctag_stack_top */
  if (ctag==ctag_stack_top) {
    return 0;
  } else if (ctag=="</ul>" && ctag_stack_top=="</ol>") {
    return 0;
  } else if (ctag=="</ol>" && ctag_stack_top=="</ul>") {
    return 0;
  } else if (indent=indent_stack_top && ctag=="" && ctag_stack_top=="</ol>") {
    return 0;
  } else if (indent=indent_stack_top && ctag=="" && ctag_stack_top=="</ul>") {
    return 0;
  } else {
    return 1;
  }
}



void structured_text::to_html(std::string& html,int *outflags) {
  const char *begin = text_.data();  // pointer to an internal array containing the same content as the string
  //const char *begin = text_.c_str();
  const size_t size = text_.size();
  const char *end = begin + size;

  int indent = 0, prev_indent = 0, pos = 0, tag = NONE;
  bool preformatted_p = false, prev_preformatted_p = false;
  std::string special_text_marker, otag, ctag;
  std::stack<int> indent_stack;
  std::stack<std::string> ctag_stack;
  std::queue<std::pair<const char*,size_t> > special_text_queue;

  const char *curr = begin;
  const char *end_of_curr; // end of current paragraph
  const char *stop_of_curr;  // skip characters after this point, e.g. special text markers,
  const char *next = NULL;

  int count = 0;
  while (curr && curr != end) {
    // DO NOT TOUCH - START
    next = find_next_para(curr,end);
    end_of_curr = next;
    while (curr!=end_of_curr && is_space_or_newline(end_of_curr-1)) --end_of_curr;
    // DO NOT TOUCH - END

    stop_of_curr = end_of_curr;
    indent = compute_para_indent(curr,end_of_curr);

    //printf("preformatted_p=%d prev_indent=%d indent=%d\n",preformatted_p,prev_indent,indent);
    //    || next == end
    if (preformatted_p && (prev_indent < indent)) {
      if (curr < end_of_curr) {
	special_text_queue.push(std::make_pair(curr,end_of_curr-curr));
      }
      prev_preformatted_p = true;
      curr = next;
      continue;
    } else {
      tag = NONE;

      // ^[ \t\n]*([*o\-\#])([ \t\n]+[^\0]*)}
      const char *symbol = NULL;
      if (symbol=find_char_neq(curr,end_of_curr,' ')) {
	//html += "Z";
	if (*symbol == '-' && match_divider(symbol,end_of_curr,&stop_of_curr)) {
	  tag = HR;
	  otag = kHorizontalRuleHTML;
	  ctag = "\n\n";
	  curr = stop_of_curr;
	} else if ((*symbol == '*' || *symbol == '-' || *symbol == 'o' || *symbol == '+') && is_space(symbol+1)) {
	  tag = UL;
	  otag = "<ul>";
	  ctag = "</ul>";
	  curr = symbol+2;
	} else if ( (*symbol == '#' &&  is_space(symbol+1)) 
		    /*
		    || (is_digit(symbol) && *(symbol+1)=='.') 
		    || (is_digit(symbol) && is_digit(symbol+1) && *(symbol+2)=='.')
		    */ ) {
	  tag = OL;
	  otag = "<ol>";
	  ctag = "</ol>";
	  curr = symbol+2;
	} else if (*symbol == '=' && match_heading(symbol,end_of_curr,&stop_of_curr)) {
	  tag = HEADING;
	  otag = "<h3>";
	  ctag = "</h3>";
	  curr = symbol+2;
	} else {
	  tag = NONE;
	  otag.clear();
	  ctag.clear();
	}
      } 

      /*
	if (tag != NONE && tag != HR && std::string::npos == text_.find_first_not_of(" \t",index+1,2)) {
	  tag = NONE;
	  otag.clear();
	  ctag.clear();
	}
	*/

      //html += "(";
      //html += char(*symbol);
      //html += ")";
    }


    while (!indent_stack.empty()) {
      if (incompatible_close_tag(indent,indent_stack.top(),ctag,ctag_stack.top())) {
	html += ctag_stack.top();
	ctag_stack.pop();
	indent_stack.pop();
      } else {
	break;
      }
    }

    if (prev_preformatted_p) {
      special_to_html(special_text_marker,special_text_queue,html,outflags);
      prev_preformatted_p = false;
      preformatted_p=false;
    }


    const char *marker;

    if ((marker=rfind_str_if(curr, end_of_curr, "::", 2))
	|| (marker=rfind_str_if(curr, end_of_curr, "%%", 2))
	|| (marker=rfind_str_if(curr, end_of_curr, "##", 2))) {

      special_text_marker = std::string(marker-1,2);
      preformatted_p = true;
      stop_of_curr = marker-1;
    } else {
      special_text_marker.clear();
    }

    if ( (indent_stack.empty() && ctag_stack.empty()) 
	 || indent > indent_stack.top() 
	 || ctag != ctag_stack.top() ) {
      html += otag;
      indent_stack.push(indent);
      ctag_stack.push(ctag);
    }

    switch (tag) {
    case UL:
    case OL:
    case DL:
      html += "<li>";
      block_to_html(FLAGS,curr,stop_of_curr,html,outflags);
      html += "</li>";
      break;
    case HEADING:
      html += std::string(curr,stop_of_curr-curr);
      break;
    case HR:
      break;
    default:
      if (curr != stop_of_curr) {
	html += "<p>";
	block_to_html(FLAGS,curr,stop_of_curr,html,outflags);
	html += "</p>\n\n";  // remove the newlines when done testing
      }
      break;
    }
    prev_indent = indent;


    curr = next;
  }


  if ( prev_preformatted_p ) {
    special_to_html(special_text_marker,special_text_queue,html,outflags);
    prev_preformatted_p = false;
    preformatted_p=false;
  }

  while(!ctag_stack.empty()) {
    html += ctag_stack.top();
    ctag_stack.pop();
  }

  sanitizehtml(html);
}

std::string structured_text::to_html(int *outflags) {
  std::string result;
  to_html(result,outflags);
  return result;
}


// TODO: parse twitter-like addressing, e.g. @k2pts
void structured_text::minitext_to_html(std::string& html,int *outflags) {
  const char *begin = text_.data();  // pointer to an internal array containing the same content as the string
  const size_t size = text_.size();
  const char *end = begin + size;

  block_to_html(FLAGS_MINITEXT, begin, end, html, outflags);
  sanitizehtml(html);

}
