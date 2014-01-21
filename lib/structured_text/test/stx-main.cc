#include <cstdio>
#include <cstdlib>
#include "structured_text.h"


size_t ReadFile(const char *filename, char **text) {

  FILE *fp = fopen(filename,"r");

  if (!fp) {
    fprintf(stderr,"Unable to open file: %s", filename);
    return 0;
  }

  size_t total = 0;
  char *buffer;
  size_t blocksize = 65536;
  size_t bytes;

  *text = (char *) malloc(blocksize);
  if (*text == NULL) {
    fprintf(stderr,"Unable to allocate memory\n");
    return 0;
  }
  total = blocksize;

  buffer = *text;
  while((bytes=fread((char *) buffer, blocksize, 1, fp))) {

    if (bytes < blocksize) {
      // an error occured, check with feof(3) and ferror(3)
      fprintf(stderr, "Error reading file, bytes=%zd\n",bytes);
      free(text);
      return 0;
    }
    if (bytes < blocksize) {
      // last block of the file, no need to allocate more memory
      break;
    } else {
      total += blocksize;
      *text = (char *) realloc(text,total);
      buffer += blocksize;
    }
  }

  fclose(fp);
  return total;
}

int main(int argc, char *argv[]) {

  if (argc<2) {
    printf("Usage: %s structured_text_file\n",argv[0]);
    return 1;
  }

  char *text;
  ReadFile(argv[1],&text);

  int outflags = 0;
  Tcl_DString ds;
  Tcl_DStringInit(&ds);
  StxToHtml(&ds, &outflags, text);

  printf("%s",Tcl_DStringValue(&ds));
  printf("\noutflags=%d\n",(unsigned char) outflags);

  Tcl_DStringFree(&ds);

  return 0;
}
