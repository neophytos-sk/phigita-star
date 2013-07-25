#!/usr/bin/tclsh

proc default_text_search_config {} { return xo.xo__ts_cfg_greek }

set filename [lindex $argv 0]


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


puts {
--    drop table xo.xo__buzz_related_query;
--    create table xo.xo__buzz_related_query (
--      occurrence integer not null
--     ,itemset_size integer not null
--     ,itemset_tags text not null
--     ,itemset_ts_vector tsvector not null
--    );
--begin;
--delete from xo.xo__buzz_related_query;
}
puts {copy xo.xo__buzz_related_query from stdin with delimiter '\t';}

while {![eof $fp]} { 
    set line [gets $fp]
    if { $line ne {} } {
	set itemset [lrange $line 0 end-1]
	set occ [string trim [lindex $line end] "()"]
	set itemset_tags ""
	foreach id $itemset {
	    append itemset_tags "$data($id) "
	}
	puts "$occ\t[llength $itemset_tags]\t$itemset_tags\txxx"
    }
}
close $fp
puts {\.}

puts {--create index xo__buzz_related_query_ts on xo.xo__buzz_related_query using gist (itemset_ts_vector);
--create index xo__buzz_related_query_occ__idx on xo.xo__buzz_related_query(occurrence);
update xo.xo__buzz_related_query set itemset_ts_vector=to_tsvector('simple',itemset_tags)||to_tsvector('[default_text_search_config]',itemset_tags);
--end;
vacuum full analyze xo.xo__buzz_related_query;}