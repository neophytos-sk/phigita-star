#include <string>
#include <iostream>
#include <vector>

using namespace std;

void StringSplit(string str, string delim, vector<string>& results) {
  int cutAt;
  while( (cutAt = str.find_first_of(delim)) != string::npos ) {
    if(cutAt > 0) {
      results.push_back(str.substr(0,cutAt));
    }
    str = str.substr(cutAt+1);
  }
  if(str.length() > 0) {
    results.push_back(str);
  }
}


int main() {
	string s("1.2.3.4.5.A.B.C");
	cout << s.find_first_of(".") << endl;
	vector<string> results;
	StringSplit(s,".",results);
	cout << s << endl;
	cout << results.size() << endl;
}
