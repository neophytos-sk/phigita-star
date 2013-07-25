//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Sensor.cpp                               	    =
//=  Version: x.x                                           =
//=   Author: Scott Wen-tau Yih                             =
//=     Date: 10/29/00                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================

#include "Sensor.h"
#include "FexParams.h"

/*
extern "C" {
#include "./wn/wn.h"
}
*/

#include <stdio.h>
#include <stdlib.h>

#include <fstream>

#include <string>
#include <vector>
#include <set>

#include <stdexcept>
#include <cctype>

//--------------------------------------------------------------

const char TARGET_STRING[] = "*";
const char TARGET_CHAR = '*';
const char FILLER_STRING[] = "_";
const char FILLER_CHAR = '_';
const char POS_STRING[] = "+";

//--------------------------------------------------------------

void Sensor::Locational( string& lex, int loc )
{
	static const char filler = FILLER_CHAR;

	// Make a local copy so that primitive and lex may
	// reference the same string.
	string temp(lex);

	// clear out the existing lexical string
	lex.resize(0);

	if (loc > 0)
	{
		lex.append(1, TARGET_CHAR);
		lex.append(loc - 1, filler);
	}
	lex.append(temp);
	if (loc < 0)
	{
		lex.append(-loc - 1, filler);
		lex.append(1, TARGET_CHAR);
	}
}


// feat is the string for lexicon; checkFeat is the string for internal checking
void Sensor::Output( RawFeatureSet &outSet, string feat, int loc)
{
	if (includeLocation)
		Locational(feat, loc);

	if (feat != "")
		outSet.insert(feat);
}

//--------------------------------------------------------------

// this extracts the word token itself
void SensorWord::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
	   
		Output(outSet, *pFeat, targLoc);
	}
}

//--------------------------------------------------------------

// part of speech tag
void SensorTag::Extract( Sentence &sentence, RawFeatureSet &outSet,
                          int rec, int targLoc )
{
   StringVector inSet = sentence[rec].tags;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
		Output(outSet, *pFeat, targLoc);
	}
}

//--------------------------------------------------------------

void SensorRole::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].func;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
		Output(outSet, *pFeat, targLoc);
	}
}

//--------------------------------------------------------------

void SensorPhrase::Extract( Sentence &sentence, RawFeatureSet &outSet,
                            int rec, int targLoc )
{
   StringVector inSet = sentence[rec].phrasal;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
		Output(outSet, *pFeat, targLoc);
	}
}

//--------------------------------------------------------------

//fires if vowel exists in target
void SensorVowel::Extract( Sentence &sentence, RawFeatureSet &outSet,
                            int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
		string feat(*pFeat);

		switch (feat[0])
		{
		    case 'a':
		    case 'e':
		    case 'i':
		    case 'o':
		    case 'u':
		      Output(outSet, feat, targLoc);
		      break;
		    default:
		      break;
		}
	}
}

//--------------------------------------------------------------

// fires if one prefix of a list of prefixes exists in target
void SensorPre::Extract( Sentence &sentence, RawFeatureSet &outSet,
                          int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
   for(StringVector::iterator pWord = inSet.begin();
       pWord != inSet.end(); pWord++)
   {
      string feat;
      if (pWord->length() > 3)
      {
            if(pWord->substr(0,2) == "co")
               feat = "co";
            if(pWord->substr(0,2) == "in")
               feat = "in";
            if(pWord->substr(0,1) == "a")
               feat = "a";
            if(pWord->substr(0,2) == "re")
               feat = "a";
            if(pWord->substr(0,2) == "de")
               feat = "de";
            if(pWord->substr(0,3) == "pre")
               feat = "pre";
            if(pWord->substr(0,3) == "con")
               feat = "con";
            if(pWord->substr(0,3) == "dis")
               feat = "dis";
      }

      if (feat.length() > 0)
      {
//         if (optParam.length() >= feat.length())
//	      optParam = optParam.substr(0, feat.length());
         Output(outSet, feat, targLoc);
      }
   }
}

//--------------------------------------------------------------

//  fires if certain suffix appears in target
void SensorSuf::Extract( Sentence &sentence, RawFeatureSet &outSet,
                          int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
   for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
   {
      string feat;
      if (pWord->length() > 3)
      {
            if(pWord->substr(pWord->length()-3, 3) == "ing")
               feat = "ing";
            if(pWord->substr(pWord->length()-4, 4) == "ment")
               feat = "ment";
            if(pWord->substr(pWord->length()-3, 3) == "ful")
               feat = "ful";
            if(pWord->substr(pWord->length()-3, 3) == "ion")
               feat = "ion";
            if(pWord->substr(pWord->length()-2, 2) == "ed")
               feat = "ed";
            if(pWord->substr(pWord->length()-2, 2) == "ly")
               feat = "ly";
            if(pWord->substr(pWord->length()-2, 2) == "al")
               feat = "al";
            if(pWord->substr(pWord->length()-3, 3) == "ist")
               feat = "ist";
            if(pWord->substr(pWord->length()-1, 1) == "s")
               feat = "s";
      }

      if (feat.length() > 0)
      { 
// if (optParam.length() >= feat.length()) 
// optParam = optParam.substr(optParam.length() - feat.length(), 
// feat.length());
         Output(outSet, feat, targLoc);
      }
   }
}

//--------------------------------------------------------------

void SensorLem::Extract( Sentence &sentence, RawFeatureSet &outSet,
                          int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
   for(StringVector::iterator pFeat = inSet.begin();
      pFeat != inSet.end(); pFeat++)
   {
      for(int wnpos = 1; wnpos <= 4; wnpos++)
      {
         char* wnOutput;
         char* rawFeat = new char[pFeat->length()+1];

         pFeat->copy(rawFeat, string::npos);
         rawFeat[pFeat->length()] = 0;

         if(rawFeat != NULL)
	         // wnOutput = morphword(rawFeat, wnpos);
         if(wnOutput != NULL)
         {
	         string feat(wnOutput);
	         Output(outSet, feat, targLoc);
         }
      }
   }
}

//--------------------------------------------------------------

void SensorBase::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
	  string checkFeat(*pFeat);

	  StringMap::iterator it = baseTags.find(*pFeat);

	  string feat;
	  if(it != baseTags.end())
	    feat = it->second;
	  else
	    feat = "NN";

	  Output(outSet, feat, targLoc);
	}
}

void SensorTabA::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
	  string checkFeat(*pFeat);

	  StringMap::iterator it = table.find(*pFeat);

	  string feat;
	  if(it != table.end())
     {
	    feat = it->second;
	    Output(outSet, feat, targLoc);
     }
	}
}

void SensorTabB::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
	  string checkFeat(*pFeat);

	  StringMap::iterator it = table.find(*pFeat);

	  string feat;
	  if(it != table.end())
     {
	    feat = it->second;
	    Output(outSet, feat, targLoc);
     }
	}
}

void SensorTabC::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
	  string checkFeat(*pFeat);

	  StringMap::iterator it = table.find(*pFeat);

	  string feat;
	  if(it != table.end())
     {
	    feat = it->second;
	    Output(outSet, feat, targLoc);
     }
	}
}

void SensorTabD::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
	  string checkFeat(*pFeat);

	  StringMap::iterator it = table.find(*pFeat);

	  string feat;
	  if(it != table.end())
     {
	    feat = it->second;
	    Output(outSet, feat, targLoc);
     }
	}
}

void SensorTabE::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
	for(StringVector::iterator pFeat = inSet.begin();
 	    pFeat != inSet.end(); pFeat++)
	{
	  string checkFeat(*pFeat);

	  StringMap::iterator it = table.find(*pFeat);

	  string feat;
	  if(it != table.end())
     {
	    feat = it->second;
	    Output(outSet, feat, targLoc);
     }
	}
}

//--------------------------------------------------------------

void SensorTarg::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
   if (rec == targLoc)
   {
	   for(StringVector::iterator pFeat = inSet.begin();
 	      pFeat != inSet.end(); pFeat++)
	   {
		   string feat(*pFeat);

		   Output(outSet, feat, targLoc);
	   }
   }
}


//---Yair's additional Sensors --------------------------

// fires if target is capitalized
void  SensorCapitlized::Extract( Sentence &sentence, RawFeatureSet &outSet,
                                  int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
   for(StringVector::iterator pFeat = inSet.begin();
         pFeat != inSet.end(); pFeat++)
   {
      string feat(*pFeat);

      if ((feat[0] >= 'A') && (feat[0] <= 'Z'))
      {
         Output(outSet, feat, targLoc);
      }
   }
}

//--------------------------------------------------------------

// fires if target contains hyphen
void SensorHasHyphen::Extract( Sentence &sentence, RawFeatureSet &outSet,
                                int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
   for(StringVector::iterator pWord = inSet.begin();
         pWord != inSet.end(); pWord++)
   {
      string feat;
      char *tmp=NULL;
      if (pWord->length() > 1)
      {
         tmp = strrchr((*pWord).c_str(),'-');
         if( tmp != NULL)
            feat = "hyphen";
      }

      if (feat.length() > 0)
         Output(outSet, feat, targLoc);
   }
}


//--------------------------------------------------------------

//---Vasin's additional Sensors --------------------------
// Jakob: I changed some of those to make sure we are talking about letters
bool isLetter(char x)
{
  if( (x>='a' && x<='z') || (x>='A' && x<='Z'))
    return true;
  else
    return false;

}


// fires if initial letters are capitalized 
void SensorInitialCapitalized::Extract(Sentence &sentence,
                                       RawFeatureSet &outSet,
                                       int rec, int targLoc)
{
  //	cout<<"icap="<<sentence[rec].words[0]<<endl;
   const StringVector& inSet = sentence[rec].words;
   for(StringVector::const_iterator pFeat = inSet.begin();
       pFeat != inSet.end(); pFeat++)
   {
      try
      {
	if (isupper(pFeat->at(0)) && isLetter(pFeat->at(0)))
         {
            Output(outSet, string("x"), targLoc);
         }
      }
      catch(out_of_range)
      {
      }
   }
}

// fires if initial letter is lowercase capitalized
void SensorNotInitialCapitalized::Extract(Sentence &sentence,
                                       RawFeatureSet &outSet,
                                       int rec, int targLoc)
{
  //    cout<<"icap="<<sentence[rec].words[0]<<endl;
   const StringVector& inSet = sentence[rec].words;
   for(StringVector::const_iterator pFeat = inSet.begin();
       pFeat != inSet.end(); pFeat++)
   {
      try
      {
        if (!isupper(pFeat->at(0)) && isLetter(pFeat->at(0)))
         {
            Output(outSet, string("x"), targLoc);
         }
      }
      catch(out_of_range)
      {
      }
   }
}


// fires if all letters are capitalized
void SensorAllCapitalized::Extract(Sentence &sentence,
                                   RawFeatureSet &outSet,
                                   int rec, int targLoc)
{
   const StringVector& inSet = sentence[rec].words;
   for(StringVector::const_iterator pFeat = inSet.begin();
       pFeat != inSet.end(); pFeat++)
   {
      if (pFeat->length() > 0)
      {
         bool isAllCap = true;
         for(string::const_iterator pChar = pFeat->begin();
               pChar != pFeat->end(); pChar++)
            if (islower(*pChar) || !isLetter(*pChar))
            {
               isAllCap = false;
               break;
            }
         if (isAllCap)
            Output(outSet, string("x"), targLoc);
      }
   }
}

// fires if internal letters are capitalized
void SensorInternalCapitalized::Extract(Sentence &sentence,
                                        RawFeatureSet &outSet,
                                        int rec, int targLoc)
{
   const StringVector& inSet = sentence[rec].words;
   for(StringVector::const_iterator pFeat = inSet.begin();
       pFeat != inSet.end(); pFeat++)
   {
      if (pFeat->length() > 1)
      {
         bool isInternalCap = false;
         for(string::const_iterator pChar = pFeat->begin() + 1;
               pChar != pFeat->end(); pChar++)
            if (isupper(*pChar) && isLetter(*pChar))
            {
               isInternalCap = true;
               break;
            }
         if (isInternalCap)
            Output(outSet, string("x"), targLoc);
      }
   }
}

// fires if target is in lowercase letters
void SensorUncapitalized::Extract(Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int rec, int targLoc)
{
   const StringVector& inSet = sentence[rec].words;
   for(StringVector::const_iterator pFeat = inSet.begin();
       pFeat != inSet.end(); pFeat++)
   {
      if (pFeat->length() > 0)
      {
         bool isUncap = true;
         for(string::const_iterator pChar = pFeat->begin();
               pChar != pFeat->end(); pChar++)
            if (isupper(*pChar) || !isLetter(*pChar))
            {
               isUncap = false;
               break;
            }
         if (isUncap)
            Output(outSet, string("x"), targLoc);
      }
   }
}

