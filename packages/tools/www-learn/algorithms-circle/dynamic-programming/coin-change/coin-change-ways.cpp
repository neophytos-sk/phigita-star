//  Q674: Coin Change
//  2007.11.15     Celia
//  DP(coin), adapted from Q357: Let Me Count The Ways
#include <iostream>          //  Accepted
#include <cstdlib>
#include <stdio.h>
#include <algorithm>
#define N 7489

using namespace std;

typedef long long int64;

int main()
{
    int coin[5] = {50, 25, 10, 5, 1};
    int64 ways[N+1];
    
    fill(ways, ways+N+1, 0);
    ways[0] = 1;
    
    for(int i = 0; i < 5; i++)
        for(int j = coin[i]; j <= N; j++)
            ways[j] += ways[j-coin[i]];
    
    int n;
    
    while(cin >> n)
        cout << ways[n] << endl;
    
    return 0;
}
