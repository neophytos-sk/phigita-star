#include <stdio.h>
#include <stdlib.h>

typedef struct nodeT {
  struct nodeT *next;
  int value;
} node_t;

void create_list(node_t **head) {
  *head=NULL;
}

node_t *new_node() {
  node_t * node=malloc(sizeof(node_t));
  node->next = NULL;
  return node;
}


void insert(node_t **head, int value) {
  node_t *node = (node_t *) new_node();
  node->value = value;
  node->next  = *head;
  *head = node;
}

node_t *find(node_t *head, int value) {
  node_t *curr = head;
  while(curr) {
    if (curr->value==value)
      return curr;
    curr=curr->next;
  }
  return NULL;
}

void delete(node_t **head, node_t *node) {

  if (*head==node) {
    *head=node->next;
    free(node);
  } else {
    node_t *curr = *head;
    while(curr && curr->next != node)
      curr=curr->next;

    if (curr->next == node) {
      curr->next = node->next;
      free(node);
    }

  }


}

void reverse_list(node_t **head) {
  node_t *prev = NULL;
  node_t *curr = *head;
  node_t *next = NULL;
  while(curr) {
    *head = curr;
    next = curr->next;
    curr->next = prev;
    prev=curr;
    curr=next;
  }


}

node_t *convergence_node(node_t *head1, node_t *head2) {

  reverse_list(&head1);
  print_list(head1);

  reverse_list(&head2);
  print_list(head2);

  node_t *curr1 = head1;
  node_t *curr2 = head2;

  node_t *convergence_node=NULL;
  while(curr1 && curr2 && curr1->value==curr2->value) {
    convergence_node=curr1;
    curr1=curr1->next;
    curr2=curr2->next;
  }

  return convergence_node;

}

void print_list(node_t *head) {
  node_t *curr=head;
  while(curr)
    printf("%2d ",curr->value), curr=curr->next;

  printf("\n");

}

int main() {


  node_t *linked_list;
  create_list(&linked_list);
  insert(&linked_list,5);
  insert(&linked_list,17);
  insert(&linked_list,1);
  insert(&linked_list,9);
  insert(&linked_list,22);
  insert(&linked_list,35);
  delete(&linked_list,find(linked_list,9));
  print_list(linked_list);
  reverse_list(&linked_list);
  print_list(linked_list);
  printf("-----------\n");

  node_t *linked_list2;
  create_list(&linked_list2);
  insert(&linked_list2,35);
  insert(&linked_list2,22);
  insert(&linked_list2,1);
  insert(&linked_list2,58);
  insert(&linked_list2,69);
  insert(&linked_list2,84);
  insert(&linked_list2,45);
  printf("-----------\n");
  node_t *node=convergence_node(linked_list,linked_list2);
  printf("convergence node=%d\n",node->value);

  return 0;

}
