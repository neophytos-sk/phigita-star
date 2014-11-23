
::xo::lib::require tdom_procs

define_lang ::basesys::lang {

    proc_cmd "import" ::basesys::lang::import_helper

    proc import_helper {import_tag import_name args} {
        set node [uplevel [list ::dom::createNodeInContext elementNode $import_tag -name $import_name {*}$args]]
        uplevel [list namespace import ::${import_name}::lang::*]
        return $node
    }

    namespace export "import"

}

define_lang ::typesys::lang {

    variable stack [list]
    array set lookahead_context [list]

    proc push_context {context_type context_tag context_name} {
        variable stack
        set context [list $context_type $context_tag $context_name]
        set stack [linsert $stack 0 $context]
    }

    proc pop_context {} {
        variable stack
        set stack [lreplace $stack 0 0]
    }

    proc top_context {} {
        variable stack
        return [lindex $stack 0]
    }

    proc top_context_of_type {context_type} {
        variable stack
        set indexList 0 ;# match first element of nested list
        set index [lsearch -exact -index $indexList $stack $context_type]
        return [lindex $stack $index]
    }

    # nest argument holds nested calls in the procs below
    # i.e nest_helper, mode_helper, meta_helper

    proc with_context {nest context_type context_tag context_name args} {

        # EXAMPLE 1:
        #
        # struct typedecl {
        #     varchar name
        #     varchar type
        #     varchar default
        #     -> bool optional_p = false
        #     varchar container_type
        #     varchar subtype
        # }
        # 
        # stack = {proc base_type bool} {eval struct typedecl} {proc struct struct}
        #
        # EXAMPLE 2:
        # 
        # struct email {
        #   varchar name
        #   -> varchar address
        # }
        #
        # stack = {proc base_type varchar} {eval struct email} {proc struct struct}

        variable stack

        push_context $context_type $context_tag $context_name

        set cmd "[lindex $nest 0] [lrange $nest 1 end] $args"
        set result [uplevel $cmd]

        pop_context

        return $result

    }

    proc set_lookahead_context {name context_type context_tag context_name} {
        set ::typesys::lang::lookahead_context($name) [list $context_type $context_tag $context_name]
    }

    proc get_lookahead_context {name} {
        return $::typesys::lang::lookahead_context($name)
    }

    proc node_helper {tag name args} {

        push_context "eval" $tag $name

        set cmd \
            [list ::dom::createNodeInContext elementNode $tag -x-name $name {*}$args]
        set node [uplevel $cmd]

        pop_context

        return $node
    }

    proc nest_helper {nest tag name args} {
        set_lookahead_context $name "proc" $tag $name
        set cmd [list [namespace which node_helper] $tag $name {*}$args]
        set node [uplevel $cmd]
        set nest [list [namespace which with_context] $nest "proc" $tag $name]
        uplevel [list proc_cmd $name $nest]
        return $node
    }

    proc meta_helper {meta_tag meta_name nest args} {
        set cmd [list nest_helper $nest $meta_tag $meta_name {*}$args]
        return [uplevel $cmd]
    }

    proc_cmd "meta" [namespace which meta_helper]

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

    proc typedecl_helper {decl_tag decl_type decl_name args} {
        typedecl_args args
        set cmd [list [namespace which node_helper] typedecl $decl_name -x-type $decl_type {*}$args]
        set result [uplevel $cmd]

        # TODO: for msg3 example in message.pdl to work

        set context [top_context_of_type "eval"]
        set context_tag [lindex $context 1]
        set context_name [lindex $context 2]

        # puts "--->>> context=$context stack=$::typesys::lang::stack"

        set cmd [list proc_cmd ${context_name}.$decl_name [list [namespace which typeinst_helper] typeinst $decl_type]]
        uplevel $cmd

    }
    
    meta "typedecl" [namespace which typedecl_helper]

    proc typeinst_args {inst_type argsVar} {

        upvar $argsVar args

        # rewrite args of the form
        #   varchar body = "this is a test"
        # to
        #   varchar body { t "this is a test" }

        set llength_args [llength $args]
        if { $llength_args == 2 } {
            if { [lindex $args 0] eq {=} } {
                set args [list [list ::dom::scripting::t [lindex $args 1]]]
            }
        } elseif { $llength_args == 1 } {

            # we don't know which of the following two cases we are in
            # and the stack does not have the context info for this call
            # i.e. the stack is {proc meta typeinst}
            #
            # message.subject "hello"
            # message.from { ... }
            #
            # so we check the lookahead_context for the upcoming command
            # we know already that typeinst_helper calls the given inst_type command

            set lookahead_context [get_lookahead_context $inst_type]
            lassign $lookahead_context lookahead_context_type lookahead_context_tag lookahead_context_name
            if { $lookahead_context_tag eq {base_type} } {
                set args [list [list ::dom::scripting::t [lindex $args 0]]]
            }
        }
    }

    proc typeinst_helper {inst_tag inst_type inst_name args} {
        typeinst_args $inst_type args
        set cmd [list [namespace which node_helper] typeinst $inst_name -x-type $inst_type {*}$args]
        return [uplevel $cmd]
    }

    meta "typeinst" [namespace which typeinst_helper]


    proc declaration_mode_p {} {
        set context [top_context_of_type "eval"]
        lassign $context context_type context_tag context_name
        if { $context_tag in {struct} } {
            return 1
        }
        return 0
    }

    proc type_helper {tag name args} {

        puts "--->>> type_helper (declaration_mode_p=[declaration_mode_p]) tag=$tag name=$name {*}$args"
        
        set type $tag
        if { [declaration_mode_p] } {
            set cmd [list [namespace which typedecl_helper] $tag $type $name {*}$args]
            return [uplevel $cmd]
        } else {
            set cmd [list [namespace which typeinst_helper] $tag $type $name {*}$args]
            return [uplevel $cmd]
        }
    }

    # meta "base_type" {nest_helper {type_helper}}
    meta "base_type" [list [namespace which nest_helper] [list [namespace which type_helper]]]

    # a varying-length text string encoded using UTF-8 encoding
    base_type "varchar"

    # a boolean value (true or false)
    base_type "bool"

    # a varying-bit signed integer
    base_type "varint"

    # an 8-bit signed integer
    base_type "byte"

    # a 16-bit signed integer
    base_type "int16"

    # a 32-bit signed integer
    base_type "int32"

    # a 64-bit signed integer
    base_type "int64"

    # a 64-bit floating point number
    base_type "double"

    # The following commented out line should have worked already 
    # as the meta "type" is equivalent to {nest_helper {type_helper}}
    # but the nest_helper does not seem to preserve the namespace 
    # at the moment (2014-11-22).
    #
    # TODO: meta "struct" {nest_helper {base_type}}

    # meta "struct" {nest_helper {nest_helper {type_helper}}}
    meta "struct" [list [namespace which nest_helper] [list [namespace which nest_helper] [list [namespace which type_helper]]]]

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

        ]>
    }

    proc unknown {args} {
        error "--->>> [namespace current]->unknown: $args"
    }
    
    namespace unknown unknown

    namespace export struct typedecl typeinst varchar bool varint byte int16 int32 int64 double

}

define_lang ::db::lang {

    text_cmd "db_insert"
    text_cmd "db_update"
    text_cmd "db_delete"

    namespace export db_insert db_update db_delete

}

define_lang ::persistence::lang {

    namespace import ::basesys::lang::*
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

}


