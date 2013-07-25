// -*-c++-*-
//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: RGF.h                                    =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================

/* $Id: RGF.h,v 1.13 2003/05/21 19:17:54 cumby Exp $ */

#ifndef __RGF_H__
#define __RGF_H__

#include <string>
#include <vector>
#include "Fex.h"
#include "Lexicon.h"
#include "Sensor.h"

using namespace std;

struct RGF;

typedef enum {EXTRACT_LABEL, EXTRACT_CONJ, EXTRACT_DISJ, EXTRACT_COLOC,
                EXTRACT_SCOLOC, EXTRACT_LINK, EXTRACT_SENSOR, 
                EXTRACT_NOT, EXTRACT_CONJUNCT, EXTRACT_DISJUNCT } ExtractMode;

typedef enum {TARGET_NULL = -2, TARGET_ALL = -1} TargetConstants;
const int RANGE_ALL = 1000000;

typedef vector<RGF> SubRGF;

struct RGF
{
public:
   // default constructor
   RGF();

   // constructor for sensors
   RGF(char* sensorName);

   // constructor for complex relations
   RGF( SubRGF& subR );

   // destructor for RGF
   ~RGF();

	// These are bogus prototypes (no implementation exists) because the
	// Visual C++ 5.0 STL implelmentation is broken.
	bool		      operator==( const RGF& rhs ) const;
	bool		      operator<=( const RGF& rhs ) const;
	bool		      operator<( const RGF& rhs ) const;
	bool		      operator>( const RGF& rhs ) const;
	bool		      operator>=( const RGF& rhs ) const;

   RawFeatureSet  Extract( Sentence& sentence, int targIndex );
   // New Extract used for phrase case
   // Added by Scott Yih, 09/25/01
   RawFeatureSet  Extract( Sentence& sentence, int targIndex, int targLength );
   // Another new Extract; used for ER:Relation case
   // Added by Scott Yih, 01/09/02
   RawFeatureSet  ExtractRelation ( Sentence& sentence, RelationInSentence& relSent, int posArg1, int posArg2 );

   int            TargetIndex() { return targetIndex; }
   void           Target(char* targ);                     // set target
   const char*    Target() const { return target; }       // return target
   void           IncludeLocation(bool val);
   void           LocationOffset(int val);
   int            LocationOffset() const { return locationOffset; }
   void           LeftOffset(int val) { leftOffset = val; }
   int            LeftOffset() const { return leftOffset; }
   void           RightOffset(int val);
   int            RightOffset() const { return rightOffset; }
   void           IncludeTarget(bool val) { includeTarget = val;}
   void           IncludeTargetRecur(bool val);
   bool           IncludeTarget() const { return includeTarget; }
   void           IncludeMark(bool val);
   bool           IncludeMark() const { return includeMark; }
   void           Mode(ExtractMode mode);
   ExtractMode    Mode()                 { return extractMode; }
   void           Mask(char* val) { mask = val; }
   char*          Mask() { return mask; }
   void           Param(char* val);
   const char*    Param() {return optParam;}
   void           GenFeature(bool val) { genFeature = val; }
   void           Insert(RGF rel) { subRGFs.push_back(rel); }

   // Show internal state of RGF
	void		      Show();

protected:
  SubRGF             subRGFs;
  char*              optParam;
  bool               includeTarget;
  bool includeMark;
  int		          targetIndex;
  int		          leftOffset;
  int		          rightOffset;
  int		          locationOffset;
  ExtractMode	       extractMode;
  char* 		       target;
  char*              mask;
  bool               genFeature;
  Sensor             *pSensor;

  // Feature extraction functions
  RawFeatureSet Process( Sentence& sentence,
			 int rec,
			 int targIndex,
			 int start,
			 int end);

};

#endif

