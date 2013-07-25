#ifndef CONFIG_H
#define CONFIG_H

#include "stralloc.h"

typedef struct {
  stralloc sa;
  int flagconf;
} config_str;

#define CONFIG_STR {{0},0}

#define config(c) ((c)->flagconf)
#define config_data(c) (&((c)->sa))

extern int config_default();
extern int config_copy();
extern int config_env();
extern int config_readline();
extern int config_readfile();

#endif
