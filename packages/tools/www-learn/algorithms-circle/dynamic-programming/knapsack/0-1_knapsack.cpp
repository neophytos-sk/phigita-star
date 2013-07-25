

//  0-1 Knapsack Problem
//  2008.03.25     Celia
//  Method: Dynamic Programming
#include <iostream>
#include <cstdlib>

using namespace std;

int main()
{
    int n;                   //  number of items
    while(cin >> n)
    {
        int wl;              //  limitation of total weight
        cin >> wl;
       
        int w[n+1], v[n+1];  //  weight and value of items
        for(int i = 1; i <= n; i++)
            cin >> w[i] >> v[i];
       
        int value[n+1][wl+1];
        for(int j = 0; j <= wl; j++)
            value[0][j] = 0;
       
        for(int i = 1; i <= n; i++)
        {
            value[i][0] = 0;
           
            for(int j = 1; j <= wl; j++)
            {
                value[i][j] = max(value[i-1][j], value[i][j-1]);
               
                if((w[i] <= j) && (value[i][j] < (v[i] + value[i-1][j-w[i]])))
                    value[i][j] = v[i] + value[i-1][j-w[i]];
            }
        }
       
        cout << value[n][wl] << endl;
    }
   
    return 0;
} 
