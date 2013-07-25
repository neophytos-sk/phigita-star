class BaseChart {
public:
  void set_size();
  int get_width();
  int get_height();
  void add_title(const std::string& title);
  add_legend(int topleft_x, int topleft_y);
  DrawArea get_drawarea();
  bool make_chart_to_file(int display_type, const char *filename);
  bool make_chart_to_memory(int display_type, const char *filename);
};

class PieChart : public BaseChart {
public:
  PieChart(int width, int height);
  setPieSize(double center_x, double center_y, double radius);
  setData(const DoubleArray& data, const StringArray& labels, int n_labels);
private:
};

class XYChart

/*
  #include "chartdir.h"
  int main(int argc, char *argv[])
  {
  // The data for the pie chart
  double data[] = {25, 18, 15, 12, 8, 30, 35};
  // The labels for the pie chart
  const char *labels[] = {"Labor", "Licenses", "Taxes", "Legal", "Insurance",
  "Facilities", "Production"};
  // Create a PieChart object of size 360 x 300 pixels
  PieChart *c = new PieChart(360, 300);
  // Set the center of the pie at (180, 140) and the radius to 100 pixels
  c->setPieSize(180, 140, 100);
  // Set the pie data and the pie labels
  c->setData(DoubleArray(data, sizeof(data)/sizeof(data[0])), StringArray(labels,
  sizeof(labels)/sizeof(labels[0])));
  // Output the chart
  c->makeChart("simplepie.png");
  //free up resources
  delete c;
  return 0;
  }
 */
