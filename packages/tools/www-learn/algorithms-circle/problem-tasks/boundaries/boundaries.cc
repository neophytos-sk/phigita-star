// Given an input array of integers of size n, and a query array of integers of size k, find the smallest window of input array that contains all the elements of query array and also in the same order.

#include <iostream>

using namespace std;

bool minWindow(int N[], int n, int K[], int k, int Boundaries[]) {
  int minWin = -1;
  int* P = new int[k]; // all elements init to 0
  
  P[0] = -1;
  while(true) {
    for(int i=0;i<k;i++) {
      if(i>0 && P[i] < P[i-1])
	P[i] = P[i-1];
      if(i==0 || P[i]==P[i-1]) {
	do {
	  P[i]++;
	  if(P[i]>=n) {
	    delete[] P;
	    return minWin>0 ? true : false;
	  }
	} while(N[P[i]] != K[i]);
      }
    }
    int win = P[k-1] - P[0] + 1;
    if(minWin==-1 || win<minWin) {
      Boundaries[0] = P[0];
      Boundaries[1] = P[k-1];
      minWin = win;
    }
  }
}


int main() {
  int N[] = {23,46,24,16,16,29,35,2,77,29,35,77,29,2};
  int K[] = {16,2,77,29};
  int Boundaries[2];
  bool success = minWindow(N,sizeof(N)/sizeof(int),K,sizeof(K)/sizeof(int),Boundaries);
  if(success)
    cout << "start: " << Boundaries[0] << ", end: " << Boundaries[1] << endl;
  else
    cout << "No such window" << endl;
  return 0;
}
