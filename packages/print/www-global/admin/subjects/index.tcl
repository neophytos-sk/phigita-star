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
	    -pool bookdb \
	    -select "id lang ddc name" \
	    -type ::Book::Subject \
	    -limit 25 \
	    -defaultSortField ddc \
	    -fields [util::list2json {id lang ddc name}] \
	    -name_field_map {
		id id
		lang lang
		ddc ddc
		name name
	    } -proc action(returnData) {marshaller} {
		ad_page_contract {
		    @author Neophytos Demetriou
		} {
		    {q:trim ""}
		}
		if { ${q} ne {} } {
		    my lappend where [::xo::db::qualifier ts_vector trigrams-contains ${q}]
		}
		return [next]
	    }


	Toolbar tbar0 -appendFromScript {
	    Toolbar.Button new \
                -text "'Test'"

	    SearchField sf \
		-map {ds0} \
		-store ds0 \
		-emptyText "'Search'" \
		-width "200" \
		-paramName 'q'

	}


	PagingToolbar bbar0 \
	    -label "paging_toolbar_1" \
	    -store ds0 \
	    -pageSize 25 \
	    -displayMsg "'Showing items {0} - {1} of {2}'" \
	    -emptyMsg "'No items to display'" \
	    -style "'background:#DFE8F6;border:none;'"

	xg.CheckboxSelectionModel sm0
	xg.ColumnModel cm0 -map {sm0 booleanRenderer} -config {[
				     sm0,
				     {id:'id',header: "ID", sortable: true, dataIndex: 'id'},
				     {id:'ddc',header: "DDC", sortable: true, dataIndex: 'ddc'},
				     {id:'name',header: "Subject", width: 160, sortable: true, dataIndex: 'name'}
				    ]}

	#renderer: Ext.util.Format.dateRenderer('m/d/Y')
	GridPanel grid0 \
	    -map {ds0 tbar0 bbar0 sm0 cm0} \
	    -store ds0 \
	    -tbar tbar0 \
	    -bbar bbar0 \
	    -cm cm0 \
	    -autoExpandColumn 'name' \
	    -viewConfig '{forceFit:true}' \
	    -animCollapse false \
	    -sm sm0 \
	    -stripeRows true \
	    -autoHeight true \
	    -width "800" \
	    -style "'margin-left:auto;margin-right:auto;'" \
	    -title "'Book Subjects'"


    }
}
