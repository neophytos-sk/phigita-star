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

proc tableCheckUnique {columns__ count} {
    upvar $columns__ columns

    set cnameList $columns(0)
    for {set c 1} {$c < $count} {incr c} {
	set cnameList "$cnameList $columns($c)"
    }    
    set origLen [llength $cnameList]
    set uniqLen [llength [lsort -uniq $cnameList]]
    if {$uniqLen != $origLen} {
	Abort "Columns must have unique names. You specified '$cnameList', which has duplicates."
    }
}

proc tableFillColsFromTable {table columns__} {
    upvar $columns__ columns
    set cnt 0
    foreach c [TableGetColNames -table $table] {
	set columns($cnt) $c
	incr cnt
    }
    return $cnt
}

# 
# EXTERNAL ROUTINES
# 
proc TableCopy {args} {
    set default {
	{"from"     ""         "copy some columns from this table"}
	{"to"       ""         "copy some columns to this table"}
	{"fcolumns" ""         "copy from these columns"}
	{"tcolumns" ""         "copy to these columns"}
    }
    ArgsProcessWithDashArgs TableCopy default args use \
	"Use this to copy some columns from one table to the other. Will overwrite the existing contents of the destination table. Assumes the columns already exist in the destination."
    
    AssertNotEqual $use(from) ""
    AssertNotEqual $use(to) ""

    set fcount [ArgsParseCommaList $use(fcolumns) fcolumns]
    set tcount [ArgsParseCommaList $use(tcolumns) tcolumns]
    AssertEqual $fcount $tcount

    for {set r 0} {$r < [TableGetNumRows -table $use(from)]} {incr r} {
	# XXX NOT IMPLEMENTED YET, NOT SURE WHETHER TO ASSUME A PREALLOCATED TABLE, ETC.
    }
}

proc TableAddRow {args} {
    set default {
	{"table"      "default"       "table to add row to"}
	{"data"       ""              "list of 'column name, value' pairs, separated by colons, to add to the table"}
    }
    ArgsProcessWithDashArgs TableAddRow default args use \
	"Use this to add a new row of data to a table. For example, if a table has columns x and y, and you wish to add an entry with x = 3 and y = 100, you would call 'TableAddRow -table whatever -data x,3:y,100' and the magic would be done. Note: you have to fill in ALL the column values. Also note: there is NOT a ton of error checking done here, so you can probably mess things up if you like."

    variable _table
    set count [ArgsParseItemPairList $use(data) values]
    AssertEqual $count $_table($use(table),columns)
    set row $_table($use(table),rows)
    for {set c 0} {$c < $count} {incr c} {
	set column $values($c,n1)
	set value  $values($c,n2)
	# insert into table
	# AssertEqual [tableIsColumnValid $table $column] 1
	set _table($use(table),$column,$row) $value
    }
    incr _table($use(table),rows)
}

# XXX -- this can be made more useful
proc TableDump {args} {
    set default {
	{"table"      "default"   "which table to get data from"}
	{"fd"         "stderr"    "which descriptor to print to"}
    }
    ArgsProcessWithDashArgs TableDump default args use \
	"Use this to print out the contents of the table to a descriptor: default is stderr"

    variable _table
    puts $use(fd) "Dumping Table $use(table) ::"
    for {set r 0} {$r < $_table($use(table),rows)} {incr r} {
	puts -nonewline $use(fd) "  Row $r :: "
	for {set c 0} {$c < $_table($use(table),columns)} {incr c} {
	    set colname $_table($use(table),columnname,$c)
	    puts -nonewline $use(fd) "($colname: $_table($use(table),$colname,$r)) "
	}
	puts $use(fd) ""
    }
}

