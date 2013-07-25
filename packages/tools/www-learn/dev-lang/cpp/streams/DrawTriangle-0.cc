#include <iomanip>
#include "simpio.h"

void DrawTriangle(int height, char ch) {
  for (int i=0; i<height; i += 2) {
    cout << setw((height-i)/2) << setfill(' ') << "";
    cout << setw(i+1) << setfill(ch) << "" << '\n';
  }
}

int main() {
  DrawTriangle(GetInteger(),'*');
  return 0;
}
