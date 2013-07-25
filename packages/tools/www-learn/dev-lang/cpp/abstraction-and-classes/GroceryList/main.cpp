#include <iostream>
#include "GroceryList.h"


using namespace std;

int main(){
  GroceryList gList;

  gList.addItem("One Gallon","Milk");
  cout << boolalpha << gList.itemExists("Milk") << noboolalpha << endl;
  cout << boolalpha << gList.itemExists("Red Bull") << noboolalpha << endl;
  gList.removeItem("Milk");
  cout << boolalpha << gList.itemExists("Milk") << noboolalpha << endl;

  return 0;
}
