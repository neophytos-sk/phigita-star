/* This problem is straight forward. N! = 1 * 2 * 3 * 4 * 5 * .... * N. If we count all 5's in this product, then that many trailing zeros are there. This is because a 5 is countered by 2 to produce a zero. Additionally, there are more 2's than 5's so counting 5's gives the right answer.
*/

#include <iostream>

using namespace std;

int FactorialTrailingZeros(int n) {
  int count = 0;
  int i = 5;
  while (i<=n) {
    int j = i;
    while(j%5==0) {
      j = j/5;
      count++;
    }
    i += 5;
  }
  return count;
}


int main() {
  int n;
  cin >> n;
  cout << FactorialTrailingZeros(n) << endl;
  return 0;
}
