
namespace eval ::dom::xpathFunc {

    array set mapping [list]

    set mapping_dir [::feed_reader::get_conf_dir]

    set filelist [glob -nocomplain -directory ${mapping_dir} *]

    foreach filename ${filelist} {
	set locale [string trimleft [file extension ${filename}] {.}]
	set mapping(${locale}) [::util::readfile ${filename}]
    }

}


proc ::dom::xpathFunc::normalizedate {ctxNode pos nodeListNode nodeList args} {

    if { [llength ${args}] ni { 4 6 } } {
	error "normalizedate(string): wrong # of args"
    }


    lassign ${args} \
	arg1Typ arg1Value \
	arg2Typ arg2Value \
	arg3Typ arg3Value


    set ts_string [::dom::xpathFuncHelper::coerce2string ${arg1Typ} ${arg1Value}]
    set locale $arg2Value

    variable mapping

    if { [info exists mapping(${locale})] } {

	set ts_string [string trim [string map $mapping(${locale}) ${ts_string}]]

    }

    if { ${ts_string} eq {now} } {
	set ts_string [clock format [clock seconds] -format "%Y%m%dT%H%M"]
    } elseif { [lindex ${ts_string} end] eq {ago} } {
	# TODO: convert pretty age to a timestamp
	set ts_string [::util::dt::age_to_timestamp ${ts_string} [clock seconds]]
    } else {
	set format ${arg3Value}	
	return [::dom::xpathFunc::returndate $ctxNode $pos $nodeListNode $nodeList string ${ts_string} string ${format} string ${locale}]
    }

    return [list string ${ts_string}]

}
