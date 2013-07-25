// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: NaiveBayes.h                                  =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef NAIVEBAYES_H__
#define NAIVEBAYES_H__

#include "LearningAlgorithm.h"

class GlobalParams;

class NaiveBayes : public LearningAlgorithm
{
  public:
  //NaiveBayes() : LearningAlgorithm() { }
    NaiveBayes( GlobalParams & gp_ ) : 
      LearningAlgorithm(), globalParams(gp_) { }

    bool PresentExample( Target& tar, Example& ex );
    void TrainingComplete( Target& tar );

    //void PrepareToRank();
    void SetTargetActivation( Target& tar, Example& ex );
    double ReturnNormalizedActivation( Target& tar );


    void Show( ostream* out );

    void Read( ifstream& in );
    void Write( ofstream& out );

  private:
    GlobalParams & globalParams;

};

/*
inline void NaiveBayes::PrepareToRank()
{
  //threshold = 0.0;
}
 */

#endif

