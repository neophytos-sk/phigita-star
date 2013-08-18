namespace eval ::xo {;}
namespace eval ::xo::ui {;}

::xo::ui::Class ::xo::ui::Template -superclass {::xo::ui::Widget} -parameter {
    {html ""}
} -jsClass Ext.XTemplate


::xo::ui::Template instproc getConfig {} {
    my instvar html


    set fragments ""
    foreach fragment [split [string trim $html] \n] {
	lappend fragments [string trim $fragment]
    }

    set html '[join $fragments ',']'
    return $html

}
::xo::ui::Template instproc render {visitor} {

    $visitor ensureLoaded XO.Core
    $visitor ensureLoaded XO.DataView

    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return [next]

}


