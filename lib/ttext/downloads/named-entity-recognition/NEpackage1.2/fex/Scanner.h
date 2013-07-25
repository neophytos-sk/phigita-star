//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Scanner.h                                     =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================

#ifndef __SCANNER_H__
#define __SCANNER_H__

#include <fstream>

using namespace std;

enum Tokens { TNULL, TLPAREN, TRPAREN, TSEMI, TSTRING, TEOL, TEOF };

class Scanner
{
public:
  enum State { SZERO, SINSTRING };

public:
  Scanner( istream& source, int bufsize = 65536 );
  ~Scanner() { delete[] buffer; }

  Tokens  scan();
  char*   lexeme() { return lexemePtr; }
  void    copyLexeme( char* dest );

protected:
  void    LoadBuffer( int shiftCount );
  char*   AdvancePtr( char* ptr, int count = 1 );

protected:
  istream&  input;
  int       bufSize;
  char*     lexemePtr;
  char*     forwardPtr;
  int       hold;
  char*     buffer;
  State     state;
  int       bufCount;
};


#endif
