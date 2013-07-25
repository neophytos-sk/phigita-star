#!/usr/bin/tclsh

set username nsadmin
set hostname turing

#set cmd "psql -q -A -t -c \"select strip(to_tsvector('simple',last_crawl_content)) from xo.xo__sw__agg__url order by creation_date desc\" buzzdb"

#set cmd "psql -q -A -t -c \"select strip(ts_vector) from xo.xo__news_in_greek order by creation_date desc\" buzzdb"

set cmd "psql -q -h $hostname -U $username -A -t -c \"select translate(last_crawl_content,'\r\n',' ') from xo.xo__sw__agg__url where creation_date > current_timestamp-'48 hours'::interval and buzz_p order by creation_date desc\" buzzdb"

set stopwords_fp [open stopwords.txt r]
while {![eof $stopwords_fp]} {
	set stop([gets $stopwords_fp]) 1
}
close $stopwords_fp

set words_fp [open words.txt w]

set input_fp [open "|$cmd" r]

if { 1 } {
    set regexp {([^a-zA-Z0-9α-ωΑ-ΩΆΈΊΏΎΉΪΫήάέόώίύϋϊΐΰς\-])}
} else {
    set regexp {([^a-zA-Zα-ωΑ-ΩΆΈΊΏΎΉΪΫήάέόώίύϋϊΐΰς\-])}
}

set count -1
while {![eof $input_fp]} { 
	set basket {}
    foreach word [split [regsub -all -- $regexp [gets $input_fp] { }] " "] {
	if { [string length $word] > 2 } {
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
