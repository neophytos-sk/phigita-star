
namespace eval ::dom::scripting {
    namespace export *
}

dom createNodeCmd textNode t

proc ::dom::scripting::node_cmd {cmd_name} {

    set nsp [uplevel { namespace current }]

    namespace eval ${nsp} [list dom createNodeCmd -returnNodeCmd elementNode $cmd_name]

}

proc ::dom::scripting::text_cmd {cmd_name {default_string ""}} {

    set nsp [uplevel { namespace current }]

    set shadow_nsp ${nsp}::shadow 

    namespace eval $shadow_nsp [list ${nsp}::node_cmd $cmd_name]

    proc ${nsp}::$cmd_name [list [list str $default_string]] [list ${shadow_nsp}::$cmd_name { t $str }]

}

proc ::dom::scripting::proc_cmd {cmd_name proc_name} {

    set nsp [uplevel { namespace current }]
    
    proc ${nsp}::$cmd_name {args} "$proc_name ${cmd_name} {*}\${args}"

}

proc ::dom::scripting::define_lang {nsp script} {

    if { [string range ${nsp} 0 1] ne {::} } {
        error "lang namespace must be fully qualified name"
    }

    namespace eval ${nsp} {
        namespace import -force \
            ::dom::scripting::node_cmd \
            ::dom::scripting::text_cmd \
            ::dom::scripting::proc_cmd

    }

    proc ${nsp}::require_procs {} [list namespace eval ${nsp} ${script}]

    ${nsp}::require_procs

}

proc ::dom::scripting::require_lang {nsp} {

    if { ![namespace exists ${nsp}] } {
        error "no such namespace / lang"
    }

    ${nsp}::require_procs

}

proc ::dom::scripting::source_tdom {filename nsp {root_element_name ""}} {

    if { $root_element_name eq {} } {

        set ext [file ext $filename]

        set root_element_name [string range $ext 1 end]

    }

    set doc [dom createDocument $root_element_name]

    set root [$doc documentElement]

    set script "namespace inscope ${nsp} { source $filename }"

    if { [catch {$root appendFromScript $script} errmsg] } {

        $doc delete

        error $errmsg

    } else {

        return $doc

    }

}

namespace import -force \
    ::dom::scripting::define_lang \
    ::dom::scripting::require_lang \
    ::dom::scripting::source_tdom


