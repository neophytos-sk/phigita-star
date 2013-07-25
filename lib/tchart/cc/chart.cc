/*
 * Handle Body Idiom - http://www.informit.com/guides/content.aspx?g=cplusplus&seqNum=242
 */

#include <cmath>
#include <gd.h>

#include "chart.h"

#include <string>
#include <algorithm>
#include <vector>
#include <utility>  // for pair

using std::make_pair;
using std::max_element;
using std::pair;
using std::vector;
using std::string;

/* Palettes definition */
int Palette[][3] = {{188,224,46},
                    {224,100,46},
                    {224,214,46},
                    {46,151,224},
                    {176,46,224},
                    {224,46,117},
                    {92,224,46},
                    {224,176,46}};



namespace phigita {

  class base_chart::plotter_impl {
  private:
    int width_;
    int height_;
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

  public:
    plotter_impl(int width, int height);
    ~plotter_impl();
    int draw_alpha_pixel(double x, double y, double alpha, int r, int g, int b);
    void draw_antialias_pixel(int x, int y, int r, int g, int b, int alpha=100,bool nofallback=false);
    int draw_line(int x1, int y1, int x2, int y2, int r, int g, int b);
    void draw_rectangle(int x1, int y1, int x2, int y2, int r, int g, int b);
    void draw_text(int xpos, int ypos, const char *text, int r, int g, int b, double angle = 0.0);
    void set_font_properties(const string font_name, int font_size);

    //void set_graph_area(int x1, int y1, int x2, int y2);
    void write_to_png(const char *filename);

  };

  base_chart::plotter_impl::plotter_impl(int width, int height) : width_(width), height_(height) {
    im_=gdImageCreateTrueColor(width,height);

    set_font_properties("../Fonts/tahoma.ttf",8);

    /* Shadow settings */
    shadow_active_    = false;
    shadow_xdistance_ = 1;
    shadow_ydistance_ = 1;
    shadow_rcolor_    = 60;
    shadow_gcolor_    = 60;
    shadow_bcolor_    = 60;
    shadow_alpha_     = 50;
    shadow_blur_      = 0;

    /* Set antialias quality : 0 is maximum, 100 minimum*/
    antialias_quality_ = 0;

  };

  int base_chart::plotter_impl::draw_alpha_pixel(double x, double y, double alpha, int r, int g, int b) {

    printf("draw_alpha_pixel x=%f y=%f alpha=%f\n",x,y,alpha);

    if (r < 0) { r = 0; } if (r > 255) { r = 255; }
    if (g < 0) { g = 0; } if (g > 255) { g = 255; }
    if (b < 0) { b = 0; } if (b > 255) { b = 255; }
    
    if ( x < 0 || y < 0 || x >= width_ || y >= height_ ) {
      return -1;
    }
    
    int RGB2 = gdImageGetPixel(im_, x, y);
    int R2   = (RGB2 >> 16) & 0xFF;
    int G2   = (RGB2 >> 8) & 0xFF;
    int B2   = RGB2 & 0xFF;
    
    double iAlpha = (100 - alpha)/100;
    alpha  = alpha / 100;
    
    int Ra   = floor(r*alpha+R2*iAlpha);
    int Ga   = floor(g*alpha+G2*iAlpha);
    int Ba   = floor(b*alpha+B2*iAlpha);
    
    int C_Aliased = gdImageColorAllocate(im_,Ra,Ga,Ba);
    gdImageSetPixel(im_,x,y,C_Aliased);
    
  };

