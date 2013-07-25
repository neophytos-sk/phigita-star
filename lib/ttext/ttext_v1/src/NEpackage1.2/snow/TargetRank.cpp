// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: TargetRank.cpp                                =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/98                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#include "GlobalParams.h"
#include "TargetRank.h"


void TargetRanking::Show() const
{
  const_iterator it = this->begin();
  const_iterator end = this->end();
  
  for (; it != end; ++it)
     *globalParams.pResultsOutput << "(" << it->id << ", " << it->activation
                                  << ")\n";
}

