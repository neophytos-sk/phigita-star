namespace eval ::agenda {;}

DB_Class ::agenda::Place -lmap mk_attribute {
    {Integer location_id}
    {HStore extra}
    {TSearch2_Vector ts_vector -isNullable no -default ''::tsvector}
    {Geometry geom}
} -lmap mk_like {
    ::content::Object
} -lmap mk_index {
    {Index extra}
    {Index ts_vector}
    {Index geom}
}


DB_Class ::agenda::Venue -lmap mk_attribute {

    {String venue_name -isNullable no}
    {String venue_address -isNullable no}
    {String venue_city -isNullable no}
    {String venue_country -isNullable no}
    {FKey   place_id -ref ::agenda::Place -onDeleteAction "cascade"}

    {String venue_description -isNullable yes}
    {String venue_homepage_url -isNullable yes}
    {String venue_phone -isNullable yes}
    {String venue_postal_code -isNullable yes}
    {Boolean venue_private_p -isNullable no -default 'f'}


    {Integer cnt_events -isNullable no -default 0}

    {TSearch2_Vector ts_vector -isNullable no -default ''::tsvector}

    {HStore extra -isNullable yes}
    {Geometry geom}

} -lmap mk_like {

    ::content::Object
    ::auditing::Auditing

} -lmap mk_index {

    {Index ts_vector}
    {Index cnt_events}
    {Index geom}
}


DB_Class ::agenda::Event -lmap mk_attribute {

    {String event_name -isNullable no}

    {FKey   venue_id -ref ::agenda::Venue -onDeleteAction "cascade"}
    {Timestamp event_start_dt -isNullable no -default null}
    {Timestamp event_end_dt -isNullable yes -default null}
    {Boolean has_end_date_p -isNullable no -default 'f'}

    {String event_description -isNullable yes}
    {String event_url -isNullable yes}

    {Boolean live_p -isNullable no -default 'f'}

    {Integer cnt_attendees -isNullable no -default 0}

    {HStore extra -isNullable yes}
    {TSearch2_Vector ts_vector -isNullable no -default ''::tsvector}
    {Intarray tags_ia -isNullable yes}

} -lmap mk_like {

    ::content::Object
    ::auditing::Auditing

} -lmap mk_index {
    {Index extra}
    {Index ts_vector}
    {Index tags_ia}
    {Index cnt_attendees}
    {Index live_p}

} -lmap mk_aggregator {

    { Aggregator=Ad-hoc agenda_event_agg_1 -targetClass ::agenda::Event_Label \
          -maps_to {
	      tags_ia
          } -proc onInsertSync {o1} {
	      my instvar targetClass
              set o2 [my getImageOf ${o1}]

	      if { [$o2 set tags_ia] ne {} } {
		  set sql [subst {
		      UPDATE [${o2} info.db.table] SET cnt_events = cnt_events + 1
		      FROM int_array_enum([${o1} quoted tags_ia]) tags_ia_id
		      WHERE id=tags_ia_id
		  }]
		  [$o1 getConn] do ${sql}
	      }

          } -proc onDeleteSync {o1} {
	      my instvar targetClass
              set o2 [my getImageOf ${o1}]

	      set table_exists_p [${o2} info.db.table_exists_p]
	      if { $table_exists_p } {
		  set sql [subst {
		      UPDATE [${o2} info.db.table] SET cnt_events = cnt_events - 1
		      FROM int_array_enum([${o1} quoted tags_ia]) tags_ia_id
		      WHERE id=tags_ia_id
		  }]
		  [$o1 getConn] do ${sql}
	      }

          } -proc onUpdateSyncBefore {o1} {

	      my instvar targetClass
              set o2 [my getImageOf ${o1}]

	      if { [$o2 exists tags_ia] } {
		  set o3 [::agenda::Event new \
			      -mixin ::db::Object \
			      -set id [$o1 set id]]
		  
		  ${o3} rdb.self-load
	      }


	      set table_exists_p [${o2} info.db.table_exists_p]
	      if { $table_exists_p } {
		  if { [$o2 exists tags_ia] } {
		      if { [$o1 exists __reset(tags_ia)] } {
			  append tags_sql_2 [subst {
			      UPDATE [${o2} info.db.table] SET cnt_entries=cnt_entries-1
			      FROM int_array_enum([${o3} quoted tags_ia]::integer\[\] - coalesce([${o2} quoted tags_ia]::integer\[\],'\{\}'::integer\[\])) tags_ia_id
			      WHERE id=tags_ia_id;
			  }]
		      }
		      append tags_sql_2 [subst {
			  UPDATE [${o2} info.db.table] SET cnt_entries=cnt_entries+1
			  FROM int_array_enum([${o2} quoted tags_ia]::integer\[\] - coalesce([${o3} quoted tags_ia]::integer\[\],'\{\}'::integer\[\])) tags_ia_id
			  WHERE id=tags_ia_id;

		      }]
		      ###ns_log notice tags_sql=${tags_sql_2}
		      [${o1} getConn] do ${tags_sql_2}
		  }
	      }

          } -proc onUpdateSyncAfter {o1} {
              # do nothing
          }}}


DB_Class ::agenda::Venue_Time -lmap mk_attribute {
    {FKey event_id -ref ::agenda::Event -onDeleteAction "cascade"}
    {FKey venue_id -ref ::agenda::Venue -onDeleteAction "cascade"}
    {Boolean has_end_date_p -isNullable no -default 'f'}
    {Timestamp start_dt -isNullable yes -default null}
    {Timestamp end_dt -isNullable yes -default null}
} -lmap mk_like {
    ::content::Object
} -lmap mk_index {
    {Index start_dt}
    {Index end_dt}
    {Index venue_id}
}


DB_Class ::agenda::Event_Label -lmap mk_attribute {
    {Integer cnt_events -isNullable no -default '0'}
    {HStore extra -isNullable yes}
} -lmap mk_like {
    ::labeling::Label
} -lmap mk_index {
    {Index name -isUnique yes}
    {Index extra}
}
