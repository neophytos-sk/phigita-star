/* ------------------------------------------------------------------------
 * FILE: least-squares.c
 * This program computes a linear model for a set of given data.
 *
 * PROBLEM DESCRIPTION:
 *  The method of least squares is a standard technique used to find
 *  the equation of a straight line from a set of data. Equation for a
 *  straight line is given by 
 *	 y = mx + b
 *  where m is the slope of the line and b is the y-intercept.
 *
 *  Given a set of n points {(x1,y1), x2,y2),...,xn,yn)}, let
 *      SUMx = x1 + x2 + ... + xn
 *      SUMy = y1 + y2 + ... + yn
 *      SUMxy = x1*y1 + x2*y2 + ... + xn*yn
 *      SUMxx = x1*x1 + x2*x2 + ... + xn*xn
 *
 *  The slope and y-intercept for the least-squares line can be 
 *  calculated using the following equations:
 *        slope (m) = ( SUMx*SUMy - n*SUMxy ) / ( SUMx*SUMx - n*SUMxx ) 
 *  y-intercept (b) = ( SUMy - slope*SUMx ) / n
 *
 * AUTHOR: Dora Abdullah (Fortran version, 11/96)
 * REVISED: RYL (converted to C, 12/11/96)
 * ---------------------------------------------------------------------- */
#include <stdlib.h>
#include <math.h>
#include <stdio.h>

int main(int argc, char **argv) {

  double *x, *y;
  double SUMx, SUMy, SUMxy, SUMxx, SUMres, res, slope,
         y_intercept, y_estimate ;
  int i,n;
  FILE *infile;

  infile = fopen("xydata", "r");
  if (infile == NULL) printf("error opening file\n");    
  fscanf (infile, "%d", &n);
  x = (double *) malloc (n*sizeof(double));
  y = (double *) malloc (n*sizeof(double));
  
  SUMx = 0; SUMy = 0; SUMxy = 0; SUMxx = 0;
  for (i=0; i<n; i++) {
    fscanf (infile, "%lf %lf", &x[i], &y[i]);
    SUMx = SUMx + x[i];
    SUMy = SUMy + y[i];
    SUMxy = SUMxy + x[i]*y[i];
    SUMxx = SUMxx + x[i]*x[i];
  }
  slope = ( SUMx*SUMy - n*SUMxy ) / ( SUMx*SUMx - n*SUMxx );
  y_intercept = ( SUMy - slope*SUMx ) / n;
  
  printf ("\n");
  printf ("The linear equation that best fits the given data:\n");
  printf ("       y = %6.2lfx + %6.2lf\n", slope, y_intercept);
  printf ("--------------------------------------------------\n");
  printf ("   Original (x,y)     Estimated y     Residual\n");
  printf ("--------------------------------------------------\n");
      
  SUMres = 0;
  for (i=0; i<n; i++) {
    y_estimate = slope*x[i] + y_intercept;
    res = y[i] - y_estimate;
    SUMres = SUMres + res*res;
    printf ("   (%6.2lf %6.2lf)      %6.2lf       %6.2lf\n", 
	    x[i], y[i], y_estimate, res);
  }
  printf("--------------------------------------------------\n");
  printf("Residual sum = %6.2lf\n", SUMres);
}

