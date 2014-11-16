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

    dtd {
        <!DOCTYPE struct [
            <!ELEMENT struct (attribute | extends | index)*>
            <!ATTLIST struct id CDATA #REQUIRED
                      is_final_if_no_scope CDATA #IMPLIED>

            <!ELEMENT attribute (name, datatype, default?, optional_p?)>
            <!ELEMENT name (#PCDATA)>
            <!ELEMENT datatype (#PCDATA)>
            <!ELEMENT default (#PCDATA)>
            <!ELEMENT optional_p (#PCDATA)>

            <!ELEMENT extends EMPTY>
            <!ATTLIST extends ref CDATA #REQUIRED>

            <!ELEMENT index EMPTY>
            <!ATTLIST index attr CDATA #REQUIRED>
        ]>
    }

}

set filename "message.pdl"

set doc [source_tdom $filename ::persistence::lang]

# puts [$doc asXML]

set struct_node [$doc selectNodes {//struct}]

::dom::scripting::validate ::persistence::lang [$struct_node asXML]
