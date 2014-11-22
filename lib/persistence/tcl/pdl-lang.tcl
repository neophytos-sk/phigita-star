
::xo::lib::require tdom_procs

define_lang ::metasys::lang {

    namespace export class_helper object_helper slot_class_helper slot_object_helper

    proc class_helper {object_helper class_name object_name args} {

        # create dom node 
        set node [uplevel [list ::dom::createNodeInContext elementNode $class_name -name $object_name {*}${args}]]

        # create object handler
        set uplevel_nsp [uplevel {namespace current}]
        set super_helper [$node @super_helper ""]
        namespace inscope ${uplevel_nsp} [list proc_cmd $object_name [list ${object_helper} $super_helper]]

        return $node

    }

    proc object_helper {super_helper class_name object_name args} {

        puts "--->>> object_helper->define super_helper=$super_helper class_name=$class_name object_name=$object_name args=$args"

        if { $super_helper ne {} } {

            set uplevel_nsp  [uplevel {namespace current}]

            # Object-oriented languages would query the object_helper of the super_helper,
            # only they wouldn't be called that way, most likely class and superclass.
            #
            # We can do the same here with variable ${nsp}::${super_helper}::object_helper
            # but it raises the question of what we put in the representation and what
            # in the interpretation. Remember object_helper is an attribute of the meta command.

            variable ::metasys::lang::${super_helper}::object_helper

            set node [uplevel [list ${uplevel_nsp}::${super_helper} $object_helper $class_name $object_name {*}${args}]]
        } else {
            # create dom node 
            set node [uplevel [list ::dom::createNodeInContext elementNode $class_name -name $object_name {*}${args}]]
        }


        return $node

    }

    proc slot_class_helper {object_helper class_name object_name args} {
        return [uplevel [list class_helper $object_helper $class_name $object_name {*}$args]]
    }

    proc slot_object_helper {super_helper class_name object_name args} {

        set node [uplevel [list ::dom::createNodeInContext elementNode slot -type $class_name -name $object_name {*}${args}]]

    }

    namespace eval class_helper {
        # queried by object_helper
        variable object_helper "object_helper"
    }

    namespace eval object_helper {
        # queried by object_helper::define
        variable object_helper ""
    }

    namespace eval slot_class_helper {
        # queried by object_helper
        variable object_helper "slot_object_helper"
    }

    namespace eval slot_object_helper {
        # queried by object_helper
        variable object_helper ""
    }


}

define_lang ::basesys::lang {

    proc_cmd "meta" meta_helper

    proc meta_helper {meta_tag meta_name args} {

        set uplevel_nsp [uplevel {namespace current}]
        set node [namespace inscope ${uplevel_nsp} [list ::dom::createNodeInContext elementNode $meta_name {*}${args}]]
        set class_helper [$node @class_helper]
        set object_helper [$node @object_helper]
        uplevel [list proc_cmd $meta_name [list namespace inscope ${uplevel_nsp} ${class_helper} $object_helper]]

    }

    proc_cmd "import" import_helper

    proc import_helper {import_tag import_name args} {

        set uplevel_nsp [uplevel {namespace current}]

        set node [namespace inscope ${uplevel_nsp} \
            [list ::dom::createNodeInContext elementNode $import_tag -name $import_name {*}${args}]]

        uplevel [list namespace import ::${import_name}::lang::*]

    }

    namespace export meta meta_helper import import_helper

}


define_lang ::typesys::lang {

    namespace export type typedecl_helper typeinst_helper varchar bool varint byte int16 int32 int64 double

    namespace import ::basesys::lang::*
    import metasys

    meta type -class_helper typedef_helper -object_helper typedecl_helper
    
    # typedef_helper typedecl_helper type type varchar
    proc typedef_helper {object_helper class_name object_name args} {
        set args [concat -super_helper slot_object_helper $args]
        return [class_helper $object_helper $class_name $object_name {*}$args]
    }

    # typedecl_helper object_helper type varchar device = "sms"
    proc typedecl_helper {super_helper class_name object_name args} {

        # support declarations of the form:
        # varchar device = "sms"
        if { [llength $args] && [lindex $args 0] eq {=} } {
            # we don't make any claims about the field being optional or not
            set args [concat -default_value [lrange $args 1 end]]
        }

        #set args [concat -value_type $class_name $args]
        #set class_name "slot"
        #set args [concat -x-struct slot $args]

        return [object_helper $super_helper $class_name $object_name {*}${args}]
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

    #text_cmd "name"
    #text_cmd "type"
    #text_cmd "default_value"
    #text_cmd "optional_p" "true"
    #text_cmd "container_type"


    #
    # HELPERS
    #

    # maybe it does not belong here, will move it out once we have proc filters in place
    # side-effects of init_class are used by ::persistence::serialize
    proc init_class {node} {
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

    rename class_helper _class_helper
    proc class_helper {args} {
        set node [uplevel [list _class_helper {*}${args}]]
        init_class $node
    }

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

    meta struct -class_helper class_helper -object_helper object_helper {
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


