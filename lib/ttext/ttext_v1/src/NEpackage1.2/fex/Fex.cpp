//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Fex.cpp                                       =
//=  Version: 2.0                                           =
//=   Author: Chad Cumby, Wen-Tau Yih, Jeff Rosen           =
//=     Date: 98-03                                         =
//=                                                         =
//= Comments:                                               =
//===========================================================

#pragma warning( disable:4786 )

using namespace std;

#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <iostream>
#include <sstream>
#include <strstream>
#include <algorithm>
#include <strings.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <signal.h>
#include <pthread.h>
#include <time.h>
//#include <wn.h>

#include "Fex.h"
#include "FexParams.h"
#include "Parser.h"
#include "Sparser.h"
#include "RGF.h"
#include "SendReceive.h"
//#include "Stats.h"

typedef vector<StringVector> TargetVector;
typedef vector<RGF> Script;

// #define DEBUG_FEX_SERVER

#define BACKLOG 5
#define BUFFER_SIZE 80000

#ifdef GETOPT
extern "C"
{
extern int getopt(int, char* const *, const char*);
extern char *optarg;
}
#else
#define ios_base ios
#endif

const char TARGET_STRING[] = "*";
const char TARGET_CHAR = '*';
const char FILLER_STRING[] = "_";
const char FILLER_CHAR = '_';

const char* logo[] = {"Fex - Feature Extractor",
		      "Cognitive Computations Group - University of Illinois at Urbana/Champaign",
		      "Version 2.3.1"};

static int serverRun = 1;

struct ClientData
{
    int                 fileDesc;
    Script*             pScript;
    Lexicon*            pLexicon;
    pthread_mutex_t*    pLexiconMutex;
  pthread_mutex_t*    clientMutex;
    TargetVector*       pTargetWords;
};

void RunBatch( Script& script, Lexicon& lexicon );
void GenExample(Script& script, Lexicon& lexicon, istream& Corpus, 
		ostream& Example, TargetVector& targetWords, 
		long &exNo, pthread_mutex_t* pLexiconMutex = NULL);
void RunServer( Script& script, Lexicon& lexicon );
void SigHandler( int sig );
void* ProcessSocket( void* clientData );

void BuildTargetWords( const char* targetsFilename, TargetVector& targets );
void BuildScript( const char* scriptFilename, Script& script );
void ShowUsage( const char* cmd );

void ShowFeatureSet( FeatureSet& vec );
void WriteFeatureSet( ostream& outputStream, FeatureSet& theSet1 );
void ShowStringVector( const StringVector& vec );

int* GetTargetArray(char* msg);

static set<long> preserved_ex;

int main( int argc, char* argv[] )
{
  // Initialize randome number generator
  time_t tmp_t;
  srand((unsigned int) time(&tmp_t));

    if (ParseCmdLine(argc, argv))
    {
        if (ValidateParams())
        {
         if (globalParams.verbosity != VERBOSE_QUIET)
         {
            cout << endl;
            int n = sizeof logo / sizeof logo[0];
            for (int i = 0; i < n; i++)
            {
               cout << logo[i] << endl;
            }
         }


         Script script;
         BuildScript(globalParams.scriptFile, script);

         Lexicon lexicon(globalParams.lexiconFile,
                            1001,
                            globalParams.stopwordsFile,
                            globalParams.readOnlyLexicon);
         
         // Load preserved example no. if requred, by Scott Yih, 04/05/02
         if (globalParams.preservedFile != NULL) {

           // 0 = success for 'access'
           if (access(globalParams.preservedFile, R_OK) == 0) {
             ifstream fin(globalParams.preservedFile);
             if (fin) {
               long ex_no;
               
               while (fin >> ex_no) {
                 if (globalParams.verbosity >= VERBOSE_MED)
                   cout << "perservedFile ex_no=" << ex_no << endl;

                 preserved_ex.insert(ex_no);
               }
             }
           }
         }
                
         // Load existing histogram if possible
         if (globalParams.histogramFile != NULL)
         {
             // 0 = success for 'access'
             if (access(globalParams.histogramFile, R_OK) == 0)
             {
                 if (globalParams.verbosity >= VERBOSE_MIN)
                     cout << "Reading current counts (histogram)" << endl;
                 lexicon.ReadFrequency(globalParams.histogramFile);
             }
         }


         if (globalParams.serverPort > 0)
         {
             RunServer(script, lexicon);
         } else {
	   RunBatch(script, lexicon);
	   while (globalParams.nonstop)
             RunBatch(script, lexicon);
         }

         // Output histogram if requested
         if (globalParams.histogramFile != NULL)
         {
             if (globalParams.verbosity >= VERBOSE_MIN)
                 cout << "Writing histogram" << endl;
             if (globalParams.histogramByFeature)
                 lexicon.WriteFrequencyByFeature(globalParams.histogramFile);
             else
                 lexicon.WriteFrequency(globalParams.histogramFile);
         }

        } else {
            ShowUsage(argv[0]);
        }
    } else {
        ShowUsage(argv[0]);
    }

    return 0;
}

