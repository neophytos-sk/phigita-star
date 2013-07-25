ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,multiple
}


set o [::agenda::Venue new \
	   -mixin ::db::Object \
	   -pool agendadb \
	   -id $id]

$o do bulk-delete -pk id

ns_return 200 text/html [::util::map2json b:success true]