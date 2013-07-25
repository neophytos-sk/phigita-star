#include "mytreemap.h"

template <typename ValType>
MyTreeMap<ValType>::MyTreeMap() {
  root = NULL;
}

template <typename ValType>
MyTreeMap<ValType>::~MyTreeMap() {
  // delete tree
}

template <typename ValType>
void MyTreeMap<ValType>::add(string key, ValType val) {

  tree_enter(root, key, val);

}


template <typename ValType>
ValType MyTreeMap<ValType>::getValue(string key) {  // getValue is wrapper
  nodeT *found = tree_search(root,key);
  if (found)
    return found->val;

  fprintf(stderr,"No such key in the map\n");
  // throw exception
  return -1;
}


template <typename ValType>
typename MyTreeMap<ValType>::nodeT *MyTreeMap<ValType>::tree_search(nodeT *node, string key) {

  if (!node) return NULL;

  if (node->key == key)                  // found match
    return node;
  else if (key < node->key) 
    return tree_search(node->left,key);  // search left
  else
    return tree_search(node->right,key); // search right

}


template <typename ValType>
void MyTreeMap<ValType>::tree_enter(nodeT *& node, string key, ValType val) {
  if (!node) {
    node = new nodeT;
    node->key = key;
    node->val = val;
    node->left = NULL;
    node->right = NULL;
  }

  if (key == node->key)
    node->val = val;
  else if (key < node->key)
    tree_enter(node->left,key,val);
  else
    tree_enter(node->right,key,val);
}
