//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: TargetIdSet.cpp                               =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#include "TargetIdSet.h"
#include <iostream>
#include <string>
#include <algorithm>

// Show() - outputs contiguous ranges in the TargetIdSet

void TargetIdSet::Show(ostream* out)
{
  // set range start and end to first element
  const_iterator it = begin();
  const_iterator end = this->end();
  FeatureID rangeStart = *it;
  FeatureID rangeEnd = *it;

  while (it != end)
  {
    ++it;
    if ((it != end) && (*it == rangeEnd + 1)) ++rangeEnd;
    else
    {
      if (rangeStart == rangeEnd)
      {
        *out << rangeStart;
        if (it != end)
        {
          *out << ", ";
          rangeStart = *it;
          rangeEnd = *it;
        }
      }
      else
      {
        *out << rangeStart << "-" << rangeEnd;
        if (it != end)
        {
          *out << ", ";
          rangeStart = *it;
          rangeEnd = *it;
        }
      }
    }
  }
}


bool TargetIdSet::Parse( const char* in )
{
  string temp;
  bool result = true;

  clear();

  try
  {
    string work(in);
    if (work.size() == 0)
    {
      temp = "No target IDs found in target ID specification.\n";
      throw temp.c_str();
    }

    FeatureID l, h;
    char* pDelim, delim;

    do
    {
      l = strtoul(work.c_str(), &pDelim, 10);
      // Did some conversion take place?
      if (pDelim != work.c_str())
      {
        // Is this a range or single ID?
        if (*pDelim == '-')
        {
          work = string(pDelim + 1);
          h = strtoul(work.c_str(), &pDelim, 10);
          if (pDelim == work.c_str())
          {
            temp = "Problem found parsing target ID specification: '";
            temp += in;
            temp += "'";
            throw temp.c_str();
          }
        } else h = l;

        while (l <= h)
        {
          insert(l);
          ++l;
        }

        // Save delim and update work
        delim = *pDelim;
        work = string(pDelim + 1);
      }
      else
      {
        temp = "Problem found parsing target ID specification: '";
        temp += in;
        temp += "'";
        throw temp.c_str();
      }
    } while (delim == ',');
  }
  catch( const char* error )
  {
    cerr << error << endl;
    result = false;
  }

  return result;
}

