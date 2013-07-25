ad_page_contract {

    @author Neophytos Demetriou

} {
    id:notnull,integer
    body:notnull,stx
    ctx_uid:integer,notnull
}


set pathexp [list "User ${ctx_uid}"]
set bic [Blog_Item_Comment new \
	    -mixin ::db::Object \
	    -pathexp ${pathexp} \
	     -id ${id} \
	     -comment ${body}]

${bic} do self-update

ns_returnredirect ".."
