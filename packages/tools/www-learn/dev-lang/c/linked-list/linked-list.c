#include <stdlib.h>
#include <stdio.h>

#ifndef NULL
#define NULL ((void *) 0)
#endif

typedef struct elementT {
  struct elementT *next;
  int data;
} element_t;


int CreateList(element_t **head) {
  *head=NULL;
  return 1;
}

int InsertElement(element_t **head,int data) {
  element_t *node = (element_t *)malloc(sizeof(element_t));
  if (!node) {
    return 0;
  }
  node->data = data;
  node->next = *head;
  *head = node;
  return 1;
}

element_t *FindElement(element_t *head,int data) {
  element_t *curr = head;
  while (curr) {
    if (curr->data == data) {
      return curr;
    }
    curr = curr->next;
  }
  return NULL;
}


element_t *DeleteElement(element_t **head, element_t *todeleteEl) {

  if (*head && *head == todeleteEl) {
    *head=(*head)->next;
    free(todeleteEl);
  }

  element_t *curr = *head;
  while(curr && curr->next != todeleteEl) {
    curr = curr->next;
  }

  if (curr && curr->next == todeleteEl) {
    curr->next = curr->next->next;
    free(todeleteEl);
  }

}

void PrintList(element_t *head) {
  printf("---------------\n");
  element_t *curr = head;
  while(curr) {
    printf("%d\n",curr->data);
    curr=curr->next;
  }
}

void ReverseList(element_t **head) {
  element_t *curr = *head;
  element_t *prev = NULL;
  element_t *next = NULL;
  while (curr) {
    *head = curr;
    next = curr->next;
    curr->next = prev;
    prev = curr;
    curr = next;
  }
}


int main(int argc, char *argv[]) {
  element_t *mylist;
  CreateList(&mylist);
  InsertElement(&mylist, 12);
  InsertElement(&mylist, 5);
  InsertElement(&mylist, 7);
  InsertElement(&mylist, 3);
  element_t *el;
  el = FindElement(mylist,7);
  printf("%d\n",el->data);

  PrintList(mylist);
  ReverseList(&mylist);
  PrintList(mylist);

  DeleteElement(&mylist, el);
  DeleteElement(&mylist, FindElement(mylist,3));
  PrintList(mylist);


  return 0;
}
