#include <iostream>

using namespace std;


struct node {
  node(int v, node *n) : value(v), next(n) {}
  int value;
  node *next;
};

class linked_list {
public:
  linked_list() : head_(NULL) {}
  void insert(int value) {
    node *n = new node(value,head_);
    head_ = n;
  }
  void print() {
    node *curr = head_;
    while(curr) {
      cout << curr->value << " ";
      curr=curr->next;
    }
    cout << endl;
  }
  void reverse() {
    node *curr=head_;
    node *prev=NULL;
    node *next=NULL;
    while(curr) {
      head_=curr;
      next=curr->next;
      curr->next = prev;
      prev=curr;
      curr=next;
    }
  }
  void sort() {
    // bubble sort
    node *first = head_;
    node *second;
    while(first) {
      second = first;

      while(second) {
	if (first->value > second->value)
	  swap(first->value,second->value);

	second = second->next;
      }

      first = first->next;
    }
    
  }
private:
  node *head_;
};


int main() {

  linked_list l;
  l.insert(5);
  l.insert(17);
  l.insert(20);
  l.insert(8);
  l.print();
  cout << "------------" << endl;
  l.reverse();
  l.print();
  cout << "------------" << endl;
  l.sort();
  l.print();

  return 0;
}
