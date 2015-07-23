namespace eval ::persistence::fs {

    variable base_dir
    set base_dir "/web/data/mystore"

    namespace export -clear \
        define_ks define_cf \
        exists_data_p set_data get_data \
        exists_column_p insert_column get_column get_column_name \
        delete_row delete_column delete_slice \
        multiget_slice \
        get_multirow get_multirow_names get_multirow_slice get_multirow_slice_names \
        get_row get_column get_supercolumn \
        get_slice_names get_slice_from_row get_slice_from_supercolumn get_slice \
        ls list_ks list_cf list_axis list_row list_col list_path \
        num_rows num_cols \
        get_name delete_data 
}

proc ::persistence::fs::get_dir {args} {
    variable base_dir
    set dir [join [list ${base_dir} {*}${args}] {/}]
    return ${dir}
}

proc ::persistence::fs::exists_ks_p {keyspace} {
    variable ks
    #return [file isdirectory [get_dir ${keyspace}]]
    return [info exists ks(${keyspace})]
}

proc ::persistence::fs::assert_ks {keyspace} {
    if { ![exists_ks_p ${keyspace}] } {
        error "assert_ks: no such keyspace (${keyspace})"
    }
}

proc ::persistence::fs::list_ks {} {
    variable base_dir
    return [::util::fs::ls ${base_dir}]
}

proc ::persistence::fs::exists_cf_p {keyspace column_family} {
    variable ks
    variable cf
    #return [file isdirectory [get_dir ${keyspace} ${column_family}]]
    return [info exists cf(${keyspace},${column_family})]
}

proc ::persistence::fs::assert_cf {keyspace column_family} {
    if { ![exists_cf_p ${keyspace} ${column_family}] } {
        error "assert_cf: no such column family (${keyspace},${column_family})"
    }
}

proc ::persistence::fs::list_cf {ks} {
    return [::util::fs::ls [get_dir ${ks}]]
}

proc ::persistence::fs::exists_row_p {args} {
    set row_dir [get_row {*}${args}]
    return [file isdirectory ${row_dir}]
}

proc ::persistence::fs::assert_row {keyspace column_family row_key} {
    assert_cf ${keyspace} ${column_family}
    if { ![exists_row_p ${keyspace} ${column_family} ${row_key}] } {
        error "assert_row: no such row (${keyspace},${column_family},${row_key})"
    }
}

proc ::persistence::fs::ls {args} {
    return [::util::fs::ls [get_dir {*}${args}]]
}

proc ::persistence::fs::list_axis {ks cf} {
    return [::util::fs::ls [get_dir ${ks} ${cf}]]
}

proc ::persistence::fs::list_row {ks cf_axis} {
    return [::util::fs::ls [get_dir ${ks} ${cf_axis}]]
}

proc ::persistence::fs::list_path {ks cf_axis row_key} {
    return [get_paths [get_dir ${ks} ${cf_axis} ${row_key}]]
}

proc ::persistence::fs::num_rows {ks cf} {
    return [llength [list_row ${ks} ${cf}]]
}

proc ::persistence::fs::list_col {ks cf_axis row} {
    return [::util::fs::ls [get_dir ${ks} ${cf_axis} ${row}]]
}

proc ::persistence::fs::num_cols {ks cf row} {
    return [llength [list_col ${ks} ${cf} ${row}]]
}

proc ::persistence::fs::exists_supercolumn_p {args} {
    set supercolumn_dir [get_supercolumn {*}${args}]
    return [file isdirectory ${supercolumn_dir}]
}

proc ::persistence::fs::assert_supercolumn {keyspace column_family row_key supercolumn_path} {
    assert_row ${keyspace} ${column_family} ${row_key}
    if { ![exists_supercolumn_p ${keyspace} ${column_family} ${row_key} ${supercolumn_path}] } {
        error "assert_supercolumn: no such supercolumn (${keyspace},${column_family},${row_key},${supercolumn_path})"
    }
}

