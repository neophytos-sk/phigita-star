#include "chart.h"

#define SCALE_NORMAL 0
#define SCALE_START0 1
#define SCALE_ADDALL 2
#define SCALE_ADDALLSTART0 3


#define abs(x) ((x)>0?(x):-(x))

chart::chart(int xsize, int ysize) : xsize_(xsize), ysize_(ysize) {
  im_=gdImageCreateTrueColor(xsize,ysize);
  int white_color = gdImageColorAllocate(im_,255,255,255);
  gdImageFilledRectangle(im_,0,0,xsize,ysize,white_color);
  gdImageColorTransparent(im_,white_color);
  set_font_properties("arial.ttf",8);
  gdImageColorDeallocate(im_, white_color);

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

  /* vars related to the graphing area */
  garea_x1_;
  garea_y1_;
  garea_x2_;
  garea_y2_;

  garea_xoffset_ = 0;
  vmax_ = 0;
  vmin_ = 0;
  vxmax_ = 0;
  vxmin_ = 0;
  divisions_ = 5;
  xdivisions_ = 0;
  division_height_ = 0;
  XDivisionHeight = 0;
  division_count_ = 0;
  XDivisionCount = 0;
  division_ratio_ = 50;
  xdivision_ratio_ = 50;
  division_width_ = 0;
  data_count_ = 0;
  Currency = '$';

  /* Lines format related vars */
  line_width_ = 1;
  line_dot_size_ = 0;

};

