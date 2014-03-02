package provide naivebayes 0.1

::xo::lib::require critcl
::xo::lib::require persistence

####
set dir [file dirname [info script]]
set package_dir [file dirname ${dir}]

source [file join $dir naivebayes.tcl]

set conf(clibraries) "-L/opt/naviserver/lib -lm"

set conf(includedirs) [list \
    /opt/naviserver/include \
    ${package_dir}/include/ \
    ${package_dir}/../persistence/c \
    ${package_dir}/../struct/include]

set conf(cinit) {
    // init_text

    Tcl_CreateObjCommand(ip, "::naivebayes::classify", naivebayes_ClassifyCmd, NULL, NULL);
    Tcl_CreateObjCommand(ip, "::naivebayes::learn", naivebayes_LearnCmd, NULL, NULL);

} 

set conf(csources) ${package_dir}/../persistence/c/persistence.c
set conf(ccode) [::util::readfile ${package_dir}/c/naivebayes.c]
::critcl::ext::cbuild_module [info script] conf

