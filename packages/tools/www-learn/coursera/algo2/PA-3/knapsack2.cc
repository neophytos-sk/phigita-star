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

  int P[knapsack_size+1];
  int S[knapsack_size+1];
  for (int j = 0; j <= knapsack_size; j++)
    S[j] = 0;

  for (int i = 1; i <= number_of_items; i++) {

    for (int j = 1; j <= knapsack_size; j++) 
      P[j] = S[j];

    S[0] = 0;
    for (int j = 1; j <= knapsack_size; j++) {
      S[j] = P[j];
      if (weight[i] <= j && (S[j] < (value[i] + P[j-weight[i]])))
	S[j] = value[i] + P[j-weight[i]];
    }
  }

  cout << S[knapsack_size] << endl;

  return 0;
}