//--------------------------------------------------------------

//---Scott's additional Sensors for phrase case ----------------

// Added on 09/27/01
// length of target phrase
void SensorPhraseLength::Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end )
{
  unsigned int length = end - start + 1;
  char buf[1024];
  snprintf(buf, 1023, "%u", length);

  // Assume targLoc = start - 1.  However, phrase type sensors
  //   should not be used along with location information.
  Output(outSet, string(buf), start-1);
}

//--------------------------------------------------------------

typedef enum { START, B_START, I_START, OUTSIDE, INSIDE, END } PhraseState;

// creates a feature corresping to the named entity entry of a target
void SensorNamedEntity::Extract( Sentence &sentence,
				 RawFeatureSet &outSet,
				 int start,
				 int end )
{
  // check the namedEntity tag of words[targIndex..targIndex+targLength-1]
  bool legitimate = false;
  string neTag, namedEntity;
  PhraseState cs;

  cs = START;

  cerr << "start = " << start << endl;

  // check the first word
  neTag = *(sentence[start].namedEntities.begin());

  if (neTag[0] == 'B' && neTag[1] == '-') {
    namedEntity = neTag.substr(2);
    cs = B_START;
  }
  else if (neTag[0] == 'I' && neTag[1] == '-') {
    namedEntity = neTag.substr(2);
    cs = I_START;
  }
  else
    cs = OUTSIDE;

  // check words within the target range
  for (int i = start + 1; i <= end; i++) {
    neTag = *(sentence[i].namedEntities.begin());

    switch (cs) {
      case B_START:
        if (neTag[0] == 'B' && neTag[1] == '-') {
          Output(outSet, "Containing-" + namedEntity, start-1);
          namedEntity = neTag.substr(2);
	  cs = INSIDE;
        }
	else if (neTag[0] == 'O') {
          Output(outSet, "Containing-" + namedEntity, start-1);
	  namedEntity = "";
          cs = OUTSIDE;
        }
        break;
      case I_START:
        if (neTag[0] == 'B' && neTag[1] == '-') {
          Output(outSet, "Overlap-" + namedEntity, start-1);
          namedEntity = neTag.substr(2);
          cs = INSIDE;
        }
        else if (neTag[0] == 'O') {
          Output(outSet, "Overlap-" + namedEntity, start-1);
          namedEntity = "";
          cs = OUTSIDE;
        }
        break;
      case INSIDE:
        if (neTag[0] == 'B' && neTag[1] == '-') {
          Output(outSet, "Containing-" + namedEntity, start-1);
          namedEntity = neTag.substr(2);
          cs = INSIDE;
        }
        else if (neTag[0] == 'O') {
          Output(outSet, "Containing-" + namedEntity, start-1);
          namedEntity = "";
          cs = OUTSIDE;
        }
        break;
      case OUTSIDE:
        if (neTag[0] == 'B' && neTag[1] == '-') {
          namedEntity = neTag.substr(2);
	  cs = INSIDE;
        }
        break;
      default:
	break;
    }
  }

  // check the word after
  if (end + 1 < sentence.size()) {
    int next = end + 1;
    neTag = *(sentence[next].namedEntities.begin());

    switch(cs) {
      case B_START:
        if (neTag[0] == 'I' && neTag[1] == '-')
          Output(outSet, "Contained-" + namedEntity, start-1);
        else
          Output(outSet, "Exact-" + namedEntity, start-1);
        break;
      case I_START:
        Output(outSet, "Contained-" + namedEntity, start-1);
        break;
      case INSIDE:
	if ((neTag[0] == 'I' && neTag[1] == '-') &&
            (namedEntity == neTag.substr(2)))
          Output(outSet, "Overlap-" + namedEntity, start-1);
        else
          Output(outSet, "Containing-" + namedEntity, start-1);
        break;
      case OUTSIDE:
      default:
        break;
    }
  }
  else { // treat it as O
    switch(cs) {
      case B_START:
        Output(outSet, "Exact-" + namedEntity, start-1);
        break;
      case I_START:
        Output(outSet, "Contained-" + namedEntity, start-1);
        break;
      case INSIDE:
        Output(outSet, "Containing-" + namedEntity, start-1);
        break;
      case OUTSIDE:
      default:
        break;
    }
  }
}

//--------------------------------------------------------------

void SensorChunk::Extract( Sentence &sentence,
                           RawFeatureSet &outSet,
                           int start,
                           int end )
{
  // check the namedEntity tag of words[targIndex..targIndex+targLength-1]
  bool legitimate = false;
  string phrasalTag, chunk;
  PhraseState cs;

  cs = START;

  // check the first word
  phrasalTag = *(sentence[start].phrasal.begin());

  if (phrasalTag[0] == 'B' && phrasalTag[1] == '-') {
    chunk = phrasalTag.substr(2);
    cs = B_START;
  }
  else if (phrasalTag[0] == 'I' && phrasalTag[1] == '-') {
    chunk = phrasalTag.substr(2);
    cs = I_START;
  }
  else
    cs = OUTSIDE;

  // check words within the target range
  for (int i = start + 1; i <= end; i++) {
    phrasalTag = *(sentence[i].phrasal.begin());

    switch (cs) {
      case B_START:
        if (phrasalTag[0] == 'B' && phrasalTag[1] == '-') {
          Output(outSet, "Containing-" + chunk, start-1);
          chunk = phrasalTag.substr(2);
	  cs = INSIDE;
        }
	else if (phrasalTag[0] == 'O') {
          Output(outSet, "Containing-" + chunk, start-1);
	  chunk = "";
          cs = OUTSIDE;
        }
        break;
      case I_START:
        if (phrasalTag[0] == 'B' && phrasalTag[1] == '-') {
          Output(outSet, "Overlap-" + chunk, start-1);
          chunk = phrasalTag.substr(2);
          cs = INSIDE;
        }
        else if (phrasalTag[0] == 'O') {
          Output(outSet, "Overlap-" + chunk, start-1);
          chunk = "";
          cs = OUTSIDE;
        }
        break;
      case INSIDE:
        if (phrasalTag[0] == 'B' && phrasalTag[1] == '-') {
          Output(outSet, "Containing-" + chunk, start-1);
          chunk = phrasalTag.substr(2);
          cs = INSIDE;
        }
        else if (phrasalTag[0] == 'O') {
          Output(outSet, "Containing-" + chunk, start-1);
          chunk = "";
          cs = OUTSIDE;
        }
        break;
      case OUTSIDE:
        if (phrasalTag[0] == 'B' && phrasalTag[1] == '-') {
          chunk = phrasalTag.substr(2);
	  cs = INSIDE;
        }
        break;
      default:
	break;
    }
  }

  // check the word after
  if (end + 1 < sentence.size()) {
    int next = end + 1;
    phrasalTag = *(sentence[next].phrasal.begin());

    switch(cs) {
      case B_START:
        if (phrasalTag[0] == 'I' && phrasalTag[1] == '-')
          Output(outSet, "Contained-" + chunk, start-1);
        else
          Output(outSet, "Exact-" + chunk, start-1);
        break;
      case I_START:
        Output(outSet, "Contained-" + chunk, start-1);
        break;
      case INSIDE:
	if ((phrasalTag[0] == 'I' && phrasalTag[1] == '-') &&
            (chunk == phrasalTag.substr(2)))
          Output(outSet, "Overlap-" + chunk, start-1);
        else
          Output(outSet, "Containing-" + chunk, start-1);
        break;
      case OUTSIDE:
      default:
        break;
    }
  }
  else { // treat it as O
    switch(cs) {
      case B_START:
        Output(outSet, "Exact-" + chunk, start-1);
        break;
      case I_START:
        Output(outSet, "Contained-" + chunk, start-1);
        break;
      case INSIDE:
        Output(outSet, "Containing-" + chunk, start-1);
        break;
      case OUTSIDE:
      default:
        break;
    }
  }
}

//--------------------------------------------------------------

//---Scott's additional Sensors for ER case ----------------

void SensorRGFNo::Extract( Sentence &sentence, RawFeatureSet &outSet,
			  int rec, int targLoc )
{
  Output(outSet, "X", targLoc);
}


void SensorEntity::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   const StringVector inSet = sentence[rec].namedEntities;
   for(StringVector::const_iterator pFeat = inSet.begin();
       pFeat != inSet.end(); pFeat++) {
     Output(outSet, *pFeat, targLoc);
   }
}

void SensorArgument::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
	const RawFeatureSet& inSet = sentence[rec].relArgs;
   	for(RawFeatureSet::const_iterator pFeat = inSet.begin();
       	pFeat != inSet.end(); pFeat++)
  		Output(outSet, *pFeat, targLoc);
}

// fires if target is a verb ( if the information is available)
void SensorVerb::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   const StringVector& inSet = sentence[rec].tags;
   for(StringVector::const_iterator pFeat = inSet.begin();
       pFeat != inSet.end(); pFeat++) {
      try {
	if (pFeat->at(0) == 'V')
            Output(outSet, *pFeat, targLoc);
      }
      catch(out_of_range) { }
   }
}

void SensorNearestVerbWordAfter::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   int i;

   // after
   for(i = rec+1; i < sentence.size(); i++) {

     const StringVector& inSet = sentence[i].tags;
     for(StringVector::const_iterator pFeat = inSet.begin();
         pFeat != inSet.end(); pFeat++) {
        try {
          if (pFeat->at(0) == 'V') {
              for (StringVector::iterator ppFeat = sentence[i].words.begin();
                   ppFeat != sentence[i].words.end(); ppFeat++)
                Output(outSet, *ppFeat, targLoc);

              return;
          }
        }
        catch(out_of_range) { }
     }
   }
}

void SensorNearestVerbWordBefore::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   int i;

   // before
   for(i = rec-1; i >= 0; i--) {

     const StringVector& inSet = sentence[i].tags;
     for(StringVector::const_iterator pFeat = inSet.begin();
         pFeat != inSet.end(); pFeat++) {
        try {
          if (pFeat->at(0) == 'V') {
              for (StringVector::iterator ppFeat = sentence[i].words.begin();
                   ppFeat != sentence[i].words.end(); ppFeat++)
                Output(outSet, *ppFeat, targLoc);

              return;
          }
        }
        catch(out_of_range) { }
     }
   }
}

void SensorBigram::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   const StringVector& wordArr = sentence[rec].words;

   for (int i = 0; i < wordArr.size() - 1; i++)
       Output(outSet, wordArr[i] + "-=-" + wordArr[i+1], targLoc);
}

void SensorWordNum::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   const StringVector& wordArr = sentence[rec].words;
   char charBuf[256];
   snprintf(charBuf, 255, "%u", wordArr.size());

   Output(outSet, charBuf, targLoc);
}

// return the word without the ending '.'; for example, "Mr." -> "Mr"
void SensorWordNoDot::Extract( Sentence &sentence, RawFeatureSet &outSet,
			  int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pFeat = inSet.begin();
      pFeat != inSet.end(); pFeat++)
    {
      // cout << "String = " << *pFeat << endl;

      string feat(*pFeat);
      unsigned len = feat.length();

      int i;
      for (i = len-1; i >= 0; i--) {
	if (feat[i] != '.')
	  break;
      }
      if (i >= 0)
	Output(outSet, feat.substr(0,i+1), targLoc);
    }
}

void SensorWordPos::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   char charBuf[256];
   snprintf(charBuf, 255, "%u", rec);

   Output(outSet, charBuf, targLoc);
}

void SensorSameArg::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int start, int end )
{
  const StringVector& wordArr1 = sentence[start].words;
  const StringVector& wordArr2 = sentence[end].words;
  
  if (wordArr1.size() != wordArr2.size())
    return;
  for (unsigned i = 0; i < wordArr1.size(); i++) {
    if (wordArr1[i] != wordArr2[i])
      return;
  }

  Output(outSet, "X", end);
}

//---------------------------------------------------------------------------------

/*  These are pretty strong sensors.
    They use a list of knowns countries, states or cities. */

bool SensorList::placeListLoaded = false;
bool SensorList::countryListLoaded = false;
bool SensorList::stateListLoaded = false;
bool SensorList::cityListLoaded = false;
bool SensorList::titleListLoaded = false;
bool SensorList::nameListLoaded = false;
bool SensorList::orgListLoaded = false;

set<string> SensorList::place_list;
set<string> SensorList::country_list;
set<string> SensorList::state_list;
set<string> SensorList::city_list;
set<string> SensorList::title_list;
set<string> SensorList::name_list;
set<string> SensorList::org_list;

// These are pretty strong sensors. They use a list of knowns countries, states or cities
SensorList::SensorList(LIST_TYPE listType, LIST_SEN_TYPE theSenType) : Sensor() {
  senType = theSenType;
  loadList(listType);

  // If it's for PHRASE extension (-P), then sent the type to ST_PHRASE
  if (globalParams.phraseCase)
    sensorType = ST_PHRASE;
}

