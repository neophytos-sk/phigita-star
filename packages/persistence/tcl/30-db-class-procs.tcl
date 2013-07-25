###############################################################################

ns_cache_create xo_db_cache [expr {1024*1024}]

###############################################################################



namespace eval ::xo::db {;}

my::Class DB_Class -superclass "my::Class" -parameter {

    {name               "[string tolower [namespace tail [self]]]"}
    {shorthand          "[string tolower [namespace tail [self]]]"}
    {scope              ""}
    {key                ""}
    {prefix             "xo"}
    {volatile_p         "no"}
    {partitioner        "::xo::dht::RandomPartitioner"}
    {replication_factor "3"}
    {pk                 "id"}

    {dbname ""}
    {is_final_if_no_scope "0"}

}

#DB_Class instproc destroy {} {ns_log notice "Under Destruction (custom -- precedence=[my info precedence]-- volatile_p=[my set volatile_p]): [self]";next}

#DB_Class instproc 

DB_Class instproc init {} {

    my instvar type dbname prefix

    next

    foreach attribute [my attributes] {
        my lappend __param [${attribute} name]
    }

    my shorthand [string tolower [my shorthand]]

    my lappend __param {pathexp ""}

    my parameter [my set __param]

    my mixin add DB_Mapper=PostgreSQL
    my instmixin add ::db::Object

    if {![info exists type]} {
	set type [string tolower [namespace tail [my info class]]]
    }

    if { $dbname eq {} } {
	set dbname "${prefix}[string tolower [string map {{:} {_}} [self]]]"
    }


    #global __CLASS_COUNTER__
    #my set __RUNTIME_ID__ [incr __CLASS_COUNTER__]
    my set __RUNTIME_ID__ ""
    my set __ATTRIBUTES_SIG__ ""
    my set __ATTRIBUTES__ ""
    my set __INDEXES_SIG__ ""
    my set __INDEXES__ ""

}

DB_Class instproc each {procName} {
    $procName [self]
}

DB_Class instproc 0or1row {{-pathexp ""} {-where ""} {-id ""}} {
    if { $id ne {} } {
	lappend where id=[ns_dbquotevalue $id]
    }
    set data [::db::Set new -pathexp $pathexp -type [self] -where $where]
    $data load [self]
    if { [$data emptyset_p] } {
	return
    } else {
	set o [$data head]
	$o set pathexp $pathexp
	$o init
	return $o
    }
}

DB_Class instproc relname {} {
    return [my dbname]
    #my instvar prefix type
    #suffixes not supported
    #return  [string tolower [join "${prefix} [string map {{:} {_}} [self]]" ""]]
}

DB_Class instproc getTableList {{conn ""}} {
    if { $conn eq {} } {
	set conn [DB_Connection new -volatile -pool main]
    }
    set cl [self]
    set relname [$cl relname]
    set sql "select n.nspname || '.' || c.relname as name, n.nspname,c.relname from pg_class c inner join pg_namespace n on (c.relnamespace=n.oid) where relname=[ns_dbquotevalue $relname]"
    set tablelist [$conn query $sql]
}

DB_Class instproc allClassNames {} {
    return [concat [self] [aux::mapobj "set targetClass" [my aggregators]]]
}

DB_Class instproc getQueryClasses {} {
    return [self]
}

DB_Class instproc getQueryKeys {o} {
    ${o} instvar pathexp
    set result ""
    foreach cl [my getQueryClasses] {
	lappend result [$o info.db.pool].[pathexp_to_key ${pathexp} ${cl}]
    }
    return $result
}

DB_Class instproc getAggregatorKeys {o} {
    set result ""
    foreach aggClass [my aggregators] {
	set pathexp [$aggClass getPathExp ${o}]
	set cl [$aggClass set targetClass]
	lappend result [$o info.db.pool].[pathexp_to_key $pathexp ${cl}]
    }
    return $result
}

#getMutationTables
DB_Class instproc getAllTables {o} {
    return [lsort -unique [concat [my getQueryKeys ${o}] [my getAggregatorKeys ${o}]]]
}


DB_Class instproc predicate_to_sql {predicatelist} {
    set result [list]
    foreach predicate $predicatelist {
	lappend result [::xo::db::qualifier {*}${predicate}]
    }
    return ${result}
}

package require crc16
DB_Class instproc predicate_to_hash {predicatelist} {
    if { ${predicatelist} eq {}} { 
	return 
    } else {
	return [crc::crc16 -format %X ${predicatelist}]
    }
    ###

    set result [list]
    foreach predicate $predicatelist {
	lassign $predicate attname op value
	lappend result [[my attribute $attname] hash ${op} ${value}]
    }
    return ${result}
}


# always use after the "attribute" command because otherwise it would disable that command due to the created child namespace
DB_Class instproc mk_like {o} {

    #    ${o} variable XXX

    foreach attr_obj [${o} attributes] {
	set attr_conf [${attr_obj} get_conf]
	Container add [self]::attribute {*}$attr_conf
    }

    foreach index_obj [${o} indexes] {
	set index_conf [${index_obj} get_conf_for_copy]
	if {![string equal ${index_conf} {}]} {
	    Container add [self]::index {*}$index_conf
	}
    }

    foreach obs_obj [${o} observers] {
	set obs_conf [${trigger_obj} get_conf]
	Container add [self]::observer {*}$obs_conf
    }

}


DB_Class instproc mk_connector {args} {
    Container add [self]::connector {*}$args
}

DB_Class instproc mk_attribute {args} {
    Container add [self]::attribute {*}$args
}

DB_Class instproc mk_partition {args} {
    Container add [self]::partition {*}$args
}

DB_Class instproc mk_index {args} {
    Container add [self]::index {*}$args
}

DB_Class instproc mk_aggregator {args} {
    Container add [self]::aggregator {*}$args
}

DB_Class instproc connectors {} {
    Container list [self]::connector
}

DB_Class instproc attributes {} {
    Container list [self]::attribute
}

DB_Class instproc partitions {} {
    Container list [self]::partition
}

DB_Class instproc indexes {} {
    Container list [self]::index
}


DB_Class instproc aggregators {} {
    Container list [self]::aggregator
}


#####

DB_Class instproc mk_observer {args} {
    Container add [self]::observer {*}$args
}

DB_Class instproc observers {} {
    Container list [self]::observer
}
DB_Class instproc preObservers {proc_name} {
    Container list [self]::observer pre(${proc_name},*)
}
DB_Class instproc postObservers {proc_name} {
    Container list [self]::observer post(${proc_name},*)
}


DB_Class instproc db.do.one-insert {o} {
}
DB_Class instproc db.do.one-delete {o} {
}
DB_Class instproc db.do.one-update {o} {
}
DB_Class instproc db.do.one-select {o} {
}


#####

DB_Class instproc db.bulk-insert {} {
}
DB_Class instproc db.bulk-delete {} {
}
DB_Class instproc db.bulk-select {} {
}


DB_Class instproc attribute {catalog} {
    foreach attribute_spec $catalog {
	Container add [self]::attribute {*}$attribute_spec
    }
}



DB_Class instproc sequence {catalog} {
    foreach sequence_spec $catalog {
	Container add [self]::seq {*}$sequence_spec
    }
}

DB_Class instproc sequences {} {
    Container list [self]::seq
}


