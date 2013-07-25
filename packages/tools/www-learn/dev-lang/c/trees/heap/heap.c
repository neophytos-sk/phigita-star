#include <stdio.h>
#include <stdlib.h>

typedef struct heapT {
  int n;
  int allocsize;
  int *elements;
} heap_t;


#define PARENT_OF(x) ((x) >> 1)


inline void swap(int *x, int *y)
{
  int temp = *x;
  *x = *y;
  *y = temp;
}

heap_t *MakeHeap(int allocsize)
{
  heap_t *heap = (heap_t *) malloc(sizeof(heap_t));
  heap->elements = (int *) malloc(allocsize * sizeof(int));
  heap->n = 0;
  heap->allocsize=allocsize;
  return heap;
}

void Insert(heap_t *heap, int value)
{
  heap->elements[heap->n]=value;
  // siftup
  int child = heap->n;
  int parent = PARENT_OF(child);
  while(heap->elements[parent] < heap->elements[child] && parent>=0) {
    swap(&heap->elements[parent], &heap->elements[child]);
    child = parent;
    parent = PARENT_OF(parent);
  }
  heap->n++;
}

int ExtractMax(heap_t *heap)
{
  int result = heap->elements[0];
  heap->elements[0] = 0;
  // siftdown
  int child = 1;
  int parent = 0;
  while(heap->elements[parent] < heap->elements[child] && child < heap->n) {
    if (heap->elements[child]<heap->elements[child+1])
      child = child+1;
    swap(&heap->elements[parent],&heap->elements[child]);
    parent = child;
    child = 2*child;
  }
  heap->n--;
  return result;
}

void PrintHeap(heap_t *heap)
{
  int i;
  for(i=0;i<heap->n;++i)
    printf("%d ",heap->elements[i]);
  printf("\n");
}

int main(int argc, char *argv[])
{
  heap_t *heap = MakeHeap(100);
  Insert(heap,137);
  Insert(heap,279);
  Insert(heap,34);
  Insert(heap,57);
  Insert(heap,88);
  Insert(heap,99);
  PrintHeap(heap);
  return;
  int i;
  while(heap->n)
    printf("%d ", ExtractMax(heap));

  free(heap);
  return 0;
}
