//1196095211

	var c;
	var _c = function(){
	    return {
		init : function(){
		    c=function(){var name=arguments[0];
	    if(name.length > 15){
		return name.substr(0, 12) + '...';
	    }
	    return name;
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_c.init,_c,true);
    
	var d;
	var _d = function(){
	    return {
		init : function(){
		    d=function(){var v=top.fc,sf=top.jb;var part_index=arguments[0];
	    var result = 'one-view/'+v.store.baseParams['id']+'/?size=500&p='+part_index;
	    var query = sf.store.baseParams[sf.paramName];
	    if (typeof query !== 'undefined' && query != '') {
		result += '&q='+query;
	    }
	    return result;

	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_d.init,_d,true);
    
	var e;
	var _e = function(){
	    return {
		init : function(){
		    e=function(){var _0=arguments;var field_name=_0[0],field_value=_0[1],view=_0[2];
	    selIDs=new Array();
	    for (i=0; i < view.sel.length; i++) { selIDs[i] = view.sel[i].get('id'); }
	     Ext.Ajax.request({
		url: 'bulk-update',
		success: function(response,options) {
		    view.store.reload({callback:function(){view.select(options.params.id);}});
		},
		failure: function(response,options) {
		    Ext.Msg.alert('Status','Failed to delete file'+response.responseText);
		},
		 params: { id: selIDs, key: field_name, value:field_value }
	    })
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_e.init,_e,true);
    
	var f;
	var _f = function(){
	    return {
		init : function(){
		    f=function(){var tree=top.xb,sfFn=top.g,roaf=top.Eb;var node=arguments[0];
	     Ext.Ajax.request({
		url: 'folder-remove',
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
		 params: { id: node.attributes.folder_id }
	    })
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_f.init,_f,true);
    
	var g;
	var _g = function(){
	    return {
		init : function(){
		    g=function(){var storeToFilter=top.v,tabPanel=top.Fb;var _0=arguments;var node=_0[0],e=_0[1];
	    tree = node.getOwnerTree();

	    attributeName=node.attributes.attributeName;
	    attributeValue=node.attributes[attributeName];

	    tabPanel.setActiveTab(0);

	    storeToFilter.baseParams['folder_id'] = null;
	    storeToFilter.baseParams['starred_p'] = null;
	    storeToFilter.baseParams['hidden_p'] = null;
	    storeToFilter.baseParams['deleted_p'] = null;
	    storeToFilter.baseParams['shared_p'] = null;
	    if (typeof attributeName !== 'undefined') {
		storeToFilter.baseParams[attributeName] = attributeValue;
	    }
	    storeToFilter.load({start:0});
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_g.init,_g,true);
    
	var h;
	var _h = function(){
	    return {
		init : function(){
		    h=function(){var storeToFilter=top.v;var _0=arguments;var sb=_0[0],item=_0[1];
            v_filetype = item.value;
            if (storeToFilter.baseParams['filetype'] != v_filetype) {
                storeToFilter.baseParams['filetype'] = v_filetype;
                storeToFilter.reload({start:0});
            }
            return true;
        };
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_h.init,_h,true);
    
	var i;
	var _i = function(){
	    return {
		init : function(){
		    i=function(){
	    top.location.href='file-upload';
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_i.init,_i,true);
    
	var j;
	var _j = function(){
	    return {
		init : function(){
		    j=function(){var grid0=top.hc;var _0=arguments;var r=_0[0],options=_0[1],success=_0[2];
	    if (success) {
		grid0.setSource(r[0].get('extra'));
	    } else {
		Ext.Msg.alert('Problem loading data','Please try again in a while.');
	    }
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_j.init,_j,true);
    
	var k;
	var _k = function(){
	    return {
		init : function(){
		    k=function(){var v2=top.gc,ds1=top.w,ds2=top.x,sf=top.jb,refreshPropertyGridFn=top.j;var _0=arguments;var v0=_0[0],index=_0[1],node=_0[2],e=_0[3];

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
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_k.init,_k,true);
    
	var l;
	var _l = function(){
	    return {
		init : function(){
		    l=function(){var sf=top.jb;var _0=arguments;var view=_0[0],index=_0[1],node=_0[2],e=_0[3];
	    e.stopEvent();
	    data = view.store.getAt(index);
	    tp = eval(view.__xo__.tabPanel);
	    var q = sf.store.baseParams[sf.paramName];
	    q = q?q:'';

	    p=tp.add(new Ext.Panel({title:data.get('shortName'),html:'<iframe width="100%" height="100%" src="one-view/'+node.id+'/?size=500&q='+q+'" />',closable:true,autoScroll:true,iconCls:'z-ft-'+data.get('filetype')}));
	    tp.setActiveTab(p);
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_l.init,_l,true);
    
	var m;
	var _m = function(){
	    return {
		init : function(){
		    m=function(){var e=arguments[0];
	    var item = e.getTarget(this.itemSelector, this.el);
	    if(item){
		this.fireEvent("contextmenu", this, this.indexOf(item), item, e);
	    } else {
		if(this.fireEvent("containercontextmenu", this, e) !== false){
		    this.clearSelections();
		}
	    }
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_m.init,_m,true);
    Ext.QuickTips.init();
	var n;
	var _n = function(){
	    return {
		init : function(){
		    n=function(){var ge=top.jc,removeFolderFn=top.f;var _0=arguments;var node=_0[0],e=_0[1];
	    tree = node.getOwnerTree();
	    if (!tree._fcm) {
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
                }]);
	    }
	    tree.ctxNode = node;
	    if (node.attributes.folder_id >0) {
		tree._fcm.showAt(e.getPoint());
	    }
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_n.init,_n,true);
    
	var o;
	var _o = function(){
	    return {
		init : function(){
		    o=function(){var _0=arguments;var view=_0[0],e=_0[1];
	    e.stopEvent();
	    if(!view._ccm){ // create context menu on first right click
		mibp = "http://www.phigita.net/lib/xo-1.0.0/resources/images/menu/";
		view._ccm = new Ext.menu.Menu([{
                    id: view.id + '-upload',
                    text: 'Upload',
                    iconCls: 'z-upload-menu',
		    handler: function() { top.location.href='file-upload'; }
		},'-',
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
	        ]);
	    }
	    view._ccm.showAt(e.getPoint());
	    return true;
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_o.init,_o,true);
    
	var p;
	var _p = function(){
	    return {
		init : function(){
		    p=function(){var updateFn=top.e;var _0=arguments;var view=_0[0],index=_0[1],item=_0[2],e=_0[3];
	    view.sel = view.getSelectedRecords();
	    if (-1 == view.sel.indexOf(view.getRecord(item))) {
		view.select(item);
		view.sel = view.getSelectedRecords();
	    }
	    e.stopEvent();
	    if(!view.menu){ // create context menu on first right click
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
			    msg: 'Please enter tags:',
			    buttons: Ext.Msg.OKCANCEL,
			    prompt:true,
			    width:250,
			    value:view.getRecord(view.ctxItem).get('tags'),
			    fn: function(btn,text) {
				if ( btn == 'ok' ) {
				    Ext.Ajax.request({
					url: 'one-tag',
					success: function(response,options) {
					    //view.refreshNode(view.indexOf(view.ctxItem));
					    //view.refresh();
					    view.store.reload();
					},
					failure: function(response,options) {
					    Ext.Msg.alert('Status','Failed to rename file'+response.responseText);
					},
					params: { id: view.ctxItem.id, tags:text }
				    })
				}
			    },
			    animEl: view.ctxItem.id,
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
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_p.init,_p,true);
    
	var q;
	var _q = function(){
	    return {
		init : function(){
		    q=function(){var node=top.Eb,ts=top.kc,view=top.cc,ge=top.jc;var _0=arguments;var field=_0[0],newValue=_0[1],oldValue=_0[2]; 

	    // ge.editNode.attributes.folder_id OR this.editNode.attributes.folder_id
	    
	    Ext.Ajax.request({
		url: 'folder-rename',
		success: function(response,options) {
		    view.store.reload();
		    ts.doSort(node);
		},
		failure: function(response,options) {
		    Ext.Msg.alert('Status','Failed to rename file'+response.responseText);
		},
		params: { "id":ge.editNode.attributes.folder_id, "newValue":newValue,"oldValue":oldValue}
	    })
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_q.init,_q,true);
    
	var r;
	var _r = function(){
	    return {
		init : function(){
		    r=function(){var root_of_folders=top.Eb,tree0=top.xb,ge=top.jc;var _0=arguments;var response=_0[0],options=_0[1];
	    var node = root_of_folders.appendChild(new Ext.tree.TreeNode({
		text: Ext.decode(response.responseText).name,
		folder_id:Ext.decode(response.responseText).id,
		attributeName:'folder_id',
		cls:'z-folder',
		allowDrag:false
	    }));
	    //tree0.getSelectionModel().select(node);
	    setTimeout(function(){
		ge.editNode = node;
		ge.startEdit(node.ui.textNode);
	    }, 10);
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_r.init,_r,true);
    
	var s;
	var _s = function(){
	    return {
		init : function(){
		    s=function(){var successFn=top.r;var _0=arguments;var baseitem=_0[0],e=_0[1];

	    // todo: baseitem.__xo__.prefix, etc
	    Ext.Ajax.request({
		requestMethod:'POST',
		url: 'folder-create',
		success: successFn,
		failure: function(response,options) {
		    Ext.Msg.alert('Status','Failed to create folder'+response.responseText);
		},
		params: { prefix:'Folder'}
	    });
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_s.init,_s,true);
    
	var t;
	var _t = function(){
	    return {
		init : function(){
		    t=function(){var node=arguments[0];
	    node.select();
	    //alert(tree0);
	    //alert(node);
	    //tree0.getSelectionModel().select(node);
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_t.init,_t,true);
    
	var u;
	var _u = function(){
	    return {
		init : function(){
		    u=function(){var updateFn=top.e,root_of_allitems=top.zb;var dropEvent=arguments[0];
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

	    if ( sourceAttributeName !== 'folder_id' && typeof sourceAttributeName !== 'undefined' && (target==root_of_allitems || (typeof targetAttributeName !== 'undefined' && targetAttributeName !== 'starred_p' && targetAttributeName!=='folder_id'))) {
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
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_u.init,_u,true);
    
	var v;
	var _v = function(){
	    return {
		init : function(){
		    var shortName=top.c;v=new Ext.data.JsonStore({url:'view/get-images',autoLoad:true,root:'images',totalProperty:'totalCount',baseParams:{limit:40},fields: ['id','url','tags','magic','title','shared_p','starred_p','hidden_p','deleted_p','filetype','folder_id','folder_title',{name: 'shortName', mapping: 'title', convert: shortName},{name: 'shortFolderName', mapping: 'folder_title', convert: shortName}]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_v.init,_v,true);
    
	var w;
	var _w = function(){
	    return {
		init : function(){
		    w=new Ext.data.JsonStore({url:'one-preview-data',autoLoad:false,root:'fileRecord',fields: ['id','title','size','tags','folder_title','starred_p','hidden_p','deleted_p','shared_p','extra']});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_w.init,_w,true);
    
	var x;
	var _x = function(){
	    return {
		init : function(){
		    var getPartUrl=top.d;x=new Ext.data.JsonStore({url:'view/get-parts',autoLoad:false,root:'searchResults',totalProperty:'totalCount',fields: ['part_index','part_text',{name: 'part_url', mapping: 'part_index', convert: getPartUrl}]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_x.init,_x,true);
    
	var z;
	var _z = function(){
	    return {
		init : function(){
		    z=new Ext.menu.Item({text:'Document',ctCls:'z-tool-new-item',iconCls:'z-ft-document'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_z.init,_z,true);
    
	var A;
	var _A = function(){
	    return {
		init : function(){
		    A=new Ext.menu.Item({text:'Spreadsheet',ctCls:'z-tool-new-item',iconCls:'z-ft-spreadsheet'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_A.init,_A,true);
    
	var B;
	var _B = function(){
	    return {
		init : function(){
		    B=new Ext.menu.Item({text:'Presentation',ctCls:'z-tool-new-item',iconCls:'z-ft-presentation'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_B.init,_B,true);
    
	var C;
	var _C = function(){
	    return {
		init : function(){
		    var newFolderFn=top.s;C=new Ext.menu.Item({text:'Folder',ctCls:'z-tool-new-item',iconCls:'z-tool-new-folder',handler:s});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_C.init,_C,true);
    
	var y;
	var _y = function(){
	    return {
		init : function(){
		    y=new Ext.menu.Menu({items:[z,A,B,C]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_y.init,_y,true);
    
	var E;
	var _E = function(){
	    return {
		init : function(){
		    E=new Ext.Toolbar.SplitButton({text:'New',iconCls:'z-tool-new-btn',ctCls:'z-tool-new',menu:y});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_E.init,_E,true);
    
	var F;
	var _F = function(){
	    return {
		init : function(){
		    var uploadFileFn=top.i;F=new Ext.Toolbar.Button({text:'Upload',iconCls:'xo-upload-btn',handler:i});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_F.init,F,true);
    
	var D;
	var _D = function(){
	    return {
		init : function(){
		    D=new Ext.Toolbar({style:'background:#67A7E3;border:none;',items: [E,F]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_D.init,D,true);
    
	var cb;
	var _cb = function(){
	    return {
		init : function(){
		    cb=new Ext.menu.CheckItem({id:'cb',text:'All Types',iconCls:'z-ft-all',checked:true,value:''});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_cb.init,_cb,true);
    
	var db;
	var _db = function(){
	    return {
		init : function(){
		    db=new Ext.menu.CheckItem({id:'db',text:'Document',iconCls:'z-ft-document',value:'document'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_db.init,_db,true);
    
	var eb;
	var _eb = function(){
	    return {
		init : function(){
		    eb=new Ext.menu.CheckItem({id:'eb',text:'Spreadsheet',iconCls:'z-ft-spreadsheet',value:'spreadsheet'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_eb.init,_eb,true);
    
	var fb;
	var _fb = function(){
	    return {
		init : function(){
		    fb=new Ext.menu.CheckItem({id:'fb',text:'Presentation',iconCls:'z-ft-presentation',value:'presentation'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_fb.init,_fb,true);
    
	var gb;
	var _gb = function(){
	    return {
		init : function(){
		    gb=new Ext.menu.CheckItem({id:'gb',text:'Image',iconCls:'z-ft-image',value:'image'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_gb.init,_gb,true);
    
	var hb;
	var _hb = function(){
	    return {
		init : function(){
		    hb=new Ext.menu.CheckItem({id:'hb',text:'Audio',iconCls:'z-ft-audio',value:'audio'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_hb.init,_hb,true);
    
	var ib;
	var _ib = function(){
	    return {
		init : function(){
		    ib=new Ext.menu.CheckItem({id:'ib',text:'Video',iconCls:'z-ft-video',value:'video'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_ib.init,_ib,true);
    
	var bb;
	var _bb = function(){
	    return {
		init : function(){
		    bb=new Ext.CycleButton({showText:true,minWidth:100,changeHandler:h,items: [{id:'cb',text:'All Types',iconCls:'z-ft-all',checked:true,value:''},{id:'db',text:'Document',iconCls:'z-ft-document',value:'document'},{id:'eb',text:'Spreadsheet',iconCls:'z-ft-spreadsheet',value:'spreadsheet'},{id:'fb',text:'Presentation',iconCls:'z-ft-presentation',value:'presentation'},{id:'gb',text:'Image',iconCls:'z-ft-image',value:'image'},{id:'hb',text:'Audio',iconCls:'z-ft-audio',value:'audio'},{id:'ib',text:'Video',iconCls:'z-ft-video',value:'video'}]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_bb.init,_bb,true);
    
	var jb;
	var _jb = function(){
	    return {
		init : function(){
		    var ds0=top.v;jb=new Ext.ux.SearchField({paramName:'q',emptyText:'Search',width:200,paramName:'q',store:ds0});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_jb.init,jb,true);
    
	var kb;
	var _kb = function(){
	    return {
		init : function(){
		    kb=new Ext.Toolbar.Fill({});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_kb.init,_kb,true);
    
	var mb;
	var _mb = function(){
	    return {
		init : function(){
		    mb=new Ext.menu.CheckItem({id:'mb',text:'Thumbnails',iconCls:'z-views-thumb',checked:true});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_mb.init,_mb,true);
    
	var nb;
	var _nb = function(){
	    return {
		init : function(){
		    nb=new Ext.menu.CheckItem({id:'nb',text:'Tiles',iconCls:'z-views-tile'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_nb.init,_nb,true);
    
	var ob;
	var _ob = function(){
	    return {
		init : function(){
		    ob=new Ext.menu.CheckItem({id:'ob',text:'Icons',iconCls:'z-views-icon'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_ob.init,_ob,true);
    
	var pb;
	var _pb = function(){
	    return {
		init : function(){
		    pb=new Ext.menu.CheckItem({id:'pb',text:'Details',iconCls:'z-views-detail'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_pb.init,_pb,true);
    
	var lb;
	var _lb = function(){
	    return {
		init : function(){
		    lb=new Ext.CycleButton({showText:true,minWidth:100,items: [{id:'mb',text:'Thumbnails',iconCls:'z-views-thumb',checked:true},{id:'nb',text:'Tiles',iconCls:'z-views-tile'},{id:'ob',text:'Icons',iconCls:'z-views-icon'},{id:'pb',text:'Details',iconCls:'z-views-detail'}]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_lb.init,_lb,true);
    
	var ab;
	var _ab = function(){
	    return {
		init : function(){
		    ab=new Ext.Toolbar({style:'background:#DFE8F6;border:none;',items: [bb,jb,kb,lb]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_ab.init,ab,true);
    
	var qb;
	var _qb = function(){
	    return {
		init : function(){
		    qb=new Ext.PagingToolbar({pageSize:40,displayInfo:true,displayMsg:'Showing items {0} - {1} of {2}',emptyMsg:'No items to display',style:'background:#DFE8F6;border:none;',store:v});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_qb.init,_qb,true);
    
	var rb;
	var _rb = function(){
	    return {
		init : function(){
		    rb=new Ext.XTemplate('<tpl for=".">','<div class="thumb-wrap" id="{id}">','<div class="thumb"><div class="thumb-inner"><img src="{url}?size=120" class="thumb-img">','<div class="z-thumb-icon first z-shared-{shared_p}"></img></div>','</div>','<div class="thumb-details">','<div class="z-thumb-icon first z-star-{starred_p}">&nbsp;</div>','<div class="z-thumb-icon second z-ft-{filetype}">&nbsp;</div>','<div class="sn"><span ext:qtip="[{id}] {title}.{magic}">&nbsp;{shortName}&nbsp;</span></div>','<div class="thumb-tags"><span class="thumb-folder">{shortFolderName}</span> {tags}</div>','</div>','</div>','</div>','</tpl>');
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_rb.init,_rb,true);
    
	var sb;
	var _sb = function(){
	    return {
		init : function(){
		    sb=new Ext.XTemplate('<tpl for=".">','<div class="s240-wrap" id="preview-{id}">','<div class="s240"><div class="item-inner"><img src="view/{id}/?size=240" class="item-img"></div></div>','({size:fileSize})','<div class="s240-title">{title}</div>','<div class="s240-tags"><span class="s240-folder">{folder_title}</span> {tags}</div>','</div>','</tpl>');
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_sb.init,_sb,true);
    
	var tb;
	var _tb = function(){
	    return {
		init : function(){
		    tb=new Ext.XTemplate('<div class="search-results">','<b>Inside this Document </b>','<tpl for=".">','<div class="page">','<a href="{part_url}" target="_blank">on Page {part_index}</a>','<div class="snippet">"... {part_text} ..."</div>','</div>','</tpl>','</div>');
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_tb.init,_tb,true);
    
	var ub;
	var _ub = function(){
	    return {
		init : function(){
		    ub=new Ext.tree.TreeLoader({dataUrl:'view/get-nodes',preloadChildren:true,baseAttrs:{iconCls:'z-folder',attributeName:'folder_id'}});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_ub.init,_ub,true);
    
	var Ab;
	var _Ab = function(){
	    return {
		init : function(){
		    Ab=new Ext.tree.TreeNode({text:'Starred',iconCls:'z-starred',cls:'cls'});
		    
		    Ab.__xo__ = {storeToFilter : 'v',tabPanel : 'Fb',attributeName : 'starred_p',starred_p : 't'};Ext.applyIf(Ab.attributes,{storeToFilter : 'v',tabPanel : 'Fb',attributeName : 'starred_p',starred_p : 't'});
		}
	    }
	}();
    
	Ext.onReady(_Ab.init,_Ab,true);
    
	var Bb;
	var _Bb = function(){
	    return {
		init : function(){
		    Bb=new Ext.tree.TreeNode({text:'Hidden',iconCls:'z-hidden',cls:'cls'});
		    
		    Bb.__xo__ = {storeToFilter : 'v',tabPanel : 'Fb',attributeName : 'hidden_p',hidden_p : 't'};Ext.applyIf(Bb.attributes,{storeToFilter : 'v',tabPanel : 'Fb',attributeName : 'hidden_p',hidden_p : 't'});
		}
	    }
	}();
    
	Ext.onReady(_Bb.init,_Bb,true);
    
	var Cb;
	var _Cb = function(){
	    return {
		init : function(){
		    Cb=new Ext.tree.TreeNode({text:'Trash',iconCls:'z-deleted',cls:'cls'});
		    
		    Cb.__xo__ = {storeToFilter : 'v',tabPanel : 'Fb',attributeName : 'deleted_p',deleted_p : 't'};Ext.applyIf(Cb.attributes,{storeToFilter : 'v',tabPanel : 'Fb',attributeName : 'deleted_p',deleted_p : 't'});
		}
	    }
	}();
    
	Ext.onReady(_Cb.init,_Cb,true);
    
	var Db;
	var _Db = function(){
	    return {
		init : function(){
		    Db=new Ext.tree.TreeNode({text:'Published',iconCls:'z-published',cls:'cls'});
		    
		    Db.__xo__ = {storeToFilter : 'v',tabPanel : 'Fb',attributeName : 'shared_p',shared_p : 't'};Ext.applyIf(Db.attributes,{storeToFilter : 'v',tabPanel : 'Fb',attributeName : 'shared_p',shared_p : 't'});
		}
	    }
	}();
    
	Ext.onReady(_Db.init,_Db,true);
    
	var zb;
	var _zb = function(){
	    return {
		init : function(){
		    var selectInitFolderFn=top.t;zb=new Ext.tree.TreeNode({text:'All Items',expanded:true,iconCls:'z-all-items',cls:'cls'});zb.appendChild(Ab,Bb,Cb,Db);
		    zb.on({'beforechildrenrendered' : {fn:t, scope:zb}});
		    zb.__xo__ = {storeToFilter : 'v',tabPanel : 'Fb',fieldName : 'folder_id',fieldValue : ''};Ext.applyIf(zb.attributes,{storeToFilter : 'v',tabPanel : 'Fb',fieldName : 'folder_id',fieldValue : ''});
		}
	    }
	}();
    
	Ext.onReady(_zb.init,_zb,true);
    
	var Eb;
	var _Eb = function(){
	    return {
		init : function(){
		    Eb=new Ext.tree.AsyncTreeNode({text:'All Folders',expanded:true,cls:'z-folder',isTarget:false,loader:ub});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_Eb.init,_Eb,true);
    
	var yb;
	var _yb = function(){
	    return {
		init : function(){
		    yb=new Ext.tree.TreeNode({expanded:true});yb.appendChild(zb,Eb);
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_yb.init,_yb,true);
    
	var xb;
	var _xb = function(){
	    return {
		init : function(){
		    var selectFolderFn=top.g,folderContextMenuFn=top.n,beforenodedropFn=top.u;xb=new Ext.tree.TreePanel({width:200,border:true,bodyBorder:true,autoScroll:true,split:true,region:'west',margins:'5 0 5 5',rootVisible:false,enableDrop:true,lines:false,ddGroup:'organizerDD','root': yb});
		    xb.on({'click' : {fn:g, scope:xb},'contextmenu' : {fn:n, scope:xb},'beforenodedrop' : {fn:u, scope:xb}});
		    xb.__xo__ = {storeToFilter : 'v',tabPanel : 'Fb'};Ext.applyIf(xb.attributes,{storeToFilter : 'v',tabPanel : 'Fb'});
		}
	    }
	}();
    
	Ext.onReady(_xb.init,_xb,true);
    
	var cc;
	var _cc = function(){
	    return {
		init : function(){
		    var tpl0=top.rb,ds0=top.v,onContextMenu=top.m,clickItemFn=top.k,openFileFn=top.l,itemContextMenuFn=top.p,ctContextMenuFn=top.o;cc=new Ext.DataView({applyTo:'cc',border:false,bodyBorder:false,multiSelect:true,loadingText:'',selectedClass:'x-view-selected',overClass:'x-view-over',itemSelector:'div.thumb-wrap',tpl:tpl0,store:ds0,onContextMenu:onContextMenu,plugins: new Ext.DataView.DragSelector({dragSafe:true})});
		    cc.on({'click' : {fn:k, scope:cc},'dblClick' : {fn:l, scope:cc},'contextmenu' : {fn:p, scope:cc},'containercontextmenu' : {fn:o, scope:cc}});
		    cc.__xo__ = {tabPanel : 'Fb'};Ext.applyIf(cc.attributes,{tabPanel : 'Fb'});
		}
	    }
	}();
    
	Ext.onReady(_cc.init,_cc,true);
    
	var bc;
	var _bc = function(){
	    return {
		init : function(){
		    bc=new Ext.Panel({border:true,bodyBorder:true,autoScroll:true,header:false,applyTo:'bc',region:'center',layout:'fit',items: [cc]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_bc.init,_bc,true);
    
	var ac;
	var _ac = function(){
	    return {
		init : function(){
		    ac=new Ext.Panel({title:'Media Box',border:false,header:false,applyTo:'ac',tbar:ab,bbar:qb,layout:'border',items: [bc]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_ac.init,_ac,true);
    
	var Fb;
	var _Fb = function(){
	    return {
		init : function(){
		    Fb=new Ext.TabPanel({applyTo:'Fb',plain:'true',region:'center',border:false,bodyBorder:false,margins:'5 0 5 0',split:false,activeTab:0,enableTabScroll:true,deferredRender:false,items: [ac],plugins: new Ext.ux.TabCloseMenu()});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_Fb.init,_Fb,true);
    
	var fc;
	var _fc = function(){
	    return {
		init : function(){
		    var tpl1=top.sb,ds1=top.w;fc=new Ext.DataView({applyTo:'fc',border:false,bodyBorder:false,loadingText:'',itemSelector:'div.s240-wrap',tpl:tpl1,store:ds1,plugins: new Ext.DataView.DragSelector({dragSafe:true})});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_fc.init,_fc,true);
    
	var gc;
	var _gc = function(){
	    return {
		init : function(){
		    var tpl2=top.tb,ds2=top.x;gc=new Ext.DataView({applyTo:'gc',border:false,bodyBorder:false,loadingText:'',itemSelector:'div.page',tpl:tpl2,store:ds2,plugins: new Ext.DataView.DragSelector({dragSafe:true})});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_gc.init,_gc,true);
    
	var ec;
	var _ec = function(){
	    return {
		init : function(){
		    ec=new Ext.Panel({title:'Info',border:false,header:false,applyTo:'ec',items: [fc,gc]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_ec.init,_ec,true);
    
	var hc;
	var _hc = function(){
	    return {
		init : function(){
		    hc=new Ext.grid.PropertyGrid({title:'Properties',autoHeight:true});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_hc.init,_hc,true);
    
	var dc;
	var _dc = function(){
	    return {
		init : function(){
		    dc=new Ext.TabPanel({applyTo:'dc',plain:'true',width:240,region:'east',border:true,bodyBorder:true,margins:'5 5 5 0',split:true,activeTab:0,enableTabScroll:true,collapsible:true,deferredRender:false,items: [ec,hc],plugins: new Ext.ux.TabCloseMenu()});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_dc.init,_dc,true);
    
	var wb;
	var _wb = function(){
	    return {
		init : function(){
		    wb=new Ext.Panel({border:false,header:false,applyTo:'wb',tbar:D,layout:'border',items: [xb,Fb,dc]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_wb.init,_wb,true);
    
	var vb;
	var _vb = function(){
	    return {
		init : function(){
		    vb=new Ext.Viewport({margins:'5 5 5 5',layout:'fit',items: [wb]});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_vb.init,_vb,true);
    
	var ic;
	var _ic = function(){
	    return {
		init : function(){
		    ic=function(){var _0=arguments;var editor=_0[0],boundEl=_0[1],value=_0[2];
	    if (typeof editor.editNode.attributes.folder_id !== 'undefined') {
		return true;
	    } else {
		return false;
	    }
	};
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_ic.init,_ic,true);
    
	var jc;
	var _jc = function(){
	    return {
		init : function(){
		    var renameFolderFn=top.q,beforeStartEditFn=top.ic;;jc=new Ext.tree.TreeEditor (xb,{allowBlank:false,blankText:'A name is required',selectOnFocus:false,stateEvents: [{ change:renameFolderFn}] });
		    jc.on({'beforestartedit' : {fn:ic, scope:jc}});
		    
		}
	    }
	}();
    
	Ext.onReady(_jc.init,_jc,true);
    
	var kc;
	var _kc = function(){
	    return {
		init : function(){
		    kc=new Ext.tree.TreeSorter(xb,{foldersort:true});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_kc.init,_kc,true);
    
	var lc;
	var _lc = function(){
	    return {
		init : function(){
		    ;lc=new Ext.ux.ImageDragZone (cc,{containerScroll:true,ddGroup:'organizerDD'});
		    
		    
		}
	    }
	}();
    
	Ext.onReady(_lc.init,_lc,true);
    
