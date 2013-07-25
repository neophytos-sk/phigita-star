#include <iostream>
#include <string>

using namespace std;

int isAnagramOfPalindrome ( const string &S ) {

  int n=S.size();
  int x=0;
  for(int i=0;i<n;i++)
    x = x ^ S[i];

  if (n%2==0)
    return x==0;
  else {
    int count = 0;
    for(int i=0;i<n;i++)
      if (S[i] == x) count++;

    return count%2==1;
  }

}


int main() {
  string s;
  cin >> s;
  cout << "isAnagramOfPalindrome=" << isAnagramOfPalindrome(s) << endl;

  return 0;
}
