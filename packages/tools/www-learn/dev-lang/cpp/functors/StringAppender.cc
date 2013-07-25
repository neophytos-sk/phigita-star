#include <cstdio>
#include <string>

namespace {

using std::string;

class StringAppender {
public:
  /* Constructor takes and stores a string. */
  explicit StringAppender(const string& str) : toAppend(str) {}

  /* operator() prints out a string, plus the stored suffix. */
  void operator() (const string& str) const {
    printf ("%s%s\n",str.c_str(),toAppend.c_str());
  }

private:
  const string toAppend;
};

}  // unnamed namespace


int main(int argc, char *argv[]) {
  StringAppender appender("Don't you think?");
  appender("C++ is awesome... ");
  return 0;
}
