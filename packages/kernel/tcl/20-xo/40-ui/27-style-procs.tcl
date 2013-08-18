namespace eval ::xo {;}
namespace eval ::xo::ui {;}

#### CSS/Style Class

::xo::ui::Class ::xo::ui::StyleText -superclass {::xo::ui::Widget} -parameter {
    {styleText ""}
    {inline_p "yes"}
}

::xo::ui::StyleText instproc render {visitor} {
    #set visitor [self callingobject]

    $visitor instvar __jsNode
    [$visitor body] insertBeforeFromScript {
	if { [my inline_p] } {
	    $visitor ensureNodeCmd elementNode style
	    style -type text/css { t -disableOutputEscaping [my styleText] }
	} else {
	    set host [ad_conn protocol]://[ad_host]/ ;# http://my.phigita.net/
	    set uri [my uri -select [my domNodeId] -action returnStyleText]
	    $visitor ensureNodeCmd elementNode link
	    $visitor importCSS -host $host $uri
	}
    } $__jsNode
}

::xo::ui::StyleText instproc action(returnStyleText) {marshaller} {
    ns_return 200 text/css [my styleText]
}

::xo::ui::Class ::xo::ui::StyleFile -superclass {::xo::ui::Widget} -parameter {
    {style_file ""}
}


::xo::ui::StyleFile instproc render {visitor} {
    [$visitor head] appendFromScript {
	set host [ad_conn protocol]://[ad_host]/ ;# http://my.phigita.net/
	set uri [my uri -select [my domNodeId] -action returnStyleFile]
	$visitor ensureNodeCmd elementNode link
	$visitor importCSS -compile_p no -host $host $uri
    }
}


::xo::ui::StyleFile instproc action(returnStyleFile) {marshaller} {
    ad_returnfile_background 200 text/css [my style_file]
}


###################
