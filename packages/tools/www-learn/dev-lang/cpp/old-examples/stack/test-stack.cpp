#include <iostream>
#include <cstdlib>
#include "stack.h"

using namespace std;

void PrintStack(Stack& stack) {
  void *data;
  while(data = stack.pop()) {
    cout << static_cast<int>(reinterpret_cast<long long>(data)) << endl;
  }

}


int main(int argc, char *argv[]) 
{

  int i;

  Stack stack;
  for(i=1;i<argc;++i)
    stack.push( reinterpret_cast<void *>(atoi(argv[i]))  );
    
  PrintStack(stack);

  return 0;
}
