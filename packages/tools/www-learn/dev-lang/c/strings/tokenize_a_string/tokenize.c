// ./tokenize "this,is,a,test,blah,blah"
// ./tokenize "Hello,How,Are,You,Today"

#include <stdio.h>
#include <string.h>


int main(int argc, char *argv[]) {

  if (argc!=2) {
    fprintf(stderr,"Usage: %s \"the string to tokenize\"\n",argv[0]);
    return 1;
  }

  char *str = strdup(argv[1]);
  char *saveptr;
  char *token;
  token = strtok_r(str, ",", &saveptr);
  while (token != NULL) {
    printf("%s\n",token);
    token=strtok_r(NULL,",",&saveptr);
  }

  return 0;
}
