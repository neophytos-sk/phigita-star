package require crc32 

ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer
    name:trim
    oldname:trim
}

if { ![string is alnum [string map {- {} { } {}} ${name}]] } {
    doc_return 200 text/plain "Sorry, only letters, numbers (0-9), dashes (-), and spaces are allowed."
    return
} elseif { [string length ${name}] > 30 } {
    doc_return 200 text/plain "Sorry, your label must be between 1 and 30 characters long."
    return
}


set pathexp [list "User [ad_conn user_id]"]
set label [::Blog_Item_Label new -pathexp ${pathexp} -mixin ::db::Object -id ${id} -name ${name} -name_crc32 [crc::crc32 -format %d ${name}]]

if {[catch "${label} do self-update" errmsg]} {
    set info "You already have a label named \"${name}\""
    # NE = Name Exists
    set status "NE"
} else {
    set info "The label \"${oldname}\" was renamed to \"${name}\""
    # NU = Name Updated
    set status "NU"
}

set response [list]
lappend response "Label-ID: ${id}"
lappend response "Label-Name: ${name}"
lappend response "Info-Text: ${info}"
lappend response "S: ${status}"


doc_return 200 text/plain [join ${response} \n]
