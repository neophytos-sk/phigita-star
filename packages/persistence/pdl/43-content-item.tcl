
Class ::AggregateFn -parameter {
    {preserve_pathexp_p "no"}
}

::AggregateFn instproc getPathExp {o1} {
    my instvar preserve_pathexp_p
    if { $preserve_pathexp_p } {
	return [$o1 set pathexp]
    }
    return ""
}

::AggregateFn instproc getImageOf {o1} {

    my instvar targetClass targetFields

    set o2 [${targetClass} new -mixin ::db::Object]

    foreach item ${targetFields} {

	### TODO: llength == 3, convertFn

        if {[llength ${item}]==2} {
            foreach {o1_varname o2_varname} ${item} break;
        } else {
            set o1_varname ${item}
            set o2_varname ${item}
        }
        if {[${o1} exists ${o1_varname}]} {
            ${o2} set ${o2_varname} [${o1} set ${o1_varname}]
        }
    }

    return ${o2}


}

::AggregateFn instproc onInsertSync {o} {}
::AggregateFn instproc onDeleteSync {o} {}
::AggregateFn instproc onUpdateSyncBefore {o} {}
::AggregateFn instproc onUpdateSyncAfter {o} {}

Class ::Mt_AggregateFn -superclass Class
::Mt_AggregateFn ::Top_AFn  -superclass ::AggregateFn -parameter {
    {targetClass ""}
    {targetFields ""}
    {targetCriteria ""}
    {targetOrdering ""}
    {sourceCriteria ""}
    {numRows "25"}
    {key ""}
} 

::Top_AFn instproc getCriteria {{-exclude_key_p false} o2} {
    my instvar targetClass targetCriteria key
    
    set result ""
    foreach varName $targetCriteria {
	if { $exclude_key_p && $key eq $varName } continue
	lappend result "$varName = [$o2 quoted $varName]"
    }
    return [join $result { AND }]
}

::Top_AFn instproc getOrderingClause {} {
    my instvar targetOrdering
    return [join $targetOrdering {, }]
}

::Top_AFn instproc onInsertSync {o1} {
    my instvar targetClass {numRows N} key

    set o2 [my getImageOf ${o1}]


    set conn [$o1 getConn]
    ${o2} rdb.self-insert

    set criteria [my getCriteria -exclude_key_p yes $o2]
    set order_by [my getOrderingClause]

    # Delete non-conforming/invalid rows

    set sql [subst {
	DELETE FROM [${o2} info.db.table]
	WHERE ${criteria} AND ${key} IN (
					 SELECT   ${key}
					 FROM     [${o2} info.db.table]
					 WHERE    ${criteria}
					 ORDER BY ${order_by}
					 OFFSET   ${N}
					 )}]


    ${conn} do ${sql}

}

::Top_AFn instproc onDeleteSync {o1} {

    my instvar targetClass {numRows N} srcCriteria

    set o2 [my getImageOf ${o1}]


    set conn [$o1 getConn]

    set delete_criteria [my getCriteria $o2]

    set sql_delete [subst {
	DELETE FROM [${o2} info.db.table]
	WHERE ${delete_criteria}
    }]

    ${conn} do ${sql_delete}

    #set order_by [my getOrderingClause]
    set order_by "creation_date desc"

    ### foreach targetCriteria ifexists in o1, then sourcecriteria
    ### e.g. shared_p below, diaforo tou key

    # Fetch last valid result from o1's table
    set sql [subst {
	SELECT   *
	FROM     [${o1} info.db.table]
	WHERE    shared_p=[${o1} quoted shared_p]
	ORDER BY ${order_by}
	OFFSET   [expr ${N}-1]
    }]

    set o3 [${conn} query ${sql} ${targetClass}]
    if {[Object isobject ${o3}]} {
	set o4 [my getImageOf ${o3}]
	${o4} set class_id [${o2} set class_id]
	${o4} set root_class_id [${o2} set root_class_id]
	${o4} set root_object_id [${o2} set root_object_id]

	${o4} rdb.self-insert
    }



}

