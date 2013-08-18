Class ::xo::ui::Wireframe -superclass {::xo::ui::Widget} -parameter {
    {splitMode  "100"}   
}

::xo::ui::Wireframe instproc render {visitor} {
    my instvar splitMode

    #set visitor [self callingobject]
    $visitor ensureLoaded YUI.CSS.Reset-Fonts-Grids
    $visitor ensureNodeCmd elementNode div
    $visitor ensureNodeCmd elementNode style
    $visitor ensureNodeCmd elementNode br
    $visitor ensureNodeCmd elementNode b
    $visitor ensureNodeCmd elementNode hr

    [next] appendFromScript {
	style {
	    t -disableOutputEscaping [subst -nobackslashes -novariables {
		#[my domNodeId] {margin:auto;}
		body {text-align:left;}
	    }]
	}
	br
	br
	b { t $splitMode }
	hr
	set nodeList [list]
	switch -exact -- $splitMode {
	    100 {
		# Case 1 - 1 Column (100)
		lappend nodeList [div -class "yui-g"]
	    }
	    50/50 {
		# Case 2 - 2 Column (50/50)
		div -class "yui-g" {
		    lappend nodeList [div -class "yui-u first"]
		    lappend nodeList [div -class "yui-u"]
		}
	    }
	    33/33/33 {
		# Case 3 - 3 Column (33/33/33/)
		div -class "yui-gb first" {
		    lappend nodeList [div -class "yui-u first"]
		    lappend nodeList [div -class "yui-u"]
		    lappend nodeList [div -class "yui-u"]
		}
	    }
	    25/25/25/25 {
		# Case 4 - 4 Column (25/25/25/25)
		div -class "yui-g" {
		    div -class "yui-g first" {
			lappend nodeList [div -class "yui-u first"]
			lappend nodeList [div -class "yui-u"]
		    }
		    div -class "yui-g" {
			lappend nodeList [div -class "yui-u first"]
			lappend nodeList [div -class "yui-u"]
		    }
		}
	    }
	    50/25/25 {
		# Case 5 - 3 Column (50/25/25)
		div -class "yui-g" {
		    lappend nodeList [div -class "yui-u first"]
		    div -class "yui-g" {
			lappend nodeList [div -class "yui-u first"]
			lappend nodeList [div -class "yui-u"]
		    }
		}		
	    }
	    25/25/50 {
		# Case 6 - 3 Column (25/25/50)
		div -class "yui-g" {
		    div -class "yui-g first" {
			lappend nodeList [div -class "yui-u first"]
			lappend nodeList [div -class "yui-u"]
		    }
		    lappend nodeList [div -class "yui-u"]
		}
	    }
	    66/33 {
		# Case 7 - 2 Column (66/33)
		div -class "yui-gc" {
		    lappend nodeList [div -class "yui-u first"]
		    lappend nodeList [div -class "yui-u"]
		}
	    }
	    33/66 {
		# Case 8 - 2 Column (33/66)
		div -class "yui-gd" {
		    lappend nodeList [div -class "yui-u first"]
		    lappend nodeList [div -class "yui-u"]
		}
	    }
	    75/25 {
		# Case 9 - 2 Column (75/25)
		div -class "yui-ge" {
		    lappend nodeList [div -class "yui-u first"]
		    lappend nodeList [div -class "yui-u"]
		}
	    }
	    25/75 {
		# Case 10 - 2 Column (25/75)
		div -class "yui-gf" {
		    lappend nodeList [div -class "yui-u first"]
		    lappend nodeList [div -class "yui-u"]
		}
	    }
	    default {
		error "Invalid splitMode value"
	    }
	}
    }
    foreach node $nodeList {
	$node appendFromScript {
	    t "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Maecenas sit amet metus. Nunc quam elit, posuere nec, auctor in, rhoncus quis, dui. Aliquam erat volutpat. Ut dignissim, massa sit amet dignissim cursus, quam lacus feugiat."
	}
    }
    return [lindex $nodeList 0]
}