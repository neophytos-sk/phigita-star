#include <stdlib.h>

typedef struct {

  /* actual size of a heap */
  size_t size;

  /* amount of allocated memory for the heap */
  size_t capacity;

  /* array of (void *), the actual max heap */
  void **data;

  /* comparator function used to prioritize elements */
  int (*cmp)(const void *d1, const void *d2);

} heapq_t;




static inline size_t LEFT  (size_t x) { return (2 * (x) + 1); }
static inline size_t RIGHT (size_t x) { return (2 * (x) + 2); }
static inline size_t PARENT(size_t x) { return ((x) / 2);     }


heapq_t *heapq_new(size_t capacity, int (*cmp)(const void *d1, const void *d2)) 
{

  heapq_t *q = malloc(sizeof(heapq_t));
  q->cmp = cmp;
  q->data = malloc(capacity * sizeof(void *));
  q->capacity = capacity;
  q->size = 0;
  
  return q;

}

void heapq_destroy(heapq_t *q)
{
  if (!q) {
    return;
  }
  free(q->data);
  free(q);
}

int heapq_empty(heapq_t *q) {
  return q->size==0;
}

void heapq_insert(heapq_t *q, const void *data)
{
  
  void **b;

  if (q->size >= q->capacity) {
    q->capacity *= 2;
    b = q->data = realloc(q->data, q->capacity * sizeof(void *));
  } else {
    b = q->data;
  }


  size_t n, m;
  n = q->size++;

  /* append at end, then up heap */
  while ((m = PARENT(n)) != n && q->cmp(b[m],data) > 0) {
    b[n] = b[m];
    n = m;
  }
  b[n] = data;


}


void *heapq_top(heapq_t *q) {
  if (heapq_empty(q)) {
    return NULL;
  }
  return q->data[0];
}

void heapq_pop(heapq_t *q) {
  if (heapq_empty(q)) {
    // error
    return;
  }

  /* pull last item to top, then down heap. */
  --q->size;

  int n = 0, m;
  while ((m = LEFT(n)) < q->size) {

    /* if right node is greater than left node then use that one */
    if (m + 1 < q->size && q->cmp(q->data[m], q->data[m + 1]) > 0) m++;
    
    if (q->cmp(q->data[n], q->data[m]) > 0) break;
    q->data[n] = q->data[m];
    n = m;
  }
 
  q->data[n] = q->data[q->size];

  if (q->size < q->capacity / 2 && q->size >= 16)
    q->data = realloc(q->data, (q->capacity /= 2) * sizeof(void *));
  
}


/* remove lowest priority item */
void heapq_pop_back(heapq_t *q) {
  if (heapq_empty(q)) {
    // error
    return;
  }

  /* pull last item from back */
  --q->size;

  if (q->size < q->capacity / 2 && q->size >= 16)
    q->data = realloc(q->data, (q->capacity /= 2) * sizeof(void *));
  
}



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
  heapq_t *q = heapq_new(100, compare_wordcount);

  wordcount_t wc0, wc1, wc2;
  wc0.pri = 213;
  wc0.str = "hello";
  wc1.pri = 456;
  wc1.str = "world";
  wc2.pri = 88;
  wc2.str = "test";

  heapq_insert(q,&wc0);
  heapq_insert(q,&wc1);
  heapq_insert(q,&wc2);

  while(!heapq_empty(q)) {
    wordcount_t *wc = heapq_top(q);
    printf("%d %s\n", wc->pri,  wc->str);
    heapq_pop(q);
  }


  return 0;
}
