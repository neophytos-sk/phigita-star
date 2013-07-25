// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Target.h                                      =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//===========================================================

#ifndef TARGET_H__
#define TARGET_H__

#include "MinimalFeature.h"
#include "LearningAlgorithm.h"
#include <vector>

#if defined(HASH_MAP) && !defined(WIN32)
  #ifdef __GNUC__
    #if __GNUC__ < 3
      #include <hash_map.h>
      namespace SGI { using ::hash_map; }; // inherit globals
    #else
      #include <ext/hash_map>
      #if __GNUC_MINOR__ == 0
        namespace SGI = std;               // GCC 3.0
      #else
        namespace SGI = ::__gnu_cxx;       // GCC 3.1 and later
      #endif
    #endif
  #else      // ... there are other compilers, right?
    #include <hash_map>
    namespace SGI = std;
  #endif
#else
#include <map>
#endif

// I've found that hash_set performs worse than set here.  If you want to try
// it, you'll probably have to do change the simple include statement below to
// something similar to what's been done with hash_map above.
#if defined(FEATURE_HASH) && !defined(WIN32)
#include <hash_set>
#else
#include <set>
#endif

// The following two constants are involved in the target confidence update
// formula employed by the Winnow and Perceptron update rules.  Their ratio
// controls the magnitude of the initial confidence adjustment (when A/B is
// small, so is the initial confidence adjustment), and their magnitude
// controls the rate at which the magnitude of confidence adjustments
// decreases for each successive mistake (as they get larger, the rate gets
// smaller).
#define CONFIDENCE_CONSTANT_A 2
#define CONFIDENCE_CONSTANT_B 100

class GlobalParams;

using namespace std;

typedef vector<LearningAlgorithm*> AlgorithmVector;

class Target
{
  public:
  //Target();
    Target(GlobalParams & gp_);
    Target( FeatureID id, LearningAlgorithm* pAlg, bool only,
	    GlobalParams & gp_ );

    Target( const Target & rhs );

    bool PresentExample( Example& ex );
    void PerformPercentageEligibility();
    void TrainingComplete();
    void Discard();
    void Discard( FeatureID id, double delta );
    bool FeatureIsLinkable(FeatureID f);

    Target & operator=( const Target & rhs );
    bool operator==( const Target& rhs ) const;
    bool operator!=( const Target& rhs ) const;
    bool operator<( const Target& rhs ) const;
    bool operator<=( const Target& rhs ) const;
    bool operator>( const Target& rhs ) const;
    bool operator>=( const Target& rhs ) const;

    void ShowStatistics( Counter total ) const;
    void ShowSize() const;
    void ShowFeatures(ostream*) const;

    LearningAlgorithm* PAlgorithm() const;
    FeatureID          Id() const;
    bool               ExternalActivation() const;
    double             InternalActivation() const;
    double             Confidence() const;
    void               NormalizeConfidence(double totalConfidence);
    double             PriorProbability() const ;
#if defined(FEATURE_HASH) && !defined(WIN32)
    void CollectFeatures( hash_set<FeatureID>& featureSet ) const;
#else
    void               CollectFeatures( set<FeatureID>& featureSet ) const;
#endif
    double             WeightOfFeature( FeatureID id ) const;
    void               ResetCounters();
    void               SetMistakes(int mistakes);

    void Read( ifstream& in , AlgorithmVector& algorithms );
    void Write( ofstream& out );

  private:
#if defined(HASH_MAP) && !defined(WIN32)
    typedef SGI::hash_map<FeatureID, MinimalFeature> FeatureMap;
#else
    typedef map<FeatureID, MinimalFeature> FeatureMap;
#endif

    FeatureID       targetID;
    bool            externalActivation;
    double          internalActivation;
    FeatureMap      features;
    Counter         activeCount;
    Counter         nonActiveCount;
    double          priorProbability;
    double          confidence;
    double          strength;
    bool            onlyTargetInCloud;
    int             mistakes;

    LearningAlgorithm*  pAlgorithm;

    GlobalParams & globalParams;

    friend class LearningAlgorithm;
    friend class Cloud;
    friend class Winnow;
    friend class Perceptron;
    friend class NaiveBayes;
};


inline Target::Target(GlobalParams & gp_)
  : targetID((FeatureID)-1), externalActivation(false),
    internalActivation(0.0), activeCount(0L), nonActiveCount(0L),
    priorProbability(1.0), confidence(1.0), strength(0),
    onlyTargetInCloud(true), mistakes(-1), pAlgorithm(NULL),
    globalParams(gp_)
{
}


inline Target::Target( FeatureID id, LearningAlgorithm* pAlg, bool only,
		       GlobalParams & gp_ )
  : targetID(id), externalActivation(false), internalActivation(0.0),
    activeCount(0L), nonActiveCount(0L), priorProbability(1.0),
    confidence(1.0), strength(0), onlyTargetInCloud(only), mistakes(-1),
    pAlgorithm(pAlg), globalParams(gp_)
{
}


inline bool Target::PresentExample( Example& ex )
{
  bool result;
  if ((result = pAlgorithm->PresentExample(*this, ex)) && mistakes >= 0)
    mistakes++;
  return result;
}


inline void Target::PerformPercentageEligibility()
{
  pAlgorithm->PerformPercentageEligibility(*this);
}


inline void Target::TrainingComplete()
{
  pAlgorithm->TrainingComplete(*this);
}


inline LearningAlgorithm* Target::PAlgorithm() const
{
  return pAlgorithm;
}


inline FeatureID Target::Id() const
{
  return targetID;
}


inline bool Target::ExternalActivation() const
{
  return externalActivation;
}


inline double Target::InternalActivation() const
{
  return internalActivation;
}


inline double Target::Confidence() const
{
  return confidence;
}


inline void Target::NormalizeConfidence(double totalConfidence) 
{   
  confidence /= totalConfidence;
}


inline double Target::PriorProbability() const
{
  return priorProbability;
}


#if defined(FEATURE_HASH) && !defined(WIN32)
inline void Target::CollectFeatures( hash_set<FeatureID>& featureSet ) const
#else
inline void Target::CollectFeatures( set<FeatureID>& featureSet ) const
#endif
{
  FeatureMap::const_iterator it = features.begin();
  for (; it != features.end(); ++it)
    featureSet.insert(it->first);
}


inline double Target::WeightOfFeature( FeatureID id ) const
{
  FeatureMap::const_iterator it = features.find(id);
  if (it != features.end() && it->second.eligibility == eligible)
    return it->second.weight;

  // This function is only called when looking for a minimum weight, so we
  // return a high weight when the feature isn't found.
  return 1e300;
}


inline void Target::ResetCounters()
{
  activeCount = 0L;
  nonActiveCount = 0L;

  externalActivation = false;
  internalActivation = 0.0;
}


inline void Target::SetMistakes(int mistakes)
{
  this->mistakes = mistakes;
}
#endif

