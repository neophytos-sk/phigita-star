#include <fstream>
#include <iostream>

using namespace std;


int main(int argc, char **argv) {

  if (argc!=2) {
    cout << "Usage: " << argv[0] << " input_file" << endl;
    return 1;
  }
  
  ifstream infile;
  infile.open(argv[1]);

  int knapsack_size;
  int number_of_items;

  cout << "reading input..." << endl;

  infile >> knapsack_size >> number_of_items;
  int value[number_of_items+1], weight[number_of_items+1];
  for (int i = 1; i <= number_of_items; i++)
    infile >> value[i] >> weight[i];


  infile.close();

  cout << "solving knapsack..." << endl;

  int S[number_of_items+1][knapsack_size+1];
  for (int j = 0; j <= knapsack_size; j++)
    S[0][j] = 0;

  for (int i = 1; i <= number_of_items; i++) {
    S[i][0] = 0;
    for (int j = 1; j <= knapsack_size; j++) {
      //S[i][j] = max(S[i-1][j], S[i][j-1]);
      S[i][j] = S[i-1][j];
      if (weight[i] <= j && (S[i][j] < (value[i] + S[i-1][j-weight[i]])))
	S[i][j] = value[i] + S[i-1][j-weight[i]];
    }
  }

  cout << S[number_of_items][knapsack_size] << endl;

  return 0;
}
