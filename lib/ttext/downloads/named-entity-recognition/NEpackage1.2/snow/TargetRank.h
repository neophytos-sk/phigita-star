// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: TargetRank.h                                  =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/98                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef TARGETRANK_H__
#define TARGETRANK_H__

#include <vector>
#include "SnowTypes.h"

using namespace std;

class GlobalParams;

struct TargetRank
{
  FeatureID   id;
  double      activation;
  double      baseActivation;
  double      softmax;
  
  TargetRank(FeatureID i = 0, double a = 0, double b = 0, double s = 0)
    : id(i), activation(a), baseActivation(b), softmax(s) { }
  
  bool operator==( const TargetRank& rhs ) const;
  bool operator!=( const TargetRank& rhs ) const;
  bool operator<( const TargetRank& rhs ) const;
  bool operator<=( const TargetRank& rhs ) const;
  bool operator>( const TargetRank& rhs ) const;
  bool operator>=( const TargetRank& rhs ) const;
};


inline bool TargetRank::operator==( const TargetRank& rhs ) const
{
  return (id == rhs.id);
}


inline bool TargetRank::operator!=( const TargetRank& rhs ) const
{
  return !operator==(rhs);
}


inline bool TargetRank::operator<( const TargetRank& rhs ) const
{
  if (activation < rhs.activation) return true;
  else if (activation == rhs.activation)
    return baseActivation < rhs.baseActivation;
  else return false;
}


inline bool TargetRank::operator<=( const TargetRank& rhs ) const
{
  return !operator>(rhs);
}


inline bool TargetRank::operator>( const TargetRank& rhs ) const
{
  if (activation > rhs.activation) return true;
  else if (activation == rhs.activation)
    return baseActivation > rhs.baseActivation;
  else return false;
}


inline bool TargetRank::operator>=( const TargetRank& rhs ) const
{
  return !operator<(rhs);
}


class TargetRanking : public vector<TargetRank>
{
public:

  //TargetRanking( bool s = false, double t = 0 )
  //  : single_target(s), threshold(t) { }

   TargetRanking( GlobalParams & gp_ ) 
     : single_target(false), threshold(0),
       globalParams(gp_) { }

   TargetRanking( bool s, double t, GlobalParams & gp_)
     : single_target(s), threshold(t), 
       globalParams(gp_) { }

  TargetRanking( const TargetRanking& cr );
  
  // returns true if the TargetRank is inserted, or false if it already
  // existed
  //    bool insert( const TargetRank& r );
  //    TargetRank* find( const TargetRank& r ) const;
  
  void Show() const;

  bool single_target;
  double threshold;

private: 
    GlobalParams & globalParams;
};


inline TargetRanking::TargetRanking( const TargetRanking& cr )
   : globalParams(cr.globalParams) 
{
  //*this = cr;
  single_target = cr.single_target;
  threshold = cr.threshold;

  //explicit copy of cr contents
  TargetRanking::const_iterator it = cr.begin();
  TargetRanking::const_iterator end = cr.end();
  
  for( ; it != end ; it++ ) {
    (*this).push_back(*it);
  }
}


#endif

