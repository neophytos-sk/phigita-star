//===========================================================
//=     University of Illinois at Urbana-Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: SNoW                                          =
//=                                                         =
//=   Module: Example.cpp                                   =
//=  Version: 3.1.4                                         =
//=  Authors: Jeff Rosen, Andrew Carlson, Nick Rizzolo      =
//=     Date: xx/xx/99                                      = 
//=                                                         =
//===========================================================

#include "Example.h"
#include "GlobalParams.h"
#include <algorithm>

FeatureArray::FeatureArray(const FeatureArray& f)
  : targets(f.targets), size(f.size), max_size(f.max_size),
    globalParams(f.globalParams)
{
  array = new FeatureArrayEntry[max_size];
  for (int i = 0; i < size; ++i) array[i] = f.array[i];
}


FeatureArray FeatureArray::operator=(const FeatureArray& f)
{
  globalParams = f.globalParams;
  targets = f.targets;
  size = f.size;
  max_size = f.max_size;
  array = new FeatureArrayEntry[max_size];
  for (int i = 0; i < size; ++i) array[i] = f.array[i];

  return f;
}


bool FeatureArray::insert(FeatureID id, double s)
{
  int j;
  //for (j = 0; j < size; ++j) if (array[j].id == id) return false;

  if (size == max_size)
  {
    max_size *= 2;
    FeatureArrayEntry* temp = new FeatureArrayEntry[max_size];
    for (j = 0; j < size; ++j) temp[j] = array[j];
    delete [] array;
    array = temp;
  }

  array[size].id = id;
  array[size].strength = s;
  ++size;

  return true;
}


bool FeatureArray::insert_labeled(FeatureID id, double s,
                                  bool strengthIsDefault)
{
  int j;
  //for (j = 0; j < size; ++j) if (array[j].id == id) return false;

  if (size == max_size)
  {
    max_size *= 2;
    FeatureArrayEntry* temp = new FeatureArrayEntry[max_size];
    for (j = 0; j < size; ++j) temp[j] = array[j];
    delete [] array;
    array = temp;
  }

  j = size;
  if (globalParams.targetIds.find(id) != globalParams.targetIds.end())
  {
    j = targets++;
    array[size] = array[j];

    if (globalParams.gradientDescent && strengthIsDefault)
      array[j].strength = id;
    else array[j].strength = s;
  }
  else array[j].strength = s;

  array[j].id = id;
  ++size;

  return true;
}


int FeatureArray::find(FeatureID id)
{
  for (int i = 0; i < size; ++i) if (array[i].id == id) return i;
  return -1;
}


int FeatureArray::find_target(FeatureID id)
{
  for (int i = 0; i < targets; ++i) if (array[i].id == id) return i;
  return -1;
}


void FeatureArray::free_unused_space()
{
  if (size == max_size) return;
  if (size == 0)
  {
    delete [] array;
    array = NULL;
  }
  else
  {
    max_size = size;
    FeatureArrayEntry* temp = new FeatureArrayEntry[size];
    for (int i = 0; i < size; ++i) temp[i] = array[i];
    delete [] array;
    array = temp;
  }
}

Example::Example( const Example & e ) :
  globalParams(e.globalParams), features(e.features)
{
  command = e.command;
  targets = e.targets;
}


Example & Example::operator=( const Example & rhs ) {
  if( this != &rhs ){
    globalParams = rhs.globalParams;
    command = rhs.command;
    features = rhs.features;
    targets = rhs.targets;
  }
  return *this;
}


bool Example::FeatureIsLabel( FeatureID feature )
{
  int i;
  for (i = 0; i < features.Targets() && feature != features[i].id
              && globalParams.multipleLabels; ++i);
  return i < features.Targets() && feature == features[i].id;
}


void Example::Show(ostream* out)
{
  for (int i = 0; i < features.Size(); ++i)
  {
    *out << features[i].id << '(' << features[i].strength << ')';
    if (i < features.Size() - 1) *out << ", ";
  }

  *out << ":\n";
}


