// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: GlobalParams.h                                =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef __GLOBALPARAMS_H__
#define __GLOBALPARAMS_H__

#include <string>

// added by jakob 11/5/03: Have to include fex.h for currentDoc variable
#include "Fex.h"

using namespace std;

typedef enum {VERBOSE_QUIET, VERBOSE_YAIR, VERBOSE_MIN, VERBOSE_MED, 
   VERBOSE_MAX, VERBOSE_CRAZY} Verbosity;

typedef enum {S_CHI, S_IG, S_MI} StatType;

typedef enum {ENTITY, RELATION} ER_Type;

struct GlobalParams
{
    GlobalParams();

    const char*          scriptFile;		// Input file
    const char*          corpusFile;		// Input file
    const char*          lexiconFile;	   // Input/Output file
    const char*          exampleFile;	   // Output file (Snow format)
    const char*	       targetsFile;	   // Input file with target words 
    const char*          histogramFile;   // Input/Output file of counts 
    const char*          stopwordsFile;   // Input file with stop words 
    const char*          statFile;        // Statistics file
    const char*          preservedFile;   // File that stores the preserved example numbers.
  string          processIDfilename;  // Process ID will be written to this file
    StatType        statType;       // Type of statistics to do
    double          statThresh;     // Type of statistics to do
    Verbosity       verbosity;
    short           serverPort;     // port to listen on in server mode
    bool	    rawInput;
    bool            readOnlyLexicon;
    bool            histogramByFeature;
    bool            targetOne;      // true if a target from targetsFile should
                                    // only evaluate one sentence from corpus
    bool            newScripting;
    bool            newParse;

  // The following two options are used for processing phrase problems.
  // Added by Scott Yih, 09/24/01
  bool phraseCase;    // true if the goal is to identify phrases
  int maxPhraseLeng;  // maximum length of each phrase:
                      // 0 -- only generate examples for positive examples
  double negativeRatio;  // the probability that a negative example will be preserved

  // The following two options are used for processing phrase problems.
  // Added by Scott Yih, 01/08/02
  bool erExtension;  // true if the mode is for ER experiments
  ER_Type labelType; // use entities or relations as labels

  // added by jakob 11/5/03:
  // currentDocument holds sentences of the current document
  vector<Sentence> currentDoc;

  // Added by Scott Yih, 12/04/03
  bool docMode;  // true if one example represents one document; documents are separated by "- - - - - - - - -", in table format corpus

  // Added by Scott Yih, 12/13/03
  bool nonstop;  // repeatedly run fex (without reloarding lexicon and script file), useful for namedpipe input
};

inline GlobalParams::GlobalParams() :
  scriptFile(NULL),
  corpusFile(NULL),
  lexiconFile(NULL),
  exampleFile(NULL),
  targetsFile(NULL),
  histogramFile(NULL),
  stopwordsFile(NULL),
  statFile(NULL),
  preservedFile(NULL),
  verbosity(VERBOSE_MIN),
  serverPort(0),
  rawInput(false),
  readOnlyLexicon(false),
  histogramByFeature(false),
  targetOne(false),
  newScripting(true),
  newParse(false),
  phraseCase(false),
  erExtension(false),
  statType(S_CHI),
  statThresh(0.0),
  negativeRatio(2.0),
  docMode(false),
  nonstop(false) {}

extern GlobalParams globalParams;

#endif

