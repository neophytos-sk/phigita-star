//-*-c++-*-
//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: RGF.cpp                                       =
//=   Version: 2.0                                          =
//=   Author: Chad Cumby                                    =
//=     Date: xx/xx/00                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================

/* $Id: RGF.cpp,v 1.65 2003/12/14 01:46:57 yih Exp $ */

#include "RGF.h"
#include "Sensor.h"
#include "GlobalParams.h"

#include <stdlib.h>
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

// extern "C" {
//#include "./wn/wn.h"
// }

#ifndef WIN32
#define strnicmp strncasecmp
#endif

/*
#ifndef WIN32
#include <minmax.h>
#else
#define min(x,y) ((x)<(y) ? x : y)
#define max(x,y) ((x)>(y) ? x : y)
#endif
*/

const char TARGET_STRING[] = "*";
const char TARGET_CHAR = '*';
const char FILLER_STRING[] = "_";
const char FILLER_CHAR = '_';
const char POS_STRING[] = "+";


/*****RGF Setup*****/

RGF::RGF() :
      subRGFs(SubRGF()),
      extractMode(EXTRACT_SENSOR),
                targetIndex(TARGET_NULL),
                leftOffset(-1),
                rightOffset(-1),
      genFeature(false),
      optParam(NULL),
      locationOffset(0),
      includeTarget(false),
      includeMark(false),
      mask(NULL),
      target(NULL),
      pSensor(NULL)
{};

