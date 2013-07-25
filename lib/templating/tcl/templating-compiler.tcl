namespace eval ::templating::compiler {;}

proc ::templating::compiler::top_block {codearrVar} {
    upvar $codearrVar codearr

    if { [info exists codearr(block_stack)] } {
	set block [lindex $codearr(block_stack) end]

	return $block
    }
    return
}

proc ::templating::compiler::pop_block {codearrVar} {
    upvar $codearrVar codearr
    if { [info exists codearr(block_stack)] } {
	set codearr(block_stack) [lrange $codearr(block_stack) 0 end-1]
    }
}


proc ::templating::compiler::push_block {codearrVar block} {
    upvar $codearrVar codearr

    lappend codearr(block_stack) $block
}


proc ::templating::compiler::incr_block_count {codearrVar depth} {

    upvar $codearrVar codearr

    return [incr codearr(block_count)]

}

proc ::templating::compiler::get_parent_block {codearrVar block} {
    upvar $codearrVar codearr
    return $codearr(${block},parent)
}

proc ::templating::compiler::set_parent_block {codearrVar block parent_block} {
    upvar $codearrVar codearr

    set codearr(${block},parent) $parent_block

}

proc ::templating::compiler::set_block_store {codearrVar block store} {
    upvar $codearrVar codearr
    set codearr(${block},store) ${store}
}

proc ::templating::compiler::get_block_store {codearrVar block} {
    upvar $codearrVar codearr
    return $codearr(${block},store)
}

proc ::templating::compiler::vartype_for_store {store} {
    if { $store eq {} } {
	return "0 /* tclvar */"
    } else {
	return "1 /* nsfvar */"
    }
}


# examples for in_text:
# param.name
# parent.name
# val.name
# top.name
# blogdata:rowcount   (tcl modifier)
# bookmarkdata.title (nsf)
# TODO: name:trim
# TODO: age+5

proc ::templating::compiler::append_for_varname {codearrVar block varname_expr} {

    upvar $codearrVar codearr

    set parts [split $varname_expr {:}]

    if { [llength $parts] > 2 } {
	# we expect an identifier with an optional modifier
	# examples:
	#     _:rownum 
	#     blogdata:rowcount
	#     registered_p
	#     content_in_html:noquote
	#
	error "append_for_varname: 'varname_expr' must be an identifier with an optional modifier"
    }

    set modifier ""
    lassign ${parts} varname modifier

    set noquote 0
    if { ${modifier} eq {noquote} } {
	set noquote 1
	set modifier "" ;# noquote is dealt with separately
    }

    set prefix "append_"
    set extraArg ",dsPtr,${noquote}"

    return [getter_for_varname $codearrVar $block $varname $prefix $extraArg $modifier]
    
}

# similar to transform_refs_getter

proc ::templating::compiler::getter_for_varname_helper {codearrVar varname block modifier} {

    upvar $codearrVar codearr

    if { ${varname} eq {_} && ${modifier} eq {rownum} } {

	return "Tcl_NewIntObj(rownum_${block})"

    } elseif { ${modifier} eq {rowcount} } {

	if { ![exists_global_string codearr "OBJECT_VARNAME_${varname}"] } {
	    error "getter_for_varname_helper: no such identifier '${varname}'"
	}

	set rowcount_identifier ${varname}_rowcount
	set rowcount_varname ${varname},rowcount
	add_global_string codearr OBJECT_VARNAME2_${rowcount_identifier} ${rowcount_varname}

	return "getvar_0(interp,global_objects,global_objects\[OBJECT_DATA\],global_objects\[OBJECT_VARNAME2_${rowcount_identifier}\])"


    } elseif { ${modifier} eq {varname} } {


	if { ![exists_global_string codearr "OBJECT_VARNAME_${varname}"] } {
	    error "getter_for_varname: no such varname '${varname}'"
	}

	# return varname, not a substitution
	return global_objects\[OBJECT_VARNAME_${varname}\]

    } elseif { ${modifier} eq {trim} } {
	
	# string_trim_in_c(${block})
	ns_log error "TODO: implement 'string_trim_in_c' that returns tcl obj "

    } elseif { ${modifier} eq {length} } {

	# string_length_in_c(${block})
	ns_log error "TODO: implement 'string_length_in_c' that returns tcl obj "

    }  elseif { ${modifier} eq {llength} } {

	# llength_in_c(${block})
	ns_log error "TODO: implement 'llength_in_c' that returns tcl obj "

    } else {

	error "do not know what to do with modifier = $modifier"

    }
}

