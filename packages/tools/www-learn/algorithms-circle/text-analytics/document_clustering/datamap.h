#ifndef DATAMAP_H
#define DATAMAP_H

#include <limits>  // For numeric_limits
#include <cmath>    // For pow
#include <ctime>    // For time
#include <cstdlib>  // For rand_r
#include <vector>
#include "datapoint.h"
#include "cluster.h"

typedef std::vector<datapoint> datapoint_vector_t;
typedef std::vector<cluster> cluster_vector_t;


class datamap {
 public:
  datamap();
  void analyze(const datapoint_vector_t& dps, int k);  // k-means++
  void decrease_weights();
  void get_clusters(cluster_vector_t& clusters) const;
  int  num_clusters() const;
 private:
  void pretty_print();
  void insert_datapoint(const datapoint& dp);
  cluster_vector_t clusters_;
};

#endif
