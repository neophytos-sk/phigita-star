#include <cstdio>
#include <limits>
#include <list>
#include <map>
#include <vector>


using std::list;
using std::map;
using std::numeric_limits;
using std::vector;


typedef int vertex_t;
typedef double weight_t;

struct edge_t {
  vertex_t source;
  vertex_t target;
  weight_t weight;
  edge_t(vertex_t in_source, vertex_t in_target, weight_t in_weight) 
    : source(in_source), target(in_target), weight(in_weight) {};
};

bool BellmanFord(const vertex_t& source,
		 const list<vertex_t>& nodes,
		 const list<edge_t>& edges,
		 map<vertex_t,weight_t>& min_distance,
		 map<vertex_t,vertex_t>& previous) 
{

  /* Initialize Single Source */
  list<vertex_t>::const_iterator vertex_iter;
  const list<vertex_t>::const_iterator vertex_stop = nodes.end();
  int count=0;
  for (vertex_iter = nodes.begin();
       vertex_iter != vertex_stop;
       ++vertex_iter) {

    count++;
    min_distance[*vertex_iter] = numeric_limits<double>::infinity();
  }
  min_distance[source] = 0;


  printf("checkpoint 1: ok\n");

  vertex_t u;
  vertex_t v;
  weight_t weight;
  weight_t distance_through_u;

  /* Relaxation */
  list<edge_t>::const_iterator edge_iter;
  const list<edge_t>::const_iterator edge_stop = edges.end();

  /*
  for (vertex_iter = nodes.begin();
       vertex_iter != vertex_stop;
       ++vertex_iter)
  */
  for (int i = 0; i<nodes.size()-1;++i) {

    printf("checkpoint 2: vertex=%d\n",*vertex_iter);

    for (edge_iter = edges.begin();
	 edge_iter != edge_stop;
	 ++edge_iter) {

      u = edge_iter->source;
      v = edge_iter->target;
      weight = edge_iter->weight;
      distance_through_u = min_distance[u] + weight;

      if (distance_through_u < min_distance[v]) {
	min_distance[v] = distance_through_u;
	previous[v] = u;
      }

      printf("checkpoint 3: edge(%d,%d) min_distance = %f\n",u,v,min_distance[v]);
      
    }
  }

  /* Detect negative-weight cycles */
  for (edge_iter = edges.begin();
       edge_iter != edge_stop;
       ++edge_iter) {

    u = edge_iter->source;
    v = edge_iter->target;
    weight = edge_iter->weight;
    distance_through_u = min_distance[u] + weight;
    if (min_distance[v] > distance_through_u) {
      printf("%d(%f) > through_%d(%f) w=%f return false\n", v,min_distance[v], u,distance_through_u, weight);
      return false;
    }
  }

  return true;
}


const list<vertex_t> GetShortestPathTo(
    const vertex_t& target, const map<vertex_t, vertex_t>& previous)
{
    list<vertex_t> path;
    map<vertex_t, vertex_t>::const_iterator prev;
    vertex_t vertex = target;
    path.push_front(vertex);
    while((prev = previous.find(vertex)) != previous.end())
    {
        vertex = prev->second;
        path.push_front(vertex);
    }
    return path;
}


int main() {
  list<vertex_t> nodes;
  nodes.push_back(0);
  nodes.push_back(1);
  nodes.push_back(2);
  nodes.push_back(3);
  nodes.push_back(4);
  nodes.push_back(5);

  list<edge_t> edges;
  edges.push_back(edge_t(0,1, 6));
  edges.push_back(edge_t(0,2, 7));
  edges.push_back(edge_t(1,2, 8));
  edges.push_back(edge_t(1,3, 5));
  edges.push_back(edge_t(1,4,-4));
  edges.push_back(edge_t(2,3,-3));
  edges.push_back(edge_t(2,4, 9));
  edges.push_back(edge_t(3,1,-2));
  edges.push_back(edge_t(4,0, 2));
  edges.push_back(edge_t(4,3, 7));

  map<vertex_t,weight_t> min_distance;
  map<vertex_t,vertex_t> previous;
  bool result;
  result = BellmanFord(0,nodes,edges,min_distance,previous);

  if (result) {  // success - computed single-source shortest path

    for (list<vertex_t>::const_iterator vertex_iter = nodes.begin();
	 vertex_iter != nodes.end();
	 ++vertex_iter) {

      vertex_t v = *vertex_iter;
      list<vertex_t> path = GetShortestPathTo(v, previous);
      list<vertex_t>::iterator path_iter = path.begin();
      printf("Path to %d: ",*vertex_iter);
      for( ; path_iter != path.end(); path_iter++) {
	printf(" %d ", *path_iter);
      }
      printf("\n");

    }

  } else {  // negative-weight cycle detected
  }
}
