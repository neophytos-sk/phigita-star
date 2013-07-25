
#if { ![::xo::kit::performance_mode_p] } {
    ns_schedule_proc 90 ::xo::storage::dumpall
#}
