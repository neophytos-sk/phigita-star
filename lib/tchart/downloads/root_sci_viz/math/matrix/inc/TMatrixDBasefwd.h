// @(#)root/matrix:$Id: TMatrixDBasefwd.h 30815 2009-10-20 13:49:22Z rdm $
// Authors: Fons Rademakers, Eddy Offermann   Nov 2003

/*************************************************************************
 * Copyright (C) 1995-2000, Rene Brun and Fons Rademakers.               *
 * All rights reserved.                                                  *
 *                                                                       *
 * For the licensing terms see $ROOTSYS/LICENSE.                         *
 * For the list of contributors see $ROOTSYS/README/CREDITS.             *
 *************************************************************************/

#ifndef ROOT_TMatrixDBasefwd
#define ROOT_TMatrixDBasefwd

//////////////////////////////////////////////////////////////////////////
//                                                                      //
// TMatrixDBase                                                         //
//                                                                      //
//  Forward declaration of TMatrixTBase<Double_t>                       //
//                                                                      //
//////////////////////////////////////////////////////////////////////////

#ifndef ROOT_Rtypes
#include "Rtypes.h"
#endif

template<class Element> class TMatrixTBase;
typedef TMatrixTBase<Double_t> TMatrixDBase;

#endif
