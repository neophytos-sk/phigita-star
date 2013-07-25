#include <iostream>

using namespace std;

struct node {
  int data;
  struct node *left;
  struct node *right;
};

bool print_ancestors(int target, const node * root) {
  if (!root) return false;
  if (root->data==target) return true;
  if (print_ancestors(target, root->left) || print_ancestors(target, root->right)) {
    cout << root->data << " ";
  }
}

node *newnode(int data) {
  node *newnode = new node;
  newnode->data = data;
  return newnode;
}

int main(){
  node *root             = newnode(1);
  root->left             = newnode(2);
  root->left->left       = newnode(4);
  root->left->right      = newnode(5);
  root->left->left->left = newnode(7);
  print_ancestors(7,root);
  return 0;
}
