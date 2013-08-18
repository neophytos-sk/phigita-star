namespace eval ::xo {;}
namespace eval ::xo::ui {;}

::xo::ui::Class ::xo::ui::Window -superclass {::xo::ui::Widget} -parameter {
    {id ""}
    {modal ""}
    {bodyStyle ""}
    {width ""}
    {height ""}
    {x ""}
    {y ""}
    {closeAction ""}
    {title ""}
    {plain ""}
    {minimizable ""}
    {layout ""}
    {minWidth ""}
    {minHeight ""}
    {html ""}
} -jsClass Ext.Window


::xo::ui::Window instproc getConfig {} {

    my instvar domNodeId

    set varList {
	id
	modal
	bodyStyle
	width
	height
	x
	y
	closeAction
	title
	plain
	minimizable
	layout
	minWidth
	minHeight
	html
    }

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }




    lappend config "applyTo:'${domNodeId}'"

    set items ""
    foreach o [my childNodes] {
	lappend items [$o domNodeId]
    }
    if { $items ne {} } { 
	lappend config "items: \[[join ${items} {,}]\]"
    }
    
    return \{[join $config {,}]\}

}

::xo::ui::Window instproc accept {{-rel default} {-action "visit"} visitor} {

    set result [next]

    $visitor ensureLoaded XO.Window

    my instvar domNodeId 
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return $result
}

::xo::ui::Window instproc render {visitor} {

    my instvar domNodeId title

    set node [next]
    $node setAttribute id $domNodeId
    $node setAttribute class x-hidden
    $node appendFromScript {
	if { $title ne {} } {
	    div -class "x-window-header" {
		t [string trim $title ']
	    }
	}
	set innerNode [div -class x-window-body]
    }
    return $innerNode
}