DB_Class instproc addIndex {subject args} {
    if {![my isobject [self]::index]} {
	Container create [self]::index
    }
    Index new -childof [self]::index -subject ${subject} {*}${args}
}

DB_Class instproc index {catalog} {
    foreach index_spec $catalog {
	my addIndex {*}${index_spec}
    }
}

DB_Class instproc addPartition {strategy subject args} {
    if {![my isobject [self]::partition]} {
	Container create [self]::partition
    }
    eval Partition=${strategy} new -childof [self]::partition -subject ${subject} ${args}
}

DB_Class instproc partition {catalog} {

    foreach partition_spec $catalog {
	my addPartition {*}${partition_spec}
    }
}


DB_Class instproc create_sequence_if {conn ns} {
    if {![${conn} exists [my pdl.schema.exists ${ns}]]} {
	catch { ${conn} do [my pdl.schema.create ${ns}] }
    }

    if {![${conn} exists [my pdl.sequence.exists ${ns}]]} {
	catch { ${conn} do [my pdl.sequence.create ${ns}] }
    }
}


DB_Class instproc create_table_if {conn ns table} {

    if {![${conn} exists [my pdl.schema.exists ${ns}]]} {
	catch { ${conn} do [my pdl.schema.create ${ns}] }
    }

    if {![${conn} exists [my pdl.table.exists ${ns} ${table}]]} {
	catch { ${conn} do [my pdl.table.create ${ns} ${table}] }
    }

}


DB_Class instproc autovalue {pathexp} {

    set ns [my dbNamespace ${pathexp}]

    set pool [my dbPool ${ns}]

    set conn [DB_Connection new -volatile -pool ${pool}]

    my create_sequence_if $conn $ns

    return [${conn} getvalue [my pdl.sequence.nextvalue ${ns}]]
}

DB_Class instproc insert {dbObject} {

    set ns [my dbNamespace [${dbObject} pathexp]]
    set pool [my dbPool ${ns}]
    set table [my dbTable ${dbObject}]
    set conn [DB_Connection new -volatile -pool ${pool}]

    my create_table_if $conn $ns $table

    ${conn} do [my pdl.object.create ${dbObject}]

}

DB_Class instproc update {dbObject} {

    set ns [my dbNamespace [${dbObject} pathexp]]
    set pool [my dbPool ${ns}]
    set table [my dbTable ${dbObject}]
    set conn [DB_Connection new -volatile -pool ${pool}]


    ${conn} do [my pdl.object.update ${dbObject}]
    
}


DB_Class instproc delete {dbObject} {

    set ns [my dbNamespace [${dbObject} pathexp]]
    set pool [my dbPool ${ns}]
    set table [my dbTable ${dbObject}]
    set conn [DB_Connection new -volatile -pool ${pool}]

    ${conn} do [my pdl.object.delete ${dbObject}]
    
}

DB_Class instproc deleteFromCriteria {dbObject criteria} {

    set ns [my dbNamespace [${dbObject} set pathexp]]
    set pool [my dbPool ${ns}]
    set table [my dbTable ${dbObject}]
    set conn [DB_Connection new -volatile -pool ${pool}]

    ${conn} do [my pdl.object.deleteFromCriteria ${dbObject} ${criteria}]
    
}


DB_Class instproc retrieve {args} {

    ad_arg_parser {pathexp output criteria group order limit offset joinpath} ${args}

    set ns [my dbNamespace ${pathexp}]
    set pool [my dbPool ${ns}]
    set table [my dbTable]
    


    set conn [DB_Connection new -volatile -pool ${pool}]

    if {![${conn} exists [my pdl.schema.exists ${ns}]]} {
	return ""
    }


    if {![${conn} exists [my pdl.table.exists ${ns} ${table}]]} {
	return ""
    }

    set sql "SELECT ${output}"
    lappend sql "FROM ${ns}.${table}"
    if {[info exists joinpath]} {
	lappend sql JT0
	set joinlist [list]
	set counter 0
	foreach jp ${joinpath} {
	    incr counter

	    lassign ${jp} jp_type jp_class_pathexp jp_condition_lhs jp_condition_rhs
	    lassign ${jp_class_pathexp} jp_class jp_pathexp

	    set jp_namespace [${jp_class} dbNamespace ${jp_pathexp}]
	    set jp_table [${jp_class} dbTable]

	    if {![${conn} exists [my pdl.schema.exists ${jp_namespace}]]} {
		return ""
	    }

	    if {![${conn} exists [my pdl.table.exists ${jp_namespace} ${jp_table}]]} {
		return ""
	    }

	    lappend joinlist "${jp_type} JOIN ${jp_namespace}.${jp_table} JT${counter} ON JT${counter}.${jp_condition_lhs} = JT[expr ${counter}-1].${jp_condition_rhs}"
	}
	lappend sql [join ${joinlist} ,]
    }
    if {[info exists criteria]} {
	lappend sql "WHERE ${criteria}"
    }
    if {[info exists group]} {
	lappend sql "GROUP BY ${group}"
    }
    if {[info exists order]} {
	lappend sql "ORDER BY ${order}"
    }
    if {[info exists limit]} {
	lappend sql "LIMIT ${limit}"
    }
    if {[info exists offset]} {
	lappend sql "OFFSET ${offset}"
    }



    return [${conn} query [join ${sql} "\n"]]
}

DB_Class instproc select {pathexp {output "*"} {dbObject ""}} {

    set ns [my dbNamespace ${pathexp}]
    set pool [my dbPool ${ns}]
    set table [my dbTable ${dbObject}]

    set conn [DB_Connection new -volatile -pool ${pool}]

    if {![${conn} exists [my pdl.schema.exists ${ns}]]} {
	return ""
    }

    if {![${conn} exists [my pdl.table.exists ${ns} ${table}]]} {
	return ""
    }

    return [${conn} query "SELECT ${output} FROM ${ns}.${table};"]
}



DB_Class instproc asNULL {} {
    set attr_list [list]
    foreach attr [my attributes] {
	lappend attr_list [${attr} asNULL]
    }
    return "select [join ${attr_list} ,]"
}


my::Class DB_Object

DB_Object instproc init {} {

    my set __pool [[my info class] getDBPool [self]]
    my set __schema [[my info class] getDBSchema [self]]
    my set __table [[my info class] getDBTable [self]]
    my set __class [[my info class] name]

}

DB_Object instproc Save {args} {
    [my info class] insert [self] 
    if {![string equal ${args} {}]} {
	uplevel "eval ${args}"
    }
}

DB_Object instproc Update {} {
    [my info class] update [self]
}

DB_Object instproc Delete {} {
    [my info class] delete [self]
}


DB_Object instproc asList {} {

    set result [list]
    foreach varname [my info vars] {
	lappend result [list ${varname} [my set ${varname}]]
    }
    return ${result}
}



namespace eval db {;}
namespace eval pattern {;}
namespace eval pattern::observer {;}

Class pattern::observer::Trigger  -instproc fire {args} {
    my instvar script
    if {[info exists script]} {
	eval [subst {${script}}]
    }
}

Class pattern::observer::Observer
Class pattern::observer::Subject

