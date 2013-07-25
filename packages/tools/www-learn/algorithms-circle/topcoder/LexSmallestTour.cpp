#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <deque>
#include <queue>
#include <set>
#include <map>
#include <algorithm>
#include <functional>
#include <utility>
#include <cmath>
#include <cstdlib>
#include <ctime>

using namespace std;

#define REP(i,n) for((i)=0;(i)<(int)(n);(i)++)

int N,M;
int graph[50][50];
int deg[50],deg2[50][60];
bool used[50][50],used2[50];
int ans[1000];

class LexSmallestTour{
  public:
  
  void dfs(int x){
    int i;
    
    if(used2[x]) return;
    used2[x] = true;
    
    REP(i,N) if(graph[x][i] != -1){
      used[x][i] = true;
      dfs(i);
    }
  }
  
  bool check(int x, int e){
    int i,j;
    
    REP(i,N) deg[i] = 0;
    REP(i,N) REP(j,N) if(graph[i][j] != -1) deg[i]++;
    REP(i,N) REP(j,52) deg2[i][j] = 0;
    REP(i,N) REP(j,N) if(graph[i][j] != -1) deg2[i][graph[i][j]]++;
    
    if(e == -1) REP(i,N) if(deg[i] % 2 == 1) return false;
    
    deg[x]++;
    if(e != -1) deg2[x][e]++;
    REP(i,N) REP(j,52) if(deg2[i][j] * 2 >= deg[i] + 2) return false;
    
    REP(i,N) REP(j,N) used[i][j] = false;
    REP(i,N) used2[i] = false;
    dfs(x);
    REP(i,N) REP(j,N) if(!used[i][j] && graph[i][j] != -1) return false;
    
    return true;
  }
  
  void calc(void){
    int iter,y;
    
    int x = 0, e = -1;
    ans[0] = 0;
    
    REP(iter,M){
      REP(y,N) if(graph[x][y] != -1 && graph[x][y] != e){
        int e2 = graph[x][y];
        graph[x][y] = graph[y][x] = -1;
        if(check(y,e2)){
          ans[iter+1] = y; x = y; e = e2;
          break;
        } else {
          graph[x][y] = graph[y][x] = e2;
        }
      }
    }
  }

  vector <int> determineTour(vector <string> roads, vector <int> queries){
    int i,j;
    
    N = roads.size();
    REP(i,N) REP(j,N){
      graph[i][j] = -1;
      char ch = roads[i][j];
      if(ch >= 'A' && ch <= 'Z') graph[i][j] = ch - 'A';
      if(ch >= 'a' && ch <= 'z') graph[i][j] = ch - 'a' + 26;
      if(i < j && graph[i][j] != -1) M++;
    }
    
    vector <int> empty;
    if(!check(0,-1)) return empty;
    
    calc();
    
    vector <int> v;
    REP(i,queries.size()) v.push_back(ans[queries[i]]);
    return v;
  }

};