string& SensorList::outputForm(string &outStr, string &inStr) {
  outStr = "";
  for(unsigned i = 0; i < inStr.size(); i++) {
    if (inStr[i] == ' ')
      outStr += "-=-";
    else
      outStr += inStr[i]; 
  }
  return outStr;
}

void SensorList::Extract( Sentence &sentence, RawFeatureSet &outSet,
				  int rec, int targLoc )
{
  StringVector wordArr;
  if (sensorType == ST_PHRASE) {
    int start = rec, end = targLoc;
    for (int i = start; i <= end; i++)
      wordArr.push_back(sentence[i].words[0]);
  }
  else {
    wordArr = sentence[rec].words;
  }

  switch (senType) {
  case IS: 
    {
      string strElement(wordArr[0]), strOutElement(wordArr[0]);
      for (int i = 1; i < wordArr.size(); i++) {
	strElement.append(" ");
	strElement.append(wordArr[i]);
	strOutElement.append("-=-");
	strOutElement.append(wordArr[i]);
      }
      
      if (pList->find(strElement) != pList->end())  // string found
	Output(outSet, strOutElement, targLoc);
    }
    break;
  case HAS:
    {
      vector<string> phrase;
      int i, len;
      string outStr;
      for (i = 0; i < wordArr.size(); i++) {
	string item = wordArr[i];
	phrase.push_back(item);
	for (len = 1; len < wordArr.size() - i; len++) {
	  item += " " + wordArr[i+len];
	  phrase.push_back(item);
	}
      }

      for (i = 0; i < phrase.size(); i++)
	if (pList->find(phrase[i]) != pList->end())
	  Output(outSet, outputForm(outStr, phrase[i]), targLoc);
    }
    break;
  }
}

void SensorList::loadList(LIST_TYPE listType) {
  string fn;
  bool *pLoaded;

  switch(listType) {
  case PLACE:
    pList = &place_list;
    fn = PLACE_LIST_FN;
    pLoaded = &placeListLoaded;
    break;
  case COUNTRY:
    pList = &country_list;
    fn = COUNTRY_LIST_FN;
    pLoaded = &countryListLoaded;
    break;
  case STATE:
    pList = &state_list;
    fn = STATE_LIST_FN;
    pLoaded = &stateListLoaded;
    break;
  case CITY:
    pList = &city_list;
    fn = CITY_LIST_FN;
    pLoaded = &cityListLoaded;
    break;
  case TITLE:
    pList = &title_list;
    fn = TITLE_LIST_FN;
    pLoaded = &titleListLoaded;
    break;
  case NAME:
    pList = &name_list;
    fn = NAME_LIST_FN;
    pLoaded = &nameListLoaded;
    break;
  case ORG:
    pList = &org_list;
    fn = ORG_LIST_FN;
    pLoaded = &orgListLoaded;
    break;
  }

  if (*pLoaded)
    return;

  ifstream inFile(fn.c_str());

  //cerr << "Load List " << fn << " Now!" << endl;

  if (!inFile) { // error occurred during open
    cerr << "Error occurred when opening " << fn << " file!" << endl;
    return;
  }

  char buffer[1024];

  while(!inFile.eof()) {
    inFile.getline(buffer, 1024);
    pList->insert(buffer);
  }

  inFile.close();

  *pLoaded = true;
}

//---------------------------------------------------------------------------------

static bool killSemListSet = false;
static set<string> killSem_list;
static bool birthSemListSet = false;
static set<string> birthSem_list;
static bool locSemListSet = false;
static set<string> locSem_list;

SensorSemantic::SensorSemantic() : Sensor()
{
  if (!killSemListSet) {
    killSem_list.insert("kill");
    killSem_list.insert("shoot");
    killSem_list.insert("assassinate");
    killSem_list.insert("murder");
    killSem_list.insert("kills");
    killSem_list.insert("shoots");
    killSem_list.insert("assassinates");
    killSem_list.insert("murders");
    killSem_list.insert("killing");
    killSem_list.insert("shooting");
    killSem_list.insert("assassinating");
    killSem_list.insert("murdering");
    killSem_list.insert("killed");
    killSem_list.insert("shot");
    killSem_list.insert("assassinated");
    killSem_list.insert("murdered");
    killSem_list.insert("assassination");
    killSem_list.insert("Kill");
    killSem_list.insert("Shoot");
    killSem_list.insert("Assassinate");
    killSem_list.insert("Murder");
    killSem_list.insert("Kills");
    killSem_list.insert("Shoots");
    killSem_list.insert("Assassinates");
    killSem_list.insert("Murders");
    killSem_list.insert("Killing");
    killSem_list.insert("Shooting");
    killSem_list.insert("Assassinating");
    killSem_list.insert("Murdering");
    killSem_list.insert("Killed");
    killSem_list.insert("Shot");
    killSem_list.insert("Assassinated");
    killSem_list.insert("Murdered");
    killSem_list.insert("Assassination");

    killSemListSet = true;
  }

  if (!birthSemListSet) {
    birthSem_list.insert("birth");
    birthSem_list.insert("born");
    birthSem_list.insert("native");
    birthSem_list.insert("hometown");
    birthSem_list.insert("birthplace");
    birthSem_list.insert("Birth");
    birthSem_list.insert("Born");
    birthSem_list.insert("Native");
    birthSem_list.insert("Hometown");
    birthSem_list.insert("Birthplace");
    
    birthSemListSet = true;
  }

  if (!locSemListSet) {
    locSem_list.insert("province");
    locSem_list.insert("Province");
    locSem_list.insert("provinces");
    locSem_list.insert("Provinces");
    locSem_list.insert("province.");
    locSem_list.insert("Province.");
    locSem_list.insert("provinces.");
    locSem_list.insert("Provinces.");
    locSem_list.insert("harbor");
    locSem_list.insert("Harbor");
    locSem_list.insert("harbors");
    locSem_list.insert("Harbors");
    locSem_list.insert("harbor.");
    locSem_list.insert("Harbor.");
    locSem_list.insert("harbors.");
    locSem_list.insert("Harbors.");
    locSem_list.insert("city");
    locSem_list.insert("City");
    locSem_list.insert("cities");
    locSem_list.insert("Cities");
    locSem_list.insert("city.");
    locSem_list.insert("City.");
    locSem_list.insert("cities.");
    locSem_list.insert("Cities.");

    locSem_list.insert("town");
    locSem_list.insert("Town");
    locSem_list.insert("towns");
    locSem_list.insert("Towns");
    locSem_list.insert("town.");
    locSem_list.insert("Town.");
    locSem_list.insert("towns.");
    locSem_list.insert("Towns.");

    locSem_list.insert("fort");
    locSem_list.insert("Fort");
    locSem_list.insert("forts");
    locSem_list.insert("Forts");
    locSem_list.insert("fort.");
    locSem_list.insert("Fort.");
    locSem_list.insert("forts.");
    locSem_list.insert("Forts.");

    locSem_list.insert("county");
    locSem_list.insert("County");
    locSem_list.insert("counties");
    locSem_list.insert("Counties");
    locSem_list.insert("county.");
    locSem_list.insert("County.");
    locSem_list.insert("counties.");
    locSem_list.insert("Counties.");
    locSem_list.insert("peninsula");
    locSem_list.insert("Peninsula");
    locSem_list.insert("peninsulas");
    locSem_list.insert("Peninsulas");
    locSem_list.insert("peninsula.");
    locSem_list.insert("Peninsula.");
    locSem_list.insert("peninsulas.");
    locSem_list.insert("Peninsulas.");
    locSem_list.insert("reservation");
    locSem_list.insert("Reservation");
    locSem_list.insert("reservation");
    locSem_list.insert("Reservation");
    locSem_list.insert("reservation.");
    locSem_list.insert("Reservation.");
    locSem_list.insert("reservations.");
    locSem_list.insert("Reservations.");
  }
}

void SensorSemantic::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   const StringVector& wordArr = sentence[rec].words;

   for (int i = 0; i < wordArr.size(); i++) {
     if (killSem_list.find(wordArr[i]) != killSem_list.end()) // string found
		Output(outSet, "kill", targLoc);
     if (birthSem_list.find(wordArr[i]) != birthSem_list.end()) // string found
		Output(outSet, "birth", targLoc);
     if (locSem_list.find(wordArr[i]) != locSem_list.end()) // string found
                Output(outSet, "loc", targLoc);
   }
}

SensorNoSemantic::SensorNoSemantic() : Sensor()
{
  sensorType = ST_PHRASE;

  if (!killSemListSet) {
    killSem_list.insert("kill");
    killSem_list.insert("shoot");
    killSem_list.insert("assassinate");
    killSem_list.insert("murder");
    killSem_list.insert("kills");
    killSem_list.insert("shoots");
    killSem_list.insert("assassinates");
    killSem_list.insert("murders");
    killSem_list.insert("killing");
    killSem_list.insert("shooting");
    killSem_list.insert("assassinating");
    killSem_list.insert("murdering");
    killSem_list.insert("killed");
    killSem_list.insert("shot");
    killSem_list.insert("assassinated");
    killSem_list.insert("murdered");
    killSem_list.insert("assassination");
    killSem_list.insert("Kill");
    killSem_list.insert("Shoot");
    killSem_list.insert("Assassinate");
    killSem_list.insert("Murder");
    killSem_list.insert("Kills");
    killSem_list.insert("Shoots");
    killSem_list.insert("Assassinates");
    killSem_list.insert("Murders");
    killSem_list.insert("Killing");
    killSem_list.insert("Shooting");
    killSem_list.insert("Assassinating");
    killSem_list.insert("Murdering");
    killSem_list.insert("Killed");
    killSem_list.insert("Shot");
    killSem_list.insert("Assassinated");
    killSem_list.insert("Murdered");
    killSem_list.insert("Assassination");
    
    killSemListSet = true;
  }
  
  if (!birthSemListSet) {
    birthSem_list.insert("birth");
    birthSem_list.insert("born");
    birthSem_list.insert("native");
    birthSem_list.insert("hometown");
    birthSem_list.insert("birthplace");
    birthSem_list.insert("Birth");
    birthSem_list.insert("Born");
    birthSem_list.insert("Native");
    birthSem_list.insert("Hometown");
    birthSem_list.insert("Birthplace");
    
    birthSemListSet = true;
  }
}

void SensorEntityNum::Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end )
{
  unsigned num = 0;

  for (int i = start; i <= end; i++) {
    const StringVector inSet = sentence[i].namedEntities;
    for(StringVector::const_iterator pFeat = inSet.begin();
        pFeat != inSet.end(); pFeat++) {
      if (*pFeat != "O")
	num++;
    }
  }

  char buf[1024];
  snprintf(buf, 1023, "%u", num);

  // Assume targLoc = start - 1.  However, phrase type sensors
  //   should not be used along with location information.
  Output(outSet, string(buf), start-1);
}


void SensorScaleEntityNum::Extract( Sentence &sentence,
				     RawFeatureSet &outSet,
				     int start,
				     int end )
{
  unsigned num = 0;

  for (int i = start; i <= end; i++) {
    const StringVector inSet = sentence[i].namedEntities;
    for(StringVector::const_iterator pFeat = inSet.begin();
        pFeat != inSet.end(); pFeat++) {
      if (*pFeat != "O")
        num++;
    }
  }

  char buf[1024];

  // Assume targLoc = start - 1.  However, phrase type sensors
  //   should not be used along with location information.

  for (int i = 0; i <= num; i++) {
    snprintf(buf, 1023, "%d", i);
    Output(outSet, string(buf), start-1);
  }
}


void SensorNoSemantic::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int start, int end )
{
   bool foundKillSem, foundBirthSem;
   foundKillSem = foundBirthSem = false;

   for (int i = start; i <= end; i++) {
  	 const StringVector &inSet = sentence[i].words;
   	 for(StringVector::const_iterator pFeat = inSet.begin();
       	pFeat != inSet.end(); pFeat++) {
       if (birthSem_list.find(*pFeat) != birthSem_list.end()) { // string found
		  foundBirthSem = true;
		  break;
	   }
	   if (foundBirthSem)
	   	break;
   	 }
   }

   for (int i = start; i <= end; i++) {
  	 const StringVector &inSet = sentence[i].words;
   	 for(StringVector::const_iterator pFeat = inSet.begin();
       	pFeat != inSet.end(); pFeat++) {
       if (killSem_list.find(*pFeat) != killSem_list.end()) { // string found
		  foundKillSem = true;
		  break;
	   }
	   if (foundKillSem)
	   	break;
   	 }
   }

   if (!foundBirthSem)
      Output(outSet, "birth", start-1);
   if (!foundKillSem)
      Output(outSet, "kill", start-1);
}


