namespace eval ::persistence {

    variable base_dir 

    set base_dir "/web/data"

}

proc ::persistence::get_keyspace_dir {keyspace} {

    variable base_dir
    set keyspace_dir ${base_dir}/${keyspace}
    return ${keyspace_dir}

}


proc ::persistence::get_cf_dir {keyspace column_family} {
    set keyspace_dir [get_keyspace_dir ${keyspace}]
    set cf_dir ${keyspace_dir}/${column_family}
    return ${cf_dir}
}


proc ::persistence::get_row_dir {keyspace column_family row_key} {

    # aka snapshot directory
    set cf_dir [get_cf_dir ${keyspace} ${column_family}]

    # TODO: depending on keyspace settings, 
    # we can setup other storage strategies

    set row_dir ${cf_dir}/${row_key}

    return ${row_dir}

}


proc ::persistence::keyspace_exists_p {keyspace} {

    return [file isdirectory [get_keyspace_dir ${keyspace}]]

}


proc ::persistence::cf_exists_p {keyspace column_family} {

    return [file isdirectory [get_cf_dir ${keyspace} ${column_family}]]

}


proc ::persistence::create_keyspace_if {keyspace {replication_factor "3"}} {

    if { ![keyspace_exists_p ${keyspace}] } {
	file mkdir [get_keyspace_dir ${keyspace}]
	return 1
    }

    return 0

}

proc ::persistence::create_row_if {keyspace column_family row_key row_dirVar} {

    upvar ${row_dirVar} row_dir

    # ensure keyspace exists
    if { ![keyspace_exists_p ${keyspace}] } {
	error "create_row_if: no such keyspace (${keyspace})"
    }

    # ensure ${cf_dir} exists
    if { ![cf_exists_p ${keyspace} ${column_family}] } {
	error "create_row_if: no such column family (${keyspace}/${column_family})"
    }

    set row_dir [get_row_dir ${keyspace} ${column_family} ${row_key}]

    # create ${row_dir} dir
    file mkdir ${row_dir}

}

# example column families and column names:
#
# cf=news_item url/3ef3908e7438635a03e2321669b5855dbf4f238f
# cf=news_item item keywspace:newsdb log/row:3ef3908e7438635a03e2321669b5855dbf4f238f
# cf=content_item keyspace:newsdb content/row:cdaa22d5ca05c6111d900ce81f5686c376a50881
#
# cf=revision     keyspace:newsdb site/row:com.philenews/super:3ef3908e7438635a03e2321669b5855dbf4f238f/column:cdaa22d5ca05c6111d900ce81f5686c376a50881
# cf=revision     keywspace:newsdb site/row:com.philenews.3ef3908e7438635a03e2321669b5855dbf4f238f/cdaa22d5ca05c6111d900ce81f5686c376a50881
#
# name := keyspace/row_key/column_path
# column_path := super_column_name/column_name or just column_name
#
proc ::persistence::insert_column {keyspace column_family row_key column_path data {timestamp ""}} {

    create_row_if ${keyspace} ${column_family} ${row_key} row_dir

    # path to file that will hold the data
    set filename ${row_dir}/${column_path}

    #puts "filename = $filename"

    # if it applies, mkdir super_column_dir
    if { [set super_column_dir [file dirname ${filename}]] ne ${row_dir} } {

	# it's a supecolumn
	file mkdir ${super_column_dir}

    }

    set_data ${filename} ${data}

    if { ${timestamp} ne {} } {
	file mtime ${filename} ${timestamp}
    }

}


proc ::persistence::exists_data_p {filename} {

    return [file exists ${filename}]

}

proc ::persistence::set_data {filename data} {

    file mkdir [file dirname ${filename}]

    return [::util::writefile ${filename} ${data}]

}

proc ::persistence::get_data {filename} {

    return [::util::readfile ${filename}]

}


proc slice_predicate=lrange {slicelistVar offset {limit ""}} {

    upvar ${slicelistVar} slicelist

    set first ${offset}

    set last "end"
    if { ${limit} ne {} } {
	set last [expr { ${offset} + ${limit} - 1 }]
    }

    set slicelist [lrange ${slicelist} ${first} ${last}]
    
}

proc slice_predicate=lindex {slicelistVar index} {

    upvar ${slicelistVar} slicelist

    set slicelist [lindex ${slicelist} ${index}]

}


proc ::persistence::get_slice {keyspace column_family row_key {slice_predicate ""}} {

    set row_dir [get_row_dir ${keyspace} ${column_family} ${row_key}]

    # puts "row_dir = ${row_dir}"

    set slicelist [lsort -decreasing [glob -nocomplain -directory ${row_dir} *]]

    if { ${slice_predicate} ne {} } {

	lassign ${slice_predicate} cmd args

	slice_predicate=${cmd} slicelist {*}${args}

    }

    return ${slicelist}

}

proc ::persistence::get_slice_names {args} {

    set result [list]

    set slicelist [get_slice {*}${args}]

    foreach filename ${slicelist} {

	lappend result [file tail ${filename}]

    }

    return ${result}

}

proc ::persistence::get_column {keyspace column_family row_key column_path {dataVar ""} {exists_pVar ""}} {

    set row_dir [get_row_dir ${keyspace} ${column_family} ${row_key}]

    set filename ${row_dir}/${column_path}

    # puts "filename = $filename"

    if { ${dataVar} ne {} } {

	if { ${exists_pVar} ne {} } {

	    upvar ${exists_pVar} exists_p

	}

	set exists_p [exists_data_p ${filename}]

	if { ${exists_p} } {

	    upvar ${dataVar} data

	    set data [get_data ${filename}]

	}

    }

    return ${filename}

}


proc ::persistence::remove_column {keyspace column_family row_key column_path} {

    set row_dir [get_row_dir ${keyspace} ${column_family} ${row_key}]

    set filename ${row_dir}/${column_path}

    file delete ${filename}

}


proc ::persistence::exists_column_p {keyspace column_family row_key column_path} {

    set row_dir [get_row_dir ${keyspace} ${column_family} ${row_key}]

    set filename ${row_dir}/${column_path}

    return [file exists ${filename}]

}


### TO BE TESTED


proc ::persistence::multiget_slice {keyspace_list column_family row_keys {slice_predicate ""}} {

    set result [list]

    foreach row_key ${row_keys} {

	set slicelist [get_slice ${keyspace} ${column_family} ${row_key} ${slicePredicate}]

	lappend result [list ${row_key} ${slicelist}]

    }

    return ${result}

}




#TODO: get_range_slices
#TODO: batch_mutate
#TODO: incr_column
#TODO: incr_super_column
