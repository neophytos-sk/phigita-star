// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Snow.cpp                                      =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#include "GlobalParams.h"
#include "SnowParam.h"
#include "Cloud.h"
#include "Network.h"
#include "Example.h"
#include "Usage.h"
#ifdef SERVER_MODE_
#include "SendReceive.h"
#endif

#include <stdlib.h>
#ifndef WIN32
#include <unistd.h>
#endif
#include <errno.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#ifndef WIN32
#include <strings.h>
#endif
#include <algorithm>
#include <iostream>
#include <fstream>
#include <strstream>
#include <iomanip>

#ifdef SERVER_MODE_
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include <pthread.h>


#define BACKLOG 5 
#define BUFFER_SIZE 16384

static int serverRun = 1;

#endif

struct ClientData
{
  int                 fileDesc;
  Network*            network;
  pthread_mutex_t*    pLexiconMutex;
};



#ifdef WIN32
extern "C"
{
  extern int getopt(int, char* const *, const char*);
  extern char *optarg;
}
#endif

const char* logo[] =
{
  "SNoW+ - Sparse Network of Winnows Plus\n",
  "Cognitive Computations Group - University of Illinois at Urbana-Champaign",
  "\nVersion 3.1.4\n",
  "\0"
};

GlobalParams globalParams;

#ifdef SERVER_MODE_
void RunServer(Network& network);
void RunInteractiveServer();
void SigHandler( int sig );
void* ProcessSocket( void* clientData );
void* ProcessSocketInteractive(void* clientData);
void ParseOptions(char* options);
#endif

void Train();
void Test();
void Interactive();
void BasicTest( Network& network );
void Output( TargetRanking &rank, ofstream* errorStream, Example &ex,
             int &correct, int &suppressed, int examples, int not_labeled );
void FinalOutput( ostream& out, int correct, int suppressed, int examples,
                  int not_labeled );
bool Predict( TargetRanking& rank );
FeatureID Evaluate();
void Pause();
void ShowOptions();
string CreateFeatureWeightOutput(TargetRanking &rank, Example &example, void* clientData);
#ifdef SERVER_MODE_
void SigHandler( int sig )
{                
  cout << "SigHandler got signal " << sig << "...\n";
  serverRun = 0;
}
#endif


int main( int argc, char* argv[] )
{
  if (globalParams.verbosity != VERBOSE_QUIET)
  {
    cout << endl;
    for (int i = 0; logo[i][0]; ++i)
      cout << logo[i];
  }

  FeatureID prediction;
  if (argc == 1)
  {
    // no options were given-- output usage
    char** usagePtr = usage;
    while (**usagePtr != '&')
    {
      cout << *usagePtr;
      ++usagePtr;
    }
  }
  else if (ParseCmdLine(argc, argv, globalParams))
  {
    ShowOptions();
    if (ValidateParams(globalParams))
    {
      // open the output file if specified
      // if none was given, output to console
      if (globalParams.outputFile.length() != 0) 
      {
        globalParams.pResultsOutput =
          new ofstream(globalParams.outputFile.c_str());
        if (!(*globalParams.pResultsOutput))
        {
          cerr << "Fatal Error:\n";
          cerr << "Failed to open output file '"
               << globalParams.outputFile.c_str() << "' for output\n\n";
        }

        cout << "Directing output to file '"
             << globalParams.outputFile.c_str() << "'\n";
      }
      else
      {
        globalParams.pResultsOutput = &cout;
        if (globalParams.verbosity != VERBOSE_QUIET)
        {
          cout << "Directing output to ";
          if (globalParams.runMode == MODE_SERVER) cout << "clients";
          else cout << "console";
          cout << ".\n";
        }
      }
      if (globalParams.runMode == MODE_TRAIN) Train();
      else if (globalParams.runMode == MODE_TEST
               || globalParams.runMode == MODE_SERVER)
        Test();
      else if (globalParams.runMode == MODE_INTERACTIVE)
        Interactive();

#ifdef SERVER_MODE_

      else if (globalParams.runMode == MODE_INTERACTIVESERVER)
	if (globalParams.serverPort > 0) RunInteractiveServer();
#endif

      else prediction = Evaluate();

      if (globalParams.outputFile.length() != 0)
      {
        ((ofstream*)(globalParams.pResultsOutput))->close();
        delete globalParams.pResultsOutput;
      }
    }//end if (validateParams())
  }//end if (parseCmdLine()) 

  if (globalParams.runMode == MODE_EVAL) return (int)prediction;
  else return 0;
}