void SensorScaleElementNum::Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end )
{
  int length = end - start;
  char buf[1024];

  // Assume targLoc = start - 1.  However, phrase type sensors
  //   should not be used along with location information.

  for (int i = 0; i <= length; i++) {
  	snprintf(buf, 1023, "%d", i);
  	Output(outSet, string(buf), start-1);
  }
}

void SensorElementNum::Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end )
{
  int length = end - start;
  char buf[1024];

  // Assume targLoc = start - 1.  However, phrase type sensors
  //   should not be used along with location information.

  snprintf(buf, 1023, "%d", length);
  Output(outSet, string(buf), start-1);
}

//---------------------------------------------------------------------------------

// phrase sensor: active if all words in the target phrase are capitalized (initial)
void SensorPhraseAllCapital::Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end )
{
  //cout << start << ", " << end << endl;

  for (int rec = start; rec <= end; rec++) {
    const StringVector& inSet = sentence[rec].words;
    for(StringVector::const_iterator pFeat = inSet.begin();
       pFeat != inSet.end(); pFeat++) {

		if (pFeat->length() != 0 && !isupper(pFeat->at(0)))
			return;

		//cout << "Not Returned: " << *pFeat << endl;
	}
  }

  Output(outSet, string("x"), start-1);
}

// phrase sensor: active if all words in the target phrase are either capitalized (initial), symbols, or numbers 
void SensorPhraseNoSmall::Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end )
{
  //cout << start << ", " << end << endl;

  for (int rec = start; rec <= end; rec++) {
    const StringVector& inSet = sentence[rec].words;
    for(StringVector::const_iterator pFeat = inSet.begin();
	pFeat != inSet.end(); pFeat++) {
      if (pFeat->length() != 0 && islower(pFeat->at(0)))
	return;

      //cout << "Not Returned: " << *pFeat << endl;
    }
  }

  Output(outSet, string("x"), start-1);
}

// phrase sensor: active if all the elements in the target phrase are words (a-z,A-Z)
void SensorPhraseAllWords::Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end )
{
    for (int rec = start; rec <= end; rec++) {
		const StringVector& inSet = sentence[rec].words;
		for(StringVector::const_iterator pFeat = inSet.begin();
		   pFeat != inSet.end(); pFeat++)
		   for (int i = 0; i < pFeat->length(); i++) {
			char ch = pFeat->at(i);
			if ((ch < 'A' || ch > 'Z') &&
				(ch < 'a' || ch > 'z'))
				return;
		   }
  }

  Output(outSet, string("x"), start-1);
}

// phrase sensor: active if all the elements in the target phrase are not numbers
void SensorPhraseAllNotNum::Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end )
{
    for (int rec = start; rec <= end; rec++) {
		const StringVector& inSet = sentence[rec].words;
		for(StringVector::const_iterator pFeat = inSet.begin();
		   pFeat != inSet.end(); pFeat++)
		   for (int i = 0; i < pFeat->length(); i++) {
			char ch = pFeat->at(i);
			if (ch >= '0' && ch <= '9')
				return;
		   }
    }

  Output(outSet, string("x"), start-1);
}

// outputs the target but with all letter capitalized
void SensorToUpper::Extract( Sentence &sentence, RawFeatureSet &outSet,
                                  int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
   for(StringVector::iterator pFeat = inSet.begin();
         pFeat != inSet.end(); pFeat++)
   {
      string feat(*pFeat);

	  for (string::iterator pCh = feat.begin();
	  		pCh != feat.end(); pCh++)
		*pCh = toupper(*pCh);

      Output(outSet, feat, targLoc);
   }
}

void SensorFirstWord::Extract( Sentence &sentence, RawFeatureSet &outSet,
                                  int rec, int targLoc )
{
   StringVector inSet = sentence[0].words;
   for(StringVector::iterator pFeat = inSet.begin();
         pFeat != inSet.end(); pFeat++)
      Output(outSet, *pFeat, targLoc);
}

//--------Some more phrase sensors written by Jakob---------------------

// first word in target phrase
void SensorPhraseFirstWord::Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end )
{
  
  const StringVector& inSet = sentence[start].words;
  StringVector::const_iterator pFeat = inSet.begin(); 
  Output(outSet, *pFeat, start-1);
}

// last word in target phrase
void SensorPhraseLastWord::Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end )
{

  const StringVector& inSet = sentence[end].words;
  StringVector::const_iterator pFeat=inSet.end();
  pFeat--;
  Output(outSet, *pFeat, start-1);
  
}

// first tag in target phrase
void SensorPhraseFirstTag::Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end )
{

  const StringVector& inSet = sentence[start].tags;
  StringVector::const_iterator pFeat=inSet.begin();
  Output(outSet, *pFeat, start-1);
  
}

// last tag in target phrase
void SensorPhraseLastTag::Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end )
{

  const StringVector& inSet = sentence[end].tags;
  StringVector::const_iterator pFeat=inSet.end();
  pFeat--;
  Output(outSet, *pFeat, start-1);
  
}

// fires if phrase looks like a percentage expression
void SensorPhrasePercent::Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end )
{ 

  //test all conditions, if one applies this phrase is a percent entity
  int ispercent=false;
  const int phraselength = end - start +1;

  if(phraselength >= 2)
  {
    string phrasewords[phraselength];
    string phrasetags[phraselength];
    string wordsbefore[3];
    string tagsbefore[3];
    string wordsafter[3];
    string tagsafter[3];
    StringVector::const_iterator pTag; 
    StringVector::const_iterator pWord;

    //get the phrase into easier to handle string arrays (only first words/tags)
    for(int rec=start;rec<=end;rec++)
    {
      pTag = sentence[rec].tags.begin();
      phrasetags[rec - start] = *pTag;
      pWord= sentence[rec].words.begin();
      phrasewords[rec - start] = *pWord;
    }

    //Condition 1: "t(CD) w(percent)" or "t(CD) w(%)" plus certain restrictions
    if(phraselength==2 && phrasetags[0]=="CD" && 
      (phrasewords[1]=="percent" || phrasewords[1]=="%"))
    { // restrictions
      // get words and tags before and after target
      for(int n=(start-3);n < start; n++)
      {
        if(n>=0)
        {
	  pTag=sentence[n].tags.begin();
	  pWord=sentence[n].words.begin();
	  tagsbefore[n-(start-3)]= *pTag;
	  wordsbefore[n-(start-3)]= *pWord;
        } 
      }

      for(int n=end+1;n <= (end+3); n++)
      {
        if(n<sentence.size())
        {
          pTag=sentence[n].tags.begin();
          pWord=sentence[n].words.begin();
          tagsafter[n-(end+1)]= *pTag;
          wordsafter[n-(end+1)]= *pWord;
        } 
      }

      //test restrictions
      if(!(
         (tagsbefore[1]=="CD" && wordsbefore[2]=="to") ||
         (tagsbefore[0]=="CD" && wordsbefore[1]=="percent" && wordsbefore[2]=="to") ||
         (tagsbefore[0]=="CD" && wordsbefore[1]=="%" && wordsbefore[2]=="to") ||
         (wordsbefore[2]=="between") ||
         (tagsbefore[0]=="CD" && wordsbefore[1]=="percent" && wordsbefore[2]=="and")
         ) &&
        !(
	  (wordsafter[0]=="to" && tagsafter[1]=="CD" && (wordsafter[2]=="percent" ||wordsafter[2]=="%")) ||
          (wordsafter[0]=="and" && tagsafter[1]=="CD" && (wordsafter[2]=="percent" ||wordsafter[2]=="%"))
         ))
      { // then we're ok
        ispercent=true;
      }
    }
  
    //some more Conditions
    if(!ispercent &&  (
       (phraselength==4 &&
	phrasetags[0]=="CD" && 
        phrasewords[1]=="to" && 
        phrasetags[2]=="CD" && 
        (phrasewords[3]=="percent" || phrasewords[3]=="%")) ||
       (phraselength==5 &&
	phrasetags[0]=="CD" && 
        (phrasewords[1]=="percent" || phrasewords[1]=="%") &&
        phrasewords[2]=="to" && 
        phrasetags[3]=="CD" && 
        (phrasewords[4]=="percent" || phrasewords[4]=="%")) ||
       (phraselength==6 &&
	phrasewords[0]=="between" &&
        phrasetags[1]=="CD" && 
        (phrasewords[2]=="percent" || phrasewords[2]=="%") &&
        phrasewords[3]=="and" && 
        phrasetags[4]=="CD" && 
        (phrasewords[5]=="percent" || phrasewords[5]=="%"))))
      
      {
	ispercent=true;
      }

    if(ispercent)
      {
	// cout<<"PERCENT:";
        // for (int i=0;i<phraselength;i++)
	//  {
	//    cout<<" "<<phrasewords[i];
	//  }
	// cout<<endl;
	Output(outSet, string("X"), start-1);
      }
  }
}


// position of the phrase in its sentence
void SensorPhrasePosition::Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end )
{
  char buf[1024];
  snprintf(buf, 1023, "%u", start);
  Output(outSet, string(buf), start-1);  
}

// length of the sentence of the current target
void SensorSentenceLength::Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end )
{
  char buf[1024];
  snprintf(buf, 1023, "%u", sentence.size());
  Output(outSet, string(buf), start-1);  
}


set<string> TitleList;

// high precision sensor for PERSON entity
SensorIsPerson::SensorIsPerson() : Sensor()
{
  sensorType = ST_PHRASE;
  ifstream inFile("known_title.lst");

  //cerr << "Load List " << fn << " Now!" << endl;

  if (!inFile) { // error occurred during open
    cerr << "Error occurred when opening file!" << endl;
    return;
  }

  char buffer[1024];

  while(!inFile.eof()) {
    inFile.getline(buffer, 1024);
    TitleList.insert(buffer);
  }

  inFile.close();
}


int CheckTitle(string word)
{
 if(word != "")
 {
  if (TitleList.find(word) != TitleList.end())
  {
     return true;
  }
  else
  {
    for(int i=0; i<word.length();i++)
      word[i] = tolower(word[i]);
    if (TitleList.find(word) != TitleList.end())
    {
      //cout<<"TITLEHIT:"<<word<<endl;
      return true;
    }
    else return false;
  }
 }
 else return false;
}

// high precision sensor for person entity
void SensorIsPerson::Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end )
{
  //test all conditions, if one applies this phrase is a percent entity
  int isPerson=false;
  int isCap=true;
  const int phraselength = end - start +1;
  
  //require that all words are capitalized
  for(int i=start;i<=end;i++)
    {
      string word(*(sentence[i].words.begin()));
      if(!((word[0] >= 'A') && (word[0] <= 'Z')))
	{
	  isCap=false;
	}
    }
  //also allow only 3 words 
  if(isCap==true &&phraselength<=3)
   {
      string phrasewords[phraselength];
      string phrasetags[phraselength];
      string wordsbefore[3];
      string tagsbefore[3];
      string wordsafter[3];
      string tagsafter[3];
      StringVector::const_iterator pTag; 
      StringVector::const_iterator pWord;
      
      //get the phrase into easier to handle string arrays (only first words/tags)
      for(int rec=start;rec<=end;rec++)
	{
	  pTag = sentence[rec].tags.begin();
	  phrasetags[rec - start] = *pTag;
	  pWord= sentence[rec].words.begin();
	  phrasewords[rec - start] = *pWord;
	}
      
      // get words and tags before and after target
      for(int n=(start-3);n < start; n++)
	{
	  if(n>=0)
	    {
	      pTag=sentence[n].tags.begin();
	      pWord=sentence[n].words.begin();
	      tagsbefore[n-(start-3)]= *pTag;
	      wordsbefore[n-(start-3)]= *pWord;
              if(CheckTitle(wordsbefore[n-(start-3)])) 
                wordsbefore[n-(start-3)][0] = tolower(wordsbefore[n-(start-3)][0]);
	    } 
	}
      
      for(int n=end+1;n <= (end+3); n++)
	{
	  if(n<sentence.size())
	    {
	      pTag=sentence[n].tags.begin();
	      pWord=sentence[n].words.begin();
	      tagsafter[n-(end+1)]= *pTag;
	      wordsafter[n-(end+1)]= *pWord;
              if(CheckTitle( wordsafter[n-(end+1)]))
                 wordsafter[n-(end+1)][0] = tolower( wordsafter[n-(end+1)][0]);

	    } 
	}


      if( ((CheckTitle(wordsbefore[1])) &&
          (wordsbefore[1]!="") &&
          (wordsbefore[2]==",") &&
          (wordsafter[0]==","))
          ||
          ((CheckTitle(wordsbefore[2])) &&
           (wordsbefore[2]!="") &&
	   (!((wordsafter[0][0]>='A') && (wordsafter[0][0]<='Z')))) //make sure this is not a subphrase of a person entity
          ||
          ((wordsafter[0]==",") &&
          ((wordsafter[1]=="a") || (wordsafter[1]=="an") || (wordsafter[1]=="the") || (wordsafter[1]=="one")) &&
	   (CheckTitle(wordsafter[2])) &&
           (wordsafter[2]!=""))
	  ||
	  ((wordsbefore[2]=="said") &&
	   (wordsafter[0]==","))
	  ||
	  ((!((wordsbefore[2][0]>='A') && (wordsbefore[2][0]<='Z'))) && //make sure this is not a subphrase of a person entity
	   (wordsafter[0]=="said"))
	  ||
	  ((wordsbefore[2]=="By") &&
	   (!((wordsafter[0][0]>='A') && (wordsafter[0][0]<='Z')))) //make sure this is not a subphrase of a person entity

	  ||
	  ((!((wordsbefore[2][0]>='A') && (wordsbefore[2][0]<='Z'))) && //make sure this is not a subphrase of a person entity
	   (wordsafter[0]==",") &&
	   (tagsafter[1]=="CD") &&
	   (wordsafter[2]==","))
	)
        {
          int phraseOK = true;
          for(int i=0;i<phraselength;i++)
          {
            if(CheckTitle(phrasewords[i]))
              phraseOK=false;

            if(phrasewords[i]=="He" || 
               phrasewords[i]=="She" || 
               phrasewords[i]=="It" ||
               phrasewords[i]=="We" || 
               phrasewords[i]=="They" || 
               phrasewords[i]=="I" || 
               phrasewords[i]=="The" ||
               phrasewords[i]=="Administration" ||
               phrasewords[i]=="Authority" ||
               phrasewords[i]=="Committee" ||
               phrasewords[i]=="Inc." ||
               phrasewords[i]=="Department")
             phraseOK=false;


	  }

          if(phraseOK) isPerson=true;
	}
  

    if(isPerson)
      {
	// cout<<"PERSON:";
        // for (int i=0;i<phraselength;i++)
	//  {
	//    cout<<" "<<phrasewords[i];
	//  }
	// cout<<endl;
	//cout<<"before:"<<wordsbefore[0]<<" "<<wordsbefore[1]<<" "<<wordsbefore[2]<<endl;
        //cout<<"after:"<<wordsafter[0]<<" "<<wordsafter[1]<<" "<<wordsafter[2]<<endl;
	Output(outSet, string("X"), start-1);
      }
  }

}

