#include <stdio.h>
// #include <unistd.h> // For sleep
#include "thread.h"


void say_hello() {
  ThreadSleep(3000);
  printf("hello world %d\n",(int) GetCurrentThread());
}

int main() {
  InitThreadPackage(true);

  int i;
  char debug_name[30];
  for(i=0;i<10;++i) {
    sprintf(debug_name,"mythread%d",i);
    ThreadNew(debug_name,(void *(*)(void *))say_hello,0);
  }


  RunAllThreads();
  return 0;
}