bool Example::Parse( string& in )
{
  features.clear();

  string work(in);
  FeatureID f;
  char* pDelim;

  if (globalParams.fixedFeature) features.insert(FIXED_FEATURE_ID, 1.0);

  do
  {
    f = strtoul(work.c_str(), &pDelim, 10);
    if (pDelim != work.c_str())
    {
      double strength = 1.0;
      if (*pDelim == '(')
      {
        strength = strtod(pDelim + 1, &pDelim);
        ++pDelim; // skip )
      }

      features.insert(f, strength);

      /* Currently, the insert function does not check for duplicate features.
      if (!features.insert(f, strength))
        cerr << "Duplicate feature (" << f << ") found!\n";
      */

      work = string(pDelim + 1);
    } 
    else
    {
      cerr << "\nProblem found parsing example: '" << in.c_str() << "'\n";
      return false;
    }
  } while ((*pDelim == ',') || (*pDelim == ';'));

  return true;    
}


// adds conjunctions of all active features to the example
void Example::GenerateConjunctions()
{
  // create a set with all active features
  // The array below used to be implemented as a set<>.  Should be more
  // efficient this way.
  FeatureID* featureSet = new FeatureID[features.Size()];
  int featureSetSize = 0, i;

  for (i = 0; i < features.Size(); ++i)
  {
    if (globalParams.targetIds.find(features[i].id)
          == globalParams.targetIds.end()
        && features[i].id != FIXED_FEATURE_ID)
      featureSet[featureSetSize++] = features[i].id;
  }

  // add conjunctions into the map of features
  for (i = 0; i < featureSetSize - 1; ++i)
  {
    for (int j = i + 1; j < featureSetSize; ++j)
      features.insert(10000 * featureSet[i] + featureSet[j], 1.0);
  }

  delete [] featureSet;
}


bool Example::Read(istream& in)
{
  features.clear();
  targets.clear();

  FeatureID f;
  char delim;

  // add the fixed feature
  if (globalParams.fixedFeature) features.insert(FIXED_FEATURE_ID, 1.0);

  // read the command if it's interactive mode
  if (globalParams.runMode == MODE_INTERACTIVE
      || globalParams.runMode == MODE_INTERACTIVESERVER) {
    in >> command; 

    if ((command != 'e' && command != 'p' && command != 'd') ||
        (in.fail())) 
    {
      command = '\0';
      if (!in.eof())
      {
        cerr << "\nProblem found in input file: '"
             << globalParams.inputFile.c_str()
             << "'; Ignoring rest of line...\n";
	   
        in.clear();
        in.get(delim);
        while (!in.eof() && (delim != '\n'))
        {
          cerr.put(delim);
          in.get(delim);
        }
        cerr << "\n\n";
      }
    }
    else {
      // drop any characters until it encounters a whitespace or eol
      while (!in.eof()) {
	in.get(delim);
	if (delim == ',')
	  break;
      }
    }
  }

  // read features
  do
  {
    in >> f;
    
    if (!in.fail())
    {
      in.get(delim);
      double strength = 1.0;
      if (delim == '(') // set strength
      {
        in >> strength;
        if (in.fail()) goto inerror;
        in.get(delim); // skip )
        in.get(delim); // skip ,
      }

      features.insert(f, strength);

      /* Currently, the insert function does not check for duplicate features.
      if (!features.insert(f, strength))
        cerr << "Duplicate feature (" << f << ") found!\n";
      */
    } 
    else
    {
inerror:
      if (!in.eof())
      {
        cerr << "\nProblem found in input file: '"
             << globalParams.inputFile.c_str()
             << "'; Ignoring rest of line...\n";
        in.clear();
        in.get(delim);
        while (!in.eof() && (delim != '\n'))
        {
          cerr.put(delim);
          in.get(delim);
        }
        cerr << "\n\n";
      }
    }
  } while (delim == ',');

  // read targets (if they're there)
  if (delim == ';')
  {
    do 
    {
      in >> f;

      if (!in.fail())
      {
        in.get(delim);
        targets.insert(f);
      }
      else
      {
        if (!in.eof())
        {
          in.clear();
          in.get(delim);
          if (delim != ':')
          {
            cerr << "\nProblem found in input file: '"
                 << globalParams.inputFile.c_str()
                 << "'; Ignoring rest of line...\n";
            while (!in.eof() && (delim != '\n'))
            {
              cerr.put(delim);
              in.get(delim);
            }
            cerr << "\n\n";
          }
        }
      }
    } while (delim == ',');
  }

  return !in.eof();
}


