#include <stdio.h>
#include <stdlib.h>
#include "llist.h"



int FindConvergence(const element_t *head1, const element_t *head2) {

  if (!head1 && !head2) {
    return NULL;
  } else if (!head1 && head2) {
    return FindConvergence(head1, head2->next);
  } else if (head1 && !head2) {
    return FindConvergence(head1->next, head2);
  } else {
    int result = FindConvergence(head1->next, head2->next);
    if (head1->data == head2->data ) {
      return result + 1;
    } else {
      printf("Result: %d\n",result);
      exit(-1);
    }
  }
}


int main(int argc, char *argv[]) {

  element_t *list1, *list2;
  
  CreateList(&list1);
  CreateList(&list2);


  Insert(&list1,(int) 10);
  Insert(&list1,(int) 9);
  Insert(&list1,(int) 8);
  Insert(&list1,(int) 7);
  Insert(&list1,(int) 6);
  Insert(&list1,(int) 5);
  Insert(&list1,(int) 4);
  Insert(&list1,(int) 3);
  Insert(&list1,(int) 2);
  Insert(&list1,(int) 1);

  Insert(&list2,(int) 10);
  Insert(&list2,(int) 9);
  Insert(&list2,(int) 8);
  Insert(&list2,(int) 2);
  Insert(&list2,(int) 2);
  Insert(&list2,(int) 2);

  //element_t *result = FindConvergence(list1, list2);
  //int result = FindConvergence(list1, list2);

  //printf("Convergence: %d\n",(int) result->data);
  //printf("%d",result);


  element_t *list3 = ConvergenceList(list1,list2);

  printf("Convergence List: ");
  const element_t *p3 = list3;
  while (p3) {
    printf(" %d ", (int) p3->data);
    p3 = p3->next;
  }
  printf("\n");

  DeleteList(&list3);
  DeleteList(&list2);
  DeleteList(&list1);
  return 0;
}
