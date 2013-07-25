/******************************************************************************/
/*                                                                            */
/*                        X r d F r m T r a c e . c c                         */
/*                                                                            */
/* (c) 2010 by the Board of Trustees of the Leland Stanford, Jr., University  */
/*                            All Rights Reserved                             */
/*   Produced by Andrew Hanushevsky for Stanford University under contract    */
/*              DE-AC02-76-SFO0515 with the Department of Energy              */
/******************************************************************************/

//         $Id: XrdFrmTrace.cc 34000 2010-06-21 06:49:56Z ganis $

const char *XrdFrmXfrTraceCVSID = "$Id: XrdFrmTrace.cc 34000 2010-06-21 06:49:56Z ganis $";

#include "XrdFrm/XrdFrmTrace.hh"

/******************************************************************************/
/*                        G l o b a l   O b j e c t s                         */
/******************************************************************************/
  
       XrdSysError        XrdFrm::Say(0, "frm_");

       XrdOucTrace        XrdFrm::Trace(&Say);
