#ifndef BST_H
#define BST_H

#ifdef DEBUG
#include <cstdio>
#endif

#ifndef NULL
#ifdef __cplusplus
#define NULL 0
#else
#define NULL ((void *)0)
#endif
#endif

template <typename T> class bst_tree; // forward declaration

template <typename T>
class bst_node {
  friend class bst_tree<T>;
public:
  explicit bst_node(const T& data) : data_(data), left_(NULL), right_(NULL) {}
  T get_data() const { return data_; }
  void print() const { 
    printf("%d ( ",data_); 
    if (left_) left_->print(); else printf(" nil "); 
    if (right_) right_->print(); else printf(" nil ");
    printf(" ) "); 
  }
protected:
#ifdef DEBUG
  virtual void what_am_i() { printf("bst_node\n"); }
#endif
  bst_node<T> *get_left() { return left_; }
  bst_node<T> *get_right() { return left_; }
  //private:
  T data_;
  bst_node<T> *left_, *right_;
};

template <typename T>
class bst_tree {
 public:
  bst_tree<T>();

  bst_node<T>* find(const T& data) const;
  virtual void insert(const T& data);
  virtual void erase(bst_node<T>*& node);
protected:
  virtual bst_node<T>* make_node(const T& data) const;
  virtual void insert_helper(bst_node<T>*& node, const T& data);
  bst_node<T>* root_;
private:
  bst_node<T>* find_helper(const T& data) const;
};

#include "bst_tree.tcc"

#endif
