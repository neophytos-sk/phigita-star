proc my_dependency_check {packages} {
    set spec_files [list]
    foreach pkg $packages {
	set spec_file [acs_root_dir]/packages/$pkg/pkgIndex.info
	if { ![file exists $spec_file] } {
	    ns_log notice "missing spec_file=$spec_file"
	    continue
	}
	lappend spec_files $spec_file
    }



    #########
    set pending [list]
    foreach spec_file $spec_files {
	if { [catch {
	    array set package [apm_read_package_info_file $spec_file]
	    set requires [list]
	    foreach item $package(requires) {
		lappend requires [lindex $item 0]
	    } 
	    set provides [list]
	    foreach item $package(provides) {
		lappend provides [lindex $item 0]
	    }
	    lappend pending [list $package(package.key) $requires $provides [llength $requires]]
	} errmsg] } {
	    # continue
	    error $errmsg
	}
    }

    set updated_p 1
    set pkg_order [list]
    while { $updated_p && [exists_and_not_null pending]} {
	set pending [lsort -index 3 $pending]
	set pkg_info [lindex $pending 0]

	lassign $pkg_info pkg_key pkg_requires pkg_provides reqlen
	#if { $reqlen != 0 } { ns_write "key=$pkg_key requires=$pkg_requires<p>" }

	lappend pkg_order $pkg_key

	set _pending [list]
	foreach _pkg [lrange $pending 1 end] {
	    lassign $_pkg _key _requires _provides _reqlen
	    lassign [intersect3 $_requires $pkg_provides] infirst intersection insecond
	    lappend _pending [list $_key $infirst $_provides [llength $infirst]]
	}
	set pending $_pending
    }
    return $pkg_order
}

