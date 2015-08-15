
# ::fs::find - search for files in a directory hierarchy 
# @param basedir {string} the directory to start looking in
# @param pattern {glob pattern} A pattern, as defined by the glob command, that the files must match
proc ::tcl::file::__find {
    {basedir "."} 
    {pattern "*"}
} {
        
    # Fix the directory name, this ensures the directory name is in the
    # native format for the platform and contains a final directory seperator
    set basedir [string trimright [file join [file normalize $basedir] { }]]

    set filelist {}
    set queue [list]
    lappend queue $basedir
    while { $queue ne {} } {
        set queue [lassign $queue dir]

        # Look in the current directory for matching files, -type {f r}
        # means ony readable normal files are looked at, -nocomplain stops
        # an error being thrown if the returned list is empty
        foreach filename [glob -nocomplain -type {f r} -directory $dir $pattern] {
            lappend filelist $filename
        }

        # Now look for any sub direcories in the current directory
        set subdirs [glob -nocomplain -type {d  r} -directory $dir *]
        foreach subdir $subdirs {
            # Recusively call the routine on the sub directory and append any
            # new files to the results
            lappend queue $subdir
            set seen($subdir) {}
        }
    }

    return $filelist
}

proc ::tcl::file::__newer_than {a b} {
    return [expr {[file mtime $a] > [file mtime $b]}]
}

proc ::tcl::file::__newer_than_mtime {path mtime} {
    return [expr {[file exists $path] && ([file mtime $path] > $mtime)}]
}



set ensemble "file"
set __config_map [namespace ensemble configure $ensemble -map]
lappend __config_map "__find" "::tcl::file::__find"
lappend __config_map "__newer_than" "::tcl::file::__newer_than"
lappend __config_map "__newer_than_mtime" "::tcl::file::__newer_than_mtime"
namespace ensemble configure $ensemble -map $__config_map
unset __config_map

