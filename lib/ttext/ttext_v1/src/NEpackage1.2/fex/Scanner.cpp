//===========================================================
//=     University of Illinois at Urbana/Champaign          =
//=     Department of Computer Science                      =
//=     Dr. Dan Roth - Cognitive Computation Group          =
//=                                                         =
//=  Project: Fex                                           =
//=                                                         =
//=   Module: Scanner.cpp                                   =
//=  Version: 1.1                                           =
//=   Author: Jeff Rosen                                    =
//=     Date: xx/xx/98                                      = 
//=                                                         =
//= Comments:                                               =
//===========================================================


#include "Scanner.h"

using namespace std;

#include <string.h>
#include <ctype.h>

Scanner::Scanner( istream& source, int bufsize ) 
    : input(source), bufSize(bufsize) 
{
  buffer = new char[bufSize];
  lexemePtr = forwardPtr = buffer;
  hold = 0;
  state = SZERO;
  bufCount = 0;
  LoadBuffer(0);
}

void Scanner::LoadBuffer( int shiftCount )
{
  if (shiftCount > 0)
    memcpy(buffer, buffer + bufSize - shiftCount, shiftCount);
  input.read(buffer + shiftCount, bufSize - shiftCount);
  int count = input.gcount();
  if (count < (bufSize - shiftCount)) buffer[count + shiftCount] = EOF;
  bufCount++;
}

char* Scanner::AdvancePtr( char* ptr, int count )
{
  int i;
  for (i = 0; i < count; i++)
  {
    if ((ptr > (buffer + bufSize - 256)) && (lexemePtr == forwardPtr))
    {
      LoadBuffer(buffer + bufSize - ptr);
      ptr = lexemePtr = buffer;
    } else {
      ptr++;
    }
  }

  return ptr;
}

Tokens Scanner::scan()
{
	Tokens  token = TNULL;

	if (*forwardPtr == 0) *forwardPtr = (char)hold;
	lexemePtr = forwardPtr;
	while (token == TNULL)
	{
		switch (*forwardPtr)
		{
		// The 'escape' character, following character is literal
		case '\\':
			if (state == SINSTRING)
			{
				if (lexemePtr < forwardPtr)
				{
					memmove(lexemePtr + 1, lexemePtr, forwardPtr - lexemePtr);
				}
				lexemePtr++;
				forwardPtr += 2;
			} else {
				state = SINSTRING;
				lexemePtr = AdvancePtr(forwardPtr);
				forwardPtr = AdvancePtr(lexemePtr);
			}
			break;

		case '(':
			if (state == SINSTRING)
			{
				hold = *forwardPtr;
				*forwardPtr = '\0';
				state = SZERO;
				token = TSTRING;
			} else {
				forwardPtr = AdvancePtr(forwardPtr);
				token = TLPAREN;
			}
			break;

		case ')':
			if (state == SINSTRING)
			{
				hold = *forwardPtr;
				*forwardPtr = '\0';
				state = SZERO;
				token = TSTRING;
			} else {
				forwardPtr = AdvancePtr(forwardPtr);
				token = TRPAREN;
			}
			break;

		case ';':
			if (state == SINSTRING)
			{
				hold = *forwardPtr;
				*forwardPtr = '\0';
				state = SZERO;
				token = TSTRING;
			} else {
				forwardPtr = AdvancePtr(forwardPtr);
				token = TSEMI;
			}
			break;

		case '\r':
		case '\n':
			if (state == SINSTRING)
			{
				hold = *forwardPtr;
				*forwardPtr = '\0';
				state = SZERO;
				token = TSTRING;
			} else {
				do {
					forwardPtr = AdvancePtr(forwardPtr);
				} while ((*forwardPtr == '\r') || (*forwardPtr == '\n'));
				token = TEOL;
			}
			break;

	    case EOF:
			if (state == SINSTRING)
			{
				hold = *forwardPtr;
				*forwardPtr = '\0';
				state = SZERO;
				token = TSTRING;
			} else {
				return TEOF;
			}
			break;

	    default:
			if ((state == SZERO) && !isspace(*forwardPtr))
			{
				lexemePtr = forwardPtr;
				state = SINSTRING;
				forwardPtr = AdvancePtr(forwardPtr);
			} else if ((state == SINSTRING) && isspace(*forwardPtr))
			{
				hold = *forwardPtr;
				*forwardPtr = '\0';
				state = SZERO;
				token = TSTRING;				
			} else {
				forwardPtr = AdvancePtr(forwardPtr);
			}
			break;
		}
	}

	return token;
}

void Scanner::copyLexeme( char* dest )
{
  if (forwardPtr > lexemePtr)
  {
    strcpy(dest, lexemePtr);
  } else {
    int first = buffer + bufSize - lexemePtr;
    strncpy(dest, lexemePtr, first);
    strcpy(dest + first, buffer);
  }
}
