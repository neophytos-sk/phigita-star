#include "KenoGame.h"

#include <iostream>

KenoGame::KenoGame() {
  srand(time(NULL));
}

bool KenoGame::isValidNumber(int number) {
  assert(number >= 1 && number <= 80);
  return true;
}

bool KenoGame::canChooseMore() {
  assert(numChosen() <=20);
  return true;
}

void KenoGame::addNumber(int number) {
  if (isValidNumber(number) && canChooseMore()) {
    myValues.push_back(number);
  }
}

size_t KenoGame::numChosen() {
  return myValues.size();
}

int KenoGame::randomNumber(int from, int to) {
  return static_cast<int>( from +  rand() % (to-from+1)  );
}

size_t KenoGame::numWinners(vector<int>& values) {
  int num;
  size_t count=0;
  for(int i=0; i<20;++i) {
    num = randomNumber(1,80);
    cout << num << endl;

    if (isValidNumber(num)) {
      if (find(myValues.begin(),myValues.end(),num) != myValues.end()) {
	values.push_back(num);
	++count;
      }
    }
  }
  return count;
}
