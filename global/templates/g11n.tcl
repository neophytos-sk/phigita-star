set translator_mode_p [lang::util::translator_mode_p]

if { $translator_mode_p } {
    global i18n_msgs
    if { ![info exists i18n_msgs] } {
	set i18n_msgs ""
    }
} else {
    set i18n_msgs ""
}