void Train()
{
  ifstream trainStream(globalParams.inputFile.c_str());
  ofstream outputConjunctionStream;

  if (globalParams.writeConjunctions)
  {
    string outputConjunctionFile = globalParams.inputFile + ".conjunctions";
    outputConjunctionStream.open(outputConjunctionFile.c_str());
    if (globalParams.verbosity >= VERBOSE_MIN)
      cout << "Writing training examples with conjunctions to file: '" 
        << outputConjunctionFile << "'\n";
  }

  if (!trainStream)
  {
    cerr << "Fatal Error:\n";
    cerr << "Failed to open training input file: '" 
      << globalParams.inputFile.c_str() << "'\n\n";
    return;
  }

  // examine training data to set default weight and decide if we should
  // perform blow-up on the feature space

  int examples = 0;
  FeatureID max_id = 0;
  Example example(globalParams);
  vector<Example> training_set;
#if defined(FEATURE_HASH) && !defined(WIN32)
  hash_set<FeatureID> featureSet;
#else
  set<FeatureID> featureSet;
#endif

  if (globalParams.generateConjunctions != CONJUNCTIONS_OFF
      || globalParams.calculateExampleSize)
  {
    // We might as well store all examples in memory now, since we're reading
    // the train stream anyway.
    if (globalParams.examplesInMemory)
    {
      while (!trainStream.eof())
      {
        if (example.ReadLabeled(trainStream))
        {
          example.ReadFeatureSet(featureSet, max_id);
          training_set.push_back(example);
          training_set[training_set.size() - 1].features.free_unused_space();
        }
        else
        {
          if (!trainStream.eof())
            cerr << "Failed reading example " << (training_set.size() + 1)
                 << " from " << globalParams.inputFile.c_str() << endl;
        }
      }

      examples = training_set.size();
    }
    else
    {
      while (!trainStream.eof() && featureSet.size() < 1000)
      {
        if (example.Read(trainStream))
        {
          example.ReadFeatureSet(featureSet, max_id);
          ++examples;
        }
        else
        {
          if (!trainStream.eof())
            cerr << "Failed reading example " << (examples + 1)
                 << " from " << globalParams.inputFile.c_str() << endl;
        }
      }

      // rewind the input file
      trainStream.clear();
      trainStream.seekg(0L);
    }

#ifdef AVERAGE_EXAMPLE_SIZE
    if (globalParams.calculateExampleSize)
      globalParams.averageExampleSize /= examples;
#endif
  }

  // do error / warning checking if user turned conjunctions on
  if (globalParams.generateConjunctions == CONJUNCTIONS_ON)
  {
    if (featureSet.size() > 999)
      cerr << "WARNING: -g generate conjunctions flag specified with more "
           << "than 1000 features\n";

    if (max_id > 9999)  
    {
      cerr << "ERROR: -g generate conjunctions flag specified with "
           << "featureIDs over 10000\n";
      cerr << "       conjunction generation will be turned off.\n";
      globalParams.generateConjunctions = CONJUNCTIONS_OFF;
    }
  }

  // if the user didn't set conjunctions, decide if we should turn them on
  if (globalParams.generateConjunctions == CONJUNCTIONS_UNSET)
  {
    if ((featureSet.size() < 100) && (max_id < 10000))  
    {
      globalParams.generateConjunctions = CONJUNCTIONS_ON;
      if (globalParams.verbosity >= VERBOSE_MIN)
        cout << "Less than 100 features used: auto-generating conjunctions\n";
    }
    else globalParams.generateConjunctions = CONJUNCTIONS_OFF;
  }

  // create the network
  Network network(globalParams);
  network.CreateStructure();

  Example* example_pointer;

  if (globalParams.examplesInMemory)
  {
    if (globalParams.generateConjunctions != CONJUNCTIONS_OFF
        || globalParams.calculateExampleSize)
      // This means examples have already been read into memory.
    {
      int i;
      if (globalParams.generateConjunctions == CONJUNCTIONS_ON
          && globalParams.writeConjunctions)
      {
        for (i = 0; i < training_set.size(); ++i)
        {
          training_set[i].GenerateConjunctions();
          training_set[i].Write(outputConjunctionStream);
        }
      }
      else if (globalParams.generateConjunctions == CONJUNCTIONS_ON)
      {
        for (i = 0; i < training_set.size(); ++i)
          training_set[i].GenerateConjunctions();
      }
    }
    else // Otherwise, examples haven't been read into memory yet.
    {
      while (!trainStream.eof())
      {
        if (example.ReadLabeled(trainStream))
        {
          training_set.push_back(example);
          training_set[training_set.size() - 1].features.free_unused_space();
        }
        else if (!trainStream.eof())
        {
          cerr << "Failed reading example " << (training_set.size() + 1)
               << " from " << globalParams.inputFile.c_str() << endl;
        }
      }
    }
  }
  else example_pointer = &example;


  int mistakes = 1;
  for (globalParams.currentCycle = 1;
       globalParams.currentCycle <= globalParams.cycles
       && (mistakes || (globalParams.currentCycle == 2
                        && globalParams.noFirstCycleUpdate));
      ++globalParams.currentCycle)
  {
    if (globalParams.verbosity >= VERBOSE_MED)
      *globalParams.pResultsOutput << "Starting training cycle "
                                   << globalParams.currentCycle << endl;

    examples = 0;
    mistakes = 0;

    while (examples < training_set.size() || !trainStream.eof())
    {
      if (!(examples % 1000) && globalParams.currentCycle == 1)
        network.Discard();

      if (globalParams.examplesInMemory)
        example_pointer = &training_set[examples];
      else
      {
        if (!example.ReadLabeled(trainStream))
        {
          if (!trainStream.eof())
          {
            cerr << "Failed reading example " << (examples + 1) << " from "
                 << globalParams.inputFile.c_str() << endl;
          }
          continue;
        }
        
        if (globalParams.generateConjunctions == CONJUNCTIONS_ON)
          example.GenerateConjunctions();
        if (globalParams.writeConjunctions)
          example.Write(outputConjunctionStream);
      }

      ++examples;

      if (globalParams.verbosity == VERBOSE_MAX)
      {
        *globalParams.pResultsOutput << "Ex " << examples << " : ";
        example_pointer->Show(globalParams.pResultsOutput);
      }

      if (network.PresentExample(*example_pointer)) ++mistakes;

      if ((globalParams.verbosity == VERBOSE_MED) && !(examples % 100))
        *globalParams.pResultsOutput << examples << " examples presented\n";

      if (globalParams.curveInterval
          && !(examples % globalParams.curveInterval)
          && (globalParams.currentCycle > 1
              || !globalParams.noFirstCycleUpdate)
          && globalParams.testFile.length() > 0)
      {
        // New way to do the learning curve.  Now it just outputs testing
        // results after every curveInterval examples instead of dumping
        // another network.

        // Prepare network 
        network.TrainingComplete();  // Which also calls NormalizeConfidence()

        *globalParams.pResultsOutput << "Testing after " << examples
                                     << " examples in cycle "
                                     << globalParams.currentCycle << "...\n";
        BasicTest(network);
        *globalParams.pResultsOutput << endl;
      }
    }

    if (globalParams.currentCycle == 1
        && globalParams.eligibilityMethod == ELIGIBILITY_PERCENT)
      network.PerformPercentageEligibility();

    if (!globalParams.examplesInMemory)
    {
      trainStream.clear();
      trainStream.seekg(0L);
    }
  }

  if (globalParams.currentCycle <= globalParams.cycles
      && globalParams.verbosity >= VERBOSE_MIN)
  {
    cout << "Only " << globalParams.currentCycle - 1 << " cycle";
    if (globalParams.currentCycle - 1 == 1) cout << " was";
    else cout << "s were";
    cout << " run.\n";
  }

  network.TrainingComplete();  // Also calls NormalizeConfidence()
  network.Discard();

  ofstream output(globalParams.networkFile.c_str());

  if (!output)
  {
    cerr << "Fatal Error:\n";
    cerr << "Failed to open network file '" 
      << globalParams.networkFile.c_str()
      << "' for writing\n\n";
    Pause();
    return;
  }

  output.setf(ios::fixed);
  output.precision(8);

  network.Write(output);
  output.close();

  if (globalParams.testFile.length() > 0)
  {
    if (globalParams.examplesInMemory) training_set.clear();
    cout << "Training complete.  Testing...\n";
    globalParams.curveInterval = 0;
    globalParams.currentCycle = 0;
    globalParams.runMode = MODE_TEST;
    BasicTest(network);
  }
}


