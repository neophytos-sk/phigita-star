/* Yahoo Interview Question for Software Engineer / Developers about Algorithm
 * 
 * Given a stack S, write a program to sort the stack (in ascending order).
 * You are not allowed to make any assumptions about how the stack is 
 * implemented; the only functions allowed to be used are: 
 * push,pop,top,isempty,isfull
 */
#include <stack>
#include <iostream>

using namespace std;

void sort_stack_M1(stack<int> &orig_stack) {

  stack<int> new_stack;

  if (orig_stack.size() == 1) {
    //new_stack.push(orig_stack.top());
    //orig_stack.pop();
    return;
  }

  int val;
  while (!orig_stack.empty()) {
    val = orig_stack.top();
    orig_stack.pop();
    while (!new_stack.empty() && new_stack.top() < val) {
      orig_stack.push(new_stack.top());
      new_stack.pop();
    }
    new_stack.push(val);
  }

  orig_stack = new_stack;
}


void insert(stack<int> &s, int x); // function prototype

// sort without using any additional stack
// seems to be like tower of hanoi problem
void sort_stack_M2(stack<int>& s) {
  int x;
  if (!s.empty()) {
    x = s.top();
    s.pop();
    sort_stack_M2(s);
    insert(s,x);
  }
}


// recursively insert x into the right position in the stack
void insert(stack<int>& s, int x) {
  int y;
  if (!s.empty() && s.top() < x) {
    y = s.top();
    s.pop();
    insert(s,x);
    s.push(y);
  } else {
    s.push(x);
  }
}


void dump_stack(stack<int> &s) {
  while (!s.empty()) {
    cout << s.top() << endl;
    s.pop();
  }
}

int main() {
  stack<int> values;
  values.push(2);
  values.push(6);
  values.push(5);
  values.push(1);
  values.push(3);

  //sort_stack_M1(values);
  sort_stack_M2(values);

  dump_stack(values);

  return 0;
}
