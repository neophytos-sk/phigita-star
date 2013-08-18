
Class ::xo::ui::Organizer -superclass {::xo::ui::Widget}

::xo::ui::Organizer instproc render {visitor} {
    #set visitor [self callingobject]

    $visitor ensureLoaded XO.Fx
    $visitor ensureLoaded XO.DD
    $visitor ensureLoaded XO.Tree
    $visitor ensureLoaded XO.DataView
    $visitor ensureLoaded XO.Toolbar
    $visitor ensureLoaded XO.QuickTips
    $visitor ensureLoaded XO.Form.ComboBox
    $visitor ensureLoaded XO.Store

    my instvar domNodeId label

    $visitor inlineJavascript [subst -nobackslashes -nocommands {


	/**
	* Create a DragZone instance for our JsonView
	*/
	ImageDragZone = function(view, config){
	    this.view = view;
	    ImageDragZone.superclass.constructor.call(this, view.getEl(), config);
	};
	Ext.extend(ImageDragZone, Ext.dd.DragZone, {
	    // We don't want to register our image elements, so let's 
	    // override the default registry lookup to fetch the image 
	    // from the event instead
	    getDragData : function(e){
		var target = e.getTarget('.thumb-wrap');
		if(target){
		    var view = this.view;
		    if(!view.isSelected(target)){
			view.onClick(e);
		    }
		    var selNodes = view.getSelectedNodes();
		    var dragData = {
			nodes: selNodes
		    };
		    if(selNodes.length == 1){
			dragData.ddel = target.firstChild.firstChild; // the img element
			dragData.single = true;
		    }else{
			var div = document.createElement('div'); // create the multi element drag "ghost"
			div.className = 'multi-proxy';
			for(var i = 0, len = selNodes.length; i < len; i++){
									    div.appendChild(selNodes[i].firstChild.firstChild.cloneNode(true));
									    if((i+1) % 3 == 0){
										div.appendChild(document.createElement('br'));
									    }
									}
			dragData.ddel = div;
			dragData.multi = true;
		    }
		    return dragData;
		}
		return false;
	    },

	    // this method is called by the TreeDropZone after a node drop
	    // to get the new tree node (there are also other way, but this is easiest)
	    getTreeNode : function(){
		var treeNodes = [];
		var nodeData = this.view.getRecords(this.dragData.nodes);
		for(var i = 0, len = nodeData.length; i < len; i++){
								    var data = nodeData[i].data;
								    treeNodes.push(new Ext.tree.TreeNode({
									text: data.shortName,
									icon: data.url,
									data: data,
									leaf:true,
									cls: 'image-node'
								    }));
								}
		return treeNodes;
	    },
	    
	    // the default action is to "highlight" after a bad drop
	    // but since an image can't be highlighted, let's frame it 
	    afterRepair:function(){
		for(var i = 0, len = this.dragData.nodes.length; i < len; i++){
									       Ext.fly(this.dragData.nodes[i]).frame('\#8db2e3', 1);
									   }
		this.dragging = false;    
	    },
	    
	    // override the default repairXY with one offset for the margins and padding
	    getRepairXY : function(e){
		if(!this.dragData.multi){
		    var xy = Ext.Element.fly(this.dragData.ddel).getXY();
		    xy[0]+=3;xy[1]+=3;
		    return xy;
		}
		return false;
	    }
	});


	// Utility functions
	function shortName(name){
	    if(name.length > 15){
		return name.substr(0, 12) + '...';
	    }
	    return name;
	};

	// Utility functions
	function displayExtra (extra){
	    result = '<ul>';
	    for (var i in extra) {
				  parts=i.split('.');
				  key = parts[parts.length-1];
				  result += '<li>' + key + ': ' + extra[i].substr(0,12) + '</li>';
			      }
	    result += '</ul>';
	    return result;
	};



Ext.app.SearchField = Ext.extend(Ext.form.TwinTriggerField, {
    initComponent : function(){
        if(!this.store.baseParams){
			this.store.baseParams = {};
		}
		Ext.app.SearchField.superclass.initComponent.call(this);
		this.on('specialkey', function(f, e){
            if(e.getKey() == e.ENTER){
                this.onTrigger2Click();
            }
        }, this);
    },

    validationEvent:false,
    validateOnBlur:false,
    trigger1Class:'x-form-clear-trigger',
    trigger2Class:'x-form-search-trigger',
    hideTrigger1:true,
    width:180,
    hasSearch : false,
    paramName : 'query',

    onTrigger1Click : function(){
        if(this.hasSearch){
            this.store.baseParams[this.paramName] = '';
			this.store.removeAll();
			this.el.dom.value = '';
            this.triggers[0].hide();
            this.hasSearch = false;
			this.focus();
        }
    },

    onTrigger2Click : function(){
        var v = this.getRawValue();
        if(v.length < 1){
            this.onTrigger1Click();
            return;
        }
		if(v.length < 2){
			Ext.Msg.alert('Invalid Search', 'You must enter a minimum of 2 characters to search the API');
			return;
		}
		this.store.baseParams[this.paramName] = v;
        var o = {start: 0};
        this.store.reload({params:o});
        this.hasSearch = true;
        this.triggers[0].show();
		this.focus();
    }
});



Ext.ux.SelectBox = function(config){
	this.searchResetDelay = 1000;
	config = config || {};
	config = Ext.apply(config || {}, {
		editable: false,
		forceSelection: true,
		rowHeight: false,
		lastSearchTerm: false,
        triggerAction: 'all',
        mode: 'local'
    });					

	Ext.ux.SelectBox.superclass.constructor.apply(this, arguments);

	this.lastSelectedIndex = this.selectedIndex || 0;
};

Ext.extend(Ext.ux.SelectBox, Ext.form.ComboBox, {
    lazyInit: false,
	initEvents : function(){
		Ext.ux.SelectBox.superclass.initEvents.apply(this, arguments);
		// you need to use keypress to capture upper/lower case and shift+key, but it doesn't work in IE
		this.el.on('keydown', this.keySearch, this, true);
		this.cshTask = new Ext.util.DelayedTask(this.clearSearchHistory, this);
	},

	keySearch : function(e, target, options) {
		var raw = e.getKey();
		var key = String.fromCharCode(raw);
		var startIndex = 0;

		if( !this.store.getCount() ) {
			return;
		}

		switch(raw) {
			case Ext.EventObject.HOME:
				e.stopEvent();
				this.selectFirst();
				return;

			case Ext.EventObject.END:
				e.stopEvent();
				this.selectLast();
				return;

			case Ext.EventObject.PAGEDOWN:
				this.selectNextPage();
				e.stopEvent();
				return;

			case Ext.EventObject.PAGEUP:
				this.selectPrevPage();
				e.stopEvent();
				return;
		}

		// skip special keys other than the shift key
		if( (e.hasModifier() && !e.shiftKey) || e.isNavKeyPress() || e.isSpecialKey() ) {
			return;
		}
		if( this.lastSearchTerm == key ) {
			startIndex = this.lastSelectedIndex;
		}
		this.search(this.displayField, key, startIndex);
		this.cshTask.delay(this.searchResetDelay);
	},

	onRender : function(ct, position) {
		this.store.on('load', this.calcRowsPerPage, this);
		Ext.ux.SelectBox.superclass.onRender.apply(this, arguments);
		if( this.mode == 'local' ) {
			this.calcRowsPerPage();
		}
	},

	onSelect : function(record, index, skipCollapse){
		if(this.fireEvent('beforeselect', this, record, index) !== false){
			this.setValue(record.data[this.valueField || this.displayField]);
			if( !skipCollapse ) {
				this.collapse();
			}
			this.lastSelectedIndex = index + 1;
			this.fireEvent('select', this, record, index);
		}
	},

	render : function(ct) {
		Ext.ux.SelectBox.superclass.render.apply(this, arguments);
		if( Ext.isSafari ) {
			this.el.swallowEvent('mousedown', true);
		}
		this.el.unselectable();
		this.innerList.unselectable();
		this.trigger.unselectable();
		this.innerList.on('mouseup', function(e, target, options) {
			if( target.id && target.id == this.innerList.id ) {
				return;
			}
			this.onViewClick();
		}, this);

		this.innerList.on('mouseover', function(e, target, options) {
			if( target.id && target.id == this.innerList.id ) {
				return;
			}
			this.lastSelectedIndex = this.view.getSelectedIndexes()[0] + 1;
			this.cshTask.delay(this.searchResetDelay);
		}, this);

		this.trigger.un('click', this.onTriggerClick, this);
		this.trigger.on('mousedown', function(e, target, options) {
			e.preventDefault();
			this.onTriggerClick();
		}, this);

		this.on('collapse', function(e, target, options) {
			Ext.getDoc().un('mouseup', this.collapseIf, this);
		}, this, true);

		this.on('expand', function(e, target, options) {
			Ext.getDoc().on('mouseup', this.collapseIf, this);
		}, this, true);
	},

	clearSearchHistory : function() {
		this.lastSelectedIndex = 0;
		this.lastSearchTerm = false;
	},

	selectFirst : function() {
		this.focusAndSelect(this.store.data.first());
	},

	selectLast : function() {
		this.focusAndSelect(this.store.data.last());
	},

	selectPrevPage : function() {
		if( !this.rowHeight ) {
			return;
		}
		var index = Math.max(this.selectedIndex-this.rowsPerPage, 0);
		this.focusAndSelect(this.store.getAt(index));
	},

	selectNextPage : function() {
		if( !this.rowHeight ) {
			return;
		}
		var index = Math.min(this.selectedIndex+this.rowsPerPage, this.store.getCount() - 1);
		this.focusAndSelect(this.store.getAt(index));
	},

	search : function(field, value, startIndex) {
		field = field || this.displayField;
		this.lastSearchTerm = value;
		var index = this.store.find.apply(this.store, arguments);
		if( index !== -1 ) {
			this.focusAndSelect(index);
		}
	},

	focusAndSelect : function(record) {
		var index = typeof record === 'number' ? record : this.store.indexOf(record);
		this.select(index, this.isExpanded());
		this.onSelect(this.store.getAt(record), index, this.isExpanded());
	},

	calcRowsPerPage : function() {
		if( this.store.getCount() ) {
			this.rowHeight = Ext.fly(this.view.getNode(0)).getHeight();
			this.rowsPerPage = this.maxHeight / this.rowHeight;
		} else {
			this.rowHeight = false;
		}
	}

});


	var $domNodeId = function(){
	    var tree;
	    var preview_panel;
	    var west_panel;
	    var images;
	    return {
		init : function(){


//		    Ext.QuickTips.init();

		    // Album toolbar
		    var newIndex = 3;
		    var tb = new Ext.Toolbar({
			items:[{
			    text: 'New Album',
			    iconCls: 'album-btn',
			    handler: function(){
				var node = root.appendChild(new Ext.tree.TreeNode({
				    text:'Album ' + (++newIndex),
				    cls:'album-node',
				    allowDrag:false
				}));
				tree.getSelectionModel().select(node);
				setTimeout(function(){
				    ge.editNode = node;
				    ge.startEdit(node.ui.textNode);
				}, 10);
			    }
			}, {
			    text: 'Upload File',
			    iconCls: 'upload-btn',
			    handler: function(){
				top.location.href='file-upload';
			    }
			}]
		    });



		    // set up the Album tree
		    var tree = new Ext.tree.TreePanel({
			// tree
			header:true,
			animate:true,
			enableDD:true,
			containerScroll: true,
			ddGroup: 'organizerDD',
			rootVisible:false,
			// layout
//			region:'west',
			width:200,
			split:true,
			// panel
			title:'Collections',
			autoScroll:true,
			tbar: tb,
			//bbar: tb2
			margins: '5 0 5 5'
		    });

		    var root = new Ext.tree.TreeNode({
			text: 'Albums',
			allowDrag:false,
			allowDrop:false
		    });
		    tree.setRootNode(root);

		    root.appendChild(
				     new Ext.tree.TreeNode({text:'Album 1', cls:'album-node', allowDrag:false}),
				     new Ext.tree.TreeNode({text:'Album 2', cls:'album-node', allowDrag:false}),
				     new Ext.tree.TreeNode({text:'Album 3', cls:'album-node', allowDrag:false})
		     );

		    // add an inline editor for the nodes
		    var ge = new Ext.tree.TreeEditor(tree, {
			allowBlank:false,
			blankText:'A name is required',
			selectOnFocus:true
		    });

		    // Set up images view

		    var view = new Ext.DataView({
			itemSelector: 'div.thumb-wrap',
			style:'overflow:auto',
			multiSelect: false,
			singleSelect: true,
			loadingText: 'Loading...',
			plugins: new Ext.DataView.DragSelector({dragSafe:true}),
			store: new Ext.data.JsonStore({
			    url: 'view/get-images',
			    autoLoad: true,
			    root: 'images',
			    totalProperty: 'totalCount',
			    id:'id',
			    fields:[
				    'id', 'url', 'tags','shared_p',
				    {name: 'shortName', mapping: 'title', convert: shortName}
				   ]
//			    baseParams: {limit:50}
			}),
			tpl: new Ext.XTemplate(
					       '<tpl for=".">',
					       '<div class="thumb-wrap" id="{id}">',
					       '<div class="thumb"><div class="thumb-inner"><img src="{url}" class="thumb-img"></div></div>',
					       '<span class="x-public-access-{shared_p}">{shortName}</span>',
					       '<span class="thumb-tags">{tags}</span></div>',
					       '</tpl>'
					       )
		    });


		    var preview_one = new Ext.DataView({
			itemSelector: 'div.thumb-wrap',
			style:'overflow:auto',
			multiSelect: false,
			singleSelect: true,
			loadingText: 'Loading image details... ',
			plugins: new Ext.DataView.DragSelector({dragSafe:true}),
			store: new Ext.data.JsonStore({
			    url: 'one-preview-data',
			    autoLoad: false,
			    root: 'imageRecord',
			    id:'id',
			    fields:[
				    'id', 'url', 'tags','shared_p','size',
				    {name: 'extraHtml', mapping: 'extra', convert: displayExtra},
				    {name: 'shortName', mapping: 'title', convert: shortName}
				   ]
			}),
			tpl: new Ext.XTemplate(
					       '<tpl for=".">',
					       '<div class="thumb-wrap" id="{id}">',
					       '<div class="thumb"><div class="thumb-inner"><img src="view/{id}?size=240" class="thumb-img"></div></div>',
					       '<div class="x-public-access-{shared_p}">\#{id} {shortName}</div>',
					       '<span class="thumb-tags">{tags}</span></div>',
					       '<div>File Size: {size:fileSize}</div>',
					       '<div>{extraHtml}</div>',
					       '</tpl>'
					       )
		    });



var preview_panel = new Ext.Panel({
    region:'east',
    split: false,
    width:260,
    margins: '5 5 5 0',
    layout:'fit',
    tbar: new Ext.Toolbar({
	items:[{
	    text: 'Rotate anti-clockwise',
	    iconCls: 'rotate-clockwise-btn',
	    handler: function(){}
	}, {
	    text: 'Rotate clockwise',
	    iconCls: 'rotate-clockwise-btn',
	    handler: function(){
	    }
	}]
    }),
    items: preview_one

});


view.on('dblclick',function(view,index,node,e) {
//    alert('doubleclick'+index+' '+node.id)
    top.location.href='view/'+node.id;
});

view.on('click',function(view,index,node,e) {
//    alert('doubleclick'+index+' '+node.id)
//    top.location.href='view/'+node.id;
    preview_one.store.load({
	params: {id: node.id}
    });
    preview_one.show();
    return;
    preview_panel.load({
	url: 'one-view',
	params: {id: node.id, size: 240}, // or a URL encoded string
	discardUrl: false,
	nocache: false,
	text: "Loading...",
	timeout: 30,
	scripts: false
    });
});

		    var images = new Ext.Panel({
			id:'images',
			region:'center',
			margins: '5 5 5 0',
			layout:'fit',
			tbar: [
			       'Search: ', ' ',
			       new Ext.ux.SelectBox({
				   listClass:'x-combo-list-small',
				   width:90,
				   value:'Starts with',
				   id:'search-type',
				   store: new Ext.data.SimpleStore({
				       fields: ['text'],
				       expandData: true,
				       data : ['Starts with', 'Ends with', 'Any match']
				   }),
				   displayField: 'text'
			       }), ' ',
			       new Ext.app.SearchField({
				   width:240,
				   store: new Ext.data.Store({
				       proxy: new Ext.data.ScriptTagProxy({
					   url: 'http://extjs.com/playpen/api.php'
				       }),
				       paramName: 'q'
				   })
			       })
			      ],
			bbar: new Ext.PagingToolbar({
			    store: view.store,
			    pageSize: 50,
			    displayInfo: true,
			    displayMsg: 'Displaying {0} - {1} of {2}',
			    emptyMsg: "No data to display"
			}),
			items: view
		    });



var west_panel = new Ext.Panel ({
    region:'west',
//    id:'west-panel',
    title:'West',
    split:true,
    width: 200,
    minSize: 175,
    maxSize: 400,
    collapsible: true,
    margins:'35 0 5 5',
    cmargins:'35 5 5 5',
    layout:'accordion',
    layoutConfig:{
	animate:false,
	alwaysOnTop:true
    },
    items: [{
        title: 'Folders',
        html: '<p>Panel content!</p>',
	border: false
    },tree,{
        title: 'Mail',
        html: '<p>Panel content!</p>',
	border: false
    },{
        title: 'Calendar',
        html: '<p>Panel content!</p>',
	border: false
    }, {
        title: 'Contacts',
        html: '<p>Panel content!</p>',
	border: false
    }]
});

var viewport = new Ext.Viewport({
    layout: 'border',
    items: [west_panel, images, preview_panel]
});
//viewport.doLayout();




		    var dragZone = new ImageDragZone(view, {containerScroll:true, ddGroup: 'organizerDD'});
		}
	    }

	}();

}]
    $visitor onReady [my domNodeId].init [my domNodeId] true


    set node [next]
    $node appendFromScript {
	#h3 { t [my label] }
	div -id [my domNodeId]
    }
    return $node
}
