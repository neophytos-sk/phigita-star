ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    tags:trim
}

package require crc32

set pathexp [list "User [ad_conn user_id]"]
set o [Content_Item new \
	   -mixin ::db::Object \
	   -pathexp $pathexp \
	   -id $id]

set tags_list [::xo::fun::filter [::xo::fun::map x [split $tags {,}] {string trim $x}] x {$x ne {}}]

set tags_ia ""
array set tags_hash_ia [list]

if { ${tags_list} ne {} } {

    set tags_clause ""
    foreach tag $tags_list {
	lappend tags_clause [::util::dbquotevalue $tag]
    }
    set tags_clause ([join $tags_clause {,}])

    set ds_tags [::db::Set new \
		     -pathexp $pathexp \
		     -select [list "trim(xo__concatenate_aggregate( '{' || name || '} ' || id || ' '),', ') as tags_hash_ia"] \
		     -type ::Content_Item_Label \
		     -where [list "name in $tags_clause"]]

    $ds_tags load

    if { ![$ds_tags emptyset_p] } {
	array set tags_hash_ia [[$ds_tags head] set tags_hash_ia]
    }

    set tags_ia ""
    foreach tag $tags_list {

	if { [info exists __label($tag)] } {
	    continue
	} else {
	    set __label($tag) ""
	}

	if { [info exists tags_hash_ia($tag)] } {
	    lappend tags_ia $tags_hash_ia($tag)
	} else {
	    set tag_crc32 [crc::crc32 -format %d $tag]
	    set lo [::Content_Item_Label new \
			-pathexp ${pathexp} \
			-mixin ::db::Object \
			-name ${tag} \
			-name_crc32 ${tag_crc32}]

	    $lo rdb.self-insert {select true;}
	    set lo_id [[${lo} getConn] getvalue "select id from [${lo} info.db.table] where name=[::util::dbquotevalue ${tag}]"]
	    lappend tags_ia $lo_id
	}
    }

}

if { $tags_ia ne {} } {
    set tags_ia \{[join $tags_ia {,}]\}
}

$o beginTransaction

#select trim(xo__concatenate_aggregate( '{' || name || '} ' || id || ' '),', ') from xo__u814.xo__content_item_label where name in ('Google','PostgreSQL','Hypergraph Partitioning','HStore');


$o set tags_ia $tags_ia
$o set __reset(tags_ia) ""
$o rdb.self-update

#set docTextSql "select xo__concatenate_tsvector_aggregate(ts_vector) from xo__u[ad_conn user_id].xo__content_item_part where item_id=[nd_dbquotevalue $id]"
#### re-index title,description,tags here
#[$o getConn] do "update [$o info.db.table] set ts_vector=ts_vector || coalesce(setweight(to_tsvector('[default_text_search_config]',[::util::dbquotevalue $tags]),'B'),'') where id=[ns_dbquotevalue $id]"




$o endTransaction

ns_return 200 text/plain ok-${id}-${tags_ia}