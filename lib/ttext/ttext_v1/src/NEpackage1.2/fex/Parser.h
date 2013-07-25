//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Parser.h                                      =
//=  Version: 2.0                                           =
//=   Author: Chad Cumby
//=     Date: xx/xx/01                                      =
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef __PARSER_H__
#define __PARSER_H__

#include <fstream>

#include "Fex.h"

typedef vector<string> RawFeatureVector;

enum States { SZERO, STAG1, STAG2, SWORD, STEMP, SERROR };

class Parser
{
  public:
	Parser( istream& inputStream );
	~Parser();

	void Form1Only( bool val ) { form1Only = val; }

	bool eof() const;

	// The ParseSentence methods
	bool  OldParseSentence( Sentence& sentence );
   	bool  NewParseSentence( Sentence& sentence, RelationInSentence* relSentenceP = NULL );
  protected:
	int	      line;
  	bool      form1Only;
  	istream&  inStream;
  private:
    void processRelInSent(Sentence& sentence, RelationInSentence &relSent);
};

#endif
