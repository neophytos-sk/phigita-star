#include "MyMap.h"

template <typename ValType>
MyMap<ValType>::MyMap() {
  for (int i = 0; i < kNumBuckets; ++i)
    buckets[i] = NULL;
}

template <typename ValType>
MyMap<ValType>::~MyMap() {
  /*
  for (int i = 0; i < kNumBuckets; ++i)
    for (cellT *cell = buckets[i]; cell != NULL; cell=cell->next)
      delete cell;
  */
}

template <typename ValType>
void MyMap<ValType>::add(string key, ValType val) {
  int hashcode = hash(key);
  cellT *match = findCell(key,buckets[hashcode]);
  if (match)
    match->val = val;
  else {
    cellT *cell = new cellT;
    cell->key = key;
    cell->val = val;
    cell->next = buckets[hashcode];
    buckets[hashcode] = cell;
  }
}

template <typename ValType>
ValType MyMap<ValType>::getValue(string key) {
  int hashcode = hash(key);
  cellT *match = findCell(key, buckets[hashcode]);
  if (match)
    return match->val;

  fprintf(stderr,"No such key found\n");
  return 0;
}


template <typename ValType>
typename MyMap<ValType>::cellT *MyMap<ValType>::findCell(string key, cellT *list) {

  for (cellT *cur = list; cur != NULL; cur=cur->next)
    if (cur->key == key)
      return cur;

  return NULL;
}

const int multiplier = 127;

template <typename ValType>
int MyMap<ValType>::hash(string key) {
  int hashcode = 0;
  for (int i=0; i<key.size(); ++i)
    hashcode = (multiplier*hashcode + key[i]) % kNumBuckets;
}
