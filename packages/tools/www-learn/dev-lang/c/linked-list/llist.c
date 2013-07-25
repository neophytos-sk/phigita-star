
#include "llist.h"

int CreateList(element_t **head) 
{
  *head = NULL;
  return 1;
}

int DeleteList(element_t **head) 
{
  element_t *next;

  while(*head) {
    next = (*head)->next;
    free(*head);
    *head = next;
  }
  return 1;
}


void ReverseList(element_t **head) {
  if (*head == NULL)
    return;


  element_t *curr = *head;
  element_t *next = NULL;
  element_t *prev = NULL;
  while(curr) {
    *head = curr;
    next = curr->next;
    curr->next = prev;
    prev = curr;
    curr = next;
  }

}

// Returns the common tail between list1 and list2
element_t *ConvergenceList(element_t *list1, element_t *list2) {

  if (!list1 || !list2) 
    return NULL;

  ReverseList(&list1);
  ReverseList(&list2);

  element_t *result;
  CreateList(&result);

  element_t *p1 = list1;
  element_t *p2 = list2;
  while(p1 && p2 && p1->data == p2->data) {
    Insert((element_t **) &result, p1->data);
    p1 = p1->next;
    p2 = p2->next;
  }

  return result;
}

/* an O(n) based algorithm to find the nth node from the end of the linked list */
element_t *NthNode(element_t *head, int n) {
  element_t *p1 = head, *p2 = head;
  int i=0;
  while (p1) {
    p1 = p1->next;
    if (i>=n)
      p2=p2->next;
    i++;
  }
  return i>=n?p2:0;
}


//Assume HEAD pointer denotes the first element in the //linked list
// only change the values...don’t have to change the //pointers
void SortList(element_t *head) {
  element_t *first, *second;
  first = head;
  while(first) {
    second=first;
    while(second) {
      if(first->data < second->data) {
	int temp;
	temp=first->data;
	first->data=second->data;
	second->data=temp;
      }
      second=second->next;
    }
    first=first->next;
  }

}



int Insert(element_t **head, void *data) 
{
  element_t *elem;

  elem = (element_t *) malloc(sizeof(element_t));
  if (!elem)
    return 0;

  elem->data = data;
  elem->next = *head;
  *head = elem;

  return 1;

}
int Delete(element_t **head, element_t *deleteme) 
{
  element_t *elem;

  if (!head)
    return 0;

  if ( (*head) == deleteme ) { // special case for head
    *head = deleteme->next;
    free(deleteme);
    return 0;
  }

  elem = *head;
  while(elem) {
    if (elem->next == deleteme) {
      // elem is element preceding deleteme
      elem->next=deleteme->next;
      free(deleteme);
      return 1;
    }
    elem=elem->next;
  }

  // deleteme not found
  return 0;
}

