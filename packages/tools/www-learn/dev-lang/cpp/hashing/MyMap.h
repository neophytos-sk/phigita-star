#ifndef MYMAP_H
#define MYMAP_H

#include <string>

using std::string;


#define DISALLOW_COPY_AND_ASSIGN(T) \
  T(const T& other); \
  void operator=(const T& other);

template <typename ValType>
class MyMap {
 public:
  MyMap();
  ~MyMap();

  void add(string key, ValType value);
  ValType getValue(string key);

 private:
  static const int kNumBuckets = 99;
  struct cellT {
    string key;
    ValType val;
    cellT *next;
  };

  cellT *buckets[kNumBuckets];

  int hash(string key);
  cellT *findCell(string key, cellT *list);

  DISALLOW_COPY_AND_ASSIGN(MyMap);
};

  // #include .tcc because of template (quirky)
  #include "MyMap.tcc"

#endif
