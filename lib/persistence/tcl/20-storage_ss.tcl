if { ![setting_p "sstable"] } {
    return
}

namespace eval ::persistence::ss {
    variable base_dir
    set base_dir [config get ::persistence base_dir]

    namespace path "::persistence::common"
    namespace import ::persistence::common::split_oid
}

proc ::persistence::ss::init {type_oid} {
    variable base_dir

    set name [binary encode base64 $type_oid]
    set dir [file join $base_dir "sysdb/sstable.by_name/${name}/+/"]
    # log "ss->init: type_oid=$type_oid dir=$dir"
    set filelist [file __find $dir "*.part@*"]
    foreach filename $filelist {
        # TODO: the following, not quite right as it is currently triggered upon define_cf
        #
        # log "deleting (sstable.part) file: $filename"
        # file delete $filename
        # log "deleted (sstable.part) file: $filename"
    }
}

proc ::persistence::ss::read_sstable {idxVar fp file_i} {
    upvar $idxVar idx

    seek $fp -4 end
    set start_of_indexmap [::util::io::read_int $fp]

    assert { $start_of_indexmap > 0 } 

    seek $fp $start_of_indexmap start
    seek $fp -4 current
    while { [tell $fp] != 0} {
        set endpos [tell $fp]
        set startpos [::util::io::read_int $fp]
        seek $fp $startpos start
        ::util::io::read_string $fp row_key

        while { [tell $fp] < $endpos } {
            ::util::io::read_string $fp rev
            set pos [tell $fp]
            lappend idx(${row_key}) [list $rev $file_i $pos]
            ::util::io::skip_string $fp 
        }
        if { $startpos == 0 } {
            break
        }
        seek $fp $startpos start
        seek $fp -4 current
    }
}

proc ::persistence::ss::read_sstable_indexmap {indexmapVar fp} {
    upvar $indexmapVar indexmap

    seek $fp -4 end
    set start_of_indexmap [::util::io::read_int $fp]
    assert { $start_of_indexmap > 0 } 
    seek $fp $start_of_indexmap start
    ::util::io::read_string $fp indexmap
    assert { $indexmap ne {} }
}

proc ::persistence::ss::load_sstable_indexmap {type_oid codec_conf} {

    set name [binary encode base64 $type_oid]
    set sstable_idxVar "__sstable_idx_${name}"
    set sstable_filenameVar "__sstable_filename_${name}"
    namespace upvar ::persistence::ss $sstable_idxVar sstable_idx
    namespace upvar ::persistence::ss $sstable_filenameVar sstable_filename

    # start of temporary hack
    variable base_dir
    set sstable_rev [glob \
        -nocomplain \
        -tails \
        -directory $base_dir \
        "sysdb/sstable.by_name/${name}/+/${name}.sstable@*"]

    if { $sstable_rev eq {} } {
        log "sstable name: $name"
        log "no sstable files matched: [binary decode base64 $name]"
        log "exiting..."
        exit
    }

    # log sstable_rev=$sstable_rev
    lassign [split_oid $sstable_rev] \
        ks cf_axis row_key column_path ext ts

    # end of temporary hack


    set load_p 0
    if { ![info exists sstable_idx] } {
        set load_p 1
    } elseif { $sstable_idx(ts) ne $ts } {
        array unset sstable_idx
        set load_p 1
    }

    if { $load_p } {
        set sstable_filename [get_filename $sstable_rev]
        set fp [open $sstable_filename]
        fconfigure $fp {*}$codec_conf
        read_sstable_indexmap indexmap $fp
        array set sstable_idx $indexmap
        array set sstable_idx [list ts $ts]
    }
}


proc ::persistence::ss::read_sstable_column {rev args} {
    set codec_conf $args

    set type_oid [type_oid $rev]
    load_sstable_indexmap $type_oid $codec_conf

    set name [binary encode base64 $type_oid]
    set sstable_idxVar "__sstable_idx_${name}"
    set sstable_filenameVar "__sstable_filename_${name}"
    namespace upvar ::persistence::ss $sstable_idxVar sstable_idx
    namespace upvar ::persistence::ss $sstable_filenameVar sstable_filename

    lassign [split_oid $rev] ks cf_axis row_key column_path ext ts
    set row_endpos $sstable_idx($row_key)

    # log row_endpos=$row_endpos

    set fp [open $sstable_filename]
    fconfigure $fp {*}$codec_conf

    seek $fp $row_endpos start
    set row_startpos [::util::io::read_int $fp]

    # log row_startpos=$row_startpos

    assert { $row_startpos < $row_endpos }

    seek $fp $row_startpos start
    ::util::io::read_string $fp row_key_in_file
    assert { $row_key eq $row_key_in_file }

    set found_p 0
    while { [tell $fp] < $row_endpos } {
        ::util::io::read_string $fp rev_in_file
        if { $rev eq $rev_in_file } {
            ::util::io::read_string $fp data
            set found_p 1
            break
        } else {
            ::util::io::skip_string $fp
        }
    }

    close $fp

    if { !$found_p } {
        error "not found rev=$rev"
    }

    return $data

}


