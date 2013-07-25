proc ArgsProcess {command defaultList__ argList__ resultArray__} {
    upvar $defaultList__ defaultList
    upvar $argList__     argList
    upvar $resultArray__ resultArray

    puts "% DEBUG $command $argList"

    # set defaults first
    foreach d $defaultList {
	set name [lindex $d 0]
	set val  [lindex $d 1]
	# puts "% DEBUG defaults: setting resultArray($name) to $val"
	set resultArray($name) $val
    }

    foreach a $argList {
	# puts "% DEBUG arg: ($a)"
	set name  [lindex $a 0]
	set val   [lrange $a 1 end]
	if {[array names resultArray $name] == ""} {
	    puts stderr "Invalid argument name: -$name"
	    ArgsUsage $command {} $defaultList
	}
	# puts "% DEBUG overrides: setting resultArray($name) to $val"
	set resultArray($name) $val
    }
}

proc ArgsProcess2 {command defaultList__ argList__ resultArray__} {
    upvar $defaultList__ defaultList
    upvar $argList__     argList
    upvar $resultArray__ resultArray

    puts "% DEBUG $command $argList"

    # set defaults first
    foreach d $defaultList {
	set name [lindex $d 0]
	set val  [lindex $d 1]
	set resultArray($name) $val
    }

    foreach a $argList {
	set s [split $a ":"]
	set name  [lindex $s 0]
	set val   [lrange $s 1 end]
	if {[array names resultArray $name] == ""} {
	    puts stderr "Invalid argument name: -$name"
	    ArgsUsage $command {} $defaultList
	}
	set resultArray($name) $val
    }
}