// fires if target is first word in sentence
void SensorIsFirstWord::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
  if(rec==0)
  {
    Output(outSet, string("X"), targLoc);
  }
}

// fires if target word includes digits
void SensorHasDigit::Extract( Sentence &sentence, RawFeatureSet &outSet,
                                int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      bool found=false;
      char tmp;
      for(int i=0; i<pWord->length(); i++)
	{
	  tmp = pWord->at(i);
	  if( (tmp>=48) && (tmp<=57))
            {
	      found=true;
	      break;
	    }
      }
      if(found) Output(outSet, string("X"), targLoc);
   }
}

// fires if target word consists of only digits
void SensorAllDigit::Extract( Sentence &sentence, RawFeatureSet &outSet,
                                int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      bool found=true;
      char tmp;
      for(int i=0; i<pWord->length(); i++)
	{
	  tmp = pWord->at(i);
	  if(! ( (tmp>=48) && (tmp<=57) ) )
            {
	      found=false;
	      break;
	    }
      }
      if(found) Output(outSet, string("X"), targLoc);
   }
}

// fires if target word is alphanumeric
void SensorAlphaNumeric::Extract( Sentence &sentence, RawFeatureSet &outSet,
                                int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      bool found=true;
      char tmp;
      for(int i=0; i<pWord->length(); i++)
	{
	  tmp = pWord->at(i);
	  if(! ( ((tmp>=48) && (tmp<=57)) || // numerals
		 ((tmp>=65) && (tmp<=90)) || // uppercase alphabet
		 ((tmp>=97) && (tmp<=122))   // lowercase alphabet
		 ) )
            {
	      found=false;
	      break;
	    }
      }
      if(found) Output(outSet, string("X"), targLoc);
   }
}

// Sensor for roman numerals. Note: this one does not check for a correct order of them
void SensorRomanNum::Extract( Sentence &sentence, RawFeatureSet &outSet,
                                int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      bool found=true;
      char tmp;
      for(int i=0; i<pWord->length(); i++)
	{
	  tmp = pWord->at(i);
	  if(! ( (tmp=='I') || (tmp=='V') || (tmp=='X') || (tmp=='L') || (tmp=='C') || (tmp=='D') || (tmp=='M')))
            {
	      found=false;
	      break;
	    }
      }
      if(found) Output(outSet, string("X"), targLoc);
   }
}

// extracts 2-letter prefixes
void SensorPrefix2::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      if(pWord->length()>=2)
	{
	  string prefix("");
	  prefix += pWord->at(0);
	  prefix += pWord->at(1);
	  
	  Output(outSet, prefix, targLoc);
	}
    } 
}

// extracts 3-letter prefixes
void SensorPrefix3::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      if(pWord->length()>=3)
	{
	  string prefix("");
	  prefix += pWord->at(0);
	  prefix += pWord->at(1);
	  prefix += pWord->at(2);
	  
	  Output(outSet, prefix, targLoc);
	}
    } 
}

// extracts 4-letter prefixes
void SensorPrefix4::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      if(pWord->length()>=4)
	{
	  string prefix("");
	  prefix += pWord->at(0);
	  prefix += pWord->at(1);
	  prefix += pWord->at(2);
	  prefix += pWord->at(3);	  
	  Output(outSet, prefix, targLoc);
	}
    } 
}

// extracts 1-letter suffixes
void SensorSuffix1::Extract( Sentence &sentence, RawFeatureSet &outSet,
                             int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words; 
  for(StringVector::iterator pWord = inSet.begin(); 
      pWord != inSet.end(); pWord++)
    {
      int size = pWord->length();
      if(size>=1)
        {
          string suffix("");
          suffix += pWord->at(size-1);
               
          Output(outSet, suffix, targLoc);
        }
    }
}


// extracts 2-letter suffixes
void SensorSuffix2::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      int size = pWord->length();
      if(size>=2)
	{
	  string suffix("");
	  suffix += pWord->at(size-2);
	  suffix += pWord->at(size-1);
	  
	  Output(outSet, suffix, targLoc);
	}
    } 
}

// extracts 3-letter suffixes
void SensorSuffix3::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      int size = pWord->length();
      if(size>=3)
	{
	  string suffix("");
	  suffix += pWord->at(size-3);
	  suffix += pWord->at(size-2);
	  suffix += pWord->at(size-1);
	  
	  Output(outSet, suffix, targLoc);
	}
    } 
}

// extracts 4-letter suffixes
void SensorSuffix4::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      int size = pWord->length();
      if(size>=4)
	{
	  string suffix("");
	  suffix += pWord->at(size-4);
	  suffix += pWord->at(size-3);
	  suffix += pWord->at(size-2);
	  suffix += pWord->at(size-1);
	  
	  Output(outSet, suffix, targLoc);
	}
    } 
}

// Length of the target word
void SensorLength::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      int size = pWord->length();
      char buf[1024];
      snprintf(buf, 1023, "%u", size);
      
      Output(outSet, string(buf), targLoc);
    } 
}


// checks if target includes punctuation marks
void SensorHasPM::Extract( Sentence &sentence, RawFeatureSet &outSet,
                                int rec, int targLoc )
{
   StringVector inSet = sentence[rec].words;
   for(StringVector::iterator pWord = inSet.begin();
         pWord != inSet.end(); pWord++)
   {
      string feat;
      char *tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'.');
      if( tmp != NULL)
	Output(outSet, string("."), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'-');
      if( tmp != NULL)
	Output(outSet, string("-"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'\'');
      if( tmp != NULL)
	Output(outSet, string("\'"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'\"');
      if( tmp != NULL)
	Output(outSet, string("\""), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),',');
      if( tmp != NULL)
	Output(outSet, string(","), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'\(');
      if( tmp != NULL)
	Output(outSet, string("\("), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),')');
      if( tmp != NULL)
	Output(outSet, string(")"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'\[');
      if( tmp != NULL)
	Output(outSet, string("\["), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),']');
      if( tmp != NULL)
	Output(outSet, string("]"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),';');
      if( tmp != NULL)
	Output(outSet, string(";"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'!');
      if( tmp != NULL)
	Output(outSet, string("!"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'?');
      if( tmp != NULL)
	Output(outSet, string("?"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),':');
      if( tmp != NULL)
	Output(outSet, string(":"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'/');
      if( tmp != NULL)
	Output(outSet, string("/"), targLoc);
      tmp=NULL;

      // the following are not really punctuation marks but useful

      tmp = strrchr((*pWord).c_str(),'%');
      if( tmp != NULL)
	Output(outSet, string("%"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'$');
      if( tmp != NULL)
	Output(outSet, string("$"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'@');
      if( tmp != NULL)
	Output(outSet, string("@"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'#');
      if( tmp != NULL)
	Output(outSet, string("#"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'`');
      if( tmp != NULL)
	Output(outSet, string("`"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'\\');
      if( tmp != NULL)
	Output(outSet, string("\\"), targLoc);
      tmp=NULL;

      tmp = strrchr((*pWord).c_str(),'&');
      if( tmp != NULL)
	Output(outSet, string("&"), targLoc);
      tmp=NULL;
   }
}


// Hyphenated words & case. possible outputs: U-U, U-L, L-U, L-L
void SensorHyphenCase::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      bool found=true;
      int size = pWord->length();
      char first;
      char hyphen=' ';
      char second;
      if(islower(pWord->at(0))) first='L';
      else if(isupper(pWord->at(0))) first='U';
      else found=false;

      int i=0;
      while(hyphen!='-' && i<(size-1))
	{
	  hyphen=pWord->at(i);
	  i++;
	}
      if(hyphen!='-') found=false;
      if(islower(pWord->at(i))) second='L';
      else if(isupper(pWord->at(i))) second='U';
      else found=false;
      
      if(found)
	{
	  string pattern("");
	  pattern += first;
	  pattern += hyphen;
	  pattern += second;
	  Output(outSet, pattern, targLoc);
	}
    } 
}



//Character patterns:  ABCdefg123:345! becomes Aa0:0!
void SensorCharPattern::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      string pattern("");
      int size = pWord->length();
      int index=0;
      char c;
      while(index<size)
	{
	  c = pWord->at(index);

	  if((c>=48) && (c<=57)) // numerals
	    {
	      pattern += '0'; 
	      while((c>=48) && (c<=57) && (index<size)) 
		{
		  index++;
		  if(index<size) c=pWord->at(index);
		}
	    }

	  else if((c>=65) && (c<=90)) // uppercase alphabet
	    {
	      pattern += 'A'; 
	      while((c>=65) && (c<=90) && (index<size)) 
		{
		  index++;
		  if(index<size) c=pWord->at(index);
		}
	    }

	  else if((c>=97) && (c<=122)) // lowercase alphabet
	    {
	      pattern += 'a';
	      while((c>=97) && (c<=122) && (index<size)) 
		{
		  index++;
		  if(index<size) c=pWord->at(index);
		}
	    }
	  
	  else
	    {
	      pattern += c;
	      index++;
	    }

	}
	  Output(outSet, pattern, targLoc);
    } 
}

//fires when word is in quotes/parentheses
void SensorInQuotePar::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      if(rec>0 && rec<(sentence.size()-1))
        {   	  
	  StringVector w;
	  //first try to find open parentheses
	  int offset = -1;
	  if (rec>0) w = sentence[rec+offset].words;
	  StringVector::iterator p = w.begin();
	  while(*p!="\(" && (offset+rec)>=0)
	    {
	      w = sentence[rec+offset].words;
	      p = w.begin();
	      offset--;
	    }
	  
	  if(*p=="\(") //if '(' found, find ')'
	    {
	      offset = 1;
	      while(*p!=")" && (offset+rec)<sentence.size())
		{
		  w = sentence[rec+offset].words;
		  p = w.begin();
		  offset++;
		} 
	      
	      if(*p==")") 
		Output(outSet, string("\()") , targLoc);
	    }
	  
	  // is in quotes? if yes, there should be an odd number of
	  // '"' before it and after it in the sentence
	  
	  int count=0;
	  for(int i=0;i<rec;i++)
	    {
	      w = sentence[i].words;
	      p = w.begin();
	      if(*p=="\"") count++;
	    }
	  if((count % 2) == 1)
	    {
	      count=0;
	      for(int i=rec+1;i<sentence.size();i++)
		{
		  w = sentence[i].words;
		  p = w.begin();
		  if(*p=="\"") count++;
		}
	    }
	  if((count % 2) == 1)
	    Output(outSet, string("\"\"") , targLoc);  
        }
    }
}    

//
// The follwoing sensors (by Jakob) are somewhat specific for the conll03 named entity task (except zone)
// but can be easily changed
//
////////////////////////////

set<string> frequentWords;

SensorFrequentWord::SensorFrequentWord() : Sensor()
{
  sensorType = ST_WORD;
  ifstream inFile("freqW.list");

  //cerr << "Load List " << fn << " Now!" << endl;

  if (!inFile) { // error occurred during open
    cerr<<"histogram file not found! cannot use SensorFrequentWord"<<endl
	<<"A list must be created called freqW.list"<<endl;
    return;
  }
  else 
    {
      //cout<<"List Found..."<<endl;
      string word;
      int freq;
      while(!inFile.eof()) 
	{
	  inFile>>word;
	  frequentWords.insert(word);
	}
    }
  inFile.close();
}


//needs a word frequency list of the training corpus and decides whether the current word is frequent or not ( > 5 ocurrences)
void SensorFrequentWord::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      // first we need to "normalize" the word
      string word = *pWord;
      string final = "";
      // replace all numbers with NNUMN
      for(int i=0;i<word.size();i++)
	{
	  if(word[i]<='9' && word[i]>='0')
	    {
	      final += "NNUMN";
	      while(word[i]<='9' && word[i]>='0' && i<word.size()) i++;
	      i--;
	    }
	  else final += toupper(word[i]);
	}
      //cout<<final<<endl;
      if (frequentWords.find(final) != frequentWords.end())
	Output(outSet, string("YES") , targLoc);
      else
	Output(outSet, string("NO") , targLoc);  
    } 
}



