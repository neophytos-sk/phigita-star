# tcl

# where all table info is stored (amazingly)
variable _table

proc tableExists {tablename} {
    variable _table
    if {[info exists _table(inuse,$tablename)]} {
	AssertEqual $_table(inuse,$tablename) 1
	return 1
    }
    return 0
}

proc tableAllocate {tablename} {
    variable _table
    if {[info exists _table(inuse,$tablename)]} {
	Abort "Table $tablename is already in use"
    }
    set _table(inuse,$tablename) 1
    # allocate some other stuff about table?
}

proc tableGetNextNumber {} {
    variable _table
    if {[info exists _table(uniquenumber)]} {
	set s $_table(uniquenumber)
	incr _table(uniquenumber)
	return $s
    } else {
	set _table(uniquenumber) 1
	return 0
    }
}

# XXX: this is really poorly done right now (esp. w/ large numbers of columns)
proc tableIsColumnValid {table column} {
    # XXX 
    variable _table
    for {set c 0} {$c < $_table($table,columns)} {incr c} {
	if {[StringEqual $_table($table,columnname,$c) $column]} {
	    return 1
	}
    }
    return 0
}

proc Table {args} {
    variable _table
    set default {
	{"table"    "default"  "name to call table"}
	{"columns"  "x,y"      "columns in this table"}
    }
    ArgsProcessWithDashArgs Table default args use \
	"Create an empty table."

    tableAllocate $use(table)

    set count [ArgsParseNumbers $use(columns) columns]
    set _table($use(table),columns) $count

    for {set c 0} {$c < $_table($use(table),columns)} {incr c} {
	set _table($use(table),columnname,$c) $columns($c)
    }
    set _table($use(table),rows) 0
}

proc TableAddVal {table valueList} {
    variable _table
    set count [ArgsParseNumbersList $valueList values]
    AssertEqual $count $_table($table,columns)
    set row $_table($table,rows)
    for {set c 0} {$c < $count} {incr c} {
	set column $values($c,n1)
	set value  $values($c,n2)
	# puts stderr "table $table :: addval inserting '$value' into column '$column'"
	# insert into table
	AssertEqual [tableIsColumnValid $table $column] 1
	set _table($table,$column,$row) $value
    }
    incr _table($table,rows)
}

