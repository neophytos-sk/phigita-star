// Program to print BFS traversal from a given source vertex. BFS(int s)
// traverses vertices reachable from s.
#include<iostream>
#include <list>
#include <fstream>
#include <map>
#include <algorithm>
#include <vector>
#include <iterator>

using namespace std;
 
// This class represents a directed graph using adjacency list representation
class Graph
{
  int V;    // No. of vertices
  list<int> *adj;    // Pointer to an array containing adjacency lists
  list<int> *reversed_adj;    // Pointer to an array containing adjacency lists
  bool *visited;
  int *leader;
  int *finish_time;
  //  int *finish_time_index;

  int t;

  int start;

public:
  Graph(int V);  // Constructor
  void addEdge(int v, int w); // function to add an edge to graph
  void DFS_Loop();
  void DFS(int s);  // prints BFS traversal from a given source s
  void show();
  void SCC();
  void reverseGraph(Graph& g);
};
 
Graph::Graph(int V) {
  this->V = V;

  V++;

  adj = new list<int>[V];
  reversed_adj = new list<int>[V];
  visited = new bool[V];
  leader = new int[V];
  finish_time = new int[V];

  t=0;
}
 
void Graph::addEdge(int v, int w) {
  adj[v].push_back(w); // Add w to v’s list.
}


void Graph::DFS_Loop() {

  // Mark all the vertices as not visited
  for(int i = 1; i <= V; i++) {
    visited[i] = false;
    leader[i] = 0;
  }

  // To keep track of ordering
  // current_label = V;

  for(int i = V; i >=1; i--) {
    if (!visited[i]) {
      start = i;
      DFS(i);
      //cout << "leader=" << leader[i] << endl;;
    }
  }

}

void Graph::DFS(int s) {
 
  // Create a stack for DFS
  list<int> stack;
 
  // Mark the current node as visited and push it on the stack
  visited[s] = true;
  leader[s] = start;

  // cout << "s=" << s << " start=" << leader[s] << endl;
 
  // 'i' will be used to get all adjacent vertices of a vertex
  list<int>::iterator i;
 
  // cout << "s=" << s << endl;
      
  // Get all adjacent vertices of the dequeued vertex s
  // If a adjacent has not been visited, then mark it visited
  // and enqueue it
  for(i = adj[s].begin(); i != adj[s].end(); ++i)
    if(!visited[*i])
      DFS(*i);


  t++;
  finish_time[s] = t;
  //cout << "finish_time of " << s << " = " << t << endl;

}

void Graph::show() {

  for(int u=1;u<=V;u++) {
    cout << u << ":";
    for(typeof(adj[u].begin()) i=adj[u].begin(); i!=adj[u].end(); ++i) {
      cout << " " << *i;
    }
    cout << endl;
  }

}

void Graph::SCC() {

  cout << "compute strongest connected components from leaders" << endl;
  int scc[V+1];
  for (int i=1; i<=V; i++) 
    scc[i]=0;

  for (int i=1; i<=V; i++) {
    // cout << "leader= " << leader[i] << endl;
    scc[leader[i]]++;
  }

  vector<int> scc_sizes;
  for(int i=1;i<=V;i++)
      scc_sizes.push_back(scc[i]);

  sort(scc_sizes.begin(),scc_sizes.end());
  std::reverse(scc_sizes.begin(),scc_sizes.end());

  //copy(scc_sizes.begin(),scc_sizes.end(),ostream_iterator<int>(cout,"\n"));
  cout << scc_sizes[0] << endl;
  cout << scc_sizes[1] << endl;
  cout << scc_sizes[2] << endl;
  cout << scc_sizes[3] << endl;
  cout << scc_sizes[4] << endl;
  cout << scc_sizes[5] << endl;

}

void Graph::reverseGraph(Graph& g) {

  // cout << "t=" << t << endl;

  for(int u = 1; u <= V; u++) {
    for(typeof(adj[u].begin()) i=adj[u].begin(); i != adj[u].end(); ++i) {
      // reverse arc and replace node name with finishing time
      int reversed_from = finish_time[*i];
      int reversed_to = finish_time[u];
      // cout << "reversed_edge " << reversed_from << " " << reversed_to << endl;
      g.addEdge(reversed_from, reversed_to);
      // cout << "new adj " << adj[reversed_from].back() << endl;
    }
  }
}

// Driver program to test methods of graph class
int main(int argc, char *argv[]) {

  if (argc != 3) {
    cout << "Usage: " << argv[0] << " largest_vertex filename" << endl;
    return 1;
  }

  int largest_vertex = atoi(argv[1]);

    // Create a graph given in the above diagram
  Graph g(largest_vertex); // base 1 indexes

    int from,to;
    ifstream infile;
    infile.open(argv[2]);
    while (!infile.eof()) {
      infile >> from >> to;
      // if (from == 0) break;
      g.addEdge(from, to);
    }

    // g.show();
 
    g.DFS_Loop();

    Graph g2(largest_vertex);
    g.reverseGraph(g2);
    cout << "graph g2" << endl;

    // g2.show();

    g2.DFS_Loop();
    g2.SCC();
 
    return 0;
}
