namespace eval ::xo {;}
namespace eval ::xo::ui {;}



::xo::ui::Class ::xo::ui::DataView -superclass {::xo::ui::Widget} -parameter {

    {width ""}
    {height ""}
    {margins ""}
    {border "false"}
    {bodyBorder "false"}
    {singleSelect ""}
    {multiSelect ""}
    {loadingText "''"}
    {simpleSelect ""}
    {autoWidth ""}
    {autoHeight ""}
    {selectedClass ""}
    {overClass ""}
    {style ""}
    {tpl ""}
    {store ""}
    {extraInfo ""}
    {region ""}
    {emptyText ""}
    {onContextMenu ""}
    {itemSelector ""}
} -jsClass Ext.DataView

::xo::ui::DataView instproc getConfig {} {
    my instvar domNodeId label tpl store

    set varList {
	width
	height
	margins
	border
	bodyBorder
	singleSelect
	multiSelect
	simpleSelect
	loadingText
	autoWidth
	autoHeight
	style
	region
	selectedClass 
	overClass
	emptyText
	itemSelector
	tpl
	store
	onContextMenu
    }


    lappend config "applyTo:'${domNodeId}'"


    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }


    lappend config "plugins: new Ext.DataView.DragSelector({dragSafe:true})"

    return \{[join $config ,]\}

}


::xo::ui::DataView instproc render {visitor} {

    $visitor ensureLoaded XO.DD
    $visitor ensureLoaded XO.DataView
    $visitor ensureLoaded XO.Store

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true


    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}


