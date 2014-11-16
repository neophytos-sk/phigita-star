
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

    # proc ${nsp}::$cmd_name [list [list str $default_string]] [list ${shadow_nsp}::$cmd_name { t $str }]

    proc ${nsp}::$cmd_name {args} [subst -nocommands -nobackslashes {

        set str {}
        if { [llength [set args]] % 2 == 1 } {
            set str [lindex [set args] end]
            set args [lrange [set args] 0 end-1]
        }

        set node [${shadow_nsp}::$cmd_name {*}[set args]]

        if { [set str] ne {} } {
            [set node] appendFromScript { t [set str] }
        }

    }]

}

proc ::dom::scripting::proc_cmd {cmd_name proc_name} {

    set nsp [uplevel { namespace current }]
    
    proc ${nsp}::$cmd_name {args} "uplevel \[list ${nsp}::$proc_name ${cmd_name} {*}\${args}\]"

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
            ::dom::scripting::node_cmd \
            ::dom::scripting::text_cmd \
            ::dom::scripting::proc_cmd \
            ::dom::scripting::dtd

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

proc ::dom::scripting::source_inscope {filename nsp} {

    namespace inscope ${nsp} [list source $filename]

}

proc ::dom::scripting::source_tdom {filename nsp {root_element_name ""}} {

    if { $root_element_name eq {} } {

        set ext [file ext $filename]

        set root_element_name [string range $ext 1 end]

    }

    set doc [dom createDocument $root_element_name]

    set root [$doc documentElement]

    set script "namespace inscope ${nsp} { source $filename }"

    if { [catch {$root appendFromScript $script} errmsg options] } {

        $doc delete

        array set options_arr $options

        error $errmsg $options_arr(-errorinfo)

    } else {

        return $doc

    }

}

proc ::dom::scripting::validate {nsp xml} {

    variable ${nsp}::dtd

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
    ::dom::scripting::source_inscope \
    ::dom::scripting::source_tdom


