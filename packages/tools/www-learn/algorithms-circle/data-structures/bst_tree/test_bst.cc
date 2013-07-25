#include "bst_tree.h"

#include <iostream>

int main() {
  bst_tree<int> mytree;
  mytree.insert(5);
  mytree.insert(4);
  mytree.insert(17);
  mytree.insert(63);
  mytree.insert(9);
  std:: cout << mytree.find(17)->get_data() << '\n';
  return 0;
}
