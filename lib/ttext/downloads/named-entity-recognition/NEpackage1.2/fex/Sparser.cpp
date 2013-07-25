/* A Bison parser, made by GNU Bison 1.875c.  */

/* Skeleton parser for Yacc-like parsing with Bison,
   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

/* Written by Richard Stallman by simplifying the original so called
   ``semantic'' parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     SENSOR = 258,
     COMPRGF = 259,
     CONJUNCT = 260,
     DISJUNCT = 261,
     WORD = 262,
     FLAG = 263,
     TARG = 264,
     INT = 265,
     COLON = 266,
     LBRACK = 267,
     RBRACK = 268,
     LPAREN = 269,
     RPAREN = 270,
     NEWLINE = 271,
     COMMA = 272,
     AMP = 273,
     BAR = 274,
     SMALLX = 275,
     BIGX = 276,
     EQUALS = 277,
     SEMICOLON = 278,
     FLOC = 279,
     FINC = 280,
     FMARK = 281,
     ERROR = 282
   };
#endif
#define SENSOR 258
#define COMPRGF 259
#define CONJUNCT 260
#define DISJUNCT 261
#define WORD 262
#define FLAG 263
#define TARG 264
#define INT 265
#define COLON 266
#define LBRACK 267
#define RBRACK 268
#define LPAREN 269
#define RPAREN 270
#define NEWLINE 271
#define COMMA 272
#define AMP 273
#define BAR 274
#define SMALLX 275
#define BIGX 276
#define EQUALS 277
#define SEMICOLON 278
#define FLOC 279
#define FINC 280
#define FMARK 281
#define ERROR 282




/* Copy the first part of user declarations.  */
#line 1 "Sparser.y"


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



/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

#if ! defined (YYSTYPE) && ! defined (YYSTYPE_IS_DECLARED)
typedef int YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 214 of yacc.c.  */
#line 178 "y.tab.c"

#if ! defined (yyoverflow) || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   define YYSTACK_ALLOC alloca
#  endif
# else
#  if defined (alloca) || defined (_ALLOCA_H)
#   define YYSTACK_ALLOC alloca
#  else
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning. */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
# else
#  if defined (__STDC__) || defined (__cplusplus)
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   define YYSIZE_T size_t
#  endif
#  define YYSTACK_ALLOC malloc
#  define YYSTACK_FREE free
# endif
#endif /* ! defined (yyoverflow) || YYERROR_VERBOSE */


