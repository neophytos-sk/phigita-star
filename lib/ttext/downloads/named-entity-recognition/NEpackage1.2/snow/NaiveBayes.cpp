//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: NaiveBayes.cpp                                =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#include "NaiveBayes.h"
#include "Target.h"
#include "GlobalParams.h"
#include <iomanip>
#include <math.h>


// Presents an example to the Target's classifier.  The return value indicates
// whether the Target's classifier made a mistake on this example (and had its
// weight vector updated).  Return of true indicates a mistake and update,
// otherwise false.
bool NaiveBayes::PresentExample( Target& tar, Example& ex )
{
  int i;
  Target::FeatureMap::iterator f;

  // Only count during the first cycle through the training data.  A higher
  // cycle can be reached if there's another algorithm in this cloud.
  if (globalParams.currentCycle <= 1)
  {    
    // Reset activation flags
    tar.externalActivation = ex.HasTarget(tar.targetID);
    tar.internalActivation = 0.0;

    // Update the active / non-active counters
    if (tar.externalActivation) ++tar.activeCount;
    else
    {
      ++tar.nonActiveCount;
      return false;
    }

    for (i = 0; i < ex.features.Size(); ++i)
    {
      if (tar.FeatureIsLinkable(ex.features[i].id))
      {
        // this feature already exist?
        if ((f = tar.features.find(ex.features[i].id)) != tar.features.end())
          // Yes, count it (we know it is a positive example)
          ++(f->second.activeCount);
        else
        {
          // No, create it
          if (globalParams.verbosity >= VERBOSE_MAX)
            *globalParams.pResultsOutput << "Naive Bayes adding feature ("
                                         << ex.features[i].id
                                         << ") to target (" << tar.targetID
                                         << ")\n";

          // Add the feature
          tar.features.insert(make_pair(ex.features[i].id, MinimalFeature()));
          ++tar.features[ex.features[i].id].activeCount;
        }
      } 
    }
  }

  // Naive Bayes is not a mistake driven learner, so always return false.
  return false;
}


void NaiveBayes::TrainingComplete( Target& tar )
{
  double priorProb = (double)tar.activeCount
                     / (tar.activeCount + tar.nonActiveCount);

  // Calculate the prior
  if (priorProb != 0) tar.priorProbability = log(priorProb);
  else tar.priorProbability = -100000000;

  Target::FeatureMap::iterator it = tar.features.begin();
  Target::FeatureMap::iterator end = tar.features.end();

  // If tar.activeCount == 0, then tar.features is empty, so
  // it->second.activeCount can never be less than 1.
  for (; it != end; ++it)
    it->second.weight = log((double)it->second.activeCount
                            / (double)tar.activeCount);
}


void NaiveBayes::Show( ostream* out )
{
  *out << "Naive Bayes: (" << setprecision(4) << defaultWeight
       << ") Targets: ";
  targetIds.Show(out);
  *out << endl;
}


void NaiveBayes::Read( ifstream& in )
{
  in >> defaultWeight >> threshold;

  if (globalParams.verbosity >= VERBOSE_MED)
  {
    *globalParams.pResultsOutput << "\nCreated:";
    Show(globalParams.pResultsOutput);
  }
}


void NaiveBayes::Write( ofstream& out )
{
  if (globalParams.verbosity >= VERBOSE_MED)
    Show(globalParams.pResultsOutput);

#ifdef WIN32
  // This looks weird, but it is a work around for the NT version.  Due to a
  // bug in MSVC 5.0 you have to call the insertion operator explicitly.
  operator<<(out, "naivebayes");

  out << ' ' << index << ' ' << defaultWeight << ' ' << threshold << endl;
#else
  out << "naivebayes " << index << ' ' << defaultWeight << ' ' << threshold
      << endl;
#endif
}


void NaiveBayes::SetTargetActivation( Target& tar, Example& ex )
{
  Target::FeatureMap::iterator f;

  tar.externalActivation = ex.HasTarget(tar.targetID);
  tar.internalActivation = 0.0;

  for (int i = 0; i < ex.features.Size(); ++i)
  {
    // Does this feature have a weight?
    if ((f = tar.features.find(ex.features[i].id)) != tar.features.end())
      tar.internalActivation += ex.features[i].strength * f->second.weight;
    else
    {
      // This is smoothing factor for features which had active counts of 0.
      // Note -=.
      if (tar.FeatureIsLinkable(ex.features[i].id))
        tar.internalActivation -= ex.features[i].strength
                                  * globalParams.bayesSmoothing;
    }
  }

  tar.internalActivation += tar.priorProbability;
  tar.internalActivation = exp(tar.internalActivation);
}


double NaiveBayes::ReturnNormalizedActivation( Target& tar )
{
  return tar.internalActivation * tar.Confidence();
}

