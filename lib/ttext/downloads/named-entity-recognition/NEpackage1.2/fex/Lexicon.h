//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Lexicon.h                                     =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef __LEXICON_H__
#define __LEXICON_H__

#include <string>
#include <fstream>
#include <set>
#include "Fex.h"


using namespace std;

typedef enum {LABEL_TRUE = 3000, LABEL_FALSE} LabelVal;

const int HIGH_LAB = 1000;

struct FeatureData
{
    int id;
    int count;
};

#ifdef HASH_MAP
  typedef hash_map<string,FeatureData> mapType;
#else
  typedef map<string,FeatureData> mapType;
#endif

class Lexicon : public mapType
{
public:
	Lexicon( const char* filename, int start_id, const char* sw, 
         bool ro = false );
	~Lexicon();

	// operations
	int		Lexical2Id( const string& lex, LabelVal lab );

    void    ReadFrequency( const char* filename );
    
    void    WriteFrequency( const char* filename );
    void    WriteFrequencyByFeature( const char* filename );
    
protected:
			// initialize the lexicon from a file
	bool	Read();
	bool	WriteMapping( int id, const string& lex );

	// member variables
	int		nextid;
   int      nextlab;
   ifstream  lexinStr;
   ofstream  lexoutStr;
   bool     readOnly;
   ifstream  stopwordsFile;
   set<string> stopWords;
};
 
#endif
