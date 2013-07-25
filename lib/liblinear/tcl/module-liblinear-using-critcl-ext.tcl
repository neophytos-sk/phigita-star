package provide liblinear 0.1

::xo::lib::require critcl
::xo::lib::require critcl-ext


::critcl::reset
::critcl::config outdir /web/local-data/critcl/
::critcl::cache /web/local-data/critcl/cache/
::critcl::config force [::xo::kit::debug_mode_p]
::critcl::config keepsrc 1

::critcl::config language c++
::critcl::clibraries -lstdc++ -lblas

set dir [file dirname [info script]]
::critcl::config I /opt/naviserver/include [file join $dir ../c/]

#  blas/blas.h  blas/blasp.h blas/daxpy.c blas/ddot.c blas/dnrm2.c blas/dscal.c
foreach file {linear.cpp tron.cpp linear.h tron.h} {
    set extension [file extension $file]
    set filename  [file join $dir ../c/ $file]
    if { $extension eq {.h} } {
        ::critcl::cheaders $filename
    } else {
        ::critcl::csources $filename
    }
}


critcl::ccode {
    #include "ns.h"
    #include "linear.h"
    #include <string.h>

}

define_ctype ll_parameter {struct parameter} {
    int     solver_type;

    /* these are for training only */
    double  eps;          /* stopping criteria */
    double  C;
    int     nr_weight;
    int     *weight_label /* @size "nr_weight" */ ;
    double  *weight       /* @size "nr_weight" */ ;
}

define_ctype ll_feature_node {struct feature_node} {
    int    index;
    double value;
}



define_ctype ll_problem {struct problem} {
    int l                     /* @comment "number of training data"                        */ ;
    int n                     /* @comment "number of feature (including bias)"             */ ;
    int *y                    /* @size "l"   @comment "target values/labels"               */ ;

    struct feature_node **x   /* @size "l n" @input "inline" @allocType(n) "sparse" @allocIf(n) "%s.index != -1" */ ;

    double bias               /* @comment "<0 if no bias term"                             */ ;
}

 
define_ctype ll_model {struct model} {
    struct parameter param;
    int nr_class               /* @comment "number of classes"                    */ ;
    int nr_feature             /* @comment "number of features"                   */ ;
    double *w                  /* @size "nr_feature nr_class"                     */ ;
    int *label                 /* @size "nr_class" @comment "label of each class" */ ;
    double bias;
}



::critcl::cproc ll_train {Tcl_Interp* interp Tcl_Obj* objPtr1 Tcl_Obj* objPtr2} ok {

    Tcl_Obj* problemObj = ll_problem_GetObjFromHandle(interp,&ll_problem_HashTable,objPtr1);
    Tcl_Obj* paramObj = ll_parameter_GetObjFromHandle(interp,&ll_parameter_HashTable,objPtr2);

    ll_problem_InternalType *internal1 = (ll_problem_InternalType *) problemObj->internalRep.otherValuePtr;
    struct problem* problem = (struct problem *) internal1->dataPtr;

    ll_parameter_InternalType *internal2 = (ll_parameter_InternalType *) paramObj->internalRep.otherValuePtr;
    struct parameter* param = (struct parameter *) internal2->dataPtr;

    struct model *model = train(problem,param);
    Tcl_Obj* modelObj = ll_model_Tcl_Obj(model);

    Tcl_SetObjResult(interp,modelObj);
    return TCL_OK;
}

::critcl::cproc ll_predict {Tcl_Interp* interp Tcl_Obj* objPtr Tcl_Obj* listPtr} int {
    Tcl_Obj* modelObj = ll_model_GetObjFromHandle(interp,&ll_model_HashTable,objPtr);

    ll_model_InternalType *internal = (ll_model_InternalType *) modelObj->internalRep.otherValuePtr;
    struct model *model = (struct model *) internal->dataPtr;

    // predict

    int nr_class=get_nr_class(model);
    double *prob_estimates=NULL;
    int j, n;
    int nr_feature=get_nr_feature(model);


    fprintf(stderr,"nr_class=%d nr_feature=%d\n",nr_class, nr_feature);

    if(model->bias>=0) {
	n=nr_feature+1;
    } else {
	n=nr_feature;
    }


    // TODO: flag_predict_probability

    int i=0;
    int listLength=0;
    Tcl_ListObjLength(interp,listPtr,&listLength);
    int inst_max_index = 0;
    struct feature_node *x = (struct feature_node *) Tcl_Alloc((listLength+2)*sizeof(struct feature_node));
    for(i=0; i<listLength; ++i) {
				 Tcl_Obj *elemListPtr;
				 Tcl_Obj *indexPtr;
				 Tcl_Obj *valuePtr;

			       Tcl_ListObjIndex(interp,listPtr,i,&elemListPtr);
			       Tcl_ListObjIndex(interp,elemListPtr,i,&indexPtr);
			       Tcl_ListObjIndex(interp,elemListPtr,i,&valuePtr);

			       Tcl_GetIntFromObj(interp,indexPtr,&(x[i].index));
			       Tcl_GetDoubleFromObj(interp,valuePtr,&(x[i].value));

	if (x[i].index <= inst_max_index) {
	    // Tcl_AppendError
	    return TCL_ERROR;
	} else {
	    inst_max_index = x[i].index;
	}

	// feature indices larger than those in training are not used
	if(x[i].index <= nr_feature)
	++i;

    }
    
    if(model->bias>=0)
    {
	x[i].index = n;
	x[i].value = model->bias;
	i++;
    }
    x[i].index = -1;


    int predict_label = predict(model,x);

    Tcl_Free((char *) x);

    return predict_label;
}

::critcl::cproc ll_save_model {Tcl_Interp* interp Tcl_Obj* filenameObj Tcl_Obj* objPtr} ok {
    Tcl_Obj* modelObj = ll_model_GetObjFromHandle(interp,&ll_model_HashTable,objPtr);

    ll_model_InternalType *internal = (ll_model_InternalType *) modelObj->internalRep.otherValuePtr;
    struct model *model = (struct model *) internal->dataPtr;
	
    const char *model_file_name = Tcl_GetString(filenameObj);
    save_model(model_file_name,model);

    Tcl_SetObjResult(interp,modelObj);
    return TCL_OK;
}

::critcl::cproc ll_load_model {Tcl_Interp* interp Tcl_Obj* newObjName Tcl_Obj* filenameObj} ok {

    const char *model_file_name = Tcl_GetString(filenameObj);
    struct model *model = (struct model *) load_model(model_file_name);

    fprintf(stderr,"nr_class=%d nr_feature=%d\n",get_nr_class(model), get_nr_feature(model));

    Tcl_Obj* modelObj = ll_model_Tcl_Obj(model);

    /* just for debugging */
    ll_model_InternalType *internal = (ll_model_InternalType *) modelObj->internalRep.otherValuePtr;
    struct model *model2 = (struct model *) internal->dataPtr;
    fprintf(stderr,"nr_class=%d nr_feature=%d\n",get_nr_class(model2), get_nr_feature(model2));


    if (modelObj == NULL) {
	return TCL_ERROR;
    }
    int setVariable = 1;
    return ll_model_ReturnHandle(interp, modelObj, setVariable, newObjName);
}

::critcl::cbuild [file normalize [info script]]
