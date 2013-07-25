#include <string>
#include <vector>
#include "datapoint.h"

using namespace std;

class Cluster
{
 private:
    vector<unsigned int> indexes;
 public:
    DataPoint* dataPoint;
    Cluster(DataPoint* dp);
    void update(DataPoint* dp);
    vector<unsigned int> getIndexes();
    double weight;
};