  void base_chart::plotter_impl::draw_antialias_pixel(int x, int y, int r, int g, int b, int alpha, bool nofallback) {
    /* Process shadows */
    if ( shadow_active_ && !nofallback ) {
      draw_antialias_pixel(x+shadow_xdistance_,y+shadow_ydistance_,shadow_rcolor_,shadow_gcolor_,shadow_bcolor_,shadow_alpha_,true);
      if ( shadow_blur_ != 0 ) {
	double alpha_decay = (shadow_alpha_ / shadow_blur_);
	
	for(int i=1; i<=shadow_blur_; i++)
	  draw_antialias_pixel(x+shadow_xdistance_-i/2,y+shadow_ydistance_-i/2,shadow_rcolor_,shadow_gcolor_,shadow_bcolor_,shadow_alpha_-alpha_decay*i,true);
	for(int i=1; i<=shadow_blur_; i++)
	  draw_antialias_pixel(x+shadow_xdistance_+i/2,y+shadow_ydistance_+i/2,shadow_rcolor_,shadow_gcolor_,shadow_bcolor_,shadow_alpha_-alpha_decay*i,true);
      }
    }
    
    if (r < 0) { r = 0; } if (r > 255) { r = 255; } 
    if (g < 0) { g = 0; } if (g > 255) { g = 255; } 
    if (b < 0) { b = 0; } if (b > 255) { b = 255; } 
    
    int xi   = floor(x);
    int yi   = floor(y);
    
    if ( xi == x && yi == y) {
      if ( alpha == 100 ) {
	int C_Aliased = gdImageColorAllocate(im_,r,g,b);
	gdImageSetPixel(im_,x,y,C_Aliased);
      } else {
	draw_alpha_pixel(x,y,alpha,r,g,b);
      }
    } else {
      double alpha1 = (((1 - (x - floor(x))) * (1 - (y - floor(y))) * 100) / 100) * alpha;
      if ( alpha1 > antialias_quality_ ) { draw_alpha_pixel(xi,yi,alpha1,r,g,b); }
      
      double alpha2 = (((x - floor(x)) * (1 - (y - floor(y))) * 100) / 100) * alpha;
      if ( alpha2 > antialias_quality_ ) { draw_alpha_pixel(xi+1,yi,alpha2,r,g,b); }
      
      double alpha3 = (((1 - (x - floor(x))) * (y - floor(y)) * 100) / 100) * alpha;
      if ( alpha3 > antialias_quality_ ) { draw_alpha_pixel(xi,yi+1,alpha3,r,g,b); }
      
      double alpha4 = (((x - floor(x)) * (y - floor(y)) * 100) / 100) * alpha;
      if ( alpha4 > antialias_quality_ ) { draw_alpha_pixel(xi+1,yi+1,alpha4,r,g,b); }
    }
    
  };

