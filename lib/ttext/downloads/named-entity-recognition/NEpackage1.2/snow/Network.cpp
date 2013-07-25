//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Network.cpp                                   =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================

//#define TRAIN_WITH_NORMALIZED_ACTIVATION
// Uncomment the previous line if you want the constraint classification
// decision to be based on normalized activations as opposed to regular
// activations.  By default, the line is commented.

#define INITIAL_WEIGHT_FACTOR 3

#include "GlobalParams.h"
#include "Network.h"
#include "Winnow.h"
#include "Perceptron.h"
#include "NaiveBayes.h"
#include "Cloud.h"
#include <string>
#include <typeinfo>
#include <algorithm>
#include <float.h>
#include <math.h>

bool Network::CreateStructure()
{
  bool result = true;

  char* networkSpec =
    new char[globalParams.algorithmSpecification.length() + 1];
  if (networkSpec != NULL)
  {
    // Make a working copy
    strcpy(networkSpec, globalParams.algorithmSpecification.c_str());
    if (globalParams.verbosity != VERBOSE_QUIET)
      cout << "Network Spec -> " << networkSpec << endl;

    char* token = strtok(networkSpec, ":(, \t\n\r");
    char* delim;
    int index = 0;

    while (token != NULL)
    {
      // token must now be an algorithm type
      if (tolower(*token) == 'w')
      {
        double alpha = 1.35;
        double beta = 0.8;
        double threshold = 4.0;
#ifdef AVERAGE_EXAMPLE_SIZE
        double defaultWeight = (globalParams.rawMode)
                                 ? 1
                                 : (INITIAL_WEIGHT_FACTOR * threshold
                                     / globalParams.averageExampleSize);
#else
        double defaultWeight = (globalParams.rawMode)
                                 ? 1
                                 : (INITIAL_WEIGHT_FACTOR * threshold
                                     / globalParams.maxExampleSize);
#endif

        token = token + strlen(token) + 1;

        // if only a target set is specified, keep defaults
        if ((*token) == ':') delim = token;
        else
        {
          // look for commas to see what parameters the user gave
          alpha = strtod(token, &delim);
          token = delim + strspn(delim, ":, \t\n\r");
          beta = strtod(token, &delim);

          if (*delim == ',')
          {
            token = delim + strspn(delim, ":, \t\n\r");
            threshold = strtod(token, &delim);

            if (*delim == ',')
            {
              token = delim + strspn(delim, ":, \t\n\r");
              defaultWeight = strtod(token, &delim);
            }
#ifdef AVERAGE_EXAMPLE_SIZE
            else
              defaultWeight = (globalParams.rawMode)
                               ? 1
                               : (INITIAL_WEIGHT_FACTOR * threshold
                                   / globalParams.averageExampleSize);
#else
            else
              defaultWeight = (globalParams.rawMode)
                               ? 1
                               : (INITIAL_WEIGHT_FACTOR * threshold
                                   / globalParams.maxExampleSize);
#endif
          }
        }

        // make sure a target set was specified
        if (*delim == ':')
        {
          token = delim + strspn(delim, ":, \t\n\r");
          if (*token == ')')
          {
            cerr << "Error: No target IDs specified for Winnow.\n";
            return false;
          }

          token = strtok(token, ")");
          delim += strlen(token) + 2;
        }
        else
        {
          delim += strspn(delim, ":) \t\n\r");
          cerr << "Error: No target set given for Winnow.\n";
          return false;
        }

        if (*delim == ',')
        {
          Winnow* pWin = new Winnow(alpha, beta, threshold, 
				    defaultWeight, globalParams);
          pWin->targetIds.Parse(token);
          pWin->index = index;

          algorithms.push_back(pWin);
        }
        else
        {
          delim = token;
          token = strtok(NULL, ")");
          cerr << "Failed to parse Winnow spec '" << delim << '(' << token
               << ")'\n\n";
          result = false;
        }
      }
      else if (tolower(*token) == 'p')
      {
        token = token + strlen(token) + 1;

        double learningRate = 0.1;
        double threshold = 4.0;
#ifdef AVERAGE_EXAMPLE_SIZE
        double defaultWeight = (globalParams.rawMode)
                                ? 0
                                : (INITIAL_WEIGHT_FACTOR * threshold
                                    / globalParams.averageExampleSize);
#else
        double defaultWeight = (globalParams.rawMode)
                                ? 0
                                : (INITIAL_WEIGHT_FACTOR * threshold
                                    / globalParams.maxExampleSize);
#endif

        if ((*token) == ':') delim = token;
        else
        {
          learningRate = strtod(token, &delim);

          if (*delim == ',')
          {
            token = delim + strspn(delim, ", \t\n\r");
            threshold = strtod(token, &delim);

            if (*delim == ',')
            {
              token = delim + strspn(delim, ", \t\n\r");
              defaultWeight = strtod(token, &delim);
            }
#ifdef AVERAGE_EXAMPLE_SIZE
            else
              defaultWeight = (globalParams.rawMode)
                               ? 0
                               : (INITIAL_WEIGHT_FACTOR * threshold
                                   / globalParams.averageExampleSize);
#else
            else
              defaultWeight = (globalParams.rawMode)
                               ? 0
                               : (INITIAL_WEIGHT_FACTOR * threshold
                                   / globalParams.maxExampleSize);
#endif
          }
        }

        if (*delim == ':')
        {
          token = delim + strspn(delim, ":, \t\n\r");
          if (*token == ')')
          {
            cerr << "Error: No target IDs specified for Perceptron.\n";
            return false;
          }

          token = strtok(token, ")");
          delim += strlen(token) + 2;
        }
        else
        {
          delim += strspn(delim, ":) \t\n\r");
          cerr << "Error: No target IDs specified for Perceptron.\n";
          return false;
        }

        if (*delim == ',')
        {
          Perceptron* pPer = new Perceptron(learningRate, threshold,
                                            defaultWeight, globalParams);
          pPer->targetIds.Parse(token);
          pPer->index = index;

          algorithms.push_back(pPer);
        }
        else
        {
          delim = token;
          token = strtok(NULL, ")");
          cerr << "Failed to parse Perceptron spec '" << delim << '('
               << token << ")'\n\n";
          result = false;
        }
      }
      else if (tolower(*token) == 'b')
      {
        delim = token + strlen(token) + 1;
        token = delim + strspn(delim, ":, \t\n\r");
        if (*token == ')')
        {
          cerr << "Error: No target IDs specified for Naive Bayes.\n";
          return false;
        }

        token = strtok(token, ")");
        delim += strlen(token) + 2;

        if (*delim == ',')
        {
          NaiveBayes* pBay = new NaiveBayes(globalParams);
          pBay->targetIds.Parse(token);
          pBay->index = index;

          algorithms.push_back(pBay);
        }
        else
        {
          delim = token;
          token = strtok(NULL, ")");
          cerr << "Failed to parse Naive Bayes spec '" << delim << '('
               << token << ")'\n\n";
          result = false;
        }
      }

      ++index;
      token = strtok(delim, " (),\t\n\r");
    }

    CreateClouds();
    if (globalParams.constraintClassification)
    {
      globalParams.targetIdsArray = new FeatureID[clouds.size()];
      CloudVector::iterator it;
      CloudVector::iterator end = clouds.end();
      int i;
      for (i = 0, it = clouds.begin(); it != end; ++it, ++i)
      {
        TargetIDToCloud[it->Id()] = VectorCloudIterator_Bool(it);
        globalParams.targetIdsArray[i] = it->Id();
      }
    }
  }
  else
  {
    cerr << "Error:\n";
    cerr << "Failed to allocate work buffer for parsing network specification"
         << "\n";
    result = false;
  }

  return result;
}


