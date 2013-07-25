

//  Maximum Consecutive Sum
#include <iostream>
#include <cstdlib>
#define SIZE 10

using namespace std;

int main()
{
    int array[SIZE] = {-4, 9, -5, 6, 8, -3, -1, 10, -10, 1};
    int max_sum = 0, sum = 0;
    int start_pos = 0, end_pos = 0;
    
    for(int i = 0; i < SIZE; i++)
    {
        if(sum + array[i] < array[i])
        {
            sum = array[i];
        
            if(sum > max_sum)
            {
                max_sum = sum;
                start_pos = i;
                end_pos = i;
            }
        }
        else if(sum + array[i] >= sum)
        {
            sum += array[i];
        
            if(sum > max_sum)
            {
                max_sum = sum;
                end_pos = i;
            }
        }
        else
            sum += array[i];
    }
    
    if(max_sum <= 0)
        cout << "No Solution\n";
    else
    {
        cout << max_sum << endl;
        
        for(int i = start_pos; i < end_pos; i++)
            cout << array[i] << ' ';
        
        cout << array[end_pos] << endl;
    }
    
    //system( "sleep 1" );
    return 0;
}
