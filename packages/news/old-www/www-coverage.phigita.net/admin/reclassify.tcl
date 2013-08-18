ad_page_contract {
    @author Neophytos Demetriou
} {
    {numHours "2"}
}



set oTemp1 [db::Set new -pool newsdb -select * -from xo.xo__news_in_greek -where [list "creation_date>current_timestamp-[ns_dbquotevalue "$numHours hours"]::interval"] -order "creation_date desc"]
$oTemp1 load

foreach o [$oTemp1 set result] {
    set data [$o set ts_vector]
    set classification__tree_sk  [::bow::getClassTreeSk [::bow::getExpandedVector $data] 1821] 
    set classification__edition_sk  [::bow::getClassTreeSk [::bow::getExpandedVector $data] 1822] 
    ns_log notice "Reclassify url $url"
    [$oTemp1 getConn] do [subst {
	update xo.xo__sw__agg__url set 
	classification__tree_sk=[ns_dbquotevalue $classification__tree_sk]
	,classification__edition_sk=[ns_dbquotevalue $classification__edition_sk]
	where url=[ns_dbquotevalue [$o set url]]
    }]
}

doc_return 200 text/html ok