void Network::CreateClouds()
{
  AlgorithmVector activeAlgorithms;

  TargetIdSet::const_iterator it = globalParams.targetIds.begin();
  TargetIdSet::const_iterator end = globalParams.targetIds.end();

  // Create one new Cloud for each TargetId
  for (; it != end; ++it)
  {
    activeAlgorithms.clear();
    AlgorithmVector::iterator algIt = algorithms.begin();
    AlgorithmVector::iterator algEnd = algorithms.end();

    for (; algIt != algEnd; ++algIt)
    {
      if ( (*algIt)->targetIds.find(*it) != ( (*algIt)->targetIds.end() ) )
        activeAlgorithms.push_back(*algIt);
    }

    clouds.push_back(Cloud(*it, activeAlgorithms, globalParams));
    clouds.back().SetMistakes(0);
  }
}


bool Network::PresentExample( Example& ex )
{
  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator clouds_end = clouds.end();
  TargetIdSet::iterator targets_end = ex.targets.end();
  bool targets_empty = ex.targets.empty();
  bool mistakes = false;

  for (; it != clouds_end; ++it)
  {
    if (targets_empty || ex.targets.find(it->Id()) != targets_end)
      // The following call to PresentExample will always return false if
      // globalParams.constraintClassification = true
      if (it->PresentExample(ex)) mistakes = true;
  }

  if (globalParams.constraintClassification
      && (globalParams.currentCycle > 1 || !globalParams.noFirstCycleUpdate
        || globalParams.currentCycle == 0))
  { // Make the update decision based on relative activation levels
    int i, currentID = 0, subordinateID, targets = ex.features.Targets();
    CloudVector::iterator currentCloud, subordinateCloud;

    if (globalParams.conservativeCC)
    {
      double highestActivation = DBL_MIN;
      for (it = clouds.begin(); it != clouds_end; ++it)
#ifdef TRAIN_WITH_NORMALIZED_ACTIVATION
        if (it->NormalizedActivation() > highestActivation)
#else
        if (it->Activation() > highestActivation)
#endif
        {
#ifdef TRAIN_WITH_NORMALIZED_ACTIVATION
          highestActivation = it->NormalizedActivation();
#else
          highestActivation = it->Activation();
#endif
          subordinateCloud = it;
        }

      currentCloud =
        TargetIDToCloud[ex.features[currentID].id].VCIterator;
      if (subordinateCloud->Id() != ex.features[0].id
          && ConstraintClassificationUpdate(ex, currentCloud,
                                            subordinateCloud,
                                            ex.features[currentID].id,
                                            subordinateCloud->Id()))
        mistakes = true;
    }
    else
    {
      // For all target IDs whose activations should be higher than another
      // target ID's
      for (subordinateID = 1; subordinateID < targets;
           ++currentID, ++subordinateID)
      {
        currentCloud =
          TargetIDToCloud[ex.features[currentID].id].VCIterator;
        subordinateCloud =
          TargetIDToCloud[ex.features[subordinateID].id]
            .VCIterator;
        if (ConstraintClassificationUpdate(ex, currentCloud, subordinateCloud,
                                           ex.features[currentID].id,
                                           ex.features[subordinateID].id))
          mistakes = true;
      }

      if (currentID < targets)
      {
        // Find the cloud that corresponds to the remaining target ID.
        if (currentID > 0) currentCloud = subordinateCloud;
        else
          currentCloud =
            TargetIDToCloud[ex.features[currentID].id]
            .VCIterator;

        // Find out which targets are active first.
        for (i = 0; i < clouds.size(); ++i)
          TargetIDToCloud[globalParams.targetIdsArray[i]]
            .not_active = true;
        for (currentID = 0; currentID < ex.features.Targets(); ++currentID)
          TargetIDToCloud[ex.features[currentID].id].not_active =
            false;

        // Run through all target IDs that weren't looked at previously,
        // treating them as subordinate to the remaining target ID.
        for (i = 0; i < clouds.size(); ++i)
        {
          if (TargetIDToCloud[globalParams.targetIdsArray[i]]
              .not_active)
          {
            subordinateCloud =
              TargetIDToCloud[globalParams.targetIdsArray[i]]
                .VCIterator;
            if (ConstraintClassificationUpdate(ex, currentCloud,
                                               subordinateCloud,
                                               ex.features[currentID].id,
                                               ex.features[subordinateID].id))
              mistakes = true;
          }
        }
      }
    }
  }

  return mistakes;
}

