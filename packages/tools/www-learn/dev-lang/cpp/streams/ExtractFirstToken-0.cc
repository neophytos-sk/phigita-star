#include <iostream>
#include <sstream>

using namespace std;


string ExtractFirstToken(string str) {
  string token;
  stringstream buffer;
  buffer << str;
  getline(buffer,token,' ');
  return token;
}

int main() {
  string str;
  getline(cin,str);
  cout << ExtractFirstToken(str);
  return 0;
}
