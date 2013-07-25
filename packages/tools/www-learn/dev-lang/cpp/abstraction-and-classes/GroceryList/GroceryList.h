#ifndef GroceryList_H
#define GroceryList_H

#include <string>
#include <map>

using namespace std;

class GroceryList {
 public:
  GroceryList();
  
  void addItem(string quantity, string item);
  void removeItem(string item);

  string itemQuantity(string item);
  bool itemExists(string item);
 private:
  map<string,string> groceries;
};


#endif