int chart::draw_alpha_pixel(double x, double y, double alpha, int r, int g, int b) {

  printf("draw_alpha_pixel x=%f y=%f alpha=%f\n",x,y,alpha);

  if (r < 0) { r = 0; } if (r > 255) { r = 255; }
  if (g < 0) { g = 0; } if (g > 255) { g = 255; }
  if (b < 0) { b = 0; } if (b > 255) { b = 255; }
  
  if ( x < 0 || y < 0 || x >= xsize_ || y >= ysize_ ) {
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

void chart::draw_antialias_pixel(int x, int y, int r, int g, int b, int alpha, bool nofallback) {
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

void chart::draw_filled_circle(int xc, int yc, int height, int r, int g, int b, int width) {
  if (0 == width) { width = height; }
  if (r < 0) { r = 0; } if (r > 255) { r = 255; } 
  if (g < 0) { g = 0; } if (g > 255) { g = 255; } 
  if (b < 0) { b = 0; } if (b > 255) { b = 255; } 

  int c_circle = gdImageColorAllocate(im_,r,g,b);
  double step = 360 / (2 * 3.1418 * max(width,height));
  double x1,y1,x2,y2;
  for (int i=90; i<=270; i+=step) {

    x1 = cos(i*3.1418/180) * height + xc;
    y1 = sin(i*3.1418/180) * width + yc;
    x2 = cos((180-i)*3.1418/180) * height + xc;
    y2 = sin((180-i)*3.1418/180) * width + yc;

    draw_antialias_pixel(x1-1,y1-1,r,g,b);
    draw_antialias_pixel(x2-1,y2-1,r,g,b);

    if ( (y1-1) > yc - max(width,height) )
      gdImageLine(im_,x1,y1-1,x2-1,y2-1,c_circle);

  }

};


void chart::draw_filled_rounded_rectangle(int X1, int Y1, int X2, int Y2, double radius, int r, int g, int b) {
  draw_rounded_rectangle(X1,Y1,X2,Y2,radius,r,g,b,true);
}


void chart::draw_graph_area(int r, int g, int b, bool stripe) {
  draw_filled_rectangle(garea_x1_, garea_y1_, garea_x2_, garea_y2_, r, g, b, false);
  draw_rectangle(garea_x1_, garea_y1_, garea_x2_, garea_y2_, r-40, g-40, b-40);

  if ( stripe ) {
    int r2 = r-15; if ( r2 < 0 ) { r2 = 0; }
    int g2 = r-15; if ( g2 < 0 ) { g2 = 0; }
    int b2 = r-15; if ( b2 < 0 ) { b2 = 0; }
    
    int line_color = gdImageColorAllocate(im_,r2,g2,b2);
    int skew_width = garea_y2_ - garea_y1_ - 1;
    
    for(int i=garea_x1_ - skew_width; i<=garea_x2_; i+=4) {
      int x1 = i;
      int y1 = garea_y2_;
      int x2 = i + skew_width;
      int y2 = garea_y1_;

      if (x1 < garea_x1_) {
	x1 = garea_x1_; 
	y1 = garea_y1_ + x2 - garea_x1_ + 1;
      }
	
      if (x2 >= garea_x2_) {
	y2 = garea_y1_ + x2 - garea_x2_ +1;
	x2 = garea_x2_ - 1;
      }
      
      gdImageLine(im_,x1,y1,x2,y2+1,line_color);
    }
  }
}


void chart::draw_rectangle(int x1, int y1, int x2, int y2, int r, int g, int b) {

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
}







void chart::draw_rounded_rectangle(int X1, int Y1, int X2, int Y2, double radius, int r, int g, int b, bool filled) {

  if ( r < 0 ) { r = 0; } if ( r > 255 ) { r = 255; }
  if ( g < 0 ) { g = 0; } if ( g > 255 ) { g = 255; }
  if ( b < 0 ) { b = 0; } if ( b > 255 ) { b = 255; }

  int C_Rectangle = gdImageColorAllocate(im_,r,g,b);

  double step = 90 / ((3.1418 * radius)/2);

  for(int i=0; i<=90; i+=step) {
    double Xi1 = cos((i+180)*3.1418/180) * radius + X1 + radius;
    double Yi1 = sin((i+180)*3.1418/180) * radius + Y1 + radius;

    double Xi2 = cos((i-90)*3.1418/180) * radius + X2 - radius;
    double Yi2 = sin((i-90)*3.1418/180) * radius + Y1 + radius;

    double Xi3 = cos((i)*3.1418/180) * radius + X2 - radius;
    double Yi3 = sin((i)*3.1418/180) * radius + Y2 - radius;
    
    double Xi4 = cos((i+90)*3.1418/180) * radius + X1 + radius;
    double Yi4 = sin((i+90)*3.1418/180) * radius + Y2 - radius;
    
    gdImageLine(im_,Xi1,Yi1,X1+radius,Yi1,C_Rectangle);
    gdImageLine(im_,X2-radius,Yi2,Xi2,Yi2,C_Rectangle);
    gdImageLine(im_,X2-radius,Yi3,Xi3,Yi3,C_Rectangle);
    gdImageLine(im_,Xi4,Yi4,X1+radius,Yi4,C_Rectangle);

    draw_antialias_pixel(Xi1,Yi1,r,g,b);
    draw_antialias_pixel(Xi2,Yi2,r,g,b);
    draw_antialias_pixel(Xi3,Yi3,r,g,b);
    draw_antialias_pixel(Xi4,Yi4,r,g,b);
  }

  if (filled) {
    gdImageFilledRectangle(im_,X1,Y1+radius,X2,Y2-radius,C_Rectangle);
    gdImageFilledRectangle(im_,X1+radius,Y1,X2-radius,Y2,C_Rectangle);
  }

  X1=X1-.2; Y1=Y1-.2;
  X2=X2+.2; Y2=Y2+.2;
  draw_line(X1+radius,Y1,X2-radius,Y1,r,g,b);
  draw_line(X2,Y1+radius,X2,Y2-radius,r,g,b);
  draw_line(X2-radius,Y2,X1+radius,Y2,r,g,b);
  draw_line(X1,Y2-radius,X1,Y1+radius,r,g,b);

}

void chart::draw_title(int xpos, int ypos, const char *text, int r, int g, int b, int xpos2, int ypos2, bool shadow) {
  double angle=0.0;
  int brect[8]; // for text bounds

  int C_TextColor = gdImageColorAllocate(im_,r,g,b);

  if ( xpos2 != -1 ) {
    // HERE: position  = imageftbbox($this->FontSize,0,$this->FontName,$Value);
    // text_width = $Position[2]-$Position[0];
    // xpos = floor(( xpos2 - xpos - text_width ) / 2 ) + xpos;
  }

  if ( ypos2 != -1 ) {
    // $Position   = imageftbbox($this->FontSize,0,$this->FontName,$Value);
    // text_height = $Position[5]-$Position[3];
    // ypos = floor(( ypos2 - ypos - text_height ) / 2 ) + ypos;
  }

  if ( shadow ) {
    int C_ShadowColor = gdImageColorAllocate(im_, shadow_rcolor_, shadow_gcolor_, shadow_bcolor_);
    //gdImageStringFT(im_, font_size_, 0, xpos + shadow_xdistance, ypos + shadow_ydistance, C_ShadowColor, font_name_, value);
    gdImageStringFT(im_, &brect[0], C_ShadowColor, (char *) font_name_.c_str(), font_size_, angle, xpos + shadow_xdistance_, ypos + shadow_ydistance_, (char *) text);
  }

  // imagettftext($this->Picture,$this->FontSize,0,$XPos,$YPos,$C_TextColor,$this->FontName,$Value);
  gdImageStringFT(im_, &brect[0], C_TextColor, (char *) font_name_.c_str(), font_size_, angle, xpos, ypos, (char *) text);
}


void chart::set_font_properties(const string font_name, int font_size) {
  font_name_ = font_name;
  font_size_ = font_size;
};

void chart::set_graph_area(int x1, int y1, int x2, int y2) {
  garea_x1_ = x1;
  garea_y1_ = y1;
  garea_x2_ = x2;
  garea_y2_ = y2;
};


void chart::test(){

  /*
  int x1=10,y1=10, x2=50, y2=50, color=0xff0000;
  gdImageRectangle(im_, x1, y1, x2, y2, color);


  int brect[8]; // for text bounds
  int color_blue = gdImageColorAllocate(im_,0,0,255);
  int x=50,y=70;
  double angle=0.0;
  char text[] = "this is a test";
  gdFontCacheSetup();
  gdImageStringFT(im_, &brect[0], color_blue, "/web/data/fonts/verdana.ttf", font_size_, angle, x, y, text);
  gdFreeFontCache();

  
  int line_color = gdImageColorAllocate(im_,Palette[0][0],Palette[0][1],Palette[0][2]);
  x1=100;
  y1=100;
  x2=200;
  y2=200;
  gdImageLine(im_,x1,y1,x2,y2,line_color);

  FILE *out;
  out = fopen("test.png","w");
  gdImagePng(im_,out);

  gdImageColorDeallocate(im_, color_blue);
  */


}

void chart::draw_xygraph(vector<pair<double,double> >& data, int palette_id) {
  int y_last = -1; 
  int x_last = -1;

  printf("GArea_X1=%d GArea_Y1=%d GArea_X2=%d GArea_Y2=%d\n", garea_x1_, garea_y1_, garea_x2_, garea_y2_);

  double x,y;
  vector<pair<double,double> >::const_iterator it;
  const vector<pair<double,double> >::const_iterator end = data.end();
  for(it=data.begin(); it!=end; ++it) {

    x = it->first;
    y = it->second;

    printf("x=%f y=%f\n",x,y);

    y = garea_y2_ - ((y - vmin_) * division_ratio_);
    x = garea_x1_ + ((x - vxmin_) * xdivision_ratio_);

    if (x_last != -1 && y_last != -1) {
      draw_line(x_last,y_last,x,y,Palette[palette_id][0],Palette[palette_id][1],Palette[palette_id][2],true);
    }

    x_last = x;
    y_last = y;
  }
}

void chart::draw_linegraph(vector<double>& data, int palette_id) {
  int y_last = -1; 
  int x_last = -1;

  double x,y,value;
  x = garea_x1_ + garea_xoffset_;


  vector<double>::const_iterator it;
  const vector<double>::const_iterator end = data.end();
  for(it=data.begin(); it!=end; ++it) {

    value = *it;
    

    y = garea_y2_ - ((value - vmin_) * division_ratio_);

    /* Save point into the image map if option activated 
       if ( $this->BuildMap )
       $this->addToImageMap($XPos-3,$YPos-3,$XPos+3,$YPos+3,$DataDescription["Description"][$ColName],$Data[$Key][$ColName].$DataDescription["Unit"]["Y"],"Line");
    */

    if (x_last != -1) {
      draw_line(x_last,y_last,x,y,Palette[palette_id][0],Palette[palette_id][1],Palette[palette_id][2],true);
    }

    x_last = x;
    y_last = y;
    x = x + division_width_;
  }
}


 int chart::draw_dotted_line(int x1, int y1, int x2, int y2, int dot_size, int r,int g,int b, bool graph_function) {
  if ( r < 0 ) { r = 0; } if ( r > 255 ) { r = 255; }
  if ( g < 0 ) { g = 0; } if ( g > 255 ) { g = 255; }
  if ( b < 0 ) { b = 0; } if ( b > 255 ) { b = 255; }

  double distance = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));  
  if ( distance == 0 ) return -1;

  double xstep = (x2-x1) / distance;
  double ystep = (y2-y1) / distance;

  // printf("draw_line x1=%d y1=%d x2=%d y2=%d r=%d g=%d b=%d distance=%f xstep=%f ystep=%f\n",x1,y1,x2,y2,r,g,b,distance,xstep,ystep);


  int dot_index = 0;
  for(int i=0; i<=distance; i++) {
    int x = i * xstep + x1;
    int y = i * ystep + y1;

    if (!dot_size || dot_index <= dot_size) {
      if ( (x >= garea_x1_ && x <= garea_x2_ && y >= garea_y1_ && y <= garea_y2_) || !graph_function ) {
	if ( line_width_ == 1 ) {
	  draw_antialias_pixel(x,y,r,g,b);
	} else {
	  int start_offset = -(line_width_/2); int end_offset = (line_width_/2);
	  for(int j=start_offset;j<=end_offset;j++) {
	    draw_antialias_pixel(x+j,y+j,r,g,b);
	  }
	}
      }
    }
    dot_index++;
    if (dot_index = dot_size * 2) {
      dot_index = 0;
    }
  }

}

int chart::draw_line(int x1, int y1, int x2, int y2, int r,int g,int b, bool graph_function) {

  if ( line_dot_size_ > 1 ) { 
    draw_dotted_line(x1,y1,x2,y2,line_dot_size_,r,g,b,graph_function); 
    return 0; 
  }
  if ( r < 0 ) { r = 0; } if ( r > 255 ) { r = 255; }
  if ( g < 0 ) { g = 0; } if ( g > 255 ) { g = 255; }
  if ( b < 0 ) { b = 0; } if ( b > 255 ) { b = 255; }

  double distance = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));  
  if ( distance == 0 ) return -1;

  double xstep = (x2-x1) / distance;
  double ystep = (y2-y1) / distance;

  // printf("draw_line x1=%d y1=%d x2=%d y2=%d r=%d g=%d b=%d distance=%f xstep=%f ystep=%f\n",x1,y1,x2,y2,r,g,b,distance,xstep,ystep);


  for(int i=0; i<=distance; i++) {
    int x = i * xstep + x1;
    int y = i * ystep + y1;

    if ( (x >= garea_x1_ && x <= garea_x2_ && y >= garea_y1_ && y <= garea_y2_) || !graph_function ) {
      if ( line_width_ == 1 ) {
	draw_antialias_pixel(x,y,r,g,b);
      } else {
	int start_offset = -(line_width_/2); int end_offset = (line_width_/2);
	for(int j=start_offset;j<=end_offset;j++) {
	  draw_antialias_pixel(x+j,y+j,r,g,b);
	}
      }
    }
  }
}

