ad_page_contract {
    @author Neophytos Demetriou
} {
    YYYY:trim,optional
    MM:trim,optional
    DD:trim,optional
    year:trim,optional
    month:trim,optional
    day:trim,optional
    label:trim,optional
    label_id:trim,optional
}
ns_returnredirect [export_vars -base ../blog/  -no_empty {YYYY MM DD year month day label label_id}]
