source ../../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require tdom_procs

define_lang ::persistence::lang {

    node_cmd "struct"
    node_cmd "slot"
    
    text_cmd "name"
    text_cmd "type"
    text_cmd "default"
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

    proc attribute_helper {datatype name args} {

        set default_value {}

        if { $args ne {} } {

            if { [llength $args] != 2 || [lindex $args 0] ne {=} } {
                error "usage: datatype name = default_value"
            }

            set default_value [lindex $args 1]

        }

        slot {
            name ${name}
            type ${datatype}
            if { $default_value ne {} } {
                default ${default_value}
                optional_p true
            }
        }
    }

    node_cmd index
    node_cmd extends

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
                $node appendFromScript { container_type $container_type }
            }

        } else {
            set doc $::__source_tdom_doc
            set xpath "//struct\[@name=\"${field_type}\"\]"
            set nodes [$doc selectNodes ${xpath}]
            if { $nodes eq {} } {
                error "no such field type: $field_type nodes=[list $nodes]"
            } else {

                attribute_helper $field_type $field_name {*}${args}

                #extend_lang ::persistence::lang "text_cmd $field_type"
                #namespace inscope ::persistence::lang "${field_type} ${field_name}"
            }
        }

    }

    dtd {
        <!DOCTYPE pdl [

            <!ELEMENT pdl (struct*)>
            <!ELEMENT struct (slot | extends | index)*>
            <!ATTLIST struct name CDATA #REQUIRED
                      is_final_if_no_scope CDATA #IMPLIED>

            <!ELEMENT slot (name, type, default?, optional_p?, container_type?)>
            <!ELEMENT name (#PCDATA)>
            <!ELEMENT type (#PCDATA)>
            <!ELEMENT default (#PCDATA)>
            <!ELEMENT optional_p (#PCDATA)>
            <!ELEMENT container_type (#PCDATA)>

            <!ELEMENT extends EMPTY>
            <!ATTLIST extends ref CDATA #REQUIRED>

            <!ELEMENT index EMPTY>
            <!ATTLIST index attr CDATA #REQUIRED>
        ]>
    }

}

set filename "message.pdl"

set doc [source_tdom $filename ::persistence::lang]

puts [$doc asXML]

# set struct_node [$doc selectNodes {//struct}]
# ::dom::scripting::validate ::persistence::lang [$struct_node asXML]

set root [$doc documentElement]
::dom::scripting::validate ::persistence::lang [$root asXML]

set nodes [$doc selectNodes {//struct[@name="message"]/slot}]
set slots [list]
foreach node $nodes {

    set name ""
    set type ""
    set default ""
    set optional_p ""
    set container_type ""

    set childnodes [$node childNodes]
    foreach child $childnodes {
        set [$child nodeName] [$child text]
    }

    lappend slots [list $name $type $default $optional_p $container_type]

}

array set ::persistence::lang::slots [list message $slots]

# ::dom::scripting::create_value ::persistence::lang message [list from [list find_by email "someone@example.com"]]

set message_dict {

    device "sms"

    num_comments 123

    from { email "someone@example.com" }
    from/refs {_247}

    to { {email "zena@example.com"} {email "jane@example.com"} }
    to/refs { 
        {email "zena@example.com"} 
        {email "jane@example.com"} 
    }

    cc {}

    bcc {}

    subject "hello world"

    body "hello world this is a test ... repeat many times ..."

    public_p false

    categories { {name "sports"} {name "technology"} {"culture"} }
    categories/refs {
        _222 
        _888 
        _555
    }

    folders { {name "works"} {name "somefolder"} {"anotherfolder"} }
    folders/refs {
        _123 
        _456 
        _789
    }

    tags {
        "#sports" 
        "#event"
    }

    attachment {
        name "/tmp/somefile"
        size 12345
    }

    wordcount {
        "hello" 12 
        "world" 5 
        "this" 18 
        "is" 22 
        "a" 55 
        "test" 1
    }

}

::dom::scripting::serialize ::persistence::lang message $message_dict
