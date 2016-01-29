namespace eval ::templating::ctx {

    set import_pattern [setting "context_import_pattern"]
    log import_pattern $import_pattern
    namespace import $import_pattern

}