#if (! defined (yyoverflow) \
     && (! defined (__cplusplus) \
	 || (defined (YYSTYPE_IS_TRIVIAL) && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  short yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (short) + sizeof (YYSTYPE))				\
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined (__GNUC__) && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  register YYSIZE_T yyi;		\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (0)
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (0)

#endif

#if defined (__STDC__) || defined (__cplusplus)
   typedef signed char yysigned_char;
#else
   typedef short yysigned_char;
#endif

/* YYFINAL -- State number of the termination state. */
#define YYFINAL  17
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   88

/* YYNTOKENS -- Number of terminals. */
#define YYNTOKENS  28
/* YYNNTS -- Number of nonterminals. */
#define YYNNTS  17
/* YYNRULES -- Number of rules. */
#define YYNRULES  38
/* YYNRULES -- Number of states. */
#define YYNSTATES  70

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   282

#define YYTRANSLATE(YYX) 						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const unsigned char yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const unsigned char yyprhs[] =
{
       0,     0,     3,     5,     9,    10,    16,    21,    23,    27,
      29,    34,    40,    44,    47,    48,    51,    53,    56,    58,
      61,    63,    64,    68,    70,    74,    76,    80,    84,    86,
      89,    94,    96,   100,   106,   107,   110,   111,   115
};

/* YYRHS -- A `-1'-separated list of the rules' RHS. */
static const yysigned_char yyrhs[] =
{
      29,     0,    -1,    30,    -1,    31,    16,    30,    -1,    -1,
      34,     6,    14,    32,    15,    -1,    34,     7,    22,    31,
      -1,    33,    -1,    32,    23,    33,    -1,    33,    -1,    34,
      39,    43,    44,    -1,    34,     5,    14,    32,    15,    -1,
      10,    35,    11,    -1,    35,    11,    -1,    -1,    26,    36,
      -1,    36,    -1,    25,    37,    -1,    37,    -1,    24,    10,
      -1,    24,    -1,    -1,    38,    17,    39,    -1,    39,    -1,
      39,    19,    40,    -1,    40,    -1,    14,    40,    15,    -1,
      40,    18,    41,    -1,    41,    -1,     7,    42,    -1,     4,
      14,    38,    15,    -1,     4,    -1,    14,    21,    15,    -1,
      14,    20,    22,     9,    15,    -1,    -1,    12,    10,    -1,
      -1,    17,    10,    13,    -1,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const unsigned short yyrline[] =
{
       0,    47,    47,    52,    67,    72,    87,    95,   102,   109,
     118,   134,   150,   157,   165,   175,   180,   186,   191,   197,
     204,   212,   219,   224,   231,   247,   254,   258,   274,   281,
     306,   330,   343,   344,   346,   348,   349,   351,   352
};
#endif

#if YYDEBUG || YYERROR_VERBOSE
/* YYTNME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals. */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "SENSOR", "COMPRGF", "CONJUNCT",
  "DISJUNCT", "WORD", "FLAG", "TARG", "INT", "COLON", "LBRACK", "RBRACK",
  "LPAREN", "RPAREN", "NEWLINE", "COMMA", "AMP", "BAR", "SMALLX", "BIGX",
  "EQUALS", "SEMICOLON", "FLOC", "FINC", "FMARK", "ERROR", "$accept",
  "File", "LineList", "Line", "LineItemList", "LineItem", "OptTarg",
  "FlagList", "FlagList2", "LocPart", "Stmt", "Disj", "Conj", "Expr",
  "OptArg", "LeftOff", "RightOff", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const unsigned short yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const unsigned char yyr1[] =
{
       0,    28,    29,    30,    30,    31,    31,    31,    32,    32,
      33,    33,    34,    34,    34,    35,    35,    36,    36,    37,
      37,    37,    38,    38,    39,    39,    40,    40,    40,    41,
      41,    41,    42,    42,    42,    43,    43,    44,    44
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const unsigned char yyr2[] =
{
       0,     2,     1,     3,     0,     5,     4,     1,     3,     1,
       4,     5,     3,     2,     0,     2,     1,     2,     1,     2,
       1,     0,     3,     1,     3,     1,     3,     3,     1,     2,
       4,     1,     3,     5,     0,     2,     0,     3,     0
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const unsigned char yydefact[] =
{
      14,    21,    20,    21,    21,     0,     2,     0,     7,     0,
       0,    16,    18,     0,    19,    17,    15,     1,    14,    31,
       0,     0,    34,     0,    36,    25,    28,    13,    12,     3,
       0,    14,    14,     0,    14,    29,    34,     0,     0,     0,
      38,     0,     0,    23,     0,     9,     0,     0,     0,     0,
       6,    26,    35,    24,     0,    10,    27,    30,     0,    11,
      14,     5,     0,    32,     0,    22,     8,     0,    37,    33
};

/* YYDEFGOTO[NTERM-NUM]. */
static const yysigned_char yydefgoto[] =
{
      -1,     5,     6,     7,    44,     8,     9,    10,    11,    12,
      42,    24,    25,    26,    35,    40,    55
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -32
static const yysigned_char yypact[] =
{
       9,    28,    -4,   -12,    35,    38,   -32,    39,   -32,    10,
      14,   -32,   -32,    46,   -32,   -32,   -32,   -32,     9,    29,
      47,    48,    -9,    32,    -1,    45,   -32,   -32,   -32,   -32,
      32,    -3,    -3,    30,    -3,   -32,    50,    27,    55,    32,
      49,    40,    41,    51,    25,   -32,    23,    26,    52,    53,
     -32,   -32,   -32,    45,    57,   -32,   -32,   -32,    32,   -32,
      -3,   -32,    60,   -32,    58,    51,   -32,    61,   -32,   -32
};

/* YYPGOTO[NTERM-NUM].  */
static const yysigned_char yypgoto[] =
{
     -32,   -32,    54,    43,    56,   -31,   -29,    72,    71,    75,
     -32,   -26,   -13,    42,   -32,   -32,   -32
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -22
static const yysigned_char yytable[] =
{
      45,    45,    46,    46,    43,    33,    14,     1,   -21,    -4,
      37,    38,     2,    34,    19,    20,    21,    22,    39,     1,
     -21,     2,     3,     4,    23,    27,    53,    19,    20,    66,
      36,    46,    65,     2,     3,     4,    19,    23,    17,    36,
      59,    61,    51,    30,    19,    41,    23,    36,    60,    60,
      48,    49,     2,     3,     4,    18,    57,    28,    58,     2,
       3,    31,    32,    41,    33,    52,    54,    64,    63,    67,
      39,    68,    29,    13,    62,    16,    69,    50,    15,     0,
       0,     0,     0,    56,     0,     0,     0,     0,    47
};

static const yysigned_char yycheck[] =
{
      31,    32,    31,    32,    30,    14,    10,    10,    11,     0,
      23,    12,    24,    22,     4,     5,     6,     7,    19,    10,
      11,    24,    25,    26,    14,    11,    39,     4,     5,    60,
       7,    60,    58,    24,    25,    26,     4,    14,     0,     7,
      15,    15,    15,    14,     4,    18,    14,     7,    23,    23,
      20,    21,    24,    25,    26,    16,    15,    11,    17,    24,
      25,    14,    14,    18,    14,    10,    17,    10,    15,     9,
      19,    13,    18,     1,    22,     4,    15,    34,     3,    -1,
      -1,    -1,    -1,    41,    -1,    -1,    -1,    -1,    32
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const unsigned char yystos[] =
{
       0,    10,    24,    25,    26,    29,    30,    31,    33,    34,
      35,    36,    37,    35,    10,    37,    36,     0,    16,     4,
       5,     6,     7,    14,    39,    40,    41,    11,    11,    30,
      14,    14,    14,    14,    22,    42,     7,    40,    12,    19,
      43,    18,    38,    39,    32,    33,    34,    32,    20,    21,
      31,    15,    10,    40,    17,    44,    41,    15,    17,    15,
      23,    15,    22,    15,    10,    39,    33,     9,    13,    15
};

#if ! defined (YYSIZE_T) && defined (__SIZE_TYPE__)
# define YYSIZE_T __SIZE_TYPE__
#endif
#if ! defined (YYSIZE_T) && defined (size_t)
# define YYSIZE_T size_t
#endif
#if ! defined (YYSIZE_T)
# if defined (__STDC__) || defined (__cplusplus)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# endif
#endif
#if ! defined (YYSIZE_T)
# define YYSIZE_T unsigned int
#endif

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { 								\
      yyerror ("syntax error: cannot back up");\
      YYERROR;							\
    }								\
while (0)

#define YYTERROR	1
#define YYERRCODE	256

/* YYLLOC_DEFAULT -- Compute the default location (before the actions
   are run).  */

#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)		\
   ((Current).first_line   = (Rhs)[1].first_line,	\
    (Current).first_column = (Rhs)[1].first_column,	\
    (Current).last_line    = (Rhs)[N].last_line,	\
    (Current).last_column  = (Rhs)[N].last_column)
#endif

/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (0)

# define YYDSYMPRINT(Args)			\
do {						\
  if (yydebug)					\
    yysymprint Args;				\
} while (0)

# define YYDSYMPRINTF(Title, Token, Value, Location)		\
do {								\
  if (yydebug)							\
    {								\
      YYFPRINTF (stderr, "%s ", Title);				\
      yysymprint (stderr, 					\
                  Token, Value);	\
      YYFPRINTF (stderr, "\n");					\
    }								\
} while (0)

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_stack_print (short *bottom, short *top)
#else
static void
yy_stack_print (bottom, top)
    short *bottom;
    short *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (/* Nothing. */; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yy_reduce_print (int yyrule)
#else
static void
yy_reduce_print (yyrule)
    int yyrule;
#endif
{
  int yyi;
  unsigned int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %u), ",
             yyrule - 1, yylno);
  /* Print the symbols being reduced, and their result.  */
  for (yyi = yyprhs[yyrule]; 0 <= yyrhs[yyi]; yyi++)
    YYFPRINTF (stderr, "%s ", yytname [yyrhs[yyi]]);
  YYFPRINTF (stderr, "-> %s\n", yytname [yyr1[yyrule]]);
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (Rule);		\
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YYDSYMPRINT(Args)
# define YYDSYMPRINTF(Title, Token, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   SIZE_MAX < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#if defined (YYMAXDEPTH) && YYMAXDEPTH == 0
# undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined (__GLIBC__) && defined (_STRING_H)
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
static YYSIZE_T
#   if defined (__STDC__) || defined (__cplusplus)
yystrlen (const char *yystr)
#   else
yystrlen (yystr)
     const char *yystr;
#   endif
{
  register const char *yys = yystr;

  while (*yys++ != '\0')
    continue;

  return yys - yystr - 1;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined (__GLIBC__) && defined (_STRING_H) && defined (_GNU_SOURCE)
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
static char *
#   if defined (__STDC__) || defined (__cplusplus)
yystpcpy (char *yydest, const char *yysrc)
#   else
yystpcpy (yydest, yysrc)
     char *yydest;
     const char *yysrc;
#   endif
{
  register char *yyd = yydest;
  register const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

#endif /* !YYERROR_VERBOSE */



#if YYDEBUG
/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yysymprint (FILE *yyoutput, int yytype, YYSTYPE *yyvaluep)
#else
static void
yysymprint (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;

  if (yytype < YYNTOKENS)
    {
      YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
# ifdef YYPRINT
      YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# endif
    }
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  switch (yytype)
    {
      default:
        break;
    }
  YYFPRINTF (yyoutput, ")");
}

#endif /* ! YYDEBUG */
/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

#if defined (__STDC__) || defined (__cplusplus)
static void
yydestruct (int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yytype, yyvaluep)
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  /* Pacify ``unused variable'' warnings.  */
  (void) yyvaluep;

  switch (yytype)
    {

      default:
        break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM);
# else
int yyparse ();
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */



/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
# if defined (__STDC__) || defined (__cplusplus)
int yyparse (void *YYPARSE_PARAM)
# else
int yyparse (YYPARSE_PARAM)
  void *YYPARSE_PARAM;
# endif
#else /* ! YYPARSE_PARAM */
#if defined (__STDC__) || defined (__cplusplus)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  
  register int yystate;
  register int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken = 0;

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  short	yyssa[YYINITDEPTH];
  short *yyss = yyssa;
  register short *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  register YYSTYPE *yyvsp;



#define YYPOPSTACK   (yyvsp--, yyssp--)

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* When reducing, the number of symbols on the RHS of the reduced
     rule.  */
  int yylen;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed. so pushing a state here evens the stacks.
     */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack. Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	short *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow ("parser stack overflow",
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyoverflowlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyoverflowlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	short *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyoverflowlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YYDSYMPRINTF ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */
  YYDPRINTF ((stderr, "Shifting token %s, ", yytname[yytoken]));

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;


  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  yystate = yyn;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
#line 48 "Sparser.y"
    {
             script = (SubRGF*)yyvsp[0]; 
          }
    break;

  case 3:
#line 53 "Sparser.y"
    {
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "linelist" << endl; 
            if(yyvsp[-2])
               if(((RGF*)yyvsp[-2])->Mode() == EXTRACT_LABEL)
                  ((SubRGF*)yyvsp[0])->insert(((SubRGF*)yyvsp[0])->begin(),
                                             *(RGF*)yyvsp[-2]);
               else 
               {
                  ((SubRGF*)yyvsp[0])->push_back(*(RGF*)yyvsp[-2]);
//                  delete (RGF*)$1;
               }   
            yyval = yyvsp[0];
         }
    break;

  case 4:
#line 67 "Sparser.y"
    {
            SubRGF* temp = new SubRGF(); 
            yyval = (int)temp;
          }
    break;

  case 5:
#line 73 "Sparser.y"
    {
         if(globalParams.verbosity >= VERBOSE_CRAZY)
           cout << "line" << endl;
         RGF *compExpr = new RGF(*(SubRGF*)yyvsp[-1]);
         compExpr->Mode(EXTRACT_DISJUNCT);
         compExpr->Target(((TargInfo*)yyvsp[-4])->targ); 
         compExpr->LeftOffset(-1); 
         compExpr->RightOffset(-1); 
         compExpr->IncludeMark(((TargInfo*)yyvsp[-4])->mark);
         compExpr->IncludeTarget(((TargInfo*)yyvsp[-4])->inc); 
         compExpr->IncludeLocation(((TargInfo*)yyvsp[-4])->loc);
         compExpr->LocationOffset(((TargInfo*)yyvsp[-4])->offset);
         yyval = (int)compExpr;
      }
    break;

  case 6:
#line 88 "Sparser.y"
    {
         if(globalParams.verbosity >= VERBOSE_CRAZY)
           cout << "line" << endl;
         ((RGF*)yyvsp[0])->Mask((char*)yyvsp[-2]);
         Mnemonics.insert(pair<string, RGF>((char*)yyvsp[-2], *(RGF*)yyvsp[0]));
         yyval = 0; 
      }
    break;

  case 7:
#line 96 "Sparser.y"
    {
         if(globalParams.verbosity >= VERBOSE_CRAZY)
           cout << "line" << endl;
         yyval = yyvsp[0];
      }
    break;

  case 8:
#line 103 "Sparser.y"
    {
                 if(globalParams.verbosity >= VERBOSE_CRAZY)
                   cout << "lineitemlist" << endl;
                 ((SubRGF*)yyvsp[-2])->push_back(*(RGF*)yyvsp[0]);
                 yyval = yyvsp[-2];
              }
    break;

  case 9:
#line 110 "Sparser.y"
    {
                 if(globalParams.verbosity >= VERBOSE_CRAZY)
             	     cout << "lineitemlist" << endl;
                 SubRGF* sub = new SubRGF();
                 sub->push_back(*(RGF*)yyvsp[0]); 
                 yyval = (int)sub; 
              }
    break;

  case 10:
#line 119 "Sparser.y"
    {
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "lineitem" << endl;
            ((RGF*)yyvsp[-2])->Target(((TargInfo*)yyvsp[-3])->targ); 
            ((RGF*)yyvsp[-2])->LeftOffset(yyvsp[-1]); 
            ((RGF*)yyvsp[-2])->RightOffset(yyvsp[0]); 
            ((RGF*)yyvsp[-2])->IncludeMark(((TargInfo*)yyvsp[-3])->mark);
            if(((RGF*)yyvsp[-2])->Mode() == EXTRACT_LABEL)
               ((RGF*)yyvsp[-2])->IncludeTargetRecur(true); 
            else
               ((RGF*)yyvsp[-2])->IncludeTargetRecur(((TargInfo*)yyvsp[-3])->inc); 
            ((RGF*)yyvsp[-2])->IncludeLocation(((TargInfo*)yyvsp[-3])->loc);
            ((RGF*)yyvsp[-2])->LocationOffset(((TargInfo*)yyvsp[-3])->offset);
            yyval = yyvsp[-2]; 
          }
    break;

  case 11:
#line 135 "Sparser.y"
    {
             if(globalParams.verbosity >= VERBOSE_CRAZY)
               cout << "conjlineitem" << endl;
             RGF *compExpr = new RGF(*(SubRGF*)yyvsp[-1]);
             compExpr->Mode(EXTRACT_CONJUNCT);
             compExpr->Target(((TargInfo*)yyvsp[-4])->targ); 
             compExpr->LeftOffset(-1); 
             compExpr->RightOffset(-1); 
             compExpr->IncludeMark(((TargInfo*)yyvsp[-4])->mark);
             compExpr->IncludeTarget(((TargInfo*)yyvsp[-4])->inc); 
             compExpr->IncludeLocation(((TargInfo*)yyvsp[-4])->loc);
             compExpr->LocationOffset(((TargInfo*)yyvsp[-4])->offset);
             yyval = (int)compExpr;
          }
    break;

  case 12:
#line 151 "Sparser.y"
    {
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "opttarg" << endl;
            ((TargInfo*)yyvsp[-1])->targ = (char*)yyvsp[-2];
            yyval = yyvsp[-1];
          }
    break;

  case 13:
#line 158 "Sparser.y"
    { 
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "opttarg" << endl;
            ((TargInfo*)yyvsp[0])->targ = "-1";
            yyval = yyvsp[0];
          }
    break;

  case 14:
#line 165 "Sparser.y"
    {
            TargInfo *pTargI = new TargInfo;
            pTargI->targ = "-1";
            pTargI->mark = false;
            pTargI->inc = false;
            pTargI->loc = false;
            pTargI->offset = 0;
            yyval = (int) pTargI;
         }
    break;

  case 15:
#line 176 "Sparser.y"
    { 
             ((TargInfo*)yyvsp[0])->mark = true;
             yyval = yyvsp[0]; 
           }
    break;

  case 16:
#line 181 "Sparser.y"
    {
             ((TargInfo*)yyvsp[0])->mark = false;
             yyval = yyvsp[0]; 
           }
    break;

  case 17:
#line 187 "Sparser.y"
    { 
              ((TargInfo*)yyvsp[0])->inc = true;
              yyval = yyvsp[0];
            }
    break;

  case 18:
#line 192 "Sparser.y"
    {
              ((TargInfo*)yyvsp[0])->inc = false;
              yyval = yyvsp[0]; 
            }
    break;

  case 19:
#line 198 "Sparser.y"
    { 
            TargInfo *pTargI = new TargInfo;
            pTargI->loc = true;
            pTargI->offset = yyvsp[0];
            yyval = (int) pTargI;
          }
    break;

  case 20:
#line 205 "Sparser.y"
    {
            TargInfo *pTargI = new TargInfo;
            pTargI->loc = true;
            pTargI->offset = 0;
            yyval = (int) pTargI;
          }
    break;

  case 21:
#line 212 "Sparser.y"
    {
            TargInfo *pTargI = new TargInfo;
            pTargI->loc = false;
            pTargI->offset = 0;
            yyval = (int) pTargI;
          }
    break;

  case 22:
#line 220 "Sparser.y"
    {
             ((SubRGF*)yyvsp[-2])->push_back(*(RGF*)yyvsp[0]);
             yyval = yyvsp[-2];
          }
    break;

  case 23:
#line 225 "Sparser.y"
    {
             SubRGF* sub = new SubRGF();
             sub->push_back(*(RGF*)yyvsp[0]); 
             yyval = (int)sub; 
          }
    break;

  case 24:
#line 232 "Sparser.y"
    {  
             if(((RGF*)yyvsp[-2])->Mode() == EXTRACT_DISJ)
             {
               ((RGF*)yyvsp[-2])->Insert(*(RGF*)yyvsp[0]);
               yyval = yyvsp[-2];
             }
             else
             { 
               RGF* disj = new RGF();
               disj->Mode(EXTRACT_DISJ);
               disj->Insert(*(RGF*)yyvsp[-2]);
               disj->Insert(*(RGF*)yyvsp[0]);
               yyval = (int)disj;
             }
          }
    break;

  case 25:
#line 248 "Sparser.y"
    {
             if(globalParams.verbosity >= VERBOSE_CRAZY)
               cout << "disj" << endl;
             yyval = yyvsp[0];
          }
    break;

  case 26:
#line 255 "Sparser.y"
    { 
             yyval = yyvsp[-1]; 
          }
    break;

  case 27:
#line 259 "Sparser.y"
    { 
             if(((RGF*)yyvsp[-2])->Mode() == EXTRACT_CONJ)
             {
               ((RGF*)yyvsp[-2])->Insert(*(RGF*)yyvsp[0]);
               yyval = yyvsp[-2];
             }
             else
             {
               RGF* conj = new RGF();
               conj->Mode(EXTRACT_CONJ); 
               conj->Insert(*(RGF*)yyvsp[-2]);
               conj->Insert(*(RGF*)yyvsp[0]);
               yyval = (int)conj;
             }
          }
    break;

  case 28:
#line 275 "Sparser.y"
    {    
             if(globalParams.verbosity >= VERBOSE_CRAZY)
               cout << "conj" << endl;
             yyval = yyvsp[0]; 
          }
    break;

  case 29:
#line 282 "Sparser.y"
    { 
            if(globalParams.verbosity >= VERBOSE_CRAZY)
              cout << "sensor" << endl;
            RGF *primExpr;
            // try to find it in the mnemonics map first
            if(Mnemonics.find((char*)yyvsp[-1]) != Mnemonics.end())
            {
               primExpr = new RGF(Mnemonics[(char*)yyvsp[-1]]);
            }
            else
            {
               //create Sensor RGF obj for this expression
               primExpr = new RGF((char*)yyvsp[-1]);
            }

            //set the generic/specific feature mode
            if(yyvsp[0] < 0)
               primExpr->GenFeature(true);
            else
               if(yyvsp[0])
                  primExpr->Param((char*)yyvsp[0]);

             yyval = (int)primExpr;
          }
    break;

  case 30:
#line 307 "Sparser.y"
    { 
             RGF *compExpr = new RGF(*(SubRGF*)yyvsp[-1]);
             switch (yyvsp[-3])
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
             yyval = (int)compExpr;
          }
    break;

  case 31:
#line 331 "Sparser.y"
    {
             // no parentheses and other sensors after "lab"
             // used only for phrase case
             // Added by Scott Yih, 09/27/01
             if (yyvsp[0] == T_LABEL) {
               RGF *compExpr = new RGF();
               compExpr->Mode(EXTRACT_LABEL);
               yyval = (int)compExpr;
             }
           }
    break;

  case 32:
#line 343 "Sparser.y"
    { yyval = -1; }
    break;

  case 33:
#line 345 "Sparser.y"
    { yyval = yyvsp[-1]; }
    break;

  case 34:
#line 346 "Sparser.y"
    { yyval = 0; }
    break;

  case 35:
#line 348 "Sparser.y"
    { yyval = yyvsp[0]; }
    break;

  case 36:
#line 349 "Sparser.y"
    { yyval = RANGE_ALL; }
    break;

  case 37:
#line 351 "Sparser.y"
    { yyval = yyvsp[-1]; }
    break;

  case 38:
#line 352 "Sparser.y"
    { yyval = RANGE_ALL;}
    break;


    }

/* Line 993 of yacc.c.  */
#line 1516 "y.tab.c"

  yyvsp -= yylen;
  yyssp -= yylen;


  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (YYPACT_NINF < yyn && yyn < YYLAST)
	{
	  YYSIZE_T yysize = 0;
	  int yytype = YYTRANSLATE (yychar);
	  const char* yyprefix;
	  char *yymsg;
	  int yyx;

	  /* Start YYX at -YYN if negative to avoid negative indexes in
	     YYCHECK.  */
	  int yyxbegin = yyn < 0 ? -yyn : 0;

	  /* Stay within bounds of both yycheck and yytname.  */
	  int yychecklim = YYLAST - yyn;
	  int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
	  int yycount = 0;

	  yyprefix = ", expecting ";
	  for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	      {
		yysize += yystrlen (yyprefix) + yystrlen (yytname [yyx]);
		yycount += 1;
		if (yycount == 5)
		  {
		    yysize = 0;
		    break;
		  }
	      }
	  yysize += (sizeof ("syntax error, unexpected ")
		     + yystrlen (yytname[yytype]));
	  yymsg = (char *) YYSTACK_ALLOC (yysize);
	  if (yymsg != 0)
	    {
	      char *yyp = yystpcpy (yymsg, "syntax error, unexpected ");
	      yyp = yystpcpy (yyp, yytname[yytype]);

	      if (yycount < 5)
		{
		  yyprefix = ", expecting ";
		  for (yyx = yyxbegin; yyx < yyxend; ++yyx)
		    if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
		      {
			yyp = yystpcpy (yyp, yyprefix);
			yyp = yystpcpy (yyp, yytname[yyx]);
			yyprefix = " or ";
		      }
		}
	      yyerror (yymsg);
	      YYSTACK_FREE (yymsg);
	    }
	  else
	    yyerror ("syntax error; also virtual memory exhausted");
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror ("syntax error");
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* If at end of input, pop the error token,
	     then the rest of the stack, then return failure.  */
	  if (yychar == YYEOF)
	     for (;;)
	       {
		 YYPOPSTACK;
		 if (yyssp == yyss)
		   YYABORT;
		 YYDSYMPRINTF ("Error: popping", yystos[*yyssp], yyvsp, yylsp);
		 yydestruct (yystos[*yyssp], yyvsp);
	       }
        }
      else
	{
	  YYDSYMPRINTF ("Error: discarding", yytoken, &yylval, &yylloc);
	  yydestruct (yytoken, &yylval);
	  yychar = YYEMPTY;

	}
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

#ifdef __GNUC__
  /* Pacify GCC when the user code never invokes YYERROR and the label
     yyerrorlab therefore never appears in user code.  */
  if (0)
     goto yyerrorlab;
#endif

  yyvsp -= yylen;
  yyssp -= yylen;
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;

      YYDSYMPRINTF ("Error: popping", yystos[*yyssp], yyvsp, yylsp);
      yydestruct (yystos[yystate], yyvsp);
      YYPOPSTACK;
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  YYDPRINTF ((stderr, "Shifting error token, "));

  *++yyvsp = yylval;


  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*----------------------------------------------.
| yyoverflowlab -- parser overflow comes here.  |
`----------------------------------------------*/
yyoverflowlab:
  yyerror ("parser stack overflow");
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
  return yyresult;
}


#line 354 "Sparser.y"


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

