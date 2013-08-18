namespace eval ::xo {;}
namespace eval ::xo::ui {;}

::xo::ui::Class ::xo::ui::TreeLoader -superclass {::xo::ui::Widget} -configOptions {

    {dataUrl ""}
    {baseParams ""}
    {clearOnLoad ""}
    {preloadChildren ""}
    {baseAttrs ""}
    {uiProviders ""}
    {requestMethod ""}

} -jsClass Ext.tree.TreeLoader

::xo::ui::TreeLoader instproc getConfig {} {

    set varList [my getConfigOptions]

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config {,}]\}

}

::xo::ui::TreeLoader instproc render {visitor} {

    $visitor ensureLoaded XO.Tree

    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return [next]
}


::xo::ui::Class ::xo::ui::TreePanel -superclass {::xo::ui::Widget} -parameter {

    {title ""}
    {layout ""}
    {region ""}
    {margins ""}
    {cmargins ""}
    {width ""}
    {height ""}
    {split "false"}
    {border "false"}
    {bodyBorder "false"}
    {hideBorders ""}
    {showTitle "false"}
    {autoScroll ""}
    {autoWidth ""}
    {autoHeight ""}
    {header ""}
    {rootVisible ""}
    {enableDD ""}
    {enableDrag ""}
    {enableDrop ""}
    {animate ""}
    {containerScroll ""}
    {loader ""}
    {collapsible ""}
    {lines ""}	
    {tbar ""}
    {bbar ""}
    {style ""}
    {ddGroup ""}
    {minSize ""}
    {maxSize ""}
    {collapseFirst ""}
    {tbar ""}

} -jsClass Ext.tree.TreePanel

::xo::ui::TreePanel instproc getConfig {} {

    my instvar domNodeId label region layout

    lappend config "applyTo:'${domNodeId}'"

    set varList {
	title
	width
	height
	border
	bodyBorder
	hideBorders
	autoScroll
	autoWidth
	autoHeight
	style
	split
	header
	region
	margins
	cmargins
	layout
	rootVisible
	enableDD
	enableDrag
	enableDrop
	animate
	containerScroll
	collapsible
	lines
	style
	ddGroup
	minSize
	maxSize
	collapseFirst
	tbar
	loader
    }



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
	#lappend config "items: \[[join ${items} {,}]\]"
	if { [llength $items] == 1 } {
	    lappend config "'root': ${items}"
	} else {
	    error "Tree should have only one toplevel node/root"
	}
    }
    
    return \{[join $config ,]\}

}

::xo::ui::TreePanel instproc accept {{-rel default} {-action "visit"} visitor} {

    set node [next]

    $visitor ensureLoaded XO.Fx
    $visitor ensureLoaded XO.DD
    $visitor ensureLoaded XO.Tree

    my instvar domNodeId 
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true


    return $node
}

::xo::ui::TreePanel instproc render {visitor} {
    return [next]
}




::xo::ui::Class ::xo::ui::TreeNode -superclass {::xo::ui::Widget} -parameter {

    {text ""}
    {allowDrag ""}
    {allowDrop ""}
    {checked ""}
    {disabled ""}
    {expandable ""}
    {expanded ""}
    {leaf ""}
    {singleClickExpand ""}
    {iconCls ""}
    {cls ""}
    {icon ""}
    {uiProvider ""}
    {qtip ""}
    {isTarget ""}

} -jsClass Ext.tree.TreeNode

::xo::ui::TreeNode instproc getConfig {} {

#    lappend config "applyTo:'${domNodeId}'"

    set varList {
	text
	allowDrag
	allowDrop
	checked
	disabled
	expandable
	expanded
	leaf 
	singleClickExpand
	iconCls
	cls
	icon
	uiProvider
	qtip
	isTarget
    }

    set config ""
#    lappend config "applyTo:'${domNodeId}'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config ,]\}

}

::xo::ui::TreeNode instproc getConstructor {} {

    set result [next]

    my instvar domNodeId
    set items ""
    foreach o [my childNodes] {
        lappend items [$o domNodeId]
    }
    set extra ""
    if { $items ne {} } {
        #lappend config "items: \[[join ${items} {,}]\]"
        set extra "${domNodeId}.appendChild(\[[join $items ,]\]);"
    }

    return "${result}${extra}"
}


::xo::ui::TreeNode instproc accept  {{-rel default} {-action "visit"} visitor} {

    set node [next]

    $visitor ensureLoaded XO.Fx
    $visitor ensureLoaded XO.DD
    $visitor ensureLoaded XO.Tree

    my instvar domNodeId

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return $node
}


::xo::ui::Class ::xo::ui::AsyncTreeNode -superclass {::xo::ui::Widget} -parameter {

    {text ""}
    {allowDrag ""}
    {allowDrop ""}
    {checked ""}
    {disabled ""}
    {expandable ""}
    {expanded ""}
    {leaf ""}
    {singleClickExpand ""}
    {loader ""}
    {iconCls ""}
    {cls ""}
    {isTarget ""}
    {uiProvider ""}

} -jsClass Ext.tree.AsyncTreeNode

::xo::ui::AsyncTreeNode instproc getConfig {} {
    my instvar loader

    set varList {
	text
	allowDrag
	allowDrop
	checked
	disabled
	expandable
	expanded
	leaf 
	singleClickExpand
	iconCls
	cls
	isTarget
	uiProvider
	loader
    }

    set config ""
#    lappend config "applyTo:'${domNodeId}'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config ,]\}
}

