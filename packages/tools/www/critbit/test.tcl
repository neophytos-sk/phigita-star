::xo::lib::require critbit_tree


ad_page_contract {
    @author Neophytos Demetriou
} {
    handle:trim,notnull
}

cbt::extend $handle "hello world"

append result "\n contains(abba)=[cbt::contains $handle abba]"
append result "\n contains(abba)=[cbt::allprefixed $handle ""]"

doc_return 200 text/plain $result