pattern::observer::Subject instproc notificationFilter {args} {

    set procName [self calledproc]

    my instvar type
    ${type} variable [list postObservers(${procName}) postObs]

    set result [next]

    if {[info exists postObs]} {
	foreach obj ${postObs} {
	    ${obj} fire [self] {*}${args}
	}
    }

    return ${result}
}

#pattern::observer::Subject instfilter notificationFilter




## cf = column family
proc pathexp_to_key {pathexp cf {prefix "xo"} {suffix ""}} {
    set result ""
    foreach item ${pathexp} {
	if {[llength ${item}]==1} {
	    # item is the name of a foreign key attribute
	    set class [[${cf} attribute ${item}] set ref]
	    set value [my set ${item}]
	} else {
	    lassign ${item} class value
	}
	lappend result [${class} shorthand]${value}
    }
    return [string tolower [join "${prefix} ${result}" "__"]].[string tolower [join "${prefix} [string map {{:} {_}} ${cf}] ${suffix}" ""]]
}



###############################################################################

my::Class db::Map -parameter {{pathexp ""} {pool "main"} {prefix "xo"}}

#db::Map instproc init {} {
#    my instvar prefix
#    set prefix xo
#    next
#}
db::Map instproc info.db.pool {} {
    my instvar pathexp pool
    if { [info exists pool] } {
	return ${pool}
    } else {
	return main
    }
}
db::Map instproc info.db.schema {} {
    my instvar pathexp type prefix
    set result ""
    foreach item ${pathexp} {
	if {[llength ${item}]==1} {
	    # item is the name of a foreign key attribute
	    set class [[${type} attribute ${item}] set ref]
	    set value [my set ${item}]
	} else {
	    lassign ${item} class value
	}
	lappend result [${class} shorthand]${value}
    }
    return [string tolower [join "${prefix} ${result}" "__"]]

}
db::Map instproc info.db.sequence_name {} {
    my instvar prefix type
    return [string tolower "[string map {{:} {_}} [string trimleft ${type} {:}]]__seq"]
}
db::Map instproc info.db.sequence {} {
    return [my info.db.schema].[my info.db.sequence_name]
}
# requires: ((my type))
db::Map instproc get_table_suffix {} {
    set suffix [next]
    my instvar type
    foreach partition [${type} partitions] {
        lappend suffix [${partition} suffix [self]]
    }
    return $suffix
}


db::Map instproc info.db.tablename {} {
    my instvar type 
    set suffix [my get_table_suffix]
    set dbname [$type dbname]
    return  ${dbname}${suffix}
}
db::Map instproc info.db.tablespace {} {
    return "pg_default"
}
db::Map instproc info.db.indexspace {} {
    return "pg_default"
}
#Fully Qualified Name
db::Map instproc info.db.table {} {
    return [my info.db.schema].[my info.db.tablename]
}


db::Map instproc info.db.emptytable {} {
    my instvar type
    set attr_list [list]
    foreach attr [${type} attributes] {
	lappend attr_list [${attr} asNULL]
    }
    return "(select [join ${attr_list} ,] where false) as \"empty__[my alias]\""
}


db::Map instproc getConn {} {
    my instvar conn
    if {![info exists conn]} {
	set pool [my info.db.pool]
	set conn [DB_Connection new -pool ${pool}]
    }
    return ${conn}
}

db::Map instproc info.db.table_exists_p {} {

    set pool [my info.db.pool]
    set schema [my info.db.schema]
    set tablename [my info.db.tablename]
    set tablekey ${pool}.${schema}.${tablename}
    return [check_if_table_exists_p [my getConn] ${tablekey}]
}

proc check_if_table_exists_p {conn tablekey} {
    return [::xo::db::get_table_version ${tablekey}]
}

proc filter_out_tables_that_do_not_exist {conn tablekeys} {
    set result [list]
    foreach tablekey $tablekeys {
	if { [check_if_table_exists_p $conn $tablekey] } {
	    lappend result $tablekey
	}
    }
    return $result
}


### It should have been called db::Broker or something similar.

my::Class db::Object -parameter {
    {pathexp ""}
    {volatile_p "yes"}
    type
} -instmixin db::Map


db::Object instproc init {} {
    my instvar type
    if {![info exists type]} {
	set type [my info class]
    }
    next
}

db::Object instproc destroy {} {
    if { [catch {
	my instvar conn
	if {[info exists conn]} {
	    if {[Object isobject ${conn}]} {
		${conn} destroy
	    }
	}
	next
    } errmsg] } {
	ns_log error ${errmsg}
    }
}


::db::Object instproc getRowKey {} {
    my instvar pathexp
    if { $pathexp eq {} } {
	return {XO:XO}
    } else { 
	return [join [::xo::fun::map x $pathexp {join $x {:}}] {.}]
    }
}

::db::Object instproc getColumnFamily {} {
    #my instvar {name className}
    #return $className

    return [my info class]
}

::db::Object instproc getColumnPath {} {
    
    if { [my exists id] } {
	set columnName [my set id]
    } else {
	set columnName [my getTimestamp]
    }
    [my info class] instvar {name className}
    return ${className}:${columnName}
}
::db::Object instproc getTimestamp {} {
    return [clock milliseconds]
}


db::Object instproc beginTransaction {} {
    set conn [my getConn]
    ${conn} beginTransaction
}

db::Object instproc endTransaction {} {
    set conn [my getConn]
    ${conn} endTransaction
}

db::Object instproc abortTransaction {} {
    set conn [my getConn]
    ${conn} abortTransaction
}

db::Object instproc do {cmd args} {
    my beginTransaction
    if { [catch {
	[self] rdb.${cmd} {*}${args}
    } errmsg] } {
	my abortTransaction
	global errorInfo
	error ${errmsg} ${errorInfo}
    }
    my endTransaction
}


db::Object instproc info.db.schema_ddl {} {
    my instvar type
    set schema [my info.db.schema]
    return "\n\tCREATE SCHEMA ${schema};\n"
}
db::Object instproc info.db.table_ddl {} {
    my instvar type
    set schema [my info.db.schema]
    set table [my info.db.table]
    set tablespace [my info.db.tablespace]
    set attr_defs [join [aux::mapobj [list get_column_def ${schema}] [${type} attributes]] "\n\t\t,"]
    return "\n\tCREATE TABLE ${table} (\n\t\t${attr_defs}\n\t) WITHOUT OIDS TABLESPACE ${tablespace};\n"
}
db::Object instproc info.db.index_ddl {} {
    my instvar type
    set schema [my info.db.schema]
    set tablename [my info.db.tablename]
    set indexspace [my info.db.indexspace]
    return "\n\t[join [aux::mapobj [list get_db_def ${schema} ${tablename} ${indexspace}] [${type} indexes]] "\n\t"]"
}

db::Object instproc rdb.ensure-table {} {

    if { ![my info.db.table_exists_p] } {

	set conn [my getConn]

	set pool [my info.db.pool]
	set schema [my info.db.schema]
	set tablename [my info.db.tablename]

	set table_ddl [my info.db.table_ddl]
	set index_ddl [my info.db.index_ddl]

	set sql "select xo__ensure_schema([ns_dbquotevalue ${schema}]) & xo__ensure_class([ns_dbquotevalue "${table_ddl} ${index_ddl}"]);"
	#ns_log notice "ensure-table: sql=$sql"
	${conn} pl ${sql}

	### ns_cache_incr -- xo_db_cache TABLE:
	set tablekey ${pool}.${schema}.${tablename}

	::xo::db::touch ${tablekey}

	bg_sendOneWay "touch ${tablekey}"
	#bg_sendOneWay "touch [[my info class] getAllTables [self]]"

    }

}

