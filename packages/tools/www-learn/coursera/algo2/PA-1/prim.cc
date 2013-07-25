#include <iostream>
#include <fstream>
#include <algorithm>
#include <vector>
#include <iterator>
#include <queue>

using namespace std;


struct edge_t {
    int cost;
    int u;
    int v;
};

struct edge_comparator {
    bool operator()(const edge_t& e1, const edge_t& e2) {
        return e1.cost>e2.cost; 
    }
};

int main(int argc, const char **argv) {

    if (argc!=2) {
        cout << "Usage: " << argv[0] << " filename" << endl;
        return 1;
    }
    const char *filename = argv[1];

    cout << "filename=" << filename << endl;

    ifstream infile(filename);

    int n,m, i=0;
    infile >> n >> m;
    cout << "n=" << n << " m=" << m << endl;
    vector<edge_t> edges;
    // priority_queue<edge_t, vector<edge_t>, edge_comparator> edges;
    while (i<m) {
        edge_t edge;
        infile >> edge.u >> edge.v >> edge.cost;
        edges.push_back(edge);
        i++;
    }
    cout << "i=" << i << endl;
    infile.close();


    vector<edge_t> mst;
    int overall_cost=0;
    int visited[n+1];
    for(int i=1; i<=n; i++) visited[i]=0;
    visited[1]=1;
    while(n) {
        vector<edge_t>::const_iterator it = edges.begin();
        vector<edge_t>::const_iterator end = edges.end();
        vector<edge_t>::const_iterator cheapest = end;
        for(; it != end; ++it)
            if ((visited[it->u] && !visited[it->v])
                    || (!visited[it->u] && visited[it->v]))
            if(cheapest == end)
                cheapest = it;
            else if (it->cost < cheapest->cost)
                cheapest = it;

        visited[cheapest->u]=1;
        visited[cheapest->v]=1;
//        mst.push_back(*it);
        overall_cost += cheapest->cost;
        n--;
    }

    cout << "overall cost=" << overall_cost << endl;
    return 0;
}