bool Example::ReadLabeled(istream& in)
{
  features.clear();
  targets.clear();

  FeatureID f;
  char delim;

  if (globalParams.fixedFeature) features.insert(FIXED_FEATURE_ID, 1.0);

  do
  {
    in >> f;

    if (!in.fail())
    {
      in.get(delim);

      if (delim == '(') // set strength
      {
        double strength;
        in >> strength;
        if (in.fail()) goto inerror;
        features.insert_labeled(f, strength, false);
        in.get(delim); // skip )
        in.get(delim); // skip ,
      }
      else features.insert_labeled(f, 1.0, true);

      /* Currently, the insert_labeled function does not check for duplicate
       * features.
      if (!features.insert_labeled(f, strength))
        cerr << "Duplicate feature (" << f << ") found!\n";
      */
    } 
    else
    {
inerror:
      if (!in.eof())
      {
        cerr << "\nProblem found in input file: '"
             << globalParams.inputFile.c_str()
             << "'; Ignoring rest of line...\n";
        in.clear();
        in.get(delim);
        while (!in.eof() && (delim != '\n'))
        {
          cerr.put(delim);
          in.get(delim);
        }
        cerr << "\n\n";
      }
    }
  } while (delim == ',');


  // read targets (if they're there)
  if (delim == ';')
  {
    do 
    {
      in >> f;

      if (!in.fail())
      {
        in.get(delim);
        targets.insert(f);
      }
      else
      {
        if (!in.eof())
        {
          in.clear();
          in.get(delim);
          if (delim != ':')
          {
            cerr << "\nProblem found in input file: '"
                 << globalParams.inputFile.c_str()
                 << "'; Ignoring rest of line...\n";
            while (!in.eof() && (delim != '\n'))
            {
              cerr.put(delim);
              in.get(delim);
            }
            cerr << "\n\n";
          }
        }
      }
    } while (delim == ',');
  }

  return !in.eof();
}


#if defined(FEATURE_HASH) && !defined(WIN32)
bool Example::ReadFeatureSet( hash_set<FeatureID> &featureSet,
                              FeatureID &max_id )
#else
void Example::ReadFeatureSet( set<FeatureID> &featureSet, FeatureID &max_id )
#endif
{
  int i, size = features.Size() - ((globalParams.fixedFeature) ? 1 : 0);

  // I know - this looks dumb.  But I'm going for maximum efficiency.
  //  - Nick

  // We're guaranteed that one of the following two conditions will hold.
  // (See this function's only call site - it's in Snow.cpp)
  if (globalParams.generateConjunctions != CONJUNCTIONS_OFF
      && globalParams.calculateExampleSize)
  {
    if (globalParams.fixedFeature)
    {
      for (i = 0; features[i].id != FIXED_FEATURE_ID; ++i)
      {
        if (features[i].id > max_id) max_id = features[i].id;
        featureSet.insert(features[i].id);
      }

      ++i;
    }
    else i = 0;

    for (; i < features.Size(); ++i)
    {
      if (features[i].id > max_id) max_id = features[i].id;
      featureSet.insert(features[i].id);
    }

#ifdef AVERAGE_EXAMPLE_SIZE
    globalParams.averageExampleSize += size;
#else
    if (size > globalParams.maxExampleSize)
      globalParams.maxExampleSize = size;
#endif
  }
  else if (globalParams.generateConjunctions != CONJUNCTIONS_OFF)
  {
    if (globalParams.fixedFeature)
    {
      for (i = 0; features[i].id != FIXED_FEATURE_ID; ++i)
      {
        if (features[i].id > max_id) max_id = features[i].id;
        featureSet.insert(features[i].id);
      }

      ++i;
    }
    else i = 0;

    for (; i < features.Size(); ++i)
    {
      if (features[i].id > max_id) max_id = features[i].id;
      featureSet.insert(features[i].id);
    }
  }
  else
  {
#ifdef AVERAGE_EXAMPLE_SIZE
    globalParams.averageExampleSize += size;
#else
    if (size > globalParams.maxExampleSize)
      globalParams.maxExampleSize = size;
#endif
  }
}


void Example::Write( ofstream& out )
{
  int i;

  if (features.Size())
  {
    for (i = 0; features[i].id == FIXED_FEATURE_ID && i < features.Size();
         ++i);
    if (i < features.Size())
      out << features[i].id << "(" << features[i].strength << ")";
  }

  for (++i; i < features.Size(); ++i)
  {
    if (features[i].id != FIXED_FEATURE_ID)
      out << ", " << features[i].id << "(" << features[i].strength << ")";
  }

  out << ":\n";
}