void chart::set_fixed_scale(int vmin, int vmax, int divisions, int vxmin, int vxmax, int xdivisions) {
  vmin_      = vmin;
  vmax_      = vmax;
  divisions_ = divisions;

  if ( !vxmin == 0 ) {
    vxmin_      = vxmin;
    vxmax_      = vxmax;
    xdivisions_ = xdivisions;
  }
}


/* Compute and draw the scale */
void chart::draw_grid(int line_width, bool mosaic, int r, int g, int b, int alpha) {
  /* Draw mosaic */

  if ( mosaic ) {
    int layer_width  = garea_x2_ - garea_x1_;
    int layer_height = garea_y2_ - garea_y1_;

    gdImagePtr layer = gdImageCreateTrueColor(layer_width,layer_height);
    int C_White = gdImageColorAllocate(layer,255,255,255);
    gdImageFilledRectangle(layer,0,0,layer_width,layer_height,C_White);
    gdImageColorTransparent(layer,C_White);

    int C_Rectangle = gdImageColorAllocate(layer,250,250,250);

    int ypos  = layer_height; //$this->GArea_Y2-1;
    int last_y = ypos;
    for(int i=0; i<= division_count_; i++) {
      last_y = ypos;
      ypos  = ypos - division_height_;
      
      if ( ypos <= 0 ) { ypos = 1; }
      
      if ( i % 2 == 0 ) {
	gdImageFilledRectangle(layer,1,ypos,layer_width-1,last_y,C_Rectangle);
      }
    }
    gdImageCopyMerge(im_,layer,garea_x1_,garea_y1_,0,0,layer_width,layer_height,alpha);
    //gdImageCopyMerge(im_,layer,garea_x1_,garea_y1_,layer_width,layer_height,0,0,alpha);
    //gdImageCopyMerge(im_,layer,0,0,garea_x1_,garea_y1_,layer_width,layer_height,alpha);
    gdImageDestroy(layer);
  }

  /* Horizontal lines */

  // division_height_=10;
  // division_width_=10;
  // division_count_=5;

  int ypos = garea_y2_ - division_height_;
  for(int i=1; i<= division_count_;i++) {
    if ( ypos > garea_y1_ && ypos < garea_y2_ ) {
	draw_dotted_line(garea_x1_, ypos, garea_x2_, ypos, line_width, r, g, b);
    }
    ypos = ypos - division_height_;
  }

  /* Vertical lines */

    int xpos, col_count;
  if ( garea_xoffset_ == 0 )
    { xpos = garea_x1_ + division_width_ + garea_xoffset_; col_count = data_count_ - 2; }
  else
    { xpos = garea_x1_ + garea_xoffset_; col_count = floor( (garea_x2_ - garea_x1_) / division_width_ ); }

  for(int i=1;i<=col_count;i++) {
    if ( xpos > garea_x1_ && xpos < garea_x2_ ) {
	draw_dotted_line(floor(xpos),garea_y1_,floor(xpos),garea_y2_,line_width,r,g,b);
    }
    xpos = xpos + division_width_;
  }

}


