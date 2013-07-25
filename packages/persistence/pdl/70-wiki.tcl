namespace eval ::wiki {;}

## previous_revision_id would enable us to merge concurrent revisions
##{RelKey previous_revision_id - ref ::Wiki::Page_Revision -ref id -datatype "Integer" -isNullable "yes"}
## {RelKey latest_revision_id -ref ::Wiki::Page_Revision -refkey id -datatype "Integer"}


DB_Class ::wiki::Page_Revision -lmap mk_attribute {

    {RelKey page_id -ref ::Wiki::Page -refkey id -datatype "integer"}

} -lmap mk_like {
    ::content::Object
    ::content::Title
    ::content::Content
    ::auditing::Auditing
}

DB_Class ::wiki::Page -lmap mk_attribute {

    {RelKey live_revision_id \
	 -ref ::Wiki::Page_Revision \
	 -refkey id \
	 -datatype "integer" \
	 -proc get_sql=before_not_null {tablename} {
	     set conn [DB_Connection new]
	     set schema [lindex [split $tablename .] 0]
	     set revisions "${schema}.xo__wiki__page_revision"

	     ::wiki::Page_Revision create_sequence_if $conn $schema
	     ::wiki::Page_Revision create_table_if $conn $schema "xo__wiki__page_revision"

	     set sql ""
	     # populate wiki::page_revision table from wiki::page
	     append sql "\n insert into $revisions (page_id,id,title,content,creation_user,creation_ip,creation_date,modifying_user,modifying_ip,last_update)
		     select id,nextval('${schema}.page_revision__seq'),title,content,creation_user,creation_ip,creation_date,modifying_user,modifying_ip,last_update from ${tablename};"
	     append sql "\n update $tablename pages set live_revision_id=(select id from $revisions where page_id=pages.id order by creation_date desc limit 1);"
	     return $sql
	     
	 }}

} -lmap mk_like {

    ::content::Object
    ::content::Title
    ::content::Content
    ::sharing::Flag_with_Start_Date
    ::auditing::Auditing

} -lmap mk_aggregator {

    { Aggregator=Ad-hoc wiki_page_1 -targetClass ::sw::agg::Most_Recent_Objects \
	  -maps_to {
	      {pathexp_arr(User) root_object_id}
	      {id object_id}
	      class_id
	      title
	      {body content}
	      shared_p
	      sharing_start_date
	  } -proc onInsertSync {o1} {

	      my instvar targetClass

	      set N 25
	      set o2 [my getImageOf ${o1}]
	      ${o2} set root_class_id 10 ;# User
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]

	      ${o2} rdb.self-insert

	      # GET CONN: Delete invalid rows.
	      set sql [subst {
		  DELETE FROM [${o2} info.db.table]
                  WHERE root_class_id=[${o2} set root_class_id]
		  AND root_object_id=[${o2} set root_object_id]
		  AND class_id=[${o2} set class_id]
		  AND object_id IN (
				      SELECT   object_id
				      FROM     [${o2} info.db.table]
				      WHERE    root_class_id=[${o2} set root_class_id] AND root_object_id=[${o2} set root_object_id] AND class_id=[${o2} set class_id] AND shared_p=[${o2} quoted shared_p]
				      ORDER BY sharing_start_date desc
				      OFFSET   ${N}
				     )}]


	      ns_log notice sql=${sql}
	      ${conn} do ${sql}

	  } -proc onDeleteSync {o1} {

	      #ns_log NOTICE "START:onDeleteSync ${o1}"

	      my instvar targetClass

	      set N 25
	      set o2 [my getImageOf ${o1}]
	      ${o2} set root_class_id 10 ;# User
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]

	      set sql_delete [subst {
		  DELETE FROM [${o2} info.db.table] 
		  WHERE root_class_id=[${o2} set root_class_id] AND 
		        root_object_id=[${o2} set root_object_id] AND 
		        class_id=[${o2} set class_id] AND 
		        object_id=[${o2} set object_id]
	      }]
	      ns_log notice sql_delete=${sql_delete}
	      ${conn} do ${sql_delete}

	      # GET CONN: Fetch last valid result from o1's table
	      set sql [subst {
		  SELECT   *
		  FROM     [${o1} info.db.table]
		  WHERE    shared_p=[${o1} quoted shared_p]
		  ORDER BY sharing_start_date desc
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

	  } -proc onUpdateSyncBefore {o1} {

	      set N 25

	      my instvar targetClass
	      set o2 [my getImageOf ${o1}]
	      ${o2} set root_class_id 10 ;# User
	      ${o2} rdb.self-update [subst {
		  root_class_id=[${o2} set root_class_id] AND 
		  root_object_id=[${o2} set root_object_id] AND 
		  class_id=[${o2} set class_id] AND
		  object_id=[${o2} set object_id]		  
	      }]
	      

	      # GET CONN: Fetch last valid result from o1's table
	      set pool1 [${o1} info.db.pool]
	      set conn1 [DB_Connection new -pool ${pool1}]
	      set sql [subst {
		  SELECT   *
		  FROM     [${o1} info.db.table]
		  WHERE    shared_p=[${o1} quoted shared_p]
		  ORDER BY sharing_start_date desc
		  OFFSET   [expr ${N}-1]
	      }]
	      set o3 [${conn1} query ${sql} ${targetClass}]
	      if {[Object isobject ${o3}]} {
		  set o4 [my getImageOf ${o3}]
		  ${o4} rdb.self-insert
	      }


	      # GET CONN: Delete invalid rows.
	      set pool2 [${o2} info.db.pool]
	      set conn2 [DB_Connection new -pool ${pool2}]
	      ${conn2} do [subst {
		  DELETE FROM [${o2} info.db.table]
                  WHERE root_class_id=[${o2} set root_class_id]
		  AND root_object_id=[${o2} set root_object_id]
		  AND class_id=[${o2} set class_id]
                    AND object_id IN (
				      SELECT   object_id
				      FROM     [${o2} info.db.table]
				      WHERE    root_class_id=[${o2} set root_class_id] AND root_object_id=[${o2} set root_object_id] AND class_id=[${o2} set class_id] AND shared_p=[${o2} quoted shared_p]
				      ORDER BY sharing_start_date desc
				      OFFSET   ${N}
				     )}]

	  } -proc onUpdateSyncAfter {o1} {
              # do nothing
          }}
} -instproc init {} {

    my instvar pathexp class_id
    my array set pathexp_arr [join ${pathexp}]
    set class_id 70
    next

} -set id 70

