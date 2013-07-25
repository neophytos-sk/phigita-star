#!/usr/bin/tclsh

source ../../naviserver_compat/tcl/module-naviserver_compat.tcl
::xo::lib::require critbit_tree
::xo::lib::require geoip

set blocks_cbt [::cbt::create $::cbt::UINT64_KEYS]
set filename ../data/geoip_blocks.csv
set fp [open $filename]
while { [gets $fp line] >= 0 } {
    lassign [split $line {|}] lo hi location_id
    #lassign [split $line {|}] lo hi_diff location_id
    #puts "adding ip range: lo=[val2ip $lo] hi_diff=$hi_diff location_id=$location_id"

    set lo_key [::util::uint32_to_bin ${lo}]
    set hi_key [::util::uint32_to_bin ${hi}]
    set key "${lo_key}${hi_key}"
    set value ${location_id}
    #set value "${hi_diff}_${location_id}"
    set data "${key}${value}"
    ::cbt::insert $blocks_cbt ${data}

}
close $fp

::cbt::write_to_file $blocks_cbt "../data/geoip_blocks.cbt_db"


# OLD CODE BELOW THIS LINE
#set data ${key}=${value}
#set data $lo=${hi_diff}_${location_id}
#::cbt::insert $blocks_cbt $key "    $value"
