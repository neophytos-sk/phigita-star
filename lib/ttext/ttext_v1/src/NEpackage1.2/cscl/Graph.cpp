#include <cstdio>
#include <cstdlib>
#include <iostream>
#include "Graph.h"

void Graph::Initialize_Single_Source (long s, DoubleSparseArray& D,
      LongSparseArray& P)
{
   BoolSparseArray::const_iterator i;
   for (i = list.begin(); i != list.end(); i++){
      P[i->first] = NIL;
   }
   D[s] = 0.0;
}

void Graph::Relax (long u, long v, LongSparseArray& P, DoubleSparseArray& D)
{
   DoubleSparseArray::iterator i_u,i_v,m_v;
   DoubleSparseArray2::iterator m_u;

   if ((i_u = D.find(u)) != D.end()) { // D[u] != INF
      if ((m_u = matrix.find(u)) != matrix.end()) { // matrix[u][v] != INF
        if ((m_v = (m_u->second).find(v)) != (m_u->second).end()) {
           if ((i_v = D.find(v)) == D.end()) { // D[v] == INF
              D[v] = i_u->second + m_v->second;
              P[v] = u;
           } else if (i_v->second > (i_u->second + m_v->second)) {
              i_v->second = i_u->second + m_v->second;
              P[v] = u;
           }
        }
      }
   }
}

long Graph::DAG_Short_Path(long from, long to, long path[], double &length)
{
  LongSparseArray parents;
  DoubleSparseArray D;
 
  Initialize_Single_Source(from, D, parents);

  DoubleSparseArray2::const_iterator u;
  DoubleSparseArray::const_iterator v;

  for (u = matrix.begin(); u != matrix.end(); u++) {
    for (v = (u->second).begin(); v != (u->second).end(); v++){
      Relax (u->first, v->first, parents, D);
    }
  }

  long num_in_path = 0;
  path[num_in_path++] = to;
  long current_node = to;
  while (current_node != from){
    current_node = parents[current_node];
    path[num_in_path++] = current_node;
  }
  
  path[num_in_path] = -1;
 
  if (D.find(to) != D.end())
     length = D[to];
  else
     length = INF;
  //  cout << "\nDijkstraValue = " << D[to] << "\n";
  return num_in_path;
}

double Graph::l(long from, long to) const
{
   double len = INF;
   DoubleSparseArray2::const_iterator i;
   DoubleSparseArray::const_iterator j;
   if ((i = matrix.find(from)) != matrix.end())
      if ((j = (i->second).find(to)) != (i->second).end())
         len = j->second;
   return len;
}

void Graph::Print(void) const
{
   DoubleSparseArray2::const_iterator i;
   DoubleSparseArray::const_iterator j;

	cout << "\nMatrix\n" << endl;

	for (i = matrix.begin(); i != matrix.end(); i++){
		cout << i->first << ": " ;
		for (j = (i->second).begin();  j != (i->second).end(); j++)
			cout << j->first << "(" << j->second << ") ";
      cout << endl;
	}
}


void Graph::Clear(void)
{
//	num_nodes = 0;
   matrix.clear();
   list.clear();
}

void Graph::Initialize(long n)
{
	Clear();
//	num_nodes = n;
}

void Graph::AddEdge(long from, long to, double cost)
{
	matrix[from][to] = cost;
   list[from] = true; list[to] = true;  // add from and to to the list.
}
	
void Graph::SetEdgeCost(long from, long to, double cost)
{
	matrix[from][to] = cost;
   list[from] = true; list[to] = true;  // add from and to to the list.
}

