#include <stdio.h>

#define print_addr(addr) printf("%p\n",(char *) addr)

void C(){
  double m[3];
  int ni;
  printf("C();\n");
  print_addr(&m[0]);
  print_addr(&ni);
}

void B(){
  int x;
  char *y;
  char *z[2];
  printf("B();\n");
  print_addr(&x);
  print_addr(&y);
  print_addr(&z);
  C();
}

void A(){
  int a;
  short b[4];
  double c;
  printf("A(); == %p\n",A);
  print_addr(A);
  print_addr(&a);
  print_addr(&b[3]);
  print_addr(&b[2]);
  print_addr(&b[1]);
  print_addr(&b[0]);
  print_addr(&c);

  B();
}

int main(){
  printf("sizeof(int)=%zd\n",sizeof(int));
  printf("sizeof(short)=%zd\n",sizeof(short));
  printf("sizeof(double)=%zd\n",sizeof(double));
  printf("sizeof(char *)=%zd\n",sizeof(char *));
  A();
  return 0;
}
