#ifndef STRUCTURED_TEXT_H
#define STRUCTURED_TEXT_H


#include <cstring>  // For memrchr, strdup
#include <queue>
#include <string>
#include <stack>
#include <utility> // For make_pair

#include "tcl.h"


int MinitextToHtml(Tcl_DString *dsPtr, int *outflags, char *text);
int StxToHtml(Tcl_DString *dsPtr, int *outflags, char *text);

#endif