proc ::persistence::ss::compact {type_oid} {
    variable base_dir

    set name [binary encode base64 $type_oid]

    set filelist [glob \
        -tails \
        -directory $base_dir \
        "sysdb/sstable.by_name/${name}/+/${name}.sstable@*"]

    set filelist [lsort \
        -increasing \
        -command ::persistence::compare_mtime \
        $filelist]

    set llen [llength $filelist]
    if { $llen == 1 } {
        return
    }

    # log "compacting... type_oid=$type_oid #files=$llen"

    set i 0
    array set fp [list]
    array set idx [list]
    foreach infile_rev $filelist {
        set infile [file join $base_dir $infile_rev]

        # log file_size=[file size $infile]

        if { [file size $infile] == 0 } {
            # log "skip sstable (size=0)... $infile"
            continue
        }
        set fp($i) [open $infile]
        fconfigure $fp($i) -translation binary
        if { [catch {
            # log "i=$i (out of [llength $filelist]) infile=$infile"
            read_sstable idx $fp($i) $i
        } errmsg] } {
            log errmsg=$errmsg
            log errorInfo=$::errorInfo
            log exiting...
            exit
        }
        incr i
    }

    set clicks [clock clicks]
    set micros [clock microseconds]
    set filename [file join $base_dir "sysdb/sstable.by_name/${name}/+/${name}.sstable"]
    set outfile "${filename}@${micros}"
    set tmpfile "${filename}.${clicks}.part@${micros}"
    # log "merging sstables..."

    set row_keys [lsort [array names idx]]

    if { $row_keys eq {} } {
        return
    }

    set ofp [open $tmpfile "w"]
    fconfigure $ofp -translation binary
    set map [list]
    foreach row_key $row_keys {
        set row_startpos [tell $ofp]
        ::util::io::write_string $ofp $row_key
        set idx($row_key) [lsort -command ::persistence::compare_files -index 0 $idx($row_key)]
        foreach item $idx($row_key) {
            lassign $item rev i pos
            seek $fp($i) $pos start
            ::util::io::read_string $fp($i) data
            ::util::io::write_string $ofp $rev
            ::util::io::write_string $ofp $data
            unset data
        }
        set row_endpos [tell $ofp]
        lappend map $row_key $row_endpos
        ::util::io::write_int $ofp $row_startpos
    }

    set start_of_indexmap [tell $ofp]
    assert { $start_of_indexmap > 0 }
    ::util::io::write_string $ofp $map
    ::util::io::write_int $ofp $start_of_indexmap
    close $ofp

    for {set i 0} { $i < [llength $filelist] } {incr i} {
        close $fp($i)
        set infile_rev [lindex $filelist $i]
        set infile [file join $base_dir $infile_rev]
        file delete $infile
    }

    file rename ${tmpfile} ${outfile}
    # log "merged sstables, new file: $outfile"
}

proc ::persistence::ss::dump {sorted_revs} {
    variable base_dir
    variable ::persistence::mem::__mem

    set micros [clock microseconds]

    set fp ""
    set i ""
    set j ""
    set row_startpos ""
    set map [list]
    foreach rev $sorted_revs {

        lassign [split_oid $rev] ks cf_axis row_key column_path

        if { $i ne "${ks}/${cf_axis}" } {
            if { $row_startpos ne {} } {
                set row_endpos [tell $fp]
                lappend map $j $row_endpos
                ::util::io::write_int $fp $row_startpos
            }
            if { $fp ne {} } {
                set start_of_indexmap [tell $fp]
                ::util::io::write_string $fp $map
                ::util::io::write_int $fp $start_of_indexmap
                close $fp

                if { [catch {
                    file rename ${tmpfile} ${outfile}
                } errmsg] } {
                    log errmsg=$errmsg
                    log errorInfo=$::errorInfo
                    log exiting...
                    exit
                }

                # log "sstable renamed"
                compact $i
            }
            set i "${ks}/${cf_axis}"
            set j ""
            set name [binary encode base64 $i]
            set filename [file join $base_dir "sysdb/sstable.by_name/${name}/+/${name}.sstable"]
            set outfile "${filename}@${micros}"
            set tmpfile "${filename}.part@${micros}"
            file mkdir [file dirname ${tmpfile}]
            set fp [open ${tmpfile} "w"]
            fconfigure $fp {*}$__mem(${rev},codec_conf)
        }

        if { $j ne $row_key } {
            if { $row_startpos ne {} } {
                set row_endpos [tell $fp]
                lappend map $j $row_endpos
                ::util::io::write_int $fp $row_startpos
            }
            set j $row_key
            set row_startpos [tell $fp]
            ::util::io::write_string $fp $row_key
        }

        ::util::io::write_string $fp ${rev} ;# $__mem(${rev},oid)
        ::util::io::write_string $fp $__mem(${rev},data)

    }

    if { [info exists fp] && [info exists j] } {
        if { $j ne {} } {
            set row_endpos [tell $fp]
            lappend map $j $row_endpos
            ::util::io::write_int $fp $row_startpos
        }
        if { $fp ne {} } {
            set start_of_indexmap [tell $fp]
            ::util::io::write_string $fp $map
            ::util::io::write_int $fp $start_of_indexmap
            close $fp

            if { [catch {
                file rename ${tmpfile} ${outfile}
            } errmsg] } {
                log errmsg=$errmsg
                log errorInfo=$::errorInfo
                log exiting...
                exit
            }

        }
    }

}

if {1} {
    proc ::persistence::ss::readfile {rev args} {
        assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] } {
            log failed,rev=$rev
        }

        set codec_conf $args

        lassign [split_oid $rev] ks

        if { $ks eq {sysdb} } {
            return [::persistence::fs::readfile $rev {*}$codec_conf]
        } else {

            # log "retrieving column (=$rev) from sstable"

            set data [::persistence::ss::read_sstable_column $rev {*}$codec_conf]
            
            #log #length=[string length $data]

            return $data

        }

    }

    proc ::persistence::ss::writefile {rev args} {
        assert { [is_column_rev_p $rev] || [is_link_rev_p $rev] } {
            log failed,rev=$rev
        }

        log "writing column (=$rev) to sstable"
        set filename [get_filename ${rev}]
        error "not implemented yet"
        set codec_conf $args
        return [::util::writefile ${filename} {*}$codec_conf]
    }

}
