#include <cstdio>
#include <functional>  // for bind2nd
#include <vector>
#include <algorithm>   // for count_if
#include <string>

using std::bind1st;
using std::vector;
using std::count_if;
using std::string;

bool LengthIsLessThan(string str, int threshold) {
  return str.length() < threshold;
}

int main(int argc, char *argv[]) {

  if (argc==1) {
    printf("Usage: %s <num1> <num2> ... <numN>\n",argv[0]);
    return 1;
  }

  vector<int> myVector;
  for (int i=1; i<argc; ++i)
    myVector.push_back(atoi(argv[i]));

  int result = count_if(myVector.begin(), 
			myVector.end(),
			bind1st(ptr_fun(LengthIsLessThan),"C++"));

  printf("Number of elements in the vector bigger than the length of string 'C++': %d\n",result);

  return 0;

}
//./a.out 34 243 235 2 1 0 2 30 23