  int base_chart::plotter_impl::draw_line(int x1, int y1, int x2, int y2, int r, int g, int b) { 

    if ( r < 0 ) { r = 0; } if ( r > 255 ) { r = 255; }
    if ( g < 0 ) { g = 0; } if ( g > 255 ) { g = 255; }
    if ( b < 0 ) { b = 0; } if ( b > 255 ) { b = 255; }
    
    double distance = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));  
    if ( distance == 0 ) return -1;
    
    double xstep = (x2-x1) / distance;
    double ystep = (y2-y1) / distance;
    
    for(int i=0; i<=distance; i++) {
      int x = i * xstep + x1;
      int y = i * ystep + y1;
      
      //if ( (x >= garea_x1_ && x <= garea_x2_ && y >= garea_y1_ && y <= garea_y2_) ) {
      draw_antialias_pixel(x,y,r,g,b);
      //}
    }
  };

  void base_chart::plotter_impl::draw_rectangle(int x1, int y1, int x2, int y2, int r, int g, int b) {

    if ( r < 0 ) { r = 0; } if ( r > 255 ) { r = 255; }
    if ( g < 0 ) { g = 0; } if ( g > 255 ) { g = 255; }
    if ( b < 0 ) { b = 0; } if ( b > 255 ) { b = 255; }
    
    int C_Rectangle = gdImageColorAllocate(im_,r,g,b);
    
    x1=x1-.2;y1=y1-.2;
    x2=x2+.2;y2=y2+.2;
    draw_line(x1,y1,x2,y1,r,g,b);
    draw_line(x2,y1,x2,y2,r,b,b);
    draw_line(x2,y2,x1,y2,r,g,b);
    draw_line(x1,y2,x1,y1,r,g,b);
  };

  void base_chart::plotter_impl::draw_text(int xpos, int ypos, const char *text, int r, int g, int b, double angle) {
    int brect[8]; // for text bounds
    int C_TextColor = gdImageColorAllocate(im_,r,g,b);

    gdImageStringFT(im_, &brect[0], C_TextColor, (char *) font_name_.c_str(), font_size_, angle, xpos, ypos, (char *) text);
  }

  void base_chart::plotter_impl::set_font_properties(const string font_name, int font_size) {
    font_name_ = font_name;
    font_size_ = font_size;
  };

  void base_chart::plotter_impl::write_to_png(const char *filename) {
    FILE *out;
    out = fopen(filename,"w");
    gdImagePng(im_,out);
    fclose(out);
  };

  base_chart::plotter_impl::~plotter_impl() { 
    gdImageDestroy(im_);
  };


  //////

  void base_chart::set_graph_area(int x1, int y1, int x2, int y2) {
    // pimpl_->set_graph_area(x1,y1,x2,y2);
    garea_x1_ = x1;
    garea_y1_ = y1;
    garea_x2_ = x2;
    garea_y2_ = y2;

  };

  base_chart::base_chart(int width, int height) : pimpl_(new plotter_impl(width,height)) {
    set_graph_area(0,0,width,height);
  }

  base_chart::~base_chart() { delete pimpl_; }

  /*
  void base_chart::draw() {
    pimpl_->draw_line(70,70,200,200,255,55,55);
  }
  */

  void base_chart::write_to_png(const char *filename) {
    pimpl_->write_to_png(filename);
  }


  class xy_chart : public base_chart {
  public:

    xy_chart(int width, int height) : base_chart(width,height) {};

    void draw() {
      //base_chart::draw();
      pimpl_->draw_rectangle(70,70,200,200,255,255,255);
    };

    void draw_title(int xpos, int ypos, const char *text, int r, int g, int b) {
      pimpl_->draw_text(xpos,ypos,text,r,g,b);   
    };

    void draw(const vector<pair<double,double> >& data, int palette_id) {

      int xmin_ = 2147483647;
      int ymin_ = 2147483647;
      int ymax_ = -2147483647;
      int xmax_ = -2147483647;

      vector<pair<double,double> >::const_iterator itr;
      const vector<pair<double,double> >::const_iterator end0 = data.end();
      for (itr=data.begin(); itr!=end0; ++itr) {
        double xvalue = itr->first;
	double yvalue = itr->second;
        if (ymax_ < yvalue) { ymax_ = yvalue; }
        if (ymin_ > yvalue) { ymin_ = yvalue; }
        if (xmin_ > xvalue) { xmin_ = xvalue; }
        if (xmax_ < xvalue) { xmax_ = xvalue; }
      }


      int yrange = ymax_ - ymin_;
      int ydivision_ratio_  = ( garea_y2_ - garea_y1_ ) / yrange;

      int xrange = xmax_ - xmin_;
      int xdivision_ratio_ = ( garea_x2_ - garea_x1_) / xrange;

      int y_last = -1; 
      int x_last = -1;

      printf("GArea_X1=%d GArea_Y1=%d GArea_X2=%d GArea_Y2=%d\n", garea_x1_, garea_y1_, garea_x2_, garea_y2_);
      pimpl_->draw_rectangle(garea_x1_,garea_y1_,garea_x2_,garea_y2_,255,255,255);

      int x,y;
      vector<pair<double,double> >::const_iterator it;
      const vector<pair<double,double> >::const_iterator end = data.end();
      for(it=data.begin(); it!=end; ++it) {

	x = it->first;
	y = it->second;

	printf("x=%d y=%d\n",x,y);

	y = garea_y2_ - ((y - ymin_) * ydivision_ratio_);
	x = garea_x1_ + ((x - xmin_) * xdivision_ratio_);

	if (x_last != -1 && y_last != -1) {
	  pimpl_->draw_line(x_last,y_last,x,y,Palette[palette_id][0],Palette[palette_id][1],Palette[palette_id][2]);
	  // pimpl_->draw_text(x-2,y+2,"x",255,0,0);
	}

	x_last = x;
	y_last = y;
      }
    };

  };

}

using namespace phigita;

int main(){

  vector<pair<double,double> > data;
  data.push_back(make_pair(1,2));
  data.push_back(make_pair(2,1));
  data.push_back(make_pair(3,5));
  data.push_back(make_pair(4,7));
  data.push_back(make_pair(5,4));
  data.push_back(make_pair(6,1));
  data.push_back(make_pair(7,3));

  base_chart *mychart = new xy_chart(700,230);
  mychart->set_graph_area(50,30,685,200);
  mychart->draw(data,0);
  mychart->draw_title(60,22,"example 1",250,250,250);
  mychart->write_to_png("example.png");
  return 0;
}