void RunBatch(Script& script, Lexicon& lexicon) {
  // example no. --  used in phrase case only; Scott Yih 04/05/02
  long exNo = 0;

  // Open the corpus file for input
  ifstream corpusFile(globalParams.corpusFile);
  if (!corpusFile) {
    cerr << "Failed to open the corpus file '"
	 << globalParams.corpusFile
	 << "' for reading!" << endl;
    exit(1);
  }
  
  // Open the example file for output
  ofstream exampleFile(globalParams.exampleFile,
		       ios_base::app);
  if (!exampleFile) {
    cerr << "Failed to open the example file '"
	 << globalParams.exampleFile
	 << "' for writing!" << endl;
    exit(1);
  }
  
  // Create vector of target words from file
  TargetVector targetWords;
  if (globalParams.targetsFile != NULL)
    BuildTargetWords(globalParams.targetsFile, targetWords);

  GenExample(script, lexicon, corpusFile, exampleFile, targetWords, exNo);

  exampleFile.close();
  corpusFile.close();

  if (globalParams.verbosity >= VERBOSE_MED)
    cout << "exNo = " << exNo << endl;
}


void RunServer( Script& script, Lexicon& lexicon )
{

  // Initialize WordNet  
  /*    if (wninit())
        {
        cerr << "problem during wninit" << endl;
        exit(1);
        }
   */

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

  pthread_mutex_t clientMutex;
  pthread_mutex_init(&clientMutex, NULL);

  signal(SIGHUP, SigHandler);

  // Store the process ID in a file so that web server running utility can know which pID refers to which process.
  if (globalParams.processIDfilename.length() != 0)
  {
    ofstream out(globalParams.processIDfilename.c_str());
    if (!out)
    {
      cerr << "Could not open process ID file for output.\n";
      exit(1);
    }

    out << (int)getpid() << endl;
    out.close();
  }

  while (serverRun)
  {  /* main accept() loop */
    sin_size = sizeof(struct sockaddr_in);
    cout << "Waiting for clients...\n";

    if ((new_fd = accept(sockfd, (struct sockaddr*)&their_addr, &sin_size)) == -1)
    {
      cerr << "accept: " << strerror(errno) << endl;
      continue;
    }

    cout << "fex: got connection from " << inet_ntoa(their_addr.sin_addr) << endl;

    ClientData cd;
    cd.fileDesc = new_fd;
    cd.pScript = &script;
    cd.pLexicon = &lexicon;
    cd.clientMutex = &clientMutex;

    // cout << "trying to create a thread" << endl;
    pthread_t theThread;
    int threadVal;

    threadVal = pthread_create(&theThread, NULL, ProcessSocket, &cd);
    // cout << threadVal << endl;
  }

  pthread_mutex_destroy(&clientMutex);

  close(sockfd);
}

void SigHandler( int sig )
{
    cout << "SigHandler got signal " << sig << "..." << endl;
    serverRun = 0;
}

