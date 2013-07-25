// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: SnowTypes.h                                   =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef SNOWTYPES_H__
#define SNOWTYPES_H__

// In NT environment, disable the warning about truncating 
// identifiers
#pragma warning(disable:4786)
 
typedef unsigned int FeatureID;
typedef unsigned long Counter;

#define FIXED_FEATURE_ID ((FeatureID) -2)
#define NO_PREDICTION    ((FeatureID) -3)

typedef enum {MODE_TRAIN, MODE_TEST, MODE_EVAL, MODE_SERVER, MODE_INTERACTIVE, MODE_INTERACTIVESERVER} RunMode;
typedef enum {DISCARD_NONE, DISCARD_ABS, DISCARD_REL} DiscardMethod;
typedef enum {CONJUNCTIONS_UNSET, CONJUNCTIONS_ON, CONJUNCTIONS_OFF}
             ConjunctionMethod;
typedef enum {ELIGIBILITY_COUNT, ELIGIBILITY_PERCENT} EligibilityMethod;
typedef enum {VERBOSE_QUIET, VERBOSE_MIN, VERBOSE_MED, VERBOSE_MAX} Verbosity;
typedef enum
{
  PREDICT_METHOD_UNSET, ACCURACY, WINNERS, ALL_ACTIVATIONS, ALL_PREDICTIONS,
  ALL_BOTH, SOFTMAX
} PredictMethod;

#endif

