#include "cluster.h"

cluster::cluster(const datapoint& dp) : centroid_(dp), sum_of_points_(dp), num_of_points_(1) {
  ids_.insert(dp.get_id());
}

void cluster::relocate_centroid() {
  centroid_ = sum_of_points_ / num_of_points_;
}

void cluster::insert_point(const datapoint& dp) {
  ++num_of_points_;
  ids_.insert(dp.get_id());
  sum_of_points_ += dp;
}

void cluster::remove_point(const datapoint& dp) {
  ids_.erase(dp.get_id());
  --num_of_points_;
  sum_of_points_ -= dp;
}





const datapoint& cluster::get_centroid() const { return centroid_; }

std::set<int> cluster::get_identities() const { return ids_; }

int cluster::size() const { return num_of_points_; }
