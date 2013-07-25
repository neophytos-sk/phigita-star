#include <tcl.h>
#include <string>
#include <vector>
#include <set>
#include <iostream> 
#include "ttext.h"
#include "ns.h"

#define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }


using namespace std;

extern "C" {


  int Ns_ModuleVersion = 1;

  int Ns_ModuleInit(char *hServer, char *hModule);


    static int Ttext_ClusterCmd(ClientData clientData,
				Tcl_Interp *interp,
				int objc,
				Tcl_Obj *CONST objv[]);

    static int Ttext_ExtractCmd(ClientData clientData,
				Tcl_Interp *interp,
				int objc,
				Tcl_Obj *CONST objv[]);

    static int Ttext_TtextCmd(ClientData clientData,
			      Tcl_Interp *interp,
			      int objc,
			      Tcl_Obj *CONST objv[]);

    static int Ttext_TidyCmd(ClientData clientData,
			      Tcl_Interp *interp,
			      int argc,
			      const char * argv[]);

  static int Ttext_UnaccentCmd(ClientData clientData,
			       Tcl_Interp *interp,
			       int argc,
			       const char * argv[]);

    EXTERN int Ttext_Init _ANSI_ARGS_((Tcl_Interp * interp, void *context));



  static int
  Ttext_ConvertStringListObjToVector(Tcl_Interp * interp, Tcl_Obj* objPtr, vector<string>* V)
  {
    int i, objc, result;
    Tcl_Obj **objv;
    Tcl_Obj* listPtr = Tcl_NewListObj(0,NULL);
    Tcl_Obj *elemPtr;

    result = Tcl_ListObjGetElements(interp, objPtr, &objc, &objv);
    if (result != TCL_OK) {
      return result;
    }
    
    result = Tcl_ListObjReplace(interp, listPtr, 0, 0, objc, objv);
    if (result != TCL_OK) {
      return result;
    }
    
    V->clear();
    for (i=0; i<objc; i++) {
      Tcl_ListObjIndex(interp,listPtr,i,&elemPtr);
      string s(Tcl_GetStringFromObj(elemPtr,NULL));
      V->push_back(s);
    }
    Tcl_SetObjResult(interp,Tcl_NewIntObj(objc));
    return TCL_OK;
  }

    static int
    Ttext_ConvertDoubleListObjToVector(Tcl_Interp * interp, Tcl_Obj* objPtr, vector<double>* V)
    {
	int i, objc, result;
	Tcl_Obj **objv;
	Tcl_Obj* listPtr = Tcl_NewListObj(0,NULL);
	Tcl_Obj *elemPtr;
	
	result = Tcl_ListObjGetElements(interp, objPtr, &objc, &objv);
	if (result != TCL_OK) {
	    return result;
	}
	
	result = Tcl_ListObjReplace(interp, listPtr, 0, 0, objc, objv);
	if (result != TCL_OK) {
	    return result;
	}
	
	V->clear();
	for (i=0; i<objc; i++) {
	    Tcl_ListObjIndex(interp,listPtr,i,&elemPtr);
	    double k;
	    int r = Tcl_GetDoubleFromObj(interp,elemPtr,&k);
	    V->push_back(k);
	}
	Tcl_SetObjResult(interp,Tcl_NewIntObj(objc));
	return TCL_OK;
    }
    
    

  void 
  Ttext_SetVectorResult(Tcl_Interp * interp, vector<vector<unsigned int> > V, vector<double> D)
  {
    unsigned int i,j;
    Tcl_Obj * listPtr = Tcl_NewListObj(0, NULL);
    Tcl_Obj * listPtrV = Tcl_NewListObj(0, NULL);
    Tcl_Obj * listPtrD = Tcl_NewListObj(0, NULL);
    Tcl_Obj * elemListPtr;
	
    for (i=0; i<V.size(); i++) {
      elemListPtr = Tcl_NewListObj(0,NULL);
      for (j=0; j<V[i].size(); j++) {
	Tcl_ListObjAppendElement(interp, elemListPtr, Tcl_NewIntObj(V[i][j]));
      }
      Tcl_ListObjAppendElement(interp,listPtrV,elemListPtr);
    }
    for (i=0; i<D.size(); i++) {
      Tcl_ListObjAppendElement(interp,listPtrD,Tcl_NewDoubleObj(D[i]));
    }
    Tcl_ListObjAppendElement(interp,listPtr,listPtrD);
    Tcl_ListObjAppendElement(interp,listPtr,listPtrV);
    Tcl_ResetResult(interp);
    Tcl_SetObjResult(interp,listPtr);
  }



  vector<DataPoint> 
  Ttext_CreateDataPoints(vector<string> data,/*Sgi::hash_set<string>*/myset* removeSet)
  {
    vector<DataPoint> points;
    for(unsigned int i = 0; i < data.size(); i++) {
      points.push_back( DataPoint(data[i], i , removeSet) );
    }
    return points;
  }

  vector<Cluster> 
  Ttext_ComputeClusters(int k, vector<string> data, vector<string> stopwords,vector<double>* D)
  {
    Threshold threshold;
    Evaluator * eval = new Evaluator();

    //i am using the getTokens function to "clear" the stopwords file
    string str("");
    for (int i = 0; i < stopwords.size(); i++)
	str += stopwords[i] + ' ';
    vector<string> v = getTokens(str);

    //creating the removeSet to be used within the datapoints parceArticle
    myset removeSet;
    for(unsigned int i = 0; i < v.size(); i++)
	removeSet.insert(v[i]);

    vector<DataPoint> dps = Ttext_CreateDataPoints(data, &removeSet);

    DataPoint* d = new DataPoint();
    srand( (unsigned)time( NULL ) );
    for(int i = 0; i < 1000; i++) {
      int rand1 = 0;
      int rand2 = 0;
      while(rand1 == rand2) {
	rand1 = rand() % dps.size();
	rand2 = rand() % dps.size();
      }
      threshold.add(d->cosineDistance(&dps[rand1], &dps[rand2]));
      //printf("%d,%d %6.2f\n",rand1,rand2,d->cosineDistance(&dps[rand1], &dps[rand2]));
    }
    delete d;

    double thresh = threshold.getThreshold()[k];
    Map map(eval, thresh);
    for(unsigned int i = 0; i < dps.size(); i++) {
      map.insertDataPoint(&dps[i]);
    }

    D->push_back(eval->getLow());
    D->push_back(eval->getHigh());
    D->push_back(eval->getAverage());
    D->push_back(eval->getOutAvg());
    D->push_back(eval->getInAvg());
    D->push_back(eval->getStdev());
    D->push_back(eval->getOutStdev());

    /*printf("Closest distance         : %6.2f\n",eval->getLow());
    printf("Farthest distance        : %6.2f\n",eval->getHigh());
    printf("Average distance         : %6.2f\n",eval->getAverage());
    printf("Intercluster avg distance: %6.2f\n",eval->getOutAvg());
    printf("Intracluster avg distance: %6.2f\n",eval->getInAvg());
    printf("Spread                   : %6.2f\n",eval->getStdev());
    printf("Intracluster spread      : %6.2f\n",eval->getOutStdev());
    printf("Threshold: %6.2f\n",thresh);*/

    delete eval;
    map.decreaseWeights(1.0);
    return map.getClusters();
  }



  bool 
  Ttext_GetClusters(int k, vector<string> data, vector<string> stopwords, vector<vector<unsigned int> >* V, vector<double>* D)
  {
    vector<Cluster> Clusters = Ttext_ComputeClusters(k, data,stopwords,D);
    for (unsigned int i = 0; i < Clusters.size(); i++) {
      V->push_back(Clusters[i].getIndexes());
    }
    return true;
  }



  /*
   *----------------------------------------------------------------------
   *
   * Ttext_ClusterCmd --
   *
   *      
   *
   * Results:
   *      TCL_OK or TCL_ERROR
   *
   * Side effects:
   *      
   *
   *----------------------------------------------------------------------
   */

  static int
  Ttext_ClusterCmd(ClientData clientData,
		   Tcl_Interp *interp,
		   int objc,
		   Tcl_Obj *CONST objv[])
  {

    int result;
    int k;

    CheckArgs(4,4,objc,"wrong # args: should be \"cluster k dataset stopwords\"");

    vector<string> data;
    vector<string> stopwords;

    result=Tcl_GetIntFromObj(interp,objv[1],&k);
    if (result != TCL_OK)
      return result;

    result=Ttext_ConvertStringListObjToVector(interp,objv[2],&data);
    if (result != TCL_OK)
      return result;


    result=Ttext_ConvertStringListObjToVector(interp,objv[3],&stopwords);
    if (result != TCL_OK)
      return result;

    //text clustrering
    vector<vector<unsigned int> > V;
    vector<double> D;
    if (!Ttext_GetClusters(k,data,stopwords,&V,&D))
      return TCL_ERROR;
    
    Ttext_SetVectorResult(interp,V,D);

    return TCL_OK;

  }


  /*
   *----------------------------------------------------------------------
   *
   * Ttext_ExtractCmd --
   *
   *      
   *
   * Results:
   *      TCL_OK or TCL_ERROR
   *
   * Side effects:
   *      
   *
   *----------------------------------------------------------------------
   */

  static int
  Ttext_ExtractCmd(ClientData clientData,
		   Tcl_Interp *interp,
		   int objc,
		   Tcl_Obj *CONST objv[])
  {

  }


  /*
   *----------------------------------------------------------------------
   *
   * Ttext_UnaccentCmd --
   *
   *    http://home.gna.org/unac/  
   *
   * Results:
   *      TCL_OK or TCL_ERROR
   *
   * Side effects:
   *      
   *
   *----------------------------------------------------------------------
   */

  static int
  Ttext_UnaccentCmd(ClientData clientData,
                    Tcl_Interp *interp,
                    int argc,
                    const char* argv[])
  {

    if (argc < 3)
      {
	Tcl_AddErrorInfo(interp,"wrong # args : should be \"ttext::unac charset string\"");
	return TCL_ERROR;
      }
    else
      return Unaccent(clientData,interp,argc,argv);

  }



  /*
   *----------------------------------------------------------------------
   *
   * Ttext_SpellCmd --
   *
   *      
   *
   * Results:
   *      TCL_OK or TCL_ERROR
   *
   * Side effects:
   *      
   *
   *----------------------------------------------------------------------
   */

  static int
  Ttext_SpellCmd(ClientData clientData,
		 Tcl_Interp *interp,
		 int objc,
		 Tcl_Obj *CONST objv[])
  {

  }


  /*
   *----------------------------------------------------------------------
   *
   * Ttext_StemCmd --
   *
   *      
   *
   * Results:
   *      TCL_OK or TCL_ERROR
   *
   * Side effects:
   *      
   *
   *----------------------------------------------------------------------
   */

  static int
  Ttext_StemCmd(ClientData clientData,
		Tcl_Interp *interp,
		int objc,
		Tcl_Obj *CONST objv[])
  {

  }


  /*
   *----------------------------------------------------------------------
   *
   * Ttext_TidyCmd --
   *
   *      
   *
   * Results:
   *      TCL_OK or TCL_ERROR
   *
   * Side effects:
   *      
   *
   *----------------------------------------------------------------------
   */

  static int
  Ttext_TidyCmd(ClientData clientData,
		Tcl_Interp *interp,
		int argc,
		const char * argv[])
  {
      return Tidy(clientData,interp,argc,argv);
  }


  /*
   *----------------------------------------------------------------------
   *
   * Ttext_TtextCmd --
   *
   *      
   *
   * Results:
   *      TCL_OK or TCL_ERROR
   *
   * Side effects:
   *      
   *
   *----------------------------------------------------------------------
   */

  static int 
  Ttext_TtextCmd (ClientData clientData,
		  Tcl_Interp *interp,
		  int objc,
		  Tcl_Obj *CONST objv[]) 
  {

    CheckArgs(2,999,objc,"wrong # args: should be \"ttext cmd args\"");

    enum commands {
      cmdCluster, cmdExtract, UnaccentCmd, SpellCmd, StemCmd
    } cmd;
    
    const char *sCmd[] = {
      "cluster", "extract", "unac", "spell", "stem", 0
    };

    if(Tcl_GetIndexFromObj(interp,objv[1],sCmd,"command",TCL_EXACT,(int*)&cmd) != TCL_OK)
      return TCL_ERROR;
    
    switch(cmd) {
      case cmdCluster:
        Ttext_ClusterCmd(clientData,interp,objc-1,++objv);
	return TCL_OK;
	break;
      case cmdExtract:
	Ttext_ExtractCmd(clientData,interp,objc-1,++objv);
	return TCL_OK;
	break;
    }

    Tcl_AppendResult(interp,"Invalid command",0);
    return TCL_ERROR;
  }




  /*
   *----------------------------------------------------------------------
   *
   * The following structure defines a command to be created
   * in new interps.
   *
   *----------------------------------------------------------------------
   */

  typedef struct Cmd {
    char *name;
    Tcl_CmdProc *proc;
    Tcl_ObjCmdProc *objProc;
  } Cmd;


  static Cmd cmds[] = {

    {"ttext::ttext", NULL, Ttext_TtextCmd},
    {"ttext::cluster", NULL, Ttext_ClusterCmd},
    {"ttext::extract", NULL, Ttext_ExtractCmd},
    {"ttext::unac", Ttext_UnaccentCmd, NULL},
    {"ttext::spell", NULL, Ttext_SpellCmd},
    {"ttext::stem", NULL, Ttext_StemCmd},
    {"ttext::tidy", Ttext_TidyCmd, NULL},
    
    /*
     * Add more server Tcl commands here.
     */
    
    {NULL, NULL}
  };    


  static void
  AddCmds(Tcl_Interp *interp, Cmd *cmdPtr)
  {
    while (cmdPtr->name != NULL) {
      if (cmdPtr->objProc != NULL) {
	Tcl_CreateObjCommand(interp, cmdPtr->name, cmdPtr->objProc, 
			     (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
      } else {
	Tcl_CreateCommand(interp, cmdPtr->name, cmdPtr->proc, 
			  (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
      }
      ++cmdPtr;
    }
  }








	

  /*
   *----------------------------------------------------------------------
   *
   * Ttext_Init --
   *
   *      Register new commands with the Tcl interpreter.
   *
   * Results:
   *      TCL_OK
   *
   * Side effects:
   *      C functions are registered with the Tcl interpreter.
   *
   *----------------------------------------------------------------------
   */

  int  Ttext_Init(Tcl_Interp *interp, void *context) 
  {

    Tcl_Eval(interp, "namespace eval ttext {;}");
    AddCmds(interp,cmds);
    return TCL_OK;
  }


  int Ns_ModuleInit(char *hServer, char *hModule)
  {
    return (Ns_TclInitInterps(hServer, Ttext_Init, NULL));
  }

  

}
