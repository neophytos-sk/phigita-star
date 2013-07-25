#include <stdio.h>



#define E_TARGET_NOT_IN_ARRAY -1
#define E_ARRAY_UNORDERED     -2
#define E_LIMITS_REVERSED     -3


int BinarySearch(const int array[], int lower, int upper,int target)
{
  int range = upper - lower;
  if (range < 0)
    return E_LIMITS_REVERSED;
  else if (range == 0 && array[lower]!=target)
    return E_TARGET_NOT_IN_ARRAY;

  if (array[lower] > array[upper])
    return E_ARRAY_UNORDERED;

  int center = lower+range/2;
  if (target < array[center])
    return BinarySearch(array,lower,center-1,target);
  else if (target > array[center])
    return BinarySearch(array,center+1,upper,target);
  else
    return center; // target found in center position

}


int main(int argc, char *argv[])
{
  int N[] = {12,34,56,78,90,123,456,789,888,999};
  int lower,upper,target;

  lower=0;
  upper=9;
  target=78;
  int index = BinarySearch(N,lower,upper,target);
  printf("result index = %d\n",index);

  return 0;
}
