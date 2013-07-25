ad_page_contract {
    @author Neophytos Demetriou
} {
    isbn:trim,notnull
}

set v_isbn [::isbn::convert_to_ean13 ${isbn}]

set o [db::Set new -pool bookdb -from xo.xo__book -where [list "isbn=[ns_dbquotevalue ${v_isbn}]"]]


tmpl::master {

    t [${o} set title]
    p
    t [${o} set authorlist]

}