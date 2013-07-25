#ifndef _DAV_COMB_H_
#define _DAV_COMB_H_

#include <fstream>
#include <vector>
#include "Pr.h"
#include "HMMin.h"
#include "Graph.h"

typedef State PhraseType;
typedef State OCTag;

class DAVComb {
private:
  Graph& combineGraph;

protected:
  StateIndex stateIndex;

public:
  DAVComb(Graph& graph): combineGraph(graph) {};
  double BestSequence(StateSequence &ss);
  bool ReadOneSequence(ifstream &in);
  void GenStateIndex();  // don't forget to call this after update stateorder.

  //bool IsOpen(const Pr& pr) const;
  bool IsOpen(const Pr& pr, const PhraseType phr = "") const;
  bool IsOpen(const OCTag& oc) const { return (oc == "O"); };
  //bool IsClose(const Pr& pr) const;
  bool IsClose(const Pr& pr, const PhraseType phr = "") const;
  bool IsClose(const OCTag& oc) const { return (oc == "C"); };
  bool IsPhrase(const Pr& prO, const Pr& prC, const PhraseType phr = "") const;

  StateOrder    stateOrder;
  double        openThreshold;
  double        closeThreshold;
  double        phraseThreshold;
  StatePrTable  prS_Oi;
};

inline void DAVComb::GenStateIndex()
{
  int i;

  stateIndex.clear();
  for (i = 0; i < stateOrder.size(); i++)
    stateIndex[stateOrder[i]] = i;
}

void StateExtract(const State s, OCTag& oc, PhraseType& phr);
State StateCombine(const OCTag oc, const PhraseType phr);
bool IsOpen(const OCTag& oc);
bool IsClose(const OCTag& oc);

inline bool DAVComb::IsOpen(const Pr& pr, const PhraseType phr) const
{
  return (pr.find(StateCombine("O", phr))->second > openThreshold);
}

inline bool DAVComb::IsClose(const Pr& pr, const PhraseType phr) const
{
  return (pr.find(StateCombine("C", phr))->second > closeThreshold);
}

inline bool DAVComb::IsPhrase(const Pr& prO, const Pr& prC, const PhraseType phr) const
{
  return (prO.find(StateCombine("O", phr))->second
         * prC.find(StateCombine("C", phr))->second
         > phraseThreshold);
}

inline bool IsOpen(const OCTag& oc)
{
  return (oc == "O");
}

inline bool IsClose(const OCTag& oc)
{
  return (oc == "C");
}

/*
inline bool DAVComb::IsOpen(const Pr& pr) const
{
  return (pr.find("O")->second > openThreshold);
}

inline bool DAVComb::IsClose(const Pr& pr) const
{
  return (pr.find("C")->second > closeThreshold);
}
*/

inline void StateExtract(const State s, OCTag& oc, PhraseType& phr)
{
  int sep = s.find("-");

  if (sep != string::npos) {
    oc = s.substr(0, sep);
    phr = (s.length() > (sep + 1)? s.substr(sep + 1): "");
  } else {
    oc = s;
    phr = "";
  }
}

inline State StateCombine(const OCTag oc, const PhraseType phr)
{
  return (phr != ""? oc + "-" + phr: oc);
}

#endif
