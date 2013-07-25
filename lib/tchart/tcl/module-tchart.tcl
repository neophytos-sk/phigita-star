package provide tchart 0.1

::xo::lib::require critcl

set dir [file dirname [info script]]

::critcl::reset
::critcl::config outdir /web/local-data/critcl/
::critcl::cache /web/local-data/critcl/cache/
::critcl::config force [::xo::kit::debug_mode_p]
::critcl::config keepsrc 1
::critcl::clibraries -L/opt/naviserver/lib -lgd -lm

::critcl::config I /opt/naviserver/include
::critcl::config I [file join $dir ../cc]

::critcl::csources [file join $dir ../cc/chart.cc]
::critcl::cheaders [file join $dir ../cc/chart.h]

if { [::xo::kit::debug_mode_p] } {
    ::critcl::cflags -DDEBUG
}



::critcl::cinit {
    // init_text
    Tcl_CreateObjCommand(ip, "::tchart::plot", tchart_PlotCmd, NULL, NULL);

} {
    // init_exts
}

critcl::ccode {
    static int 
    tchart_PlotCmd (ClientData  clientData, Tcl_Interp *interp, int objc, Tcl_Obj * const objv[] ) {
        //DBG(fprintf(stderr,"PlotCmd\n"));

        //CheckArgs(3,3,1,"handle list");

	char * title=NULL;		/* Title of the chart			*/
	char * xtext=NULL;		/* X axis Title of the chart			*/
	char * ytext=NULL;		/* Y axis Title of the chart			*/
	char *display_type = "meta";	/* default libplot output format 	*/
	double radius=0.8;		/* radius of the circle in plot coords	*/
	double text_distance=0;		/* distance of text from circle		*/
	int chart_type = 0 ;                 /* 0=barchar, 1=piechart */ 

	if (objc >= 1) {
	    /* "X", "Xdrawable", "pnm", "gif", "ai", "ps", "fig", "pcl", "hpgl", "tek", or "meta" */
	    display_type = Tcl_GetString(objv[1]);
	}

	if (objc >= 2) {
	    Tcl_GetIntFromObj(interp,objv[2],&chart_type);
	}
	if (objc >= 3) {
	    title = Tcl_GetString(objv[3]);
	}
	if (objc >= 4) {
	    xtext = Tcl_GetString(objv[4]);
	}
	if (objc >= 5) {
	    ytext = Tcl_GetString(objv[5]);
	}
	fprintf(stderr,"objc: %d\ndisplay_type: %s\nchart_type=%d\n",objc,display_type,chart_type);

	plot(display_type,title,xtext,ytext,chart_type,radius,text_distance);


	/*
	if (TclListObjGetElements(interp, objv[arg], &listc,
				  &listv) != TCL_OK) {
	    return TCL_ERROR;
	}
	*/

        return TCL_OK;

    }

}


::critcl::cbuild [file normalize [info script]]
