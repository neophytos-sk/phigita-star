// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: MinimalFeature.h                              =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef MINIMALFEATURE_H__
#define MINIMALFEATURE_H__

#include "SnowTypes.h"

enum Eligibility { eligible, pending, discard };

class MinimalFeature
{
  public:
    double  weight;
    Counter activeCount;
    Eligibility eligibility;
    int updates;

    MinimalFeature(double wgt = 0.0, Counter actCnt = 0L,
                   Eligibility e = eligible, int u = 0);
};


inline MinimalFeature::MinimalFeature(double wgt, Counter actCnt,
                                      Eligibility e, int u )
       : weight(wgt), activeCount(actCnt), eligibility(e), updates(u)
{
}

#endif

