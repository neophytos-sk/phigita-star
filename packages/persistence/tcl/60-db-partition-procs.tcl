Class Partition -parameter {
    {subject "[namespace tail [self]]"}
}


Class Partition=HASH -superclass "Partition" -parameter {
    {nbuckets "64"}
}


Partition=HASH instproc suffix {o} {

    my instvar nbuckets subject

    set value [${o} set ${subject}]
    return "__H[expr int(${value} % ${nbuckets})]"

}

Class Partition=HASH_TEXT -superclass "Partition" -parameter {
    {first_index "0"}
    {last_index "1"}
}


Partition=HASH_TEXT instproc suffix {o} {

    my instvar subject first_index last_index

    set str [${o} set ${subject}]
    return "__T[string range ${str} ${first_index} ${last_index}]"

}


Class Partition=HASH_SHA1 -superclass "Partition" -parameter {
    {first_index "0"}
    {last_index "1"}
}


Partition=HASH_SHA1 instproc suffix {o} {

    my instvar subject first_index last_index

    set str [ns_sha1 [${o} set ${subject}]]
    return "__S[string range ${str} ${first_index} ${last_index}]"

}

# A guard is a set of conditions

Class Partition=RANGE -superclass "Partition" -parameter {
    {guard_list ""}
}


Partition=RANGE instproc suffix {o} {

    my instvar guard_list subject

    set count 0
    foreach guard ${quard_list} {
	if { [${guard} is_true [${o} set ${subject}]] } {
	    return "__R${count}"
	}
	incr count
    }

    return ""
}

Class Partition=FUNCTIONAL -superclass "Partition" -parameter {
    {fn ""}
}

Partition=FUNCTIONAL instproc suffix {o} {
    my instvar fn
    set value [$subject get_raw_value $o]
    return __F[eval ${fn} $value]
}


### clock format [clock seconds] -format "%Y_%m"

namespace eval ::xo {;}
namespace eval ::xo::fn {;}
proc ::xo::fn::get_year_month {seconds} {
}

