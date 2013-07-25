#include <iostream>
#include <queue>

using namespace std;

template <class T>
struct node {
  typedef node<T> node_t;
  node(T v) : value(v), left(0), right(0) {}
  T value;
  node_t *left;
  node_t *right;

};

template <class T>
class tree {
public:
  typedef node<T> node_t;

  tree() : root(NULL) {}
  void add_node(T v) {

    node_t *thenode = new node_t(v);

    if (!root) {
      root=thenode;
      return;
    }

    node_t *curr = root;
    while(curr)
      if (v<=curr->value)
	if (curr->left)
	  curr=curr->left;
	else {
	  curr->left=thenode;
	  break;
	}
      else
	if (curr->right)
	  curr=curr->right;
	else {
	  curr->right=thenode;
	  break;
	}


  }
  void print() {
    if (!root) return;

    queue<node_t* > q;
    q.push(root);
    q.push(NULL);
    while(!q.empty()) {
      node_t *curr = q.front();
      q.pop();

      if (!curr) {
	cout << endl;
	if (q.empty()) {
	  break;
	} else {
	  q.push(NULL);
	  continue;
	}
      }
      cout << curr->value << " ";
      if (curr->left) q.push(curr->left);
      if (curr->right) q.push(curr->right);
    }
  }
private:
  node_t *root;
};


int main() {
  tree<int> t;
  int x;
  while(cin >> x)
    t.add_node(x);

  cout << "-------------" << endl;
  t.print();

  return 0;
}
