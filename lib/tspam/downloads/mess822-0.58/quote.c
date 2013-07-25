#include "mess822.h"
#include "subfd.h"
#include "substdio.h"
#include "strerr.h"

#define FATAL "quote: fatal: "

void nomem()
{
  strerr_die2x(111,FATAL,"out of memory");
}

stralloc quoted = {0};
stralloc addr = {0};
char *comment = 0;

void main(argc,argv)
int argc;
char **argv;
{
  if (!stralloc_copys(&addr,"@")) nomem();

  if (argv[1]) {
    if (!stralloc_copys(&addr,argv[1])) nomem();
    if (!stralloc_cats(&addr,"@")) nomem();

    if (argv[2]) {
      if (!stralloc_cats(&addr,argv[2])) nomem();

      comment = argv[3];
    }
  }

  if (!stralloc_0(&addr)) nomem();
  if (!mess822_quote(&quoted,addr.s,comment)) nomem();

  if (!stralloc_append(&quoted,"\n")) nomem();

  substdio_putflush(subfdout,quoted.s,quoted.len);

  _exit(0);
}
