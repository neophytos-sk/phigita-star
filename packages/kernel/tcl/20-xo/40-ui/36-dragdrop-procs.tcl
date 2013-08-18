namespace eval ::xo {;}
namespace eval ::xo::ui {;}


::xo::ui::Class ::xo::ui::ImageDragZone -superclass {::xo::ui::Widget} -parameter {
    view
    {containerScroll ""}
    {ddGroup ""}
} -jsClass Ext.ux.ImageDragZone


::xo::ui::ImageDragZone instproc getConfig {} {

    my instvar stateEvents

    set varList {
	containerScroll
	ddGroup
    }

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config ,]\}
}

::xo::ui::ImageDragZone instproc getConstructor {} {
    my instvar domNodeId view
    [my info class] instvar jsClass
    set config [my getConfig]
    set viewEl [$view domNodeId]
    set aliases [my getAliases]
    return "${aliases};${domNodeId}=new $jsClass (${viewEl},$config);"
}

::xo::ui::ImageDragZone instproc render {visitor} {

    $visitor ensureLoaded XO.ImageDragZone
    my instvar domNodeId 

    # add an inline editor for the nodes
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}


