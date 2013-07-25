#include <cstdio>
#include <functional>  // for bind2nd
#include <vector>
#include <algorithm>   // for count_if
#include <string>

using std::bind2nd;
using std::vector;
using std::count_if;
using std::string;
using std::not2;

bool LengthIsLessThan(string str, int threshold) {
  return str.length() < threshold;
}

int main(int argc, char *argv[]) {

  if (argc==1) {
    printf("Usage: %s <str1> <str2> ... <strN>\n",argv[0]);
    return 1;
  }

  vector<string> myVector;
  for (int i=1; i<argc; ++i)
    myVector.push_back(argv[i]);

  int result = count_if(myVector.begin(), 
			myVector.end(),
			bind2nd(not2(ptr_fun(LengthIsLessThan)),5));

  printf("Number of strings with length less than 5: %d\n",result);


  return 0;

}

// ./a.out hello world this is a test neophytos demetriou
// ./a.out abra cadabra blah blah test hello world bingo
