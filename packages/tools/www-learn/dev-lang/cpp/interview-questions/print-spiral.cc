#include <iostream>

using namespace std;

int main() {
	int matrix[10][10];
	int r,c;
	cout << "Enter rows and columns:";
	cin >> r >> c;
	cout << "rows=" << r << endl;
	cout << "cols=" << c << endl;

	// initialize matrix
	int count=1;
	for (int i=0;i<r;i++) 
		for (int j=0;j<c;j++)
			matrix[i][j]=count++;

	int m=(r/2)+1;
	int i=0;
	int k,j;
	while (i<=m) {
		k = i;
		j = 0;
		for(;j<=c-2;j++)
			cout << matrix[k][j]  << " ";
		for (;k<=r-2;k++) 
			cout << matrix[k][j]  << " ";
		for (;j>=i;j--)
			cout << matrix[k][j]  << " ";
		for (;k>=i;k--)
			cout << matrix[k][j]  << " ";

		i++;
		
		c--; // restrict columns to smaller square
		r--; // restrict rows to smaller square
	}
	
	return 0;
}