proc ::templating::compiler::getter_for_varname {codearrVar block in_text {prefix ""} {extraArg ""} {modifier ""}} {

    upvar $codearrVar codearr

    set result ""

    # getter command according to current block store
    # if store is "::__data__" or empty, then getvar2
    # otherwise, getter2

    set parts [split $in_text {.}]
    set num_parts [llength $parts]
    if { $num_parts == 1 } {

	if { ${modifier} eq {} } {

	    if { $in_text eq {_} } {
		if { $prefix eq {append_} } {
		    set result "append_obj(${block}${extraArg});"
		    #set result "append_obj(${thevar}${extraArg});"
		} else {
		    set result ${block}
		    #set result $thevar
		}
	    } else {

		# fetching from current context, blockX_oY, 
		set varname ${in_text}

		add_global_string codearr OBJECT_VARNAME_${varname} ${varname}

		set store [get_block_store codearr $block]

		if { ${store} ne {} && ${varname} ni $codearr(${store},attributes) } {
		    error "no such property '${varname}' for objects of '${store}'"
		}

		set vartype [vartype_for_store $store]
		set getterCmd ${prefix}${vartype}

		set result "${getterCmd}(interp,global_objects,${block},global_objects\[OBJECT_VARNAME_${in_text}\]${extraArg})"

	    }

	} else {

	    set theobj [getter_for_varname_helper codearr $in_text ${block} ${modifier}]
	    if { $prefix eq {append_} } {
		set result "append_obj(${theobj}${extraArg});"
	    } else {
		set result $theobj
	    }

	}

    } elseif { $num_parts == 2 } {

	lassign $parts part1 part2

	if { $part1 eq {_} && [string is integer -strict $part2] && ${part2} >= 0 } {

	    # listobjindex from block
	    if { $prefix eq {append_} } {
		set result "append_obj_element(interp,${block},${part2}${extraArg})"
	    } else {
		set result "${prefix}obj_element(interp,${block},${part2}${extraArg})"
	    }


	} elseif { $part1 eq {val} || $part1 eq {param} || $part1 eq {top} } {

	    # fetching value from global context, array "::__data__"

	    set varname $part2

	    if { ![exists_global_string codearr "OBJECT_VARNAME_${varname}"] } {
		error "getter_for_varname: no such varname '${varname}' in global context"
	    }

	    set vartype [vartype_for_store ""]
	    set getterCmd ${prefix}${vartype}

	    set result "${getterCmd}(interp,global_objects,global_objects\[OBJECT_DATA\],global_objects\[OBJECT_VARNAME_${varname}\]${extraArg})"

	} elseif { $part1 eq {parent} } {

	    # fetching from parent context, blockX_oY

	    set varname $part2
	    add_global_string codearr OBJECT_VARNAME_${varname} ${varname}

	    # returns an obj pointer in the form blockX_oY
	    set parent_block [get_parent_block codearr ${block}]

	    set store [get_block_store codearr $parent_block]

	    if { ${store} ne {} && ${varname} ni $codearr(${store},attributes) } {
		error "no such property '${varname}' for objects of '${varname}'"
	    }

	    set vartype [vartype_for_store $store]
	    set getterCmd ${prefix}${vartype}

	    set result "${getterCmd}(interp,global_objects,${parent_block},global_objects\[OBJECT_VARNAME_${varname}\]${extraArg})"

	} elseif { $part1 eq {proc} } {

	    # fetching value from the result of a call to a proc

	} else {

	    set varname ${part2}
	    add_global_string codearr OBJECT_VARNAME_${varname} ${varname}

	    # object_get.object.property

	    if { ![exists_global_string codearr "OBJECT_VARNAME_${part1}"] } {
		error "getter_for_varname: no such varname/store '${part1}' in global context"
	    }

	    if { ${varname} ni $codearr(${part1},attributes) } {
		error "no such property '${varname}' for objects of '${part1}'"
	    }

	    set vartype [vartype_for_store ${part1}] ;# in this case we fetch from the global data object
	    set getterCmd ${prefix}${vartype}

	    set objvar "Tcl_ObjGetVar2(interp,global_objects\[OBJECT_DATA\],global_objects\[OBJECT_VARNAME_${part1}\],TCL_GLOBAL_ONLY)"

	    set result "${getterCmd}(interp,global_objects,${objvar},global_objects\[OBJECT_VARNAME_${varname}\]${extraArg})"

	    # TODO: array_get.arrayname.element

	}
    } elseif { $num_parts == 3 } {
	lassign $parts part1 part2 part3

	if { $part1 eq {object_get} } {
	    set varname ${part3}
	    add_global_string codearr OBJECT_VARNAME_${varname} ${varname}


	    if { ![exists_global_string codearr "OBJECT_VARNAME_${part2}"] } {
		error "getter_for_varname: no such varname/store '${part2}' in global context"
	    }

	    # TODO: check that the store has a property by that varname

	    set vartype [vartype_for_store ${part2}] ;# in this case we fetch from the global data object
	    set getterCmd ${prefix}${vartype}

	    set objvar "Tcl_ObjGetVar2(interp,global_objects\[OBJECT_DATA\],global_objects\[OBJECT_VARNAME_${part2}\],TCL_GLOBAL_ONLY)"

	    set result "${getterCmd}(interp,global_objects,${objvar},global_objects\[OBJECT_VARNAME_${varname}\]${extraArg})"
	    
	}

    } else {
	# example: parent.parent.parent.title
	# do something
    }

    return $result

}