void chart::set_line_style(int width, int dot_size) {
  line_width_ = width;
  line_dot_size_ = dot_size;
}


// DataDescription
void chart::draw_scale(vector<double>& data, int scale_mode, int r, int g, int b, bool draw_ticks_p, int angle, int decimals, bool with_margin_p, int skip_labels, bool right_scale_p) {

  int divisions=0;
  double data_range;

  // Validate the Data and DataDescription array
  //$this->validateData("drawScale",$Data);

  int C_TextColor = gdImageColorAllocate(im_,r,g,b);

  draw_line(garea_x1_, garea_y1_, garea_x1_, garea_y2_, r, g, b);
  draw_line(garea_x1_, garea_y2_, garea_x2_, garea_y2_, r, g, b);

  if (vmin_ == 0 && vmax_ == 0) {
    if (data.size()) {
      vmin_ = data[0];
      vmax_ = data[0];
    } else {
      vmin_ = 2147483647;
      vmax_ = -2147483647;
    }

    // Compute Min and Max values
    if (scale_mode == SCALE_NORMAL || scale_mode == SCALE_START0) {
      if (scale_mode == SCALE_START0) { vmin_ = 0; }
      vector<double>::const_iterator it;
      const vector<double>::const_iterator end = data.end();
      for (it=data.begin(); it!=end; ++it) {
	double value = *it;
	if (vmax_ < value) { vmax_ = value; }
	if (vmin_ > value) { vmin_ = value; }
      }
    } else if ( scale_mode == SCALE_ADDALL || scale_mode == SCALE_ADDALLSTART0 ) {

      // Experimental
      if ( scale_mode == SCALE_ADDALLSTART0 ) { vmin_ = 0; }

      /*
	foreach ( $Data as $Key => $Values )
	{
	$Sum = 0;
	foreach ( $DataDescription["Values"] as $Key2 => $ColName )
	{
	if (isset($Data[$Key][$ColName]))
	{
	$Value = $Data[$Key][$ColName];
	if ( is_numeric($Value) )
	$Sum  += $Value;
	}
	}
	if ( $this->VMax < $Sum) { $this->VMax = $Sum; }
	if ( $this->VMin > $Sum) { $this->VMin = $Sum; }
	}
      */
    }

    /*
      if ( $this->VMax > preg_replace('/\.[0-9]+/','',$this->VMax) )
      $this->VMax = preg_replace('/\.[0-9]+/','',$this->VMax)+1;
    */

    // If all values are the same 
    if ( vmax_ == vmin_ ) {
      if ( vmax_ >= 0 ) { 
	vmax_++; 
      } else { 
	vmin_--;
      }
    }


    data_range = vmax_ - vmin_;
    if ( data_range == 0 ) { data_range = 0.1; }

    // Compute automatic scaling
    bool scale_ok_p = false; double factor = 1;
    int min_div_height = 25;
    int max_divs = (garea_y2_ - garea_y1_) / min_div_height;
      
    int scale;
    int grid_id;
    if ( vmin_ == 0 && vmax_ == 0 ) { 
      vmin_ = 0;
      vmax_ = 2;
      scale = 1; 
      divisions = 2;
    } else if (max_divs > 1) {
      double scale1,scale2,scale4;
      while(!scale_ok_p) {
	scale1 = ( vmax_ - vmin_ ) / factor;
	scale2 = ( vmax_ - vmin_ ) / factor / 2;
	scale4 = ( vmax_ - vmin_ ) / factor / 4;
	  
	if ( scale1 > 1 && scale1 <= max_divs && !scale_ok_p) { 
	  scale_ok_p = true;
	  divisions = floor(scale1); 
	  scale = 1;
	}
	if ( scale2 > 1 && scale2 <= max_divs && !scale_ok_p) {
	  scale_ok_p = true; 
	  divisions = floor(scale2);
	  scale = 2;
	}
	if (!scale_ok_p) {
	  if ( scale2 > 1 ) { factor = factor * 10; }
	  if ( scale2 < 1 ) { factor = factor / 10; }
	}
      }
      
      if ( floor(vmax_ / scale / factor) != vmax_ / scale / factor) {
	grid_id = floor ( vmax_ / scale / factor) + 1;
	vmax_ = grid_id * scale * factor;
	divisions++;
      }
	
      if ( floor(vmin_ / scale / factor) != vmin_ / scale / factor) {
	grid_id = floor( vmin_ / scale / factor);
	vmin_ = grid_id * scale * factor;
	divisions++;
      }
    } else {
      // Can occurs for small graphs
      scale = 1;
    }

    if ( 0 == divisions) divisions=2;

    if (scale == 1 && divisions % 2 == 1) divisions--;

  } else {
    divisions = divisions_;
  }


  division_count_ = divisions;


  data_range = vmax_ - vmin_;
  if ( data_range == 0 ) { data_range = 0.1; }

  division_height_ = ( garea_y2_ - garea_y1_ ) / divisions_;
  division_ratio_  = ( garea_y2_ - garea_y1_ ) / data_range;

  printf("data_range=%f division_height_=%d\n",data_range,division_height_);



  data_count_ = data.size();
  garea_xoffset_  = 0;
  if ( data_count_ > 1 ) {
    if ( with_margin_p == false ) {
      division_width_ = ( garea_x2_ - garea_x1_ ) / (data_count_ - 1);
    } else {
      division_width_ = ( garea_x2_ - garea_x1_ ) / (data_count_);
      garea_xoffset_  = division_width_ / 2;
    }
  } else {
    division_width_ = garea_x2_ - garea_x1_;
    garea_xoffset_  = division_width_ / 2;
  }

 
  if ( draw_ticks_p == false ) return;

  double ypos = garea_y2_;


  int brect[8]; // for text bounds
  char text[20];
  double value;
  int xmin = -1;
  int text_width,text_height;

  for(int i=1;i<=divisions+1;i++) {
    printf("i=%d divisions=%d ypos=%f division_height_=%d\n",i,divisions,ypos,division_height_);

    if ( right_scale_p ) {
      draw_line(garea_x2_, ypos, garea_x2_ + 5, ypos, r, g, b);
    } else {
      draw_line(garea_x1_, ypos, garea_x1_ - 5, ypos, r, g, b);
    }

    value     = vmin_ + (i-1) * (( vmax_ - vmin_ ) / divisions);
    value     = round(value * pow(10,decimals)) / pow(10,decimals);
    sprintf(text,"%.*f",decimals, value);

    /*

      if ( $DataDescription["Format"]["Y"] == "number" )
      $Value = $Value.$DataDescription["Unit"]["Y"];
      if ( $DataDescription["Format"]["Y"] == "time" )
      $Value = $this->ToTime($Value);        
      if ( $DataDescription["Format"]["Y"] == "date" )
      $Value = $this->ToDate($Value);        
      if ( $DataDescription["Format"]["Y"] == "metric" )
      $Value = $this->ToMetric($Value);        
      if ( $DataDescription["Format"]["Y"] == "currency" )
      $Value = $this->ToCurrency($Value);        
    */

    /* obtain brect so that we can size the image */
    //imageftbbox(font_size_,0,font_name_,text);
    gdImageStringFT ((gdImagePtr) NULL, &brect[0], 0, (char *) font_name_.c_str(), font_size_, angle, 0, 0, (char *) text);
    text_width = brect[2]-brect[0];

    if ( right_scale_p ) {
      // imagettftext($this->Picture,$this->FontSize,0,$this->GArea_X2+10,$YPos+($this->FontSize/2),$C_TextColor,$this->FontName,$Value);
      gdImageStringFT(im_, &brect[0], C_TextColor, (char *) font_name_.c_str(), font_size_, angle, garea_x1_ - 10 - text_width, ypos + (font_size_/2), (char *) text);
      if ( xmin < garea_x2_ + 15 + text_width || xmin == -1 ) { 
	xmin = garea_x2_ + 15 + text_width;
      }
    } else {

      gdImageStringFT(im_, &brect[0], C_TextColor, (char *) font_name_.c_str(), font_size_, angle, garea_x1_ - 10 - text_width, ypos + (font_size_/2), (char *) text);

      if (xmin > garea_x1_ - 10 - text_width || xmin == -1) { xmin == garea_x1_ - 10 - text_width; }

    }
    ypos = ypos - division_height_;

  }



  /*
     // Write the Y Axis caption if set 
     if ( isset($DataDescription["Axis"]["Y"]) )
      {
       $Position   = imageftbbox($this->FontSize,90,$this->FontName,$DataDescription["Axis"]["Y"]);
       $TextHeight = abs($Position[1])+abs($Position[3]);
       $TextTop    = (($this->GArea_Y2 - $this->GArea_Y1) / 2) + $this->GArea_Y1 + ($TextHeight/2);

       if ( right_scale )
        imagettftext($this->Picture,$this->FontSize,90,$XMin+$this->FontSize,$TextTop,$C_TextColor,$this->FontName,$DataDescription["Axis"]["Y"]);
       else
        imagettftext($this->Picture,$this->FontSize,90,$XMin-$this->FontSize,$TextTop,$C_TextColor,$this->FontName,$DataDescription["Axis"]["Y"]);
      }
  */

  // Horizontal Axis
  double xpos = garea_x1_ + garea_xoffset_;
  int id = 1; int ymax = -1;
  vector<double>::const_iterator it;
  const vector<double>::const_iterator end = data.end();
  for (it=data.begin(); it!=end; ++it) {
    if ( id % skip_labels == 0 ) {

      draw_line(floor(xpos),garea_y2_,floor(xpos),garea_y2_ + 5, r, g, b);

      // double value = *it;
      value = id;
      sprintf(text,"%.*f",decimals, value);

      /*
      $Value      = $Data[$Key][$DataDescription["Position"]];
         if ( $DataDescription["Format"]["X"] == "number" )
          $Value = $Value.$DataDescription["Unit"]["X"];
         if ( $DataDescription["Format"]["X"] == "time" )
          $Value = $this->ToTime($Value);        
         if ( $DataDescription["Format"]["X"] == "date" )
          $Value = $this->ToDate($Value);        
         if ( $DataDescription["Format"]["X"] == "metric" )
          $Value = $this->ToMetric($Value);        
         if ( $DataDescription["Format"]["X"] == "currency" )
          $Value = $this->ToCurrency($Value);        
      */
      
      /* obtain brect so that we can size the image */
      gdImageStringFT ((gdImagePtr) NULL, &brect[0], 0, (char *) font_name_.c_str(), font_size_, angle, 0, 0, (char *) text);
      text_width  = abs(brect[2]) + abs(brect[0]);
      text_height = abs(brect[1]) + abs(brect[3]);

      if ( angle == 0 ) {
	ypos = garea_y2_ + 18;
	gdImageStringFT(im_, &brect[0], C_TextColor, (char *) font_name_.c_str(), font_size_, angle, floor(xpos)-floor(text_width/2),ypos, (char *) text);
      } else {
	ypos = garea_y2_ + 10 + text_height;
	if ( angle <= 90 )
	  gdImageStringFT(im_, &brect[0], C_TextColor, (char *) font_name_.c_str(), font_size_, angle, floor(xpos)-text_width+5,ypos, (char *) text);
	else
	  gdImageStringFT(im_, &brect[0], C_TextColor, (char *) font_name_.c_str(), font_size_, angle, floor(xpos)+text_width+5,ypos, (char *) text);
      }
      if ( ymax < ypos || ymax == -1 ) { ymax = ypos; }
    }

       xpos = xpos + division_width_;
       id++;
    }

  /*
    // Write the X Axis caption if set
    if ( isset($DataDescription["Axis"]["X"]) )
      {
       $Position   = imageftbbox($this->FontSize,90,$this->FontName,$DataDescription["Axis"]["X"]);
       $TextWidth  = abs($Position[2])+abs($Position[0]);
       $TextLeft   = (($this->GArea_X2 - $this->GArea_X1) / 2) + $this->GArea_X1 + ($TextWidth/2);
       imagettftext($this->Picture,$this->FontSize,0,$TextLeft,$YMax+$this->FontSize+5,$C_TextColor,$this->FontName,$DataDescription["Axis"]["X"]);
      }
  */

}

