// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: LearningAlgorithm.h                           =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef LEARNINGALGORITHM_H__
#define LEARNINGALGORITHM_H__

#include "Example.h"
#include "TargetIdSet.h"

class Target;

class LearningAlgorithm
{
  public:
    LearningAlgorithm( double t = 1, double d = 0.1 )
      : threshold(t), defaultWeight(d) { }

    virtual bool PresentExample( Target& tar, Example& ex );
    virtual void PerformPercentageEligibility( Target& tar );
    virtual void TrainingComplete( Target& tar );
    virtual void Discard( Target& tar );
    virtual void Update( Target& tar, Example& ex, bool promote );

    virtual void PrepareToRank();
    virtual void SetTargetActivation( Target& tar, Example& ex );
    virtual double ReturnNormalizedActivation( Target& tar );

    virtual void Show( ostream* out ) = 0;

    virtual void Read( ifstream& in ) = 0;
    virtual void Write( ofstream& out ) = 0;

    int     index;
    TargetIdSet targetIds;
    double  threshold;
    double  defaultWeight;
};


inline bool LearningAlgorithm::PresentExample( Target& tar, Example& ex )
{
  cout << "LearningAlgorithm::PresentExample()...\n";
  return false;
}


inline void LearningAlgorithm::PerformPercentageEligibility( Target& tar )
{
  cout << "LearningAlgorithm::PerformPercentageEligibility()...\n";
}


inline void LearningAlgorithm::TrainingComplete( Target& tar )
{
  cout << "LearningAlgorithm::TrainingComplete()...\n";
}


inline void LearningAlgorithm::Discard( Target& tar )
{
  cout << "LearningAlgorithm::Discard()...\n";
}


inline void LearningAlgorithm::Update( Target& tar, Example& ex,
                                       bool promote )
{
  cout << "LearningAlgorithm::Update()...\n";
}


inline void LearningAlgorithm::PrepareToRank()
{
  cout << "LearningAlgorithm::PrepareToRank()...\n";
}


inline void LearningAlgorithm::SetTargetActivation( Target& tar, Example& ex )
{
  cout << "LearningAlgorithm::SetTargetActivation()...\n";
}


inline double LearningAlgorithm::ReturnNormalizedActivation( Target& tar )
{
  cout << "LearningAlgorithm::ReturnNormalizedActivation()...\n";
  return 0;
}


#endif

