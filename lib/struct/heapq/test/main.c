#include <stdio.h>
#include "heapq.h"


typedef struct {
  int pri;
  char *str;
} wordcount_t;

int compare_wordcount(const void *d1, const void *d2)
{
  int v1 = ((wordcount_t *) d1)->pri;
  int v2 = ((wordcount_t *) d2)->pri;

  return (v1>v2) ? -1 : ((v1<v2) ? 1 : 0);
}


int main(int argc, char **argv)
{
  heapq_t q;
  heapq_init(&q, compare_wordcount);

  wordcount_t wc0, wc1, wc2;
  wc0.pri = 213;
  wc0.str = "hello";
  wc1.pri = 456;
  wc1.str = "world";
  wc2.pri = 88;
  wc2.str = "test";

  heapq_insert(&q,&wc0);
  heapq_insert(&q,&wc1);
  heapq_insert(&q,&wc2);

  while(!heapq_empty(&q)) {
    const wordcount_t *wc = heapq_top(&q);
    printf("%d %s\n", wc->pri,  wc->str);
    heapq_pop(&q);
  }


  return 0;
}
