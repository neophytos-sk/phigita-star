//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Lexicon.cpp                                   =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#pragma warning( disable:4786 )

#include "Lexicon.h"
#include <iostream>
#include <iomanip>
#include <set>
#include <fstream>

#ifndef WIN32
#define ios_base ios
#endif

Lexicon::Lexicon( const char* filename, int start_id, const char* sw, bool ro)  
         : lexinStr(filename), lexoutStr(filename,ios_base::app), 
           stopwordsFile(sw), nextid(start_id), readOnly(ro), nextlab(1) 
         
{
   if(lexinStr)
      Read();
      
   //Build stopWords from file
   if(stopwordsFile)
   { 
      string stopword;
      while (!stopwordsFile.eof()) 
      {
         stopwordsFile >> stopword;
         if (!stopwordsFile.fail())
         {
            stopWords.insert(stopword);
         } else if (!stopwordsFile.eof()) 
         {
           cerr << "I/O operation Failed while reading stopwords" << endl;
         }
      }
      stopwordsFile.close();
   }
}

Lexicon::~Lexicon()
{
   if (lexinStr.is_open()) 
      lexinStr.close();
   if (lexoutStr.is_open())
      lexoutStr.close();
}


int Lexicon::Lexical2Id( const string& lex, LabelVal lab )
{
  //Check whether lex _contains_ a stopWord, if so return -1 so it doesn't get
  //added to examples
  for (set<string>::iterator it = stopWords.begin(); 
       it != stopWords.end(); it++) {
    if (strstr(lex.c_str(), it->c_str()) != NULL) return -1;
  }

  int id;

  iterator fm;
  if ((fm = find(lex)) != end()) {
    id = fm->second.id;
    fm->second.count++;
  } else {
    if (readOnly) 
      return -1;

    FeatureData fd;
    if(lab==LABEL_TRUE)
      id = fd.id = nextlab++;
    else
      id = fd.id = nextid++;
    fd.count = 1;
    (*this)[lex] = fd;
    WriteMapping(fd.id, lex);
  }
  return id;
}



bool Lexicon::Read()
{
	lexinStr.seekg(0L);
	while (!lexinStr.eof())
	{
		int id = 0;
		string lex;

		lexinStr >> id >> lex;
		if (id >= nextid) 
         nextid++;
      if ((id < HIGH_LAB) && (id >= nextlab)) 
         nextlab++; 
		if (lexinStr.fail() && !lexinStr.eof())
		{
			char delim;

			cerr << "Failed reading lexicon entry!" << endl;
            cerr << "  Ignoring rest of line:";
            lexinStr.clear();
            lexinStr.get(delim);
            while (!lexinStr.eof() && (delim != '\n'))
            {
                cerr.put(delim);
                lexinStr.get(delim);
            }
            cerr << endl;
		} else {
            if (lexinStr.eof()) continue;

            //if (id == 0)
             //   cout << "Found it with " << size()
               //      << " entries in the map! " << endl;
        
            FeatureData fd;
            fd.id = id;
            fd.count = 0;
            (*this)[lex] = fd;
		}
	}

	lexinStr.clear();

	return true;
}

bool Lexicon::WriteMapping( int id, const string& lex )
{
	// Assumes we're at the end of the file
	lexoutStr << id << '\t' << lex << endl;
	if (lexoutStr.fail())
	{
		cerr << "Failed writing lexicon entry!" << endl;
		lexoutStr.clear();
		return false;
	}

	return true;
}

void Lexicon::ReadFrequency( const char* filename )
{
    ifstream histogramFile(filename);
    if (!histogramFile)
    {
        cerr << "Failed to open histogram file '"
             << filename << "' for input" << endl;
        cerr << "  No initial counts were read!" << endl;
        return;
    }
    
	while (!histogramFile.eof())
	{
		int count = 0;
		string lex;

		histogramFile >> lex >> count;
		if (histogramFile.fail() && !histogramFile.eof())
		{
			char delim;

			cerr << "Failed reading histogram entry!" << endl;
            cerr << "  Ignoring rest of line:";
            histogramFile.clear();
            histogramFile.get(delim);
            while (!histogramFile.eof() && (delim != '\n'))
            {
                cerr.put(delim);
                histogramFile.get(delim);
            }
            cerr << endl;
		} else {
            if (histogramFile.eof()) continue;
            
            FeatureData fd;
            fd.id = Lexical2Id(lex, LABEL_FALSE);
            fd.count = count;
			(*this)[lex] = fd;
		}
	}

    histogramFile.clear();
}

    
void Lexicon::WriteFrequency( const char* filename )
{
    ofstream histogramFile(filename);
    if (!histogramFile)
    {
        cerr << "Failed to open histogram output file '"
             << filename << "'" << endl;
        cerr << "  No output will be written!" << endl;
        return;
    }

    int error_count = 0;

    set<int> counts;
    
	const_iterator fm = begin();
	while (fm != end())
	{
       // if (fm->second.count == 0)
           // cout << "Found It! string:'" << fm->first
           //      << "'  id: " << fm->second.id 
           //      << "  count: " << fm->second.count << endl;
        
        counts.insert(fm->second.count);        
        fm++;
	}

    set<int>::const_reverse_iterator theCount = counts.rbegin();
	while (theCount != counts.rend())
	{
        set<string> features;
        
        for (fm = begin(); fm != end(); fm++)
        {
            if (fm->second.count == *theCount)
                features.insert(fm->first);
        }

        set<string>::const_iterator theFeature = features.begin();
        while (theFeature != features.end())
        {
            string filler;
            int len = 24 - theFeature->length();
            if (len < 1) len = 1;
            filler.assign(len, ' ');
            histogramFile << *theFeature << filler
                          << setw(6) << *theCount << endl ;
            if (histogramFile.fail())
            {
                if (error_count < 10)
                {
                    cerr << "Failed writing histogram entry!" << endl;
                    if (error_count == 9)
                        cerr << "No more error notifications will be written!" << endl;
                }
                histogramFile.clear();
                error_count++;
            }

            theFeature++;
        }

        theCount++;
	}
}

void Lexicon::WriteFrequencyByFeature( const char* filename )
{
    ofstream histogramFile(filename);
    if (!histogramFile)
    {
        cerr << "Failed to open histogram output file '"
             << filename << "'" << endl;
        cerr << "  No output will be written!" << endl;
        return;
    }
    
    int error_count = 0;
    
	const_iterator fm = begin();
	while (fm != end())
	{
        string filler;
        int len = 24 - fm->first.length();
        if (len < 1) len = 1;
        filler.assign(len, ' ');
		histogramFile << fm->first << filler
                      << setw(6) << fm->second.count << endl ;
        if (histogramFile.fail())
        {
            if (error_count < 10)
            {
                cerr << "Failed writing histogram entry!" << endl;
                if (error_count == 9)
                    cerr << "No more error notifications will be written!" << endl;
            }
            histogramFile.clear();
            error_count++;
        }
        fm++;
	}

    histogramFile.close();
}

