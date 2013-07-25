//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: FexParams.h                                   =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef __FLEX_H__
#define __FLEX_H__

#include "tokens.h"

#define TEOF 0;

enum {T_COLOC, T_LABEL, T_NOT, T_CONJ, T_SCOLOC, T_DISJ, T_LINK};

extern int lineno;

#endif
