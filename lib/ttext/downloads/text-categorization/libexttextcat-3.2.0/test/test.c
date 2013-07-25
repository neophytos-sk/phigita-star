#include "textcat.h"

int main(int argc, char *argv[]) {

  void *h = textcat_Init( "conf.txt" );

  printf( "Language: %s\n", textcat_Classify(h, buffer, 400));

  textcat_Done(h);

  return 0;

}