::Top_AFn instproc onUpdateSyncAfter {o1} {

    my instvar {numRows N} targetClass key

    set o2 [my getImageOf ${o1}]

    set update_criteria [my getCriteria $o2]
    ${o2} rdb.self-update ${update_criteria}

    set order_by "creation_date desc"

    # Fetch last valid result from o1's table
    set sql [subst {
	SELECT   *
	FROM     [${o1} info.db.table]
	WHERE    shared_p=[${o1} quoted shared_p]
	ORDER BY ${order_by}
	OFFSET   [expr ${N}-1]
    }]

    set conn [$o1 getConn]
    set o3 [${conn} query ${sql} ${targetClass}]
    if {[Object isobject ${o3}]} {
	${o3} set class_id [${o2} set class_id]
	set o4 [my getImageOf ${o3}]
	${o4} set root_class_id 10 ;# User
	${o4} set root_object_id [ad_conn user_id]
	${o4} rdb.self-insert "select true;"
    }


    set delete_criteria [my getCriteria -exclude_key_p yes $o2]
    set target_order_by [my getOrderingClause]

    # Delete invalid rows.
    ${conn} do [subst {
	DELETE FROM [${o2} info.db.table]
	WHERE ${delete_criteria} AND ${key} IN (
			  SELECT   $key
			  FROM     [${o2} info.db.table]
			  WHERE    ${delete_criteria}
			  ORDER BY ${target_order_by}
			  OFFSET   ${N}
			  )}]
}










