#ifndef CLUSTER_H
#define CLUSTER_H

#include <list>
#include "datapoint.h"

class cluster {
 public:
  cluster(const datapoint& dp, double weight = 1.0);
  double distance_from(const datapoint& dp) const;
  void update(const datapoint& dp);

  const datapoint& get_center() const;
  std::list<int> get_identities() const;


  typedef std::list<int>::iterator iterator;
  typedef std::list<int>::const_iterator const_iterator;

 private:
  datapoint center_;
  double weight_;
  std::list<int> ids_;
};

#endif
