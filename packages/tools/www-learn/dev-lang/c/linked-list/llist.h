#ifndef LLIST_H
#define LLIST_H

#include <stdlib.h>

#ifndef NULL
#define NULL ((void *) 0)
#endif

typedef struct elementT {
  struct elementT* next;
  void *data;
} element_t;

int CreateList(element_t **head);
int DeleteList(element_t **head);
void ReverseList(element_t **head);
element_t *ConvergenceList(element_t *list1, element_t *list2);
element_t *NthNode(element_t *list, int n);
void SortList(element_t *head);
int Insert(element_t **head, void *data);
int Delete(element_t **head, element_t *deleteme);


#endif
