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

    set fcount [ArgsParseNumbers $use(fcolumns) fcolumns]
    set tcount [ArgsParseNumbers $use(tcolumns) tcolumns]
    AssertEqual $fcount $tcount

    for {set r 0} {$r < [TableGetNumRows $use(from)]} {incr r} {
	XXX
    }
}

proc TableAddRow {table valueList} {
    variable _table
    set count [ArgsParseNumbersList $valueList values]
    AssertEqual $count $_table($table,columns)
    set row $_table($table,rows)
    for {set c 0} {$c < $count} {incr c} {
	set column $values($c,n1)
	set value  $values($c,n2)
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
	    TableAddRow $use(to) $str
	}
    }
}

proc TableMath {args} {
    set default {
	{"table"       "default"             "table which we are doing column math upon"}
	{"expression"  "$x+$y"               "math expression to apply to each row of table"}
	{"destcol"     "x"                   "destination column for expression"}
    }
    ArgsProcessWithDashArgs TableColumnMath default args use \
	"Use this to perform math on each row of a table."
    AssertNotEqual $use(expression) ""

    set colnames [TableColNames $use(table)]
    for {set r 0} {$r < [TableGetNumRows $use(table)]} {incr r} {
	# get all the values (XXX - inefficient)
	foreach col $colnames {
	    set val [TableGetVal $use(table) $col $r]
	    # puts stderr "setting $col to $val"
	    set $col $val
	}

	# do expression
	set val [eval "expr $use(expression)"]
	# puts stderr "setting '$use(destcol)' to expression '$use(expression)' which evals to $val"
	
	# now set value
	TableSetVal $use(table) $use(destcol) $r $val
    }
    
}


proc TableSelect {args} {
    set default {
	{"from"     "table1" "select values from this table"}
	{"to"       "table2" "put results into this table"}
	{"where"    "x > 3"  "selection criteria in 'from' table"}
	{"fcolumns" "x,y"    "columns to include from 'from' table"}
	{"tcolumns" "x,y"    "columns to insert into in the 'to' table"}
    }
    ArgsProcessWithDashArgs TableSelect default args use \
	"Use this to select values from a table and put the results in a different table."

    set t1 [clock clicks -milliseconds]

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
    puts $fd "            TableAddRow \$to $str"
    puts $fd "        \}"
    puts $fd "    \}"
    puts $fd "\}"
    close $fd

    # now source the file and call the routine
    source /tmp/select
    Select_$s $use(from) $use(to)

    set t2 [clock clicks -milliseconds]
    Dputs table "Table: Select ran in [expr ($t2-$t1)] ms :: [ArgsPrint use]"
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
    Dputs table "TableGetRange: $min,$max"
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

proc Table {args} {
    variable _table
    set default {
	{"table"    "default"  "name to call table"}
	{"file"     ""         "file to read from"}
	{"columns"  ""         "if a new table, specify the columns in this table"}
    }
    ArgsProcessWithDashArgs Table default args use \
	"Create a table. If '-file' is specified, load the table from a file. Otherwise, '-columns' must be specified and give a comma-separated list of columns in the table (e.g., '-columns x,y,mean'). "

    if {$use(file) == ""} {
	# creating a new empty table, don't load from a file
	tableAllocate $use(table)
	set count [ArgsParseNumbers $use(columns) columns]
	set _table($use(table),columns) $count
	tableCheckUnique columns $count
	for {set c 0} {$c < $count} {incr c} {
	    set _table($use(table),columnname,$c) $columns($c)
	}
	set _table($use(table),rows) 0
	# all done, just return
	return
    } 

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
		    Abort "Table:: bad row in $tablename (file: $_table($tablename,file))"
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
    # XXX - should probably check legality of column
    #       and of row number, but oh well
    if [StringEqual $colname "rownumber"] {
	return $row
    }
    return $_table($tablename,$colname,$row)
}

proc TableSetVal {tablename colname row val} {
    variable _table
    AssertEqual [tableExists $tablename] 1
    set _table($tablename,$colname,$row) $val
}

proc TableGetNumRows {tablename} {
    variable _table
    AssertEqual [tableExists $tablename] 1
    return $_table($tablename,rows)
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

    set fcnt [ArgsParseNumbers $use(fcolumns) fcol]
    AssertEqual $fcnt 2
    set tcnt [ArgsParseNumbers $use(tcolumns) tcol]
    AssertEqual $tcnt 3

    AssertNotEqual $use(from) ""
    AssertNotEqual $use(to)   ""

    set rows [TableGetNumRows $use(from)]
    for {set r 0} {$r < $rows} {incr r} {
	set x [TableGetVal $use(from) $fcol(0) $r]
	set y [TableGetVal $use(from) $fcol(1) $r]
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
	TableAddRow $use(to) "$tcol(0),$x : $tcol(1),$y : $tcol(2),$data($x,$y)"
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

    set count [ArgsParseNumbers $use(columns) columns]
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


proc TableComputeMeanEtc {args} {
    set default {
	{"from"       ""                "table to get data from"}
	{"to"         ""                "table to put data into"}
	{"fcolumns"   "x,y"             "list of columns to get data from (should be two)"}
	{"tcolumns"   "mean,c0:dev,c1"  "list of (function,column) pairs, e.g., compute the 'mean' over the data and put it into the c0 column, compute the deviation and put it in c1; list of functions to compute over the data are mean,dev,meanminusdev,meanplusdev,var,p5,p95,min,max"}
    }
    ArgsProcessWithDashArgs TableComputeMeanEtc default args use \
	"Use this to compute a bunch of numerical values over data. Data should be in x,y format, and each x=c value should have multiple y values in the table (e.g., the data might contain (1,2), (1,3) (1,4) and (2,2) (2,4) (2,6). What the function then does is compute a bunch of functions (as you specify) and put them into the columns of the -to table, also as specified. For example, if you specify '-tcolumns mean,c0', TableComputeMeanEtc would compute the mean of the data and put it into column c0. From the data above, c0 would end up with (1,3) and (2,4) in it (i.e., the mean is computed per unique x-value). Many possible functions are available: mean (the mean), dev (standard deviation), avgminusdev (average minus the deviation), avgplusdev (average plus the deviation), var (the variance), min (the minimum), max (the maximum), and so forth."

    set count [ArgsParseNumbers $use(fcolumns) fcols]
    AssertEqual $count 2

    for {set r 0} {$r < [TableGetNumRows $use(from)]} {incr r} {
	set x [TableGetVal $use(from) $fcols(0) $r]
	set y [TableGetVal $use(from) $fcols(1) $r]

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
    for {set r 0} {$r < [TableGetNumRows $use(from)]} {incr r} {
	set x [TableGetVal $use(from) $fcols(0) $r]
	set y [TableGetVal $use(from) $fcols(1) $r]
    
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
    set count [ArgsParseNumbersList $use(tcolumns) tcols]
    AssertGreaterThan $count 0

    # finally, insert it all into a table
    foreach x [lsort -increasing [array names values -glob *]] {
	# make the list of things AddRow must do
	set tlist "x,$x"
	for {set i 0} {$i < $count} {incr i} {
	    set tlist "$tlist : $tcols($i,n2),$tmp($tcols($i,n1),$x)"
	}
	# puts stderr "The list: $tlist"
	TableAddRow $use(to) $tlist
    }

    # dump it for debugging
    # TableDump $use(to)
}