#{FKey folder_id -ref "Content_Folder" -refkey "id" -isNullable yes}
DB_Class ::Content_Item -lmap mk_attribute {
    {String title -isNullable no}
    {String description -isNullable yes}
    {HStore extra}
    {TSearch2_Vector ts_vector -isNullable yes}
    {Intarray tags_ia -isNullable yes}
} -lmap mk_like {
    ::content::Object
    ::content::Starred
    ::content::Hidden
    ::content::Deleted
    ::content::Shared
    ::auditing::Auditing
} -lmap mk_index {
    {Index extra}
    {Index ts_vector}
    {Index tags_ia}
} -lmap mk_aggregator {

    { Aggregator=Ad-hoc content_item_3 -targetClass ::Content_Item_Label \
          -maps_to {
              pathexp
	      tags_ia
	      shared_p
          } -proc onInsertSync {o1} {
	      my instvar targetClass
              set o2 [my getImageOf ${o1}]

	      if { [$o1 set shared_p] } {
		  set delta_shared_p 1
	      } else {
		  set delta_shared_p 0
	      }
	      if { [$o2 set tags_ia] ne {} } {
		  set sql [subst {
		      UPDATE [${o2} info.db.table] SET cnt_shared_entries = cnt_shared_entries + ${delta_shared_p}, cnt_entries = cnt_entries + 1
		      FROM int_array_enum([${o1} quoted tags_ia]) tags_ia_id
		      WHERE id=tags_ia_id
		  }]
		  [$o1 getConn] do ${sql}
	      }

          } -proc onDeleteSync {o1} {
	      my instvar targetClass
              set o2 [my getImageOf ${o1}]

	      ${o1} rdb.self-load

	      if { [$o1 set shared_p] } {
		  set delta_shared_p 1
	      } else {
		  set delta_shared_p 0
	      }

	      set table_exists_p [${o2} info.db.table_exists_p]
	      if { $table_exists_p } {
		  set sql [subst {
		      UPDATE [${o2} info.db.table] SET cnt_shared_entries = cnt_shared_entries - ${delta_shared_p}, cnt_entries = cnt_entries - 1
		      FROM int_array_enum([${o1} quoted tags_ia]) tags_ia_id
		      WHERE id=tags_ia_id
		  }]
		  [$o1 getConn] do ${sql}
	      }

          } -proc onUpdateSyncBefore {o1} {

	      my instvar targetClass
              set o2 [my getImageOf ${o1}]


	      if { [$o2 exists shared_p] || [$o2 exists tags_ia] } {
		  set o3 [Content_Item new \
			      -pathexp [$o1 set pathexp] \
			      -mixin ::db::Object \
			      -set id [$o1 set id]]
		  
		  ${o3} rdb.self-load
	      }

	      ### HERE Handle label-apply tags_ia

	      if { [$o2 exists shared_p] } {

		  set varlist {
		      shared_p
		  }

		  foreach varname ${varlist} {
		      set ${varname}.new [${o1} set ${varname}]
		      ${o1} unset ${varname}
		  }
		  
		  foreach varname ${varlist} {
		      set delta_${varname} 0
		      if {[${o2} exists ${varname}]} {
			  if {![string equal [${o3} set ${varname}] [${o2} set ${varname}]]} {
			      if {[${o2} set ${varname}]} {
				  set delta_${varname} 1
			      } else {
				  set delta_${varname} -1
			      }
                      }
		      }
		  }
	      } else {
		  set delta_shared_p 0
	      }


	      set table_exists_p [${o2} info.db.table_exists_p]
	      if { $table_exists_p } {
		  if { $delta_shared_p != 0 } {
		      set sql [subst {
			  UPDATE [${o2} info.db.table] SET cnt_shared_entries = cnt_shared_entries + ${delta_shared_p}
			  FROM int_array_enum([${o3} quoted tags_ia]) tags_ia_id
			  WHERE id=tags_ia_id
		      }]
		      ###ns_log notice sql=${sql}
		      [${o1} getConn] do ${sql}
		  }

		  if { [$o2 exists tags_ia] } {
		      if { [$o3 set shared_p] || ${delta_shared_p} == 1 } {
			  set tags_delta_shared_p 1
		      } else {
			  set tags_delta_shared_p 0
		      }
		      if { [$o1 exists __reset(tags_ia)] } {
			  append tags_sql_2 [subst {
			      UPDATE [${o2} info.db.table] SET cnt_shared_entries = cnt_shared_entries - ${tags_delta_shared_p}, cnt_entries=cnt_entries-1
			      FROM int_array_enum([${o3} quoted tags_ia]::integer\[\] - coalesce([${o2} quoted tags_ia]::integer\[\],'\{\}'::integer\[\])) tags_ia_id
			      WHERE id=tags_ia_id;
			  }]
		      }
		      append tags_sql_2 [subst {
			  UPDATE [${o2} info.db.table] SET cnt_shared_entries = cnt_shared_entries + ${tags_delta_shared_p}, cnt_entries=cnt_entries+1
			  FROM int_array_enum([${o2} quoted tags_ia]::integer\[\] - coalesce([${o3} quoted tags_ia]::integer\[\],'\{\}'::integer\[\])) tags_ia_id
			  WHERE id=tags_ia_id;

		      }]
		      ###ns_log notice tags_sql=${tags_sql_2}
		      [${o1} getConn] do ${tags_sql_2}
		  }
	      }

	      if { [$o2 exists shared_p] } {
		  foreach varname ${varlist} {
		      ${o1} set ${varname} [set ${varname}.new]
		  }
	      }


          } -proc onUpdateSyncAfter {o1} {
              # do nothing
          }}

    {::Top_AFn Content_Item__MRO_25 -targetClass ::sw::agg::Most_Recent_Objects -key object_id -targetFields {
	root_class_id
	{pathexp_arr(User) root_object_id}
	class_id
	{id object_id}
	title
	shared_p
    } -targetCriteria {
	root_class_id
	root_object_id
	class_id
	object_id
	shared_p
    } -sourceCriteria {
	shared_p
    } -targetOrdering {
	{sharing_start_date desc}
    }}


} -instproc init {args} {

    my instvar pathexp class_id root_class_id
    my array set pathexp_arr [join ${pathexp}]
    set class_id 33
    set root_class_id 10
    next

} -set id 33


