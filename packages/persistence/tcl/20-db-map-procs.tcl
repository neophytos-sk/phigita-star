namespace eval ::xo::pg {;}

proc ::xo::pg::table_exists {tablename} {
    set sql "SELECT 1 FROM pg_namespace ns join pg_class c on (ns.oid=c.relnamespace) WHERE ns.nspname='${ns}' and c.relname='${name}' LIMIT 1"
    set db [::xo::db::gethandle]
    set row [ns_db 0or1row $db $sql]
    if { $row ne {} } {
	return 1
    } else {
	return 0
    }
}
proc ::xo::pg::column_exists {tablename attname} {
    lassign [split $tablename .] nspname typname
    set sql "SELECT nspname,typname,attname 
             FROM pg_attribute a inner join pg_type t on (a.attrelid=t.typrelid) inner join pg_namespace nsp on (t.typnamespace=nsp.oid) 
             WHERE nspname=[ns_dbquotevalue $nspname]
             AND typname = [ns_dbquotevalue $typname]
             AND attname = [ns_dbquotevalue $attname]"
    #ns_log notice "(column_exists) sql=$sql"
    set db [::xo::db::gethandle]
    set row [ns_db 0or1row $db $sql]
    #ns_log notice "row=[xo::ns::printset $row]"
    if { $row ne {} } {
	return 1
    } else {
	return 0
    }
}



Class DB_Mapper

Class DB_Mapper=PostgreSQL -superclass DB_Mapper


###

DB_Mapper=PostgreSQL instproc getDBPool {dbObject} {

    return "main"

    set dbClass [${dbObject} info class]

    if {![string equal [${dbClass} scope] ""]} {
    
	set toplevel [lindex [${dbClass} scope] 0]

	if {[string equal [${dbClass} set map(scope:${toplevel})] "NS"]} {
	    return [string tolower ${toplevel}]
	}
    }


}

DB_Mapper=PostgreSQL instproc getDBSchema {dbObject} {

    set result ""

	foreach {class value} [${dbObject} pathexp] {
	    lappend result [${class} shorthand]${value}
	}


    return [join "[my prefix] ${result}" "__"]

}


DB_Mapper=PostgreSQL instproc getDBTable {dbObject} {

    set suffix ""

    foreach partition [my partitions] {
	append suffix [${partition} suffix ${dbObject}]
    }

    return  [join "[my prefix] [my name]${suffix}" "__"]
}


DB_Mapper=PostgreSQL instproc dbNamespace {pathexp} {

    set result ""

	foreach {class value} ${pathexp} {
	    #ns_log notice "class=$class value=$value"
	    lappend result [${class} shorthand]${value}
	}


    return [join "[my prefix] ${result}" "__"]

}

DB_Mapper=PostgreSQL instproc dbPool {ns} {
    return main
}


DB_Mapper=PostgreSQL instproc dbTable {{dbObject ""}} {

    if {[string equal [my prefix] "public"]} {
	return [string tolower [my name]]s
    }
    set suffix ""

    if {[Object isobject ${dbObject}]} {
	foreach partition [my partitions] {
	    append suffix [${partition} suffix ${dbObject}]
	}
    }

    return  [join "[my prefix] [my name]${suffix}" "__"]
}



# Schema

DB_Mapper=PostgreSQL instproc pdl.schema.exists {ns} {
    return "SELECT 1 FROM pg_namespace ns WHERE ns.nspname='${ns}' LIMIT 1"
}

DB_Mapper=PostgreSQL instproc pdl.schema.create {ns} {
    return "CREATE SCHEMA ${ns};"
}

DB_Mapper=PostgreSQL instproc pdl.schema.drop {ns} {
    return "DROP SCHEMA ${ns};"
}

# Class

DB_Mapper=PostgreSQL instproc pdl.class.create {dbObject} {

    set sql ""
    append sql [my pdl.schema.create ${dbObject}]
    append sql [my pdl.sequence.create ${dbObject}]
    append sql [my pdl.table.create ${dbObject}]
    append sql [join [aux::map [list my pdl.index.create ${dbObject}] [my indexes]]]

    return ${sql}
}


