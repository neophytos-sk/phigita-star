// see dijkstra-example.cpp (this one is not finished yet)
#include <iostream>
#include <set>
#include <list>
#include <map>
#include <utility>
#include <vector>
#include <limits>

using namespace std;



typedef int vertex_t;
typedef double weight_t;

struct edge {
  vertex_t target;
  weight_t weight;
  edge(vertex_t inTarget, weight_t inWeight) 
    : target(inTarget), weight(inWeight) {}
};

typedef map<vertex_t, list<edge> > adjacency_map_t;

template <typename T1, typename T2>
struct pair_first_less {
  bool operator()(pair<T1,T2> p1, pair<T1,T2> p2) const
  {
    if (p1.first == p2.first) {
      // otherwise the initial vertex_queue will have the size 2 { 0,source ; inf;n }
      return p1.second < p2.second;
    }
    return p1.first < p2.first;
  }
};

typedef set<pair<weight_t,vertex_t>, pair_first_less<weight_t,vertex_t> > vertex_queue_t;

void Dijkstra(vertex_t source, adjacency_map_t& adjacency_map,
	      map<vertex_t,weight_t>& minDistance,
	      map<vertex_t,vertex_t>& previous)
{

  vertex_t u,v;
  adjacency_map_t::iterator itr;
  vertex_queue_t vertex_queue;

  for(itr = adjacency_map.begin(); itr != adjacency_map.end(); ++itr) {
    v = itr->first;
    minDistance[v] = numeric_limits<double>::infinity();
  }

  minDistance[source]=0;

  for(itr = adjacency_map.begin();
      itr != adjacency_map.end(); ++itr) {
    v = itr->first;
    vertex_queue.insert(pair<weight_t,vertex_t>(minDistance[v],v));
  }

  while(!vertex_queue.empty()) {

    // vertex_queue.begin() is the vertex_t with the minimum distance
    // initially, it is the source which is the only vertex with non-infinity
    // distance.

    u = vertex_queue.begin()->second;
    vertex_queue.erase(vertex_queue.begin());

    // visit each edge exiting u
    for(list<edge>::iterator edge_iter = adjacency_map[u].begin();
	edge_iter != adjacency_map[u].end();
	++edge_iter) {

      v = edge_iter->target;
      weight_t weight = edge_iter->weight;
      weight_t distance_through_u = minDistance[u] + weight;
      if (distance_through_u < minDistance[v]) {
	vertex_queue.erase(pair<weight_t,vertex_t>(minDistance[v],v));
	minDistance[v] = distance_through_u;
	previous[v] = u;
	vertex_queue.insert(pair<weight_t,vertex_t>(minDistance[v],v));
      }
    }
  }
}

int main()
{

  // --------------------------------------------------

    adjacency_map_t adjacency_map;
    std::vector<std::string> vertex_names;

    vertex_names.push_back("Harrisburg");   // 0
    vertex_names.push_back("Baltimore");    // 1
    vertex_names.push_back("Washington");   // 2
    vertex_names.push_back("Philadelphia"); // 3
    vertex_names.push_back("Binghamton");   // 4
    vertex_names.push_back("Allentown");    // 5
    vertex_names.push_back("New York");     // 6
    adjacency_map[0].push_back(edge(1,  79.83));
    adjacency_map[0].push_back(edge(5,  81.15));
    adjacency_map[1].push_back(edge(0,  79.75));
    adjacency_map[1].push_back(edge(2,  39.42));
    adjacency_map[1].push_back(edge(3, 103.00));
    adjacency_map[2].push_back(edge(1,  38.65));
    adjacency_map[3].push_back(edge(1, 102.53));
    adjacency_map[3].push_back(edge(5,  61.44));
    adjacency_map[3].push_back(edge(6,  96.79));
    adjacency_map[4].push_back(edge(5, 133.04));
    adjacency_map[5].push_back(edge(0,  81.77));
    adjacency_map[5].push_back(edge(3,  62.05));
    adjacency_map[5].push_back(edge(4, 134.47));
    adjacency_map[5].push_back(edge(6,  91.63));
    adjacency_map[6].push_back(edge(3,  97.24));
    adjacency_map[6].push_back(edge(5,  87.94));

    map<vertex_t,weight_t> minDistance;
    map<vertex_t,vertex_t> previous;
    Dijkstra(0,adjacency_map,minDistance,previous);

  return 0;
}
