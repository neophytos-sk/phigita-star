#include <stdio.h>

#include "llist.h"

void PrintNode(element_t *elem) {
  if (!elem) return;
  printf("%d\n",(int) elem->data);
}

void PrintList(element_t *head) {
  element_t *elem = head;
  while(elem) {
    PrintNode(elem);
    elem=elem->next;
  }
}


int main(int argc, char *argv[]) 
{
  element_t *list;  
  int i;

  CreateList(&list);

  for(i=1;i<argc;++i)
    Insert(&list,(int) atoi(argv[i]));
  
  printf("SortList:\n");
  SortList(list);
  PrintList(list);
  
  printf("ReverseList:\n");
  ReverseList(&list);
  PrintList(list);


  printf("NthNode (where n=%d) is:\n",argc/2);
  PrintNode(NthNode(list,argc/2));

  DeleteList(&list);
  return 0;
}
