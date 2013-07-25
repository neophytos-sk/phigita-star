#include <iostream>
#include <sstream>

using namespace std;

#define SEPARATOR ' '

string ExtractFirstToken(string str) {
  string token;
  stringstream buffer(str);
  getline(buffer,token,SEPARATOR);
  return token;
}

int main() {
  string str;
  getline(cin,str);
  cout << ExtractFirstToken(str);
  return 0;
}
