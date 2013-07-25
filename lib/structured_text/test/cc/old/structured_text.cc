#include "structured_text.h"


void st_init(st_md_t *md) {
  int i;
  md->state = 0;
  for (i = 0; i < MAX_ARGS; ++i)
    md->ptr[i] = NULL;

}

// is_traling_char
// is_leading_char





inline int is_space(const char *ch) {
  return (*ch == ' '  || 
	  *ch == '\t');
}

inline int is_invisible_char(const char *ch) {
  return (is_space(ch) ||
	  *ch == '\r' ||
	  *ch == '\n');
}

inline int is_boundary_char(const char *ch) {
  return (*ch == ' '  || 
	  *ch == ',' ||
	  *ch == '.' ||
	  *ch == ':' ||
	  *ch == ';' ||
	  *ch == '!' ||
	  *ch == '?');
}

inline int is_markup_symbol(const char *ch) {
  return (*ch == '*'  ||
	  *ch == '\'' ||
	  *ch == '\"' ||
	  *ch == '_'  ||
	  *ch == '='  ||
	  *ch == '{'  ||
	  *ch == '$');
}



const char *find_char(const char *begin, const char *end, char ch) {
  while (begin != end && *begin != ch) ++begin;
  if (*begin == ch)
    return begin;
  else
    return NULL;

}

const char *next_boundary(const char *ch, const char *end) {
  const char *stop = ch + 1000; // max lookahead 1000 chars
  stop = stop < end ? stop : end;
  while (ch != stop)
    if (is_boundary_char(ch))
      return ch;
    else
      ++ch;
}

const char *match_href(const char *ch, const char *end) {

  if ( ch+7 > end) 
    return NULL;
  
  if ('h' == *ch       &&
      't' == *(ch + 1) &&
      't' == *(ch + 2) &&
      'p' == *(ch + 3) &&
      ':' == *(ch + 4) &&
      '/' == *(ch + 5) &&
      '/' == *(ch + 6)) {

    const char *boundary = next_boundary(ch+7,end);
    while (boundary < end && *boundary != ' ' && *(boundary+1) != ' ') {
      boundary = next_boundary(boundary+1, end);
    }
    //  printf("%td ~~~ %.*s ~~~",boundary-ch, boundary-ch,ch);


    return boundary;
  }
  return NULL;
}


const char *match_spaces(const char *begin, const char *end) {
  const char *p = begin;
  while (p!=end && *p == ' ') ++p;
  return p;
}

int only_spaces(const char *begin, const char *end) {
  const char *p = begin;
  while (p!=end)
    if (*p != ' ')
      return 0;
    else
      ++p;
  return 1;
}


const char *match_divider(const char *begin, const char *end, const char **stop_of_curr) {
  const char *p = begin;
  while (p!=end && *p == '-') ++p;
  if (p-begin>=5) {
    *stop_of_curr=begin;
    return p;
  }
  return NULL;
}

const char *match_integer(const char *begin, const char *end, st_md_t *md) {
  const char *ch = begin;
  while (ch != end && *ch >= '0' && *ch <= '9') {
    ++ch;
  }
  if (ch != begin) 
    return ch;
  else
    return NULL;
}

const char *match_image(const char *begin, const char *end, st_md_t *md) {

  if (begin+7 > end) return 0;
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
      if(md->ptr[2] = find_char(ch,end,'}')) {
	md->ptr[1] = find_char(ch,md->ptr[2],'|');
	return md->ptr[2]+1;
      } else {
	md->ptr[0] = NULL;
      }
    }
  }
  return NULL;
}


