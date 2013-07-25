#!/usr/bin/tclsh

proc default_text_search_config {} { return xo.xo__ts_cfg_greek }

set filename [lindex $argv 0]
set max_length 50

global data
set fp [open related_query_words.txt r]
while {![eof $fp]} {
    foreach {word id} [gets $fp] {
	set data($id) $word
	set data(!$id) !$word
    }
}
close $fp

set cmd "cat $filename"
set fp [open "|$cmd" r]

#for {set i 0} {$i < 1000} {incr i} {
#    set max_occ($i) 0
#}


puts {
    drop table xo.xo__buzz_related_tags;
    create table xo.xo__buzz_related_tags (
      support numeric(7,6) not null
     ,confidence numeric(7,6) not null
     ,occurence integer not null
     ,rule_size integer not null
     ,rule_head text not null
     ,rule_body text not null
     ,rule_ts_vector tsvector not null
    );
}
puts {copy xo.xo__buzz_related_tags from stdin with delimiter '\t';}

while {![eof $fp]} { 
    set line [gets $fp]
    if { $line ne {} } {
	set rule [string map {{{}} {}} [split [string map {{ -> } { } {(} {} {)} {}} $line] " "]]
	set itemset [lrange $rule 0 end-4]
	if { [llength $itemset] > $max_length } continue
	foreach {occ head support confidence} [lrange $rule end-3 end] break

	set body ""
	foreach id $itemset {
#	    puts -nonewline "[list $data($id)] "
	    append body "$data($id) "
	}
#	puts "($occ) -> $data($head) ($support, $confidence)"
	puts "$support\t$confidence\t$occ\t[llength $body]\t$data($head)\t$body\txxx"
    }
}
close $fp
puts {\.}

puts {create index xo__buzz_related_tags on xo.xo__buzz_related_tags using gist (rule_ts_vector);
update xo.xo__buzz_related_tags set rule_ts_vector=to_tsvector('simple',rule_body)||to_tsvector('[default_text_search_config]',rule_body);
vacuum full analyze xo.xo__buzz_related_tags;}