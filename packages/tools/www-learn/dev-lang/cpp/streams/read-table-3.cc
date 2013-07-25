#include <fstream>
#include <iostream>
#include <iomanip>

using namespace std;

const int NUM_LINES = 4;
const int NUM_COLUMNS = 3;
const int COLUMN_WIDTH = 20;

void PrintTableHeader () {
  /* Print the ---...---+- pattern for all but the last column. */
  for (int column = 0; column < NUM_COLUMNS - 1; ++column) 
    cout << setfill('-') << setw(COLUMN_WIDTH) << "" << "-+-";

  /* Now print the ---...--- pattern for the last column and a newline. */
  cout << setw(COLUMN_WIDTH) << "" << setfill(' ') << endl;
}

void PrintTableBody() {

  ifstream input("table-data.txt");
  /* No error-checking here, but you should be sure to do this in any real
   * program.
   */

  /* Loop over the lines in the file reading data. */
  int  rowNumber = 0;
  while(true) {
    int intValue;
    double doubleValue;
    input >> intValue >> doubleValue;
    if (input.fail()) break;
    cout << setw(COLUMN_WIDTH) << (rowNumber+1) << " | ";
    cout << setw(COLUMN_WIDTH) << intValue << " | ";
    cout << setw(COLUMN_WIDTH) << doubleValue << endl;
    rowNumber++;
  }
}

int main() {
  PrintTableHeader();
  PrintTableBody();
  return 0;
}
