#include <iostream>

using namespace std;

int whole_cubes_count(int A, int B) {
  int count=0;
  for(int cur=0;cur*cur*cur<=B;++cur)
    if(cur*cur*cur>=A) count++;
  return count;
}

int main() {
  int A,B;
  cin >> A >> B;
  cout << whole_cubes_count(A,B) << endl;
  return 0;
}
