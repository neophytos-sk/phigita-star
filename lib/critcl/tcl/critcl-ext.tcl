package require core
package require util_procs

namespace eval ::critcl::ext {;}

proc ::critcl::ext::get_value_if {varname {default ""}} {
    upvar $varname var
    if { [info exists var] } {
        return ${var}
    }
    return ${default}
}

namespace eval ::util {;} 
proc ::util::ino {filename} {
    file stat $filename arr
    return $arr(ino)
}

proc ::critcl::ext::get_build_dir {} {
    return /web/data/build
}

proc ::critcl::ext::get_build_rootname {filename} {

    set performance_mode_p [::xo::kit::performance_mode_p]

    set rootname [file rootname [file normalize $filename]]
    # dereference possible symbolic link in acs_root_dir
    set root_dir [file normalize [file normalize [acs_root_dir]/www]/..]

    set root_dir_len [string length $root_dir]
    set prefix_dir_of_rootname [string range $rootname 0 [expr {$root_dir_len - 1}]]
    if { $prefix_dir_of_rootname eq $root_dir } {
        set rootname [string range $rootname $root_dir_len end]
    }

    set build_dir [get_build_dir]
    set build_rootname ${build_dir}/${performance_mode_p}/${rootname}

    if { ![file isdirectory [file dirname $build_rootname]] } {
        file mkdir [file dirname $build_rootname]
    }

    return ${build_rootname}
}

proc ::critcl::ext::latest_mtime {inputfile} {

    set templatingdir [file join [acs_root_dir] lib/templating]

    # latest mtime for the files in the templating package
    set filelist [file __find $templatingdir *]

    # add the source file
    lappend filelist $inputfile

    # add file dependencies
    set depfile [get_build_rootname $inputfile].tdp_dep
    if { [file readable $depfile] } {
        foreach filename [::util::readfile $depfile] {
            lappend filelist $filename
        }
    }

    set mtime 0
    foreach filename $filelist {
        if { [::util::newerFileThan $filename $mtime] } {
            set mtime [file mtime $filename]
        }
    }

    return $mtime
}

proc ::critcl::ext::get_base_rootname {filename} {
    set build_rootname [get_build_rootname $filename]
    set latest_mtime [latest_mtime ${filename}]
    return "${build_rootname}.[::util::ino $filename].${latest_mtime}"
}


proc ::critcl::ext::get_outdir {filename} {
    return [file dirname [get_build_rootname $filename]]
    #return /web/local-data/critcl
}

proc ::critcl::ext::get_ininame {filename} {
    set mode [::xo::kit::performance_mode_p]
    set ino [::util::ino $filename]
    set rootname [file rootname [file tail $filename]]
    set ininame [string totitle [string map {"-" "_"} $rootname]]_${mode}_${ino}
    #set ininame [string totitle [string map {"-" "_"} $rootname]]
    return ${ininame}
}

proc ::critcl::ext::get_sharedlib {filename} {
    set sharedlibext [info sharedlibextension]
    return [get_base_rootname $filename]${sharedlibext}
}

proc ::critcl::ext::cbuild_module {filename confArr} {

    upvar $confArr conf

    set includedirs [get_value_if conf(includedirs) ""]
    set clibraries [get_value_if conf(clibraries) ""]
    set csources [get_value_if conf(csources) ""]
    set cheaders [get_value_if conf(cheaders) ""]
    set cflags [get_value_if conf(cflags) ""]
    set init_code [get_value_if conf(cinit) ""]
    set c_code [get_value_if conf(ccode) ""]
    set debug_mode_p [get_value_if conf(debug_mode_p) 0]
    set keepsrc [get_value_if conf(keepsrc) 1]
    set language [get_value_if conf(language) ""]
    set combine [get_value_if conf(combine) "standalone"]

    set cachedir [get_build_dir]/cache
    set outdir [get_outdir $filename]
    set ininame [get_ininame $filename]
    set base [get_base_rootname $filename]

    ###

    set normalized_filename [file normalize ${filename}]
    set dir [file dirname $normalized_filename]

    set temp_includedirs [list]
    foreach includedir $includedirs {
        lappend temp_includedirs [file normalize [file join $dir $includedir]]
    }
    set includedirs $temp_includedirs

    ::critcl::reset

    if { $language ne {} } {
        ::critcl::config language $language
    }


    if { $cflags ne {} } {
        # "-Wall -pedantic"
        ::critcl::cflags ${cflags}
    }

    if { $debug_mode_p } { 
        ::critcl::debug all
        ::critcl::config force 1
    }

    ::critcl::cache $cachedir
    ::critcl::config outdir $outdir
    ::critcl::config combine $combine
    ::critcl::clibraries {*}${clibraries}
    ::critcl::config I {*}$includedirs
    ::critcl::csources {*}${csources}
    ::critcl::cheaders {*}${cheaders}

    ::critcl::ininame $ininame
    ::critcl::cinit $init_code {
        // init_exts
    } $normalized_filename
    
    ::critcl::ccode $c_code $normalized_filename

    set load 0
    set pretend_load 1
    set result [::critcl::cbuild ${normalized_filename} ${load} "" "" ${pretend_load} ${base}]
    lassign ${result} libfile ininame

    set sharedlib [get_sharedlib $filename]

    load $sharedlib $ininame

    # unset conf array
    array unset conf

    
    return ${result}
}
