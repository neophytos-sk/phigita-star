#include <iostream>
#include <vector>
#include <cstring>  // for memset


using namespace std;

#define FOR(i,a,b) for(int i=a;i<=b;++i)
template <class T> inline bool checkmax(T& a, T b) { bool p = a<b; if (p) a=b; return p; }

int max_cont_subseq_sum(vector<int>& a) {

  int n=a.size();
  a.insert(a.begin(),-1); // dummy value
  int prefix_sum[n+1];
  int opt[n+1];
  int back[n+1];
  memset(prefix_sum,0,sizeof(prefix_sum));
  memset(opt,0,sizeof(opt));
  memset(back,0,sizeof(back));

  FOR(i,1,n) prefix_sum[i] = prefix_sum[i-1] + a[i];

  FOR(i,1,n) {
    opt[i] = 0;
    FOR(j,1,i-1) {
      if (checkmax(opt[i],prefix_sum[i]-prefix_sum[j])) {
	back[i]=j;
      }
    }
  }

  int best=0;
  FOR(i,1,n) if (opt[best]<opt[i]) best=i;

  cout << "subseq from " << back[best] << " to " << best << endl;
  cout << "prefix_sum[back[best]]-prefix_sum[best] = " << prefix_sum[best] << " - " << prefix_sum[back[best]] << endl;

  return prefix_sum[best]-prefix_sum[back[best]];

}

int main() {

  int x;
  vector<int> a;
  while (cin >> x)
    a.push_back(x);


  int sum = max_cont_subseq_sum(a);
  cout << "max contiguous subsequence sum = " << sum << endl;

  return 0;

}
