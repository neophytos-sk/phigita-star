#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/10-ui-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-datastore-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/55-grid-procs.tcl
#source [acs_root_dir]/packages/persistence/tcl/ZZ-tablet-procs.tcl





#doc_return 200 text/plain [$o get_js_fields]\n[$o get_js_array]

namespace inscope ::xo::ui {


    Page new -master ::xo::ui::DefaultMaster -appendFromScript {

	StyleText new -inline_p yes -styleText {
	    .add {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/add.gif) !important;}
	    .option {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/plugin.gif) !important;}
	    .remove {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/delete.gif) !important;}
	}


	JS.Function OLD_mergePlacesFn -map {sm0} -argv {btn e} -body {
	    var sel = sm0.getSelections();
	    var synonyms='';
	    var place_name;
	    for (var i=0; i<sel.length;i++) {
		place_name = place_name || sel[i].get('place_city');
		synonyms+=sel[i].get('place_city');
	    }
	    alert('name:'+place_name+' synonyms:'+synonyms);
	}

	JS.Function mergePlacesFn_processResult -map {{sm0 sm} {ds0 ds}} -argv {buttonId text opt} -body {
	    if (buttonId == 'yes') {
		var sel = sm.getSelections();
		var selIDs=new Array();
		for (i=0; i < sel.length; i++) { selIDs[i] = sel[i].get('place_id'); }
		if (sel.length > 0) {
		    Ext.Ajax.request({
                    url: 'bulk-merge-places',
			success: function(response,options) {
			    ds.load();
			},
			failure: function(response,options) {
			    Ext.Msg.alert('Status','Failed to merge selected places... Try again later:'+response.responseText);
			},
			params: { id: selIDs }
		    });
		}
	    } else {
		// do nothing
	    }
	}

	JS.Function mergePlacesFn -map {mergePlacesFn_processResult} -argv {} -body {
	    Ext.Msg.show({
		title:'Merge Places?',
		msg: 'You are mergin places. Would you like to continue?',
		buttons: Ext.Msg.YESNOCANCEL,
		fn: mergePlacesFn_processResult,
		icon: Ext.MessageBox.QUESTION
	    });
	}

	JS.Function urlRenderer -argv {v} -body {
	    return '<a href="' + v + '" target="_blank">' + v + '</a>';
        }

	JS.Function booleanRenderer -argv {v} -body {
	    return v ? 'Yes' : 'No';
        }


	#-store_fields [$data get_js_fields] -data [$data get_js_array] 
	Tablet ds0 \
	    -root 'root' \
	    -remoteSort true \
	    -autoLoad true \
	    -pool agendadb \
	    -select "{id as place_id} {extra->'city' as place_city} {extra->'country' as place_country}" \
	    -type ::agenda::Place \
	    -limit 25 \
	    -defaultSortField place_city \
	    -defaultSortDir DESC \
	    -fields [util::list2json {place_id place_city place_country}] \
	    -name_field_map {
		place_id place_id
		place_city extra->'city'
		place_country extra->'country'
	    }

	Toolbar tbar0 -appendFromScript {
	    Toolbar.Button new \
                -text "'Add Place'" \
                -iconCls "'add'"

	    Toolbar.Button new \
                -text "'Merge'" \
		-map {mergePlacesFn} \
		-listeners {
		    click mergePlacesFn
		}


	    Toolbar.Button new \
                -text "'Options'" \
                -iconCls "'option'"

	    Toolbar.Button new \
                -text "'Remove'" \
                -iconCls "'remove'"
	    #-map {uploadFileFn} -handler uploadFileFn
	}


	PagingToolbar bbar0 \
	    -label "paging_toolbar_1" \
	    -store ds0 \
	    -pageSize 25 \
	    -displayMsg "'Showing items {0} - {1} of {2}'" \
	    -emptyMsg "'No items to display'" \
	    -style "'background:#DFE8F6;border:none;'"

	Template tpl0 -html {
	    <p><b>City:</b> {place_city}<br>
	    <p><b>Country:</b> {place_country}<br>
	    <form action=place-edit>
	      <input type=hidden name=id value={place_id} />
	    <br>City (in Greek):<input type=text name=city.el value="{place_city}" />
	    <br>City (in English):<input type=text name=city.en value="{place_city}" />
	    <br>Country (in Greek):<input type=text name=country.el value="{place_city}" />
	    <br>Country (in English):<input type=text name=country.en value="{place_country}" />
	      <input type=submit value="Submit">
	    </form><br>
	}

	xg.RowExpander expander -map tpl0 -tpl tpl0
	xg.CheckboxSelectionModel sm0
	xg.RowNumberer rn0
	xg.ColumnModel cm0 -map {rn0 sm0 expander booleanRenderer} -config {[
				     rn0,
				     sm0,
				     expander,
				     {id:'place_id',header: "ID", sortable: true, dataIndex: 'place_id'},
				     {id:'place_city',header: "City", width: 160, sortable: true, dataIndex: 'place_city'},
				     {header: "Country", width: 85, sortable: true, dataIndex: 'place_country'},
				    ]}

	#renderer: Ext.util.Format.dateRenderer('m/d/Y')
	GridPanel grid0 \
	    -map {ds0 tbar0 bbar0 expander sm0 cm0} \
	    -store ds0 \
	    -tbar tbar0 \
	    -bbar bbar0 \
	    -cm cm0 \
	    -viewConfig '{forceFit:true}' \
	    -animCollapse false \
	    -plugins expander \
	    -sm sm0 \
	    -stripeRows true \
	    -autoHeight true \
	    -width "800" \
	    -style "'margin-left:auto;margin-right:auto;'" \
	    -title "'Places'"


    }
}
