#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-datastore-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/55-grid-procs.tcl
source [acs_root_dir]/packages/kernel/tcl/20-templating/85-window-procs.tcl
#source [acs_root_dir]/packages/persistence/tcl/ZZ-tablet-procs.tcl





#doc_return 200 text/plain [$o get_js_fields]\n[$o get_js_array]

namespace inscope ::xo::ui {


    Page new -master ::xo::ui::DefaultMaster -appendFromScript {

	StyleText new -inline_p yes -styleText {
	    .add {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/add.gif) !important;}
	    .option {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/plugin.gif) !important;}
	    .remove {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/delete.gif) !important;}
	}

	JS.Function urlRenderer -argv {v} -body {
	    return '<a href="' + v + '" target="_blank">' + v + '</a>';
        }

	JS.Function booleanRenderer -argv {v} -body {
	    return v ? 'Yes' : 'No';
        }

	JS.Function showVenueWinFn -map {{venue_win w}} -argv {} -body {
	    w.show();
        }


	JS.Function removeVenueFn_processResult -map {{sm0 sm} {ds0 ds}} -argv {buttonId text opt} -body {
	    if (buttonId == 'yes') {
		var sel = sm.getSelections();
		var selIDs=new Array();
		for (i=0; i < sel.length; i++) { selIDs[i] = sel[i].get('venue_id'); }
		if (sel.length > 0) {
		    Ext.Ajax.request({
                    url: 'bulk-remove',
			success: function(response,options) {
			    ds.load();
			},
			failure: function(response,options) {
			    Ext.Msg.alert('Status','Failed to remove selected venues... Try again later:'+response.responseText);
			},
			params: { id: selIDs }
		    });
		}
	    } else {
		// do nothing
	    }
	}

	JS.Function removeVenueFn -map {removeVenueFn_processResult} -argv {} -body {
	    Ext.Msg.show({
		title:'Remove Venues?',
		msg: 'You are removing venues. Would you like to continue?',
		buttons: Ext.Msg.YESNOCANCEL,
		fn: removeVenueFn_processResult,
		icon: Ext.MessageBox.QUESTION
	    });
	}


	#-store_fields [$data get_js_fields] -data [$data get_js_array] 
	Tablet ds0 \
	    -root 'root' \
	    -remoteSort true \
	    -autoLoad true \
	    -pool agendadb \
	    -select "{id as venue_id} venue_name venue_address venue_city venue_country venue_phone venue_postal_code venue_homepage_url venue_private_p creation_date {astext(geom) as geom_astext} {st_x(geom) as geom_x} {st_y(geom) as geom_y} {st_distance_sphere(geom,st_setsrid(st_makepoint(33.22,35.10),4326)) as geom_distance}" \
	    -type ::agenda::Venue \
	    -limit 25 \
	    -defaultSortField creation_date \
	    -defaultSortDir DESC \
	    -fields [util::list2json {venue_id venue_name venue_address venue_city venue_country venue_phone venue_postal_code venue_homepage_url venue_private_p creation_date geom_astext geom_x geom_y geom_distance}] \
	    -name_field_map {
		venue_id venue_id
		venue_name venue_name
		venue_address venue_address
		venue_city venue_city
		venue_country venue_country
		venue_phone venue_phone
		venue_postal_code venue_postal_code
		venue_homepage_url venue_homepage_url
		venue_private_p venue_private_p
		creation_date creation_date
		geom_astext geom
	    }

	Toolbar tbar0 -appendFromScript {
	    Toolbar.Button new \
                -text "'Add Venue'" \
                -iconCls "'add'" \
		-map {showVenueWinFn} \
		-listeners {
		    click showVenueWinFn
		}

	    Toolbar.Button new \
                -text "'Options'" \
                -iconCls "'option'"

	    Toolbar.Button new \
                -text "'Remove'" \
                -iconCls "'remove'" \
		-map {removeVenueFn} \
		-handler removeVenueFn
	}


	PagingToolbar bbar0 \
	    -label "paging_toolbar_1" \
	    -store ds0 \
	    -pageSize 25 \
	    -displayMsg "'Showing items {0} - {1} of {2}'" \
	    -emptyMsg "'No items to display'" \
	    -style "'background:#DFE8F6;border:none;'"

	Template tpl0 -html {
	    <p><b>Address:</b> {venue_address}<br>
	    <p><b>City:</b> {venue_city}<br>
	    <form action=venue-edit>
	      <input type=hidden name=id value={venue_id} />
	      <input type=text name=venue_name value="{venue_name}" />
	      <input type=text name=venue_address value="{venue_address}" />
	      <input type=text name=venue_city value="{venue_city}" />
	      <input type=text name=venue_country value="{venue_country}" />
	      <input type=text name=venue_phone value="{venue_phone}" />
	      <input type=text name=venue_postal_code value="{venue_postal_code}" />
	      <input type=text name=venue_homepage_url value="{venue_homepage_url}" />
	      <input type=text name=venue_private_p value="{venue_private_p}" />
	    <br>
	    Longitude: <input type=text name=lng value="{geom_x}" />
	    Latitude: <input type=text name=lat value="{geom_y}" />
	      <input type=submit value="Submit">
	    </form><br>
	    <p><b>Country:</b> {venue_country}<br>
	    <p><b>Homepage URL:</b> <a href="{venue_homepage_url}">{venue_homepage_url}</a><br>
	    <p><b>Actions:</b> <a href="venue-private-toggle?id={venue_id}&private_p=f">Disable</a> <a href="venue-private-toggle?id={venue_id}&private_p=t">Enable</a></p>
	}

	xg.RowExpander expander -map tpl0 -tpl tpl0
	xg.CheckboxSelectionModel sm0
	xg.RowNumberer rn0
	xg.ColumnModel cm0 -map {rn0 sm0 expander booleanRenderer} -config {[
				     rn0,
				     sm0,
				     expander,
				     {id:'venue_id',header: "ID", sortable: true, dataIndex: 'venue_id'},
				     {id:'venue_name',header: "Venue", width: 160, sortable: true, dataIndex: 'venue_name'},
				     {header: "Longitude", width: 65, sortable: true, dataIndex: 'geom_x'},
				     {header: "Latitude", width: 65, sortable: true, dataIndex: 'geom_y'},
				     {header: "Distance", width: 65, sortable: true, dataIndex: 'geom_distance'},
				     {header: "Creation Date", width: 85, sortable: true, dataIndex: 'creation_date'},
				     {header: "Private?", width: 85, renderer: booleanRenderer, sortable: true, dataIndex: 'venue_private_p'}
				    ]}

	HtmlText new -inline_p yes -html_text {
	    <div style="margin:10;">
	    Drag and drop the following bookmarklet on your browser's toolbar:
	    <a href="javascript:void(function(){var coord=gApplication.getMap().getCenter();prompt('','('+coord.lng() + ', ' + coord.lat() + ')' );}());">Get Coordinates</a>
	    <p>
	    You first need to lookup a place on <a href="http://maps.google.com/">Google Maps</a>, but this trick only works if the place is centered.
	    <p>
	    When the place you want to find (longitude,latitude) for is dead center, click on the bookmarklet.
	    <p>
	    </div>
	}

	#renderer: Ext.util.Format.dateRenderer('m/d/Y')
	GridPanel new \
	    -map {ds0 tbar0 bbar0 expander sm0 cm0} \
	    -store ds0 \
	    -tbar tbar0 \
	    -bbar bbar0 \
	    -cm cm0 \
	    -viewConfig '{forceFit:true}' \
	    -animCollapse false \
	    -plugins expander \
	    -autoExpandColumn 'venue_name' \
	    -sm sm0 \
	    -stripeRows true \
	    -autoHeight true \
	    -width "800" \
	    -style "'margin-left:auto;margin-right:auto;'" \
	    -title "'Venues'"

	Window venue_win \
	    -title "'Add Venue'" \
	    -modal true \
	    -width 400 \
	    -height 475 \
	    -x 100 \
	    -y 50 \
	    -closeAction 'hide' \
	    -layout 'fit' \
	    -bodyStyle 'padding:5' \
	    -appendFromScript {

		Form new \
		    -monitorValid true \
		    -monitorPoll 100 \
		    -labelWidth 125 \
		    -action store \
		    -standardSubmit false \
		    -url '.' \
		    -appendFromScript {
			
			FieldSet new \
			    -title "'Basic Info'" \
			    -autoHeight true \
			    -border false \
			    -appendFromScript {

				TextField new \
				    -name venue_name \
				    -label "Venue Name" \
				    -allowBlank false \
				    -width 210

			    }

			FieldSet new \
			    -title "'Location'" \
			    -autoHeight true \
			    -border false \
			    -appendFromScript {

				TextField new \
				    -name venue_address \
				    -label "Address" \
				    -allowBlank false \
				    -width 210

				TextField new \
				    -name venue_city \
				    -label "City" \
				    -allowBlank false \
				    -width 210

				TextField new \
				    -name venue_country \
				    -label "Country" \
				    -allowBlank false \
				    -width 210

			    }

			FieldSet new \
			    -title "'More Details (optional, but nice)'" \
			    -autoHeight true \
			    -border false \
			    -appendFromScript {

				TextField new \
				    -name venue_phone \
				    -label "Phone Number" \
				    -allowBlank true \
				    -width 210

				TextField new \
				    -name venue_homepage_url \
				    -label "Homepage" \
				    -allowBlank true \
				    -width 210

				TextField new \
				    -name venue_postal_code \
				    -label "Postal / ZIP Code" \
				    -allowBlank true \
				    -width 210

				TextArea new \
				    -name venue_description \
				    -label "Short Description" \
				    -allowBlank true \
				    -width 210 \
				    -height 65 

			    }
		    }
	    }


    }
}