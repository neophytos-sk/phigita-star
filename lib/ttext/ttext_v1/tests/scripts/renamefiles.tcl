#!/usr/bin/tclsh

if {$argc > 0} {
    set dir [ lindex $argv 0 ]
    #set s [ exec ls ${dir} ]
    #set files [ split $s ]
    set files [glob ${dir}/*]
    set i 0
    exec mkdir "${dir}_numbered"
    foreach file $files {
	set f "${i}.txt"
	exec cp "${dir}/${file}" "${dir}_numbered/$f"
	set i [ expr $i + 1 ]
    }
} else { puts "Wrong argumengs. It takes one argument : the folder name with the articles" }