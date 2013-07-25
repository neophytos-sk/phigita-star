//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Stats.cpp                                     =
//=  Version: 2.0                                           =
//=   Author: Chad Cumby                                    =
//=     Date: xx/xx/00                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#pragma warning( disable:4786 )

#include "Stats.h"
#include <iostream>
#include <iomanip>
#include <set>
#include <fstream>

#ifndef WIN32
#define ios_base ios
#endif

extern "C" float chdtr(float, float);

Stats::Stats() : totalEx(0), totalFe(0)
{
}

Stats::~Stats()
{
}

bool Stats::CalcStats()
{

   //only doing chi^2 for now
   for(iterator itFeat = begin(); itFeat != end(); itFeat++)
   {
   double cumChi = 0.0;
   double maxChi = 0.0;
   for(iterator itTarg = (itFeat->second).concMap.begin(); itTarg !=
         (itFeat->second).concMap.end(); itTarg++)
      {
         double A,B,C,D,N, nom, denom;
         // A is count(t^c)
         A = (itTarg->second).count;
         // B is t without c
         B = ((itFeat->second).count) - A;
         // C is c without t
         TargMap::iterator targcount = targMap.find(itTarg->first);
         C = (targcount->second) - ((itTarg->second).count);
         // D is neither c nor t
         D = totalEx - (A + B + C);
         N = totalEx;
         //if( !A || !D || !C || !B)
         //   cout << "zero";
   
         double pro = (A*D - C*B);   
         //if(!(nom = (N * pro * pro)))
         //   cout << "zero";
         if(denom = ((A+C) * (B+D) * (A+B) * (C+D)))
            (itTarg->second).chi = nom / denom;
         else 
            (itTarg->second).chi = 0; 
         //cumChi += ((targcount->second / N) * ((itTarg->second).chi));
         maxChi = max(maxChi, (itTarg->second).chi);
      }
      (itFeat->second).chi = maxChi;  
      //(itFeat->second).chi_percent = chdtr(1.0, 3.54);
   }
   return true; 
}

void Stats::WriteStats(const char* outFile)
{
   ofstream outStream(outFile, ios_base::out);
   if(!outStream)
   {
      cerr << "Error opening output file" << endl;
   }
   else
   { 
      outStream.setf(ios::fixed);
     // outStream << setw(10) << "Feature"; 
     // outStream << setw(14) << "chi"
     //           << setw(10) << "count" << endl;
      for(int i=0; i < 3; i++)
      {
         switch(i)
         {
            case 0: outStream << "[chi]" << endl; break;
            case 1: outStream << "[ig]" << endl; break;
            case 2: outStream << "[mi]" << endl; break;
         }
         for(iterator itFeat = begin(); itFeat != end(); itFeat++)
         {
            // output the feature stats
            outStream << setw(10) << (itFeat->first) << "  "; 
            //outStream.setf(ios::scientific);

            double valFeat;
            switch(i)
            {
               case 0: valFeat = (itFeat->second).chi; break;
               case 1: valFeat = (itFeat->second).ig; break;
               case 2: valFeat = (itFeat->second).mi; break;
            }
            //if(!i)
            //   outStream << setprecision(4) << (itFeat->second).chi_percent;
            outStream << setprecision(8) << valFeat;
                     // << setw(8) << (itFeat->second).count << endl;

            for(TargMap::const_iterator itTarg = targMap.begin(); 
                  itTarg != targMap.end(); itTarg++)
            {
               double valTarg; 
               iterator itVal = 
                  (itFeat->second).concMap.find(itTarg->first);
               if(itVal != (itFeat->second).concMap.end())
                  switch(i)
                  {
                     case 0: valTarg = (itVal->second).chi; break;
                     case 1: valTarg = (itVal->second).ig; break;
                     case 2: valTarg = (itVal->second).mi; break;
                  }
               else
                  valTarg = 0.0;

               //outStream << setw(10) << itTarg->first << "  "
               outStream << setw(10) << setprecision(5) << valTarg;
                       //  << setw(10) << (itTarg->second).count;
            }
            outStream << endl;
         }
         outStream << endl; 
      }
   }
} 
         

void Stats::BuildCounts( FeatureSet& example )
{
   totalEx++;

   FeatureSet::iterator pFeat = example.begin(); 

   // update target information
   int Targ = *pFeat;
   TargMap::iterator targIt;
   if ((targIt = targMap.find(Targ)) != targMap.end())
      targIt->second++;
   else
      targMap[Targ] = 1;
   
   // update feature/target concurency info
   pFeat++;
   iterator fm;
   while(pFeat != example.end())
   {
      totalFe++;
      if((fm = find(*pFeat)) != end())
      {
         (fm->second).count++; 
         iterator conc; 
         if((conc = (fm->second).concMap.find(Targ)) != 
               (fm->second).concMap.end()) 
            (conc->second).count++;
         else 
         { 
            FeatureStats fs;
            fs.count = 1;
            (fm->second).concMap[Targ] = fs;
         } 
      }
      else
      {
         ConcMap newMap;
         FeatureStats ts;
         ts.count = 1;
         newMap[Targ] = ts;

         FeatureStats fs;
         fs.count = 1;
         fs.concMap = newMap;
         (*this)[*pFeat] = fs;
      }
      pFeat++;
   }
}

void Stats::FilterExamps(string exampleFile, double thresh, StatType type )
{
   ifstream exIn(exampleFile.c_str());
   
   string outFile = exampleFile + ".new";
   ofstream exOut(outFile.c_str());

   if(!exIn || !exOut)
   {
      cerr << "Error opening example file for filtering." << endl;
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
               const_iterator itMap = find(foo);
               double statValue;
               if(itMap != end()) 
               {
                  switch(type)
                  {
                     case S_CHI: 
                        statValue = (itMap->second).chi_percent;
                        break;
                     case S_IG:
                        statValue = (itMap->second).ig;
                        break;
                     case S_MI:
                        statValue = (itMap->second).mi;
                        break;
                  }
                  if(statValue >= thresh)
                     theSet.insert(foo);
               }
               else
                  theSet.insert(foo);

               exIn.get(delim); 
            }
            else
            {
               if(!exIn.eof())
               {
                  cerr << "problem" << endl;
                  exIn.close();
                  exOut.close();
                  exit(-1);
               }
            }
         } while(delim == ',');
         
         if(!exOut.fail())
         { 
            for(FeatureSet::const_iterator it = theSet.begin(); 
                  it != theSet.end(); 
                  it++)
            {
               if(it == theSet.begin())
                     exOut << *it;
               else
                     exOut << ", "<< *it; 
            }
            exOut << ":" << endl;
         }
      } 
      exIn.close();
      exOut.close();
   }
}

