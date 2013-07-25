// next_permutation
#include <iostream>
#include <algorithm>
#include <string>

using namespace std;

int main () {

  string str = "neophytos";
  //string str = "bca";
  
  sort (str.begin(),str.end());

  do {
    cout << str << endl;
  } while ( next_permutation (str.begin(),str.end()) );
  
  return 0;
}
