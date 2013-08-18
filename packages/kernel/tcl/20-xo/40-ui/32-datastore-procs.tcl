namespace eval ::xo {;}
namespace eval ::xo::ui {;}





::xo::ui::Class ::xo::ui::Store -superclass {::xo::ui::Widget} -configOptions {
    {id ""}
    {autoLoad ""}
    {baseParams ""}
    {expandData ""}
    {data ""}
    {pruneModifiedRecords ""}
    {reader ""}
    {remoteSort ""}
    {sortInfo ""}
    {url ""}
    {totalProperty ""}
    {root ""}
    {paramNames ""}
    {proxy ""}
    {reader ""}
    {fields ""}
    {inlineData ""}
} -jsClass Ext.data.Store

::xo::ui::Store instproc getConfig {} {

    my instvar data

    set varList [my getConfigOptions]

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    #if { $fields ne {} } {	lappend config "fields : \[[join $fields {, }]\]"    }
    #if { $data ne {} } {	lappend config "data : \[[join $data ,]\]"    }


    return \{[join $config {, }]\}

}

::xo::ui::Store instproc render {visitor} {

    $visitor ensureLoaded XO.Store

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return [next]
}



::xo::ui::Class ::xo::ui::SimpleStore -superclass {::xo::ui::Widget} -parameter {
    {id ""}
    {autoLoad ""}
    {baseParams ""}
    {expandData ""}
    {data ""}
    {pruneModifiedRecords ""}
    {reader ""}
    {remoteSort ""}
    {sortInfo ""}
    {url ""}
    {root ""}
    {totalProperty ""}
    {paramNames ""}

} -jsClass Ext.data.SimpleStore

::xo::ui::SimpleStore instproc getConfig {} {

    my instvar data

    set varList {
	id
	baseParams
	expandData
	data
	reader
	pruneModifiedRecords
	remoteSort
	sortInfo
	url
	root
	totalProperty
	paramNames
    }

    
    set config ""
    if { [my store_fields] ne {} } {
	lappend config "fields:\[[join [my set store_fields] {, }]\]"
    }
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    #if { $fields ne {} } {	lappend config "fields : \[[join $fields {, }]\]"    }
    #if { $data ne {} } {	lappend config "data : \[[join $data ,]\]"    }


    return \{[join $config {, }]\}

}

::xo::ui::SimpleStore instproc render {visitor} {

    $visitor ensureLoaded XO.Store

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return [next]
}









::xo::ui::Class ::xo::ui::JsonStore -superclass {::xo::ui::Store} -jsClass Ext.data.JsonStore




