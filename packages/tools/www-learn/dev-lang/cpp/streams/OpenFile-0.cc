#include <fstream>

#include "simpio.h"

void OpenFile (ifstream& infile) {
  string filename;
  filename = GetLine();
  while (true) {
    infile.open(filename.c_str());
    if (!infile.fail()) break;
    infile.clear();
    cout << "Please enter a filename." << '\n';
    cout << "Retry: ";
    filename = GetLine();
  }
}

int main(){

  ios::sync_with_stdio(false);

  ifstream infile;
  OpenFile(infile);
  string line;
  while (getline(infile,line))
    cout << line << '\n';

  infile.close();
  return 0;
}
