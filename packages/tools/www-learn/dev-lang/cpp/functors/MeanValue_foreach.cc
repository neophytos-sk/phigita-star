/* The Return Value of for_each()
 *
 * The effort involved with a reference-counted implementation of a function
 * object to access its final state is not necessary if you use the for_each()
 * has the unique ability to return its function object (no other algorithm
 * can do this). Thus you can query the state of your function object by 
 * checking the return value of for_each().
 *
 */

#include <cstdio>
#include <vector>
#include <algorithm>

using std::for_each;
using std::vector;


class MeanValue {
public:
  MeanValue() : num(0), sum(0) {}
  void operator()(int elem) {
    ++num;
    sum+=elem;
  }
  double value() {
    return static_cast<double>(sum) / static_cast<double>(num);
  }
private:
  long num;
  long sum;
};


int main() {
  vector<int> coll;

  for(int i=1;i<=8;++i)
    coll.push_back(i);

  MeanValue mv = for_each(coll.begin(),coll.end(),MeanValue());

  printf("mean value: %f\n", mv.value());

  return 0;

}
