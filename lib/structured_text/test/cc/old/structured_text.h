#ifndef STRUCTURED_TEXT_H
#define STRUCTURED_TEXT_H


#include <limits>  // for INT_MAX
#include <cstring>  // for strpbrk
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <string>
#include <stack>

#define INT_MAX std::numeric_limits<int>::max()
#define MAX_ARGS 8



typedef struct st_md_T { 
  char state; 
  const char *ptr[MAX_ARGS]; 
} st_md_t;


void st_init(st_md_t *md);

inline int is_invisible_char(const char *ch);
inline int is_boundary_char(const char *ch);
inline int is_markup_symbol(const char *ch);
const char * next_boundary(const char *ch, const char *end);
const char *match_href(const char *ch, const char *end);
const char *match_spaces(const char *begin, const char *end);
int only_spaces(const char *begin, const char *end);
const char *find_char(const char *begin, const char *end, char ch);
const char *match_integer(const char *begin, const char *end, st_md_t *md);
const char *match_image(const char *begin, const char *end, st_md_t *md);
int compute_para_indent(const char *begin, const char *end);
const char *find_next_para(const char *text, const char **end_of_curr_para);



const char kMarkupSymbol[] = "*_\"\'$";

class structured_text {
public:
  explicit structured_text(const char *text);
  void block_to_html(const char *begin, const char *end, std::string& html);
  void special_to_html(const std::string& marker, const std::string& text, std::string& html);
  void to_html(std::string& html);
  std::string to_html();
private:
  enum {
    NONE        = 0,
    BOLD        = 1,
    ITALICS     = 2,
    UNDERLINE   = 3,
    HIGHLIGHT   = 4,
    DOUBLEQUOTE = 5,
    EQUATION    = 6,
    HEADING     = 7,
    INCLUDE     = 8,
    UL          = 9,
    OL          = 10,
    DL          = 11,
    HR          = 12
  };


  std::string text_;
};


#endif
