#ifndef __GRAPH_H__
#define __GRAPH_H__

using namespace std;

#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <map>

const double INF = 100000.0;
const long NIL = -2;

//const long MAXNODES = 20000;
//typedef long bool;
//const long true = 1;
//const long false = 0;

typedef map<long,double>            DoubleSparseArray;
typedef map<long,DoubleSparseArray> DoubleSparseArray2;
typedef map<long,long>              LongSparseArray;
typedef map<long,bool>              BoolSparseArray;

class Graph {
//	long num_nodes;
	BoolSparseArray    list;  // list of all nodes.
	DoubleSparseArray2 matrix;



public:
	Graph();
	Graph(long n);
	void Print(void) const;
	void Clear(void);
	void Initialize(long n);
	void AddEdge(long from, long to, double cost);
	void SetEdgeCost(long from, long to, double cost);
	double l(long from, long to) const;
	void Initialize_Single_Source (long s, DoubleSparseArray& D,
         LongSparseArray& P);
	long DAG_Short_Path(long from, long to, long path[], double &length);
   void Relax(long u, long v, LongSparseArray& P, DoubleSparseArray& D);
};


inline Graph::Graph(void){
//	num_nodes = 0;
}

inline Graph::Graph(long n){
//	num_nodes = n;
}

#endif
