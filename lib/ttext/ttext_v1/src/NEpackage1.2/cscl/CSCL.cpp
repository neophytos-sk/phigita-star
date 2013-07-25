#include <fstream>
#include <iostream>
#include "Pr.h"
#include "HMMin.h"
#include "DAVComb.h"
#include "Graph.h"

Graph        *graph = new(Graph);
DAVComb      comb(*graph);

main(int argc, char *argv[])
{
  StatePrTable prS_Oi;

  ifstream prS_Oif(argv[1]);

  if (!(prS_Oif)) {
    cerr << "cannot open some files." << endl;
    exit(1);
  }

  int i;
  char ch;
  if (!(prS_Oif >> i >> ch)) {
    cerr << "incorrect format in " << argv[1] << endl;
    exit(1);
  }

  comb.stateOrder.ReadStateOrder(prS_Oif);
  comb.GenStateIndex();
  comb.openThreshold = atof(argv[2]);
  comb.closeThreshold = atof(argv[3]);
  if (argc > 4)
    comb.phraseThreshold = atof(argv[4]);
  else
    comb.phraseThreshold = -1.0;

  bool normalizeIt = true;

  if (argc > 5)
    if (atoi(argv[5]) < 0)
      normalizeIt = false;

  StateSequence answer;
  i = 0;
  while (comb.ReadOneSequence(prS_Oif)) {
    if (normalizeIt)
      comb.prS_Oi.Normalize();
  
    comb.BestSequence(answer);

    answer.Print();
//    cerr << ++i << endl;
  }
}
