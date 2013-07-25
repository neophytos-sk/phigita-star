#ifndef STRUCTURED_TEXT_H
#define STRUCTURED_TEXT_H


#include <limits>  // For INT_MAX
#include <cstring>  // For memrchr, strdup
#include <cstdlib>
#include <ctime>
#include <queue>
#include <string>
#include <stack>
#include <utility> // For make_pair

#define INT_MAX std::numeric_limits<int>::max()
#define MAX_ARGS 4

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

typedef struct st_md_T { 
  const char *ptr[MAX_ARGS]; 
} st_md_t;



//const std::string kHorizontalRuleHTML = "<div style=\"width:100%;text-align:center;margin:10px 0px 10px 0px;\">-~-~-~-~-~-<img src=\"/graphics/divider.png\" style=\"width:55px;height:12px;margin:0px 5px 0px 5px;\" />-~-~-~-~-~-</div>";
//const std::string kHorizontalRuleHTML = "<div style=\"width:100%;text-align:center;margin:10px 0px 10px 0px;\"><img style=\"width:100px;height:1px;margin:5px 0px 5px 0px;background:#000;\" /><img src=\"/graphics/divider.png\" style=\"width:55px;height:12px;margin:0px 5px 0px 5px;\" /><img style=\"width:100px;height:1px;margin:5px 0px 5px 0px;background:#000;\" /></div>";
const std::string kHorizontalRuleHTML = "<div style=\"width:100%;text-align:center;margin:10px 0px 10px 0px;\"><span style=\"width:100px;height:1px;margin:5px 0px 5px 0px;border-bottom:1px solid #000;position:relative;top:7px;display:inline-block;\">&nbsp;</span><img src=\"/graphics/divider.png\" style=\"width:55px;height:12px;margin:0px 5px 0px 5px;\" /><span style=\"width:100px;height:1px;margin:5px 0px 5px 0px;border-bottom:1px solid #000;position:relative;top:7px;display:inline-block;\">&nbsp;</span></div>";


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
  explicit structured_text(const char*const text);
  void block_to_html(const char flags, const char *begin, const char*const end, std::string& html,int *outflags);
  void special_to_html(const std::string& marker, std::queue<std::pair<const char*,size_t> >& special_text_queue, std::string& html,int *outflags);
  void to_html(std::string& html,int *outflags);
  void minitext_to_html(std::string& html,int *outflags);
  std::string to_html(int *outflags);
private:
  void transform_image(const char*const p, st_md_t *md, std::string& html, int *outflags);
  void transform_video(const char*const p, st_md_t *md, std::string& html, int *outflags);
  void transform_embed(const char*const p, st_md_t *md, std::string& html, int *outflags);
  std::string text_;
};


#endif
