%{

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <vector>
#include <map>
#include "Flex.h"
#include "Sparser.h"
#include "FexParams.h"
#include "RGF.h"

void openFiles(const char *inFile);
void closeFiles();

static SubRGF *script;
static map<string, RGF> Mnemonics;

struct TargInfo
{
   char* targ;
   bool loc;
   int  offset;
   bool inc;
   bool mark;
};

#ifdef YYBISON
int yylex();
int yyerror (char *s)
{
  fprintf (stderr, "%s\n", s);
}
#endif

%}

%token SENSOR COMPRGF CONJUNCT DISJUNCT
%token WORD FLAG TARG INT COLON LBRACK RBRACK LPAREN RPAREN NEWLINE
%token COMMA AMP BAR SMALLX BIGX EQUALS SEMICOLON
%token FLOC FINC FMARK ERROR

%start File

%%

File    : LineList      
          {
             script = (SubRGF*)$1; 
          }

LineList: Line NEWLINE LineList        
         {
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "linelist" << endl; 
            if($1)
               if(((RGF*)$1)->Mode() == EXTRACT_LABEL)
                  ((SubRGF*)$3)->insert(((SubRGF*)$3)->begin(),
                                             *(RGF*)$1);
               else 
               {
                  ((SubRGF*)$3)->push_back(*(RGF*)$1);
//                  delete (RGF*)$1;
               }   
            $$ = $3;
         } 
        | {
            SubRGF* temp = new SubRGF(); 
            $$ = (int)temp;
          }

Line: OptTarg DISJUNCT LPAREN LineItemList RPAREN
      {
         if(globalParams.verbosity >= VERBOSE_CRAZY)
           cout << "line" << endl;
         RGF *compExpr = new RGF(*(SubRGF*)$4);
         compExpr->Mode(EXTRACT_DISJUNCT);
         compExpr->Target(((TargInfo*)$1)->targ); 
         compExpr->LeftOffset(-1); 
         compExpr->RightOffset(-1); 
         compExpr->IncludeMark(((TargInfo*)$1)->mark);
         compExpr->IncludeTarget(((TargInfo*)$1)->inc); 
         compExpr->IncludeLocation(((TargInfo*)$1)->loc);
         compExpr->LocationOffset(((TargInfo*)$1)->offset);
         $$ = (int)compExpr;
      }      
    | OptTarg WORD EQUALS Line
      {
         if(globalParams.verbosity >= VERBOSE_CRAZY)
           cout << "line" << endl;
         ((RGF*)$4)->Mask((char*)$2);
         Mnemonics.insert(pair<string, RGF>((char*)$2, *(RGF*)$4));
         $$ = 0; 
      }
    | LineItem
      {
         if(globalParams.verbosity >= VERBOSE_CRAZY)
           cout << "line" << endl;
         $$ = $1;
      }

LineItemList: LineItemList SEMICOLON LineItem
              {
                 if(globalParams.verbosity >= VERBOSE_CRAZY)
                   cout << "lineitemlist" << endl;
                 ((SubRGF*)$1)->push_back(*(RGF*)$3);
                 $$ = $1;
              }
            | LineItem
              {
                 if(globalParams.verbosity >= VERBOSE_CRAZY)
             	     cout << "lineitemlist" << endl;
                 SubRGF* sub = new SubRGF();
                 sub->push_back(*(RGF*)$1); 
                 $$ = (int)sub; 
              }

LineItem: OptTarg Disj LeftOff RightOff    
          {
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "lineitem" << endl;
            ((RGF*)$2)->Target(((TargInfo*)$1)->targ); 
            ((RGF*)$2)->LeftOffset($3); 
            ((RGF*)$2)->RightOffset($4); 
            ((RGF*)$2)->IncludeMark(((TargInfo*)$1)->mark);
            if(((RGF*)$2)->Mode() == EXTRACT_LABEL)
               ((RGF*)$2)->IncludeTargetRecur(true); 
            else
               ((RGF*)$2)->IncludeTargetRecur(((TargInfo*)$1)->inc); 
            ((RGF*)$2)->IncludeLocation(((TargInfo*)$1)->loc);
            ((RGF*)$2)->LocationOffset(((TargInfo*)$1)->offset);
            $$ = $2; 
          }
        | OptTarg CONJUNCT LPAREN LineItemList RPAREN
          {
             if(globalParams.verbosity >= VERBOSE_CRAZY)
               cout << "conjlineitem" << endl;
             RGF *compExpr = new RGF(*(SubRGF*)$4);
             compExpr->Mode(EXTRACT_CONJUNCT);
             compExpr->Target(((TargInfo*)$1)->targ); 
             compExpr->LeftOffset(-1); 
             compExpr->RightOffset(-1); 
             compExpr->IncludeMark(((TargInfo*)$1)->mark);
             compExpr->IncludeTarget(((TargInfo*)$1)->inc); 
             compExpr->IncludeLocation(((TargInfo*)$1)->loc);
             compExpr->LocationOffset(((TargInfo*)$1)->offset);
             $$ = (int)compExpr;
          }      

OptTarg : INT FlagList COLON
          {
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "opttarg" << endl;
            ((TargInfo*)$2)->targ = (char*)$1;
            $$ = $2;
          }
        | FlagList COLON
          { 
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "opttarg" << endl;
            ((TargInfo*)$2)->targ = "-1";
            $$ = $2;
          }
        | 
         {
            TargInfo *pTargI = new TargInfo;
            pTargI->targ = "-1";
            pTargI->mark = false;
            pTargI->inc = false;
            pTargI->loc = false;
            pTargI->offset = 0;
            $$ = (int) pTargI;
         }

