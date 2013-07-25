// -*- mode: C++ -*-
Bool_t enable_afs               = kFALSE;
Bool_t enable_alien             = kFALSE;
Bool_t enable_asimage           = kTRUE;
Bool_t enable_cern              = strlen("gfortran") > 0;
Bool_t enable_chirp             = kFALSE;
Bool_t enable_clarens           = kTRUE;
Bool_t enable_dcache            = kFALSE;
Bool_t enable_globus            = kFALSE;
Bool_t enable_krb5              = kFALSE;
Bool_t enable_ldap              = kFALSE;
Bool_t enable_mysql             = kFALSE;
Bool_t enable_opengl            = kTRUE;
Bool_t enable_oracle            = kFALSE;
Bool_t enable_peac              = kTRUE;
Bool_t enable_pgsql             = kFALSE;
Bool_t enable_pythia6           = kFALSE;
Bool_t enable_python            = kTRUE;
Bool_t enable_qt                = kFALSE;
Bool_t enable_ruby              = kFALSE;
Bool_t enable_rfio              = kFALSE;
Bool_t enable_sapdb             = kFALSE;
Bool_t enable_srp               = kFALSE;
Bool_t enable_ssl               = kTRUE;
Bool_t enable_table             = kFALSE;
Bool_t enable_thread            = kTRUE;
Bool_t enable_xml               = kTRUE;
Bool_t enable_xrootd            = kTRUE;

void html()
{
   gSystem->Load("libEG");
   gSystem->Load("libFumili.so");
   gSystem->Load("libGX11.so");
   gSystem->Load("libGX11TTF.so");
   gSystem->Load("libGed.so");
   gSystem->Load("libGeom.so");
   gSystem->Load("libGeomPainter.so");
   gSystem->Load("libGpad.so");
   gSystem->Load("libGraf.so");
   gSystem->Load("libGraf3d.so");
   gSystem->Load("libGui.so");
   gSystem->Load("libGuiBld.so");
   gSystem->Load("libHist");
   gSystem->Load("libHist.so");
   gSystem->Load("libHistPainter");
   gSystem->Load("libHtml.so");
   gSystem->Load("libMLP.so");
   gSystem->Load("libMatrix.so");
   gSystem->Load("libMinuit.so");
   gSystem->Load("libNew.so");
   gSystem->Load("libPhysics");
   gSystem->Load("libPostscript.so");
   gSystem->Load("libProof");
   gSystem->Load("libQuadp.so");
   gSystem->Load("libRGL");
   gSystem->Load("libRint.so");
   gSystem->Load("libSrvAuth.so");
   gSystem->Load("libThread");
   gSystem->Load("libTree.so");
   gSystem->Load("libTreePlayer");
   gSystem->Load("libTreeViewer");
   gSystem->Load("libTreeViewer.so");
   gSystem->Load("libVMC.so");
   gSystem->Load("libX3d");
   gSystem->Load("libX3d.so");
   gSystem->Load("libXMLIO.so");

   if (enable_alien)             gSystem->Load("libRAliEn");
   if (enable_asimage)           gSystem->Load("libASImage");
   if (enable_cern)              gSystem->Load("libHbook");
   if (enable_chirp)             gSystem->Load("libChirp");
   if (enable_clarens) {
      gSystem->Load("libClarens");
      if (enable_peac) {
         gSystem->Load("libPeacGui");
         gSystem->Load("libPeac");
      }
   }
   if (enable_dcache)            gSystem->Load("libDCache");
   if (enable_globus)            gSystem->Load("libGlobusAuth");
   if (enable_krb5)              gSystem->Load("libKrb5Auth");
   if (enable_ldap)              gSystem->Load("libRLDAP");
   if (enable_mysql)             gSystem->Load("libMySQL");
   if (enable_opengl)            gSystem->Load("libRGL");
   if (enable_oracle)            gSystem->Load("libOracle");
   if (enable_pgsql)             gSystem->Load("libPgSQL");
   if (enable_pythia6)           gSystem->Load("libEGPythia6");
   if (enable_python)            gSystem->Load("libPyROOT");
   if (enable_qt) {
      gSystem->Load("libGQt");
      gSystem->Load("libQtRoot");
   }
   if (enable_ruby)              gSystem->Load("libRuby");
   if (enable_rfio)              gSystem->Load("libRFIO");
   if (enable_sapdb)             gSystem->Load("libSapDB");
   if (enable_srp)               gSystem->Load("libSRPAuth");
   if (enable_table)             gSystem->Load("libTable");
   if (enable_thread)            gSystem->Load("libThread");
   if (enable_xml)               gSystem->Load("libXMLParser");
   if (enable_xrootd) {
      gSystem->Load("libNetx.so");
      gSystem->Load("libXrdRootd");
      gSystem->Load("libXrdSec.so");
      if (enable_krb5) {
         gSystem->Load("libXrdSeckrb4");
         gSystem->Load("libXrdSeckrb5");
      }
   }

   THtml html;
   html.MakeAll();
}
