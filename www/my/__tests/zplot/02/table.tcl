# tcl

proc allocate {tablename} {
    global _table
    if {[info exists _table(inuse,$tablename)]} {
	Abort "Table $tablename is already in use"
    }
    set _table(inuse,$tablename) 1
}

proc getnextnumber {} {
    global _table
    if {[info exists _table(uniquenumber)]} {
	set s $_table(uniquenumber)
	incr _table(uniquenumber)
	return $s
    } else {
	set _table(uniquenumber) 1
	return 0
    }
}

# this is really poorly done right now (esp. w/ large numbers of columns)
proc checkvalid {table column} {
    # XXX 
    global _table
    for {set c 0} {$c < $_table($table,columns)} {incr c} {
	if {[StringEq $_table($table,columnname,$c) $column]} {
	    return 1
	}
    }
    return 0
}

proc Table {args} {
    global _table
    set default {
	{"table"    "default"  "name to call table"}
	{"columns"  "x,y"      "columns in this table"}
    }
    ArgsProcessWithDashArgs Table default args use \
	"Create an empty table."

    allocate $use(table)

    set count [ArgsParseNumbers $use(columns) columns]
    set _table($use(table),columns) $count

    for {set c 0} {$c < $_table($use(table),columns)} {incr c} {
	set _table($use(table),columnname,$c) $columns($c)
    }
    set _table($use(table),rows) 0
}

proc TableAddVal {table valueList} {
    global _table
    set count [ArgsParseNumbersList $valueList values]
    AssertEqual $count $_table($table,columns)
    set row $_table($table,rows)
    for {set c 0} {$c < $count} {incr c} {
	set column $values($c,n1)
	set value  $values($c,n2)
	# puts stderr "$c: inserting into column '$column' the value '$value'"

	# insert into table
	checkvalid $table $column
	set _table($table,$column,$row) $value
    }
    incr _table($table,rows)
}

# XXX -- this can be made more useful
proc TableDump {table} {
    global _table
    puts stderr "Dumping Table $table ::"
    for {set r 0} {$r < $_table($table,rows)} {incr r} {
	puts -nonewline stderr "  Row $r :: "
	for {set c 0} {$c < $_table($table,columns)} {incr c} {
	    set colname $_table($table,columnname,$c)
	    puts -nonewline stderr "($colname: $_table($table,$colname,$r)) "
	}
	puts stderr ""
    }
}

proc TableSelect {args} {
    global _table
    set default {
	{"from"     "table1" "select values from this table"}
	{"to"       "table2" "put results into this table"}
	{"where"    "x > 3"  "selection criteria in 'from' table"}
	{"fcolumns" "x,y"    "columns to include from 'from' table"}
	{"tcolumns" "x,y"    "columns to insert into in the 'to' table"}
    }
    ArgsProcessWithDashArgs TableSelect default args use \
	"Use this to select values from a table and put the results in a different table."

    set fcnt [ArgsParseNumbers $use(fcolumns) fcolumns]
    set tcnt [ArgsParseNumbers $use(tcolumns) tcolumns]
    AssertEqual $fcnt $tcnt

    set s [getnextnumber]
    set fd [open /tmp/select w]
    puts $fd "proc Select_$s \{from to\} \{"
    puts $fd "    for \{set r 0\} \{\$r < \[TableGetRows \$from]\} \{incr r\} \{ "
    for {set i 0} {$i < $fcnt} {incr i} {
	puts $fd "        set $fcolumns($i) \[TableGetVal \$from $fcolumns($i) \$r] "
    }
    puts $fd "        if \{ $use(where) \} \{ "
    # assemble addval string
    set str "$tcolumns(0),\$$fcolumns(0)"
    for {set i 1} {$i < $tcnt} {incr i} {
	set str "$str:$tcolumns($i),\$$fcolumns($i)"
    }
    puts $fd "            TableAddVal \$to $str"
    puts $fd "        \}"
    puts $fd "    \}"
    puts $fd "\}"
    close $fd

    # now source the file and call the routine
    source /tmp/select
    Select_$s $use(from) $use(to)
} 



proc TableProject {args} {
    global _table
    set default {
	{"from"    "table1"   "source table for projection"}
	{"to"      "table2"   "destination table for projection"}
    }
    XXX
}



proc TableLoad {args} {
    global _table
    set default {
	{"file"   "/no/such/file"   "file to read from"}
	{"table"  "default"         "name to call table"}
    }
    ArgsProcessWithDashArgs TableLoad default args use \
	"Use this routine to create and fill a table with values from a file."

    # get data
    set fd [open $use(file) r]

    # table name is ...
    set tablename $use(table)
    allocate $tablename

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