void chart::draw_bargraph(vector<double>& data, bool shadow) {
  /* Validate the Data and DataDescription array */
  // $this->validateDataDescription("drawBarGraph",$DataDescription);
  // $this->validateData("drawBarGraph",$Data);

  int graph_id = 0;
  // $Series       = count($DataDescription["Values"]);
  int series_width  = division_width_ / (series+1);
  int serie_xoffset = division_width_ / 2 - series_width / 2;

  double yzero = garea_y2_ - ((0-vmin_) * division_ratio_);
  if ( yzero > garea_y2_ ) { yzero = garea_y2_; }


  int serie_id = 0;
  // foreach ( $DataDescription["Values"] as $Key2 => $ColName )
  int xpos  = garea_x1_ + garea_xoffset_ - serie_xoffset + series_width * serie_id;
  int xlast = -1;
   
  vector<double>::const_iterator it;
  const vector<double>::const_iterator end = data.end();
  for (it=data.begin(); it != end; ++it) {
    double value = *it;
    ypos = garea_y2_ - ((value-vmin_) * division_ratio_);
    if ( shadow && alpha == 100 )
      draw_rectangle(xpos+1,yzero,xpos+series_width-1,ypos,25,25,25,true,alpha);

    draw_filled_rectangle(xpos+1,yzero,xpos+series_width-1,ypos,Palette[color_id][0],Palette[color_id][1],Palette[color_id][2],true,alpha);
  }

  /*
  foreach ( $DataDescription["Values"] as $Key2 => $ColName )
      {
       $ID = 0;
       foreach ( $DataDescription["Description"] as $keyI => $ValueI )
        { if ( $keyI == $ColName ) { $ColorID = $ID; }; $ID++; }

       int xpos  = garea_x1_ + garea_xoffset_ - serie_xoffset + series_width * serie_id;
       $XLast = -1;
       foreach ( $Data as $Key => $Values )
        {
         if ( isset($Data[$Key][$ColName]))
          {
           if ( is_numeric($Data[$Key][$ColName]) )
            {
             $Value = $Data[$Key][$ColName];
             $YPos = $this->GArea_Y2 - (($Value-$this->VMin) * $this->DivisionRatio);

             // Save point into the image map if option activated
             if ( $this->BuildMap )
              {
               $this->addToImageMap($XPos+1,min($YZero,$YPos),$XPos+$SeriesWidth-1,max($YZero,$YPos),$DataDescription["Description"][$ColName],$Data[$Key][$ColName].$DataDescription["Unit"]["Y"],"Bar");
              }
           
             if ( $Shadow && $Alpha == 100 )
              $this->drawRectangle($XPos+1,$YZero,$XPos+$SeriesWidth-1,$YPos,25,25,25,TRUE,$Alpha);

             $this->drawFilledRectangle($XPos+1,$YZero,$XPos+$SeriesWidth-1,$YPos,$this->Palette[$ColorID]["R"],$this->Palette[$ColorID]["G"],$this->Palette[$ColorID]["B"],TRUE,$Alpha);
            }
          }
         $XPos = $XPos + $this->DivisionWidth;
	}
       $SerieID++;
      }
  */

}


