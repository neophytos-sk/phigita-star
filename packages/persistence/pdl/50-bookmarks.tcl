

##############
### ::bm    ##
##############

namespace eval ::bm {;}


DB_Class ::bm::Label -lmap mk_attribute {
    {Integer cnt_bookmarks -default '0'}    
} -lmap mk_like {
    ::labeling::Label
} -lmap mk_aggregator {

    { Aggregator=Ad-hoc x1 -targetClass ::sw::agg::Url_Label \
	  -maps_to {
	      name
	      name_crc32
	  } -proc onInsertSync {o1} {

	      my instvar targetClass
	      set o2 [my getImageOf ${o1}]
	      ${o2} set cnt_users 1

	      # Just In Case SQL
	      set jic_sql [subst {
		  UPDATE [${o2} info.db.table] set
		      cnt_users = cnt_users + 1
		  WHERE
		     name_crc32= [${o2} quoted name_crc32] and
		     name=[${o2} quoted name]
	      }]

	      
	      ${o2} rdb.self-insert ${jic_sql}


	  } -proc onDeleteSync {o1} {

	      

	      # In particular, self-load fetches the missing variables only
	      # and thus the following is required in order to be able to 
	      # delete the old record. 

	      #ns_log notice "OLD: name=[${o1} quoted name], name_crc32=[${o1} quoted name_crc32]"
	      
	      set name.new [${o1} set name]
	      set name_crc32.new [${o1} set name_crc32]
	      ${o1} unset name
	      ${o1} unset name_crc32

	      ${o1} rdb.self-load

	      #ns_log notice "NEW: name=[${o1} quoted name], name_crc32=[${o1} quoted name_crc32]"

	      set o2 [my getImageOf ${o1}]
	      set sql [subst {
		  UPDATE [${o2} info.db.table] set
		      cnt_users = cnt_users - 1
		  WHERE
		     name_crc32= [${o2} quoted name_crc32] and
		     name=[${o2} quoted name]
	      }]
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      #ns_log notice ${sql}
	      ${conn} do ${sql}
	      ${o1} set name ${name.new}
	      ${o1} set name_crc32 ${name_crc32.new}

	  } -proc onUpdateSyncBefore {o1} {
	      my onDeleteSync ${o1}
	      my onInsertSync ${o1}
	  } -proc onUpdateSyncAfter {o1} {
	      #do nothing
	  }}

}


