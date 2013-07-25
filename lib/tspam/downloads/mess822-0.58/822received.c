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

#define FATAL "822received: fatal: "

void nomem()
{
  strerr_die2x(111,FATAL,"out of memory");
}

mess822_time t;
struct tai sec;
unsigned char secpack[TAI_PACK];
time_t secunix;

stralloc tokens = {0};

stralloc line = {0};

void doit()
{
  int i;
  int j;
  int state;
  char ch;
  char *x;

  for (i = 0;i < line.len;++i)
    if (line.s[i] == 0)
      line.s[i] = '\n';
  if (!stralloc_0(&line)) nomem();

  t.known = 0;
  if (!mess822_token(&tokens,line.s)) nomem();
  if (!mess822_when(&t,line.s)) nomem();
  --line.len;

  if (!t.known)
    substdio_puts(subfdoutsmall,"\t\t\t");
  else {
    caltime_tai(&t.ct,&sec);
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
    substdio_put(subfdoutsmall,ctime(&secunix),24);
  }
  substdio_puts(subfdoutsmall," ");

  state = 1;
  /* 1: start; 2: middle; 3: immediately after space; 4: after semicolon */

  for (j = i = 0;j < tokens.len;++j)
    if (!tokens.s[j]) {
      x = tokens.s + i;
      if (*x == '(') {
#ifdef notdef
        if (state == 3)
	  substdio_puts(subfdoutsmall,"\n\t\t\t   ");
#endif
	substdio_puts(subfdoutsmall,"(");
	while (ch = tokens.s[++i]) {
	  if (ch == '\n') ch = 0;
	  substdio_put(subfdoutsmall,&ch,1);
	}
	substdio_puts(subfdoutsmall,")");
        if (state & 1) state = 2;
      }
      else if (*x == '=') {
        if (state == 3)
	  if (!case_diffs(x,"=from")
	    ||!case_diffs(x,"=by")
	    ||!case_diffs(x,"=for")
	    ||!case_diffs(x,"=id")
	     )
	    substdio_puts(subfdoutsmall,"\n\t\t\t ");
	while (ch = tokens.s[++i]) {
	  if (ch == '\n') ch = 0;
	  substdio_put(subfdoutsmall,&ch,1);
	}
        if (state & 1) state = 2;
      }
      else if (*x == ';') {
        if ((state == 2) || (state == 3))
	  substdio_puts(subfdoutsmall,"\n\t\t\t ");
	state = 4;
	substdio_puts(subfdoutsmall,";");
        if (state & 1) state = 2;
      }
      else if ((*x == ' ') || (*x == '\t')) {
	if ((state != 1) && (state != 3))
	  substdio_puts(subfdoutsmall," ");
	if (state == 2) state = 3;
      }
      else {
	substdio_put(subfdoutsmall,tokens.s + i,1);
        if (state & 1) state = 2;
      }
      i = j + 1;
    }

  substdio_puts(subfdoutsmall,"\n");
}

stralloc received = {0};

mess822_header h = MESS822_HEADER;
mess822_action a[] = {
  { "received", 0, 0, &received, 0, 0 }
, { 0, 0, 0, 0, 0, 0 }
} ;

void main(argc,argv)
int argc;
char **argv;
{
  int i;
  int j;
  int match;

  if (leapsecs_init() == -1)
    strerr_die2sys(111,FATAL,"unable to init leapsecs: ");

  if (!mess822_begin(&h,a)) nomem();
  for (;;) {
    if (getln(subfdinsmall,&line,&match,'\n') == -1)
      strerr_die2sys(111,FATAL,"unable to read input: ");
    if (!mess822_ok(&line)) break;
    if (!mess822_line(&h,&line)) nomem();
    if (!match) break;
  }
  if (!mess822_end(&h)) nomem();

  i = 0;
  j = received.len;
  for (;;) {
    if (!j || (received.s[j - 1] == '\n')) {
      if (i >= j) {
        if (!stralloc_copyb(&line,received.s + j,i - j)) nomem();
        doit();
      }
      if (!j) break;
      i = j - 1;
    }
    --j;
  }

  substdio_flush(subfdoutsmall);
  _exit(0);
}