vector<string> funcWordsLoc;
vector<string> funcWordsPer;
vector<string> funcWordsOrg;
vector<string> funcWordsMisc;

SensorFunctionalWord::SensorFunctionalWord() : Sensor()
{
  sensorType = ST_WORD;
  ifstream inFile("func.lst");

  //cerr << "Load List " << fn << " Now!" << endl;

  if (!inFile) { // error occurred during open
    cerr<<"functional word list not found! cannot use SensorFunctionalWord"<<endl;
    return;
  }
  else 
    {
      //      cout<<"List Found..."<<endl;
      string word;
      string entity;
      string final;
      while(!inFile.eof()) 
	{
	  inFile>>word;
	  entity=word;
	  while (word!="*" && !inFile.eof())
	    {
	      inFile>>word;
	      if(word!="*")
		{
		  if(final!="")
		    final += " ";
		  final += word;
		}
	      
	    }
	  if(final!="")
	    {
	      if(entity=="LOC")
		funcWordsLoc.push_back(final);
	      else if(entity=="PER")
		funcWordsPer.push_back(final);
	      else if(entity=="ORG")
		funcWordsOrg.push_back(final);
	      else if(entity=="MISC")
		funcWordsMisc.push_back(final);
	      // cout<<entity<<":"<<final<<endl;
	    }
	  final="";
	  
	}
    }
  inFile.close();
}

// for NER: fires if functional words exist (lowercase words in a NE from training, # > threshold
void SensorFunctionalWord::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      //check if word is lowercase
      if(islower(pWord->at(0)))
	{
	  //normalize
	  string word = *pWord;
	  string final = "";
	  for(int j=0;j<word.size();j++)
	    {
	      final += toupper(word[j]);
	    }
	  // cout<<"final:"<<final<<endl;
	  // try to find substring in the functional words lists
	  bool found=false;
	  for(int i=0;(i<funcWordsLoc.size() && !found);i++)
	    {
	      if(funcWordsLoc[i].find(final, 0) != string::npos)
		  found=true;
	    }
	  if(found) Output(outSet, string("LOC") , targLoc);

	  found=false;
	  for(int i=0;(i<funcWordsPer.size() && !found);i++)
	    {
	      if(funcWordsPer[i].find(final, 0) != string::npos)
		  found=true;
	    }
	  if(found) Output(outSet, string("PER") , targLoc);

	  found=false;
	  for(int i=0;(i<funcWordsOrg.size() && !found);i++)
	    {
	      if(funcWordsOrg[i].find(final, 0) != string::npos)
		  found=true;
	    }
	  if(found) Output(outSet, string("ORG") , targLoc);

	  found=false;
	  for(int i=0;(i<funcWordsMisc.size() && !found);i++)
	    {
	      if(funcWordsMisc[i].find(final, 0) != string::npos)
		  found=true;
	    }
	  if(found) Output(outSet, string("MISC") , targLoc);

	} 
    }
}


// extracts the information from column 8 in table format which is interpreted as the text zone the current word is in (e.g. headline, dateline, authorline, text, etc.)
void SensorZone::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  // REMEMBER: first element in zone is zone, 2nd is document number!!!
  // so don't iterate over inSet, pick the first entry
  StringVector inSet = sentence[rec].zones;
  StringVector::iterator pWord = inSet.begin();

  if (pWord != inSet.end())
    Output(outSet, *pWord , targLoc);
}


set<string> NCSloc;
set<string> NCSper;
set<string> NCSorg;
set<string> NCSmisc;

SensorNCS::SensorNCS() : Sensor()
{
  sensorType = ST_WORD;
  ifstream inLoc("LS.lst");
  ifstream inPer("PS.lst");
  ifstream inOrg("CS.lst");
  ifstream inMisc("MS.lst");

  if (!inLoc || !inPer || !inOrg || !inMisc) { // error occurred during open
    cerr<<"One of the list files not found.cannot apply SensorNCS"<<endl;
    return;
  }
  else 
    {
     
      string word;
      while(!inLoc.eof()) 
	{
	  inLoc>>word;
	  NCSloc.insert(word);
	}
      while(!inPer.eof()) 
	{
	  inPer>>word;
	  NCSper.insert(word);
	}
      while(!inOrg.eof()) 
	{
	  inOrg>>word;
	  NCSorg.insert(word);
	}
      while(!inMisc.eof()) 
	{
	  inMisc>>word;
	  NCSmisc.insert(word);
	}
    }
  inLoc.close();
  inPer.close();
  inOrg.close();
  inMisc.close();
}


//uses lists to determine if a word in a sequence of initCaps words but after the target word (Target+1...target+n) contains a word that commonly closes an named entity phrase (NCS=Name Class Suffix) 
void SensorNCS::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  //check if this word is initCaps
  StringVector inSet = sentence[rec].words;
  bool stop=false;
  bool firstInit=false;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      if (isupper(pWord->at(0)) && isLetter(pWord->at(0))) firstInit=true;
      // cout<<"we're at:"<<*pWord<<endl;
    }
  
  // now check if the following words are initCaps & in one of the lists
  for(int i=rec+1;(i<sentence.size() && !stop && firstInit);i++)
    {
      inSet = sentence[i].words;
      for(StringVector::iterator p = inSet.begin();
	  p != inSet.end(); p++)
	{
	  // cout<<"checking word "<<*p<<endl;
	  if (isupper(p->at(0)) && isLetter(p->at(0)))
	  {
	    
	    // first we need to "normalize" the word
	    string word = *p;
	    string final = "";
	    for(int j=0;j<word.size();j++)
	      {
		final += toupper(word[j]);
	      }
	    //cout<<final<<endl;
	    if (NCSloc.find(final) != NCSloc.end())
	      Output(outSet, string("LOC") , targLoc);
	    else if (NCSper.find(final) != NCSper.end())
	      Output(outSet, string("PER") , targLoc);
	    else if (NCSorg.find(final) != NCSorg.end())
	      Output(outSet, string("ORG") , targLoc); 
	    else if (NCSmisc.find(final) != NCSmisc.end())
	      Output(outSet, string("MISC") , targLoc);  
	  }
	  else stop=true;
	}
    }
}

set<string> NEuniPre;

//vector < set<string> >  NEuniPreLists;
//vector<string> NEclassnames;

SensorNEunigramPre::SensorNEunigramPre() : Sensor()
{
  sensorType = ST_WORD;

  // it could be that the lists are already loaded by the previous bigram sensor
  ifstream inFile("Pre.lst");

  if (!inFile) { // error occurred during open
    cerr << "list file not found. cannot apply SensorNEunigramPre"<<endl;
    return;
  }
  else {

    string unigram;
    while(!inFile.eof()) {
      inFile >> unigram;
      NEuniPre.insert(unigram);
    }
  }
  inFile.close();
}

// for NER: fires if the word before target has a word thats typically before an NE (also indicates which NE). A list must be created for this sensor.
void SensorNEunigramPre::Extract( Sentence &sentence, RawFeatureSet &outSet,
                             int rec, int targLoc )
{
  //need to acces 1 word prior to w
  if (rec > 0) {
    // first we need to "normalize" the unigram by replacing numbers with +NUM+ && uppercasing
    StringVector::iterator p = sentence[rec-1].words.begin();
    string word1 = *p;
    string final = "";
    for(int i=0;i<word1.size();i++) {
      if(word1[i]<='9' && word1[i]>='0') {
	final += "+NUM+";
	while(word1[i]<='9' && word1[i]>='0' && i<word1.size()) i++;
	i--;
      }
      else 
	final += toupper(word1[i]);
    }

    // cout<<final<<endl;
    if (NEuniPre.find(final) != NEuniPre.end())
      Output(outSet, final, targLoc);
  }
}

set<string> NEPreBIloc;
set<string> NEPreBIper;
set<string> NEPreBIorg;
set<string> NEPreBImisc;

SensorNEPrebigram::SensorNEPrebigram() : Sensor()
{
  sensorType = ST_WORD;
  ifstream inFile("Pre2.lst");

  if (!inFile) { // error occurred during open
    cerr<<"list file not found. cannot apply SensorNEbigram"<<endl;
    return;
  }
  else 
    {
      
      string NEclass;
      string bigram;
      while(!inFile.eof()) 
	{
	  inFile>>NEclass>>bigram;
	  if(NEclass=="LOC")
	    NEPreBIloc.insert(bigram);
	  else if(NEclass=="PER")
	    NEPreBIper.insert(bigram);
	  else if(NEclass=="ORG")
	    NEPreBIorg.insert(bigram);
	  else if(NEclass=="MISC")
	    NEPreBImisc.insert(bigram);
	}
    }
  inFile.close();
}
  

//uses lists to determine if the two wordes (bigram) before the target usually occur before a name class
void SensorNEPrebigram::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  //need to acces 2 words prior to rec
  if(rec>1)
    {
      StringVector inSet = sentence[rec].words;
      for(StringVector::iterator pWord = inSet.begin();
	  pWord != inSet.end(); pWord++)
	{
	  
	  // first we need to "normalize" the bigram by adding underscore between and replacing numbers with +NUM+
	  StringVector::iterator p = sentence[rec-2].words.begin();
	  string word1 = *p;
	  p = sentence[rec-1].words.begin();
	  string word2 = *p;

	  string final = "";
	  //first word
	  for(int i=0;i<word1.size();i++)
	    {
	      if(word1[i]<='9' && word1[i]>='0')
		{
		  final += "+NUM+";
		  while(word1[i]<='9' && word1[i]>='0' && i<word1.size()) i++;
		  i--;
		}
	      else final += toupper(word1[i]);
	    }
	  
	  final+="_";
	  
	  //second word
	  for(int i=0;i<word2.size();i++)
	    {
	      if(word2[i]<='9' && word2[i]>='0')
		{
		  final += "+NUM+";
		  while(word2[i]<='9' && word2[i]>='0' && i<word2.size()) i++;
		  i--;
		}
	      else final += toupper(word2[i]);
	    }
	  
	  //cout<<final<<endl;
	  if (NEPreBIloc.find(final) != NEPreBIloc.end())
	    Output(outSet, string("LOC") , targLoc);
	  if (NEPreBIper.find(final) != NEPreBIper.end())
	    Output(outSet, string("PER") , targLoc);
	  if (NEPreBIorg.find(final) != NEPreBIorg.end())
	      Output(outSet, string("ORG") , targLoc); 
	  if (NEPreBImisc.find(final) != NEPreBImisc.end())
	    Output(outSet, string("MISC") , targLoc);  
	} 
    }
}


set<string> NEsufloc;
set<string> NEsufper;
set<string> NEsuforg;
set<string> NEsufmisc;

SensorNEsuffix::SensorNEsuffix() : Sensor()
{
  sensorType = ST_WORD;
  ifstream inLoc("LOC.suf");
  ifstream inPer("PER.suf");
  ifstream inOrg("ORG.suf");
  ifstream inMisc("MISC.suf");

  if (!inLoc || !inPer || !inOrg || !inMisc) { // error occurred during open
    cerr<<"One of the list files not found.cannot apply SensorNEsuffix"<<endl;
    return;
  }
  else 
    {
     
      string word;
      while(!inLoc.eof()) 
	{
	  inLoc>>word;
	  NEsufloc.insert(word);
	}
      while(!inPer.eof()) 
	{
	  inPer>>word;
	  NEsufper.insert(word);
	}
      while(!inOrg.eof()) 
	{
	  inOrg>>word;
	  NEsuforg.insert(word);
	}
      while(!inMisc.eof()) 
	{
	  inMisc>>word;
	  NEsufmisc.insert(word);
	}
    }
  inLoc.close();
  inPer.close();
  inOrg.close();
  inMisc.close();
}


