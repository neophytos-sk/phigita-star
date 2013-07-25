package require crc32 

ad_page_contract {
    @author Neophytos Demetriou
} {
    name:trim
}

if { ![string is alnum [string map {- {} { } {}} ${name}]] } {
    doc_return 200 text/plain "Sorry, only letters, numbers (0-9), dashes (-), and spaces are allowed."
    return
} elseif { [string length ${name}] > 30 } {
    doc_return 200 text/plain "Sorry, your label must be between 1 and 30 characters long."
    return
}


set pathexp [list "User [ad_conn user_id]"]
set label [::Blog_Item_Label new -pathexp ${pathexp} -mixin ::db::Object -name ${name} -name_crc32 [crc::crc32 -format %d ${name}]]

if {[catch "${label} do self-insert" errmsg]} {
    set info "Label \"${name}\" already exists"
    # first zero in the code denotes an insert (the first action in CRUD)
    set status "OE"
} else {
    set info "Label \"${name}\" has been created"
    set status "OC"
}


set o [db::One new \
	   -pathexp ${pathexp} \
	   -select id \
	   -type ::Blog_Item_Label \
	   -where [list "name=[ns_dbquotevalue ${name}]"]]


set response [list]
lappend response "Label-ID: [${o} get id]"
lappend response "Label-Name: ${name}"
lappend response "Info-Text: ${info}"
lappend response "S: ${status}"


doc_return 200 text/plain [join ${response} \n]
