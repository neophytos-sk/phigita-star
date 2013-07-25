/* Google interview question for software engineer about algorithm
 *
 * Given a sum S and an integer N, find all possible combinations that sum
 * up to S.
 *
 */

#include <cstdio>
#include <string>
#include <iostream>

using namespace std;


void print_sums(string sofar, int s, int n) {
  if (n==1) {
    cout << sofar << s << endl;
    return;
  }

  int i;
  char buffer[10];
  for (i=0;i<=s; ++i) {
    sprintf(buffer,"%d + ",i);
    print_sums(sofar + buffer,s-i,n-1);

  }

}


int main() {
  print_sums("", 5,3); // s=5, n=3
}