/* This function create a filled rectangle with antialias */
void chart::draw_filled_rectangle(int x1, int y1, int x2, int y2, int r, int g, int b, bool draw_border, int alpha, bool nofallback) {
  if ( x2 < x1 ) { x1 = x2; x2 = x1; }
  if ( y2 < y1 ) { y1 = y2; y2 = y1; }

  if (r < 0) { r = 0; } if (r > 255) { r = 255; } 
  if (g < 0) { g = 0; } if (g > 255) { g = 255; } 
  if (b < 0) { b = 0; } if (b > 255) { b = 255; } 
  
  if ( alpha == 100 ) {
    /* Process shadows */
    if ( shadow_active_ && !nofallback ) {
      draw_filled_rectangle(x1+shadow_xdistance_,y1+shadow_ydistance_,x2+shadow_xdistance_,y2+shadow_ydistance_,shadow_rcolor_,shadow_gcolor_,shadow_bcolor_,false,shadow_alpha_,true);
      if ( shadow_blur_ != 0 ) {
	double alpha_decay = (shadow_alpha_ / shadow_blur_);

	for(int i=1; i<=shadow_blur_; i++)
	  draw_filled_rectangle(x1+shadow_xdistance_ - i/2, y1+shadow_ydistance_ - i/2, x2+shadow_xdistance_ - i/2, y2 + shadow_ydistance_ - i/2, shadow_rcolor_, shadow_gcolor_, shadow_bcolor_, false, shadow_alpha_ - alpha_decay*i,true);
	for(int i=1; i<=shadow_blur_; i++)
	  draw_filled_rectangle(x1+shadow_xdistance_ + i/2, y1 + shadow_ydistance_ + i/2, x2 + shadow_xdistance_ + i/2, y2 + shadow_ydistance_ + i/2, shadow_rcolor_, shadow_gcolor_, shadow_bcolor_, false, shadow_alpha_ - alpha_decay*i,true);
      }
    }

    int C_Rectangle = gdImageColorAllocate(im_,r,g,b);
    // gdImageFilledRectangle(im_,round(x1),round(y1),round(x2),round(y2),C_Rectangle);
  } else {
    int layer_width  = abs(x2-x1)+2;
    int layer_height = abs(y2-y1)+2;
    
    gdImagePtr layer = gdImageCreateTrueColor(layer_width,layer_height);
    int C_White   = gdImageColorAllocate(layer,255,255,255);
    // gdImageFilledRectangle($this->Layers[0],0,0,$LayerWidth,$LayerHeight,$C_White);
    // gdImageColorTransparent($this->Layers[0],$C_White);
    
    // int C_Rectangle = gdImageColorAllocate($this->Layers[0],$R,$G,$B);
    // gdImageFilledRectangle($this->Layers[0],round(1),round(1),round($LayerWidth-1),round($LayerHeight-1),$C_Rectangle);
    
    // gdImageCopyMerge($this->Picture,$this->Layers[0],round(min($X1,$X2)-1),round(min($Y1,$Y2)-1),0,0,$LayerWidth,$LayerHeight,$Alpha);
    // gdImageDestroy($this->Layers[0]);
  }
  
  if ( draw_border ) {
    bool shadow_settings = shadow_active_;
    shadow_active_ = false;
    draw_rectangle(x1,y1,x2,y2,r,g,b);
    shadow_active_ = shadow_settings;
  }
}