void* ProcessSocket( void* clientData )
{

#ifdef DEBUG_FEX_SERVER
    cerr << "## trying to process socket..." << endl;
#endif
    static char resp[] = "Hello, world!\n";

    int client_fd = ((ClientData*)clientData)->fileDesc;
    Script& script(*((ClientData*)clientData)->pScript);
    Lexicon& lexicon(*((ClientData*)clientData)->pLexicon);
    pthread_mutex_t* clientMutex(((ClientData*)clientData)->clientMutex);

    // parent thread doesn't need to 'join' us
    pthread_detach(pthread_self());

    // Block the ourselves from handling SIGHUP
    // so the main thread always gets it
    sigset_t blockSet;
    sigemptyset(&blockSet);
    sigaddset(&blockSet, SIGHUP);
    pthread_sigmask(SIG_BLOCK, &blockSet, NULL);

#ifdef DEBUG_FEX_SERVER
    cerr << "## set up pthread stuff..." << endl;

    if(!globalParams.newParse)
      cerr << "## warning: old parse format expected." << endl;
#endif



    int count = 1;
    while (count != 0)
    {
        char* msg;
        char reply[BUFFER_SIZE];

        memset(reply, 0, BUFFER_SIZE);

#ifdef DEBUG_FEX_SERVER
	cerr << "## called memset successfully; ready to receive message size..."  << endl;
#endif

        count = receive_bytes(client_fd, msg, 0);

#ifdef DEBUG_FEX_SERVER
	cerr << "##count is: " << count << endl;
#endif

        //cout<<"Got that:"<<msg;
        if (count > 0)
        {
            pthread_mutex_lock(clientMutex);
            int* targetIndex;
            Sentence* sentence = new Sentence();
            int sentenceStart = 0;



            bool notEof;
            if (!globalParams.newParse)
            {
	      cout<<"1"<<endl;
              char* colonLoc = strchr(msg, ':');
	       cout<<"2"<<endl;
              if (colonLoc == NULL) continue;
	       cout<<"3"<<endl;

              sentenceStart = colonLoc - msg + 1;
#ifdef DEBUG_FEX_SERVER
	      cerr<<"before targetarray"<<endl;

#endif

              targetIndex = GetTargetArray(msg);

#ifdef DEBUG_FEX_SERVER
	      cerr<<"received targetarray....first:"<<targetIndex[0]<<endl;

#endif
              // Negative target tell server to modify script on -1, shutdown on
              // all else
              if (targetIndex[0] < 0)
              {
                  if (targetIndex[0] == -1) 
                  {
                     int commandStart = colonLoc - msg + 1;
                     script.push_back(RGF());
//                     script.back().Parse(&msg[commandStart]);
                    if (globalParams.verbosity >= VERBOSE_MAX)
                    {
                      cout << "Script contains:" << endl;
                      for (Script::iterator pRel = script.begin();
                           pRel != script.end(); pRel++)
                      {
                        pRel->Show();
                        cout << endl;
                      }
                    }
                  }
                  else
                  {
                    cout << "Raising SIGHUP..." << endl;
                    raise(SIGHUP);
                  }
                  count = 0;
                  continue;
              }
            }


#ifdef DEBUG_FEX_SERVER
	      cerr << "ready to parse sentence ..."<<endl;
#endif

            // The currently installed version of g++ doesn't support
            // istringstream, so I am using istrstream which uses a 
            // nul-terminated buffer rather than a string object.
            // You may want to change this in the future

            istrstream sentenceStream(&msg[sentenceStart]);
            Parser theParser(sentenceStream);

            if (!globalParams.newParse)
            {
               notEof = theParser.OldParseSentence(*sentence);
            }
            else
            {
              notEof = theParser.NewParseSentence(*sentence);
              targetIndex = new int[sentence->size() + 1];
              int i;
              for (i = 0; i < sentence->size(); i++) 
		targetIndex[i] = i;

              targetIndex[i] = -2;
            }

            if (!notEof) continue;

#ifdef DEBUG_FEX_SERVER
            cerr << "Sentence: " << &msg[sentenceStart] << endl;

#endif
	    string fullReply = "";

            int nAppendLocation = 0;
            for (int nTargetArrayIndex = 0; targetIndex[nTargetArrayIndex] != -2; nTargetArrayIndex++)
            {
              FeatureSet* example = new FeatureSet();

	      if(!example) {
		cerr << "ERROR: processsocket(): failed to allocate FeatureSet..." << endl;
	      }

	      int pRelCount = 0;

              // Generate example
              for (Script::iterator pRel = script.begin(); pRel != script.end(); pRel++)
              { 
		pRelCount++;
#ifdef DEBUG_FEX_SERVER
		cerr << "## extracting features for pRel " << pRelCount << "... " <<  endl;

#endif

                // Generate features for example
                RawFeatureSet features = pRel->Extract(*sentence, targetIndex[nTargetArrayIndex]);

                RawFeatureSet::iterator pFeat; 


#ifdef DEBUG_FEX_SERVER
            cerr << "## adding features to lexicon and example... iterating over "
		 << features.size() << " features..." << endl;

	    int featID = 0;
#endif

                for (pFeat = features.begin(); pFeat != features.end(); pFeat++) 
                {
                  int idFeature;

#ifdef DEBUG_FEX_SERVER
		  cerr << "## processing feature " << featID << endl;
#endif

//                  pthread_mutex_lock(pLexiconMutex);
                  if (pFeat->substr(0, 6) == "label[")
                    idFeature = lexicon.Lexical2Id(*pFeat, LABEL_TRUE);
                  else
                    idFeature = lexicon.Lexical2Id(*pFeat, LABEL_FALSE);
//                  pthread_mutex_unlock(pLexiconMutex);

                  if (idFeature > 0) 
                  {
                    if (globalParams.verbosity >= VERBOSE_MAX) 
                    {
                       cout << "Adding feature '" << *pFeat; 
                       cout << "' as id " << idFeature << endl;
                    }

#ifdef DEBUG_FEX_SERVER
		    cerr << "##Adding feature '" << *pFeat; 
		    cerr << "' as id " << idFeature << endl;
#endif
		    if(example->size() < example->max_size())
		      example->insert(idFeature);
		    else {

		      cerr << "WARNING: example reached maximum size; failed to insert "
			   << "feature " << idFeature << endl; 
		    }
                  }
                }
#ifdef DEBUG_FEX_SERVER
		featID++;
#endif
		
              }
#ifdef DEBUG_FEX_SERVER
	      cerr << "## finshed adding features to lexicon and example... " << endl;

#endif

	      
	      if (!example->empty())
	      {
                if (globalParams.verbosity >= VERBOSE_MED)
                  ShowFeatureSet(*example); 

//                 ostrstream* exampleStream = new ostrstream(reply + nAppendLocation, sizeof(reply) - nAppendLocation);

		ostringstream exampleStream;

#ifdef DEBUG_FEX_SERVER
		cerr << "## writing feature set..." << endl;

#endif

//                 WriteFeatureSet(*exampleStream, *example);

		WriteFeatureSet(exampleStream, *example);

#ifdef DEBUG_FEX_SERVER
		cerr << "## wrote feature set..." << endl;

#endif
		fullReply += exampleStream.str();

//                 nAppendLocation = strlen(reply);
//                 delete exampleStream;

#ifdef DEBUG_FEX_SERVER
		cerr << "## deleted exampleStream..." << endl;

#endif

              }

              delete example;

#ifdef DEBUG_FEX_SERVER
	      cerr << "## deleted example..." << endl;

#endif

            } //end loop over array

            delete [] targetIndex;
            delete sentence;

#ifdef DEBUG_FEX_SERVER
	      cerr << "## deleted targetIndex[], sentence..." << endl;

#endif

            pthread_mutex_unlock(clientMutex);

#ifdef DEBUG_FEX_SERVER
	      cerr << "## unlocked clientMutex..." << endl;

#endif

//             cout << "Replying:\n" << reply << endl;
             cout << "Replying:\n" << fullReply << endl;

#ifdef DEBUG_FEX_SERVER
	    cerr << "## Replying: \n" << fullReply << endl;

#endif

	    char reply[fullReply.length()+1];

	    strcpy(reply, fullReply.c_str());

             send_bytes(client_fd, reply, strlen(reply), 0);



#ifdef DEBUG_FEX_SERVER
	      cerr << "##sent bytes... deleting msg..." << endl;

#endif

            delete [] msg;
        }
    }

    cout << "Closing client socket..." << endl;
#ifdef DEBUG_FEX_SERVER
	      cerr << "## Closing client socket..." << endl;

#endif

    close(client_fd);

#ifdef DEBUG_FEX_SERVER
	      cerr << "## returning..." << endl;

#endif

    return NULL;    
}