void Test()
{
  ifstream netStream(globalParams.networkFile.c_str());
  if (!netStream)
  {
    cerr << "Fatal Error:\n";
    cerr << "Failed to open network file '"
         << globalParams.networkFile.c_str() << "'\n\n";
    Pause();
    return;
  }

  Network network(globalParams);
  network.Read(netStream);

  // Copy the inputFile to testFile in this case
  globalParams.testFile = globalParams.inputFile;

  BasicTest(network);
}


void Interactive() 
{
  Network network(globalParams);

  ifstream netStream(globalParams.networkFile.c_str());
  if (!netStream) // Failed to open network file for input
    network.CreateStructure();
  else 
    network.Read(netStream);
  
  if (netStream.is_open())
    netStream.close();

  ifstream inStream(globalParams.inputFile.c_str());
  if (!inStream)
  {
    cerr << "Fatal Error:\n";
    cerr << "Failed to open input file: '"
	 << globalParams.inputFile.c_str() << "'\n\n";
    return;
  }

  // Open the error file if necessary
  ofstream errorStream;
  if (!globalParams.errorFile.empty())
  {
    errorStream.open(globalParams.errorFile.c_str());
    if (!errorStream)
    {
      cerr << "Fatal Error:\n";
      cerr << "Failed to open error file '" << globalParams.errorFile.c_str()
	   << "'\n\n";
      Pause();
      return;
    }
    else
    {
      errorStream << "Algorithms:\n";
      network.WriteAlgorithms(&errorStream);
      errorStream << endl;
    }
  }

  int examples = 0, correct = 0, suppressed = 0, not_labeled = 0;

  Example example(globalParams);
  while (!inStream.eof()) {
    
    example.Read(inStream);

    switch(example.command) 
    {
      case 'e':  // evaluate
	{
	  network.TrainingComplete();
	  TargetRanking rank(network.SingleTarget(), network.FirstThreshold(),
			     globalParams);
	  network.RankTargets(example, rank);
	  Output(rank, &errorStream, example, correct, suppressed, examples,
		 not_labeled);
	}
	break;
      case 'p':  // promote
      case 'd': // demote
	network.PresentInteractiveExample(example);
	break;
      default: // other -- error
	break;
    }
  }

  ofstream output(globalParams.networkFile.c_str());

  if (!output)
  {
    cerr << "Fatal Error:\n";
    cerr << "Failed to open network file '"
	 << globalParams.networkFile.c_str()
	 << "' for writing\n\n";
    Pause();
    return;
  }

  output.setf(ios::fixed);
  output.precision(8);

  network.Write(output);
  output.close();
}

void BasicTest(Network& network)
{
  ofstream outputConjunctionStream;
  if (globalParams.writeConjunctions)
  {
    string outputConjunctionFile = globalParams.testFile + ".conjunctions";
    outputConjunctionStream.open(outputConjunctionFile.c_str());
    if (globalParams.verbosity >= VERBOSE_MIN
        && globalParams.runMode != MODE_TRAIN)
      cout << "Writing test examples with conjunctions to file: '"
           << outputConjunctionFile << "'\n";
  }

  // Open the error file if necessary
  ofstream errorStream;
  if (!globalParams.errorFile.empty())
  {
    errorStream.open(globalParams.errorFile.c_str());
    if (!errorStream)
    {
      cerr << "Fatal Error:\n";
      cerr << "Failed to open error file '" << globalParams.errorFile.c_str()
           << "'\n\n";
      Pause();
      return;
    }
    else
    {
      errorStream << "Algorithms:\n";
      network.WriteAlgorithms(&errorStream);
      errorStream << endl;
    }        
  }

#ifdef SERVER_MODE_
  if (globalParams.serverPort > 0) RunServer(network);
  else
  {
#endif
    ifstream testStream(globalParams.testFile.c_str());
    if (!testStream)
    {
      cerr << "Fatal Error:\n";
      cerr << "Failed to open test file '" << globalParams.testFile.c_str()
           << "'\n\n";
      Pause();
      return;
    }

    Example example(globalParams);
    TargetRanking rank(network.SingleTarget(), network.FirstThreshold(),
		       globalParams);

    if (globalParams.verbosity >= VERBOSE_MIN
        && globalParams.curveInterval == 0)
    {
      // output algorithm information
      *globalParams.pResultsOutput << "Algorithm information:\n";
      network.WriteAlgorithms(globalParams.pResultsOutput);
    }

    int examples = 0, correct = 0, suppressed = 0, not_labeled = 0;

    while (!testStream.eof())
    {
      rank.clear(); 
      bool readResult = true;

      if (globalParams.labelsPresent)
        readResult = example.ReadLabeled(testStream);
      else readResult = example.Read(testStream);

      if (!readResult)
      {       
        if (!testStream.eof())
          cerr << "Failed reading example " << examples << " from "
               << globalParams.inputFile.c_str() << endl;
      }
      else
      {
        if (globalParams.generateConjunctions == CONJUNCTIONS_ON)
          example.GenerateConjunctions();
        if (globalParams.writeConjunctions)
          example.Write(outputConjunctionStream);
        network.RankTargets(example, rank);
        ++examples;

        Output(rank, &errorStream, example, correct, suppressed, examples,
               not_labeled);

        // If we're in online mode
        if (globalParams.onlineLearning && globalParams.runMode == MODE_TEST)
        {

          network.PresentExample(example);
          network.TrainingComplete();  // Also calls NormalizeConfidence()
       
        }
      }
    }

    if (globalParams.onlineLearning)
    {
      if (globalParams.eligibilityMethod == ELIGIBILITY_PERCENT)
        network.PerformPercentageEligibility();

      // write updated network from online learning to a new network file
      char newNetwork[256];
      strcpy(newNetwork,globalParams.networkFile.c_str());
      strcat(newNetwork, ".new");
      ofstream newNetworkOut(newNetwork);
      network.Write(newNetworkOut);
    }

    // take care of final output (accuracy, other statistics)
    //network.ShowSize();
    FinalOutput(*globalParams.pResultsOutput, correct, suppressed, examples,
                not_labeled);
  }
#ifdef SERVER_MODE_  // Yes, this line should come before
}                    // <-- this bracket.


