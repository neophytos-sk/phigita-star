namespace eval ::xo {;}

Class ::xo::FileManager -parameter {
    {magic_file /web/servers/service-phigita/share/ImageMagick/magic.xml}
}

::xo::FileManager instproc init {args} {

    my instvar __magic

    set fp [open [my magic_file]]
    fconfigure $fp -encoding binary
    set document [dom parse -channel $fp]
    close $fp
    set root [$document documentElement]


    foreach node [$root childNodes] {
	set name [$node getAttribute name]
	set extensions [string tolower [$node getAttribute extensions ""]]
	set offset [$node getAttribute offset]
	set target [subst -nocommands -novariables [$node getAttribute target]]
	set script [$node getAttribute script ""]
	set len [$node getAttribute length ""]
	if { $len eq {} } {
	    set len [string length $target]
	}
	lappend __magic [list $name $extensions $offset $target $len $script]
    }

}

::xo::FileManager instproc identify {tmpfile filename} {

    set file_extension [string tolower [file extension $filename]]

    set fp [open $tmpfile]
    fconfigure $fp -encoding binary
    set result ""
    foreach item [my set __magic] {

	lassign $item name extensions offset target len script


	if { ![info exists data(${offset},${len})] } {
	    seek $fp $offset
	    set data(${offset},${len}) [read $fp ${len}]
	}


	#if { $name eq {PDF} } { ns_log notice "name=$name offset=$offset target=$target data=$data(${offset},${len})" }
	
	set pass_p false
	if { $script ne {} } {
	    #ns_log notice {hex=[::util::string_to_hex $data(${offset},${len})] [subst [format $script $data(${offset},${len})]] [expr [subst [format $script $data(${offset},${len})]]]}
	    set pass_p [expr [subst [format $script $data(${offset},${len})]] == $target] 
	} else {
	    set pass_p [expr { $data(${offset},${len}) eq $target }]
	}

	if { $pass_p && ( ${extensions} eq {} || -1 != [lsearch -exact $extensions $file_extension] ) } {
	    lappend result $name
	}
    }
    close $fp
    return $result
}

::xo::FileManager create __FILE_MANAGER__
