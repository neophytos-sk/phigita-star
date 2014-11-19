source ../../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require persistence

set filename "message.pdl"

set doc [source_tdom $filename ::persistence::lang]

puts [$doc asXML]

# set struct_node [$doc selectNodes {//struct}]
# ::dom::scripting::validate ::persistence::lang $struct_node

set root [$doc documentElement]

::dom::scripting::validate ::persistence::lang $root

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

::persistence::serialize message $message_dict