/**********SENSOR REGISTRATION SECTION!!!!********/
/*THIS IS WHERE YOU NEED TO REGISTER YOUR SENSOR */
/*************************************************/
RGF::RGF(char* sensorName) :
      subRGFs(SubRGF()),
      extractMode(EXTRACT_SENSOR),
                targetIndex(TARGET_NULL),
                leftOffset(-1),
                rightOffset(-1),
      genFeature(false),
      optParam(NULL),
      locationOffset(0),
      includeTarget(false),
      includeMark(false),
      mask(sensorName),
      target(NULL)
{
   if(!strcmp (sensorName, "w"))
     pSensor = new SensorWord();
   else
     if(!strcmp (sensorName, "t"))
        pSensor = new SensorTag();
   else
     if(!strcmp (sensorName, "phr"))
        pSensor = new SensorPhrase();
   else
     if(!strcmp (sensorName, "r"))
        pSensor = new SensorRole();
   else
     if(!strcmp (sensorName, "pre"))
        pSensor = new SensorPre();
   else
     if(!strcmp (sensorName, "suf"))
        pSensor = new SensorSuf();
   else
     if(!strcmp (sensorName, "base"))
        pSensor = new SensorBase();
   else
     if(!strcmp (sensorName, "lem"))
        pSensor = new SensorLem();
   else
     if(!strcmp (sensorName, "v"))
        pSensor = new SensorVowel();
   else
     if(!strcmp (sensorName, "targ"))
        pSensor = new SensorTarg();
   else
     if(!strcmp (sensorName, "cap"))
        pSensor = new SensorCapitlized();
   else
     if(!strcmp (sensorName, "hasHyp"))
        pSensor = new SensorHasHyphen();
   else
     if(!strcmp (sensorName, "tabA"))
        pSensor = new SensorTabA();
   else
     if(!strcmp (sensorName, "tabB"))
        pSensor = new SensorTabB();
   else
     if(!strcmp (sensorName, "tabC"))
        pSensor = new SensorTabC();
   else
     if(!strcmp (sensorName, "tabD"))
        pSensor = new SensorTabD();
   else
     if(!strcmp (sensorName, "tabE"))
        pSensor = new SensorTabE();
   else
     if(!strcmp (sensorName, "icap"))
        pSensor = new SensorInitialCapitalized();
   else
     if(!strcmp (sensorName, "nicap"))
        pSensor = new SensorNotInitialCapitalized();
   else
     if(!strcmp (sensorName, "acap"))
        pSensor = new SensorAllCapitalized();
   else
     if(!strcmp (sensorName, "incap"))
        pSensor = new SensorInternalCapitalized();
   else
     if(!strcmp (sensorName, "uncap"))
        pSensor = new SensorUncapitalized();
   else
     if(!strcmp (sensorName, "phLen"))
       pSensor = new SensorPhraseLength();
   else
     if(!strcmp (sensorName, "phNE"))
       pSensor = new SensorNamedEntity();
   else
     if(!strcmp (sensorName, "phChunk"))
       pSensor = new SensorChunk();
   else
     if(!strcmp (sensorName, "rgfOne"))
       pSensor = new SensorRGFNo();
   else
     if(!strcmp (sensorName, "rgfTwo"))
       pSensor = new SensorRGFNo();
   else
     if(!strcmp (sensorName, "rgfThree"))
       pSensor = new SensorRGFNo();
   else
     if(!strcmp (sensorName, "rgfFour"))
       pSensor = new SensorRGFNo();
   else
     if(!strcmp (sensorName, "rgfFive"))
       pSensor = new SensorRGFNo();
   else
     if(!strcmp (sensorName, "rgfSix"))
       pSensor = new SensorRGFNo();
   else
     if(!strcmp (sensorName, "rgfSeven"))
       pSensor = new SensorRGFNo();
   else
     if(!strcmp (sensorName, "rgfEight"))
       pSensor = new SensorRGFNo();
   else
     if(!strcmp (sensorName, "rgfNine"))
       pSensor = new SensorRGFNo();
   else
     if(!strcmp (sensorName, "ent"))
       pSensor = new SensorEntity();
   else
     if(!strcmp (sensorName, "arg"))
       pSensor = new SensorArgument();
   else
     if(!strcmp (sensorName, "verb"))
       pSensor = new SensorVerb();
   else
     if(!strcmp (sensorName, "An_verb_w"))
       pSensor = new SensorNearestVerbWordAfter();
   else
     if(!strcmp (sensorName, "Bn_verb_w"))
       pSensor = new SensorNearestVerbWordBefore();
   else
     if(!strcmp (sensorName, "bigram"))
       pSensor = new SensorBigram();
   else
     if(!strcmp (sensorName, "numW"))
       pSensor = new SensorWordNum();
   else
     if(!strcmp (sensorName, "wN"))
       pSensor = new SensorWordNoDot();
   else
     if(!strcmp (sensorName, "wPos"))
       pSensor = new SensorWordPos();
   else
     if(!strcmp (sensorName, "isPlace"))
       //pSensor = new SensorIsKnownPlace();
       pSensor = new SensorList(PLACE, IS);
   else
     if(!strcmp (sensorName, "hasPlace"))
       //pSensor = new SensorContainKnownPlace();
       pSensor = new SensorList(PLACE, HAS);
   else
     if(!strcmp (sensorName, "isCountry"))
       //pSensor = new SensorIsKnownCountry();
       pSensor = new SensorList(COUNTRY, IS);
   else
     if(!strcmp (sensorName, "hasCountry"))
       //pSensor = new SensorContainKnownCountry();
       pSensor = new SensorList(COUNTRY, HAS);
   else
     if(!strcmp (sensorName, "isState"))
       //pSensor = new SensorIsKnownState();
       pSensor = new SensorList(STATE, IS);
   else
     if(!strcmp (sensorName, "hasState"))
       //pSensor = new SensorContainKnownState();
       pSensor = new SensorList(STATE, HAS);
   else
     if(!strcmp (sensorName, "isCity"))
       //pSensor = new SensorIsKnownCity();
       pSensor = new SensorList(CITY, IS);
   else
     if(!strcmp (sensorName, "hasCity"))
       //pSensor = new SensorContainKnownCity();
       pSensor = new SensorList(CITY, HAS);
   else
     if(!strcmp (sensorName, "isTitle"))
       //pSensor = new SensorIsKnownTitle();
       pSensor = new SensorList(TITLE, IS);
   else
     if(!strcmp (sensorName, "hasTitle"))
       //pSensor = new SensorContainKnownTitle();
       pSensor = new SensorList(TITLE, HAS);
   else
     if(!strcmp (sensorName, "isName"))
       //pSensor = new SensorIsKnownName();
       pSensor = new SensorList(NAME, IS);
   else
     if(!strcmp (sensorName, "hasName"))
       //pSensor = new SensorContainKnownName();
       pSensor = new SensorList(NAME, HAS);
   else
     if(!strcmp (sensorName, "isOrg"))
       pSensor = new SensorList(ORG, IS);
   else
     if(!strcmp (sensorName, "hasOrg"))
       pSensor = new SensorList(ORG, HAS);
   else
     if(!strcmp (sensorName, "sem"))
       pSensor = new SensorSemantic();
   else
     if(!strcmp (sensorName, "noSem"))
       pSensor = new SensorNoSemantic();
   else
     if(!strcmp (sensorName, "sNumEnt"))
       pSensor = new SensorScaleEntityNum();
   else
     if(!strcmp (sensorName, "numEnt"))
       pSensor = new SensorEntityNum();
   else
     if(!strcmp (sensorName, "sNumElem"))
       pSensor = new SensorScaleElementNum();
   else
     if(!strcmp (sensorName, "numElem"))
       pSensor = new SensorElementNum();
   else
     if(!strcmp (sensorName, "sameArg"))
       pSensor = new SensorSameArg();
   else
     if(!strcmp (sensorName, "phAllCap"))
       pSensor = new SensorPhraseAllCapital();
   else
     if(!strcmp (sensorName, "phNoSmall"))
       pSensor = new SensorPhraseNoSmall();
   else
     if(!strcmp (sensorName, "phAllWord"))
       pSensor = new SensorPhraseAllWords();
   else
     if(!strcmp (sensorName, "phAllNotNum"))
       pSensor = new SensorPhraseAllNotNum();
   else
     if(!strcmp (sensorName, "toUpper"))
       pSensor = new SensorToUpper();
   else
     if(!strcmp (sensorName, "firstW"))
       pSensor = new SensorFirstWord();
   else
     if(!strcmp (sensorName, "phFirstWord"))
       pSensor = new SensorPhraseFirstWord();
   else
     if(!strcmp (sensorName, "phLastWord"))
       pSensor = new SensorPhraseLastWord();
   else
     if(!strcmp (sensorName, "phFirstTag"))
       pSensor = new SensorPhraseFirstTag();
   else
     if(!strcmp (sensorName, "phLastTag"))
       pSensor = new SensorPhraseLastTag();
   else
     if(!strcmp (sensorName, "phPercent"))
       pSensor = new SensorPhrasePercent();
   else
     if(!strcmp (sensorName, "phPos"))
       pSensor = new SensorPhrasePosition();
   else
     if(!strcmp (sensorName, "sentLength"))
       pSensor = new SensorSentenceLength();
   else	
     if(!strcmp (sensorName, "isPerson"))
       pSensor = new SensorIsPerson();
   else	
     if(!strcmp (sensorName, "isFirstW"))
       pSensor = new SensorIsFirstWord();
   else	
     if(!strcmp (sensorName, "hasDigit"))
       pSensor = new SensorHasDigit();
   else
     if(!strcmp (sensorName, "allDigit"))
       pSensor = new SensorAllDigit();
   else
     if(!strcmp (sensorName, "alphaNum"))
       pSensor = new SensorAlphaNumeric();
   else
     if(!strcmp (sensorName, "romanNum"))
       pSensor = new SensorRomanNum();
   else
     if(!strcmp (sensorName, "prefixTwo"))
       pSensor = new SensorPrefix2();
   else	
     if(!strcmp (sensorName, "prefixThree"))
       pSensor = new SensorPrefix3();
   else	
     if(!strcmp (sensorName, "prefixFour"))
       pSensor = new SensorPrefix4();
   else
     if(!strcmp (sensorName, "suffixTwo"))
       pSensor = new SensorSuffix2();
   else	
     if(!strcmp (sensorName, "suffixThree"))
       pSensor = new SensorSuffix3();
   else	
     if(!strcmp (sensorName, "suffixFour"))
       pSensor = new SensorSuffix4();
   else	
     if(!strcmp (sensorName, "len"))
       pSensor = new SensorLength();
  else	
     if(!strcmp (sensorName, "hasPM"))
       pSensor = new SensorHasPM();
  else	
     if(!strcmp (sensorName, "hypCase"))
       pSensor = new SensorHyphenCase();
   else	
     if(!strcmp (sensorName, "charPat"))
       pSensor = new SensorCharPattern();
   else	
     if(!strcmp (sensorName, "inQP"))
       pSensor = new SensorInQuotePar();
   else	
     if(!strcmp (sensorName, "freqW"))
       pSensor = new SensorFrequentWord();
   else	
     if(!strcmp (sensorName, "funcW"))
       pSensor = new SensorFunctionalWord();
   else
     if(!strcmp (sensorName, "uniPre"))
       pSensor = new SensorNEunigramPre();
   else	
     if(!strcmp (sensorName, "z"))
        pSensor = new SensorZone();
   else	
     if(!strcmp (sensorName, "ncs"))
        pSensor = new SensorNCS();
   else	
     if(!strcmp (sensorName, "nePreBi"))
        pSensor = new SensorNEPrebigram();
   else	
     if(!strcmp (sensorName, "neSuffix"))
        pSensor = new SensorNEsuffix();
   else	
     if(!strcmp (sensorName, "neOtherBI"))
        pSensor = new SensorNEotherBI();
   else	
     if(!strcmp (sensorName, "neOtherNCS"))
        pSensor = new SensorNEotherNCS();
   else	
     if(!strcmp (sensorName, "otherIcap"))
        pSensor = new SensorOtherInitCap();
   else	
     if(!strcmp (sensorName, "acroPart"))
        pSensor = new SensorPartOfAcronym();
   else	
     if(!strcmp (sensorName, "neOtherUni"))
        pSensor = new SensorNEotherUNI();
   else	
     if(!strcmp (sensorName, "icapSubSeq"))
        pSensor = new SensorIcapSubSequence();
   else	
     if(!strcmp (sensorName, "neOtherLab"))
        pSensor = new SensorNEotherLabel();   
   else	
     if(!strcmp (sensorName, "colOne"))
        pSensor = new SensorFirstColumn();   
   else	
     if(!strcmp (sensorName, "url"))
        pSensor = new SensorHTML();   
   else
     if(!strcmp (sensorName, "colTwo"))
        pSensor = new SensorSecondColumn();
   else
     if(!strcmp (sensorName, "nerList"))
        pSensor = new SensorNERlist();
   else
     if(!strcmp (sensorName, "wUpper"))
        pSensor = new SensorWordUpper();  
   else
     if(!strcmp (sensorName, "suffixOne"))
        pSensor = new SensorSuffix1();
  

   else	
   {
      cerr << "Invalid identifier: " << sensorName << "!" << endl;
      exit(-1);
   }
}