proc ::templating::compiler::compile_template_for {codearrVar node depth inside_code_block} {

    upvar $codearrVar codearr

    set parent_block [top_block codearr]
    set block_count [incr_block_count codearr $depth]
    set new_depth [expr {1+$depth}]
    set block "block${block_count}_o${new_depth}"

    set varname [$node @for]
    set listvar "block${block_count}_listPtr${depth}"
    if { $varname eq {.} || ${varname} eq {} } {
	set_block_store codearr $block [get_block_store codearr $parent_block]
	set list_expr ""
	append list_expr "\n" "Tcl_Obj *${listvar} = ${parent_block};"
    } else {
	set_block_store codearr $block ${varname}
	add_global_string codearr OBJECT_VARNAME_${varname} ${varname}
	set list_expr "Tcl_Obj *${listvar} = [getter_for_varname codearr $parent_block $varname "getvar_"];"
    }


    set indexvar "rownum_${block}"
    set lenvar   "rowcount_${block}"

    push_block codearr $block
    set_parent_block codearr ${block} ${parent_block}


    set compiled_tpl ""
    append compiled_tpl "\xff" 
    append compiled_tpl "\n" ${list_expr}
    append compiled_tpl "\n" "Tcl_IncrRefCount(${listvar});"
    append compiled_tpl "\n" "int ${lenvar},${indexvar};"
    append compiled_tpl "\n" "Tcl_ListObjLength(interp, ${listvar}, &${lenvar});"
    append compiled_tpl "\n" "Tcl_Obj *${block};"

    set offset [$node @offset "0"]
    set limit [$node @limit ""]
    set extra_condition ""
    if { $limit ne {} } {
	if { [string is integer $limit] } {
	    set limit_expr "$limit"
	}

	set extra_condition "&& ${indexvar}<${limit_expr}"
    }

    append compiled_tpl "\n" "for (${indexvar}=${offset}; ${indexvar}<${lenvar} ${extra_condition}; ${indexvar}++) \{"
    append compiled_tpl "\n" "  Tcl_ListObjIndex(interp,${listvar},${indexvar},&${block});"
    append compiled_tpl "\xfe"
    append compiled_tpl [compile_template_children codearr $node $new_depth $inside_code_block]
    append compiled_tpl "\xff" "\n" "\}"
    append compiled_tpl "\n" "Tcl_DecrRefCount(${listvar});" "\xfe"

    pop_block codearr

    return $compiled_tpl

}

proc ::templating::compiler::compile_template_with {codearrVar node depth inside_code_block} {

    upvar $codearrVar codearr

    set parent_block [top_block codearr]
    set block_count [incr_block_count codearr $depth]
    set new_depth [expr {1+$depth}]
    set block  "block${block_count}_o${new_depth}"

    push_block codearr $block
    set_parent_block codearr ${block} ${parent_block}

    set varname [$node @with]
    if { ${varname} eq {.} || ${varname} eq {} } {
	set_block_store codearr $block [get_block_store codearr $parent_block]
	set obj_expr "Tcl_Obj *${block} = ${parent_block};"
    } else {
	set_block_store codearr $block ${varname}
	add_global_string codearr OBJECT_VARNAME_${varname} ${varname}
	set obj_expr "Tcl_Obj *${block} = [getter_for_varname codearr ${parent_block} $varname "getvar_"];"
    }

    set compiled_tpl ""
    append compiled_tpl "\xff" 
    append compiled_tpl "\n" ${obj_expr}
    append compiled_tpl "\xfe"
    append compiled_tpl [compile_template_children codearr $node $new_depth $inside_code_block]
    append compiled_tpl "\xff" "\n" "\xfe"

    pop_block codearr

    return $compiled_tpl

}



