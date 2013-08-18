namespace eval ::xo {;}
namespace eval ::xo::ui {;}

Class ::xo::ui::Desktop -superclass {::xo::ui::Widget}

::xo::ui::Desktop instproc render {visitor} {

    $visitor ensureLoaded XO.Desktop
#    $visitor ensureLoaded XO.Toolbar
#    $visitor ensureLoaded XO.Form

    my instvar domNodeId

    $visitor inlineJavascript [subst -nobackslashes -nocommands {
	var $domNodeId = function(){
	    return {
		init : function(){

		    this.m_el = null;

		}
	    }
	}();
    }]
    $visitor onReady [my domNodeId].init [my domNodeId] true

    set node [next]

    $visitor ensureNodeCmd elementNode div
    $visitor ensureNodeCmd elementNode dl
    $visitor ensureNodeCmd elementNode dt
    $visitor ensureNodeCmd elementNode a 
    $visitor ensureNodeCmd elementNode img   

    $node appendFromScript {

	div -id "x-desktop" {
	    a -href "http://www.phigita.net/" -target "_blank" -style "margin:5px; float:right;" {
		img -src "http://www.phigita.net/graphics/phigita-tv-2"
	    }
	    
	    dl -id "x-shortcuts" {
		dt -id "grid-win-shortcut" {
		    a -href "\#" { 
			img -src "http://www.phigita.net/graphics/s.gif"
			div { t "Grid Window" }
		    }
		}
		dt -id "acc-win-shortcut" {
		    a -href "\#" { 
			img -src "http://www.phigita.net/graphics/s.gif" 
			div { t "Instant Messenger" }
		    }
		}
	    }
	}
	
	div -id "ux-taskbar" {
	    div -id "ux-taskbar-start"
	    div -id "ux-taskbuttons-panel"
	    div -class "x-clear"
	}
	
    }


    return $node

}