#include "substdio.h"
#include "strerr.h"
#include "subfd.h"
#include "getln.h"
#include "mess822.h"
#include "exit.h"

#define FATAL "822field: fatal: "

void nomem()
{
  strerr_die2x(111,FATAL,"out of memory");
}

int flag;
stralloc value = {0};

mess822_header h = MESS822_HEADER;
mess822_action a[] = {
  { "subject", &flag, 0, &value, 0, 0 }
, { 0, 0, 0, 0, 0, 0 }
} ;

stralloc line = {0};
int match;

void main(argc,argv)
int argc;
char **argv;
{
  int i;
  char ch;

  if (argv[1])
    a[0].name = argv[1];

  if (!mess822_begin(&h,a)) nomem();

  for (;;) {
    if (getln(subfdinsmall,&line,&match,'\n') == -1)
      strerr_die2sys(111,FATAL,"unable to read input: ");

    if (!mess822_ok(&line)) break;
    if (!mess822_line(&h,&line)) nomem();
    if (!match) break;
  }

  if (!mess822_end(&h)) nomem();

  substdio_putflush(subfdoutsmall,value.s,value.len);

  _exit(flag ? 0 : 100);
}
