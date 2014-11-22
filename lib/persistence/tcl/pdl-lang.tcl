
::xo::lib::require tdom_procs

define_lang ::metasys::lang {

    # nest argument holds nested calls in the procs below
    # i.e nest_helper, mode_helper, meta_helper

    variable stack [list]

    proc with_mode {nest mode_name args} {
        variable stack
        set stack [linsert $stack 0 $mode_name]
        set cmd "[lindex $nest 0] [lrange $nest 1 end] $args"
        set result [uplevel $cmd]
        set stack [lreplace $stack 0 0]
        return $result
    }

    proc node_helper {tag name args} {
        set node [uplevel [list ::dom::createNodeInContext elementNode $tag -x-name $name {*}$args]]
        return $node
    }

    proc nest_helper {nest tag name args} {
        set node [uplevel [list node_helper $tag $name {*}$args]]
        uplevel [list proc_cmd $name $nest]
        return $node
    }

    proc mode_helper {nest tag name args} {
        set node [uplevel [list node_helper $tag $name {*}$args]]
        uplevel [list proc_cmd $name [list ::metasys::lang::with_mode $nest $name]]
        return $node
    }

    proc meta_helper {meta_tag meta_name nest args} {
        return [uplevel [list nest_helper $nest $meta_tag $meta_name {*}$args]]
    }

    proc_cmd "meta" meta_helper 

    # rewrite typedecl args
    proc typedecl_args {argsVar} {

        upvar $argsVar args

        # rewrite args of the form
        #   varchar device = "sms"
        # to
        #   varchar device -default_value "sms"

        if { [llength $args] && [lindex $args 0] eq {=} } {
            # we don't make any claims about the field being optional or not
            set args [concat -default_value [lrange $args 1 end]]
        }
    }

    proc typeinst_args {argsVar} {

        upvar $argsVar args

        # rewrite args of the form
        #   varchar body = "this is a test"
        # to
        #   varchar body { t "this is a test" }

        if { [llength $args] == 2 && [lindex $args 0] eq {=} } {
            set args [list [list ::dom::scripting::t [lrange $args 1 end]]]
        }
    }

    proc typedecl_helper {decl_tag decl_type decl_name args} {
        typedecl_args args
        return [uplevel [list node_helper typedecl $decl_name -x-type $decl_type {*}$args]]
    }
    
    meta "typedecl" typedecl_helper

    proc typeinst_helper {inst_tag inst_type inst_name args} {
        typeinst_args args
        return [uplevel [list node_helper typeinst $inst_name -x-type $inst_type {*}$args]]
    }

    meta "typeinst" typeinst_helper

    namespace export meta meta_helper typedecl typedecl_helper typedecl_args typeinst typeinst_helper nest_helper node_helper mode_helper

}

define_lang ::basesys::lang {

    proc_cmd "import" import_helper

    proc import_helper {import_tag import_name args} {
        set node [uplevel [list ::dom::createNodeInContext elementNode $import_tag -name $import_name {*}$args]]
        uplevel [list namespace import ::${import_name}::lang::*]
        return $node
    }

    namespace export import import_helper export export_helper

}

define_lang ::typesys::lang {

    namespace import ::basesys::lang::*
    import metasys

    proc declaration_mode_p {} {
        variable ::metasys::lang::stack
        set mode [lindex $stack end]
        if { $mode eq {struct} } {
            return 1
        }
        return 0
    }

    proc type_helper {tag name args} {

        puts "--->>> type_helper (declaration_mode_p=[declaration_mode_p]) tag=$tag name=$name {*}$args"

        set type $tag
        if { [declaration_mode_p] } {
            return [uplevel [list typedecl_helper $tag $type $name {*}$args]]
        } else {
            return [uplevel [list typeinst_helper $tag $type $name {*}$args]]
        }
    }

    proc typeargs_helper {nest tag name args} {
        typedecl_args args
        return [uplevel "$nest $tag $name $args"]
    }

    meta "type" {nest_helper {type_helper}}
    #meta "type" {mode_helper {type_helper}}

    # a varying-length text string encoded using UTF-8 encoding
    type "varchar"

    # a boolean value (true or false)
    type "bool"

    # a varying-bit signed integer
    type "varint"

    # an 8-bit signed integer
    type "byte"

    # a 16-bit signed integer
    type "int16"

    # a 32-bit signed integer
    type "int32"

    # a 64-bit signed integer
    type "int64"

    # a 64-bit floating point number
    type "double"

    namespace export type type_helper varchar bool varint byte int16 int32 int64 double

}

define_lang ::db::lang {

    text_cmd "db_insert"
    text_cmd "db_update"
    text_cmd "db_delete"

    namespace export db_insert db_update db_delete

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

    # The following commented out line should have worked already 
    # as the meta "type" is equivalent to {nest_helper {type_helper}}
    # but the nest_helper does not seem to preserve the namespace 
    # at the moment (2014-11-22).
    #
    # TODO: meta "struct" {nest_helper {type}}

    # OLD: meta "struct" {nest_helper {nest_helper {type_helper}}}

    meta "struct" {mode_helper {nest_helper {type_helper}}}

    dtd {
        <!DOCTYPE pdl [

            <!ELEMENT pdl (struct | typeinst)*>
            <!ELEMENT struct (typedecl)*>
            <!ATTLIST struct x-name CDATA #REQUIRED
                             name CDATA #IMPLIED
                             nsp CDATA #IMPLIED
                             pk CDATA #IMPLIED
                             is_final_if_no_scope CDATA #IMPLIED
                             super_helper CDATA #IMPLIED>

            <!ELEMENT typedecl EMPTY>
            <!ATTLIST typedecl x-name CDATA #REQUIRED
                           x-type CDATA #REQUIRED
                           name CDATA #IMPLIED
                           type CDATA #IMPLIED
                           nsp CDATA #IMPLIED
                           default_value CDATA #IMPLIED
                           optional_p CDATA #IMPLIED
                           container_type CDATA #IMPLIED
                           subtype CDATA #IMPLIED
                           lang_nsp CDATA #IMPLIED>

            <!ELEMENT typeinst ANY>
            <!ATTLIST typeinst x-name CDATA #REQUIRED
                               x-type CDATA #REQUIRED
                               name CDATA #IMPLIED
                               type CDATA #IMPLIED>

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


