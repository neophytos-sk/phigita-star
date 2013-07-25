#include <string>

using std::string;

int main() {

  string s = "neophytos";
  while (!s.empty())
    s.erase(s.begin());

  return 0;
}