RGF::RGF( SubRGF& subR ) :
      extractMode(EXTRACT_COLOC),
      subRGFs(subR),
                targetIndex(TARGET_NULL),
                leftOffset(-1),
                rightOffset(-1),
      genFeature(false),
      optParam(NULL),
      includeTarget(false),
      includeMark(false),
      mask(NULL),
      target(NULL),
      pSensor(NULL)
{ }

RGF::~RGF()
{
//   if( optParam != NULL)
//      free(optParam);
}

void RGF::Mode( ExtractMode mode )
{
   extractMode = mode;

   if (mode == EXTRACT_LABEL)
      mask = "label";
}


void RGF::Target( char* targ )
{
     for(SubRGF::iterator pSub = subRGFs.begin(); pSub !=
          subRGFs.end(); pSub++)
        pSub->Target(targ);

          if (isdigit(*targ) || (*targ == '-'))
     {
        targetIndex = atoi(targ);
        target = NULL;
     }
     else
     {
        if ((*targ == '\'') || (*targ == '"'))
        {
           target = targ++;
        } else
        {
           target = targ;
        }
          }
}


void RGF::Param(char* val)
{
   if(val != NULL)
   {
      optParam = val;
   }
}


void RGF::IncludeTargetRecur(bool val)
{
     for(SubRGF::iterator pSub = subRGFs.begin(); pSub !=
          subRGFs.end(); pSub++)
        pSub->IncludeTargetRecur(val);

     includeTarget = val;
}

