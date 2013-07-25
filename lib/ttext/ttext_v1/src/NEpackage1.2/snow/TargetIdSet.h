// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: TargetIdSet.h                                 =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef TARGETIDSET_H__
#define TARGETIDSET_H__

#include "SnowTypes.h"
#if defined(HASH_SET) && !defined(WIN32)
#include <hash_set>
#else
#include <set>
#endif

using namespace std;


#if defined(HASH_SET) && !defined(WIN32)
class TargetIdSet : public hash_set<FeatureID>
#else
class TargetIdSet : public set<FeatureID>
#endif
{
  public:

    bool Parse( const char* in );

    // Information and debugging support
    void Show(ostream* out);

};

#endif

