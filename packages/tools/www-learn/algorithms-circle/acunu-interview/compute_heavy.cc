#include <iostream>
#include <assert.h>
#include <cstdio>

using namespace std;

const int HEAVY_AVG = 7;

bool verbose = false;

/** Given a number, returns the the sum of the digits and computes the number of digits */
int digit_sum(int n, int& numDigits)
{
    if (n==0) return 0;
    int digSum = 0; // sum of digits
    numDigits = 0; // num of digits
    while (n)
    {
        digSum += n%10;
        n = n/10;
        ++numDigits;
    }
    return digSum;
}

/** Computes the increment required to meet the deficit */
int compute_increment(int n, int deficit)
{
    int inc = 0;
    int d = 1;
    if (verbose) cout << "n " << n << " deficit " << deficit << endl;
    while (deficit)
    {
        int digit = n%10;
        if (digit < 9) // Don't change the digit which is already at its max
        {
            int inc_d = (9-digit) < (deficit)? 9-digit:(deficit);
            inc += inc_d * d;
            deficit -= inc_d;
        }
        n /= 10;
        d *= 10;
    }
    if (verbose) printf("increment required: %d \n", inc );
    return inc;
}

/** The naive function : used purely for verification */
int compute_heavy_naive(int start, int end)
{
    int numHeavy = 0;
    int numDigits = 0; // unused here
    printf("\n[Naive] heavy numbers between %d and %d \n" , start, end);
    for( int i = start; i <= end; ++i )
    {
        if ( digit_sum(i,numDigits) > (HEAVY_AVG*numDigits) ) 
        {
             cout << i << " " ;
            ++numHeavy;
        }
    }
     printf("\n[Naive] digit_sum computed : %d times, and total heavy numbers: %d \n", (end-start)+1, numHeavy);
    return numHeavy;
}

/** A optimal approach */
int compute_heavy_optimal(int start, int end)
{
    printf("\n[Optimal] heavy numbers between %d and %d \n" , start, end);
    int _count = 0; // profiling : how times is digit_sum computed?
    int i = start;
    int numHeavy = 0;
    while (i <= end)
    {
        int numDigits=1; // number of digits;
        int sum = digit_sum(i,numDigits);
        ++_count; // profiling.
        if ( verbose) printf("%d : avg %d num_digits %d \n" , i, sum, numDigits);
        int reqdSum = HEAVY_AVG * numDigits;

        if ( sum > reqdSum ) 
        {
            /* we have found a heavy number */
            cout << i << " ";
            ++i;
            ++numHeavy;
        }
        else 
        {
            /* Not so heavy! */
            int sumDeficit = reqdSum - sum + 1 ;
            if (verbose) printf("average deficit for %d = %d \n" , i, sumDeficit );
            i += compute_increment(i, sumDeficit );
        }
    }
    printf("\n[Optimal] digit_sum computed : %d times, and total heavy numbers: %d \n", _count, numHeavy);
    /* verify that the optimal method is correct */
    assert( numHeavy == compute_heavy_naive(start, end)); 
    return numHeavy;
}

int main()
{
    compute_heavy_optimal(1, 100);
    cout << endl << "-------" << endl;
    compute_heavy_optimal(10000,20000);
    return 0;
}

