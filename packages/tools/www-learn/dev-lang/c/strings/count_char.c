#include <stdio.h>

#define MIN_CHAR 33
#define MAX_CHAR 256

int main(int argc, char *argv[]) {

  if (argc<2) {
    printf("Usage: %s string\n",argv[0]);
    return 1;
  }

  int count[256];
  int i;
  for(i=0;i<MAX_CHAR;i++) count[i]=0;
  
  char *ch=argv[1];
  while(*ch !='\0') {
    count[(*ch)]++;
    ch++;
  }
  
  for(i=MIN_CHAR;i<MAX_CHAR;i++)
    if(count[i]!=0)
      printf("%c %d\n",i,count[i]);
  
  return 0;
  
}
