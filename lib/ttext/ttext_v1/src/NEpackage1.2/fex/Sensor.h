//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Sensor.h                            		=
//=  Version: x.x                                           =
//=   Author: Scott Wen-tau Yih                             =
//=     Date: 10/29/00                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef __SENSOR_H__
#define __SENSOR_H__

#include "Fex.h"

#include <string>
#include <iostream>
#include <fstream>

using namespace std;

// Added by Scott Yih, 09/27/01
typedef enum { ST_WORD, ST_PHRASE } SensorType;

// Add SensorType --Scott Yih, 09/27/01
class Sensor
{
 public:

  // default setting
  Sensor() { includeLocation = false; sensorType = ST_WORD; }

  bool IncludeLocation()  { return includeLocation; }
  void IncludeLocation(bool val) { includeLocation = val; }
  SensorType getSensorType() { return sensorType; }

  // If the sensor is PHRASE TYPE, then the last two parameters are
  //   treated as the start and end locations of the phrase.
  virtual void Extract( Sentence &sentence,
			RawFeatureSet &outSet,
			int rec_OR_start,
			int targLoc_OR_end ) = 0;

 protected:
  void Output( RawFeatureSet &outSet, string feat, int loc);
  SensorType sensorType;

 private:
  void Locational( string& lex, int loc );
  string& PostProcess( string &feat, const char* checkFeat );
  bool includeLocation;
};

