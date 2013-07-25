#include <iostream>
#include <string>


using namespace std;

void print_interleavings(string s1, string s2, string sofar) {

  if (!s1.size() && !s2.size()) {
    cout << sofar << endl;
    return;
  } else if (!s1.size())
    cout << sofar + s2 << endl;
  else if (!s2.size())
    cout << sofar + s1 << endl;
  else {
    print_interleavings(s1.substr(1),s2,sofar+s1[0]);
    print_interleavings(s1,s2.substr(1),sofar+s2[0]);
  }
}


int main() {
  string s1;
  string s2;
  cin >> s1;
  cin >> s2;
  print_interleavings(s1,s2,"");
  return 0;
}