# meaning of video_p = embeddable video
# scribd: {Boolean document_p -isNullable no -default 'f'}
# slideshare: {Boolean slideshow_p -isNullable no -default 'f'}
# audio: {Boolean audio_p -isNullable no -default 'f'}
# flickr
DB_Class ::bm::Bookmark -lmap mk_attribute {

    {String  url}
    {String  snippet -maxlen 1000 -isNullable yes}
    {Integer cnt_clickthroughs}
    {Timestamptz last_clickthrough}
    {Timestamptz second_to_last_clickthrough}

    {Boolean deleted_p -default 'f'}
    {Boolean hidden_p -default 'f'}
    {Boolean starred_p -default 'f'}

    {Boolean video_p -isNullable no -default 'f'}
    {Boolean preview_p -isNullable no -default 'f'}
    {TclDict extra -isNullable yes}

} -lmap mk_like {

    ::content::Object
    ::content::Title
    ::content::Description
    ::content::Reading
    ::content::Subscription
    ::content::Sticky
    ::content::Cache
    ::content::Adult
    ::content::Interesting
    ::auditing::Auditing
    ::sharing::Flag_with_Start_Date

} -lmap mk_index {
    {Index url -isUnique yes}
    {Index deleted_p}
    {Index hidden_p}
    {Index starred_p}
} -lmap mk_aggregator {

    { Aggregator=Ad-hoc a1 -targetClass ::sw::agg::Most_Recent_Objects \
	  -maps_to {
	      {pathexp_arr(User) root_object_id}
	      {id object_id}
	      class_id
	      title
	      {url content}
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
	      ${conn} do [subst {
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

	  } -proc onDeleteSync {o1} {

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
	      #ns_log notice sql_delete=${sql_delete}
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
		  LIMIT 1
	      }]
	      set o3 [${conn1} query ${sql} ::bm::Bookmark]
	      if {[Object isobject ${o3}]} {
		  ${o3} set pathexp_arr(User) [${o3} set creation_user]
		  set o4 [my getImageOf ${o3}]
		  ${o4} set root_class_id 10 ;# User
		  ${o4} set class_id 50
		  ${o4} rdb.self-insert "select 1"
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
	      #do nothing
	  }} 

    { Aggregator=Ad-hoc a2 -targetClass ::sw::agg::Url_User_Map \
	  -maps_to {
	      url
	      {pathexp_arr(User) user_id}
	      shared_p
	      sharing_start_date
	      snippet
	      title
	      description
	  } -proc onInsertSync {o1} {

	      my instvar targetClass
	      set o2 [my getImageOf ${o1}]
	      array set uri [uri::split [${o2} set url]]
	      ${o2} set url_sha1 [ns_sha1 [${o2} set url]]
	      ${o2} set url_host $uri(host)
	      ${o2} set url_host_sha1 [ns_sha1 $uri(host)]

	      ${o2} set label_crc32_arr [list]

	      ${o2} rdb.self-insert

	  } -proc onDeleteSync {o1} {

	      ${o1} rdb.self-load
	      ${o1} init
	      my instvar targetClass
	      set o2 [my getImageOf ${o1}]
	      array set uri [uri::split [${o2} set url]]
	      ${o2} set url_sha1 [ns_sha1 [${o2} set url]]
	      ${o2} set url_host $uri(host)
	      ${o2} set url_host_sha1 [ns_sha1 $uri(host)]

	      set sql [subst {
		  DELETE FROM [${o2} info.db.table]
		   WHERE url_sha1 = [${o2} quoted url_sha1] 
		     AND user_id=[${o2} quoted user_id]
	      }]
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      ns_log notice ${sql}
	      ${conn} do ${sql}

	  } -proc onUpdateSyncBefore {o1} {

	      ${o1} rdb.self-load
	      ${o1} init
	      my instvar targetClass
	      set o2 [my getImageOf ${o1}]
	      array set uri [uri::split [${o2} set url]]
	      ${o2} set url_sha1 [ns_sha1 [${o2} set url]]
	      ${o2} set url_host $uri(host)
	      ${o2} set url_host_sha1 [ns_sha1 $uri(host)]

	      set sql [subst {
		  UPDATE [${o2} info.db.table] set 
		      title = [${o2} quoted title]
		     ,description = [${o2} quoted description]
		     ,snippet = [${o2} quoted snippet]
		     ,shared_p = [${o2} quoted shared_p] 
		   WHERE url_sha1 = [${o2} quoted url_sha1] 
		     AND url_host_sha1=[${o2} quoted url_host_sha1]
		     AND user_id=[${o2} quoted user_id]
	      }]
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      #ns_log notice ${sql}
	      ${conn} do ${sql}

	  } -proc onUpdateSyncAfter {o1} {
	      #do nothing
	  }}

    { Aggregator=Ad-hoc a3 -targetClass ::sw::agg::Url \
	  -maps_to {
	      url
	      feed_url
	      feed_url_sha1
	      title
	      description
	      creation_user
	      creation_ip
	      creation_date
	      modifying_user
	      modifying_ip
	      last_update
	      rating
	      unread_p
	      starred_p
	      interesting_p
	      shared_p
	      sticky_p
	      subscribe_p
	      cache_p
	      adult_p
	      video_p
	      preview_p
	      extra
	  } -proc onInsertSync {o1} {

	      my instvar targetClass
	      set o2 [my getImageOf ${o1}]
	      array set uri [uri::split [${o2} set url]]
	      ${o2} set url_sha1 [ns_sha1 [${o2} set url]]
	      ${o2} set url_host $uri(host)
	      ${o2} set url_host_sha1 [ns_sha1 $uri(host)]

	      ${o2} set cnt_unread [ad_decode [${o2} set unread_p] t 1 0]
	      ${o2} set cnt_favorite [ad_decode [${o2} set starred_p] t 1 0]
	      ${o2} set cnt_interesting [ad_decode [${o2} set interesting_p] t 1 0]
	      ${o2} set cnt_shared [ad_decode [${o2} set shared_p] t 1 0]
	      ${o2} set cnt_sticky [ad_decode [${o2} set sticky_p] t 1 0]
	      ${o2} set cnt_subscribe [ad_decode [${o2} set subscribe_p] t 1 0]
	      ${o2} set cnt_cache  [ad_decode [${o2} set cache_p] t 1 0]
	      ${o2} set cnt_adult [ad_decode [${o2} set adult_p] t 1 0]

	      ${o2} set max_sharing_user_id [ad_decode [${o2} set shared_p] t [${o2} set creation_user] ""]
	      ${o2} set max_sharing_start_date [ad_decode [${o2} set shared_p] t [clock format [ns_time] -format "%Y-%m-%d %H:%M:%S %Z"] ""]

	      ${o2} set label_crc32_arr [list]

	      ${o2} set cnt_users 1

	      # Just In Case SQL
	      set jic_sql [subst {
		  UPDATE [${o2} info.db.table] set
		  title = (case when [${o2} quoted shared_p] then [${o2} quoted title] else title end)
		  ,description = (case when [${o2} quoted shared_p] then [${o2} quoted description] else description end)
		  ,label_crc32_arr = (case when [${o2} quoted shared_p] then '{}' else label_crc32_arr end)
		     ,feed_url_sha1=[${o2} quoted feed_url_sha1]
		     ,cnt_unread = cnt_unread + [${o2} set cnt_unread]
		     ,cnt_favorite = cnt_favorite + [${o2} set cnt_favorite]
		     ,cnt_interesting = cnt_interesting + [${o2} set cnt_interesting]
		     ,cnt_shared = cnt_shared + [${o2} set cnt_shared]
		     ,cnt_sticky = cnt_sticky + [${o2} set cnt_sticky]
		     ,cnt_subscribe = cnt_subscribe + [${o2} set cnt_subscribe]
		     ,cnt_cache = cnt_cache + [${o2} set cnt_cache]
		     ,cnt_adult = cnt_adult + [${o2} set cnt_adult]
		     ,cnt_users = cnt_users+1
		     ,modifying_user = [${o2} quoted modifying_user]
		     ,modifying_ip = [${o2} quoted modifying_ip]
		     ,last_update = NOW()
		  ,max_sharing_start_date=(case when [${o2} quoted shared_p] then [::util::coalesce [${o2} quoted max_sharing_start_date] null] else max_sharing_start_date end)
		  ,max_sharing_user_id=(case when [${o2} quoted shared_p] then [::util::coalesce [${o2} quoted max_sharing_user_id] null] else max_sharing_user_id end)
		  WHERE
		     url= [${o2} quoted url]
	      }]

	      ${o2} rdb.self-insert ${jic_sql}

	      if {[${o2} exists feed_url_sha1]} {
		  if {![string equal {} [${o2} set feed_url_sha1]]} {
		      set conn [${o2} getConn]
		      set sql "INSERT INTO [${o2} info.db.table] (url,url_host_sha1,url_sha1,creation_user,creation_ip,modifying_user,modifying_ip,creation_date,last_update,label_crc32_arr,cnt_unread,cnt_favorite,cnt_adult,cnt_sticky,cnt_interesting,cnt_users,feed_p,buzz_p) values ([${o2} quoted feed_url],[${o2} quoted url_host_sha1],[${o2} quoted feed_url_sha1],[${o2} quoted creation_user],[${o2} quoted creation_ip],[${o2} quoted modifying_user],[${o2} quoted modifying_ip],current_timestamp,current_timestamp,'{}',0,0,0,0,0,0,'t','t')"
		      #ns_log notice "FEED SQL:${sql}"
		      ${conn} pl "select xo__insert_dml([ns_dbquotevalue ${sql}],[ns_dbquotevalue "UPDATE [${o2} info.db.table] SET feed_p='t' WHERE url=[${o2} quoted feed_url]"])"
		  }
	      }

	  } -proc onDeleteSync {o1} {

	      my instvar targetClass

	      set N 25
	      
	      foreach varname {unread_p starred_p interesting_p shared_p sticky_p subscribe_p cache_p adult_p} {
		  set ${varname}.new [${o1} set ${varname}]
		  ${o1} unset ${varname}
	      }

	      ${o1} rdb.self-load
	      ${o1} init
	      set o2 [my getImageOf ${o1}]
	      ${o2} set url_sha1 [ns_sha1 [${o2} set url]]


	      #HERE
	      array set uri [uri::split [${o1} set url]]
	      set o3 [db::Set new \
			  -set url_host_sha1 [ns_sha1 $uri(host)] \
			  -select "*" \
			  -type ::sw::agg::Url_User_Map \
			  -order "sharing_start_date desc" \
			  -where [list "shared_p" "url_sha1=[${o2} quoted url_sha1]" "user_id!=[${o1} quoted creation_user]"] \
			  -limit 1 \
			  -load]
	      
	      if {[${o3} emptyset_p]} {
		  ${o2} set max_sharing_start_date ""
		  ${o2} set max_sharing_user_id ""
		  ${o2} set label_crc32_arr "{}"
	      } else {

		  set o4_pathexp [list "User [[${o3} head] set user_id]"]
		  set o4 [db::Set new \
			      -select [list "int_array_aggregate(name_crc32) as label_crc32_arr"] \
			      -type [db::Inner_Join new \
					 -pathexp ${o4_pathexp} \
					 -lhs [db::Inner_Join new -alias bmlam \
						   -lhs [db::Set new \
							     -alias bm \
							     -pathexp ${o4_pathexp} \
							     -select "id" \
							     -type "::bm::Bookmark" \
							     -where [list "shared_p" "url=[${o2} quoted url]"]] \
						   -rhs [db::Set new \
							     -alias bmlm \
							     -pathexp ${o4_pathexp} \
							     -type "::bm::Label_Map"] \
						   -join_condition {bm.id = bmlm.bookmark_id}] \
					 -rhs [db::Set new \
						   -alias la \
						   -pathexp ${o4_pathexp} \
						   -type "::bm::Label"] \
					 -join_condition {la.id=label_id}]]
		  ${o4} load
						     
		  ${o2} set title [[${o3} head] set title]
		  ${o2} set description [[${o3} head] set description]
		  ${o2} set max_sharing_start_date [[${o3} head] set sharing_start_date]
		  ${o2} set max_sharing_user_id [[${o3} head] set user_id]
		  ${o2} set label_crc32_arr [[${o4} head] set label_crc32_arr]

	      }


	      ${o2} set root_class_id 10 ;# User
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]

	      ${o2} set cnt_unread [ad_decode [${o2} set unread_p] t 1 0]
	      ${o2} set cnt_favorite [ad_decode [${o2} set starred_p] t 1 0]
	      ${o2} set cnt_interesting [ad_decode [${o2} set interesting_p] t 1 0]
	      ${o2} set cnt_shared [ad_decode [${o2} set shared_p] t 1 0]
	      ${o2} set cnt_sticky [ad_decode [${o2} set sticky_p] t 1 0]
	      ${o2} set cnt_subscribe [ad_decode [${o2} set subscribe_p] t 1 0]
	      ${o2} set cnt_cache  [ad_decode [${o2} set cache_p] t 1 0]
	      ${o2} set cnt_adult [ad_decode [${o2} set adult_p] t 1 0]

	      set sql [subst {
		  UPDATE [${o2} info.db.table] set 
		      title=(case when [${o2} quoted title] is not null then [${o2} quoted title] else title end)
		     ,description=[${o2} quoted description]
		     ,cnt_unread = cnt_unread - [${o2} set cnt_unread]
		     ,cnt_favorite=cnt_favorite-[${o2} set cnt_favorite]
		     ,cnt_interesting=cnt_interesting-[${o2} set cnt_interesting]
		     ,cnt_shared = cnt_shared - [${o2} set cnt_shared]
		     ,cnt_sticky = cnt_sticky - [${o2} set cnt_sticky]
		     ,cnt_subscribe = cnt_subscribe - [${o2} set cnt_subscribe]
		     ,cnt_cache = cnt_cache - [${o2} set cnt_cache]
		     ,cnt_adult = cnt_adult - [${o2} set cnt_adult]
		     ,cnt_users = cnt_users-1
		     ,modifying_user = [${o2} quoted modifying_user]
		     ,modifying_ip = [${o2} quoted modifying_ip]
		     ,last_update = NOW()
		  ,max_sharing_start_date=[ns_dbquotevalue [${o2} set max_sharing_start_date]]
		  ,max_sharing_user_id=[ns_dbquotevalue [${o2} set max_sharing_user_id]]
		  ,label_crc32_arr=[${o2} quoted label_crc32_arr]
		  WHERE
		     url = [${o2} quoted url]
	      }]

	      ns_log notice sql=${sql}
	      ${conn} do ${sql}

	      foreach varname {unread_p starred_p interesting_p shared_p sticky_p subscribe_p cache_p adult_p} {
		  ${o1} set ${varname} [set ${varname}.new]
	      }
	      
	  } -proc onUpdateSyncBefore {o1} {

	      my instvar targetClass
	      set o2 [my getImageOf ${o1}]

	      set varlist {
		  unread_p
		  starred_p
		  interesting_p
		  shared_p
		  sticky_p
		  subscribe_p
		  cache_p
		  adult_p
	      }

	      foreach varname ${varlist} {
		  set ${varname}.new [${o1} set ${varname}]
		  ${o1} unset ${varname}
	      }
	      ${o1} rdb.self-load
	      ${o1} init
	      ${o2} set url_sha1 [ns_sha1 [${o1} set url]]


	      foreach varname ${varlist} {
		  set delta_${varname} 0
		  if {[${o2} exists ${varname}]} {
		      if { [${o1} set ${varname}] ne [${o2} set ${varname}] } {
			  if { [${o2} set ${varname}] } {
			      set delta_${varname} 1
			  } else {
			      set delta_${varname} -1
			  }
		      }
		  }
	      }

	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      set sql [subst {
		  UPDATE [${o2} info.db.table] set 
		     cnt_unread = cnt_unread + ${delta_unread_p}
		     ,cnt_favorite=cnt_favorite + ${delta_starred_p}
		     ,cnt_interesting=cnt_interesting + ${delta_interesting_p}
		     ,cnt_shared = cnt_shared + ${delta_shared_p}
		     ,cnt_sticky = cnt_sticky + ${delta_sticky_p}
		     ,cnt_subscribe = cnt_subscribe + ${delta_subscribe_p}
		     ,cnt_cache = cnt_cache + ${delta_cache_p}
		     ,cnt_adult = cnt_adult + ${delta_adult_p}
		     ,modifying_user = [ad_conn user_id]
		  ,modifying_ip = [ns_dbquotevalue [ad_conn peeraddr]]
		     ,last_update = NOW()
		  WHERE
		     url = [${o2} quoted url]
	      }]


	      #ns_log NOTICE sql=${sql}
	      ${conn} do ${sql}

	      foreach varname ${varlist} {
		  ${o1} set ${varname} [set ${varname}.new]
	      }

	  } -proc onUpdateSyncAfter {o1} {

	      my instvar targetClass
	      set o2 [my getImageOf ${o1}]
	      ${o2} set url_sha1 [ns_sha1 [${o1} set url]]
	      
	      array set uri [uri::split [${o1} set url]]
	      set o3 [db::Set new \
			  -set url_host_sha1 [ns_sha1 $uri(host)] \
			  -select "*" \
			  -type ::sw::agg::Url_User_Map \
			  -order "sharing_start_date desc" \
			  -where [list "shared_p" "url_sha1=[${o2} quoted url_sha1]"] \
			  -limit 1 \
			  -load]


	      if {[${o3} emptyset_p]} {
		  ${o2} set title ""
		  ${o2} set description ""
		  ${o2} set max_sharing_start_date ""
		  ${o2} set max_sharing_user_id ""
		  ${o2} set label_crc32_arr "{}"
	      } else {

		  set o4_pathexp [list "User [[${o3} head] set user_id]"]
		  set o4 [db::Set new \
			      -select [list "int_array_aggregate(name_crc32) as label_crc32_arr"] \
			      -type [db::Inner_Join new \
					 -pathexp ${o4_pathexp} \
					 -lhs [db::Inner_Join new -alias bmlam \
						   -lhs [db::Set new \
							     -alias bm \
							     -pathexp ${o4_pathexp} \
							     -select "id" \
							     -type "::bm::Bookmark" \
							     -where [list "shared_p" "url=[${o2} quoted url]"]] \
						   -rhs [db::Set new \
							     -alias bmlm \
							     -pathexp ${o4_pathexp} \
							     -type "::bm::Label_Map"] \
						   -join_condition {bm.id = bmlm.bookmark_id}] \
					 -rhs [db::Set new \
						   -alias la \
						   -pathexp ${o4_pathexp} \
						   -type "::bm::Label"] \
					 -join_condition {la.id=label_id}]]
		  ${o4} load
						     
		  ${o2} set title [[${o3} head] set title]
		  ${o2} set description [[${o3} head] set description]
		  ${o2} set max_sharing_start_date [[${o3} head] set sharing_start_date]
		  ${o2} set max_sharing_user_id [[${o3} head] set user_id]
		  ${o2} set label_crc32_arr [[${o4} head] set label_crc32_arr]

	      }

	      if { [$o2 set max_sharing_user_id] eq {} } {
		  # once you've posted something, it's done
		  # problem with max_sharing_user_id being set to null where cnt_shared remains >0
		  return
	      }

	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      set sql [subst {
		  UPDATE [${o2} info.db.table] set 
		      title=(case when [${o2} quoted title] is not null then [${o2} quoted title] else title end)
		     ,description=[${o2} quoted description]
		     ,max_sharing_start_date=[${o2} quoted max_sharing_start_date]
		     ,max_sharing_user_id=[${o2} quoted max_sharing_user_id]
		     ,label_crc32_arr=[${o2} quoted label_crc32_arr]
		  WHERE
		     url = [${o2} quoted url]
	      }]


	      #ns_log NOTICE sql=${sql}
	      ${conn} do ${sql}


	  }} 

} -instproc init {} {
    my instvar pathexp class_id

    my array set pathexp_arr [join ${pathexp}]
    set class_id 50

    next

} -set id 50





