# Requires: emerge netpbm
# To use this script, you will also need the following installed:
#
# latex, dvips (part of the teTeX package)
# ghostscript (version 6.5 or greater works)
# ppmtogif (part of the netpbm package http://netpbm.sourceforge.net/ )


ad_page_contract {
	@author Neophytos Demetriou
} {
    {eqn:trim ""}
    {s:trim ""}
}

if { ![string equal ${s} [ns_sha1 "MaThSeCrEt-${eqn}-83765md"]]} {
    rp_returnnotfound
    return
}


if {[string equal ${eqn} ""]} {
    rp_serve_concrete_file [acs_root_dir]/www/graphics/cleardot.gif
} else {

    set dirname [acs_root_dir]/www/math/
    #set cachedirname ${dirname}cache/
    # Move the gif file into cachedirname only if the compilation was successfull
    cd ${dirname}
    set filename [ad_conn user_id]-[ns_sha1 ${eqn}]
    if {[file exists ${dirname}${filename}.png]} { 
	rp_serve_concrete_file ${dirname}${filename}.png
    }

    set fp [open ${dirname}${filename}.tex  w]
    puts -nonewline ${fp} [subst -nobackslashes -nocommands {\documentclass[amsart]{article}
\pagestyle{empty}
\begin{document}
${eqn}
\end{document}
    }]
    close ${fp}

    exec -- /bin/sh -c "./textopng.sh ${filename} || exit 0" > /dev/null

    if {[file exists ${dirname}${filename}.png]} { 
	rp_serve_concrete_file ${dirname}${filename}.png
    } else {
	rp_serve_concrete_file [acs_root_dir]/www/graphics/cleardot.gif
    }
    exec -- /bin/sh -c "./cleanup.sh ${filename} || exit 0" > /dev/null

}
