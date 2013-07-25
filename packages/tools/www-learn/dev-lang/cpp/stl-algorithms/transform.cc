#include <string>
#include <algorithm>  // transform
#include <iostream>

using std::string;
using std::transform;
using std::cout;


int main() {
  string text = "Hello World! This is a test.";

  transform(text.begin(),text.end(),text.begin(),tolower);

  cout << text << '\n';

  return 0;

}
