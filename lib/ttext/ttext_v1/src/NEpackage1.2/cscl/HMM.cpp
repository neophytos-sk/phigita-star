#include <fstream>
#include <iostream>
#include "Pr.h"
#include "HMMin.h"

void Normalize(StatePrTable& prOi_S, PrSiTable& prSAll);
double Div(double x, double y);

main(int argc, char *argv[])
{
  HMMRestricted hmm;
  PrSiTable     prSAll;

  ifstream prS0f(argv[1]);
  ifstream prSi_Sf(argv[2]);
  ifstream prOi_Sf(argv[3]);
  ifstream allowedEndf(argv[4]);

  if (!(prS0f && prSi_Sf && prOi_Sf && allowedEndf)) {
    cerr << "cannot open some files." << endl;
    exit(1);
  }

  int i;
  char ch;
  if (!(prOi_Sf >> i >> ch)) {
    cerr << "incorrect format in " << argv[4] << endl;
    exit(1);
  }

  hmm.stateOrder.ReadStateOrder(prOi_Sf);
  hmm.GenStateIndex();
  hmm.prS0.ReadPrFile(prS0f);
  hmm.prSi_S.ReadPrSSFile(prSi_Sf);
  hmm.allowedEnd.ReadAllowedState(allowedEndf);
  prSAll.prS0 = hmm.prS0;
  prSAll.prSS = hmm.prSi_S;

  StateSequence answer;
  i = 0;
  while (hmm.ReadOneSequence(prOi_Sf)) {
    Normalize(hmm.prOi_S, prSAll);
//    cout << "PrOi_S" << endl;
//    hmm.prOi_S.Print(hmm.stateOrder);
//    cout << "PrSAll" << endl;
//    prSAll.Print();

    hmm.BestSequence(answer);

    answer.Print();
//    cerr << ++i << endl;
  }
}

void Normalize(StatePrTable& prOi_S, PrSiTable& prSAll)
{
  int T = prOi_S.size();
  int i;
  Pr::iterator j;

  for (i = 0; i < T; i++) {
    for (j = prOi_S[i].begin(); j != prOi_S[i].end(); j++) {
      j->second = Div(j->second, prSAll.Get(i, j->first));
    }
//    prOi_S[i].Normalize();
//    prSAll.Normalize();
  }
}

double Div(double x, double y)
{
  return (y == 0? 0: x/y);
}

/*
void Normalize(StatePrTable& prOi_S, PrSiTable& prSAll)
{
  int T = prOi_S.size() - 1;
  int i;
  Pr::iterator j;

  prSAll.RecalculateUpTo(T);
  for (i = 0; i <= T; i++) {
    for (j = prOi_S[i].begin(); j != prOi_S[i].end(); j++) {
      j->second /= prSAll[i][j->first];
    }
    prOi_S[i].Normalize();
//    prSAll.Normalize();
  }
}
*/
