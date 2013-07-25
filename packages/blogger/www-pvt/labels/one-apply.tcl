package require crc32

ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull
    {NewFol:optional ""}
    destBox
} -validate {
    label_name -requires {NewFol destBox} {

	if { ${destBox} == 0 } {
	    if { [string trim $NewFol] eq {} } {
		ad_complain "No label name provided"
	    }
	    if { ![string is alnum [string map {. {} - {} { } {} + {} & {}} ${NewFol}]] } {
		ad_complain "Illegal characters in label name."
	    }
	    if { [string length ${NewFol}] > 40 } {
		ad_complain "The name is too long (40 max chars)."
	    }
	}
    }

}

set pathexp [list "User [ad_conn user_id]"]

# A new label
if { ${destBox} == 0 } {

    set exists_p [Blog_Item_Label retrieve \
		      -pathexp "User [ad_conn user_id]" \
		      -output "id" \
		      -criteria "name = [ns_dbquotevalue ${NewFol}]"]

    if { [string equal ${exists_p} ""] } {
	set cat_id [Blog_Item_Label autovalue "User [ad_conn user_id]"]

	set labelObj [Blog_Item_Label new -volatile_p yes -pathexp ${pathexp} -mixin ::db::Object]

	${labelObj} set id ${cat_id}
	${labelObj} set name ${NewFol}
	${labelObj} set name_crc32 [::crc::crc32 -format %d ${NewFol}]
	${labelObj} set description ""
	${labelObj} do self-insert
	set destBox ${cat_id}
    } else {
	set destBox [${exists_p} set id]
	${exists_p} destroy
    }

    set map_exists_p 0

} else {

    set map_exists_aux [Blog_Item_Label_Map retrieve \
			  -pathexp "User [ad_conn user_id]" \
			  -output "1" \
			    -criteria "object_id=[ns_dbquotevalue ${id}] and label_id = [ns_dbquotevalue ${destBox}]"]

    if {![string equal ${map_exists_aux} ""]} {
	set map_exists_p 1
	${map_exists_aux} destroy
    } else {
	set map_exists_p 0
    }

}

if { !${map_exists_p} } {
    set mapObj [Blog_Item_Label_Map new -volatile_p yes -pathexp ${pathexp} -mixin ::db::Object]

    ${mapObj} set object_id ${id}
    ${mapObj} set label_id ${destBox}
    ${mapObj} set id ${id}
    ${mapObj} do self-insert
    ${mapObj} destroy

}

ad_returnredirect ../${id}
