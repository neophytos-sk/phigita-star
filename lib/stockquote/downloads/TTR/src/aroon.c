/*
 *  TTR: Technical Trading Rules
 *
 *  Copyright (C) 2007-2010  Joshua M. Ulrich
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <R.h>
#include <Rinternals.h>

SEXP aroon (SEXP hi, SEXP lo, SEXP n) {

    /* Initalize loop and PROTECT counters */
    int i, P=0;

    /* Ensure High and Low arguments are double */
    if(TYPEOF(hi) != REALSXP) {
      PROTECT(hi = coerceVector(hi, REALSXP)); P++;
    }
    if(TYPEOF(lo) != REALSXP) {
      PROTECT(lo = coerceVector(lo, REALSXP)); P++;
    }
    /* Ensure 'n' is integer */
    if(TYPEOF(n) != INTSXP) {
      PROTECT(n = coerceVector(n, INTSXP)); P++;
    }

    /* Pointers to function arguments */
    double *d_hi = REAL(hi);
    double *d_lo = REAL(lo);
    int *i_n = INTEGER(n);

    /* Input object length */
    int nr = nrows(hi);

    /* Initalize result R objects */
    SEXP result; PROTECT(result = allocVector(VECSXP,  2)); P++;
    SEXP up;     PROTECT(up     = allocVector(REALSXP,nr)); P++;
    SEXP dn;     PROTECT(dn     = allocVector(REALSXP,nr)); P++;

    /* Initialize REAL pointers to R result objects */
    double *d_up = REAL(up);
    double *d_dn = REAL(dn);

    /* Find first non-NA value */
/*    int beg = 1;
    for(i=0; i < nr; i++) {
      if( ISNA(d_hi[i]) || ISNA(d_lo[i]) ) {
        d_sar[i] = NA_REAL;
        beg++;
      } else {
        break;
      }
    }
*/
    /* Initialize values needed by the routine */
/*    int sig0 = 1, sig1 = 0;
    double xpt0 = d_hi[beg-1], xpt1 = 0;
    double af0 = d_xl[0], af1 = 0;
    double lmin, lmax;
    d_sar[beg-1] = d_lo[beg-1]-0.01;

    for(i=beg; i < nr; i++) {
*/      /* Increment signal, extreme point, and acceleration factor */
/*      sig1 = sig0;
      xpt1 = xpt0;
      af1 = af0;
*/
      /* Local extrema */
/*      lmin = (d_lo[i-1] < d_lo[i]) ? d_lo[i-1] : d_lo[i];
      lmax = (d_hi[i-1] > d_hi[i]) ? d_hi[i-1] : d_hi[i];
*/
    /* Assign results to list */
    SET_VECTOR_ELT(result, 0, up);
    SET_VECTOR_ELT(result, 1, dn);

    /* UNPROTECT R objects and return result */
    UNPROTECT(P);
    return(result);
}