void chart::write_to_png(string filename) {
  FILE *out;
  out = fopen(filename.c_str(),"w");
  gdImagePng(im_,out);
  fclose(out);
}

chart::~chart(){
  gdImageDestroy(im_);
  fprintf(stderr,"image destroyed\n");
}


 void example0_a() {


  vector<pair<double,double> > data;
  data.push_back(make_pair(1,2));
  data.push_back(make_pair(2,1));
  data.push_back(make_pair(3,5));
  data.push_back(make_pair(4,7));
  data.push_back(make_pair(5,4));
  data.push_back(make_pair(6,1));
  data.push_back(make_pair(7,3));


  chart ch(700,230);
  ch.set_graph_area(50, 30, 585, 200);
  // ch.set_fixed_scale(0,40,4);

  int r = Palette[0][0];
  int g = Palette[0][1];
  int b = Palette[0][2];



  //ch.draw_xyscale(data,SCALE_NORMAL,r,g,b);

  int palette_id=1;
  // ch.set_line_style(5,10);
  ch.draw_xygraph(data,palette_id);
  ch.write_to_png("test.png");
 }


void example0_b() {

  vector<pair<double,double> > data;
  data.push_back(make_pair(1,2));
  data.push_back(make_pair(2,1));
  data.push_back(make_pair(3,5));
  data.push_back(make_pair(4,7));
  data.push_back(make_pair(5,4));
  data.push_back(make_pair(6,1));
  data.push_back(make_pair(7,3));

  // Initialise the graph   
  chart test(700,230);
  test.set_font_properties("Fonts/tahoma.ttf",8);
  test.set_graph_area(70,30,680,200);
  //test.draw_xyscale(data,SCALE_NORMAL,150,150,150,true,0,2);
  test.draw_xygraph(data,4);
  test.write_to_png("example0.png");

}

