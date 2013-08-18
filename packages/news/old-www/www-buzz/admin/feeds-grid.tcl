#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
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

	JS.Function urlRenderer -argv {v} -body {
	    return '<a href="' + v + '" target="_blank">' + v + '</a>';
        }

	JS.Function booleanRenderer -argv {v} -body {
	    return (v=='t' || v=='true') ? 'Yes' : 'No';
        }


	JS.Function updateSelectionsFn -map {{sm0 sm} {ds0 ds}} -argv {theKey theValue} -body {
	    var sel = sm.getSelections();
	    var selURLs=new Array();
            for (i=0; i < sel.length; i++) { selURLs[i] = sel[i].get('url'); }
	    alert(selURLs);
	    if (sel.length > 0) {
		Ext.Ajax.request({
		    url: 'bulk-update',
		    success: function(response,options) {
			ds.load();
		    },
		    failure: function(response,options) {
			Ext.Msg.alert('Status','Failed to enable feed selections:'+response.responseText);
		    },
		    params: { url: selURLs, key: theKey, value:theValue}
		});
	    }
	}

	JS.Function enableFn -map {{updateSelectionsFn u}} -body {
	    u('active_p','t');
	}

	JS.Function disableFn -map {{updateSelectionsFn u}} -body {
	    u('active_p','f');
	}


	#-store_fields [$data get_js_fields] -data [$data get_js_array] 
	Tablet ds0 \
	    -root 'root' \
	    -remoteSort true \
	    -autoLoad true \
	    -pool newsdb \
	    -type ::buzz::Feed \
	    -limit 25 \
	    -defaultSortField url \
	    -defaultSortDir ASC \
	    -fields [::util::list2json {host url last_crawl active_p crawl_interval}] \
	    -name_field_map {
		url url
		host url
		last_crawl last_crawl
		active_p active_p
		crawl_interval crawl_interval
	    } -proc afterLoad {} {
		foreach o [my set result] {
		    array set uri [uri::split [$o set url]]
		    $o set host $uri(host)
		}
	    }

	Toolbar tbar0 -appendFromScript {
	    Toolbar.Button new \
                -text "'Add Feed'" \
                -iconCls "'add'"

	    Toolbar.Button new \
		-text 'Enable' \
		-map enableFn \
		-handler enableFn

	    Toolbar.Button new \
		-text 'Disable' \
		-map disableFn \
		-handler disableFn

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
	    <p><b>Feed URL:</b> <a href="{url}">{url}</a><br>
	    <p><b>Buzz:</b> <a href="http://buzz.phigita.net/?host={host}">view stories</a><br>
	    <p><b>Actions:</b> <a href="http://buzz.phigita.net/admin/feed-status-toggle?url={url}&active_p=f">Disable</a> <a href="http://buzz.phigita.net/admin/feed-status-toggle?url={url}&active_p=t">Enable</a></p>
	}

	xg.RowExpander expander -map tpl0 -tpl tpl0
	xg.CheckboxSelectionModel sm0
	xg.RowNumberer rn0
	xg.ColumnModel cm0 -map {rn0 sm0 expander booleanRenderer} -config {[
				     rn0,
				     sm0,
				     expander,
				     {id:'url',header: "URL", width: 160, sortable: true, dataIndex: 'host'},
				     {header: "Last Crawl", width: 85, sortable: true, dataIndex: 'last_crawl'},
				     {header: "Crawl Interval", width: 85, sortable: true, dataIndex: 'crawl_interval'},
				     {header: "Active?", width: 85, renderer: booleanRenderer, sortable: true, dataIndex: 'active_p'}
				    ]}

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
	    -sm sm0 \
	    -stripeRows true \
	    -autoExpandColumn 'url' \
	    -autoHeight true \
	    -width "800" \
	    -style "'margin-left:auto;margin-right:auto;'" \
	    -title "'Buzz Feeds'"


    }
}