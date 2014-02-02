#ifndef __HEAPQ_H
#define __HEAPQ_H__

#include <assert.h>
#include "common.h"

typedef struct {
    void **elems;
    int logLength;
    int allocLength;
    int (*cmp)(const void *d1, const void *d2);
} heapq_t;

static inline size_t heapq_left  (size_t x) { return (2 * (x) + 1); }
static inline size_t heapq_right (size_t x) { return (2 * (x) + 2); }
static inline size_t heapq_parent(size_t x) { return ((x) / 2);     }


#define kInitialAllocationSize 4

static inline
void heapq_init(heapq_t *const q, int (*cmp)(const void *elem1, const void *elem2))
{
    q->cmp = cmp;
    q->logLength = 0;
    q->allocLength = kInitialAllocationSize;
    q->elems = ckalloc(kInitialAllocationSize * sizeof(void *));
    assert(q->elems != NULL);
}


static inline
void heapq_free(heapq_t *q)
{
  ckfree(q->elems);
}


static inline
int heapq_empty(const heapq_t *q) 
{
  return !q->logLength;
}


static inline
size_t heapq_size(const heapq_t *q) 
{
  return q->logLength;
}

static inline
void heapq_insert(heapq_t *q, const void *elemPtr)
{
  
  void **b;

  if (q->logLength == q->allocLength) {
    q->allocLength *= 2;
    b = q->elems = ckrealloc((char *) q->elems, q->allocLength * sizeof(void *));
  } else {
    b = q->elems;
  }


  size_t n, m;
  n = q->logLength++;

  /* append at end, then up heap */
  while ((m = heapq_parent(n)) != n && q->cmp(b[m],elemPtr) > 0) {
    b[n] = b[m];
    n = m;
  }
  b[n] = elemPtr;

}


static inline
const void *heapq_top(const heapq_t *q) 
{
  if (heapq_empty(q)) {
    return NULL;
  }
  return q->elems[0];
}


static inline
void heapq_pop(heapq_t *q) 
{
  if (heapq_empty(q)) {
    // error
    return;
  }

  /* pull last item to top, then down heap. */
  --q->logLength;

  int n = 0, m;
  while ((m = heapq_left(n)) < q->logLength) {

    /* if right node is greater than left node then use that one */
    if (m + 1 < q->logLength && q->cmp(q->elems[m], q->elems[m + 1]) > 0) m++;
    
    if (q->cmp(q->elems[n], q->elems[m]) > 0) break;
    q->elems[n] = q->elems[m];
    n = m;
  }
 
  q->elems[n] = q->elems[q->logLength];

  if (q->logLength < q->allocLength / 2 && q->logLength >= 16)
    q->elems = ckrealloc(q->elems, (q->allocLength /= 2) * sizeof(void *));
  
}


/* remove lowest priority item */
static inline
void heapq_pop_back(heapq_t *q) 
{
  if (heapq_empty(q)) {
    // error
    return;
  }

  /* pull last item from back */
  --q->logLength;

  if (q->logLength < q->allocLength / 2 && q->logLength >= 16)
    q->elems = ckrealloc(q->elems, (q->allocLength /= 2) * sizeof(void *));
  
}

#endif
