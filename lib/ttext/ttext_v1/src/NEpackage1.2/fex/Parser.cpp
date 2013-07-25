//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Parser.cpp                                    =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================

/* $Id: Parser.cpp,v 1.22 2003/12/14 01:46:57 yih Exp $ */

#pragma warning( disable:4786 )

#include "Parser.h"
#include "FexParams.h"
#include <string>
#include <iostream>
#include <algorithm>

using namespace std;


Parser::Parser( istream& inputStream ) :
         line(1),
         form1Only(false),
         inStream(inputStream)
{ }

Parser::~Parser()
{ }


bool Parser::OldParseSentence( Sentence& sentence )
{
   sentence.clear();

   if(inStream.eof())
   {
      return false;
   }

   char* buf;
   char  bufar[1024];
   buf = bufar;

   inStream.getline(buf, 1024);

   if(!inStream.fail())
   {
      char* pToken = strtok(buf, " \t");

      RawFeatureVector tempVec;
		int recnum = 1;

      States state = SZERO;

		while(pToken != NULL && state != SERROR)
		{
			string tok(pToken);
			switch(state)
			{
				case SZERO:
				{
   		      sentence.push_back(Record());
					if(tok[0] == '(')
               {
                  if(form1Only)
                     sentence.back().words.push_back(tok);
                  else
                  {
                     if(tok.length() > 1)
                     {
                        state = STAG2;
                        sentence.back().tags.push_back(tok.substr(1,tok.length()-1));
                     }
                     else
                        state = STAG1;
                  }
               }
               else
               {
                  sentence.back().words.push_back(tok);
               }
					break;
				}
				case STAG1:
				{
					sentence.back().words.push_back(tok);
					state = STAG2;
					break;
				}
            case STAG2:
            {
               int loc = tok.find(";");
               if((loc != string::npos) && (tok[loc-1] != '\\'))
               {
                  if(tok.length() > 1)
                     sentence.back().tags.push_back(tok.substr(0,tok.length()-1));
                  state = SWORD;
               }
               else
               {
                  int ploc = tok.find(")");
                  if((ploc != string::npos) && (tok[ploc-1] != '\\'))
                  {
                     sentence.back().words.push_back(tok.substr(0,tok.length()-1));
                     state = SZERO;
                  }
                  else
                  {
                     // otherwise it's just a string and no way to know whether
                     // it'll be followed by a ';' or a ')'.. so tempset
                     tempVec.push_back(tok);
                     state = STEMP;
                  }
               }
               break;
            }
            case SWORD:
            {
               int ploc = tok.find(")");
               if((ploc != string::npos) && (tok[ploc-1] != '\\'))
               {
                  sentence.back().words.push_back(tok.substr(0,tok.length()-1));
                  state = SZERO;
               }
               else
                  sentence.back().words.push_back(tok);
               break;
            }
            case STEMP:
            {
               int loc = tok.find(";");
               if((loc != string::npos) && (tok[loc-1] != '\\'))
               {
                  if(loc == tok.length()-1)
                  {
                     if(loc != 0)
                        tempVec.push_back(tok.substr(0,tok.length()-1));
				         copy(tempVec.begin(), tempVec.end(),
                     inserter(sentence.back().tags,
                        sentence.back().tags.begin()));
                     tempVec.clear();
                     state = SWORD;
                     break;
                  }
                  else
                  {
                     cerr << "Error in corpus on line: " << line << endl;
                     cerr << "Skipping rest of line. " << endl;
                     tempVec.clear();
                     state = SERROR;
                     break;
                  }
               }
               int ploc = tok.find(")");
               if((ploc != string::npos) && (tok[ploc-1] != '\\'))
               {
                  if((tok == ")" && tempVec.size() != 2) || tempVec.size() != 1)
                  {
                     cerr << "Error in corpus on line: " << line << endl;
                     cerr << "Skipping rest of line. " << endl;
                     tempVec.clear();
                     state = SERROR;
                     break;
                  }
                  else
                  {
                     if(tok != ")")
                        tempVec.push_back(tok.substr(0,tok.length()-1));
                     sentence.back().words.push_back(tempVec.back());
                     tempVec.pop_back();
                     sentence.back().tags.push_back(tempVec.back());
                     tempVec.clear();
                     state = SZERO;
                     break;
                  }
               }
               // otherwise we just add more words to tempVec.
               tempVec.push_back(tok);
               break;
            }
			}
        	pToken = strtok(NULL, " \t");
		}
      if(state != SERROR)
         return true;
      else
         return false;
	}
	else
   {
		return false;
   }
}


