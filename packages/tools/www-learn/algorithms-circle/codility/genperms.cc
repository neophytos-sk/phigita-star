#include <iostream>
#include <algorithm>
#include <string>

#define RA(x) (x).begin(),(x).end()

using namespace std;

int main() {
  string s;
  cin >> s;
  sort(RA(s));
  cout << s << endl;
  while(next_permutation(RA(s)))
    cout << s << endl;

  return 0;

}