class SensorWord : public Sensor
{
	public:
		SensorWord() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorTag : public Sensor
{
	public:
		SensorTag() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorVowel : public Sensor
{
	public:
		SensorVowel() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorPre : public Sensor
{
	public:
		SensorPre() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorSuf : public Sensor
{
	public:
		SensorSuf() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorLem : public Sensor
{
	public:
		SensorLem() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorBase : public Sensor
{
	public:

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      SensorBase() : Sensor()
         {
            ifstream basetagFile("base_tags");
            if (!basetagFile)
            {
               cerr << "no base tag file" << endl;
               exit(-1);
            }
            while(!basetagFile.eof())
            {
               string word;
               string tag;
               basetagFile >> word >> tag;
               if (!basetagFile.fail())
                  baseTags.insert(pair<string, string>(word, tag));
            }
         };

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );

   private:
      StringMap baseTags;
};

class SensorRole : public Sensor
{
   public:
		SensorRole() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorPhrase : public Sensor
{
   public:
		SensorPhrase() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorTarg : public Sensor
{
	public:

		SensorTarg() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

//---Yair's additional Sensors --------------------------

class SensorCapitlized : public Sensor
{
   public:
      SensorCapitlized() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
                    int targLoc );
};

class SensorHasHyphen : public Sensor
{
   public:
      SensorHasHyphen() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
                    int targLoc);
};

class SensorTabA : public Sensor
{
	public:

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      SensorTabA() : Sensor()
         {
            ifstream tableFile("tableA");
            if (!tableFile)
            {
               cerr << "no table file" << endl;
               exit(-1);
            }
            while(!tableFile.eof())
            {
               string word;
               string item;
               tableFile >> word >> item;
               if (!tableFile.fail())
                  table.insert(pair<string, string>(word, item));
            }
         };

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );

   private:
      StringMap table;
};

class SensorTabB : public Sensor
{
	public:

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      SensorTabB() : Sensor()
         {
            ifstream tableFile("tableB");
            if (!tableFile)
            {
               cerr << "no table file" << endl;
               exit(-1);
            }
            while(!tableFile.eof())
            {
               string word;
               string item;
               tableFile >> word >> item;
               if (!tableFile.fail())
                  table.insert(pair<string, string>(word, item));
            }
         };

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );

   private:
      StringMap table;
};

class SensorTabC : public Sensor
{
	public:

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      SensorTabC() : Sensor()
         {
            ifstream tableFile("tableC");
            if (!tableFile)
            {
               cerr << "no table file" << endl;
               exit(-1);
            }
            while(!tableFile.eof())
            {
               string word;
               string item;
               tableFile >> word >> item;
               if (!tableFile.fail())
                  table.insert(pair<string, string>(word, item));
            }
         };

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
   private:
      StringMap table;
};

class SensorTabD : public Sensor
{
	public:

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      SensorTabD() : Sensor()
         {
            ifstream tableFile("tableD");
            if (!tableFile)
            {
               cerr << "no table file" << endl;
               exit(-1);
            }
            while(!tableFile.eof())
            {
               string word;
               string item;
               tableFile >> word >> item;
               if (!tableFile.fail())
                  table.insert(pair<string, string>(word, item));
            }
         };

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
   private:
      StringMap table;
};

class SensorTabE : public Sensor
{
	public:

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      SensorTabE() : Sensor()
         {
            ifstream tableFile("tableE");
            if (!tableFile)
            {
               cerr << "no table file" << endl;
               exit(-1);
            }
            while(!tableFile.eof())
            {
               string word;
               string item;
               tableFile >> word >> item;
               if (!tableFile.fail())
                  table.insert(pair<string, string>(word, item));
            }
         };

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
   private:
      StringMap table;
};

//---Vasin's additional Sensors --------------------------

class SensorInitialCapitalized : public Sensor
// on if the initial letter is captalized.
// off if empty
{
	public:

		SensorInitialCapitalized() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorNotInitialCapitalized : public Sensor
// on if the initial letter is captalized.
// off if empty
{
        public:

                SensorNotInitialCapitalized() : Sensor() {};

                bool IncludeLocation( );
                void IncludeLocation( bool val );
 
                void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};


class SensorAllCapitalized : public Sensor
// on if all letters (even there is only 1) are captalized.
// off if empty
{
	public:

		SensorAllCapitalized() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorUncapitalized : public Sensor
// on if all letters (even there is only 1) aren't captalized.
// off if empty
{
	public:

		SensorUncapitalized() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorInternalCapitalized : public Sensor
// on if there is a letter, not the initial one, is captalized.
// off if empty
{
	public:

		SensorInternalCapitalized() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

//--------------------------------------------------------------

//---Scott's additional Sensors for phrase case ----------------

class SensorPhraseLength : public Sensor
// used for generating phrase type label only
{
 public:

  SensorPhraseLength() : Sensor() { sensorType = ST_PHRASE; };

  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int start,
		int end );
};

class SensorNamedEntity : public Sensor
// used for generating phrase type label only
{
 public:

  SensorNamedEntity() : Sensor() { sensorType = ST_PHRASE; };

  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int start,
		int end );
};

class SensorChunk : public Sensor
// used for generating phrase type label only
{
 public:

  SensorChunk() : Sensor() { sensorType = ST_PHRASE; };

  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int start,
		int end );
};

//--------------------------------------------------------------

//---Scott's additional Sensors for ER case ----------------

class SensorRGFNo : public Sensor
{
 public:

  SensorRGFNo() : Sensor() { sensorType = ST_PHRASE; };

  void Extract( Sentence &sentence,
                RawFeatureSet &outSet,
                int start,
                int end );
};

class SensorEntity : public Sensor
{
	public:
		SensorEntity() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorArgument : public Sensor
{
	public:
		SensorArgument() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorVerb : public Sensor
{
	public:
		SensorVerb() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorNearestVerbWordAfter : public Sensor
{
        public:
                SensorNearestVerbWordAfter() : Sensor() {};

                bool IncludeLocation( );
                void IncludeLocation( bool val );

                void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorNearestVerbWordBefore : public Sensor
{
        public:
                SensorNearestVerbWordBefore() : Sensor() {};

                bool IncludeLocation( );
                void IncludeLocation( bool val );

                void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorBigram : public Sensor
{
        public:
                SensorBigram() : Sensor() {};

                bool IncludeLocation( );
                void IncludeLocation( bool val );

                void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorWordNum : public Sensor
{
        public:
                SensorWordNum() : Sensor() {};

                bool IncludeLocation( );
                void IncludeLocation( bool val );

                void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorWordNoDot : public Sensor
{
 public:
  SensorWordNoDot() : Sensor() {};

  bool IncludeLocation( );
  void IncludeLocation( bool val );

  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int rec,
		int targLoc );
};

class SensorWordPos : public Sensor
{
 public:
  SensorWordPos() : Sensor() {};

  bool IncludeLocation( );
  void IncludeLocation( bool val );

  void Extract( Sentence &sentence,
                RawFeatureSet &outSet,
                int rec,
                int targLoc );
};

/*  These are pretty strong sensors.
    They use a list of knowns countries, states or cities. */

#define PLACE_LIST_FN "known_place.lst"
#define COUNTRY_LIST_FN "known_country.lst"
#define STATE_LIST_FN "known_state.lst"
#define CITY_LIST_FN "known_city.lst"
#define TITLE_LIST_FN "known_title.lst"
#define NAME_LIST_FN "known_name.lst"
#define ORG_LIST_FN "org_words.lst"

enum LIST_TYPE { PLACE, COUNTRY, STATE, CITY, TITLE, NAME, ORG };
enum LIST_SEN_TYPE { IS, HAS };

class SensorList : public Sensor
{
 public:
  SensorList(LIST_TYPE listType, LIST_SEN_TYPE senType);

  bool IncludeLocation( );
  void IncludeLocation( bool val );

  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int rec,
		int targLoc );
 private:
  void SensorList::loadList(LIST_TYPE listType);
  string& outputForm(string &outStr, string &inStr);

  LIST_SEN_TYPE senType;
  set<string>* pList;

  static bool placeListLoaded;
  static set<string> place_list;
  static bool countryListLoaded;
  static set<string> country_list;
  static bool stateListLoaded;
  static set<string> state_list;
  static bool cityListLoaded;
  static set<string> city_list;
  static bool titleListLoaded;
  static set<string> title_list;
  static bool nameListLoaded;
  static set<string> name_list;
  static bool orgListLoaded;
  static set<string> org_list;
};

class SensorSemantic : public Sensor
{
        public:
                SensorSemantic();

                bool IncludeLocation( );
                void IncludeLocation( bool val );

                void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );

};

class SensorNoSemantic : public Sensor
{
        public:
                SensorNoSemantic();

                bool IncludeLocation( );
                void IncludeLocation( bool val );

                void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );

};

class SensorScaleEntityNum : public Sensor
{
 public:
  SensorScaleEntityNum() : Sensor() { sensorType = ST_PHRASE; };

  bool IncludeLocation( );
  void IncludeLocation( bool val );

  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int rec,
		int targLoc );
};

class SensorEntityNum : public Sensor
{
 public:
  SensorEntityNum() : Sensor() { sensorType = ST_PHRASE; };
  
  bool IncludeLocation( );
  void IncludeLocation( bool val );
  
  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int rec,
		int targLoc );
};

class SensorScaleElementNum : public Sensor
{
 public:
  SensorScaleElementNum() : Sensor() { sensorType = ST_PHRASE; };
  
  bool IncludeLocation( );
  void IncludeLocation( bool val );

  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int rec,
		int targLoc );
};

class SensorElementNum : public Sensor
{
 public:
  SensorElementNum() : Sensor() { sensorType = ST_PHRASE; };
  
  bool IncludeLocation( );
  void IncludeLocation( bool val );
  
  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int rec,
		int targLoc );
};

class SensorSameArg : public Sensor
{
 public:
  SensorSameArg() : Sensor() { sensorType = ST_PHRASE; };

  bool IncludeLocation( );
  void IncludeLocation( bool val );

  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int start,
		int end );
};

//--------------------------------------------------------------

class SensorPhraseAllCapital : public Sensor
{
   public:
      SensorPhraseAllCapital() : Sensor() { sensorType = ST_PHRASE; };

	  bool IncludeLocation( );
	  void IncludeLocation( bool val );

      void Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end );
};

class SensorPhraseNoSmall : public Sensor
{
 public:
  SensorPhraseNoSmall() : Sensor() { sensorType = ST_PHRASE; };

  bool IncludeLocation( );
  void IncludeLocation( bool val );

  void Extract( Sentence &sentence,
		RawFeatureSet &outSet,
		int start,
		int end );
};

class SensorPhraseAllWords : public Sensor
{
   public:
      SensorPhraseAllWords() : Sensor() { sensorType = ST_PHRASE; };

	  bool IncludeLocation( );
	  void IncludeLocation( bool val );

      void Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end );
};

class SensorPhraseAllNotNum : public Sensor
{
   public:
      SensorPhraseAllNotNum() : Sensor() { sensorType = ST_PHRASE; };

