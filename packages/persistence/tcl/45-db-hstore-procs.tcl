Class HStore -superclass "::xo::base::Attribute" -parameter {
    {datatype   "hstore"}
    {acc_method "GIST"}
}

HStore instproc init {args} {
    my instvar acc_method
    ns_log notice "hstore acc_method = $acc_method"
    set acc_method GIST
}

HStore instproc getValue {o} {

    my instvar name



    set tmplist ""
    if { [$o exists ${name}] } {
	set tmplist [$o set ${name}]
    }
    foreach varname [$o info vars ${name}.*] {
	set key [lindex [split $varname .] 1]
	set value [$o set ${varname}]
	lappend tmplist [list $key $value]
    }


    set result ""
    if { $tmplist ne {} } {
	foreach item $tmplist {
	    lassign $item key value
	    lappend result "[::util::doublequote ${key}]=>[::util::doublequote ${value}]"
	}
	set result [::util::dbquotevalue [join ${result} ","]]
    } else {
	set result [my default_value ${o}]
    }

    return $result
}

