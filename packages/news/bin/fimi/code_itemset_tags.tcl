#!/usr/bin/tclsh

set username nsadmin
set hostname aias
set words_file [lindex $argv 0]
set stopwords_file [lindex $argv 1]


set extra_sql ""
if { [llength $argv] == 3 } {
    set number_of_days [lindex $argv 2]
    set extra_sql "and creation_date > current_timestamp -'${number_of_days} days'::interval"
}

# BASED ON TAGS
set cmd "psql -q -A -h $hostname -U $username -t -c \"select translate(tags,'\\r\\n',' ') from xo.xo__sw__agg__url where buzz_p and language='el' and tags is not null ${extra_sql} order by creation_date desc\" buzzdb"




set stopwords_fp [open $stopwords_file r]
while {![eof $stopwords_fp]} {
    set stop([string tolower [gets $stopwords_fp]]) 1
}
close $stopwords_fp



set words_fp [open $words_file w]
set input_fp [open "|$cmd" r]

if { 1 } {
    set regexp {([^ \.a-zA-Z0-9α-ωΑ-ΩΆΈΊΏΎΉΪΫήάέόώίύϋϊΐΰς])}
} else {
    set regexp {([^ \.a-zA-Zα-ωΑ-ΩΆΈΊΏΎΉΪΫήάέόώίύϋϊΐΰς])}
}


set error_count -1
set count -1
while {![eof $input_fp]} { 
    set basket {}
    set skip_p false
    if { [catch {
	set line [join [gets $input_fp]]
	set line [string trim [regsub -all -- $regexp $line { }]]
    } errmsg] } {
	incr error_count
	### puts "error_line=$line"
	set skip_p true
    }
    if { $line eq {} } {
	set skip_p true
    }

    set new_words ""
    if { !$skip_p } {
	foreach word $line {
	    ## puts $word
	    if {[catch {
		set word [list [string trim [string tolower $word]]]
	    } errmsg]} {
		incr error_count
		### puts "error=$word"
		continue
	    }
	    if { [string length $word] < 2  || [info exists stop($word)] } {
		continue
	    }
	    if { ![info exists data($word)]} {
		set data($word) [incr count]
		puts $words_fp "$word $count"
	    }
	    lappend basket $data($word)
	}
	if { $basket ne {} } {
	    #puts [lsort -integer $basket]
	    puts $basket
	}
    }
}
close $input_fp
close $words_fp

#puts "error_count = $error_count"