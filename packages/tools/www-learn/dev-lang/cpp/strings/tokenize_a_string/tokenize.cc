#include <string>
#include <vector>
#include <iostream>

using std::string;
using std::vector;
using std::cout;
using std::cerr;

vector<string> tokenize(const string& str, const string& delims=", \t") {
  
  // output vector
  vector<string> tokens;

  string::size_type last_pos = str.find_first_not_of(delims,0);
  string::size_type pos = str.find_first_of(delims,last_pos);
  while (string::npos != pos || string::npos != last_pos) {
    // found a token, add it ot the vector.
    tokens.push_back(str.substr(last_pos,pos-last_pos));
    // skip delims. note the "not of". this is the beginnning of token
    last_pos = str.find_first_not_of(delims,pos);
    pos = str.find_first_of(delims,last_pos);
  }
  return tokens;
}


int main(int argc, char *argv[]) {

  if (argc!=2 && argc!=3) {
    cerr << "Usage: " << argv[0] << " \"the string to tokenize\""
	 << " [\"delimiters\"]" << '\n';
    return -1;
  }
  string str = argv[1];
  vector<string> tokens;
  if (argc==2)
    tokens = tokenize(str);
  else if (argc==3)
    tokens = tokenize(str,argv[2]);

  for (vector<string>::iterator itr=tokens.begin();
       itr != tokens.end();
       ++itr)
    cout << *itr << '\n';

  return 0;
}
