namespace eval ::xo {;}
namespace eval ::xo::ui {;}

Class ::xo::ui::NavTabView -superclass {::xo::ui::Widget} -parameter {
    {label "NavTabView"}
}

::xo::ui::NavTabView instproc render {visitor} {

    #set visitor [self callingobject]

    $visitor ensureLoaded YUI.CSS.Reset-Fonts-Grids
    $visitor ensureLoaded XO.CSS.NavTabView

    $visitor ensureNodeCmd elementNode div
    $visitor ensureNodeCmd elementNode h3
    $visitor ensureNodeCmd elementNode h4
    $visitor ensureNodeCmd elementNode ul
    $visitor ensureNodeCmd elementNode li


    [next] appendFromScript {
	div -class "navset" -id [my domNodeId] {
	    div -class "hd" {
		h3 { t [my label] }
		set innerNode [ul]
	    }
	    div -class bd {
		h4 { t "Business News Categories" }
		set outerNode [ul]

	    }
	}
    }

    my instvar varNameOut
    if { [info exists varNameOut] } {
	$visitor set ${varNameOut} $outerNode
    }

    return $innerNode
}


Class ::xo::ui::NavTabViewItem
::xo::ui::NavTabViewItem instproc render {visitor} {
    #set visitor [self callingobject]

    $visitor ensureNodeCmd elementNode li
    $visitor ensureNodeCmd elementNode em
    $visitor ensureNodeCmd elementNode a
    $visitor ensureNodeCmd elementNode strong

    set outerNode [li { set innerNode [a -href [my href]] }]

    # on for selected, orphan for non-tab entries
    if { [my exists flag(selected)] } {
	$outerNode setAttribute class on
	$innerNode appendFromScript {
	    strong { em { t [my label] } } 
	}
    } else {
	$innerNode appendFromScript {
	    em { t [my label] }
	}
    }
    if { [my exists flag(orphan)] } {
	$outerNode setAttribute class orphan
    }
    return $innerNode
}


Class ::xo::ui::NavTab -parameter {
    {label ""}
    {href ""}
}

::xo::ui::NavTab instproc render {visitor} {
    #set visitor [self callingobject]
    $visitor ensureNodeCmd elementNode a
    set node [a -href [my href] { t [my label]-[ad_conn path_info] }]
    if { [ad_conn path_info] eq [my href] } {
	$node setAttribute class on
    }
    return $node
}