bool Network::PresentInteractiveExample( Example& ex )
{
  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator clouds_end = clouds.end();
  TargetIdSet::iterator targets_end = ex.targets.end();
  bool targets_empty = ex.targets.empty();
  bool mistakes = false;

  if (targets_empty)
    return mistakes;

  int count=0;
  for (; it != clouds_end; ++it)
  {
    if (ex.targets.find(it->Id()) != targets_end) 
    {
      // The following call to PresentExample will always return false if
      // globalParams.constraintClassification = true, OR 
      // globalParams.runMode == MODE_INTERACTIVE
      if (it->PresentExample(ex)) mistakes = true;

      if (ex.command == 'p') // promote
	{
	  it->Update(ex, true);
	}
      else if (ex.command == 'd') // demote
	it->Update(ex, false);
    }
  }

  return mistakes;
}


bool Network::ConstraintClassificationUpdate(Example& ex,
                                      CloudVector::iterator& currentCloud,
                                      CloudVector::iterator& subordinateCloud,
                                      FeatureID currentID,
                                      FeatureID subordinateID)
{
  bool mistakes = false;

  if (currentCloud == clouds.end() || subordinateCloud == clouds.end())
  {
    cerr << "Fatal Error:\n";
    if (currentCloud == clouds.end())
      cerr << "  Target " << currentID
           << " specified in target order, but not found in target set.\n";
    if (subordinateCloud == clouds.end())
      cerr << "  Target " << subordinateID
           << " specified in target order, but not found in target set.\n";
    exit(1);
  }

  // Update if the cloud that should have been higher turned out to be lower.
#ifdef TRAIN_WITH_NORMALIZED_ACTIVATION
  if (subordinateCloud->NormalizedActivation()
      >= currentCloud->NormalizedActivation())
#else
    if (subordinateCloud->Activation() >= currentCloud->Activation())
#endif
    {
      if (globalParams.verbosity >= VERBOSE_MED)
      {
        if (globalParams.verbosity == VERBOSE_MED)
          *globalParams.pResultsOutput << endl;
        *globalParams.pResultsOutput
          << "Target " << subordinateID << " is more activated ("
          << subordinateCloud->Activation() << ", "
          << subordinateCloud->NormalizedActivation() << ") than target "
          << currentID << " (" << currentCloud->Activation() << ", "
          << currentCloud->NormalizedActivation() << ").\n"
          << "Demoting target " << subordinateID << " and promoting target "
          << currentID << ".\n";
        if (globalParams.verbosity > VERBOSE_MED)
          *globalParams.pResultsOutput << endl;
      }

      subordinateCloud->Update(ex, false);  // false = demotion
      currentCloud->Update(ex, true);       // true = promotion
      mistakes = true;
    }

  return mistakes;
}