proc ::templating::compiler::compile_template_if_expr {codearrVar expr_tpl depth inside_code_block} {

    upvar $codearrVar codearr

    set parent_block [top_block codearr]

    #TODO: check that vars exist, check with datastore, or meta vars available (e.g.rownum)
    #TODO: use while_regsub

    set expr_tpl [string map {"\{_\}" ${parent_block}} $expr_tpl]

    #set re {@\{([a-zA-Z_][a-zA-Z_0-9\.]*)\}}
    set re {@\{([a-zA-Z_][a-zA-Z_0-9\.:]*[a-zA-Z_0-9]*)\}}


    # TODO: we need to escape \\3
    set re_strcmp_empty [subst -nocommands -nobackslashes {(${re})\s+(eq|ne)\s+(\{\})}]
    set expr_tpl [regsub -all -- $re_strcmp_empty $expr_tpl "\xfa intcmp_\\3(0,Tcl_GetCharLength(getvar_\xfb\\1\xfc)) \xfa"]

    set re_varstrcmp [subst -nocommands -nobackslashes {(${re})\s+(eq|ne)\s+(${re})}]
    set expr_tpl [regsub -all -- $re_varstrcmp $expr_tpl "\xfa strcmp_\\3(Tcl_GetString(getvar_\xfb\\1\xfc),Tcl_GetString(getvar_\xfb\\4\xfc)) \xfa"]


    set re_varstrcmp_str [subst -nocommands -nobackslashes {(${re})\s+(eq|ne)\s+\{([^\}]+)\}}]
    set expr_tpl [regsub -all -- $re_varstrcmp_str $expr_tpl "\xfa strcmp_\\3(Tcl_GetString(getvar_\xfb\\1\xfc),\"\\4\") \xfa"]


    set re_intcmp [subst -nocommands -nobackslashes {(${re})\s*(!=|==|\>|\<|\>=|\<=)\s*([0-9]+)}]
    set expr_tpl [regsub -all -- $re_intcmp $expr_tpl "\xfa getint_\xfb\\1\xfc /* RIGHT_PAREN */ \\3 \\4 \xfa"]

    set re_varintcmp [subst -nocommands -nobackslashes {(${re})\s*(!=|==|\>|\<|\>=|\<=)\s*(${re})}]
    set expr_tpl [regsub -all -- $re_varintcmp $expr_tpl "\xfa getint_\xfb\\1\xfc /* RIGHT_PAREN */ \\3 getint_\xfb\\4\xfc /* RIGHT_PAREN */ \xfa"]


    set re_bool_not [subst -nocommands -nobackslashes {(^\s*|[^a-zA-Z0-9\_\&\|\(\s\xfa]\s*)(not|!)\s+(${re})(\s*[^a-zA-Z0-9\_\&\|\)\s\xfa]|\s*$)}]
    set expr_tpl [regsub -all -- $re_bool_not $expr_tpl "\\1!getbool_\xfb\\3\xfc /* RIGHT_PAREN */ \xfa"]


    set re_bool_not [subst -nocommands -nobackslashes {(^\s*|[^a-zA-Z0-9\_\&\|\(\s\xfa]\s*)(not|!)\s+(${re})(\s*[^a-zA-Z0-9\_\&\|\)\s\xfa]|\s*$)}]
    set expr_tpl [regsub -all -- $re_bool_not $expr_tpl "\\1!getbool_\xfb\\3\xfc /* RIGHT_PAREN */ \\4"]

    set re_bool [subst -nocommands -nobackslashes {(^\s*|[^\xfb]\s*)(${re})(\s*[^\xfc]|\s*$)}]
    set expr_tpl [regsub -all -- $re_bool $expr_tpl "\\1getbool_\xfb\\2\xfc /* RIGHT_PAREN */\\4"]

    set re_bool_literal [subst -nocommands -nobackslashes {(^|[^a-zA-Z0-9\_\&\|\(\s\xfa]\s*)(true|false|off|on)(\s*[^a-zA-Z0-9\_\&\|\)\s\xfa]|$)}]
    set expr_tpl [regsub -all -- $re_bool_literal $expr_tpl "\\1BOOL_LITERAL_\\2\\4"]

    set text $expr_tpl
    set result ""
    set start 0
    while {[regexp -start $start -indices -- ${re} $text match submatch]} {

	lassign $submatch subStart subEnd
	lassign $match matchStart matchEnd
	incr matchStart -1
	incr matchEnd

	set before_text [string range $text $start $matchStart]
	if { $before_text ne {} } {
	    append result $before_text
	}

	set in_text [string range $text $subStart $subEnd]


	set varname_expr $in_text
	set parts [split $varname_expr {:}]

	if { [llength $parts] > 2 } {
	    # we expect an identifier with an optional modifier
	    # examples:
	    #     _:rownum 
	    #     blogdata:rowcount
	    #     registered_p
	    #     content_in_html:noquote
	    #
	    error "compile_template_if_expr: 'varname_expr' must be an identifier with an optional modifier"
	}
	set modifier ""
	lassign ${parts} varname modifier

	if { $modifier eq {} } {
	    append result [getter_for_varname codearr $parent_block $varname]
	} else {
	    set vartype 2  ;# getter with non-empty modifier, returns Tcl_Obj
	    append result "${vartype} /* tclobj (from modifier) */ (interp,[getter_for_varname codearr $parent_block $varname "" "" $modifier])"
	}
	set start $matchEnd
    }
    set after_text [string range $text $start end]
    if { $after_text ne {} } { 
	append result $after_text
    }
    set expr_tpl $result


    set conditional_expr [string map {"\xfa" "" "\xfb" "" "\xfc" ""} $expr_tpl]
    return $conditional_expr

}


