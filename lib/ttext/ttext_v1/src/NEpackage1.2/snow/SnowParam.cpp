//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: SnowParam.cpp                                 =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#include "GlobalParams.h"
#include "SnowParam.h"
#include <stdlib.h>
#include <iostream>
#include <fstream>

#if defined(WIN32) || defined(LINUX)
extern "C"
{
    extern int getopt(int, char* const *, const char*);
    extern char *optarg;
}
#endif

//extern GlobalParams globalParams;

bool ProcessParam( char param, const char* arg, 
		   GlobalParams & globalParams )
{
  int i, commas;

  switch (param)
  {
    case 'a':
      if (!(globalParams.writePendingFeatures = *arg == '+') && *arg != '-')
      {
        cerr << "ERROR: The '-a' flag for forcing all non-discarded features "
             << "to be written\n"
             << "       to the network is followed by '" << arg
             << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    case 'B':
      // Add a naive bayes algorithm to the network
      globalParams.algorithmSpecification += "b(";
      globalParams.algorithmSpecification += arg;
      globalParams.algorithmSpecification += "),";

      for (i = 0; arg[i] && arg[i] != ':'; ++i);
      if (arg[i] == ':') globalParams.targetIds.Parse(&arg[i + 1]);
      else
      {
        cerr << "Error: No target IDs specified for Perceptron.\n";
        return false;
      }
      break;

    case 'b':
      globalParams.bayesSmoothing = atof(arg);
      break;

    case 'c':
      // interval for learning curve
      globalParams.curveInterval = atoi(arg);
      break;

    case 'd':
      // discarding
      if (!strcmp(arg, "none")) globalParams.discardMethod = DISCARD_NONE;
      else if (!strncmp(arg, "abs", 3)) 
      {
        globalParams.discardMethod = DISCARD_ABS;
        if (arg[3] == ':') globalParams.discardThreshold = atof(&arg[4]);
        else
        {
          cerr << "ERROR: no discard threshold given for absolute discard "
               << "mode\n";
          return false;
        } 
      }
      else if (!strncmp(arg, "rel", 3))
        globalParams.discardMethod = DISCARD_REL;
      else
      {
        cerr << "ERROR: discard flag -d requires parameter abs:# or rel\n";
        return false;
      }
      break;

    case 'E':
      // Error report file
      globalParams.errorFile = arg;    
      break;

    case 'e':
      // eligibility 
      if (!strncmp(arg, "count", 5))
      {
        globalParams.eligibilityMethod = ELIGIBILITY_COUNT;
        if (arg[5] == ':')
        {
          globalParams.eligibilityPercentage = 1.0;
          globalParams.eligibilityThreshold = atoi(&arg[6]);
        }
        else
        {
          cerr << "ERROR: no eligiiblity threshold given for eligibility "
               << "count mode\n";
          return false;
        } 
      }
      else if (!strncmp(arg, "percent", 7)) 
      {
        globalParams.eligibilityMethod = ELIGIBILITY_PERCENT;
        if (arg[7] == ':')
        {
          globalParams.eligibilityThreshold = 1;
          globalParams.eligibilityPercentage = atof(&arg[8]);
        }
        else
        {
          cerr << "ERROR: no eligibility threshold given for eligibility "
               << "count mode\n";
          return false;
        }
      }
      else if (isdigit(*arg)) 
      {
        globalParams.eligibilityPercentage = 1.0;
        globalParams.eligibilityThreshold = atoi(arg);
      }
      else
      {
        cerr << "ERROR: eligibility flag -e requires parameter count:# or "
             << "percent:#\n";
        return false;
      }
      break;

    case 'F':
      // Network file
      globalParams.networkFile = arg;
      break;

    case 'f':
      // The fixed feature is a like a dynamic threshold for each target.
      if (!(globalParams.fixedFeature = *arg == '+') && *arg != '-')
      {
        cerr << "ERROR: The '-f' flag for enabling the fixed feature is "
             << "followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    case 'G':
      if (!(globalParams.gradientDescent = *arg == '+') && *arg != '-')
      {
        cerr << "ERROR: The '-G' flag for enabling gradient descent is "
             << "followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    case 'g':
      // feature space "growing" - generate conjunctions
      if (arg[0] == '+') globalParams.generateConjunctions = CONJUNCTIONS_ON;
      else if (arg[0] == '-')
        globalParams.generateConjunctions = CONJUNCTIONS_OFF;
      else
      {
        cerr << "ERROR: The '-g' flag for automatic conjunction generation "
             << "is followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }

      if (arg[1] == ',')
      {
        if (!(globalParams.writeConjunctions = arg[2] == '+')
            && arg[2] != '-')
        {
          cerr << "ERROR: The second argument to the '-g' flag for writing "
               << "conjunctions is\n"
               << "       specified as '" << &arg[2] << "' in the command "
               << "line.\n"
               << "       '+' and '-' are the only legal arguments for this "
               << "flag.\n";
          return false;
        }
      }
      break;

    case 'I':
      // Input file
      globalParams.inputFile = arg;
      break;

    case 'i':
      // Online learning during test mode means the network is also trained
      // with the test examples.
      if (!(globalParams.onlineLearning = *arg == '+') && *arg != '-')
      {
        cerr << "ERROR: The '-i' flag for \"incremental\" or \"online\" "
             << "learning is followed\n"
             << "       by '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    case 'L':
      // Limit the number of targets printed with -o
      globalParams.targetOutputLimit = atol(arg);
      break;

    case 'l':
      // Labeled examples
      if (!(globalParams.labelsPresent = *arg == '+') && *arg != '-')
      {
        cerr << "ERROR: The '-l' flag for notifying SNoW that labels are "
             << "present in each\n"
             << "       example is followed by '" << arg
             << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    case 'M':
      if (!(globalParams.examplesInMemory = *arg == '+') && *arg != '-')
      {
        cerr << "ERROR: The '-M' flag for holding all examples in memory is "
             << "followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    case 'm':
      // More than one target per example
      if (!(globalParams.multipleLabels = *arg == '+') && *arg != '-')
      {
        cerr << "ERROR: The '-m' flag for allowing more than one target per "
             << "example is\n"
             << "       followed by '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    case 'O':
      // Ordered mode.  A better name would have been "constraint
      // classification mode."  I won't bore you with the confusing and, in
      // retrospect, stupid reasons why 'O' was chosen to enable this option.
      if (!(globalParams.constraintClassification = *arg == '+')
          && *arg != '-')
      {
        cerr << "ERROR: The '-O' flag for enabling constraint classification "
             << "is followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }

      if (arg[0] == '+' && arg[1] == ',')
      {
        if (!(globalParams.conservativeCC = arg[2] == '+')
            && arg[2] != '-')
        {
          cerr << "ERROR: The second argument to the '-O' flag for setting "
               << "conservative CC mode\n"
               << "       was specified as '" << &arg[2] << "' in the command"
               << " line.\n"
               << "       '+' and '-' are the only legal arguments for this "
               << "flag.\n";
          return false;
        }
      }
      break;

    case 'o':   
      // Output mode
      if (strcmp(arg, "accuracy") == 0) globalParams.predictMethod = ACCURACY;
      else if (strcmp(arg, "winners") == 0)
        globalParams.predictMethod = WINNERS;
      else if (strcmp(arg, "softmax") == 0)
        globalParams.predictMethod = SOFTMAX;
      else if (strcmp(arg, "allactivations") == 0)
        globalParams.predictMethod = ALL_ACTIVATIONS;
      else if (strcmp(arg, "allpredictions") == 0)
        globalParams.predictMethod = ALL_PREDICTIONS;
      else if (strcmp(arg, "allboth") == 0)
        globalParams.predictMethod = ALL_BOTH;
      else
      {
        cerr << "ERROR: The '-o' flag for changing the output mode is "
             << "followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       Legal arguments for this flag are:\n"
             << "         -o accuracy\n"
             << "         -o winners\n"
             << "         -o softmax\n"
             << "         -o allactivations\n"
             << "         -o allpredictions\n"
             << "         -o allboth\n";
        return false;
      }
      break;

    case 'P':
      // Add a perceptron algorithm to the network
      globalParams.algorithmSpecification += "p(";
      globalParams.algorithmSpecification += arg;
      globalParams.algorithmSpecification += "),";

      i = 0;
      if (!globalParams.calculateExampleSize)
      {
        for (commas = 0; arg[i] && arg[i] != ':'; ++i)
          if (arg[i] == ',') ++commas;
        if (commas < 2) globalParams.calculateExampleSize = true;
      }

      for (; arg[i] && arg[i] != ':'; ++i);
      if (arg[i] == ':') globalParams.targetIds.Parse(&arg[i + 1]);
      else
      {
        cerr << "Error: No target IDs specified for Perceptron.\n";
        return false;
      }
      break;

    case 'p':
      globalParams.predictionThreshold = atof(arg);
      break;

    case 'R':
      // results file for Test mode
      globalParams.outputFile = arg;
      break;

    case 'r':
      // number of learning cycles (repetitions)
      globalParams.cycles = atoi(arg);
      break;

    case 'S':
      // set separator thickness
      globalParams.thickSeparator.positive = atof(arg);
      for (i = 0; arg[i] && arg[i] != ','; ++i);
      globalParams.thickSeparator.negative =
        (arg[i]) ? atof(&arg[i + 1]) : globalParams.thickSeparator.positive;
      globalParams.thickSeparator.negative *= -1;
      break;

    case 's':
      // sparse network
      if (!(globalParams.sparseNetwork = *arg == 's') && *arg != 'f')
      {
        cerr << "ERROR: The '-s' flag for making the network sparse or full "
             << "is followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       's' for sparse and 'f' for full are the only legal "
             << "arguments for\n"
             << "       this flag.\n";
        return false;
      }
      break;

    case 'T':
      // testing file for Train/Test mode
      globalParams.testFile = arg;
      break;

    case 't':
      // For winnow; makes alpha = c * threshold / activation
      if (!(globalParams.threshold_relative = *arg == '+') && *arg != '-')
      {
        cerr << "ERROR: The '-t' flag for enabling threshold relative "
             << "updating is followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    case 'u':
      // '+' means there will be updates during the first cycle
      if (!(globalParams.noFirstCycleUpdate = *arg == '-') && *arg != '+')
      {
        cerr << "ERROR: The '-u' flag for enabling first cycle updates is "
             << "followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    case 'v':
      // Verbosity level
      if (!strcmp(arg, "off")) globalParams.verbosity = VERBOSE_QUIET;
      else if (!strcmp(arg, "med")) globalParams.verbosity = VERBOSE_MED;
      else if (!strcmp(arg, "max")) globalParams.verbosity = VERBOSE_MAX;
      else if (!strcmp(arg, "min")) globalParams.verbosity = VERBOSE_MIN;
      else
      {
        cerr << "ERROR: The '-v' flag for enabling first cycle updates is "
             << "followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       Legal arguments: 'off', 'min', 'med', 'max'\n"
             << "       Defaulting to 'min'.\n";
        globalParams.verbosity = VERBOSE_MIN;
      }
      break;

    case 'W':
      // Add a winnow algorithm to the network
      globalParams.algorithmSpecification += "w(";
      globalParams.algorithmSpecification += arg;
      globalParams.algorithmSpecification += "),";                

      i = 0;
      if (!globalParams.calculateExampleSize)
      {
        for (commas = 0; arg[i] && arg[i] != ':'; ++i)
          if (arg[i] == ',') ++commas;
        if (commas < 3) globalParams.calculateExampleSize = true;
      }

      for (; arg[i] && arg[i] != ':'; ++i);
      if (arg[i] == ':') globalParams.targetIds.Parse(&arg[i + 1]);
      else
      {
        cerr << "Error: No target IDs specified for Winnow.\n";
        return false;
      }
      break;

    case 'w':
      // Set the winnow/perceptron smoothing
      globalParams.smoothing = atof(arg);
      break;

    case 'x':
      // Example
      globalParams.evalExample = arg;
      break;

    case 'y':
      // For winnow; makes alpha = c * threshold / activation
      if (!(globalParams.showFeatureStrength = *arg == '+') && *arg != '-')
      {
        cerr << "ERROR: The '-y' flag for enabling showFeatureStrength "
             << "updating is followed by\n"
             << "       '" << arg << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
      break;

    default:
      cerr << "ERROR: Unrecognized command parameter: " << param << endl;
      return false;
  }

  return true;
}


bool ParseParamFile( const char* paramFilename, GlobalParams & globalParams )
{
  bool result = true;
  char paramLine[256];
  char *arg;

  ifstream paramStream(paramFilename);
  if (!paramStream)
  {
    cerr << "Error:\n";
    cerr << "Failed to open architecture file: '" << paramFilename
         << "'.  No parameters read.\n";
    return false;
  }

  while (result && !paramStream.eof())
  {
    //string paramLine;
    paramLine[0] = 0;
    paramStream.getline(paramLine, sizeof paramLine);
    if (strlen(paramLine))
    {
      if (paramLine[0] == '-')
      {
        arg = paramLine + 2;
        while (isspace(*arg)) ++arg;
        result = ProcessParam(paramLine[1], arg, globalParams);
      }
      else if (paramLine[0] != '#')
      {
        cerr << "Error:\n";
        cerr << "Each line in the pararmeter file must start with '-' "
             << "skipping " << paramLine << endl;
      }
    }
  }

  return result;
}


bool ValidateParams(GlobalParams & globalParams)
{
  bool result = true;

  // Always must be a network file
  if (!globalParams.networkFile.length())
  {
    cerr << "Fatal Error:\n";
    cerr << "No network file specified (-F)\n\n";
    result = false;
  }

  // If run mode is TRAIN, TEST, or INTERACTIVE(SERVER), need an input file 
  if ((globalParams.runMode == MODE_TRAIN
       || globalParams.runMode == MODE_TEST
       || globalParams.runMode == MODE_INTERACTIVE
       || globalParams.runMode == MODE_INTERACTIVESERVER)
      && !globalParams.inputFile.length())
  {
    cerr << "Fatal Error:\n";
    cerr << "No input file specified (-I)\n";
    result = false;
  }

#ifdef SERVER_MODE_
  // If run mode is SERVER, need a valid port number.
  if (globalParams.runMode == MODE_SERVER 
      || globalParams.runMode == MODE_INTERACTIVESERVER)
  {
    if (globalParams.outputFile.length() != 0)
    {
      cerr << "Warning: Results file has been specified in server mode (-R). "
           << " All server mode\n"
           << "         output goes to STDOUT or to a client.  -R will be "
           << "ignored.\n";
      globalParams.outputFile = "";
    }

    if (globalParams.serverPort < 1 || globalParams.serverPort > 65535)
    {
      cerr << "Fatal Error:\n";
      cerr << "  A valid port number must be supplied in server mode (1 - "
           << "65535)\n";
      cerr << "  -server <port>\n\n";
      result = false;
    }

    if (globalParams.predictMethod == PREDICT_METHOD_UNSET)
      globalParams.predictMethod = WINNERS;
  }
  else
#endif
  if (globalParams.predictMethod == PREDICT_METHOD_UNSET)
    globalParams.predictMethod = ACCURACY;

  // If run mode is Eval, need an example
  if (globalParams.runMode == MODE_EVAL && !globalParams.evalExample.length())
  {
    cerr << "Fatal Error:\n";
    cerr << "No example specified (-x)\n\n";
    result = false;
  }

  // Error files can only be produced with the default output mode.
  if (globalParams.errorFile.length() > 0
      && globalParams.predictMethod != ACCURACY)
  {
    cerr << "Warning:\n";
    cerr << "Error files are not supported with any output mode other than\n";
    cerr << "  -o accuracy\n";
    cerr << "(which is the default).  No error file will be produced.\n";
    globalParams.errorFile = "";
  }

  // If run mode is not Eval, no example needed (used)
  if (globalParams.runMode != MODE_EVAL && globalParams.evalExample.length())
  {
    cerr << "Warning:\n";
    if (globalParams.runMode == MODE_TRAIN) cerr << "Training";
    else if (globalParams.runMode == MODE_TEST) cerr << "Test";
    else cerr << "Server";
    cerr << " mode: Specified example will be ignored (-x)\n\n";
  }

  // In TRAIN & INTERACTIVE(SERVER) mode, check for architecture definition
  if ((globalParams.runMode == MODE_TRAIN 
       || globalParams.runMode == MODE_INTERACTIVE
       || globalParams.runMode == MODE_INTERACTIVESERVER) 
      && globalParams.targetIds.empty()
      && !globalParams.algorithmSpecification.length())
  {
    globalParams.algorithmSpecification = "w(1.35,0.8,4.0,0.2:0-1),";
    globalParams.targetIds.Parse("0-1");
    cerr << "Warning: No architecture defined (defaulting to "
         << globalParams.algorithmSpecification << ")\n";
  }

  if (globalParams.runMode != MODE_TRAIN
      && globalParams.generateConjunctions != CONJUNCTIONS_UNSET)
  {
    cerr << "Warning: The conjunction generation setting will be over-ridden "
         << "by the\n"
         << "         network's setting, if it has one.\n";
  }

  // If run mode is Train and online learning is specified
  if (globalParams.runMode == MODE_TRAIN && globalParams.onlineLearning
      && globalParams.testFile.length() == 0)
  {
    cerr << "Warning: Online learning doesn't make sense in training mode.\n"
         << "         Online flag will be ignored.\n";
  }

  // As of the date this code was written, constraint classification should
  // only be enabled for training mode, unless online learning is enabled.
  if (globalParams.runMode != MODE_TRAIN
      && globalParams.constraintClassification
      && !(globalParams.runMode == MODE_TEST && globalParams.onlineLearning))
  {
    cerr << "Constraint classification is only valid in training or online "
         << "learning.\n"
         << "Constraint classification flag will be set to false.\n";
    globalParams.constraintClassification = false;
  }

  // A curve interval only makes sense when a test file is specified in train
  // mode.
  if (globalParams.curveInterval)
  {
    if (globalParams.runMode != MODE_TRAIN)
    {
      cerr << "Warning: Curve interval is only valid in train mode.\n"
           << "         Ignoring curve interval.\n";
      globalParams.curveInterval = 0;
    }
    else if (globalParams.testFile.length() == 0)
    {
      cerr << "Warning: Curve interval specified without test file (-T)\n"
           << "         No results will be output.\n";
    }
  }

  if (globalParams.writePendingFeatures
      && !(globalParams.runMode == MODE_TRAIN || globalParams.onlineLearning))
  {
    cerr << "Warning: Forcing all non-discarded features to be written to "
         << "the network\n"
         << "         with '-a' has no effect when the network will not be "
         << "written.\n";
  }

  if (globalParams.examplesInMemory && globalParams.runMode != MODE_TRAIN)
  {
    cerr << "Warning: Storing all examples in memory with the -M+ flag only "
         << "makes\n"
         << "         sense in training mode.\n";
  }

  if (globalParams.rawMode
      && !(globalParams.runMode == MODE_TRAIN
           || globalParams.runMode == MODE_TEST))
  {
    cerr << "Warning: Enabling \"raw\" mode is only supported in '-train' "
         << "and '-test' modes.\n"
         << "         '-z' will be disabled.\n";
  }

  if (globalParams.gradientDescent && globalParams.constraintClassification)
  {
    cerr << "Warning: Gradient Descent and Constraint Classification cannot "
         << "be enabled\n"
         << "         simultaneously.  '-G' will be disabled.\n";
    globalParams.gradientDescent = false;
  }

  if (globalParams.gradientDescent && globalParams.threshold_relative)
  {
    cerr << "Warning: Gradient Descent and threshold relative updating "
         << "cannot be enabled\n"
         << "         simultaneously.  '-t' will be disabled.\n";
    globalParams.threshold_relative = false;
  }

  if (globalParams.targetOutputLimit < 1)
  {
    cerr << "Warning: Target output limit must be a positive integer.\n"
         << "         -L will be set to 1.\n";
    globalParams.targetOutputLimit = 1;
  }

  // If run mode is Interactive, labelsPresent can't be set
  if (globalParams.runMode == MODE_INTERACTIVE 
      || globalParams.runMode == MODE_INTERACTIVESERVER)
  {
    if (globalParams.labelsPresent)
    {
      cerr << "Warning: Interactive mode can't have labelsPresent.\n"
	         << "         -l+ flag will be ignored.\n";
      globalParams.labelsPresent = false;
    }

    if (globalParams.eligibilityMethod != ELIGIBILITY_COUNT
        || globalParams.eligibilityThreshold > 1)
    {
      cerr
  << "Warning: In interactive mode, the eligibility method must be 'count',\n"
  << "         and the threshold must be 1.\n";
      globalParams.eligibilityMethod = ELIGIBILITY_COUNT;
      globalParams.eligibilityThreshold = 1;
    }

    globalParams.sparseNetwork = false;
  }

  return result;
}


bool ParseCmdLine( int argc, char* argv[], GlobalParams & globalParams )
{
  bool result = true;
  bool cmdLineNetworks = false;

  // Must supply either -eval, -test, -train, or -server as first argument
  if (!strcmp(argv[1], "-test")) globalParams.runMode = MODE_TEST;
  else if (!strcmp(argv[1], "-eval")
           || !strcmp(argv[1], "-evaluate")) globalParams.runMode = MODE_EVAL;
  else if (!strcmp(argv[1], "-train")) globalParams.runMode = MODE_TRAIN;
  else if (!strcmp(argv[1], "-interactive")) 
  {
    globalParams.runMode = MODE_INTERACTIVE;
    globalParams.eligibilityMethod = ELIGIBILITY_COUNT;
    globalParams.eligibilityThreshold = 1;
    globalParams.labelsPresent = false;
  }
#ifdef SERVER_MODE_
  else if (!strcmp(argv[1], "-server"))
  {
    if (argc < 3)
    {
      cerr << "ERROR: The port number must be the next argument after "
           << "-server\n";
      return false;
    }
    globalParams.runMode = MODE_SERVER;
    globalParams.serverPort = atoi(argv[2]);
    ++argv;  // skip serverPort
    --argc;
  }
  else if(!strcmp(argv[1], "-interactive_server"))
    {
      if (argc < 3)
	{
	  cerr << "ERROR: The port number must be the next argument after "
	       << "-interactive_server\n";
	  return false;
	}
      globalParams.serverPort = atoi(argv[2]);
      ++argv;  // skip serverPort
      --argc;
      
      globalParams.runMode = MODE_INTERACTIVESERVER;
      globalParams.eligibilityMethod = ELIGIBILITY_COUNT;
      globalParams.eligibilityThreshold = 1;
      globalParams.labelsPresent = false;
    }
#endif
  else
  { 
#ifdef SERVER_MODE_
    cerr << "ERROR: First argument must be -train, -test, -evaluate, or "
         << "-server\n\n";
#else
    cerr << "ERROR: First argument must be -train, -test, or -evaluate\n\n";
#endif
    return false;
  }

  // command line arguments

  // skip mode argument (the program name has already been skipped, since the
  // getopt() function starts looking at argv from index 1)
  ++argv;
  --argc;

  // look for parameter file and raw mode flag first
  for (int i = 0; i < argc; ++i)
  {
    if (!strncmp(argv[i], "-A", 2))
    {
      // Process the parameter file
      if (strlen(argv[i]) > 2) result = ParseParamFile(&argv[i][2],
						       globalParams);
      else if (i + 1 < argc) result = ParseParamFile(argv[i + 1],
						     globalParams);
      else return false;
    }
    else if (!strncmp(argv[i], "-z", 2))
    {
      char* argument;
     
      if (strlen(argv[i]) > 2) argument = &argv[i][2];
      else if (i + 1 < argc) argument = argv[i + 1];
      else
      {
        cerr << "ERROR: The '-z' flag for enabling conventional (\"raw\") "
             << "mode requires an\n"
             << "       argument: either '+' or '-'.\n";
        return false;
      }

      if (*argument == '+')
      {
        globalParams.rawMode = true;

        switch (globalParams.runMode)
        {
          case MODE_TRAIN:
            globalParams.cycles = 1;
            globalParams.generateConjunctions = CONJUNCTIONS_OFF;
            // no break

          case MODE_TEST:
            globalParams.eligibilityThreshold = 1;
            globalParams.sparseNetwork = false;
            globalParams.fixedFeature = false;
        }
      }
      else if (*argument != '-')
      {
        cerr << "ERROR: The '-z' flag for enabling conventional (\"raw\") "
             << "mode is followed by\n"
             << "       '" << argument << "' in the command line.\n"
             << "       '+' and '-' are the only legal arguments for this "
             << "flag.\n";
        return false;
      }
    }
  }

  // Read in input data
  char c;
  while ((c = getopt(argc, argv,
      "A:a:B:b:c:d:E:e:F:f:G:g:I:i:L:l:M:m:O:o:P:p:R:r:S:s:T:t:u:v:W:w:x:z:"))
         != (char)EOF && result)
  {
    // Ignore -A and -z, as they have already been processed above
    if (c != 'A' && c != 'z')
    {
      // If we get a network specification, let it override
      // whatever may have been in the param file
      if (!cmdLineNetworks && (c == 'B' || c == 'P' || c == 'W'))
      {
        globalParams.algorithmSpecification.empty();
        cmdLineNetworks = true;
      }

      result = ProcessParam(c, optarg, globalParams);
    }    
  }

  return result;
}