void Network::TrainingComplete()
{
  // Walk through clouds
  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator end = clouds.end();
  for (; it != end; ++it)
    it->TrainingComplete();
}


void Network::PerformPercentageEligibility()
{
  // Walk through clouds
  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator end = clouds.end();
  for (; it != end; ++it)
    it->PerformPercentageEligibility();
}


void Network::Discard()
{
  if (globalParams.discardMethod != DISCARD_NONE)
  {
    if (globalParams.discardMethod == DISCARD_ABS)
    {
      CloudVector::iterator it = clouds.begin();
      CloudVector::iterator end = clouds.end();
      for (; it != end; ++it)
        it->Discard();
    }
    else
    {
      // NOTE: This method really only makes sense for Winnow.  We'll allow it
      // for others but it probably won't yield good results for others.

      CloudVector::iterator it = clouds.begin();
      CloudVector::iterator end = clouds.end();
#if defined(FEATURE_HASH) && !defined(WIN32)
      hash_set<FeatureID> allFeatures;
      hash_set<FeatureID>::const_iterator feat;
#else
      set<FeatureID> allFeatures;
      set<FeatureID>::const_iterator feat;
#endif

      for (; it != end; ++it)
        it->CollectFeatures(allFeatures);

      for (feat = allFeatures.begin(); feat != allFeatures.end(); ++feat)
      {
        it = clouds.begin();
        double min = 1.0e300;
        int dups = 0;

        for (it = clouds.begin(); it != end; ++it)
          it->FindMinimumWeight(*feat, min, dups);

        if (!dups)
        {
          for (it = clouds.begin(); it != end; ++it)
            it->Discard(*feat, min);
        }
      }
    }
  }
}


