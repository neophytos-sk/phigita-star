/*

    1. Allocate an array of 3000 bytes, with each byte representing one digit in the factorial. Start with a value of 1.
    2. Run grade-school multiplication on the array repeatedly, in order to calculate the factorial.
    3. Sum the digits.

Doing the repeated multiplications is the only potentially slow step, but I feel certain that 1000 of the multiplications could be done in a second, which is the worst case. If not, you could compute a few "milestone" values in advance and just paste them into your program.

One potential optimization: Eliminate trailing zeros from the array when they appear. They will not affect the answer.



*/

#include <iostream>

using namespace std;

int FactorialDigitsSum(int number) {
  const int MOD = 100000;

  unsigned int dig[MOD], first=0, last=0, carry, n, x;
  dig[0] = 1;
  for(n=2; n <= number; n++) {
    carry = 0;
    for(x=first; x <= last; x++) {
      carry = dig[x]*n + carry;
      dig[x] = carry % MOD;
      if(x == first && !(carry % MOD)) first++;
      carry /= MOD; 
    }
    if(carry) dig[++last] = carry; 
  }
  int sum=0;
  for(x=first; x <= last; x++)
    sum += dig[x]%10 
    + (dig[x]/10)%10 
    + (dig[x]/100)%10 
    + (dig[x]/1000)%10
    + (dig[x]/10000)%10;

  return sum;
}

int main() {
  int x;
  cin >> x;
  cout << "sum= " << FactorialDigitsSum(x) << endl;
}
