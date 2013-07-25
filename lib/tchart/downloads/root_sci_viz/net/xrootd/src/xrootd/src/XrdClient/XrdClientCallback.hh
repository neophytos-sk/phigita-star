//////////////////////////////////////////////////////////////////////////
//                                                                      //
// XrdClientCallback                                                    // 
//                                                                      //
// Author: Fabrizio Furano (CERN IT-DSS, 2009)                          //
//                                                                      //
// Base class for objects receiving events from XrdClient               //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

//       $Id: XrdClientCallback.hh 32231 2010-02-05 18:24:46Z ganis $

#ifndef XRD_CLIENTCALLBACK_H
#define XRD_CLIENTCALLBACK_H

class XrdClientAbs;

class XrdClientCallback
{

public:

   // Invoked when an Open request completes with some result.
   virtual void OpenComplete(XrdClientAbs *clientP, void *cbArg, bool res) = 0;

   XrdClientCallback() {}
   virtual ~XrdClientCallback() {}
};



#endif
