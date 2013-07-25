#!/usr/bin/tclsh

proc default_text_search_config {} { return xo.xo__ts_cfg_greek }

set filename [lindex $argv 0]
set words_file [lindex $argv 1]
set max_length 3

global data
set fp [open $words_file r]
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
puts {copy xo.xo__buzz_related_tags from stdin with delimiter E'\t';}

while {![eof $fp]} { 
    set line [string trim [gets $fp]]
    if { ${line} ne {} } {
	### (0.900000, 0.006189) 1399 <= 3627 3626 (        20)
	set rule [split [regsub -all {[ ]{2,}} [string map {{ <= } { } {(} {} {)} {} {,} {}} $line] { }]]
	### puts $rule

	lassign [lrange $rule 0 1] confidence support
	set head [string trim [lindex $rule 2]]
	set itemset [lrange $rule 3 end-1]
	set occ [lindex $rule end]
	
	set body ""
	foreach id $itemset {
	    append body "$data($id) "
	}
	set word_head $data($head)
	puts "$support\t$confidence\t$occ\t[llength $body]\t$word_head\t$body\txxx"
    }
}
close $fp
puts {\.}

puts [subst -nobackslashes -novariables {create index xo__buzz_related_tags on xo.xo__buzz_related_tags using gist (rule_ts_vector);
update xo.xo__buzz_related_tags set rule_ts_vector=to_tsvector('simple',rule_body)||to_tsvector('[default_text_search_config]',rule_body);
vacuum full analyze xo.xo__buzz_related_tags;}]