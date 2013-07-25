#include <iostream>
#include <string>
#include <cstring>  // for memset

#define FOR(i,a,b) for(typeof(a) i=a;i<=b;++i)

enum case_type {NONE,UP_LEFT, UP, LEFT};

using namespace std;

int lcs_len(string& a, string& b) {

  // opt[n][m] - length of lcs between a[1:n] and b[1:m]

  int n = a.size();
  int m = b.size();

  a.insert(0," ");
  b.insert(0," ");

  int opt[n+1][m+1];
  case_type back[n+1][m+1];
  memset(opt,0,sizeof(opt));
  memset(back,NONE,sizeof(back));


  FOR(i,1,n) {
    FOR(j,1,m) {
      if (a[i]==b[j]) {
	opt[i][j]=opt[i-1][j-1]+1;
	back[i][j] = UP_LEFT;
      } else {
	opt[i][j]=max(opt[i-1][j],opt[i][j-1]);
	back[i][j] = (opt[i][j]==opt[i-1][j]?UP:LEFT);
      }
    }
  }

  FOR(i,0,n) {
    FOR(j,0,m) {
      cout << opt[i][j] << (j==m?"\n":" ");
    }
  }

  string s;
  int i=n,j=m;
  while(i && j) {
    if (back[i][j] == UP_LEFT)
      s = a[i] + s, i--,j--;
    else if (back[i][j] == UP)
      i--;
    else
      j--;
  }
  cout << "lcs=" << s << endl;
  return opt[n][m];
}


int main() {
  string a;
  string b;

  cin >> a >> b;
  int len = lcs_len(a,b);
  cout << "length of longest common subsequence = " << len << endl;
  return 0;
}
