#include <stdio.h>

#define NO_OF_CHARS 256

/* Function removes duplicate characters from the string
   This function work in-place and fills null characters
   in the extra space left */
char *dedupe(char *str) {
  int exists[NO_OF_CHARS] = {0};
  char *p,*q;
  p = q = str;

  /* In place removal of duplicate characters*/
  while(q && *q!='\0') {
    char temp = *q;
    if (!exists[temp]) {
      exists[temp]=1;
      *p = *q;
      p++;
    }
    q++;
  }

  /* After above step string is stringiittg.
     Removing extra iittg after string*/
  *p = '\0';
  return str;
}

/* Driver program to test removeDups */
int main()
{
    char str[] = "geeksforgeeks";
    printf("%s", dedupe(str));
    getchar();
    return 0;
}
