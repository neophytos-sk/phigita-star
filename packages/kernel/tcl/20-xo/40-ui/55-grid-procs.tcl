namespace eval ::xo {;}
namespace eval ::xo::ui {;}


::xo::ui::Class ::xo::ui::GridPanel -superclass {::xo::ui::Widget} -configOptions {

    {autoExpandColumn ""}
    {autoExpandMax ""}
    {autoExpandMin ""}
    {enableColumnHide ""}
    {enableColumnMove ""}
    {enableColumnResize ""}
    {enableHdMenu ""}
    {maxHeight ""}
    {minColumnWidth ""}
    {bbar ""}
    {columns ""}
    {cm ""}
    {loadMask ""}
    {title ""}
    {width ""}
    {height ""}
    {frame ""}
    {iconCls ""}
    {plugins ""}
    {sm ""}
    {store ""}
    {stripeRows ""}
    {tbar ""}
    {trackMouseOver ""}
    {collapsible ""}
    {viewConfig ""}
    {animCollapse ""}
    {autoHeight ""}
    {autoWidth ""}
    {style ""}
    {hideHeaders ""}
    {headerAsText ""}
    {header ""}
    {hideMode ""}
    {border ""}
    {view ""}
    {selModel ""}
    {cls ""}
    

} -jsClass Ext.grid.GridPanel

::xo::ui::GridPanel instproc getConfig {} {

    set varList [my getConfigOptions]

    set config ""
    lappend config "applyTo:'[my domNodeId]'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config ,]\}
}

::xo::ui::GridPanel instproc EXPERIMENTAL_getAliases {} {
    set result [next];
    set aliases ""
    set pos 0
    foreach fieldName $store_fields {
	lappend aliases ${domNodeId}.alias[${fieldName}]='_${pos}';
	incr pos
    }
    if { ${result} ne {} } {
        set result "var [join ${result} {,}];"
    }
    return $result;
}

::xo::ui::GridPanel instproc render {visitor} {

    $visitor ensureLoaded XO.Grid
    
    my instvar domNodeId

    ### HERE: Temporary Hack for my.phigita.net - to avoid 411 Length Required message
    ### DOES NOT WORK
    ### $visitor inlineJavascript "Ext.form.Action.Load.method='GET';"
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    return $node
}


::xo::ui::Class ::xo::ui::xg.ColumnModel -superclass {::xo::ui::Widget} -parameter {
    config
} -jsClass Ext.grid.ColumnModel

::xo::ui::xg.ColumnModel instproc getConfig {} {
    return [my config]
}

::xo::ui::xg.ColumnModel instproc render {visitor} {

    $visitor ensureLoaded XO.Grid
    
    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    return $node
}



::xo::ui::Class ::xo::ui::xg.RowExpander -superclass {::xo::ui::Widget} -configOptions {
    {tpl ""}
    {renderer ""}
} -jsClass Ext.grid.RowExpander

::xo::ui::xg.RowExpander instproc getConfig {} {

    set varList [my getConfigOptions]

    set config ""
    lappend config "applyTo:'[my domNodeId]'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config ,]\}
}

::xo::ui::xg.RowExpander instproc render {visitor} {

    $visitor ensureLoaded XO.Grid
    
    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    return $node
}



::xo::ui::Class ::xo::ui::xg.CheckboxSelectionModel -superclass {::xo::ui::Widget} -configOptions {
    {header ""}
    {moveEditorOnEnter ""}
    {singleSelect ""}
    {sortable ""}
    {width ""}
} -jsClass Ext.grid.CheckboxSelectionModel

::xo::ui::xg.CheckboxSelectionModel instproc getConfig {} {

    set varList [my getConfigOptions]

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }
    if { $config ne {} } {
	return \{[join $config ,]\}
    } else {
	return ""
    }
}

::xo::ui::xg.CheckboxSelectionModel instproc render {visitor} {

    $visitor ensureLoaded XO.Grid
    
    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    return $node
}

::xo::ui::Class ::xo::ui::xg.RowNumberer -superclass {::xo::ui::Widget} -parameter {

} -jsClass Ext.grid.RowNumberer

::xo::ui::xg.RowNumberer instproc getConfig {} {

    set varList {}

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }
    if { $config ne {} } {
	return \{[join $config ,]\}
    } else {
	return ""
    }
}

::xo::ui::xg.RowNumberer instproc render {visitor} {

    $visitor ensureLoaded XO.Grid
    
    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    return $node
}



################



::xo::ui::Class ::xo::ui::PropertyGrid -superclass {::xo::ui::Widget} -parameter {

    {applyTo ""}
    {title ""}
    {closable ""}
    {autoHeight ""}
    {autoWidth ""}
    {border ""}
    {clicksToEdit ""}
    {source ""}

} -jsClass Ext.grid.PropertyGrid

::xo::ui::PropertyGrid instproc getConfig {} {

    my instvar stateEvents

    set varList {
	applyTo
	title
	closable
	autoHeight
	autoWidth
	border
	clicksToEdit
	source
    }

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config ,]\}
}

::xo::ui::PropertyGrid instproc render {visitor} {

    $visitor ensureLoaded XO.Grid
    
    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    return $node
}

::xo::ui::Class ::xo::ui::GridView -superclass {::xo::ui::Widget} -configOptions {
    {autoFill ""}
    {cellSelector ""}
    {cellSelectorDepth ""}
    {deferEmptyText ""}
    {emptyText ""}
    {enableRowBody ""}
    {forceFit ""}
    {rowSelector ""}
    {rowSelectorDepth ""}
}

::xo::ui::Class ::xo::ui::lg.GridView -superclass {::xo::ui::GridView} -configOptions {

    {nearLimit ""}
    {loadMask ""}

} -jsClass Ext.ux.grid.livegrid.GridView

::xo::ui::lg.GridView instproc getConfig {} {

    my instvar stateEvents

    set varList [my getConfigOptions]

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config ,]\}
}

::xo::ui::lg.GridView instproc render {visitor} {

    $visitor ensureLoaded XO.Grid
    
    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    return $node
}



::xo::ui::Class ::xo::ui::lg.RowSelectionModel -superclass {::xo::ui::Widget} -jsClass Ext.ux.grid.livegrid.RowSelectionModel

::xo::ui::lg.RowSelectionModel instproc render {visitor} {
    $visitor ensureLoaded XO.Grid
    
    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    return $node

}

::xo::ui::Class ::xo::ui::lg.Store -superclass {::xo::ui::Store} -jsClass Ext.ux.grid.livegrid.Store

::xo::ui::Class ::xo::ui::lg.JsonStore -superclass {::xo::ui::JsonStore} -parameter {{bufferSize "10"}} -jsClass Ext.ux.grid.livegrid.JsonStore

::xo::ui::Class ::xo::ui::lg.GridPanel -superclass {::xo::ui::GridPanel} -jsClass Ext.ux.grid.livegrid.GridPanel
##::xo::ui::Class ::xo::ui::lg.EditorGridPanel -superclass {::xo::ui::EditorGridPanel} -jsClass Ext.ux.grid.livegrid.EditorGridPanel

