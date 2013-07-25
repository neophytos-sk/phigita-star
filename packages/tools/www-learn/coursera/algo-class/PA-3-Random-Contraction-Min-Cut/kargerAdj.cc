#include <fstream>
#include <iostream>
#include <string>
#include <sstream>
#include <list>
#include <map>
#include <set>
#include <cstdlib>
#include <sys/time.h>
#include <utility>
#include <vector>

using namespace std;

#define tr(container, it) \
  for(typeof(container.begin()) it = container.begin(); it != container.end(); ++it) 

#define while_tr(container, it) \
  typeof(container.begin()) it = container.begin(); while(it != container.end()) 


#define pii pair<int,int>

class graph {
public:
  graph() : n_(0), m_(0) {};

  void add_node(int vertex) {
    n_++;
    vertices_[vertex] = vertex;
  }

  void add_edge(int from, int to) {
    edges_.push_back(make_pair(from,to));
    m_++;
  }


  void pretty_print() {
    tr(vertices_,it) {
      int v = it->second;
      cout << "Vertex " << v << ": ";
      cout << endl;
    }
    tr(edges_,it) {
      pii p = *it;
      cout << "Edge: " << p.first << "," << p.second;
      if (p.first == p.second) {
	cout << " >>> error: self-loop";
      }
      cout << endl;
    }
  }

  void remove_self_loops() {
    while_tr(edges_,it) {
      if (it->first == it->second) {
	it = edges_.erase(it);
	m_--;
      } else {
	++it;
      }
    }
  }

  void merge_vertices(int u, int v) {

    // merge vertices

    tr(edges_,it) {
      pii p = *it;

      if (p.first == u) {
	p.first = v;
      }
      if (p.second == u) {
	p.second = v;
      }

      *it = p;

    }


  }

  void remove_vertex(int u) {

    vertices_.erase(vertices_.find(u));
    n_--;

  }

  void remove_edge(int e) {
    edges_.erase(edges_.begin() + e);
    m_--;
  }

  void merge_edge(int e) {

    cout << "e=" << e << " m=" << m_ << " ";

    pii p = edges_[e];
    int u = p.first;
    int v = p.second;

    cout << "merge edge: (" << u << "," << v << ")" << endl;

    remove_edge(e);
    merge_vertices(u,v);
    remove_self_loops();
    remove_vertex(u);

  }

  int random_edge() {
    cout << "m_=" << m_ << endl;
    return rand() % m_;
  }

  int random_vertex() {
    return rand() % n_;
  }

  void find_min_cut() {
    while(n_ > 2) {
      int e = random_edge();
      merge_edge(e);
      // pretty_print();
    }
    cout << "m_/2 = " << m_/2 << endl;
  }

private:
  int n_;
  int m_;
  map<int,int> vertices_;
  vector<pair<int,int> > edges_;
};


int main(int argc, char *argv[]) {
  if (argc != 2) {
    cout << "Usage: " << argv[0] << " filename" << endl;
    return 1;
  }


  // never use time() to initialize srand()
  // use microsecond precision instead
  struct timeval tv; // C requires "struct timval" instead of just "timeval"
  gettimeofday(&tv, 0);

  // use BOTH microsecond precision AND pid as seed
  long int n = tv.tv_usec * getpid(); 
  srand(n);


  ios::sync_with_stdio(false);

  ifstream infile;
  infile.open(argv[1]);
  string line;
  int vertex;
  int adj;
  graph g;
  while(getline(infile,line,'\n')) {
    stringstream ss;
    ss << line;
    ss >> vertex;
    g.add_node(vertex);
    while (ss >> adj) 
      g.add_edge(vertex,adj);

  }
  g.pretty_print();
  g.find_min_cut();
  g.pretty_print();

  return 0;
}