void Network::RankTargets( Example& ex, TargetRanking& rank )
{
  /* The Naive Bayes PrepareToRank function currently does nothing.
     NaiveBayes nb;
     AlgorithmVector::iterator algIt = algorithms.begin();
     AlgorithmVector::iterator algEnd = algorithms.end();

     for (; algIt != algEnd; ++algIt)
     if (typeid(nb) == typeid(**algIt))
     dynamic_cast<NaiveBayes*>(*algIt)->PrepareToRank();
   */

  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator end = clouds.end();

  double softmaxDenominator = 0;
  TargetIdSet::iterator targets_end = ex.targets.end();
  int size = ex.targets.size(), ranked_targets = 0;
  bool empty = ex.targets.empty();
  for (; it != end && (empty || ranked_targets < size); ++it)
  {
    if (empty || ex.targets.find(it->Id()) != targets_end)
    {
      ++ranked_targets;
      it->PreparetoRank(ex);
      softmaxDenominator += exp(it->Activation());
    }
  }

  for (ranked_targets = 0, it = clouds.begin();
       it != end && (empty || ranked_targets < size); ++it)
  {
    if (empty || ex.targets.find(it->Id()) != targets_end)
    {
      ++ranked_targets;

      // get the activation for the current cloud and insert it into the
      // ranking
      TargetRank tr(it->Id(), it->NormalizedActivation(), it->Activation(),
                    exp(it->Activation()) / softmaxDenominator);
      rank.push_back(tr);
    }
  }
}


void Network::Show(ostream* out)
{
  AlgorithmVector::iterator algIt = algorithms.begin();
  AlgorithmVector::iterator algEnd = algorithms.end();

  for (; algIt != algEnd; ++algIt) (*algIt)->Show(out);

  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator end = clouds.end();
  for (; it != end; ++it) it->Show(out);
}


void Network::Read( ifstream& in )
{
  string Flag;
  Target* tempTarget;

  CloudVector::iterator cloudIt = clouds.begin();
  CloudVector::iterator cloudEnd = clouds.end();

  while (!in.fail())
  {
    operator>>(in, Flag);

    if ((Flag == "conjunctions") && (!in.fail()))
    {
      string status;
      operator>>(in, status);
      if (status == "on") globalParams.generateConjunctions = CONJUNCTIONS_ON;
      else if (status == "off")
        globalParams.generateConjunctions = CONJUNCTIONS_OFF;
    }
    else if ((Flag == "target") && (!in.fail()))
    {
      tempTarget = new Target(globalParams);
      tempTarget->Read(in, algorithms);
      globalParams.targetIds.insert(tempTarget->Id());

      // step through Clouds, looking for a matching targetID
      for (cloudIt = clouds.begin(), cloudEnd = clouds.end();
           (cloudIt != cloudEnd) && (cloudIt->Id() != tempTarget->Id());
           ++cloudIt);

      if (cloudIt == cloudEnd)
      {
        // no Cloud exists with the correct targetID, so create one and add
        // the Target to it
        clouds.push_back(Cloud(tempTarget->Id(), globalParams));
        clouds.back().AddTarget(*tempTarget);
      }
      else
      {
        // we've found a Cloud with the correct targetID, so just add the new
        // Target to it
        cloudIt->AddTarget(*tempTarget);
      }

      delete tempTarget;
    }
  }

  if (globalParams.onlineLearning && globalParams.constraintClassification)
  {
    globalParams.targetIdsArray = new FeatureID[clouds.size()];
    CloudVector::iterator it;
    CloudVector::iterator end = clouds.end();
    int i;
    for (i = 0, it = clouds.begin(); it != end; ++it, ++i)
    {
      TargetIDToCloud[it->Id()] = VectorCloudIterator_Bool(it);
      globalParams.targetIdsArray[i] = it->Id();
    }
  }
}


void Network::Write( ofstream& out )
{
  if (globalParams.generateConjunctions == CONJUNCTIONS_ON)
#ifdef WIN32
    // This looks weird, but it is a work around for the NT version.  Due to a
    // bug in MSVC 5.0 you have to call the insertion operator explicitly.
    operator<<(out, "conjunctions on\n");
#else
  out << "conjunctions on\n";
#endif

  // Walk through clouds and write them out
  CloudVector::iterator it = clouds.begin();
  CloudVector::iterator end = clouds.end();
  for (; it != end; ++it)
  {
    it->Write(out);
    out << endl;
  }
}


