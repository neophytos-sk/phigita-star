#include <vector>
#include <set>
#include <string>
#include <algorithm>
#include <deque>

using std::vector;
using std::deque;
using std::set;
using std::string;
using std::find_if;

#define all(c) (c).begin(),(c).end()

struct nodeT;  // forward declaration

struct arcT {
  // arc fields (distance, cost, etc)
  nodeT *start_, *end_;
  arcT(nodeT *start, nodeT *end);
};

struct nodeT {
  // node fields (name, etc)
  string name_;
  vector<arcT *> outgoing_;
  nodeT(string name) : name_(name) {}
};


arcT::arcT(nodeT *start, nodeT *end) : start_(start), end_(end) {
  start->outgoing_.push_back(this);
}


void DFS(nodeT *cur, set<nodeT *>& visited) {
  //printf("%p\n",cur);

  if (visited.count(cur)) return;

  // do something with cur
  printf("%s outgoing: %zd\n",cur->name_.c_str(),cur->outgoing_.size());
  // done

  visited.insert(cur);
  for (int i=0; i<cur->outgoing_.size(); ++i)
    DFS(cur->outgoing_[i]->end_, visited);
}

void BFS(nodeT *start_node, set<nodeT *>&visited) {

  deque<nodeT *> queue;
  queue.push_back(start_node);
  while (!queue.empty()) {
    nodeT *cur = queue.front();
    queue.pop_front();

    // do something with cur
    printf("%s outgoing: %zd\n",cur->name_.c_str(),cur->outgoing_.size());
    // done

    // expand frontier with adjacent nodes (neighbours) of the cur node
    for (int i=0; i<cur->outgoing_.size(); ++i)
      if (!visited.count(cur->outgoing_[i]->end_))
	queue.push_back(cur->outgoing_[i]->end_);
  }
}

int main(int argc, char *argv[]) {
  vector<nodeT *> nodes;
  nodes.push_back(new nodeT("A"));
  nodes.push_back(new nodeT("B"));
  nodes.push_back(new nodeT("C"));
  nodes.push_back(new nodeT("D"));
  nodes.push_back(new nodeT("E"));
  nodes.push_back(new nodeT("F"));
  nodes.push_back(new nodeT("G"));
  nodes.push_back(new nodeT("H"));


  //arcs.push_back(new arcT(find_if(all(nodes),HasName<nodeT>("A")),
  //			  find_if(all(nodes),HasName<nodeT>("B"))));

  vector<arcT *> arcs;
  arcs.push_back(new arcT(nodes[0],nodes[1]));  // A -> B
  arcs.push_back(new arcT(nodes[0],nodes[3]));  // A -> D
  arcs.push_back(new arcT(nodes[0],nodes[7]));  // A -> H
  arcs.push_back(new arcT(nodes[1],nodes[2]));  // B -> C
  arcs.push_back(new arcT(nodes[3],nodes[4]));  // D -> E
  arcs.push_back(new arcT(nodes[4],nodes[5]));  // E -> F
  arcs.push_back(new arcT(nodes[7],nodes[6]));  // H -> G

  set<nodeT *> visited;
  DFS(nodes[0],visited);
  printf("=============\n");
  visited.clear();
  BFS(nodes[0],visited);
  return 0;
}
