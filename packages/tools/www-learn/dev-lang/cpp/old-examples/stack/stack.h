#ifndef STACK_H
#define STACK_H


class Stack 
{
 public:
  Stack();
  ~Stack();
  void push(void *data);
  void* pop();
 private:
  typedef struct elementT {
    struct elementT* next;
    void *data;
  } element_t;
  element_t *firstEl;
};


#endif
