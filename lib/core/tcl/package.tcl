proc ::load_package {package_name dir {version "0.1"}} {

    # Indicates that the given version of the package is now present in the 
    # interpreter.  It is typically invoked once as part of an ifneeded script,
    # and again by the package itself when it is finally loaded

    package provide ${package_name} ${version}

    set filelist [glob -types {f} -directory [file join ${dir} tcl] *.tcl]
    foreach {filename} ${filelist} {
        source ${filename}
    }
    unset filelist
}

proc ::unload_package {package_name} {
    package forget ${package_name}
}

#proc ::cleanup {PN cmd retcode result op} {
#    puts "cleanup PN=$PN cmd=$cmd retcode=$retcode result=$result op=$op"
#    rename ::load_${PN} {}
#}
#trace add execution ::load_${PN} leave "::cleanup ${PN}"



