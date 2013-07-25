#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>


int sell_tickets() {
  int i;
  for (i=0;i<10;++i) {
    printf("hello %d\n",i);
    system("sleep 1");
  }
  return 123;
}


int main(int argc, char *argv[]) {
  pthread_t thread;
  pthread_attr_t attr;
 

  /* Initialize thread creation attributes */

  if (pthread_attr_init(&attr)) {
    fprintf(stderr,"pthread_attr_init failed\n");
    return 1;
  }

  int stack_size = -1;
  if (stack_size > 0) {
    if (pthread_attr_setstacksize(&attr,stack_size)) {
      fprintf(stderr,"pthread_attr_setstacksize failed\n");
      return 1;
    }
  }

  /* Create one thread for each command-line argument */
  if (pthread_create(&thread, &attr,&sell_tickets,NULL)) {
    fprintf(stderr,"pthread_create failed\n");
    return 1;
  }

  if (pthread_attr_destroy(&attr)) {
    fprintf(stderr,"pthread_attr_destroy failed\n");
  }

  int res = 0;

  printf("before pthread_join\n");
  system("sleep 5");
  printf("ready for pthread_join\n");
  pthread_join(thread,&res);

  printf("res=%d\n",res);



  return 0;
}