proc ::templating::compiler::compile_template_if {codearrVar node depth inside_code_block} {

    upvar $codearrVar codearr

    set expr_tpl [$node @if]
    set conditional_expr [compile_template_if_expr codearr $expr_tpl $depth $inside_code_block]

    set compiled_tpl ""
    #append compiled_tpl "\xff" "\n" "DBG(fprintf(stderr,\"expr_tpl=${expr_tpl}\\n\"));" "\xfe"
    append compiled_tpl "\xff" "\n" "if \( $conditional_expr \) \{ " "\xfe"
    append compiled_tpl [compile_template_children codearr $node $depth $inside_code_block]
    append compiled_tpl "\xff" "\n" "\} " "\xfe"
    return $compiled_tpl

}

proc ::templating::compiler::compile_template_else {codearrVar node depth inside_code_block} {

    upvar $codearrVar codearr

    set compiled_tpl ""
    append compiled_tpl "\xff" "\n" "else \{ " "\xfe"
    append compiled_tpl [compile_template_children codearr $node $depth $inside_code_block]
    append compiled_tpl "\xff" "\n" "\} " "\xfe"
    return $compiled_tpl

}

proc ::templating::compiler::compile_template_binding {codearrVar bindarrVar attvalue node depth inside_code_block} {

    upvar $codearrVar codearr
    upvar $bindarrVar bindarr

    foreach {binding binding_expr} ${attvalue} {
	if { ${binding} eq {checked} } {

	    set conditional_expr [compile_template_if_expr \
				      codearr \
				      $binding_expr \
				      $depth \
				      $inside_code_block]

	    set code ""
	    append code "\xff" "\n" "if \( /* x-bind ${binding} */ $conditional_expr \) \{ " "\xfe"
	    append code { checked=""}
	    append code "\xff" "\n" "\} " "\xfe"
	    return $code

	} elseif { ${binding} eq {disabled} } {

	    set conditional_expr [compile_template_if_expr \
				      codearr \
				      $binding_expr \
				      $depth \
				      $inside_code_block]

	    set code ""
	    append code "\xff" "\n" "if \( /* x-bind ${binding} */ $conditional_expr \) \{ " "\xfe"
	    append code { disabled=""}
	    append code "\xff" "\n" "\} " "\xfe"
	    return $code

	} elseif { ${binding} eq {formdata} } {

	    # Note: We can restrict the use of the formdata binding on form-only nodes
	    #       but there is no good reason for doing so. One might choose to use
	    #       one datastore for some of the form fields and another for the rest.
	    #
	    # if { [$node tagName] ne {form} } {
	    # error "node is not a form, cannot use 'formdata' binding on any other type of node"
	    # }

	    set dataref ${binding_expr}

	    set fields [concat \
			    [$node selectNodes {descendant::input}] \
			    [$node selectNodes {descendant::textarea}]]
	    set index 0
	    foreach field $fields {
		set tagname [$field tagName]
		set fieldname [$field @name]

		array set fieldbindarr [${field} @x-bind [list]]

		if { ${tagname} eq {input} } {

		    set type [$field @type "text"]
		    if { ${type} in {text email url} } {

			if { ![info exists fieldbindarr(value_if)] } {
			    # example: "@{bookmarkdata:rowcount} => @{bookmarkdata.title}"

			    set fieldbindarr(value_if) "@\{${dataref}:rowcount\} => @\{${dataref}.${fieldname}\}"			    
			} else {
			    ns_log notice "field ${fieldname} already has a 'value_if' binding"
			}

		    } elseif { ${type} in {radio checkbox} } {

			set fieldvalue [$field @value ""]

			if { ![info exists fieldbindarr(checked)] } {

			    if { ${index} == 0 } {

				# example: "!@{bookmarkdata:rowcount} || @{bookmarkdata.shared_p} eq {t}"
				set fieldbindarr(checked) "!@\{${dataref}:rowcount\} || @\{${dataref}.${fieldname}\} eq \{${fieldvalue}\}"

			    } else {

				# example: "@{bookmarkdata:rowcount} && @{bookmarkdata.shared_p} eq {t}"
				set fieldbindarr(checked) "@\{${dataref}:rowcount\} && @\{${dataref}.${fieldname}\} eq \{${fieldvalue}\}"

			    }

			} else {
			    ns_log notice "field ${fieldname} already has a 'checked' binding"
			}

		    }

		} elseif { ${tagname} eq {textarea} } {

		    if { ![info exists fieldbindarr(value_if)] } {
			# example: "@{bookmarkdata:rowcount} => @{bookmarkdata.description}"

			set fieldbindarr(value_if) "@\{${dataref}:rowcount\} => @\{${dataref}.${fieldname}\}"			    
		    } else {
			ns_log notice "field ${fieldname} already has a 'value_if' binding"
		    }

		}

		${field} setAttribute x-bind [array get fieldbindarr]
		array unset fieldbindarr
		incr index

	    }

	    return

	} elseif { ${binding} eq {css} } {
	} elseif { ${binding} eq {style} } {
	} elseif { ${binding} eq {visible} } {
	} elseif { ${binding} eq {attr} } {
	} elseif { ${binding} eq {value_if} } {

	    if { [llength $binding_expr] != 3 } {
		error "compile_template_binding: must be value_if {binding_if_expr => value}"
	    }

	    lassign $binding_expr binding_if_expr arrow binding_value

	    if { $arrow ne {=>} } {
		error "compile_template_binding: must be value_if {binding_if_expr => value}"
	    }

	    set conditional_expr [compile_template_if_expr \
				      codearr \
				      $binding_if_expr \
				      $depth \
				      $inside_code_block]

	    set subst_binding_value [compile_template_subst \
					 codearr \
					 $binding_value \
					 $depth \
					 $inside_code_block]

	    set tagname [$node tagName]

	    if { ${tagname} eq {input} } {

		set code ""
		append code "\xff" "\n" "if \( /* x-bind ${binding} */ $conditional_expr \) \{ " "\xfe"
		append code " value=\"${subst_binding_value}\""
		append code "\xff" "\n" "\} " "\xfe"

		if { [$node hasAttribute value] } {

		    set subst_value [compile_template_subst \
					 codearr \
					 [$node @value] \
					 $depth \
					 $inside_code_block]

		    append code "\xff" "\n" "else \{ " "\xfe"
		    append code " value=\"${subst_value}\""
		    append code "\xff" "\n" "\} " "\xfe"

		    set bindarr(value,code) $code

		} else {
		    return $code
		}

	    } elseif { ${tagname} eq {textarea} } {

		set code ""
		append code "\xff" "\n" "if \( /* x-bind ${binding} */ $conditional_expr \) \{ " "\xfe"
		append code ${subst_binding_value}
		append code "\xff" "\n" "\} " "\xfe"

		if { [$node text] ne {} } {

		    set subst_value [compile_template_subst \
					 codearr \
					 [$node text] \
					 $depth \
					 $inside_code_block]

		    append code "\xff" "\n" "else \{ " "\xfe"
		    append code ${subst_value}
		    append code "\xff" "\n" "\} " "\xfe"

		}

		set bindarr(__nodeValue__,code) $code

	    } else {
		error "compile_template_binding: value_if unknown element node tag=${tagname}"
	    }

	} else {
	    error "unknown binding '${binding}'"
	}
    }

}




