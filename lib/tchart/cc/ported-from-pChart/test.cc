#include <plotter.h>
#include <iostream>
#include <sstream>

const int maxorder = 12;
void draw_c_curve (Plotter& plotter, double dx, double dy, int order)
{
  if (order >= maxorder)
    plotter.fcontrel (dx, dy); // continue path along (dx, dy)
  else
    {
      draw_c_curve (plotter,
                    0.5 * (dx - dy), 0.5 * (dx + dy), order + 1);
      draw_c_curve (plotter,
                    0.5 * (dx + dy), 0.5 * (dy - dx), order + 1);
    }
}



int main(){
  std::stringstream ss;

  //std::stringbuf sb;
  //std::ostream os(&sb);

  // set a Plotter parameter
  PlotterParams params;
  params.setplparam ("PAGESIZE", (char *)"letter");
  //PSPlotter plotter(cin, cout, cerr, params); // declare Plotter
  PSPlotter plotter(ss,params);
  if (plotter.openpl () < 0)                  // open Plotter
    {
      cerr << "Couldn’t open Plotter\n";
      return 1;
    }
  plotter.fspace (0.0, 0.0, 1000.0, 1000.0); // specify user coor system
  plotter.flinewidth (0.25);       // line thickness in user coordinates
  plotter.pencolorname ("red");    // path will be drawn in red
  plotter.erase ();                // erase Plotter’s graphics display
  plotter.fmove (600.0, 300.0);    // position the graphics cursor
  draw_c_curve (plotter, 0.0, 400.0, 0);

  if (plotter.closepl () < 0)      // close Plotter
    {
      cerr << "Couldn’t close Plotter\n";
      return 1;
    }

  if (ss.fail()) {
    std::cout << "fail" << '\n';
  }

  {
    const std::string& tmp = ss.str();
    const char* cstr = tmp.c_str();
    std::cout << cstr;
  }
  cout << ss;


  return 0;
}
