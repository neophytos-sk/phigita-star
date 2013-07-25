#include <iostream>
#include <algorithm>
#include <sstream>

using namespace std;

int op_increase(int i) { ++i; }

int main(int argc, char *argv[]) {

  string s;
  cout << "Enter line: ";
  getline(cin,s);

  // transform(InputIterator first1, InputIterator last1, OutputIterator result, UnaryOperator op);
  transform(s.begin(),s.end(),s.begin(),::toupper);
  cout << s << '\n';

}
