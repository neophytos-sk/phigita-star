#ifndef CLUSTER_H
#define CLUSTER_H

#include <set>
#include "datapoint.h"

class cluster {
 public:
  cluster(const datapoint& dp);
  void relocate_centroid();
  void insert_point(const datapoint& dp);
  void remove_point(const datapoint& dp);


  const datapoint& get_centroid() const;
  std::set<int> get_identities() const;
  int size() const;

  typedef std::set<int>::iterator iterator;
  typedef std::set<int>::const_iterator const_iterator;

 private:
  datapoint centroid_;
  datapoint sum_of_points_;
  int num_of_points_;
  double weight_;
  std::set<int> ids_;

};

#endif
