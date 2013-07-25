#include "mess822.h"

int mess822_fold(out,in,prefix,linelen)
stralloc *out;
stralloc *in;
char *prefix;
int linelen;
{
  int i;
  int j;
  int k;
  int partial;

  if (!stralloc_copys(out,prefix)) return 0;
  partial = out->len;

  for (j = i = 0;j <= in->len;++j)
    if ((j == in->len) || (in->s[j] == '\n')) {
      k = i;
      while ((in->s[k] == ' ') && (in->s[k + 1] == ' ')) ++k;
      if (i && (partial + j - k > linelen)) {
	if (!stralloc_cats(out,"\n")) return 0;
	if (!stralloc_catb(out,in->s + i,j - i)) return 0;
	partial = j - i;
      }
      else {
	if (!stralloc_catb(out,in->s + k,j - k)) return 0;
	partial += j - k;
      }
      i = j + 1;
    }

  if (!stralloc_append(out,"\n")) return 0;

  return 1;
}
