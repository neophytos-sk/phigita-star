
#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/55-grid-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/65-DatePicker-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/70-tab-procs.tcl
#source [acs_root_dir]/packages/persistence/tcl/ZZ-tablet-procs.tcl




namespace inscope ::xo::ui {

    Page new -master ::xo::ui::DefaultMaster -title "Calendar" -appendFromScript {

	#StyleFile new -style_file [acs_root_dir]/packages/blogger/resources/css/combos.css
	StyleText new -inline_p yes -styleText {
	    .calendar_add {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/calendar_add.png) !important;}
	    .date_add {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/date_add.png) !important;}
	    .add {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/add.gif) !important;}
	    .option {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/plugin.gif) !important;}
	    .remove {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/delete.gif) !important;}
	    .done {background-image:url(http://www.phigita.net/lib/xo-1.0.0/shared/icons/fam/accept.png) !important;}
	    .task_title {font-weight:bold;}
	    .task_due_dt {color:green;}
	    .task_description {font-style:italic;}
	    .task-completed {color:gray;text-decoration:line-through;}
	}

	JS.Function onCheckHasDueDateFn -map {{task_due_dt dt} any_time_task_p} -argv {cb v} -body {
	    if (v) {
	      dt.enable();
		any_time_task_p.enable();
	    } else {
		any_time_task_p.disable();
		dt.disable();
	    }
	}

	JS.Function addEventFn -map {{event_add_win w}} -argv {} -body {
	    w.show()
	}

	JS.Function addTaskFn -map {{task_add_win w}} -argv {} -body {
	    w.show()
	}

	JS.Function addTaskSuccessFn -map {{task_add_win w} {tabToDo tab} {tp0 tp} {ds0 ds}} -argv {frm action} -body {
	    //alert(action.result);
	    w.hide();
	    //frm.reset();
	    //frm.clearInvalid();
	    tp.setActiveTab(tab);
	    ds.load();
	}

	JS.Function addTaskFailureFn -argv {frm action} -body {
	    alert('action failed: '+action.result);
	}

	JS.Function allDayCheckFn -map {{event_start_dt sdt} {event_end_dt edt}} -argv {cb checked} -body {
	    //alert('checked/unchecked? checked=' + checked);
	    if (checked) {
		sdt.tf.hide();
		edt.tf.hide();
		sdt.tf.allowBlank = true;
		edt.tf.allowBlank = true;
	    } else {
		sdt.tf.allowBlank = false;
		edt.tf.allowBlank = false;
		sdt.tf.show();
		edt.tf.show();
	    }
	}

	JS.Function anyTimeCheckFn -map {{task_due_dt dt}} -argv {cb checked} -body {
	    if (checked) {
		dt.tf.hide();
		dt.tf.allowBlank = true;
	    } else {
		dt.tf.allowBlank = false;
		dt.tf.show();
	    }
	}



        JS.Function taskUpdateFn -map {{sm0 sm} {ds0 ds}} -argv {theKey theValue} -body {
            var sel = sm.getSelections();
            var selIDs=new Array();
            for (i=0; i < sel.length; i++) { selIDs[i] = sel[i].get('id'); }
            if (sel.length > 0) {
                Ext.Ajax.request({
                    url: 'bulk-update',
                    success: function(response,options) {
                        ds.load();
                    },
                    failure: function(response,options) {
                        Ext.Msg.alert('Status','Action Failed:'+response.responseText);
                    },
                    params: { id: selIDs, key: theKey, value:theValue}
                });
            }
        }
	
        JS.Function taskDoneFn -map {{taskUpdateFn u}} -body {
            u('done_p','t');
        }

        JS.Function taskRemoveFn -body {
	    alert('remove not implemented yet');
        }


	JS.Function booleanRenderer -argv {v} -body {
            return v=='t' ? 'Yes' : 'No';
        }
	JS.Function expandRenderer -argv {v p r} -body {
	    if (r.data['task_description'] != '') { 
		p.cellAttr = 'rowspan="2"';
		return '<div class="x-grid3-row-expander">&\#160;</div>';
	    } else {
		return;
	    }
	}

	JS.Function doneRenderer -argv {v p r} -body {
	    if (r.data['done_p']=='t') {
		return '<div class="task-completed">'+v+'</div>';
	    } else {
		return v;
	    }
	}

	JS.Function dueRenderer -map {doneRenderer} -argv {v p r} -body {
	    if (r.data['has_due_dt_p']=='t') {
		dt = new Date();
		nowYear = dt.getFullYear();
		try {
		    dt = Date.parseDate(v,"Y-m-d H:i:s");
		    if (r.data['any_time_task_p']=='t') {
			result = nowYear==dt.getFullYear() ? dt.format('M j') : dt.format('M j, Y');
		    } else {
			result = nowYear==dt.getFullYear() ? dt.format('g:ia - M j') : dt.format('g:ia - M j, Y');
		    }
		} catch (ex) {
		    result = v;
		}
	    } else {
		result = 'no due date';
	    }
	    return doneRenderer(result,p,r);
	}

	set user_id [ad_conn user_id]
	set pathexp [list "User $user_id"]

	#-store_fields [$data get_js_fields] -data [$data get_js_array] 
	set pathexp [list "User ${user_id}"]
	lg.Tablet ds0 \
	    -pathexp $pathexp \
	    -root 'items' \
	    -remoteSort true \
	    -autoLoad true \
	    -type ::calendar::Task \
	    -defaultLimit 100 \
	    -limit 100 \
	    -bufferSize 300 \
	    -defaultSortField task_due_dt \
	    -defaultSortDir DESC \
	    -select {id task_title task_description {to_char(task_due_dt,'YYYY-mm-dd HH24:MI:SS') as task_due_dt} done_p creation_date has_due_dt_p any_time_task_p} \
	    -fields [util::list2json {id task_title task_description task_due_dt done_p creation_date has_due_dt_p any_time_task_p}] \
	    -name_field_map {
		id id
		task_title task_title
		task_description task_description
		task_due_dt task_due_dt
		done_p done_p
		creation_date creation_date
	    }
	#where [list "CURRENT_TIMESTAMP < task_due_dt"]

	lg.GridView gv0 -nearLimit 100 -forceFit true -loadMask {{
                msg : 'Please wait...'
	}}

	lg.Toolbar bbar0 -map gv0 -view gv0 -displayInfo true -appendFromScript {
	    Toolbar.Button new \
                -text "'Done'" \
                -iconCls "'done'" \
		-map {taskDoneFn} \
		-handler {taskDoneFn} 

	    Toolbar.Button new \
                -text "'Remove'" \
                -iconCls "'remove'" \
		-map {taskRemoveFn} \
		-handler {taskRemoveFn}
	}


	Template tpl0 -html {
	    {task_description}
	}

	xg.RowExpander expander -map {tpl0 expandRenderer} -tpl tpl0 -renderer expandRenderer
	xg.CheckboxSelectionModel sm0
	xg.ColumnModel cm0 -map {sm0 expander booleanRenderer dueRenderer doneRenderer} -config {[
				     expander,
				     {id:'cm0_title',header: "Task", renderer:doneRenderer, width: 150, sortable: true, dataIndex: 'task_title'},
				     {header: "Due", width: 75, renderer:dueRenderer, sortable: true, dataIndex: 'task_due_dt',align:'right'}
				    ]}



	Toolbar tb0 -style "'background:\#dfe8f6;'" -appendFromScript {

	    Toolbar.Button new \
		-text "'Add Event'" \
		-iconCls "'calendar_add'" \
		-map {addEventFn} \
		-handler addEventFn

	    Toolbar.Button new \
		-text "'Add Task'" \
		-iconCls "'date_add'" \
		-map {addTaskFn} \
		-handler addTaskFn
	}


	Window event_add_win \
            -title "'Add Event'" \
            -modal true \
            -width 550 \
            -height 325 \
            -x 100 \
            -y 65 \
            -closeAction 'hide' \
            -layout 'fit' \
            -bodyStyle 'padding:5' \
            -appendFromScript {

		Form new \
		    -style "margin:5px;" \
		    -labelAlign 'top' \
                    -standardSubmit false \
		    -submitText "Save" \
                    -appendFromScript {
			
			TextField new \
			    -name event_name \
			    -label "What" \
			    -hideLabel true \
			    -allowBlank false \
			    -width 510
			
			Panel new -layout column -autoHeight true -appendFromScript {			
			    Panel new -autoHeight true -appendFromScript {
				DateTimeField event_start_dt \
				    -name event_start_dt \
				    -label "Start Date" \
				    -timeFormat 'H:i' \
				    -timeConfig [list s:altFormats {g:i a|h:i:s A|H:i:s} b:allowBlank false] \
				    -dateFormat 'Y-m-d' \
				    -dateConfig [list s:altFormats {j F Y|j M Y|d M Y|F d, Y|M j, Y|F j, Y|d-M-Y|dMY|MdY|YMd|j-M-Y|jMY|MjY|YMj|j/n/Y|j.n.Y|Y-n-j|d/n/Y|d.n.Y|Y-n-d} b:allowBlank false]
			    }
			    Panel new -autoHeight true -style "'padding-left:5px;'" -appendFromScript {
				DateTimeField event_end_dt \
				    -name event_end_dt \
				    -label "End Date" \
				    -timeFormat 'H:i' \
				    -timeConfig [list s:altFormats {g:i a|h:i:s A|H:i:s} b:allowBlank false] \
				    -dateFormat 'Y-m-d' \
				    -dateConfig [list s:altFormats {j F Y|j M Y|d M Y|F d, Y|M j, Y|F j, Y|d-M-Y|dMY|MdY|YMd|j-M-Y|jMY|MjY|YMj|j/n/Y|j.n.Y|Y-n-j|d/n/Y|d.n.Y|Y-n-d} b:allowBlank false]
			    }
			    Panel new -autoWidth true -autoHeight true -style "'padding-left:5px;padding-top:15px;'" -appendFromScript {
				CheckboxGroup new -value f -appendFromScript {
				    Checkbox new \
					-name all_day_event_p \
					-value t \
					-hideLabel true \
					-label "All day" \
					-map {
					    allDayCheckFn
					} -listeners {
					    check allDayCheckFn
					}
				}
			    }
			}


			TextField new \
			    -name event_place \
			    -label "Where" \
			    -allowBlank true \
			    -width 510
			
			
			TextArea new -name event_description -label "Note" -width 510 -height 75 -allowBlank true
		    }

	    }

	Window task_add_win \
            -title "'Add Task (To-Do)'" \
            -modal true \
            -width 325 \
            -height 325 \
            -x 150 \
            -y 65 \
            -closeAction 'hide' \
            -layout 'fit' \
            -bodyStyle 'padding:5' \
            -appendFromScript {

		Form new \
		    -style "margin:5px;" \
		    -action addTask \
                    -monitorValid true \
                    -monitorPoll 100 \
		    -labelAlign 'top' \
                    -standardSubmit false \
		    -submitText "Save Task" \
		    -map {addTaskSuccessFn addTaskFailureFn} \
		    -submitOptions "{waitMsg:'Saving task details',success:addTaskSuccessFn,failure:addTaskFailureFn,timeout:1500}" \
                    -appendFromScript {
			
			TextField new \
			    -name task_title \
			    -label "Title" \
			    -hideLabel true \
			    -allowBlank false \
			    -width 285

			RadioGroup new -label "Due" -name has_due_dt_p -value "t" -appendFromScript {
			    Panel new -layout column -autoHeight true -appendFromScript {
				Panel new -autoHeight true -appendFromScript {
				    Radio new -value t -map {onCheckHasDueDateFn} -listeners {check onCheckHasDueDateFn}
				}
				Panel new -autoHeight true -style "'padding-left:5px;'" -appendFromScript {
				    DateTimeField task_due_dt \
					-name task_due_dt \
					-label "Due" \
					-allowBlank true \
					-hideLabel true \
					-timeFormat 'H:i' \
					-timeConfig [list s:altFormats {g:i a|h:i:s A|H:i:s} b:allowBlank false] \
					-dateFormat 'Y-m-d' \
					-dateConfig [list s:altFormats {j F Y|j M Y|d M Y|F d, Y|M j, Y|F j, Y|d-M-Y|dMY|MdY|YMd|j-M-Y|jMY|MjY|YMj|j/n/Y|j.n.Y|Y-n-j|d/n/Y|d.n.Y|Y-n-d} b:allowBlank false]
				}
				Panel new -autoWidth true -autoHeight true -style "'padding-left:5px;'" -appendFromScript {
				    CheckboxGroup new -value f -appendFromScript {
					Checkbox any_time_task_p \
					    -name any_time_task_p \
					    -value t \
					    -hideLabel true \
					    -label "Any time" \
					    -map {
						anyTimeCheckFn
					    } -listeners {
						check anyTimeCheckFn
					    }
				    }
				}
			    }
			    Radio new -value f -label "No due date" 
			}
			TextArea new -name event_description -label "Note" -width 285 -height 75 -allowBlank true
		    } -proc action(addTask) {marshaller} {
			if { [my isValid] } {
			    set mydict [my getDict]

			    set user_id [ad_conn user_id]
			    set peeraddr [ad_conn peeraddr]

			    set task_title [dict get $mydict task_title]
			    set task_description [dict get $mydict event_description]
			    set has_due_dt_p [dict get $mydict has_due_dt_p]
			    set any_time_task_p [::util::coalesce [dict get $mydict any_time_task_p] f]
			    if { $has_due_dt_p } {
				set task_due_dt [dict get $mydict task_due_dt]
			    } else {
				set task_due_dt ""
			    }
			    #set folder_id [dict get $folder_id]
			    set folder_id ""

			    set tmplist ""
			    foreach varName {task_title task_description} {
				lappend tmplist [::ttext::trigrams [string tolower [::ttext::unac utf-8 [::ttext::ts_clean_text [set $varName]]]]]
			    }
			    set ts_vector [join [::xo::fun::map x [join $tmplist] { string map {{'} {\'} {"} {\"} \\ \\\\ { } {\ } {,} {\,}} $x }]]


                            set pathexp [list "User $user_id"]
	                    set o [::calendar::Task new -mixin ::db::Object -pathexp $pathexp]
			    $o beginTransaction
			    $o rdb.self-id
			    set event_id [$o set id]
			    
			    $o set task_title $task_title
			    $o set task_due_dt $task_due_dt
			    $o set has_due_dt_p $has_due_dt_p
			    $o set task_description $task_description
			    $o set any_time_task_p $any_time_task_p
			    $o set done_p f
			    $o set ts_vector $ts_vector
			    $o set folder_id $folder_id

			    $o set creation_user        $user_id
			    $o set creation_ip          $peeraddr
			    $o set modifying_user       $user_id
			    $o set modifying_ip         $peeraddr

			    $o rdb.self-insert
			    $o endTransaction
                            ns_return 200 text/plain OK
                            return
			} else {
			    foreach o [my getFields] {
				$o set value [$o getRawValue]
				if { ![$o isValid] } {
				    $o markInvalid "Failed Validation"
ns_log notice "failed validation $o [$o info class] [$o getRawValue]"
				}
			    }
                            ns_return 200 text/plain NOT_OK
                            return

			    $marshaller go -select "" -action draw
	    
			    #doc_return 200 text/plain [my getDict]
			    #doc_return 200 text/plain "Incomplete or Invalid Form"
			}

		    }

	    }



	Panel new -layout border -height 450 -appendFromScript {


	    Panel new -region west -tbar tb0 -autoWidth true -appendFromScript {
		DatePicker new 
		#-style "'margin:1px;'"
	    } -margins "5 5 10 10"

	    TabPanel tp0 -appendFromScript {
		Panel new -title "'Day'" -appendFromScript {}
		Panel new -title "'Week'" -appendFromScript {}
		Panel new -title "'Month'" -appendFromScript {}
		Panel new -title "'4 Days'" -appendFromScript {}
		Panel new -title "'Agenda'" -appendFromScript {}

	    } -region center -activeTab 3 -plain true -margins "5 10 10 5" -border true

Panel new -region east -width 300 -height 350 -appendFromScript {

		lg.GridPanel tabToDo \
		    -title "'Tasks: To-Do'" \
		    -map {ds0 gv0 cm0 sm0 bbar0 expander} \
		    -store ds0 \
		    -view gv0 \
		    -cm cm0 \
		    -selModel sm0 \
		    -animCollapse false \
		    -autoExpandColumn 'cm0_title' \
		    -height 350 \
		    -border false \
		    -bbar bbar0 \
		    -plugins expander

}
	}
    }
}