#include "scan.h"

unsigned int scan_plusminus(s,sign) register char *s; register int *sign;
{
  if (*s == '+') { *sign = 1; return 1; }
  if (*s == '-') { *sign = -1; return 1; }
  *sign = 1; return 0;
}
