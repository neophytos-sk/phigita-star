namespace eval ::xo {;}
namespace eval ::xo::ui {;}

::xo::ui::Class ::xo::ui::Container -superclass {::xo::ui::Widget} -parameter {

    {title ""}
    {layout ""}
    {region ""}
    {width ""}
    {height ""}
    {autoHeight ""}
    {autoWidth ""}
    {margins ""}
    {border "false"}
    {bodyBorder ""}
    {hideBorders ""}
    {items ""}
    {split ""}
    {tbar ""}
    {bbar ""}
    {autoScroll ""}
    {style ""}
    {frame ""}
    {header "false"}
    {showTitle ""}
    {collapsible ""}
    {headerAsText ""}
    {html ""}
    {columnWidth ""}
    {monitorResize ""}
    {layoutConfig ""}
    {defaults ""}
    {labelAlign ""}
    {html ""}
} -jsClass Ext.Panel

::xo::ui::Container instproc getConfig {} {

    my instvar domNodeId layout region margins tbar bbar

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
	frame
	header
	headerAsText
	collapsible
	monitorResize
	columnWidth
	layoutConfig 
	defaults
	labelAlign 
    }

    set config ""
    foreach varName $varList {
	if { [my set $varName] ne {} } {
	    lappend config "${varName}:[my set $varName]"
	}
    }




    lappend config "applyTo:'${domNodeId}'"
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

    if { $layout ne {} } {
	lappend config "layout:'${layout}'"
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

::xo::ui::Container instproc accept {{-rel default} {-action "visit"} visitor} {

    set result [next]

    $visitor ensureLoaded XO.Panel

    my instvar domNodeId 
    $visitor inlineJavascript [my getJS]

    $visitor onReady _${domNodeId}.init _${domNodeId} true
    #$visitor onReady ${domNodeId}.render ${domNodeId} true

    return $result
}


::xo::ui::Class ::xo::ui::Panel -superclass {::xo::ui::Container} -jsClass Ext.Panel

::xo::ui::Panel instproc render {visitor} {

    my instvar region html

    set node [next]
    $node setAttribute id [my domNodeId]
    $node setAttribute class x-panel
    if { $region ne {} } {
	$node setAttribute class [concat [$node getAttribute class ""] x-border-panel]
    }
    
    $node appendFromScript {
	div -class "x-panel-bwrap" {
	    set innerNode [div -class "x-panel-body" { 
		if { $html ne {} } {
		    div { t -disableOutputEscaping [string trim $html {'}] }
		}
	    }]
	}
    }
    return $innerNode
}












#######################################3



Class ::xo::ui::Panel_OLD -superclass {::xo::ui::Widget} -parameter {
    {label "[namespace tail [self]]"}
}

::xo::ui::Panel_OLD instproc render {visitor} {
    return [next]
}

# Skins: XP, Aqua
Class ::xo::ui::OverlayPanel -superclass {::xo::ui::Panel_OLD} -parameter {
    {width "100%"}
    {visible "true"}
    {constraintoviewport "true"}
    {modal "false"}
    {iframe "false"}
    {resizable "true"}
}

::xo::ui::OverlayPanel instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureLoaded YUI.util.Yahoo-DOM-Event
    $visitor ensureLoaded YUI.util.Animation ;# OPTIONAL: Animation (only required if enabling animation)
    $visitor ensureLoaded YUI.util.DragDrop ;# OPTIONAL: Drag & Drop (only required if  enabling drag & drop)
    $visitor ensureLoaded YUI.util.Container
    $visitor ensureLoaded YUI.CSS.Reset-Fonts-Grids

    $visitor ensureNodeCmd elementNode div
    $visitor ensureNodeCmd elementNode span

    $visitor inlineJavascript [subst -nobackslashes {
	var [my domNodeId] = function(){
	    var panel;
	    return {
		init : function(){
		    panel = new YAHOO.widget.Panel("[my domNodeId]", { width:"[my width]", visible:[my visible], constraintoviewport:[my constraintoviewport], modal:[my modal], iframe:[my iframe], resizable: [my resizable] } ); 
		    panel.render()
		}
	    }
	}();
    }]
    $visitor onDocumentReady [my domNodeId].init [my domNodeId] true


    set node [next]


    if { [my skin] ne {} } {
	$visitor ensureLoaded YUI-SKIN.css.[my skin]
	$node setAttribute class [concat [$node getAttribute class ""] panel_skin_[my skin]]
	[$node parentNode] setAttribute class [concat [[$node parentNode] getAttribute class ""] panel_skin_[my skin]_c]
    }

    $node appendFromScript {
	div -class hd { div class "tl"; span { t [my label] }; div -class "tr" }
	set innerNode [div -class bd]
	div -class ft { div class "bl"; span; div -class br }
    }

    return $innerNode
}

Class ::xo::ui::InfoPanel -superclass {::xo::ui::Widget} -parameter {
    {width "100%"}
}

::xo::ui::InfoPanel instproc render {{-rel "default"}} {
    #set visitor [self callingobject]

    $visitor ensureLoaded dhtmlsuite

    $visitor inlineStyle [subst {
	#[my domNodeId] {background-color:#7190e0;width:[my width];}
    }]


    set node [next]
    set labels ""
    set cookieNames ""
    foreach child [my childNodes] {
	lappend labels [$child label]
#	lappend cookieNames [$child domNodeId]
    }
    set labels [join [lmap $labels ns_dbquotevalue] ,]
    set cookieNames [join [lmap $cookieNames ns_dbquotevalue] ,]

    set js ""
    append js {
	var infoPane = new DHTMLSuite.infoPanel();
	DHTMLSuite.commonObj.setCssCacheStatus(true);
    }
    foreach child [my childNodes] {
	append js [subst -nobackslashes {
	    infoPane.addPane([ns_dbquotevalue [$child domNodeId]],[ns_dbquotevalue [$child label]],false,'cookie_[$child domNodeId]');
	}]
    }
    append js { infoPane.init(); }

    $visitor inlineJavascript [subst -nobackslashes {
	var [my domNodeId] = function(){
	    var layout;
	    return {
		init : function(){
		    $js
		}
	    }
	}();
    }]
    $visitor onDocumentReady [my domNodeId].init [my domNodeId] true

    return $node
}






Class ::xo::ui::Image -superclass {::xo::ui::Widget} -parameter {
    {src ""}
    {width ""}
    {height ""}
}
::xo::ui::Image instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode img
    my instvar alt width height
    set node [img -src [my src]]
    if { [info exists alt] } {
	$node setAttribute alt $alt
    }
    if { [info exists width] } {
	$node setAttribute width $width
    }
    if { [info exists height] } {
	$node setAttribute height $height
    }
    
}

Class ::xo::ui::Anchor -superclass {::xo::ui::Widget} -parameter {
    {href ""}
}
::xo::ui::Anchor instproc render {visitor} {
    $visitor ensureNodeCmd elementNode a
    return [a -id [my domNodeId] -href [my href]]
}


Class ::xo::ui::Text -superclass {::xo::ui::Widget} -parameter {
    {value ""}
}

::xo::ui::Text instproc render {visitor} {
    set node [next]
    my instvar label
    $node appendFromScript {
	t $label
    }
    return $node
}

Class ::xo::ui::TextAnchor -superclass { ::xo::ui::Text ::xo::ui::Anchor}

Class ::xo::ui::NavTabPanel.TextAnchor -superclass {::xo::ui::TextAnchor} 

::xo::ui::NavTabPanel.TextAnchor instproc accept {{-rel default} {-action "visit"} visitor} {
    $visitor ensureLoaded CSS.TabPanel
    $visitor ensureNodeCmd elementNode li em a span
    my instvar label href
    [my parentNode] instvar value
    set node [li]
    $node appendFromScript {
	a -href $href -class x-tab-right {
	    em -class x-tab-left {
		span -class x-tab-strip-inner {
		    span -class x-tab-strip-text {
			t $label
		    }
		}
	    }
	}
    }

    if { [my set value] eq $value } {
	$node setAttribute class [concat [$node getAttribute class ""] x-tab-strip-active]
    }
    return $node
}

Class ::xo::ui::NavTabPanel -superclass {::xo::ui::Widget} -parameter {
    {value ""}
}



::xo::ui::NavTabPanel instproc render {visitor} {
    $visitor ensureNodeCmd elementNode div
    $visitor ensureNodeCmd elementNode ul
    set node [next]
    $node setAttribute class "x-tab-panel x-border-panel x-tab-panel-noborder"
    $node appendFromScript {
	div -class "x-tab-panel-header x-unselectable x-tab-panel-header-plain" {
	    div -class "x-tab-strip-wrap" {
		set innerNode [ul -class "x-tab-strip x-tab-strip-top"]
	    }
	}
    }
    return $innerNode
}

Class ::xo::ui::StackPanel -superclass {::xo::ui::Widget}
::xo::ui::StackPanel instproc render {visitor} {
    my instvar domNodeId
    #set visitor [self callingobject]
    $visitor ensureLoaded YUI.util.Yahoo-DOM-Event
    $visitor ensureLoaded YUI.util.Animation
    $visitor ensureLoaded YUI-MISC.widget.Accordion

    $visitor inlineJavascript [subst -nobackslashes {
	var ${domNodeId} = function(){
	    var accordion;
	    return {
		init : function(){
		    accordion = new Accordion('[my domNodeId]');
		}
	    }
	}();
    }]
    $visitor onDocumentReady [my domNodeId].init [my domNodeId] true

    set node [next]
    $node setAttribute style "width:100%;height:100%;border:1px solid activecaption"
    return $node
}

::xo::ui::StackPanel instproc accept {{-rel default} {-action "visit"} visitor} {
    set instmixins [Panel info instmixin]
    Panel instmixin add "::xo::ui::AccordionItem"
    set node [next]
    Panel instmixin $instmixins
    return $node
}

Class ::xo::ui::AccordionItem -superclass "::xo::ui::Widget"
::xo::ui::AccordionItem instproc render {visitor} {
    set node [next]
    $node setAttribute class [concat [$node getAttribute class ""] "AccordionItem"]
    $node appendFromScript {
	div -class "AccordionHeader" { t [my label] }
	set innerNode [div -class "AccordionBody"]
    }
    return $innerNode
}



Class ::xo::ui::ContentPanel

Class ::xo::ui::Carousel -superclass {::xo::ui::Widget}
::xo::ui::Carousel instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureLoaded YUI.utilities
    $visitor ensureLoaded YUI.util.Animation
    $visitor ensureLoaded YUI-Carousel
    $visitor inlineJavascript [subst -nobackslashes {
	var [my domNodeId] = function(){
	    var carousel;
	    return {
		init : function(){
		    var carousel = new YAHOO.widget.Carousel();
		    carousel.init(document.getElementById('[my domNodeId]'));
		}
	    }
	}();
    }]
    $visitor onDocumentReady [my domNodeId].init [my domNodeId] true

    set node [next]
    $node setAttribute class [concat [$node getAttribute class ""] yui-carousel-screen]
    $node appendFromScript {
	set innerNode [ol]
    }
    return $innerNode
}

Class ::xo::ui::Box2 -superclass {::xo::ui::Panel} -parameter {label {color white}} 

::xo::ui::Box2 instproc render {visitor} {
    #set visitor [self callingobject] 
    $visitor ensureNodeCmd elementNode div
    $visitor ensureNodeCmd elementNode br

    [next] appendFromScript {
	set node [div -style "margin:20px;background:[my color];" {
	    t [my label]
	    br
	    t ----------
	    br
	}]
	br
    }
    return $node
}
