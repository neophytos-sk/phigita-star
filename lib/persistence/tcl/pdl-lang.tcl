
::xo::lib::require tdom_procs

define_lang ::metasys::lang {

    namespace export meta meta_helper nest_helper node_helper

    proc node_helper {class_name object_name args} {
        set node [uplevel [list ::dom::createNodeInContext elementNode $class_name -name $object_name {*}${args}]]
        return $node
    }

    # nest argument holds nested calls
    proc nest_helper {nest class_name object_name args} {
        set node [uplevel [list ::dom::createNodeInContext elementNode $class_name -name $object_name {*}${args}]]
        uplevel [list proc_cmd $object_name $nest]
        return $node
    }

    # nest argument holds nested calls
    proc meta_helper {meta_tag meta_name nest args} {
        return [uplevel [list nest_helper $nest $meta_tag $meta_name {*}${args}]]
    }

    proc_cmd "meta" meta_helper 

}

define_lang ::basesys::lang {

    namespace export import import_helper export export_helper

    proc_cmd "import" import_helper

    proc import_helper {import_tag import_name args} {
        set node [uplevel [list ::dom::createNodeInContext elementNode $import_tag -name $import_name {*}${args}]]
        uplevel [list namespace import ::${import_name}::lang::*]
        return $node
    }

}

define_lang ::typesys::lang {

    namespace export type typedecl_helper varchar bool varint byte int16 int32 int64 double

    namespace import ::basesys::lang::*
    import metasys

    meta "type" {nest_helper {typedecl_helper}}

    proc typedecl_helper {class_name object_name args} {

        # support declarations of the form:
        # varchar device = "sms"
        if { [llength $args] && [lindex $args 0] eq {=} } {
            # we don't make any claims about the field being optional or not
            set args [concat -default_value [lrange $args 1 end]]
        }

        return [node_helper slot $object_name -type $class_name {*}${args}]
    }

    # a varying-length text string encoded using UTF-8 encoding
    type "varchar"

    # a boolean value (true or false)
    type "bool"

    # a varying-bit signed integer
    type "varint"

    # an 8-bit signed integer
    type "byte"

    # an 16-bit signed integer
    type "int16"

    # an 32-bit signed integer
    type "int32"

    # an 64-bit signed integer
    type "int64"

    # a 64-bit floating point number
    type "double"

}

define_lang ::db::lang {

    namespace export db_insert db_update db_delete

    text_cmd "db_insert"
    text_cmd "db_update"
    text_cmd "db_delete"

}

define_lang ::persistence::lang {

    namespace import ::basesys::lang::*
    import metasys
    import typesys
    import db

    #
    # HELPERS
    #

    namespace unknown unknown

    proc unknown {field_type field_name args} {

        puts "--->>> (unknown) $field_type $field_name args=$args"

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

            return
            set node [typedecl_helper slot_class_helper "" slot $field_name -type $datatype {*}${args}]

            if { $container_type ne {} } {
                $node setAttribute container_type $container_type
            }

        } else {
            error "no such field_type: $field_type"
        }
    }

    meta "struct" {nest_helper {nest_helper {typedecl_helper}}}

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