proc ::persistence::fs::create_ks_if {keyspace {replication_factor "3"}} {
    if { ![exists_ks_p ${keyspace}] } {
        file mkdir [get_dir ${keyspace}]
        return 1
    }
    return 0
}

proc ::persistence::fs::create_cf_if {keyspace column_family} {
    if { ![exists_cf_p ${keyspace} ${column_family}] } {
        file mkdir [get_dir ${keyspace} ${column_family}]
        return 1
    }
    return 0
}

proc ::persistence::fs::define_ks {keyspace} {
    variable ks
    create_ks_if ${keyspace}
    set ks(${keyspace}) 1
}

proc ::persistence::fs::define_cf {keyspace column_family {spec {}}} {
    variable cf
    assert_ks ${keyspace}
    create_cf_if ${keyspace} ${column_family}
    set cf(${keyspace},${column_family}) ${spec}
}

proc ::persistence::fs::get_row {keyspace column_family row_key} {
    set delimiter {+}
    set row_dir [get_dir ${keyspace} ${column_family} ${row_key} ${delimiter}]
    return ${row_dir}
}

proc ::persistence::fs::get_supercolumn {keyspace column_family row_key supercolumn_path} {
    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]
    set supercolumn_dir ${row_dir}/${supercolumn_path}
    return ${supercolumn_dir}
}

