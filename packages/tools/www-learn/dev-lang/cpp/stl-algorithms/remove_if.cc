#include <iostream>   // cout
#include <algorithm>  // remove_if
#include <string>
#include <cctype>     // ispunct

using std::remove_if;
using std::cout;
using std::string;


int main() {
  string text = "Hello, World! My name is: Neophytos. This is a test";

  text.erase(remove_if(text.begin(),text.end(),ispunct),text.end());

  cout << text << "\n";

  return 0;
}
