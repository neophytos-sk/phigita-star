namespace eval ::templating {;}
namespace eval ::templating::runtime {;}


define_lang ::templating::lang {

    #node_cmd master
    #node_cmd include

    #node_cmd contract
    node_cmd param
    node_cmd pragma

    node_cmd widget  ;# datastore, dataview, grid
    node_cmd tpl     ;# if, for, with
    node_cmd item
    node_cmd column

    text_cmd val
    text_cmd guard
    text_cmd js
    text_cmd css
    text_cmd tcl

    foreach cmd_name {
        layout layout_row layout_col
        grid toolbar datastore dataview
        action
        master include
        contract
    } {
        interp alias {} $cmd_name {} ::templating::lang::widget -type $cmd_name
    }

    dtd {

#TODO

        <!DOCTYPE html [

            <!ELEMENT html (widget | tpl | val | guard | js | css | tcl)*>

            <!ELEMENT widget (#PCDATA)>

            <!ELEMENT contract (param | pragma)*>

            <!ELEMENT grid (column)*>

            <!ELEMENT master (#PCDATA)>
            <!ATTLIST master src #CDATA>

            <!ELEMENT include EMPTY>
            <!ATTLIST include src #CDATA>

            <!ELEMENT slave EMPTY>
        ]>
    }
}

proc require_template_procs {} {

    ::xo::lib::require html_procs

    require_html_procs

    require_lang ::templating::lang

}


namespace eval ::templating::tag {;}

namespace eval ::templating::tag::master {;}

proc ::templating::tag::master::deps {codearrVar node} {
    set default_src "templates/default-master.inc"
    set filename [file normalize [acs_root_dir]/[$node @src $default_src]]
    return [list $filename]
}

proc ::templating::tag::master::initial_rewrite {codearrVar node {argVar ""}} {

    upvar $codearrVar codearr

    if { ${argVar} ne {} } {
        upvar ${argVar} arg
    }

    $node setAttribute __todelete 1

    proc ::templating::lang::slave {} "widget -type slave -id slave_$node"

    set default_src "templates/default-master.inc"
    set src [$node @src $default_src]
    set filename [file normalize [acs_root_dir]/${src}]

    # save master node attributes into an array
    # slave script can make use of these attributes
    array set arg [list]
    foreach att [$node attributes] {
        set arg($att) [$node @${att}]
    }

    set pn [$node parentNode]
    $pn insertBeforeFromScript { 
        source_inscope ${filename} ::templating::lang
    } $node

    # move children before the 'slave' placeholder
    set placeholder [tdom_getElementById $pn "slave_${node}"]
    if { $placeholder eq {} } {
        error "did not find slave node with id slave_${node}"
    }
    set childNodes [$node childNodes]
    foreach child $childNodes {
        [$placeholder parentNode] insertBefore $child $placeholder
    }
    $placeholder setAttribute __todelete 1
    $placeholder delete


    # if the master template introduced a new include or master node,
    # we need to 'initial_rewrite' that as well
    set new_nodes [${node} selectNodes {preceding-sibling::*/descendant-or-self::widget[@type='include' or @type='master']}]
    foreach new_node $new_nodes {

        if { [${new_node} @__todelete 0] } continue

        initial_rewrite codearr ${new_node} arg

    }


    # look for descendant nodes that have the x-master-renderTo attribute
    set rendernodes [$node selectNodes {preceding-sibling::*/descendant-or-self::*[@x-master-renderTo != ""]}]
    foreach descendant $rendernodes {
        set renderTo [$descendant @x-master-renderTo]
        set x [tdom_getElementById $pn $renderTo]
        if { $x ne {} } {
            $x appendChild $descendant
            $descendant removeAttribute "x-master-renderTo"
        } else {
            error "master::initial_rewrite --->>> x-master-renderTo=${renderTo} not found in the descendants of the master node with src=${src}"
        } 	
    }

}

namespace eval ::templating::tag::include {;}

proc ::templating::tag::include::deps {codearrVar node} {
    set filename [file normalize [acs_root_dir]/[$node @src]]
    return [list $filename]
}

proc ::templating::tag::include::initial_rewrite {codearrVar node {argVar ""}} {

    upvar $codearrVar codearr

    if { ${argVar} ne {} } {
        upvar ${argVar} arg
    }

    $node setAttribute __todelete 1

    set filename [file normalize [acs_root_dir]/[$node @src]]

    # save include node attributes into an array
    # script being included can make use of these attributes
    array set arg [list]
    foreach att [$node attributes] {
        set arg($att) [$node @${att}]
    }

    set pn [$node parentNode]
    $pn insertBeforeFromScript {
        source_inscope ${filename} ::templating::lang
    } $node


    # if the include template introduced a new include or master node,
    # we need to 'initial_rewrite' that as well
    set new_nodes [$node selectNodes {preceding-sibling::*/descendant-or-self::widget[@type='include' or @type='master']}]
    foreach new_node $new_nodes {

        if { [${new_node} @__todelete 0] } continue

        initial_rewrite codearr ${new_node} arg

    }


}



namespace eval ::templating::tag::column {;}

proc ::templating::tag::column::final_rewrite {codearrVar node} {

    if { ![$node hasAttribute "renderer"] } {
	if { [$node hasAttribute "adp"] } {

	    $node setAttribute renderer "adp"

	} elseif { [$node hasAttribute "template"] } {

	    # TODO: add renderer/formatter, e.g. url:canonicalize('http://www.phigita.net/')
	    ::adp_compiler::compile_template $node

	} elseif { [$node hasAttribute "dataIndex"] } {

	    $node setAttribute renderer "text"

	} else {

	    error "you must provide a 'template' or a 'renderer' or a 'dataIndex': node=[$node asHTML]"

	}
    }
}

namespace eval ::templating::tag::val {;}

proc ::templating::tag::val::final_rewrite {codearrVar node} {

    upvar $codearrVar codearr

    set script [$node text]

    set with [$node @with ""]
    if { ${with} ne {} } {
        set script [prepend_with_object $script $with]
    }

    set doc [$node ownerDocument]
    $node replaceChild [$doc createTextNode $script] [$node first]

    set id [$node @id ""]
    set name [$node @name $id]

    # helps to associate the attributes from a datastore/dataset 
    # when the value is an element of that dataset so that
    # we can do proper error checking - we should perhaps 
    # replace this by a specialized tag in the future
    set valuefrom [$node @x-value-from ""]
    if { ${valuefrom} ne {} } {
        set codearr(${name},attributes) $codearr(${valuefrom},attributes)
    }

    # we have situation in which we setup a list of objects-dictionaries
    # and we need to specify the attributes for the elements in that list
    set attributes [$node @x-value-attributes ""]
    foreach attname ${attributes} {
        lappend codearr(${name},attributes) ${attname}
    }

}

proc ::templating::tag::val::to_c {codearrVar node} {

    upvar $codearrVar codearr

    set other_id [$node @other_id ""]
    set id [$node @id $node]
    set name [$node @name $id]

    set orig_script [string trim [$node text]]
    set script [transform_refs codearr $orig_script num_refs]

    set timeout [$node @cache_timeout ""]
    if { $timeout ne {} && [string is integer -strict $timeout] } {
        set script "util_memoize \{${script}\} ${timeout}"
    }

    add_global_string codearr OBJECT_DATA "::__data__"
    add_global_string codearr OBJECT_VARNAME_${name} ${name}

    set found_p [exists_indexed_script codearr ${script} ref_id]
    if ${found_p} {
        if { ${ref_id} eq ${id} } {
        # if same script and same id, skip the call
            return
        } else {
        # uses the same script but still makes the call
            return "tdp_val(interp,global_objects,OBJECT_SCRIPT_${ref_id},OBJECT_VARNAME_${name})"
        }
    }

    add_indexed_script codearr ${id} ${script}

    # c code for val is now included in tdp.h
    # if { [incr codearr(count,val) 0] == 0 } {
    # #tag=val id=${id}
    # append codearr(defs) [subst -nocommands -nobackslashes {}]
    # }

    incr codearr(count,val)

    return "tdp_val(interp,global_objects,OBJECT_SCRIPT_${id},OBJECT_VARNAME_${name})"
}


namespace eval ::templating::tag::contract {;}



proc ::templating::tag::contract::initial_rewrite {codearrVar node} {

    upvar $codearrVar codearr

    $node setAttribute __todelete 1

    set doc [$node ownerDocument]
    set pn [$node parentNode]


    set has_accept_proto_p [$node hasAttribute accept_proto]
    if { ${has_accept_proto_p} } {
        set accept_proto_for_script  [list [$node @accept_proto ""]]
        set script [subst -nocommands -nobackslashes {
            if { -1 == [lsearch -exact -nocase ${accept_proto_for_script} [::util::coalesce [ad_conn protocol] {http}]] } {
                return 0
            }
            return 1
        }]
        $pn insertBeforeFromScript { 
            guard -id contract__check_conn_proto ${script}
        } $node
    }

    if { [$node hasAttribute accept_method] } {
        set accept_method_for_script [list [$node @accept_method ""]]
        set script [subst -nocommands -nobackslashes {
            if { -1 == [lsearch -exact -nocase ${accept_method_for_script} [ad_conn method]] } {
                return 0
            }
            return 1
        }]
        $pn insertBeforeFromScript { 
            guard -id contract__check_conn_method ${script}
        } $node
    }

    set require_secure_conn_p [$node @require_secure_conn "0"] 
    if { ${require_secure_conn_p} } {
        $pn insertBeforeFromScript { 
            guard -id contract__require_secure_conn {::xo::kit::require_secure_conn}
        } $node
    }

    set require_registration_p [$node @require_registration "0"]
    if { ${require_registration_p} } {
        $pn insertBeforeFromScript { 
            guard -id contract__require_registration {::xo::kit::require_registration}
        } $node
    }

    #error "you cannot require_secure_conn and not accept protocol 'https'"

    foreach child [$node childNodes] {

        set tagname [$child nodeName]
        if { $tagname eq {param} } {
            set id         [$child @id]
            set name       [$child @name $id]
            set strict_p   [::util::coalesce [$child @strict_p "0"] "1"]
            set optional_p [::util::coalesce [$child @optional "0"] "1"]
            set default    [$child @default ""]
            set vlist      [$child @check ""]
            set proclist   [$child @transform ""]

            # TODO: remove this when you implement check with xmlint
            # or incorporate the check there
            foreach vcheck $vlist { 
                set re {[[:alnum:]_]}
                if { ![regexp -- $re $vcheck] } {
                # complain about it
                    error "vcheck '${vcheck}' must be an alphanumeric+underscore string"
                }
                if { [info procs ::templating::validation::check=${vcheck}] eq {} } {
                    error "no matching proc for '${vcheck}' in ::templating::validation::check=*"
                }
            }

            add_global_string codearr OBJECT_VARNAME_${name} ${name}

            set script [list ::templating::get_and_check_param ${id} ${name} ${strict_p} ${optional_p} ${default} ${vlist} ${proclist}]

            $pn insertBeforeFromScript { 
                guard -id check_param_${id} ${script}
            } $node

            $child delete

        } elseif { $tagname eq {pragma} } {

            set id [$child @id]
            set value [$child @value]

            set codearr(pragma.${id}) ${value}

        } elseif { $tagname eq {auth} } {
        # require regisration
        # group / community membership
        } elseif { $tagname eq {perm} } {
        # check permission
        } elseif { $tagname eq {conn} } {
        # accepted protocol
        # accepted method
        # require secure conn
        } elseif { $tagname eq {inst} } {
        # instantiate well known vars, 
        # e.g. registered_p, user_id, context_username, screen_name
        }

    }
}


namespace eval ::templating::tag::guard {;}

proc ::templating::tag::guard::final_rewrite {codearrVar node} {


    set script [$node text]

    set with [$node @with ""]
    if { ${with} ne {} } {
	set script [prepend_with_object $script $with]
    }

    set doc [$node ownerDocument]
    $node replaceChild [$doc createTextNode $script] [$node first]

}

proc ::templating::tag::guard::to_c {codearrVar node} {

    upvar $codearrVar codearr

    set other_id [$node @other_id ""]
    set id [$node @id $node]

    set orig_script [string trim [$node text]]
    set script [transform_refs codearr $orig_script num_refs]

    set found_p [exists_indexed_script codearr ${script} ref_id]
    if ${found_p} {
        if { ${ref_id} eq ${id} } {
        # if same script and same id, skip the call
            return
        } else {
        # uses the same script but still makes the call
            return "tdp_guard(interp,global_objects,OBJECT_SCRIPT_${ref_id},OBJECT_VARNAME_${name})"
        }
    }

    add_global_string codearr OBJECT_DATA "::__data__"
    add_indexed_script codearr ${id} ${script}

    # c code for guard now in tdp.h
    # if { [incr codearr(count,guard) 0] == 0 } {
    # # tag=guard id=${id}
    # # _xo_${other_id}
    #    append codearr(defs) [subst -nocommands -nobackslashes {}]
    # }

    incr codearr(count,guard)

    return "tdp_guard(interp,global_objects,OBJECT_SCRIPT_${id});"
}



namespace eval ::templating::tag::datastore {;}



proc ::templating::tag::datastore::final_rewrite {codearrVar node} {

    upvar $codearrVar codearr

    set id [$node @id ""]
    set name [$node @name $id]

    if { ![$node hasAttribute from_class] } {
	error "missing 'from_class' from datastore with id=${id} and name=${name}"
    }

    set scope [$node @scope ""]
    set pool [$node @pool "main"]
    set cache [$node @cache ""]
    set singleton [$node @singleton "false"]
    set distinct [$node @distinct "0"]
    set from_class [$node @from_class ""]
    set select [$node @select "*"]
    set where [$node @where ""]
    set where_if [$node @where_if ""]
    set order [$node @order ""]
    set group [$node @group ""]
    set offset [$node @offset ""]
    set limit [$node @limit ""]
    #set extend [$node @extend ""]

    set dataset [::db::Set new \
		     -pool $pool \
		     -cache $cache \
		     -scope $scope \
		     -distinct ${distinct} \
		     -select $select \
		     -type $from_class \
		     -where $where \
		     -where_if $where_if \
		     -order $order \
		     -group $group \
		     -offset $offset \
		     -limit $limit]

    # the script as returned from the dataset class
    set sql_script_orig [$dataset get_sql_script]

    set doc [$node ownerDocument]
    $node appendChild [$doc createTextNode $sql_script_orig]

    # now save the attributes to help us with error checking
    set sql_attributes [$dataset get_sql_attributes]
    
    if { $sql_attributes eq {} } {
	ns_log error "no sql_attributes for datastore with id=${id} and name=${name}"
    }

    # add attributes from 'extend'
    set extend [$node @extend ""]
    set extend_attrs [list]
    if { ${extend} ne {} } {
	# this does not cover vars passed by reference
	set re {$\s*set\s+([a-zA-Z0-9_]+)\s+}
	set matches [regexp -line -all -inline -- ${re} ${extend}]
	foreach {match submatch} $matches {
	    lappend extend_attrs ${submatch}
	}
    }

    set codearr(${name},singleton) ${singleton}
    set codearr(${name},sql_attributes) ${sql_attributes}
    set codearr(${name},extend_attributes) ${extend_attrs}
    set codearr(${name},attributes) [concat ${sql_attributes} ${extend_attrs}]

}



proc ::templating::tag::datastore::to_c {codearrVar node} {

    # ns_log notice "--->>> datastore::to_c [$node @id]"

    upvar $codearrVar codearr


    set other_id [$node @other_id]
    set id [$node @id $node]
    set name [$node @name $id]
    set other_id [$node @other_id ""]
    set pool [$node @pool ""]
    set cache [$node @cache ""]

    set sql_script_orig [$node text]


    # substitute bind vars in sql script, id=:id
    set sql_script_quoted_vars [sql_bind_var_substitution $sql_script_orig]

    # transform any other refs, e.g. -where @{extra_clause}
    set sql [transform_refs codearr $sql_script_quoted_vars]



    set extend [transform_refs codearr [$node @extend ""]]

    set singleton [::util::boolean [$node @singleton "false"]]

    set cache_expr [list]
    if { $cache ne {} } {
        set num_of_refs 0
        lappend cache_expr [transform_refs codearr ${cache} num_of_refs]
        lappend cache_expr $num_of_refs

        set timeout [$node @cache_timeout ""]
        if { $timeout ne {} } {
            lappend cache_expr ${timeout}
        }

    }

    add_global_string codearr OBJECT_DATA_FROM_SQL_SCRIPT_CMD "data_from_sql_script"
    add_global_string codearr OBJECT_VARNAME_${name} ${name}
    add_global_string codearr OBJECT_POOL_${pool} ${pool}
    add_global_string codearr OBJECT_SQL_${id} ${sql}
    add_global_string codearr OBJECT_CACHE_${id} ${cache_expr}
    add_global_string codearr OBJECT_EXTEND_${id} ${extend}

    # for XOTCL/NSF objects
    add_global_string codearr OBJECT_EVAL_METHOD "eval"

    # for TCL dictionaries
    add_global_string codearr OBJECT_DICT_KEYWORD "dict"
    add_global_string codearr OBJECT_WITH_KEYWORD "with"
    add_global_string codearr OBJECT_TMPNAME_dictionaryVariable "::__mydict__"
    add_global_string codearr OBJECT_EMPTY ""

    set c_extend_code ""
    if { $extend ne {} } {

        set data_object_type [::templating::config::get_option "data_object_type"]

        if { $data_object_type eq {DICT} } {


            lassign [intersect3 \
                $codearr(${name},extend_attributes) \
                $codearr(${name},sql_attributes)] \
                added_attrs \
                common_attrs \
                deleted_attrs


            set extend_dict_extra ""
            set extend_keyc 0
            foreach att $added_attrs {
                add_global_string codearr OBJECT_DICT_KEY_${att} ${att}
                #append extend_keyv_extra "global_objects\[OBJECT_DICT_KEY_${att}\]"
                append extend_dict_extra "\n" "Tcl_DictObjPut(interp,dictPtr,global_objects\[OBJECT_DICT_KEY_${att}\],global_objects\[OBJECT_EMPTY\]);"
                incr extend_keyc
            }

            set c_extend_code [subst -nocommands -nobackslashes {

                Tcl_Obj *const extend_objv[] = {
                    global_objects[OBJECT_DICT_KEYWORD],
                    global_objects[OBJECT_WITH_KEYWORD],
                    global_objects[OBJECT_TMPNAME_dictionaryVariable],
                    global_objects[OBJECT_EXTEND_${id}]
                };

                int i;
                Tcl_Obj *objPtr_i;
                for (i = 0; i < length; i++) 
                {
                    Tcl_ListObjIndex(interp,listPtr,i,&objPtr_i);
                    Tcl_IncrRefCount(objPtr_i);

                    Tcl_Obj *dictPtr = Tcl_ObjSetVar2(interp,
                    global_objects[OBJECT_TMPNAME_dictionaryVariable],
                    NULL,
                    Tcl_DuplicateObj(objPtr_i),
                    TCL_LEAVE_ERR_MSG);

                    #if ${extend_keyc}
                    ${extend_dict_extra}
                    #endif

                    if (TCL_ERROR == Tcl_EvalObjv(interp, 4, extend_objv, TCL_EVAL_GLOBAL)) {
                        int j;
                        DBG(fprintf(stderr,"FAILURE interp_result=%s\n",Tcl_GetStringResult(interp)));
                        // Tcl_DecrRefCount(objPtr_i);
                        Tcl_DecrRefCount(listPtr);
                        return TDP_ERROR;
                    }

                    #if ${extend_keyc}
                    Tcl_ListObjReplace(interp,
                    listPtr,
                    i,
                    1,
                    1,
                    (Tcl_Obj **) &dictPtr);
                    #endif

                    // DBG(fprintf(stderr,"extend iteration i=%d dict=%s\n",i,Tcl_GetString(objPtr_i)));

                    Tcl_DecrRefCount(objPtr_i);
                }

            }]

        } elseif { $data_object_type eq {NSF} } {

            set c_extend_code [subst -nocommands -nobackslashes {

                Tcl_Obj * extend_objv[] = {
                    NULL,
                    global_objects[OBJECT_EVAL_METHOD],
                    global_objects[OBJECT_EXTEND_${id}]
                };

                int i;

                Tcl_Obj *objPtr_i;
                for (i = 0; i < length; i++) 
                {
                    Tcl_ListObjIndex(interp,listPtr,i,&objPtr_i);
                    Tcl_IncrRefCount(objPtr_i);
                    extend_objv[0] = objPtr_i;
                    if (TCL_ERROR == Tcl_EvalObjv(interp,3,extend_objv,TCL_EVAL_GLOBAL)) {
                        Tcl_DecrRefCount(objPtr_i);
                        Tcl_DecrRefCount(listPtr);
                        return TDP_ERROR;
                    }
                    Tcl_DecrRefCount(objPtr_i);
                }

            }]

        }
    }

    if { ${singleton} } {
    # save the head of the list
    # in most cases singleton should be accompanied with limit=1
    # and thus the listPtr would contain just one element
        set c_save_result [subst -nocommands -nobackslashes {

            if (length) {
                // return the head of the list
                Tcl_Obj *newValuePtr;
                Tcl_ListObjIndex(interp,listPtr,0, &newValuePtr);
                Tcl_IncrRefCount(newValuePtr);
                Tcl_Obj *objPtr = Tcl_ObjSetVar2(interp, part1Ptr, part2Ptr,newValuePtr,TCL_GLOBAL_ONLY);
                if (!objPtr) {
                    Tcl_DecrRefCount(newValuePtr);
                    Tcl_DecrRefCount(listPtr);
                    return TDP_ERROR;
                }
                Tcl_DecrRefCount(newValuePtr);
            } else {
                Tcl_Obj *objPtr = Tcl_ObjSetVar2(interp, part1Ptr, part2Ptr,listPtr,TCL_GLOBAL_ONLY);
                if (!objPtr) {
                    Tcl_DecrRefCount(listPtr);
                    return TDP_ERROR;
                }
            }
        }]
    } else {
    # save the whole list
        set c_save_result [subst -nocommands -nobackslashes {
            Tcl_Obj *objPtr = Tcl_ObjSetVar2(interp, part1Ptr, part2Ptr,listPtr,TCL_GLOBAL_ONLY);
            if (!objPtr) {
                Tcl_DecrRefCount(listPtr);
                return TDP_ERROR;
            }
        }]
    }

    append codearr(defs) [subst -nocommands -nobackslashes {
        // tag=datastore id=${id}
        // wrap code in functions to avoid name clashes
        static
        int _xo_${other_id}(Tcl_Interp *interp, Tcl_Obj **global_objects) {

            Tcl_Obj *const objv[] = {
                global_objects[OBJECT_DATA_FROM_SQL_SCRIPT_CMD],
                global_objects[OBJECT_VARNAME_${name}],
                global_objects[OBJECT_POOL_${pool}],
                global_objects[OBJECT_SQL_${id}],
                global_objects[OBJECT_CACHE_${id}]
            };


            if ( TCL_ERROR == Tcl_EvalObjv(interp,5,objv,TCL_EVAL_GLOBAL) ) {
                return TDP_ERROR;
            }

            Tcl_Obj *listPtr = Tcl_DuplicateObj(Tcl_GetObjResult(interp));
            Tcl_IncrRefCount(listPtr);

            int length;
            Tcl_ListObjLength(interp, listPtr, &length);

            ${c_extend_code}

            Tcl_Obj *part1Ptr = global_objects[OBJECT_DATA];
            Tcl_Obj *part2Ptr = global_objects[OBJECT_VARNAME_${name}];
            ${c_save_result}
            Tcl_DecrRefCount(listPtr);
            return TDP_OK;
        }
    }]

    return "_xo_${other_id}(interp,global_objects)"

}


namespace eval ::templating::tag::layout {;}

proc ::templating::tag::layout::final_rewrite {codearrVar node} {
    $node setAttribute __todelete 1

    # check @class in {"container" "container-fluid"}

    [$node parentNode] insertBeforeFromScript {
        set pn [::tmpl::div -class [$node @class "container"]]
    } $node

    set childNodes [$node childNodes]
    foreach child $childNodes {
        $pn appendChild $child
    }

}

namespace eval ::templating::tag::layout_row {;}

proc ::templating::tag::layout_row::final_rewrite {codearrVar node} {

    # check @class in {"row" "row-fluid"}
    if { [$node @class ""] eq {} } {
        $node setAttribute class "row"
    }

    [$node parentNode] insertBeforeFromScript {
        set pn [::tmpl::div]
    } $node

    foreach att [$node attributes] {
        if { $att ne {type} } {
            $pn setAttribute $att [$node @${att}]
        }
    }

    set childNodes [$node childNodes]
    foreach child $childNodes {
        $pn appendChild $child
    }

    $node setAttribute __todelete 1
}

namespace eval ::templating::tag::layout_col {;}


# The default Bootstrap grid system has 12 columns, 
# making for a 940px wide container without responsive
# features enabled. With the responsive CSS file added,
# the grid adapts to be 724px and 1170px wide depending
# on your viewport. Below 767px viewports, the columns
# become fluid and stack vertically.
proc ::templating::tag::layout_col::final_rewrite {codearrVar node} {

    # check @class matches "span*"
    # check @class matches "offset*"

    [$node parentNode] insertBeforeFromScript {
        set pn [::tmpl::div]
    } $node


    foreach att [$node attributes] {
        if { $att ne {type} } {
            $pn setAttribute $att [$node @${att}]
        }
    }

    set childNodes [$node childNodes]
    foreach child $childNodes {
        $pn appendChild $child
    }

    $node setAttribute __todelete 1

}

namespace eval ::templating::tag::dataview {;}

proc ::templating::tag::dataview::final_rewrite {codearrVar node} {

    #${::COMPILE_TEMPLATE} $node

}


proc ::templating::tag::dataview::to_c {codearrVar node} {

    upvar $codearrVar codearr


    # check if we have any widgets inside
    set widgets [$node selectNodes {descendant::widget}]

    #ns_log notice "dataview id=[$node @id ""] num_widgets=[llength ${widgets}]"

    foreach widget $widgets {

    #ns_log notice "(dataview) ::to_c [$widget @type ""] [$widget @id ""]"

        if { $widget eq $node } continue

        set cmdName [${widget} @type]
        set cmd "::templating::tag::${cmdName}::to_c"

        if { [info procs ${cmd}] ne {} } {
            set call_string [${cmd} codearr ${widget}]
            [$widget parentNode] insertBeforeFromScript {
                tpl -id [$widget @id ""] -call "${call_string}"
            } $widget

            # mark it so that we won't process it twice

            $widget setAttribute skip 1

            # move it out of the template that is being compiled
            # it will get deleted in compile_to_c_helper

            [$node parentNode] appendChild $widget
        }

    }
    # end of widgets inside this dataview


    ::templating::compiler::compile_template codearr $node

    # temp remove
    #::util::writefile /tmp/test_compiled_template_[$node @id ""].c [$node text]


    set code [$node text]
    set other_id [$node @other_id]

    append codearr(defs) [subst -nocommands -nobackslashes {
        // tag=dataview
        int
        _xo_${other_id}(Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_DString *dsPtr) {
            ${code}
        }
    }]
    return "_xo_${other_id}(interp,global_objects,dsPtr)"

}

namespace eval ::templating::tag::grid {;}

# proc ::templating::tag::grid::define {-store:required} {}
proc ::templating::tag::grid::final_rewrite {codearrVar node} {

    upvar $codearrVar codearr

    # TODO: check that node has a valid store attribute

    set childNodes [$node childNodes]
    foreach childNode $childNodes {
	::templating::tag::column::final_rewrite codearr $childNode
    }
}

proc ::templating::tag::grid::to_c {codearrVar node} {

    upvar $codearrVar codearr

    set id [$node @id ""]
    set other_id [$node @other_id ""]

    set dv [$node cloneNode]

    $dv appendFromScript {
	set childNodes [$node childNodes]
	
	array set continue [list sort 0]
	array set rcontinue [list 0 sort]

	table -class "table" {
	    thead {
		tr {
		    foreach child $childNodes {
			incr count
			th {
			    span { t [$child @text ""] }
			    if { [$child @sortable "0"] } {
				# TODO: useful to have grid object to ask for 
				# state/form vars that are relevant to the grid.
				# On a related note, we should be able to traverse
				# the tree context for state/form vars to export.
				a -href "?[$node @other_id ""].$continue(sort)=${count}" -class "x-column-header-trigger" { t "v" }
			    }
			}
		    }
		}
	    }
	    tbody {
		tpl -for "." {
		    tr {
			set index 0
			foreach child $childNodes {
			    set tdNode [tmpl::td {
				set renderer [$child @renderer ""]
				set child_id "${other_id}_column${index}"
				tpl \
				    -exec $renderer \
				    -config [tdom_attributesDict $child] \
				    -id ${child_id} { 

					nt [$child text]
				}
			    }]
			    if { [$child hasAttribute "cls"] } {
				$tdNode setAttribute class [concat [$tdNode @class ""] [$child @cls]]
			    }
			    incr index
			}
		    }
		}
	    }
	}
    }
    ::templating::compiler::compile_template codearr $dv

    set code [$dv text]
    $dv delete
    set other_id [$node @other_id]
    append codearr(defs) [subst -nocommands -nobackslashes {
	// tag=grid
	int
	_xo_${other_id}(Tcl_Interp *interp, Tcl_Obj **global_objects, Tcl_DString *dsPtr) {
	    ${code}
	}
    }]
    return "_xo_${other_id}(interp,global_objects, dsPtr)"
}



namespace eval ::templating::tag::js {;}

proc ::templating::tag::js::deps {codearrVar node} {

    set deps [$node @deps ""]

    set depfiles [list]
    foreach dep $deps {
	lappend depfiles [file normalize [acs_root_dir]/packages/${dep}]
    }

    return $depfiles
}

proc ::templating::tag::js::final_rewrite {codearrVar node} {
    $node setAttribute __todelete 1
    
    # deprecated
    set names_map [$node @names_map ""]
    if { $names_map ne {} } {
	::xo::kit::log "deprecated names_map is not empty, use xo.getCssName"
    }

    set externs [$node @externs ""]
    set key [$node @key $node]
    set names [$node @names ""]
    set deps [$node @deps ""]
    set tags [$node @tags ""]
    set inline_js [$node text]
    set excludeClassesFromRenaming [$node @excludeClassesFromRenaming ""]

    if { ${excludeClassesFromRenaming} ne {} } {
	::xo::tdp::excludeClassesFromRenaming ${excludeClassesFromRenaming}
    }
    ::templating::js::add_script ${key} $deps $names $tags $externs $inline_js

}


namespace eval ::templating::tag::css {;}

proc ::templating::tag::css::deps {codearrVar node} {
    set src [$node @src ""]
    if { ${src} ne {} } {
	set filename [file normalize [acs_root_dir]/${src}]
	return [list ${filename}]
    }
    return [list]
}

proc ::templating::tag::css::final_rewrite {codearrVar node} {
    $node setAttribute __todelete 1

    [$node parentNode] insertBeforeFromScript {
	if { [$node @href ""] ne {} } {
	    # mediabox.reader.js => /js/mediabor.reader.js
	    link -rel "stylesheet" -href [$node @href]
	} elseif { [$node @src ""] ne {} } {
	    set filename [file normalize [acs_root_dir]/[$node @src ""]]
	    lappend ::__CSS_FILE__ $filename
	}
	if { [$node text] ne {} } {
	    style -type text/css {
		nt [$node text]
	    }
	}
    } $node

}


if {0} {
    namespace eval ::templating::tag::anchor {;}
    proc ::templating::tag::anchor::final_rewrite {codearrVar node} {
	$node setAttribute __todelete 1

	if { [$node @href ""] ne {} } {
	    set href [$node @href]
	} elseif { [$node @target ""] ne {} } {
	    set target [$node @target]
	    set target_node [tdom_getElementById $node $target]
	    ::xo::kit::log target=[$node @target] target_node=$target_node
	    set other_id [$target_node @other_id]
	    set href "?select=${other_id}&action=[$node @action]"
	} elseif { [$node @route ""] ne {} } {
	    set href "call [$node @route] to get the link"
	}

	[$node parentNode] insertBeforeFromScript {
	    a -href $href {
		t [$node @text "--- no text ---"]
	    }
	} $node
    }
}
