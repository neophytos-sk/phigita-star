namespace eval ::adp_compiler {;}

proc ::adp_compiler::compile_template_for {node depth inside_code_block} {

    set varname [$node @for]
    if { $varname eq {.} } {
	set list_expr "\$o${depth}"
    } else {
	set list_expr "\[\$o${depth} set ${varname}\]"
    }

    set new_depth [expr {1+$depth}]
    set compiled_tpl ""
    append compiled_tpl "\xff" "\n" "foreach o${new_depth} $list_expr \{" "\xfe"
    append compiled_tpl [compile_template_children $node $new_depth $inside_code_block]
    append compiled_tpl "\xff" "\n" "\}" "\xfe"
    return $compiled_tpl

}

proc ::adp_compiler::compile_template_if_expr {node depth inside_code_block} {

    #TODO: check that vars exist, check with datastore, or meta vars available (e.g.rownum)
    #TODO: use while_regsub

    set expr_tpl [$node @if]
    set expr_tpl [string map {"\{_\}" "\$o${depth}"} $expr_tpl]
    set re {@\{([a-zA-Z_][a-zA-Z_0-9\.]*)\}}
    set conditional_expr [regsub -all -- $re $expr_tpl "\[\$o${depth} set \\1\]"]
    return $conditional_expr

}

proc ::adp_compiler::compile_template_if {node depth inside_code_block} {

    set conditional_expr [compile_template_if_expr $node $depth $inside_code_block]

    set compiled_tpl ""
    append compiled_tpl "\xff" "\n" "if \{ $conditional_expr \} \{ \xfe"
    append compiled_tpl [compile_template_children $node $depth $inside_code_block]
    append compiled_tpl "\xff" "\n" "\} \xfe"
    return $compiled_tpl
}


proc ::adp_compiler::compile_template_subst {text depth inside_code_block} {

    # we return a triple consisting of the object name, the varname, 
    # and whether it is inside a code block or not

    # the special character \xfd is used to denote that 
    # the block is a substitution and thus not a control structure

    set re {@\{([a-zA-Z_][a-zA-Z_0-9\.]*)\}}
    if { $inside_code_block } {
	set compiled_tpl [regsub -all -- $re $text "\xff\xfe\xfd\$o${depth} \\1 1\xff\xfe"]
    } else {
	set compiled_tpl [regsub -all -- $re $text "\xfe\xfd\$o${depth} \\1 0\xff"]
    }
    return $compiled_tpl
}

proc ::adp_compiler::compile_template_children {node depth inside_code_block} {
    set compiled_tpl ""
    foreach child [$node childNodes] {
	append compiled_tpl [compile_template_helper $child $depth $inside_code_block]
    }
    return $compiled_tpl
}

proc ::adp_compiler::compile_template_statement {node depth inside_code_block} {

    if { [$node hasAttribute "for"] } {
	set compiled_tpl [compile_template_for $node $depth true]
    } elseif { [$node hasAttribute "if"] } {
	set compiled_tpl [compile_template_if $node $depth true]
    } elseif { [$node hasAttribute "exec"] } {
	# do something
    } else {
	set compiled_tpl [compile_template_children $node $depth $inside_code_block]
	#error "unknown template tag"
    }

    return $compiled_tpl
}

proc ::adp_compiler::compile_template_helper {node {depth 0} {inside_code_block "false"}} {

    set compiled_tpl ""
    set nodeType [$node nodeType]

    if { $nodeType eq {TEXT_NODE} } {
	append compiled_tpl [compile_template_subst [$node nodeValue] $depth $inside_code_block]
    } elseif { $nodeType eq {ELEMENT_NODE} } {
	set tag [$node tagName]
	if { $tag eq {tpl} } {
	    append compiled_tpl [compile_template_statement $node $depth $inside_code_block]
	} else {
	    set tplNodes [$node selectNodes {descendant::tpl[1]}]
	    if { $tplNodes eq {} } {
		append compiled_tpl [compile_template_subst [$node asHTML] $depth $inside_code_block]
	    } else {
		set otag "<${tag}"
		foreach att [$node attributes] {
		    set attvalue [compile_template_subst [$node @${att}] ${depth} $inside_code_block]
		    append otag " ${att}=${attvalue}"
		}
		append otag ">"
		set ctag "</${tag}>"

		set compiled_tpl ${otag}
		append compiled_tpl [compile_template_children $node $depth $inside_code_block]
		append compiled_tpl ${ctag}
	    }
	}
    }

    return $compiled_tpl
}



proc ::adp_compiler::compiled_template_to_adp {text} {

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
	    append adp $before_text
	}

	set in_text [string range $text $subStart $subEnd]
	if { $in_text eq {} } {
	} elseif { [string index $in_text 0] eq "\xfd" } {
	    lassign [split [string range $in_text 1 end]] obj varname inside_code_block
	    if { $varname eq {_} } {
		set var_expr "${obj}"
	    } else {
		set var_expr "\[${obj} set ${varname}\]"
	    }
	    if { $inside_code_block } {
		append adp "\n" "\xfb${var_expr}" "\xfc"
	    } else {
		append adp "<%=${var_expr}%>"
	    }
	} else {
	    append adp "\n" "\xfb[list $in_text]" "\xfc"
	}

	set start $matchEnd
    }
    set after_text [string range $text $start end]
    if { $after_text ne {} } { 
	append adp $after_text
    }

    # remaining special characters denote start and end of code
    set adp [string map {
	"\xfc\n\xfb" { } 
	"\xfb"       {append out } 
	"\xfc"       {} 
	"\xff"       "\n<%"
	"\xfe"       "\nns_adp_puts -nonewline \${out} \n%>"
    } $adp]
    return $adp
}

proc ::adp_compiler::compile_template {node} {

    set tpl [$node @template ""]
    if { $tpl eq {} } {
	foreach child [$node childNodes] {
	    append tpl [$child asHTML]
	    $child delete
	}
    } else {
	$node removeAttribute template
    }

    # remove all special characters we use in parsing
    set tpl [string map {"\xfd" "" "\xfe" "" "\xff" ""} $tpl]

    if { [catch {set doc [dom parse -html <tpl>${tpl}</tpl>]} errMsg] } {
	error "failed to parse template errMsg=$errMsg"
    }

    set root [$doc documentElement]
    set compiled_tpl [compiled_template_to_adp [compile_template_helper $root]]
    $doc delete

    set adp "<%ns_adp_bind_args o0; set out {};%>"
    append adp ${compiled_tpl}

    #::xo::kit::log \n\n --->>> \n\n adp=$adp \n\n

    $node setAttribute renderer "adp"
    set doc [$node ownerDocument]

    set textNode [$doc createTextNode $adp]
    $textNode disableOutputEscaping 1
    $node appendChild $textNode

}

