
::xo::lib::require tdom_procs

define_lang ::dom::lang {

    proc_cmd "meta" meta_helper

    proc meta_helper {cmd_type cmd_name args} {

        set lang_nsp [uplevel {namespace current}]
        set node [namespace inscope ${lang_nsp} [list ::dom::createNodeInContext elementNode $cmd_name {*}${args}]]
        set class_helper [$node @class_helper]
        set object_helper [$node @object_helper]

        uplevel [list proc_cmd $cmd_name "namespace inscope ${lang_nsp} ${class_helper}::define $object_helper"]

    }

    namespace export meta meta_helper

}

define_lang ::db::lang {

    text_cmd "db_insert"
    text_cmd "db_update"
    text_cmd "db_delete"

    namespace export db_insert db_update db_delete

}

define_lang ::persistence::lang {

    namespace import ::dom::lang::*
    namespace import ::db::lang::*

    # a varying-length text string encoded using UTF-8 encoding
    proc_cmd "varchar" attribute_helper

    # a boolean value (true or false)
    proc_cmd "bool" attribute_helper

    # a varying-bit signed integer
    proc_cmd "varint" attribute_helper

    # an 8-bit signed integer
    proc_cmd "byte" attribute_helper

    # an 16-bit signed integer
    proc_cmd "int16" attribute_helper

    # an 32-bit signed integer
    proc_cmd "int32" attribute_helper

    # an 64-bit signed integer
    proc_cmd "int64" attribute_helper

    # a 64-bit floating point number
    proc_cmd "double" attribute_helper

    #node_cmd "slot"
    # node_cmd "attribute" -isa slot
    
    text_cmd "name"
    text_cmd "type"
    text_cmd "default_value"
    text_cmd "optional_p" "true"
    text_cmd "container_type"


    #
    # HELPERS
    #

    namespace eval class_helper {

        # queried by object_helper::define
        variable object_helper "object_helper"

        proc self {} {
            return [uplevel {namespace current}]
        }

        proc define {object_helper class_name object_name args} {

            # create dom node 
            set node [uplevel [list ::dom::createNodeInContext elementNode $class_name -name $object_name {*}${args}]]

            # create object handler
            set super_helper [$node @super_helper ""]
            set lang_nsp [uplevel {namespace current}]

            #puts "$object_name super_helper=$super_helper args=$args"

            namespace inscope ${lang_nsp} [list proc_cmd $object_name [list ${object_helper}::define $super_helper]]

            # init
            namespace inscope [self] init $node {*}$args

        }

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

            set class_name [$node @name]

            set varname ::persistence::lang::_info_::${class_name}(attributes)
            set $varname $attributes

        }

        proc unknown {args} {
            error "no such command: $args"
        }

        namespace unknown unknown

    }

    namespace eval object_helper {

        # queried by object_helper::define
        variable object_helper ""

        proc init {args} {}

        proc define {super_helper class_name object_name args} {
set nsp [uplevel {namespace current}]
puts "--->>> object_helper->define (nsp=$nsp) super_helper=$super_helper class_name=$class_name object_name=$object_name args=$args"

            # create dom node 
            set node [uplevel [list ::dom::createNodeInContext elementNode $class_name -name $object_name {*}${args}]]

            if { $super_helper ne {} } {

                #set lang_nsp  [uplevel {namespace current}]
                set lang_nsp ::persistence::lang

                # Object-oriented languages would query the object_helper of the super_helper,
                # only they wouldn't be called that way, most likely class and superclass.
                #
                # We can do the same here with variable ${nsp}::${super_helper}::object_helper
                # but it raises the question of what we put in the representation and what
                # in the interpretation. Remember object_helper is an attribute of the meta command.

                variable ${lang_nsp}::${super_helper}::object_helper

                uplevel [list ${lang_nsp}::${super_helper}::define $object_helper $class_name $object_name {*}${args}]
            }
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

        set lang_nsp [uplevel {namespace current}]
        # namespace eval ${nsp} "text_cmd _${name}"

        set node [::dom::createNodeInContext elementNode slot -lang_nsp $lang_nsp -name $name -type $type -subtype attribute]
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

    meta "struct" -class_helper class_helper -object_helper object_helper {
        puts "current nsp=[namespace current]"
        varchar super_helper
    }


    dtd {
        <!DOCTYPE pdl [

            <!ELEMENT pdl (struct*)>
            <!ELEMENT struct (slot | struct)*>
            <!ATTLIST struct name CDATA #REQUIRED
                             nsp CDATA #IMPLIED
                             pk CDATA #IMPLIED
                             is_final_if_no_scope CDATA #IMPLIED
                             super_helper CDATA #IMPLIED>

            <!ELEMENT slot EMPTY>
            <!ATTLIST slot name CDATA #REQUIRED
                           nsp CDATA #IMPLIED
                           type CDATA #REQUIRED
                           default_value CDATA #IMPLIED
                           optional_p CDATA #IMPLIED
                           container_type CDATA #IMPLIED
                           subtype CDATA #IMPLIED
                           lang_nsp CDATA #IMPLIED>

            <!ELEMENT extends EMPTY>
            <!ATTLIST extends ref CDATA #REQUIRED>

            <!ELEMENT index EMPTY>
            <!ATTLIST index attr CDATA #REQUIRED>

            <!ELEMENT db_insert EMPTY>
            <!ATTLIST db_insert scope CDATA #IMPLIED
                                what CDATA #REQUIRED>
        ]>
    }

}


