
#### JavaScript Classes

Class ::xo::ui::ScriptText -superclass {::xo::ui::Widget} -parameter {
    {scriptText ""}
    {inline_p "no"}
}

::xo::ui::ScriptText instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode script

    [$visitor head] appendFromScript {
	if { [my inline_p] } {
	    script -type text/javascript { t -disableOutputEscaping [my scriptText] }
	} else {
	    set uri [my uri -select [my domNodeId] -action returnScriptText]
	    script -type text/javascript -src $uri
	}
    }
}

::xo::ui::ScriptText instproc action(returnScriptText) {marshaller} {
    ns_return 200 text/css [my scriptText]
}

#################

Class ::xo::ui::ScriptFile -superclass {::xo::ui::Widget} -parameter {
    {scriptFile} 
    {need ""}
}

::xo::ui::ScriptFile instproc render {visitor} {
    #set visitor [self callingobject]
    my instvar need
    if { $need ne {} } {
	eval $visitor ensureLoaded $need
    }
    $visitor ensureNodeCmd elementNode script

    set uri [my uri -select [my domNodeId] -action returnScriptFile]


    $visitor instvar domDoc __jsNode 
    set newChild [$domDoc createElement script]
    $newChild setAttribute type "text/javascript"
    $newChild setAttribute src ${uri}
    [$visitor body] insertBefore $newChild $__jsNode

}

::xo::ui::ScriptFile instproc action(returnScriptFile) {marshaller} {
    ad_returnfile_background 200 text/javascript [my scriptFile]
}


###################
