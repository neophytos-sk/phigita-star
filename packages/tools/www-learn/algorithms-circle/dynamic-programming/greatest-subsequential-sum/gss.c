// Given a sequence of integers, find a continuous subsequence which maximizes the sum of its elements, that is, the elements of no other single subsequence add up to a value larger than this one. An empty subsequence is considered to have the sum 0; thus if all elements are negative, the result must be the empty sequence. 

#include <stdio.h>
 
int main()
{
        int a[] = {-1 , -2 , 3 , 5 , 6 , -2 , -1 , 4 , -4 , 2 , -1};
        int length = 11;
 
        int begin, end, beginmax, endmax, maxsum, sum, i;
 
        sum = 0;
        beginmax = 0;
        endmax = -1;
        maxsum = 0;
 
 
        for (begin=0; begin<length; begin++) {
                sum = 0;
                for(end=begin; end<length; end++) {
                        sum += a[end];
                        if(sum > maxsum) {
                                maxsum = sum;
                                beginmax = begin;
                                endmax = end;
                        }
                }
        }
 
        for(i=beginmax; i<=endmax; i++) {
                printf("%d\n", a[i]);
        }
 
        return 0;
}
