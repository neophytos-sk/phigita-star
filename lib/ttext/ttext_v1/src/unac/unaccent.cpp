#ifdef HAVE_CONFIG_H
#include "config.h"
#endif /* HAVE_CONFIG_H */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <tcl.h>

#include <unac.h>

extern "C" {

int Unaccent(ClientData clientData,Tcl_Interp *interp,int argc,const char* argv[]) {
  
    if (argc < 3) 
    {
	Tcl_AddErrorInfo(interp,"wrong # args : should be \"ttext::unaccent charset string\"");
	return TCL_ERROR;
    }
    
    const char* charset = argv[1];
    const char* string = argv[2];

    char* unaccented = 0;
    int unaccented_length = 0;
   
    if(unac_string(charset, string, strlen(string), &unaccented,(size_t*) &unaccented_length) < 0) {
	Tcl_AddErrorInfo(interp,"unaccent: attemp to unaccent with the specified charset failed");
	return TCL_ERROR;
    }
     
    Tcl_AppendResult(interp,unaccented,NULL);
    //printf("%.*s\n", unaccented_length, unaccented);
    free(unaccented);
    
    return TCL_OK;
}

}
