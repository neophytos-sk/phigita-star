#include "map.h"
#include <iostream>

Map::Map(Evaluator* e) {
    eval = e;
    THRESHOLD = 0.54;
}

Map::Map(Evaluator* e, double thr) {
    eval = e;
    THRESHOLD = thr;
}

void Map::insertDataPoint(DataPoint* dp) {
    int closestCluster = -1;
    double closestDistance = 1;
    for (unsigned int i = 0; i < clusters.size(); i++) {
	double dist = clusters[i].dataPoint->cosineDistance(dp);
	if (dist < closestDistance) {
	    closestCluster = i;
	    closestDistance = dist;
	}
	 eval->addOut(dist);
    }

    if(THRESHOLD > closestDistance) {
	clusters[closestCluster].update(dp);
	eval->addIn(closestDistance);
      }
    else
	clusters.push_back(Cluster(dp));

}

int Map::numClusters() {
      return clusters.size();
}

void Map::decreaseWeights(double decrease) {
    vector<Cluster> V;
    for (unsigned int i = 0; i < clusters.size(); i++) {
	clusters[i].weight -= decrease;
	if (clusters[i].weight > 0) V.push_back(clusters[i]);
    }
    clusters.clear();
    clusters = V;
}

vector<Cluster> Map::getClusters() {
    vector<Cluster> V;
    V = clusters;
    stable_sort(V.begin(),V.end(),ClusterComparator());
    return V;
}

Evaluator* Map::getEvaluator()
{
    return eval;
}
