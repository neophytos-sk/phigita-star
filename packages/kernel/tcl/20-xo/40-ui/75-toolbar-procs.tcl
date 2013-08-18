namespace eval ::xo {;}
namespace eval ::xo::ui {;}

::xo::ui::Class ::xo::ui::SelectBox -superclass {::xo::ui::Widget} -parameter {
    {listClass "'x-combo-list-small'"}
    {width 90}
    {value "''"}
    {id "'search-type'"}
    {store ""}
    {displayField ""}
    {valueField ""}
    {emptyText ""}
} -jsClass Ext.ux.SelectBox


::xo::ui::SelectBox instproc getConfig {} {
    my instvar store

    set varList {
	listClass
	width
	value
	id
	displayField
	valueField
	emptyText
    }

#    lappend config "applyTo:'${domNodeId}'"
    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }


    if { $store ne {} } {
	lappend config "store:[${store} domNodeId]"
    }

    return \{[join $config {,}]\}

}

::xo::ui::SelectBox instproc render {visitor} {

    $visitor ensureLoaded XO.Form.ComboBox

    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true
    
    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}




::xo::ui::Class ::xo::ui::SearchField -superclass {::xo::ui::Widget} -parameter {
    {paramName "'q'"}
    {emptyText ""}
    {store ""}
    {width ""}
    {paramName ""}
    {store ""}
} -jsClass Ext.ux.SearchField

::xo::ui::SearchField instproc getConfig {} {
    my instvar store

    set varList {
	paramName
	emptyText
	width
	paramName
	store
    }

#    lappend config "applyTo:'${domNodeId}'"
    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }




    return \{[join $config {,}]\}
}

::xo::ui::SearchField instproc render {visitor} {
    $visitor ensureLoaded XO.Form.TriggerField

    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true
    
    set node [next]
    $node setAttribute id [my domNodeId]
    return $node
}




::xo::ui::Class ::xo::ui::Toolbar -superclass {::xo::ui::Widget} -configOptions {
    {cls ""}
    {style ""}
} -jsClass Ext.Toolbar

::xo::ui::Toolbar instproc getConfig {} {


    set varList [my getConfigOptions]

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }




    set items ""
    foreach o [my childNodes] {
	lappend items [$o domNodeId]
    }
    if { $items ne {} } { 
	lappend config "items: \[[join ${items} {,}]\]"
    }
    
    return \{[join $config {,}]\}

}


::xo::ui::Toolbar instproc accept {{-rel default} {-action "visit"} visitor} {

    set result [next]

    my instvar domNodeId


    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true

    return $result
}

::xo::ui::Toolbar instproc render {visitor} {

    $visitor ensureLoaded XO.Form.TriggerField
    $visitor ensureLoaded XO.Toolbar

    return [next]
}


::xo::ui::Class ::xo::ui::PagingToolbar -superclass {::xo::ui::Widget} -parameter {
    {pageSize "10"}
    {displayInfo "true"}
    {displayMsg "'Displaying {0} - {1} of {2}'"}
    {emptyMsg "'No data to display'"}
    {store ""}
    {style ""}
    {paramNames "\{'start':'x_offset','limit':'x_limit','sort':'sort','dir':'dir'\}"}
} -jsClass Ext.PagingToolbar

::xo::ui::PagingToolbar instproc getConfig {} {
    my instvar store

    set varList {
	pageSize
	displayInfo
	displayMsg
	emptyMsg
	style
	paramNames
    }

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    if { $store ne {} } {
	lappend config "store:[${store} domNodeId]"
    }


    return \{[join $config {,}]\}

}

::xo::ui::PagingToolbar instproc render {visitor} {

    $visitor ensureLoaded XO.Toolbar

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id $domNodeId
    return $node

}






::xo::ui::Class ::xo::ui::Toolbar.Button -superclass {::xo::ui::Widget} -parameter {
    {text ""}
    {iconCls ""}
    {handler ""}
} -jsClass Ext.Toolbar.Button

::xo::ui::Toolbar.Button instproc getConfig {} {
    my instvar handler

    set varList {
	text
	iconCls
    }

#    lappend config "applyTo:'${domNodeId}'"
    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }


    if { $handler ne {} } {
	lappend config "handler:[${handler} domNodeId]"
    }


    return \{[join $config {,}]\}
}

