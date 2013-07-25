#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-datastore-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/55-grid-procs.tcl
source [acs_root_dir]/packages/persistence/tcl/ZZ-tablet-procs.tcl





#doc_return 200 text/plain [$o get_js_fields]\n[$o get_js_array]

namespace inscope ::xo::ui {


    Page new -master ::xo::ui::DefaultMaster -appendFromScript {

	StyleText new -inline_p yes -styleText {
	    .add {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/add.gif) !important;}
	    .option {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/plugin.gif) !important;}
	    .remove {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/delete.gif) !important;}
	}


	JS.Function booleanRenderer -argv {v} -body {
	    return v ? 'Yes' : 'No';
        }


	#-store_fields [$data get_js_fields] -data [$data get_js_array] 
	set pathexp [list "User 814"]
	Tablet ds0 \
	    -pathexp $pathexp \
	    -root 'root' \
	    -remoteSort true \
	    -autoLoad true \
	    -type ::calendar::Task \
	    -limit 25 \
	    -defaultSortField task_due_dt \
	    -defaultSortDir DESC \
	    -store_fields {'id','task_title','task_description','task_due_dt','done_p'} \
	    -name_field_map {
		id id
		task_title task_title
		task_description task_description
		task_due_dt task_due_dt
		done_p done_p
	    }

	Toolbar tbar0 -appendFromScript {
	    Toolbar.Button new \
                -text "'Remove'" \
                -iconCls "'remove'"
	}


	PagingToolbar bbar0 \
	    -label "paging_toolbar_1" \
	    -store ds0 \
	    -pageSize 25 \
	    -displayMsg "'Showing items {0} - {1} of {2}'" \
	    -emptyMsg "'No tasks to display'" \
	    -style "'background:#DFE8F6;border:none;'"

	Template tpl0 -html {
	    {task_description}
	}

	xg.RowExpander expander -map tpl0 -tpl tpl0
	xg.CheckboxSelectionModel sm0
	xg.ColumnModel cm0 -map {sm0 expander booleanRenderer} -config {[
				     sm0,
				     expander,
				     {header: "ID", width: 160, sortable: true, dataIndex: 'id'},
				     {id:'task_title',header: "Title", width: 85, sortable: true, dataIndex: 'task_title'},
				     {header: "Done?", width: 85, renderer: booleanRenderer, sortable: true, dataIndex: 'done_p'}
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
	    -autoExpandColumn 'task_title' \
	    -autoHeight true \
	    -width "800" \
	    -style "'margin-left:auto;margin-right:auto;'" \
	    -title "'Tasks'"


    }
}