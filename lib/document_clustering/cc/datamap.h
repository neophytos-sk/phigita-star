#ifndef DATAMAP_H
#define DATAMAP_H

#include <limits>  // For numeric_limits
#include <cmath>    // For pow
#include <ctime>    // For time
#include <cstdlib>  // For rand_r
#include <vector>

#include "datapoint.h"
#include "cluster.h"
#include "evaluator.h"

using std::vector;
using std::set;

class datamap {
 public:
  datamap();

  void kmeans(const vector<datapoint>& dps, int k);
  void decrease_weights();
  void get_clusters(vector<cluster>& clusters) const;
  int  num_clusters() const;
  evaluator *get_evaluator();

  void compute_centroids();

 private:
  void pretty_print();
  bool assign_to_nearest_cluster(const datapoint& dp);

  vector<cluster>   clusters_;

  vector<int> point_to_cluster_;
  evaluator eval_;

};

#endif
