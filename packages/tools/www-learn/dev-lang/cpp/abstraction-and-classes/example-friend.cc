#include <iostream>
using namespace std;

class Numbers {
  int a;
  int b;
public:
  Numbers(int i, int j) {
	a=i;
	b=j;
  }
  friend class Average;
};

class Average {
  public:
  int average(Numbers x);
};

int Average::average(Numbers x) {
  return ((x.a+x.b)/2);
}

int main(){
  Numbers ob(23,67);
  Average avg;
  cout << "The average of the numbers is:" << avg.average(ob) << endl;
  return 0;
}
