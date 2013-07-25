#include "substdio.h"
#include "strerr.h"
#include "subfd.h"
#include "getln.h"
#include "mess822.h"
#include "exit.h"

#define FATAL "822header: fatal: "

stralloc line = {0};
int match;

void main(argc,argv)
int argc;
char **argv;
{
  for (;;) {
    if (getln(subfdinsmall,&line,&match,'\n') == -1)
      strerr_die2sys(111,FATAL,"unable to read input: ");
    if (!mess822_ok(&line)) break;
    substdio_put(subfdoutsmall,line.s,line.len);
    if (!match) break;
  }

  substdio_flush(subfdoutsmall);
  _exit(0);
}
