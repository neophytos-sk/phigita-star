/*
  Copyright (c) 2008 Florent D'halluin , Sylvain Calinon, 
  LASA Lab, EPFL, CH-1015 Lausanne, Switzerland, 
  http://www.calinon.ch, http://lasa.epfl.ch

  The program is free for non-commercial academic use. 
  Please acknowledge the authors in any academic publications that have 
  made use of this code or part of it. Please use this BibTex reference: 
 
  @article{Calinon07SMC,
  title="On Learning, Representing and Generalizing a Task in a Humanoid 
  Robot",
  author="S. Calinon and F. Guenter and A. Billard",
  journal="IEEE Transactions on Systems, Man and Cybernetics, Part B. 
  Special issue on robot learning by observation, demonstration and 
  imitation",
  year="2007",
  volume="37",
  number="2",
  pages="286--298"
  }
*/

#include "MathLib.h"
#include "gmr.h"

#define NBSTATES 4   // Number of states in the GMM 
#define NBSAMPLES 3  // Number of samples used to train the GMM

int main(int argc, char *argv[]) 
{ 
  GaussianMixture g;

  ///////////////////////////////////////////////////////////////////////
  std::cout << "Load raw data from './indata/'..." << std::flush;
  Matrix rawData[NBSAMPLES];
  unsigned int nbData=0;
  char filename[256];
  for (unsigned int i = 0; i < NBSAMPLES; i++){
    sprintf(filename,"./indata/data%.2d.txt",i+1);
    rawData[i] = g.loadDataFile(filename); 
    nbData += rawData[i].RowSize(); 
  }
  nbData = (int)(nbData/NBSAMPLES);
  unsigned int nbVar = rawData[0].ColumnSize();
  std::cout << "ok" << std::endl;

  ///////////////////////////////////////////////////////////////////////
  std::cout << "Rescale the raw data and save the result to './outdata'..." 
	    << std::flush; 
  Matrix interpol, dataset;
  interpol.Resize(nbData,nbVar);
  for (unsigned int i = 0; i < NBSAMPLES; i++){
    g.HermitteSplineFit(rawData[i],nbData,interpol); 
    dataset = interpol.VCat(dataset);
    sprintf(filename,"./outdata/data%.2d_rescaled.txt",i+1);
    g.saveDataFile(filename,interpol);
  }
  std::cout << "ok" << std::endl;

  /////////////////////////////////////////////////////////////////////// 
  std::cout << "Learn the GMM model and save the result to './outdata'..." 
	    << std::flush; 
  g.initEM_TimeSplit(NBSTATES,dataset); // initialize the model
  g.doEM(dataset); // performs EM
  g.saveParams("./outdata/gmm.txt");
  std::cout << "ok" << std::endl;

  ///////////////////////////////////////////////////////////////////////
  std::cout << "Apply the GMR regression and save the result to './outdata'..." 
	    << std::flush; 
  Vector inC(1), outC(nbVar-1);
  inC(0)=0; // Columns of the input data for regression (here, time)
  for(unsigned int i=0;i<nbVar-1;i++) 
    outC(i)=(float)(i+1); // Columns for output : remainings
  Matrix inData = rawData[0].GetColumnSpace(0,1);
  Matrix *outSigma;
  outSigma = new Matrix[nbData];
  Matrix outData = g.doRegression(inData,outSigma,inC,outC);
  g.saveRegressionResult("./outdata/gmr_Mu.txt","./outdata/gmr_Sigma.txt", 
			inData, outData, outSigma);
  std::cout << "ok" << std::endl;
  std::cout << "You can now run 'plotall' in matlab (or type 'make plot' here) to display the GMM/GMR results." << std::endl;
  
  return 0;
}
