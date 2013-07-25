#include <cstdio>
#include <string>

namespace {

  using std::string;

class MyFunctor {
public:
  void operator() (const string& str) const {
    printf("%s\n",str.c_str());
  }
};
  
} // unnamed namespace



int main(int argc, char *argv[]) {
  MyFunctor myFunctor;
  myFunctor("C++ is awesome");
  return 0;
}
