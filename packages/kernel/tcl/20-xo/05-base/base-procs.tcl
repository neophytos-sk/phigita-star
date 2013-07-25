namespace eval ::xo {;}
namespace eval ::xo::base {;}

Class ::xo::base::NodeLabelVisitor -parameter {
    {nodeCount "0"}
}
::xo::base::NodeLabelVisitor instproc obfuscate2 {nodeCount} {
    return [format {%X} $nodeCount]
}
set i 0
foreach char {
    a b c d e f g h i j k l m n
    o p q r s t u v w x y z A B
    C D E F G H I J K L M N O P
    Q R S T U V W X Y Z 0 1 2 3
    4 5 6 7 8 9 $ _
} {
    ::xo::base::NodeLabelVisitor set sBase64Chars(${i}) $char
    incr i
}
::xo::base::NodeLabelVisitor instproc obfuscate {id} {
    ::xo::base::NodeLabelVisitor instvar sBase64Chars
    set result ""
    append result $sBase64Chars([expr {${id} & 0x1f}])
    set id [expr { ${id} >> 5  }]
    while { ${id} != 0 } {
	append result $sBase64Chars([expr {${id} & 0x3f}])
	set id [expr { ${id} >> 6  }]
    }
    return ${result}
}

::xo::base::NodeLabelVisitor instproc setLabel {o} {

    $o instvar nodeLabel
    if { [$o parentNode] ne {} } {
	set tmpNodeLabel [[$o parentNode] nodeLabel]
	lappend tmpNodeLabel [$o nodeIndex]
	set nodeLabel [join $tmpNodeLabel .]
    }

    if { [$o domNodeId] eq {} } {
	my instvar nodeCount
	$o set domNodeId [my obfuscate $nodeCount]_ ;# underscore is important to avoid name conflicts with global js vars
	incr nodeCount
    }

    my set objectFrom([$o domNodeId]) $o

}

Object CLASS_EQ -proc check {o cl} {
    return [expr { [$o info class] eq ${cl} }] 
}

### Node
Class ::xo::base::Node -parameter {
    {nodeName  "[self]"}
    {nodeType  "[self class]"}
    {nodeIndex ""}
    {nodeLabel ""}
}


::xo::base::Node instproc init/1 {script} {
    my appendFromScript $script
    return [next]
}

::xo::base::Node instproc TEST_init {args} {
    set argc [llength $args]
    if { $argc && [my info procs init/$argc] ne {}} {
	return [eval my init/${argc} $args]
    }
    return [next]
}


::xo::base::Node instproc parentNode {} {
    my instvar __parentNode
    if { [info exists __parentNode] } {
	return $__parentNode
    } else {
	return
    }
}

::xo::base::Node instproc findParent {{-maxDepth ""} {-returnEl ""} selector args} {
    set o [my parentNode]
    while { $o ne {} } {
	if { [$selector check $o {*}${args}] } {
	    return $o
	}
	set o [$o parentNode]
    }
    return
}

::xo::base::Node instproc findChildren {{-maxDepth ""} {-returnEl ""} selector args} {
    set result [list]
    foreach o [my childNodes] {
	if { [$selector check $o {*}${args}] } {
	    lappend result $o
	}
	lappend result [$o findChildren $selector {*}${args}]
    }
    return [join $result]
}

::xo::base::Node instproc accept {{-rel "default"} {-action "visit"} visitor} {
    next
    set result [$visitor $action [self]]
    return $result
}

### ::xo::base::AbstractCollection
Class ::xo::base::AbstractCollection
::xo::base::AbstractCollection abstract instproc each {name script}
::xo::base::AbstractCollection abstract instproc appendFromScript {script}        ;# concat.eval
::xo::base::AbstractCollection abstract instproc appendChild {newChild}           ;# lappend
::xo::base::AbstractCollection abstract instproc removeChild {child}              ;# lreplace (without element arguments)
::xo::base::AbstractCollection abstract instproc replaceChild {newChild oldChild} ;# lreplace (with element arguments)



### ::xo::base::AbstractVisitor
Class ::xo::base::AbstractVisitor
::xo::base::AbstractVisitor abstract instproc visit {o}


### Composite
Class ::xo::base::Composite -superclass { ::xo::base::Node ::xo::base::AbstractCollection } -parameter {
    {childCount "0"}
    {__rels ""}
}


::xo::base::Composite instproc appendChild {{-rel "default"} o} {
    my incr childCount
    my lappend __childNodes(${rel}) ${o}
    #HERE: DO NOT ENABLE --- iaccept is severely affected by this: my lappend __rels ${rel}
    ${o} set __parentNode [self]
    ${o} nodeIndex [my childCount]
}

::xo::base::Composite instproc childNodes {{-rel "default"}} {
    my instvar __childNodes
    if { [info exists __childNodes(${rel})] } {
	return $__childNodes(${rel})
    } else {
	return
    }
}

