#include <iostream>
#include <deque>

using namespace std;

template <typename T> class Stack
{
public:
  void push(T newValue);
  T pop();
  size_t size();
  bool empty();

  // you only need to use the typename keyword when accessing a type
  // nested inside of a dependent type
  typename deque<T>::iterator begin();
  typename deque<T>::iterator end();

  typedef typename deque<T>::iterator iterator;

private:
  deque<T> elems;

  
};


template <typename T> void Stack<T>::push(T newValue)
{
  elems.push_front(newValue);
}

template <typename T> T Stack<T>::pop()
{
  T result;
  result = elems.front();
  elems.pop_front();
  return result;
}

template <typename T> size_t Stack<T>::size()
{
  return elems.size();
}

template <typename T> bool Stack<T>::empty()
{
  return elems.empty();
}

template <typename T> typename deque<T>::iterator Stack<T>::begin()
{
  return elems.begin();
}

template <typename T> typename deque<T>::iterator Stack<T>::end()
{
  return elems.end();
}


int main()
{
  Stack<int> myStack;
  myStack.push(5);
  myStack.push(4);
  myStack.push(3);
  myStack.push(2);
  myStack.push(1);

  while(!myStack.empty())
    cout << myStack.pop() << endl;

  cout << "=================== typeof(myStack.begin()) it" << endl;

  myStack.push(15);
  myStack.push(14);
  myStack.push(13);
  myStack.push(12);
  myStack.push(11);

  for(typeof(myStack.begin()) it = myStack.begin(); it != myStack.end(); it++)
    cout << "iterator out: " << *it << endl;

  cout << "-------------------- deque<int>::iterator it" << endl;

  for(deque<int>::iterator it = myStack.begin(); it != myStack.end(); it++)
    cout << "iterator out: " << *it << endl;


  cout << "-------------------- Stack<int>::iterator it" << endl;

  for(Stack<int>::iterator it = myStack.begin(); it != myStack.end(); it++)
    cout << "iterator out: " << *it << endl;


  return 0;

}
