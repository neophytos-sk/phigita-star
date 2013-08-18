source /web/service-phigita/packages/tools/lib/critcl-ext/tcl/module-critcl-ext.tcl
source /web/service-phigita/packages/kernel/tcl/20-xo/fun/functional-procs.tcl
source /web/service-phigita/packages/kernel/tcl/0000-utils/00-util-procs.tcl

proc ns_log {level args} {
    puts "$level: $args"
}


ctype_template cbt critbit0_tree {
    voidptr_t root;
} "" code init_text init_exts

puts "init_text:-------------------\n$init_text"
puts "init_exts:-------------------\n$init_exts"
puts "code:-------------------\n$code"