#include <fstream>
#include <iostream>

using namespace std;

int main() {
  ifstream ts("table-data.txt");
  int lineIndex =0, iNum;
  float fNum;
  while (!ts.eof()) {
    lineIndex++;
    ts >> iNum >> fNum;
    cout << lineIndex << '\t' << "iNum=" << iNum << " fNum=" << fNum << endl;
  }
  return 0;
}
