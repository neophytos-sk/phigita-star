
::xo::lib::require tdom_procs


define_lang ::basesys::lang {

    variable stack [list]
    array set lookahead_context [list]
    array set forward [list]

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

    proc get_context_path_of_type {context_type} {
        variable stack
        set indexList 0 ;# match first element of nested list
        set contextList [lsearch -all -inline -exact -index $indexList $stack $context_type]
        set context_path ""
        foreach context [lreverse $contextList] {
            lassign $context context_type context_tag context_name
            append context_path $context_name "."
        }
        return [string trimright $context_path "."]
    }

    # nest argument holds nested calls in the procs below
    # i.e. with_context, nest, meta_helper

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
        set varname "::basesys::lang::lookahead_context($name)"
        set $varname [list $context_type $context_tag $context_name]
    }

    proc get_lookahead_context {name} {
        set varname "::basesys::lang::lookahead_context($name)"
        set $varname
    }

    proc node_helper {tag name args} {
        push_context "eval" $tag $name
        set cmd  [list ::dom::createNodeInContext elementNode $tag -x-name $name {*}$args]
        set node [uplevel $cmd]
        pop_context
        return $node
    }

    proc forward {name cmd args} {

        puts "--->>> (def forward $name) cmd_handler=[list $cmd] def_args=$args"

        # register forward

        set varname "::basesys::lang::forward($name)"
        if { [info exists $varname] } {
            puts "!!! forward with that name (=$name) already exists"
        }
        set $varname ""

        # create handler proc

        set nsp [uplevel {namespace current}]
        set arg0 $name

        proc ${nsp}::$name {args} "uplevel [list $cmd] $arg0 \$args"

    }

    proc nest {nest tag name args} {
        set_lookahead_context $name "proc" $tag $name
        set cmd [list [namespace which node_helper] $tag $name {*}$args]
        set node [uplevel $cmd]
        set nest [list [namespace which with_context] $nest "proc" $tag $name]
        uplevel [list [namespace which forward] $name $nest]
        return $node
    }

    proc lambda {params body args} {
        set pre {}
        while { ($params ne {} && $args ne {}) || $params eq {args} } { 
            if { $params eq {args} } {
                append pre "set args [list $args] ; "
                set params {}
                set args {}
            } else {
                set params [lassign $params param]
                set args [lassign $args arg]
                append pre "set $param [list $arg] ; "
            }
        }   
        set body [concat $pre $body]
        if { $params ne {} } { 
            puts "+++++ lambda returns = [list lambda $params $body]"
            return [list lambda $params $body]
        }   
        uplevel $body $args
    }

    #proc meta_helper {meta_tag meta_name nest args} {
    #    set cmd [list nest $nest $meta_tag $meta_name {*}$args]
    #    return [uplevel $cmd]
    #}
    #forward "meta" [namespace which meta_helper]

    forward "meta" {lambda {tag name nest args} {nest $nest $tag $name {*}$args}}

    proc multiple_helper {_dummy_multiple_tag_ arg0 args} {

        # remove {proc meta multiple} from the top of the context stack
        # and at the bottom, put it back so that it will be removed from with_context
        # where it applies
        set top_context [top_context]
        pop_context

        set nodes [list]
        set llength_args [llength $args]

        if { [is_declaration_mode_p] && ( $llength_args == 1 || $llength_args == 3 ) } {

            # EXAMPLE 1:
            #   struct message {
            #     ...
            #     multiple email to
            #     ...
            #   }
            #
            # EXAMPLE 2:
            #   struct message {
            #     ...
            #     multiple email cc = {}
            #     ...
            #   }


            set type $arg0
            set tag $type
            set args [lassign $args name]

            # push a temporary context so that typedecl_helper gets it right
            # context = {eval struct message}
            # lookahead_context of message = {proc struct message}

            set context [top_context_of_type "eval"]
            lassign $context context_type context_tag context_name
            set lookahead_context [get_lookahead_context $context_name]
            push_context {*}$lookahead_context 

            puts "+++++ (multiple declaration) tag=type=$type name=$name args=$args stack=$::basesys::lang::stack context=$context"

            typedecl_args args
            set args [concat -x-container "multiple" $args] 
            set cmd [list [namespace which typedecl_helper] $tag $type $name {*}$args]
            lappend nodes [uplevel $cmd]

            # now pop the temporary context
            pop_context

        } elseif { $llength_args == 1 } {

            # EXAMPLE:
            #   multiple cc {{ 
            #       name "jane awesome"
            #       address "jane@example.com"
            #   } {
            #   } { 
            #       name "someone great" 
            #       address "someone@example.com" 
            #   }}

            set name $arg0

            puts "+++++ (multiple instantiation) name=$name args=$args"

            lassign $args argv
            foreach arg $argv {
                set cmd [list $name $arg]
                lappend nodes [uplevel $cmd]
            }

        } else {
            error "Usage:\n\tmultiple type name = default_value\n\tmultiple name inst_script"
        }

        # push the {proc meta multiple} context back to the top of the context stack
        # as it were before we removed it in the beginning of this proc
        push_context {*}$top_context

        return $nodes

    }

    meta "multiple" [namespace which multiple_helper]

    proc map_helper {_dummy_map_tag_ arg0 args} {

        # remove {proc meta map} from the top of the context stack
        # and at the bottom, put it back so that it will be removed from with_context
        # where it applies
        set top_context [top_context]
        pop_context

        set nodes [list]
        set llength_args [llength $args]

        if { [is_declaration_mode_p] } {

            # EXAMPLE 1:
            #   struct message {
            #     ...
            #     map word_count_pair wordcount
            #     ...
            #   }
            #
            # EXAMPLE 2:
            #   struct message {
            #     ...
            #     map word_count_pair wordcount = {}
            #     ...
            #   }
            #
            # EXAMPLE 3 (TODO):
            #   struct message {
            #     ...
            #     map pair "from_type to_type" wordcount = {}
            #     ...
            #   }
            #
            # EXAMPLE 4:
            #   struct message {
            #     ...
            #     map struct wordcount { 
            #       varchar word
            #       varint count
            #     }
            #     ...
            #   }
            #
            # EXAMPLE 5:
            #   struct message {
            #     ...
            #     map struct wordcount = {} { 
            #       varchar word
            #       varint count
            #     }
            #     ...
            #   }


            set type $arg0
            set tag $type
            set args [lassign $args name]

            # push a temporary context so that typedecl_helper gets it right
            # context = {eval struct message}
            # lookahead_context of message = {proc struct message}

            set context [top_context_of_type "eval"]
            lassign $context context_type context_tag context_name
            set lookahead_context [get_lookahead_context $context_name]
            push_context {*}$lookahead_context 

            puts "----- (map declaration) tag=type=$type name=$name args=$args stack=$::basesys::lang::stack context=$context"

            typedecl_args args
            set args [concat -x-container "map" $args] 
            set cmd [list [namespace which typedecl_helper] $tag $type $name {*}$args]
            lappend nodes [uplevel $cmd]

            # now pop the temporary context
            pop_context

        } elseif { $llength_args == 1 } {

            # EXAMPLE:
            #   map wordcount {{ 
            #       word "the"
            #       count "123"
            #   } {
            #   } { 
            #       word "and" 
            #       count "54" 
            #   }}

            set name $arg0

            puts "----- (map instantiation) name=$name args=$args"

            lassign $args argv
            foreach arg $argv {
                set cmd [list $name $arg]
                lappend nodes [uplevel $cmd]
            }

        } else {
            error "Usage:\n\tmap type name = default_value\n\tmap name inst_script"
        }

        # push the {proc meta map} context back to the top of the context stack
        # as it were before we removed it in the beginning of this proc
        push_context {*}$top_context

        return $nodes

    }
    meta "map" [namespace which map_helper]

    proc typedecl_args {argsVar} {

        upvar $argsVar args

        # rewrite args of the form
        #   varchar device = "sms"
        # to
        #   varchar device -x-default_value "sms"

        if { [llength $args] && [lindex $args 0] eq {=} } {
            # we don't make any claims about the field being optional or not
            set args [concat -x-default_value [lrange $args 1 end]]
        }
    }

    proc typedecl_helper {decl_tag decl_type decl_name args} {
        typedecl_args args
        set cmd [list [namespace which node_helper] typedecl $decl_name -x-type $decl_type {*}$args]
        set node [uplevel $cmd]

        set context_path [get_context_path_of_type "eval"]

        puts "--->>> (typedecl_helper) context_path=[list $context_path] stack=[list $::basesys::lang::stack]"

        set dotted_name "${context_path}.$decl_name"
        # OBSOLETE: set_lookahead_context $dotted_name "proc" $decl_tag $dotted_name
        set dotted_nest [list [namespace which typeinst_helper] typeinst $decl_type]
        set dotted_nest [list [namespace which with_context] $dotted_nest "proc" $decl_tag $dotted_name]
        set cmd [list [namespace which forward] $dotted_name $dotted_nest]
        uplevel $cmd

        return $node

    }
    
    meta "typedecl" [namespace which typedecl_helper]

    text_cmd t

    proc nt {text} { t -disableOutputEscaping ${text} }

    proc typeinst_args {inst_type argsVar} {

        upvar $argsVar args

        # rewrite args of the form
        #   varchar body = "this is a test"
        # to
        #   varchar body { t "this is a test" }

        set llength_args [llength $args]
        if { $llength_args == 2 } {
            if { [lindex $args 0] eq {=} } {
                set args [list [list [namespace which t] [lindex $args 1]]]
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
                set args [list [list [namespace which t] [lindex $args 0]]]
            }
        }
    }

    proc typeinst_helper {inst_tag inst_type inst_name args} {
        typeinst_args $inst_type args

        set context [top_context_of_type "proc"]
        set context_tag [lindex $context 1]
        set context_name [lindex $context 2]

        puts "--->>> (typeinst_helper) context=[list $context] stack=[list $::basesys::lang::stack]"
        
        set cmd [list [namespace which node_helper] typeinst $inst_name -x-type $inst_type {*}$args]
        return [uplevel $cmd]

    }

    meta "typeinst" [namespace which typeinst_helper]

    proc is_dotted_p {name} {
        return [expr { [llength [split ${name} {.}]] > 1 }]
    }

    proc is_declaration_mode_p {} {
        # set context [top_context_of_type "eval"]
        variable stack
        set context [lindex $stack end]
        #lassign $context context_type context_tag context_name
        #if { $context_tag in {struct} }
        if { $context eq {proc struct struct} || $context eq {proc meta struct} } {
            return 1
        }
        return 0
    }

    proc type_helper {tag name args} {

        puts "--->>> type_helper (is_declaration_mode_p=[is_declaration_mode_p]) tag=$tag name=$name {*}$args"
        
        set type $tag
        if { [is_declaration_mode_p] } {
            set cmd [list [namespace which typedecl_helper] $tag $type $name {*}$args]
            return [uplevel $cmd]
        } else {
            set cmd [list [namespace which typeinst_helper] $tag $type $name {*}$args]
            return [uplevel $cmd]
        }
    }

    meta "base_type" {nest {type_helper}}
    # OLD: meta "base_type" [list [namespace which nest] [list [namespace which type_helper]]]
    # ALT: meta "base_type" {lambda {} {nest {type_helper}}}

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

    # EXPERIMENTAL
    # pair
    # tuple
    # record


    # The following commented out line should have worked already 
    # as the meta "type" is equivalent to {nest {type_helper}}
    # but the nest does not seem to preserve the namespace 
    # at the moment (2014-11-22).
    #
    # TODO: meta "struct" {nest {base_type}}

    meta "struct" {nest {nest {type_helper}}}
    # OLD: meta "struct" [list [namespace which nest] [list [namespace which nest] [list [namespace which type_helper]]]]

    proc unknown {field_type field_name args} {

        puts "--->>> (unknown) $field_type $field_name args=$args"

        # re is such to allow for expressions of the form set<file>
        set type_re {[_a-zA-Z][_a-zA-Z0-9]*}

        # recognizes expressions of the following forms:
        # set<i32>
        # map<string,i32>
        set re ""
        append re "(set)<(${type_re})>" "|"
        append re "(map)<(${type_re}),(${type_re})>" "|"
        append re "(list)<(${type_re})>"
        set re "^(?:${re})\$"

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

            # (is_set_p)  sm1=set sm2=string sm3= sm4= sm5= 
            # (is_map_p)  sm1= sm2= sm3=map sm4=string sm5=i32 
            #
            # puts "sm1=$sm1 sm2=$sm2 sm3=$sm3 sm4=$sm4 sm5=$sm5"

            return
            set node [typedecl_helper slot_class_helper "" slot $field_name -type $datatype {*}${args}]

            if { $container_type ne {} } {
                $node setAttribute container_type $container_type
            }

        } else {
            if { ![is_dotted_p $field_type] } {

                set context [top_context_of_type "proc"]
                lassign $context context_type context_tag context_name

                set redirect_name "${context_name}.$field_type"

                if { 0 } {
                    puts "+++ stack=[list $::basesys::lang::stack]"
                    puts "+++ info proc=[uplevel [list info proc $redirect_name]]"
                    puts "+++ forward=[array get ::basesys::lang::forward]"
                    puts "+++ forward_exists_p=[info exists ::basesys::lang::forward($redirect_name)]"
                }

                set forward_exists_p [info exists ::basesys::lang::forward($redirect_name)]
                if { $forward_exists_p } {
                    set dotted_name $redirect_name
                } else {
                    set dotted_name ${context_tag}.$field_type
                }

                ::basesys::lang::push_context "unknown" $context_tag $dotted_name
                set cmd [list $dotted_name $field_name {*}$args]
                uplevel $cmd
                ::basesys::lang::pop_context

            } else {
                error "no such field_type: $field_type stack=$::basesys::lang::stack"
            }
        }
    }

    namespace unknown unknown

    proc import_helper {import_tag import_name args} {
        set node [uplevel [list ::dom::createNodeInContext elementNode $import_tag -name $import_name {*}$args]]
        uplevel [list namespace import ::${import_name}::lang::*]
        return $node
    }

    forward "import" [namespace which import_helper]

    proc dtd_helper {dtd_tag args} {
        variable dtd
        if { $args eq {} } {
            return $dtd
        } else {
            set dtd {*}$args
        }
    }

    forward "dtd" [namespace which dtd_helper]

    dtd {
        <!DOCTYPE pdl [

            <!ELEMENT pdl (struct | typeinst)*>
            <!ELEMENT struct (struct | typedecl | typeinst)*>
            <!ATTLIST struct x-name CDATA #REQUIRED
                             name CDATA #IMPLIED
                             nsp CDATA #IMPLIED
                             pk CDATA #IMPLIED
                             is_final_if_no_scope CDATA #IMPLIED
                             super_helper CDATA #IMPLIED>

            <!ELEMENT typedecl (typedecl)*>
            <!ATTLIST typedecl x-name CDATA #REQUIRED
                           x-type CDATA #REQUIRED
                           x-default_value CDATA #IMPLIED
                           x-container CDATA #IMPLIED
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
                               x-container CDATA #IMPLIED
                               x-map_p CDATA #IMPLIED
                               name CDATA #IMPLIED
                               type CDATA #IMPLIED>

        ]>
    }

    namespace export "import" "struct" "typedecl" "typeinst" "varchar" "bool" "varint" "byte" "int16" "int32" "int64" "double" "multiple" "dtd"

}

define_lang ::datasys::lang {
    namespace import ::basesys::lang::*
    namespace path [list ::datasys::lang ::basesys::lang ::]
    namespace unknown ::basesys::lang::unknown
}

define_lang ::db::lang {

    textnode_cmd "db_insert"
    textnode_cmd "db_update"
    textnode_cmd "db_delete"

    namespace export db_insert db_update db_delete

}




