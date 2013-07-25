#include <vector>
#include <algorithm>

using namespace std;

class Threshold
{
    vector<double> distances;
 public:
    bool add(double distance);
    vector<double> getThreshold();
    unsigned int getSize(); //returns the distances vector size
};