proc ::templating::compiler::compile_template_call {codearrVar node depth inside_code_block} {
    upvar $codearrVar codearr

    set code [$node @call ""]
    return "\xff/* CALL id='[$node @id ""]' */ ${code};\xfe"

    #set compiled_tpl ""
    #append compiled_tpl "\xff" "\n" "/* CALL HERE */ ${code};" "\xfe"
    #return $compiled_tpl
}



proc ::templating::compiler::compile_template_exec {codearrVar node depth inside_code_block} {

    upvar $codearrVar codearr

    set parent_block [top_block codearr]

    set renderer [$node @exec ""]
    set tpl_config [$node @config ""]
    set varname ""
    if { [dict exists $tpl_config dataIndex] } {
	set varname [dict get $tpl_config dataIndex]
    }

    add_global_string codearr OBJECT_VARNAME_${varname} ${varname}

    if { $varname eq {} } {
	set c_getter ${parent_block}
    } else {
	set c_getter getvar_[getter_for_varname codearr $parent_block $varname]
    }

    set id [${node} @id ${node}]
    add_global_string codearr OBJECT_RENDERER_${renderer} "::templating::renderer::${renderer}"
    add_global_string codearr OBJECT_RENDERER_CONFIG_${id} ${tpl_config}
    add_global_string codearr OBJECT_RENDERER_TEXT_${id} [::util::coalesce [$node @template ""] [$node text]]

    set compiled_tpl ""
    append compiled_tpl "\xff" "\n"
    append compiled_tpl [subst -nocommands -nobackslashes {
	Tcl_Obj *const objv_${node}[] = { 
	    global_objects[OBJECT_RENDERER_${renderer}],
	    ${c_getter},
	    global_objects[OBJECT_RENDERER_CONFIG_${id}],
	    global_objects[OBJECT_RENDERER_TEXT_${id}],
	};
	if ( TCL_ERROR == Tcl_EvalObjv(interp, 4, objv_${node}, TCL_GLOBAL_ONLY) ) {
	    return TDP_ERROR;
	}
	append_obj(Tcl_GetObjResult(interp),dsPtr,1);  // noquote=1
    }]
    append compiled_tpl "\n" "\xfe"
    return $compiled_tpl
}




