# tcl

proc Location {args} {
    set default {
	{"type"       "title"         "title,ylabel,xlabel,..."}
	{"params"     "center"        "center,left,right,..."}
	{"drawable"   "root"          "name of relevant drawable"}
	{"separator"  ","             "what to use to separate coord list that is returned"}
    }
    ArgsProcessWithDashArgs Placement default args use \
	"Use this to get the coordinates of well-known things, like title, ylabel, xlabel, etc."
    # XXX - this isn't very good right now
    variable _draw
    set d $use(drawable)
    switch -regexp $use(type) {
	"title" { 
	    set x [expr ($_draw($d,width)/2.0) + $_draw($d,xoff)]
	    set y [expr $_draw($d,height) + $_draw($d,yoff) + 5.0]
	}
	"ylabel" {
	    # XXX -- this is not a very good heuristic
	    set x [expr $_draw($d,xoff) * 0.25]
	    set y [expr ($_draw($d,height)/2.0) + $_draw($d,yoff)]
	}
	"xlabel" {
	    set x [expr $_draw($d,xoff) + ($_draw($d,width)/2.0)]
	    # XXX -- this is not a very good heuristic
	    set y [expr $_draw($d,yoff) - 25.0]
	}
	default {
	    Abort "Location: bad option $use(type), should be xlabel, ylabel, or title"
	}
    }
    return "$x$use(separator)$y"
}
