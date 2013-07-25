#include "datamap.h"

datamap::datamap() {}

void datamap::insert_datapoint(const datapoint& dp) {

  double distance;
  double closest_distance = 1.0;
  int closest_cluster=0;

  cluster_vector_t::const_iterator cluster_iter = clusters_.begin();
  const cluster_vector_t::const_iterator stop = clusters_.end();

  for(int i=0; cluster_iter!=stop; ++i, ++cluster_iter) {
    distance = cluster_iter->distance_from(dp);
    //printf("cluster %d distance=%f\n",cluster_iter->get_center().get_id(),distance);
    if (distance < closest_distance) {
      closest_distance = distance;
      closest_cluster = i;
    }
    // eval_.addOut(distance);
  }

  //printf("closest_cluster=%d\n",closest_cluster);
  clusters_[closest_cluster].update(dp);

  // use this code only if no initial centers computed
  /*
  if (closest_distance < threshold_) {
    closest_cluster->update(dp);
    // eval_.addIn(closest_distance);
  } else {
    clusters_.push_back(cluster(dp));
  }
  */

}


int datamap::num_clusters() const { return clusters_.size(); }
void datamap::get_clusters(cluster_vector_t& clusters) const { clusters = clusters_; }


/* k-means++ */
void datamap::analyze(const datapoint_vector_t& dps, int k) {

  unsigned int seed = time(NULL);
  const int n = dps.size();
  int used[n];
  for (int i=0;i<n;++i) used[i]=0;


  /* Choose one center uniformly at random from among the data points. */
  unsigned long r = (unsigned)(rand_r(&seed) * RAND_MAX) % n;
  //printf("r=%ld n=%d\n",r,n);
  datapoint_vector_t::const_iterator center = dps.begin()+r;
  clusters_.push_back(cluster(*center));
  used[r]=1;


  /* Repeat until K centers have been chosen. */

  double dist_sq[n];
  for (int i=0;i<n;++i) dist_sq[i]=std::numeric_limits<double>::max();

  datapoint_vector_t::const_iterator iter;
  const datapoint_vector_t::const_iterator stop = dps.end();

  for (int i=1; i<k; ++i) {

    /* For each data point X, compute D(X), the distance between X and 
     * the nearest center that has already been chosen.
     */
    double total_dist = 0.0;
    iter = dps.begin();
    for(int x=0; iter!=stop; ++iter) {
      if (used[x]) 
	dist_sq[x]=0.0;
      else
	dist_sq[x] = std::min(dist_sq[x],pow(iter->cosine_distance_from(*center),2));

      total_dist += dist_sq[x];
      ++x;
    }

    /* Add one new data point at random as a new center, using a weighted
     * probability distribution where a point X is chosen with probability
     * proportional to D(X)^2.
     */
    while (true) {
      double cutoff = (rand_r(&seed) / double(RAND_MAX)) * total_dist;
      //printf("cutoff=%f i=%d n=%d\n",cutoff,i,n);
      double curr_dist = 0;
      for (r=0; r<n; ++r) {
	curr_dist += dist_sq[r];
	//printf("curr_dist=%f\n",curr_dist);
	if (curr_dist >= cutoff) break;
      }
      if (r < n) break;
    }

    center = dps.begin()+r;
    clusters_.push_back(cluster(*center));
    used[r]=1;
    //printf("r=%ld n=%d\n",r,n);
  }


  /* Now that the initial centers have been chosen, proceed using
   * standard k-means clustering.
   */

  //printf("%zd\n",clusters_.size());
  iter=dps.begin();
  for(int x=0; iter!=stop; ++iter) {
    if (!used[x])
      insert_datapoint(*iter);

    ++x;

  }

}

