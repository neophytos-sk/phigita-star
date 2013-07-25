// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Winnow.h                                      =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/98                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef WINNOW_H__
#define WINNOW_H__

#include "LearningAlgorithm.h"

class GlobalParams;

class Winnow : public LearningAlgorithm
{
  public:
//     Winnow( double alpha = 2.0,
//             double beta = 0.50,
//             double threshold = 1.0,
//             double defaultWeight = 0.05 );

  Winnow( GlobalParams & gp_ );

  Winnow( double alpha, double beta, double threshold, 
	 double defaultWeight, GlobalParams & gp_ );

    void UpdateCounts( Target& tar, Example& ex );
    bool PresentExample( Target& tar, Example& ex );
    void PerformPercentageEligibility( Target& tar );
    void TrainingComplete( Target& tar );
    //void Discard( Target& tar );

    // Updates the target based on the example and the Winnow parameters.  The
    // decision on how to update has been moved out of the Update function,
    // thus the third parameter.
    void Update( Target& tar, Example& ex, bool promote );

    void SetTargetActivation( Target& tar, Example& ex );
    double ReturnNormalizedActivation( Target& tar);

    void Show( ostream* out );

    void Read( ifstream& in );
    void Write( ofstream& out );

  private:
    double alpha;
    double beta;
    GlobalParams & globalParams;
};


inline Winnow::Winnow( GlobalParams & gp_ )
  : LearningAlgorithm(1.0, 0.05), alpha(2.0), beta(0.5),
    globalParams(gp_)
{ 
}


inline Winnow::Winnow( double a, double b, double t, double d,
		       GlobalParams & gp_ )
  : LearningAlgorithm(t, d), alpha(a), beta(b), 
    globalParams(gp_)
{
}


inline void Winnow::TrainingComplete( Target& tar ) { }

#endif