int* GetTargetArray(char* msg)
{
  int size = 8, index = 0;
  int* result = new int[size];
  char* end = strchr(msg, ':');

  while (msg != NULL && msg < end)
  {
    result[index] = atoi(msg);

    if (++index == size)
    {
      int* temp = new int[size * 2];
      for (int i = 0; i < size; i++) temp[i] = result[i];
      delete [] result;
      result = temp;
      size *= 2;
    }

    msg = strchr(msg, ',');
    if (msg != NULL) msg++;
  }

  for (; index < size; index++) result[index] = -2;

  return result;
}


void GenExample(Script& script, Lexicon& lexicon, 
		istream& corpusStream, 
		ostream& exampleStream, 
		TargetVector& targetWords, 
		long& exNo, 
		pthread_mutex_t* pLexiconMutex)
{
  Parser theParser(corpusStream);
  if (globalParams.rawInput) theParser.Form1Only(true);

  if (globalParams.verbosity >= VERBOSE_MIN)
    cout << "Processing..." << endl;

  Sentence sentence;
  FeatureSet example;
  RelationInSentence relSent;
  bool notEof = true;

  int lineCount = 0;
  while (notEof) {
    lineCount++;

    if ((lineCount%5000 == 0) && globalParams.verbosity >= VERBOSE_MIN)
      cout << "line: " << lineCount << endl;

    if (!globalParams.newParse)
      notEof = theParser.OldParseSentence(sentence);
    else if (!globalParams.erExtension)
      notEof = theParser.NewParseSentence(sentence);
    else // globalParams.newParse && globalParams.erExtension
      notEof = theParser.NewParseSentence(sentence, &relSent);

    if (!notEof) {
      continue;
    }

    // Determine the set of target indices
    // To make it compatible to phrase case, I changed it to set of pair int
    // <startPos, length>
    // Modified by Scott Yih, 09/24/01
    vector<pair<int,int> > targetIndices;

    if (globalParams.docMode && sentence[0].words[0] == "-") {
      if (!example.empty()) {
	WriteFeatureSet(exampleStream, example);
	example.clear();
      }
      continue;
    }
    // If there is a targetwords file, set the indices without
    // looking at the script.
    else if (targetWords.size() > 0 || globalParams.targetOne) {
      // if targetOne is true then use first target and then pop
      // it, else iterate over the targets
      TargetVector::iterator targetV = targetWords.begin();

      while (targetV != targetWords.end()) {
	// Scan and add each occurence of the target
	for (int i = 0; i < sentence.size(); i++) {

	  for (StringVector::const_iterator pFeat = 
		 sentence[i].words.begin();
	       pFeat != sentence[i].words.end(); pFeat++)
	    if (*targetV->begin() == *pFeat) {
	      targetIndices.push_back(pair<int,int>(i,1));
	      break;
	    }
	}
	if (globalParams.targetOne) {
	  targetWords.erase(targetV);
	  break;
	} else {
	  targetV++;
	}
      }
    }
    // phrase case
    // Added by Scott Yih, 09/24/01
    else if (globalParams.phraseCase) {
      if (globalParams.maxPhraseLeng > 0) {
	for (int i = 0; i < sentence.size(); i++)
	  for (int j = 1; j <= globalParams.maxPhraseLeng; j++)
	    if ((i+j-1) < sentence.size()) {
	      bool isPositive = false;

	      // check if it's a positive example
	      if (sentence[i].phraseLabel.find("B-") != string::npos) {
		int k;
		for (k = 1; k < j; k++)
		  if (sentence[i+k].phraseLabel.find("I-") == string::npos)
		    break;
		if (k == j) // it's a positive example
		  isPositive = true;
	      }

	      if (isPositive) {
		exNo++;
		if ((globalParams.preservedFile == NULL) ||
		    (preserved_ex.find(exNo) != preserved_ex.end())) {
		  //cout << "exNo = " << exNo << endl;
		  targetIndices.push_back(pair<int,int>(i,j));
		}
	      }
	      else {
		double r = (double)rand()/(double)RAND_MAX;
		if (r < globalParams.negativeRatio) {
		  exNo++;
		  if ((globalParams.preservedFile == NULL) ||
		      (preserved_ex.find(exNo) != preserved_ex.end())) {
		    // cout << "exNo = " << exNo << endl;
		    targetIndices.push_back(pair<int,int>(i,j));
		  }
		}
	      }
	    }
      } // if (globalParams.maxPhraseLeng > 0)
      else { // suppose (globalParams.maxPhraseLeng == 0)
	// find only positive examples
	for (int i = 0; i < sentence.size(); i++) {
	  if (sentence[i].phraseLabel.find("B-") != string::npos) {
	    int stPos = i;
	    i++;
	    while (i < sentence.size()) {
	      if (sentence[i].phraseLabel.find("I-") == string::npos)
		break;
	      i++;
	    }
	    exNo++;
	    if ((globalParams.preservedFile == NULL) || 
		(preserved_ex.find(exNo) != preserved_ex.end()))
	      targetIndices.push_back(pair<int,int>(stPos, i-stPos));
	    i--;
	  }
	}
      }
    }
    // ER case
    // Added by Scott Yih, 01/08/02
    else if (globalParams.erExtension) {
      if (globalParams.labelType == ENTITY) { // Entity as label
	for (int i = 0; i < sentence.size(); i++)
	  for(StringVector::iterator it = sentence[i].namedEntities.begin();
	      it != sentence[i].namedEntities.end(); it++) // the 2nd column
	    if(*it != "O")
	      targetIndices.push_back(pair<int,int>(i, 1));
      } else { // labelType == RELATION; Relation as label
	
	StringVector::const_iterator it, jt;
	int i, j;
	
	// find every pair of entities
	for (i = 0; i < sentence.size(); i++) {
	  for(it = sentence[i].namedEntities.begin();
	      it != sentence[i].namedEntities.end(); it++) // the 2nd column
	    if(*it != "O") { // It's an entity.
	      for (int j = i + 1; j < sentence.size(); j++)
		for(jt = sentence[j].namedEntities.begin();
		    jt != sentence[j].namedEntities.end(); jt++)
		  if (*jt != "O") { // It's an entity
		    
		    /* BE CAREFUL!!!  BE CAREFUL!!!  BE CAREFUL!!!  BE CAREFUL!!!
		       The integer pair indicates the position of (Arg1, Arg2). */
		    
		    targetIndices.push_back(pair<int,int>(i, j));
		    targetIndices.push_back(pair<int,int>(j, i));
		    
		    if (globalParams.verbosity > VERBOSE_MIN) {
		      cerr << "inserted pair: (" << i << ", " << j << ")" << endl
			   << "inserted pair: (" << j << ", " << i << ")" << endl;
		    }
		  }
	    }
	}
      }
    }
    else {
      // If there's no targetwords file, set the target indices
      // from the script
      
      // * somehow i think this shouldn't be so complicated, but
      // maybe it's necessary. cc
      set<int> indexSet;

      Script::iterator pRel = script.begin();
      while (pRel != script.end()) {
	if (pRel->TargetIndex() == TARGET_ALL) {
	  for (int i = 0; i < sentence.size(); i++)
	    targetIndices.push_back(pair<int,int>(i,1));
	  break;
	}
	else if ((pRel->TargetIndex() == TARGET_NULL)
		 && (pRel->Target() != NULL)) {
	  // Scan for each occurence of the target word
	  for (int i = 0; i < sentence.size(); i++) {
	    for (StringVector::const_iterator pFeat = 
		   sentence[i].words.begin();
		 pFeat != sentence[i].words.end(); pFeat++)
	      if (*pFeat == (pRel->Target()) && 
		  indexSet.find(i) == indexSet.end()) {
		targetIndices.push_back(pair<int,int>(i,1));
		indexSet.insert(i);
		break;
	      }
	  }
	} 
	else if (pRel->TargetIndex() >= 0)
	  if(indexSet.find(pRel->TargetIndex()) == indexSet.end()) {
	    targetIndices.push_back(pair<int,int>(pRel->TargetIndex(),1));
	    indexSet.insert(pRel->TargetIndex());
	  }
	pRel++;
      }
    }

        
    // for each index, build and write an example
    for (vector<pair<int,int> >::iterator ti = targetIndices.begin();
	 ti != targetIndices.end();
	 ti++) {
      // Reset the example
      if (!globalParams.docMode)
	example.clear();

      int targetIndex = ti->first;
      if (globalParams.verbosity >= VERBOSE_MAX)
	cout << "Target index is " << targetIndex << endl;
      
      bool labelFlag = false;
      Script::iterator pRel = script.begin();
      while (pRel != script.end()) {
	bool wordMatched = false;

	if (pRel->Target() != NULL) {
	  for (StringVector::const_iterator pFeat = sentence[targetIndex].words.begin();
	       pFeat != sentence[targetIndex].words.end(); pFeat++)
	    if (*pFeat == pRel->Target()) {
	      wordMatched = true;
	      break;
	    }
	}
	else
	  wordMatched = false;

	if ((pRel->TargetIndex() == targetIndex) ||
	    (pRel->TargetIndex() == TARGET_ALL) ||
	    (targetWords.size() > 0) ||
	    wordMatched) {
	  // set the label flag to determine whether to break if no
	  // labels exist
	  if(pRel->Mode() == EXTRACT_LABEL)
	    labelFlag = true;
	  else
	    labelFlag = false;
	  
	  // Generate features for example
	  RawFeatureSet features;
	  if (globalParams.phraseCase) {
	    features = pRel->Extract(sentence, ti->first, ti->second);
	  }
	  else if (globalParams.erExtension && globalParams.labelType == RELATION) {
	    features = pRel->ExtractRelation(sentence, relSent, ti->first, ti->second);
	  }
	  else {
	    features = pRel->Extract(sentence, ti->first);
	  }

	  // If the label function returns nothing, we don't want to
	  // continue with this example, so we don't process any more
	  // RGF's
	  //
	  // I don't know if this is what we want, but it's definitely not needed for docMode
	  // Scott Yih, 12/04/03
	  if (!globalParams.docMode)
	    if(labelFlag && features.size() == 0)
	      break;

	  RawFeatureSet::iterator pFeat;
	  for (pFeat = features.begin(); pFeat != features.end();
	       pFeat++) {
	    int idFeature;

	    if (pLexiconMutex != NULL && !globalParams.readOnlyLexicon)
	      pthread_mutex_lock(pLexiconMutex);

	    if (pFeat->length() >= 6 && pFeat->substr(0,6)=="label[")
	      idFeature = lexicon.Lexical2Id(*pFeat, LABEL_TRUE);
	    else
	      idFeature = lexicon.Lexical2Id(*pFeat, LABEL_FALSE);

	    if (pLexiconMutex != NULL && !globalParams.readOnlyLexicon)
	      pthread_mutex_unlock(pLexiconMutex);	    

	    if (idFeature > 0) {
	      if (globalParams.verbosity >= VERBOSE_MAX) {
		cout << "Adding feature '" << *pFeat;
		cout << "' as id " << idFeature << endl;
	      }
	      example.insert(idFeature);
	    }
	  }
	  pRel++;
	}
	else {
	  pRel++;
	  continue;
	}
      }

      if (!example.empty()) {
	if (globalParams.verbosity >= VERBOSE_MED)
	  ShowFeatureSet(example);
	if (!globalParams.docMode)
	  WriteFeatureSet(exampleStream, example);
      }
    }
    
  }
}

