//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Target.cpp                                    =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//===========================================================

#include "Target.h"
#include "GlobalParams.h"
#include "Winnow.h"
#include "Perceptron.h"
#include "NaiveBayes.h"
#include <math.h>
#include <iostream>
#include <iomanip>

Target::Target(const Target & t) : 
  globalParams(t.globalParams) {
  targetID = t.targetID;
  externalActivation = t.externalActivation;
  internalActivation = t.internalActivation;
  features = t.features;
  activeCount = t.activeCount;
  nonActiveCount = t.nonActiveCount;
  priorProbability = t.priorProbability;
  confidence = t.confidence;
  strength = t.strength;
  onlyTargetInCloud = onlyTargetInCloud;
  mistakes = t.mistakes;
  pAlgorithm = t.pAlgorithm;
}


Target & Target::operator=( const Target & rhs ) {
  if( this != &rhs ) {

    globalParams = rhs.globalParams;
    targetID = rhs.targetID;
    externalActivation = rhs.externalActivation;
    internalActivation = rhs.internalActivation;
    features = rhs.features;
    activeCount = rhs.activeCount;
    nonActiveCount = rhs.nonActiveCount;
    priorProbability = rhs.priorProbability;
    confidence = rhs.confidence;
    strength = rhs.strength;
    onlyTargetInCloud = onlyTargetInCloud;
    mistakes = rhs.mistakes;
    pAlgorithm = rhs.pAlgorithm;
  }

}

void Target::Discard()
{
  // NOTE: This routine is only for the DISCARD_ABS mode, do NOT call this
  //       routine unless discardMode == DISCARD_ABS. The DISCARD_REL mode
  //       should be handled by the Network.
  double discardThreshold;
  FeatureMap::iterator feat = features.begin();

  discardThreshold = pAlgorithm->defaultWeight
                     * globalParams.discardThreshold;

  // Update the weight vector
  for (; feat != features.end(); ++feat)
  {
    if (feat->second.eligibility == eligible
        && feat->second.weight < discardThreshold)
      feat->second.eligibility = discard;
  }
}


void Target::Discard( FeatureID id, double delta )
{
  // NOTE: This routine is only for the DISCARD_REL mode, do NOT call this
  //       routine unless discardMode == DISCARD_REL. Unlike Discard above,
  //       this routine operates on the specified feature (id) only rather
  //       than processing entire weight vector.

  FeatureMap::iterator feat = features.find(id);

  // Update the feature weight
  if (feat != features.end() && feat->second.eligibility == eligible)
  {
    feat->second.weight -= delta;
    if (feat->second.weight == 0.0) feat->second.eligibility = discard;
  }    
}


bool Target::FeatureIsLinkable(FeatureID f)
{
  return f != targetID
         && (!globalParams.multipleLabels
             || globalParams.targetIds.find(f)
                == globalParams.targetIds.end());
}


void Target::ShowStatistics( Counter total ) const
{
  *globalParams.pResultsOutput << "Statistics for target (" << targetID
                               << ")\n";
  *globalParams.pResultsOutput << "   Active: " << activeCount << " / "
                               << (activeCount + nonActiveCount) << endl;
}


void Target::ShowSize() const
{
  int count = 0;

  if (globalParams.runMode == MODE_TRAIN)
  {
    FeatureMap::const_iterator feat = features.begin();

    for ( ; feat != features.end(); ++feat)
      if (feat->second.eligibility == eligible) ++count;
  }
  else count = features.size();

  *globalParams.pResultsOutput << "contains " << count
                               << " eligible features.\n";
}


void Target::ShowFeatures(ostream* out) const
{
  FeatureMap::const_iterator it = features.begin();
  FeatureMap::const_iterator end = features.end();

  for (; it != end; ++it)
    *out << "  " << it->first << " -> " << it->second.weight << endl;
}


