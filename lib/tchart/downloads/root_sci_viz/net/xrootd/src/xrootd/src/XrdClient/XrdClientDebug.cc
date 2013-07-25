/***********************************************************/
/*                T X D e b u g . c c                      */
/*                        2003                             */
/*             Produced by Alvise Dorigo                   */
/*         & Fabrizio Furano for INFN padova               */
/***********************************************************/
//
//   $Id: XrdClientDebug.cc 30949 2009-11-02 16:37:58Z ganis $

const char *XrdClientDebugCVSID = "$Id: XrdClientDebug.cc 30949 2009-11-02 16:37:58Z ganis $";
//
// Author: Alvise Dorigo, Fabrizio Furano

#include "XrdClient/XrdClientDebug.hh"

#include "XrdSys/XrdSysPthread.hh"
XrdClientDebug *XrdClientDebug::fgInstance = 0;

//_____________________________________________________________________________
XrdClientDebug* XrdClientDebug::Instance() {
   // Create unique instance

   if (!fgInstance) {
      fgInstance = new XrdClientDebug;
      if (!fgInstance) {
         abort();
      }
   }
   return fgInstance;
}

//_____________________________________________________________________________
XrdClientDebug::XrdClientDebug() {
   // Constructor

   fOucLog = new XrdSysLogger();
   fOucErr = new XrdSysError(fOucLog, "Xrd");

   fDbgLevel = EnvGetLong(NAME_DEBUG);
}

//_____________________________________________________________________________
XrdClientDebug::~XrdClientDebug() {
   // Destructor
   delete fOucErr;
   delete fOucLog;

   fOucErr = 0;
   fOucLog = 0;

   delete fgInstance;
   fgInstance = 0;
}