DB_Class ::bm::Label_Map -lmap mk_attribute {
    {FKey bookmark_id -ref ::bm::Bookmark -onDeleteAction "cascade"}
    {FKey label_id -ref ::bm::Label -onDeleteAction "cascade"}
} -lmap mk_index {
    {Index bookmark_label_idx -subject "bookmark_id label_id" -isUnique yes}
} -lmap mk_aggregator {

    { Aggregator=Ad-hoc z1 -targetClass ::bm::Label \
	  -preserve_pathexp_p yes \
	  -maps_to {
	      pathexp
	      {label_id id}
	  } -proc onInsertSync {o1} {

	      my instvar targetClass
	      set o2 [my getImageOf ${o1}]

	      set sql [subst {
		  UPDATE [${o2} info.db.table] set
		      cnt_bookmarks = cnt_bookmarks + 1
		  WHERE
		      id=[${o2} quoted id]
	      }]
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      #ns_log notice ${sql}
	      ${conn} do ${sql}

	  } -proc onDeleteSync {o1} {
	      set o2 [my getImageOf ${o1}]
	      set sql [subst {
		  UPDATE [${o2} info.db.table] set
		      cnt_bookmarks = cnt_bookmarks - 1
		  WHERE
		      id=[${o2} quoted id]
	      }]
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      #ns_log notice ${sql}
	      ${conn} do ${sql}
	  } -proc onUpdateSyncBefore {o1} {
	      # do nothing
	  } -proc onUpdateSyncAfter {o1} {
	      #do nothing
	  }}


    { Aggregator=Ad-hoc z2 -targetClass ::sw::agg::Url \
	  -maps_to {
	      {pathexp_arr(User) user_id}
	      url
	  } -proc onInsertSync {o1} {


	      set o2 [my getImageOf ${o1}]

	      set o3 [::bm::Label new \
			  -mixin ::db::Object \
			  -pathexp [${o1} set pathexp] \
			  -id [${o1} set label_id]]

	      ${o3} rdb.self-load

	      if {![${o2} exists url]} {
		  set o4 [::bm::Bookmark new \
			      -mixin ::db::Object \
			      -pathexp [${o1} set pathexp] \
			      -id [${o1} set bookmark_id]]
		  ${o4} rdb.self-load
		  ${o2} set url [${o4} set url]
	      }

	      set sql [subst {
		  UPDATE [${o2} info.db.table] SET 
		      label_crc32_arr=(label_crc32_arr-[${o3} quoted name_crc32]::int)+[${o3} quoted name_crc32]::int
		  WHERE max_sharing_user_id=[${o2} quoted user_id]
		    AND url=[${o2} quoted url]
	      }]
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      #ns_log notice ${sql}
	      ${conn} do ${sql}

	  } -proc onDeleteSync {o1} {

	      set o2 [my getImageOf ${o1}]

	      set o3 [::bm::Label new \
			  -mixin ::db::Object \
			  -pathexp [${o1} set pathexp] \
			  -id [${o1} set label_id]]

	      ${o3} rdb.self-load

	      if {![${o2} exists url]} {
		  set o4 [::bm::Bookmark new \
			      -mixin ::db::Object \
			      -pathexp [${o1} set pathexp] \
			      -id [${o1} set bookmark_id]]
		  ${o4} rdb.self-load
		  ${o2} set url [${o4} set url]
	      }

	      set sql [subst {
		  UPDATE [${o2} info.db.table] SET 
		      label_crc32_arr=label_crc32_arr-[${o3} quoted name_crc32]::int
		  WHERE max_sharing_user_id=[${o2} quoted user_id]
		  AND label_crc32_arr @ [ns_dbquotevalue "\{[${o3} set name_crc32]\}"]
		  AND url=[${o2} quoted url]
	      }]
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      #ns_log notice ${sql}
	      ${conn} do ${sql}

	  } -proc onUpdateSyncBefore {o1} {
	      # do nothing
	  } -proc onUpdateSyncAfter {o1} {
	      #do nothing
	  }}


    { Aggregator=Ad-hoc z3 -targetClass ::sw::agg::Url_User_Map \
	  -maps_to {
	      {pathexp_arr(User) user_id}
	      url
	  } -proc onInsertSync {o1} {


	      set o2 [my getImageOf ${o1}]

	      set o3 [::bm::Label new \
			  -mixin ::db::Object \
			  -pathexp [${o1} set pathexp] \
			  -id [${o1} set label_id]]

	      ${o3} rdb.self-load

	      if {![${o2} exists url]} {
		  set o4 [::bm::Bookmark new \
			      -mixin ::db::Object \
			      -pathexp [${o1} set pathexp] \
			      -id [${o1} set bookmark_id]]
		  ${o4} rdb.self-load
		  ${o2} set url [${o4} set url]
	      }
	      array set uri [uri::split [${o2} set url]]
	      ${o2} set url_sha1 [ns_sha1 [${o2} set url]]
	      ${o2} set url_host $uri(host)
	      ${o2} set url_host_sha1 [ns_sha1 $uri(host)]

	      set sql [subst {
		  UPDATE [${o2} info.db.table] SET 
		      label_crc32_arr=(label_crc32_arr-[${o3} quoted name_crc32]::int)+[${o3} quoted name_crc32]::int
		  WHERE user_id=[${o2} quoted user_id]
		    AND url_sha1=[${o2} quoted url_sha1]
	      }]
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      #ns_log notice ${sql}
	      ${conn} do ${sql}

	  } -proc onDeleteSync {o1} {

	      set o2 [my getImageOf ${o1}]

	      set o3 [::bm::Label new \
			  -mixin ::db::Object \
			  -pathexp [${o1} set pathexp] \
			  -id [${o1} set label_id]]

	      ${o3} rdb.self-load

	      if {![${o2} exists url]} {
		  set o4 [::bm::Bookmark new \
			      -mixin ::db::Object \
			      -pathexp [${o1} set pathexp] \
			      -id [${o1} set bookmark_id]]
		  ${o4} rdb.self-load
		  ${o2} set url [${o4} set url]
	      }
	      array set uri [uri::split [${o2} set url]]
	      ${o2} set url_sha1 [ns_sha1 [${o2} set url]]
	      ${o2} set url_host $uri(host)
	      ${o2} set url_host_sha1 [ns_sha1 $uri(host)]

	      set sql [subst {
		  UPDATE [${o2} info.db.table] SET 
		      label_crc32_arr=label_crc32_arr-[${o3} quoted name_crc32]::int
		  WHERE user_id=[${o2} quoted user_id]
		  AND label_crc32_arr @ [ns_dbquotevalue "\{[${o3} set name_crc32]\}"]
		  AND url_sha1=[${o2} quoted url_sha1]
	      }]
	      set pool [${o2} info.db.pool]
	      set conn [DB_Connection new -pool ${pool}]
	      #ns_log notice ${sql}
	      ${conn} do ${sql}

	  } -proc onUpdateSyncBefore {o1} {
	      # do nothing
	  } -proc onUpdateSyncAfter {o1} {
	      #do nothing
	  }}

} -instproc init {} {
    my instvar pathexp

    my array set pathexp_arr [join ${pathexp}]

    next

}





