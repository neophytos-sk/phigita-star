#!/usr/bin/tclsh

set username nsadmin
set hostname aias


# BASED ON TAGS
set cmd "psql -q -A -h $hostname -U $username -t -c \"select strip(to_tsvector('simple',last_crawl_content)) from xo.xo__sw__agg__url where buzz_p and language='el' order by creation_date desc limit 100000\" buzzdb"


set stopwords_fp [open stopwords.txt r]
while {![eof $stopwords_fp]} {
    set stop([string tolower [gets $stopwords_fp]]) 1
}
close $stopwords_fp



set words_fp [open related_query_words.txt w]
set input_fp [open "|$cmd" r]

if { 1 } {
    set regexp {([^a-zA-Z0-9α-ωΑ-ΩΆΈΊΏΎΉΪΫήάέόώίύϋϊΐΰς\-])}
} else {
    set regexp {([^a-zA-Zα-ωΑ-ΩΆΈΊΏΎΉΪΫήάέόώίύϋϊΐΰς\-])}
}

set count -1
while {![eof $input_fp]} { 
	set basket {}
    foreach word [join [gets $input_fp]] {
	set word [list [string trim [string tolower [regsub -all -- $regexp $word { }]]]]
	if { [string length $word]>2 && ![info exists stop($word)] } {
	    if { ![info exists data($word)]} {
		set data($word) [incr count]
		puts $words_fp "$word $count"
	    }
	    lappend basket $data($word)
	}
    }
    if { $basket ne {} } {
	puts [lsort -integer $basket]
    }
}
close $input_fp
close $words_fp
