#!/usr/bin/tclsh

if {$argc > 0} {
    set dir [lindex $argv 0]
    set files [split [exec ls -f ${dir}]]
    foreach file $files {
	if {$file != "."} {
	    if {$file != ".."} {
		puts "${dir}/${file}"
	    }
	}
    }
} else { puts "Wrong argumengs. It takes one argument : the folder name with the articles" }