::xo::ui::Toolbar.Button instproc render {visitor} {

    $visitor ensureLoaded XO.Toolbar
    $visitor ensureLoaded XO.Button

    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init ${domNodeId} true
    
    set node [next]
    $node setAttribute id [my domNodeId]
    return $node
}





::xo::ui::Class ::xo::ui::Toolbar.SplitButton -superclass {::xo::ui::Widget} -parameter {
    {text ""}
    {cls ""}
    {ctCls ""}
    {iconCls ""}
    {handler ""}
    {menu ""}
} -jsClass Ext.Toolbar.SplitButton

::xo::ui::Toolbar.SplitButton instproc getConfig {} {
    my instvar handler menu

    set varList {
	text
	iconCls
	cls
	ctCls
    }

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }


    if { $handler ne {} } {
	lappend config "handler:[${handler} domNodeId]"
    }
    if { $menu ne {} } {
	lappend config "menu:[${menu} domNodeId]"
    }

    return \{[join $config {,}]\}
}

::xo::ui::Toolbar.SplitButton instproc render {visitor} {

    $visitor ensureLoaded XO.Toolbar
    $visitor ensureLoaded XO.Button

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    
    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}






::xo::ui::Class ::xo::ui::Toolbar.TextItem -superclass {::xo::ui::Widget} -parameter {
    {text ""}
} -jsClass Ext.Toolbar.TextItem -jsExpandConfig true

::xo::ui::Toolbar.TextItem instproc getConfigOptions {} {
    my instvar text
    return [list text $text]
}

::xo::ui::Toolbar.TextItem instproc render {visitor} {

    $visitor ensureLoaded XO.Toolbar

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    
    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}





::xo::ui::Class ::xo::ui::Toolbar.Separator -superclass {::xo::ui::Widget} -jsClass Ext.Toolbar.Separator

::xo::ui::Toolbar.Separator instproc render {visitor} {

    $visitor ensureLoaded XO.Toolbar

    my instvar domNodeId text
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    
    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}


::xo::ui::Class ::xo::ui::Toolbar.Spacer -superclass {::xo::ui::Widget} -jsClass Ext.Toolbar.Spacer

::xo::ui::Toolbar.Spacer instproc render {visitor} {

    $visitor ensureLoaded XO.Toolbar

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    
    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}

::xo::ui::Class ::xo::ui::Toolbar.Fill -superclass {::xo::ui::Widget} -jsClass Ext.Toolbar.Fill

::xo::ui::Toolbar.Fill instproc render {visitor} {

    $visitor ensureLoaded XO.Toolbar

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    
    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}




::xo::ui::Class ::xo::ui::CycleButton -superclass {::xo::ui::Widget} -parameter {
    {changeHandler ""}
    {showText ""}
    {prependText ""}
    {enableToggle ""}
    {minWidth ""}
    {menuAlign ""}
} -jsClass Ext.CycleButton


::xo::ui::CycleButton instproc getConfig {} {
    my instvar changeHandler

    set varList {
	showText
	prependText
	enableToggle
	minWidth
	menuAlign
    }

#    lappend config "applyTo:'${domNodeId}'"
    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    if { $changeHandler ne {} } {
	lappend config "changeHandler:[${changeHandler} domNodeId]"
    }



    set items ""
    foreach o [my childNodes] {
	lappend items [$o getConfig]
    }

#    set items {	"{text:'Tiles',checked:true}"	"{text:'Icons'}"    }

    if { $items ne {} } { 
	lappend config "items: \[[join ${items} {,}]\]"
    }
    return \{[join $config {,}]\}

}

::xo::ui::CycleButton instproc accept {{-rel default} {-action "visit"} visitor} {

    set node [next]
    $visitor ensureLoaded XO.Toolbar
    $visitor ensureLoaded XO.Button

    my instvar domNodeId


    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    

    $node setAttribute id ${domNodeId}
    return $node
}

::xo::ui::CycleButton instproc render {visitor} {
    return [next]
}



::xo::ui::Class ::xo::ui::lg.Toolbar -superclass {::xo::ui::Toolbar} -configOptions {{view ""} {displayInfo ""}} -jsClass Ext.ux.grid.livegrid.Toolbar
