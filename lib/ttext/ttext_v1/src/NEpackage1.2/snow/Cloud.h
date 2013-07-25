// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Cloud.h                                       =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef CLOUD_H__
#define CLOUD_H__

#include <vector>
#include <numeric>
#include <iomanip>

#if defined(FEATURE_HASH) && !defined(WIN32)
#include <hash_set>
#else
#include <set>
#endif

#include "SnowTypes.h"
#include "Target.h"
#include "TargetRank.h"
#include "NaiveBayes.h"

using namespace std;

class GlobalParams;

typedef vector<LearningAlgorithm*> AlgorithmVector;


class Cloud
{
  public:
    Cloud(GlobalParams & gp_): globalParams(gp_) { }
    Cloud( FeatureID id, GlobalParams & gp_ ) : 
      targetID(id), globalParams(gp_) { }
    Cloud( FeatureID id, AlgorithmVector& algorithms, 
	   GlobalParams & gp_);
  //need copy constructor, assignment operator now that
  //GlobalParams is handled explicitly
    Cloud( const Cloud & cl );

    Cloud & operator=( const Cloud& rhs);

    bool operator==( const Cloud& rhs ) const;
    bool operator!=( const Cloud& rhs ) const;
    bool operator<( const Cloud& rhs ) const;
    bool operator<=( const Cloud& rhs ) const;
    bool operator>( const Cloud& rhs ) const;
    bool operator>=( const Cloud& rhs ) const;

    // Functions used during training
    //double ReturnActivation();
    //double ReturnNormalizedActivation();
    bool PresentExample( Example& ex );
    void PerformPercentageEligibility();
    void TrainingComplete();
    void NormalizeConfidence();
    void Discard();
    void Discard( FeatureID id, double delta );
    // Update added for the constraint classification implementation.
    void Update( Example& ex, bool promote );

    // Functions used during evaluation and on-line learning
    void PreparetoRank( Example& ex );
    void FindMinimumWeight( FeatureID id, double& min, int& dups);
#if defined(FEATURE_HASH) && !defined(WIN32)
    void CollectFeatures( hash_set<FeatureID>& featureSet );
#else
    void CollectFeatures( set<FeatureID>& featureSet );
#endif
    void ResetCounters();
    void SetMistakes(int mistakes);
    void ShowStatistics( Counter total );
    void ShowSize();
    int Targets() { return targets.size(); }

    // Output functions
    void Show(ostream*);
    void WriteAlgorithms( ofstream& out );
    FeatureID Id() const { return targetID; }
    // The Activation() and NormalizedActivation() member functions added for
    // the constraint classification implementation.
    double Activation() const { return activation; }
    double NormalizedActivation() const { return normalizedActivation; }

    // Manual cloud construction
    void AddTarget( const Target& target );

    // Network persistence
    void Write( ofstream& out );

  //Jakob: need to be able to access targets
  vector<Target> *  getTargets() { return &targets;}
  protected:
    typedef vector<Target> TargetVector;

    FeatureID       targetID;
    TargetVector    targets;
    // The activation and normalizedActivation member variables added for the
    // constraint classification implementation.
    double          activation;
    double          normalizedActivation;

    GlobalParams & globalParams;

};
 

inline Cloud::Cloud( FeatureID id, AlgorithmVector& algorithms, 
		     GlobalParams & gp_ )
  : targetID(id), globalParams(gp_)
{
  AlgorithmVector::iterator algIt = algorithms.begin();
  AlgorithmVector::iterator algEnd = algorithms.end();

  // Create one new Target for each learner 
  for (; algIt != algEnd; ++algIt)
    targets.push_back(Target(id, *algIt, algorithms.size() == 1, 
			     globalParams));
}



inline void Cloud::PerformPercentageEligibility()
{
  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();

  for (; it != end; ++it)
    it->PerformPercentageEligibility();
}


inline void Cloud::TrainingComplete()
{
  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();

  for (; it != end; ++it)
    it->TrainingComplete();

  NormalizeConfidence();
}


inline void Cloud::NormalizeConfidence()
{
  double totalConfidence = 0;

  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();

  for (; it != end; ++it)
    totalConfidence += it->Confidence();
  
  for (it = targets.begin(); it != end; ++it)
    it->NormalizeConfidence(totalConfidence);
}


