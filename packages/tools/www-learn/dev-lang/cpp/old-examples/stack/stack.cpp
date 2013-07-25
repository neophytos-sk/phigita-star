#include <iostream>
#include "stack.h"

Stack::Stack() 
{
  firstEl = NULL;
  return;
}


Stack::~Stack() 
{
  element_t *next;
  while(firstEl) {
    next=firstEl->next;
    delete firstEl;
  }
  std::cout << "stack destroyed" << std::endl;
  return;
}


void Stack::push(void *data) 
{
  // allocation error will throw exception
  element_t *elem = new element_t;
  elem->data = data;
  elem->next = firstEl;
  firstEl = elem;
}


void* Stack::pop() 
{
  element_t *popElement = firstEl;
  void *data;

  // assume StackError exception class is defined elsewhere
  if (!firstEl)
    return NULL;  // throw StackError(E_EMPTY)

  data = firstEl->data;
  firstEl = firstEl->next;
  delete popElement;
  return data;

}
