#include <fstream>
#include <iostream>
#include "Pr.h"
#include "HMMin.h"

main(int argc, char *argv[])
{
  HMMRestricted hmm;

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

  StateSequence answer;
  i = 0;
  while (hmm.ReadOneSequence(prOi_Sf)) {
    hmm.BestSequence(answer);

    answer.Print();
  }
}
