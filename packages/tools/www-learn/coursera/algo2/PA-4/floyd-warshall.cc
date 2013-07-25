#include <fstream>
#include <iostream>
#include <limits>
#include <map>

using namespace std;

int main(int argc, char **argv) {

  if (argc!=2) {
    cout << "Usage: " << argv[0] << "input_file" << endl;
    return 1;
  }

  long long inf = numeric_limits<long long>::max();

  ifstream infile;
  infile.open(argv[1]);

  int num_vertices, num_edges;
  map<pair<int,int>, long long> c;
  infile >> num_vertices >> num_edges;

  cout << "num_vertices=" << num_vertices << " num_edges=" << num_edges << endl;

  for (int i=0; i<num_edges; i++) {
    int tail, head, length;
    infile >> tail >> head >> length;
    c[make_pair(head,tail)] = length;
  }
  infile.close();

  long long A[num_vertices+1][num_vertices+1][num_vertices+1];
  for (int i=1; i<=num_vertices; i++)
    for (int j=1; j<=num_vertices; j++)
      if (i==j)
	A[i][j][0] = 0;
      else if (c.count(make_pair(i,j)))
	A[i][j][0] = c[make_pair(i,j)];
      else
	A[i][j][0] = inf;
	       

  for (int k=1; k<=num_vertices; k++)
    for (int i=1; i<=num_vertices; i++)
      for (int j=1; j<=num_vertices; j++)
	if (A[i][k][k-1]==inf || A[k][j][k-1]== inf)
	  A[i][j][k] = A[i][j][k-1];
	else
	  A[i][j][k] = min(A[i][j][k-1],A[i][k][k-1]+A[k][j][k-1]);


  for (int i=1; i<=num_vertices; i++)
    if (A[i][i][num_vertices] < 0) {
      cout << "has_negative_cost_cycle: " << A[i][i][num_vertices] << endl;
      return 1;
    }

  long long min_dist = inf;
  for (int i=1; i<=num_vertices; i++)
    for (int j=1; j<=num_vertices; j++)
      if (min_dist > A[i][j][num_vertices])
	min_dist = A[i][j][num_vertices];

  cout << "min_dist = " << min_dist << endl;

  return 0;
}