proc ::persistence::fs::create_row_if {keyspace column_family row_key row_dirVar} {

    # ensure keyspace exists
    assert_ks ${keyspace}
    assert_cf ${keyspace} ${column_family}

    upvar ${row_dirVar} row_dir

    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]

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
proc ::persistence::fs::insert_column {keyspace column_family row_key column_path data {timestamp ""}} {

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

proc ::persistence::fs::exists_data_p {filename} {
    return [file exists ${filename}]
}

# TODO: consider renaming it to put_data
proc ::persistence::fs::set_data {filename data} {
    file mkdir [file dirname ${filename}]
    return [::util::writefile ${filename} ${data}]
}

proc ::persistence::fs::get_data {filename} {
    return [::util::readfile ${filename}]
}

proc ::persistence::fs::incr_refcount {target_filename_or_dir link_filename_or_dir} {

    set mapping {{/} {.}}
    set target_name [string map ${mapping} ${target_filename_or_dir}]
    set link_name [string map ${mapping} ${link_filename_or_dir}]

    ::persistence::fs::insert_column \
        "sysdb" \
        "refcount_item" \
        "target-${target_name}" \
        "link-${link_name}" \
        "${link_filename_or_dir}"

}

proc ::persistence::fs::assert_refcount_is_zero {target_filename_or_dir} {
    set mapping {{/} {.}}
    set target_name [string map ${mapping} ${target_filename_or_dir}]

    set slice \
        [::persistence::fs::get_slice \
             "sysdb" \
             "refcount_item" \
             "target-${target_name}"]

    if { ${slice} ne {} } {
        error "assert_refcount: there one or more items linking to this object"
    }

}

proc ::persistence::fs::link_data {target_filename_or_dir link_filename_or_dir} {
    file link -symbolic ${link_filename_or_dir} ${target_filename_or_dir}
    incr_refcount ${target_filename_or_dir} ${link_filename_or_dir} 
}

proc ::persistence::fs::rename_data {old_supercolumn_dir new_supercolumn_dir} {
    assert_refcount_is_zero ${old_supercolumn_dir}
    file rename ${old_supercolumn_dir} ${new_supercolumn_dir}
}

proc ::persistence::fs::get_name {filename_or_dir} {
    return [file tail ${filename_or_dir}]
}

proc ::persistence::fs::delete_data {filename_or_dir} {
    assert_refcount_is_zero ${filename_or_dir}
    return [file delete ${filename_or_dir}]
}


# TODO: replace glob with ::util::fs::ls
proc ::persistence::fs::empty_row_p {row_dir} {
    return [expr { [glob -nocomplain -directory ${row_dir} *] eq {} }]
}


proc ::persistence::fs::predicate=lrange {slicelistVar offset {limit ""}} {

    upvar ${slicelistVar} slicelist

    set first ${offset}
    set last "end"
    if { ${limit} ne {} } {
        set last [expr { ${offset} + ${limit} - 1 }]
    }
    set slicelist [lrange ${slicelist} ${first} ${last}]

}

proc ::persistence::fs::predicate=match {slicelistVar pattern} {

    upvar ${slicelistVar} slicelist

    set result [list]
    foreach filename ${slicelist} {
        if { [string match ${pattern} ${filename}] } {
            lappend result ${filename}
        }
    }
    set slicelist ${result}

}

proc ::persistence::fs::predicate=match_name {slicelistVar pattern} {

    upvar ${slicelistVar} slicelist

    set result [list]
    foreach filename ${slicelist} {
        set name [::persistence::fs::get_name ${filename}]
        if { [string match ${pattern} ${name}] } {
            lappend result ${filename}
        }
    }
    set slicelist ${result}

}


proc ::persistence::fs::predicate=lindex {slicelistVar index} {

    upvar ${slicelistVar} slicelist

    set slicelist [lindex ${slicelist} ${index}]

}

proc ::persistence::fs::predicate=in {slicelistVar column_names} {

    upvar ${slicelistVar} slicelist

    set result [list]

    foreach filename ${slicelist} {

	if { [file tail ${filename}] in ${column_names} } {
	    lappend result ${filename}
	}
    }

    set slicelist ${result}

}

proc ::persistence::fs::predicate=lsort {slicelistVar args} {

    set slicelist [lsort {*}${args} ${slicelist}]

}


# TODO: replace glob with ::util::fs::ls
proc ::persistence::fs::get_files {dir} {
    return [glob -types {f} -nocomplain -directory ${dir} *]
}

# TODO: replace glob with ::util::fs::ls
proc ::persistence::fs::get_subdirs {dir} {
    return [glob -types {d} -nocomplain -directory ${dir} *]
}

proc ::persistence::fs::get_paths {dir} {
    set paths [list]
    set files_or_dirs [glob -tails -types {d f} -nocomplain -directory ${dir} *]
    foreach name ${files_or_dirs} {
        if { [file type ${dir}/${name}] eq {file} } {
            lappend paths ${name}
        } else {
            foreach path [get_paths ${dir}/${name}] {
                lappend paths ${name}/${path}
            }
        }
    }
    return ${paths}
}

proc ::persistence::fs::get_recursive_subdirs {dir resultVar} {

    upvar $resultVar result

    set subdirs [get_subdirs ${dir}]
    foreach subdir ${subdirs} {
        lappend result ${subdir}
        get_recursive_subdirs ${subdir} result
    }

}


proc ::persistence::fs::get_slice_from_supercolumn {supercolumn_dir {slice_predicate ""}} {

    set dirs [list ${supercolumn_dir}]

    get_recursive_subdirs ${supercolumn_dir} dirs

    set slicelist [list]
    foreach dir ${dirs} {
        foreach filename [get_files ${dir}] {
            lappend slicelist ${filename}
        }
    }

    set slicelist [lsort -decreasing ${slicelist}]
    if { ${slice_predicate} ne {} } {
        lassign ${slice_predicate} cmd args
        predicate=${cmd} slicelist {*}${args}
    }
    return ${slicelist}
}


proc ::persistence::fs::get_slice_from_row {row_dir {slice_predicate ""}} {
    set slicelist [get_files ${row_dir}]
    set slicelist [lsort -decreasing ${slicelist}]
    if { ${slice_predicate} ne {} } {
        lassign ${slice_predicate} cmd args
        predicate=${cmd} slicelist {*}${args}
    }
    return ${slicelist}
}

proc ::persistence::fs::get_slice {keyspace column_family row_key {slice_predicate ""}} {

    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]
    return [get_slice_from_row ${row_dir} ${slice_predicate}]

}

proc ::persistence::fs::get_slice_names {args} {
    set result [list]
    set slicelist [get_slice {*}${args}]
    foreach filename ${slicelist} {
        lappend result [::persistence::fs::get_name ${filename}]
    }
    return ${result}
}


