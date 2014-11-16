source ../../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require tdom_procs

define_lang ::persistence::lang {

    node_cmd "struct"
    node_cmd "attribute"
    
    text_cmd "name"
    text_cmd "datatype"
    text_cmd "default"
    text_cmd "optional_p" "true"

    proc_cmd "string" attribute_helper
    proc_cmd "integer" attribute_helper
    proc_cmd "boolean" attribute_helper

    proc attribute_helper {datatype name {default_value ""}} {
        attribute {
            name ${name}
            datatype ${datatype}
            if { $default_value ne {} } {
                default ${default_value}
            }
        }
    }

    node_cmd index
    node_cmd extends

}

set filename "message.pdl"

set doc [source_tdom $filename ::persistence::lang]

puts [$doc asXML]
