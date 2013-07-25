#ifndef COMMON_H
#define COMMON_H

#include <list>
#include <tr1/unordered_map>  // For unordered_map
#include <tr1/unordered_set>  // For unordered_set

typedef std::tr1::unordered_map<std::string,double> freq_map_t;
typedef std::list<std::string> word_list_t;
typedef std::tr1::unordered_set<std::string> word_hash_set_t;  // for stopwords

#endif
