%module Mapscript

%{
/* static global copy of Tcl interp */
static Tcl_Interp *SWIG_TCL_INTERP;
%}

%init %{
#ifdef USE_TCL_STUBS
  if (Tcl_InitStubs(interp, "8.1", 0) == NULL) {
    return TCL_ERROR;
  }
  /* save Tcl interp pointer to be used in getImageToVar() */
  SWIG_TCL_INTERP = interp;
#endif /* USE_TCL_STUBS */
%}