void RunServer(Network& network)
{
  int sockfd, new_fd;  /* listen on sock_fd, new connection on new_fd */
  struct sockaddr_in my_addr;    /* my address information */
  struct sockaddr_in their_addr; /* connector's address information */
  socklen_t sin_size;

  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
  {
    cerr << "socket: " << strerror(errno) << endl;
    exit(1);
  }

  my_addr.sin_family = AF_INET;         /* host byte order */
  my_addr.sin_port = htons(globalParams.serverPort);
  my_addr.sin_addr.s_addr = INADDR_ANY; /* automatically fill with my IP */
  bzero(&(my_addr.sin_zero), 8);        /* zero the rest of the struct */

  if (bind(sockfd, (struct sockaddr*)&my_addr, sizeof(struct sockaddr)) == -1)
  {
    cerr << "bind: " << strerror(errno) << endl;
    exit(1);
  }

  if (listen(sockfd, BACKLOG) == -1)
  {
    cerr << "listen: " << strerror(errno) << endl;
    exit(1);
  }

  pthread_mutex_t lexiconMutex;
  pthread_mutex_init(&lexiconMutex, NULL);

  signal(SIGHUP, SigHandler);

  while (serverRun)
  {  /* main accept() loop */
    sin_size = sizeof(struct sockaddr_in);
    cout << "Waiting for clients...\n";

    if ((new_fd = accept(sockfd, (struct sockaddr*)&their_addr, &sin_size))
        == -1)
    {
      cerr << "accept: " << strerror(errno) << endl;
      continue;
    }

    cout << "SNoW: got connection from " << inet_ntoa(their_addr.sin_addr)
         << endl;

    ClientData cd;
    cd.fileDesc = new_fd;
    cd.network = &network;
    cd.pLexiconMutex = &lexiconMutex;

    //cout << "trying to create a thread\n";
    pthread_t theThread;
    int threadVal;

    threadVal = pthread_create(&theThread, NULL, ProcessSocket, &cd);
    //cout << threadVal << endl;
  }

  pthread_mutex_destroy(&lexiconMutex);

  close(sockfd);
}


void* ProcessSocket(void* clientData)
{
  
  int client_fd = ((ClientData*)clientData)->fileDesc;
  Network* network = ((ClientData*)clientData)->network;
  pthread_mutex_t* pLexiconMutex(((ClientData*)clientData)->pLexiconMutex);

  //<<<<<<< Snow.cpp
  //Vasin added
  pthread_mutex_lock(pLexiconMutex);

  //Example example;
  //TargetRanking rank(network->SingleTarget(), network->FirstThreshold());
  //=======
    Example example(globalParams);
    TargetRanking rank(network->SingleTarget(), network->FirstThreshold(),
  		     globalParams);
  //>>>>>>> 1.12

  // parent thread doesn't need to 'join' us
  pthread_detach(pthread_self()); 

  // Block the ourselves from handling SIGHUP
  // so the main thread always gets it 
  sigset_t blockSet;
  sigemptyset(&blockSet);
  sigaddset(&blockSet, SIGHUP);
  pthread_sigmask(SIG_BLOCK, &blockSet, NULL);

  char* options;
  if (receive_bytes(client_fd, options, 0))
  {
    ParseOptions(options);
    delete [] options;
  }

  char* header = new char[BUFFER_SIZE];
  globalParams.pResultsOutput = new ostrstream(header, BUFFER_SIZE);
  if (globalParams.verbosity >= VERBOSE_MIN)
  {
    // output algorithm information
    *globalParams.pResultsOutput << "Algorithm information:\n";
    network->WriteAlgorithms(globalParams.pResultsOutput);
  }

  send_bytes(client_fd, header, strlen(header), 0);
  delete globalParams.pResultsOutput;
  delete [] header;

  int examples = 0, correct, suppressed, not_labeled;
  int count;

  char* msg;
  char reply[BUFFER_SIZE];
  string allReply;

  do
  { 
    count = receive_bytes(client_fd, msg, 0);
   
    if (count > 0)
    {
       istrstream* testStream = new istrstream(msg);
      allReply = "";

      while (!(testStream->eof())) {
     
        memset(reply, 0, BUFFER_SIZE);
        globalParams.pResultsOutput = new ostrstream(reply, BUFFER_SIZE);

        rank.clear();
        bool readResult = true;

	// Jakob: here we decide whether to use the interactive mode for this example or do the normal stuff
	if(globalParams.runMode == MODE_INTERACTIVE)
	  {
	   
	    example.Read(*testStream);
	    switch(example.command) 
	      {
	      case 'e':  // evaluate
		{
		  network->TrainingComplete();
		  TargetRanking rank(network->SingleTarget(), network->FirstThreshold(),
				     globalParams);
		  network->RankTargets(example, rank);
		  Output(rank, NULL, example, correct, suppressed, examples,
			 not_labeled);
		      }
		break;
	      case 'p': // promote
	      case 'd': // demote
		network->PresentInteractiveExample(example);
	       
		break;
	      default: // other -- error
	       
		break;
	      }
		    
	  }
      
	else
	  {

	    if (globalParams.labelsPresent)
	      readResult = example.ReadLabeled(*testStream);
	    else readResult = example.Read(*testStream);
	    //delete testStream;
	    
	    if (!readResult) {
	      if (!(testStream->eof()))
		cout << "Failed reading example " << examples << " from client.\n";
	    }
	    else
	      {
		if (globalParams.generateConjunctions == CONJUNCTIONS_ON)
		  example.GenerateConjunctions();
		network->RankTargets(example, rank);
		++examples;
		
		Output(rank, NULL, example, correct, suppressed, examples,
		       not_labeled);
		
		// added by Jakob to enable incremental training in server mode
		// this does NOT prevent concurrency issues 4
		
		//cout <<"checking online learning..."<<endl;
		if (globalParams.onlineLearning)
		  {
		    // cout<<"Doing online learning..."<<endl;
		    //turn off sparse network flag - we need the features to appear every target
		    // in order to choose for which targets to promote/demote the feature in teaching mode
		    bool oldval = globalParams.sparseNetwork;
		    globalParams.sparseNetwork=false;
		    network->PresentExample(example);
		    network->TrainingComplete();  // Also calls NormalizeConfidence()
		    globalParams.sparseNetwork = oldval;
		  }
	      }
	  }
	allReply += string(reply);
	//send_bytes(client_fd, reply, strlen(reply), 0);
	
	//Jakob: now add the feature strengths to the output
	if(globalParams.showFeatureStrength)
	  {
	    //cout<<sum<<endl;sum=0.0;
	    allReply += CreateFeatureWeightOutput(rank, example, clientData) + "\n";
	  }

	delete globalParams.pResultsOutput;
      }
      
      char* allChReply = (char*)malloc(strlen(allReply.c_str()) + 1);
      strcpy(allChReply, allReply.c_str());
      send_bytes(client_fd, allChReply, strlen(allChReply), 0);

      delete testStream;
      delete [] msg;

    }

  } while (count != 0);

  // save network file if desired
  if(globalParams.optionalNetworkFile.length()>0)
    {
      cout<<"writing network file to "<<globalParams.optionalNetworkFile<<endl;
      ofstream newNetworkOut(globalParams.optionalNetworkFile.c_str());
      network->Write(newNetworkOut);
      newNetworkOut.close();
      //reset the parameter so we don't do this every time an example is presented
      globalParams.optionalNetworkFile = "";
    }

  cout << "Closing client socket...\n";
  close(client_fd);

  //Vasin added
  pthread_mutex_unlock(pLexiconMutex);

  //Jakob
  if(globalParams.runMode == MODE_INTERACTIVE)
    {
      //restore old mode
      globalParams.runMode = globalParams.runMode_old;
    }
	    
  return NULL;
}


