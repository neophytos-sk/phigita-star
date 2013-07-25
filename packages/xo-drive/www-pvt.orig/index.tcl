
#source [acs_root_dir]/packages/kernel/tcl/20-templating/00-renderingvisitor-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/10-ui-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/20-template-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/27-style-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/28-script-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/28-js-fun-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/29-hypertext-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/30-form-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/32-datastore-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/34-dataview-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/36-dragdrop-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/40-panel-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/41-viewport-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/55-grid-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/70-tab-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/75-toolbar-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/80-menu-procs.tcl
#source [acs_root_dir]/packages/kernel/tcl/20-templating/90-tree-procs.tcl


namespace path ::xo::ui

    
Page new -master ::xo::ui::DefaultMaster -title "MediaBox" -appendFromScript {

	StyleFile new -style_file [acs_root_dir]/packages/xo-drive/resources/css/organizer.css
	StyleFile new -style_file [acs_root_dir]/packages/blogger/resources/css/combos.css
	StyleText new -inline_p yes -styleText {
	    .x-form-check-wrap {float:left;margin-left:4;}
	}

	JS.Function shortName -argv {name} -body {
	    if(name.length > 15){
		return name.substr(0, 12) + '...';
	    }
	    return name;
	}

	JS.Function tagsToTextFn -argv {tags} -body {
	    result='';
	    L=tags.length;
	    for (i=0;i<L;i++) {
	       result +=tags[i].name;
	       if (i<L-1) result+=', ';
	    }
	    return result;
	}

	JS.Function convertTags -argv {tags} -body {
	    result='';
	    L=tags.length;
	    for(i=0;i<L;i++) {
			      if (tags[i].bgcolor=='') {tags[i].bgcolor='F1F5EC';tags[i].fontcolor='006633';}
	      result += '<div class="z-itm-wrap"><span class="z-itm"><b style="border-color:#'+tags[i].bgcolor+';background-color:#'+tags[i].bgcolor+';"><b style="border-color:#'+tags[i].bgcolor+';"><b style="color:#'+tags[i].fontcolor+';">'+ tags[i].name+'</b></b></b></span></div>';
	    }
	    return result;
	}


	JS.Function getPartUrl -map {{view1 v} sf} -argv {part_index} -body {
	    var result = 'one-view/'+v.store.baseParams['id']+'/?size=500&p='+part_index;
	    var query = sf.store.baseParams[sf.paramName];
	    if (typeof query !== 'undefined' && query != '') {
		result += '&q='+query;
	    }
	    return result;

	}

	JS.Function updateFn -map {root_of_folders {tl1 tl}} -argv {field_name field_value view} -body {
	    selIDs=new Array();
	    for (i=0; i < view.sel.length; i++) { selIDs[i] = view.sel[i].get('id'); }
	     Ext.Ajax.request({
		url: 'bulk-update',
		success: function(response,options) {
		    view.store.reload({callback:function(){view.select(options.params.id);}});
		    tl.load(root_of_folders);
		    root_of_folders.expand();
		},
		failure: function(response,options) {
		    Ext.Msg.alert('Status','Failed to delete file'+response.responseText);
		},
		 params: { id: selIDs, key: field_name, value:field_value }
	    })
	}

	JS.Function removeFolderFn -map {{tree0 tree} {selectFolderFn sfFn} {root_of_folders roaf}} -argv {node} -body {
	     Ext.Ajax.request({
		url: 'label-remove',
		success: function(response,options) {
		    if (node==tree.getSelectionModel().getSelectedNode()) {
			roaf.firstChild.select();
		    }
		    sfFn(roaf.firstChild);
		    node.parentNode.removeChild(node);
		    Ext.destroy(node);
		},
		failure: function(response,options) {
		    Ext.Msg.alert('Status','Failed to remove folder'+response.responseText);
		},
		 params: { id: node.attributes.label_id }
	    })
	}

	JS.Function selectFolderFn -map {{ds0 storeToFilter} {tp1 tabPanel}} -argv {node e} -body {
	    tree = node.getOwnerTree();

	    attributeName=node.attributes.attributeName;
	    attributeValue=node.attributes[attributeName];

	    tabPanel.setActiveTab(0);

	    storeToFilter.baseParams['label_id'] = null;
	    storeToFilter.baseParams['starred_p'] = null;
	    storeToFilter.baseParams['hidden_p'] = null;
	    storeToFilter.baseParams['deleted_p'] = null;
	    storeToFilter.baseParams['shared_p'] = null;
	    if (typeof attributeName !== 'undefined') {
		storeToFilter.baseParams[attributeName] = attributeValue;
	    }
	    storeToFilter.load({start:0});
	}

        JS.Function changeButtonFn -map {{ds0 storeToFilter} {tb2 ptb}} -argv {sb item} -body {
            v_filetype = item.value;
            if (storeToFilter.baseParams['filetype'] != v_filetype) {
                storeToFilter.baseParams['filetype'] = v_filetype;
                //storeToFilter.baseParams['x_offset'] = 0;
                storeToFilter.load({x_offset:0});
		//ptb.changePage(0);
            }
            return true;
        }


	JS.Function uploadFileFn -map {{upload_form frm} {upload_file_win w}} -body {
	    w.show();
	    frm.getForm().reset();
	}

	JS.Function oldUploadFileFn -body {
	    top.location.href='file-upload';
	}

	JS.Function refreshPropertyGridFn -map {grid0} -argv {r options success} -body {
	    if (success) {
		grid0.setSource(r[0].get('extra'));
	    } else {
		Ext.Msg.alert('Problem loading data','Please try again in a while.');
	    }
	}

	JS.Function clickItemFn -map {{view2 v2} ds1 ds2 sf refreshPropertyGridFn} -argv {v0 index node e} -body {

	    var query=v0.store.baseParams[sf.paramName];
	    if (ds1.baseParams['id']!=node.id || query != ds2.baseParams['q']) {
		ds1.baseParams['id']=node.id;
		ds2.baseParams['q']=query;

		ds1.load({callback:refreshPropertyGridFn});

		v2.hide();
		if (typeof query !== 'undefined' && query != '') {
		    ds2.baseParams['item_id']=node.id;
		    ds2.baseParams['q']=v0.store.baseParams[sf.paramName];
		    ds2.reload();
		    v2.show();
		}
	    }
	}


	JS.Function openFileFn -map {sf} -argv {view index node e} -body {
	    e.stopEvent();
	    data = view.store.getAt(index);
	    tp = eval(view.__xo__.tabPanel);
	    var q = sf.store.baseParams[sf.paramName];
	    q = q?q:'';

	    p=tp.add(new Ext.Panel({title:data.get('shortName'),html:'<iframe width="100%" height="100%" src="one-view/'+node.id+'/?size=500&q='+q+'" />',closable:true,autoScroll:true,iconCls:'z-ft-'+data.get('filetype')}));
	    tp.setActiveTab(p);
	}


	JS.Function onContextMenu -argv {e} -body {
	    var item = e.getTarget(this.itemSelector, this.el);
	    if(item){
		this.fireEvent("contextmenu", this, this.indexOf(item), item, e);
	    } else {
		if(this.fireEvent("containercontextmenu", this, e) !== false){
		    this.clearSelections();
		}
	    }
	}

	JS.Function folderContextMenuFn -map {ge removeFolderFn color_menu_tpl {view0 view} {tl1 tl} root_of_folders} -needs "XO.Menu" -argv {node e} -body {
	    e.stopEvent();
	    tree = node.getOwnerTree();
	    if (!tree._fcm) {

		Sw="CC0000",uEa="DEE5F2",vEa="E0ECFF",wEa="DFE2FF",xEa="E0D5F9",yEa="FDE9F4",zEa="FFE3E3",AEa="FFF0E1",BEa="FADCB3",CEa="F3E7B3",DEa="FFFFF4",EEa="F9FFEF",FEa="F1F5EC";
		GEa="5A6986",HEa="206CFF",IEa="0000CC",JEa="5229A3",KEa="854F61",LEa="EC7000",MEa="B36D00",NEa="AB8B00",OEa="636330",PEa="64992C",QEa="006633";
		BASE_COLORS=[uEa,vEa,wEa,xEa,yEa,zEa,GEa,HEa,IEa,JEa,KEa,Sw,AEa,BEa,CEa,DEa,EEa,FEa,LEa,MEa,NEa,OEa,PEa,QEa];
		L = BASE_COLORS.length;
		COLORS=new Array();
		for (i=0;i<L;i++) {
				   COLORS[i]={bgcolor:BASE_COLORS[i],fontcolor:BASE_COLORS[(i+6) % L]};
		}

		tree._colormenu = new Ext.menu.ColorMenu({
		    /*value: 'F5F5DC',*/
		    tpl: color_menu_tpl,
		    itemCls: 'z-color-palette',
		    allowReselect: true,
		    selectHandler: function(colorpicker,bgcolor){
			Ext.Ajax.request({
			    url: 'label-color-change',
			    success: function(response,options) {
				//alert('Color Selected. You chose: ' + options.params.bgcolor);
				view.store.reload();
				tl.load(root_of_folders);
				root_of_folders.expand();
			    },
			    failure: function(response,options) {
				Ext.Msg.alert('Status','Failed to change color '+response.responseText);
			    },
			    params: { 'id': tree.ctxNode.attributes.label_id, 'bgcolor': bgcolor }
			});
		    },
		    colors: COLORS
		});
		tree._fcm = new Ext.menu.Menu([{
                    id: tree.id + '-remove',
                    text: 'Remove folder',
		    iconCls:'z-folder-remove',
                    handler: function(){removeFolderFn(tree.ctxNode);}
                },{
                    id: tree.id + '-rename',
                    text: 'Rename folder',
		    iconCls:'z-menu-rename',
                    handler: function(){ge.triggerEdit(tree.ctxNode);}
                }, {
		    text: 'Change color',
		    menu: tree._colormenu

		}]);
	    }
	    tree.ctxNode = node;
	    if (node.attributes.label_id >0) {
		tree._fcm.showAt(e.getPoint());
	    }
	}

	set COMMENT {

	    {text: 'View', menu: {items:[
					 {text:'Thumbnails',checked:true,group:'views-field'},
					 {text:'Tiles',checked:false,group:'views-field'},
					 {text:'Details',checked:false,group:'views-field'}]}},
	    '-',
	    {text: 'Sort By', menu: { items: [
					      {text: 'Name', checked: false, group: "sort-field", handler: function(){ this.filesView.setSortField('name'); }},
					      {text: 'Size', checked: true, group: "sort-field", handler: function(){ this.filesView.setSortField('size'); }},
					      {text: 'Type', checked: false, group: "sort-field", handler: function(){ this.filesView.setSortField('type'); }},
					      {text: 'Modified', checked: false, group: "sort-field", handler: function(){ this.filesView.setSortField('dateModified'); }}
					     ]}},
	    {text: 'Sort Ascending', icon: mibp + 'sort-asc.gif', handler: function(){ this.filesView.setSortDirection('asc'); }},
	    {text: 'Sort Descending', icon: mibp + 'sort-desc.gif', handler: function(){ this.filesView.setSortDirection('desc'); }}
	}

	JS.Function ctContextMenuFn -needs "XO.Menu XO.MessageBox XO.MenuExtra" -argv {view e} -body {
	    e.stopEvent();
	    if(!view._ccm){ // create context menu on first right click
		mibp = "http://www.phigita.net/lib/xo-1.0.0/resources/images/menu/";
		view._ccm = new Ext.menu.Menu([{
                    id: view.id + '-upload',
                    text: 'Upload',
                    iconCls: 'z-upload-menu',
		    handler: function() { top.location.href='file-upload'; }
		}]);
	    }
	    view._ccm.showAt(e.getPoint());
	    return true;
	}

	JS.Function itemContextMenuFn -map {updateFn tagsToTextFn root_of_folders {tl1 tl}} -needs "XO.Menu XO.MessageBox" -argv {view index item e} -body {
	    view.sel = view.getSelectedRecords();
	    if ( view.sel.indexOf(view.getRecord(item)) == -1 ) {
		view.select(item);
		view.sel = view.getSelectedRecords();
	    }
	    e.stopEvent();
	    if(!view.menu) {
		view.menu = new Ext.menu.Menu([{
		    id: view.id + '-open',
		    text: 'Open',
		    handler: function() {
			r = view.getRecord(view.ctxItem);
			tp = eval(view.__xo__.tabPanel);
			p=tp.add(new Ext.Panel({title:r.get('shortName'),html:'<iframe width="100%" height="100%" src="one-view/'+r.get('id')+'/?size=500" />',closable:true,autoScroll:true,iconCls:'z-ft-'+r.get('filetype')}));
			tp.setActiveTab(p);
		    }
		},{
		    id: view.id + '-download',
		    text: 'Download',
		    iconCls: 'z-download-menu',
		    handler: function() { 
			r = view.getRecord(view.ctxItem);
			window.location = 'download/' + r.get('id') + '/' + r.get('id') + '_' + r.get('title') + '.' + r.get('magic');
		    }
		},'-',
					       {id: view.id + '-publish', text: 'Publish',iconCls: 'z-publish-menu',handler:function(){ updateFn('shared_p','t',view) }},
					       {id: view.id + '-unpublish', text: 'Unpublish',iconCls: 'z-unpublish-menu',handler:function(){ updateFn('shared_p','f',view) }},
					       {id: view.id + '-star', text: 'Star',iconCls: 'z-star-menu',handler:function(){ updateFn('starred_p','t',view) }},
					       {id: view.id + '-unstar', text: 'Unstar',iconCls: 'z-unstar-menu',handler:function(){ updateFn('starred_p','f',view) }},
					       {id: view.id + '-hide', text: 'Hide',iconCls: 'z-hide-menu', handler:function(){ updateFn('hidden_p','t',view) }},
					       {id: view.id + '-unhide', text: 'Unhide',iconCls: 'z-unhide-menu',handler:function(){ updateFn('hidden_p','f',view) }},
					       {id: view.id + '-delete', text: 'Delete',iconCls: 'z-delete-menu',handler:function(){ updateFn('deleted_p','t',view) }},
					       {id: view.id + '-undelete', text: 'Undelete',iconCls: 'z-undelete-menu',handler:function(){ updateFn('deleted_p','f',view) }},
		{
		    id: view.id + '-permanent-delete',
		    text: 'Permanent Delete',
		    iconCls: 'z-permanent-delete-menu',
		    handler : function(){
			Ext.Msg.show({
			    title:'Delete File?',
			    msg: 'You are deleting a file. Are you sure you want to continue?',
			    buttons: Ext.Msg.YESNOCANCEL,
			    fn: function(btn,text) {
				if ( btn == 'yes' ) {
				    Ext.Ajax.request({
					url: 'one-delete',
					success: function(response,options) {
					    view.store.reload();
					},
					failure: function(response,options) {
					    Ext.Msg.alert('Status','Failed to delete file'+response.responseText);
					},
					params: { id: view.ctxItem.id }
				    })
				}
			    },
			    animEl: view.ctxItem.id,
			    icon: Ext.MessageBox.WARNING
			});
		    }
		},{
		    id: view.id + '-rename',
		    text: 'Rename',
		    iconCls: 'z-menu-rename',
		    handler : function(){

			Ext.Msg.show({
			    title:'Rename File',
			    msg: 'Please enter file name:',
			    buttons: Ext.Msg.OKCANCEL,
			    prompt:true,
			    width:250,
			    value:view.getRecord(view.ctxItem).get('title'),
			    fn: function(btn,text) {
				if ( btn == 'ok' ) {
				    Ext.Ajax.request({
					url: 'one-rename',
					success: function(response,options) {
					    view.store.reload();
					},
					failure: function(response,options) {
					    Ext.Msg.alert('Status','Failed to rename file'+response.responseText);
					},
					params: { id: view.ctxItem.id, name:text }
				    })
				}
			    },
			    animEl: view.ctxItem.id,
			    icon: Ext.MessageBox.QUESTION
			});

		    }
		},'-',{
		    id: view.id + '-tag-edit',
		    text: 'Tags',
		    iconCls: 'z-tag-edit-menu',
		    handler : function(){

			Ext.Msg.show({
			    title:'Tags',
			    msg: 'Please enter tags (separated by comma):',
			    buttons: Ext.Msg.OKCANCEL,
			    prompt:true,
			    width:350,
			    value:tagsToTextFn(view.getRecord(view.ctxItem).get('tags')),
			    fn: function(btn,text) {
				if ( btn == 'ok' ) {
				    Ext.Ajax.request({
					url: 'tags-edit',
					success: function(response,options) {
					    //view.refreshNode(view.indexOf(view.ctxItem));
					    //view.refresh();
					    view.store.reload();
					    // HERE: reload & expand if new tags were created (get result from one-tag)
					    tl.load(root_of_folders);
					    root_of_folders.expand();
					},
					failure: function(response,options) {
					    Ext.Msg.alert('Status','Failed to update tags '+response.responseText);
					},
					params: { id: view.ctxItem.id, tags:text }
				    })
				}
			    },
			    animEl: view.ctxItem.id
			});

		    }
		}]);
	    }
	    view.ctxItem = item;
	    r = view.getRecord(item);

	    if (r.get('shared_p')=='t') {
		view.menu.items.get(view.id+'-publish').hide();
		view.menu.items.get(view.id+'-unpublish').show();
	    } else {
		view.menu.items.get(view.id+'-publish').show();
		view.menu.items.get(view.id+'-unpublish').hide();
	    }
	    if (r.get('starred_p')=='t') {
		view.menu.items.get(view.id+'-star').hide();
		view.menu.items.get(view.id+'-unstar').show();
	    } else {
		view.menu.items.get(view.id+'-star').show();
		view.menu.items.get(view.id+'-unstar').hide();
	    }
	    if (r.get('hidden_p')=='t') {
		view.menu.items.get(view.id+'-hide').hide();
		view.menu.items.get(view.id+'-unhide').show();
	    } else {
		view.menu.items.get(view.id+'-hide').show();
		view.menu.items.get(view.id+'-unhide').hide();
	    }
	    if (r.get('deleted_p')=='t') {
		view.menu.items.get(view.id+'-delete').hide();
		view.menu.items.get(view.id+'-undelete').show();
	    } else {
		view.menu.items.get(view.id+'-delete').show();
		view.menu.items.get(view.id+'-undelete').hide();
	    }

	    // if folder is the recycle bin
	    if (view.store.baseParams['deleted_p']=='t') {
		view.menu.items.get(view.id+'-permanent-delete').show();
		view.menu.items.get(view.id+'-publish').hide();
		view.menu.items.get(view.id+'-hide').hide();
		view.menu.items.get(view.id+'-unpublish').hide();
		view.menu.items.get(view.id+'-unhide').hide();
	    } else {
		view.menu.items.get(view.id+'-permanent-delete').hide();
	    }

	    ft = r.get('filetype');
	    if ( ft == 'audio' || ft=='video' || ft=='database' ) {
		//view.menu.items.get(view.id+'-publish').disable();
	    } else {
		//view.menu.items.get(view.id+'-publish').enable();
	    }

	    if (view.sel.length>1) {
		//view.menu.items.get(view.id+'-publish').disable();
		//view.menu.items.get(view.id+'-unpublish').disable();
		view.menu.items.get(view.id+'-open').disable();
		view.menu.items.get(view.id+'-download').disable();
		view.menu.items.get(view.id+'-rename').disable();
	    } else {
		//view.menu.items.get(view.id+'-publish').enable();
		//view.menu.items.get(view.id+'-unpublish').enable();
		view.menu.items.get(view.id+'-open').enable();
		view.menu.items.get(view.id+'-download').enable();
		view.menu.items.get(view.id+'-rename').enable();
	    }

	    view.menu.showAt(e.getPoint());
	}

	JS.Function renameFolderFn -map {{root_of_folders node} {sorter0 ts} {view0 view} ge} -argv {field newValue oldValue} -body { 

	    // ge.editNode.attributes.label_id OR this.editNode.attributes.label_id
	    
	    Ext.Ajax.request({
		url: 'label-rename',
		success: function(response,options) {
		    view.store.reload();
		    ts.doSort(node);
		},
		failure: function(response,options) {
		    Ext.Msg.alert('Status','Failed to rename file'+response.responseText);
		},
		params: { "id":ge.editNode.attributes.label_id, "newValue":newValue,"oldValue":oldValue}
	    })
	}
	

	JS.Function newFolderSuccessFn -map {root_of_folders tree0 ge} -argv {response options} -body {
	    var node = root_of_folders.appendChild(new Ext.tree.TreeNode({
		text: Ext.decode(response.responseText).name,
		label_id:Ext.decode(response.responseText).id,
		attributeName:'label_id',
		cls:'z-folder',
		allowDrag:false
	    }));
	    //tree0.getSelectionModel().select(node);
	    setTimeout(function(){
		ge.editNode = node;
		ge.startEdit(node.ui.textNode);
	    }, 10);
	}

	JS.Function newFolderFn -map {{newFolderSuccessFn successFn}} -argv {baseitem e} -body {

	    // todo: baseitem.__xo__.prefix, etc
	    Ext.Ajax.request({
		requestMethod:'POST',
		url: 'label-create',
		success: successFn,
		failure: function(response,options) {
		    Ext.Msg.alert('Status','Failed to create folder'+response.responseText);
		},
		params: { prefix:'Folder'}
	    });
	}

	# -map {{root_of_allitems node}}
	JS.Function selectInitFolderFn -argv {node} -body {
	    node.select();
	    //alert(tree0);
	    //alert(node);
	    //tree0.getSelectionModel().select(node);
	}

	JS.Function beforenodedropFn -map {updateFn root_of_allitems} -argv {dropEvent} -body {
	    target=dropEvent.target;
	    source=dropEvent.source;
	    view=source.view;
	    view.sel=view.getRecords(dropEvent.data.nodes);
	    tree=target.getOwnerTree();
	    node=tree.getSelectionModel().getSelectedNode();
	    if (typeof node !== 'undefined') {
		sourceAttributeName=node.attributes.attributeName;
		sourceAttributeValue=node.attributes[sourceAttributeName];
	    } else {
		sourceAttributeName='';
		sourceAttributeValue='';
	    }
	    targetAttributeName = target.attributes.attributeName;
	    targetAttributeValue = target.attributes[targetAttributeName];

	    if ( sourceAttributeName !== 'label_id' && typeof sourceAttributeName !== 'undefined' && (target==root_of_allitems || (typeof targetAttributeName !== 'undefined' && targetAttributeName !== 'starred_p' && targetAttributeName!=='label_id'))) {
		var q_msg, q_msg_info;
		if (sourceAttributeName=='starred_p') {q_msg='Unstar';q_msg_info='unstarring';sourceAttributeValue='f'}
		if (sourceAttributeName=='hidden_p') {q_msg='Unhide';q_msg_info='unhiding';sourceAttributeValue='f';}
		if (sourceAttributeName=='deleted_p') {q_msg='Undelete';q_msg_info='undeleting';sourceAttributeValue='f';}
		if (sourceAttributeName=='shared_p') {q_msg='Unpublish';q_msg_info='unpublishing';sourceAttributeValue='f';}

		if (targetAttributeName=='hidden_p') { q_msg+= ' & Hide'; }
		if (targetAttributeName=='deleted_p') { q_msg+= ' & Delete'; }
		if (targetAttributeName=='shared_p') { q_msg+= ' & Publish'; }

		if (typeof q_msg !== 'undefined') {
		    var q_object = view.sel.length > 1 ? 'selection' : 'file';
		    Ext.Msg.show({
			title:q_msg + ' ' + q_object + '?',
			msg: 'You are about to ' + q_msg + ' a ' + q_object + '. Are you sure you want to continue?',
			buttons: Ext.Msg.YESNOCANCEL,
			fn: function(btn,text) {
			    if ( btn == 'yes' ) {
				updateFn(sourceAttributeName,sourceAttributeValue,view);
				return true;
			    } else {
				return false;
			    }
			}
		    });
		}
	    } else {
		updateFn(targetAttributeName,targetAttributeValue,view)
	    }
	    //return true;
	    return false;
	}

	Action action__getNodes -name getNodes -body {
	    ::xo::ns::source [acs_root_dir]/packages/xo-drive/tmpl-pvt/view/get-nodes.tcl
	}

        Action action__getImages -name getImages -body {
            ::xo::ns::source [acs_root_dir]/packages/xo-drive/tmpl-pvt/view/get-images.tcl
        }

	JsonStore ds0 \
            -map {action__getImages shortName convertTags} \
            -url action__getImages \
            -proxy "new Ext.data.HttpProxy({url:action__getImages,method:'GET'})" \
	    -totalProperty 'totalCount' \
	    -root 'images' \
	    -autoLoad true \
	    -baseParams "{x_limit:25}" \
	    -fields [::util::list2json {
		id url magic tags title shared_p starred_p hidden_p deleted_p filetype
		{s:name shortName s:mapping title fn:convert shortName}
		{s:name itemTags s:mapping tags fn:convert convertTags}
	    } {s s s s s s s s s s M M}]


        Action action__previewData -name previewData -body {
            ::xo::ns::source [acs_root_dir]/packages/xo-drive/tmpl-pvt/view/one-preview-data.tcl
        }
	JsonStore ds1 \
            -map {action__previewData} \
            -url action__previewData \
            -proxy "new Ext.data.HttpProxy({url:action__previewData,method:'GET'})" \
	    -root 'fileRecord' \
	    -autoLoad false \
	    -fields [::util::list2json {id title size tags starred_p hidden_p deleted_p shared_p extra}]

        Action action__getParts -name getParts -body {
            ::xo::ns::source [acs_root_dir]/packages/xo-drive/tmpl-pvt/view/get-parts.tcl
        }
	JsonStore ds2 \
	    -map {action__getParts getPartUrl} \
	    -url action__getParts \
	    -proxy "new Ext.data.HttpProxy({url:action__getParts,method:'GET'})" \
	    -root 'searchResults' \
	    -totalProperty 'totalCount' \
	    -autoLoad false \
	    -fields [::util::list2json {
		part_index part_text
		{s:name part_url s:mapping part_index fn:convert getPartUrl}
	    } {s s M}]






	Action action__getTags -name getTags -body {
	    ::xo::ns::source [acs_root_dir]/packages/xo-drive/www-pvt/get-tags.tcl
	}

	JsonStore ds01 \
	    -map {action__getTags} \
	    -url action__getTags \
	    -proxy "new Ext.data.HttpProxy({url:action__getTags,method:'GET'})" \
	    -totalProperty 'totalCount' \
	    -root 'tags' \
	    -fields [util::list2json {tagName numOccurs}]

	Template tpl0_search -html {
	    <tpl for="."><div class="search-item">
	    <h3><span>{numOccurs} entries</span>{tagName}</h3>
	    </div></tpl>
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

	JS.Function tagSelectFn -map {tags setCaretToEnd removeDuplicates} -argv {record} -body {
	    var oldValueArray = tags.getValue().split(',');
	    oldValueArray[oldValueArray.length-1] = record.get('tagName');
	    var newValueArray = new Array();
	    for (var i=0; i<oldValueArray.length;i++) {
						       newValueArray[i]=oldValueArray[i].trim();
						   }
	    var newValue=removeDuplicates(newValueArray).join(', ') + ', ';
	    tags.setValue(newValue);
	    setCaretToEnd(tags);
	    tags.collapse();
	}

	JS.Function setCaretToEnd -argv {el} -body {
	    var length=el.getRawValue().length;
	    el.selectText(length,length);
	}

	JS.Function uploadSuccessFn -map {{ds0 ds} {upload_file_win w}} -argv {frm action} -body {
	    w.hide();
	    ds.load();
	}

	JS.Function uploadFailureFn -map {{upload_file_win w}} -argv {frm action} -body {
	    w.hide();
	}


        Window upload_file_win \
            -title "'Upload File'" \
            -modal true \
            -width 400 \
            -x 100 \
            -y 50 \
            -closeAction 'hide' \
            -bodyStyle 'padding:5' \
            -appendFromScript {

		Form upload_form \
		    -monitorValid true \
		    -monitorPoll 100 \
		    -action store \
		    -label "Upload" \
		    -standardSubmit false \
                    -submitText "Upload" \
                    -map {uploadSuccessFn uploadFailureFn} \
                    -submitOptions "{waitMsg:'Uploading file...',success:uploadSuccessFn,failure:uploadFailureFn,timeout:120000}" \
		    -appendFromScript {


			FileField upload_file \
			    -name upload_file \
			    -label "File"

			ComboBox tags -map {
			    {ds01 ds} 
			    {tpl0_search resultTpl} 
			    tagSelectFn
			} -name "tags" \
			    -label "Tags" \
			    -store ds \
			    -typeAhead false \
			    -width 250 \
			    -hideTrigger true \
			    -tpl resultTpl \
			    -queryParam 'q' \
			    -itemSelector 'div.search-item' \
			    -onSelect tagSelectFn \
			    -allowBlank true \
			    -minChars 0

			RadioGroup new -name shared_p -label "Access Control" -appendFromScript {
			    Radio new -label "Private" -value f -checked true
			    Radio new -label "Public" -value t
			}
		    } -proc action(store) {marshaller} {
			if { [my isValid] } {

			    set mydict [my getDict]

			    
			    set pathexp [list "User [ad_conn user_id]"]
			    set o [::Content_Item new -mixin "GIST_Text_Index ::db::Object" -pathexp $pathexp]

			    $o setSubject id
			    $o setTarget ts_vector
			    $o setIndexList {
				{A db "" title}

				{B db "simple" extra->'XO.Info.title'}
				{B db "simple" extra->'XO.Info.author'}
				{B db "simple" extra->'PDF.Info.subject'}
				{B db "simple" extra->'PDF.Info.keywords'}

				{B db "" extra->'MP3.Info.Title'}
				{B db "" extra->'MP3.Info.Artist'}
				{B db "" extra->'MP3.Info.Album'}
				{B db "" extra->'MP3.Info.Genre'}
				{B db "" extra->'MP3.Info.Year'}

				{C db "" description}
				{C tcl "" document_text}

				{D db "simple" extra->'Exif.Image.Make'}
				{D db "simple" extra->'Exif.Image.Model'}
			    }

			    $o set document_text ""

			    $o set title [string tolower [file rootname [dict get $mydict upload_file]]]
			    #$o set description [dict get $mydict description]
			    #$o set filetype [dict get $mydict upload_file.filetype]
			    $o set tags_ia ""
			    set tags_list [::xo::fun::filter [::xo::fun::map x [split [dict get $mydict tags] {,}] {string trim $x}] x {$x ne {}}]

			    ### $o set tags [join [::xo::fun::filter [split [dict get $mydict tags] {,}] x {[string trim $x] ne {}}] {,}]

			    $o set shared_p [dict get $mydict shared_p]

			    $o set extra [dict get $mydict upload_file.extra]

			    #		$o set translation [dict get $mydict upload_file.translation]


			    # Auditing
			    $o set creation_user [ad_conn user_id]
			    $o set creation_ip [ad_conn peeraddr]
			    $o set modifying_user [ad_conn user_id]
			    $o set modifying_ip [ad_conn peeraddr]


			    $o beginTransaction
			    $o rdb.self-id



			    set list ""
			    foreach item $pathexp {
				foreach {className instance_id} $item break
				lappend list [$className set id]-${instance_id}
			    }

			    set object_id [$o set id]
			    set directory /web/data/storage/
			    append directory [join $list .]/ ;# [User set id]-[ad_conn user_id]
			    append directory $object_id

			    set upload_file [ns_queryget upload_file]

			    set original_file ${directory}/o-${object_id}

			    file mkdir ${directory}
			    file mkdir ${directory}/preview/
			    set previewdir ${directory}/preview/

			    file rename -force -- [ns_queryget upload_file.tmpfile] ${directory}/o-${object_id}


			    ####### prepare preview
			    #ns_log notice "extra=[$o set extra]"
			    array set extra [join [$o set extra]]
			    #ns_log notice "XO.File.Type = $extra(XO.File.Type)"

			    set filetype  $extra(XO.File.Type)
			    set magic $extra(XO.File.Magic)

			    ### DOCUMENT ###
			    if { $filetype eq {document} || $filetype eq {spreadsheet} || $filetype eq {presentation} } {

				set PDFTOTEXT /opt/poppler/bin/pdftotext 

				set config [dict create original_file $original_file directory $directory previewdir $previewdir object_id $object_id magic $magic]
				set docinfo [::xo::media::process_upload=document $config]
				
				set PDFTOTEXT_INPUT "o-${object_id}"
				$o set document_text [exec -- /bin/sh -c "cd ${directory};${PDFTOTEXT} ${PDFTOTEXT_INPUT} - || exit 0" 2> /dev/null]

				$o set extra [concat [$o set extra] $docinfo]
				ns_log notice "xo-drive: docinfo=[$o set extra]"

				$o lappend indexList {D db "simple" extra->'XO.Info.title'}
				$o lappend indexList {D db "simple" extra->'XO.Info.author'}

			    }

			    
			    ### IMAGE ###
			    if { $filetype eq {image} } {
				set config [dict create original_file $original_file previewdir $previewdir object_id $object_id]
				::xo::media::process_upload=image $config
			    }


			    ### AUDIO ### 
			    if { $filetype eq {audio} } {

				set album ""
				set artist ""
				if { [info exists extra(MP3.Info.Album)] && [info exists extra(MP3.Info.Artist)] } {
				    set album $extra(MP3.Info.Album)
				    set artist $extra(MP3.Info.Artist)
				}

				set config [dict create original_file $original_file directory $directory previewdir $previewdir object_id $object_id album $album artist $artist]
				::xo::media::process_upload=audio $config
			    }


			    ### VIDEO ### 
			    if { $filetype eq {video} } {
				set duration $extra(XO.Info.duration)
				set config [dict create original_file $original_file directory $directory previewdir $previewdir object_id $object_id duration $duration]
				::xo::media::process_upload=video $config
				$o lappend extra $extra
			    }


			    ### USER DB ###

			    if { -1 != [lsearch -exact $extra(XO.File.Magic) {MDB}] } {
				exec -- /bin/sh -c "/usr/bin/mdb-schema -S __dummy__ ${original_file} > ${directory}/c-${object_id}.ddl || exit 0" 2> /dev/null
				set tables [exec -- /bin/sh -c "/usr/bin/mdb-tables ${original_file}  || exit 0" 2> /dev/null]
				foreach table_name $tables {
				    exec -- /bin/sh -c "/usr/bin/mdb-export ${original_file} ${table_name} | bzip2 > ${directory}/c-${object_id}-${table_name}.csv.bz2 || exit 0" 2> /dev/null
				}
			    }

			    package require crc32
			    ###set tags_list [::xo::fun::filter [::xo::fun::map x [split $tags {,}] {string trim $x}] x {$x ne {}}]

			    set tags_ia ""
			    array set tags_hash_ia [list]

			    if { ${tags_list} ne {} } {

				set tags_clause ""
				foreach tag $tags_list {
				    lappend tags_clause [::util::dbquotevalue $tag]
				}
				set tags_clause ([join $tags_clause {,}])

				set ds_tags [::db::Set new \
						 -pathexp $pathexp \
						 -select [list "trim(xo__concatenate_aggregate( '{' || name || '} ' || id || ' '),', ') as tags_hash_ia"] \
						 -type ::Content_Item_Label \
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
					set lo [::Content_Item_Label new \
						    -pathexp ${pathexp} \
						    -mixin ::db::Object \
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




			    $o rdb.self-insert


			    #source [acs_root_dir]/packages/persistence/pdl/33-content-item.tcl
			    set part [::Content_Item_Part new \
					  -mixin "GIST_Text_Index ::db::Object" \
					  -pathexp $pathexp \
					  -item_id [$o set id]]

			    $part setTarget ts_vector
			    $part setSubject {item_id part_index}
			    $part setIndexList {
				{B db "" part_text}
			    }

			    # split \x0c = ^L = form feed
			    set part_index 1
			    foreach part_text [split [$o set document_text] "\x0c"] {
				if { $part_text ne {} } {
				    $part set part_index $part_index
				    $part set part_text $part_text
				    $part rdb.self-insert
				}
				incr part_index
			    }


			    $o endTransaction



			    ns_return 200 text/html [::util::map2json b:success true]
			} else {

			    foreach o [my set __childNodes(__FORM_FIELD__)] {
				$o set value [$o getRawValue]
				if { ![$o isValid] } {
				    $o set markInvalid "Invalid"
				}
			    }
			    
			    ns_return 200 text/html [::util::map2json b:success false]
			    #$marshaller go -select "" -action draw


			}

		    }
	    }




	Menu btnNewMenu -appendFromScript {
	    #Menu.Item new -text "'Document'" -iconCls "'z-ft-document'" -ctCls "'z-tool-new-item'"
	    #Menu.Item new -text "'Spreadsheet'" -iconCls "'z-ft-spreadsheet'" -ctCls "'z-tool-new-item'"
	    #Menu.Item new -text "'Presentation'" -iconCls "'z-ft-presentation'" -ctCls "'z-tool-new-item'"
	    Menu.Item new -text "'Folder'" -iconCls "'z-tool-new-folder'" -ctCls "'z-tool-new-item'" -map {newFolderFn} -handler newFolderFn
	    #-listeners {click newFolderFn}
	}


	Toolbar tb0 -style "'background:#67A7E3;border:none;'" -appendFromScript {

	    Toolbar.SplitButton new \
		-text "'New'" \
		-iconCls "'z-tool-new-btn'" \
		-ctCls "'z-tool-new'" \
		-menu btnNewMenu 

	    Toolbar.Button new \
		-text "'Upload'" \
		-iconCls "'xo-upload-btn'" \
		-map {uploadFileFn} \
		-handler uploadFileFn

	}

	Toolbar tb1 -label "hello world" -style "'background:#DFE8F6;border:none;'" -appendFromScript {

	    #Toolbar.TextItem new -text "'Show: '"

	    CycleButton new -showText true -appendFromScript {
		CheckItem new -text "'All Types'" -value '' -checked true -iconCls 'z-ft-all'
		CheckItem new -text "'Document'" -value 'document' -iconCls 'z-ft-document'
		CheckItem new -text "'Spreadsheet'" -value 'spreadsheet' -iconCls 'z-ft-spreadsheet'
		CheckItem new -text "'Presentation'" -value 'presentation' -iconCls 'z-ft-presentation'
		CheckItem new -text "'Image'" -value 'image' -iconCls 'z-ft-image'
		CheckItem new -text "'Audio'" -value 'audio' -iconCls 'z-ft-audio'
		CheckItem new -text "'Video'" -value 'video' -iconCls 'z-ft-video'
	    } -minWidth 100 -changeHandler changeButtonFn

	    SearchField sf \
		-map {ds0} \
		-store ds0 \
		-emptyText "'Search'" \
		-width "200" \
		-paramName 'q'

	    Toolbar.Fill new

	    CycleButton cb1 -showText true -appendFromScript {
		CheckItem new -text "'Thumbnails'" -iconCls "'z-views-thumb'" -checked true
		#CheckItem new -text "'Tiles'" -iconCls "'z-views-tile'"
		#CheckItem new -text "'Icons'" -iconCls "'z-views-icon'"
		#CheckItem new -text "'Details'" -iconCls "'z-views-detail'"
	    } -minWidth 100

	}

	PagingToolbar tb2 \
	    -label "paging_toolbar_1" \
	    -store ds0 \
	    -pageSize 25 \
	    -displayMsg "'Showing items {0} - {1} of {2}'" \
	    -emptyMsg "'No items to display'" \
	    -style "'background:#DFE8F6;border:none;'"


	Template color_menu_tpl -html {
	    <tpl for="."><a href="#" class="color-{bgcolor}" hidefocus="on"><em><span style="background:#{bgcolor};color:#{fontcolor};" unselectable="on">a</span></em></a></tpl>
	}

	Template tpl0 -html {
	    <tpl for=".">
	    <div class="thumb-wrap" id="{id}">
	    <div class="thumb"><div class="thumb-inner"><img src="{url}?size=120" class="thumb-img">
	    <div class="z-thumb-icon first z-shared-{shared_p}"></img></div>
	    </div>
	    <div class="thumb-details">
	    <div class="z-thumb-icon first z-star-{starred_p}">&nbsp;</div>
	    <div class="z-thumb-icon second z-ft-{filetype}">&nbsp;</div>
	    <div class="sn"><span ext:qtip="[{id}] {title}.{magic}">&nbsp;{shortName}&nbsp;</span></div>
	    <div class="thumb-tags"><span class="thumb-folder">{shortFolderName}</span> {itemTags}</div>
	    </div>
	    </div>
	    </div>
	    </tpl>
	}

	Template tpl1 -html {
	    <tpl for=".">
	    <div class="s240-wrap" id="preview-{id}">
	    <div class="s240"><div class="item-inner"><img src="view/{id}/?size=240" class="item-img"></div></div>
	    ({size:fileSize})
	    <div class="s240-title">{title}</div>
	    <div class="s240-tags">{tags}</div>
	    </div>
	    </tpl>
	}

###  <div>X - Y of Z pages with references to Q</div>

	Template tpl2 -html {
	    <div class="search-results">
	    <b>Inside this Document </b>
	    <tpl for=".">
	    <div class="page">
	    <a href="{part_url}" target="_blank">on Page {part_index}</a>
	      <div class="snippet">"... {part_text} ..."</div>
            </div>
	    </tpl>
	    </div>
	}


	TreeLoader tl1 -map {action__getNodes} -requestMethod 'GET' -dataUrl action__getNodes -preloadChildren true -baseAttrs "{iconCls:'z-folder',attributeName:'label_id','uiProvider':'col'}" -uiProviders {{'col': Ext.tree.ColumnNodeUI}}

	#Viewport 
	#-width 1400
	Panel new -autoWidth true -height 550 -layout fit -monitorResize true -appendFromScript {

	    #monitorResize true
	    Panel new -tbar tb0 -layout border -appendFromScript {

		#### Panel new -layout accordion -appendFromScript {} -region west -width 200 -split true -border true -bodyBorder true -margins "5 0 5 5"
		ColumnTree tree0 -rootVisible false -autoScroll true -containerScroll true -lines false -enableDrop true -ddGroup 'organizerDD' -animate false -columns {
		    [{
			header:'Tag',
			dataIndex:'text'
		    },{
			header:'Cnt',
			dataIndex:'cnt_entries'
		    }]
		} -extraInfo {
		    storeToFilter ds0 
		    tabPanel tp1
		} -appendFromScript {
		    TreeNode new -text "'Root'" -expanded true -appendFromScript {

			TreeNode root_of_allitems \
			    -text "'All Items'" \
			    -iconCls 'z-all-items' \
			    -cls 'cls' \
			    -expanded true \
			    -map {selectInitFolderFn} \
			    -listeners {beforechildrenrendered selectInitFolderFn} \
			    -extraInfo {

				storeToFilter ds0 
				tabPanel tp1
				fieldName 'label_id' 
				fieldValue ''

			    } -appendFromScript {

				TreeNode new -text "'Starred'" -iconCls "'z-starred'" -cls 'cls' -extraInfo {storeToFilter ds0 tabPanel tp1 attributeName 'starred_p' starred_p 't'}
				TreeNode new -text "'Hidden'" -iconCls "'z-hidden'" -cls 'cls' -extraInfo {storeToFilter ds0 tabPanel tp1 attributeName 'hidden_p' hidden_p 't'}
				TreeNode new -text "'Trash'" -iconCls "'z-deleted'" -cls 'cls' -extraInfo {storeToFilter ds0 tabPanel tp1 attributeName 'deleted_p' deleted_p 't'}
				TreeNode new -text "'Published'" -iconCls "'z-published'" -cls 'cls' -extraInfo {storeToFilter ds0 tabPanel tp1 attributeName 'shared_p' shared_p 't'}
			    }

			AsyncTreeNode root_of_folders -text "'All Folders'" -expanded true -cls 'z-folder' -isTarget false -loader tl1 -map {tl1}			

			#TreeNode new -text "'Shared with...'" -cls "'z-folder'" -expanded true -appendFromScript {
			#    TreeNode new -text "'Public'" -iconCls "'z-shared-t'" -cls 'cls' 
			# -extraInfo {storeToFilter ds0 tabPanel tp1 attributeName 'shared_p' shared_p 't'} -map {selectFolderFn} -listeners { click selectFolderFn }
			#}

		    }

		} -map {
		    selectFolderFn 
		    folderContextMenuFn
		    beforenodedropFn
		} -listeners {
		    click selectFolderFn
		    contextmenu folderContextMenuFn
		    beforenodedrop beforenodedropFn
		} -region 'west' -width 250 -split true -border true -bodyBorder true -margins "'5 0 5 5'"


		TabPanel tp1 -appendFromScript {

		    Panel new -title "'Media Box'" -tbar tb1 -bbar tb2 -layout fit -autoWidth true -appendFromScript {
			DataView view0 \
			    -label "Media Box" \
			    -multiSelect true \
			    -autoWidth true \
			    -itemSelector "'div.thumb-wrap'" \
			    -selectedClass "'x-view-selected'" \
			    -overClass "'x-view-over'" \
			    -tpl tpl0 \
			    -store ds0 \
			    -extraInfo {
				tabPanel tp1
			    } -map {
				tpl0
				ds0
				onContextMenu
				clickItemFn
					openFileFn
				itemContextMenuFn
				ctContextMenuFn
			    } -listeners {
				click clickItemFn
				dblClick openFileFn
				contextmenu itemContextMenuFn
				containercontextmenu ctContextMenuFn
			    } -onContextMenu onContextMenu
		    } -border true -bodyBorder true -autoScroll true
		    


		} -region "center" -deferredRender false -activeTab 0 -enableTabScroll true -plain true -margins "5 0 5 0"

		TabPanel new -appendFromScript {


		    Panel new -title "'Info'" -appendFromScript {

			DataView view1 \
			    -label "Preview One File" \
			    -map {tpl1 ds1} \
			    -itemSelector "'div.s240-wrap'" \
			    -tpl tpl1 \
			    -store ds1


			DataView view2 \
			    -label "Search Results" \
			    -map {tpl2 ds2} \
			    -itemSelector "'div.page'" \
			    -tpl tpl2 \
			    -store ds2
		    }

                    PropertyGrid grid0 \
                        -title "'Properties'" \
                        -autoHeight true

		} -region east -collapsible true -width 240 -split true -deferredRender false -activeTab 0 -enableTabScroll true -plain true -border true -bodyBorder true -margins "5 5 5 0"
	    }

	} -label "viewport"


	JS.Function beforeStartEditFn -argv {editor boundEl value} -body {
	    if (typeof editor.editNode.attributes.label_id !== 'undefined') {
		return true;
	    } else {
		return false;
	    }
	}

	TreeEditor ge \
	    -tree tree0 \
	    -allowBlank false \
	    -blankText "'A name is required'" \
	    -selectOnFocus false \
	    -map {renameFolderFn beforeStartEditFn} \
	    -stateEvents { [{ change:renameFolderFn}] } \
	    -listeners {beforestartedit beforeStartEditFn}

	TreeSorter sorter0 -tree tree0 -foldersort true

	ImageDragZone new -view view0 -ddGroup 'organizerDD' -containerScroll true

    }
