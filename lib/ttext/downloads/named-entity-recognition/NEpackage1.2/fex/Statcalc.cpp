// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Statcalc
//=                                                         =
//=   Module: Statcalc.cpp                                  =
//=  Version: 1.0                                           =
//=   Author: Chad Cumby 
//=     Date: xx/xx/00                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#include "GlobalParams.h"
#include "Stats.h"
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <iomanip>

#ifdef WIN32
extern "C"
{
    extern int getopt(int, char* const *, const char*);
    extern char *optarg;
}
#endif

GlobalParams globalParams;

void Pause();
void ShowOptions();
bool ParseCmdLine(int argc, char* argv[]);
void ShowUsage();


int main( int argc, char* argv[] )
{
    if (argc == 1)
        // no options were given-- output usage
        ShowUsage(); 

    else if (ParseCmdLine(argc, argv))
    {      
            Stats stats;
            ifstream exIn(globalParams.exampleFile);
   
            if(!exIn)
            {
               cerr << "Error opening input file." << endl;
               exit(-1);
            }
            else
            {
               FeatureSet theSet;

               while(!exIn.eof()) 
               {
                  theSet.clear();
                  char delim;

                  do
                  { 
                     int foo; 
                     exIn >> foo;
                     if(!exIn.fail())
                     {
                        theSet.insert(foo);
                        exIn.get(delim);
                     }
                     else
                     {
                        if(!exIn.eof())
                        {
                           cerr << "problem in initial read" << endl;
                           exIn.close();
                           exit(-1);
                        }
                     }
                  } while(delim == ',');
                  if(!exIn.eof())
                     stats.BuildCounts(theSet);
               }
            } 
            exIn.close();

            //do the actual statistics
            if (stats.CalcStats())
               stats.WriteStats(globalParams.statFile); 
            if(globalParams.statThresh >= 0)
               stats.FilterExamps(globalParams.exampleFile, 
                     globalParams.statThresh, globalParams.statType);
    }
    else
      ShowUsage(); 
  
    return 0;
}

bool ParseCmdLine(int argc, char* argv[])
{
  
	static int fileParam = 1;
    bool result = true;

    // command line arguments    
    // Read in input data

   if(argc > 1)
	   globalParams.exampleFile = argv[1];
   else
      result = false;
   if(argc > 2)
	   globalParams.statFile = argv[2];
   else
      result = false;
	if (argc > 3)
   {
      if (!strcmp(argv[3], "chi")) {
               globalParams.statType = S_CHI;
          } else if (!strcmp(argv[3], "ig")) {
               globalParams.statType= S_IG;
          } else if (!strcmp(argv[3], "mi")) {
               globalParams.statType = S_MI;
          } else 
               result = false;
         if(argc < 4)
         return false;
      else
         globalParams.statThresh = atoi(argv[4]);
   }

   return result;
}

void ShowUsage()
{
   cerr << "Usage: statcalc [options] <example-file> <stat-file> [stat-type] " 
        << "[threshold]" << endl;
}
