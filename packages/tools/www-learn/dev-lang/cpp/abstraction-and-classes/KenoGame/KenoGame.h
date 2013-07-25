#ifndef KenoGame_H
#define KenoGame_H

#include <assert.h>
#include <ctime>
#include <cstdlib>
#include <vector>
#include <algorithm>

using namespace std;

class KenoGame {
 public:
  KenoGame();
  void addNumber(int number);
  size_t numChosen();
  size_t numWinners(vector<int>& values);
 private:
  int randomNumber(int from,int to);
  bool canChooseMore();
  bool isValidNumber(int number);

  vector<int> myValues;
};

#endif
