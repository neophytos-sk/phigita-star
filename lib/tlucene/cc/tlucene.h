#ifndef TLUCENE_H
#define TLUCENE_H

#include <map>
#include <list>
#include <string>


#define MAX_QUERY_BYTELEN 4096
#define MAX_TOKEN_LEN 1024

void tlucene_ParseQuery(const char *utf8_query_string, char * result);
void tlucene_Tokenize(const char *utf8_query_string, std::map<std::string,std::list<int> >& result);

#endif
