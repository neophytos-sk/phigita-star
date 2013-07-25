##
## Paul Nash
## webscool <webscool@ihug.co.nz>
## http://homepages.ihug.co.nz/~webscool/integer.html
## Acknowledgements to Alexandre Ferrieux <alexandre.ferrieux@cnet.francetelecom.fr>

if (0) {

    NAME

    lambda - Evaluate a lambda expression 


    SYNOPSIS

    lambda params body ?arg arg ...? 


    DESCRIPTION

    Assigns arguments to the parameter list. If the arguments are fully specified the body is evaluated. otherwise a lambda expression is returned. params specifies the formal arguments to the lambda bpdy.  It consists of a list, possibly empty, each of whose elements specifies one argument.  If the last formal parameter has the name args, then the argument list may contain more actual arguments than the procedure has formal parameters.  In this case, all of the actual arguments starting at the one that would be assigned to args are combined into a list (as if the list command had been used); this combined value is assigned to the local variable args. However lambda curries additional arguments into the tail of the lambda expression.

    When the body is evaluated the rturn value is the value of the last command executed in the procedure body. The body executes in the scope of its invoking procedure, so that return, break and continue commands will relate to the invoking procedure environment. Similarly the variables known inside the body are the same as those known in the invoking procedure together with the parameter names. The parameter names become known when the body is evaluated, and remain in existence after the body has been evaluated. This is a similar convention to the for command.The result of an integer command should be treated only as a string in Tcl.

}

rename unknown __curry__unknown

proc unknown {base args} {
    set split 0
    while {[set first [lindex $base 0]] !=$base} {
	set split 1
	regsub -all \\$ $first {\\$} pfirst
	regsub $pfirst $base {} rest
	set args [concat $rest $args]
	set base $first
    }
    if {!$split} {return [uplevel [list __curry__unknown $base] $args]}
    uplevel $base $args
} 

# evaluate a lambda function

proc lambda {params body args} {
    set pre ""
    while { [llength $params ] > 0 && [llength $args] > 0} {
	if { [llength $params] == 1 && [lindex $params 0] == "args" } {
	    append pre "set args [list $args] ; "
	    set params {}
	    set args {}
	} else {
	    append pre "set [lindex $params 0] [list [lindex $args 0]] ; "
	    set params [lrange $params 1 end]
	    set args [lrange $args 1 end]
	}
    }
    set body [concat $pre $body]
    if { [llength $params] > 0 } { return [list lambda $params $body ] }
    puts $body--$args
    uplevel $body $args
}









