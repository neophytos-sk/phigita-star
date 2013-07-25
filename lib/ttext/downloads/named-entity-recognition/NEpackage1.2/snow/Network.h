// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Network.h                                     =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef NETWORK_H__
#define NETWORK_H__

#include "Target.h"
#include "TargetIdSet.h"
#include "TargetRank.h"
#include "Cloud.h"
#include <vector>
#include <numeric>
#include <iomanip>

class GlobalParams;

using namespace std;

typedef vector<LearningAlgorithm*> AlgorithmVector;

class Network
{
  public:
//     Network();
//     Network( TargetIdSet& labs, LearningAlgorithm* pAlg );

    Network(GlobalParams & gp_);
    Network( TargetIdSet& labs, LearningAlgorithm* pAlg,
	     GlobalParams & gp_ );
    Network( const Network& net );

    Network& operator=( const Network& rhs );

    bool operator==( const Network& rhs ) const;
    bool operator!=( const Network& rhs ) const;
    bool operator<( const Network& rhs ) const;
    bool operator<=( const Network& rhs ) const;
    bool operator>( const Network& rhs ) const;
    bool operator>=( const Network& rhs ) const;

    // Network construction from specification
    bool CreateStructure();
    void CreateClouds();

    // Manual cloud construction
    void AddCloud( const Cloud& newcloud );

    // Functions used during training
    bool PresentExample( Example& ex );
    bool PresentInteractiveExample( Example& ex );
    void PerformPercentageEligibility();
    void TrainingComplete();    
    void NormalizeConfidence();
    void Discard();

    // Functions used during evaluation and on-line learning
    double FirstThreshold() { return algorithms[0]->threshold; }
    void RankTargets( Example& ex, TargetRanking& ranking );
    void ResetCounters();
    void ShowStatistics( Counter total );
    void ShowSize();
    bool SingleTarget()
    { return clouds.size() == 1 && clouds[0].Targets() == 1; }

    // Output the network
    void Show(ostream*);
    void WriteAlgorithms( ostream* out );

    // Network persistence
    void Read( ifstream& in );
    void Write( ofstream& out );


  // Jakob: need to access clouds from outside
  vector<Cloud>* getClouds() { return &clouds;}
  protected:
    typedef vector<Cloud> CloudVector;
    bool ConstraintClassificationUpdate(Example& ex,
                                      CloudVector::iterator& currentCloud,
                                      CloudVector::iterator& subordinateCloud,
                                      FeatureID currentID,
                                      FeatureID subordinateID);

    CloudVector clouds;
    AlgorithmVector algorithms;
    TargetCloudMap TargetIDToCloud;
    GlobalParams & globalParams;
};


inline Network::Network(GlobalParams & gp_) 
  : globalParams(gp_) { }


inline void Network::AddCloud( const Cloud& newcloud )
{
  clouds.push_back(newcloud);
}


inline void Network::NormalizeConfidence()
{
  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator end = clouds.end();
  for ( ; it != end; ++it)
  {
    it->NormalizeConfidence();
  }
}


inline void Network::ResetCounters()
{
  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator end = clouds.end();
  for ( ; it != end; ++it)
  {
    it->ResetCounters();
  }
}


inline void Network::ShowStatistics( Counter total )
{
  // Show each target...
  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator end = clouds.end();
  for ( ; it != end; ++it)
  {
    it->ShowStatistics(total);
  }
}


inline void Network::ShowSize()
{
  // Show each target...
  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator end = clouds.end();
  for ( ; it != end; ++it)
  {
    it->ShowSize();
  }
}


inline void Network::WriteAlgorithms( ostream* out )
{
  AlgorithmVector::iterator it = algorithms.begin();
  AlgorithmVector::iterator end = algorithms.end();

  for (; it != end; ++it)
    (*it)->Show(out);
}

#endif
