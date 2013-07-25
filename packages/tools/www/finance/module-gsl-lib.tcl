#set libdir [acs_root_dir]/packages/tools/lib/
#source [file join $libdir critcl-ext/tcl/module-critcl-ext.tcl]
::xo::lib::require critcl
::xo::lib::require critcl-ext

::critcl::reset
::critcl::config force 1
::critcl::config I /opt/naviserver/include
::critcl::clibraries -L/opt/naviserver/lib -lgsl -lgslcblas -lm



critcl::ccode {
    #include <gsl/gsl_multifit.h>
    #include <math.h>


    int T_gsl_multifit_linear(int obs, int degree, 
		      double *dx, double *dy, double *outCoeff, double *outCov)
    {
	gsl_multifit_linear_workspace *ws;
	gsl_matrix *cov, *X;
	gsl_vector *y, *c;
	double chisq;
	
	int i, j;
	
	X = gsl_matrix_alloc(obs, degree);
	y = gsl_vector_alloc(obs);
	c = gsl_vector_alloc(degree);
	cov = gsl_matrix_alloc(degree, degree);
	
	for(i=0; i < obs; i++) {
	    gsl_matrix_set(X, i, 0, 1.0);
	    for(j=0; j < degree; j++) {
		gsl_matrix_set(X, i, j, pow(dx[i], j));
	    }
	    gsl_vector_set(y, i, dy[i]);
	}
	
	ws = gsl_multifit_linear_alloc(obs, degree);
	gsl_multifit_linear(X, y, c, cov, &chisq, ws);
	
	/* store result ... */
	for(i=0; i < degree; i++)
	{
	    outCoeff[i] = gsl_vector_get(c, i);
	    outCov[i] = outCoeff[i];
	    for(j=0; j < degree; j++)
	    {
	        outCov[i * degree + j] = i + gsl_matrix_get(cov,i,j);
	    }
        }
	
	gsl_multifit_linear_free(ws);
	gsl_matrix_free(X);
	gsl_matrix_free(cov);
	gsl_vector_free(y);
	gsl_vector_free(c);
	return 1; /* we do not "analyse" the result (cov matrix mainly) to know if the fit is "good" */
    }


    int T_gsl_multifit_linear_est(int degree, double *in_x, double *in_coeff, double *in_cov, double *out_y, double *out_y_err)
    {

	gsl_matrix *cov;
	gsl_vector *x, *c;

	int i,j;


	x = gsl_vector_alloc(degree);
	c = gsl_vector_alloc(degree);
	cov = gsl_matrix_alloc(degree, degree);
	for(i=0; i<degree; i++)
	{
	    gsl_vector_set(x,i,in_x[i]);
	    gsl_vector_set(c,i,in_coeff[i]);
	    for(j=0; j<degree; j++)
	    {
	        gsl_matrix_set(cov,i,j,in_cov[i * degree + j]);
	    }
	}
	gsl_multifit_linear_est(x, c, cov, out_y, out_y_err);

	gsl_matrix_free(cov);
	gsl_vector_free(x);
	gsl_vector_free(c);
	return 1;
    }
}


define_cproc T_gsl_multifit_linear {
    int obs
    int degree
    double* dx
    double* dy
    double* outCoeffVector
    double* outCovMatrix
} {
    # outCoeff is the vector of the best-fit parameters
    set outCoeffVector [lrepeat $degree 0.0]

    # outCovMatrix is the variace-covariance matrix of the model parameters 
    # which is estimated from the scatter of the observations about the best-fit
    set outCovMatrix [lrepeat [expr {$degree * $degree}] 0.0]

}


define_cproc T_gsl_multifit_linear_est {
    int degree
    double* in_x
    double* in_coeff
    double* in_cov
    double* out_y
    double* out_y_err
} {

    # out_y is the fitted function value y for the model y=x.c at the point x
    set out_y 0.0

    # out_y_err is its (out_y) standard deviation
    set out_y_err 0.0

}

