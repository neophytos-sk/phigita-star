// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Perceptron.h                                  =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef PERCEPTRON_H__
#define PERCEPTRON_H__

#include "LearningAlgorithm.h"

class GlobalParams;

class Perceptron : public LearningAlgorithm
{
  public:
//     Perceptron( double learningRate = 0.10,
//                 double threshold = 1.0,
//                 double defaultWeight = 0.10 );
  Perceptron( GlobalParams & gp_ );
  Perceptron( double learningRate, double threshold, 
	      double defaultWeight, GlobalParams & gp_ );

    void UpdateCounts( Target& tar, Example& ex );
    bool PresentExample( Target& tar, Example& ex );
    void PerformPercentageEligibility( Target& tar );
    void TrainingComplete( Target& tar );

    // Updates the target based on the example and the Perceptron parameters
    // The decision on how to update has been moved out of the Update
    // function, thus the third parameter.
    void Update( Target& tar, Example& ex, bool promote );

    void SetTargetActivation( Target& tar, Example& ex );
    double ReturnNormalizedActivation( Target& tar);

    void Show( ostream* out );

    void Read( ifstream& in );
    void Write( ofstream& out );

  private:
    double  learningRate;
    GlobalParams & globalParams;

};

inline Perceptron::Perceptron( GlobalParams & gp_ )
  : LearningAlgorithm(1.0, 0.10), learningRate (0.10), 
    globalParams(gp_)
{
}

inline Perceptron::Perceptron( double lr, double th, double dw,
			       GlobalParams & gp_ )
  : LearningAlgorithm(th, dw), learningRate(lr),
    globalParams(gp_)
{
}

inline void Perceptron::TrainingComplete( Target& tar ) { }

#endif
