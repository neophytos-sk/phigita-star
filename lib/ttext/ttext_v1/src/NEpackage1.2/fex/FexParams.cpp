//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: FexParams.cpp                                 =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================


#include "FexParams.h"
#include <iostream>

GlobalParams globalParams;

bool ParseCmdLine( int argc, char* argv[] )
{
    static int fileParam = 1;
    bool result = true;

    // command line arguments
    // Read in input data
    int c;
    while (((c = getopt(argc,argv,"Df:h:iopP:R:N:nrs:S:t:T:uv:")) != -1)
			&& (c != '?')
			&& (result == true))
    {
        if (result = ProcessParam(c, optarg))
		{
			fileParam++;
			if (optarg == argv[fileParam]) fileParam++;
		}
    }

	if (argc > fileParam)
		globalParams.scriptFile = argv[fileParam];
	else
		result = false;
	if (argc > (fileParam + 1))
		globalParams.lexiconFile = argv[fileParam + 1];
	else
		result = false;
	if (argc > (fileParam + 2))
		globalParams.corpusFile = argv[fileParam + 2];
	else
        if (globalParams.serverPort == 0) result = false;
	if (argc > (fileParam + 3))
		globalParams.exampleFile = argv[fileParam + 3];
	else
		if (globalParams.serverPort == 0) result = false;

    return result;
}

bool ProcessParam( int param, const char* optarg )
{
  switch (param) 
  {
    // for document classification problems (e.g. spam filter)
    // Added by Scott Yih, 12/04/03
    case 'D':
      // one document has one example of features
      globalParams.docMode = true;
      break;

    case 'f':
      // preserved example file
      globalParams.preservedFile = optarg;
      break;

    case 'h':
        // Histogram file
        globalParams.histogramFile = optarg;
        break;

    case 'i':
        globalParams.histogramByFeature = true;
        break;

    case 'j':
        globalParams.statFile = optarg;
        break;

  case 'n':
    globalParams.nonstop = true;
    break;

    case 'o':
        globalParams.newScripting = false;
        break;

    case 'p':
        globalParams.newParse = true;
        break;

    // for phrase related problems
    // Added by Scott Yih, 09/24/01
    case 'P':
      globalParams.phraseCase = true;
      globalParams.maxPhraseLeng = atoi(optarg);

      // Column Format
      globalParams.newParse = true;
      // No Target File
      //globalParams.targetsFile = "";
      break;

    // for phrase related problems,
    //   this option indicates the probility of picking up a negative example
    // Added by Scott Yih, 10/10/01
    case 'N':
      globalParams.negativeRatio = atof(optarg);
      break;

    case 'r':
        globalParams.readOnlyLexicon = true;
        break;

    case 'S':
        // Stop-words file
        globalParams.stopwordsFile = optarg;
        break;

    case 's':
        globalParams.serverPort = (short)atoi(optarg);
        break;

    case 't':
	// Targets file: all targets process all sentences
	globalParams.targetsFile = optarg;
	break;

    case 'T':
      // Targets file: each target processes its respective sentence in corpus
      globalParams.targetsFile = optarg;
      globalParams.targetOne = true;
      break;

    case 'u':
      // Unformatted input
      globalParams.rawInput = true;
      break;

    case 'v':
        // Verbosity level
        if (!strcmp(optarg, "off"))
        {
            globalParams.verbosity = VERBOSE_QUIET;
        } else if (!strcmp(optarg, "crazy")) {
            globalParams.verbosity = VERBOSE_CRAZY;
        } else if (!strcmp(optarg, "yair")) {
            globalParams.verbosity = VERBOSE_YAIR;
        } else if (!strcmp(optarg, "med")) {
            globalParams.verbosity = VERBOSE_MED;
        } else if (!strcmp(optarg, "max")) {
            globalParams.verbosity = VERBOSE_MAX;
        } else {
            globalParams.verbosity = VERBOSE_MIN;
        }
        break;

    // for entity/relation experiments,
    // Added by Scott Yih, 01/08/02

    case 'R':
      globalParams.erExtension = true;
      // Column Format
      globalParams.newParse = true;
      // No Target File
      //globalParams.targetsFile = "";

      if (!strcmp(optarg, "e")) {
         globalParams.labelType = ENTITY;
      } else { // "r"
         globalParams.labelType = RELATION;
      }
      break;

    case '?':
	return false;

    default:
        return false;
    }

    return true;
}

bool ValidateParams()
{
    bool result = true;

	if ((globalParams.verbosity < VERBOSE_QUIET)
			|| (globalParams.verbosity > VERBOSE_CRAZY))
    {
		cerr << "Verbosity level is out of range!" << endl;
		result = false;
	}

	if (globalParams.scriptFile == NULL)
	{
		cerr << "<script-file> parameter is required!" << endl;
		result = false;
	}

	if (globalParams.lexiconFile == NULL)
	{
		cerr << "<lexicon-file> parameter is required!" << endl;
		result = false;
	}

	if ((globalParams.corpusFile == NULL)
        && (globalParams.serverPort == 0))
	{
		cerr << "<corpus-file> parameter is required!" << endl;
		result = false;
	}

	if ((globalParams.exampleFile == NULL)
        && (globalParams.serverPort == 0))
	{
		cerr << "<example-file> parameter is required!" << endl;
		result = false;
	}

	// special checking for phrase problems
	// Added by Scott Yih, 09/24/01
	if (globalParams.phraseCase)
	{
	  // check if it's column format, or has a target file
	  if (!globalParams.newParse || globalParams.targetsFile != NULL) {
	    cerr << "Column format input is required!" << endl;
	    result = false;
	  }

	  // check it the length is not negative
	  if (globalParams.maxPhraseLeng < 0) {
	    cerr << "Maximum phrase length can not be negative!" << endl;
	    result = false;
	  }
	}

	/*
	if (globalParams.erExtension && globalParams.relationName == "") {
	  cerr << "Relation name has to be specified!" << endl;
	  result = false;
	}
	*/

    return result;
}
