//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Fex.h                                         =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef __FEX_H__
#define __FEX_H__

#include <string>
#include <set>
#include <vector>
#ifdef HASH_MAP
  #include <hash_map>
   template <>
   class hash<string>
   {
      public:
         size_t operator()(string const &str) const
      {
         hash<char const *> h;
         return (h(str.c_str()));
      }
   };
#else
  #include <map>
#endif

using namespace std;


typedef set<string>	RawFeatureSet;
typedef vector<RawFeatureSet> RawSentenceFeatures;
typedef set<int>		FeatureSet;

typedef vector<string>	StringVector;

struct Record
{
  StringVector phrasal;
  StringVector tags;
  StringVector words;
  StringVector func;
  set<int> pointer;
  
  // for phrase case, by Scott Yih, 09/24/01
  string phraseLabel;  // 1st column
  StringVector namedEntities;  // 2nd column

  //text zone designation in column 8 by Jakob Metzler 10/6/03
  StringVector zones;
  //document index in column 8, 2ns entry (Jakob Metzler 11/5/03)
  int docIndex;

  // html tag stored in the 9th column, added by Scott Yih 12/12/03
  StringVector htmlTags;

  RawFeatureSet relArgs;
};

typedef vector<Record>  Sentence;

struct RelationTag
{
	int arg1, arg2;
	string label;
};

typedef vector<RelationTag> RelationInSentence;

typedef vector<StringVector>  TargetVector;
#ifdef HASH_MAP
  typedef hash_map<string,string> StringMap;
#else
  typedef map<string, string> StringMap;
#endif

#endif