# compile_template_subst
#
# 1. replaces each variable substitution with a quintuple consisting of the object name, 
# the varname, whether it is inside a code block or not, the current block,
# and modifiers (e.g. whether to quote html or not)
#
# 2. the special character \xfd is used to denote that 
# the block is a substitution and thus not a control structure
#
proc ::templating::compiler::compile_template_subst {codearrVar text depth inside_code_block} {

    upvar $codearrVar codearr

    #set re {@\{([a-zA-Z_][a-zA-Z_0-9\.]*)(:noquote|:varname|:rownum|:rowcount|:llength|:length|:trim)?\}}
    set re {@\{([a-zA-Z_][a-zA-Z_0-9\.:]*[a-zA-Z_0-9]*)\}}
    if { $inside_code_block } {

	# inside_code_block=1, noquote_p=0
	set parent_block [top_block codearr]
	set compiled_tpl [regsub -all -- $re $text "\xff\xfe\xfd ${depth} \\1 1 ${parent_block} \xff\xfe"]

	# inside_code_block=1, noquote_p=1
	#set compiled_tpl [regsub -all -- $re_noquote $compiled_tpl "\xff\xfe\xfd ${depth} \\1 1 ${parent_block} 1 1\xff\xfe"]

    } else {

	# inside_code_block=0, noquote_p=0
	set compiled_tpl [regsub -all -- $re $text "\xfe\xfd ${depth} \\1 0 \xff"]

	# inside_code_block=0, noquote_p=1
	#set compiled_tpl [regsub -all -- $re_noquote $compiled_tpl "\xfe\xfd ${depth} \\1 0 1\xff"]

    }
    return $compiled_tpl
}

proc ::templating::compiler::compile_template_children {codearrVar node depth inside_code_block} {

    upvar $codearrVar codearr

    set compiled_tpl ""
    foreach child [$node childNodes] {
	append compiled_tpl [compile_template_helper codearr $child $depth $inside_code_block]
    }
    return $compiled_tpl
}

proc ::templating::compiler::compile_template_statement {codearrVar node depth inside_code_block} {

    upvar $codearrVar codearr

    if { [$node hasAttribute "for"] } {
	set compiled_tpl [compile_template_for codearr $node $depth true]
    } elseif { [$node hasAttribute "with"] } {
	set compiled_tpl [compile_template_with codearr $node $depth true]
    } elseif { [$node hasAttribute "if"] } {
	set compiled_tpl [compile_template_if codearr $node $depth true]
    } elseif { [$node hasAttribute "else"] } {
	set compiled_tpl [compile_template_else codearr $node $depth true]
    } elseif { [$node hasAttribute "exec"] } {
	set compiled_tpl [compile_template_exec codearr $node $depth true]
    } elseif { [$node hasAttribute "call"] } {
	set compiled_tpl [compile_template_call codearr $node $depth true]
    } else {
	set compiled_tpl [compile_template_children codearr $node $depth $inside_code_block]
	#error "unknown template tag"
    }

    return $compiled_tpl
}


proc ::templating::compiler::compile_template_element {codearrVar node depth inside_code_block} {

    upvar $codearrVar codearr

    set tag [$node tagName]

    set otag "<${tag}"
    set attributes [$node attributes]

    array set bindarr [list]
    if { {x-bind} in ${attributes} } {

	set attvalue [$node @x-bind]

	append otag [compile_template_binding \
			 codearr \
			 bindarr \
			 ${attvalue} \
			 ${node} \
			 ${depth} \
			 ${inside_code_block}]

    }

    foreach att ${attributes} {

	set firstTwoChars [string range [string trim ${att}] 0 1] 
	if { ${firstTwoChars} eq {x-} } {

	    # ignore attribute, e.g. x-master-renderTo, x-form-setvalues

	} else {

	    set attvalue [$node @${att}]

	    set compiled_attvalue [compile_template_subst \
				       codearr \
				       ${attvalue} \
				       ${depth} \
				       $inside_code_block]

	    if { [info exists bindarr(${att},code)] } {

		append otag $bindarr(${att},code)

	    } elseif { ${att} eq {value} && [info exists bindarr(${att},value)] } {

		append otag " ${att}=\"$bindarr(${att},value)\""

	    } else {

		append otag " ${att}=\"[ns_quotehtml ${compiled_attvalue}]\""

	    }

	}

    }
    

    set EMPTY_ELEMENTS_IN_HTML {
	area base basefont br col frame 
	hr img input isindex link meta param
    }
    if { ${tag} in ${EMPTY_ELEMENTS_IN_HTML} } {
	append otag "/>"
	set ctag ""
    } else {
	append otag ">"
	set ctag "</${tag}>"
    }

    set compiled_tpl ${otag}

    if { [info exists bindarr(__nodeValue__,code)] } {

	# e.g. code to set textarea node's value
	append compiled_tpl $bindarr(__nodeValue__,code)

    } else {

	append compiled_tpl [compile_template_children \
				 codearr \
				 $node \
				 $depth \
				 $inside_code_block]

    }

    append compiled_tpl ${ctag}

    return ${compiled_tpl}

}

