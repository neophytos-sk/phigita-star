#include <cstdio>
#include <cstdlib>

#include "tlucene.h"


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
    printf("Usage: %s query_string\n",argv[0]);
    return 1;
  }

  char *text = argv[1];
  char result[MAX_QUERY_BYTELEN] = { '\0' };
  tlucene_ParseQuery(text,result);

  printf("%s\n",result);

  std::map<std::string, std::list<int> > tokenmap;
  tlucene_Tokenize(text,tokenmap);


  for(typeof(tokenmap.begin()) it=tokenmap.begin();
      it != tokenmap.end();
      ++it) {

    printf("%s has %zd positions\n",(it->first).c_str(),(it->second).size());

    
  }


  return 0;
}
