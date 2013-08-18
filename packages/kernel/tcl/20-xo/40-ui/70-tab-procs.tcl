namespace eval ::xo {;}
namespace eval ::xo::ui {;}



::xo::ui::Class  ::xo::ui::TabPanel -superclass {::xo::ui::Widget} -parameter {

    {title ""}
    {activeTab ""}
    {region ""}
    {layout ""}
    {width ""}
    {height ""}
    {margins ""}
    {split "false"}
    {border "false"}
    {bodyBorder "false"}
    {deferredRender "false"}
    {enableTabScroll "false"}
    {hideBorders ""}
    {tabPosition ""}
    {collapsible ""}
    {collapseMode ""}
    {plain ""}
    {tbar ""}
    {bbar ""}
    {buttonAlign ""}
    {resizeTabs ""}
    {autoWidth ""}
    {autoHeight ""}
} -jsClass Ext.TabPanel

::xo::ui::TabPanel instproc getConfig {} {

    my instvar domNodeId region margins tbar bbar


    set varList {
	plain
	title
	width
	height
	layout
	border
	bodyBorder
	hideBorders
	split
	activeTab
	enableTabScroll
	tabPosition
	collapsible
	collapseMode
	deferredRender
	buttonAlign
	resizeTabs
	autoWidth
	autoHeight
    }

    set config ""
    lappend config "applyTo:'$domNodeId'"
    foreach varName $varList {
        if { [my set $varName] ne {} } {
            lappend config "${varName}:[my set $varName]"
        }
    }

    if { $region ne {} } {
	lappend config "region:'${region}'"
    }
    if { $margins ne {} } {
	lappend config "margins:'${margins}'"
    }
    if { $tbar ne {} } {
	lappend config "tbar:[${tbar} domNodeId]"
    }
    if { $bbar ne {} } {
	lappend config "bbar:[${bbar} domNodeId]"
    }


    set items ""
    foreach o [my childNodes] {
	#lappend items \{contentEl:'[$o domNodeId]',title:'[$o label]',closable:false\}
	lappend items "[$o domNodeId]"
    }


    if { $items ne {} } { 
	lappend config "items: \[[join ${items} {,}]\]"
    }

    lappend config "plugins: new Ext.ux.TabCloseMenu()"
    
    return \{[join $config {,}]\}

}

::xo::ui::TabPanel instproc accept {{-rel default} {-action "visit"} visitor} {

    set result [next]

    $visitor ensureLoaded XO.TabPanel

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    #$visitor onReady ${domNodeId}.render ${domNodeId} true

    return $result
}

::xo::ui::TabPanel instproc render {visitor} {
    #set visitor [self callingobject]

    my instvar region

    set node [next]
    $node setAttribute id [my domNodeId]
    $node setAttribute class x-tab-panel
    if { $region ne {} } {
	$node setAttribute class [concat [$node getAttribute class ""] x-border-panel]
    }

    return $node
}