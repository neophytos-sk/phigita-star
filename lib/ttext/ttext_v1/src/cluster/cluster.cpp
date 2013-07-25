#include "cluster.h"

Cluster::Cluster(DataPoint* dp)
{
    dataPoint = dp;
    weight = 1.0;
    indexes.push_back(dp->getIndex());
}

void Cluster::update(DataPoint* dp)
{
    dataPoint->add(dp, weight);
    weight++;
    indexes.push_back(dp->getIndex());
}

vector<unsigned int> Cluster::getIndexes()
{
    return indexes;
}
