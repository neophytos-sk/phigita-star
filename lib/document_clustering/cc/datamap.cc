#include "datamap.h"
#include <iostream>
using std::cout;

datamap::datamap() {}

bool datamap::assign_to_nearest_cluster(const datapoint& dp) {

  bool changed  = false;
  double distance;
  double nearest_distance = 1.0;
  int nearest_cluster=0;

  vector<cluster>::const_iterator cluster_iter = clusters_.begin();
  const vector<cluster>::const_iterator end = clusters_.end();

  for(int i=0; cluster_iter!=end; ++i, ++cluster_iter) {
    distance = cluster_iter->get_centroid().cosine_distance_from(dp);
    if (distance < nearest_distance) {
      nearest_distance = distance;
      nearest_cluster = i;
    }
    eval_.addOut(distance);
  }

  int point_id = dp.get_id();
  int current_cluster = point_to_cluster_[point_id];
  if (nearest_cluster != current_cluster) {
    if (current_cluster != -1) {
      clusters_[current_cluster].remove_point(dp);
    }
    point_to_cluster_[point_id] = nearest_cluster;
    clusters_[nearest_cluster].insert_point(dp);
    changed = true;
  }

  eval_.addIn(nearest_distance);

  return changed;

}

void datamap::compute_centroids() {
  vector<cluster>::iterator cluster_iter = clusters_.begin();
  const vector<cluster>::const_iterator end = clusters_.end();

  for(int i=0; cluster_iter!=end; ++i, ++cluster_iter)
    cluster_iter->relocate_centroid();

}


int datamap::num_clusters() const { return clusters_.size(); }
void datamap::get_clusters(vector<cluster>& clusters) const { clusters = clusters_; }


evaluator *datamap::get_evaluator() { return &eval_; }

/* k-means++ */
void datamap::kmeans(const vector<datapoint>& dps, int k) {

  /* Make sure point IDs start from zero, 
   * centroid->get_id() must much the variable r.
   */
  if (!dps.at(0).get_id() == 0) { return; }


  const int n = dps.size();
  /* Make sure we have more datapoints than clusters */
  if (k >= n) { return; }

  int used[n];
  if (point_to_cluster_.size() != n)
    point_to_cluster_.resize(n,-1);

  for (int i=0;i<n;++i) {
    used[i]=0;
    point_to_cluster_[i]=-1;
  }

  clusters_.clear();



  unsigned int seed = time(NULL);

  /*
   * Select initial centers  using k-means++ algorithm
   * 1. Choose first center at random
   * 2. Choose next centers using their distance from centers already chosen
   *
   */

  /* Choose one center uniformly at random from among the data points. */
  unsigned int r = (unsigned int)(rand_r(&seed) * RAND_MAX) % n;

  vector<datapoint>::const_iterator centroid = dps.begin()+r;

  clusters_.push_back(cluster(*centroid));

  used[r]=1;
  point_to_cluster_[r] = 0;

  /* Repeat until K centroids have been chosen. */

  double dist[n];
  for (int i=0;i<n;++i) dist[i]= 1.0; // std::numeric_limits<double>::max();

  vector<datapoint>::const_iterator iter;
  const vector<datapoint>::const_iterator end = dps.end();

  for (int i=1; i<k; ++i) {

    /* For each data point x, compute dist_sq[x], the distance between x and 
     * the nearest centroid that has already been chosen.
     */
    double total_dist = 0.0;
    iter = dps.begin();
    for(int x=0; iter!=end; ++iter) {
      if (used[x]) 
	dist[x]=0.0;
      else
	dist[x] = iter->cosine_distance_from(*centroid);

      if (dist[x]>1) { cout << dist[x] << '\n'; }

      total_dist += dist[x];
      ++x;
    }

    /* Add one new data point at random as a new center, using a weighted
     * probability distribution where a point X is chosen with probability
     * proportional to dist_sq[x]^2.
     */
    while (true) {
      double cutoff = (rand_r(&seed) / double(RAND_MAX)) * total_dist;

      double curr_dist = 0;
      for (r=0; r<n; ++r) {
	curr_dist += dist[r];
	if (curr_dist >= cutoff) break;
      }
      if (r < n) break;
    }

    centroid = dps.begin()+r;
    clusters_.push_back(cluster(*centroid));
    used[r]=1;
    point_to_cluster_[r] = i;
  }

  bool some_point_is_moving = true;
  int round = 0;  // up to 10 rounds to stabilize
  while(some_point_is_moving && round++ < 10) {

    eval_.reset();

    some_point_is_moving = false;

    iter = dps.begin();
    for(int x=0; iter!=end; ++x, ++iter) {
      some_point_is_moving = assign_to_nearest_cluster(*iter) || some_point_is_moving;
    }

    if (some_point_is_moving) compute_centroids();
    


    /*
     * The objective is to cluster the data in such a way as to minimize
     * the intra-cluster data point distances while maximizing 
     * inter-cluster distances.
     *
     * InAvg - intra-cluster average 
     * OutAvg - inter-cluster average
     *
     */
    cout << "some_point_is_moving=" << some_point_is_moving << " "
	 << "InSqrSum=" << eval_.getInSqrSum() << " "
	 << "OutSqrSum=" << eval_.getOutSqrSum() << " "
	 << "InAvg=" << eval_.getInAvg() << " "
	 << "OutAvg=" << eval_.getOutAvg() << " "
	 << "InStdDev=" << eval_.getInStdev() << " "
	 << "OutStdDev=" << eval_.getOutStdev() << " "
	 << '\n';

  }
  
}

