# tcl

#
# NEED: file managment infrastructure
#
proc TableRead {args} {
    global _table
    set default {
	"file"   "/no/such/file"   "file to read from"
	"table"  "default"         "name to call table"
    }
    ArgsProcessWithDashArgs TableRead default args use

    # get data
    set fd [open $use(file) r]

    # table name is ...
    set tablename $use(table)

    # get first line
    #   should have the format: "# col1_name col2_name ... colN_name"
    #   thus, N columns, each with a name, and the leading pound
    gets $fd schema
    set _table($tablename,file)    $use(file)
    set _table($tablename,columns) [expr [llength $schema] - 1]
    for {set c 1} {$c <= $_table($tablename,columns)} {incr c} {
	set rc [expr $c - 1]
	set val [lindex $schema $c]
	set _table($tablename,columnname,$rc) $val
    }

    set rows 0
    while {! [eof $fd]} {
	gets $fd line
	if {$line != ""} {
	    if {[string index $line 0] != "#"} {
		set len [llength $line]
		if {$len != $_table($tablename,columns)} {
		    puts stderr "bad data:$tablename (file: $_table($tablename,file)"
		    exit 1
		}

		for {set c 0} {$c < $len} {incr c} {
		    set colname $_table($tablename,columnname,$c)
		    set _table($tablename,$colname,$rows) [lindex $line $c]
		}
		incr rows
	    }
	}
    }
    set _table($tablename,rows) $rows
    close $fd
}

proc TableColNames {tablename} {
    global _table
    if {$_table($tablename,columns) < 1} {
	return ""
    }
    set nlist [list $_table($tablename,columnname,0)]
    for {set c 1} {$c < $_table($tablename,columns)} {incr c} {
	set nlist "$nlist $_table($tablename,columnname,$c)"
    }
    return $nlist
}

proc TableGetVal {table colname row} {
    global _table
    return $_table($table,$colname,$row)
}

proc TableGetRows {table} {
    global _table
    return $_table($table,rows)
}