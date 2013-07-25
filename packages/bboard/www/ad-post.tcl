#ad_maybe_redirect_for_registration
package require crc32

#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-textarea-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/35-captcha-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/40-panel-procs.tcl
#source [acs_root_dir]/packages/persistence/tcl/ZZ-tablet-procs.tcl



namespace path {::xo::ui ::template}

Page new -master ::xo::ui::DefaultMaster -title "Post to classifieds" -appendFromScript {



	Panel new -autoHeight true -width 500 -header true -border true -headerAsText true -style "'margin-left:auto;margin-right:auto'" -title "'Post to classifieds'" -appendFromScript {

	    Form new \
		-label "Post to classifieds" \
		-action store \
		-autoHeight true \
		-labelAlign 'top' \
		-style "padding:5px;margin-left:auto;margin-right:auto;" \
		-appendFromScript {

		    TextField new \
			-name title \
			-label "Posting Title" \
			-anchor '100%'

		    TextArea new \
			-name description \
			-label "Posting Description" \
			-anchor '100%' \
			-height 150

		    if { 0 == [ad_conn user_id] } {
			TextField new \
			    -name email \
			    -label "Your email address" \
			    -anchor '100%'
			TextField new \
			    -name mobile_phone \
			    -label "Your phone number (mobile)" \
			    -anchor '100%'
			CharacterRecognitionCaptcha new
		    }


		}


    } -proc action(store) {marshaller} {
	if { [my isValid] } {
	    set mydict [my getDict]

	    foreach o [my set __childNodes(__FORM_FIELD__)] {
		set mydict [dict merge $mydict [$o getValue]]
	    }
	    

	    set user_id [ad_conn user_id]
	    set peeraddr [ad_conn peeraddr]

	    set event_name [dict get $mydict event_name]
	    set venue_id [dict get $mydict hidden_venue]
	    set event_start_dt [dict get $mydict event_start_dt]
	    set event_end_dt [dict get $mydict event_end_dt]
	    set event_description [dict get $mydict event_description]
	    set event_url [dict get $mydict event_url]
	    set has_end_date_p [expr { [dict get $mydict has_end_date_p] eq {on} ? t : f }]

	    set live_p f
	    if { ${user_id} > 0 } {
		set live_p t
	    }

	    set tmplist ""
	    foreach varName {event_name event_description} {
		lappend tmplist [::ttext::trigrams [string tolower [::ttext::unac utf-8 [::ttext::ts_clean_text [set $varName]]]]]
	    }
	    set ts_vector [join [::xo::fun::map x [join $tmplist] { string map {{'} {\'} {"} {\"} \\ \\\\ { } {\ } {,} {\,}} $x }]]

	    $o set tags_ia ""
	    set tags_list [::xo::fun::filter [::xo::fun::map x [split [dict get $mydict tags] {,}] {string trim $x}] x {$x ne {}}]


	    set o [::agenda::Event new -mixin ::db::Object -pool agendadb]
	    $o beginTransaction
	    $o rdb.self-id
	    set event_id [$o set id]

	    $o set event_name $event_name
	    $o set venue_id $venue_id
	    $o set event_start_dt $event_start_dt
	    $o set event_end_dt $event_end_dt
            $o set has_end_date_p $has_end_date_p
	    $o set event_description $event_description
	    $o set event_url $event_url
	    $o set ts_vector $ts_vector
            $o set live_p $live_p
            $o set tags_ia "" 

	    set tags_ia ""
	    array set tags_hash_ia [list]

	    if { ${tags_list} ne {} } {

		set tags_clause ""
		foreach tag $tags_list {
		    lappend tags_clause [::util::dbquotevalue $tag]
		}
		set tags_clause ([join $tags_clause {,}])

		set ds_tags [::db::Set new \
                                 -pool agendadb \
				 -select [list "trim(xo__concatenate_aggregate( '{' || name || '} ' || id || ' '),', ') as tags_hash_ia"] \
				 -type ::agenda::Event_Label \
				 -where [list "name in $tags_clause"]]

		$ds_tags load

		if { ![$ds_tags emptyset_p] } {
		    array set tags_hash_ia [[$ds_tags head] set tags_hash_ia]
		}

		set tags_ia ""
		foreach tag $tags_list {

		    if { [info exists __label($tag)] } {
			continue
		    } else {
			set __label($tag) ""
		    }

		    if { [info exists tags_hash_ia($tag)] } {
			lappend tags_ia $tags_hash_ia($tag)
		    } else {
			set tag_crc32 [crc::crc32 -format %d $tag]
			set lo [::agenda::Event_Label new \
				    -mixin ::db::Object \
				    -pool agendadb \
				    -name ${tag} \
				    -name_crc32 ${tag_crc32}]

			$lo rdb.self-insert {select true;}
			set lo_id [[${lo} getConn] getvalue "select id from [${lo} info.db.table] where name=[::util::dbquotevalue ${tag}]"]
			lappend tags_ia $lo_id
		    }
		}

	    }

	    if { $tags_ia ne {} } {
		$o set tags_ia \{[join $tags_ia {,}]\}
	    }


	    $o set creation_user        $user_id
	    $o set creation_ip          $peeraddr
	    $o set modifying_user       $user_id
	    $o set modifying_ip         $peeraddr

	    [$o getConn] do "update xo.xo__agenda__venue set cnt_events=cnt_events+1 where id=[ns_dbquotevalue $venue_id]"

	    $o rdb.self-insert

            set vt [::agenda::Venue_Time  new -mixin ::db::Object -pool agendadb]
            $vt rdb.self-id
            $vt set event_id $event_id
            $vt set venue_id $venue_id
            $vt set start_dt $event_start_dt
            $vt set end_dt $event_end_dt
            $vt rdb.self-insert

	    $o endTransaction

	    ad_returnredirect ./event/$event_id

	} else {

	    foreach o [my getFields] {
		$o set value [$o getRawValue]
                if { ![$o isValid] } {
                    $o markInvalid "Failed Validation"
                }
	    }

            $marshaller go -select "" -action draw
	    
	    #doc_return 200 text/plain [my getDict]
	    #doc_return 200 text/plain "Incomplete or Invalid Form"
	}
    }
}


}