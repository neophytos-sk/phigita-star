/* Google Interview Question for Software Engineer / Developers about Algorithm
 *
 * Given strings input1 and input2, remove all occurrences of input2 in input1.
 * e.g.:
 * input1 = abcthabdtheshhtexyztheaaa
 * input2 = the
 *
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void remove_string(char *dest, const char *s1, const char *s2) {
  const char *p = s1;
  const char *last = s1;
  size_t n;
  size_t len = strlen(s2);
  while ( p=strstr(last,s2) ) {
    n = p - last;
    strncat(&dest[0],last,n);
    dest += n;
    last = p + len;
  }
  strcat(&dest[0],last);
}



int main(int argc, char *argv[]) {
  if (argc != 3) {
    fprintf(stderr,"Usage: %s str1 str2\n", argv[0]);
    return 1;
  }

  int len = strlen(argv[1]);
  char *diff = (char *) malloc(1+len);
  diff[len] = '\0';
  remove_string(diff, argv[1], argv[2]);
  printf("%s\n",diff);

  free(diff);

  return 0;
}