void ParseOptions(char* options)
{
  cout << "Options: " << options << endl;

  options = strtok(options, " ");

  while (options)
  {
    while (options && options[0] != '-') options = strtok(NULL, " ");

    if (options)
    {
      char c = *++options;

      if (!*++options) options = strtok(NULL, " ");
      if (options)
      {
        switch (c)
        {
          case 'b':
            globalParams.bayesSmoothing = atof(options);
            break;

          case 'f':
            if (*options == '+') globalParams.fixedFeature = true;
            else if (*options == '-') globalParams.fixedFeature = false;
            break;
	    
	case 'i':
	  if(*options == '+') globalParams.onlineLearning=true;
	  else globalParams.onlineLearning=false;
	  break;    

          case 'L':
            globalParams.targetOutputLimit = atol(options);
            break;

          case 'l':
            if (*options == '+') globalParams.labelsPresent = true;
            else if (*options == '-') globalParams.labelsPresent = false;
            break;

          case 'm':
            if (*options == '+') globalParams.multipleLabels = true;
            else if (*options == '-') globalParams.multipleLabels = false;
            break;

          case 'o':
            if (!strcmp(options, "accuracy"))
              globalParams.predictMethod = ACCURACY;
            else if (!strcmp(options, "winners"))
              globalParams.predictMethod = WINNERS;
            else if (!strcmp(options, "allpredictions"))
              globalParams.predictMethod = ALL_PREDICTIONS;
            else if (!strcmp(options, "allactivations"))
              globalParams.predictMethod = ALL_ACTIVATIONS;
            else if (!strcmp(options, "allboth"))
              globalParams.predictMethod = ALL_BOTH;
            break;

          case 'p':
            globalParams.predictionThreshold = atof(options);
            break;

          case 'v':
            if (!strcmp(options, "off"))
              globalParams.verbosity = VERBOSE_QUIET;
            else if (!strcmp(options, "min"))
              globalParams.verbosity = VERBOSE_MIN;
            else if (!strcmp(options, "med"))
              globalParams.verbosity = VERBOSE_MED;
            else if (!strcmp(options, "max"))
              globalParams.verbosity = VERBOSE_MAX;
            break;

	   case 'w':
            globalParams.smoothing = atof(options);
            break;
	  	
	case 'x': // JAKOB: write network file to given filename
	  globalParams.optionalNetworkFile = options;
	  break; 
	   
	case 'y': // JAKOB: return feature weights of winning label
	  if(*options == '+') globalParams.showFeatureStrength=true;
	  else globalParams.showFeatureStrength=false;
	  break; 

	case 'z': // JAKOB: for this example in server mode, go into interactive mode
	  if(*options == '+')
	    {
	      globalParams.runMode_old = globalParams.runMode;
	      globalParams.runMode=MODE_INTERACTIVE;
	    }
	  else globalParams.showFeatureStrength=false;
	  break; 

        }
      }

      options = strtok(NULL, " ");
    }
  }
}

// Jakob: the following *interactive* functions are a trivial server-implementation of the interactive mode.
void RunInteractiveServer()
{
  int sockfd, new_fd;  /* listen on sock_fd, new connection on new_fd */
  struct sockaddr_in my_addr;    /* my address information */
  struct sockaddr_in their_addr; /* connector's address information */
  socklen_t sin_size;

  Network network(globalParams);

  ifstream netStream(globalParams.networkFile.c_str());
  if (!netStream) // Failed to open network file for input
    network.CreateStructure();
  else 
    network.Read(netStream);
  
  if (netStream.is_open())
    netStream.close();
  
  if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
  {
    cerr << "socket: " << strerror(errno) << endl;
    exit(1);
  }

  my_addr.sin_family = AF_INET;         /* host byte order */
  my_addr.sin_port = htons(globalParams.serverPort);
  my_addr.sin_addr.s_addr = INADDR_ANY; /* automatically fill with my IP */
  bzero(&(my_addr.sin_zero), 8);        /* zero the rest of the struct */

  if (bind(sockfd, (struct sockaddr*)&my_addr, sizeof(struct sockaddr)) == -1)
  {
    cerr << "bind: " << strerror(errno) << endl;
    exit(1);
  }

  if (listen(sockfd, BACKLOG) == -1)
  {
    cerr << "listen: " << strerror(errno) << endl;
    exit(1);
  }

  pthread_mutex_t lexiconMutex;
  pthread_mutex_init(&lexiconMutex, NULL);

  signal(SIGHUP, SigHandler);

  while (serverRun)
  {  /* main accept() loop */
    sin_size = sizeof(struct sockaddr_in);
    cout << "Waiting for clients...\n";

    if ((new_fd = accept(sockfd, (struct sockaddr*)&their_addr, &sin_size))
        == -1)
    {
      cerr << "accept: " << strerror(errno) << endl;
      continue;
    }

    cout << "SNoW: got connection from " << inet_ntoa(their_addr.sin_addr)
         << endl;

    ClientData cd;
    cd.fileDesc = new_fd;
    cd.network = &network;
    cd.pLexiconMutex = &lexiconMutex;

    //cout << "trying to create a thread\n";
    pthread_t theThread;
    int threadVal;

    threadVal = pthread_create(&theThread, NULL, ProcessSocketInteractive, &cd);
    //cout << threadVal << endl;
  }

  pthread_mutex_destroy(&lexiconMutex);

  close(sockfd);
}