void RGF::IncludeMark(bool val)
{
     for(SubRGF::iterator pSub = subRGFs.begin(); pSub !=
          subRGFs.end(); pSub++)
        pSub->IncludeMark(val);

     includeMark = val;
}

void RGF::IncludeLocation(bool val)
{
     for(SubRGF::iterator pSub = subRGFs.begin(); pSub !=
          subRGFs.end(); pSub++)
        pSub->IncludeLocation(val);

     if(pSensor != NULL)
        pSensor->IncludeLocation(val);
}

void RGF::LocationOffset( int val )
{
     for(SubRGF::iterator pSub = subRGFs.begin(); pSub !=
          subRGFs.end(); pSub++)
        pSub->LocationOffset(val);

     locationOffset = val;
}


void RGF::RightOffset( int val )
{

  rightOffset = val;

  // Not check if ER:Relation
  if (globalParams.erExtension && globalParams.labelType == RELATION)
    return;

  if(val < leftOffset) {
    cerr << "Invalid scope definition" << endl;
    exit(-1);
  }
}


void RGF::Show()
{
   cout << "               this: " << this << endl;
   if((int)optParam == -1)
      cout << "      optParam is -1" << endl;
   else
      if(optParam == NULL)
         cout << "           optParam: " << endl;
      else
         cout << "           optParam: " << optParam    << endl;
   cout << "        targetIndex: " << targetIndex << endl;
   if(pSensor != NULL)
      cout << "    includeLocation: " << pSensor->IncludeLocation() << endl;
   cout << "     locationOffset: " << locationOffset << endl;
   cout << "      includeTarget: " << includeTarget << endl;
   cout << "         leftOffset: " << leftOffset  << endl;
   cout << "        rightOffset: " << rightOffset << endl;
   cout << "        extractMode: " << extractMode << endl;
   if(target == NULL)
      cout << "             target: " << endl;
   else
      cout << "             target: " << target      << endl;
   if(mask == NULL)
      cout << "               mask: " << endl;
   else
      cout << "               mask: " << mask        << endl;
   cout << "    generic feature: " << genFeature  << endl;
   cout << "            pSensor: " << pSensor     << endl;
   for(SubRGF::iterator pRGF = subRGFs.begin(); pRGF != subRGFs.end(); pRGF++)
      cout << "             subRGF: " << &*pRGF << endl;
   cout << endl;

   for(SubRGF::iterator pSub = subRGFs.begin(); pSub !=
         subRGFs.end(); pSub++)
   {
      pSub->Show();
   }
}

/*
RGF* RGF::InMode(ExtractMode mode)
{
   RGF* val = 0;
   if(extractMode == mode)
      val = this;
   for(SubRGF::iterator pSub = subRGFs.begin(); pSub !=
         subRGFs.end(); pSub++)
      val = pSub->InMode(mode);
   return val;
}
*/

/*****Feature Extraction*****/

