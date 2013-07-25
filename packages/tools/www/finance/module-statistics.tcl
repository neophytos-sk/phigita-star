
package require critcl
::critcl::config force 1
critcl::clibraries -lm

critcl::ccode {
    #include <math.h>

    /* inverse of normal distribution ([2]) */
    /* P( (-\infty, z] ) = qn -> z */

    double pnormaldist_(double qn) {
	static double b[11] = {
	    1.570796288,     0.03706987906,  -0.8364353589e-3,
	    -0.2250947176e-3, 0.6841218299e-5, 0.5824238515e-5,
	    -0.104527497e-5,  0.8360937017e-7,-0.3231081277e-8,
	    0.3657763036e-10,0.6936233982e-12
	};

	double w1, w3;
	int i;

	if(qn < 0. || 1. < qn)
	{
	    fprintf(stderr, "Error : qn <= 0 or qn >= 1 in pnorm()!\n");
	    return 0.;
	}
	if(qn == 0.5)	return 0.;

	w1 = qn;
	if(qn > 0.5)	w1 = 1. - w1;
	w3 = -log(4. * w1 * (1. - w1));
	w1 = b[0];
	for(i = 1; i < 11; i++)	w1 += (b[i] * pow(w3, (double)i));
	if(qn > 0.5)	return sqrt(w1 * w3);
	return -sqrt(w1 * w3);
    }
}


critcl::cproc pnormaldist {double qn} double {
    return pnormaldist_(qn);
}


# pos is the number of positive ratings
# n is the total number of ratings
# power refers to the statistical power, 
#  -> pick 0.10 to have a 95% chance that your lower bound is correct, 0.5 to have a 97.5% chance, etc
critcl::cproc ci_lower_bound {int pos int n double power} double {
    double phat;
    double z;
    if (n == 0) {
        return 0;
    }
    z = pnormaldist_(1-power/2);
    phat = 1.0*pos/n;
    return (phat + z*z/(2*n) - z * sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n);
}

