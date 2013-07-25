#include <iostream>

using namespace std;

int reversedigits(int x) {

  int y;

  while(x)
    y*=10,y+=(x%10),x/=10;

  return y;
}


int main() {
  int x;
  cin >> x;

  int y=reversedigits(x);
  cout << "x=" << x << " y=" << y << endl;

  return 0;
}
