#!/usr/bin/tclsh

global data
set fp [open words.txt r]
array set data [read $fp]
close $fp


#set cmd "psql -q -A -t -c \"select strip(to_tsvector('simple',last_crawl_content)) from xo.xo__sw__agg__url order by creation_date desc\" buzzdb"

set cmd "psql -q -A -h turing -U nsadmin -t -c \"select strip(ts_vector) from xo.xo__news_in_greek where creation_date > current_timestamp-'48 hours'::interval order by creation_date desc\" buzzdb"





set fp [open "|$cmd" r]

set count 0
while {![eof $fp]} { 
    foreach word [split [gets $fp] " "] {
	puts -nonewline "$data($word) "
    }
    puts ""
}
close $fp
