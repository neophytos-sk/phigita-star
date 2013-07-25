#include "mess822.h"
#include "byte.h"

int mess822_ok(sa)
stralloc *sa;
{
  int i;
  int len;
  int colon;

  len = sa->len;
  if (len && (sa->s[len - 1] == '\n')) --len;
  if (!len) return 0;

  /* if input message is 822-compliant, will return 1 after this */

  if (sa->s[0] == ' ') return 1;
  if (sa->s[0] == '\t') return 1;

  colon = byte_chr(sa->s,sa->len,':');
  if (colon >= sa->len) return 0;

  while (colon && ((sa->s[colon - 1] == ' ') || (sa->s[colon - 1] == '\t')))
    --colon;

  if (!colon) return 0;

  for (i = 0;i < colon;++i) if (sa->s[i] < 33) return 0;
  for (i = 0;i < colon;++i) if (sa->s[i] > 126) return 0;

  return 1;
}