void* ProcessSocketInteractive(void* clientData)
{
  int client_fd = ((ClientData*)clientData)->fileDesc;
  Network* network = ((ClientData*)clientData)->network;
  pthread_mutex_t* pLexiconMutex(((ClientData*)clientData)->pLexiconMutex);

  //<<<<<<< Snow.cpp
  //Vasin added
  pthread_mutex_lock(pLexiconMutex);

  //Example example;
  //TargetRanking rank(network->SingleTarget(), network->FirstThreshold());
  //=======
    Example example(globalParams);
    TargetRanking rank(network->SingleTarget(), network->FirstThreshold(),
  		     globalParams);
  //>>>>>>> 1.12

  // parent thread doesn't need to 'join' us
  pthread_detach(pthread_self()); 

  // Block the ourselves from handling SIGHUP
  // so the main thread always gets it 
  sigset_t blockSet;
  sigemptyset(&blockSet);
  sigaddset(&blockSet, SIGHUP);
  pthread_sigmask(SIG_BLOCK, &blockSet, NULL);

  char* options;
  if (receive_bytes(client_fd, options, 0))
  {
    ParseOptions(options);
    delete [] options;
  }

  char* header = new char[BUFFER_SIZE];
  globalParams.pResultsOutput = new ostrstream(header, BUFFER_SIZE);
  if (globalParams.verbosity >= VERBOSE_MIN)
  {
    // output algorithm information
    *globalParams.pResultsOutput << "Algorithm information:\n";
    network->WriteAlgorithms(globalParams.pResultsOutput);
  }

  send_bytes(client_fd, header, strlen(header), 0);
  delete globalParams.pResultsOutput;
  delete [] header;

  int examples = 0, correct, suppressed, not_labeled;
  int count;

  char* msg;
  char reply[BUFFER_SIZE];
  string allReply;

  do
  {
    count = receive_bytes(client_fd, msg, 0);
    if (count > 0)
    {
       istrstream* testStream = new istrstream(msg);
      allReply = "";

      while (!(testStream->eof())) {

        memset(reply, 0, BUFFER_SIZE);
        globalParams.pResultsOutput = new ostrstream(reply, BUFFER_SIZE);

        rank.clear();
        bool readResult = true;

        if (globalParams.labelsPresent)
          readResult = example.ReadLabeled(*testStream);
        else readResult = example.Read(*testStream);
        //delete testStream;

        if (!readResult) {
          if (!(testStream->eof()))
            cout << "Failed reading example " << examples << " from client.\n";
        }
        else
        {

	  switch(example.command) 
	    {
	    case 'e':  // evaluate
	      {
		network->TrainingComplete();
		TargetRanking rank(network->SingleTarget(), network->FirstThreshold(),
				   globalParams);
		network->RankTargets(example, rank);

		Output(rank, NULL, example, correct, suppressed, examples,
		       not_labeled);
		//	Output(rank, &errorStream, example, correct, suppressed, examples,
		//       not_labeled);
	      }
	      break;
	    case 'p':  // promote
	    case 'd': // demote
	      network->PresentInteractiveExample(example);
	      break;
	    default: // other -- error
	      break;
	    }
	  /*
	    if (globalParams.generateConjunctions == CONJUNCTIONS_ON)
	    example.GenerateConjunctions();
	    network->RankTargets(example, rank);
	    ++examples;
	    
	    Output(rank, NULL, example, correct, suppressed, examples,
	    not_labeled);
	    
	    // added by Jakob to enable incremental training in server mode
	    // this does NOT prevent concurrency issues 
	    
	    if (globalParams.onlineLearning)
	    {
	    network->PresentExample(example);
	    network->TrainingComplete();  // Also calls NormalizeConfidence()
	    }

	  */
        }

        allReply += string(reply);
        //send_bytes(client_fd, reply, strlen(reply), 0);

        delete globalParams.pResultsOutput;
      }

      char* allChReply = (char*)malloc(strlen(allReply.c_str()) + 1);
      strcpy(allChReply, allReply.c_str());
      send_bytes(client_fd, allChReply, strlen(allChReply), 0);

      delete testStream;
      delete [] msg;

    }

  } while (count != 0);

  cout << "Closing client socket...\n";
  close(client_fd);

  //Vasin added
  pthread_mutex_unlock(pLexiconMutex);

  return NULL;
}


#endif