# XXX -- this can be made more useful
proc TableDump {table} {
    variable _table
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

proc TableSelect2 {args} {
    variable _table
    set default {
	{"from"     "table1" "select values from this table"}
	{"to"       "table2" "put results into this table"}
	{"where"    "x > 3"  "selection criteria in 'from' table"}
	{"fcolumns" "x,y"    "columns to include from 'from' table"}
	{"tcolumns" "x,y"    "columns to insert into in the 'to' table"}
    }
    ArgsProcessWithDashArgs TableSelect2 default args use \
	"Use this to select values from a table and put the results in a different table."

    set fcnt [ArgsParseNumbers $use(fcolumns) fcolumns]
    set tcnt [ArgsParseNumbers $use(tcolumns) tcolumns]
    AssertEqual $fcnt $tcnt

    for {set r 0} {$r < [TableGetNumRows $use(from)]} {incr r} {
	for {set i 0} {$i < $fcnt} {incr i} {
	    set $fcolumns($i) [TableGetVal $use(from) $fcolumns($i) $r]
	}
	if { [eval $use(where)] } { 
	    set str "$tcolumns(0),$fcolumns(0)"
	    for {set i 1} {$i < $tcnt} {incr i} {
		set str "$str:$tcolumns($i),$fcolumns($i)"
	    }
	    TableAddVal $use(to) $str
	}
    }
}

proc TableSelect {args} {
    variable _table
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

    set s [tableGetNextNumber]
    set fd [open /tmp/select w]
    puts $fd "proc Select_$s \{from to\} \{"
    puts $fd "    for \{set r 0\} \{\$r < \[TableGetNumRows \$from]\} \{incr r\} \{ "
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
    variable _table
    set default {
	{"from"    "table1"   "source table for projection"}
	{"to"      "table2"   "destination table for projection"}
    }
    XXX
}

proc TableGetMax {args} {
    variable _table
    set default {
	{"table"  "default"         "table (can be a comma/space separated list"}
	{"column" "x"               "column to get max over (also can be a list)"}
    }
    ArgsProcessWithDashArgs TableGetMax default args use \
	"Use this to get the max value of a particular column of a table."

    set cnt  [ArgsParseNumbers $use(table) table]
    AssertGreaterThan $cnt 0
    set cnt2 [ArgsParseNumbers $use(column) column]
    AssertEqual $cnt2 $cnt

    for {set c 0} {$c < $cnt} {incr c} {
	AssertEqual [tableExists $table($c)] 1
    }

    # get first value in table
    set max $_table($table(0),$column(0),0)
    for {set c 0} {$c < $cnt} {incr c} {
	for {set r 0} {$r < $_table($table($c),rows)} {incr r} {
	    set val $_table($table($c),$column($c),$r)
	    if {$val > $max} {
		set max $val
	    }
	}
    }
    return $max
}

proc TableGetMin {args} {
    variable _table
    set default {
	{"table"  "default"         "table (can be a comma/space separated list"}
	{"column" "x"               "column to get min over (also can be a list)"}
    }
    ArgsProcessWithDashArgs TableGetMin default args use \
	"Use this to get the min value of a particular column of a table."

    set cnt  [ArgsParseNumbers $use(table) table]
    AssertGreaterThan $cnt 0
    set cnt2 [ArgsParseNumbers $use(column) column]
    AssertEqual $cnt2 $cnt

    for {set c 0} {$c < $cnt} {incr c} {
	AssertEqual [tableExists $table($c)] 1
    }

    # get first value in table
    set min $_table($table(0),$column(0),0)
    for {set c 0} {$c < $cnt} {incr c} {
	# ok, ok, so we check one extra value ...
	for {set r 0} {$r < $_table($table($c),rows)} {incr r} {
	    set val $_table($table($c),$column($c),$r)
	    if {$val < $min} {
		set min $val
	    }
	}
    }
    return $min
}

proc TableGetRange {args} {
    variable _table
    set default {
	{"table"  "default"         "table"}
	{"column" "x"               "column to get min/max over"}
    }
    ArgsProcessWithDashArgs TableGetRange default args use \
	"Use this to get the min/max value of a particular column of a table. Returned as 'x,y' pair"

    set min [TableGetMin -table $use(table) -column $use(column)]
    set max [TableGetMax -table $use(table) -column $use(column)]
    return "$min,$max"
}


proc TableStore {args} {
    variable _table
    set default {
	{"file"   "/no/such/file"   "file to read from"}
	{"table"  "default"         "name to call table"}
    }
    ArgsProcessWithDashArgs TableStore default args use \
	"Use this routine to store the contents of a table to a file."

    AssertEqual [tableExists $use(table)] 1
    set fd [open $use(file) "w"]

    # make header first
    puts -nonewline $fd "\# "
    for {set c 0} {$c < $_table($use(table),columns)} {incr c} {
	puts -nonewline $fd "$_table($use(table),columnname,$c) "
    }
    puts $fd ""

    # now, fill in data
    for {set r 0} {$r < $_table($use(table),rows)} {incr r} {
	for {set c 0} {$c < $_table($use(table),columns)} {incr c} {
	    set colname $_table($use(table),columnname,$c)
	    puts -nonewline $fd "$_table($use(table),$colname,$r) "
	}
	puts $fd ""
    }

    # all done
    close $fd
}

proc TableLoad {args} {
    variable _table
    set default {
	{"file"   "/no/such/file"   "file to read from"}
	{"table"  "default"         "name to call table"}
    }
    ArgsProcessWithDashArgs TableLoad default args use \
	"Use this routine to create and fill a table with values from a file."

    set t1 [clock clicks -milliseconds]

    # get data
    set fd [open $use(file) r]

    # table name is ...
    set tablename $use(table)
    tableAllocate $tablename

    # get first line
    #   should have the format: "# col1_name col2_name ... colN_name"
    #   thus, N columns, each with a name, and the leading pound
    gets $fd schema
    if {[string index $schema 0] == "\#"} {
	set _table($tablename,columns) [expr [llength $schema] - 1]
	for {set c 1} {$c <= $_table($tablename,columns)} {incr c} {
	    set rc [expr $c - 1]
	    set val [lindex $schema $c]
	    set _table($tablename,columnname,$rc) $val
	}
    } else {
	# just assume a numerical naming for each column
	set _table($tablename,columns) [llength $schema]
	for {set c 0} {$c <= $_table($tablename,columns)} {incr c} {
	    set _table($tablename,columnname,$c) c$c
	}

	# rewind, so that subsequent table load will NOT miss first line of data
	seek $fd 0
    }

    # associated file name for this table
    set _table($tablename,file) $use(file)

    # now, get all the data
    set rows 0
    while {! [eof $fd]} {
	gets $fd line
	# skip blank lines
	if {$line != ""} {
	    # skip comment lines too
	    if {[string index $line 0] != "#"} {
		set len [llength $line]
		if {$len != $_table($tablename,columns)} {
		    Abort "TableLoad:: bad row in $tablename (file: $_table($tablename,file))"
		}

		for {set c 0} {$c < $len} {incr c} {
		    set colname $_table($tablename,columnname,$c)
		    set _table($tablename,$colname,$rows) [lindex $line $c]
		    # XXX: do max, min here?
		}
		incr rows
	    }
	}
    }
    set _table($tablename,rows) $rows
    close $fd

    set t2 [clock clicks -milliseconds]
    Dputs table "Table: Loaded $rows rows in [expr ($t2-$t1)] ms :: [ArgsPrint use]"
}

proc TableColNames {tablename} {
    variable _table
    AssertEqual [tableExists $tablename] 1
    if {$_table($tablename,columns) < 1} {
	return ""
    }
    set nlist [list $_table($tablename,columnname,0)]
    for {set c 1} {$c < $_table($tablename,columns)} {incr c} {
	set nlist "$nlist $_table($tablename,columnname,$c)"
    }
    return $nlist
}

proc TableGetVal {tablename colname row} {
    variable _table
    AssertEqual [tableExists $tablename] 1
    return $_table($tablename,$colname,$row)
}

proc TableGetNumRows {tablename} {
    variable _table
    AssertEqual [tableExists $tablename] 1
    return $_table($tablename,rows)
}

