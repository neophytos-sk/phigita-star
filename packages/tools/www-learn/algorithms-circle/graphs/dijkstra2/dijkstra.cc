#include <iostream>
#include <list>
#include <map>
#include <queue>  // priority_queue
#include <utility>  // pair

using namespace std;

typedef int vertex_t;
typedef int weight_t;
typedef pair<vertex_t,vertex_t> edge_t;
typedef list<vertex_t> adjacency_list_t;
typedef map<vertex_t, list<vertex_t> > adjacency_map_t;

// graph instance
enum nodes {A,B,C,D,E,F};
const char name[] = "ABCDEF";
edge_t edges[] = {edge_t(A,B),edge_t(A,C),edge_t(A,F),
		  edge_t(B,C),edge_t(B,D),
		  edge_t(C,D),edge_t(C,F),
		  edge_t(D,E),
		  edge_t(E,F)};

const int num_edges = sizeof(edges) / sizeof(edge_t);

weight_t weights[] = {7,9,14,
		 10,15,
		 11,2,
		 6,
		 9};


// typedef pair<weight_t,vertex_t> state_t;


struct state_t {
  int cost;
  vertex_t vertex;
  state_t(int in_cost, vertex_t in_vertex) : cost(in_cost), vertex(in_vertex) {}
};


/* map<vertex_t,weight_t>& min_distance, map<vertex_t,vertex_t>& previous*/ 
void dijkstra (vertex_t source,
	       const adjacency_map_t& adjacency_map) {

  vertex_t u,v;
  priority_queue<state_t> pq;
  pq.push(state_t(0,source));
  while(!pq.empty()) {
    // state_t current = pq.top();
    u = pq.top()->vertex;

    pq.pop();
    if (!visit[u]) {
      adjacency_list_t::const_iterator it = adjacency_map[u].begin();
      const adjacency_list_t::const_iterator end = adjacency_map[u].end();
      for(;it!=end;++it) {
	if (!visit[v])
	  // relax(u,v,w);
      }
    }
  }
}


void print_adj_list(const adjacency_list_t& adjacency_list) {
  list<vertex_t>::const_iterator it = adjacency_list.begin();
  const list<vertex_t>::const_iterator end = adjacency_list.end();
  for(;it!=end;++it) {
    cout << *it << ' ';
  }
}

void print_adj_map(const adjacency_map_t& adjacency_map) {
  adjacency_map_t::const_iterator it = adjacency_map.begin();
  const adjacency_map_t::const_iterator end = adjacency_map.end();
  for(;it!=end;++it) {
    cout << it->first << "=" ;
    print_adj_list(it->second);
    cout << endl;
  }
}

int main(int argc, char *argv[]) {

  // create adjacency map
  adjacency_map_t adjacency_map;
  for(int i=0;i<num_edges;i++) {
    vertex_t u = edges[i].first;
    vertex_t v = edges[i].second;
    adjacency_map[u].push_back(v);
    adjacency_map[v].push_back(u);
  }

  print_adj_map(adjacency_map);

  return 0;
}
