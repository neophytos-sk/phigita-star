function shortName (name) {
    if(name.length > 15){	
	return name.substr(0, 12) + '...';
    }
    return name;
}


// InsertImage ---------------------------------------------------------------------------------------------------------------------------------------------------


Xinha.prototype.ImageDialog = function() {

  var chooser,editor,img;

  return {
    show: function(p_editor,p_image,p_param) {
	editor = p_editor;
	img = p_image;
	if(!chooser){
	    chooser = new ImageChooser({
		url:editor.config.URIs.insert_image,
		width:515, 
		height:350,
		modal:true,
		pageSize:10
	      });
	}
	chooser.show(null, {ok: this.ok, hide: this.hideDialog}, img);
    },

    hideDialog: function(e) {
	  if (typeof e != 'undefined') Xinha._stopEvent(e.browserEvent);
	  chooser.dlg.hide();
	  editor.focusEditor();
	  if (!img) { editor.findCC(); }
    },

    ok: function (data) {

	editor.ImageDialog.hideDialog();
var url = 'http://my.phigita.net/media/'+ data.get('url').trim() + '?size=240';
	if ( !img ) {
	    imgHTML = '<img class="center" style="display:block;padding:15px;margin-left:auto;margin-right:auto;" filetype="' + data.get('filetype') + '" identifier="' + data.get('id') + '" src="' + url + '" />';
	    editor.insertAtCursor(imgHTML + (Xinha.is_gecko ? editor.cc : ''));
	    if (Xinha.is_gecko) editor.findCC();
	} else {
	    img.src = url
	    editor.moveAfterNode(img);
	}
	editor.updateToolbar();
    }
  };
}();

// Called when the user clicks on "InsertImage" button.  If an image is already
// there, it will just modify it's properties.
Xinha.prototype._insertImage = function(image) {

  var editor = this;
  var outparam = null;
  if ( typeof image == "undefined" )
  {
    image = this._getElement('img');
  }
  if ( image ) {
    outparam = {
      f_url    : Xinha.is_ie ? image.src : image.getAttribute("src"),
      f_align  : image.align
    };
  }
  
  this.ImageDialog.show(editor,image,outparam);
  return;
};






var ImageChooser = function(config){

    var ds=new Ext.data.JsonStore({
	url:config.url,
	root:'images',
	totalProperty:'totalCount',
	baseParams:{x_limit:config.pageSize,filetype:'image'},
	fields:[
		'id', 'url', 'tags', 'magic', 'title', 'shared_p', 'starred_p', 'hidden_p', 'deleted_p', 'filetype', 'folder_id', 'folder_title',
		{name: 'shortName', mapping: 'title', convert: shortName},
		{name: 'shortFolderName', mapping: 'folder_title', convert: shortName}
	       ]
    });

    // filter/sorting toolbar
    tb = new Ext.Toolbar({
	items:[
	       new Ext.ux.SearchField({
		   store:ds,
		   emptyText:'Search',
		   paramName:'q'
	       }),
	       new Ext.Toolbar.Fill(),
	       new Ext.CycleButton({
//		   prependText:'Sort by... ',
		   showText:true,
		   ctCls:'z-white-cb',
		   items:[{text:"Name"},{text:"File Size"},{text:"Last Modified",checked:true}]
	       })
	      ]
    });



	// create the required templates
	var thumbTemplate = new Ext.XTemplate(
		'<tpl for=".">',
		'<div class="s90-wrap" id="{id}">',
		'<div class="thumb"><div class="thumb-inner"><img class="thumb-img" src="http://my.phigita.net/media/{url}?size=120" identifier="{id}" filetype="{filetype}"></div>',
		'<div class="sn">{shortName}</div>',
		'</div></div>',
		'</tpl>'
	);
	//this.thumbTemplate.compile();	

	this.detailsTemplate = new Ext.Template(
		'<div class="details"><img src="{url}" filetype="{filetype}" identifier="{id}"><div class="details-info">' +
		'<b>Image Name:</b>' +
		'<span>{name}</span>' +
		'<b>Size:</b>' +
		'<span>{sizeString}</span>' +
		'<b>Last Modified:</b>' +
		'<span>{dateString}</span></div></div>'
	);
	this.detailsTemplate.compile();	




    var ptb = new Ext.PagingToolbar({
	store:ds,
	pageSize:config.pageSize,
	displayMsg:'Showing images {0} - {1} of {2}',
	emptyMsg:'No images to display'
    });

    // initialize the View		
    var view = new Ext.DataView({
	itemSelector:'div.s90-wrap',
	selectedClass:'s90-view-selected',
	overClass:'s90-view-over',
	store: ds,
	tpl: thumbTemplate, 
	singleSelect: true,
	emptyText : '<div style="padding:10px;">No images match the specified filter</div>'
    });


    var mediabox = new Ext.Panel({
	title:'Media Box',
	layout:'fit',
	tbar:tb,
	bbar:ptb,
	items:[view]
    });

	var tabs = new Ext.TabPanel({
	    region: 'center',
	    margins: '3 3 3 0', 
	    activeTab: 0,
	    border:false,
	    bodyBorder:false,
	    hideBorders:true,
	    defaults: {autoScroll:true},
	    items:[mediabox/* ,{title: 'Web Address (URL)'} */]
	});


    // create the dialog from scratch
    var win = new Ext.Window({
	title:'Choose an Image',
	width:config.width,
	height:config.height,
	modal:config.modal,
	resizable:false,
	collapsible:false,
	draggable:false,
	layout:'fit',
	items:[tabs],
	buttons:[{text:'Ok',handler:this.doCallback,scope:this},{text:'Cancel',handler:this.doCancel,scope:this}]
    });

	view.on('dblclick', this.doCallback, this);
	ds.on('loadexception', this.onLoadException, this);

	this.dlg = win;
	this.ds=ds;
	this.view = view;
	this.thumbTemplate=thumbTemplate;
	this.tb = tb;
	this.ptb = ptb;

//	ds.load();


//	win.show(this);

	return;

// HERE    this.view.on('selectionchange', this.showDetails, this, {buffer:100});



	this.dlg = dlg;


// HERE	dlg.addKeyListener(27, dlg.hide, dlg);
    // add some buttons
// HERE    this.ok = dlg.addButton('OK', this.doCallback, this);
// HERE    this.ok.disable();
// HERE    dlg.setDefaultButton(dlg.addButton('Cancel', dlg.hide, dlg));



    

    
    var formatSize = function(size){
        if(size < 1024) {
            return size + " bytes";
        } else {
            return (Math.round(((size*10) / 1024))/10) + " KB";
        }
    };
    
    // cache data by image name for easy lookup
    var lookup = {};
    // make some values pretty for display
    this.view.store.prepareData = function(data,recordIndex,recordElement){
        data._recordIndex = recordIndex;
        data._recordElement = recordElement;
    	data.shortName = data.title.ellipse(15);
    	data.sizeString = formatSize(data.size);
    	data.dateString = '' ;new Date(data.lastmod).format("m/d/Y g:i a");
    	lookup[data.name] = data;
    	return data;
    };
    this.lookup = lookup;

	this.loaded = false;
};


