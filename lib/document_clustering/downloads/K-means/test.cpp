#include <iostream>
#include "cluster.hpp"

using namespace Clustering;

int main(int argc, char* argv[])
{
  ClusterId num_clusters = 30;
  PointId num_points = 3000;
  Dimensions num_dimensions = 10;

  PointsSpace ps(num_points, num_dimensions);
  //std::cout << "PointSpace" << ps;

  Clusters clusters(num_clusters, ps);

  clusters.k_means();
  
  std::cout << clusters;

}
