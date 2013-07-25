#ifndef MESS822_H
#define MESS822_H

#include "stralloc.h"
#include "caltime.h"

typedef struct {
  struct caltime ct;
  int known; /* 0 for ct uninitialized; 1 if ok; 2 if ok and right zone */
} mess822_time;

typedef struct {
  char *name; /* 0 means all names */
  int *flag;
  stralloc *copy;
  stralloc *value;
  stralloc *addr;
  mess822_time *when;
} mess822_action;

typedef struct {
  stralloc inprogress;
  mess822_action *action;
} mess822_header;

#define MESS822_HEADER { {0} }

extern int mess822_quoteplus();
extern int mess822_quote();
extern int mess822_quotelist();
extern int mess822_fold();
extern int mess822_date();

extern int mess822_token();
extern int mess822_addrlist();
extern int mess822_when();

extern int mess822_begin();
extern int mess822_line();
extern int mess822_end();
extern int mess822_ok();

#endif