DB_Class instproc getDBSlots {{-max_priority "0"}} {
    set attributes [list]
    foreach att [my attributes] {
	if { [${att} set priority] <= ${max_priority} } {
	    lappend attributes $att
	}
    }
    return [concat $attributes [my connectors]]
}

db::Object instproc toDict {{noempty_p "1"} args} {
    my instvar type
    set mydict [dict create]
    foreach dbslot [$type getDBSlots] {
	set value [$dbslot get_raw_value [self]]
	if { $value eq {} && $noempty_p } continue
	#lappend kvl [list [$att dbname] $value]
	dict set mydict [$dbslot dbname] $value 
    }
    foreach {key value} $args {
	dict set mydict $key $value
    }
    return $mydict
}

db::Object instproc toRecord {} {
    return [dict values [my toDict 0]]
}

db::Object instproc rdb.self-insert {{jic_sql ""}} {

    my instvar type

    set keys ""
    set values ""
    foreach att [$type attributes] {
	lappend keys  [$att dbname]
	lappend values [$att getValue [self]]
    }
    set columns [join ${keys} {,}]
    set expressions [join ${values} {,}]
    set table_name [my info.db.table]


    my rdb.ensure-table
    set conn [my getConn]

    if { ${jic_sql} eq {} } {
	${conn} do "insert into ${table_name} ( ${columns} ) values ( ${expressions} );"
    } else {
	${conn} pl "select xo__insert_dml(\n\t[::util::dbquotevalue "insert into ${table_name} ( ${columns} ) values ( ${expressions} );"],\n\t[ns_dbquotevalue ${jic_sql}]);"
    }
    
    #foreach tablekey in [my allKeys] = getMutationKeys + getQueryKeys

    ::xo::db::touch [my info.db.pool].${table_name}

    #touch ${table_name}
    ### HERE check that the tables exist

    my touch_affected_tables

    foreach o [${type} aggregators] {
	#ns_log notice aggregator=${o}
	${o} onInsertSync [self]
    }


    next

}

db::Object instproc touch_affected_tables {} {
    set conn [my getConn]
    set all_tablekeys [[my info class] getAllTables [self]]
    set tablekeys_that_exist [filter_out_tables_that_do_not_exist $conn $all_tablekeys]
    bg_sendOneWay "touch $tablekeys_that_exist"
}

db::Object instproc OLD.rdb.self-insert {{jic_sql ""}} {

    my instvar conn type
    if {![info exists conn]} {
	set pool [my info.db.pool]
	set conn [DB_Connection new -pool ${pool}]
    }

    set schema [my info.db.schema]
    set table_ddl [my info.db.table_ddl]
    set index_ddl [my info.db.index_ddl]

    #set attributes [aux::mapobj dbname [${type} attributes]]
    #set values [aux::mapobj [list getValue [self]] [${type} attributes]]

    set keys ""
    set values ""
    foreach att [$type attributes] {
	lappend keys  [$att dbname]
	lappend values [$att getValue [self]]
    }
    set columns [join ${keys} {,}]
    set expressions [join ${values} {,}]
    set table_name [my info.db.table]

    set sql [subst {
	select xo__ensure_schema([ns_dbquotevalue ${schema}]) & xo__ensure_class([ns_dbquotevalue "${table_ddl} ${index_ddl}"]) & xo__insert_dml(
																		 [::util::dbquotevalue [subst {
																		     insert into ${table_name} ( ${columns} ) values ( ${expressions} );
																		 }]],
																		 [ns_dbquotevalue ${jic_sql}]
																		 );
    }]

    #ns_log notice sql=${sql}
    ${conn} pl ${sql}

    foreach o [${type} aggregators] {
	#ns_log notice aggregator=${o}
	${o} onInsertSync [self]
    }


    next

}

db::Object instproc rdb.self-delete {{-pk id} {where_clause ""}} {

    my instvar type $pk
    
    foreach o [${type} aggregators] {
	#ns_log notice "onDeleteSync:${o}"
	${o} onDeleteSync [self]
    }
    
    if { [my info.db.table_exists_p] } {	
	if { ${where_clause} eq {} } {
	    set where_clause "$pk=[my set $pk]"
	}
	set table_name [my info.db.table]
	[my getConn] do "DELETE FROM ${table_name} WHERE ${where_clause}"
	my touch_affected_tables ;# bg_sendOneWay "touch [[my info class] getAllTables [self]]"

	::xo::db::touch [my info.db.pool].${table_name}

    }

    next

}

db::Object instproc rdb.self-id {} {
    my instvar conn type id
    if {![info exists conn]} {
	set pool [my info.db.pool]
	set conn [DB_Connection new -pool ${pool}]
    }
    set sql [subst {
	select xo__nextval([ns_dbquotevalue [my info.db.schema]],[ns_dbquotevalue [my info.db.sequence]])
    }]
    #ns_log notice sql=${sql}
    set id [${conn} getvalue ${sql}]
}

db::Object instproc rdb.self-load {{-pk "id"} {-select "*"}} {
    my instvar conn type $pk
    if {![info exists conn]} {
	set pool [my info.db.pool]
	set conn [DB_Connection new -pool ${pool}]
    }
    set sql [subst {
	SELECT ${select} FROM [my info.db.table]
	WHERE ${pk}=[ns_dbquotevalue [set ${pk}]]
    }]

    #ns_log notice sql=${sql}
    ${conn} 1row ${sql} [self]


}

db::Object instproc rdb.bulk-update {{-pk "id"} {where_clause ""}} {
    
    my instvar "${pk} bucket"
    foreach id $bucket {
	my set ${pk} $id
	my rdb.self-update -pk ${pk} $where_clause
    }
    my set id $bucket
}

db::Object instproc rdb.bulk-delete {{-pk "id"} {where_clause ""}} {
    
    my instvar "${pk} bucket"
    foreach id $bucket {
	my set ${pk} $id
	my rdb.self-delete -pk ${pk} $where_clause
    }

}

db::Object instproc rdb.self-update {{-pk "id"} {where_clause ""}} {

    my instvar conn type ${pk}

    foreach o [${type} aggregators] {
	${o} onUpdateSyncBefore [self]
    }

    if { [my info.db.table_exists_p] } {	
	set conn [my getConn]
	if {[string equal ${where_clause} {}]} {
	    set where_clause "${pk}=[::util::dbquotevalue [my set ${pk}]]"
	}

	set o [self]
	set setter [list]
	foreach a [${type} attributes] {
	    if {[${o} exists __update([$a name])]} {
		lappend setter [$a dbname]=[$o set __update([$a name])]
	    } elseif {[${o} exists [$a name]]} {
		lappend setter [$a dbname]=[$a getValue ${o}]
	    }
	}
	set setter [join ${setter} {,}]

	set table_name [my info.db.table]
	ns_log notice "self-update setter: $setter"
	${conn} do "UPDATE ${table_name} SET ${setter} WHERE ${where_clause}"


	::xo::db::touch	[my info.db.pool].${table_name}

    }

    my touch_affected_tables  ;# bg_sendOneWay "touch [[my info class] getAllTables [self]]"

    foreach o [${type} aggregators] {
	#ns_log notice "self-update,aggregator=${o},onUpdateSyncAfter"
	${o} onUpdateSyncAfter [self]
    }

}