ImageChooser.prototype = {
	show : function(el, callback,img){
	    this.reset();
		this.callback = callback.ok;
            if (img) {
	        this.view.clearSelections();
                r = this.ds.getById(img.getAttribute('id'));
                this.view.select(this.ds.indexOf(r));
            }

	    var win=this.dlg;
	    this.ds.load({callback:function(){win.show(el);}});
	},
	hide : function() {
	    this.dlg.hide();
	},
	reset : function(){
	    // HERE this.view.el.dom.scrollTop = 0;
	    // HERE this.view.clearFilter();
		//this.txtFilter.dom.value = '';
		this.view.select(0);
	},
	
	load : function(){
		if(!this.loaded){
			this.view.store.load({url: this.url, params:this.params, callback:this.onLoad.createDelegate(this)});
		}
	},
	
	onLoadException : function(v,o){
	    this.view.getEl().update('<div style="padding:10px;">Error loading images.</div>'); 
	},
	
	filter : function(){
		var filter = this.txtFilter.dom.value;
		this.view.filter('name', filter);
		this.view.select(0);
	},
	
	onLoad : function(){
		this.loaded = true;
		this.view.select(0);
	},
	
	sortImages : function(){
		var p = this.sortSelect.dom.value;
    	this.view.sort(p, p != 'name' ? 'desc' : 'asc');
    	this.view.select(0);
    },
	
	showDetails : function(view, nodes){
	    var selNode = nodes[0];
		if(selNode && this.view.getCount() > 0){
			this.ok.enable();
		    var data = this.lookup[selNode.id];
            this.detailEl.hide();
            this.detailsTemplate.overwrite(this.detailEl, data);
	    this.detailEl.show();
//            this.detailEl.slideIn('l', {stopFx:true,duration:.2});
			
		}else{
		    this.ok.disable();
		    this.detailEl.update('');
		}
	},

	doCancel : function() {
		this.dlg.hide();
	},
	
	doCallback : function(){
	    var selNode = this.view.getSelectedNodes()[0];
            var view = this.view;
            var callback = this.callback;
	    var lookup = this.lookup;
	    this.dlg.hide(null,function(){
                if(selNode && callback){
		    var r = view.getRecord(selNode);
		    callback(r);
	        }
	    });
	}
};

