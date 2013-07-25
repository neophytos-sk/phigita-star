#ifndef _PR_H_
#define _PR_H_

using namespace std;
#include <fstream>
#include <string>
#include <map>
#include <vector>

typedef string State;
typedef map<State, double> PrMap;
typedef vector<State> StateVector;

class StateOrder: public StateVector {
public:
  void ReadStateOrder(ifstream &in);
  void Print() const;
};

class Pr: public PrMap {
public:
  void ReadPrFile(ifstream &in);
  void ReadPrSequence(ifstream &in, const StateOrder& stateOrder);
  void Print() const;
  void Normalize();
};

typedef map<State, Pr> PrMapMap;

class PrSS: public PrMapMap {
public:
  void ReadPrSSFile(ifstream &in);
  void Print() const;
  void Normalize();
};

#endif
