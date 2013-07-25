#    {Intarray labels_ia -isNullable yes}
#    {ObjectMap comments_map -cf "::Blog_Item_Comment"}



DB_Class Blog_Item -lmap mk_attribute {

    {String body}
    {Timestamptz entry_date}

    {Boolean allow_comments_p -isNullable no -default 'f'}
    {Integer cnt_comments -isNullable no -default 0}
    {Timestamptz last_comment -isNullable yes}

    {TSearch2_Vector ts_vector -isNullable no -default ''::tsvector}

} -lmap mk_connector {

    {Connector comments -referrer "::Blog_Item_Comment" -referrer_fkey "parent_id" -columnTarget comments_map}
    {Connector labels -referrer "::Blog_Item_Label_Map" -referrer_fkey "object_id" -columnTarget labels_ia -transformation {x {dict get $x label_id}} }

} -lmap mk_like {

    ::content::Object
    ::content::Title
    ::sharing::Flag_with_Start_Date

} -lmap mk_index {

    {Index entry_date}

} -lmap mk_aggregator {

    { Aggregator=Ad-hoc SearchIndexer -targetClass ::Blog_Item \
	  -preserve_pathexp_p yes \
	  -maps_to {
	      {pathexp_arr(User) root_object_id}
	      id
	  } -proc onInsertSync {o1} {

	      set conn [$o1 getConn]
	      set sql [subst {
		  update [$o1 info.db.table] set 
		  ts_vector=setweight(to_tsvector('[default_text_search_config]',coalesce(title,'')),'A') || setweight(to_tsvector('[default_text_search_config]',coalesce(body,'')),'B')
		  where id=[$o1 quoted id]
	      }]
	      $conn do $sql

	  } -proc onUpdateSyncBefore {o1} {

	      set conn [$o1 getConn]
	      set sql [subst {
		  update [$o1 info.db.table] set 
		  ts_vector=setweight(to_tsvector('[default_text_search_config]',coalesce(title,'')),'A') || setweight(to_tsvector('[default_text_search_config]',coalesce(body,'')),'B')
		  where id=[$o1 quoted id]
	      }]
	      $conn do $sql

	      return [$o1 info.db.table]

	  } -proc onUpdateSyncAfter {o1} { 
	      #do nothing
	  } -proc onDeleteSync {o1} {
	      # do nothing
	  }}


    { Aggregator=Ad-hoc blog_item_1 -targetClass ::sw::agg::Most_Recent_Objects \
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

	      ns_log notice "START:onDeleteSync ${o1}"

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
                  ${o3} set class_id [${o2} set class_id]
		  set o4 [my getImageOf ${o3}]
		  ${o4} set root_class_id 10 ;# User
                  ${o4} set root_object_id [ad_conn user_id]
		  ${o4} rdb.self-insert "select true;"
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


    { Aggregator=Ad-hoc blog_item_2 -targetClass ::sw::agg::Blog_Stats \
          -maps_to {
	      {pathexp_arr(User) user_id}
	      shared_p
          } -proc onInsertSync {o1} {

              my instvar targetClass
              set o2 [my getImageOf ${o1}]

	      ${o2} set cnt_entries 1
	      ${o2} set cnt_shared_entries [ad_decode [${o2} set shared_p] f 0 1]
	      ${o2} set last_shared_entry [::util::decode [${o2} set shared_p] f {} [::util::sysdate]]

              set jic_sql [subst {
                  UPDATE [${o2} info.db.table] set
                      cnt_entries = cnt_entries + 1
		     ,cnt_shared_entries = cnt_shared_entries + (case when [${o2} quoted shared_p] then 1 else 0 end)
		     ,last_entry=CURRENT_TIMESTAMP
		     ,last_shared_entry=(case when [${o2} quoted shared_p] then CURRENT_TIMESTAMP else last_shared_entry end)
                  WHERE
                      user_id=[${o2} quoted user_id]
              }]

	      ${o2} do self-insert ${jic_sql}
	      

          } -proc onDeleteSync {o1} {

	      ${o1} rdb.self-load

              set o2 [my getImageOf ${o1}]
              set sql [subst {
                  UPDATE [${o2} info.db.table] set
                      cnt_entries = cnt_entries - 1
		     ,cnt_shared_entries = cnt_shared_entries - (case when [${o1} quoted shared_p] then 1 else 0 end)
		  ,last_entry=(select max(entry_date) from [${o1} info.db.table] where id!=[${o1} quoted id])
		  ,last_shared_entry=(select max(entry_date) from [${o1} info.db.table] where shared_p and id!=[${o1} quoted id])
                  WHERE
                      user_id=[${o2} quoted user_id]
              }]
              set pool [${o2} info.db.pool]
              set conn [DB_Connection new -pool ${pool}]
              ns_log notice ${sql}
              ${conn} do ${sql}

          } -proc onUpdateSyncBefore {o1} {

              my instvar targetClass
              set o2 [my getImageOf ${o1}]

              set varlist {
                  shared_p
              }

              foreach varname ${varlist} {
                  set ${varname}.new [${o1} set ${varname}]
                  ${o1} unset ${varname}
              }
              ${o1} rdb.self-load

              foreach varname ${varlist} {
                  set delta_${varname} 0
                  if {[${o2} exists ${varname}]} {
                      if {![string equal [${o1} set ${varname}] [${o2} set ${varname}]]} {
                          if {[${o2} set ${varname}]} {
                              set delta_${varname} 1
                          } else {
                              set delta_${varname} -1
                          }
                      }
                  }
              }

              set sql [subst {
                  UPDATE [${o2} info.db.table] set
		   cnt_shared_entries = cnt_shared_entries + ${delta_shared_p}
		  ,last_shared_entry=(case when [${o2} quoted shared_p] then [${o1} quoted entry_date] else (select max(entry_date) from [${o1} info.db.table] where shared_p and id!=[${o1} quoted id]) end)
                  WHERE
                      user_id=[${o2} quoted user_id]
              }]
              set pool [${o2} info.db.pool]
              set conn [DB_Connection new -pool ${pool}]
              ns_log notice ${sql}
              ${conn} do ${sql}

              foreach varname ${varlist} {
                  ${o1} set ${varname} [set ${varname}.new]
              }

          } -proc onUpdateSyncAfter {o1} {
              # do nothing
          }}

    { Aggregator=Ad-hoc blog_item_3 -targetClass ::Blog_Item_Label \
	  -preserve_pathexp_p yes \
          -maps_to {
              pathexp
	      shared_p
          } -proc onInsertSync {o1} {
	      #do nothing
          } -proc onDeleteSync {o1} {
	      #do nothing
          } -proc onUpdateSyncBefore {o1} {

	      my instvar targetClass
              set o2 [my getImageOf ${o1}]

              set varlist {
                  shared_p
              }

              foreach varname ${varlist} {
                  set ${varname}.new [${o1} set ${varname}]
                  ${o1} unset ${varname}
              }
              ${o1} rdb.self-load

              foreach varname ${varlist} {
                  set delta_${varname} 0
                  if {[${o2} exists ${varname}]} {
                      if {![string equal [${o1} set ${varname}] [${o2} set ${varname}]]} {
                          if {[${o2} set ${varname}]} {
                              set delta_${varname} 1
                          } else {
                              set delta_${varname} -1
                          }
                      }
                  }
              }

	      set o3 [::Blog_Item_Label_Map new \
			  -mixin ::db::Object \
			  -pathexp [${o1} set pathexp]]

	      set table_exists_p [${o3} info.db.table_exists_p]
	      if {${table_exists_p}} {
		  set pool [${o2} info.db.pool]
		  set conn [DB_Connection new -pool ${pool}]
		  set sql [subst {
		      UPDATE [${o2} info.db.table] SET cnt_shared_entries = cnt_shared_entries + ${delta_shared_p}
		      FROM [${o3} info.db.table] AS bilm
		      WHERE id=bilm.label_id AND bilm.object_id=[${o1} quoted id]
		  }]
		  ns_log notice sql=${sql}
		  ${conn} do ${sql}
	      }

              foreach varname ${varlist} {
                  ${o1} set ${varname} [set ${varname}.new]
              }


          } -proc onUpdateSyncAfter {o1} {
              # do nothing
          }}


} -instproc init {} {

    my instvar pathexp class_id
    my array set pathexp_arr [join ${pathexp}]
    set class_id 80
    next

} -set id 80



### CNF
### aggregate watch
### * min entry_date s.t {{unify shared_p true}}
### * onInsert onUpdate onDelete 
### * onCreate: set to null onDrop


DB_Class Blog_Item_Comment -lmap mk_attribute {

    {FKey parent_id -ref "Blog_Item" -refkey "id" -onDeleteAction "cascade"}
    {String comment}
    {Timestamptz creation_date}
    {String creation_ip -maxlen 255}
    {Integer creation_user}
    {Boolean shared_p}
} -lmap mk_like {

    ::content::Object

} -lmap mk_index {

    {Index parent_id}

} -lmap mk_aggregator {

    { Aggregator=Ad-hoc blitco1 -targetClass ::Blog_Item \
	  -preserve_pathexp_p yes \
          -maps_to {
              pathexp
              {parent_id id}
          } -proc onInsertSync {o1} {

              my instvar targetClass
              set o2 [my getImageOf ${o1}]

              set sql [subst {
                  UPDATE [${o2} info.db.table] set
                      cnt_comments = cnt_comments + 1
		     ,last_comment=CURRENT_TIMESTAMP
		     ,ts_vector=ts_vector||setweight(to_tsvector('[default_text_search_config]',coalesce([$o1 quoted comment],'')),'C')
                  WHERE
                      id=[${o2} quoted id]
              }]
              set pool [${o2} info.db.pool]
              set conn [DB_Connection new -pool ${pool}]
              ns_log notice ${sql}
              ${conn} do ${sql}

          } -proc onDeleteSync {o1} {

	      set o3 [::Blog_Item_Comment new \
			  -mixin ::db::Object \
			  -pathexp [${o1} set pathexp]]

              set o2 [my getImageOf ${o1}]
              set sql [subst {
                  UPDATE [${o2} info.db.table] set
                      cnt_comments = cnt_comments - 1
		  ,last_comment=(select max(creation_date) from [${o3} info.db.table] where parent_id=[${o1} quoted parent_id])
                  WHERE
                      id=[${o2} quoted id]
              }]
              set pool [${o2} info.db.pool]
              set conn [DB_Connection new -pool ${pool}]
              ns_log notice ${sql}
              ${conn} do ${sql}
          } -proc onUpdateSyncBefore {o1} {
              # do nothing
          } -proc onUpdateSyncAfter {o1} {
              # do nothing
          }}}




DB_Class Blog_Item_Label -lmap mk_attribute {
    {Integer cnt_entries -isNullable no -default '0'}
    {Integer cnt_shared_entries -isNullable no -default '0'}
} -lmap mk_like {
    ::content::Object
    ::content::Name
}

DB_Class Blog_Item_Label_Map -lmap mk_attribute {

    {FKey object_id -ref "Blog_Item" -refkey "id" -onDeleteAction "cascade"}
    {FKey label_id -ref "Blog_Item_Label" -refkey "id" -onDeleteAction "cascade"}

} -lmap mk_index {
    {Index entry_label_idx -subject "object_id label_id" -isUnique yes}
} -lmap mk_aggregator {

    { Aggregator=Ad-hoc z1 -targetClass ::Blog_Item_Label \
	  -preserve_pathexp_p yes \
          -maps_to {
              pathexp
              {label_id id}
          } -proc onInsertSync {o1} {

              my instvar targetClass
              set o2 [my getImageOf ${o1}]

	      set o3 [::Blog_Item new \
			  -mixin ::db::Object \
			  -pathexp [${o1} set pathexp] \
			  -id [${o1} set object_id]]

	      ${o3} rdb.self-load

              set sql [subst {
                  UPDATE [${o2} info.db.table] set
                      cnt_entries = cnt_entries + 1
		     ,cnt_shared_entries = cnt_shared_entries + (case when [${o3} quoted shared_p] then 1 else 0 end)
                  WHERE
                      id=[${o2} quoted id]
              }]
              set pool [${o2} info.db.pool]
              set conn [DB_Connection new -pool ${pool}]
              ns_log notice ${sql}
              ${conn} do ${sql}

          } -proc onDeleteSync {o1} {
              set o2 [my getImageOf ${o1}]

	      set o3 [::Blog_Item new \
			  -mixin ::db::Object \
			  -pathexp [${o1} set pathexp] \
			  -id [${o1} set object_id]]

	      ${o3} rdb.self-load

              set sql [subst {
                  UPDATE [${o2} info.db.table] set
                      cnt_entries = cnt_entries - 1
		     ,cnt_shared_entries = cnt_shared_entries - (case when [${o3} quoted shared_p] then 1 else 0 end)
                  WHERE
                      id=[${o2} quoted id]
              }]
              set pool [${o2} info.db.pool]
              set conn [DB_Connection new -pool ${pool}]
              ns_log notice ${sql}
              ${conn} do ${sql}
          } -proc onUpdateSyncBefore {o1} {
              # do nothing
          } -proc onUpdateSyncAfter {o1} {
              # do nothing
          }}}

