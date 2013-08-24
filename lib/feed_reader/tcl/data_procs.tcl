namespace eval ::persistence {

    variable base_dir 

    set base_dir "/web/data/"

}

proc ::persistence::get_keyspace_dir {keyspace} {

    variable base_dir
    set keyspace_dir ${base_dir}/${keyspace}
    return ${keyspace_dir}

}

proc ::persistence::keyspace_exists_p {keyspace} {

    return [file isdirectory [get_keyspace_dir ${keyspace}]]

}

proc ::persistence::create_keyspace_if {keyspace {replication_factor "3"}} {

    if { ![keyspace_exists_p ${keyspace}] } {
	file mkdir [get_keyspace_dir ${keyspace}]
	return 1
    }

    return 0

}

proc ::persistence::create_row_if {keyspace row_key row_dirVar} {

    upvar ${row_dirVar} row_dir

    # ensure ${keyspace_dir} exists
    if { ![keyspace_exists_p ${keyspace}] } {
	error "get_row_dir: no such keyspace (${keyspace})"
    }

    set keyspace_dir [get_keyspace_dir ${keyspace}]

    # TODO: depending on keyspace settings, 
    # we can setup other placement strategies
    # e.g. order preserving partitioning
    # or 

    set row_dir ${keyspace_dir}/${row_key}

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
proc ::persistence::insert_column {keyspace row_key column_path data {timestamp ""}} {

    create_row_if ${keyspace} ${row_key} row_dir

    # path to file that will hold the data
    set filename ${row_dir}/${column_path}

    # if it applies, mkdir super_column_dir
    if { [set super_column_dir [file dirname ${filename}]] ne ${row_dir} } {

	# it's a supecolumn
	file mkdir ${super_column_dir}

    }

    ::util::writefile ${filename} ${data}

    if { ${timestamp} ne {} } {
	file mtime ${filename} ${timestamp}
    }

}

