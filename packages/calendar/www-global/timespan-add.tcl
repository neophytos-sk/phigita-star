#ad_maybe_redirect_for_registration
package require crc32

#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-textarea-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/35-captcha-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/40-panel-procs.tcl
#source [acs_root_dir]/packages/persistence/tcl/ZZ-tablet-procs.tcl



namespace path {::xo::ui ::template}
#-master ::xo::ui::DefaultMaster 
Page new -appendFromScript {

    StyleFile new -style_file [acs_root_dir]/packages/blogger/resources/css/combos.css
    StyleText new -inline_p yes -styleText {
	img.z-form-trigger-add{
	    width:17px;
	    height:21px;
	    background:transparent url(http://www.phigita.net/graphics/icons/add.png) no-repeat 0 0 !important;
	    cursor:pointer;
	    border:0 !important;
	    position:absolute;
	    top:0;
	}
	.fl {color:#7777CC;} 
    }

    Tablet ds0 \
	-pool agendadb \
	-select "{name as tagname} {cnt_events as numoccurs}" \
	-type ::agenda::Event_Label \
	-limit 10 \
	-totalProperty 'totalCount' \
	-root 'tags' \
	-store_fields {'tagname','numoccurs'}

    MixinRule new -applyTo ds0 -check ALL -guard {
	{[::xo::kit::queryget q] ne {} }
    } -instproc getSQLCriteria {} {
	set result [next]

	set q [::xo::kit::queryget q]
	lappend result "name ilike [::util::dbquotevalue "${q}%"]"

	return $result
    } -instproc getSQLOrder {} {
	return "cnt_events desc"
    }


    
    Template tpl0 -html {
	<tpl for="."><div class="search-item">
	<h3><span>{numoccurs} events</span>{tagname}</h3>
	</div></tpl>
    }

    Template venue_details_tpl -html {
	You selected:
	<div style="font-size:14px;">{venue_name}</div>
	<div>{venue_address}</div>
	<div>{venue_city}, {venue_country}</div>
	<div><a class="fl" href="#" onclick="changeVenueFn();return false;">Change venue...</a></div>
    }
    
    Tablet ds_venues \
	-pool agendadb \
	-select "* {id as venue_id} {cnt_events as numoccurs}" \
	-type ::agenda::Venue \
	-limit 10 \
	-defaultLimit 10 \
	-autoLoad false \
	-totalProperty 'totalCount' \
	-root 'venues' \
	-store_fields { 'venue_id','venue_name','venue_address','venue_city','venue_country' 'numoccurs'}


    # check ALL | ANY
    MixinRule new -applyTo ds_venues -check ALL -guard {
	{[::xo::kit::queryget q] ne {} }
    } -instproc getSQLCriteria {} {
	set result [next]

	set q [::xo::kit::queryget q]
	set tmplist ""
	foreach word [split $q {-,. }] {
	    lappend tmplist [::ttext::trigrams [string tolower [::ttext::unac utf-8 [::ttext::ts_clean_text $word]]]]
	}
	set trigrams [join $tmplist]
	set plainQuery [join [::xo::fun::map x $trigrams {  string map {{'} {\'} {"} {\"} \\ \\\\ { } {\ } {,} {\,}} $x }] {&}]
	set tsQuery "[::util::dbquotevalue $plainQuery]::tsquery"
	lappend result "ts_vector @@ $tsQuery"

	return $result
    } -instproc getSQLOrder {} {
	return "cnt_events desc"
    }

    
    Template tpl_venues -html {
	<tpl for="."><div class="search-item">
	<h3><span>{numoccurs} events</span>{venue_name}</h3>
	</div></tpl>
	<div class="search-item" onclick="onClickAVFn();return false;">
	<h3>None of the above! Add a new venue...</h3>
	</div>
    }
    
    JS.Function removeDuplicates -argv {arr} -body {
	var result = new Array(0);
	var seen = {};
	for (var i=0; i<arr.length; i++) {
					  if (!seen[arr[i]]) {
					      result.length += 1;
					      result[result.length-1] = arr[i];
					  }
					  seen[arr[i]] = true;
				      }
	return result
    }

    JS.Function setCaretToEnd -argv {el} -body {
	var length=el.getRawValue().length;
	el.selectText(length,length);
    }



    JS.Function tagSelectFn -map {tags setCaretToEnd removeDuplicates} -argv {record} -body {
	var oldValueArray = tags.getValue().split(',');
	oldValueArray[oldValueArray.length-1] = record.get('tagname');
	var newValueArray = new Array();
	for (var i=0; i<oldValueArray.length;i++) {
						   newValueArray[i]=oldValueArray[i].trim();
					       }
	var newValue=removeDuplicates(newValueArray).join(', ') + ', ';
	tags.setValue(newValue);
	setCaretToEnd(tags);
	tags.collapse();
    }


    JS.Function venueSelectFn -map {{venue_details_tpl vdt} {venue_details_panel vdp} venue} -argv {record} -body {
	venue.setValue(record.get('venue_id'));
	venue.collapse();
	venue.getEl().setDisplayed(false);
	vdt.overwrite(vdp.body,record.data);
	vdp.body.repaint();
    }

    JS.Function btnVenueHandlerFn -map {{ds_venues ds} venue {venueSelectFn vSFn}} -argv {button e} -body {
	var frm=button.ownerCt.getForm();
	var form_values= frm.getValues(false);
	frm.reset();
	Ext.Ajax.request({
	    url: 'venue-create',
	    success: function(response,options) {
		var obj=Ext.decode(response.responseText);
		var obj_id=obj.venue_id;
		var r=new Ext.data.Record(obj,obj_id);
		vSFn(r);
		Ext.getCmp('venue-win').hide();
		Ext.destroy(r);
	    },
	    failure: function(response,options) {
		Ext.Msg.alert('Status','Failed to add new venue'+response.responseText);
	    },
	    params: form_values
	});
    }
    JS.Function changeVenueFn -domNodeId changeVenueFn -map {venue {venue_details_panel vdp} addVenueFn} -needs "XO.Window" -body {
	venue.reset();
	venue.getEl().setDisplayed(true);
	vdp.body.update('Not Listed? <a class="fl" href="#" onclick="onClickAVFn();return false;">Add a new venue</a>');
	vdp.body.repaint();
    }
    JS.Function onClickAVFn -domNodeId onClickAVFn -map {venue addVenueFn} -argv {} -needs "XO.Window" -body {
	venue.collapse();
	addVenueFn();
    }
    JS.Function addVenueFn -map {venue btnVenueHandlerFn} -argv {} -needs "XO.Window" -body {
	if (!venue.win) {
	    venue.win = new Ext.Window({
		id:'venue-win',
		modal:true,
		title:'Add a new venue',
		bodyStyle:'padding:5',
		width:400,
		height:475,
		x:100,
		y:50,
		closeAction:'hide',
		defaultType: 'textfield',
		plain:true,
		items: new Ext.FormPanel({
		    plain:true,
		    monitorValid: true,
		    monitorPoll:100,
		    labelWidth:125,
		    defaults:{border:false},
		    items: [{
			xtype:'fieldset',
			title: 'Basic Info',
			autoHeight:true,
			defaultType: 'textfield',
			layout: 'form',
			defaults: {width: 210},
			items: [{
			    fieldLabel: 'Venue Name',
			    name: 'venue_name',
			    allowBlank:false,
			    labelStyle:'font-weight:bold;'
			}]
		    },{
			xtype:'fieldset',
			title: 'Location',
			autoHeight:true,
			defaultType: 'textfield',
			layout: 'form',
			defaults: {width: 210},
			items: [{
			    fieldLabel: 'Address',
			    name: 'venue_address',
			    allowBlank:false,
			    labelStyle:'font-weight:bold;'
			},{
			    fieldLabel: 'City',
			    name: 'venue_city',
			    allowBlank:false,
			    labelStyle:'font-weight:bold;'
			},{
			    fieldLabel: 'Country',
			    name: 'venue_country',
			    allowBlank:false,
			    labelStyle:'font-weight:bold;'
			}]
		    },{
			xtype:'fieldset',
			title: 'More Details (optional, but nice)',
			autoHeight:true,
			defaultType: 'textfield',
			layout: 'form',
			defaults: {width: 210},
			items: [{
			    fieldLabel:'Phone Number',
			    name:'venue_phone'
			},{
			    vtype:'url',
			    fieldLabel:'Venue Homepage',
			    name:'venue_homepage_url'
			},{
			    fieldLabel:'Postal / ZIP Code',
			    name:'venue_postal_code'
			},{
			    fieldLabel: 'Short description',
			    xtype:'textarea',
			    name:'venue_description',
			    height:65
			},{
			    xtype:'checkbox',
			    boxLabel:'Personal / Private (e.g. your home)',
			    name:'venue_private_p'
			}]
		    }],

		    buttons: [{
			text:'Submit',
			formBind:true,
			disabled:true,
			handler:btnVenueHandlerFn
		    },{
			text: 'Close',
			handler: function(){
			    venue.win.hide();
			}
		    }]
		})
	    });
	}
	venue.win.show();
    }


    Form new \
	-label "Add Event" \
	-labelWidth 125 \
	-monitorValid true \
	-monitorPoll 100 \
	-action store \
	-autoHeight true \
	-style "width:500px;margin-left:auto;margin-right:auto;" \
	-appendFromScript {


	    FieldSet new \
		-title "'What'" \
		-autoHeight true \
		-collapsed false \
		-appendFromScript {

		    TextField new \
			-name event_name \
			-label "Event Name" \
			-allowBlank false \
			-width 325

		}

	    FieldSet new \
		-title "'Where'" \
		-autoHeight true \
		-collapsed false \
		-appendFromScript {
		    
		    ComboBox venue -map {
			{ds_venues ds} 
			{tpl_venues resultTpl} 
			{venueSelectFn vSFn}
		    } -appendFromScript {


		    } -name "venue" \
			-label "Find a Venue" \
			-store ds \
			-typeAhead false \
			-width 325 \
			-hideTrigger true \
			-tpl resultTpl \
			-queryParam 'q' \
			-itemSelector 'div.search-item' \
			-allowBlank false \
			-minChars 3 \
			-onSelect vSFn \
			-valueField 'venue_id' \
			-displayField 'venue_name' \
			-hidden_field_p true \
			-forceSelection true \
			-emptyText {' Type a few letters to search (e.g. "Hilton" "Nicosia")'}

			Panel venue_details_panel \
			    -autoHeight true \
			    -html {'Not Listed? <a class="fl" href="#" onclick="onClickAVFn();return false;">Add a new venue</a>'}

		}

	    FieldSet new \
		-title "'When'" \
		-autoHeight true \
		-collapsed false \
		-appendFromScript {

		    FieldSet new \
			-autoHeight true \
			-border false \
			-appendFromScript {

			    DateTimeField event_start_dt \
				-name event_start_dt \
				-label "Start Date / Time" \
				-allowBlank false \
				-timeFormat 'H:i' \
				-timeConfig {{altFormats {'g:i a|h:i:s A|H:i:s'}} {allowBlank false}} \
				-dateFormat 'Y-m-d' \
				-dateConfig {{altFormats {'j F Y|j M Y|d M Y|F d, Y|M j, Y|F j, Y|d-M-Y|dMY|MdY|YMd|j-M-Y|jMY|MjY|YMj|j/n/Y|j.n.Y|Y-n-j|d/n/Y|d.n.Y|Y-n-d'}} {allowBlank false}}

			}

		    FieldSet new \
			-name has_end_date_p \
			-title "'End Date / Time'" \
			-checkboxToggle "true" \
			-checkboxName "'has_end_date_p'" \
			-collapsed true \
			-autoHeight true \
			-style 'border:none' \
			-maskDisabled true \
			-appendFromScript {
			    
			    DateTimeField event_end_dt \
				-name event_end_dt \
				-label "End Date & Time" \
				-hideLabel "true" \
				-timeFormat 'H:i' \
				-allowBlank true \
				-timeConfig {{altFormats {'g:i a|h:i:s A|H:i:s'}} {allowBlank true}} \
				-dateFormat 'Y-m-d' \
				-dateConfig {{altFormats {'j F Y|j M Y|d M Y|F d, Y|M j, Y|F j, Y|d-M-Y|dMY|MdY|YMd|j-M-Y|jMY|MjY|YMj|j/n/Y|j.n.Y|Y-n-j|d/n/Y|d.n.Y|Y-n-d'}} {allowBlank true}}

			}


		}
	    

	    FieldSet new \
		-title "'More Details'" \
		-autoHeight true \
		-appendFromScript {

		    ComboBox tags -map {
			{ds0 ds} 
			{tpl0 resultTpl} 
			tagSelectFn
		    } -name "tags" \
			-label "Tags / Type of Event" \
			-store ds \
			-typeAhead false \
			-width 325 \
			-hideTrigger true \
			-tpl resultTpl \
			-queryParam 'q' \
			-itemSelector 'div.search-item' \
			-onSelect tagSelectFn \
			-allowBlank true \
			-minChars 0

		    TextArea new \
			-name "event_description" \
			-label "About the Event" \
			-width 325 \
			-height 150 \
			-emptyText {'e.g. description, ticket prices, all ages'}
		    
		    TextField new \
			-name event_url \
			-label "Event Homepage" \
			-allowBlank true \
			-width 325 \
			-vtype 'url'

		    if { 0 == [ad_conn user_id] } {
			CharacterRecognitionCaptcha new
		    }


		}

	    proc ::util::dt_to_list {dt} {
	    }
	    MixinRule new -applyTo event_start_dt -instproc isValid {} {
		namespace path {:: ::xotcl ::xo::ui ::template}
		set start_dt [dt_ansi_to_list [event_start_dt getRawValue]]
		return [expr { [next] && ([template::util::date::compare $start_dt [template::util::date::now]] > 0) }]
	    }

	    MixinRule new -applyTo event_end_dt -guard {
		{[::xo::kit::queryget event_end_dt] ne {}}
	    } -instproc isValid {} {
		namespace path {:: ::xotcl ::xo::ui ::template}
		set start_dt [dt_ansi_to_list [event_start_dt getRawValue]]
		set end_dt [dt_ansi_to_list [event_end_dt getRawValue]]
		return [expr { [next] && ([template::util::date::compare $start_dt $end_dt] < 0) }]
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

            set timespan [::agenda::Venue_Time new -mixin ::db::Object -pool agendadb]
            $timespan rdb.self-id
            $timespan set event_id $event_id
            $timespan set venue_id $venue_id
            $timespan set has_start_date_p t
            $timespan set has_end_date_p $has_end_date_p
            $timespan set start_dt $event_start_dt
            $timespan set end_dt $event_end_dt
            $timespan rdb.self-insert

	    $o endTransaction

	    ad_returnredirect ./event/$event_id

	} else {

	    foreach o [my set __childNodes(__FORM_FIELD__)] {
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


