namespace eval ::dom {
    namespace eval _elementNodeCmd {;}
    namespace eval _textNodeCmd {;}
    namespace eval _cdataNode {;}
    namespace eval _commentNode {;}
    namespace eval _piNode {;}
    namespace eval _parserNode {;}
}

proc ::dom::createNodeCmd {node_type node_tag} {
    set nsp "::dom::_${node_type}Cmd"
    namespace eval $nsp [list dom createNodeCmd -returnNodeCmd $node_type $node_tag]
}

proc ::dom::execNodeCmd {node_type node_tag args} {
    set nsp "::dom::_${node_type}Cmd"
    set cmd [list ${nsp}::$node_tag {*}$args]
    set node [uplevel $cmd]
}

proc ::dom::createDocumentFromScript {rootname script} {
    set doc [dom createDocument $rootname]
    set root [$doc documentElement]
    $root setAttribute x-nsp [uplevel {namespace current}]
    $root appendFromScript $script
    return $doc
}

namespace eval ::dom::scripting {
    namespace export *

}

proc ::dom::scripting::define_lang {nsp script {docVar ""}} {

    if { $docVar ne {} } {
        upvar $docVar doc
    }

    if { [string range ${nsp} 0 1] ne {::} } {
        error "lang namespace must be fully qualified name"
    }

    namespace eval ${nsp} {;}

    proc ${nsp}::require_procs {} \
        [list ::dom::createDocumentFromScript "lang" \
            [list namespace eval ${nsp} ${script}]]

    set doc [${nsp}::require_procs]
    return $doc

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

    set dtd [${lang_nsp}::dtd]
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

        # puts "--->>> $errortext($errorcode)"
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
    ::dom::scripting::source_tdom \
    ::dom::scripting::t \
    ::dom::scripting::nt


