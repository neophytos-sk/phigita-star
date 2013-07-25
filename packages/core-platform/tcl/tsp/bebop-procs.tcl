namespace eval bebop {;}


ad_proc bebop::activeTable {
    {-varname ""} {-context ""} {-dataset ""}
    {-name ""} {-action ""}
    {-table "table"} {-header ""} {-onerow ""}
} {

    if { ![string equal ${varname} ""] } { upvar ${varname} elementId }

    set docId [${context} ownerDocument]
    set elementId [${docId} createElement table]
    
    ${context} appendFromScript [subst -nobackslashes -nocommands {
	${table} {
	    ${header}
	    foreach setId [set dataset] { ${onerow} }
	}
    }]
}


#############

# HTML page
proc bebop::HTML-Page {nodeId leafage} {
    upvar ${leafage} elementId

    set docId [${nodeId} ownerDocument]
    set elementId(head) [${docId} createElement head]
    set elementId(body) [${docId} createElement body]
    ${nodeId} appendChild $elementId(head)
    ${nodeId} appendChild $elementId(body)
}

# Top-Middle-Bottom
proc bebop::Simple-TMB-Layout {nodeId leafage} {
    upvar ${leafage} elementId

    set docId [${nodeId} ownerDocument]
    set elementId(top) [${docId} createElement div]
    set elementId(middle) [${docId} createElement div]
    set elementId(bottom) [${docId} createElement div]
    ${nodeId} appendChild $elementId(top)
    ${nodeId} appendChild $elementId(middle)
    ${nodeId} appendChild $elementId(bottom)
}

proc bebop::N-Children-Layout {nodeId leafage tagName size} {
    upvar ${leafage} elementId

    set docId [${nodeId} ownerDocument]
    for {set i 0} {$i < ${size}} {incr i} {
	set elementId($i) [${docId} createElement ${tagName}]
	${nodeId} appendChild $elementId($i)
    }
}

proc bebop::N-Row-Layout {nodeId leafage nrows} {
    upvar ${nodeId} elementId
    upvar ${leafage} row
    ::bebop::N-Children-Layout ${elementId} row TR ${nrows}
}



# 1 | 4 | 7
# --+---+--
# 2 | 5 |  
# --+---+--
# 3 | 6 |  
# +-------+
#   ncols
#
proc bebop::N-Column-Grid {nodeId llength list ncols {script {t ${list:item}}} 
} {
    upvar ${nodeId} gridId

    set nrows [expr ${llength} / ${ncols} + (${llength} % ${ncols} > 0 ? 1: 0)]

    ::bebop::N-Row-Layout gridId row ${nrows}

    set list:cursor 0
    foreach list:item ${list} {
	set i [expr ${list:cursor} % ${nrows}]
	$row($i) appendFromScript "td { ${script} }"
	incr list:cursor
    }

}



# 1 | 2 | 3 -+
# --+---+--  |
# 4 | 5 | 6  |-> nrows
# --+---+--  |
# 7 |   |   -+
#
proc bebop::N-Row-Grid {nodeId llength list nrows {script {t ${list:item}}} 
} {
    upvar ${nodeId} gridId

    set ncols [expr ${llength} / ${nrows} + (${llength} % ${nrows} > 0 ? 1: 0)]

    ::bebop::N-Row-Layout gridId row ${nrows}

    set list:cursor 0
    foreach list:item ${list} {
	set i [expr ${list:cursor} / ${ncols}]
	$row($i) appendFromScript "td { ${script} }"
	incr list:cursor
    }

}


proc bebop::MxN-Table {nodeId leafage dimensions} {
    upvar ${leafage} elementId

    set docId [${nodeId} ownerDocument]
    lassign [split ${dimensions} "x"] nrows ncols

    for {set i 1} {$i <= $nrows} {incr i} {
	set rowNodeId [${docId} createElement TR]
	${nodeId} appendChild ${rowNodeId}
	for {set j 1} {$j <= $ncols} {incr j} {
	    set elementId(${nodeId}-${i}-${j}) [${docId} createElement TD]
	    ${rowNodeId} appendChild $elementId(${nodeId}-${i}-${j})
	}
    }
}



proc bebop::Search-Form {nodeId _leafage name} {
    upvar ${_leafage} leafage

    ${nodeId} appendFromScript {
	form -name ${name} -action /search -method GET {
	    input -type hidden -name hl -value [ad_conn language]
	    input -type text -name q -size 31 -maxlength 256 -value ""
	    input -type submit -value Search
	}
    }

    set leafage(query) [${nodeId} selectNodes [subst -nocommands {descendant::form[@name='${name}']/descendant::input[@name='q']}]]
}










namespace eval bebop::phigitanet {;}


proc bebop::topNavigation { nodeObjCmd user_id q } {
    #### bebop::topNavigation
    ${nodeObjCmd} appendFromScript {
	form -name ps -action /search -method get {
	    table {
		tr {
		    td -valign top {
			a -href / {
			    img -src /graphics/logo -width 173 -heigh 35 -border 0
			}
		    }
		    td -nowrap "" {
			table -border 0 -cellspacing 0 -cellpadding 0 -valign bottom {
			    if { ${user_id} == 0 } {
				tr {
				    td -width 7 {
					t " "
				    }
				    td -align center {
					font -size -1 {
					    a -href /register/ { 
						b { t "Please login or register" }
					    }
					    t "["
					    a -href /register/explain-cookies {
						t "why?"
					    }
					    t "]"
					}
				    }
				    td -width 7 {
					t " "
				    }
				}
			    } else {
				tr {
				    td -width 7 { t " " }
				    td -class x -align center {
					a -class x -href /my/preferences/ {
					    font -size -3 {
						t [::g11n::gettext "PREFERENCES"]
					    }
					}
				    }
				    td -width 7 { t " | " }
				    td -class "x" -bgcolor "#eeeecc" -align "center" {
					a -class x -href /my/ {
					    font -size -3 {
						t " YOUR ACCOUNT  "
					    }
					}
				    }
				    td -width 7 { t " | " }
				    td -class x -align center {
					a -class x -href "/register/logout" {
					    font -size -3 {
						t "LOGOUT"
					    }
					}
				    }
				    td -width 7 { t " " }
				}
			    }
			}
			font -size -3 { br }
			input -type text -name q -size 31 -maxlength 256 -value "${q}"
			input -type submit -value Search
		    }
		}
	    }
	}
    }
    }

