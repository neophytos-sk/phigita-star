// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: GlobalParams.h                                =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef GLOBALPARAMS_H__
#define GLOBALPARAMS_H__

#define AVERAGE_EXAMPLE_SIZE

#include <string>
#include <vector>
#include <numeric>
#include <iomanip>
#include "TargetIdSet.h"

using namespace std;


class ThickSeparator
{
  public:
    double positive;
    double negative;

    ThickSeparator() : positive(0), negative(0) { }
};


class GlobalParams
{
  public:
    GlobalParams();
    ~GlobalParams() { if (targetIdsArray) delete [] targetIdsArray; }

    RunMode               runMode;
    RunMode               runMode_old; // Jakob:to switch back and forth between mode in server mode
#ifdef SERVER_MODE_
    int                   serverPort;
#endif
    Counter               currentCycle;
    Counter               cycles;
    DiscardMethod         discardMethod;
    EligibilityMethod     eligibilityMethod;
    PredictMethod         predictMethod; 
    double                discardThreshold;
    Counter               eligibilityThreshold;
    Counter               curveInterval;
    TargetIdSet           targetIds;
    string                inputFile;
    string                outputFile;
    ostream*              pResultsOutput;
    string                testFile;
    string                networkFile;
    string                optionalNetworkFile; //JAKOB:save the network in server mode to an arbitray filename
    string                errorFile;
    string                algorithmSpecification;
    string                evalExample;
    bool                  sparseNetwork;
    bool                  noFirstCycleUpdate;
    bool                  onlineLearning;
    Verbosity             verbosity;
    double                smoothing;
    double                bayesSmoothing;
    double                predictionThreshold;
    double                eligibilityPercentage;
#ifdef AVERAGE_EXAMPLE_SIZE
    double                averageExampleSize;
#else
    double                maxExampleSize;
#endif
    bool                  calculateExampleSize;
    bool                  labelsPresent;
    bool                  multipleLabels;  
    ConjunctionMethod     generateConjunctions;
    bool                  writeConjunctions;
    bool                  rawMode;
    bool                  examplesInMemory;
    bool                  writePendingFeatures;
    bool                  threshold_relative;
    bool                  fixedFeature;
    ThickSeparator        thickSeparator;
    bool                  constraintClassification;
    bool                  conservativeCC;
    FeatureID*            targetIdsArray;
    bool                  gradientDescent;
    unsigned long         targetOutputLimit;
    bool                  showFeatureStrength;
};

inline GlobalParams::GlobalParams() :
        runMode(MODE_TRAIN),
#ifdef SERVER_MODE_
        serverPort(0),
#endif
        currentCycle(0),
        cycles(2),
        discardMethod(DISCARD_NONE),
        eligibilityMethod(ELIGIBILITY_COUNT),
        predictMethod(PREDICT_METHOD_UNSET),
        discardThreshold(0.2),
        eligibilityThreshold(2),
        curveInterval(0),
        targetIdsArray(NULL),
        sparseNetwork(true),
        noFirstCycleUpdate(false),
        onlineLearning(false),
        verbosity(VERBOSE_MIN),
        pResultsOutput(NULL),
        smoothing(0.0),
        bayesSmoothing(15.0),
        predictionThreshold(-1.0),
        eligibilityPercentage(0.1),
#ifdef AVERAGE_EXAMPLE_SIZE
        averageExampleSize(0),
#else
        maxExampleSize(0),
#endif
        calculateExampleSize(false),
        labelsPresent(true),
        multipleLabels(true),
        generateConjunctions(CONJUNCTIONS_UNSET),
        writeConjunctions(false),
        rawMode(false),
        examplesInMemory(false),
        writePendingFeatures(false),
        threshold_relative(false),
        fixedFeature(true),
        constraintClassification(false),
        conservativeCC(false),
        gradientDescent(false),
        targetOutputLimit(ULONG_MAX),
        thickSeparator(),
        showFeatureStrength(false)
{
}

//extern GlobalParams globalParams;

#endif

