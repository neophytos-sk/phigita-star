#include <iostream>
#include <string>
#include <algorithm>
#include <iomanip>
#include <map>

#define RA(x) (x).begin(),(x).end()

using namespace std;

bool anagram_check(string& x, string& y) {
  
  sort(RA(x));
  sort(RA(y));

  return x==y;

}

bool anagram_check_xor(const string& x, const string& y) {

  const int sx = x.size();
  const int sy = y.size();

  if (sx!=sy) return false;

  char c;
  for(int i=0;i<sx; i++) {
    c = c ^ x[i];
    c = c ^ y[i];
  }

  return c==0;
}

bool anagram_check_map(const string& x, const string& y) {

  const int sx = x.size();
  const int sy = y.size();

  if (sx != sy) return false;

  map<char,int> mx;
  map<char,int> my;

  for(int i=0; i<sx; i++)
    mx[x[i]]++, my[y[i]]++;

  map<char,int>::const_iterator x_it=mx.begin();
  map<char,int>::const_iterator x_end=mx.end();

  for(;x_it!=x_end;++x_it)
    if (x_it->second != my[x_it->first])
      return false;

  return true;

}

int main() {
  string x;
  string y;

  cin >> x;
  cin >> y;

  cout << "x anagram of y: " << boolalpha << anagram_check(x,y) << endl;
  cout << "x anagram of y: " << boolalpha << anagram_check_xor(x,y) << endl;
  cout << "x anagram of y: " << boolalpha << anagram_check_map(x,y) << endl;

  return 0;

}