::db::Object instproc quoted {__NAME__} {
    my instvar ${__NAME__}
    if {[info exists ${__NAME__}]} {
	return [::util::dbquotevalue [set ${__NAME__}]]
    } else {
        return null
    }
}






my::Class db::View -parameter {
    {pathexp ""}
    type
    {cache ""}
    {alias "[self]"}
    {select "*"}
    {result ""}
    {distinct "no"}
    {restrictClause ""}
    viewFields
    from
    {where ""}
    {where_if ""}
    {group ""}
    order
    {limit ""}
    {offset ""}
    {extend ""}
    {scope ""}
} -instmixin db::Map


db::View instproc each {procName} {
    my instvar type
    if {[exists_and_not_null type]} {
	$procName $type
    }
}

db::View instproc connectors {} {
    if { ![my exists type] } return
    my instvar type
    return [$type connectors]
}

db::View instproc getQueryClasses {} {
    if { ![my exists type] } return
    my instvar type
    return [${type} getQueryClasses]
}

db::View instproc getQueryKeys {o} {
    #we deliberately ignore object 'o' - most likely a join or a union object
    my instvar type
    if { [info exists type] } {
	return [${type} getQueryKeys [self]]
    } else {
	return ;# from
    }
}

db::View instproc init_sql {} {

    my instvar sql
    set sql [my info.db.xql [self]]

}


proc ::db::pathexp_script_from_scope {o} {
    set scope [$o set scope]
    if { $scope eq {user} } {
	set pathexp [list [list User "\[ad_conn user_id\]"]]
    } elseif { $scope eq {context_user} } {
	set pathexp [list [list User "\[ad_conn ctx_uid\]"]]
    } elseif { $scope eq {subsite} } {
	# TODO: get the actual subsite_id, e.g. from ad_conn
	set pathexp [list [list Subsite "\[ad_conn subsite_id\]"]]
    } else {
	set pathexp ""
    }
    return $pathexp
}


proc ::db::get_sql_schema {class pathexp} {

    set prefix [${class} prefix]

    set result ""
    foreach item $pathexp {
	lassign $item targetClass value_script
	lappend result [$targetClass shorthand]${value_script}
    }
    return [join "${prefix} ${result}" "__"]
}

proc ::db::get_sql_tablename {class} {
    return [$class dbname]
}

proc ::db::get_sql_emptytable {classname} {

    set attributes [${classname} attributes]

    set attr_list [list]
    foreach attr ${attributes} {
	lappend attr_list [${attr} asNULL]
    }
    return "(select [join ${attr_list} ,] where false) as \"empty__${classname}\""
}


proc ::db::get_sql_table {pool class table} {

    #set version [::xo::db::get_table_version ${pool}.${table} ${conn}]
    set version [::xo::db::get_table_version ${pool}.${table}]

    upvar __vc vc
    lappend vc $version

    if { ${version} } {
	return $table
    } else {
	return [::db::get_sql_emptytable $class]
    }
}

proc ::db::get_sql_where_if {qualifier_expr criteria} {
    if ${qualifier_expr} {
	return [subst -nobackslashes ${criteria}]
    }
    return true
}

db::View instproc get_sql_script {} {
    my instvar cache scope
    return [my info.db.sql_script [self] ${scope} ${cache}]
}

db::View instproc get_sql_attributes {} {

    return [my info.db.sql_attributes]

}

DB_Class instproc info.db.sql_script {o scope cache} {

    # pathexp_script will be substituted on runtime,
    # and thus will become pathexp
    set pool [::util::coalesce [$o pool] "main"]
    set class [self]
    set pathexp_script [db::pathexp_script_from_scope $o]
    set schema [::db::get_sql_schema $class $pathexp_script]
    set tablename [::db::get_sql_tablename $class]
    set table ${schema}.${tablename}

    my instvar is_final_if_no_scope

    # we cannot finalize the table if we use the cache 
    # because it makes use of the vector clock that
    # is set by get_sql_table
    #
    # we cannot finalize the table when we use scope because
    # scoped tables are created dynamically, e.g. it might
    # exist for one user and not exist for another
    #
    if { $is_final_if_no_scope && $scope eq {} && ${cache} eq {} } {
	return $table
    } else {
	return [subst -nocommands -nobackslashes {[::db::get_sql_table $pool $class $table]}]
    }

}

DB_Class instproc info.db.sql_attributes {} {
    set attributes [my attributes]
    set sql_attrs [list]
    foreach att ${attributes} {
	lappend sql_attrs [${att} dbname]
    }
    return ${sql_attrs}
}

DB_Class instproc info.db.xql {o} {

    if { [$o info.db.table_exists_p]  } {
	append xql " [$o info.db.table]"
    } {
	append xql " [$o info.db.emptytable]"
    }
    return $xql
}

db::View instproc getSQLCriteria {} {
    my instvar where where_if
    set result ""
    if { ${where} ne {} } {
	set result $where
    }

    if { $where_if ne {} } {
	foreach {qualifier_expr _dummy_arrow_ criteria} $where_if {
	    if { $_dummy_arrow_ ne {=>} } {
		error "malformed where_if clause, should be 'qualifer => criteria'"
	    }
	    lappend result "\[::db::get_sql_where_if [list ${qualifier_expr}] [list ${criteria}]\]"
	}
    }

    return $result

    #foreach expression $restrictClause {
    #	lappend result [::xo::db::qualifier {*}$expression]
    #}

}




db::View instproc getSQLOrder {} {
    my instvar order
    if { [info exists order] } {
	return $order
    } else {
	return
    }
}


db::View instproc info.db.xql-count {o} {
    my instvar type from alias select group order limit offset viewFields
    set xql "select count(1) from"

    if { [info exists type] } {
	append xql " [${type} info.db.xql [self]]"
    } else {
	append xql " ${from}"
    }

    set where_criteria [my getSQLCriteria]
    if { $where_criteria ne {} } {
	append xql " where [join $where_criteria { and }]"
    }

    if { ${group} ne {} } {
	append xql " group by ${group}"
    }

    if { ${o} eq [self] } {
	return ${xql}
    } else {
	return "(${xql}) as \"${alias}\""
    }

}

db::View instproc info.db.sql_script {{-no_alias_p false} o scope cache} {

    my instvar type from alias select group order limit offset viewFields distinct

    if { [info exists viewFields] } {
	foreach field $viewFields {
	    #lappend select "([${field} info.db.xql ${field}]) as \"[$field alias]\""
	    lappend select [$field info.db.xql [self]]
	}
    }
    set xql "select"
    if { ${distinct} } {
	append xql " distinct"
    }
    append xql " [join ${select} {,}] from"

    if { [info exists type] } {
	append xql " [${type} info.db.sql_script [self] ${scope} ${cache}]"
    } else {
	append xql " ${from}"
    }
    
    set where_criteria [my getSQLCriteria]
    if { $where_criteria ne {} } {
	append xql " where [join $where_criteria { and }]"
    }

    if { ${group} ne {} } {
	append xql " group by ${group}"
    }

    set order_by [my getSQLOrder]
    if { $order_by ne {} } {
	append xql " order by ${order_by}"
    }
    if { $limit ne {} } {
	append xql " limit ${limit}"
    }
    if { $offset ne {} } {
	append xql " offset ${offset}"
    }
    
    if { ${o} eq [self] || $no_alias_p } {
	return ${xql}
    } else {
	return "(${xql}) as \"${alias}\""
    }

}


