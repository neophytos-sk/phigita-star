// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Example.h                                     =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//===========================================================

#ifndef EXAMPLE_H__
#define EXAMPLE_H__

#include "TargetIdSet.h"
#include "SnowTypes.h"
#include <string>
#include <iostream>
#include <fstream>
#if defined(FEATURE_HASH) && !defined(WIN32)
#include <hash_set>
#else
#include <set>
#endif

class GlobalParams;

using namespace std;

class FeatureArrayEntry
{
  public:
    FeatureID id;
    double strength;
};


class FeatureArray
{
  public:
    FeatureArray(GlobalParams & gp_) : 
      max_size(32), globalParams(gp_) { }

    FeatureArray(int s, GlobalParams & gp_) : 
      targets(0), size(0), max_size(s), globalParams(gp_)
    { array = new FeatureArrayEntry[max_size]; }
    FeatureArray(const FeatureArray& f);
    FeatureArray operator=(const FeatureArray& f);
    ~FeatureArray() { if (array) delete [] array; }

    int Size() { return size; }
    int Targets() { return targets; }
    bool insert(FeatureID i, double s);
    bool insert_labeled(FeatureID i, double s, bool strengthIsDefault);
    bool empty() { return size == 0; }
    void clear() { size = targets = 0; }
    int find(FeatureID id);
    int find_target(FeatureID id);
    void free_unused_space();
    FeatureArrayEntry operator[](int i) { return array[i]; }

  private:
    FeatureArrayEntry* array;
    int targets;
    int size;
    int max_size;

    GlobalParams & globalParams;

};



class Example
{
  public:
    Example( GlobalParams & gp_ );
    Example( int array_size, GlobalParams & gp_ );

    Example( const Example & e );

    Example & operator=( const Example & rhs );

    bool Insert( FeatureID id, double strgth = 1.0 );
    void Erase();

    void GenerateConjunctions();

    // Feature access
    bool HasFeature( FeatureID id );
    bool HasTarget( FeatureID id );   // For determining external activation.
    // For determining correctness of predictions.
    bool FeatureIsLabel( FeatureID feature );

    // Information and debugging support
    void Show(ostream*);

    bool Parse( string& in );

    // Example persistence
    bool Read( istream& in );
    bool ReadLabeled( istream& in );
#if defined(FEATURE_HASH) && !defined(WIN32)
    bool ReadFeatureSet( hash_set<FeatureID> &featureSet, FeatureID &max_id);
#else
    void ReadFeatureSet( set<FeatureID> &featureSet, FeatureID &max_id);
#endif
    void Write( ofstream& out );

    char command;  // for interactive mode only
    FeatureArray features;
    TargetIdSet targets;

  GlobalParams & globalParams;
};

inline Example::Example(GlobalParams & gp_) :
  features(32, gp_), globalParams(gp_) 
{}

inline Example::Example(int array_size, GlobalParams & gp_) :
  features(array_size, gp_), globalParams(gp_)
{}

inline bool Example::Insert( FeatureID id, double strgth )
{
  return features.insert(id, strgth);
}

inline void Example::Erase()
{
  features.clear();
}

inline bool Example::HasFeature( FeatureID id )
{
  return features.find(id) != -1;
}

inline bool Example::HasTarget( FeatureID id )
{
  return features.find_target(id) != -1;
}

#endif

