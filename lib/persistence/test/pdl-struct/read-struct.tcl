source ../../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require persistence

set filename "message.pdl"

set doc [source_tdom $filename ::typesys::lang]

puts [$doc asXML]

# set struct_node [$doc selectNodes {//struct}]
# ::dom::scripting::validate ::persistence::lang $struct_node

set root [$doc documentElement]

::dom::scripting::validate ::typesys::lang $root

# ::dom::scripting::create_value ::persistence::lang message [list from [list find_by email "someone@example.com"]]
set message_dict {

    message_id "12345"

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


namespace eval ::persistence::lang::_info_ {;}

proc init_struct {node} {
    set attributes [list]
    set attnodes [$node selectNodes {descendant::typedecl}]
    foreach attnode $attnodes {

        set name [$attnode @x-name]
        set type [$attnode @x-type]
        set default_value [$attnode @default_value ""]
        set optional_p [$attnode @optional_p ""]
        set container_type [$attnode @container_type ""]
        set subtype [$attnode @subtype ""]

        lappend attributes [list $name $type $default_value $optional_p $container_type $subtype]
    }

    set class_name [$node @x-name]

    # puts "init_struct $class_name"

    set varname ::persistence::lang::_info_::${class_name}(attributes)
    set $varname $attributes
}

proc init_struct_all {doc} {
    set nodes [$doc selectNodes "//struct"]
    foreach node $nodes {
        init_struct $node
    }
}

proc serialize {struct dict} {

    set attributes [set ::persistence::lang::_info_::${struct}(attributes)]

    set header [list]
    set values [list]

    foreach att $attributes {

        lassign $att name type default_value optional_p container_type

        if { [dict exists $dict $name] } {

            set value [dict get $dict $name]

        } elseif { $default_value ne {} } {

            set value $default_value

        } elseif { $optional_p ne {true} } {

            error "required attribute (=${name}) missing"

        }

        # puts "$name = $value"

        lappend header ${name}
        lappend values ${value}

    }

    puts $header
    puts [string map {"\n" "\\n"} $values]
}

init_struct_all $doc
serialize message $message_dict
