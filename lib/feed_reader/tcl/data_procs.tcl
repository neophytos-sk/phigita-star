namespace eval ::feed_reader::data {

    set base_dir /web/data/newsdb

}

# example column families and column names:
#
# cf=news_item url/3ef3908e7438635a03e2321669b5855dbf4f238f
# cf=news_item item keywspace:log/row:3ef3908e7438635a03e2321669b5855dbf4f238f
# cf=content_item keyspace:content/row:cdaa22d5ca05c6111d900ce81f5686c376a50881
#
# cf=revision     keyspace:site/row:com.philenews/super:3ef3908e7438635a03e2321669b5855dbf4f238f/column:cdaa22d5ca05c6111d900ce81f5686c376a50881
# cf=revision     keywspace:site/row:com.philenews.3ef3908e7438635a03e2321669b5855dbf4f238f/cdaa22d5ca05c6111d900ce81f5686c376a50881
#
# name := keyspace/row_key/column_path
# column_path := super_column_name/column_name or just column_name
#
proc ::feed_reader::data::insert_column {keyspace row column_path data {timestamp ""}} {

    variable base_dir

    set keyspace_dir ${base_dir}/${keyspace}

    # ensure ${keyspace_dir} exists
    if { ![file isdirectory ${keyspace_dir}] } {
	error "insert_column: no such keyspace dir ${keyspace_dir}"
    }

    set row_dir ${keyspace_dir}/${row}

    # create ${row_dir} dir
    file mkdir ${row_dir}

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

