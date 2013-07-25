#include <iostream>
#include <list>
#include <set>
#include <map>
#include <algorithm>
#include <cstring>  // for memset
#include <utility>  // for pair
#include <queue>

#define RA(x) (x).begin(),(x).end()
#define tr(it,x) for(typeof((x).begin()) it = (x).begin(); it!=(x).end(); ++it)
#define pii pair<int,int>

using namespace std;

class graph {
public:
  bool exists(int u) {
    return vertex.count(u)!=0;
  }
  void add_node(int u) {
    vertex.insert(u);
  }
  void add_edge(int u, int v) {
    if (!exists(u)) add_node(u);
    if (!exists(v)) add_node(v);
    adj[u].push_back(v);
  }
  void dfs() {
    int n = vertex.size();

    time = 0;
    // nodes start out unmarked
    tr(it,vertex) d[*it]=0, f[*it]=0, visited[*it]=0;
    tr(it,vertex)
      if (!visited[*it])
	dfs_visit(*it);
  }
  void dfs_visit(int s) {
    time++;
    d[s] = time;  // discovery time for s
    visited[s] = 1;
    tr(it,adj[s])
      if (!visited[*it])
	dfs_visit(*it);

    f[s] = time++;  // finish time for s
  }
  void toposort() {

    tr(it,vertex) cout << "vertex " << *it << endl;

    dfs();

    priority_queue<pii> nodes;
    tr(it,vertex)
      nodes.push(make_pair(f[*it],*it));

    while(!nodes.empty()) {
      pii p = nodes.top();
      nodes.pop();
      cout << " finish_time=" << p.first << " vertex=" << p.second << endl;
    }
  }
private:
  set<int> vertex;
  map<int,list<int> > adj;
  map<int,int> d;
  map<int,int> f;
  map<int,int> visited;
  int time;
};


int main() {
  graph g;
  int u,v;
  while (cin >> u >> v) 
    g.add_edge(u,v);

  g.toposort();
  return 0;
}
