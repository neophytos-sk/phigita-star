#include <vector>
#include <utility>  // for pair

using std::vector;
using std::pair;


namespace phigita {

  class base_chart {
  public:
    //virtual void draw();
    explicit base_chart(int width, int height);
    ~base_chart();
    void set_graph_area(int x1, int y1, int x2, int y2);
    virtual void draw() = 0;
    virtual void draw_title(int xpos, int ypos, const char *text, int r, int g, int b) = 0;
    virtual void draw(const vector<pair<double,double> >& data, int palette_id) {};
    void write_to_png(const char *filename);
  protected:
    struct plotter_impl; // fwd declaration
    plotter_impl *pimpl_;

    /* vars related to the graphing area */
    int garea_x1_;
    int garea_y1_;
    int garea_x2_;
    int garea_y2_;
  };

}