//*********CHANGED BY JAKOB METZLER**************
// For some still unidentified reason, conjunctions for the word based mode (as opposed
// to the phrase more) of fex did not work.
// I hacked something that works and hopefully does not destroy other functionality:
// In this function I changed all recursive calls to calls of the phrase-based version of ::Extract
RawFeatureSet RGF::Extract( Sentence& sentence, int targIndex )
{
   RawFeatureSet outputFeatures;
   if (extractMode == EXTRACT_CONJUNCT) {
     outputFeatures = subRGFs[0].Extract(sentence, targIndex, 1);
     if(!outputFeatures.empty())
       for(int sub = 1; sub < subRGFs.size(); sub++)
         {
           RawFeatureSet inSet1 = outputFeatures;
           RawFeatureSet inSet2;

           inSet2 = subRGFs[sub].Extract(sentence, targIndex, 1);

           outputFeatures.clear();
           if(inSet2.empty())
             break;

           for(RawFeatureSet::iterator p1 = inSet1.begin();
               p1 != inSet1.end(); p1++)
             for(RawFeatureSet::iterator p2 = inSet2.begin();
                 p2 != inSet2.end(); p2++)
               {
                 string tempstr(*p1);
                 tempstr.append("--");
                 tempstr.append(*p2);
                 outputFeatures.insert(tempstr);
               }
         }

     return outputFeatures;
   }

   if (extractMode == EXTRACT_DISJUNCT){
      for(SubRGF::iterator pRel = subRGFs.begin();
         pRel != subRGFs.end(); pRel++)
      {
         RawFeatureSet temp = pRel->Extract(sentence, targIndex, 1);
         set_union(outputFeatures.begin(), outputFeatures.end(),
                         temp.begin(),
                         temp.end(),
                         inserter(outputFeatures,
                                  outputFeatures.begin()));
      }
      return outputFeatures;
   }

   // Set up Right scope index
   // realized i'm never using start and i can do the scoloc thing with it
   // keeping the variable just in case we end up needing it
   int start, end;
   if(rightOffset != RANGE_ALL)
     {
      
       start = max(targIndex + leftOffset, 0);
       end = min(targIndex + rightOffset, (int)sentence.size());

       if(start > end)
	 {
	   return RawFeatureSet();
	 }
     }
   else
     {
       start = 0;
       end = sentence.size() - 1;
     }

   // Use Process method to extract features rooted at each record and
   // insert them into the output set
   for (int pos = start; pos <= end && pos < sentence.size(); pos++)
   {
      RawFeatureSet Set = Process(sentence, pos, targIndex, -1, end);
      for(RawFeatureSet::iterator pFeat = Set.begin();
            pFeat != Set.end(); pFeat++)
         if(*pFeat != TARGET_STRING)
            outputFeatures.insert(*pFeat);
   }
   return outputFeatures;
}


// A different version of Extract, used for phrase case only.
// Added by Scott Yih, 09/25/01
RawFeatureSet RGF::Extract( Sentence& sentence, int targIndex, int targLength )
{
   RawFeatureSet outputFeatures;
   if (extractMode == EXTRACT_CONJUNCT) {

     outputFeatures = subRGFs[0].Extract(sentence, targIndex, targLength);
     if(!outputFeatures.empty())
       for(int sub = 1; sub < subRGFs.size(); sub++)
         {
           RawFeatureSet inSet1 = outputFeatures;
           RawFeatureSet inSet2;

           inSet2 = subRGFs[sub].Extract(sentence, targIndex, targLength);

           outputFeatures.clear();
           if(inSet2.empty())
             break;

           for(RawFeatureSet::iterator p1 = inSet1.begin();
               p1 != inSet1.end(); p1++)
             for(RawFeatureSet::iterator p2 = inSet2.begin();
                 p2 != inSet2.end(); p2++)
               {
                 string tempstr(*p1);
                 tempstr.append("--");
                 tempstr.append(*p2);
                 outputFeatures.insert(tempstr);
               }
         }

     return outputFeatures;
   }
   if (extractMode == EXTRACT_DISJUNCT){
      for(SubRGF::iterator pRel = subRGFs.begin();
         pRel != subRGFs.end(); pRel++)
      {
         RawFeatureSet temp = pRel->Extract(sentence, targIndex, targLength);
         set_union(outputFeatures.begin(), outputFeatures.end(),
                         temp.begin(),
                         temp.end(),
                         inserter(outputFeatures,
                                  outputFeatures.begin()));
      }
      return outputFeatures;
   }

   // Set up Right scope index
   // realized i'm never using start and i can do the scoloc thing with it
   // keeping the variable just in case we end up needing it
   int start, end;

   // Ignore RANGE_ALL
   // preserve original leftOffset & rightOffset
   int lOffset = leftOffset, rOffset = rightOffset;

   if(rightOffset != RANGE_ALL) {
     // This modification doesn't allow the window covers target phrase
     if (lOffset > 0)   // right window
       targIndex += targLength - 1;
     else if (leftOffset == rightOffset && leftOffset == 0) { // target phrase
       targIndex --;
       lOffset ++;
       rOffset += targLength;
     }
     // before - inside - after, only first word would be treated as target
     else if (leftOffset < 0 && rightOffset > 0)
       rOffset += targLength - 1;

     start = max(targIndex + lOffset, 0);
     end = min(targIndex + rOffset, (int)sentence.size()-1);

     // cerr << "start = " << start << " end = " << end << " targIndex = " 
     //<< targIndex << endl;

     if(start > end)
       return RawFeatureSet();
   }
   else {
     start = 0;
     end = sentence.size() - 1;
   }

   if (extractMode == EXTRACT_LABEL) // treated LABEL specially
   {
     // check the phrase label of words[targIndex..targIndex+targLength-1]
     bool legitimate = false;
     string label;

     // check if the first word is the start of the phrase
     if (sentence[targIndex].phraseLabel[0] == 'B' &&
         sentence[targIndex].phraseLabel[1] == '-') {
       legitimate = true;
       label = sentence[targIndex].phraseLabel.substr(2);
     }

     // check if other words are inside the phrase
     for (int i = targIndex + 1; i < targIndex + targLength; i++) {
       if (!legitimate)
         break;

       if (sentence[i].phraseLabel[0] == 'I' &&
           sentence[i].phraseLabel[1] == '-') {
         if (label != sentence[i].phraseLabel.substr(2))
           legitimate = false;
       }
       else
         legitimate = false;
     }

     // check the word after is outside the phrase
     if (legitimate && (targIndex + targLength <= end)) {
       int next = targIndex + targLength;

       if (sentence[next].phraseLabel[0] == 'I' &&
           sentence[next].phraseLabel[1] == '-')
         legitimate = false;
     }

     if (legitimate)
       outputFeatures.insert(mask + string("[") + label + string("]"));
     else
       outputFeatures.insert(mask + string("[") + string("IRRELEVANT") + string("]"));
   }
   else if (extractMode == EXTRACT_SENSOR && pSensor->getSensorType() == ST_PHRASE) {
     // Only process it when the range is [0,0]
      if (leftOffset == rightOffset &&
          leftOffset == 0 &&
          pSensor != NULL) {

        // treat the range as the target indicator
        RawFeatureSet Set = Process(sentence, start, targIndex, start, end);

        for(RawFeatureSet::iterator pFeat = Set.begin();
            pFeat != Set.end(); pFeat++)
          if(*pFeat != TARGET_STRING) {

            // cerr << *pFeat << endl;

            // if within target phrase and with location information, add '*' at last
            if (pSensor->IncludeLocation())
              outputFeatures.insert(*pFeat + TARGET_STRING);
            else
              outputFeatures.insert(*pFeat);
          }
      }
   }
   else {

     // cerr << "start = " << start << " end = " << end << " targIndex = " << targIndex << endl;

     // Use Process method to extract features rooted at each record and
     // insert them into the output set
     for (int pos = start; pos <= end; pos++) {
       RawFeatureSet Set = Process(sentence, pos, targIndex, -1, end);

       for(RawFeatureSet::iterator pFeat = Set.begin();
           pFeat != Set.end(); pFeat++)
         if(*pFeat != TARGET_STRING) {

           // cerr << *pFeat << endl;

           // if within target phrase and with location information, add '*' at last
           if ((leftOffset == rightOffset && leftOffset == 0) &&
               (pSensor != NULL && pSensor->IncludeLocation()))
               outputFeatures.insert(*pFeat + TARGET_STRING);
           else
             outputFeatures.insert(*pFeat);
         }
     }
   }

   return outputFeatures;
}


