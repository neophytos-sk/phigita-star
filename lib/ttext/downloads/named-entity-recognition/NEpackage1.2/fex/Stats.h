//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Stats.h                                       =
//=  Version: 2.0                                           =
//=   Author: Chad Cumby                                    =
//=     Date: xx/xx/00                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef __STATS_H__
#define __STATS_H__

#include "Fex.h"
#include "GlobalParams.h"
#ifdef HASH_MAP
   #include <hash_map>
#else
  #include <map>
#endif

struct FeatureStats;

#ifdef HASH_MAP
   typedef hash_map<int, FeatureStats> ConcMap;
   typedef hash_map<int, int> TargMap;
#else
   typedef map<int, FeatureStats> ConcMap;
   typedef map<int, int> TargMap;
#endif

struct FeatureStats
{
   int      count; 
   double   chi;
   double   chi_percent;
   double   ig;
   double   mi;
   ConcMap  concMap;  
};


class Stats : public ConcMap 
{
public:
	Stats();
	~Stats();

	bool     CalcStats(); 
   void     WriteStats(const char* outFile);
   void     FilterExamps( string exampleFile , double thresh, StatType type );
   void     BuildCounts( FeatureSet& example );

protected:
   int      totalEx;
   int      totalFe;
   TargMap  targMap;
};

#endif
