#include <fstream>
#include <iostream>
#include <map>
#include "HMMin.h"
#include "Pr.h"

bool StatePrTable::ReadOneSequence(ifstream &in,
                                   const StateOrder& stateOrder)
{
  int t;
  char ch;

  if (in >> t >> ch) {
    clear();
    do {
      if (t > 0) {
        Pr pr;
        pr.ReadPrSequence(in, stateOrder);
        this->push_back(pr);
      } else break;
    } while (in >> t >> ch);
  } else return false;
  return true;
}

void StatePrTable::Print() const
{
  const_iterator i;
  Pr::const_iterator j;
  int a;

  for (a = 1, i = begin(); i != end(); i++, a++) {
    cout << a << ':';
    for (j = i->begin(); j != i->end(); j++)
      cout << '\t' << j->second;
    cout << endl;
  }
}

void StatePrTable::Print(const StateOrder& stateOrder) const
{
  const_iterator i;
  StateOrder::const_iterator j;
  int a;

  for (a = 1, i = begin(); i != end(); i++, a++) {
    cout << a << ':';
    for (j = stateOrder.begin(); j != stateOrder.end(); j++)
      cout << '\t' << i->find(*j)->second;
    cout << endl;
  }
}

void StatePrTable::Normalize()
{
  iterator i;

  for (i = begin(); i != end(); i++)
    i->Normalize();
}

/*void StatePrTable::Normalize(const Pr& s)
{
  iterator i;
  Pr::iterator j;

  for (i = begin(); i != end(); i++) {
    for (j = i->begin(); j != i->end(); j++)
      j->second /= s.find(j->first)->second;
    i->Normalize();
  }
}*/

void PrSiTable::CalculateNext(const int t)
{
  const int prevT = t - 1;
  PrSS::const_iterator prev;
  Pr::const_iterator cur;

  for (prev = prSS.begin(); prev != prSS.end(); prev++) {
    for (cur = prev->second.begin(); cur != prev->second.end(); cur++) {
      if ((*this)[t].find(cur->first) == (*this)[t].end())
        (*this)[t][cur->first] = 0;
      (*this)[t][cur->first] += (*this)[prevT][prev->first]*cur->second;
    }
  }
}

void PrSiTable::CalculateUpTo(const int t)
{
  int i, oldSize, newSize;

  if (t >= size()) {
    if (size() == 0)
      push_back(prS0);
    oldSize = size();
    newSize = t + 1;
    resize(newSize);
    for (i = oldSize; i < newSize; i++)
      CalculateNext(i);
  }
}

void PrSiTable::RecalculateUpTo(const int t)
{
  clear();
  CalculateUpTo(t);
}

Pr& PrSiTable::Get(const int t)
{ 
  if (!Ready(t)) {
    CalculateUpTo(t);
  }
  return (*this)[t];
}

double PrSiTable::Get(const int t, const State& state)
{
  return Get(t)[state];
}

void StateSequence::Print() const
{
  const_iterator i;

  for (i = begin(); i != end(); i++) {
    cout << *i;
    if ((i + 1) != end()) cout << ' ';
  }
  cout << endl;
}

void HMM::AllBestSequence(StatePrTable &delta,
                          InternalSolution &solution)
{
  Pr::iterator i;
  Pr::const_iterator j;
  int T = prOi_S.size();

  delta.clear();
  delta.resize(T);
  solution.clear();
  solution.resize(T);

//  GenStateIndex();

  for (i = prOi_S[0].begin(); i != prOi_S[0].end(); i++) {
    delta[0][i->first] = prS0[i->first]*i->second;
    solution[0][stateIndex[i->first]] = -1;
  }

  State bestState;
  double maxDelta;

  for (int t = 1; t < T; t++) {
    for (i = prOi_S[t].begin(); i != prOi_S[t].end(); i++) {
      double aDelta;
      maxDelta = -1;
      for (j = delta[t - 1].begin(); j != delta[t - 1].end(); j++) {
        aDelta = j->second*prSi_S[j->first][i->first]*i->second;
        if (aDelta > maxDelta) {
          maxDelta = aDelta;
          bestState = j->first;
        }
      }
      delta[t][i->first] = maxDelta;
      solution[t][stateIndex[i->first]] = stateIndex[bestState];
    }
  }
}

double HMM::SolutionToSequence(const StatePrTable& delta,
                               const InternalSolution& solution,
                               StateSequence &ss)
{
  Pr::const_iterator i;
  int T = prOi_S.size();
  State bestState;
  double maxDelta = -1;

  for (i = delta[T - 1].begin(); i != delta[T - 1].end(); i++) {
    if (i->second > maxDelta) {
      maxDelta = i->second;
      bestState = i->first;
    }
  }

  ss.clear();
  ss.insert(ss.begin(), bestState);
  for (int t = T - 1; t > 0; t--) {
    ss.insert(ss.begin(), stateOrder[solution[t].find(stateIndex[bestState])
                                     ->second]);
    bestState = stateOrder[solution[t].find(stateIndex[bestState])->second];
  }
  return maxDelta;
}

double HMM::BestSequence(StateSequence &ss)
{
  StatePrTable delta;
  InternalSolution solution;

  AllBestSequence(delta, solution);
  return SolutionToSequence(delta, solution, ss);
}

bool HMM::ReadOneSequence(ifstream &in)
{
  return prOi_S.ReadOneSequence(in, stateOrder);
}

double HMMRestricted::SolutionToSequence(const StatePrTable& delta,
                                         const InternalSolution& solution,
                                         StateSequence &ss)
{
  Pr::const_iterator i;
  int T = prOi_S.size();
  State bestState;
  double maxDelta = -1;

  for (i = delta[T - 1].begin(); i != delta[T - 1].end(); i++) {
    if (allowedEnd[i->first]) 
      if (i->second > maxDelta) {
        maxDelta = i->second;
        bestState = i->first;
      }
  }

  ss.clear();
  ss.insert(ss.begin(), bestState);
  for (int t = T - 1; t > 0; t--) {
    ss.insert(ss.begin(), stateOrder[solution[t].find(stateIndex[bestState])
                                     ->second]);
    bestState = stateOrder[solution[t].find(stateIndex[bestState])->second];
  }
  return maxDelta;
}

void AllowedState::ReadAllowedState(ifstream &in)
{
  State state;
  bool allowed;

  clear();
  while (in >> state >> allowed)
    (*this)[state] = allowed;
}

void AllowedState::Print() const
{
  const_iterator i;

  for (i = begin(); i != end(); i++)
    cout << i->first << '\t' << i->second << endl;
}
