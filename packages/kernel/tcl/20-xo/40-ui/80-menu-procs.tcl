namespace eval ::xo {;}
namespace eval ::xo::ui {;}


::xo::ui::Class ::xo::ui::Menu -superclass {::xo::ui::Widget} -parameter {

    {allowOtherMenus ""}
    {defaultAlign ""}
    {defaults ""}
    {minWidth ""}
    {shadow ""}
    {subMenuAlign ""}
    {items ""}

} -jsClass Ext.menu.Menu

::xo::ui::Menu instproc getConfig {} {

    my instvar items

    foreach o [my childNodes] {
	lappend items "[$o domNodeId]"
    }
    set items \[[join ${items} {,}]\]

    set varList {
	allowOtherMenus
	defaultAlign
	defaults
	minWidth
	shadow
	subMenuAlign
	items
    }


    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config ,]\}

}

::xo::ui::Menu instproc accept {{-rel default} {-action "visit"} visitor} {
    
    set result [next]
    
    $visitor ensureLoaded XO.Menu
    
    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    
    return $result

}

::xo::ui::Menu instproc render {visitor} {
    set node [next]
    $node setAttribute id [my domNodeId]
    return $node
}




::xo::ui::Class ::xo::ui::Menu.TextItem -superclass {::xo::ui::Widget} -parameter {
    {text ""}
} -jsClass Ext.menu.TextItem -jsExpandConfig true

::xo::ui::Menu.TextItem instproc getConfigOptions {} {
    my instvar text
    return [list text $text]
}

::xo::ui::Menu.TextItem instproc render {visitor} {

    $visitor ensureLoaded XO.Menu

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    
    set node [next]
    $node setAttribute id [my domNodeId]
    return $node
}

::xo::ui::Class ::xo::ui::Menu.Item -superclass {::xo::ui::Widget} -parameter {
    {text ""}
    {itemCls ""}
    {style ""}
    {cls ""}
    {ctCls ""}
    {handler ""}
    {iconCls ""}
    {itemCls ""}
    {handler ""}
} -jsClass Ext.menu.Item

::xo::ui::Menu.Item instproc getConfig {} {

    set varList {
	text
	itemCls
	style
	cls
	ctCls
	iconCls
	itemCls
	handler
    }

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }


    #if { $handler ne {} } {
    #	lappend config "handler:[${handler} domNodeId]"
    #}

    return \{[join $config ,]\}
}

::xo::ui::Menu.Item instproc render {visitor} {

    $visitor ensureLoaded XO.Menu

    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    
    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}








::xo::ui::Class ::xo::ui::CheckItem -superclass {::xo::ui::Widget} -parameter {
    {text ""}
    {iconCls ""}
    {checked ""}
    {group ""}
    {value ""}
    {icon ""}
} -jsClass Ext.menu.CheckItem

::xo::ui::CheckItem instproc getConfig {} {
    lappend result "id:'[my domNodeId]'"
    set varList {
	text
	iconCls
	checked
	group
	value
    }
    foreach varName $varList {
	if { [my $varName] ne {} } {
	    lappend result "${varName}:[my $varName]"
	}
    }
    return \{[join $result ,]\}
}

::xo::ui::CheckItem instproc render {visitor} {
    $visitor ensureLoaded XO.Menu
    
    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return [next]

}

::xo::ui::Class ::xo::ui::RadioItem -superclass {::xo::ui::CheckItem} -parameter {
    {group true}
}

::xo::ui::RadioItem instproc render {visitor} {
    return [next]
}




::xo::ui::Class ::xo::ui::Menu.Separator -superclass {::xo::ui::Widget} -parameter {
    {itemCls ""}
} -jsClass Ext.menu.Separator

::xo::ui::Menu.Separator instproc render {visitor} {
    $visitor ensureLoaded XO.Menu
    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    return [next]
}