void Target::Read(ifstream& in, AlgorithmVector& algorithms)
{
  features.clear();

  // Read the target ID and prior Probability
  in >> targetID >> priorProbability >> confidence >> activeCount
     >> nonActiveCount;

  // Create the algorithm object
  string networkType;
  char delim;
  int index;  

  operator>>(in, networkType);
  delim = in.get();

  in >> index; 

  // Check for an algorithm with the same index
  AlgorithmVector::iterator algIt = algorithms.begin();
  while ((algIt != algorithms.end()) && ((*algIt)->index != index)) 
    ++algIt;

  // no algorithm with the current index exists, so create it
  if (algIt == algorithms.end()) 
  { 
    if (networkType == "winnow") 
      pAlgorithm = new Winnow(globalParams);
    else if (networkType == "perceptron") 
      pAlgorithm = new Perceptron(globalParams);
    else if (networkType == "naivebayes") 
      pAlgorithm = new NaiveBayes(globalParams);

    pAlgorithm->Read(in);
    pAlgorithm->index = index;
    pAlgorithm->targetIds.insert(targetID);
    algorithms.push_back(pAlgorithm);
  } 
  else
  { 
    // an algorithm with the current index exists, so use that 
    // algorithm and skip the rest of the input line
    (*algIt)->targetIds.insert(targetID);
    pAlgorithm = *algIt;
    char skipline[80];
    in.getline(skipline, 80);
  }

  if (in.fail())
  {
    in.clear();
    cerr << "Failed reading target!\n";
    return;
  }

  if (globalParams.verbosity >= VERBOSE_MED)
    *globalParams.pResultsOutput << "\nCreated target " << targetID << endl;

  FeatureID id;
  double weight;
  unsigned long count;
  int skip;
  int updates;
  // use skip and delim to skip over unnecessary values and colons 
  in >> skip >> delim >> skip >> delim >> id >> delim >> count >> updates
     >> weight;

  if (globalParams.eligibilityMethod == ELIGIBILITY_COUNT)
  {
    while (!in.fail())
    {
      features.insert(
          make_pair(
            id,
            MinimalFeature(
              weight,
              count,
              (count >= globalParams.eligibilityThreshold)
                ? eligible : pending,
              updates)));
      // use skip and delim to skip over unnecessary values and colons 
      in >> skip >> delim >> skip >> delim >> id >> delim >> count >> updates
         >> weight;
    }
  }
  else
  {
    while (!in.fail())
    {
      features.insert(
          make_pair(id, MinimalFeature(weight, count, eligible, updates)));
      // use skip and delim to skip over unnecessary values and colons 
      in >> skip >> delim >> skip >> delim >> id >> delim >> count >> updates
         >> weight;
    }

    PerformPercentageEligibility();
  }

  in.clear();
}


void Target::Write( ofstream& out )
{
  if (globalParams.verbosity >= VERBOSE_MED)
    *globalParams.pResultsOutput << "\nFeatures for target (" << targetID
                                 << ")\n";

  // Write the target label
#ifdef WIN32    
  out << endl;
  operator<<(out, "target ");
  out << targetID << ' '
      << setprecision(12) << priorProbability << ' '
      << setprecision(12) << confidence << ' ' 
      << activeCount << ' '
      << nonActiveCount << ' ';
  pAlgorithm->Write(out);
#else
  out.clear();
  out << "target " << targetID << ' ';
  out.setf(ios::scientific);
  out << setprecision(12) << priorProbability << ' ';
  out.setf(ios::fixed);
  out << confidence << ' ' << activeCount << ' ' << nonActiveCount << ' ';
  pAlgorithm->Write(out);
#endif
  // Write-out each feature and its parameters
  FeatureMap::const_iterator it = features.begin();
  FeatureMap::const_iterator end = features.end();
  for (; it != end; ++it)
  {
    if (it->second.eligibility == eligible
        || (it->second.eligibility == pending
            && globalParams.writePendingFeatures))
    {
      if (globalParams.verbosity >= VERBOSE_MED)
        *globalParams.pResultsOutput << " " << it->first << " -> "
                                     << it->second.weight << endl;

      out << targetID << " : " << pAlgorithm->index << " : " 
          << setw(10) << it->first << " : "
          << setw(10) << it->second.activeCount << " "
          << setw(10) << it->second.updates << " "
          << setw(18) << setprecision(10) << it->second.weight << endl;
    }
  }
}