::xo::ui::AsyncTreeNode instproc getConstructor {} {
    my instvar domNodeId
    set result [next]
    set items ""
    foreach o [my childNodes] {
        lappend items [$o domNodeId]
    }
    set extra ""
    if { $items ne {} } {
        #lappend config "items: \[[join ${items} {,}]\]"
        set extra "${domNodeId}.appendChild([join $items ,]);"
    }

    return "${result}${extra}"
}

::xo::ui::AsyncTreeNode instproc accept  {{-rel default} {-action "visit"} visitor} {

    set node [next]

    $visitor ensureLoaded XO.Fx
    $visitor ensureLoaded XO.DD
    $visitor ensureLoaded XO.Tree

    my instvar domNodeId
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return $node
}


::xo::ui::Class ::xo::ui::TreeEditor -superclass {::xo::ui::Widget} -parameter {

    tree
    {allowBlank ""}
    {blankText ""}
    {selectOnFocus ""}
    {cancelOnEsc ""}
    {editDelay ""}
    {revertInvalid ""}
    {swallowKeys ""}
    {ignoreNoChange ""}
    {completeOnEnter ""}
    {stateEvents ""}

} -jsClass Ext.tree.TreeEditor

::xo::ui::TreeEditor instproc getConfig {} {

    my instvar stateEvents

    set varList {
	allowBlank
        blankText
        selectOnFocus
	cancelOnEsc
	editDelay
	revertInvalid
	swallowKeys
	ignoreNoChange
	completeOnEnter
	stateEvents
    }

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    return \{[join $config ,]\}
}


::xo::ui::TreeEditor instproc getConstructor {} {
    my instvar domNodeId tree
    [my info class] instvar jsClass
    set config [my getConfig]
    set treeEl [$tree domNodeId]
    set aliases [my getAliases]
    return "${aliases};${domNodeId}=new $jsClass (${treeEl},$config);"
}


::xo::ui::TreeEditor instproc render {visitor} {

    $visitor ensureLoaded XO.Tree
    my instvar domNodeId 

    # add an inline editor for the nodes
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    set node [next]
    $node setAttribute id ${domNodeId}
    return $node
}


::xo::ui::Class ::xo::ui::TreeSorter -superclass {::xo::ui::Widget} -parameter {
    tree
    {foldersort ""}
    {property ""}
    {leafAttr ""}
    {dir ""}
    {caseSensitive ""}
    {sortType ""}
} -jsClass Ext.tree.TreeSorter

::xo::ui::TreeSorter instproc getConfig {} {

    set varList {
	foldersort
	property
	leafAttr
	dir
	caseSensitive
	sortType
    }

    set config ""
#    lappend config "applyTo:'${domNodeId}'"
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }

    set items ""
    foreach o [my childNodes] {
	lappend items [$o domNodeId]
    }
    set extra ""
    if { $items ne {} } { 
	#lappend config "items: \[[join ${items} {,}]\]"
	set extra "this.appendChild([join $items ,]);"
    }
    return \{[join $config ,]\}
}


::xo::ui::TreeSorter instproc getConstructor {} {
    my instvar domNodeId tree
    [my info class] instvar jsClass
    set config [my getConfig]
    set treeEl [$tree domNodeId]
    set aliases [my getAliases]
    return "${aliases}${domNodeId}=new ${jsClass}(${treeEl},${config});"
}



::xo::ui::TreeSorter instproc accept  {{-rel default} {-action "visit"} visitor} {

    set node [next]

    $visitor ensureLoaded XO.Fx
    $visitor ensureLoaded XO.DD
    $visitor ensureLoaded XO.Tree

    my instvar domNodeId




    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true

    return $node
}











::xo::ui::Class ::xo::ui::ColumnTree -superclass {::xo::ui::Widget} -parameter {

    {title ""}
    {layout ""}
    {region ""}
    {margins ""}
    {cmargins ""}
    {width ""}
    {height ""}
    {split "false"}
    {border "false"}
    {bodyBorder "false"}
    {hideBorders ""}
    {showTitle "false"}
    {autoScroll ""}
    {autoWidth ""}
    {autoHeight ""}
    {header ""}
    {rootVisible ""}
    {enableDD ""}
    {enableDrag ""}
    {enableDrop ""}
    {animate ""}
    {containerScroll ""}
    {loader ""}
    {collapsible ""}
    {lines ""}	
    {tbar ""}
    {bbar ""}
    {style ""}
    {ddGroup ""}
    {minSize ""}
    {maxSize ""}
    {collapseFirst ""}
    {tbar ""}
    {columns ""}
    {showHeaders ""}

} -jsClass Ext.tree.ColumnTree

::xo::ui::ColumnTree instproc getConfig {} {

    my instvar domNodeId label region layout 

    lappend config "applyTo:'${domNodeId}'"

    set varList {
	title
	width
	height
	border
	bodyBorder
	hideBorders
	autoScroll
	autoWidth
	autoHeight
	style
	split
	header
	region
	margins
	cmargins
	layout
	rootVisible
	enableDD
	enableDrag
	enableDrop
	animate
	containerScroll
	collapsible
	lines
	style
	ddGroup
	minSize
	maxSize
	collapseFirst
	tbar
	columns
	showHeaders
	loader
    }



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
	#lappend config "items: \[[join ${items} {,}]\]"
	if { [llength $items] == 1 } {
	    lappend config "'root': ${items}"
	} else {
	    error "Tree should have only one toplevel node/root"
	}
    }
    
    return \{[join $config ,]\}

}

::xo::ui::ColumnTree instproc accept {{-rel default} {-action "visit"} visitor} {

    set node [next]

    $visitor ensureLoaded XO.Fx
    $visitor ensureLoaded XO.DD
    $visitor ensureLoaded XO.Tree

    my instvar domNodeId 
    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true


    return $node
}

::xo::ui::ColumnTree instproc render {visitor} {
    return [next]
}
