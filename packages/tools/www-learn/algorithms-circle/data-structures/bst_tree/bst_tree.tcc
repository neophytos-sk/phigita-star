#include "bst_tree.h"

template <typename T>
bst_tree<T>::bst_tree() : root_(NULL) {}

template <typename T>
bst_node<T>* bst_tree<T>::find(const T& data) const {
  bst_node<T>* node = find_helper(data);
  return node;
}

template <typename T>
bst_node<T> *bst_tree<T>::find_helper(const T& data) const {
  bst_node<T> *node = root_;

  while (node != NULL) {
    if (data < node->data_)
      node = node->left_;
    else if (data > node->data_)
      node = node->right_;
    else
      break;
  }
  return node;	
}


template <typename T>
void bst_tree<T>::insert(const T& data) {
  insert_helper(root_,data);
}

template <typename T>
bst_node<T>* bst_tree<T>::make_node(const T& data) const {
  return new bst_node<T>(data);
}

template <typename T>
void bst_tree<T>::insert_helper(bst_node<T>*& node, const T& data) {

  if (!node) {
    node = make_node(data);
  }
  
  if (data < node->data_)
    insert_helper(node->left_,data);
  else if (data > node->data_)
    insert_helper(node->right_,data);
  else
    return;
}


template <typename T>
void bst_tree<T>::erase(bst_node<T> *&node) {
}