//uses lists to determine if target has a 3-letter-suffix that occurs often in a named entity
void SensorNEsuffix::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
      if ((*pWord).size()>=3)
	{
	  string x = *pWord;
	  string suffix("   ");
	  suffix[0] = x[x.size()-3];
	  suffix[1] = x[x.size()-2];
	  suffix[2] = x[x.size()-1];
	  
	  // first we need to "normalize" the suffix
	  
	  string final = "";
	  for(int j=0;j<suffix.size();j++)
	    {
	      final += toupper(suffix[j]);
	    }

	  //cout<<final<<endl;
	  if (NEsufloc.find(final) != NEsufloc.end())
	    Output(outSet, string("LOC") , targLoc);
	  else if (NEsufper.find(final) != NEsufper.end())
	    Output(outSet, string("PER") , targLoc);
	  else if (NEsuforg.find(final) != NEsuforg.end())
	    Output(outSet, string("ORG") , targLoc); 
	  else if (NEsufmisc.find(final) != NEsufmisc.end())
	    Output(outSet, string("MISC") , targLoc);  
	}

    }
}

SensorNEotherBI::SensorNEotherBI() : Sensor()
{
  sensorType = ST_WORD;
  
  // it could be that the lists are already loaded by the previous bigram sensor
  if(NEPreBIloc.size()==0 || NEPreBIper.size()==0 || NEPreBIorg.size()==0 || NEPreBImisc.size()==0)
    {
      ifstream inFile("Pre2.lst");
      
      if (!inFile) { // error occurred during open
	cerr<<"list file not found. cannot apply SensorNEotherBI"<<endl;
	return;
      }
      else 
	{
	  
	  string NEclass;
	  string bigram;
	  while(!inFile.eof()) 
	    {
	      inFile>>NEclass>>bigram;
	      if(NEclass=="LOC")
		NEPreBIloc.insert(bigram);
	      else if(NEclass=="PER")
		NEPreBIper.insert(bigram);
	      else if(NEclass=="ORG")
		NEPreBIorg.insert(bigram);
	      else if(NEclass=="MISC")
		NEPreBImisc.insert(bigram);
	    }
	}
      inFile.close();
    }
}
  

//this checks whether another occurrence of target in the document has a nePreBI feature active, and fires the corresponding feature for this word
void SensorNEotherBI::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{

  //check all other occurrences of the target word except target itself

  for(int s=0;s<globalParams.currentDoc.size();s++)   // for all sentences in current document...
    for(int w=0;w<globalParams.currentDoc[s].size();w++) // for each word...
      if(!(s==(globalParams.currentDoc.size()-1) && (w==rec)))  // if its not the actual target...
	{
	  //need to acces 2 words prior to w
	  if(w>1 && (*(globalParams.currentDoc[s][w].words.begin()) == *(sentence[rec].words.begin())))
	    {
	  
	      // first we need to "normalize" the bigram by adding underscore between and replacing numbers with +NUM+
	      StringVector::iterator p = globalParams.currentDoc[s][w-2].words.begin();
	      string word1 = *p;
	      p = globalParams.currentDoc[s][w-1].words.begin();
	      string word2 = *p;
	      
	      string final = "";
	      //first word
	      for(int i=0;i<word1.size();i++)
		{
		  if(word1[i]<='9' && word1[i]>='0')
		    {
		      final += "+NUM+";
		      while(word1[i]<='9' && word1[i]>='0' && i<word1.size()) i++;
		      i--;
		    }
		  else final += toupper(word1[i]);
		}
	      
	      final+="_";
	      
	      //second word
	      for(int i=0;i<word2.size();i++)
		    {
		      if(word2[i]<='9' && word2[i]>='0')
			{
			  final += "+NUM+";
			  while(word2[i]<='9' && word2[i]>='0' && i<word2.size()) i++;
			  i--;
			}
		      else final += toupper(word2[i]);
		    }
		  
	      //cout<<final<<endl;
	      if (NEPreBIloc.find(final) != NEPreBIloc.end())
		Output(outSet, string("LOC") , targLoc);
	      if (NEPreBIper.find(final) != NEPreBIper.end())
		Output(outSet, string("PER") , targLoc);
	      if (NEPreBIorg.find(final) != NEPreBIorg.end())
		Output(outSet, string("ORG") , targLoc); 
	      if (NEPreBImisc.find(final) != NEPreBImisc.end())
		Output(outSet, string("MISC") , targLoc);  
	      
	    } 
	}
}


SensorNEotherNCS::SensorNEotherNCS() : Sensor()
{
  if(NCSloc.size()==0 || NCSper.size()==0 || NCSorg.size()==0 || NCSmisc.size()==0)
    {
      sensorType = ST_WORD;
      ifstream inLoc("LS.lst");
      ifstream inPer("PS.lst");
      ifstream inOrg("CS.lst");
      ifstream inMisc("MS.lst");
      
      if (!inLoc || !inPer || !inOrg || !inMisc) { // error occurred during open
	cerr<<"One of the list files not found.cannot apply SensorNCS"<<endl;
	return;
      }
      else 
	{
	  
	  string word;
	  while(!inLoc.eof()) 
	    {
	      inLoc>>word;
	      NCSloc.insert(word);
	    }
	  while(!inPer.eof()) 
	    {
	      inPer>>word;
	      NCSper.insert(word);
	    }
	  while(!inOrg.eof()) 
	    {
	      inOrg>>word;
	      NCSorg.insert(word);
	    }
	  while(!inMisc.eof()) 
	    {
	      inMisc>>word;
	      NCSmisc.insert(word);
	    }
	}
      inLoc.close();
      inPer.close();
      inOrg.close();
      inMisc.close();
    }
}


//uses lists to check if another occurrence of target in document has the ncs feature active
void SensorNEotherNCS::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{

  //check all other occurrences of the target word except target itself

  for(int s=0;s<globalParams.currentDoc.size();s++)   // for all sentences in current document...
    for(int w=0;w<globalParams.currentDoc[s].size();w++) // for each word...
      if(!(s==(globalParams.currentDoc.size()-1) && (w==rec)))  // if its not the actual target...
	{
	  if(*(globalParams.currentDoc[s][w].words.begin()) == *(sentence[rec].words.begin()))
	    {
	  
	      //check if this word is initCaps
	      StringVector inSet = globalParams.currentDoc[s][w].words;
	      bool stop=false;
	      bool firstInit=false;
	      for(StringVector::iterator pWord = inSet.begin();
		  pWord != inSet.end(); pWord++)
		{
		  if (isupper(pWord->at(0)) && isLetter(pWord->at(0))) firstInit=true;
		  // cout<<"we're at:"<<*pWord<<endl;
		}
	      
	      // now check if the following words are initCaps & in one of the lists
	      for(int i=w+1;(i<globalParams.currentDoc[s].size() && !stop && firstInit);i++)
		{
		  inSet = globalParams.currentDoc[s][i].words;
		  for(StringVector::iterator p = inSet.begin();
		      p != inSet.end(); p++)
		    {
		      // cout<<"checking word "<<*p<<endl;
		      if (isupper(p->at(0)) && isLetter(p->at(0)))
			{
			  
			  // first we need to "normalize" the word
			  string word = *p;
			  string final = "";
			  for(int j=0;j<word.size();j++)
			    {
			      final += toupper(word[j]);
			    }
			  //cout<<final<<endl;
			  if (NCSloc.find(final) != NCSloc.end())
			    Output(outSet, string("LOC") , targLoc);
			  else if (NCSper.find(final) != NCSper.end())
			    Output(outSet, string("PER") , targLoc);
			  else if (NCSorg.find(final) != NCSorg.end())
			    Output(outSet, string("ORG") , targLoc); 
			  else if (NCSmisc.find(final) != NCSmisc.end())
			    Output(outSet, string("MISC") , targLoc);  
			}
		      else stop=true;
		    }
		}
	    }
	}
}


//indicate if another occurrence of target in document is InitCaps or not. The other occurrence must be in an unambiguous position (non-first word in the text zone
void SensorOtherInitCap::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{

  //check all other occurrences of the target word except target itself
  // the other occurrence may be lowercase or uppercase
  string low = *(sentence[rec].words.begin());
  if(isLetter(low[0]))
  {
    low[0] = tolower(low[0]);
    string up = low;
    up[0] = toupper(up[0]);
    
    for(int s=0;s<globalParams.currentDoc.size();s++)   // for all sentences in current document...
      for(int w=0;w<globalParams.currentDoc[s].size();w++) // for each word...
	if(!(s==(globalParams.currentDoc.size()-1) && (w==rec)))  // if its not the actual target...
	  {
	    if( (*(globalParams.currentDoc[s][w].words.begin()) == low)) // found lowercase occurrence
	      {
		
		//check if this word is in the TXT zone
		if(*(globalParams.currentDoc[s][w].zones.begin()) == "TXT")
		Output(outSet, string("NO") , targLoc); 
	      }
	  
	    if( (*(globalParams.currentDoc[s][w].words.begin()) == up)) // found uppercase occurrence
	      {
		
		//check if this word is in the TXT zone
		if(*(globalParams.currentDoc[s][w].zones.begin()) == "TXT")
		Output(outSet, string("YES") , targLoc); 
	      }
	  }
  }
}


vector<int> AcroIndices;
vector<string> Acronyms;
vector<string> AcroSeq;

SensorPartOfAcronym::SensorPartOfAcronym() : Sensor()
{

  sensorType = ST_WORD;

  //  ifstream plFile("acronyms.pl");
  // if(!plFile) {
  //cerr<<"acronyms.pl not found. needs to be in working directory. Check fex/tools.\n"<<endl;
  //return;
  //}
  //string corp = string(globalParams.corpusFile);
  //string command = "./acronyms.pl ";
  //command += corp;
  //command += " > acronyms.lst";
  //system(command.c_str());
  
  //string corp = string(globalParams.corpusFile);
  //corp += ".acronyms";
  //ifstream inFile(corp.c_str());
  ifstream inFile("acronyms");
  
  if (!inFile) { // error occurred during open
    cerr<<"acronyms not found. cannot apply SensorPartOfAcronym. see fex/tools/acronym.pl"<<endl;
    return;
  }
  else 
    {

      int index;
      string acronym, sequence;
      while(!inFile.eof()) 
	{
	  inFile>>index>>acronym>>sequence;
	  AcroIndices.push_back(index);
	  Acronyms.push_back(acronym);
	  AcroSeq.push_back(sequence);
	}
    }

  inFile.close();

}

//indicate if target is at the beginning, middle, or end of an InitCap phrase that constitues an acronym that has been found in the text zone of the same document
void SensorPartOfAcronym::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  
  bool ok;
  int i;
  string target = *(sentence[rec].words.begin());
  int docindex = sentence[rec].docIndex;
  if((target[0] == toupper(target[0]) && isLetter(target[0])))
    {
      // check if its all initcap or just first one
      
      bool isAllCap = true;
      for(int ci=1;ci<target.size();ci++)
	if (islower(target[ci]))
            {
	      isAllCap = false;
               break;
            }
      
      if (isAllCap) // its an acronym candidate... look for it in the list
	{
	  bool found=false;
	  for(int bla=0;(bla<Acronyms.size() && AcroIndices[bla]<=docindex && !found); bla++)
	    if(AcroIndices[bla]==docindex && Acronyms[bla]==target)
	      {
		Output(outSet, string("A_Unique") , targLoc);
		found==true;
	      }
	}
      else // it's not an acronym, but maybe a sequence of initcap words...
	{
	  
	  // get the whole sequence
	  // find starting point
	  ok=true;
	  for(i = rec; (i>=0 && ok);i--)
	    {
	      string prev = *(sentence[i].words.begin());
	      if(!((prev[0] == toupper(prev[0]) && isLetter(prev[0]))))
		ok = false;
	    }
	  
	  // get initCap sequence
	  int start;
	  start = ok ? 0 : i+2;
	  ok=true;
	  string sequence="";
	  for(i=start;(i<sentence.size() && ok);i++)
	    {
	      string word = *(sentence[i].words.begin());
	      if((word[0] == toupper(word[0]) && isLetter(word[0])))
		{
		  if(i!=start) sequence+= "_";
		  sequence += word;
		}
	      else ok=false;
	    }
	  
	  int end = ok ? i-1 : i-2;
	  //try to find the sequence in the list
	  bool found=false;
	  for(int x=0;(x<AcroSeq.size() && !found && AcroIndices[x]<= docindex);x++)
	    if(AcroIndices[x]==docindex && AcroSeq[x]==sequence) found=true;
	  	  
	  if(found==true)
	    {
	      if(rec==start) Output(outSet, string("A_begin") , targLoc);
	      if(rec>start && rec<end) Output(outSet, string("A_continue") , targLoc);
	      if(rec==end) Output(outSet, string("A_end") , targLoc); 
	    }
	}
    }
}