const char *match_video(const char *begin, const char *end, st_md_t *md) {

  if (begin+7 > end) return 0;
  if ( '{' == *begin     &&
       'v' == *(begin+1) &&
       'i' == *(begin+2) &&
       'd' == *(begin+3) &&
       'e' == *(begin+4) &&
       'o' == *(begin+5) &&
       ':' == *(begin+6) ) {

    // {video:abc123_456def.youtube center | hello world}
    //        ^begin+7             ^ptr[0] ^ptr[1]      ^ptr[2]

    if(md->ptr[2] = find_char(begin+7,end,'}')) {
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


bool match_heading(const char *begin, const char *end, const char **stop_of_curr) {
  const char *p = begin;
  if (*p == '=' && *(p+1) == '=') {
    p = end;
    while (p>begin && is_invisible_char(p))
      --p;

    //printf("HERE: %.*sX%d\n",p-begin,begin,is_invisible_char(p));

    // TODO: also check that it contains no newline between the open/close markers

    if (p > begin+4 && *(p-1) == '=' && *p == '=') {
      *stop_of_curr = p-1;
      return true;
    }
  }
  return false;
}


void transform_image(const char *p, st_md_t *md, std::string& html) {

  std::string image_id(p+7,(int)(md->ptr[0]-(p+7)));

  html += "<__image__ id=\"" + image_id + "\"";

  const char *inner_text_end = md->ptr[2];
  if (md->ptr[1]) {
    html += " caption=\"" +  std::string(md->ptr[1]+1,(int)(md->ptr[2]-(md->ptr[1]+1)))  + "\"";
    
    inner_text_end = md->ptr[1];
  }

  if (!only_spaces(md->ptr[0],inner_text_end)) {
    html += " align=\"" + std::string(md->ptr[0],(int)(inner_text_end-md->ptr[0])) + "\""; 
			     
  }

  html += " />";

  md->ptr[0] = NULL;
  md->ptr[1] = NULL;
  md->ptr[2] = NULL;
}



void transform_video(const char *p, st_md_t *md, std::string& html) {

  std::string clip_id(p+7,(int)(md->ptr[0]-(p+7)));

  html += "<__video__ id=\"" + clip_id + "\"";

  const char *inner_text_end = md->ptr[2];
  if (md->ptr[1]) {
    html += " caption=\"" +  std::string(md->ptr[1]+1,(int)(md->ptr[2]-(md->ptr[1]+1)))  + "\"";
    
    inner_text_end = md->ptr[1];
  }

  if (!only_spaces(md->ptr[0],inner_text_end)) {
    html += " align=\"" + std::string(md->ptr[0],(int)(inner_text_end-md->ptr[0])) + "\""; 
			     
  }

  html += " />";

  md->ptr[0] = NULL;
  md->ptr[1] = NULL;
  md->ptr[2] = NULL;
}





int compute_para_indent(const char *begin, const char *end) {

  int count, result = INT_MAX;
  const char *p = begin;
  while (p != end) {
    count = 0;
    while (*p == ' ') {
      // TODO: Take into consideration the case when (*p == '\t')
      ++count;
      ++p;
    }

    /* Check that it's not a blank line by checking that there exists a visible
     * character after the spaces-indent. 
     */
    if (*p != '\n' && *p != '\r')
      if (count < result)
	result = count;

    /* advance to the next line of the paragraph */
    p = 1 + strpbrk(p,"\r\n");
  }
  return result;
}

const char *find_next_para(const char *text, const char **end_of_curr_para) {

  const char *p1 = text, *p2;
  int blank_lines = 0;

  *end_of_curr_para = NULL;
  while (p1 = strpbrk(p1,"\r\n")) {
  //while (p1 = memchr(p1,'\n'),n)

    p2 = p1;
    blank_lines = 0;
    while (is_invisible_char(++p2))
      if (*p2 == '\n' || *p2 == '\r')
	++blank_lines;

    if (blank_lines || *p2 == '\0') {

      /* save p1 as the end of the given paragraph */
      *end_of_curr_para = p1;

      /* return to the beginning of the paragraph */
      while (*(p2-1) == ' ' || *(p2-1) == '\t')
	--p2;

      return p2;

    } else {
      p1 = p2 + 1;
    }
  }

  return NULL;

}


// copies quoted HTML to given string
std::string quotehtml(const char *begin, const char *end) {
  std::string out;

  const char *ch = begin;
  while (ch != end && ch != '\0') {
    switch(*ch) {
    case '<':
      out += "&lt;";
      break;
    case '>':
      out += "&gt;";
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

structured_text::structured_text(const char *text) : text_(quotehtml(text)) {
  //printf("text length=%zd\n",text_.size());
}


// decorate, font emphasis (bold,italics,highlight)
// paragraph to html, in the future maybe section to html, we'll see...
void structured_text::block_to_html(const char *begin, const char *end, std::string& html) {
  const char *p = begin;
  const char *q = NULL, *temp = NULL;
  st_md_t md ;
  st_init(&md);

  while (p != end) {

    if (is_markup_symbol(p)) {

      // if (match_bold(p,end,&state)) continue;
      // if (match_highlight(p,end,&state)) continue;

      if ( *p == '*' && *(p+1) == '*') {       // BOLD

	if ((md.state & BOLD) && ((p+2)<end) && is_boundary_char(p+2)) {
	  md.state ^= BOLD;
	  html += "<span class=\"bold\">" + std::string(q, (int) (p-q)) + "</span>";
	} else if (is_boundary_char(p-1)) {
	  md.state |= BOLD;
	  q = p+2;
	}
	++p;
	
      } else if ( *p == '=' && *(p+1) == '=') {    // HEADING

	if ((md.state & HEADING) && ((p+2)<=end) && match_spaces(p+2,end)==end) {
	  //printf("HEADING END CONDITION:%p =?= %p\n", match_spaces(p+2,end), end);
	  md.state ^= HEADING;
	  html += "<h3>" + std::string(q, (int) (p-q)) + "</h3>"; 
	} else if (match_spaces(begin,p) == p) {
	  md.state |= HEADING;
	  q = p+2;
	}
	++p;
	
      } else if ( *p == '\'' && *(p+1) == '\'') {    // HEADING

	if ((md.state & HIGHLIGHT) && ((p+2)<end) && is_boundary_char(p+2)) {
	  md.state ^= HIGHLIGHT;
	  html += "<span class=\"highlight\">" + std::string(q, (int) (p-q)) + "</span>"; 
	} else if (is_boundary_char(p-1)) {
	  md.state |= HIGHLIGHT;
	  q = p+2;
	}
	++p;
	
      } else if (*p == '*')  {

	if ((md.state & ITALICS) && ((p+1)<end) && is_boundary_char(p+1)) {
	  md.state ^= ITALICS;
	  html += "<span class=\"italics\">" + std::string(q, (int) (p-q)) + "</span>"; 
	} else if (is_boundary_char(p-1)) {
	  md.state |= ITALICS;
	  q = p+1;
	}

      } else if (*p == '_')  {

	if ((md.state & UNDERLINE) && ((p+1)<end) && is_boundary_char(p+1)) {
	  md.state ^= UNDERLINE;
	  html +=  "<span class=\"underline\">" + std::string(q, (int) (p-q)) + "</span>";
	} else if (is_boundary_char(p-1)) {
	  md.state |= UNDERLINE;
	  q = p+1;
	}

      } else if (*p == '$')  {
	//printf("found equation\n");
      } else if (*p == '\"') {  // LINK

	const char * boundary;
	if ((md.state & DOUBLEQUOTE) && ((p+1)<end) && (*(p+1) == ':') && 
	    (boundary = match_href(p+2, end))) {

	  md.state ^= DOUBLEQUOTE;
	  html +=  "<a href=\"" + std::string(p+2,(int)(boundary-(p+2)-1)) + "\">" + std::string(q, (int) (p-q)) + "</a>"; 

	  p = boundary-1;
	} else if (is_boundary_char(p-1)) {
	  md.state |= DOUBLEQUOTE;
	  q = p+1;
	}
	
      } else if (*p == '{' && (temp=match_image(p,end,&md))) {
	transform_image(p,&md,html);
	p=temp;
	continue;
      } else if (*p == '{' && (temp=match_video(p,end,&md))) {
	transform_video(p,&md,html);
	p=temp;
	continue;
      }

    } else {

      //*html = 'a';
      //printf("%p %p\n",html,html+1);
      //++html;
      //printf("%p\n",html);
      //*(*html+1) = 'b';
      //*html = 'b';
      if (!md.state) {
	html += *p;
      }
    }
    ++p; // to avoid falling into an infinity loop / cycle

  } // while
}



void structured_text::special_to_html(const std::string& marker, const std::string& text, std::string& html) {
  if (marker == "::") {
    html += "<pre>";
    html += text;  // decorate
    html += "</pre>\n\n";
  } else if (marker == "%%") {
    html += "<code>";
    html += text;
    html += "</code>\n\n";
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






void structured_text::to_html(std::string& html) {
  //const char *text = text_.data();
  const char *text = text_.c_str();

  int indent = 0, prev_indent = 0, index = -1, pos = 0, tag = NONE;
  bool preformatted_p = false, prev_preformatted_p = false;
  std::string special_text, special_text_marker, otag, ctag;
  std::stack<int> indent_stack;
  std::stack<std::string> ctag_stack;

  const char *curr = text;
  const char *end_of_curr; // end of current paragraph
  const char *stop_of_curr;  // skip characters after this point, e.g. special text markers,
  const char *next = find_next_para(text, &end_of_curr);
  while (next) {
    stop_of_curr = end_of_curr;

    indent = compute_para_indent(curr,next);


    //printf("----- indent=%d -----\n", indent);
    //printf("%.*s",(int) (next-curr),curr); //prints substring from &curr[0]
    //html += "<p>";
    //block_to_html(curr,end_of_curr,html);
    //html += "</p>\n\n";
    //printf("-------curr=%p midd=%p next=%p-----\n",curr,end_of_curr,next);


    if (preformatted_p && prev_indent < indent) {
      special_text += std::string(curr,end_of_curr-curr) + "\n\n";
      prev_preformatted_p = true;
      curr = next;
      next = find_next_para(curr, &end_of_curr);
      continue;
    } else {
      tag = NONE;

      // ^[ \t\n]*([*o\-\#])([ \t\n]+[^\0]*)}
      pos = curr-text;
      index = text_.find_first_not_of(" \t",pos,2);
      //printf("pos=%d index=%d substr=%s\n",pos,index,text_.substr(pos,10).c_str());

      char symbol = text_[index];
      //printf("pos=%d index=%d symbol=%c\n",pos,index,symbol);

      if (symbol == '-' && match_divider(text+index,end_of_curr,&stop_of_curr)) {
	tag = HR;
	otag = "<hr />";
	ctag = "\n\n";
      } else if (symbol == '*' || symbol == '-' || symbol == 'o') {
	tag = UL;
	otag = "<ul>";
	ctag = "</ul>";
      } else if (symbol == '#') {
	tag = OL;
	otag = "<ol>";
	ctag = "</ol>";
      } else if (symbol == '=' && match_heading(text+index,end_of_curr,&stop_of_curr)) {
	tag = HEADING;
	otag = "<h3>";
	ctag = "</h3>";
	curr += index-pos+2;
      } else {
	tag = NONE;
	otag.clear();
	ctag.clear();

      }
      if (tag != NONE && -1 == text_.find_first_not_of(" \t",index+1,2)) {
	tag = NONE;
	otag.clear();
	ctag.clear();
      }

    }

    while (!indent_stack.empty()) {
      //html += " --- XXXX --";
      //if (indent < indent_stack.top() || (indent == indent_stack.top() && ctag != ctag_stack.top())) 
      if (indent < indent_stack.top() || ctag != ctag_stack.top()) {
	html += ctag_stack.top();
	ctag_stack.pop();
	indent_stack.pop();
      } else {
	break;
      }
    }
    
    if (prev_preformatted_p) {
      special_to_html(special_text_marker,special_text,html);
      special_text.clear();
      prev_preformatted_p = false;
    }

    ///////  match(/::|%%|##[ \t\n\r]*$/)
    const int n=4;  // length of the sequence of accepted characters
    pos = end_of_curr-text;
    //int n=end_of_curr-curr;

    index = text_.find_last_not_of(" \t\r\n",pos,n);
    if (-1 != index) {
      special_text_marker = text_.substr(index-1,2);  // 2 is the length of the substring
      if ( special_text_marker == "::" || special_text_marker == "%%" || special_text_marker == "##") {
	preformatted_p = true;
	stop_of_curr = text+index-1; // para[i].replace(/::|%%|##[ \t\n\r]*$/,'');
      } else {
	special_text_marker.clear();
      }
    }

    //html += "(" + ctag + ")";
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
      block_to_html(curr,stop_of_curr,html);
      html += "</li>";
      break;
    case HEADING:
      html += std::string(curr,stop_of_curr-curr);
      break;
    case HR:
      break;
    default:
      html += "<p>";
      block_to_html(curr,stop_of_curr,html);
      html += "</p>\n\n";  // remove the newlines when done testing
    }
    prev_indent = indent;


    curr = next;
    next = find_next_para(curr, &end_of_curr);

  }


  if ( prev_preformatted_p ) {
    special_to_html(special_text_marker,special_text,html);
    prev_preformatted_p = 0;
  }

  while(!ctag_stack.empty()) {
    html += ctag_stack.top();
    ctag_stack.pop();
  }


}

std::string structured_text::to_html() {
  std::string result;
  to_html(result);
  return result;
}
