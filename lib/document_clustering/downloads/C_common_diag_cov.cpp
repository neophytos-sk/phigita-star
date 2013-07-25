/* EM algorithm for CLUSTER ANALYSIS*/
// common diagonal covariance

/* standard libraries to include */
#include "R.h"
#include <iostream>
#include <fstream>
#include <cstdlib> 
#include <ctime> 
#include <cmath>
#include <sstream>
#include <string>
// #include <sys/resource.h>
// #include <sys/time.h> 
// #include <stdlib.h>
// #define PI 3.1415926

using namespace std;

extern "C"{   

double f(double *Y, double *mu, double *sigma_vec,int ii,int jj, int k)
{
  double s=0;
  for(int mm=1;mm<=k;mm++){
    s=s+(-0.5*(Y[(ii-1)*k+(mm-1)]-mu[(jj-1)*k+(mm-1)])*(Y[(ii-1)*k+(mm-1)]-mu[(jj-1)*k+(mm-1)])/
      sigma_vec[(jj-1)*k+(mm-1)]+1.0)-0.5*log(sigma_vec[(jj-1)*k+(mm-1)])-0.5*log(2.0*3.1415);
  }
  return(s);
}

double f12(double *Y, double *mu, double *sigma_vec,int ii,int jj, int k)
{
  double s=0;
  for(int mm=1;mm<=k;mm++){
    s=s+0.5*(Y[(ii-1)*k+(mm-1)]-mu[(jj-1)*k+(mm-1)])*(Y[(ii-1)*k+(mm-1)]-mu[(jj-1)*k+(mm-1)])/
            sigma_vec[(jj-1)*k+(mm-1)]+0.5*log(sigma_vec[(jj-1)*k+(mm-1)]);
  }
  return(s);
}

void muUpdate(double *mu,double *Y,double *tau, double *pie, double *sigma_vec,int k,int n,int g,double lambda)
{
  double ttt,sumtau;
  int i,j,m;
  double sign;
  for (i=1;i<=g;i++){ 
    for (m=1;m<=k;m++){
      mu[(i-1)*k+(m-1)]=0;
      for (j=1;j<=n;j++){
        mu[(i-1)*k+(m-1)]+=tau[(i-1)*n+(j-1)]*Y[(j-1)*k+(m-1)];
      }
    }
  }
  for (i=1;i<=g;i++){
    sumtau=0;
    for(j=1;j<=n;j++){
      sumtau+=tau[(i-1)*n+(j-1)];
    }
    for (m=1;m<=k;m++){
      ttt=abs(mu[(i-1)*k+(m-1)]);
      if(lambda>=ttt/sigma_vec[(i-1)*k+(m-1)]) {mu[(i-1)*k+(m-1)]=0;}
      else {mu[(i-1)*k+(m-1)]=(mu[(i-1)*k+(m-1)]/ttt)*(ttt-lambda*sigma_vec[(i-1)*k+(m-1)])/sumtau;}
    }
  }
}

void sigmaUpdate(double *sigma_vec,double *Y, double *mu, double *tau,int g,int n,int k)
{
  int i,j,m;
  // Note: k would always equals to kGlob
  for (m=1;m<=k;m++){
    sigma_vec[(1-1)*k+(m-1)]=0;
    for (i=1;i<=g;i++){
        for (j=1;j<=n;j++){
        sigma_vec[(1-1)*k+(m-1)]+=tau[(i-1)*n+(j-1)]*(Y[(j-1)*k+(m-1)]-mu[(i-1)*k+(m-1)])*
                                                     (Y[(j-1)*k+(m-1)]-mu[(i-1)*k+(m-1)]);
      }
    }
    sigma_vec[(1-1)*k+(m-1)]=sigma_vec[(1-1)*k+(m-1)]/(double)n;
    for (i=1;i<=g;i++){
      sigma_vec[(i-1)*k+(m-1)]=sigma_vec[(1-1)*k+(m-1)];
    }
  }
}
     
void tauUpdate(double *tau,double *Y, double *mu, double *sigma_vec, double *pie,int g,int n, int k)
{
  int i,j,ii;

  for (j=1;j<=n;j++){
  for (i=1;i<=g;i++){
        double ss_temp=0;
        for (ii=1;ii<=g;ii++){
            double tt_temp=exp(  -f12(Y,mu,sigma_vec,j,ii,k)+f12(Y,mu,sigma_vec,j,i,k)  );
            ss_temp+=+pie[ii-1]*tt_temp;
        }
        if(pie[i-1]==0) {tau[(i-1)*n+(j-1)]=0;}
      else {tau[(i-1)*n+(j-1)]=pie[i-1]/ss_temp;}
   }
  }
}
     
void pieUpdate(double *pie,double *tau,int g,int n)
{
  for(int i=1;i<=g;i++){
    pie[i-1]=0;
    for(int j=1;j<=n;j++){
      pie[i-1]+=tau[(i-1)*n+(j-1)]/(double)n;
    }
  }
}

double ploglik(double *Y,double *mu,double *tau,double *pie,double *sigma_vec,int k,int n,int g,double lambda)
{
  double plog=0,temp1=1;
  int ss,i,j,m;
  double temp[g];

  for(j=1;j<=n;j++){
    for(i=1;i<=g;i++){
      if(pie[i-1]!=0) temp[i-1]=log(pie[i-1])+f(Y,mu,sigma_vec,j,i,k);
      else temp[i-1]=0-1.0e+50;
    }
    
    ss=1;
    double tempmax=temp[0];
    for(int ii=1;ii<=g;ii++){
    if(temp[ii-1]>tempmax)
    ss=ii;
    }

    temp1=1.0;
    for(i=1;i<=g;i++){
      if(i!=ss) {
      	temp1+=(pie[i-1]/(pie[ss-1]))*exp(-f12(Y,mu,sigma_vec,j,i,k)+f12(Y,mu,sigma_vec,j,ss,k));
      }
    }
    plog=plog+((temp[ss-1])+log(temp1));
  }

    // temp2=0;
    // for(m=1;m<=k;m++){
    //  for(i=1;i<=g;i++) {temp2=temp2+fabs(mu[i][m]);}
    // }
    // plog=plog-lambda*temp2;
    
    // temp2=0;
    // for(m=1;m<=k;m++){
    //  for(i=1;i<=g;i++) {temp2=temp2+fabs(log(sigma2[i][m]));}
    // }
    // plog=plog-lambda1*temp2;

  return(plog);
}
     
void common_diag_cov(double *Y,double *mu, double *tau, double *pie, double *sigma_vec,
       int *n,int *k, int *g_c, double *lambda_c, int *MAX_iter, double *threshold,double *out_mu, double *out_tau, 
       double *out_pie, double *out_sigma_vec){       
       
       int nGlob=n[0];
       int kGlob=k[0];
       int gGlob=g_c[0];
       double lambda=lambda_c[0];
       int maxit=MAX_iter[0];
       double thr=threshold[0];
       
       int z=1;
       double diff=100.0;
       double nplog=1.0;
       double plog=5.0;
       
       while((z<=maxit)&&(diff>thr))
       {
              tauUpdate(tau,Y, mu, sigma_vec, pie,gGlob,nGlob,kGlob);                       
              pieUpdate(pie,tau,gGlob,nGlob);                           
              sigmaUpdate(sigma_vec,Y, mu,tau,gGlob,nGlob,kGlob);  
              muUpdate(mu,Y,tau,pie,sigma_vec,kGlob,nGlob,gGlob,lambda);  
              
              plog=ploglik(Y,mu,tau,pie,sigma_vec,kGlob,nGlob,gGlob,lambda);
              diff=abs(plog-nplog);
              nplog=plog;
              z++;                   
       }
       
       int f=1;
       for(int i=1;i<=gGlob;i++){
               for(int j=1;j<=kGlob;j++){
                      out_mu[f-1]=mu[(i-1)*kGlob+(j-1)];
                      f++;
               }
       } 

       f=1;
       for(int i=1;i<=gGlob;i++){
               for(int j=1;j<=nGlob;j++){
                      out_tau[f-1]=tau[(i-1)*nGlob+(j-1)];
                      f++;
               }
       }                
       
       for(int i=1;i<=gGlob;i++)
       out_pie[i-1]=pie[i-1];
       
       f=1;
       for(int i=1;i<=gGlob;i++){
               for(int j=1;j<=kGlob;j++){
                      out_sigma_vec[f-1]=sigma_vec[(i-1)*kGlob+(j-1)];
                      f++;
               }
       } 
       
} // end function common_diag_cov
} // end extern "C"{  

