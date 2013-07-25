InsertImage._pluginInfo = {
  name          : "InsertImage"
};

function InsertImage(editor) {
}                                      


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
	      height:400,
	      modal:true
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

	if ( !img ) {
	    //editor.insertAtCursor('<img src="' + data.url.trim() + '" />' + (Xinha.is_gecko ? editor.cc : ''));
	    //editor.insertAtCursor('<span style="width:16px;height:16px;background-image:url(/lib/xo-1.0.0/resources/images/ed-buttons-main);background-repeat: no-repeat; background-position:-80px 0;padding-left:16px;margin:1px;" imageUrl="' + data.url.trim() + '" />' + (Xinha.is_gecko ? editor.cc : ''));

            //imgHTML = '<img style="border: 0pt none ; padding: 0px; position: relative; cursor: move;"src="' + data.url.trim() + '" />';

	    //imgHTML = '<span style="display:block;width:120px;height:90px;background-image:url(' + data.url.trim()  + ');background-repeat: no-repeat;margin:1px;" imageUrl="' + data.url.trim() + '/>';

	    imgHTML = '<img _xo_id="' + data.name + '" title="' + data.name + '"src="' + data.url.trim() + '" />';
	    editor.insertAtCursor(imgHTML + (Xinha.is_gecko ? editor.cc : ''));


	    if (Xinha.is_gecko) editor.findCC();
	} else {
	    img.src = data.url.trim();
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
    // create the dialog from scratch
    var dlg = new Ext.LayoutDialog(config.id || Ext.id(), {
		autoCreate : true,
		minWidth:400,
		minHeight:300,
		syncHeightBeforeShow: true,
		shadow:true,
		modal:true,
        fixedcenter:true,
        center:{autoScroll:false},
		east:{split:true,initialSize:150,minSize:150,maxSize:250}
	});
	dlg.setTitle('Choose an Image');
	dlg.getEl().addClass('ychooser-dlg');
	dlg.addKeyListener(27, dlg.hide, dlg);
    
    // add some buttons
    this.ok = dlg.addButton('OK', this.doCallback, this);
    this.ok.disable();
    dlg.setDefaultButton(dlg.addButton('Cancel', dlg.hide, dlg));
    dlg.on('show', this.load, this);
	this.dlg = dlg;
	var layout = dlg.getLayout();
	
	// filter/sorting toolbar
	this.tb = new Ext.Toolbar(this.dlg.body.createChild({tag:'div'}));
	this.sortSelect = Ext.DomHelper.append(this.dlg.body.dom, {
		tag:'select', children: [
			{tag: 'option', value:'name', selected: 'true', html:'Name'},
			{tag: 'option', value:'size', html:'File Size'},
			{tag: 'option', value:'lastmod', html:'Last Modified'}
		]
	}, true);
	this.sortSelect.on('change', this.sortImages, this, true);
	
	this.txtFilter = Ext.DomHelper.append(this.dlg.body.dom, {
		tag:'input', type:'text', size:'12'}, true);
		
	this.txtFilter.on('focus', function(){this.dom.select();});
	this.txtFilter.on('keyup', this.filter, this, {buffer:500});
	
	this.tb.add('Filter:', this.txtFilter.dom, 'separator', 'Sort By:', this.sortSelect.dom);
	
	// add the panels to the layout
	layout.beginUpdate();
	var vp = layout.add('center', new Ext.ContentPanel(Ext.id(), {
		autoCreate : true,
		toolbar: this.tb,
		fitToFrame:true
	}));
	var dp = layout.add('east', new Ext.ContentPanel(Ext.id(), {
		autoCreate : true,
		fitToFrame:true
	}));
    layout.endUpdate();
	
	var bodyEl = vp.getEl();
	bodyEl.appendChild(this.tb.getEl());
	var viewBody = bodyEl.createChild({tag:'div', cls:'ychooser-view'});
	vp.resizeEl = viewBody;
	
	this.detailEl = dp.getEl();
	
	// create the required templates
	this.thumbTemplate = new Ext.Template(
		'<div class="thumb-wrap" id="{name}">' +
		'<div class="thumb"><img src="{url}" _xo_id="{name}" title="{name}"></div>' +
		'<span>{shortName}</span></div>'
	);
	this.thumbTemplate.compile();	
	
	this.detailsTemplate = new Ext.Template(
		'<div class="details"><img src="{url}"><div class="details-info">' +
		'<b>Image Name:</b>' +
		'<span>{name}</span>' +
		'<b>Size:</b>' +
		'<span>{sizeString}</span>' +
		'<b>Last Modified:</b>' +
		'<span>{dateString}</span></div></div>'
	);
	this.detailsTemplate.compile();	
    
    // initialize the View		
	this.view = new Ext.JsonView(viewBody, this.thumbTemplate, {
		singleSelect: true,
		jsonRoot: 'images',
		emptyText : '<div style="padding:10px;">No images match the specified filter</div>'
	});
    this.view.on('selectionchange', this.showDetails, this, {buffer:100});
    this.view.on('dblclick', this.doCallback, this);
    this.view.on('loadexception', this.onLoadException, this);
    this.view.on('beforeselect', function(view){
        return view.getCount() > 0;
    });
    Ext.apply(this, config, {
        width: 540, height: 400
    });
    
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
    this.view.prepareData = function(data,recordIndex,recordElement){
        data._recordIndex = recordIndex;
        data._recordElement = recordElement;
    	data.shortName = data.name.ellipse(15);
    	data.sizeString = formatSize(data.size);
    	data.dateString = new Date(data.lastmod).format("m/d/Y g:i a");
    	lookup[data.name] = data;
    	return data;
    };
    this.lookup = lookup;
    
	dlg.resizeTo(this.width, this.height);
	this.loaded = false;
};


ImageChooser.prototype = {
	show : function(el, callback,img){
	    this.reset();
		this.callback = callback.ok;
            if (img) {
	        this.view.clearSelections();
                data = this.lookup[img.getAttribute('_xo_id')];
                this.view.select(data._recordIndex);
            }
	    this.dlg.show(el);
	},
	hide : function() {
	    this.dlg.hide();
	},
	reset : function(){
	    this.view.getEl().dom.scrollTop = 0;
	    this.view.clearFilter();
		this.txtFilter.dom.value = '';
		this.view.select(0);
	},
	
	load : function(){
		if(!this.loaded){
			this.view.load({url: this.url, params:this.params, callback:this.onLoad.createDelegate(this)});
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
            this.detailEl.slideIn('l', {stopFx:true,duration:.2});
			
		}else{
		    this.ok.disable();
		    this.detailEl.update('');
		}
	},
	
	doCallback : function(){
        var selNode = this.view.getSelectedNodes()[0];
		var callback = this.callback;
		var lookup = this.lookup;
		this.dlg.hide(function(){
            if(selNode && callback){
				var data = lookup[selNode.id];
				callback(data);
			}
		});
	}
};

String.prototype.ellipse = function(maxLength){
    if(this.length > maxLength){
        return this.substr(0, maxLength-3) + '...';
    }
    return this;
};

