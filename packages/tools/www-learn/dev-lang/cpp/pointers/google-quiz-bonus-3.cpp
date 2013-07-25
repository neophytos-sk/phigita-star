#include <iostream>

using namespace std;

const int kNumVeggies = 4;

void Grill(int squash, int *mushroom);
int Saute(int onions[], int celery);

void Grill(int squash, int *mushroom)
{
  *mushroom = squash / 4;
  cout << *mushroom + squash << endl;
}

int Saute(int onions[], int celery) 
{
  celery *= 2;
  onions[celery]++;
  Grill(onions[0], &onions[3]);
  cout << celery << " " << onions[3] << endl;
  return celery;
}

main() {
  int broccoli, peppers[kNumVeggies], *zucchini;

  for(broccoli=0; broccoli<kNumVeggies; broccoli++)
    peppers[broccoli] = kNumVeggies - broccoli;
  zucchini = &peppers[Saute(peppers,1)];
  Grill(*zucchini, zucchini);
  zucchini--;
  cout << peppers[3] + *zucchini + *(zucchini + 1) << endl;
}