bool Parser::NewParseSentence( Sentence& sentence, RelationInSentence* relSentenceP )
{
   sentence.clear();
   if (relSentenceP != NULL)
      relSentenceP->clear();

   if(inStream.eof())
      return false;

   int init = -1;

   while(!inStream.eof())
   {
      char* buf;
      char  bufar[1024];
      buf = bufar;

      Record record;
      vector<char*> tempVec;
      //int pass = 0;

      inStream.getline(buf, 1024);

      if(!inStream.fail())
      {
         char* pToken = strtok(buf, " \t\n");

         int pass = 0;
         while(pToken != NULL)
         {
            string tok(pToken);
            StringVector tokSet;

            int ind = tok.find("/");
            if(ind != string::npos){
               while(ind != string::npos)
               {
                  if(tok[ind-1] != '\\')
                  {
                     string tempTok;
                     tempTok.assign(tok,0,ind);
                     tokSet.push_back(tempTok);
                     tok.assign(tok,ind+1,tok.size());
                  }
                  else{
                     tok.erase(ind-1,1);
                     //cout << "bonk " << tok << endl;
                     break;
                  }
                  ind = tok.find("/");
               }
               string tempTok;
               tempTok.assign(tok,0,tok.size());
               tokSet.push_back(tempTok);
            }
            else
               tokSet.push_back(tok);

            switch(pass)
            {
	        	// case 0 (the first column) is used to store phrase label in BIO format
	       		// used only for phrase case
	       		// Added by Scott Yih, 09/25/01
	       		case 0:
	       		{
		 			record.phraseLabel = pToken;
		 			break;
	     		}
         		case 1:
	       		{
		 			for(StringVector::iterator it = tokSet.begin(); it !=
		 		      tokSet.end(); it++)
		 	  		if(*it != "_NONE_" && *it != "NOFUNC")
		     			record.namedEntities.push_back(*it);
		 			break;
	       		}
                case 2:
               	{
                  	if(init < 0)
						init = atoi(pToken);
                  	break;
               	}
               	case 3:
               	{
                  	for(StringVector::iterator it = tokSet.begin(); it !=
                        tokSet.end(); it++)
                     	if(*it != "_NOPHRASE_" && *it != "NOFUNC")
                        	record.phrasal.push_back(*it);
                  	break;
               	}
               	case 4:
               	{
                  	for(StringVector::iterator it = tokSet.begin(); it !=
                        tokSet.end(); it++)
                     	if(*it != "_NOTAG_" && *it != "NOFUNC")
                        	record.tags.push_back(*it);
                  	break;
               	}
               	case 5:
               	{
                  	for(StringVector::iterator it = tokSet.begin(); it !=
                        tokSet.end(); it++)
                     	if(*it != "_NOWORD_" && *it != "NOFUNC")
                        	record.words.push_back(*it);
                  	break;
               	}
               	case 6:
               	{
                  	for(StringVector::iterator it = tokSet.begin(); it !=
                        tokSet.end(); it++)
                     	if(*it != "NOFUNC")
                        	record.func.push_back(*it);
                  	break;
               	}

		// The 8th column is now being used to hold information about the zone of a text
		// e.g. Headline (HL), authorline (AU), dateline (DL), text (TXT).
		// Zone is in first entry, document number in 2nd entry, e.g. HL/5
		// Added by Jakob Metzler 10/6/03
	        case 7:
		{       //zone
		        StringVector::iterator it = tokSet.begin();
                        if(it!= tokSet.end() && *it != "-1" && *it != "???")
                     	   record.zones.push_back(*it);

			it++;
			
			//document index
                        if(it!= tokSet.end() && *it != "-1" && *it != "???")
			  record.docIndex = atoi((*it).c_str()) ;

                  	break;
               	}

		// In the document mode, the 9th column is used to store HTML tagged information.
		// Added by Scott Yih 12/12/03
               	case 8:
               	{
		  for(StringVector::iterator it = tokSet.begin(); it !=
			tokSet.end(); it++) { 
		    if(*it != "-1" && *it != "???") {
		      if (globalParams.docMode && *it != "0") {
			record.htmlTags.push_back(*it);
		      }
		      else
			record.pointer.insert(atoi(it->c_str()) - init);
		    }
		  }
		  break;
               	}
            }
            pass++;
            pToken = strtok(NULL, " \t\n");
         } // end of while

         if(pass)
            sentence.push_back(record);
         else { // no more records
		   if (relSentenceP != NULL)
		   	  processRelInSent(sentence, *relSentenceP);



		   // added by Jakob 11/5/03:
		   // every sentence in one document is added to the currentDocument vector of sentences.
		   // when a sentence of a new document occurs, currentDocument is cleared and is created 
		   // for the new document.
		   // As one can see above, this assumes that the 2nd entry in the 8th column hold the index
		   // of the document
					   
		   if(sentence.size() > 0)
		     {
		       if(globalParams.currentDoc.size() > 0 )
			 {
			   Sentence last = globalParams.currentDoc[0];
			   if(last[0].docIndex != sentence[0].docIndex)
			     globalParams.currentDoc.clear();
			 }
		       
		       globalParams.currentDoc.push_back(sentence);
		     }
		   
		   return true;
	      }
      }
      else { // no more records
 	    if (relSentenceP != NULL)
		  processRelInSent(sentence, *relSentenceP);
	    return true;
	  }

      line++;
   }
   if(sentence.size() > 0) 
     return true;
   else
     return false;


}

// Special routine for reading relation description.
// Added by Scott Yih, 01/21/02
void Parser::processRelInSent(Sentence& sentence, RelationInSentence &relSent) {

   	while(!inStream.eof()) {
    	char* buf;
    	char  bufar[1024];
      	buf = bufar;

      	RelationTag relTag;
      	vector<char*> tempVec;

      	inStream.getline(buf, 1024);

      	if(!inStream.fail()) {
			char* pToken = strtok(buf, " \t\n");

			int pass = 0;
			while(pToken != NULL) {
            	switch(pass)
            	{
		       		case 0:
						relTag.arg1 = atoi(pToken);
			 			break;
	         		case 1:
						relTag.arg2 = atoi(pToken);
			 			break;
	                case 2:
						relTag.label = pToken;
	                  	break;
	               	default:
	               		break;
            	}
            	pass++;
            	pToken = strtok(NULL, " \t\n");
         	} // end of while

         	if(pass) {
				sentence[relTag.arg1].relArgs.insert(relTag.label + "1");
				sentence[relTag.arg2].relArgs.insert(relTag.label + "2");
				relSent.push_back(relTag);
			}
			else
				return;
      	} // end of if
      	else
		    return;
	} // end of while

}
