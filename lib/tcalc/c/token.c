/*
  TOKEN.C
  =======
  (c) Copyright Paul Griffiths 2002
  Email: mail@paulgriffiths.net

  Implementation of tokenising operation
*/


#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

#include "token.h"


/*  Array of operators  */

struct operator oplist[] = { {'+', OP_PLUS,     1},
                             {'-', OP_MINUS,    1},
                             {'*', OP_MULTIPLY, 2},
                             {'/', OP_DIVIDE,   2},
                             {'^', OP_POWER,    3},
                             {'%', OP_MOD,      2},
                             {')', OP_RPAREN,   4},
                             {'(', OP_LPAREN,   5},
                             {0,   0,           0} };


/*  Gets the next token from a string based numeric
    expression. Returns the address of the first
    character after the token found.                 */

char * GetNextToken(char * input, struct token * t) {
    while ( *input && isspace(*input) )  /*  Skip leading whitespace  */
        ++input;

    if ( *input == 0 )                   /*  Check for end of input   */
        return NULL;

    if ( isdigit(*input) ) {             /*  Token is an operand      */
        t->type  = TOK_OPERAND;
        //t->value = strtol(input, &input, 0);
	t->value = strtod(input, &input);
    }
    else {                               /*  Token is an operator     */
        int n = 0, found = 0;

        t->type = TOK_OPERATOR;

        while ( !found && oplist[n].symbol ) {
            if ( oplist[n].symbol == *input ) {
                t->operator_index = oplist[n].value;
                found = 1;
            }
            ++n;
        }

        if ( !found ) {
	  fprintf(stderr,"Bad operator: %c\n", *input);
	  // TODO: exit(EXIT_FAILURE);
	  return NULL;
        }
        ++input;
    }        
    return input;
}
