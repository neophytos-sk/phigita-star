#include <cstdio>
#include <map>


using std::map;

void ComposeMaps(const map<int,int>& f, 
		 const map<int,int>& g, 
		 map<int,int>& result) {
  for (map<int,int>::const_iterator itr = f.begin();
       itr != f.end();
       ++itr) {
    if (g.find(itr->second) != g.end()) {
      result[itr->first] = g.at(itr->second);
    }
  }
}


void PrintMap(const map<int,int>& m) {
  for (map<int,int>::const_iterator itr = m.begin();
       itr != m.end();
       ++itr)
    printf("%d,%d\n",itr->first,itr->second);
}


int main() {
  map<int,int> f;
  map<int,int> g;
  map<int,int> composition;

  f[1] = 2;
  f[2] = 3;
  f[7] = 4;
  f[5] = 5;
  f[6] = 12;

  g[1] = 2;
  g[2] = 4;
  g[3] = 8;
  g[4] = 16;
  g[5] = 32;

  ComposeMaps(f,g,composition);
  PrintMap(composition);

  return 0;
}
