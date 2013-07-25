
#include "simpio.h"

using namespace std;

/* Slow Input / Output with C++ Streams
 *
 * When solving tasks with very large amounts of input / output data, you may 
 * notice that C++ programs using the cin and cout streams are much slower than
 * equivalent programs that use the scanf and printf functions for input and
 * output processing. Thus, if you are using the cin / cout streams we strongly
 * recommend that you switch to using scanf / printf instead. However, if you
 * still want to use cin / cout, we recommend adding the following line at the
 * beginning of your program:
 *
 *     ios::sync_with_stdio(false);
 *
 * and also making sure that you never use endl , but use '\n' instead.
 *
 * Please note, however, that including ios::sync_with_stdio(false) breaks the
 * synchrony between cin / cout and scanf / printf, so if you are using this,
 * you should never mix usage of cin and scanf, nor mix cout and printf.
 *
 */


string GetLine() {
  string result;
  getline(cin,result);
  return result;
}


int GetInteger() {
  // Read input until user enters valid data
  while(true) {
    stringstream converter;
    converter << GetLine();

    int result;
    if (converter >> result) {
      /* check that there isn't any leftover data ... */
      char remaining;
      if (converter >> remaining)  // something's left, input is invalid
        cout << "Unexpected character: " << remaining << '\n';
      else
        return result;
    } else
      cout << "Please enter an integer." << '\n';

    cout << "Retry: ";
  }
}

double GetReal() {
  // Read input until user enters valid data
  while(true) {
    stringstream converter;
    converter << GetLine();

    double result;
    if (converter >> result) {
      /* check that there isn't any leftover data ... */
      char remaining;
      if (converter >> remaining)  // something's left, input is invalid
        cout << "Unexpected character: " << remaining << '\n';
      else
        return result;
    } else
      cout << "Please enter a real." << '\n';

    cout << "Retry: ";
  }
}

bool GetBoolean() {
  // Read input until user enters valid data
  while(true) {
    stringstream converter;
    converter << GetLine();

    bool result;
    if (converter >> boolalpha >> result) {
      /* check that there isn't any leftover data ... */
      char remaining;
      if (converter >> remaining)  // something's left, input is invalid
        cout << "Unexpected character: " << remaining << '\n';
      else
        return result;
    } else
      cout << "Please enter 'true' or 'false'." << '\n';

    cout << "Retry: ";
  }
}
