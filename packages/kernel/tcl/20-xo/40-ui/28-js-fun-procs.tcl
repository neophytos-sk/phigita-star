namespace eval ::xo {;}
namespace eval ::xo::ui {;}

::xo::ui::Class ::xo::ui::JS.Function -superclass {::xo::ui::Widget} -parameter {

    {argv ""}
    {body ""}
    {needs ""}
    {lazy_p "no"}

} -jsClass Function

::xo::ui::JS.Function instproc getConstructor {} {
    my instvar domNodeId argv body
    set arg_parser ""
    set i 0
    set arg_parser ""
    set argc [llength $argv]
    if { $argc > 1 } {
	set argsVarName _0
	set prefix "var _0=arguments;"
    } else {
	set argsVarName arguments
	set prefix ""
    }

    foreach arg $argv {
	lappend arg_parser "${arg}=${argsVarName}\[$i\]"
	incr i
    }
    if { $arg_parser ne {} } {
	set arg_parser "${prefix}var [join $arg_parser {,}];"
    }
    set aliases [my getAliases]
    return "${domNodeId}=function(){${aliases}${arg_parser}${body}};"
}

::xo::ui::JS.Function instproc render {visitor} {
    
    my instvar domNodeId needs
    eval $visitor ensureLoaded $needs

    $visitor inlineJavascript [my getJS]
    $visitor onReady _${domNodeId}.init _${domNodeId} true
    return [next]

}
