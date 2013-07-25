#include <sys/types.h>
#include <time.h>
#include "substdio.h"
#include "strerr.h"
#include "subfd.h"
#include "getln.h"
#include "mess822.h"
#include "exit.h"
#include "leapsecs.h"
#include "caltime.h"
#include "tai.h"

#define FATAL "822date: fatal: "

void nomem()
{
  strerr_die2x(111,FATAL,"out of memory");
}

mess822_time t;
struct tai sec;
unsigned char secpack[TAI_PACK];
time_t secunix;

mess822_header h = MESS822_HEADER;
mess822_action a[] = {
  { "date", 0, 0, 0, 0, &t }
, { 0, 0, 0, 0, 0, 0 }
} ;

stralloc line = {0};
int match;

void main(argc,argv)
int argc;
char **argv;
{
  if (leapsecs_init() == -1)
    strerr_die2sys(111,FATAL,"unable to init leapsecs: ");

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

  if (!t.known) _exit(100);

  if (!stralloc_ready(&line,caltime_fmt((char *) 0,&t.ct))) nomem();
  substdio_put(subfdoutsmall,line.s,caltime_fmt(line.s,&t.ct));
  substdio_put(subfdoutsmall,"\n",1);

  caltime_tai(&t.ct,&sec);

  caltime_utc(&t.ct,&sec,(int *) 0,(int *) 0);
  if (!stralloc_ready(&line,caltime_fmt((char *) 0,&t.ct))) nomem();
  substdio_put(subfdoutsmall,line.s,caltime_fmt(line.s,&t.ct));
  substdio_put(subfdoutsmall,"\n",1);

  tai_pack(secpack,&sec);
  secunix = secpack[0] - 64;
  secunix = (secunix << 8) + secpack[1];
  secunix = (secunix << 8) + secpack[2];
  secunix = (secunix << 8) + secpack[3];
  secunix = (secunix << 8) + secpack[4];
  secunix = (secunix << 8) + secpack[5];
  secunix = (secunix << 8) + secpack[6];
  secunix = (secunix << 8) + secpack[7];
  secunix -= 10;
  substdio_puts(subfdoutsmall,ctime(&secunix));

  substdio_flush(subfdoutsmall);
  _exit(0);
}
