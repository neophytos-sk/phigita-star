namespace eval ::xo {;}
namespace eval ::xo::db {;}
namespace eval ::xo::db::op {;}


proc ::xo::db::op::eq-noquote {name value} {
    return "${name} = ${value}"
}
proc ::xo::db::op::eq {name value} {
    return "${name} = [ns_dbquotevalue ${value}]"
}
proc ::xo::db::op::= {name value} {
    return "${name} = [ns_dbquotevalue ${value}]"
}
proc ::xo::db::op::like {name value} {
    return "${name} like [ns_dbquotevalue ${value}]"
}
proc ::xo::db::op::ilike {name value} {
    return "${name} ilike [ns_dbquotevalue ${value}]"
}
proc ::xo::db::op::in {name value} {
    return "${name} in [::util::sqllist ${value}]"
}

proc ::xo::db::op::sha1-eq {name value} {
    return "extra->'sha1(${name})' = [ns_dbquotevalue [ns_sha1 ${value}]]"
}
proc ::xo::db::op::trigrams-contains {name value} {
    return "${name} @@ [::ttext::trigrams.tsQuery ${value}]"
}

proc ::xo::db::qualifier {name op value} {
    # get column corresponding to the given "name" and "operator"
    # for example, getIndexColumnFor columnName op
    return [::xo::db::op::${op} ${name} ${value}]
}
