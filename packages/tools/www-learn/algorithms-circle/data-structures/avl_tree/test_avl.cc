#include "avl_tree.h"

#include <iostream>

int main() {
  avl_tree<int> mytree;
  mytree.insert(5);
  mytree.insert(4);
  mytree.insert(17);
  mytree.insert(63);
  mytree.insert(9);

  for (int i=10;i<30;++i) {
    printf("----(i=%d)-----\n",i);
    mytree.insert(i);
  }

  std::cout << "pointer of node with data=17 is: " << mytree.find(17) << '\n';
  std:: cout << mytree.find(17)->get_data() << '\n';

  //mytree.find(5)->print();
  return 0;
}
