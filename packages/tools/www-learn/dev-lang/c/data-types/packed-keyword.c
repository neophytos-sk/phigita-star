#include <stdio.h>

// comment out/in the #pragma pack(1) line : overrides compiler optimizations
// which lead to natural boundary alignment of one or more of the data elemens
// contained in the structure. A "packed" structure will almost always have a
// smaller memory footprint than its unpacked brother.
// #pragma pack(1)

typedef struct struct_1 {
  char a;
  int b;
  char c;
  int d;
} s1;

typedef struct struct_2 {
  char a;
  char c;
  int b;
  int d;
} s2;


int main(void) {
  printf("sizeof(s1) is %zd, sizeof(s2) is %zd\n",sizeof(s1),sizeof(s2));
  return 0;
}
