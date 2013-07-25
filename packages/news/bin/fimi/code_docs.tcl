#!/usr/bin/tclsh

set username nsadmin
set hostname aias

set length 1000

global stop

proc trigrams text {
    global stop
    set res {}
    set last " "
    set prev [lindex $text 0]
    foreach word [lrange [split "$text " " "] 1 end] {
	if { [info exists stop($word)] } {
	    continue
	}
        lappend res [join [list $last $prev $word] -]
        set last $prev
        set prev $word
    }
    set res
}


set words_file [lindex $argv 0]
set stopwords_file [lindex $argv 1]
set docs_file [lindex $argv 2]
set num_hours [lindex $argv 3]

# BASED ON TAGS
set cmd "/opt/postgresql/bin/psql -q -A -h $hostname -U $username -t -c \"select url_sha1 || '|' || translate(substr(last_crawl_content,0,${length}),'\\r\\n|',' ') from xo.xo__sw__agg__url where creation_date > current_timestamp-'${num_hours} hours'::interval order by creation_date desc\" buzzdb"


set stopwords_fp [open $stopwords_file r]
while {![eof $stopwords_fp]} {
    set stop([string tolower [gets $stopwords_fp]]) 1
}
close $stopwords_fp



set words_fp [open $words_file w]
set input_fp [open "|$cmd" r]
set docs_fp [open $docs_file w]

if { 1 } {
    set regexp {([^ \-\.a-zA-Z0-9α-ωΑ-ΩΆΈΊΏΎΉΪΫήάέόώίύϋϊΐΰς])}
} else {
    set regexp {([^ \-\.a-zA-Zα-ωΑ-ΩΆΈΊΏΎΉΪΫήάέόώίύϋϊΐΰς])}
}

set count_docs 0
set error_count -1
set count -1
while {![eof $input_fp]} { 
    set basket {}
    set skip_p false
    if { [catch {
	lassign [split [gets $input_fp] {|}] url text
	set line [string trim [regsub -all -- $regexp $text { }] {. -}]
    } errmsg] } {
	incr error_count
	###puts "error_line=$errmsg"
	set skip_p true
	continue
    }
    if { $line eq {} } {
	set skip_p true
    }

    set new_words ""
    if { !$skip_p } {
	set line [trigrams $line]
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
	    puts $docs_fp "${count_docs} ${url}"
	    incr count_docs
	}
    }
}

close $docs_fp
close $input_fp
close $words_fp

#puts "error_count = $error_count"