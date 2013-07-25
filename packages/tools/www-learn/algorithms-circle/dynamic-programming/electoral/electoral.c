/*
 * How many ways there were to win the electoral college with a minimal set of 
 * states, that is, sets of states that add up to 270 or more votes, but for
 * which removing any state from the set would drop under 270.
 *
 * http://research.swtch.com/2008/06/electoral-programming.html
 */

#include <stdio.h>

typedef long long int64;

int votes[51] = {
    55, 34, 31, 27, 21, 21, 20, 17, 15, 15,
    15, 13, 12, 11, 11, 11, 11, 10, 10, 10,
    10,  9,  9,  9,  8,  8,  7,  7,  7,  7,
     6,  6,  6,  5,  5,  5,  5,  5,  4,  4,
     4,  4,  4,  3,  3,  3,  3,  3,  3,  3,
     3,
};

int64 ways[400];

int
main(int argc, char **argv)
{
    int n, v, reps;
    int64 total;
    
    for(n=0; n<400; n++)
        ways[n] = 0;

    ways[0] = 1;
    for(n=0; n<51; n++)
        for(v=270+votes[n]-1; v>=votes[n]; v--)
            ways[v] += ways[v-votes[n]];

    total = 0;
    for(v=270; v<400; v++)
        total += ways[v];

    printf("%lld\n", total);
    return 0;
}
