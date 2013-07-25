package require crc32 

ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    name:trim
    value:trim
}

set pathexp [list "User [ad_conn user_id]"]
set bm [::bm::Bookmark new -mixin ::db::Object -pathexp ${pathexp} -id ${id}]
$bm do self-load
${bm} set ${name} ${value}


if {[catch "${bm} do self-update" errmsg]} {
    set info "problem with update"
    # NE = Name Exists
    set status "UE"
} else {
    set info "The attribute \"${name}\" was updated to \"${value}\""
    # AU = Attribute Updated
    set status "AU"
    ::xo::db::touch main.xo.xo__sw__agg__url
}

set response [list]
lappend response "Bookmark-ID: ${id}"
lappend response "AN: ${name}"
lappend response "AV: ${value}"
lappend response "Info-Text: ${info}"
lappend response "S: ${status}"

ns_set put [ns_conn outputheaders] Cache-Control no-cache
ns_set put [ns_conn outputheaders] Pragma no-cache
ns_set put [ns_conn outputheaders] Expires -1
doc_return 200 text/plain [join ${response} \n]
