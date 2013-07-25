/* Yahoo Interview Question for Software Engineer / Developers about Algorithm
 *
 * Write a program to reverse a stack in place using recursion. You can only
 * use the following ADT functions on stack: isEmpty, isFull, Push, Pop, Top.
 * you may not use extra stack or any other data structure.
 */

#include <stack>
#include <iostream>



using namespace std;


typedef stack<int> Stack;


void push_to_bottom(Stack& stack, int x);


void reverse(Stack& stack)
{
  if (!stack.empty()) {
    int x = stack.top();
    stack.pop();
    reverse(stack);
    push_to_bottom(stack, x);
  }
}


void push_to_bottom(Stack& stack, int x)
{
  if (stack.empty()) {
    stack.push(x);
  }
  else {
    int y = stack.top();
    stack.pop();
    push_to_bottom(stack, x);
    stack.push(y);
  }
}


// destructive
void dump_stack(Stack& s)
{
  while (!s.empty()) {
    int i = s.top();
    s.pop();
    cout << i << ' ';
  }
  cout << endl;
}


int main()
{
  Stack s;


  // 5 at bottom
  s.push(5);
  s.push(4);
  s.push(3);
  s.push(2);
  s.push(1);


  reverse(s);


  dump_stack(s);
}
