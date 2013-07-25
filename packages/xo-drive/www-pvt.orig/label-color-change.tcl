ad_page_contract {
    @author Neophytos Demetriou
} {
    id:integer,notnull
    bgcolor:trim,notnull
}

set Sw "CC0000"
set uEa "DEE5F2"
set vEa "E0ECFF" 
set wEa "DFE2FF" 
set xEa "E0D5F9" 
set yEa "FDE9F4" 
set zEa "FFE3E3" 
set AEa "FFF0E1" 
set BEa "FADCB3" 
set CEa "F3E7B3" 
set DEa "FFFFF4" 
set EEa "F9FFEF" 
set FEa "F1F5EC"
set GEa "5A6986" 
set HEa "206CFF" 
set IEa "0000CC" 
set JEa "5229A3" 
set KEa "854F61" 
set LEa "EC7000" 
set MEa "B36D00" 
set NEa "AB8B00" 
set OEa "636330" 
set PEa "64992C" 
set QEa "006633"

set BASE_COLORS "$uEa $vEa $wEa $xEa $yEa $zEa $GEa $HEa $IEa $JEa $KEa $Sw $AEa $BEa $CEa $DEa $EEa $FEa $LEa $MEa $NEa $OEa $PEa $QEa"


set L [llength $BASE_COLORS]
for {set i 0} {$i < $L } {incr i} {
    set color([lindex $BASE_COLORS $i]) [lindex $BASE_COLORS [expr { ($i + 6) % $L }]]
}

if { ![info exists color(${bgcolor})] } {
    doc_return 200 text/plain NOT-${id}-${color}
    return
} else {
    set fontcolor $color(${bgcolor})
}

set pathexp [list "User [ad_conn user_id]"]
set folder [Content_Item_Label new \
		-mixin ::db::Object \
		-pathexp $pathexp \
		-id $id]

$folder set __update(extra) "coalesce(extra,'')::hstore || [ns_dbquotevalue fontcolor=>${fontcolor},bgcolor=>${bgcolor}]"

$folder do self-update

doc_return 200 text/plain ok-${id}-${bgcolor}-${fontcolor}