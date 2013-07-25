#include <cstdio>


int main(int argc, char *argv[])
{
  if (argc==1) {
    printf("Usage: %s <num1> <num2> ... <numN>\n",argv[0]);
  }

  int myNumber;
  char *str;
  for (int i = 1; i<argc; ++i) {
    sprintf(str,"%s",argv[i]);
    if ( sscanf(str,"%d",&myNumber) )
      printf("%d\n",myNumber);
  }
  return 0;
}