FlagList : FMARK FlagList2
           { 
             ((TargInfo*)$2)->mark = true;
             $$ = $2; 
           }
         | FlagList2
           {
             ((TargInfo*)$1)->mark = false;
             $$ = $1; 
           }

FlagList2 : FINC LocPart 
            { 
              ((TargInfo*)$2)->inc = true;
              $$ = $2;
            }
         | LocPart
            {
              ((TargInfo*)$1)->inc = false;
              $$ = $1; 
            }

LocPart : FLOC INT
          { 
            TargInfo *pTargI = new TargInfo;
            pTargI->loc = true;
            pTargI->offset = $2;
            $$ = (int) pTargI;
          }
        | FLOC
          {
            TargInfo *pTargI = new TargInfo;
            pTargI->loc = true;
            pTargI->offset = 0;
            $$ = (int) pTargI;
          }
        |
          {
            TargInfo *pTargI = new TargInfo;
            pTargI->loc = false;
            pTargI->offset = 0;
            $$ = (int) pTargI;
          }
               
Stmt    : Stmt COMMA Disj 
          {
             ((SubRGF*)$1)->push_back(*(RGF*)$3);
             $$ = $1;
          }
        | Disj              
          {
             SubRGF* sub = new SubRGF();
             sub->push_back(*(RGF*)$1); 
             $$ = (int)sub; 
          }
          
Disj    : Disj BAR Conj
          {  
             if(((RGF*)$1)->Mode() == EXTRACT_DISJ)
             {
               ((RGF*)$1)->Insert(*(RGF*)$3);
               $$ = $1;
             }
             else
             { 
               RGF* disj = new RGF();
               disj->Mode(EXTRACT_DISJ);
               disj->Insert(*(RGF*)$1);
               disj->Insert(*(RGF*)$3);
               $$ = (int)disj;
             }
          }
        | Conj 
          {
             if(globalParams.verbosity >= VERBOSE_CRAZY)
               cout << "disj" << endl;
             $$ = $1;
          }

Conj    : LPAREN Conj RPAREN
          { 
             $$ = $2; 
          }
        | Conj AMP Expr
          { 
             if(((RGF*)$1)->Mode() == EXTRACT_CONJ)
             {
               ((RGF*)$1)->Insert(*(RGF*)$3);
               $$ = $1;
             }
             else
             {
               RGF* conj = new RGF();
               conj->Mode(EXTRACT_CONJ); 
               conj->Insert(*(RGF*)$1);
               conj->Insert(*(RGF*)$3);
               $$ = (int)conj;
             }
          }
        | Expr
          {    
             if(globalParams.verbosity >= VERBOSE_CRAZY)
               cout << "conj" << endl;
             $$ = $1; 
          }

Expr    : WORD OptArg 
          { 
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "sensor" << endl;
            RGF *primExpr;
            // try to find it in the mnemonics map first
            if(Mnemonics.find((char*)$1) != Mnemonics.end())
            {
               primExpr = new RGF(Mnemonics[(char*)$1]);
            }
            else
            {
               //create Sensor RGF obj for this expression
               primExpr = new RGF((char*)$1);
            }

            //set the generic/specific feature mode
            if($2 < 0)
               primExpr->GenFeature(true);
            else
               if($2)
                  primExpr->Param((char*)$2);

             $$ = (int)primExpr;
          }
        | COMPRGF LPAREN Stmt RPAREN 
          { 
             RGF *compExpr = new RGF(*(SubRGF*)$3);
             switch ($1)
             {
             case T_COLOC:
                compExpr->Mode(EXTRACT_COLOC);
                break;
             case T_SCOLOC:
                compExpr->Mode(EXTRACT_SCOLOC);
                break;
             case T_LINK:
                compExpr->Mode(EXTRACT_LINK);
                break;
             case T_LABEL:
                compExpr->Mode(EXTRACT_LABEL);
                break;
             case T_NOT:
                compExpr->Mode(EXTRACT_NOT);
                compExpr->Mask("not");
                break;
             }
             $$ = (int)compExpr;
          }
         | COMPRGF 
           {
             // no parentheses and other sensors after "lab"
             // used only for phrase case
             // Added by Scott Yih, 09/27/01
             if ($1 == T_LABEL) {
               RGF *compExpr = new RGF();
               compExpr->Mode(EXTRACT_LABEL);
               $$ = (int)compExpr;
             }
           }


OptArg : LPAREN BIGX RPAREN           { $$ = -1; } 
         | LPAREN SMALLX EQUALS TARG RPAREN
                                   { $$ = $4; }
         |                         { $$ = 0; }                  

LeftOff : LBRACK INT  { $$ = $2; }
        |             { $$ = RANGE_ALL; }
        
RightOff : COMMA INT RBRACK  { $$ = $2; }
         |                   { $$ = RANGE_ALL;}

%%

SubRGF* DoParse(const char *scriptFile) {
    int result; 

    openFiles(scriptFile);
    result = yyparse();
    closeFiles();
    if(!result)
       return script;
    else
       return 0;
}

void openFiles(const char *inFile) {
    FILE *tmp;
    if ((tmp = fopen(inFile, "r")) == NULL) {
        fprintf(stderr, "could not open %s for input.\n", inFile);
        exit(1);
    }
    fclose(tmp);
    freopen(inFile, "r", stdin);
    return;
}

void closeFiles() {
    fclose(stdin);
   // fclose(stdout);
}

void yyerror(char const *msg) {
    fprintf(stderr, "\nerror: on line %d: %s\n", lineno, msg);
}
