// We are given 4 numbers say n1, n2, n3, n4. We can place them in any order and we can use mathematical operator +,-,*,/ in between them to have final result as 24. Write an algorithm for this, it will take 4 numbers and return false or true whether final result 24 is possible with any combination.


/*
In principal, this is nice but
(1) Integer division/multiplication would cause problems (since you're modifying the result; i.e. the right-hand side). Dividing right hand side by x is different from multiplying the left-hand side by x and vice versa; e.g. 3*5 <> 16 but 3 == 16/5). Switching to float computation would fix the issue but would change the problem (depends on whether integer or float arithmetic is expected)
(2) operator precedence is not considered (which may be OK depending again on what's expected).

You could avoid both of these caveats using the following:
(a) Build a math expression evaluator (given a string of numbers and operators, return its value).
(b) Recursively build a string of numbers and operators from our input using code similar to the above.
(c) When you get to the final string, evaluate it and return it if its value is the same as the goal.

I know, this just fixes a few (minor) issues with the above code and does not reduce the running time.

To avoid checking all posibilities using brute force, we could try to somehow explore commutativity of + and * operations. Not exactly sure how, though.
*/









#include <iostream>
#include <vector>
#include <stdlib.h>

#define MAX_GOAL 1000
#define MAX_NUMS 50

using namespace std;

bool existing(const vector<int>& numbers, int goal) {

  if (numbers.size() == 1) {
    if (numbers[0] == goal) 
      return true;
    else
      return false;
  }

  for (int i=0; i<numbers.size(); ++i) {
    vector<int> numbers_left;

    for (int j=0; j<numbers.size(); ++j) 
      if (i != j) 
	numbers_left.push_back(numbers[j]);

    if (existing(numbers_left, goal-numbers[i]))
      return true;

    if (existing(numbers_left, goal+numbers[i]))
      return true;

    if (existing(numbers_left, goal*numbers[i]))
      return true;

    if (existing(numbers_left, goal/numbers[i]))
      return true;
  }

  return false;
}

// INCORRECT BUT WORTH TO SEE/READ --- SEE SUBSET SUM PROBLEM
// subset sum pseudo-polynomial algorithm
// Q(i,s): there is a nonempty subset of x1,...,xi which sums to s
bool existing_dp(const vector<int> numbers, int goal) {

  int n = numbers.size();
  int Q[MAX_NUMS][MAX_GOAL];
  int i,s;
  
  for (s=0; s<=goal; ++s)
    Q[0][s] = (numbers[i] == s);

  for (i=1; i<n; ++i) {
    // maybe: try from -goal to goal, this way we cover addition and subtraction
    for (s=0; s<=goal; ++s) {
      Q[i][s] = Q[i-1][s] || (numbers[i] == s) || Q[i-1][s-numbers[i]];
    }
  }
  return Q[n][0]==0;
}


int main(int argc, char *argv[]) {

  int goal=24;
  vector<int> numbers;
  for (int i=0; i<argc-1; ++i) {
    numbers.push_back(atoi(argv[i+1]));
    cout << numbers[i] << '\n';
  }
  cout << "existing() = " << boolalpha << existing(numbers,goal) << noboolalpha << '\n';

  //cout << "existing_dp() = " << boolalpha << existing_dp(numbers,goal) << noboolalpha << '\n';

}