void BuildTargetWords( const char* targetsFilename, TargetVector& targets )
{
   ifstream targetsFile(targetsFilename);
   if (!targetsFile)
   {
      cerr << "Failed to open the targets file '" << targetsFilename << "'" << endl;
      return;
   }

   StringVector temp;
   char*        tempstr;
   char         tempar[256];

   while (!targetsFile.eof())
   {
      tempstr = tempar;
      targetsFile.getline(tempstr, 256);

      if (!targetsFile.fail())
      {
         char* pToken = strtok(tempstr, " \t\r\n");
         while (pToken != NULL) {
            temp.push_back(pToken);
            pToken = strtok(NULL, " \t\r\n");
         }
         targets.push_back(temp);
         if (globalParams.verbosity >= VERBOSE_MAX) {
            StringVector::iterator it = temp.begin();
            cout << "Added '" << *it << "' to targets" << endl;
         }
         temp.erase(temp.begin(), temp.end());
      } else if (!targetsFile.eof()) {
         cerr << "I/O operation Failed while reading targets files" << endl;
      }
   }
}

void BuildScript( const char* scriptFilename, Script& script )
{
   if (globalParams.newScripting)
   {
      Script* scr = DoParse(scriptFilename);
      if (scr)
      {
         if (globalParams.verbosity >= VERBOSE_MAX)
         {
            cout << "Script contains:" << endl;

            for (Script::iterator ef = scr->begin();
                  ef != scr->end(); ef++)
            {
               ef->Show();
            }
         }
         script = *scr;
         delete scr;
      }
      else
      {
         cerr << "script parsing error" << endl;
         exit(1);
      }
   }
   else
   {
      /*
      ifstream scriptFile(scriptFilename);
      if (!scriptFile)
      {
         cerr << "Failed to open the script file '" << scriptFilename << "'" << endl;
         exit(1);
      }

      string lineBuffer;
      while (!scriptFile.eof())
      {
         getline(scriptFile, lineBuffer);
         if (!scriptFile.fail() && lineBuffer.length() > 0)
         {
            script.push_back(RGF());
            script.back().Parse(lineBuffer);
         }
      }

      if (globalParams.verbosity >= VERBOSE_MAX)
      {
         cout << "Script contains:" << endl;
         for (Script::const_iterator ef = script.begin();
               ef != script.end(); ef++)
         {
            ef->Show();
         }
      }
      */
      cout << "not yet back-compatible." << endl;
      exit(1);
   }
}

