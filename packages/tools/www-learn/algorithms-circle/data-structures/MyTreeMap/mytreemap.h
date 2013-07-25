#ifndef MYTREEMAP_H
#define MYTREEMAP_H

#include <string>

using std::string;

#define DISALLOW_COPY_AND_ASSIGN(T) \
  T(const T& other); \
  void operator=(const T&other);


template <typename ValType>
class MyTreeMap {
 public:
  MyTreeMap();
  ~MyTreeMap();
  void add(string key, ValType val);
  ValType getValue(string key);
 private:
  struct nodeT {
    string key;
    ValType val;
    nodeT *left, *right;
  };
  nodeT *root;

  nodeT *tree_search(nodeT *t, string key);
  void tree_enter(nodeT *&t, string key, ValType val);

  DISALLOW_COPY_AND_ASSIGN(MyTreeMap);
};

// #include .tcc because of template (quirky)
#include "mytreemap.tcc"

#endif
