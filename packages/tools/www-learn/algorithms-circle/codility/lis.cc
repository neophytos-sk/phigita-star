#include <iostream>
#include <vector>
#include <cstring>  // for memset

#define FOR(i,a,b) for(typeof(a) i=a;i<=b;++i)

template <class T> inline bool checkmax(T& a, T b) { bool p=a<b; if (p) {a=b;}; return p; }

using namespace std;

int lis(vector<int> a, int n) {

  // opt[i] - lis up including ith element

  int opt[n+1];
  int back[n+1];
  memset(opt,0,sizeof(opt));
  memset(back,0,sizeof(back));



  FOR(i,1,n) {
    checkmax(opt[i],1);         // element is the beginning of a new subsequence
    back[i] = i;
    FOR(j,1,i-1) {
      if (a[i]>a[j]) {
	if(checkmax(opt[i],opt[j]+1)) 
	  back[i]=j;
      }
    }
  }

  int best=0;
  FOR(i,1,n)
    if (opt[i]>opt[best])
      best=i;

  int curr=best;
  while(1) {
    cout << a[curr] << " ";
    if (curr==back[curr]) break;
    curr=back[curr];
  }
  cout << endl;

  return opt[best];

}


int main() {

  vector<int> a;
  int x;
  a.push_back(0);
  while (cin >> x)
    a.push_back(x);

  int len=lis(a,a.size()-1);

  cout << "size of problem = " << a.size()-1 << endl;
  cout << "length of the longest increasing subsequence = " << len << endl;

  return 0;

}
