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




	JS.Function addTypeShowWinFn -map {{type_frm frm} {type_win w}} -argv {} -body {
	    frm.getForm().reset();
	    w.show();
        }

	JS.Function editTypeShowWinFn -map {{sm0 sm} {type_frm frm} {type_win w}} -argv {} -body {
	    var r = sm.getSelected();
	    frm.getForm().reset();
	    frm.getForm().loadRecord(r);
	    frm.getForm().setValues({op:'editType'});
	    w.show();
        }

	JS.Function storeTypeSuccessFn -map {{ds0 ds} {type_win w}} -argv {frm action} -body {
	    w.hide();
	    ds.load();
	}

	JS.Function storeTypeFailureFn -argv {frm action} -body {
	    Ext.Msg.alert('Status','Failed to add new type'+action.result);
	}


	Action action__bulkDeleteTypes -name bulkDeleteTypes -body {
	    ad_page_contract {
		@author Neophytos Demetriou
	    } {
		id:trim,notnull,multiple
	    }
	    
	    set o [::bboard::Message_Type new -mixin ::db::Object]
	    $o set id $id
	    $o beginTransaction
	    $o rdb.bulk-delete -pk id
	    $o endTransaction
	    ns_return 200 text/html [::util::map2json b:success true L:id $id]
	    return

        }

	JS.Function removeTypeFn_processResult -map {action__bulkDeleteTypes {sm0 sm} {ds0 ds}} -argv {buttonId text opt} -body {
	    if (buttonId == 'yes') {
		var sel = sm.getSelections();
		var selIDs=new Array();
		for (i=0; i < sel.length; i++) { selIDs[i] = sel[i].get('id'); }
		if (sel.length > 0) {
		    Ext.Ajax.request({
			method:'GET',
			url: action__bulkDeleteTypes,
			success: function(response,options) {
			    ds.load();
			},
			failure: function(response,options) {
			    Ext.Msg.alert('Status','Failed to remove selected types... Try again later:'+response.responseText);
			},
			params: { id: selIDs }
		    });
		}
	    } else {
		// do nothing
	    }
	}

	JS.Function removeTypeFn -map {removeTypeFn_processResult} -argv {} -body {
	    Ext.Msg.show({
		title:'Remove Types?',
		msg: 'You are removing types. Would you like to continue?',
		buttons: Ext.Msg.YESNOCANCEL,
		fn: removeTypeFn_processResult,
		icon: Ext.MessageBox.QUESTION
	    });
	}


	#-store_fields [$data get_js_fields] -data [$data get_js_array] 
	Tablet ds0 \
	    -root 'root' \
	    -remoteSort true \
	    -autoLoad true \
	    -select "id title creation_date" \
	    -type ::bboard::Message \
	    -limit 25 \
	    -defaultSortField creation_date \
	    -fields [util::list2json {id title creation_date}] \
	    -name_field_map {
		title title
		msg_type msg_type
		creation_date creation_date
	    }

	Toolbar tbar0 -appendFromScript {

	    Toolbar.Button new \
                -text "'Add Type'" \
		-iconCls 'add' \
		-map {addTypeShowWinFn} \
		-handler "addTypeShowWinFn"

	    Toolbar.Button new \
                -text "'Edit'" \
		-iconCls 'edit' \
		-map {editTypeShowWinFn} \
		-handler "editTypeShowWinFn"

	    Toolbar.Button new \
                -text "'Remove'" \
		-iconCls 'remove' \
		-map {removeTypeFn} \
		-handler "removeTypeFn"

	}


	PagingToolbar bbar0 \
	    -label "paging_toolbar_1" \
	    -store ds0 \
	    -pageSize 25 \
	    -displayMsg "'Showing items {0} - {1} of {2}'" \
	    -emptyMsg "'No items to display'" \
	    -style "'background:#DFE8F6;border:none;'"

	xg.CheckboxSelectionModel sm0 -singleSelect true
	xg.ColumnModel cm0 -map {sm0} -config {[
				     sm0,
				     {id:'msg_type',header: "Type", sortable: true, dataIndex: 'msg_type'},
				     {id:'title',header: "Title", width: 160, dataIndex: 'title'},
				     {id:'creation_date',header:'Date',dataIndex:'creation_date'}
				    ]}


	Window type_win \
	    -title "'Add Type'" \
	    -modal true \
	    -width 400 \
	    -height 250 \
	    -x 100 \
	    -y 50 \
	    -closeAction 'hide' \
	    -layout 'fit' \
	    -bodyStyle 'padding:5' \
	    -appendFromScript {

		Form type_frm \
		    -monitorValid true \
		    -monitorPoll 100 \
		    -labelWidth 175 \
		    -standardSubmit false \
                    -submitText "Save Type" \
		    -action store \
                    -map {storeTypeSuccessFn storeTypeFailureFn} \
                    -submitOptions [::util::map2json s:waitMsg "Saving type details..." fn:success storeTypeSuccessFn fn:failure storeTypeFailureFn n:timeout 120000] \
		    -appendFromScript {

			HiddenField new -name id
			HiddenField new -name op -value "addType"

			TextField new \
			    -name name \
			    -label "Type Name" \
			    -allowBlank false \
			    -width 250


			TextArea new \
			    -name description \
			    -label "Short Description" \
			    -allowBlank true \
			    -width 250 \
			    -height 75 

			TextField new \
			    -name hstore \
			    -label HStore \
			    -allowBlank true \
			    -width 250


		    }  -proc action(store) {marshaller} {
			ad_page_contract {
			    @author Neophytos Demetriou
			} {
			    id:integer
			    name:trim,notnull
			    description:trim
			    hstore:trim
			    op:trim,notnull
			}
			
			if { -1 == [lsearch {addType editType} ${op}] } {
			    ns_return 200 text/html [::util::map2json b:success false]
			    return
			}

			set o [::bboard::Message_Type new -mixin ::db::Object]
			$o set id $id
			$o set name $name
			$o set description $description
			# HERE: $o set hstore $hstore
			if { ${op} eq {addType} } {
			    $o do self-insert {select true;}
			} elseif { ${op} eq {editType} } {
			    $o do self-update
			}
			ns_return 200 text/html [::util::map2json b:success true]
			return
		    }
	    }






	#renderer: Ext.util.Format.dateRenderer('m/d/Y')
	GridPanel grid0 \
	    -map {ds0 tbar0 bbar0 sm0 cm0} \
	    -store ds0 \
	    -tbar tbar0 \
	    -bbar bbar0 \
	    -cm cm0 \
	    -autoExpandColumn 'title' \
	    -viewConfig '{forceFit:true}' \
	    -animCollapse false \
	    -sm sm0 \
	    -stripeRows true \
	    -autoHeight true \
	    -width "800" \
	    -style "'margin-left:auto;margin-right:auto;'" \
	    -title "'Message Types'"


    }
}
