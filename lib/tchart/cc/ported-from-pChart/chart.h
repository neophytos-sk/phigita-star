#include <cmath>
#include <utility>  // for pair
#include <string>
#include <vector>

#include <gd.h>


using std::max;
using std::make_pair;
using std::pair;
using std::string;
using std::vector;

/* Palettes definition */
int Palette[][3] = {{188,224,46},
		    {224,100,46},
		    {224,214,46},
		    {46,151,224},
		    {176,46,224},
		    {224,46,117},
		    {92,224,46},
		    {224,176,46}};


class chart {
public:
  chart(int xsize, int ysize);
  int draw_alpha_pixel(double x, double y, double alpha, int r, int g, int b);
  void draw_antialias_pixel(int x, int y, int r, int g, int b, int alpha=100,bool nofallback=false);
  int  draw_dotted_line(int x1, int y1,int x2, int y2, int dot_size, int r,int g,int b, bool graph_function = false);
  void draw_graph_area(int r, int g, int b, bool stripe = false);
  void draw_grid(int line_width, bool mosaic = true, int r = 220, int g = 220, int b = 220, int alpha = 100);
  void draw_filled_circle(int xc, int yc, int height, int r, int g, int b, int width = 0);
  void draw_filled_rectangle(int x1, int y1, int x2, int y2, int r, int g, int b, bool draw_border = true, int alpha = 100,bool nofallback = false);
  void draw_filled_rounded_rectangle(int x1, int y1, int x2, int y2, double radius, int r, int g, int b);
  int  draw_line(int x_last, int y_last, int x, int y, int red,int green,int blue,bool graph_function = false);
  void draw_rectangle(int x1, int y1, int x2, int y2, int r, int g, int b);
  void draw_title(int xpos, int ypos, const char *text, int r, int g, int b, int xpos2=-1, int ypos2=-1, bool shadow = false);
  void set_graph_area(int x1, int y1, int x2, int y2);
  void test();
  void draw_xygraph(vector<pair<double,double> >& data, int palette_id);
  void draw_linegraph(vector<double>& data, int palette_id);
  void draw_bargraph(vector<double>& data, bool shadow = false);
  void draw_rounded_rectangle(int x1, int y1, int x2, int y2, double radius, int r, int g, int b, bool filled = false);
  void draw_scale(vector<double>& data, int scale_mode, int r, int g, int b, bool draw_ticks = true, int angle = 0, int decimals = 1, bool with_margin = false, int skip_labels = 1, bool right_scale = false);
  void set_fixed_scale(int vmin, int vmax, int divisions = 5, int vxmin = 0, int vxmax = 0, int xdivisions = 5);
  void set_font_properties(const string fontname, int fontsize);
  void set_line_style(int width = 1, int dot_size = 0);
  void write_to_png(string filename);
  ~chart();
private:
  int xsize_;
  int ysize_;
  gdImagePtr im_;
  string font_name_;
  int font_size_;

  /* Shadow settings */
  bool shadow_active_;
  int shadow_xdistance_;
  int shadow_ydistance_;
  int shadow_rcolor_;
  int shadow_gcolor_;
  int shadow_bcolor_;
  int shadow_alpha_;
  int shadow_blur_;

   /* Set antialias quality : 0 is maximum, 100 minimum*/
  int antialias_quality_;

  /* vars related to the graphing area */
  int garea_x1_;
  int garea_y1_;
  int garea_x2_;
  int garea_y2_;
  int garea_xoffset_;

  int vmax_;
  int vmin_;
  int vxmax_;
  int vxmin_;
  int divisions_;
  int xdivisions_;
  int division_height_;
  int XDivisionHeight;
  int division_count_;
  int XDivisionCount;
  int division_ratio_;
  int xdivision_ratio_;
  int division_width_;
  int data_count_;
  char Currency;

   /* Lines format related vars */
  int line_width_;  // = 1
   int line_dot_size_;  // = 0



};
