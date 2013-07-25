#include <stdio.h>


typedef struct nodeT {
  nodeT *next;
  int data;
} node_t;

void reverse_list(node_t **head) {
  node_t *curr = *head;
  node_t *prev = NULL;
  node_t *next = NULL;
  while(curr) {
    *head = curr;
    next = curr->next;
    curr->next = prev;

    prev = curr;
    curr = next;

  }
}