db::View instproc info.db.sql_attributes {} {

    my instvar select type from

    # we have to get the attributes from all tables
    set sql_attrs [list]
    foreach select_expr ${select} {
	if { -1 != [string first {*} ${select_expr}] } {
	    # we need to get the attributes from type
	    if { [info exists type] } {
		set type_attrs [$type info.db.sql_attributes]
	    } else {
		# get table attributes from the db but better not use from
		set type_attrs ""
	    }
	    set sql_attrs [concat ${sql_attrs} ${type_attrs}]
			   
	} else {
	    lappend sql_attrs [lindex [lreverse [split [lindex ${select_expr} end] {.}]] 0]
	}
    }
    return ${sql_attrs}

}


db::View instproc info.db.xql {{-no_alias_p false} o} {

    my instvar type from alias select group order limit offset viewFields distinct

    if { [info exists viewFields] } {
	foreach field $viewFields {
	    lappend select [$field info.db.xql [self]]
	}
    }
    set xql "select"
    if { ${distinct} } {
	append xql " distinct"
    }
    append xql " [join ${select} {,}] from"

    if { [info exists type] } {
	append xql " [${type} info.db.xql [self]]"
    } else {
	append xql " ${from}"
    }
    
    set where_criteria [my getSQLCriteria]
    if { $where_criteria ne {} } {
	append xql " where [join $where_criteria { and }]"
    }

    if { ${group} ne {} } {
	append xql " group by ${group}"
    }

    set order_by [my getSQLOrder]
    if { $order_by ne {} } {
	append xql " order by ${order_by}"
    }
    if { $limit ne {} } {
	append xql " limit ${limit}"
    }
    if { $offset ne {} } {
	append xql " offset ${offset}"
    }
    
    if { ${o} eq [self] || $no_alias_p } {
	return ${xql}
    } else {
	return "(${xql}) as \"${alias}\""
    }

}



my::Class db::Join -superclass db::View -parameter {
    lhs
    rhs
    {join_condition true}
}

db::Join instproc each {procName} {
    my instvar type lhs rhs

    if { [info exists lhs] } {
	$lhs each $procName
    }
    if { [info exists rhs] } {
	$rhs each $procName
    }
}

db::Join instproc getQueryClasses {} {
    my instvar lhs rhs
    return [concat [$lhs getQueryClasses] [$rhs getQueryClasses]]
}

db::Join instproc getQueryKeys {o} {
    my instvar lhs rhs
    return [concat [$lhs getQueryKeys [self]] [$rhs getQueryKeys [self]]]
}


db::Join instproc info.db.sql_script {o scope cache} {

    my instvar lhs rhs alias

    set lhs_xql [${lhs} info.db.sql_script [self] ${scope} ${cache}]
    set rhs_xql [${rhs} info.db.sql_script [self] ${scope} ${cache}]
    return "${lhs_xql} [my info.db.join_type]  ${rhs_xql} on ([my join_condition])"

}

db::Join instproc info.db.sql_attributes {} {

    my instvar lhs rhs alias
    set lhs_attrs [${lhs} info.db.sql_attributes]
    set rhs_attrs [${rhs} info.db.sql_attributes]
    return [concat $lhs_attrs $rhs_attrs]

}


db::Join instproc info.db.xql {o} {

    my instvar lhs rhs alias

    set lhs_xql [${lhs} info.db.xql [self]]
    set rhs_xql [${rhs} info.db.xql [self]]
    return "${lhs_xql} [my info.db.join_type]  ${rhs_xql} on ([my join_condition])"

}

my::Class db::Inner_Join -superclass db::Join

db::Inner_Join instproc info.db.join_type {} {
    return "INNER JOIN"
}


my::Class db::Left_Outer_Join -superclass db::Join

db::Left_Outer_Join instproc info.db.join_type {} {
    return "LEFT OUTER JOIN"
}


my::Class db::Right_Outer_Join -superclass db::Join

db::Right_Outer_Join instproc info.db.join_type {} {
    return "RIGHT OUTER JOIN"
}



my::Class ::db::Union -superclass db::View -parameter {
    lhs
    rhs
}

::db::Union instproc getQueryClasses {} {
    my instvar lhs rhs
    return [concat [$lhs getQueryClasses] [$rhs getQueryClasses]]
}


::db::Union instproc getQueryKeys {o} {
    my instvar lhs rhs
    return [concat [$lhs getQueryKeys [self]] [$rhs getQueryKeys [self]]]
}

::db::Union instproc info.db.sql_script {o scope cache} {

    my instvar lhs rhs alias

    set lhs_xql [${lhs} info.db.sql_script -no_alias_p true [self] ${scope} ${cache}]
    set rhs_xql [${rhs} info.db.sql_script -no_alias_p true [self] ${scope} ${cache}]
    return "((${lhs_xql}) UNION (${rhs_xql})) as \"$alias\""

}


db::Union instproc info.db.sql_attributes {} {

    # we need only take lhs_attrs (rhs_attrs must match them)

    my instvar lhs
    set lhs_attrs [${lhs} info.db.sql_attributes]
    return $lhs_attrs

}


::db::Union instproc info.db.xql {o} {

    my instvar lhs rhs alias

    set lhs_xql [${lhs} info.db.xql -no_alias_p true [self]]
    set rhs_xql [${rhs} info.db.xql -no_alias_p true [self]]
    return "((${lhs_xql}) UNION (${rhs_xql})) as \"$alias\""

}

my::Class ::db::Union_All -superclass db::View -parameter {
    lhs
    rhs
}

::db::Union_All instproc getQueryClasses {} {
    my instvar lhs rhs
    return [concat [$lhs getQueryClasses] [$rhs getQueryClasses]]
}

::db::Union_All instproc getQueryKeys {o} {
    my instvar lhs rhs
    return [concat [$lhs getQueryKeys [self]] [$rhs getQueryKeys [self]]]
}


::db::Union_All instproc info.db.sql_script {o scope cache} {

    my instvar lhs rhs alias

    set lhs_xql [${lhs} info.db.sql_script -no_alias_p true [self] ${scope} ${cache}]
    set rhs_xql [${rhs} info.db.sql_script -no_alias_p true [self] ${scope} ${cache}]
    return "((${lhs_xql}) UNION ALL  (${rhs_xql})) as \"$alias\""

}


db::Union_All instproc info.db.sql_attributes {} {

    # we need only take lhs_attrs (rhs_attrs must match them)

    my instvar lhs
    set lhs_attrs [${lhs} info.db.sql_attributes]
    return $lhs_attrs

}



::db::Union_All instproc info.db.xql {o} {

    my instvar lhs rhs alias

    set lhs_xql [${lhs} info.db.xql -no_alias_p true [self]]
    set rhs_xql [${rhs} info.db.xql -no_alias_p true [self]]
    return "((${lhs_xql}) UNION ALL  (${rhs_xql})) as \"$alias\""

}




