/*
The trick is to skip the numbers which are guaranteed to give a sub-average value. If sumDigits is the sum of the digits and numDigits is the number of digits, then if sumDigits <= 7 * numDigits, we skip it and we need at least (7 * numDigits)-sumDigits+1 to bring the digits avg above 7.0. The trick is to increment the number (starting from the units place) so that the total average goes above 7.0; To take an example, if the number is 10000, sumDigits = 1 and avg of digits = 0.2. The deficit in sum is 7*5-1 +1= 35, so we can increment 10000 by 8999 i.e we increase the sum by 8+9+9+9 = 35 and new number = 18999 has sumDigits =36 and average of digits becomes greater than 7.0;

Note that in the below code we do not compute the average at all, which uses a floating-point operation, but instead use multiplication. (To digress a bit, see Jon Bentley's More Programming Pearls Column.1 page.7, where Bentley applies similar technique during generation of prime numbers and avoids sqrt, there by gaining performance)

Here is the sample code in C++ (Tested on VS 2010). This has two functions, one for the naive method and another for the optimal method. It also prints the number of times the sum of digits is computed in each case. (By setting verbose = true, a detailed way of execution can be seen); 
*/


#include <cstdio>
#include <iostream>
#include <assert.h>
using namespace std;

const size_t HEAVY_AVG = 7;

bool verbose = false;

/** Given a number, returns the the sum of the digits and computes the number of digits */
size_t digit_sum(size_t n, size_t& numDigits)
{
    if (n==0) return 0;
    size_t digSum = 0; // sum of digits
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
size_t compute_increment(size_t n, size_t deficit)
{
    size_t inc = 0;
    size_t d = 1;
    if (verbose) cout << "n " << n << " deficit " << deficit << endl;
    while (deficit)
    {
        size_t digit = n%10;
        if (digit < 9) // Don't change the digit which is already at its max
        {
            size_t inc_d = (9-digit) < (deficit)? 9-digit:(deficit);
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
size_t compute_heavy_naive(size_t start, size_t end)
{
    size_t numHeavy = 0;
    size_t numDigits = 0; // unused here
    printf("\n[Naive] heavy numbers between %d and %d \n" , start, end);
    for( size_t i = start; i <= end; ++i )
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
size_t compute_heavy_optimal(size_t start, size_t end)
{
    printf("\n[Optimal] heavy numbers between %d and %d \n" , start, end);
    size_t _count = 0; // profiling : how times is digit_sum computed?
    size_t i = start;
    size_t numHeavy = 0;
    while (i <= end)
    {
        size_t numDigits=1; // number of digits;
        size_t sum = digit_sum(i,numDigits);
        ++_count; // profiling.
        if ( verbose) printf("%d : avg %d num_digits %d \n" , i, sum, numDigits);
        size_t reqdSum = HEAVY_AVG * numDigits;

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
            size_t sumDeficit = reqdSum - sum + 1 ;
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
    system("pause");
    return 0;
}

