namespace eval ::config {
    namespace ensemble create -map {
        get __get 
        set __set 
        use __use
        section __section 
        param __param
    }

    namespace export \
        setting_p \
        use_p

    ##
    # Example: __config(::persistence,write_ahead_log) on
    #

    variable __config
    array set __config [list]

    ##
    # Example: __default(::persistence,write_ahead_log) on
    #

    variable __default
    array set __default [list]

    ##
    # Example: __param(::persistence) "write_ahead_log client_server"
    #

    variable __param 
    array set __param [list]

    variable __current_nsp ""
}

proc ::config::__get {nsp name} {
    assert { vcheck("nsp","tcl_namespace") }
    variable __config
    variable __default
    set default_value [value_if __default(${nsp},${name}) ""]
    return [value_if __config(${nsp},${name}) $default_value]
}

proc ::config::__set {nsp name value} {
    assert { vcheck("nsp","tcl_namespace") }
    assert { vcheck("name", "tcl_varname") }

    variable __config
    set __config(${nsp},${name}) ${value}
}

proc ::config::__section {nsp} {
    assert { vcheck("nsp","tcl_namespace") }
    variable __current_nsp
    set __current_nsp ${nsp}
}

# defines a default value for a configuration parameter
proc ::config::__param {name value} {
    assert { vcheck("name","tcl_varname") }
    variable __default
    variable __current_nsp
    lappend __param(${__current_nsp}) ${name}
    set __default(${__current_nsp},${name}) ${value}
}

proc ::config::__use {name} {
    assert { vcheck("name","tcl_varname") }
    variable __current_nsp
    __set ${__current_nsp} "use_${name}" "on"
}

proc ::config::setting_p {param_name} {
    set caller [info frame -1]
    set type [dict get $caller type]
    if { $type eq {proc} } {
        set procname [dict get $caller proc]
        set nsp [namespace qualifier $procname]
    } elseif { $type in {eval source} } {
        variable __current_nsp
        set nsp $__current_nsp
    } else {
        error "setting: type=$type"
    }
    return [boolval [config get ${nsp} ${param_name}]]
}

proc ::config::use_p {flag} {
    set caller [info frame -1]
    set type [dict get $caller type]
    if { $type eq {proc} } {
        set procname [dict get $caller proc]
        set nsp [namespace qualifier $procname]
    } elseif { $type in {eval source} } {
        variable __current_nsp
        set nsp $__current_nsp
    } else {
        error "setting_p: type=$type"
    }

    return [boolval [config get ${nsp} "use_${flag}"]]
}

namespace eval :: {
    namespace import ::config::setting_p
    namespace import ::config::use_p
}
