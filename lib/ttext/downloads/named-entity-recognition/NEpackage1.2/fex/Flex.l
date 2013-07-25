%{
/*
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "Flex.h"

extern int yylval;
int lineno = 1;

%}

delim       [ \t]
anchnl      ^\n
ws          {delim}+
letter      [A-Za-z_]|-
nat         [0-9]+
int         -?{nat}
word        {letter}+
alphanum    {nat}|{letter}
targ ({alphanum}|[\$\-\+\#\@\!\?\.\;\:\~\%\^\*\,\\\/\<\>\"\'\&\_\|\{\}])+

%s win flag arg 

%%
<INITIAL,flag,arg,win>{ws}                    {}
<INITIAL,flag,arg,win>\/\*([^*]|\*[^/])*\*\/  {}
<INITIAL,flag,arg,win>\/\/.*\n                {}
<INITIAL,flag,arg,win>\/\*([^*]|\*[^/])*\*\/(\n)*  {lineno++;}
<INITIAL,flag,arg,win>{anchnl}           {lineno++;}
<INITIAL,flag,arg>"\n"               {lineno++;BEGIN(INITIAL); 
                                        return(NEWLINE);}

<INITIAL>{int}                       {BEGIN(flag);
                                        yylval = (int) malloc(yyleng); 
                                        strcpy((char *)yylval, yytext); 
                                        return(INT);
                                     }
<flag>":"                            {BEGIN(INITIAL);return(COLON);}
<flag>loc                            {return(FLOC);}
<flag>inc                            {return(FINC);}
<flag>mark                           {return(FMARK);}
<INITIAL>disjunct                    {return(DISJUNCT);}
<INITIAL>conjunct                    {return(CONJUNCT);}
<INITIAL>coloc                       {yylval = T_COLOC; 
                                       return(COMPRGF);
                                     }
<INITIAL>not                         {yylval = T_NOT; 
                                       return(COMPRGF);
                                     }
<INITIAL>scoloc                      {yylval = T_SCOLOC; 
                                       return(COMPRGF);
                                     }
<INITIAL>lab                         {yylval = T_LABEL; 
                                       return(COMPRGF);
                                     }
<INITIAL>link                        {yylval = T_LINK; 
                                       return(COMPRGF);
                                     }
<INITIAL>x                           {BEGIN(arg);return(SMALLX);}
<INITIAL>X                           {return(BIGX);}
<INITIAL>{word}                      {yylval = (int) malloc(yyleng);
                                        strcpy((char *)yylval, yytext);
                                        return(WORD);}
<INITIAL,arg>"="                     {return(EQUALS);}
<INITIAL,win>","                     {return(COMMA);}
<INITIAL>";"                         {return(SEMICOLON);}
<INITIAL,win>"["                     {BEGIN(win);return(LBRACK);}
<win>"]"                             {BEGIN(INITIAL); return(RBRACK);}
<INITIAL>"("                         {return(LPAREN);}
<INITIAL>"|"                         {return(BAR);}
<INITIAL>"&"                         {return(AMP);}
<INITIAL,arg>")"                     {BEGIN(INITIAL);return(RPAREN);}
<arg>{targ}                          {yylval = (int) malloc(yyleng);
                                        strcpy((char *)yylval, yytext);
                                        return(TARG);
                                     }
<win,flag>{int}                      {yylval = atoi(yytext); return(INT);}
.                                    {return(ERROR);}

%%