void ShowUsage( const char* cmd )
{
  cerr << logo[0] << endl
       << logo[1] << endl
       << logo[2] << endl;
  cerr << "Usage: fex [options] <script-file> <lexicon-file> <corpus-file> <example-file>" << endl;
}

void ShowFeatureSet( FeatureSet& theSet )
{
   FeatureSet::const_iterator elem = theSet.begin();
   while (elem != theSet.end())
   {
      if (elem == theSet.begin())
      {
         cout << *elem;
      } else {
         cout << ", " << *elem;
      }
      elem++;
   }
   cout << ':' << endl;
}

void WriteFeatureSet( ostream& outputStream, FeatureSet& theSet)
{
#ifdef DEBUG_FEX_SERVER
    cerr << "## in WriteFeatureSet()..." << endl;
#endif

   FeatureSet::const_iterator elem = theSet.begin();

#ifdef DEBUG_FEX_SERVER
    cerr << "## got iterator from featureset..." << endl;
#endif


   while (elem != theSet.end()) {

#ifdef DEBUG_FEX_SERVER
     cerr << "## elem is " << *elem << endl;
#endif



     if(!(outputStream.fail())) {
       if (elem == theSet.begin()) {

	 outputStream << *elem;

       }
       else {

	 outputStream << ", " << *elem;
       }
     }
     else {
       cerr << "ERROR: writefeatureset(): ostream failed." << endl;
       return;
     }

#ifdef DEBUG_FEX_SERVER
     cerr << "## incrementing elem..." << endl;
#endif

     elem++;

#ifdef DEBUG_FEX_SERVER
     cerr << "## incremented elem successfully..." << endl;
#endif

   }
   outputStream << ':' << endl;

#ifdef DEBUG_FEX_SERVER
    cerr << "## leaving WriteFeatureSet()..." << endl;
#endif

}

void ShowStringVector( StringVector& vec )
{
   StringVector::const_iterator elem = vec.begin();
   while (elem != vec.end())
   {
      cout << *elem << ' ';
      elem++;
   }

   cout << endl;
}