proc ::templating::compiler::compile_template_helper {codearrVar node {depth 0} {inside_code_block "false"}} {

    upvar $codearrVar codearr

    set compiled_tpl ""
    set nodeType [$node nodeType]

    if { $nodeType eq {TEXT_NODE} } {

	append compiled_tpl [compile_template_subst \
				 codearr \
				 [$node nodeValue] \
				 $depth \
				 $inside_code_block]

    } elseif { $nodeType eq {ELEMENT_NODE} } {

	set tag [$node tagName]
	if { $tag eq {tpl} } {

	    append compiled_tpl [compile_template_statement \
				     codearr \
				     $node \
				     $depth \
				     $inside_code_block]

	} else {

	    append compiled_tpl [compile_template_element \
				     codearr \
				     $node \
				     $depth \
				     $inside_code_block]

	}
    }

    return $compiled_tpl
}



proc ::templating::compiler::compiled_template_to_c {codearrVar text} {

    upvar $codearrVar codearr

    set isCode false
    set adp ""
    set re {\xfe([^\xfe\xff]*)\xff}
    set start 0
    while {[regexp -start $start -indices -- $re $text match submatch]} {
	lassign $submatch subStart subEnd
	lassign $match matchStart matchEnd
	incr matchStart -1
	incr matchEnd

	set before_text [string range $text $start $matchStart]
	if { $before_text ne {} } {
	    append adp "\n" $before_text
	}

	set in_text [string range $text $subStart $subEnd]
	if { $in_text eq {} } {
	} elseif { [string index $in_text 0] eq "\xfd" } {
	    lassign [split [string trim [string range $in_text 1 end]]] depth varname_expr inside_code_block parent_block

	    # example output: 
	    set var_expr "[append_for_varname codearr $parent_block $varname_expr];"
	    if { $inside_code_block } {
		append adp "\n" "\xfb${var_expr}" "\xfc"
	    } else {
		append adp "${var_expr} "
	    }
	} else {
	    set bytes [::util::cstringquote_escape_newlines $in_text length]
	    append adp "\n" "\xfbTcl_DStringAppend(dsPtr,${bytes},${length});" "\xfc"
	}

	set start $matchEnd
    }
    set after_text [string range $text $start end]
    if { $after_text ne {} } { 
	append adp "\n" $after_text
    }

    # remaining special characters denote start and end of code
    #ND "\xfb"       "\nTcl_AppendStringsToObj\(resultPtr,"
    #ND	"\xfc"       "(char *) NULL\);"

    set adp [string map {
	"\xfc\n\xfb" { } 
	"\xfb"       "\n"
	"\xfc"       ""
	"\xff"       ""
	"\xfe"       ""
	"\xfa"       ""
    } $adp]
    return $adp
}

proc ::templating::compiler::compile_template {codearrVar node} {

    upvar $codearrVar codearr

    #::xo::kit::log templating::compiler [$node tagName]

    set doc [$node ownerDocument]
    set root [$doc createElement tpl]
    foreach child [$node childNodes] {
	$root appendChild $child
    }

    add_global_string codearr OBJECT_DATA "::__data__"

    set depth 0
    set inside_code_block true
    set block block0_o0
    set storeId [$node @store ""]
    if { $storeId eq {} || $storeId eq {.} } {
	set_block_store codearr $block ""
	set initial_obj_code {global_objects[OBJECT_DATA]}
    } else {
	set_block_store codearr $block ${storeId}
	add_global_string codearr OBJECT_VARNAME_${storeId} ${storeId}

	set initial_obj_code [subst -nocommands -nobackslashes {Tcl_ObjGetVar2(interp,global_objects[OBJECT_DATA],global_objects[OBJECT_VARNAME_${storeId}],TCL_GLOBAL_ONLY)}]
    }

    push_block codearr ${block}

    set compiled_tpl [::templating::compiler::compiled_template_to_c codearr \xfe[::templating::compiler::compile_template_helper codearr $root $depth $inside_code_block]\xff]

    set c_code [subst -nocommands -nobackslashes {

	Tcl_Obj *${block} = ${initial_obj_code};
	Tcl_IncrRefCount(${block});
	${compiled_tpl}
	Tcl_DecrRefCount(${block});
	return TDP_OK;
    }]

    #::xo::kit::log \n\n --->>> \n\n c_code=$c_code \n\n

    $root delete
    $node setAttribute renderer "c"

    $node appendChild [$doc createTextNode $c_code]

}

