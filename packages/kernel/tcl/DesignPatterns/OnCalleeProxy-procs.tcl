# Simple proxy pattern implementation enhanced with the ability to adapt
# calls solely for specified calling objects
# for each calling obj there may be a different delegator obj

# Callee -- The function or subroutine being called by the caller. 

Class OnCalleeProxy -superclass Class  


OnCalleeProxy instproc onCalleeProxyFilter args { 
    set o [string trimleft [self callingobject] :]
    my instvar callee
    puts stderr "[self class]: checking $o -- [self] -- [self calledproc] "
    if {[info exists callee($o)]} {
	return [::eval [set callee($o)] [self calledproc] $args]
    } else {
	next
    }
}

OnCalleeProxy instproc init args {
    my instfilterappend onCalleeProxyFilter
    next
    my instproc setCallee {callingObj a} {
	my set callee([string trimleft $callingObj :]) $a
    }
}


#### Example:
## OnCalleeProxy aCalleeProxyClass
## aCalleeProxyClass aCalleeProxy
## Object x -proc test {} {aCalleeProxy print_hello}
## Object y -proc print_hello {} {puts "hello world"}
## aCalleeProxy setCallee x y
## x test
## RESULT: hello world

## Object z -proc print_hello {puts "this is a test"}
## aCalleeProxy setCallee x z
## x test
## RESULT: this is a test
