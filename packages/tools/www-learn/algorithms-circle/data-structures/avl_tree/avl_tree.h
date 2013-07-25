#ifndef AVL_TREE_H
#define AVL_TREE_H

#include "bst_tree.h"

#ifndef NULL
#ifdef __cplusplus
#define NULL 0
#else
#define NULL ((void *)0)
#endif
#endif

inline int abs(int x) {
  return x>0?x:-x;
}

inline int max(int x, int y) {
  return x>y?x:y;
}

template <typename T> class avl_tree;  // forward declaration

template <typename T>
class avl_node /* : public bst_node<T> */ {
  friend class avl_tree<T>;
 public:
  explicit avl_node(const T& data);
  virtual T get_data() { return data_; }

protected:
  int get_height() { return height_; }

#ifdef DEBUG
  void what_am_i() { printf("avl_node\n"); }
#endif

 private:
  T data_;
  int height_;
  avl_node<T> *left_;
  avl_node<T> *right_;

};

template <typename T>
class avl_tree /* : public bst_tree<T> */  {
public:
  avl_tree() : root_(NULL) {}
  virtual void insert(const T& data);
  virtual void erase(avl_node<T> **node);
  avl_node<T>* find(const T& data) {
    avl_node<T> *node = root_;
    while (node) {
      if (data < node->data_)
	node = node->left_;
      else if (data > node->data_)
	node = node->right_;
      else
	break;
    }
    return node;
  }
protected:
  virtual avl_node<T>* make_node(const T& data) const;
  virtual void insert_helper(avl_node<T> *&node, const T& data);
private:

  void adjust_height(avl_node<T> *&node);
  void rebalance(avl_node<T> *&node);
  void rotate_left(avl_node<T> *&node);
  void rotate_right(avl_node<T> *&node);

  avl_node<T>* root_;
};

#include "avl_tree.tcc"

#endif
