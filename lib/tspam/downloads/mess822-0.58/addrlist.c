#include "substdio.h"
#include "strerr.h"
#include "subfd.h"
#include "getln.h"
#include "mess822.h"

#define FATAL "addrlist: fatal: "

void nomem()
{
  strerr_die2x(111,FATAL,"out of memory");
}

void put(buf)
char *buf;
{
  char ch;

  while (ch = *buf) {
    if (ch == '\n') ch = 0;
    substdio_put(subfdout,&ch,1);
    ++buf;
  }
}

stralloc line = {0};
int match;

stralloc addrlist = {0};
stralloc quoted = {0};

void main()
{
  int i;
  int j;

  for (;;) {
    if (getln(subfdin,&line,&match,'\n') == -1)
      strerr_die2sys(111,FATAL,"unable to read input: ");
    if (!line.len) break;
    if (match) --line.len;

    substdio_puts(subfdout,"input {");
    substdio_put(subfdout,line.s,line.len);
    substdio_puts(subfdout,"}\n");

    for (i = 0;i < line.len;++i)
      if (line.s[i] == 0)
	line.s[i] = '\n';
    if (!stralloc_0(&line)) nomem();

    if (!mess822_addrlist(&addrlist,line.s)) nomem();

    for (j = i = 0;j < addrlist.len;++j)
      if (!addrlist.s[j]) {
	if (addrlist.s[i] == '(') {
	  substdio_puts(subfdout,"comment {");
	  put(addrlist.s + i + 1);
	  substdio_puts(subfdout,"}\n");
	}
	else if (addrlist.s[i] == '+') {
	  substdio_puts(subfdout,"address {");
	  put(addrlist.s + i + 1);
	  substdio_puts(subfdout,"}\n");
	}
	i = j + 1;
      }

    if (!mess822_quotelist(&quoted,&addrlist)) nomem();
    substdio_puts(subfdout,"rewrite {");
    substdio_put(subfdout,quoted.s,quoted.len);
    substdio_puts(subfdout,"}\n");

    substdio_puts(subfdout,"\n");
    if (!match) break;
  }

  substdio_flush(subfdout);
  _exit(0);
}