DB_Class ::Content_Item_Part -lmap mk_attribute {
    {FKey item_id -ref ::Content_Item -isNullable no -onDeleteAction "cascade"}
    {Integer part_index -isNullable no}
    {String part_text -isNullable no}
    {TSearch2_Vector ts_vector -isNullable yes}
} -lmap mk_index {
    {Index item_part_un -subject {item_id part_index} -isUnique yes}
    {Index ts_vector}
}


Class GIST_Text_Index -instproc setSubject {subject} {

    my set __index_subject $subject

} -instproc setTarget {name} {

    my set __index_vector_name $name

} -instproc setIndexList {list} {

    my set __index_list $list

} -instproc rdb.self-insert {{jic_sql ""}} {

    set result [next]
    my rdb.self-update-index
    return $result

} -instproc rdb.self-update {{where_clause ""}} {

    set result [next]
    my rdb.self-update-index
    return $result

} -instproc rdb.self-update-index {} {

    my instvar __index_vector_name __index_list __index_subject

    if { ![info exists __index_subject] } {
	set __index_subject id
    }
    
    set expression "coalesce($__index_vector_name,'')"
    foreach item $__index_list {
	foreach {field_weight storage_type field_dict field_name} $item break
	switch -exact -- $storage_type {
	    db {
		lappend expression "setweight(to_tsvector([ns_dbquotevalue [::util::coalesce $field_dict [default_text_search_config]]],coalesce(translate($field_name,'.@\/','---'),'')),[ns_dbquotevalue $field_weight])"
	    } 
	    tcl {
		set quoted_value [::util::dbquotevalue [my set $field_name]]
		lappend expression "setweight(to_tsvector([ns_dbquotevalue [::util::coalesce $field_dict [default_text_search_config]]],coalesce(translate($quoted_value,'.@\/','---'),'')),[ns_dbquotevalue $field_weight])"
	    }
	}
    }
    set expression [join $expression {||}]
    
    set where_clause ""
    foreach attname ${__index_subject} {
	lappend where_clause ${attname}=[ns_dbquotevalue [my set ${attname}]]
    }
    set where_clause [join $where_clause { AND }]

    set sql "update [my info.db.table] set $__index_vector_name=$expression where ${where_clause}"
    #ns_log notice text/plain $sql
    [my getConn] do $sql

}




DB_Class Content_Item_Label -lmap mk_attribute {
    {Integer cnt_entries -isNullable no -default '0'}
    {Integer cnt_shared_entries -isNullable no -default '0'}
    {HStore extra -isNullable yes}
} -lmap mk_like {
    ::labeling::Label
} -lmap mk_index {
    {Index name -isUnique yes}
    {Index extra}
}



















return

### Generic Aggregate Mechanism

# MRO = Most Recent Objects 
# AFn = Aggregate Function

Class ::Mt_Mt_AggregateFn -superclass Class -parameter {
    {Mt_AFn.prefix ""}
    {Mt_AFn.class ""}
}

::Mt_Mt_AggregateFn instproc init {args} {
    my superclass [concat [my Mt_AFn.class] [my info superclass]]
    return [next]
}


Class ::Mt_AggregateFn -superclass Class
::Mt_AggregateFn instproc init {args} {

    ns_log notice "here infoclass=[my info class] self=[self] selfclass=[self class] callingclass=[self callingclass]"
    set cl [my info class]
    my instproc worker([namespace tail [$cl Mt_AFn.class]]) {} "return [self]"
    [$cl Mt_AFn.class] set manager $cl


    ns_log notice "[self] instforward flowTrigger([namespace tail [$cl Mt_AFn.class]]) [self]"

    my instforward flowTrigger([namespace tail [$cl Mt_AFn.class]]) [self]

    next
}



