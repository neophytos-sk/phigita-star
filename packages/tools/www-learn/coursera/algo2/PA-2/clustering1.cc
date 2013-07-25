/* Max-Spacing k-Clusterings
 * the spacing of a k-clustering is min_of_separates_{p,q} d(p,q)
 */


#include <iostream>
#include <fstream>
#include <queue>
#include <map>

using namespace std;

struct edge_t {
  edge_t(int u, int v, int cost) : cost_(cost), u_(u), v_(v) {}
  int cost_;
  int u_;
  int v_;
};

struct edge_comparator {
    bool operator()(const edge_t& e1, const edge_t& e2) {
        return e1.cost_>e2.cost_; 
    }
};

const int k = 4;

int main(int argc, char **argv) {

  if (argc!=2) {
    cout << "Usage: " << argv[0] << " filename" << endl;
    return 1;
  }

  ifstream infile;
  infile.open(argv[1]);

  int n;
  infile >> n;
  priority_queue<edge_t, vector<edge_t>, edge_comparator> pq;
  map<int,vector<int> > adj;
  for(int i=0;i<n*n;++i) {
    int u,v,cost;
    infile >> u >> v >> cost;
    pq.push(edge_t(u,v,cost));
    adj[u].push_back(v);
    adj[v].push_back(u);
  }
  infile.close();

  if (n < k) {
    cout << "too few nodes" << endl;
  }

  int cluster[n+1];
  for(int i=1;i<=n;++i) cluster[i]=i;

  int i = 0;
  while (i < n-k) {
    edge_t e = pq.top();
    pq.pop();

    if (cluster[e.u_] == cluster[e.v_]) continue;

    // merge the two clusters
    for(int j=1;j<=n;j++)
      if (j != e.v_ && cluster[j] == cluster[e.v_]) {
	cluster[j] = cluster[e.u_];
	//cout << "merge " << j << endl;
      }
    cluster[e.v_] = cluster[e.u_];

    // cout << "i=" << i << " (" << e.u_ << "," << e.v_ << ") " << " cost=" << e.cost_ << " cluster=" << cluster[e.v_] << endl;

    ++i;
  }

  int max_spacing = 0;
  while(!pq.empty()) {
    edge_t e = pq.top();
    pq.pop();

    if (cluster[e.u_] != cluster[e.v_]) {
      max_spacing = e.cost_;
      break;
    }

  }

  // for(int i=1;i<=n;i++) cout << "i=" << i << " cluster=" << cluster[i] << endl;

  cout << "max_spacing = " << max_spacing << endl;
  return 0;

}