proc TableSelect2 {args} {
    set default {
	{"from"     "table1" "select values from this table"}
	{"to"       "table2" "put results into this table"}
	{"where"    "x > 3"  "selection criteria in 'from' table"}
	{"fcolumns" "x,y"    "columns to include from 'from' table"}
	{"tcolumns" "x,y"    "columns to insert into in the 'to' table"}
    }
    ArgsProcessWithDashArgs TableSelect2 default args use \
	"Use this to select values from a table and put the results in a different table."

    set fcnt [ArgsParseCommaList $use(fcolumns) fcolumns]
    set tcnt [ArgsParseCommaList $use(tcolumns) tcolumns]
    AssertEqual $fcnt $tcnt

    for {set r 0} {$r < [TableGetNumRows -table $use(from)]} {incr r} {
	for {set i 0} {$i < $fcnt} {incr i} {
	    set $fcolumns($i) [__TableGetVal $use(from) $fcolumns($i) $r]
	}
	if { [eval $use(where)] } { 
	    set str "$tcolumns(0),$fcolumns(0)"
	    for {set i 1} {$i < $tcnt} {incr i} {
		set str "$str:$tcolumns($i),$fcolumns($i)"
	    }
	    TableAddRow -table $use(to) -data $str
	}
    }
}

proc TableMath {args} {
    set default {
	{"table"       "default"             "table which we are doing column math upon"}
	{"expression"  "$x+$y"               "math expression to apply to each row of table"}
	{"destcol"     "x"                   "destination column for expression"}
    }
    ArgsProcessWithDashArgs TableMath default args use \
	"Use this to perform math on each row of a table. Specifically, specifying something like -expression {x + y} with '-destcol x' means for each row, take the values of x and y, add them together, and put the result back in column x. "
    AssertNotEqual $use(expression) ""

    set colnames [TableGetColNames -table $use(table)]
    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	# get all the values (XXX - inefficient)
	foreach col $colnames {
	    set val [__TableGetVal $use(table) $col $r]
	    set $col $val
	}

	# do expression
	set val [eval "expr $use(expression)"]
	# puts stderr "setting '$use(destcol)' to expression '$use(expression)' which evals to $val"
	
	# now set value
	__TableSetVal $use(table) $use(destcol) $r $val
    }
    
}

# BUG or FEATURE?: ORDER of column names matters
# select -fcolumns x,y -tcolumns y,x will switch the two ...
proc TableSelect {args} {
    set default {
	{"from"     "table1" "select values from this table"}
	{"to"       "table2" "put results into this table"}
	{"where"    "x > 3"  "selection criteria in 'from' table"}
	{"fcolumns" ""       "comma-separated list of columns to include from 'from' table; empty implies all columns"}
	{"tcolumns" ""       "comma-separated list of columns to insert into in the 'to' table; empty implies all columns"}
    }
    ArgsProcessWithDashArgs TableSelect default args use \
	"Use this to select values from a table and put the results in a different table."

    set t1 [clock clicks -milliseconds]

    # if column list is empty, use ALL columns from specified table
    if {$use(fcolumns) != ""} {
	set fcnt [ArgsParseCommaList $use(fcolumns) fcolumns]
    } else {
	set fcnt [tableFillColsFromTable $use(from) fcolumns]
    }
    if {$use(tcolumns) != ""} {
	set tcnt [ArgsParseCommaList $use(tcolumns) tcolumns]
    } else {
	set tcnt [tableFillColsFromTable $use(to) tcolumns]
    }
    AssertEqual $fcnt $tcnt

    set s [tableGetNextNumber]
    set fd [open /tmp/select w]
    puts $fd "proc Select_$s \{from to\} \{"
    puts $fd "    for \{set r 0\} \{\$r < \[TableGetNumRows -table \$from]\} \{incr r\} \{ "
    for {set i 0} {$i < $fcnt} {incr i} {
	puts $fd "        set $fcolumns($i) \[__TableGetVal \$from $fcolumns($i) \$r] "
    }
    puts $fd "        if \{ $use(where) \} \{ "
    # assemble addval string
    set str "$tcolumns(0),\$$fcolumns(0)"
    for {set i 1} {$i < $tcnt} {incr i} {
	set str "$str:$tcolumns($i),\$$fcolumns($i)"
    }
    puts $fd "            TableAddRow -table \$to -data $str"
    puts $fd "        \}"
    puts $fd "    \}"
    puts $fd "\}"
    close $fd

    # now source the file and call the routine
    source /tmp/select
    Select_$s $use(from) $use(to)
    exec /bin/rm -f /tmp/select >@stdout 2>@stderr

    set t2 [clock clicks -milliseconds]
    Dputs table "Table: Select ran in [expr ($t2-$t1)] ms :: [ArgsPrint use]"
} 

