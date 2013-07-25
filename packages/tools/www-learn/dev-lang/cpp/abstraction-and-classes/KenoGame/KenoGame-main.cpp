#include <iostream>
#include <algorithm>
#include <iterator>

#include "KenoGame.h"

using namespace std;

int main() {
  
  KenoGame game;

  game.addNumber(12);
  game.addNumber(56);
  game.addNumber(73);

  vector<int> values;
  game.numWinners(values);
  copy(values.begin(), values.end(), ostream_iterator<int>(cout,"\n"));


  return 0;
}
