#include <deque>
#include <iostream>
#include <iterator>
#include <cstdlib>
#include <ctime>


using namespace std;


double RandomNumber() {
  return static_cast<double>(rand() / (RAND_MAX + 1.0));
}

const int kMaxNums = 10;

int main() {

  srand(static_cast<unsigned int>(time(NULL)));

  deque<double> myDeque;

  for(int i=0;i<kMaxNums;++i) {
    myDeque.push_back(RandomNumber());
  }

  copy(myDeque.begin(),myDeque.end(),ostream_iterator<double>(cout,"\n"));

  cout << "-------------" << '\n';

  myDeque.push_front(888);
  myDeque.push_front(12345);
  myDeque.push_back(7890);
  myDeque.push_back(9999);

  copy(myDeque.begin(),myDeque.end(),ostream_iterator<double>(cout,"\n"));

  cout << "-------------" << '\n';

  cout << "front: " << myDeque.front() << '\n';
  cout << "back: " << myDeque.back() << '\n';

  myDeque.pop_front();
  myDeque.pop_back();

  cout << "-------------" << '\n';

  copy(myDeque.begin(),myDeque.end(),ostream_iterator<double>(cout,"\n"));

  cout << "size: " << myDeque.size() << '\n';

  return 0;
}