void example1() {


  // Draw the line graph
  vector<double> data;
  data.push_back(2);
  data.push_back(1);
  data.push_back(5);
  data.push_back(7);
  data.push_back(4);
  data.push_back(1);
  data.push_back(3);


  // Initialise the graph   
  chart test(700,230);
  test.set_font_properties("Fonts/tahoma.ttf",8);
  test.set_graph_area(70,30,680,200);
  test.draw_filled_rounded_rectangle(7,7,693,223,5,240,240,240);
  test.draw_rounded_rectangle(5,5,695,225,5,230,230,230);
  test.draw_graph_area(255,255,255,true);
  test.draw_scale(data,SCALE_NORMAL,150,150,150,true,0,2);
  test.draw_grid(4,true,230,230,230,50);
  
  // Draw the 0 line
  test.set_font_properties("Fonts/tahoma.ttf",6);
  //test.draw_treshold(0,143,55,72,true,true);


  test.draw_linegraph(data,3);
  //test.draw_line_graph($DataSet->GetData(),$DataSet->GetDataDescription());   
  // test.draw_plot_graph($DataSet->GetData(),$DataSet->GetDataDescription(),3,2,255,255,255);   
  
  // Finish the graph   
  test.set_font_properties("Fonts/tahoma.ttf",8);
  //test.draw_legend(75,35,$DataSet->GetDataDescription(),255,255,255);   
  test.set_font_properties("Fonts/tahoma.ttf",10);
  test.draw_title(60,22,"example 1",50,50,50,585);
  test.write_to_png("example1.png");
}


void example12() {

  // Initialise the graph   
  chart test(700,230);
  test.set_font_properties("Fonts/tahoma.ttf",8);
  test.set_graph_area(50,30,680,200);
  test.draw_filled_rounded_rectangle(7,7,693,223,5,240,240,240);
  test.draw_rounded_rectangle(5,5,695,225,5,230,230,230);
  test.draw_graph_area(255,255,255,true);
  test.draw_scale(data,SCALE_NORMAL,150,150,150,true,0,2);
  test.draw_grid(4,true,230,230,230,50);

  // draw the 0 line
  test.set_font_properties("Fonts/tahoma.ttf",6);
  // test.drawTreshold(0,143,55,72,TRUE,TRUE);

  // Draw the bar graph
  // test.draw_bargraph(data,/* data_description */, true, 80);


 // Finish the graph
  test.set_font_properties("Fonts/tahoma.ttf",8);
  // $Test->drawLegend(596,150,$DataSet->GetDataDescription(),255,255,255);
  test.set_font_properties("Fonts/tahoma.ttf",10);
  test.draw_title(50,22,"Example 12",50,50,50,585);
  test.write_to_png("example12.png");

}


// TODO: Upon module init/loading do gdFontCacheSetup() and gdFreeFontCache() on unload.
int main() {

  gdFontCacheSetup();

  example0_a();
  example0_b();
  example1();
  example12();

  //  ch.test();

  gdFontCacheShutdown();
}
