#!/usr/bin/tclsh

if {$argc > 0} {
    set dir [ lindex $argv 0 ]
    #set s [ exec ls ${dir} ]
    #set files [ split $s ]
    set files [glob ${dir}/*]
    exec mkdir "${dir}_texts"
    
    foreach file $files {
	exec ./extracttext.tcl "${dir}/${file}" "${dir}_texts/${file}.txt"
    }
} else { 
    puts "Wrong argumengs. It takes one argument : the folder name with the articles" 
}