DB_Mapper=PostgreSQL instproc pdl.class.drop {args} {
    set sql ""
    append sql [aux::map [list my pdl.index.drop ${dbObject}] [my indexes]]
    append sql [my pdl.table.drop ${schema_name} ${dbObject}]
    return ${sql}
}


# Table

DB_Mapper=PostgreSQL instproc pdl.table.qualifiedName {ns table} {
    return ${ns}.${table}
}

DB_Mapper=PostgreSQL instproc pdl.table.create {ns table} {
    set sql ""
    append sql "CREATE TABLE [my pdl.table.qualifiedName ${ns} ${table}] ([join [aux::map [list my attributemap ${ns}] [my attributes]] {, }]);"

    append sql [join [aux::map [list my pdl.index.create ${ns} ${table}] [my indexes]]]
    #ns_log notice "sql=$sql"
    return ${sql}
}

DB_Mapper=PostgreSQL instproc pdl.table.exists {ns name} {
    return "SELECT 1 FROM pg_namespace ns join pg_class c on (ns.oid=c.relnamespace) WHERE ns.nspname='${ns}' and c.relname='${name}' LIMIT 1"
}

# Index

DB_Mapper=PostgreSQL instproc pdl.index.qualifiedName {table dbIndex} {
    return "${table}__[join [${dbIndex} subject] _]__[${dbIndex} suffix]"
}

DB_Mapper=PostgreSQL instproc pdl.index.create {ns table dbIndex} {
    return "CREATE INDEX [my pdl.index.qualifiedName ${table} ${dbIndex}] ON [my pdl.table.qualifiedName ${ns} ${table}] USING [${dbIndex} acc_method] ([join [${dbIndex} subject] ,]);"
}


# Sequence
DB_Mapper=PostgreSQL instproc pdl.sequence.qualifiedName {ns} {
    return "${ns}.[my name]__seq"
}

DB_Mapper=PostgreSQL instproc pdl.sequence.create {ns} {
    set sql "CREATE SEQUENCE [my pdl.sequence.qualifiedName ${ns}];"
    #ns_log notice sql=$sql
    return $sql
}

DB_Mapper=PostgreSQL instproc pdl.sequence.nextvalue {ns} {
    return "SELECT nextval('[my pdl.sequence.qualifiedName ${ns}]');"
}

DB_Mapper=PostgreSQL instproc pdl.sequence.exists {ns} {
    return "SELECT 1 FROM pg_namespace ns join pg_class c on (ns.oid=c.relnamespace) WHERE ns.nspname='${ns}' and c.relname='[my name]__seq' LIMIT 1"
}

DB_Mapper=PostgreSQL instproc pdl.sequence.drop {ns} {
    return "DROP SEQUENCE [my pdl.sequence.qualifiedName ${ns}];"
}


# Auxilliary

DB_Mapper instproc attributemap_old {attribute} {

    return "[${attribute} dbname] [${attribute} datatype][aux::decode [${attribute} isNullable] yes {} no { NOT NULL}][aux::decode [${attribute} isUnique] no {} yes { UNIQUE}]"

}

DB_Mapper instproc attributemap {ns attribute} {

    return [${attribute} get_column_def ${ns}]

}


# Object

DB_Mapper instproc pdl.object.create {dbObject} {

    return "INSERT INTO [${dbObject} set __schema].[${dbObject} set __table] ([join [aux::mapobj dbname [my attributes]] ,]) VALUES ([join [aux::mapobj [list getValue ${dbObject}] [my attributes]] ,]);"

}

DB_Mapper instproc pdl.object.update {dbObject} {
    

    set setter [list]
    foreach a [my attributes] {
	if {[${dbObject} exists [$a name]]} then {
	    lappend setter [$a dbname]=[$a getValue ${dbObject}]
	}
    }

    return "update [${dbObject} set __schema].[${dbObject} set __table] set [join ${setter} ,] where [my key]=[[self]::attribute::[my key] getValue ${dbObject}];"

}

DB_Mapper instproc pdl.object.delete {dbObject} {
    


    return "delete from [${dbObject} set __schema].[${dbObject} set __table] where [my key]=[[self]::attribute::[my key] getValue ${dbObject}];"

}


DB_Mapper instproc pdl.object.deleteFromCriteria {dbObject criteria} {

    return "delete from [${dbObject} getFQN] where ${criteria};"

}
