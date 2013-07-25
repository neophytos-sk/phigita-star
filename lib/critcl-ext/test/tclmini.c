#include "tcl.h"

typedef struct mystruct {
  int nr_weight;
  double *weight;
  int *weight_label;
} mystruct_t;

int main(){
  Tcl_Obj *listPtr, *listElemPtr, *listElemPtr2;
  Tcl_Interp *interp;
  int i;

  mystruct_t dataPtr;
  dataPtr.weight=NULL;
  
  interp=Tcl_CreateInterp();
  listPtr=Tcl_NewStringObj("123 456.78 90.123 3 {11 22 33} {44 55 66}", -1);
  
  Tcl_ListObjIndex(NULL, listPtr, 3, (Tcl_Obj **)&listElemPtr);
  Tcl_GetIntFromObj(NULL,listElemPtr,&(dataPtr.nr_weight));

  // Issue (fatal signal 11) was with Tcl_InvalidateStringRep(listElemPtr) before every code block
  Tcl_SetObjLength(listElemPtr,0);
  Tcl_ListObjIndex(interp,listPtr,4,&listElemPtr);
  fprintf(stderr,"4th elem is %s\n", Tcl_GetString(listElemPtr));


  dataPtr.weight_label=(int *)ckalloc(dataPtr.nr_weight*sizeof(int));
  for(i=0;i<dataPtr.nr_weight;i++){
    Tcl_ListObjIndex(interp, listElemPtr,i,&listElemPtr2);
    Tcl_GetIntFromObj(interp,listElemPtr2,&(dataPtr.weight_label)[i]);
    fprintf(stderr,"\t[4.%d] as int: %d\n",i,dataPtr.weight_label[i]);
    //dataPtr.weight_label[i]=intvalue;
  }


  //Tcl_InvalidateStringRep(listElemPtr);
  Tcl_ListObjIndex(interp,listPtr,5,&listElemPtr);
  fprintf(stderr,"5th elem is %s\n", Tcl_GetString(listElemPtr));

  dataPtr.weight=(double *)ckalloc(dataPtr.nr_weight*sizeof(double));
  for(i=0;i<dataPtr.nr_weight;i++){
    Tcl_ListObjIndex(interp, listElemPtr,i,&listElemPtr2);
    Tcl_GetDoubleFromObj(interp,listElemPtr2,&(dataPtr.weight)[i]);
    fprintf(stderr,"\t[5.%d] as float: %5.2f\n",i,dataPtr.weight[i]);
  }


  return 0;
}

  
