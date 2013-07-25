#include <fstream>
#include <iostream>
#include <map>
#include "DAVComb.h"
#include "HMMin.h"
#include "Pr.h"
#include "Graph.h"

#define MINUS_INFINITY -10000

double DAVComb::BestSequence(StateSequence &ss)
{
  long path[prS_Oi.size() + 3];

  combineGraph.Initialize(prS_Oi.size()*stateOrder.size() + 2);
//  cout << "long:" << prS_Oi.size() << endl;

  StatePrTable::iterator i, j;
  Pr::const_iterator k, l;
  State oc, phr;
  int a, b;
  const int source = 0, sink = prS_Oi.size()*stateOrder.size() + 1;
  combineGraph.AddEdge(source, sink, 0);
  for (a = 1, i = prS_Oi.begin(); i != prS_Oi.end(); a += 2*stateOrder.size(), i += 2)
    for (k = i->begin(); k != i->end(); k++) {
      StateExtract(k->first, oc, phr);
      if (IsOpen(oc) && IsOpen(*i, phr)) {
        combineGraph.AddEdge(source, a + stateIndex[k->first], 0);
//        cout << "add" << source << "," << a + stateIndex[k->first] << "(" << k->first << ")" << endl;
        for (b = a + stateOrder.size(), j = i; j != prS_Oi.end(); b += 2*stateOrder.size(), j++) {
          j++;
          if (IsClose(*j, phr)) {
            if (IsPhrase(*i, *j, phr)) {
              State c = StateCombine("C", phr);
              double act = (*i)[k->first]*(*j)[c];
              combineGraph.AddEdge(a + stateIndex[k->first], b + stateIndex[c], -act);
//              cout << "add" << a + stateIndex[k->first] << "(" << k->first << ")" << "," << b + stateIndex[c] << "(" << c << ")" << ":" << -act << endl;
            }
          }
        }
      }
    }
  for (b = stateOrder.size() + 1, j = prS_Oi.begin(); j != prS_Oi.end(); b += 2*stateOrder.size(), j++) {
    j++;
    for (l = j->begin(); l != j->end(); l++) {
      StateExtract(l->first, oc, phr);
      if (IsClose(oc) && IsClose(*j, phr)) {
        combineGraph.AddEdge(b + stateIndex[l->first], sink, 0);
//        cout << "add" << b + stateIndex[l->first] << "(" << l->first << ")" << "," << sink << endl;
        for (a = b + stateOrder.size(), i = j + 1; i != prS_Oi.end(); a += 2*stateOrder.size(), i += 2)
          for (k = i->begin(); k != i->end(); k++) {
            StateExtract(k->first, oc, phr);
            if (IsOpen(oc) && IsOpen(*i, phr)) {
              combineGraph.AddEdge(b + stateIndex[l->first], a + stateIndex[k->first], 0);
//              cout << "add" << b + stateIndex[l->first] << "(" << l->first << ")" << "," << a + stateIndex[k->first] << "(" << k->first << ")" << endl;
            }
          }
      }
    }
  }

  double cost;
  long num = combineGraph.DAG_Short_Path(source, sink, path, cost);

//  cout << "found" << num << endl;

  ss.clear();

  long m, n;

//  for (m = num; m >= 0; m--)
//    cout << path[m] << ' ';
//  cout << endl;
  for (n = 2*stateOrder.size(); n < path[num - 2]; n += 2*stateOrder.size()) {
    ss.push_back("nOo");
    ss.push_back("nCo");
  }
  for (m = num - 2; m >= 2; m -= 2) {
    ss.push_back(stateOrder[(path[m] - 1)%stateOrder.size()]);
    StateExtract(stateOrder[(path[m] - 1)%stateOrder.size()], oc, phr);
    for (n = (int((path[m] - 1)/(2*stateOrder.size())) + 1)*2*stateOrder.size(); n < path[m - 1]; n += 2*stateOrder.size()) {
      ss.push_back(StateCombine("nCi", phr));
      ss.push_back(StateCombine("nOi", phr));
    }
    ss.push_back(stateOrder[(path[m - 1] - 1)%stateOrder.size()]);
    for (n = (int((path[m - 1] - 1)/(2*stateOrder.size())) + 2)*2*stateOrder.size(); n < path[m - 2]; n += 2*stateOrder.size()) {
      ss.push_back("nOo");
      ss.push_back("nCo");
    }
  }

  return -cost;
}

bool DAVComb::ReadOneSequence(ifstream &in)
{
  return prS_Oi.ReadOneSequence(in, stateOrder);
}

/*
double DAVComb::BestSequence(StateSequence &ss)
{
  long path[prS_Oi.size() + 3];

  combineGraph.Initialize(prS_Oi.size() + 2);
//  cout << "long:" << prS_Oi.size() << endl;

  StatePrTable::iterator i, j;
  int a, b;
  const int source = 0, sink = prS_Oi.size() + 1;
  combineGraph.AddEdge(source, sink, 0);
  for (a = 1, i = prS_Oi.begin(); i != prS_Oi.end(); a++, i++)
    if (IsOpen(*i)) {
      combineGraph.AddEdge(source, a, 0);
//      cout << "add" << source << "," << a << endl;
      for (b = a + 1, j = i + 1; j != prS_Oi.end(); b++, j++)
        if (IsClose(*j)) {
          double act = (*i)["O"]*(*j)["C"];
          combineGraph.AddEdge(a, b, -act);
//          cout << "add" << a << "," << b << ":" << -act << endl;
        }
    }
  for (b = 1, j = prS_Oi.begin(); j != prS_Oi.end(); b++, j++)
    if (IsClose(*j)) {
      combineGraph.AddEdge(b, sink, 0);
//      cout << "add" << b << "," << sink << endl;
      for (a = b + 1, i = j + 1; i != prS_Oi.end(); a++, i++)
        if (IsOpen(*i)) {
          combineGraph.AddEdge(b, a, 0);
//          cout << "add" << b << "," << a << endl;
        }
    }

  double cost;
  int num = combineGraph.DAG_Short_Path(source, sink, path, cost);

//  cout << "found" << num << endl;

  ss.clear();

  int k, l;

//  for (k = num; k >= 0; k--)
//    cout << path[k] << ' ';
//  cout << endl;
  for (l = 1; l < path[num - 2]; l += 2) {
    ss.push_back("nOo");
    ss.push_back("nCo");
  }
  for (k = num - 2; k >= 2; k -= 2) {
    ss.push_back("O");
    for (l = path[k] + 1; l < path[k - 1]; l += 2) {
      ss.push_back("nCi");
      ss.push_back("nOi");
    }
    ss.push_back("C");
    for (l = path[k - 1] + 1; l < path[k - 2]; l += 2) {
      ss.push_back("nOo");
      ss.push_back("nCo");
    }
  }

  return -cost;
}
*/

