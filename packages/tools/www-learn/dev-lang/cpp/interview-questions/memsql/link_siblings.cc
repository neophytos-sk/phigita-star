/*

         1
    2    ->    3
 4 -> 5 ->   6 -> 7
     8     ->      10     

*/

#include <iostream>
#include <queue>

struct node {
  node* left, *right;
  node* sibling;
  node() : left(NULL),right(NULL),sibling(NULL) {};
  int value;
};

using namespace std;

void link_siblings(node* root)
{

    if (!root) return;
    
    node *current = NULL;
    node *prev = NULL; // left sibling of a dequeued node
    queue<node*> q;
    q.push(root);
    q.push(NULL);  // queue the marker
    while(!q.empty()) {
      current = q.front();
      q.pop();

      if (!current) {  // end of a level - marker is null
	if (q.empty()) {
	  break;
	}
	q.push(NULL);
	prev = NULL;
	continue;
      }
        
      if (prev) {
	prev->sibling = current;
      }

      prev = current;
      
      if (current->left)
	q.push(current->left);
      
      if (current->right)
	q.push(current->right);

    }
    
}

void print_tree(node* root) {
  
  queue<node*> q;
  q.push(root);
  while (!q.empty()) {
    node *current = q.front();
    q.pop();
    cout << current->value << ": " << (current->sibling?current->sibling->value:0)  << endl;
    if (current->left)
      q.push(current->left);
    if (current->right)
      q.push(current->right);
  }
}


int main() {

  node *t = new node;
  t->left = new node;
  t->right = new node;

  t->value = 1;
  t->left->value = 2;
  t->left->left = new node;
  t->left->right = new node;

  t->left->left->value = 4;
  t->left->right->value = 5;
  t->left->right->left = new node;
  t->left->right->left->value = 8;

  t->right->value = 3;
  t->right->left = new node;
  t->right->left->value = 6;

  t->right->right = new node;
  t->right->right->value = 7;

  t->right->right->right = new node;
  t->right->right->right->value = 10;

  link_siblings(t);

  print_tree(t);
}
