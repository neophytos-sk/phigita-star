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


puts {
--    drop table xo.xo__buzz_itemset_tags;
--    create table xo.xo__buzz_itemset_tags (
--      occurrence integer not null
--     ,itemset_size integer not null
--     ,itemset_tags text not null
--     ,itemset_ts_vector tsvector not null
--    );
begin;
delete from xo.xo__buzz_itemset_tags;
}
puts {copy xo.xo__buzz_itemset_tags from stdin with delimiter E'\t';}

while {![eof $fp]} { 
    set line [string map {{(} { } {)} { }} [gets $fp]]
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

puts [subst -nobackslashes -novariables {--create index xo__buzz_itemset_tags on xo.xo__buzz_itemset_tags using gist (itemset_ts_vector);
--create index xo__buzz_itemset_occ__idx on xo.xo__buzz_itemset_tags(occurrence);
update xo.xo__buzz_itemset_tags set itemset_ts_vector=to_tsvector('simple',itemset_tags)||to_tsvector('[default_text_search_config]',itemset_tags);
end;
vacuum full analyze xo.xo__buzz_itemset_tags;}]