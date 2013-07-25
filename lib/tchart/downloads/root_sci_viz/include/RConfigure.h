#ifndef ROOT_RConfigure
#define ROOT_RConfigure

/* Configurations file for linuxx8664gcc */
#ifdef R__HAVE_CONFIG
#define ROOTPREFIX    "$(ROOTSYS)"
#define ROOTBINDIR    "$(ROOTSYS)/bin"
#define ROOTLIBDIR    "$(ROOTSYS)/lib"
#define ROOTINCDIR    "$(ROOTSYS)/include"
#define ROOTETCDIR    "$(ROOTSYS)/etc"
#define ROOTDATADIR   "$(ROOTSYS)"
#define ROOTDOCDIR    "$(ROOTSYS)"
#define ROOTMACRODIR  "$(ROOTSYS)/macros"
#define ROOTSRCDIR    "$(ROOTSYS)/src"
#define ROOTICONPATH  "$(ROOTSYS)/icons"
#define EXTRAICONPATH ""
#define TTFFONTDIR    "$(ROOTSYS)/fonts"
#define CINTINCDIR    "$(ROOTSYS)/cint"
#endif

#define R__HAS_SETRESUID   /**/
#define R__HAS_MATHMORE   /**/
#define R__HAS_PTHREAD    /**/
#define R__HAS_XFT    /**/
#undef R__HAS_CLING   /**/

#endif
