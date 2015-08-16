proc ::load_package {package_name dir {version "0.1"}} {

    # Indicates that the given version of the package is now present in the 
    # interpreter.  It is typically invoked once as part of an ifneeded script,
    # and again by the package itself when it is finally loaded

    package provide ${package_name} ${version}

    variable __after_package_load

    set __after_package_load(${package_name}) ""

    set files [list]

    foreach {name patt} {"tcl" "*.tcl" "pdl" "*_pdl.tcl"} {

        # ${package_name},${name},enter

        set subdir [file join $dir $name]
        set files [concat $files \
            [lsort [glob -nocomplain -types "f" -directory $subdir $patt]]]

        # ${package_name},${name},leave

    }

    foreach filename $files {
        source $filename
    }

    unset files

    foreach script $__after_package_load(${package_name}) {
        uplevel #0 $script
    }

    # unset __after_package_load(${package_name})

}

proc ::unload_package {package_name} {
    package forget ${package_name}
    unset __after_package_load(${package_name})
}

#proc ::cleanup {PN cmd retcode result op} {
#    puts "cleanup PN=$PN cmd=$cmd retcode=$retcode result=$result op=$op"
#    rename ::load_${PN} {}
#}
#trace add execution ::load_${PN} leave "::cleanup ${PN}"



proc ::after_package_load {package_name script} {
    variable __after_package_load
    lappend __after_package_load(${package_name}) $script
}