// Another different version of Extract, used for ER:Relation case only.
// Added by Scott Yih, 01/09/02
RawFeatureSet RGF::ExtractRelation( Sentence& sentence, RelationInSentence& relSent, int posArg1, int posArg2 )
{
   RawFeatureSet outputFeatures;

   if (extractMode == EXTRACT_CONJUNCT) {

     outputFeatures = subRGFs[0].ExtractRelation(sentence, relSent, posArg1, posArg2);
     if(!outputFeatures.empty())
       for(int sub = 1; sub < subRGFs.size(); sub++)
         {
           RawFeatureSet inSet1 = outputFeatures;
           RawFeatureSet inSet2;

           inSet2 = subRGFs[sub].ExtractRelation(sentence, relSent, posArg1, posArg2);

           outputFeatures.clear();
           if(inSet2.empty())
             break;

           for(RawFeatureSet::iterator p1 = inSet1.begin();
               p1 != inSet1.end(); p1++)
             for(RawFeatureSet::iterator p2 = inSet2.begin();
                 p2 != inSet2.end(); p2++)
               {
                 string tempstr(*p1);
                 tempstr.append("--");
                 tempstr.append(*p2);
                 outputFeatures.insert(tempstr);
               }
         }

     return outputFeatures;
   }
   if (extractMode == EXTRACT_DISJUNCT){
      for(SubRGF::iterator pRel = subRGFs.begin();
         pRel != subRGFs.end(); pRel++)
      {
         RawFeatureSet temp = pRel->ExtractRelation(sentence, relSent, posArg1,
                                                    posArg2);
         set_union(outputFeatures.begin(), outputFeatures.end(),
                         temp.begin(),
                         temp.end(),
                         inserter(outputFeatures,
                                  outputFeatures.begin()));
      }
      return outputFeatures;
   }

   // Set up Right scope index
   int start, end;

   // preserve original leftOffset & rightOffset
   int lOffset = leftOffset, rOffset = rightOffset;
   // Reference arguments of leftOffset and rightOffset
   int lRefArg, rRefArg;
   // Reference origins of leftOffset and rightOffset
   int lOrigin, rOrigin;

   if (rightOffset != RANGE_ALL) {
     lRefArg = abs(leftOffset) / 100;
     rRefArg = abs(rightOffset) / 100;

     if (globalParams.verbosity > VERBOSE_MIN) {
       cerr << "leftOffset, rightOffset, lRefArg, rRefArg  = "
            << leftOffset << "," <<  rightOffset << "," << lRefArg << "," << rRefArg << endl;
     }

     lOrigin = (lRefArg == 1) ? posArg1 : posArg2;
     rOrigin = (rRefArg == 1) ? posArg1 : posArg2;

     lOffset = leftOffset % 100;
     rOffset = rightOffset % 100;

     start = max(lOrigin + lOffset, 0);
     end = min(rOrigin + rOffset, (int)sentence.size()-1);

     if (globalParams.verbosity > VERBOSE_MIN) {
       cerr << "leftOffset, rightOffset, lOrigin, rOrigin, lOffset, rOffset, start, end = "
            << leftOffset << "," <<  rightOffset << "," << lOrigin << "," << rOrigin << "," << lOffset << "," << rOffset << "," << start << "," << end << endl;
     }

     if(start > end)
       return RawFeatureSet();
   } else {
     start = 0;
     end = sentence.size() - 1;
   }

    if (globalParams.verbosity > VERBOSE_MIN) {
      cerr << "(extractMode == EXTRACT_LABEL) = " << (extractMode == EXTRACT_LABEL) << endl;
    }

   if (extractMode == EXTRACT_LABEL) // treated LABEL specially
   {
      bool hasRelation = false;
      for (RelationInSentence::iterator pRelTag = relSent.begin();
               pRelTag != relSent.end(); pRelTag++) {

         /*
         cout << pRelTag->arg1 << ", " << pRelTag->arg2 << ", " << pRelTag->label << endl;
         cout << posArg1 << ", " << posArg2 << endl;
         */


         if (pRelTag->arg1 == posArg1 && pRelTag->arg2 == posArg2) {

             // cout << "Yes" << endl;

             outputFeatures.insert(mask + string("[Rel-") + pRelTag->label + string("]"));
             hasRelation = true;
         }
      }

           if (!hasRelation)
               outputFeatures.insert(mask + string("[Rel-Unknown]"));
   } else {

     // Use Process method to extract features rooted at each record and
     // insert them into the output set
     for (int pos = start; pos <= end; pos++) {
       //RawFeatureSet Set = Process(sentence, pos, lOrigin, -1, end);
       RawFeatureSet Set = Process(sentence, pos, lOrigin, start, end);

       for(RawFeatureSet::iterator pFeat = Set.begin();
           pFeat != Set.end(); pFeat++)
         if(*pFeat != TARGET_STRING) {
           if (includeMark) {
               string lMark(1, char('0' + lRefArg)), rMark(1, char('0' + rRefArg));
               outputFeatures.insert(*pFeat + lMark + rMark);
           } else {
               outputFeatures.insert(*pFeat);
           }
         }
     }
   }

   return outputFeatures;
}

