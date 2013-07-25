package provide json 0.1

set dir [file dirname [info script]]

::xo::lib::require critcl

::critcl::reset

set dir [file dirname [info script]]
::critcl::config I /opt/naviserver/include [file join $dir ../c/]

::critcl::cfile {JSON_parser.h JSON_parser.c}

::critcl::cinit {
    // init_text

    Tcl_CreateObjCommand(ip, "::json::json_to_dict", json_JsonToDictCmd, NULL, NULL);

} {
    // init_exts
}

critcl::ccode {


    #define CheckArgs(min,max,n,msg) \
                     if ((objc < min) || (objc >max)) { \
                         Tcl_WrongNumArgs(interp, n, objv, msg); \
                         return TCL_ERROR; \
                     }

    static int json_ModuleInitialized;



static int json_print(void* ctx, int type, const JSON_value* value)
{

    switch(type) {
	case JSON_T_ARRAY_BEGIN:    
        if (!s_IsKey) print_indention();
        s_IsKey = 0;
        printf("[\n");
        ++s_Level;
        break;
    case JSON_T_ARRAY_END:
        assert(!s_IsKey);
        if (s_Level > 0) --s_Level;
        print_indention();
        printf("]\n");
        break;
   case JSON_T_OBJECT_BEGIN:
       if (!s_IsKey) print_indention();
       s_IsKey = 0;
       printf("{\n");
        ++s_Level;
        break;
    case JSON_T_OBJECT_END:
        assert(!s_IsKey);
        if (s_Level > 0) --s_Level;
        print_indention();
        printf("}\n");
        break;
    case JSON_T_INTEGER:
        if (!s_IsKey) print_indention();
        s_IsKey = 0;
        printf("integer: "JSON_PARSER_INTEGER_SPRINTF_TOKEN"\n", value->vu.integer_value);
        break;
    case JSON_T_FLOAT:
        if (!s_IsKey) print_indention();
        s_IsKey = 0;
        printf("float: %f\n", value->vu.float_value); /* We wanted stringified floats */
        break;
    case JSON_T_NULL:
        if (!s_IsKey) print_indention();
        s_IsKey = 0;
        printf("null\n");
        break;
    case JSON_T_TRUE:
        if (!s_IsKey) print_indention();
        s_IsKey = 0;
        printf("true\n");
        break;
    case JSON_T_FALSE:
        if (!s_IsKey) print_indention();
        s_IsKey = 0;
        printf("false\n");
        break;
    case JSON_T_KEY:
        s_IsKey = 1;
        print_indention();
        printf("key = '%s', value = ", value->vu.str.value);
        break;   
    case JSON_T_STRING:
        if (!s_IsKey) print_indention();
        s_IsKey = 0;
        printf("string: '%s'\n", value->vu.str.value);
        break;
    default:
        assert(0);
        break;
    }
    
    return 1;
}


    /*
    *----------------------------------------------------------------------
    *
    * json_JsonToDictCmd --
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

    int json_JsonToDictCmd(ClientData clientData,Tcl_Interp *interp,int objc,Tcl_Obj * const objv[]) {
	
	CheckArgs(2,3,1,"jsonVar ?depth?");
	
	const char *varName = Tcl_GetString(objv[1]);
	const char *json = Tcl_GetVar(interp, varName, 0);

	int depth = 19; // default depth
	if (objc == 3) {
	    depth = Tcl_GetInt(objv[1]);
	}


	Tcl_Obj *dictPtr = Tcl_NewDictObj();

	int count = 0, result = 0;
	FILE* input;
        
	JSON_config config;

	struct JSON_parser_struct* jc = NULL;
	
	init_JSON_config(&config);
	
	config.depth                  = depth;
	config.callback               = &json_print;
	config.allow_comments         = 1;
	config.handle_floats_manually = 0;
	config.callback_ctx = (void *) dictPtr;

	/* Important! Set locale before parser is created. */
	/*
	if (argc >= 2) {
	    if (!setlocale(LC_ALL, argv[1])) {
		fprintf(stderr, "Failed to set locale to '%s'\n", argv[1]);
	    }
	} else {
	    fprintf(stderr, "No locale provided, C locale is used\n");
	}
	*/
	
	jc = new_JSON_parser(&config);
	
	const char *input = json;
	for (; input ; ++count) 
	{
	 //int next_char = fgetc(input);
	 int next_char = input[0];
	 if (next_char <= 0) {
	     break;
	 }
	 if (!JSON_parser_char(jc, next_char)) {
	     DBG(fprintf(stderr, "JSON_parser_char: syntax error, byte %d\n", count));
	     result = 1;
	     goto done;
	 }
     }
	if (!JSON_parser_done(jc)) {
	    DBG(fprintf(stderr, "JSON_parser_end: syntax error\n"));
	    result = 1;
	    goto done;
	}
	
	done:
	delete_JSON_parser(jc);
	return TCL_OK;

    }


    /*----------------------------------------------------------------------------
     |   Initialize Module
     |   Activated at module load to initialize shared object handles table.
     |   This is exported since we need it in HERE: tdominit.c.
     \---------------------------------------------------------------------------*/


    void json_InitModule() 
    {
        //Tcl_MutexLock(&json_Mutex);
        if (!json_ModuleInitialized) {
            json_ModuleInitialized = 1;
        }
        //Tcl_MutexUnlock(&json_Mutex);
    }


}

::critcl::cbuild [file normalize [info script]]
