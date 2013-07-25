#include <vector>
#include <stdlib.h>
#include "cluster.h"
#include "evaluator.h"
#include <algorithm>

using namespace std;

class ClusterComparator
{
 public:
    bool operator()(Cluster c1, Cluster c2) {
	if (c1.weight <= c2.weight) return true;
	else if (c1.weight > c2.weight) return false;
    }
};

class Map 
{
    vector<Cluster> clusters;
    Evaluator* eval;
 public:
    double THRESHOLD;
   
    Map(Evaluator* e);
    Map(Evaluator* e, double thr);
    void insertDataPoint(DataPoint* dp);
    int numClusters();
    
    void decreaseWeights(double decrease);

    vector<Cluster> getClusters();
    Evaluator* getEvaluator();

    
};