proc TableProject {args} {
    set default {
	{"from"    "table1"   "source table for projection"}
	{"to"      "table2"   "destination table for projection"}
    }
    # XXX
    # this should make a new table with fewer columns than the first (a subset, or 'projection')
}

proc TableGetMax {args} {
    variable _table
    set default {
	{"table"  "default"         "table (can be a comma/space separated list"}
	{"column" "x"               "column to get max over (also can be a list)"}
    }
    ArgsProcessWithDashArgs TableGetMax default args use \
	"Use this to get the max value of a particular column of a table."

    set cnt  [ArgsParseCommaList $use(table) table]
    AssertGreaterThan $cnt 0
    set cnt2 [ArgsParseCommaList $use(column) column]
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
    set default {
	{"table"  "default"         "table (can be a comma/space separated list"}
	{"column" "x"               "column to get min over (also can be a list)"}
    }
    ArgsProcessWithDashArgs TableGetMin default args use \
	"Use this to get the min value of a particular column of a table."

    variable _table
    set cnt  [ArgsParseCommaList $use(table) table]
    AssertGreaterThan $cnt 0
    set cnt2 [ArgsParseCommaList $use(column) column]
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
    set default {
	{"table"  "default"         "table"}
	{"column" "x"               "column to get min/max over"}
	{"border" "0"               "how much to subtract/add to min/max of range"}
    }
    ArgsProcessWithDashArgs TableGetRange default args use \
	"Use this to get the min/max value of a particular column of a table. Returned as 'x,y' pair"

    set min [TableGetMin -table $use(table) -column $use(column)]
    set max [TableGetMax -table $use(table) -column $use(column)]
    Dputs table "TableGetRange: $min,$max"
    return "[expr $min-$use(border)],[expr $max+$use(border)]"
}


