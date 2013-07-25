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

#ifndef _FEXPARAMS_H
#define _FEXPARAMS_H

//#define CYGWIN

#include "GlobalParams.h"

extern GlobalParams globalParams;

bool ParseCmdLine( int argc, char* argv[] );
bool ProcessParam( int param, const char* arg );
bool ValidateParams();

#ifdef CYGWIN
extern "C"
{
extern int getopt(int, char* const *, const char*);
extern char *optarg;
}
#endif

#endif
