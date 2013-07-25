#include <cstdio>
#include <cstring>
#include <set>

using std::set;


struct CStringCompare {
  bool operator() (const char* str1, const char* str2) const {
    return strcmp(str1,str2) < 0;  // use strcmp to do the comparison
  }
};


int main(int argc, char *argv[]) {

  if (argc == 1) {
    printf("Usage: %s <word1> <word2> ... <wordN>\n",argv[0]);
    return 1;
  }

  set<const char*, CStringCompare> mySet;  
  for (int i; i<argc; ++i)
    mySet.insert(argv[i]);

  for (typeof(mySet.begin()) itr = mySet.begin();
       itr != mySet.end();
       ++itr) {
    printf("%s\n",*itr);
  }

  return 0;
}
