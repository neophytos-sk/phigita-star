#include <numeric>  // for accumulate
#include <cstdio>   // for printf
#include <cstdlib>  // for atoi
#include <limits>   // for numeric_limits
#include <vector>

using std::vector;
using std::accumulate;
using std::numeric_limits;

class LowerBoundHelper {
public:
  explicit LowerBoundHelper(int lower) : lowest_value(lower) {}
  int operator() (int best_sofar, int current) {
    return current >= lowest_value && current < best_sofar ?
      current : best_sofar;
  }

private:
  const int lowest_value;
};



int main(int argc, char *argv[]) {
  
  if (argc==1) {
    printf("Usage: %s <num1> <num2> ... <numN>\n",argv[0]);
    return 1;
  }

  vector<int> myVector;
  for (int i = 1; i < argc; ++i) 
    myVector.push_back(atoi(argv[i]));


  int result = accumulate(myVector.begin(),myVector.end(),
			  numeric_limits<int>::max(),LowerBoundHelper(12));

  printf("result = %d infinity=%d limits_max=%d\n",
	 result, numeric_limits<int>::infinity(), numeric_limits<int>::max());

  printf("has_infinity = %d\n",numeric_limits<int>::has_infinity);

  return 0;

}