void Output( TargetRanking &rank, ofstream* errorStream, Example &ex,
             int &correct, int &suppressed, int examples, int not_labeled )
{
  int i;
  bool prediction_wrong = false;
  FeatureID prediction;
  char prediction_text[32];
  ostrstream prediction_stream(prediction_text, 32);

  sort(rank.begin(), rank.end(), greater<TargetRank>());
  TargetRanking::iterator it = rank.begin();
  TargetRanking::iterator end = rank.end();

  if (globalParams.targetOutputLimit < rank.size())
    end = it + globalParams.targetOutputLimit;

  if (rank.single_target)
  {
    if (it->baseActivation >= rank.threshold)
    {
      prediction_stream << "positive";
      prediction = 1;
    }
    else
    {
      prediction_stream << "negative";
      prediction = 0;
    }

    if (ex.features.Targets() - prediction == 0) ++correct;
    else prediction_wrong = true;
  }
  else
  {
    if (globalParams.targetIds.size() == 1 || Predict(rank))
    {
      prediction = it->id;
      prediction_stream << prediction << '\0';
      if (ex.features.Targets() == 0) ++not_labeled;
      else if (ex.FeatureIsLabel(prediction)) ++correct;
      else prediction_wrong = true;
    }
    else
    {
      prediction = NO_PREDICTION;
      prediction_stream << "no prediction";
      prediction_wrong = ex.features.Targets() > 0;
      ++suppressed;
    }
  }

  switch (globalParams.predictMethod)
  {
    case ACCURACY:
      if (errorStream && errorStream->is_open() && prediction_wrong)
      {
        *errorStream << "Ex: " << examples << " Prediction: "
                     << prediction_text;
        if (ex.features.Targets() > 0)
        {
          *errorStream << " Label: " << ex.features[0].id;
          for (i = 1;
               i < ex.features.Targets() && globalParams.multipleLabels; ++i)
            *errorStream << ", " << ex.features[i].id;
        }
        else *errorStream << " Not labeled.";
        *errorStream << endl;

        for (; it != end; ++it)
        {   
          *errorStream << setprecision(5); 
          *errorStream << it->id << ":" << setw(14) << it->activation
                       << setw(14) << it->baseActivation;
          if (ex.FeatureIsLabel(it->id)) *errorStream << "*";
          *errorStream << endl;
        }

        *errorStream << endl;
        it = rank.begin();
      } 

      if (globalParams.verbosity == VERBOSE_MAX)
      {
        *globalParams.pResultsOutput << "  Ex" << examples << ": ";
        *globalParams.pResultsOutput << "Prediction - " << prediction_text
                                     << " (" << it->activation << ")\n";
      }
      else if ((globalParams.verbosity == VERBOSE_MED) && !(examples % 100))
        *globalParams.pResultsOutput << examples << " examples presented\n";
      break;

    case WINNERS:
      *globalParams.pResultsOutput << prediction_text << endl;
      break;

    case SOFTMAX:
      *globalParams.pResultsOutput << "Example " << examples;
      if (globalParams.labelsPresent)
      {
        if (ex.features.Targets() > 0)
        {
          *globalParams.pResultsOutput << " Label: " << ex.features[0].id;
          for (i = 1;
               i < ex.features.Targets() && globalParams.multipleLabels; ++i)
            *globalParams.pResultsOutput << ", " << ex.features[i].id;
        }
        else *globalParams.pResultsOutput << " Not labeled.";
      }
      *globalParams.pResultsOutput << endl; 

      for (; it != end; ++it)
      {   
        *globalParams.pResultsOutput << setprecision(5); 
        //globalParams.pResultsOutput->setf(ios::showpoint);
        *globalParams.pResultsOutput << it->id << ":" << setw(14)
                                     << it->softmax;
        if (ex.FeatureIsLabel(it->id)) *globalParams.pResultsOutput << "*";
        *globalParams.pResultsOutput << endl;
      }
      *globalParams.pResultsOutput << endl; 
      break;

    case ALL_ACTIVATIONS:
      *globalParams.pResultsOutput << "Example " << examples;
      if (globalParams.labelsPresent)
      {
        if (ex.features.Targets() > 0)
        {
          *globalParams.pResultsOutput << " Label: " << ex.features[0].id;
          for (i = 1;
               i < ex.features.Targets() && globalParams.multipleLabels; ++i)
            *globalParams.pResultsOutput << ", " << ex.features[i].id;
        }
        else *globalParams.pResultsOutput << " Not labeled.";
      }
      *globalParams.pResultsOutput << endl; 

      for (; it != end; ++it)
      {   
        *globalParams.pResultsOutput << setprecision(5); 
        //globalParams.pResultsOutput->setf(ios::showpoint);
        *globalParams.pResultsOutput << it->id << ":" << setw(14)
                                     << it->activation << setw(14)
                                     << it->baseActivation << setw(14)
                                     << it->softmax;
        if (ex.FeatureIsLabel(it->id)) *globalParams.pResultsOutput << "*";
        *globalParams.pResultsOutput << endl;
      }
      *globalParams.pResultsOutput << endl; 
      break;

    case ALL_PREDICTIONS:
      *globalParams.pResultsOutput << "Example " << examples;
      if (globalParams.labelsPresent)
      {
        if (ex.features.Targets() > 0)
        {
          *globalParams.pResultsOutput << " Label: " << ex.features[0].id;
          for (i = 1;
               i < ex.features.Targets() && globalParams.multipleLabels; ++i)
            *globalParams.pResultsOutput << ", " << ex.features[i].id;
        }
        else *globalParams.pResultsOutput << " Not labeled.";
      }
      *globalParams.pResultsOutput << endl;  

      for (; it != end; ++it)
      {   
        *globalParams.pResultsOutput << it->id << ":\t"
          << (rank.single_target ? prediction : (it->id == prediction));
        if (ex.FeatureIsLabel(it->id)) *globalParams.pResultsOutput << "*";
        *globalParams.pResultsOutput << endl;
      }
      *globalParams.pResultsOutput << endl; 
      break;

    case ALL_BOTH:
      *globalParams.pResultsOutput << "Example " << examples;
      if (globalParams.labelsPresent)
      {
        if (ex.features.Targets() > 0)
        {
          *globalParams.pResultsOutput << " Label: " << ex.features[0].id;
          for (i = 1;
               i < ex.features.Targets() && globalParams.multipleLabels; ++i)
            *globalParams.pResultsOutput << ", " << ex.features[i].id;
        }
        else *globalParams.pResultsOutput << " Not labeled.";
      }
      *globalParams.pResultsOutput << endl;         

      for (; it != end; ++it)
      {   
        *globalParams.pResultsOutput << setprecision(5); 
        *globalParams.pResultsOutput << it->id << ":\t" << setw(1)
          << (rank.single_target ? prediction : (it->id == prediction))
          << setw(14) << it->activation
          << setw(14) << it->baseActivation
          << setw(14) << it->softmax;
        if (ex.FeatureIsLabel(it->id)) *globalParams.pResultsOutput << "*";
        *globalParams.pResultsOutput << endl;
      }
      *globalParams.pResultsOutput << endl; 
      break;
  }
}