proc ::persistence::fs::get_column {keyspace column_family row_key column_path {dataVar ""} {exists_pVar ""}} {

    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]

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

proc ::persistence::fs::get_column_name {args} {

    set result [list]

    set column [get_column {*}${args}]

    set result [file tail ${column}]

    return ${result}

}


proc ::persistence::fs::delete_column {args} {

    set filename [get_column {*}${args}]

    delete_data ${filename}

}

proc ::persistence::fs::delete_row {args} {
    
    set row_dir [get_row {*}${args}]

    delete_row_dir ${row_dir}

}

proc ::persistence::fs::delete_row_dir {row_dir} {

    # removes by_urlsha1_and_contentsha1/0ede2e2ca7bf4bf22a75cb22bac7e70a4e466a0d/+
    # (with plus sign)
    delete_data ${row_dir}

    # removes by_urlsha1_and_contentsha1/0ede2e2ca7bf4bf22a75cb22bac7e70a4e466a0d/
    # (without plus sign)
    delete_data [file dirname ${row_dir}]

}

proc ::persistence::fs::delete_row_if {args} {
    set row_dir [get_row {*}${args}]

    set empty_row_p [empty_row_p ${row_dir}]

    if { ${empty_row_p} } {
        delete_row_dir ${row_dir}
    }

    return ${empty_row_p}
}


proc ::persistence::fs::delete_slice {keyspace column_family row_key {slice_predicate ""}} {

    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]
    set slicelist [get_slice_from_row ${row_dir} ${slice_predicate}]

    foreach filename ${slicelist} {
        ::persistence::fs::delete_data ${filename}
    }


    if { [empty_row_p ${row_dir}] } {
        delete_data ${row_dir}
    }

    return ${slicelist}
}


proc ::persistence::fs::exists_column_p {keyspace column_family row_key column_path} {
    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]
    set filename ${row_dir}/${column_path}
    return [file exists ${filename}]
}


proc ::persistence::fs::multiget_slice {keyspace column_family row_keys {slice_predicate ""}} {

    set result [list]

    foreach row_key ${row_keys} {
        set slicelist [get_slice ${keyspace} ${column_family} ${row_key} ${slice_predicate}]
        lappend result ${row_key}
        lappend result ${slicelist}
    }

    return ${result}

}

#::persistence::fs::directed_join newsdb
#  get_multirow_slice_names classifier/${axis}
#  get_column content_item/by_contentsha1_and_const/%s/_data_

proc ::persistence::fs::names__directed_join {multirow_slice_names keyspace column_family {include_empty_p "0"}} {
    set multirow_filelist [list]
    foreach names ${multirow_slice_names} { 
	set filelist [list]
	foreach name ${names} {

	    set get_slice_args [concat ${keyspace} ${column_family} ${name}]

	    # if the relationship is one to one, i.e. if one name
	    # in the left-hand side corresponds to one item in the
	    # right-hand side then slicelist should be a list a
	    # list of length at most one
	    set slicelist [::persistence::fs::get_slice {*}${get_slice_args}]

	    # note that slicelist can be empty if no match was found
	    if { ${slicelist} ne {} || ${include_empty_p} } {
		lappend filelist ${slicelist}
		#puts "${name} -> ${slicelist}"
	    }


	} 

	lappend multirow_filelist ${filelist}
    }
    return ${multirow_filelist}
}



#TODO: get_range_slices
#TODO: batch_mutate
#TODO: incr_column
#TODO: incr_super_column


################ multirow

# TODO: replace glob with ::util::fs::ls
# TODO: replace ::util::fs::ls with ::persistence::fs::list_rows
proc ::persistence::fs::get_multirow {keyspace column_family {predicate ""}} {


    assert_cf ${keyspace} ${column_family}


    set cf_dir [get_dir ${keyspace} ${column_family}]

    set multirow [lsort -decreasing [glob -types {d} -nocomplain -directory ${cf_dir} *]]

    if { ${predicate} ne {} } {

	lassign ${predicate} cmd args

	predicate=${cmd} multirow {*}${args}

    }

    return ${multirow}

}


