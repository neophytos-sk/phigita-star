//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Cloud.cpp                                     =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#include "Cloud.h"
#include "GlobalParams.h"
#include "Winnow.h"
#include "Perceptron.h"
#include "NaiveBayes.h"
#include <string>
#include <algorithm>
#include <math.h>

using namespace std;

/*
double Cloud::ReturnActivation()
{
  // Before calling this function, PreparetoRank() should be called to set the
  // target activations

  activation = 0;

  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();


  for (it = targets.begin(); it != end; ++it)
    activation += it->InternalActivation();

  return activation;
}


double Cloud::ReturnNormalizedActivation()
{
  // Before calling this function, PreparetoRank() should be called
  // to set the target activations

  double normalizedActivation = 0;

  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();

  for (it = targets.begin(); it != end; ++it)
    normalizedActivation += it->PAlgorithm()->ReturnNormalizedActivation(*it);

  return normalizedActivation;
}
*/

Cloud::Cloud(const Cloud & cl) : globalParams(cl.globalParams) {

    targetID = cl.targetID;
    targets = cl.targets;
    // The activation and normalizedActivation member variables added for the
    // constraint classification implementation.
    activation = cl.activation;
    normalizedActivation = cl.normalizedActivation;
}

Cloud & Cloud::operator=(const Cloud & rhs){
  if(this != &rhs){
    globalParams = rhs.globalParams;
    targetID = rhs.targetID;
    targets = rhs.targets;
    activation = rhs.activation;
    normalizedActivation = rhs.normalizedActivation;

    return *this;
  }
}

bool Cloud::PresentExample( Example& ex )
{
  bool mistakes = false;
  activation = 0;

  // Walk through targets and present the example
  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();
  for (; it != end; ++it)
  {
    if (it->PresentExample(ex)) mistakes = true;
    // When constraint classification is enabled, the network needs activation
    // values in order to decide which targets should be promoted and demoted.
    // Therefore, the next few lines were added.
    if (globalParams.constraintClassification)
    {
      activation += it->InternalActivation();
      normalizedActivation +=
        it->PAlgorithm()->ReturnNormalizedActivation(*it);
    }
  }

  return mistakes;
}


void Cloud::PreparetoRank(Example& ex)
{
  // Walk through targets and set the internal activation
  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();
  for (activation = normalizedActivation = 0; it != end; ++it)
  {
    it->PAlgorithm()->SetTargetActivation(*it, ex);
    activation += it->InternalActivation();
    normalizedActivation += it->PAlgorithm()->ReturnNormalizedActivation(*it);
  }
}


void Cloud::AddTarget( const Target& target )
{
  targets.push_back(target);
  targets.back().onlyTargetInCloud = targets.size() == 1;
  if (targets.size() == 2) targets[0].onlyTargetInCloud = false;
}


void Cloud::Write( ofstream& out )
{
  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();
  for (; it != end; ++it)
    it->Write(out);
}


void Cloud::ShowSize()
{
  *globalParams.pResultsOutput << "Networks for " << targetID << ":\n";

  TargetVector::iterator it = targets.begin();
  TargetVector::iterator end = targets.end();

  int i = 1;
  for (; it != end; ++it, ++i)
  {
    *globalParams.pResultsOutput << i << " - ";
    it->ShowSize();
  }
}