my::Class db::Set -superclass "db::View"

db::Set instproc each {procName} {

    # call the proc and pass the object as argument
    $procName [self]

    my instvar type from
    if { [exists_and_not_null type] } {
	$type each $procName
    } else {
	if { [exists_and_not_null from] } {
	    error "cannot execute procName=$procName on sets that use 'from' as opposed to 'type' as its underlying table"
	} else {
	    # do nothing
	}
    }
}

db::Set instproc debug {} {
    my instvar sql
    ns_log notice "SQL=$sql"
}

db::Set instproc getHeader {} {
    my instvar {type cf}
    return [::xo::fun::map x [$cf getDBSlots] {$x dbname}]

}
db::Set instproc fromRecordSet {rs} {
    my instvar {type cf} result
    set result [rows_to_objs $rs $cf]
}

db::Set instproc toRecordSet {} {
    return [dict create names [my getHeader] rows [my toRecordList]]
}

db::Set instproc toDict {} {
    set mydict ""
    foreach o [my set result] {
	dict set mydict [incr counter] [$o toDict]
    }
    return $mydict
}

db::Set instproc toRecordList {} {
    return [::xo::fun::map x [my set result] {$x toRecord}]
}

db::Set instproc getQueryClasses {} {
    if { ![my exists type] } return
    my instvar type
    return [${type} getQueryClasses]
}

db::Set instproc emptyset_p {} {
    my instvar result
    return [string equal ${result} [list]]
}

db::Set instproc head {} {
    my instvar result
    return [lindex ${result} 0]
}


db::Set instproc tail {} {
    my instvar result
    return [lrange ${result} 1 end]
}

db::Set instproc getIndexMapBy {varName} {
    return [join [::xo::fun::map x [my set result] {list [$x set $varName] $x}]]
}

db::Set instproc loadRows {} {
    my instvar conn sql  ;# header
    my init_sql

    # Execute SQL query
    set result ""
    if { [catch {
	set conn [my getConn]
	set result [${conn} queryDict ${sql}]
    } errmsg] } {
	ns_log error "Failed to load data errmsg=errmsg sql=${sql}"
    }

    set vector_clock [my getVectorClock]
    dict set result vector_clock $vector_clock
    ###set header [dict get $result names]

    ##ns_log notice "getQueryKeys=[my getQueryKeys [self]] vector_clock=${vector_clock}\n\t\tsql=${sql}\n\n"
    #ns_log notice "getQueryKeys=[my getQueryKeys [self]] vector_clock=${vector_clock}"


    return $result
}




::db::Set instproc __compare {by a b} {
    set x [$a set $by]
    set y [$b set $by]
    if {$x < $y} {
	return -1
    } elseif {$x > $y} {
	return 1
    } else {
	return 0
    }
}

::db::Set instproc sort {sortField {direction "increasing"}} {
    my instvar result order
    set result [lsort -command [list my __compare $sortField] -$direction $result]
    return $result
}



::db::Set instproc getTableVersion {tablekey} {
    return [::xo::db::get_table_version ${tablekey}]
}

::db::Set instproc getVectorClock {{queryTables ""}} {
    if { ${queryTables} eq {} } {
	set queryTables [my getQueryKeys [self]]
    }
    set vector_clock ""
    foreach tablekey [lsort -unique ${queryTables}] {
	lappend vector_clock [my getTableVersion $tablekey]
    }
    return ${vector_clock}
}



# vector clocks must have equal number of elements
proc compare_vector_clocks {vc1 vc2} {
    foreach gen1 $vc1 gen2 $vc2 {
	if { ${gen1} < ${gen2} } return -1
	if { ${gen1} > ${gen2} } return 1
    }
    return 0
}

db::Set instproc load {{cl "::my::Object"}} {

    my instvar cache

    global __DATASET_COUNTER__
    incr __DATASET_COUNTER__


    if { ${cache} eq {} || ![ns_conn isconnected] || [my getQueryClasses] eq {} } {
	set rows [my loadRows]
	#ns_log notice "NO CACHE: dataset load: [ad_conn file].${__DATASET_COUNTER__}"
    } else {
	#set queryClasses [lsort -unique [my getQueryClasses]]
	#set classIDs [aux::mapobj "set __RUNTIME_ID__" $queryClasses]
	set queryTables [my getQueryKeys [self]]
	#set key "[ad_conn file].${__DATASET_COUNTER__}.${cache}"
	set key "[ad_conn file].${cache}"
	set rows [ns_cache_eval -expires [ns_time incr [ns_time get] 3000] -- xo_db_cache DATA:${key} {
	    my loadRows
	}]
	set vc1 [dict get $rows vector_clock]
	set vc2 [my getVectorClock $queryTables]
	#ns_log notice "vector_clocks (load): vc1=$vc1 vc2=$vc2 queryTables=$queryTables"
	if { ${vc1} ne ${vc2} } {
	    ns_log notice "force loadRows for key=$key"
	    set rows [ns_cache_eval -expires [ns_time incr [ns_time get] 3000] -force -- xo_db_cache DATA:${key} {
		my loadRows
	    }]
	}
	#ns_log notice "key=$key"
    }

    my instvar result
    set result [rows_to_objs $rows $cl]

    my instvar extend
    if { $extend ne {} } {
	foreach o $result {
	    $o eval $extend
	}
    }

    #{ns_log notice "$__DATASET_COUNTER__ rows=$rows result=$result"}
    return $result

}

::db::Set instproc load_cell {x cf column_path} {
    my instvar pathexp type result

    set arrayName "DATA:${x}:${cf}"
    set found_p [nsv_exists $arrayName ${column_path}]
    if { !$found_p } {
	set mydict [my loadRows]
	dict set mydict ms [clock milliseconds]
	dict set mydict size [string bytelength $mydict]
	nsv_set $arrayName ${column_path} $mydict
    } else {
	set mydict [nsv_get $arrayName ${column_path}]
    }
    set result [rows_to_objs [set mydict] ::$cf]
    return $result
}


::db::Set instproc get_json {} {
    my instvar result
    set data ""
    if { ![my emptyset_p] } {
	set vars [lsort [[my head] info vars]]
	foreach o $result {
	    set row ""
	    foreach varName $vars {
		lappend row [::util::jsquotevalue ${varName}]:[::util::jsquotevalue [$o set $varName]]
	    }
	    lappend data \{[join ${row} {,}]\}
	}
    }
    return \[[join ${data} {,}]\]
}

::db::Set instproc get_js_fields {} {
    set fields ""
    if { ![my emptyset_p] } {
	set vars [lsort [[my head] info vars]]
	foreach varName $vars {
	    lappend fields "{name:[::util::jsquotevalue $varName]}"
	}
    }
    #return \[[join $fields {,}]\]
    return $fields
}

::db::Set instproc getCount {} {
    set sql [my info.db.xql-count [self]]
    return [[my getConn] getvalue ${sql}]
}

::db::Set instproc reinit {args} {
    my instvar sql
    if {[info exists sql]} {
	unset sql
    }
    my init
}






my::Class db::One -superclass "db::View"

