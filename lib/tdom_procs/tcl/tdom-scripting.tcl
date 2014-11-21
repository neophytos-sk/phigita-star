namespace eval ::dom {;}

# tDOM does not provide such a proc,
# so we had to write one for cases like
# the following:
#
# $doc appendFromScript {
#   dom createNodeInContext elementNode somecmdname
# }
#
proc ::dom::createNodeInContext {node_type cmd_name args} {

    set nsp "::dom::_temp_::$node_type"

    if { [info proc "${nsp}::$cmd_name"] eq {} } {
        namespace eval ${nsp} [list dom createNodeCmd -returnNodeCmd $node_type $cmd_name]
    }

    set uplevel_nsp [uplevel [list namespace current]]
    set old_nsp_path [namespace path]
    namespace path ${uplevel_nsp}
    set node [uplevel [list ${nsp}::$cmd_name {*}${args}]]
    namespace path $old_nsp_path

    rename ${nsp}::$cmd_name {}

    return $node

}

namespace eval ::dom::scripting {
    namespace export *
}

proc ::dom::scripting::require_procs {} {
    namespace eval ::dom::scripting {
        dom createNodeCmd textNode t
        proc nt {text} { t -disableOutputEscaping ${text} }
    }
}
::dom::scripting::require_procs

proc ::dom::scripting::node_cmd {cmd_name} {

    set nsp [uplevel { namespace current }]

    namespace eval ${nsp} [list dom createNodeCmd -returnNodeCmd elementNode $cmd_name]

}

proc ::dom::scripting::text_cmd {cmd_name {default_string ""}} {

    set nsp [uplevel { namespace current }]

    set shadow_nsp ${nsp}::_shadow_

    namespace eval $shadow_nsp [list ${nsp}::node_cmd $cmd_name]

    proc ${nsp}::$cmd_name {args} [subst -nocommands -nobackslashes {

        set str {}
        if { [llength [set args]] % 2 == 1 } {
            set str [lindex [set args] end]
            set args [lrange [set args] 0 end-1]
        }

        set node [uplevel [list ${shadow_nsp}::$cmd_name {*}[set args]]]

        if { [set str] ne {} } {
            [set node] appendFromScript { ::dom::scripting::t [set str] }
        }

    }]

}

proc ::dom::scripting::proc_cmd {cmd_name cmd_handler args} {

    set nsp [uplevel { namespace current }]
    
    proc ${nsp}::$cmd_name {args} [subst -nocommands -nobackslashes {
        uplevel "{*}$cmd_handler $cmd_name ${args} [set args]"
    }]

}

proc ::dom::scripting::meta_cmd {cmd_name cmd_handler args} {

    # puts "meta_cmd $cmd_name $cmd_handler args=$args"

    set nsp [uplevel {namespace current}]

    if { [info proc ${nsp}::${cmd_handler}::define] eq {} } {
        namespace eval ${nsp} [subst -nocommands -nobackslashes {
            namespace eval $cmd_handler {
                proc define {typename args} {
                    # args = nodename -nsp somensp -name somename
                    # e.g. struct -nsp ::persistence::lang -name message { ... }
                    if { [string index [lindex [set args] 4] 0] eq {-} } {
                        error "usage: ${cmd_name} name ?-attname attvalue ...? ?script?"
                    }
                    # create node 
                    set node [uplevel "::dom::createNodeInContext elementNode {*}[set args]"]
                    # init
                    namespace eval ${nsp}::$cmd_handler init [set node] {*}$args
                }
            }
        }]
    }


    # when called, it will be as follows:
    # ::persistence::lang::class_helper::define struct somename -nsp ::persistence::lang -name somename ... { ... }
    uplevel [list proc_cmd $cmd_name "${nsp}::${cmd_handler}::define $cmd_name" -nsp ${nsp} -name]

}


proc ::dom::scripting::dtd {dtd} {

    set nsp [uplevel { namespace current }]

    namespace eval ${nsp} [list variable dtd $dtd]
}

proc ::dom::scripting::define_lang {nsp script} {

    if { [string range ${nsp} 0 1] ne {::} } {
        error "lang namespace must be fully qualified name"
    }

    namespace eval ${nsp} {
        namespace import -force \
            ::dom::scripting::meta_cmd \
            ::dom::scripting::node_cmd \
            ::dom::scripting::text_cmd \
            ::dom::scripting::proc_cmd \
            ::dom::scripting::dtd

    }

    proc ${nsp}::require_procs {} [list namespace eval ${nsp} ${script}]

    ${nsp}::require_procs

}

proc ::dom::scripting::extend_lang {nsp script} {

    set i 0
    while { [info proc ${nsp}::_require_procs_${i}] ne {} } {
        incr i
        if { $i > 100 } {
            error "something is wrong or too many extension to the language"
        }
    }

    rename ${nsp}::require_procs ${nsp}::_require_procs_${i}

    proc ${nsp}::require_procs {} [list ${nsp}::_require_procs_${i}; namespace eval ${nsp} ${script}]

    ${nsp}::require_procs

}

proc ::dom::scripting::require_lang {nsp} {

    if { ![namespace exists ${nsp}] } {
        error "no such namespace / lang"
    }

    ${nsp}::require_procs

}

proc ::dom::scripting::source_inscope {filename nsp} {

    namespace inscope ${nsp} [list source $filename]

}

proc ::dom::scripting::source_tdom {filename nsp {root_element_name ""}} {

    if { $root_element_name eq {} } {

        set ext [file ext $filename]

        set root_element_name [string range $ext 1 end]

    }

    set doc [dom createDocument $root_element_name]

    set ::__source_tdom_doc $doc

    set root [$doc documentElement]

    set script "namespace inscope ${nsp} { source $filename }"

    if { [catch {$root appendFromScript $script} errmsg options] } {

        unset ::__source_tdom_doc

        $doc delete

        array set options_arr $options

        error $errmsg $options_arr(-errorinfo)

    } else {

        unset ::__source_tdom_doc

        return $doc

    }

}

proc ::dom::scripting::validate {lang_nsp node} {

    variable ${lang_nsp}::dtd

    set xml [$node asXML]
    set tmpfile /tmp/somelang.xml
    set fp [open $tmpfile w]
    puts $fp "${dtd}\n${xml}"
    close $fp

    if { [catch {exec /usr/bin/xmllint --valid --noout $tmpfile} errmsg options] } {

        array set options_arr $options

        lassign $options_arr(-errorcode) _childstatus_ _pid_ errorcode

        array set errortext {
            0 "No error"
            1 "Unclassified"
            2 "Error in DTD"
            3 "Validation error"
            4 "Validation error"
            5 "Error in schema compilation"
            6 "Error writing output"
            7 "Error in pattern (generated when --pattern option is used)"
            8 "Error in Reader registration (generated when --chkregister option is used)"
            9 "Out of memory error"
        }

        puts "--->>> $errortext($errorcode)"

        set lines [regsub -all {\n\/} $errmsg "\x01\/"]
        set lines [split $lines "\x01"]
        foreach line $lines {

            lassign [split $line {:}] filename line_number which_element what_error error_message 

            puts "filename: $filename"
            puts "line: $line_number"
            puts "which element: $which_element"
            puts "what error: $what_error"
            puts "error message: $error_message"
        }

    }

}

namespace import -force \
    ::dom::scripting::define_lang \
    ::dom::scripting::require_lang \
    ::dom::scripting::extend_lang \
    ::dom::scripting::source_inscope \
    ::dom::scripting::source_tdom



