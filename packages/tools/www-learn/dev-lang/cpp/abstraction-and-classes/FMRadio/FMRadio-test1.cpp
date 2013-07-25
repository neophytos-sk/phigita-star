#include <iostream>
#include "FMRadio.h"

using namespace std;

int main(){
  //FMRadio myRadio(88.5,5);
  FMRadio myRadio;
  myRadio.setFrequency(88.5);
  myRadio.setVolume(8);

  cout << myRadio.getFrequency() << endl;
  cout << myRadio.getVolume() << endl;

  /* ... etc ... */

  return 0;
}