inline void Cloud::Discard()
{
	TargetVector::iterator it = targets.begin();
	TargetVector::iterator end = targets.end();
    
	for (; it != end; ++it)
		it->Discard();
}


inline void Cloud::Discard( FeatureID id, double delta )
{
	TargetVector::iterator it = targets.begin();
	TargetVector::iterator end = targets.end();
    
	for (; it != end; ++it)
		it->Discard(id, delta);
}


// Update added for the constraint classification implementation.
inline void Cloud::Update( Example& ex, bool promote )
{
  int size = targets.size();
  for (int i = 0; i < size; ++i)
    targets[i].PAlgorithm()->Update(targets[i], ex, promote);
  PreparetoRank(ex);
}


inline void Cloud::FindMinimumWeight( FeatureID id, double& min, int& dups)
{
	TargetVector::iterator it = targets.begin();
	TargetVector::iterator end = targets.end();
	for (it = targets.begin(); it != end; ++it)
	{
		double weight = it->WeightOfFeature(id);
		if (weight < min)
		{
			min = weight;
			dups = 0;
		}
    else if (weight == min)
      // Two features with the same weight.  Don't discard yet.
			++dups;
	}
}


#if defined(FEATURE_HASH) && !defined(WIN32)
inline void Cloud::CollectFeatures( hash_set<FeatureID>& featureSet ) 
#else
inline void Cloud::CollectFeatures( set<FeatureID>& featureSet ) 
#endif
{
	TargetVector::iterator it = targets.begin();
	TargetVector::iterator end = targets.end();

	for (; it != end; ++it)
		it->CollectFeatures(featureSet);
}


inline void Cloud::ResetCounters()
{
  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();

  for (; it != end; ++it)
    it->ResetCounters();
}


inline void Cloud::SetMistakes(int mistakes)
{
  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();

  for (; it != end; ++it)
    it->SetMistakes(mistakes);
}


inline void Cloud::ShowStatistics( Counter total )
{
  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();

  for (; it != end; ++it)
    it->ShowStatistics(total);
}


inline void Cloud::Show(ostream* out)
{
  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();

  for (; it != end; ++it)
  {
    *out << "Target " << it->targetID << ":\n"
         << "internal activation: " << it->InternalActivation()
         << "   log(prior) = " << it->priorProbability << endl;
    it->ShowFeatures(out);
  }
}


inline bool Cloud::operator==( const Cloud& rhs ) const
{
  return activation == rhs.activation;
}


inline bool Cloud::operator!=( const Cloud& rhs ) const
{
  return activation != rhs.activation;
}


inline bool Cloud::operator<( const Cloud& rhs ) const
{
  return activation < rhs.activation;
}


inline bool Cloud::operator<=( const Cloud& rhs ) const
{
  return activation <= rhs.activation;
}


inline bool Cloud::operator>( const Cloud& rhs ) const
{
  return activation > rhs.activation;
}


inline bool Cloud::operator>=( const Cloud& rhs ) const
{
  return activation >= rhs.activation;
}


class VectorCloudIterator_Bool
{
public:
   vector<Cloud>::iterator VCIterator;
   bool not_active;
   VectorCloudIterator_Bool() : not_active(true) { }
   VectorCloudIterator_Bool(vector<Cloud>::iterator &i, bool b = true)
     : VCIterator(i), not_active(b) { }
};

// /*
//    Looks like it's faster to use a regular map here.  I have no idea why.
// #if defined(HASH_MAP) && !defined(WIN32)
//   #ifdef __GNUC__
//     #if __GNUC__ < 3
//       #include <hash_map.h>
//       namespace SGI { using ::hash_map; }; // inherit globals
//     #else
//       #include <ext/hash_map>
//       #if __GNUC_MINOR__ == 0
//         namespace SGI = std;               // GCC 3.0
//       #else
//         namespace SGI = ::__gnu_cxx;       // GCC 3.1 and later
//       #endif
//     #endif
//   #else      // ... there are other compilers, right?
//     #include <hash_map>
//     namespace SGI = std;
//   #endif

// typedef SGI::hash_map<FeatureID, VectorCloudIterator_Bool> TargetCloudMap;
// #else

#include <map>
typedef map<FeatureID, VectorCloudIterator_Bool> TargetCloudMap;

//#endif

#endif



