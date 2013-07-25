#include <vector>
#include <list>
#include <map>
#include <set>
#include <deque>
#include <queue>
#include <stack>
#include <bitset>
#include <algorithm>
#include <functional>
#include <numeric>
#include <utility>
#include <sstream>
#include <iostream>
#include <iomanip>
#include <cstdio>
#include <cmath>
#include <cstdlib>
#include <cctype>
#include <string>
#include <cstring>
#include <cstdio>
#include <cmath>
#include <cstdlib>
#include <ctime>

using namespace std;

#define SIZE(X) ((int)(X.size()))
#define LENGTH(X) ((int)(X.length()))
template<class T> inline void checkmin(T &a,T b){if(b<a) a=b;}

class EllysString
{
public:
  int theMin(int n, string a, string b)
  {

    int sa[26],sb[26],ga[26][n],gb[26][n];
    int f[n+1];

    for (int i=0;i<=n;i++) f[i]=i;
    for (int k=0;k<n;k++)
    {
      checkmin(f[k+1],f[k]+1);
      int total=0,cbad=0;
      memset(sa,0,sizeof(sa));
      memset(sb,0,sizeof(sb));
      for (int i=k;i<n;i++)
      {
        int key=a[i]-'A';
        cbad-=(int)(sa[key]!=sb[key]);
        ga[key][sa[key]]=i;

        if (sa[key]<sb[key]) total+=abs(ga[key][sa[key]]-gb[key][sa[key]]);
        sa[key]++;
        cbad+=(int)(sa[key]!=sb[key]);

        key=b[i]-'A';
        cbad-=(int)(sa[key]!=sb[key]);
        gb[key][sb[key]]=i;

        if (sb[key]<sa[key]) total+=abs(gb[key][sb[key]]-ga[key][sb[key]]);
        sb[key]++;
        cbad+=(int)(sa[key]!=sb[key]);
        if (cbad==0) checkmin(f[i+1],f[k]+total/2);
      }
    }
    return f[n];
  }
};

int main() {

  int n;
  string s1;
  string s2;

  cin >> n;
  cin >> s1;
  cin >> s2;

  EllysString es;
  int m = es.theMin(n,s1,s2);

  cout << m << endl;

  return 0;
}
