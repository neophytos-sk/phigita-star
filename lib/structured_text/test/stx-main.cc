#include <cstdio>
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
  ssize_t bytes;

  *text = (char *) malloc(blocksize);
  if (*text == NULL) {
    fprintf(stderr,"Unable to allocate memory\n");
    return 0;
  }
  total = blocksize;

  buffer = *text;
  while(bytes=fread((char *) buffer, blocksize, 1, fp)) {

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
}

int main(int argc, char *argv[]) {

  if (argc<2) {
    printf("Usage: %s structured_text_file\n",argv[0]);
    return 1;
  }

  char *text;
  int size = ReadFile(argv[1],&text);

  //printf("%s",text);

  structured_text doc(text);
  //int text_length = strlen(text);
  //int extra_bytes = text_length; // this is for the markup code
  //char *html = (char *) malloc(text_length+1+extra_bytes);
  //html[text_length] = '\0';
  //stx_to_html(text,html);
  //printf("++++++++++++html++++++++++\n%s\n",doc.to_html().c_str());
  int outflags = 0;
  std::string html;
  doc.to_html(html,&outflags);
  printf("%s",html.c_str());
  printf("\noutflags=%d\n",(unsigned char) outflags);
  //free(html);

  return 0;
}
