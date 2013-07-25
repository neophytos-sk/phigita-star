/******************************************************************************/
/*                                                                            */
/*                        X r d A c c A u d i t . c c                         */
/*                                                                            */
/* (c) 2003 by the Board of Trustees of the Leland Stanford, Jr., University  */
/*                            All Rights Reserved                             */
/*   Produced by Andrew Hanushevsky for Stanford University under contract    */
/*              DE-AC03-76-SFO0515 with the Department of Energy              */
/******************************************************************************/

//         $Id: XrdAccAudit.cc 22437 2008-03-04 14:35:16Z rdm $

const char *XrdAccAuditCVSID = "$Id: XrdAccAudit.cc 22437 2008-03-04 14:35:16Z rdm $";

#include <stdio.h>
#include <stdlib.h>

#include "XrdAcc/XrdAccAudit.hh"
#include "XrdSys/XrdSysError.hh"
  
/******************************************************************************/
/*                           C o n s t r u c t o r                            */
/******************************************************************************/
  
XrdAccAudit::XrdAccAudit(XrdSysError *erp)
{

// Set default
//
   auditops = audit_none;
   mDest    = erp;
}

/******************************************************************************/
/*                                  D e n y                                   */
/******************************************************************************/
  
void XrdAccAudit::Deny(const char *opname,
                       const char *tident,
                       const char *atype,
                       const char *id,
                       const char *host,
                       const char *path)
{if (auditops & audit_deny)
    {char buff[2048];
     snprintf(buff, sizeof(buff)-1, "%s deny %s %s@%s %s %s",
              (tident ? tident : ""), atype, id, host, opname, path);
     buff[sizeof(buff)-1] = '\0';
     mDest->Emsg("Audit", buff);
    }
}

/******************************************************************************/
/*                                 G r a n t                                  */
/******************************************************************************/
  
void XrdAccAudit::Grant(const char *opname,
                        const char *tident,
                        const char *atype,
                        const char *id,
                        const char *host,
                        const char *path)
{if (auditops & audit_deny)
    {char buff[2048];
     snprintf(buff, sizeof(buff)-1, "%s grant %s %s@%s %s %s",
              (tident ? tident : ""), atype, id, host, opname, path);
     buff[sizeof(buff)-1] = '\0';
     mDest->Emsg("Audit", buff);
    }
}

/******************************************************************************/
/*                A u d i t   O b j e c t   G e n e r a t o r                 */
/******************************************************************************/
  
XrdAccAudit *XrdAccAuditObject(XrdSysError *erp)
{
static XrdAccAudit AuditObject(erp);

// Simply return the default audit object
//
   return &AuditObject;
}