Class ::AggregateFn

::AggregateFn instproc init {args} {
    ns_log notice "infoclass=[my info class] self=[self] selfclass=[self class] callingclass=[self callingclass]"
    next
}

::AggregateFn instproc AFn_getFlowTrigger {cl} {
    return [my flowTrigger([namespace tail $cl])]
}

::AggregateFn instproc AFn_getTargetObject {} {

    my array set pathexp_arr [join [my set pathexp]]
    
    set cl [self callingclass]
    #ns_log notice "$cl worker($cl)=[my worker($cl)] [[my worker([namespace tail $cl])] info class]"

    set prefix [[$cl set manager] set Mt_AFn.prefix]

    ns_log notice "manager=[$cl set manager] $prefix"

    #[my worker([namespace tail $cl])] 
    [my AFn_getFlowTrigger $cl] instvar "${prefix}.class targetClass" "${prefix}.fields fields"


    set o [$targetClass new -mixin ::db::Object]
    foreach item $fields {

	### llength == 3, would contain the convert function from o1 to o2

        if {[llength ${item}]==2} {
            foreach {o1_varname o2_varname} ${item} break;
        } else {
            set o1_varname ${item}
            set o2_varname ${item}
        }
        if {[my exists ${o1_varname}]} {
            ${o} set ${o2_varname} [my set ${o1_varname}]
        }
    }

    return ${o}

}



###### TOP_N aggregate function
Class ::TOP_AFn -superclass ::AggregateFn

::TOP_AFn instproc rdb.self-insert {{jic_sql ""}} {
    ns_log notice "inside [self class]"
    next

    set o [my AFn_getTargetObject]

    ns_log notice "selfclass=[self class] infoclass=[my info class] self=[self] callingclass=[self callingclass] calledclass=[self calledclass]"

    [my AFn_getFlowTrigger [self class]] instvar {TOP_AFn.N N}

    ${o} set root_class_id 10
    ${o} set class_id [[my info class] set id]

    #set pool [${o} info.db.pool]
    #set conn [DB_Connection new -pool ${pool}]
    set conn [$o getConn]

    ${o} rdb.self-insert

              # GET CONN: Delete invalid rows.
    set sql [subst {
	DELETE FROM [${o} info.db.table]
	WHERE root_class_id=[${o} set root_class_id]
	AND root_object_id=[${o} set root_object_id]
	AND class_id=[${o} set class_id]
                  AND object_id IN (
                                      SELECT   object_id
                                      FROM     [${o} info.db.table]
                                      WHERE    root_class_id=[${o} set root_class_id] AND root_object_id=[${o} set root_object_id] AND class_id=[${o} set class_id] AND shared_p=[${o} quoted shared_p]
                                      ORDER BY sharing_start_date desc
                                      OFFSET   ${N}
				      )}]


    ns_log notice sql=${sql}
    #${conn} do ${sql}

}


::Mt_Mt_AggregateFn ::Mt_TOP_AFn  -superclass ::Mt_AggregateFn -parameter {
    {TOP_AFn.class ""}
    {TOP_AFn.fields ""}
    {TOP_AFn.N "25"}
} -Mt_AFn.prefix TOP_AFn -Mt_AFn.class ::TOP_AFn



## Mt_MRO_AFn instmixin add MRO_AFn


Mt_TOP_AFn ::Content_Item__MRO_25 -superclass ::TOP_AFn -TOP_AFn.N 25 -TOP_AFn.class {::sw::agg::Most_Recent_Objects} -TOP_AFn.fields {
    {pathexp_arr(User) root_object_id}
    title
    {id object_id}
    {description content}
    shared_p
    sharing_start_date
}

#set o ::CI_MRO_AFn
#ns_log notice "[$o MRO_AFn.class] [$o MRO_AFn.fields] [$o info class]"
########### HERE HERE HERE
::Content_Item instmixin add ::Content_Item__MRO_25 end














