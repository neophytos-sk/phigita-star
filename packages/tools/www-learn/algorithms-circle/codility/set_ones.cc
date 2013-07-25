/*
    Given a matrix of size n x m filled with 0's and 1's
    e.g.:
    1 1 0 1 0
    0 0 0 0 0 
    0 1 0 0 0
    1 0 1 1 0

    if the matrix has 1 at (i,j), fill the column j and row i with 1's
    i.e., we get:
    1 1 1 1 1
    1 1 1 1 0 
    1 1 1 1 1
    1 1 1 1 1

    complexity: O(n*m) time and O(1) space
    NOTE: you are not allowed to store anything except
    '0' or '1' in the matrix entries
*/

#include <iostream>
#include <vector>

#define FOR(i,a,b) for(__typeof(a) i=a;i<=b;i++)

using namespace std;

void set_ones(vector<vector<int> >& a, int rows, int cols) {

  // figure out rows/cols with ones
  FOR(i,1,rows) {
    FOR(j,1,cols) {
      if (a[i][j]) {
	a[i][0]=1;
	a[0][j]=1;
      }
    }
  }

  // fill identified rows/cols with ones
  FOR(i,1,rows) {
    FOR(j,1,cols) {
      if (a[i][0] || a[0][j])
	a[i][j]=1;
    }
  }
}


int main() {
  
  int rows;
  int cols;
  cin >> rows >> cols;
  vector<vector<int> > a(rows+1,vector<int>(cols+1,0));
  FOR(i,1,rows) FOR(j,1,cols) cin >> a[i][j];
  set_ones(a,rows,cols);
  FOR(i,1,rows) FOR(j,1,cols) cout << a[i][j] << ((j==cols)?"\n":" ");
  return 0;
}
