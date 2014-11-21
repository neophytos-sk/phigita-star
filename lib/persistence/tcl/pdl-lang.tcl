
::xo::lib::require tdom_procs


define_lang ::db::lang {

    text_cmd "db_insert"
    text_cmd "db_update"
    text_cmd "db_delete"

    namespace export db_insert db_update db_delete

}

define_lang ::persistence::lang {

    namespace import ::db::lang::*

    meta_cmd "struct" class_helper object_helper
    #node_cmd "slot"
    # node_cmd "attribute" -isa slot
    
    text_cmd "name"
    text_cmd "type"
    text_cmd "default_value"
    text_cmd "optional_p" "true"
    text_cmd "container_type"

    # a boolean value (true or false)
    proc_cmd "bool" attribute_helper

    # an 8-bit signed integer
    proc_cmd "byte" attribute_helper

    # an 16-bit signed integer
    proc_cmd "i16" attribute_helper

    # an 32-bit signed integer
    proc_cmd "i32" attribute_helper

    # an 64-bit signed integer
    proc_cmd "i64" attribute_helper

    # a 64-bit floating point number
    proc_cmd "double" attribute_helper

    # a text string encoded using UTF-8 encoding
    proc_cmd "string" attribute_helper

    namespace eval class_helper {

        proc init {node args} {
            set attributes [list]
            set attnodes [$node selectNodes {descendant::slot}]
            foreach attnode $attnodes {

                set name [$attnode @name]
                set type [$attnode @type]
                set default_value [$attnode @default_value ""]
                set optional_p [$attnode @optional_p ""]
                set container_type [$attnode @container_type ""]
                set subtype [$attnode @subtype ""]

                lappend attributes [list $name $type $default_value $optional_p $container_type $subtype]
            }

            set lang_nsp [$node @nsp]
            set typename [$node @name]

            # puts "creating meta_cmd $typename with struct_helper"

            namespace eval ${lang_nsp} [list meta_cmd $typename {*}$args]

            set varname ::persistence::lang::_info_::${typename}(attributes)
            set $varname $attributes

        }

        proc unknown {args} {
            puts "struct_helper: args=$args typename=[$node @name]"
        }

        namespace unknown unknown

    }

    namespace eval object_helper {

        proc typenode {typename} {
            set xpath "//struct\[@name=\"${typename}\"\]"
            set typenode [$::__source_tdom_doc selectNodes $xpath]
            if { $typenode eq {} } {
                error "no such struct: $typename"
            }
            return $typenode
        }

        proc init {node args} {}

        proc define {typename name args} {
            set typenode [typenode $typename]
            set super_cmd [$typenode @super_cmd ""]
            if { $super_cmd ne {} } {
                set nsp  [uplevel {namespace current}]
                uplevel "${nsp}::${super_cmd}::define $typename $name {*}${args}"
            }
        }

        # TO BE REMOVED
        proc next {args} {

            array set callerofcallerframe [info frame [expr { [info frame] - 2 }]]
            array set callerframe [info frame [expr { [info frame] - 1 }]]

            # There is an expander in the beginning of the callerofcaller(cmd) string 
            # that "confuses" list manipulation commands, in particular lindex and lrange.
            #
            # Here's what the command string looks like:.
            # {*}::persistence::lang::object_helper::define struct message -nsp ::persistence::lang -name message ...
            #
            set called_args [string range $callerofcallerframe(cmd) [string first " " $callerofcallerframe(cmd)] end]
            set called_proc [namespace tail $callerframe(proc)]

            # MISSING node VARIABLE HERE
            set typenode [$node @name ""]
            set super_cmd [$typenode @super_cmd ""]

            return [$super_cmd $called_proc {*}$called_args]

        }

    }

    proc attribute_helper {type name args} {

        set default_value {}

        if { $args ne {} } {

            if { [llength $args] != 2 || [lindex $args 0] ne {=} } {
                error "usage: datatype name = default_value"
            }

            set default_value [lindex $args 1]

        }

        set nsp [uplevel {namespace current}]
        # namespace eval ${nsp} "text_cmd _${name}"

        set node [::dom::createNodeInContext elementNode slot -nsp $nsp -name $name -type $type -subtype attribute]
        if { $default_value ne {} } {
            $node setAttribute default_value ${default_value}
            $node setAttribute optional_p true
        }
        return $node
    }

    namespace unknown unknown_handler

    proc unknown_handler {field_type field_name args} {

        # re is such to allow for expressions of the form set<file>
        set type_re {[_a-zA-Z][_a-zA-Z0-9]*}

        # recognizes expressions of the following forms:
        # set<i32>
        # map<string,i32>
        # list<string>
        set re "^(?:(set)<(${type_re})>|(map)<(${type_re}),(${type_re})>|(list)<(${type_re})>)\$"

        if { [regexp -- $re $field_type _dummy_ sm1 sm2 sm3 sm4 sm5 sm6 sm7] } {
            if { $sm1 ne {} && $sm2 ne {} } {
                set container_type "set"
                set datatype $sm2
            } elseif { $sm3 ne {} && $sm4 ne {} && $sm5 ne {} } {
                set container_type "map"
                set datatype [list $sm4 $sm5]
            } elseif { $sm6 ne {} && $sm7 ne {} } {
                set container_type "list"
                set datatype $sm7
            }

            # (is_set_p)  sm1=set sm2=string sm3= sm4= sm5= sm6=
            # (is_map_p)  sm1= sm2= sm3=map sm4=string sm5=i32 sm6=
            # (is_list_p) sm1= sm2= sm3= sm4= sm5= sm6=list
            #
            # puts "sm1=$sm1 sm2=$sm2 sm3=$sm3 sm4=$sm4 sm5=$sm5 sm6=$sm6 sm7=$sm7"

            set node [attribute_helper $datatype $field_name {*}${args}]

            if { $container_type ne {} } {
                $node @container_type $container_type
            }

        } else {
            set doc $::__source_tdom_doc
            set xpath "//struct\[@name=\"${field_type}\"\]"
            set nodes [$doc selectNodes ${xpath}]
            if { $nodes eq {} } {
                error "no such field type: $field_type nodes=[list $nodes]"
            } else {

                attribute_helper $field_type $field_name {*}${args}

            }
        }

    }

    dtd {
        <!DOCTYPE pdl [

            <!ELEMENT pdl (struct*)>
            <!ELEMENT struct (slot | struct)*>
            <!ATTLIST struct name CDATA #REQUIRED
                             nsp CDATA #IMPLIED
                             pk CDATA #IMPLIED
                             is_final_if_no_scope CDATA #IMPLIED>

            <!ELEMENT slot EMPTY>
            <!ATTLIST slot name CDATA #REQUIRED
                           nsp CDATA #IMPLIED
                           type CDATA #REQUIRED
                           default_value CDATA #IMPLIED
                           optional_p CDATA #IMPLIED
                           container_type CDATA #IMPLIED
                           subtype CDATA #IMPLIED>

            <!ELEMENT extends EMPTY>
            <!ATTLIST extends ref CDATA #REQUIRED>

            <!ELEMENT index EMPTY>
            <!ATTLIST index attr CDATA #REQUIRED>
        ]>
    }

}


