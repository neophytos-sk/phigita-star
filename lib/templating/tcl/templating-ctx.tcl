namespace eval ::templating::ctx {

    set import_pattern [setting "context_import_pattern"]
    log import_pattern $import_pattern
    if { $import_pattern eq {::httpd::kit::*} } {
        package require httpd
    }
    namespace import $import_pattern

}