void FinalOutput( ostream& out, int correct, int suppressed, int examples,
                  int not_labeled )
{
  if (globalParams.labelsPresent)
  {
    if (globalParams.verbosity != VERBOSE_QUIET) 
    { 
      out << examples << " test examples presented\n";
      if (suppressed > 0) out << suppressed << " predictions suppressed\n";
    }

    double pctCorrect = (double) correct / (examples - suppressed);
    double pctPredict = 1.00 - ((double)suppressed / examples);

    out << "Overall Accuracy - " << setprecision(4) << (pctCorrect * 100.0)
        << "%  (" << correct << " / " << examples - suppressed;
    if (not_labeled)
      out << ", " << not_labeled << " of which weren't labeled";
    out << ")\n";
    if (suppressed > 0)
      out << " Prediction Rate - " << setprecision(4) << (pctPredict * 100.0)
          << "%\n";
  }
}


bool Predict( TargetRanking &ranking )
{
  // Check if we meet the threshold
  return (ranking[0].activation - ranking[1].activation)
         >= globalParams.predictionThreshold;
}


FeatureID Evaluate()
{
  ifstream netStream(globalParams.networkFile.c_str());

  if (!netStream)
  {
    cerr << "Fatal Error:\n";
    cerr << "Failed to open network file '"
         << globalParams.networkFile.c_str() << "'\n\n";
    Pause();
    return (FeatureID)-1;
  }

  Network network(globalParams);
  network.Read(netStream);

  Example ex(globalParams);
  ex.Parse(globalParams.evalExample);
  if (globalParams.generateConjunctions == CONJUNCTIONS_ON)
    ex.GenerateConjunctions();

  TargetRanking rank(globalParams);
  FeatureID prediction;    
  char prediction_text[32];
  ostrstream prediction_stream(prediction_text, 32);
  network.RankTargets(ex, rank);

  sort( rank.begin(), rank.end(), greater<TargetRank>() );

  // check to see if we meet the predictionThreshold,
  // unless we only have one target
  if (network.SingleTarget())
  {
    if (rank.begin()->baseActivation >= network.FirstThreshold())
    {
      prediction = 1;
      prediction_stream << "positive";
    }
    else
    {
      prediction = 0;
      prediction_stream << "negative";
    }
  }
  else
  {
    if (globalParams.targetIds.size() == 1 || Predict(rank))
    {
      prediction = rank.begin()->id;
      prediction_stream << prediction;
    }
    else
    {
      prediction = NO_PREDICTION;
      prediction_stream << "no prediction";
    }
  }

  *globalParams.pResultsOutput << "For example: ";
  ex.Show(globalParams.pResultsOutput);
  *globalParams.pResultsOutput << "Prediction is " << prediction_text << endl;

  return prediction;
}


void ShowOptions()
{
  if (globalParams.verbosity != VERBOSE_QUIET)
  {
    if (globalParams.runMode != MODE_EVAL
        && globalParams.runMode != MODE_SERVER)
      cout << "Input file: '" << globalParams.inputFile << "'\n";

    cout << "Network file: '" << globalParams.networkFile << "'\n";

    if (globalParams.testFile.length() > 0)
      cout << "Test file: '" << globalParams.testFile << "'\n";

    if (globalParams.errorFile.length() > 0)
      cout << "Error file: '" << globalParams.errorFile << "'\n";

#ifdef SERVER_MODE_
    if (globalParams.runMode == MODE_SERVER)
      cout  << "Server port: " << globalParams.serverPort << endl;
#endif

    if (globalParams.runMode == MODE_TRAIN)
    {
      cout << "Training with " << globalParams.cycles
           << " cycles over training data.\n";
      if (globalParams.examplesInMemory)
        cout << "Storing examples in memory.\n";
      if (globalParams.discardMethod == DISCARD_ABS)
        cout << "Absolute discarding @ " << globalParams.discardThreshold
             << endl;
    }

    if (globalParams.rawMode)
      cout << "Conventional (\"raw\") mode enabled.\n";

    if (globalParams.thickSeparator.positive
        || globalParams.thickSeparator.negative)
      cout << "Thick separator set to "
           << globalParams.thickSeparator.positive << ", "
           << globalParams.thickSeparator.negative << ".\n";

    if (globalParams.threshold_relative)
      cout << "Threshold relative updating enabled.\n";

    if (globalParams.constraintClassification)
      cout << "Training with constraint classification enabled.\n";

    if (globalParams.gradientDescent)
      cout << "Gradient descent function approximation enabled.\n";
  }
}

void Pause()
{
  cerr << "Press Enter to continue... ";
  cin.ignore(999,'\n');
}

string CreateFeatureWeightOutput(TargetRanking &rank, Example &example, void* clientData)
{
   // Jakob: used to output weights of all features in a given example
  // after the the normal Output() is done for an example.
  // To use this feature, use the "-y + " parameter in server mode
  string allStrength;
  Network* network = ((ClientData*)clientData)->network;

  if(example.features.Size() >1) allStrength += "Feature Weights\n";
  // get winning target
  sort(rank.begin(), rank.end(), greater<TargetRank>());
  int targetid = (*(rank.begin())).id;
  vector<Cloud>*  cv = network->getClouds();
  vector<Target>* tv = (*cv)[targetid-1].getTargets();

  double weight=0.0;
  double num;
  char buf[30];
  for(int i=2;i<example.features.Size();i++)
    {
      // cout<<"feature ID:"<<example.features[i].id<<endl;
      // find the maximum weight for this feature among all the targets
      double maxweight_other=0.0;
      double currweight_other=0.0;
      for(TargetRanking::const_iterator tri = rank.begin(); tri!=rank.end(); tri++)
	{
	  int target = (*tri).id;
	  vector<Target>* tp = (*cv)[target-1].getTargets();
	  currweight_other=0.0;
	  for(int k=0;k<tp->size();k++)
	    {
	      num = (*tp)[k].WeightOfFeature(example.features[i].id);
	      if(num == 1e300)
		{
		  num=0.0;
		}
	      currweight_other += num;
	    }
	  if(targetid != target && currweight_other>maxweight_other) 
	    maxweight_other = currweight_other;
	}

      // get the winning target's weight
      weight=0.0;
      for(int k=0;k<(*tv).size();k++)
	{
	  num = (*tv)[k].WeightOfFeature(example.features[i].id);
	  if(num == 1e300)
	    {
	      num=0.0;
	    }
	  weight += num;
	}
      allStrength += string(gcvt(weight, 5, buf));
      if(weight> maxweight_other)
	allStrength += "*"; 
      allStrength += "\n";
      //cout<<maxweight_other<<" "<<weight<<endl;
    }
  return allStrength;
}
