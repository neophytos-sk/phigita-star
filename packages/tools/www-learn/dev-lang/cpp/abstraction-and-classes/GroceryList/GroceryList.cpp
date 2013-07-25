#include "GroceryList.h"

GroceryList::GroceryList() {
  /* sets the grocery list to contain no items */
  groceries.clear();
}
  
void GroceryList::addItem(string quantity, string item) {
  groceries[item] = quantity;
}

void GroceryList::removeItem(string item) {
  if (itemExists(item))
    groceries.erase(item);
}

string GroceryList::itemQuantity(string item) {
  if (itemExists(item))
    return groceries[item];
}

bool GroceryList::itemExists(string item) {
  return groceries.find(item) != groceries.end();
}
