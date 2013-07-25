#include <cstdio>
#include <functional>  // for bind2nd, plus<int>
#include <vector>
#include <algorithm>   // for tranform


using std::bind2nd;
using std::vector;
using std::transform;
using std::plus;

int main(int argc, char *argv[]) {

  if (argc==1) {
    printf("Usage: %s <num1> <num2> ... <numN>\n",argv[0]);
    return 1;
  }

  vector<int> myVector;
  for (int i=1; i<argc; ++i)
    myVector.push_back(atoi(argv[i]));


  transform(myVector.begin(),myVector.end(),myVector.begin(),
	    bind2nd(plus<int>(),137));

  for (vector<int>::iterator itr = myVector.begin();
       itr != myVector.end();
       ++itr) {
    printf("%d\n",*itr);
  }

  return 0;

}
//./a.out 34 243 235 2 1 0 2 30 23

