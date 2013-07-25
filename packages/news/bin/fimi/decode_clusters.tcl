#!/usr/bin/tclsh

proc default_text_search_config {} { return xo.xo__ts_cfg_greek }

set filename [lindex $argv 0]
set words_file [lindex $argv 1]
set docs_file [lindex $argv 2]

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

global doc
set fp [open $docs_file r]
while {![eof $fp]} {
    foreach {id url} [gets $fp] {
	set doc($id) http://buzz.phigita.net/admin/cache?url_sha1=$url
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
    set cluster_docs [gets $fp]
    set cluster_itemset [gets $fp]
    set line [string map {{(} { } {)} { }} ${cluster_docs}]
    if { $line ne {} } {
	set occ [string trim [lindex $line end] "()"]
	set cluster_docs [lrange $line 1 end-1]
	set cluster_words ""
	foreach word_id ${cluster_itemset} {
	    append cluster_words "$data($word_id) "
	}
	set cluster_urls ""
	foreach doc_id ${cluster_docs} {
	    append cluster_urls "$doc($doc_id) "
	}
	puts [join $cluster_urls \n]\n\n
	#puts "$occ\t[llength $cluster_words]\t$cluster_words\t${cluster_docs}\t${cluster_urls}\txxx"
    }
}
close $fp
puts {\.}

puts [subst -nobackslashes -novariables {--create index xo__buzz_itemset_tags on xo.xo__buzz_itemset_tags using gist (itemset_ts_vector);
--create index xo__buzz_itemset_occ__idx on xo.xo__buzz_itemset_tags(occurrence);
update xo.xo__buzz_itemset_tags set itemset_ts_vector=to_tsvector('simple',itemset_tags)||to_tsvector('[default_text_search_config]',itemset_tags);
end;
vacuum full analyze xo.xo__buzz_itemset_tags;}]