//set<string> NEuniPre;

SensorNEotherUNI::SensorNEotherUNI() : Sensor()
{
  sensorType = ST_WORD;
  
  // it could be that the lists are already loaded by the previous bigram sensor
  ifstream inFile("Pre.lst");
      
  if (!inFile) { // error occurred during open
    cerr<<"list file not found. cannot apply SensorNEotherUNI"<<endl;
    return;
  }
  else 
    {
      
      string unigram;
      while(!inFile.eof()) 
	{
	  inFile>>unigram;
	  NEuniPre.insert(unigram);
	}
    }
  inFile.close();
}


//this checks whether another occurrence of target in the document has a word from the unigram list in front of it, and fires the corresponding feature for this word
void SensorNEotherUNI::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{

  //check all other occurrences of the target word except target itself

  for(int s=0;s<globalParams.currentDoc.size();s++)   // for all sentences in current document...
    for(int w=0;w<globalParams.currentDoc[s].size();w++) // for each word...
      if(!(s==(globalParams.currentDoc.size()-1) && (w==rec)))  // if its not the actual target...
	{
	  //need to acces 1 word prior to w
	  if(w>0 && (*(globalParams.currentDoc[s][w].words.begin()) == *(sentence[rec].words.begin())))
	    {
	  
	      // first we need to "normalize" the unigram by replacing numbers with +NUM+ && uppercasing
	      StringVector::iterator p = globalParams.currentDoc[s][w-1].words.begin();
	      string word1 = *p;
	      string final = "";
	      for(int i=0;i<word1.size();i++)
		{
		  if(word1[i]<='9' && word1[i]>='0')
		    {
		      final += "+NUM+";
		      while(word1[i]<='9' && word1[i]>='0' && i<word1.size()) i++;
		      i--;
		    }
		  else final += toupper(word1[i]);
		}
	      		  
	      // cout<<final<<endl;
	      if (NEuniPre.find(final) != NEuniPre.end())
		Output(outSet, final , targLoc);
	      
	    } 
	}
}

vector<string> subseq;
vector<int> subseqIndices;

SensorIcapSubSequence::SensorIcapSubSequence() : Sensor()
{

  sensorType = ST_WORD;
  
  //string corp = string(globalParams.corpusFile);
  //corp += ".icapSequences";
  //ifstream inFile(corp.c_str());
  ifstream inFile("icapSequences");
  
  if (!inFile) { // error occurred during open
    cerr<<"icapSequences not found. cannot apply SensorIcapSubSequence. see fex/tools/icapSequence.pl"<<endl;
    return;
  }
  else 
    {

      int index;
      string seq;
      while(!inFile.eof()) 
	{
	  inFile>>index>>seq;
	  subseqIndices.push_back(index);
	  subseq.push_back(seq);
	}
    }

  inFile.close();

}

// finds longest subsequences of sequences of initCaps words in a given document and marks them accordingly
void SensorIcapSubSequence::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  
  bool ok;
  int i;
  string target = *(sentence[rec].words.begin());
  int docindex = sentence[rec].docIndex;
  if((target[0] == toupper(target[0]) && isLetter(target[0])))
    {
	  
      // get the whole sequence
      // find starting point
      ok=true;
      for(i = rec; (i>=0 && ok);i--)
	{
	  string prev = *(sentence[i].words.begin());
	  if(!((prev[0] == toupper(prev[0]) && isLetter(prev[0]))))
	    ok = false;
	}
      
      // get initCap sequence
      int start;
      start = ok ? 0 : i+2;
      ok=true;
      
      // find ending point
      for(i=start;(i<sentence.size() && ok);i++)
	{
	  string word = *(sentence[i].words.begin());
	  if(!(word[0] == toupper(word[0]) && isLetter(word[0])))
	    ok=false;
	}
      int end = ok ? i-1 : i-2;
      
      ok=true;
      string sequence="";

      for(int j=start;j<=end;j++)
	{
	  sequence="";
	  for(i=j;i<=end;i++)
	    {
	      string word = *(sentence[i].words.begin());
	      if((word[0] == toupper(word[0]) && isLetter(word[0])))
		{
		  if(i!=j) sequence+= "_";
		  sequence += word;
		  
		  //try to find the sequence in the list
		  //cout<<"seq:"<<sequence<<endl;
		  bool found=false;
		  for(int x=0;(x<subseq.size() && !found && subseqIndices[x]<= docindex);x++)
		    if(subseqIndices[x]==docindex && subseq[x]==sequence) found=true;
		  
		  if(found==true)
		    {
		      if(rec==j) Output(outSet, string("I_begin") , targLoc);
		      if(rec>j && rec<i) Output(outSet, string("I_continue") , targLoc);
		      if(rec==i) Output(outSet, string("I_end") , targLoc); 
		    }
		}
	      else ok=false;
	    }
	}
    }
}

// find another, already labeled occurrence of target and fire it's label. The label is given in the second column of the corpus; see tools/BILOU2nNCm.pl. The occurrence of target within the longest label sequence is preferred.
void SensorNEotherLabel::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{ 
  bool ok;
  int i;
  string target = *(sentence[rec].words.begin());
  int docindex = sentence[rec].docIndex;

  int maxlength=0;
  string maxLabel= "";
  string label;

  //find occurrence
  for(int s=0;s<globalParams.currentDoc.size();s++)   // for all sentences in current document...
    for(int w=0;w<globalParams.currentDoc[s].size();w++) // for each word...
      if(!(s==(globalParams.currentDoc.size()-1) && (w==rec)))  // if its not the actual target...
	if( *(globalParams.currentDoc[s][w].words.begin()) == target)
	  {
	    label = *(globalParams.currentDoc[s][w].namedEntities.begin());
	    if (label != "O")
	      {
		int length = atoi(&(label[label.size()-1]));
		if(length>maxlength)
		  {
		    maxlength=length;
		    maxLabel = label;
		  }
	      }
	  }
  
  if(maxLabel != "") 
    {
      //cout<<target<<" is assigned "<<maxLabel<<endl;
      Output(outSet, maxLabel , targLoc);
    }
  
}

//output whatever is in first column (used for word mode as a hack to do lab(col1) to get labels
void SensorFirstColumn::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{ 
  string label  =   sentence[rec].phraseLabel;
  Output(outSet, label , targLoc);

}

//output whatever is in 2nd column (e.g. labels of previous classification)
void SensorSecondColumn::Extract( Sentence &sentence, RawFeatureSet &outSet,
                             int rec, int targLoc ) 
{

    for(StringVector::iterator it = sentence[rec].namedEntities.begin();
       it != sentence[rec].namedEntities.end(); it++) // the 2nd column
    {
       Output(outSet, *it , targLoc);
    }
}      
//--------------------------------------------------------------

// this extracts the html tag token itself (9th column)
void SensorHTML::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{
   StringVector inSet = sentence[rec].htmlTags;
   for(StringVector::iterator pFeat = inSet.begin();
       pFeat != inSet.end(); pFeat++) {
     Output(outSet, *pFeat, targLoc);
   }
}



// NE list sensor used in conll03

vector<string> Loc;
vector<string> Per;
vector<string> Org;
vector<string> Misc;

SensorNERlist::SensorNERlist() : Sensor()
{
  sensorType = ST_WORD;
  ifstream inFile("NER.lst");

  //cerr << "Load List " << fn << " Now!" << endl;

  if (!inFile) { // error occurred during open
    cerr<<" NER.lst not found! cannot use NERlist sensor"<<endl;
    return;
  }
  else 
    {
      //      cout<<"List Found..."<<endl;
      string word;
      string entity;
      string final;
      while(!inFile.eof()) 
	{
	  inFile>>word;
	  entity=word;
	  while (word!="*" && !inFile.eof())
	    {
	      inFile>>word;
	      if(word!="*")
		{
		  if(final!="")
		    final += " ";
		  final += word;
		}
	      
	    }
	  if(final!="")
	    {
	      if(entity=="LOC")
		Loc.push_back(final);
	      else if(entity=="PER")
		Per.push_back(final);
	      else if(entity=="ORG")
		Org.push_back(final);
	      else if(entity=="MISC")
		Misc.push_back(final);
	      // cout<<entity<<":"<<final<<endl;
	    }
	  final="";
	  
	}
    }
  inFile.close();
}

//make a string corresponding to all uppercase version of sentence
string NormalizeSentence(Sentence &sentence)
{
	string final = "";
	for(int i=0;i<sentence.size();i++)
	{
		string word = *(sentence[i].words.begin());
	        for(int j=0;j<word.size();j++)
       		{
              		word[j] = toupper(word[j]);
            	}
		if(i<(sentence.size()-1)) word += " ";
		final += word;
	}
	return final;
}

// for NER: checks a list of NE's for the conll03 task (gazeteer)
void SensorNERlist::Extract( Sentence &sentence, RawFeatureSet &outSet,
			     int rec, int targLoc )
{
  StringVector inSet = sentence[rec].words;
  string label = sentence[rec].phraseLabel;
  bool loc,org,per,misc;loc=org=per=misc=false;
  for(StringVector::iterator pWord = inSet.begin();
      pWord != inSet.end(); pWord++)
    {
	  //normalize
	  string word = *pWord;
	  string final = "";
	  for(int j=0;j<word.size();j++)
	    {
	      final += toupper(word[j]);
	    }
	  // cout<<"final:"<<final<<endl;
	  // try to find substring in the functional words lists


	  string normsent = NormalizeSentence(sentence);
	  // make sure to find the position of the actual word in the sentence, not just any identical word
	  // there must be rec blanks before the current position
	  int count=0;
	  int where=0;
	  for(int i=0; ((i<normsent.size()) && (count<rec));i++)
	  {
		if(normsent[i]==' ') count++;
		if(count==rec) where=i;
	  }
	  int word_index = normsent.find(final, where);

	  bool found=false;
	  int index;
	  for(int i=0;(i<Loc.size() && !found);i++)
	    {
	      index = normsent.find(Loc[i], 0);
	      if((index != string::npos) && (word_index >= index) && (word_index <= (index+Loc[i].size())))
		{
		   if(Loc[i].find(final,0) != string::npos)
		   {
		   	found=true; loc=true;
		   }
		}
	    }
	  if(found) Output(outSet, string("LOC") , targLoc);

          found=false;
          for(int i=0;(i<Per.size() && !found);i++)
            {
              index = normsent.find(Per[i], 0);
              if((index != string::npos) && (word_index >= index) && (word_index <= (index+Per[i].size())))
                {       
                   if(Per[i].find(final,0) != string::npos)
                   {
                        found=true;per=true;
                   }    
                }   
            }
          if(found) Output(outSet, string("PER") , targLoc);
  
          found=false;
          for(int i=0;(i<Org.size() && !found);i++)
            {
              index = normsent.find(Org[i], 0);
              if((index != string::npos) && (word_index >= index) && (word_index <= (index+Org[i].size())))
                {       
                   if(Org[i].find(final,0) != string::npos)
                   {
                        found=true;org=true;
                   }    
                }   
            }
          if(found) Output(outSet, string("ORG") , targLoc);
  
          found=false;
          for(int i=0;(i<Misc.size() && !found);i++)
            {
              index = normsent.find(Misc[i], 0);
              if((index != string::npos) && (word_index >= index) && (word_index <= (index+Misc[i].size())))
                {       
                   if(Misc[i].find(final,0) != string::npos)
                   {
                        found=true;misc=true;
                   }    
                }   
            }
          if(found) Output(outSet, string("MISC") , targLoc);  

	//cout<<label<<"\t"<<final;
	//if(per) cout<<"\tPER";
	//if(loc) cout<<"\tLOC";
	//if(org) cout<<"\tORG";
	//if(misc)cout<<"\tMISC";
	//cout<<endl;

    }
}


// case-insensitive version of "w"
void SensorWordUpper::Extract( Sentence &sentence, RawFeatureSet &outSet,
                           int rec, int targLoc )
{       
   StringVector inSet = sentence[rec].words;
        for(StringVector::iterator pFeat = inSet.begin();
            pFeat != inSet.end(); pFeat++)
        {
		string word = *pFeat;
                for(int j=0;j<word.size();j++)
                {
                        word[j] = toupper(word[j]);
                }


                Output(outSet, word, targLoc);
        }

}
