/*
  EVAL.C
  ======
  (c) Copyright Paul Griffiths 2002
  Email: mail@paulgriffiths.net

  Implementation of expression evaluation operation
*/


#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "token.h"


/*  Converts a string based infix numeric expression
    to a string based postfix numeric expression      */

static char * toPostfix(char * infix, char * postfix) {
    char         buffer[BUFFERSIZE];
    int          stack[STACKSIZE];
    int          top = 0;
    struct token t;
    
    *postfix = 0;                         /*  Empty output buffer     */

    while ( (infix = GetNextToken(infix, &t)) ) {
        if ( t.type == TOK_OPERAND ) {

            /*  Always output operands immediately  */

            sprintf(buffer, "%f ", t.value);
            strcat(postfix, buffer);
        }
        else {

            /*  Add the operator to the stack if:
                 - the stack is empty; OR
                 - if the operator has a higher precedence than
                   the operator currently on top of the stack; OR
                 - An opening parenthesis is on top of the stack   */

            if ( top == 0 || oplist[t.operator_index].precedence >
                             oplist[stack[top]].precedence ||
                             oplist[stack[top]].value == OP_LPAREN ) {
                stack[++top] = t.operator_index;
            }
            else {
                int balparen = 0;

                /*  Otherwise, remove all operators from the stack
                    which have a higher precedence than the current
                    operator. If we encounter a closing parenthesis,
                    keep removing operators regardless of precedence
                    until we find its opening parenthesis.            */

                while ( top > 0 && ((oplist[stack[top]].precedence >=
                                     oplist[t.operator_index].precedence)
                                    || balparen)
                                && !(!balparen
                                     && oplist[stack[top]].value ==
                                        OP_LPAREN) ) {
                    if ( stack[top] == OP_RPAREN )
                        ++balparen;
                    else if ( stack[top] == OP_LPAREN )
                        --balparen;
                    else {
                        sprintf(buffer, "%c ", oplist[stack[top]].symbol);
                        strcat(postfix, buffer);
                    }
                    --top;
                }
                stack[++top] = t.operator_index;
            }
        }
    }


    /*  Output any operators still on the stack  */

    while ( top > 0 ) {
        if ( oplist[stack[top]].value != OP_LPAREN &&
             oplist[stack[top]].value != OP_RPAREN ) {
            sprintf(buffer, "%c ", oplist[stack[top]].symbol);
            strcat(postfix, buffer);
        }
        --top;
    }
    return postfix;
}    


/*  Parses a postfix expression and returns its value  */

static double parsePostfix(char * postfix) {
    struct token t;
    double       stack[STACKSIZE];
    int          top = 0;
    
    while ( (postfix = GetNextToken(postfix, &t)) ) {

        if ( t.type == TOK_OPERAND ) {
            stack[++top] = t.value;       /*  Store operand on stack  */
        }
        else {
            double a, b, value;
            
            if ( top < 2 ) {              /*  Two operands on stack?  */
	      fprintf(stderr,"Stack empty!");
	      // exit(EXIT_FAILURE);
	      return 0.0;
            }

            b = stack[top--];             /*  Get last two operands   */
            a = stack[top--];

            switch ( t.operator_index ) {
            case OP_PLUS:                 /*  Perform operation       */
                value = a + b;
                break;
                
            case OP_MINUS:
                value = a - b;
                break;
                
            case OP_MULTIPLY:
                value = a * b;
                break;
                
            case OP_DIVIDE:
                value = a / b;
                break;

            case OP_MOD:
                value = fmod(a, b);
                break;
                
            case OP_POWER:
                value = pow(a, b);
                break;
                
            default:
	      fprintf(stderr,"Bad operator: %c\n", oplist[t.operator_index].symbol);
	      // TODO: HERE: exit(EXIT_FAILURE);
	      return 0.0;
	      break;
            }            
            stack[++top] = value;        /*  Put value back on stack  */
        }
    }
    return stack[top];
}
            

/*  Evaluates an postfix numeric expression  */

double evaluate(const char * input, double* result) {
    char postfix[BUFFERSIZE];
    char *infix = strdup(input);
    toPostfix(infix,postfix);
    free(infix);
    return parsePostfix(postfix);
}