	  bool IncludeLocation( );
	  void IncludeLocation( bool val );

      void Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end );
};

class SensorToUpper : public Sensor
{
   public:
      SensorToUpper() : Sensor() {};

	  bool IncludeLocation( );
	  void IncludeLocation( bool val );

      void Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int rec,
				  int targLoc );
};

class SensorFirstWord : public Sensor
{
   public:
      SensorFirstWord() : Sensor() { sensorType = ST_PHRASE; };

	  bool IncludeLocation( );
	  void IncludeLocation( bool val );

      void Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int rec,
				  int targLoc );
};

//--------------Jakob's additional phrase sensors-------------

class SensorPhraseFirstWord : public Sensor
{
   public:
      SensorPhraseFirstWord() : Sensor() { sensorType = ST_PHRASE; };

	  bool IncludeLocation( );
	  void IncludeLocation( bool val );

      void Extract( Sentence &sentence,
				  RawFeatureSet &outSet,
				  int start,
				  int end );
};

class SensorPhraseLastWord : public Sensor
{
   public:
      SensorPhraseLastWord() : Sensor() { sensorType = ST_PHRASE; };
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorPhraseFirstTag : public Sensor
{
   public:
      SensorPhraseFirstTag() : Sensor() { sensorType = ST_PHRASE; };
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorPhraseLastTag : public Sensor
{
   public:
      SensorPhraseLastTag() : Sensor() { sensorType = ST_PHRASE; };
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorPhrasePercent : public Sensor
{
   public:
      SensorPhrasePercent() : Sensor() { sensorType = ST_PHRASE; };
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorPhrasePosition : public Sensor
{
   public:
      SensorPhrasePosition() : Sensor() { sensorType = ST_PHRASE; };
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorSentenceLength : public Sensor
{
   public:
      SensorSentenceLength() : Sensor() { sensorType = ST_PHRASE; };
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorIsPerson : public Sensor
{
   public:
  SensorIsPerson();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorIsFirstWord : public Sensor
{
   public:
      SensorIsFirstWord() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
                    int targLoc);
};

class SensorHasDigit : public Sensor
{
   public:
      SensorHasDigit() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
                    int targLoc);
};

class SensorAllDigit : public Sensor
{
   public:
      SensorAllDigit() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
                    int targLoc);
};

class SensorAlphaNumeric : public Sensor
{
   public:
      SensorAlphaNumeric() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
                    int targLoc);
};

class SensorRomanNum : public Sensor
{
   public:
      SensorRomanNum() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
                    int targLoc);
};

class SensorPrefix2 : public Sensor
{
   public:
      SensorPrefix2() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorPrefix3 : public Sensor
{
   public:
      SensorPrefix3() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorPrefix4 : public Sensor
{
   public:
      SensorPrefix4() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorSuffix2 : public Sensor
{
   public:
      SensorSuffix2() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorSuffix3 : public Sensor
{
   public:
      SensorSuffix3() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorSuffix4 : public Sensor
{
   public:
      SensorSuffix4() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorLength : public Sensor
{
   public:
      SensorLength() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorHasPM : public Sensor
{
   public:
      SensorHasPM() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorHyphenCase : public Sensor
{
   public:
      SensorHyphenCase() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorCharPattern : public Sensor
{
   public:
      SensorCharPattern() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorInQuotePar : public Sensor
{
   public:
      SensorInQuotePar() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorFrequentWord : public Sensor
{
   public:
  SensorFrequentWord();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorFunctionalWord : public Sensor
{
   public:
  SensorFunctionalWord();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorNEunigramPre : public Sensor
{     
   public:
  SensorNEunigramPre();
  
          bool IncludeLocation( );
          void IncludeLocation( bool val );
 
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorZone : public Sensor
{
	public:
		SensorZone() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorNCS : public Sensor
{
   public:
  SensorNCS();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorNEPrebigram : public Sensor
{
   public:
  SensorNEPrebigram();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorNEsuffix : public Sensor
{
   public:
  SensorNEsuffix();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorNEotherBI : public Sensor
{
   public:
  SensorNEotherBI();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorNEotherNCS : public Sensor
{
   public:
  SensorNEotherNCS();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorOtherInitCap : public Sensor
{
   public:
		SensorOtherInitCap() : Sensor() {};
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};


class SensorPartOfAcronym : public Sensor
{
   public:
  SensorPartOfAcronym();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorNEotherUNI : public Sensor
{
   public:
  SensorNEotherUNI();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorIcapSubSequence : public Sensor
{
   public:
  SensorIcapSubSequence();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorNEotherLabel : public Sensor
{
   public:
      SensorNEotherLabel() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorFirstColumn : public Sensor
{
   public:
      SensorFirstColumn() : Sensor() {};
 
                bool IncludeLocation( );
		void IncludeLocation( bool val );
  
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
		int targLoc);
};

class SensorSecondColumn : public Sensor
{
   public:
      SensorSecondColumn() : Sensor() {};
                
                bool IncludeLocation( );
                void IncludeLocation( bool val );
                    
      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
                int targLoc);
};


class SensorHTML : public Sensor
{
	public:
		SensorHTML() : Sensor() {};

		bool IncludeLocation( );
		void IncludeLocation( bool val );

		void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorNERlist : public Sensor
{
   public:
  SensorNERlist();
      
          bool IncludeLocation( );
          void IncludeLocation( bool val );
                                  
      void Extract( Sentence &sentence,
                                  RawFeatureSet &outSet,
                                  int start,
                                  int end );
};

class SensorWordUpper : public Sensor
{
        public:
                SensorWordUpper() : Sensor() {};

                bool IncludeLocation( );
                void IncludeLocation( bool val );

                void Extract( Sentence &sentence,
                    RawFeatureSet &outSet,
                    int rec,
                    int targLoc );
};

class SensorSuffix1 : public Sensor
{
   public:
      SensorSuffix1() : Sensor() {};

                bool IncludeLocation( );
                void IncludeLocation( bool val );

      void Extract( Sentence &sentence, RawFeatureSet &outSet, int rec,
                int targLoc);
};


#endif