### NEW
::xo::base::Composite instproc contains {script} {
    # ::xotcl::Object instmixin add ::xo::base::Component end
    ::xotcl::Object class mixin add ::xo::base::Component end
    eval $script
    ::xotcl::Object class mixin delete ::xo::base::Component
    # ::xotcl::Object instmixin delete ::xo::base::Component
}



::xo::base::Composite instproc appendFromScript {{-rel "default"} script} {
    global __CONTEXT__
    global __REL__

    set prev_context ""
    if { [info exists __CONTEXT__] } {
	set prev_context $__CONTEXT__
    }
    set prev_rel ""
    if { [info exists __REL__] } {
	set prev_rel $__REL__
    }
    set prev_parent_tree_sk ""
    if { [info exists __PARENT_TREE_SK__] } {
	set prev_parent_tree_sk $__PARENT_TREE_SK__
    }
    set __CONTEXT__ [self]
    set __REL__ $rel
    my __appendFromScript [list uplevel 2 $script]
    set __REL__ $prev_rel
    set __CONTEXT__ $prev_context
}

::xo::base::Composite instproc __appendFromScript {script} {
    set instmixins [Object info instmixin]
    Object instmixin add ::xo::base::Component
    eval $script
    Object instmixin $instmixins
}

::xo::base::Composite instproc removeChild {{-rel "default"} child} {
    if { [my llength __childNodes(${default})] == 0 } {
	my unset __childNodes
    }
}
::xo::base::Composite instproc empty_p {{-rel "default"}} {
    return [expr {![my exists __childNodes(${rel})]}]
}

::xo::base::Composite instproc each {{-rel "default"} name script} {
    uplevel [self callinglevel] [list foreach ${name} [my childNodes -rel ${rel}] ${script}]
}

::xo::base::Composite instproc accept {{-rel "default"} {-action "visit"} visitor} {
    set result [next]
    foreach child [my childNodes -rel ${rel}] {
	$child accept -action $action $visitor
    }
    return $result
}


### Component
Class ::xo::base::Component
::xo::base::Component instproc init {args} {
    global __CONTEXT__
    global __REL__
    set result [next]
    my set __parentNode $__CONTEXT__
    $__CONTEXT__ appendChild -rel ${__REL__} [self]
    return ${result}
}





### SortableComposite
Class ::SortableComposite -superclass { ::xo::base::Composite } -parameter {{cache_p "no"} {order "increasing"} varname}

::SortableComposite instproc childNodes {} {
    my instvar cache_p order varname

    if { ${cache_p} } {
	my instvar __sortedChildNodes__${order}__${varname}
    }
    if { ![info exists __sortedChildNodes__${order}__${varname}] } {
	set __sortedChildNodes__${order}__${varname} [lsort -command [list my __compare -varname ${varname}] -${order} [next]]
    }
    return [set __sortedChildNodes__${order}__${varname}]
}

::SortableComposite instproc __compare {{-order "increasing"} {-varname ""} a b} {

    if { ${varname} eq {} } {
	return 0
    }

    set x [${a} set ${varname}]
    set y [${b} set ${varname}]
    if {${x} < ${y}} {
	return -1
    } elseif {${x} > ${y}} {
	return 1
    } else {
	return 0
    }

}



Class ::Element -superclass { ::xo::base::Composite }
#Class ::SortableElement -superclass { ::SortableComposite }

Class ::Atom -superclass ::xo::base::Node 
::Atom instproc init {value} {
    my instvar __nodeValue
    set __nodeValue ${value}
}
::Atom instproc nodeValue {} {
    my instvar __nodeValue
    if { [info exists __nodeValue] } {
	return ${__nodeValue}
    } else {
	return
    }
}

Class ::Text -superclass ::Atom
Class ::Comment -superclass ::Atom
Class ::List -superclass { ::Atom ::xo::base::AbstractCollection }
::List instproc each {name script} {
    uplevel [self callinglevel] [list foreach ${name} [my nodeValue] ${script}]
}

::List instproc appendFromScript {script} {
    my instvar __nodeValue
    set __nodeValue [concat ${nodeValue} [my eval ${script}]]
}

### Ordered list of tuples
Class ::OrderedList -superclass ::List -parameter {{cache_p "no"} {order "increasing"} {type dictionary} {index "0"}}

::OrderedList instproc nodeValue {} {
    my instvar cache_p order type index

    if { ${cache_p} } {
	my instvar __sortedNodeValue__${order}__${index}
    }
    if { ![info exists __sortedNodeValue__${order}__${index}] } {
	set __sortedNodeValue__${order}__${index} [lsort -${type} -index ${index} -${order} [next]]
    }
    return [set __sortedNodeValue__${order}__${index}]
}

proc this {} {
    global __CONTEXT__
    return $__CONTEXT__
}