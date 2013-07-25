#include <iostream>
#include <list>
#include <map>
#include <cstring>  // for memset
#include <queue>    // for queue

#define RA(x) (x).begin(),(x).end()
#define tr(x,it) for(typeof((x).begin()) it=(x).begin();it!=(x).end();++it)

using namespace std;


class graph {
public:
  graph(int n) : n_(n) {}

  void add_edge(int u, int v, int type = 0) {
    adj_edge_[u].push_back(v);
  }
  void print() {
    tr(adj_edge_,it) {
      tr(adj_edge_[it->first], it2) {
	cout << it->first << "," << *it2 << endl;
      }
    }
  }
  void toposort() {
    int indegrees[n_+1];
    memset(indegrees,0,(n_+1)*sizeof(int));


    // keep a queue of nodes with indegree = 0
    queue<int> q;
    tr(adj_edge_,it) {
      tr(adj_edge_[it->first], it2) {
	indegrees[*it2]++;
      }
    }


    for(int i=1;i<=n_;i++) {
      if (indegrees[i]==0) q.push(i);
      cout << "i=" << i << " indegrees=" << indegrees[i] << endl;
    }


    int num_visited=0;
    int visited[n_+1];
    memset(visited,0,(n_+1)*sizeof(int));
    int v=0;
    while(num_visited!=n_) {
      v = q.front();
      q.pop();

      tr(adj_edge_[v],it)
	if (--indegrees[*it] == 0)
	  q.push(*it);

      cout << "visit " << v << endl;

      num_visited++;
      visited[v]=1;
    }

  }
private:
  int n_;
  map<int,list<int> > adj_edge_;
};



int main() {

  int n, m1, m2;
  cin >> n >> m1 >> m2;

  graph g(n);
  for(int i=0;i<m1+m2;i++) {
    int u,v;
    cin >> u >> v;
    g.add_edge(u,v,i>m1);
  }
  g.print();
  cout << "----------" << endl;
  g.toposort();

  return 0;
}
