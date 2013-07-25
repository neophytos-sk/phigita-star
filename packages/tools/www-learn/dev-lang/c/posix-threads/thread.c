#include <stdio.h>
#include <string.h> // For strcpy
#include <unistd.h> // For usleep
//#include <time.h>   // For nanosleep

#include "thread.h"
#include "llist.h"

typedef struct thread_s {
  char *debug_name;
  pthread_t thread_id;   /* the ID of the thread */
  pthread_attr_t attr;   /* set of thread attributes */
  void *(*func)(void *); /* Main() function of the thread) */
  int narg;
  element_t *args;       /* the one argument to Main(), a linked list */
} thread_t;


element_t *thread_list;

void InitThreadPackage(bool trace_flag) {
  printf("Trace Flag: %d\n",trace_flag);
  CreateList(&thread_list);
}

void ThreadNew(const char *debug_name, void *(*func)(void *), int narg, ...) {

  thread_t *rec = (thread_t *)malloc(sizeof(thread_t));
  rec->debug_name = (char *)malloc(strlen(debug_name));
  strcpy(rec->debug_name,debug_name);
  rec->func = (void *(*)(void *))func;
  rec->narg = narg;
  CreateList(&rec->args);
  
  char *s;
  int i;
  va_list args;
  va_start(args, narg);
  for (i=0;i<narg;++i) {
    s = va_arg(args, char *);
    Insert(&rec->args, (void *) s);
  }
  va_end(args);

  Insert(&thread_list,(void *) rec);

}

void WaitThread(const thread_t *thread) {
  /* wait for the thread to exit */
  pthread_join(thread->thread_id,NULL);
}

void RunThread(const thread_t *thread, bool wait_thread_p) {

  /* get the default attributes */
  pthread_attr_t *attrp = (pthread_attr_t *) &(thread->attr);
  pthread_attr_init(attrp);

  /* create the thread */
  pthread_create((pthread_t *) &(thread->thread_id),attrp,thread->func,NULL);

  printf("RunThread: %s (tid=%d)\n",thread->debug_name, (int)thread->thread_id);

  if (wait_thread_p) {
    WaitThread(thread);
  }

}

pthread_t GetCurrentThread(void) {
  return pthread_self();
}


void WaitAllThreads() {
  element_t *node = thread_list;
  while(node) {
    WaitThread(node->data);
    node = node->next;
  }

}

void RunAllThreads() {
  element_t *node = thread_list;
  while(node) {
    RunThread(node->data,false);
    node = node->next;
  }
  
  WaitAllThreads();
}

void ThreadSleep(int msec) {
  usleep(msec*1000);
}
