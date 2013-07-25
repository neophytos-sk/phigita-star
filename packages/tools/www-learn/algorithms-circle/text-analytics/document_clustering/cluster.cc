#include "cluster.h"


cluster::cluster(const datapoint& dp, double weight) : center_(dp), weight_(weight) {
  ids_.push_back(dp.get_id());
}

double cluster::distance_from(const datapoint& dp) const {
  return center_.cosine_distance_from(dp);
}

void cluster::update(const datapoint& dp) {
  center_.add(dp,weight_);
  ++weight_;
  ids_.push_back(dp.get_id());
}

const datapoint& cluster::get_center() const {return center_;}

std::list<int> cluster::get_identities() const {
  return ids_;
}
