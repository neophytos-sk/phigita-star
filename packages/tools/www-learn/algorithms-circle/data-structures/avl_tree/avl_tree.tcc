#include "avl_tree.h"

#ifdef DEBUG
#include <cstdio> // remove me
#endif 

template <typename T>
avl_node<T>::avl_node(const T& data)
  : /* bst_node<T>(data), */ data_(data),  height_(0), left_(NULL), right_(NULL) {}

template <typename T>
avl_node<T>* avl_tree<T>::make_node(const T& data) const {
  printf("make avl node\n");
  return new avl_node<T>(data);
}

/*
template <typename T>
void avl_tree<T>::insert_helper(avl_node<T>*& node, const T& data) {

  bst_tree<T>::insert_helper(node,data);
  //avl_node<T>*the_node= static_cast<avl_node<T>*>(node);
  //rebalance(the_node);
  //rebalance(static_cast<avl_node<T>*>(node));
  //printf("height:%d\n",static_cast<avl_node<T>*>(node)->height_);
  //bst_node<T> &derived_node = *node;
  //rebalance(derived_node);
  rebalance(node);
}
*/


template <typename T>
void avl_tree<T>::insert(const T& data) {
  insert_helper(root_,data);
  //    printf("root_->data_=%d\n",root_->data_);
}


template <typename T>
void avl_tree<T>::insert_helper(avl_node<T>*& node, const T& data) {

  printf("insert_helper node=%p data=%d\n",node,data );

  if (!node)
    node = make_node(data);
  
  if (data < node->data_)
    insert_helper(node->left_,data);
  else if (data > node->data_)
    insert_helper(node->right_,data);
  else
    return;

  rebalance(node);


}


template <typename T>
void avl_tree<T>::erase(avl_node<T>** node) {
}

template <typename T>
void avl_tree<T>::adjust_height(avl_node<T> *&node) {
  if (!node)
    return;

  int left_height, right_height;
  left_height = node->left_ == NULL ? -1 : node->left_->height_;
  right_height = node->right_ == NULL ? -1 : node->right_->height_;
  node->height_ = 1 + max(left_height,right_height);

  printf("node=%d height: %d\n", node->data_,node->height_);
}

template <typename T>
void avl_tree<T>::rebalance(avl_node<T> *&node) {
  int left_height  = node->left_ == NULL ? -1 : node->left_->height_;
  int right_height = node->right_ == NULL ? -1 : node->right_->height_;
  int diff = left_height - right_height;  // balancing factor

  //printf("node=%d diff=%d\n",node->data_,diff);

  if (abs(diff) > 1) {

    #ifdef DEBUG
    if (node)
      printf("AVL condition violated (diff=%d node=%p)\n", diff,node);
    #endif

    if ( left_height > right_height ) {

      int left_left_height = node->left_->left_ == NULL ? -1 : node->left_->left_->height_;
      int left_right_height = node->left_->right_ == NULL ? -1 : node->left_->right_->height_;

      if ( left_left_height < left_right_height ) rotate_left(node->left_);
      rotate_right(node);

    } else {

      int right_left_height = node->right_->left_ == NULL ? -1 : node->right_->left_->height_;
      int right_right_height = node->right_->right_ == NULL ? -1 : node->right_->right_->height_;

      if ( right_left_height > right_right_height ) rotate_right(node->right_);
      rotate_left(node);

    }

  }

  adjust_height(node);
}


template <typename T>
void avl_tree<T>::rotate_left(avl_node<T> *&node) {

  avl_node<T> *Rt = node->right_, *RtLt = Rt->left_;

  Rt->left_ = node;
  node->right_ = RtLt;
  adjust_height(node);
  adjust_height(Rt);
  node = Rt;

#ifdef DEBUG
  printf("<<< done:rotate_left <<< ");
  //printf("left(%d) < parent(%d) < right(%d)\n", node->left_->data_, node->data_, node->right_->data_);
#endif

}


template <typename T>
void avl_tree<T>::rotate_right(avl_node<T> *&node) {

  avl_node<T> *Lt = node->left_, *LtRt = Lt->right_;

  Lt->right_ = node;
  node->left_ = LtRt;
  adjust_height(Lt);
  adjust_height(node);
  node = Lt;

#ifdef DEBUG
  printf(">>> done:rotate_right >>> ");
  //printf("left(%d) < parent(%d) < right(%d)\n", node->left_->data_, node->data_, node->right_->data_);
#endif

}

/* rebalance:
while node is not None:
            update_height(node)
            if height(node.left) >= 2 + height(node.right):
                if height(node.left.left) >= height(node.left.right):
                    self.right_rotate(node)
                else:
                    self.left_rotate(node.left)
                    self.right_rotate(node)
            elif height(node.right) >= 2 + height(node.left):
                if height(node.right.right) >= height(node.right.left):
                    self.left_rotate(node)
                else:
                    self.right_rotate(node.right)
                    self.left_rotate(node)
            node = node.parent
*/
