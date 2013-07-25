#ifndef _HMM_IN_H_
#define _HMM_IN_H_

#include <fstream>
#include <vector>
#include "Pr.h"

typedef vector<Pr> PrMapVector;

class StatePrTable: public PrMapVector {
public:
  bool ReadOneSequence(ifstream &in, const StateOrder& stateOrder);
  void Print() const;
  void Print(const StateOrder& stateOrder) const;
  void Normalize();
//  void Normalize(const Pr& s);  // to compute Pr(O|S) = Pr(S|O)P(O)/P(S)
};

class PrSiTable: public StatePrTable {
private:
  void CalculateNext(const int t);

public:
  int LastT();
  bool Ready(const int t);
  void CalculateUpTo(const int t);
  void RecalculateUpTo(const int t);
  Pr& Get(const int t);
  double Get(const int t, const State& state);

  Pr    prS0;
  PrSS  prSS;
};

typedef vector<State> StateVector;
class StateSequence: public StateVector {
public:
  void Print() const;
};

typedef int NumState;
typedef map<State, NumState> StateIndex;

typedef vector < map < NumState, NumState > > InternalSolution;

class HMM {
protected:
  void AllBestSequence(StatePrTable &delta, InternalSolution &solution);
  virtual double SolutionToSequence(const StatePrTable& delta,
                                    const InternalSolution& solution,
                                    StateSequence &ss);

  StateIndex stateIndex;

public:
  double BestSequence(StateSequence &ss);
  bool ReadOneSequence(ifstream &in);
  void GenStateIndex();  // don't forget to call this after update stateorder.

  StateOrder    stateOrder;
  Pr            prS0;
  PrSS          prSi_S;
  StatePrTable  prOi_S;
};

typedef map<State, bool> StateBoolMap;
class AllowedState: public StateBoolMap {
public:
  void ReadAllowedState(ifstream &in);
  void Print() const;
};

class HMMRestricted: public HMM {
protected:
  double SolutionToSequence(const StatePrTable& delta,
                            const InternalSolution& solution,
                            StateSequence &ss);
public:
  AllowedState allowedEnd;
};


inline int PrSiTable::LastT()
{
  return size() - 1;
}

inline bool PrSiTable::Ready(int t)
{
  return ((t >= 0) && (t < size()));
}

inline void HMM::GenStateIndex()
{
  int i;

  stateIndex.clear();
  for (i = 0; i < stateOrder.size(); i++)
    stateIndex[stateOrder[i]] = i;
}

#endif