RawFeatureSet RGF::Process( Sentence& sentence,
                                 int rec,
                                 int targIndex,
                                 int start,
                                 int end)
{
   RawFeatureSet outSet;

   switch ( extractMode )
   {
   case EXTRACT_LABEL:
   {
      if(rec == targIndex)
      {
         RawFeatureSet tempSet =
            subRGFs[0].Process(sentence, rec, targIndex, start, end);
         for(RawFeatureSet::iterator pFeat = tempSet.begin();
               pFeat != tempSet.end(); pFeat++)
         {
            outSet.insert(*pFeat);
         }
      }
      break;
   }
   case EXTRACT_CONJ:
   {
      //arg.. these first are going to be really confusing and stupid
      outSet = subRGFs[0].Process(sentence, rec, targIndex, start, end);

      for(int sub = 1; sub < subRGFs.size(); sub++)
      {
         RawFeatureSet inSet1 = outSet;
         RawFeatureSet inSet2 = subRGFs[sub].Process(sentence, rec,
               targIndex, start, end);

         outSet.clear();

         for(RawFeatureSet::iterator p1 = inSet1.begin();
               p1 != inSet1.end(); p1++)
            for(RawFeatureSet::iterator p2 = inSet2.begin();
                  p2 != inSet2.end(); p2++)
            {
               string tempstr(*p1);
               tempstr.append("&");
               tempstr.append(*p2);
               outSet.insert(tempstr);
            }
      }
      break;
   }
   case EXTRACT_DISJ:
   {
      for(SubRGF::iterator pRel = subRGFs.begin();
         pRel != subRGFs.end(); pRel++)
      {
         RawFeatureSet temp = pRel->Process(sentence, rec, targIndex, start, end);
         set_union(outSet.begin(), outSet.end(),
                         temp.begin(),
                         temp.end(),
                         inserter(outSet,
                                  outSet.begin()));
      }
      break;
   }
   case EXTRACT_NOT:
   {
      RawFeatureSet tempoutSet;
      if(subRGFs.size() != 1 || 
          subRGFs.begin()->Mode() != EXTRACT_SENSOR ||
          subRGFs.begin()->Param() == NULL)
      {
         cerr << "Invalid argument to 'not' operator." << endl;
         exit(-1);             
      }
      if(subRGFs.begin() != subRGFs.end()){
         tempoutSet = subRGFs.begin()->Process(sentence, rec, targIndex, start, end); 
         if(tempoutSet.empty())
         {
            string strparam = string(subRGFs.begin()->Param());
            string tmpstring = string(subRGFs.begin()->Mask()) + "[" +
                                 string(strparam) + "]";
            tempoutSet.insert(tmpstring);
         }
         else
            tempoutSet.clear();
      }
      else
         cerr << "something weird" << endl;

      outSet = tempoutSet;
      break;
   }
   case EXTRACT_COLOC:
   {
      outSet = subRGFs[0].Process(sentence, rec, targIndex, start, end);
      if(!outSet.empty())
         for(int sub = 1; sub < subRGFs.size(); sub++)
         {
            RawFeatureSet inSet1 = outSet;
            RawFeatureSet inSet2;
            if(rec+sub <= end && rec+sub < sentence.size())
               inSet2 = subRGFs[sub].Process(sentence, rec+sub, targIndex,
                     start, end);
            outSet.clear();
            if(inSet2.empty())
               break;


            for(RawFeatureSet::iterator p1 = inSet1.begin();
                  p1 != inSet1.end(); p1++)
               for(RawFeatureSet::iterator p2 = inSet2.begin();
                     p2 != inSet2.end(); p2++)
               {
                  string tempstr(*p1);
                  tempstr.append("-");
                  tempstr.append(*p2);
                  outSet.insert(tempstr);
               }
         }
      break;
   }
   case EXTRACT_SCOLOC:
   {
      int left;
      if (start < 0)
         left = subRGFs.size()-1;
      else
         left = start;

      RawFeatureSet inSet1;
      inSet1 = subRGFs[subRGFs.size()-left-1].Process(sentence, rec,
                                             targIndex, start, end);
      if(!inSet1.empty())
      {
         if(left)
         {
            // compute a safe end value
            int safeEnd = min((int)end, (int)sentence.size() - 1);
            for (int j = rec+1; j <= safeEnd-left+1; j++)
            {
               RawFeatureSet inSet2 = this->Process(sentence, j,
                     targIndex, left-1, end);
               for(RawFeatureSet::iterator p1 = inSet1.begin();
                     p1 != inSet1.end(); p1++)
                  for(RawFeatureSet::iterator p2 = inSet2.begin();
                        p2 != inSet2.end(); p2++)
                  {
                     string tempstr(*p1);
                     tempstr.append("-");
                     tempstr.append(*p2);
                     outSet.insert(tempstr);
                  }
            }
         }
         else
            outSet = inSet1;
      }
      break;
   }


   // I think this one is not a sensor, so I move this part of code here.
   // by Scott Wen-tau Yih
   case EXTRACT_LINK:
   {
      outSet = subRGFs[0].Process(sentence, rec, targIndex, start, end);

      for(int sub = 1; sub < subRGFs.size(); sub++)
      {
         RawFeatureSet inSet1 = outSet;
         RawFeatureSet inSet2;

         int point;
         if(sentence[rec].pointer.begin() != sentence[rec].pointer.end())
            point = *(sentence[rec].pointer.begin());
         else
         {
            outSet.clear();
            return outSet;
         }

         inSet2 = subRGFs[sub].Process(sentence, point, targIndex,
                  start, end);

         outSet.clear();

         for(RawFeatureSet::iterator p1 = inSet1.begin();
               p1 != inSet1.end(); p1++)
            for(RawFeatureSet::iterator p2 = inSet2.begin();
                  p2 != inSet2.end(); p2++)
            {
               string tempstr(*p1);
               tempstr.append("->");
               tempstr.append(*p2);
               outSet.insert(tempstr);
            }

         rec = point;
      }
      break;
   }

   // these are much easier/better
   // Below are sensors (Scott Wen-tau Yih)
   // slightly modified for generality -cmc11/14
        case EXTRACT_SENSOR:
        {
          // Added by Scott Yih, 09/27/01
          if (pSensor->getSensorType() == ST_PHRASE)
            pSensor->Extract(sentence, outSet, start, end);
          else
            pSensor->Extract( sentence,
                              outSet,
                              rec,
                              rec - targIndex - locationOffset);

          for(RawFeatureSet::iterator pFeat = outSet.begin(); pFeat != outSet.end();
              pFeat++)
            if(optParam != NULL)
              {
                if(*pFeat != string(optParam))
                  outSet.erase(pFeat);
              }
          if(rec == targIndex && !includeTarget)
            {
              outSet.clear();
              outSet.insert(TARGET_STRING);
            }
          break;
        }
   }

   RawFeatureSet tempSet = outSet;
   outSet.clear();
   for(RawFeatureSet::iterator pFeat = tempSet.begin();
      pFeat != tempSet.end(); pFeat++)
   {
      string feat;
      if(mask != NULL && *pFeat != TARGET_STRING)
      {
         feat += mask;
         feat += "[";
      }
      if(!genFeature)
         feat += *pFeat;
      if(mask != NULL && *pFeat != TARGET_STRING)
         feat += "]";
      outSet.insert(feat);
   }
   return outSet;
}

