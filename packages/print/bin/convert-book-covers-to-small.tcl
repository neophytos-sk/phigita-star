#!/usr/bin/tclsh
set files [glob -nocomplain /web/data/books/cover/b*jpg]
set count 0
foreach file $files {
    set dirname [file dirname $file]
    set filename [file tail $file]
    set new_file ${dirname}/s[string range $filename 1 end]

    #puts "dirname=$dirname filename=$filename new_file=$new_file"

    if { ![file exists $new_file] } {
	exec -- /bin/sh -c "convert -resize 100x100 ${file} ${new_file} || exit 0" 2> /dev/null
    }
    if { [incr count] % 1000 == 0 } { puts "count=$count" }
}
