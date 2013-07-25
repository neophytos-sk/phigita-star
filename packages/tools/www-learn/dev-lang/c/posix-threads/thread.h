#ifndef THREAD_H
#define THREAD_H

#include <pthread.h>
#include <stdarg.h>

typedef enum {false,true} bool;

void InitThreadPackage(bool trace_flag);
void ThreadNew(const char *debug_name, void * (*func)(void *), int vargc,...);
pthread_t GetCurrentThread(void);
void ThreadSleep(int msec);
void RunAllThreads();

#endif
