::xo::ui::Class ::xo::ui::Viewport -superclass {::xo::ui::Widget} -parameter {

    {layout ""}
    {margins "5 5 5 5"}
    {items ""}

} -jsClass Ext.Viewport

::xo::ui::Viewport instproc getConfig {} {

    my instvar layout width height margins

    set items ""
    foreach o [my childNodes] {
	lappend items [$o domNodeId]
    }


#    lappend config "applyTo:'${domNodeId}'"
    if { $margins ne {} } {
	lappend config "margins:'${margins}'"
    }
    if { $layout ne {} } {
	lappend config "layout:'${layout}'"
    }
    if { $items ne {} } { 
	lappend config "items: \[[join ${items} {,}]\]"
    }
    
    return \{[join $config {,}]\}
}


::xo::ui::Viewport instproc accept {{-rel default} {-action "visit"} visitor} {

    set result [next]

    $visitor ensureLoaded XO.Layout

    my instvar domNodeId


    $visitor inlineJavascript [my getJS] 
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return $result
}


::xo::ui::Viewport instproc render {visitor} {
    set node [next]
    $node setAttribute id [my domNodeId]
    return $node
}