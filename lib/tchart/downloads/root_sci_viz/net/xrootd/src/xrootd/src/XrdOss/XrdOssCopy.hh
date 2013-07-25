#ifndef _XRDOSSCOPY_H_
#define _XRDOSSCOPY_H_
/******************************************************************************/
/*                                                                            */
/*                            X r d O s s C o p y                             */
/*                                                                            */
/* (c) 2009 by the Board of Trustees of the Leland Stanford, Jr., University  */
/*                            All Rights Reserved                             */
/*   Produced by Andrew Hanushevsky for Stanford University under contract    */
/*              DE-AC02-76-SFO0515 with the Department of Energy              */
/******************************************************************************/
  
//          $Id: XrdOssCopy.hh 28902 2009-06-11 12:36:21Z ganis $

class XrdOssCopy
{
public:

static off_t Copy(const char *inFn, const char *outFn, int outFD);

             XrdOssCopy() {}
            ~XrdOssCopy() {}

private:
static int   Write(const char *, int, char *, size_t, off_t);
};
#endif
