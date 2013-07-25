#ad_maybe_redirect_for_registration
package require crc32

#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-textarea-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/35-captcha-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/40-panel-procs.tcl
#source [acs_root_dir]/packages/persistence/tcl/ZZ-tablet-procs.tcl



namespace path {::xo::ui ::template}

Page new -master ::xo::ui::DefaultMaster -title "Add Occurrence" -appendFromScript {

    #StyleFile new -style_file [acs_root_dir]/packages/blogger/resources/css/combos.css
    StyleText new -inline_p yes -styleText {
	.search-item {
	    font:normal 11px tahoma, arial, helvetica, sans-serif;
	    padding:3px 10px 3px 10px;
	    border:1px solid #fff;
	    border-bottom:1px solid #eeeeee;
	    white-space:normal;
	    color:#555;
	}
	.search-item h3 {
	    display:block;
	    font:inherit;
	    font-weight:bold;
	    color:#222;
	}
	.search-item h3 span {
	    float: right;
	    font-weight:normal;
	    margin:0 0 5px 5px;
	    width:100px;
	    display:block;
	    clear:none;
	}
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
	-defaultLimit 10 \
	-totalProperty 'totalCount' \
	-root 'tags' \
	    -autoLoad false \
	    -fields [::util::list2json {tagname numoccurs}]

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
	<div><b>{venue_name}</b></div>
	<div>{venue_address}</div>
	<div>{venue_city}, {venue_country}</div>
	<div><a class="fl" href="#" onclick="changeVenueFn();return false;">Change venue...</a></div>
    }
    
    Tablet ds_venues \
	-pool agendadb \
	-type ::agenda::Venue \
	-limit 10 \
	-defaultLimit 10 \
	-autoLoad false \
	    -defaultSortField numoccurs \
	    -defaultSortDir DESC \
	-totalProperty 'totalCount' \
	-root 'venues' \
	    -select "{id as venue_id} venue_name venue_address venue_city venue_country {cnt_events as numoccurs}" \
	    -fields [::util::list2json {venue_id venue_name venue_address venue_city venue_country numoccurs}] \
	    -name_field_map {
		numoccurs numoccurs
	    }


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
	</div>
        </tpl>
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
    JS.Function addVenueFn -map {venue btnVenueHandlerFn} -argv {} -needs "XO.Window XO.Form" -body {
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
			    name:'venue_private_p',
			    autoWidth:true
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


    Panel new -autoHeight true -width 465 -header true -border true -headerAsText true -style "'margin-left:auto;margin-right:auto'" -title "'Add Occurrence'" -appendFromScript {

    Form new \
	-label "Add Occurrence" \
	-action store \
	-autoHeight true \
	-style "padding:5px;margin-left:auto;margin-right:auto;" \
	-appendFromScript {


	    HiddenField new -name event_id -value [::xo::kit::queryget id]

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
			-hideTrigger true \
			-typeAhead false \
			-width 325 \
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
			-emptyText {' Type a few letters to search (e.g. "Hilton")'}

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
				-timeConfig [list s:altFormats {g:i a|h:i:s A|H:i:s} b:allowBlank false] \
				-dateFormat 'Y-m-d' \
				-dateConfig [list s:altFormats {j F Y|j M Y|d M Y|F d, Y|M j, Y|F j, Y|d-M-Y|dMY|MdY|YMd|j-M-Y|jMY|MjY|YMj|j/n/Y|j.n.Y|Y-n-j|d/n/Y|d.n.Y|Y-n-d} b:allowBlank false]

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
				-timeConfig [list s:altFormats {g:i a|h:i:s A|H:i:s} b:allowBlank true] \
				-dateFormat 'Y-m-d' \
				-dateConfig [list s:altFormats {j F Y|j M Y|d M Y|F d, Y|M j, Y|F j, Y|d-M-Y|dMY|MdY|YMd|j-M-Y|jMY|MjY|YMj|j/n/Y|j.n.Y|Y-n-j|d/n/Y|d.n.Y|Y-n-d} b:allowBlank true]


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

	    foreach o [my getFields] {
		set mydict [dict merge $mydict [$o getValue]]
	    }
	    

	    set user_id [ad_conn user_id]
	    set peeraddr [ad_conn peeraddr]

	    set event_id [dict get $mydict event_id]
	    set venue_id [dict get $mydict hidden_venue]
	    set event_start_dt [dict get $mydict event_start_dt]
	    set event_end_dt [dict get $mydict event_end_dt]
	    set has_end_date_p [expr { [dict get $mydict has_end_date_p] eq {on} ? t : f }]

	    set live_p f
	    if { ${user_id} > 0 } {
		set live_p t
	    }


	    set o [::agenda::Event new -mixin ::db::Object -pool agendadb]
	    $o beginTransaction
	    $o set id $event_id

	    $o set modifying_user       $user_id
	    $o set modifying_ip         $peeraddr
	    $o set last_update           [dt_systime]

	    [$o getConn] do "update xo.xo__agenda__venue set cnt_events=cnt_events+1 where id=[ns_dbquotevalue $venue_id]"

	    $o rdb.self-update

            set vt [::agenda::Venue_Time  new -mixin ::db::Object -pool agendadb]
            $vt rdb.self-id
            $vt set event_id $event_id
            $vt set venue_id $venue_id
            $vt set start_dt $event_start_dt
            $vt set end_dt $event_end_dt
	    $vt set has_end_date_p $has_end_date_p
            $vt rdb.self-insert

	    $o endTransaction

	    ad_returnredirect ../event/$event_id

	} else {

	    my markInvalidFields

            $marshaller go -select "" -action draw
	    
	    #doc_return 200 text/plain [my getDict]
	    #doc_return 200 text/plain "Incomplete or Invalid Form"
	}
    }
}


}