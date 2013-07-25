#include <iostream>
#include <memory>
#include <stack>

using namespace std;

int main() {
  shared_ptr<stack<int> > ptr(new stack<int>());
  ptr->push(5);
  ptr->push(12);
  ptr->push(87);
  while (!ptr->empty()) {
    cout << ptr->top() << endl;
    ptr->pop();
  }
  return 0;
}
