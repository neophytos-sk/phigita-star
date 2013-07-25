#include <algorithm>
#include <cstdio>
#include <vector>


using std::vector;
using std::count_if;

bool IsEven(int value) {
  return value % 2 == 0;
}


int main(int argc, char *argv[]) {

  if (argc == 1) {
    printf("Usage: %s <num1> <num2> ... <numN>\n",argv[0]);
    return 1;
  }

  vector<int> myVector;
  for (int i=1; i<argc; ++i) 
    myVector.push_back(atoi(argv[i]));

  int numEvens = count_if(myVector.begin(), myVector.end(), IsEven);
  printf("numEvens = %d\n", numEvens);

  return 0;
}