proc ::persistence::fs::get_multirow_names {args} {

    set multirow [get_multirow {*}${args}]
    set result [list]
    foreach row ${multirow} {
	lappend result [get_name ${row}]
    }
    return ${result}
}


proc ::persistence::fs::get_multirow_slice {keyspace column_family {multirow_predicate ""} {slice_predicate ""}} {

    set multirow [get_multirow ${keyspace} ${column_family} ${multirow_predicate}]

    set multirow_slice [list]

    foreach row_dir ${multirow} {

	set slicelist \
	    [get_slice_from_row \
		 "${row_dir}" \
		 "${slice_predicate}"]

	lappend multirow_slice ${slicelist}

    }

    return ${multirow_slice}
}


proc ::persistence::fs::get_multirow_slice_names {args} {

    set multirow_slice [get_multirow_slice {*}${args}]

    set multirow_slice_names [list]
    foreach slicelist ${multirow_slice} {
	set names [list]
	foreach filename ${slicelist} {
	    lappend names [::persistence::fs::get_name ${filename}]
	}
	lappend multirow_slice_names ${names}
    }
    return ${multirow_slice_names}

}


############## supercolumns



proc ::persistence::fs::get_supercolumns {keyspace column_family row_key {supercolumn_path ""} {predicate ""}} {


    # assert_cf ${keyspace} ${column_family}
    # assert_row ${keyspace} ${column_family} ${row_key}
    assert_supercolumn  ${keyspace} ${column_family} ${row_key} ${supercolumn_path}

    set supercolumn_dir [get_supercolumn ${keyspace} ${column_family} ${row_key} ${supercolumn_path}]

    set subdirs [get_subdirs ${supercolumn_dir}]

    set supercolumns [lsort -decreasing ${subdirs}]

    if { ${predicate} ne {} } {

	lassign ${predicate} cmd args

	predicate=${cmd} supercolumns {*}${args}

    }

    return ${supercolumns}

}



proc ::persistence::fs::get_column_path {column_parent_dir} {

    set delimiter {+}
    lassign [split ${column_parent_dir} ${delimiter}] row_dir column_path

    # alternatively, we could just trimleft {/} but for
    # some reason we expect the following would be faster
    return [string range ${column_path} 1 end]

}

proc ::persistence::fs::get_column_path_with_status {column_parent_dir} {

    set delimiter {+}
    lassign [split ${column_parent_dir} ${delimiter}] row_dir column_path

    # alternatively, we could just trimleft {/} but for
    # some reason we expect the following would be faster
    set result_path [string range ${column_path} 1 end]

    file lstat ${column_parent_dir} lstat

    if { $lstat(type) eq {link} } {
	#variable base_dir
	#set fromIndex [string length ${base_dir}]
	#set lstat(target) [string range [file readlink ${column_parent_dir}] $fromIndex end]
	set lstat(target) [file readlink ${column_parent_dir}]
    }

    return [list ${result_path} [array get lstat]]

}


proc ::persistence::fs::get_supercolumns_names {args} {

    set supercolumns [get_supercolumns {*}${args}]
    set result [list]
    foreach supercolumn ${supercolumns} {
	lappend result [get_name ${supercolumn}]
    }
    return ${result}
}


# recursive column paths, i.e. under each supercolumn
proc ::persistence::fs::get_supercolumns_paths {args} {

    set supercolumns [get_supercolumns {*}${args}]
    set subdirs [list]
    foreach supercolumn_dir ${supercolumns} {
	lappend subdirs ${supercolumn_dir}
	get_recursive_subdirs ${supercolumn_dir} subdirs
    }

    set result [list]
    foreach subdir ${subdirs} {
	lappend result [get_column_path ${subdir}]
    }
    return ${result}

}

