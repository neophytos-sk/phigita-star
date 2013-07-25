#include <iostream>

using namespace std;

class RedAndGreen
{
public:
  int twoDiff(int A[],int B[],int n)
  {
    int i,ans=0;
    for(i=0;i<n;i++)
      {
	ans+=A[i]^B[i];
      }
    return ans;
  }

  int minPaints(string x)
  {
    int i,sol;
    int inp[51];
    int n=x.length();
    for(i=0;i<n;i++)
      {
	inp[i]=1;
	if(x[i]=='R')
	  inp[i]=0;
      }
    int all[51];
    fill(all,all+n,1);
    int ans=twoDiff(all,inp,n);
    for(i=0;i<n;i++)
      {
	all[i]=0;
	sol=twoDiff(all,inp,n);
	if(sol<ans)
	  ans=sol;
      }
    return ans;
  }

};


int main() {

  RedAndGreen p;
  cout << p.minPaints("RGGRRGRRRGGGGGGGRG") << endl;
  
  return 0;
}
