
Class AssociativeArray 
AssociativeArray instproc init {} {
    my setValue {}
}
AssociativeArray instproc setValue {{-type "atom"} list} {
    my instvar __array__
    foreach {key value} $list {
	set __array__(${type},${key}) $value
    }
}
AssociativeArray instproc getValue {} {
    my instvar __array__
    return [array get __array__]
}
AssociativeArray instproc names {} {
    my instvar __array__
    return [array names __array__]
}
AssociativeArray instproc setValueOf {{-type atom} key value} {
    my instvar __array__
    return [set __array__(${type},${key}) $value]
}
AssociativeArray instproc json_encode {} {
    set result ""
    foreach {key value} [my getValue] {
	foreach {keyNS keyName} [split $key ,] break
	if {$keyNS eq {object}} {
	    set value [$value json_encode]
	} elseif { $keyNS eq {js}} {
	    # do nothing, as is
	} elseif { $keyNS eq {atom}} {
	    #set value [::util::jsquotevalue ${value}]
	    set value [::util::jsquotevalue ${value}]
	}
	lappend result [::util::jsquotevalue ${keyName}]:${value}
    }
    set result [join $result ,]
    return \{${result}\}
}

Class ListArray
ListArray instproc init {} {
    my setValue {}
}
ListArray instproc setValue {value} {
    my instvar __list__
    return [set __list__ $value]
}
ListArray instproc getValue {} {
    my instvar __list__
    return $__list__
}
ListArray instproc json_encode {} {
    set result ""
    foreach el [my getValue] {
	foreach {type value} [split $el |] break
	if { $type eq {object} } {
	    lappend result [$value json_encode]
	} elseif { $type eq {atom} } {
	    lappend result [::util::jsquotevalue $value]
	}
    }
    set result [join $result ,]
    return \[${result}\]
}
ListArray instproc add {{-type atom} value} {
    my instvar __list__
    lappend __list__ ${type}|${value}
}
