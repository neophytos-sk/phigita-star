#include <stdlib.h>


int main() {
  int *arr = malloc(1000 * sizeof(int));
  arr[0] = 1234;
  printf("%d\n",*arr);
  printf("size=%d\n",*(arr-2));
  free(arr);
  return 0;
}