# recursive column paths, i.e. under each supercolumn
proc ::persistence::fs::get_supercolumns_paths_with_status {args} {

    set supercolumns [get_supercolumns {*}${args}]
    set subdirs [list]
    foreach supercolumn_dir ${supercolumns} {
	lappend subdirs ${supercolumn_dir}
	get_recursive_subdirs ${supercolumn_dir} subdirs
    }

    set result [list]
    foreach subdir ${subdirs} {
	lappend result [get_column_path_with_status ${subdir}]
    }
    return ${result}

}


proc ::persistence::fs::get_supercolumns_slice {keyspace column_family row_key {supercolumn_path ""} {supercolumns_predicate ""} {slice_predicate ""}} {

    set supercolumns [get_supercolumns \
			  ${keyspace} \
			  ${column_family} \
			  ${row_key} \
			  ${supercolumn_path} \
			  ${supercolumns_predicate}]

    set supercolumns_slice [list]

    foreach supercolumn_dir ${supercolumns} {

	set slicelist \
	    [get_slice_from_supercolumn \
		 "${supercolumn_dir}" \
		 "${slice_predicate}"]

	lappend supercolumns_slice ${slicelist}

    }

    return ${supercolumns_slice}
}


proc ::persistence::fs::get_supercolumns_slice_names {args} {

    set supercolumns_slice [get_supercolumns_slice {*}${args}]

    set supercolumns_slice_names [list]
    foreach slicelist ${supercolumns_slice} {
        set names [list]
        foreach filename ${slicelist} {
            lappend names [::persistence::fs::get_name ${filename}]
        }
        lappend supercolumns_slice_names ${names}
    }
    return ${supercolumns_slice_names}

}




proc ::persistence::fs::rename_supercolumn {keyspace column_family row_key old_name_path new_name_path} {

    set old_supercolumn_dir \
        [::persistence::fs::get_supercolumn \
            "${keyspace}" \
            "${column_family}" \
            "${row_key}" \
            "${old_name_path}"]

    set new_supercolumn_dir \
        [::persistence::fs::get_supercolumn \
            "${keyspace}" \
            "${column_family}" \
            "${row_key}" \
            "${new_name_path}"]


    puts old_supercolumn_dir=$old_supercolumn_dir
    puts new_supercolumn_dir=$new_supercolumn_dir

    ::persistence::fs::rename_data ${old_supercolumn_dir} ${new_supercolumn_dir}

}


# for example:
#
# ::persistence::fs::link \
#     newsdb \
#     train_item \
#     el/edition/+/cyprus/politics/domestic_politics \
#     el/topic/+/politics/domestic_politics/cyprus
#
proc ::persistence::fs::link {keyspace column_family target_path link_path {force_p "0"}} {

    lassign [split ${target_path} {+}] target_row target_supercolumn_path
    lassign [split ${link_path} {+}] link_row link_supercolumn_path   

    set target_row [string trimright ${target_row} {/}]
    set link_row [string trimright ${link_row} {/}]

    set target_supercolumn_path [string trimleft ${target_supercolumn_path} {/}]
    set link_supercolumn_path [string trimleft ${link_supercolumn_path} {/}]

    assert_supercolumn \
        ${keyspace} \
        ${column_family} \
        ${target_row} \
        ${target_supercolumn_path}

    assert_row \
        ${keyspace} \
        ${column_family} \
        ${link_row}


    set target_supercolumn_dir \
        [::persistence::fs::get_supercolumn \
            "${keyspace}" \
            "${column_family}" \
            "${target_row}" \
            "${target_supercolumn_path}"]

    set link_supercolumn_dir \
        [::persistence::fs::get_supercolumn \
            "${keyspace}" \
            "${column_family}" \
            "${link_row}" \
            "${link_supercolumn_path}"]

    if { !${force_p} && [::persistence::fs::exists_data_p ${link_supercolumn_dir}] } {
        error "::persistence::fs::link - data already exists at ${link_supercolumn_dir}"
    }

    ::persistence::fs::link_data ${target_supercolumn_dir} ${link_supercolumn_dir}

}

