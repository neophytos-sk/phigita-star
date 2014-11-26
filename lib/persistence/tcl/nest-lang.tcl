
::xo::lib::require tdom_procs


define_lang ::basesys::lang {

    variable stack_ctx [list]
    variable stack_fwd [list]

    array set lookahead_ctx [list]
    array set alias [list]

    proc push_fwd {name} {
        variable stack_fwd
        set stack_fwd [linsert $stack_fwd 0 $name]
    }
    proc pop_fwd {} {
        variable stack_fwd
        set stack_fwd [lreplace $stack_fwd 0 0]
    }
    proc top_fwd {} {
        variable stack_fwd
        lindex $stack_fwd 0
    }
    proc with_fwd {name args} {
        push_fwd $name
        set result [uplevel $args]
        pop_fwd
        return $result
    }


    # =========
    # stack_ctx
    # =========
    #
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
    # stack_ctx = {proc basetype bool} {eval struct typedecl} {proc struct struct}
    #
    # EXAMPLE 2:
    # 
    # struct email {
    #   varchar name
    #   -> varchar address
    # }
    #
    # stack_ctx = {proc basetype varchar} {eval struct email} {proc struct struct}

    proc push_ctx {ctx} {
        variable stack_ctx
        set stack_ctx [linsert $stack_ctx 0 $ctx]
    }
    proc pop_ctx {} {
        variable stack_ctx
        set stack_ctx [lreplace $stack_ctx 0 0]
    }
    proc top_ctx {} { 
        variable stack_ctx
        lindex $stack_ctx 0
    }
    proc with_ctx {context args} {
        push_ctx $context
        set result [uplevel $args]
        pop_ctx
        return $result
    }

    proc top_context_of_type {context_type} {
        variable stack_ctx
        set indexList 0 ;# match first element of nested list
        set index [lsearch -exact -index $indexList $stack_ctx $context_type]
        return [lindex $stack_ctx $index]
    }

    proc get_context_path_of_type {context_type} {
        variable stack_ctx
        set indexList 0 ;# match first element of nested list
        set contextList [lsearch -all -inline -exact -index $indexList $stack_ctx $context_type]
        set context_path ""
        foreach context [lreverse $contextList] {
            lassign $context context_type context_tag context_name
            append context_path $context_name "."
        }
        return [string trimright $context_path "."]
    }

    # context := {context_type context_tag context_name}
    proc set_lookahead_ctx {name context} {
        set varname "::basesys::lang::lookahead_ctx($name)"
        set $varname $context
    }

    proc get_lookahead_ctx {name} {
        set varname "::basesys::lang::lookahead_ctx($name)"
        set $varname
    }

    #proc lambda {params body args} {
    #    set pre {}
    #    while { ($params ne {} && $args ne {}) || $params eq {args} } { 
    #        if { $params eq {args} } {
    #            append pre "set args [list $args] ; "
    #            set params {}
    #            set args {}
    #        } else {
    #            set params [lassign $params param]
    #            set args [lassign $args arg]
    #            append pre "set $param [list $arg] ; "
    #        }
    #    }   
    #    set body [concat $pre $body]
    #    if { $params ne {} } { 
    #        puts "+++++ lambda returns = [list lambda $params $body]"
    #        return [list lambda $params $body]
    #    }   
    #    # NOTE THAT WE ARE USING uplevel 0 IN ORDER TO PROTECT
    #    # VARS IN THE UPPER STACK FRAME FROM BEING OVERWRITTEN
    #    uplevel 0 $body $args
    #}
    proc lambda {params body args} {

        set {llength_params} [llength ${params}]
        set {llength_args} [llength ${args}]

        if { ${llength_params} - 1 <= ${llength_args} } {
            set {last_param} [lindex ${params} {end}]
            if { ${llength_params} == ${llength_args} || ${last_param} eq {args} } {
                unset {llength_params} {llength_args}
                return [uplevel 0 ${body} [if {${params} eq {}} {
                    # llength_params == 0 and llength_args == 0
                    unset {last_param} {params} {body} {args}
                } elseif { ${last_param} ne {args} } {
                    # llength_params == llength_args
                    lassign ${args} {*}[concat ${params} [unset {last_param} {params} {body} {args}]]
                } else {
                    # (llength_params - 1 <= llength_args) and last_param eq {args}
                    set {args} [lassign ${args} {*}[lrange [concat ${params} [unset {last_param} {params} {body} {args}]] 0 {end-1}]]
                    set {} {}
                }]]
            }
        }

        if { ${args} eq {} } {
            return [list {lambda} ${params} ${body}]
        } elseif {${llength_params} >= ${llength_args}} {
            return [list {lambda} [lrange ${params} ${llength_args} {end}] [concat [list lassign ${args} {*}[lrange ${params} 0 [expr {${llength_args} - 1}]]] { ; } ${body}]]
        } else {
            error "lambda: more args than params"
        }

    } 

    proc set_alias {name cmd} {
        variable alias
        set alias($name) "" ;# set alias($name) $cmd
    }
    proc get_alias {name} {
        variable alias
        set alias($name)
    }
    proc check_alias {name} {
        variable alias
        info exists alias($name)
    }

    # Wow!!!
    set name "alias"
    set cmd [list [namespace which "lambda"] {name cmd} {
        set_alias $name $cmd
        interp alias {} [namespace current]::${name} {} [namespace which "with_fwd"] ${name} {*}${cmd}
        keyword ${name}
    }]
    {*}${cmd} "keyword" {::dom::createNodeCmd elementNode}
    {*}${cmd} ${name} ${cmd}
    # with_fwd alias lambda {name cmd} {
    #   set_alias $name $cmd
    #   interp alias {} [namespace current]::${name} {} [namespace which "with_fwd"] ${name} {*}${cmd}
    #   keyword ${name}
    # }

    alias "node" {lambda {tag name args} {with_ctx [list "eval" $tag $name] ::dom::execNodeCmd elementNode $tag -x-name $name {*}$args}}

    keyword "typeinst"

    # nest argument holds nested calls in the procs below
    # i.e. with_context, nest, meta_helper
    proc nest {nest name args} {
        set tag [top_fwd]
        keyword $name
        set context [list "proc" $tag $name]
        set_lookahead_ctx $name $context

        set nsp [uplevel {namespace current}]
        set type $tag
        set cmd [list [namespace which "node"] $tag $name {*}$args]
        #set cmd [list [namespace which "node"] "typeinst" $name -x-type $type -x-nsp $nsp {*}$args]
        set node [uplevel $cmd]

        puts "!!! nest: $name -> $nest"
        set nest [list with_ctx $context {*}$nest]
        uplevel [list [namespace which "alias"] $name $nest]

        if { $type ni {meta basetype} } {
            $node appendFromScript {
                ${type}.type $tag
                name $name
                nsp $nsp

                foreach typedecl [$node selectNodes {child::typedecl}] {
                    slot [subst -nocommands -nobackslashes {
                        name [$typedecl @x-name]
                        type [$typedecl @x-type]
                        if { [$typedecl hasAttribute "x-default_value"] } {
                            default_value [$typedecl @x-default_value ""]
                        }
                        if { [$typedecl hasAttribute "x-optional_p"] } {
                            optional_p [$typedecl @x-optional_p ""]
                        }
                        if { [$typedecl hasAttribute "x-container"] } {
                            container [$typedecl @x-container ""]
                        }
                    }]
                }

            }
        }
        return $node
    }


    #alias "shiftl" {lambda {_ args} {return $args}}
    #alias "chain" {lambda {args} {foreach arg $args {set args [{*}$arg {*}$args]}}}

    alias "meta" {lambda {name nest args} {nest $nest $name {*}$args}}


    proc container_helper {arg0 args} {

        # remove {proc meta map} from the top of the context stack
        # and at the bottom, put it back so that it will be removed 
        # from whatever put it there
        set top_ctx [top_ctx]
        pop_ctx

        set container_type [top_fwd]

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
            set lookahead_ctx [get_lookahead_ctx $context_name]
            push_ctx $lookahead_ctx 

            puts "----- (container declaration) tag=type=$type name=$name args=$args stack_ctx=$::basesys::lang::stack_ctx context=$context"

            typedecl_args args
            set args [concat -x-container $container_type $args] 
            set cmd [list [namespace which "typedecl_helper"] $type $name {*}$args]
            lappend nodes [with_fwd $tag uplevel $cmd]

            # now pop the temporary context
            pop_ctx

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

            puts "----- (container instantiation) name=$name args=$args"

            lassign $args argv
            foreach arg $argv {
                set cmd [list $name $arg]
                lappend nodes [uplevel $cmd]
            }

        } else {
            error "Usage:\n\n (map|multiple) type name = default_value ?decl_script? \n\t (map|multiple) name inst_script"
        }

        # push the {proc meta map} context back to the top of the context stack
        # as it were before we removed it in the beginning of this proc
        push_ctx $top_ctx

        return $nodes

    }
    meta "multiple" [namespace which "container_helper"]
    meta "map" [namespace which "container_helper"]

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

    proc typedecl_helper {decl_type decl_name args} {
        set decl_tag [top_fwd]

        typedecl_args args
        set cmd [list [namespace which "node"] typedecl $decl_name -x-type $decl_type {*}$args]
        set node [uplevel $cmd]

        set context_path [get_context_path_of_type "eval"]

        puts "--->>> (typedecl_helper) context_path=[list $context_path] stack_ctx=[list $::basesys::lang::stack_ctx]"

        set dotted_name "${context_path}.$decl_name"
        # OBSOLETE: set_lookahead_ctx $dotted_name "proc" $decl_tag $dotted_name
        set dotted_nest [list with_fwd "typeinst" [namespace which "typeinst_helper"] $decl_type $dotted_name]
        set dotted_nest [list with_ctx [list "proc" $decl_tag $dotted_name] {*}$dotted_nest] 
        set cmd [list [namespace which "alias"] $dotted_name $dotted_nest]
        uplevel $cmd

        return $node

    }
    
    meta "typedecl" [namespace which "typedecl_helper"]

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
                set args [list [list [namespace which "t"] [lindex $args 1]]]
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

            set lookahead_ctx [get_lookahead_ctx $inst_type]
            lassign $lookahead_ctx lookahead_ctx_type lookahead_ctx_tag lookahead_ctx_name
            if { $lookahead_ctx_tag eq {basetype} } {
                set args [list [list [namespace which "t"] [lindex $args 0]]]
            }
        }
    }

    proc typeinst_helper {inst_type inst_name args} {
        set inst_tag [top_fwd]

        typeinst_args $inst_type args

        set context [top_context_of_type "proc"]
        set context_tag [lindex $context 1]
        set context_name [lindex $context 2]

        puts "--->>> (typeinst_helper) context=[list $context] stack_ctx=[list $::basesys::lang::stack_ctx]"
        
        set cmd [list [namespace which "node"] typeinst $inst_name -x-type $inst_type {*}$args]
        return [uplevel $cmd]

    }

    meta "typeinst" [namespace which "typeinst_helper"]

    proc is_dotted_p {name} {
        return [expr { [llength [split ${name} {.}]] > 1 }]
    }

    proc is_declaration_mode_p {} {
        # set context [top_context_of_type "eval"]
        variable stack_ctx
        set context [lindex $stack_ctx end]
        #if { $context eq {proc metatype struct} || $context eq {proc meta metatype} }
        if { $context eq {proc struct struct} || $context eq {proc meta struct} } {
            return 1
        }
        return 0
    }

    proc type_helper {name args} {
        set tag [top_fwd]

        puts "--->>> type_helper (is_declaration_mode_p=[is_declaration_mode_p]) tag=$tag name=$name {*}$args"
        
        set type $tag
        if { [is_declaration_mode_p] } {
            set cmd [list [namespace which "typedecl_helper"] $type $name {*}$args]
            return [with_fwd $tag uplevel $cmd]
        } else {
            push_fwd $tag
            set cmd [list [namespace which "typeinst_helper"] $type $name {*}$args]
            set result [uplevel $cmd]
            pop_fwd
            return $result
        }
    }

    meta "basetype" {nest {type_helper}}

    # a varying-length text string encoded using UTF-8 encoding
    basetype "varchar"

    # a boolean value (true or false)
    basetype "bool"

    # a varying-bit signed integer
    basetype "varint"

    # an 8-bit signed integer
    basetype "byte"

    # a 16-bit signed integer
    basetype "int16"

    # a 32-bit signed integer
    basetype "int32"

    # a 64-bit signed integer
    basetype "int64"

    # a 64-bit floating point number
    basetype "double"

    # EXPERIMENTAL
    # pair
    # tuple
    # record

    meta "struct" {nest {nest {type_helper}}}

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
            # VERY OLD: set node [typedecl_helper ---slot_class_helper--- "" slot $field_name -type $datatype {*}${args}]

            if { $container_type ne {} } {
                $node setAttribute container_type $container_type
            }

        } else {
            if { ![is_dotted_p $field_type] } {

                set stack_ctx $::basesys::lang::stack_ctx

                set stack_proc_ctx [lsearch -all -inline -index 0 $stack_ctx {proc}]
                puts $stack_proc_ctx
                foreach context $stack_proc_ctx {
                    puts "--->>> context=$context"
                    lassign $context context_type context_tag context_name

                    set redirect_name "${context_name}.$field_type"

                    if { 0 } {
                        puts "+++ stack_ctx=[list $::basesys::lang::stack_ctx]"
                        puts "+++ info proc=[uplevel [list info proc $redirect_name]]"
                        puts "+++ alias=[array get ::basesys::lang::alias]"
                        puts "+++ alias_exists_p=[[namespace which check_alias] $redirect_name]"
                    }

                    set redirect_exists_p [[namespace which check_alias] $redirect_name]
                    if { $redirect_exists_p } {
                        puts "+++ $field_type $field_name $args -> redirect_name=$redirect_name"
                        set context [list "unknown" "unknown" $redirect_name]
                        set cmd [list $redirect_name $field_name {*}$args]
                        with_ctx $context uplevel $cmd
                        return
                    } else {
                        set redirect_name "${context_tag}.${field_type}"
                        set redirect_exists_p [[namespace which check_alias] $redirect_name]
                        if { $redirect_exists_p } {
                            puts "+++ $field_type $field_name $args -> redirect_name=$redirect_name"
                            set cmd [list $redirect_name $field_name {*}$args]
                            with_ctx [list "unknown" "unknown" $redirect_name] uplevel $cmd
                            return
                        }
                    }
                }

            } else {
                error "no such field_type: $field_type stack_ctx=$::basesys::lang::stack_ctx"
            }
        }
    }

    namespace unknown unknown

    proc import_helper {import_tag import_name args} {
        set node [uplevel [list ::dom::createNodeInContext elementNode $import_tag -name $import_name {*}$args]]
        uplevel [list namespace import ::${import_name}::lang::*]
        return $node
    }

    alias "import" [namespace which "import_helper"]

    variable dtd
    proc dtd_helper {args} {
        variable dtd
        if { $args eq {} } {
            return $dtd
        } else {
            set dtd [lindex $args 0]
        }
    }

    alias "dtd" [namespace which "dtd_helper"]

    dtd {
        <!DOCTYPE pdl [

            <!ELEMENT pdl (struct | typeinst)*>
            <!ELEMENT struct (struct | typedecl | typeinst)*>
            <!ATTLIST struct x-name CDATA #IMPLIED>

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

    namespace export "import" "struct" "varchar" "bool" "varint" "byte" "int16" "int32" "int64" "double" "multiple" "dtd" "lambda"

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




