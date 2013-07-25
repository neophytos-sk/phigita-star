#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

namespace {

using std::string;
using std::vector;

class ShorterThan {
public:
  /* Accept and store an int parameter */
  explicit ShorterThan(size_t max_length) : length(max_length) {}

  /* Return whether the string length is less than the stored int. */
  bool operator() (const string& str) const {
    return str.length() < length;
  }
private:
  const size_t length;
};

}


int main(int argc, char *argv[]) {

  if (argc==1) {
    printf("Usage: %s <string1> <string2> ... <stringN>",argv[0]);
    return 1;
  }

  vector<string> myVector;
  for (int i = 1; i < argc; ++i)
    myVector.push_back(argv[i]);

  // ShorterThan LessThanTen(10);
  // printf("%d\n", LessThanTen("hello world"));
  // printf("%d\n", LessThanTen("neophytos"));

  int num_of_strings = count_if(myVector.begin(),
				myVector.end(),
				ShorterThan(5));

  printf("Number of string with length less than five: %d\n",num_of_strings);
  return 0;
}
