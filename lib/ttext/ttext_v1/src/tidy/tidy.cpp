/*
  tidy.c - HTML TidyLib command line driver

  Copyright (c) 1998-2003 World Wide Web Consortium
  (Massachusetts Institute of Technology, European Research 
  Consortium for Informatics and Mathematics, Keio University).
  All Rights Reserved.

  CVS Info :

    $Author: terry_teague $ 
    $Date: 2004/08/03 07:15:33 $ 
    $Revision: 1.20 $ 
*/

#include <tidy.h>
#include <buffio.h>
#include <stdio.h>
#include <errno.h>
#include <tcl.h>
#include "tidy.h"
#include "ns.h"

extern "C" {



  int Tidy(ClientData clientData, Tcl_Interp *interp, int argc,const char** argv )
  {
    ctmbstr errfil = NULL;
    TidyBuffer output = {0};
    TidyBuffer errbuf = {0};
    int status = 0;

    uint contentErrors = 0;
    uint contentWarnings = 0;
    uint accessWarnings = 0;

    TidyDoc tdoc = tidyCreate();

    status = 0;

    //    Ns_Log(Notice, "ttext::tidy - called");

    /* read command line */
    while ( argc > 0 )
      {
        if (argc > 1 && argv[1][0] == '-')
	  {
            /* support -foo and --foo */
            ctmbstr arg = argv[1] + 1;
	    if ( strncmp(argv[1], "--", 2 ) == 0)
	      {
		//printf("config_option : %s\n",argv[1]+2);
                if ( tidyOptParseValue(tdoc, argv[1]+2, argv[2]) )
		  {
                    /* Set new error output stream if setting changed */
                    ctmbstr post = tidyOptGetValue( tdoc, TidyErrFile );
                    if ( post && !errfil )
		      {
                        errfil = post;
                        // errout = tidySetErrorFile( tdoc, post );
		      }

                    ++argv;
                    --argc;
		  }
	      }

            else
	      {
                uint c;
                ctmbstr s = argv[1];

                while ( c = *++s )
		  {
                    switch ( c )
		      {
		      case 'i':
                        tidyOptSetInt( tdoc, TidyIndentContent, TidyAutoState );
                        if ( tidyOptGetInt(tdoc, TidyIndentSpaces) == 0 )
			  tidyOptResetToDefault( tdoc, TidyIndentSpaces );
                        break;

			/* Usurp -o for output file.  Anyone hiding end tags?
			   case 'o':
			   tidyOptSetBool( tdoc, TidyHideEndTags, yes );
			   break;
			*/

		      case 'u':
                        tidyOptSetBool( tdoc, TidyUpperCaseTags, yes );
                        break;

		      case 'c':
                        tidyOptSetBool( tdoc, TidyMakeClean, yes );
                        break;

		      case 'b':
                        tidyOptSetBool( tdoc, TidyMakeBare, yes );
                        break;

		      case 'n':
                        tidyOptSetBool( tdoc, TidyNumEntities, yes );
                        break;

		      case 'm':
                        tidyOptSetBool( tdoc, TidyWriteBack, yes );
                        break;

		      case 'e':
                        tidyOptSetBool( tdoc, TidyShowMarkup, no );
                        break;

		      case 'q':
                        tidyOptSetBool( tdoc, TidyQuiet, yes );
                        break;

		      default:
                        //unknownOption( tdoc, c );
			return TCL_ERROR;
                        break;
		      }
		  }
	      }

            --argc;
            ++argv;
            continue;
	  }

	/* Parse from string */
	status = tidyParseString( tdoc, argv[1] );

        if ( status >= 0 )
	  status = tidyCleanAndRepair( tdoc );


        if ( status >= 0 )
	  status = tidyRunDiagnostics( tdoc );


        if ( status > 1 ) /* If errors, do we want to force output? */
	  status = ( tidyOptGetBool(tdoc, TidyForceOutput) ? status : -1 );


        contentErrors   += tidyErrorCount( tdoc );
        contentWarnings += tidyWarningCount( tdoc );
        accessWarnings  += tidyAccessWarningCount( tdoc );

        --argc;
        ++argv;

        if ( argc <= 1 )
	  break;
      }


    status = tidySaveBuffer( tdoc, &output );
    Tcl_AppendResult(interp,output.bp,NULL);
    /* called to free hash tables etc. */
    tidyRelease( tdoc );

    return TCL_OK;
  }

}  
