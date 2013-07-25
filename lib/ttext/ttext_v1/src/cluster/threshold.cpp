#include "threshold.h"

bool Threshold::add(double distance) {
    if(distances.size() < 1000) {
	distances.push_back(distance);
	return true;
      }
    return false;
}

vector<double> Threshold::getThreshold() {
      sort(distances.begin(),distances.end());
      return distances;
   }

unsigned int Threshold::getSize()
{
    return distances.size();
}
