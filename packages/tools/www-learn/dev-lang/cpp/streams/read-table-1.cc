#include <fstream>
#include <iostream>
#include <iomanip>

using namespace std;

const int NUM_LINES = 4;
const int NUM_COLUMNS = 3;
const int COLUMN_WIDTH = 20;

void PrintTableHeader () {
  /* Print the ---...---+- pattern for all but the last column. */
  for (int column = 0; column < NUM_COLUMNS - 1; ++column) {
    for (int k = 0; k < COLUMN_WIDTH; ++k)
      cout << '-';
    cout << "-+-";
  }

  /* Now print the ---...--- pattern for the last column. */
  for (int k = 0; k < COLUMN_WIDTH; ++k)
    cout << '-';

  /* Print a newline... there's nothing else on this line. */
  cout << endl;
}

void PrintTableBody() {

  ifstream input("table-data.txt");
  /* No error-checking here, but you should be sure to do this in any real
   * program.
   */

  /* Loop over the lines in the file reading data. */
  for (int k = 0; k < NUM_LINES; ++k) {
    int intValue;
    double doubleValue;
    input >> intValue >> doubleValue;
    cout << setw(COLUMN_WIDTH) << (k+1) << " | ";
    cout << setw(COLUMN_WIDTH) << intValue << " | ";
    cout << setw(COLUMN_WIDTH) << doubleValue << endl;
  }
}

int main() {
  PrintTableHeader();
  PrintTableBody();
  return 0;
}
