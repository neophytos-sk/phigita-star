#include <iostream>
#include <cmath>
#include <iomanip>

using std::cout;
using std::endl;
using std::setw;
using std::setfill;

const double kLowerBound = 0.0;
const double kUpperBound = 1.0;
const int    kNumSteps   = 25;
const double kStepSize   = (kUpperBound - kLowerBound) / kNumSteps;


template <typename UnaryFunction>
void TabulateFunctionValues(UnaryFunction function) {
  for (double i = kLowerBound; i <= kUpperBound; i += kStepSize)
    cout << "f(" << i << ") = " << function(i) << endl;
}

double plus_half(double value) {
  return value + 0.5;
}

class Reciprocal {
public:
  double operator() (double value) const {
    return 1.0 / value;
  }
};


class Arccos {
public:
  double operator() (double value) const {
    return acos(value);  // Using the acos function from <cmath>
  }
};



int main(int argc, char *argv[]) {

  TabulateFunctionValues(plus_half);
  cout << setw(40) << setfill('*') << " " << endl;

  TabulateFunctionValues(Reciprocal());
  cout << setw(40) << setfill('*') << " " << endl;

  TabulateFunctionValues(Arccos());

  return 0;
}
