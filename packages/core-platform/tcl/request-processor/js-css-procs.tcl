::xotcl::THREAD create JS {

    proc write_to_file {text filename} {
	set fp [open ${filename} w]
	fconfigure $fp -encoding binary
	puts $fp $text
	close $fp
    }

    proc minimize {name targetName} {

	### /opt/naviserver/bin/jscompact --infile=$name --outfile=${targetName}-tmp

	set YUICOMPRESSOR /opt/yuicompressor/build/yuicompressor-2.2.5.jar
	set JAVA /opt/jdk/bin/java

	set cmd "${JAVA} -jar ${YUICOMPRESSOR} --type js --charset utf-8 -o ${targetName}-tmp $name"
	ns_log notice "JS->minimize cmd=$cmd"

	if {[catch "exec -- /bin/sh -c \"${cmd} || exit 0\" 2> /dev/null" errmsg]} {
	    ns_log notice "jscompact error: $errmsg"
	    #set fp [open $name r]
	    #set data [read $fp]
	    #close $fp

	    #set jsdata [jsmin::jsmin $data]

	    #set fp [open $targetName w]
	    #puts $fp $jsdata
	    #close $fp
	}
	if {[catch "exec -- /bin/sh -c \"/opt/naviserver/bin/jspack.sh ${targetName}-tmp ${targetName}; rm ${targetName}-tmp || exit 0\" 2> /dev/null" errmsg]} {
	    ns_log notice "jspack error: $errmsg"
	}
    }

} -persistent 1


::xotcl::THREAD create CSS {

    proc minimize {infile outfile} {

        set YUICOMPRESSOR /opt/yuicompressor/build/yuicompressor-2.2.5.jar
        set JAVA /opt/jdk/bin/java

	set cmd "${JAVA} -jar ${YUICOMPRESSOR} --type css --charset utf-8 -o ${outfile} $infile"
	ns_log notice "CSS->minimize cmd=$cmd"
	exec -- /bin/sh -c "${cmd}  || exit 0" 2> /dev/null
	
	return

	set fp [open $name r]
	set data [read $fp]
	close $fp
	
	set fp [open $targetName w]
	puts $fp [css_compress $data]
	close $fp
    }

    proc css_compress {css} {
	# remove comments
	set result [regsub -all -- {\/[*][^*]*[*]+([^/][^*]*[*]+)*\/} $css {}]
	#set result [string map {"\r\n" {} "\n" {} "\t" {}} $result]
	set result [string map {"\r\n" {} "\r" {} "\n" {} "\t" {}  "    " { } "    " { } "  " { }} $result]
	set result [string map {";   " {;} ";  " {;} "; " {;}} $result]
	return $result
    }


} -persistent 1