proc TableStore {args} {
    set default {
	{"table"  "default"         "name to call table"}
	{"file"   "/no/such/file"   "file to read from"}
    }
    ArgsProcessWithDashArgs TableStore default args use \
	"Use this routine to store the contents of a table to a file."

    variable _table
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

proc Table {args} {
    set default {
	{"table"     "default"  "name to call table"}
	{"file"      ""         "file to read from"}
	{"columns"   ""         "if a new table, specify the columns in this table"}
	{"separator" ""         "if empty, whitespace; otherwise, whatever you specify, e.g., a colon"}
    }
    ArgsProcessWithDashArgs Table default args use \
	"Create a table. If '-file' is specified, load the table from a file. Otherwise, '-columns' must be specified and give a comma-separated list of columns in the table (e.g., '-columns x,y,mean'). "

    variable _table
    if {$use(file) == ""} {
	# creating a new empty table, don't load from a file
	tableAllocate $use(table)
	set count [ArgsParseCommaList $use(columns) columns]
	set _table($use(table),columns) $count
	tableCheckUnique columns $count
	for {set c 0} {$c < $count} {incr c} {
	    set _table($use(table),columnname,$c) $columns($c)
	}
	set _table($use(table),rows) 0
	# all done, just return
	return
    } 

    # puts "creating table: '$use(table)'"

    # the rest of this assumes the table is being loaded from a file...
    if {$use(columns) != ""} {
	Abort "Can't specify both -file and -columns; must pick one or the other"
    }
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
	set schema [string range $schema 1 end]
	if {$use(separator) != ""} {
	    set schema [split $schema $use(separator)]
	}
	set _table($tablename,columns) [llength $schema]
	for {set c 0} {$c < $_table($tablename,columns)} {incr c} {
	    set val [lindex $schema $c]
	    set _table($tablename,columnname,$c) [string trim $val]
	}
    } else {
	# just assume a numerical naming for each column (c0, c1, etc.)
	# note: now 'schema' is just the first line of data
	if {$use(separator) != ""} {
	    set schema [split $schema $use(separator)]
	}
	set _table($tablename,columns) [llength $schema]
	for {set c 0} {$c < $_table($tablename,columns)} {incr c} {
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
		if {$use(separator) != ""} {
		    set line [split $line $use(separator)]
		}
		set len [llength $line]
		if {$len != $_table($tablename,columns)} {
		    Abort "Table:: bad row in $tablename (len:$len  cols:$_table($tablename,columns)) (file: $_table($tablename,file))"
		}

		# go over the columns, insert each entry into the table
		for {set c 0} {$c < $len} {incr c} {
		    set colname $_table($tablename,columnname,$c)
		    set _table($tablename,$colname,$rows) [string trim [lindex $line $c]]
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


proc TableGetColNames {args} {
    set default {
	{"table"        "default"  "which table to get names from"}
	{"separator"    " "        "what to use to separate list of names that is returned"}
    }
    ArgsProcessWithDashArgs TableGetColNames default args use \
	"Use this routine to get the names of each column of the specified table"

    variable _table
    AssertEqual [tableExists $use(table)] 1
    if {$_table($use(table),columns) < 1} {
	return ""
    }
    set nlist [list $_table($use(table),columnname,0)]
    for {set c 1} {$c < $_table($use(table),columns)} {incr c} {
	set nlist "$nlist$use(separator)$_table($use(table),columnname,$c)"
    }
    return $nlist
}

proc TableGetNumRows {args} {
    set default {
	{"table"        "default"    "which table to get names from"}
    }
    ArgsProcessWithDashArgs TableGetNumRows default args use \
	"Use this routine to get the number of rows in a table"

    variable _table
    AssertEqual [tableExists $use(table)] 1
    return $_table($use(table),rows)
}

proc TableBucketize {args} {
    set default {
	{"from"         ""         "table to get raw data from"}
	{"fcolumns"     "x,y"      "columns to get data from"}
	{"to"           ""         "table to put data into"}
	{"tcolumns"     "x,y,heat" "columns to put data into"}
	{"xbucketsize"  "1.0"      "size of each bucket for first fcolumn (x)"}
	{"ybucketsize"  "1.0"      "size of each bucket for second fcolumn (x)"}
    }
    ArgsProcessWithDashArgs TableBucketize default args use \
	"Use this to turn a table with x,y data into a bucketized table with x,y,frequency counts. The bigger you make the buckets, the higher the counts will (likely) be."

    set t1 [clock clicks -milliseconds]

    set fcnt [ArgsParseCommaList $use(fcolumns) fcol]
    AssertEqual $fcnt 2
    set tcnt [ArgsParseCommaList $use(tcolumns) tcol]
    AssertEqual $tcnt 3

    AssertNotEqual $use(from) ""
    AssertNotEqual $use(to)   ""

    set rows [TableGetNumRows -table $use(from)]
    for {set r 0} {$r < $rows} {incr r} {
	set x [__TableGetVal $use(from) $fcol(0) $r]
	set y [__TableGetVal $use(from) $fcol(1) $r]
	set bx [expr int($x / $use(xbucketsize))]
	set by [expr int($y / $use(ybucketsize))]
	if {[info exists data($bx,$by)] == 0} {
	    set data($bx,$by) 1
	} else {
	    incr data($bx,$by)
	}
    }

    foreach index [array names data] {
	set vals [split $index ","]
	set x [lindex $vals 0]
	set y [lindex $vals 1]
	TableAddRow -table $use(to) -data "$tcol(0),$x : $tcol(1),$y : $tcol(2),$data($x,$y)"
    }

    set t2 [clock clicks -milliseconds]
    Dputs table "Table: Bucketized $rows rows in [expr ($t2-$t1)] ms :: [ArgsPrint use]"
}

proc TableAddColumns {args} {
    set default {
	{"table"         "default"         "name of table we are adding columns to"}
	{"columns"       "x"               "column list to add to table"}
	{"value"         "0"               "default value of each added entry"}
    }
    ArgsProcessWithDashArgs TableAddColumns default args use \
	"Use this to add one or more columns to an existing table. If adding more than one, specify using either a space-separated  (\"f g\") or comma-separated list. The 'value' flag is used to initialize each entry."
    AssertEqual [tableExists $use(table)] 1

    set count [ArgsParseCommaList $use(columns) columns]
    AssertGreaterThan $count 0

    # inc column count
    variable _table
    set curr $_table($use(table),columns)
    set _table($use(table),columns) [expr $curr + $count]

    for {set c 0} {$c < $count} {incr c} {
	set _table($use(table),columnname,$curr) $columns($c)
	incr curr
    }
    AssertEqual $curr $_table($use(table),columns)
    # check for duplicate column names
    for {set i 0} {$i < $curr} {incr i} {
	set tmp($i) $_table($use(table),columnname,$i)
    }
    tableCheckUnique tmp $curr

    # init values
    for {set r 0} {$r < $_table($use(table),rows)} {incr r} {
	for {set c 0} {$c < $count} {incr c} {
	    set column $columns($c)
	    set _table($use(table),$column,$r) $use(value)
	}
    }
}


proc TableMakeAxisLabels {args} {
    set default {
	{"table"      "default"         "table to get data from"}
	{"name"       ""                "column to get name data from"}
	{"number"     ""                "column to get numeric data from"}
    }
    ArgsProcessWithDashArgs TableMakeAxisLabels default args use \
	"Use this to pass in two columns -name and -number and get back something to pass to the axis generator to label the columns, with a 'name' appearing at each spot that 'number' specifies."

    set ulist ""
    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set number [__TableGetVal $use(table) $use(number) $r]
	set name   [__TableGetVal $use(table) $use(name) $r]
	if {$ulist == ""} {
	    set ulist "$number,$name"
	} else {
	    set ulist "${ulist}:$number,$name"
	}
    }    
    return $ulist
}

proc TableMap {args} {
    set default {
	{"table"      "default"         "table to get data from"}
	{"from"       ""                "column to get data from"}
	{"to"         ""                "column to map data into"}
    }
    ArgsProcessWithDashArgs TableMap default args use \
	"Use this to map non-numerical data onto a numerical range."

    # puts "Mapping: '$use(table)'"
    set ucnt 0

    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set value [__TableGetVal $use(table) $use(from) $r]
	set nval  [string map {{ } ___SPACE___} $value]

	if {[info exists ulist($nval)] == 0} {
	    # assign unique value to this named category
	    set ulist($nval) $ucnt
	    incr ucnt
	} 
	# assign the mapping to the destination column 'use(to)'
	__TableSetVal $use(table) $use(to) $r $ulist($nval)
    }
    return $ucnt
}

proc TableGetUniqueValues {args} {
    set default {
	{"table"      "default"         "table to get data from"}
	{"column"     ""                "column to get data from"}
	{"separator"  ","               "what to use to separate the values in the list; comma is default"}
	{"empties"    "0,0"             "how many empty to fields to add to the beginning, end of category"}
	{"number"     ""                "if not empty, name of variable to store the number of unique values in"}
    }
    ArgsProcessWithDashArgs TableGetUniqueValues default args use \
	"Use this to get the unique values found in a column."

    set count [ArgsParseCommaList $use(empties) empties]
    AssertEqual $count 2
    if {$empties(0) > 0} {
	set ulist [drawableGetEmptyMarker]
	for {set i 1} {$i < $empties(0)} {incr i} {
	    set ulist "${ulist}$use(separator)[drawableGetEmptyMarker]"
	}
    } else {    
	set ulist ""
    }

    set ucnt 0
    for {set r 0} {$r < [TableGetNumRows -table $use(table)]} {incr r} {
	set value [__TableGetVal $use(table) $use(column) $r]
	if {$ulist == ""} {
	    set ulist $value
	} else {
	    if {[lsearch -exact $ulist $value] < 0} {
		set ulist "${ulist}$use(separator)$value"
	    } 
	}
	incr ucnt
    }
    if {$empties(1) > 0} {
	for {set i 0} {$i < $empties(1)} {incr i} {
	    set ulist "${ulist}$use(separator)[drawableGetEmptyMarker]"
	}
    } 

    if {$use(number) != ""} {
	upvar $use(number) number
	set number $ucnt
    }
    return $ulist
}




proc TableComputeMeanEtc {args} {
    set default {
	{"from"       ""                "table to get data from"}
	{"to"         ""                "table to put data into"}
	{"fcolumns"   "x,y"             "list of columns to get data from (should be two)"}
	{"tcolumns"   "mean,c0:dev,c1"  "list of (function,column) pairs, e.g., compute the 'mean' over the data and put it into the c0 column, compute the deviation and put it in c1; list of functions to compute over the data are mean,dev,meanminusdev,meanplusdev,var,p5,p95,min,max"}
    }
    ArgsProcessWithDashArgs TableComputeMeanEtc default args use \
	"Use this to compute a bunch of numerical values over data. Data should be in x,y format, and each x=c value should have multiple y values in the table (e.g., the data might contain (1,2), (1,3) (1,4) and (2,2) (2,4) (2,6). What the function then does is compute a bunch of functions (as you specify) and put them into the columns of the -to table, also as specified. For example, if you specify '-tcolumns mean,c0', TableComputeMeanEtc would compute the mean of the data and put it into column c0. From the data above, c0 would end up with (1,3) and (2,4) in it (i.e., the mean is computed per unique x-value). Many possible functions are available: mean (the mean), dev (standard deviation), avgminusdev (average minus the deviation), avgplusdev (average plus the deviation), var (the variance), min (the minimum), max (the maximum), and so forth."

    set count [ArgsParseCommaList $use(fcolumns) fcols]
    AssertEqual $count 2

    for {set r 0} {$r < [TableGetNumRows -table $use(from)]} {incr r} {
	set x [__TableGetVal $use(from) $fcols(0) $r]
	set y [__TableGetVal $use(from) $fcols(1) $r]

	# mark that this x-value has been seen
	set values($x) 1

	# compute count and total
	set tmp(count,$x) [expr 1 + [Deref tmp(count,$x) 0.0]]
	set tmp(total,$x) [expr $y + [Deref tmp(total,$x) 0.0]]
	# min, max too
	if {$y < [Deref tmp(min,$x) $y]} {
	    set tmp(min,$x) $y
	}
	if {$y > [Deref tmp(max,$x) $y]} {
	    set tmp(max,$x) $y
	}
    }

    # calculate mean
    foreach x [lsort -increasing [array names values -glob *]] {
	set tmp(mean,$x) [expr double($tmp(total,$x)) / double($tmp(count,$x))]
    }

    # now, sum up the variance 
    for {set r 0} {$r < [TableGetNumRows -table $use(from)]} {incr r} {
	set x [__TableGetVal $use(from) $fcols(0) $r]
	set y [__TableGetVal $use(from) $fcols(1) $r]
    
	# compute sum of variances
	set diff [expr $y-$tmp(mean,$x)]
	set tmp(varsum,$x) [expr ($diff*$diff) + [Deref tmp(varsum,$x) 0.0]]
    }

    # now compute variances, deviations, 95/5% confidences
    foreach x [lsort -increasing [array names values -glob *]] {
	set tmp(var,$x) [expr $tmp(varsum,$x) / ($tmp(count,$x) - 1)]
	set tmp(dev,$x) [expr sqrt($tmp(var,$x))]
	set tmp(meanminusdev,$x) [expr $tmp(mean,$x) - $tmp(dev,$x)]
	set tmp(meanplusdev,$x) [expr $tmp(mean,$x) + $tmp(dev,$x)]
	set tmp(p5,$x) [expr $tmp(mean,$x) - (2.0*$tmp(dev,$x))]
	set tmp(p95,$x) [expr $tmp(mean,$x) + (2.0*$tmp(dev,$x))]
    }

    # put together list of what will be added
    set count [ArgsParseItemPairList $use(tcolumns) tcols]
    AssertGreaterThan $count 0

    # finally, insert it all into a table
    foreach x [lsort -increasing [array names values -glob *]] {
	# make the list of things AddRow must do
	set tlist "x,$x"
	for {set i 0} {$i < $count} {incr i} {
	    set tlist "$tlist : $tcols($i,n2),$tmp($tcols($i,n1),$x)"
	}
	# puts stderr "The list: $tlist"
	TableAddRow -table $use(to) -data $tlist
    }
}

# these routine are different: they generally should not be used
# particularly: they do NOT do the usual arg processing, rather they take direct args
# XXX - should probably check legality of column
#       and of row number, but oh well
proc __TableGetVal {tablename colname row} {
    variable _table
    if [StringEqual $colname "rownumber"] {
	return $row
    }
    return $_table($tablename,$colname,$row)
}

proc __TableSetVal {tablename colname row val} {
    variable _table
    AssertEqual [tableExists $tablename] 1
    set _table($tablename,$colname,$row) $val
}

