

/*
 * NOTE: This is only relevant for online clustering of data.
 * 
 * Problem: Clusters need to die out over time - they need to
 * gradually disappear if new data is not being added to them. 
 *
 * We use the following scheme: a cluster starts out with weight
 * of one. Every time a point (e.g. an article) is added to it,
 * its weight increases by 1. After each time-step the weights
 * of all clusters decrease by one. When a cluster reaches 
 * weight 0, it disappears.
 *
 * Using this method would make clusters to which articles 
 * are not added at a high enough rate disappear and those to
 * which articles are added often be reinforced.
 */

#define eps 0.00001
bool cluster::fade_out () {
  --weight_;
  if (weight_ < eps) {
    return true; // destroy
  }
  return false; // keep
}

//int cluster::count_ = 0;




/*
 * As data is added to clusters, we update the vectors representing
 * the clusters in the following way. Take 'n' to be the number of points
 * in the cluster, C to be the vector representing the cluster, and 
 * V to be the vector being added to the cluster.
 *
 *     C := (n*C + V) / (n + 1)
 *
 * equivalently,
 *
 *     C := n/(n+1) * C + 1/(n+1) * V
 * 
 * where,
 *
 *     C = freq_map_
 *     n = weight
 *     V = other
 *
 * Then the vector is normalized again. By this scheme, each new component
 * modifies the cluster less and less the more points the cluster represents.
 * With this scheme, each cluster is represented by all of the articles that
 * were included in it, solving the problem posed in the straight single-pass
 * approach.
 *
 */
