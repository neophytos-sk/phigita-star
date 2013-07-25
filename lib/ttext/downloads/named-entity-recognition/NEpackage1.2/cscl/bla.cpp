#include "Pr.h"
#include <iostream>

void StateOrder::ReadStateOrder(ifstream &in)
{
  int num;
  char ch;
  State state;

  clear();
//  in >> num >> ch;
  do {
    if (in >> state) { push_back(state); }
    else break; // cannot read anymore.
  } while (in.get() != '\n');
}

void StateOrder::Print() const
{
  const_iterator i;

  for (i = begin(); i != end(); i++)
    cout << *i << endl;
}

void Pr::ReadPrFile(ifstream &in)
{
  State state;
  int count;
  double pr;

  clear();

  // first line is total.
  in >> state >> count >> pr;

  while (in >> state >> count >> pr) {
    (*this)[state] = pr;
  }
}

void Pr::ReadPrSequence(ifstream& in, const StateOrder& stateOrder)
{
  StateOrder::const_iterator i;
  double pr;

  clear();
  i = stateOrder.begin();
  do {
    if ((in >> pr) && (i != stateOrder.end())) (*this)[*i] = pr;
    else break; // cannot read anymore or no more index.
    i++;
  } while (in.get() != '\n');
}

void Pr::Print() const
{
  const_iterator i;

  for (i = begin(); i != end(); i++)
    cout << i->first << '\t' << i->second << endl;
}

void Pr::Normalize()
{
  iterator i;
  double sum = 0;

  for (i = begin(); i != end(); i++)
    sum += i->second;
  for (i = begin(); i != end(); i++)
    i->second /= sum;
}

void PrSS::ReadPrSSFile(ifstream &in)
{
  State state;
  double pr;
  StateOrder stateOrder;
  string temp;

  clear();

  // read state order.
  in >> temp;  // get rid of total;
  stateOrder.ReadStateOrder(in);
//  stateOrder.Print();

  // first line is total.
  getline(in, temp);
  
  while (in >> state >> pr) {  // pr of total
    Pr prMap;
    prMap.ReadPrSequence(in, stateOrder);
//    prMap.Print();
    (*this)[state] = prMap;
  }
}

void PrSS::Print() const
{
  const_iterator i;
  Pr::const_iterator j;

  for (i = begin(); i != end(); i++) {
    cout << i->first;
    for (j = i->second.begin(); j != i->second.end(); j++)
      cout << '\t' << j->second;
    cout << endl;
  }
}

void PrSS::Normalize()
{
  iterator i;

  for (i = begin(); i != end(); i++)
    i->second.Normalize();
}
