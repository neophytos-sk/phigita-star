Class Sequence -parameter {
    {subject     ""}
    {minvalue    ""}
    {maxvalue    ""}
    {increment   ""}
    {cache       ""}
    {isCyclic    "no"}
    {isTemporary "no"}
}



Sequence instproc nextval {} {
    return 1
}


Sequence instproc asSQL {{qualifiedName ""}} {

    return "CREATE SEQUENCE [my getSequenceQName ${qualifiedName}];"
}

Sequence instproc getSequenceQName {{qualifiedName ""}} {
    return [lindex [split ${qualifiedName} .] 0].[[my dom] name]__seq
}
