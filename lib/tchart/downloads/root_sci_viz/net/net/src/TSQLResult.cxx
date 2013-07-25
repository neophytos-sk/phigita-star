// @(#)root/net:$Id: TSQLResult.cxx 23091 2008-04-09 15:04:27Z rdm $
// Author: Fons Rademakers   25/11/99

/*************************************************************************
 * Copyright (C) 1995-2000, Rene Brun and Fons Rademakers.               *
 * All rights reserved.                                                  *
 *                                                                       *
 * For the licensing terms see $ROOTSYS/LICENSE.                         *
 * For the list of contributors see $ROOTSYS/README/CREDITS.             *
 *************************************************************************/

//////////////////////////////////////////////////////////////////////////
//                                                                      //
// TSQLResult                                                           //
//                                                                      //
// Abstract base class defining interface to a SQL query result.        //
// Objects of this class are created by TSQLServer methods.             //
//                                                                      //
// Related classes are TSQLServer and TSQLRow.                          //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

#include "TSQLResult.h"

ClassImp(TSQLResult)
