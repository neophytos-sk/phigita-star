#ifndef SET_UTILS_H
#define SET_UTILS_H

#include <iostream>
#include <set>

using std::set;
using std::cout;
using std::endl;

namespace {

  template <typename T>
    void PrintSet(const set<T>& s) {

    typename set<T>::const_iterator itr;
    for (itr = s.begin(); itr != s.end(); ++itr) {
      cout << *itr << endl;
    }
  }
  
  template <typename T> 
    void set_union(const set<T>& s1, 
		   const set<T>& s2,
		   set<T>& result) {

    result = s1;
    typename set<T>::const_iterator itr;
    for (itr = s2.begin(); itr != s2.end(); ++itr)
      result.insert(*itr);
    
  }

  template <typename T>
    void set_intersection(const set<T>& s1,
			  const set<T>& s2,
			  set<T>& result) {

    typename set<T>::const_iterator itr;
    for (itr = s2.begin(); itr != s2.end(); ++itr)
      if (s1.count(*itr))
	result.insert(*itr);
  }

} // unnamed namespace

#endif
