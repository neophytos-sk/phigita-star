#! /bin/csh -f
# this is a csh hack \
exec tclsh $0 $*

namespace eval bar {
    proc cook {} {
	puts "cooking"
    }
    namespace export cook
}
    
namespace eval foo {
    variable time  [clock format [clock seconds]]
    variable bar   0
    variable _g
    
    proc grill {} {
	variable bar
	variable _g
	set _g(0) 1
	puts "called [incr bar] time(s) ($_g(0))"
	bar::cook
    }
    namespace export grill
}

namespace eval foo {
    variable jimmy 33
}

# Call the command defined in the previous example in various ways.
namespace import bar::cook
cook

# Direct call
foo::grill

# Import into current namespace, then call local alias
namespace import foo::grill
grill

puts "Time is $foo::time -- global is $foo::_g(0) -- jimmy is $foo::jimmy"
return 0