db::One instproc init {} {

    next
    my init_sql
    my instvar conn sql result

    # Execute SQL Query

    set conn [my getConn]


    set table_exists_p [my info.db.table_exists_p]

    if {!${table_exists_p}} {
	set result [list]
	return
    }

    #ns_log notice sql=${sql}
    set result [${conn} 0or1row ${sql}]

    if {[info exists conn]} {
	${conn} destroy
    }

    return ${result}
}

db::One instproc exists_p {} {
    my instvar result
    return [exists_and_not_null result]
}

db::One instproc get {varname} {
    my instvar result
    return [${result} set ${varname}]
}


proc __compare_md_files {file1 file2} {
    lassign [split $file1 {.}] prefix ms1 ext
    lassign [split $file2 {.}] prefix ms2 ext
    if { $ms1 < $ms2 } { 
	return -1
    } elseif { $ms1 > $ms2 } {
	return 1
    } else {
	return 0
    }
}


proc sync_attributes {cl attributes} {
    set previous_version_attrs [$cl set __ATTRIBUTES__]
    if { $previous_version_attrs ne {} } {
	lassign [intersect3 $attributes $previous_version_attrs] added_attrs common_attrs deleted_attrs
	ns_log notice "CHANGES DETECTED: $cl \n\tadded_attrs=$added_attrs \n\tdeleted_attrs=$deleted_attrs"

	if { $added_attrs ne {} } {
	    # alter existing tables and ADD the new columns
	    set conn [DB_Connection new]
	    #$conn beginTransaction
	    set relname [$cl relname]
	    set sql "select n.nspname || '.' || c.relname as name from pg_class c inner join pg_namespace n on (c.relnamespace=n.oid) where relname=[ns_dbquotevalue $relname]"
	    set tablelist [$conn query $sql]
	    ns_log notice "affected tables (relname=$relname): [aux::mapobj "set name" $tablelist]"
	    foreach table $tablelist {
		foreach attr $added_attrs {
		    set tablename  [$table set name]
		    set alter_sql [$attr get_sql "add_column" $tablename]
		    if { $alter_sql ne {} } {
			if { [catch {$conn do $alter_sql} errmsg] } {
			    ns_log error "METADATA - ALTER SQL (30-db-class-procs.tcl) - ERROR: $errmsg"
			}
		    }
		}
	    }
	    #$conn endTransaction
	}
	if { $deleted_attrs ne {} } {
	    # WE DO NOT DROP ATTRIBUTE COLUMNS BECAUSE THEY MIGHT CONTAIN DATA
	    # INSTEAD CREATE A SCRIPT THAT POTENTIALLY MAKES A BACKUP AND THEN DROPS THE COLUMNS
	    # alter existing tables and DROP the deleted columns
	}
    }
}

proc sync_indexes {cl indexes} {
    set previous_version_indexes [$cl set __INDEXES__]
    if { $previous_version_indexes ne {} } {
	lassign [intersect3 $indexes $previous_version_indexes] added_indexes common_indexes deleted_indexes
	ns_log notice "CHANGES DETECTED: $cl added_indexes=$added_indexes deleted_indexes=$deleted_indexes"

	if { $added_indexes ne {} } {
	    # create new indexes
	    set conn [DB_Connection new]
	    set relname [$cl relname]
	    set tablelist [$cl getTableList $conn]

	    ns_log notice "affected tables (relname=$relname): [::xo::fun::map x $tablelist {$x set name}]"
	    foreach table $tablelist {
		foreach index $added_indexes {
		    $table instvar {nspname schema} {relname tablename}
		    set indexspace "pg_default"
		    set create_sql [$index get_db_def $schema $tablename $indexspace]
		    ns_log notice "METADATA - CREATE INDEX SQL: $create_sql"
		    if { [catch {$conn do $create_sql} errMsg] } {
			ns_log error "METADATA - CREATE INDEX SQL (30-db-class-procs.tcl) - ERROR: $errMsg"
		    }
		}
	    }
	}
	if { $deleted_indexes ne {} } {
	    # WE DO NOT DROP INDEXES BECAUSE THESE MIGHT HAVE BEEN ACCIDENTAL AND IT WOULD TAKE
	    # CONSIDERABLE TIME RECREATING THEM
	    # INSTEAD CREATE A SCRIPT THAT CAN BE SOURCED AT ANY TIME TO SYNC DB WITH METADATA
	    # alter existing tables and DROP the deleted indexes
	}
    }
}

proc update_md_column_families_file {} {
    set MD_VERSION 1
    set dir /web/db/system/
    set classes [lsort [DB_Class info instances]]

    # ns_log notice "DB_Class info instances: $classes"

    file mkdir $dir

    ### data1 - existing db metadata info
    set data1 ""
    set md_files [lsort -decreasing -integer -command __compare_md_files [glob -nocomplain -directory $dir *]]
    set latest_file [lindex $md_files 0]
    if { $latest_file ne {} } {
	set fd [open $latest_file]
	set file_version [gets $fd]
	set data1 [read $fd]
	close $fd
    }


    foreach {classId cl attributes_sig attributes indexes_sig indexes} $data1 {
	if { ![Object isobject $cl] } {
	    ns_log notice "METADATA WARNING: $cl no longer exists"
	    continue
	}
	$cl set __RUNTIME_ID__ $classId
	$cl set __ATTRIBUTES_SIG__ $attributes_sig
	$cl set __ATTRIBUTES__ $attributes
	
	$cl set __INDEXES_SIG__ $indexes_sig
	$cl set __INDEXES__ $indexes
    }


    global __CLASS_COUNTER__

    ### data2 - current metadata info
    set current_data ""
    # ns_log notice "classes=[join $classes \n\t]"
    foreach cl $classes {
	set classId [::util::coalesce [$cl set __RUNTIME_ID__] [incr __CLASS_COUNTER]]

	set attributes [lsort [$cl attributes]]
	set attributes_sig [ns_sha1 $attributes]
	if { $attributes_sig ne [$cl set __ATTRIBUTES_SIG__] } {
	    sync_attributes $cl $attributes
	}

	set indexes [lsort [$cl indexes]]
	set indexes_sig [ns_sha1 $indexes]
	if { $indexes_sig ne [$cl set __INDEXES_SIG__] } {
	    sync_indexes $cl $indexes
	}

	lappend current_data [list $classId $cl $attributes_sig $attributes $indexes_sig $indexes]
    }
    set data2 [join $current_data \n]


    # write metadata to file
    ns_log notice "[string length $data1] [string length $data2]"
    if { $file_version ne $MD_VERSION || $data1 ne $data2 } {

	# set o [::db::Schema_Version new -mixin ::db::Object]
	# $o set version $MD_VERSION
	# $o do self-insert


	set filename [file join $dir MD-ColumnFamilies.[clock milliseconds].txt]
	#HERE:save once changes have been applied to the database
	set fd [open $filename w]
	puts $fd $MD_VERSION
	puts -nonewline $fd $data2
	close $fd
	if { $latest_file ne {} } {
	    set differences [exec -- /bin/sh -c "diff $latest_file $filename || exit 0"]
	    ns_log notice "CHANGES DETECTED - db metadata changes detected - diff $latest_file $filename = $differences"
	}
    } else {
	ns_log notice "NO CHANGES - no db metadata changes detected"
    }

}

ns_atstartup update_md_column_families_file
