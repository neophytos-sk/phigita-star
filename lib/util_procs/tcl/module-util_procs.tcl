package provide util_procs 0.1


namespace eval ::util {;}


proc ::util::boolean {value} {
    return [expr { ![string is false -strict $value] }]
}

# ---------------------------------- numbers ------------------------------
 
proc ::util::dec_to_hex {num} {
    return [format "%x" $num]
}

proc ::util::hex_to_dec {hex} {
    return [expr "0x${hex}"]
}

# ---------------------------------- lists ------------------------------

proc ::util::head {list} {
    return [lindex $list 0]
}

proc ::util::prepend {prefix text} {
    return "${prefix}${text}"
}


# ---------------------------------- uri ------------------------------

proc ::util::host_from_url {url} {

    set host ""
    set re {://([^/]+)}
    regexp -- ${re} ${url} match host
    return ${host}
}

proc ::util::domain_from_host {host} {

    set re {([^\.]+\.)(com\.cy|ac.cy|gov.cy|gr|com|net|org|info|coop|int|co\.uk|org\.uk|ac\.uk|uk|co|__and so on__)$}

    if { [regexp -- ${re} ${host} whole domain tld] } {
	return ${domain}${tld}
    }

    error "could not match regexp to host=${host}"
}

proc ::util::domain_from_url {url} {

    set index [string first {:} ${url}]
    if { ${index} == -1 } {
	return
    }

    set scheme [string range ${url} 0 ${index}]
    if { ${scheme} ne {http:} && ${scheme} ne {https:} } {
	return
    }

    set host [host_from_url ${url}]

    return [::util::domain_from_host ${host}]
}


# ---------------------------------- files ------------------------------

proc ::util::readfile {filename} {
    set fp [open ${filename}]
    set data [read $fp [file size ${filename}]]
    close $fp
    return $data
}

proc ::util::writefile {filename data} {
    set fp [open $filename w]
    puts -nonewline $fp $data
    close $fp
}


proc ::util::ino {filename} {
    file stat $filename arr
    return $arr(ino)
}

proc ::util::newerFile {a b} {
    return [expr {[file mtime $a] > [file mtime $b]}]
}

proc ::util::newerFileThan {path mtime} {
    return [expr {[file exists $path] && ([file mtime $path] > $mtime)}]
}


# findFiles
# basedir - the directory to start looking in
# pattern - A pattern, as defined by the glob command, that the files must match
proc ::util::findFiles { basedir pattern } {

    # Fix the directory name, this ensures the directory name is in the
    # native format for the platform and contains a final directory seperator
    set basedir [string trimright [file join [file normalize $basedir] { }]]
    set fileList {}

    # Look in the current directory for matching files, -type {f r}
    # means ony readable normal files are looked at, -nocomplain stops
    # an error being thrown if the returned list is empty
    foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
        lappend fileList $fileName
    }

    # Now look for any sub direcories in the current directory
    foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
        # Recusively call the routine on the sub directory and append any
        # new files to the results
        set subDirList [findFiles $dirName $pattern]
        if { [llength $subDirList] > 0 } {
            foreach subDirFile $subDirList {
                lappend fileList $subDirFile
            }
        }
    }
    return $fileList
}



# ------------------------ variables -----------------------------

namespace eval ::util::var {;}

proc ::util::var::get_value_if {varname {default ""}} {
    upvar $varname var
    if { [info exists var] } {
	return ${var}
    }
    return ${default}
}

# Returns 1 if the variable name exists in the caller's environment and is not the empty string.
proc ::util::var::exists_and_not_null { varname } {
    upvar 1 ${varname} var
    return [expr { [info exists var] && (${var} ne {}) }] 
} 

namespace eval ::util::var {
    namespace export *
}

namespace eval :: {
    namespace import ::util::var::*
}
