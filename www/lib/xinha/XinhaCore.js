
Ext.ux.HtmlEditor = function(config){
    Ext.apply(this, config);
    Ext.ux.HtmlEditor.superclass.constructor.call(this);
};


Ext.extend(Ext.ux.HtmlEditor,Ext.form.Field, {
    initComponent : function(){
	var ta = Ext.get(this.applyTo);
	Ext.ux.HtmlEditor.superclass.initComponent.call(this);

	xinha_config = new Xinha.Config();

	xinha_config.formatblock = this.formatblock;
	xinha_config.toolbar = this.toolbarItems;
	xinha_config.height = this.height + 'px';
	xinha_config.pageStyle = this.pageStyle;	 
	xinha_config.URIs.insert_image_proxy = this.get_images_proxy;
	xinha_config.URIs.blank = this.blank_url;

	document.body.spellcheck=false;

	this.editor = Xinha.makeEditor(ta.dom, xinha_config);
	Xinha.startEditor(this.editor);
    },

    onFocus : Ext.emptyFn,
    validationEvent : false,

    initEvents : function(){
        this.originalValue = this.getValue();
    },
	syncValue : function(){
		this.editor.syncValue();
	},
    formatblock:{
	"p"   : {
	    text: "Normal Text",
	    cls: "x-menu-item-p"
	},
	"ul": {
	    text: "Bullet Text",
	    cls: "x-menu-item-ul",
	    code: "insertunorderedlist"
	},
	"pre"  : {
	    text: "Preformatted",
	    cls: "x-menu-item-pre"
	},
	"h1": {
	    text: "Heading",
	    cls: "x-menu-item-h1"
	},
	"h2": {
	    text: "Subheading",
	    cls: "x-menu-item-h2"
	},
	"h3": {
	    text: "Minor Heading",
	    cls: "x-menu-item-h3"
	}
    },
    toolbarItems:[
		  ['fullscreen',"separator","bold","italic","highlight","separator","createlink","insertimage","insertmath","separator","formatblock","separator","undo","redo","separator","htmlmode"]
		 ],
    applyTo:null,
    height:100,
    validationEvent : false,
    deferHeight: true,
    initialized : false,
    activated : false,
    sourceEditMode : false,
    onFocus : Ext.emptyFn
});



String.prototype.ellipse = function(maxLength){
    if(this.length > maxLength){
        return this.substr(0, maxLength-3) + '...';
    }
    return this;
};





// browser identificationparam
Xinha.agt       = navigator.userAgent.toLowerCase();
Xinha.is_ie	   = ((Xinha.agt.indexOf("msie") != -1) && (Xinha.agt.indexOf("opera") == -1));
Xinha.is_opera  = (Xinha.agt.indexOf("opera") != -1);
Xinha.is_mac	   = (Xinha.agt.indexOf("mac") != -1);
Xinha.is_mac_ie = (Xinha.is_ie && Xinha.is_mac);
Xinha.is_win_ie = (Xinha.is_ie && !Xinha.is_mac);
Xinha.is_gecko  = (navigator.product == "Gecko");
Xinha.isRunLocally = document.URL.toLowerCase().search(/^file:/) != -1;
if ( Xinha.isRunLocally )
{
  alert('HtmlEditor *must* be installed on a web server. Locally opened files (those that use the "file://" protocol) cannot properly function. HtmlEditor will try to initialize but may not be correctly loaded.');
}


// Creates a new Xinha object.  Tries to replace the textarea with the given
// ID with it.
function Xinha(textarea, config)
{

  if ( !textarea )
  {
    throw("Tried to create HtmlEditor without textarea specified.");
  }

  if ( Xinha.checkSupportedBrowser() )
  {
    if ( typeof config == "undefined" )
    {
      this.config = new Xinha.Config();
    }
    else
    {
      this.config = config;
    }
    this._htmlArea = null;

    if ( typeof textarea != 'object' )
    {
      textarea = Xinha.getElementById('textarea', textarea);
    }
    this._textArea = textarea;
    this._textArea.spellcheck = false;

    textAreaEl = Ext.get(textarea);
    // Before we modify anything, get the initial textarea size
    this._initial_ta_size =
    {
      w: textAreaEl.getComputedWidth()+'px',
      h: textAreaEl.getComputedHeight()+'px'
    };

	Ext.applyIf(this,config);
    this._editMode = "wysiwyg";
    this.plugins = {};
    this._timerToolbar = null;
    this._timerUndo = null;
    this._undoQueue = new Array(this.undoSteps);
    this._undoPos = -1;
    this._customUndo = true;
    this._mdoc = document; // cache the document, we need it in plugins
    this.doctype = '';


    this._notifyListeners = {};

    // Panels
    var panels = 
    {
      right:
      {
        on: true,
        container: document.createElement('td'),
        panels: []
      },
      left:
      {
        on: true,
        container: document.createElement('td'),
        panels: []
      },
      top:
      {
        on: true,
        container: document.createElement('td'),
        panels: []
      },
      bottom:
      {
        on: true,
        container: document.createElement('td'),
        panels: []
      }
    };

    for ( var i in panels )
    {
      if(!panels[i].container) { continue; } // prevent iterating over wrong type
      panels[i].div = panels[i].container; // legacy
      panels[i].container.className = 'panels ' + i;
      Xinha.freeLater(panels[i], 'container');
      Xinha.freeLater(panels[i], 'div');
    }
    // finally store the variable
    this._panels = panels;

    Xinha.freeLater(this, '_textArea');
  }
}



// cache some regexps
Xinha.RE_tagName  = /(<\/|<)\s*([^ \t\n>]+)/ig;
Xinha.RE_doctype  = /(<!doctype((.|\n)*?)>)\n?/i;
Xinha.RE_head     = /<head>((.|\n)*?)<\/head>/i;
Xinha.RE_body     = /<body[^>]*>((.|\n|\r|\t)*?)<\/body>/i;
Xinha.RE_Specials = /([\/\^$*+?.()|{}[\]])/g;
Xinha.RE_email    = /[_a-zA-Z\d\-\.]{3,}@[_a-zA-Z\d\-]{2,}(\.[_a-zA-Z\d\-]{2,})+/i;
Xinha.RE_url      = /(https?:\/\/)?(([a-z0-9_]+:[a-z0-9_]+@)?[a-z0-9_-]{2,}(\.[a-z0-9_-]{2,}){2,}(:[0-9]+)?(\/\S+)*)/i;
Xinha.HBC = 'rgb(222, 231, 236)'; //#dee7ec

Xinha.Config = function() {
  var cfg = this;






  // Width and Height
  //  you may set these as follows
  //  width = 'auto'      -- the width of the original textarea will be used
  //  width = 'toolbar'   -- the width of the toolbar will be used
  //  width = '<css measure>' -- use any css measurement, eg width = '75%'
  //
  //  height = 'auto'     -- the height of the original textarea
  //  height = '<css measure>' -- any css measurement, eg height = '480px'
  this.width  = "auto";
  this.height = "auto";

  // the next parameter specifies whether the toolbar should be included
  // in the size above, or are extra to it.  If false then it's recommended
  // to have explicit pixel sizes above (or on your textarea and have auto above)
  this.sizeIncludesBars = true;

  // the next parameter specifies whether the panels should be included
  // in the size above, or are extra to it.  If false then it's recommended
  // to have explicit pixel sizes above (or on your textarea and have auto above)
  this.sizeIncludesPanels = true;

  // each of the panels has a dimension, for the left/right it's the width
  // for the top/bottom it's the height.
  //
  // WARNING: PANEL DIMENSIONS MUST BE SPECIFIED AS PIXEL WIDTHS
  this.panel_dimensions =
  {
    left:   '200px', // Width
    right:  '200px',
    top:    '100px', // Height
    bottom: '100px'
  };

  // enable creation of a status bar?
  this.statusBar = true;

  // intercept ^V and use the Xinha paste command
  // If false, then passes ^V through to browser editor widget
  this.htmlareaPaste = false;

  
  // maximum size of the undo queue
  this.undoSteps = 20;

  // the time interval at which undo samples are taken
  this.undoTimeout = 100;	// 1/2 sec.

  // set this to true if you want to explicitly right-justify when 
  // setting the text direction to right-to-left
  this.changeJustifyWithDirection = false;

  // if true then Xinha will retrieve the full HTML, starting with the
  // <HTML> tag.
  this.fullPage = false;

  // style included in the iframe document
  this.pageStyle = "";

  // external stylesheets to load (REFERENCE THESE ABSOLUTELY)
  this.pageStyleSheets = [];

  // specify a base href for relative links
  this.baseHref = null;

  // when the editor is in different directory depth as the edited page relative image sources
  // will break the display of your images
  // this fixes an issue where Mozilla converts the urls of images and links that are on the same server 
  // to relative ones (../) when dragging them around in the editor (Ticket #448)
  this.expandRelativeUrl = true;
  
  //   we can strip the base href out of relative links to leave them relative, reason for this
  //   especially if you don't specify a baseHref is that mozilla at least (& IE ?) will prefix
  //   the baseHref to any relative links to make them absolute, which isn't what you want most the time.
  this.stripBaseHref = true;

  // and we can strip the url of the editor page from named links (eg <a href="#top">...</a>)
  //  reason for this is that mozilla at least (and IE ?) prefixes location.href to any
  //  that don't have a url prefixing them
  this.stripSelfNamedAnchors = true;

  // sometimes high-ascii in links can cause problems for servers (basically they don't recognise them)
  //  so you can use this flag to ensure that all characters other than the normal ascii set (actually
  //  only ! through ~) are escaped in URLs to % codes
  this.only7BitPrintablesInURLs = true;

  // if you are putting the HTML written in Xinha into an email you might want it to be 7-bit
  //  characters only.  This config option (off by default) will convert all characters consuming
  //  more than 7bits into UNICODE decimal entity references (actually it will convert anything
  //  below <space> (chr 20) except cr, lf and tab and above <tilde> (~, chr 7E))
  this.sevenBitClean = false;

  // sometimes we want to be able to replace some string in the html comng in and going out
  //  so that in the editor we use the "internal" string, and outside and in the source view
  //  we use the "external" string  this is useful for say making special codes for
  //  your absolute links, your external string might be some special code, say "{server_url}"
  //  an you say that the internal represenattion of that should be http://your.server/
  this.specialReplacements = {}; // { 'external_string' : 'internal_string' }

  // set to true if you want Word code to be cleaned upon Paste
  this.killWordOnPaste = true;

  // enable the 'Target' field in the Make Link dialog
  this.makeLinkShowsTarget = true;

  // CharSet of the iframe, default is the charset of the document
  this.charSet = Xinha.is_gecko ? document.characterSet : document.charset;

  // URL-s
  this.imgURL = "images/";


  // remove tags (these have to be a regexp, or null if this functionality is not desired)
  this.htmlRemoveTags = null;

  // Turning this on will turn all "linebreak" and "separator" items in your toolbar into soft-breaks,
  // this means that if the items between that item and the next linebreak/separator can
  // fit on the same line as that which came before then they will, otherwise they will
  // float down to the next line.


  // set to false if you want to allow JavaScript in the content, otherwise <script> tags are stripped out
  this.stripScripts = true;

  // see if the text just typed looks like a URL, or email address
  // and link it appropriatly
  // Note: Setting this option to false only affects Mozilla based browsers.
  // In InternetExplorer this is native behaviour and cannot be turned off.
  this.convertUrlsToLinks = true;

  /** CUSTOMIZING THE TOOLBAR
   * -------------------------
   *
   * It is recommended that you customize the toolbar contents in an
   * external file (i.e. the one calling Xinha) and leave this one
   * unchanged.  That's because when we (InteractiveTools.com) release a
   * new official version, it's less likely that you will have problems
   * upgrading Xinha.
   */
  this.toolbar = [];



  this.formatblock = {};

  this.customSelects = {};

  this.debug = true;
  this.URIs = {};


  this.btnList =
  {

	fullscreen: [ 'Full Screen (Ctrl+Shift+J)', ['ed_buttons_main.gif',8,0], false, function (e) { e.execCommand("fullscreen"); } ],
    bold: [ "Bold (Ctrl+B)", ["ed_buttons_main.gif",3,2], false, function(e) { e.execCommand("bold"); } ],
    italic: [ "Italic (Ctrl+I)", ["ed_buttons_main.gif",2,2], false, function(e) { e.execCommand("italic"); } ],
    highlight: [ "Highlight (Ctrl+H)", ["ed_buttons_main.gif",3,2], false, function(e) { e.execCommand("highlight"); } ],

	htmlmode: [ "View Source", ["ed_buttons_main.gif",2,3], false, function(e) { e.execCommand("htmlmode"); } ],
    insertunorderedlist: [ "Bulleted List", ["ed_buttons_main.gif",1,3], false, function(e) { e.execCommand("insertunorderedlist"); } ],

    undo: [ "Undo (Ctrl+Z)", ["ed_buttons_main.gif",4,2], false, function(e) { e.execCommand("undo"); } ],
    redo: [ "Redo (Ctrl+Y)", ["ed_buttons_main.gif",5,2], false, function(e) { e.execCommand("redo"); } ],

    createlink: [ "Create Link (Ctrl+K)", ["ed_buttons_main.gif",6,1], false, function(e) { e._createLink(); } ],
    insertimage: [ "Insert Image (Ctrl+Shift+G)", ["ed_buttons_main.gif",6,3], false, function(e) { e.execCommand("insertimage"); } ],

    removeformat: [ "Remove formatting", ["ed_buttons_main.gif",4,4], false, function(e) { e.execCommand("removeformat"); } ]
  };

  // initialize tooltips from the I18N module and generate correct image path
  for ( var i in this.btnList )
  {
    var btn = this.btnList[i];
    // prevent iterating over wrong type
    if ( typeof btn != 'object' )
    {
      continue;
    } 
	_editor_url='TESTME';
    if ( typeof btn[1] != 'string' )
    {
      btn[1][0] = _editor_url + this.imgURL + btn[1][0];
    }
    else
    {
      btn[1] = _editor_url + this.imgURL + btn[1];
    }
    btn[0] = Xinha._lc(btn[0]); //initialize tooltip
  }

};







/** Helper function: replaces the TEXTAREA with the given ID with Xinha. */
Xinha.replace = function(id, config)
{
  var ta = Xinha.getElementById("textarea", id);
  return ta ? (new Xinha(ta, config)).generate() : null;
};

// Creates the toolbar and appends it to the _htmlarea
Xinha.prototype._createToolbar = function ()
{


  var editor = this;	// to access this in nested functions

  var toolbar = document.createElement("div");
  // ._toolbar is for legacy, ._toolBar is better thanks.
  this._toolBar = this._toolbar = toolbar;
  toolbar.className = "toolbar";
  toolbar.unselectable = "1";

  Xinha.freeLater(this, '_toolBar');
  Xinha.freeLater(this, '_toolbar');
  
  var tb_row = null;
  var tb_objects = {};
  this._toolbarObjects = tb_objects;

	this._createToolbar1(editor, toolbar, tb_objects);


	this._htmlArea.appendChild(toolbar);      
  return toolbar;
};

Xinha.prototype._addToolbar = function()
{
	this._createToolbar1(this, this._toolbar, this._toolbarObjects);
};


// separate from previous createToolBar to allow dynamic change of toolbar
Xinha.prototype._createToolbar1 = function (editor, toolbar, tb_objects)
{


	var add_button = function (btn,id, toggle, handler){
		return {
				id : id,
				cls : 'x-btn-icon x-edit-'+id,
				enableToggle: toggle !== false,
				scope: editor,
				handler:handler||editor.relayBtnCmd,
				clickEvent:'mousedown',
				tooltip: btn[0],
				//tooltip: .buttonTips[id] || undefined,
				tabIndex:-1
		};
	};
	var cb = new Ext.CycleButton({
	    showText:true,
	    cls:'z-style-cb',
	    items:[{
		text:'Normal Text',
		iconCls:'z-menu-item-p',
		checked:true
	    },{
		text:'Bullet Text',
		iconCls:'z-menu-item-ul',
		code:"insertunorderedlist"
	    },{
		text:'Preformatted',
		iconCls:'z-menu-item-pre'
	    },{
		text:'Heading',
		iconCls:'z-menu-item-h1'
	    },{
		text:'Subheading',
		iconCls:'z-menu-item-h2'
	    },{
		text:'Minor Heading',
		iconCls:'z-menu-item-h3'
	    }],
	    changeHandler:Ext.emptyFn
	});

	var tb = new Ext.Toolbar({
	    renderTo:Ext.get(toolbar)
	});

	this._xo_toolbar = tb;
	Ext.get(toolbar).addClass('x-xinha-editor-tb');
	
	this.config.toolbar_buttons = new Array();
	
	for ( var i = 0; i < this.config.toolbar.length; ++i )
	{
		var group = this.config.toolbar[i];
		
		for ( var j = 0; j < group.length; ++j )
		{
			var code = group[j];
			if (code != "separator")
			{
				_btn = editor.config.btnList[code];
				
				if (_btn) {
					var btn_handler = function(btn) {
						editor.execCommand(btn.id,false,null);
					}

					var toggle = false;
					switch (code)
					{
						case "bold":
						case "italics":
						case "underline":
						case "insertunorderedlist":
						case "highlight":
							toggle = true;
						break;
					}
					//add button
					var b = tb.addButton(add_button(_btn,code,toggle,btn_handler));
					//keep to a global variable for use in updateToolbar()
					this.config.toolbar_buttons[code] = b;
					b.setDisabled(true);
				}
				else
				{
					switch (code) {
					case "formatblock":
						//menu item onclick handler
						var onItemClick = function(itm){
						    //HERE:we should unlink if its a header
						    //We should merge with previous if we are and it is a PRE
							editor.execCommand(itm.cmd,false,'<' + itm.value + '>');
							itm.menubutton.setText(itm.text);
						}						
						var formatmenu = new Ext.menu.Menu();
						
						var formatmenubutton = new Ext.Toolbar.SplitButton({
							id: 'formatblock',
							text: 'Style',
								//handler: onButtonClick,
								tooltip: {text:'This is a QuickTip with autoHide set to false and a title', title:'Tip Title', autoHide:false},
								cls: 'x-edit-style'
						});
						//keep to a global variable for use in updateToolbar() 
						this.config.toolbar_buttons[code] = formatmenubutton;
						//iterate through menu options (see mytest.html)
						var options = editor.config[code];
						for ( var i in options )
						{
							// prevent iterating over wrong type
							if ( typeof(options[i]) != 'string' )
							{
								//continue;
							}
							formatmenu.add(
								{text: options[i].text,
								cmd:options[i].code || code,
								menubutton:formatmenubutton,
								value:i,
								handler: onItemClick,
								cls:options[i].cls
							});
						}
						formatmenu.cls = "x-xinha-editor-tb";
						formatmenubutton.menu = formatmenu;
						tb.add(formatmenubutton);
						formatmenubutton.setDisabled(true);
						break;

					}
				}
			}
			else
				tb.addSeparator();
		}
	}
	return;
	//AK Change
};

Xinha.prototype.syncValue = function () {
	var s, html;
    html = this.getHTML();
    var s = this.outwardHtml(html);
    this._textArea.value = s.replace(/\xAD\xA0/g,'');
    return true;
}

// Creates the Xinha object and replaces the textarea with it.
Xinha.prototype.generate = function ()
{
  var i;
  var editor = this;  // we'll need "this" in some nested functions


  // create the editor framework, yah, table layout I know, but much easier
  // to get it working correctly this way, sorry about that, patches welcome.

  this._framework =
  {
    'table':   document.createElement('table'),
    'tbody':   document.createElement('tbody'), // IE will not show the table if it doesn't have a tbody!
    'tb_row':  document.createElement('tr'),
    'tb_cell': document.createElement('td'), // Toolbar

    'tp_row':  document.createElement('tr'),
    'tp_cell': this._panels.top.container,   // top panel

    'ler_row': document.createElement('tr'),
    'lp_cell': this._panels.left.container,  // left panel
    'ed_cell': document.createElement('td'), // editor
    'rp_cell': this._panels.right.container, // right panel

    'bp_row':  document.createElement('tr'),
    'bp_cell': this._panels.bottom.container// bottom panel


  };
  Xinha.freeLater(this._framework);
  
  var fw = this._framework;
  fw.table.border = "0";
  fw.table.cellPadding = "0";
  fw.table.cellSpacing = "0";

  fw.tb_row.style.verticalAlign = 'top';
  fw.tp_row.style.verticalAlign = 'top';
  fw.ler_row.style.verticalAlign= 'top';
  fw.bp_row.style.verticalAlign = 'top';

  fw.ed_cell.style.position     = 'relative';

  // Put the cells in the rows        set col & rowspans
  // note that I've set all these so that all panels are showing
  // but they will be redone in sizeEditor() depending on which
  // panels are shown.  It's just here to clarify how the thing
  // is put togethor.
  fw.tb_row.appendChild(fw.tb_cell);
  fw.tb_cell.colSpan = 3;

  fw.tp_row.appendChild(fw.tp_cell);
  fw.tp_cell.colSpan = 3;

  fw.ler_row.appendChild(fw.lp_cell);
  fw.ler_row.appendChild(fw.ed_cell);
  fw.ler_row.appendChild(fw.rp_cell);

  fw.bp_row.appendChild(fw.bp_cell);
  fw.bp_cell.colSpan = 3;


  // Put the rows in the table body
  fw.tbody.appendChild(fw.tb_row);  // Toolbar
  fw.tbody.appendChild(fw.tp_row); // Left, Top, Right panels
  fw.tbody.appendChild(fw.ler_row);  // Editor/Textarea
  fw.tbody.appendChild(fw.bp_row);  // Bottom panel

  // and body in the table
  fw.table.appendChild(fw.tbody);

  var xinha = this._framework.table;
  this._htmlArea = xinha;
  Xinha.freeLater(this, '_htmlArea');
  xinha.className = "htmlarea";

    // create the toolbar and put in the area
  this._framework.tb_cell.appendChild( this._createToolbar() );

    // create the IFRAME & add to container
  var iframe = document.createElement("iframe");
    //iframe.src = _editor_url + editor.config.URIs.blank;
    iframe.src = editor.config.URIs.blank;
  this._framework.ed_cell.appendChild(iframe);
  this._iframe = iframe;
  this._iframe.className = 'xinha_iframe';
  Xinha.freeLater(this, '_iframe');

  // insert Xinha before the textarea.
  textarea = this._textArea;
  Ext.get(xinha).insertBefore(Ext.get(textarea));
  textarea.className = 'xinha_textarea';

  // extract the textarea and insert it into the xinha framework
  Xinha.removeFromParent(textarea);
  this._framework.ed_cell.appendChild(textarea);


  // Set up event listeners for saving the iframe content to the textarea
  if ( textarea.form )
  {

      var initialTAContent = textarea.value;

    // onsubmit get the Xinha content and update original textarea.
	formEl=Ext.get(textarea.form);
	formEl.on(
      'submit',
      function()
      {
	try {
		var s = editor.outwardHtml(editor.getHTML());
		editor._textArea.value = s.replace(/\xAD\xA0/g,'');
	} catch (ex) {
		//do nothing
	}
        return true;
      }
    );




    // onreset revert the Xinha content to the textarea content
	formEl.on(
      'reset',
      function()
      {
	try {
	        editor.setHTML(editor.inwardHtml(initialTAContent));
        	editor.updateToolbar(false);
	} catch (ex) {
		// do nothing
	}
        return true;
      }
    );

  }

  // add a handler for the "back/forward" case -- on body.unload we save
  // the HTML content into the original textarea.
	Ext.lib.Event.on(
    window,
    'unload',
    function()
    {
	try {
		var s = editor.outwardHtml(editor.getHTML());
		textarea.value = s;
		if (!Xinha.is_ie) {
		    xinha.parentNode.replaceChild(textarea,xinha);
		    textarea.style.display='block';
		}
		Xinha.collectGarbage();
	} catch (ex) {
		// do nothing
	}
	return true;
    }
  );

  // Hide textarea
  textarea.style.display = "none";

  // Initalize size
  editor.initSize();

  // Add an event to initialize the iframe once loaded.
  editor._iframeLoadDone = false;
  Xinha._addEvent(
    this._iframe,
    'load',
    function(e)
    {
      if ( !editor._iframeLoadDone )
      {
        editor._iframeLoadDone = true;
        editor.initIframe();
      }
      return true;
    }
  );

};

/**
 * Size the editor according to the INITIAL sizing information.
 * config.width
 *    The width may be set via three ways
 *    auto    = the width is inherited from the original textarea
 *    toolbar = the width is set to be the same size as the toolbar
 *    <set size> = the width is an explicit size (any CSS measurement, eg 100em should be fine)
 *
 * config.height
 *    auto    = the height is inherited from the original textarea
 *    <set size> = an explicit size measurement (again, CSS measurements)
 *
 * config.sizeIncludesBars
 *    true    = the tool & status bars will appear inside the width & height confines
 *    false   = the tool & status bars will appear outside the width & height confines
 *
 */

Xinha.prototype.initSize = function()
{
  var editor = this;
  var width = null;
  var height = null;

  switch ( this.config.width )
  {
    case 'auto':
      width = this._initial_ta_size.w;
    break;

    case 'toolbar':
      width = this._toolBar.offsetWidth + 'px';
    break;

    default :
      // @todo: check if this is better :
      // width = (parseInt(this.config.width, 10) == this.config.width)? this.config.width + 'px' : this.config.width;
      width = /[^0-9]/.test(this.config.width) ? this.config.width : this.config.width + 'px';
    break;
  }

  switch ( this.config.height )
  {
    case 'auto':
      height = this._initial_ta_size.h;
    break;

    default :
      // @todo: check if this is better :
      // height = (parseInt(this.config.height, 10) == this.config.height)? this.config.height + 'px' : this.config.height;
      height = /[^0-9]/.test(this.config.height) ? this.config.height : this.config.height + 'px';
    break;
  }

  this.sizeEditor(width, height, this.config.sizeIncludesBars, this.config.sizeIncludesPanels);

  // why can't we use the following line instead ?
//  this.notifyOn('panel_change',this.sizeEditor);
//  this.notifyOn('panel_change',function() { editor.sizeEditor(); });
};

/**
 *  Size the editor to a specific size, or just refresh the size (when window resizes for example)
 *  @param width optional width (CSS specification)
 *  @param height optional height (CSS specification)
 *  @param includingBars optional boolean to indicate if the size should include or exclude tool & status bars
 */
Xinha.prototype.sizeEditor = function(width, height, includingBars, includingPanels)
{

  // We need to set the iframe & textarea to 100% height so that the htmlarea
  // isn't "pushed out" when we get it's height, so we can change them later.
  this._iframe.style.height   = '100%';
  this._textArea.style.height = '100%';
  this._iframe.style.width    = '';
  this._textArea.style.width  = '';

  if ( includingBars !== null )
  {
    this._htmlArea.sizeIncludesToolbars = includingBars;
  }
  if ( includingPanels !== null )
  {
    this._htmlArea.sizeIncludesPanels = includingPanels;
  }

  if ( width )
  {
    this._htmlArea.style.width = width;
    if ( !this._htmlArea.sizeIncludesPanels )
    {
      // Need to add some for l & r panels
      var rPanel = this._panels.right;
      if ( rPanel.on && rPanel.panels.length && Xinha.hasDisplayedChildren(rPanel.div) )
      {
        this._htmlArea.style.width = (this._htmlArea.offsetWidth + parseInt(this.config.panel_dimensions.right, 10)) + 'px';
      }

      var lPanel = this._panels.left;
      if ( lPanel.on && lPanel.panels.length && Xinha.hasDisplayedChildren(lPanel.div) )
      {
        this._htmlArea.style.width = (this._htmlArea.offsetWidth + parseInt(this.config.panel_dimensions.left, 10)) + 'px';
      }
    }
  }

  if ( height )
  {
    this._htmlArea.style.height = height;
    if ( !this._htmlArea.sizeIncludesToolbars )
    {
      // Need to add some for toolbars
      this._htmlArea.style.height = (this._htmlArea.offsetHeight + this._toolbar.offsetHeight ) + 'px';
    }

    if ( !this._htmlArea.sizeIncludesPanels )
    {
      // Need to add some for t & b panels
      var tPanel = this._panels.top;
      if ( tPanel.on && tPanel.panels.length && Xinha.hasDisplayedChildren(tPanel.div) )
      {
        this._htmlArea.style.height = (this._htmlArea.offsetHeight + parseInt(this.config.panel_dimensions.top, 10)) + 'px';
      }

      var bPanel = this._panels.bottom;
      if ( bPanel.on && bPanel.panels.length && Xinha.hasDisplayedChildren(bPanel.div) )
      {
        this._htmlArea.style.height = (this._htmlArea.offsetHeight + parseInt(this.config.panel_dimensions.bottom, 10)) + 'px';
      }
    }
  }

  // At this point we have this._htmlArea.style.width & this._htmlArea.style.height
  // which are the size for the OUTER editor area, including toolbars and panels
  // now we size the INNER area and position stuff in the right places.
  width  = this._htmlArea.offsetWidth;
  height = this._htmlArea.offsetHeight;

  // Set colspan for toolbar, and statusbar, rowspan for left & right panels, and insert panels to be displayed
  // into thier rows
  var panels = this._panels;
  var editor = this;
  var col_span = 1;

  function panel_is_alive(pan)
  {
    if ( panels[pan].on && panels[pan].panels.length && Xinha.hasDisplayedChildren(panels[pan].container) )
    {
      panels[pan].container.style.display = '';
      return true;
    }
    // Otherwise make sure it's been removed from the framework
    else
    {
      panels[pan].container.style.display='none';
      return false;
    }
  }

  if ( panel_is_alive('left') )
  {
    col_span += 1;      
  }

//  if ( panel_is_alive('top') )
//  {
    // NOP
//  }

  if ( panel_is_alive('right') )
  {
    col_span += 1;
  }

//  if ( panel_is_alive('bottom') )
//  {
    // NOP
//  }

  this._framework.tb_cell.colSpan = col_span;
  this._framework.tp_cell.colSpan = col_span;
  this._framework.bp_cell.colSpan = col_span;


  // Put in the panel rows, top panel goes above editor row
  if ( !this._framework.tp_row.childNodes.length )
  {
    Xinha.removeFromParent(this._framework.tp_row);
  }
  else
  {
    if ( !Xinha.hasParentNode(this._framework.tp_row) )
    {
      this._framework.tbody.insertBefore(this._framework.tp_row, this._framework.ler_row);
    }
  }

  // bp goes after the editor
  if ( !this._framework.bp_row.childNodes.length )
  {
    Xinha.removeFromParent(this._framework.bp_row);
  }
  else
  {
    if ( !Xinha.hasParentNode(this._framework.bp_row) )
    {
      this._framework.tbody.insertBefore(this._framework.bp_row, this._framework.ler_row.nextSibling);
    }
  }


  // Size and set colspans, link up the framework
  this._framework.lp_cell.style.width  = this.config.panel_dimensions.left;
  this._framework.rp_cell.style.width  = this.config.panel_dimensions.right;
  this._framework.tp_cell.style.height = this.config.panel_dimensions.top;
  this._framework.bp_cell.style.height = this.config.panel_dimensions.bottom;
  this._framework.tb_cell.style.height = this._toolBar.offsetHeight + 'px';


  var edcellheight = height - this._toolBar.offsetHeight;
  if ( panel_is_alive('top') )
  {
    edcellheight -= parseInt(this.config.panel_dimensions.top, 10);
  }
  if ( panel_is_alive('bottom') )
  {
    edcellheight -= parseInt(this.config.panel_dimensions.bottom, 10);
  }
  this._iframe.style.height = edcellheight + 'px';  

  
  var edcellwidth = width;
  if ( panel_is_alive('left') )
  {
    edcellwidth -= parseInt(this.config.panel_dimensions.left, 10);
  }
  if ( panel_is_alive('right') )
  {
    edcellwidth -= parseInt(this.config.panel_dimensions.right, 10);    
  }
  this._iframe.style.width = edcellwidth + 'px';

  this._textArea.style.height = this._iframe.style.height;
  this._textArea.style.width  = this._iframe.style.width;
     

};


Xinha.objectProperties = function(obj)
{
  var props = [];
  for ( var x in obj )
  {
    props[props.length] = x;
  }
  return props;
};

/*
 * EDITOR ACTIVATION NOTES:
 *  when a page has multiple Xinha editors, ONLY ONE should be activated at any time (this is mostly to
 *  work around a bug in Mozilla, but also makes some sense).  No editor should be activated or focused
 *  automatically until at least one editor has been activated through user action (by mouse-clicking in
 *  the editor).
 */
Xinha.prototype.editorIsActivated = function()
{
  try
  {
    return Xinha.is_gecko? this._doc.designMode == 'on' : this._doc.body.contentEditable;
  }
  catch (ex)
  {
    return false;
  }
};

Xinha._someEditorHasBeenActivated = false;
Xinha._currentlyActiveEditor      = false;
Xinha.prototype.activateEditor = function()
{
  // We only want ONE editor at a time to be active
  if ( Xinha._currentlyActiveEditor ) {
    if ( Xinha._currentlyActiveEditor == this ) {
      return true;
    }
    Xinha._currentlyActiveEditor.deactivateEditor();
  }

  if ( Xinha.is_gecko && this._doc.designMode != 'on' ) {
    try {
	var FFSpellChecker = false;
	this._doc.body.spellcheck = FFSpellChecker;

      // cannot set design mode if no display
      if ( this._iframe.style.display == 'none' ) {
        this._iframe.style.display = '';
        this._doc.designMode = 'on';
        this._iframe.style.display = 'none';
      }
      else
      {

	  this._doc.designMode = 'on';
      }


	var DisableObjectResizing=true;
	var DisableFFTableHandles=true;


	// http://dev.fckeditor.net/browser/FCKeditor/trunk/editor/_source/classes/fckeditingarea.js?rev=445
	// Tell Gecko (Firefox 1.5+) to enable or not live resizing of objects (by Alfonso Martinez)
	this._doc.execCommand( 'enableObjectResizing', false, !DisableObjectResizing ) ;
	// Disable the standard table editing features of Firefox.
	this._doc.execCommand( 'enableInlineTableEditing', false, !FCKConfig.DisableFFTableHandles ) ;

    } catch (ex) {}
  }
  else if ( !Xinha.is_gecko && this._doc.body.contentEditable !== true )
  {
    this._doc.body.contentEditable = true;
  }
 

  // We need to know that at least one editor on the page has been activated
  // this is because we will not focus any editor until an editor has been activated
  Xinha._someEditorHasBeenActivated = true;
  Xinha._currentlyActiveEditor      = this;
  var editor = this;
  editor._undoTakeSnapshot();
  this.enableToolbar();
};

Xinha.prototype.deactivateEditor = function()
{
  // If the editor isn't active then the user shouldn't use the toolbar
  this.disableToolbar();

  if ( Xinha.is_gecko && this._doc.designMode != 'off' )
  {
    try
    {
      this._doc.designMode = 'off';
    } catch (ex) {}
  }
  else if ( !Xinha.is_gecko && this._doc.body.contentEditable !== false )
  {
    this._doc.body.contentEditable = false;
  }

  if ( Xinha._currentlyActiveEditor != this )
  {
    // We just deactivated an editor that wasn't marked as the currentlyActiveEditor

    return; // I think this should really be an error, there shouldn't be a situation where
            // an editor is deactivated without first being activated.  but it probably won't
            // hurt anything.
  }

  Xinha._currentlyActiveEditor = false;
};


function addCSS(doc, cssCode) {
var styleElement = doc.createElement("style");
  styleElement.type = "text/css";
  if (styleElement.styleSheet) {
    styleElement.styleSheet.cssText = cssCode;
  } else {
    styleElement.appendChild(document.createTextNode(cssCode));
  }
  doc.getElementsByTagName("head")[0].appendChild(styleElement);
}


Xinha.prototype.initIframe = function()
{
  this.disableToolbar();

  var doc = null;
  var editor = this;
  try {
    if ( editor._iframe.contentDocument ) {
      this._doc = editor._iframe.contentDocument;        
    } else {
      this._doc = editor._iframe.contentWindow.document;
    }
    doc = this._doc;
    // try later
    if ( !doc ) {
      if ( Xinha.is_gecko ) {
	  setTimeout(function() { editor.initIframe(); }, 50);
	  return false;
      } else {
	  alert("ERROR: IFRAME can't be initialized.");
      }
    }
  } catch(ex) {
      // try later
      setTimeout(function() { editor.initIframe(); }, 50);
	return false;
  }
  
  Xinha.freeLater(this, '_doc');
  
  doc.open("text/html","replace");
  var html = '';
  if ( !editor.config.fullPage )
  {
      //html += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n';
      html += "<html>\n";
      //html += "<head>\n";
      //html += "<title>STX</title>\n";
      //html += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=" + editor.config.charSet + "\">\n";
    if ( typeof editor.config.baseHref != 'undefined' && editor.config.baseHref !== null )
    {
      html += "<base href=\"" + editor.config.baseHref + "\"/>\n";
    }

    var coreCSS = "html, body { border:0px; } \n"
    + "body { background-color:#ffffff; } \n" 
    + ".bold { font-weight:bold; } \n" 
    + ".italic { font-style:italic; } \n" 
    + ".highlight { background-color:rgb(255,255,204); } \n" 


    if ( editor.config.pageStyle )
    {
	coreCSS += editor.config.pageStyle;
    }

    if ( typeof editor.config.pageStyleSheets !== 'undefined' )
    {
      for ( var i = 0; i < editor.config.pageStyleSheets.length; i++ )
      {
        if ( editor.config.pageStyleSheets[i].length > 0 )
        {
	    //html += "<link rel=\"stylesheet\" type=\"text/css\" href=\"" + editor.config.pageStyleSheets[i] + "\">";
          coreCSS += " @import url('" + editor.config.pageStyleSheets[i] + "'); \n";
        }
      }
    }
    //html += "<style type=\"text/css\">\n" + coreCSS +"\n</style>\n";


    //html += "</head> ";
    html += "<body>";
    html +=   editor.inwardHtml(editor._textArea.value);
    html += "</body>";
    html += "</html>";

  }
  else
  {
    html = editor.inwardHtml(editor._textArea.value);
    if ( html.match(Xinha.RE_doctype) )
    {
      editor.setDoctype(RegExp.$1);
      html = html.replace(Xinha.RE_doctype, "");
    }
    
    //Fix Firefox problem with link elements not in right place (just before head)
    var match = html.match(/<link\s+[\s\S]*?["']\s*\/?>/gi);
    html = html.replace(/<link\s+[\s\S]*?["']\s*\/?>\s*/gi, '');
    match ? html = html.replace(/<\/head>/i, match.join('\n') + "\n</head>") : null;    
  }

try {
  doc.write(html);
} catch(ex) {
  if (window['console']) {
    console.log("phigita: exception caught...");
    console.log(ex);
  }
}

  doc.close();

try {
  addCSS(doc,coreCSS);
} catch (ex) {
  if (window['console']) {
    console.log("phigita: exception caught...");
  }
}
  this.setEditorEvents();
};
  
/**
 * Delay a function until the document is ready for operations.
 * See ticket:547
 * @param {object} F (Function) The function to call once the document is ready
 * @public
 */
Xinha.prototype.whenDocReady = function(F)
{
  var E = this;
  if ( this._doc && this._doc.body )
  {
    F();
  }
  else
  {
    setTimeout(function() { E.whenDocReady(F); }, 50);
  }
};

// Switches editor mode; parameter can be "textmode" or "wysiwyg".  If no
// parameter was passed this function toggles between modes.
Xinha.prototype.setMode = function(mode)
{
  var html;
  if ( typeof mode == "undefined" )
  {
    mode = this._editMode == "textmode" ? "wysiwyg" : "textmode";
  }
  switch ( mode )
  {
    case "textmode":
      this.setCC("iframe");
      html = this.outwardHtml(this.getHTML());
      this.setHTML(html);

      // Hide the iframe
      this.deactivateEditor();
      this._iframe.style.display   = 'none';
      this._textArea.style.display = '';

//      this.notifyOf('modechange', {'mode':'text'});
      this.findCC("textarea"); 
    break;

    case "wysiwyg":
      this.setCC("textarea");
      html = this.inwardHtml(this.getHTML());
      this.deactivateEditor();
      this.setHTML(html);
      this._iframe.style.display   = '';
      this._textArea.style.display = "none";
      this.activateEditor();
//      this.notifyOf('modechange', {'mode':'wysiwyg'});
      this.findCC("iframe");
    break;

    default:
      alert("Mode <" + mode + "> not defined!");
      return false;
  }
  this._editMode = mode;

  if ( this._customUndo && this._editMode == 'wysiwyg') {
    this._undoTakeSnapshot();
  }

  for ( var i in this.plugins )
  {
    var plugin = this.plugins[i].instance;
    if ( plugin && typeof plugin.onMode == "function" )
    {
      plugin.onMode(mode);
    }
  }
};

Xinha.prototype.setFullHTML = function(html)
{
  var save_multiline = RegExp.multiline;
  RegExp.multiline = true;
  if ( html.match(Xinha.RE_doctype) )
  {
    this.setDoctype(RegExp.$1);
    html = html.replace(Xinha.RE_doctype, "");
  }
  RegExp.multiline = save_multiline;
  if ( !Xinha.is_ie )
  {
    if ( html.match(Xinha.RE_head) )
    {
      this._doc.getElementsByTagName("head")[0].innerHTML = RegExp.$1;
    }
    if ( html.match(Xinha.RE_body) )
    {
      this._doc.getElementsByTagName("body")[0].innerHTML = RegExp.$1;
    }
  }
  else
  {
    // FIXME - can we do this without rewriting the entire document
    //  does the above not work for IE?
    var reac = this.editorIsActivated();
    if ( reac )
    {
      this.deactivateEditor();
    }
    var html_re = /<html>((.|\n)*?)<\/html>/i;
    html = html.replace(html_re, "$1");
    this._doc.open("text/html","replace");
    this._doc.write(html);
    this._doc.close();
    if ( reac )
    {
      this.activateEditor();
    }        
    this.setEditorEvents();
    return true;
  }
};

Xinha.prototype.onPasteHandler = function (editor,event) {
     setTimeout(function() {
	if (editor._doc.body.innerHTML.length > editor._xo_length + 1) {
	    editor._xo_length = editor._doc.body.innerHTML.length;
	    editor.deactivateEditor();
	    editor._wordClean();
	    editor._xo_length = editor._doc.body.innerHTML.length;
	    editor.activateEditor();
	}
          // editor cleaning code goes here
     }, 1); // 1ms should be enough
}

Xinha.prototype.setEditorEvents = function()
{
  var editor=this;
  var doc=this._doc;
  editor.whenDocReady(
    function() {
      // if we have multiple editors some bug in Mozilla makes some lose editing ability
      Xinha._addEvents(
        doc,
        ["mousedown"],
        function()
        {
          editor.activateEditor();
          return true;
        }
      );

      Xinha._addEvents(
        doc,
        ["keydown","keypress"],
        function (event) {
		//return editor._editorEvent(Xinha.is_ie ? editor._iframe.contentWindow.event : event);
		return editor._editorEvent(event);
        }
      );

      Xinha._addEvents(
        doc,
        ["mousedown","mouseup", "drag"],
        function (event) {
	  editor._xo_length = editor._doc.body.innerHTML.length;
	  return editor._editorEvent(event);
	  //result = editor._editorEvent(Xinha.is_ie ? editor._iframe.contentWindow.event : event);
	  //editor.onPasteHandler(editor,event);
	  //return result;
        }
      );

      // specific editor initialization
      if ( typeof editor._onGenerate == "function" )
      {
        editor._onGenerate();
      }

	Ext.EventManager.onWindowResize(function(e) { editor.sizeEditor(); });
    }
  );
};
  



/***************************************************
 *  Category: EDITOR UTILITIES
 ***************************************************/


Xinha.getInnerText = function(el)
{
  var txt = '', i;
  for ( i = el.firstChild; i; i = i.nextSibling )
  {
    if ( i.nodeType == 3 )
    {
      txt += i.data;
    }
    else if ( i.nodeType == 1 )
    {
      txt += Xinha.getInnerText(i);
    }
  }
  return txt;
};

Xinha.prototype._wordClean = function() {
  var editor = this;

  function clearClass(node) {
      if (node.getAttribute('_xo') == null) node.setAttribute('class','');
      node.removeAttribute('class');
  }
  
  function clearStyle(node) {
      node.style.cssText = '';
      node.removeAttribute('style');
      if (node.getAttribute('_xo') != 1) {
	  for (k=0; k< node.attributes.length; k++) {
	      attname = node.attributes[k].nodeName;
	      if (attname != 'class' && attname != 'href' && attname != 'src') {
		  node.removeAttribute(attname);
	      }
	  }
      }
  }
  
  function _xo_insertBefore (_xo_node,_xo_ref) {
      _xo_ref.parentNode.insertBefore(_xo_node,_xo_ref);
  }


  function transformTag(_xo_el,tag) {
      var _xo_style = [];

      if ( ['strong','em','b','i','u','span','font'].contains(tag) && _xo_el.style) {
	  _xo_tmp = Ext.fly(_xo_el);
	  if (tag == 'strong' || tag == 'b' || _xo_tmp.getStyle('font-weight') == 'bold') {
	      _xo_style.push('bold');
	  }
	  if (Xinha.is_ie) {
	      if (_xo_tmp.getStyle('background-color') != 16777215) {
		  _xo_style.push('highlight');
	      }
	  } else {
	      if (_xo_tmp.getStyle('background-color') != 'transparent') {
		  _xo_style.push('highlight');
	      }
	  }
	  if (tag == 'em' || tag == 'i' || _xo_tmp.getStyle('font-style') == 'italic') {
	      _xo_style.push('italic');
	  }
      }
      
      _xo_ref = getReferenceNode(_xo_el);
      
      if ( tag == 'img') {
	  alt = _xo_el.getAttribute('alt');
	  if (alt != null && alt.trim() != '') {
	      _xo_insertBefore(editor._doc.createTextNode('['+alt+']'),_xo_ref);
	  }
	  Xinha.removeFromParent(_xo_el);
	  return;
      }
      
      if (['br','hr'].contains(tag)) {
	  _xo_insertBefore(editor._doc.createTextNode(' '),_xo_ref);
	  Xinha.removeFromParent(el);
	  return;
      }
      
      
      if (_xo_style.length) {
	  _xo_node = editor._doc.createElement('font');
	  _xo_node.setAttribute('_xo',1);
	  _xo_node.setAttribute('class',_xo_style.join(' '));
	  for ( i = 0; i < _xo_el.childNodes.length; i++) {
	      _xo_node.appendChild(_xo_el.childNodes[i]);
	  }
	  _xo_insertBefore(_xo_node,_xo_ref);
	  Xinha.removeFromParent(_xo_el);
	  return;
      } else {
	  _xo_node = _xo_el;
	  _xo_insertBefore(_xo_node,_xo_ref);
	  return _xo_node;
      }
  }

  // ,'form','div','blockquote','small','large','center','strong','em','b','i','u','span','font'
  // ['table','thead','tbody','tr','th','td']

/*
      if (_xo_ref.parentNode == editor._doc.body && (_xo_node.nodeType !=1 || !['p','h1','h2','h3','ul','pre'].contains(_xo_node.tagName.toLowerCase())) ) {
	  _xo_p = editor._doc.createElement('p');
	  _xo_ref.parentNode.insertBefore(_xo_p,_xo_ref);
	  _xo_p.appendChild(_xo_node);
	  _xo_node = _xo_p;
      }

*/

  function getReferenceNode (_xo_ref) {
      while (!['body','p','pre','h1','h2','h3','ul','li','a'].contains(_xo_ref.parentNode.tagName.toLowerCase())) {
	  _xo_ref = _xo_ref.parentNode;
      }
      return _xo_ref;
  }
		      //	      if ( _xo_tmp && ['table','tr','td','thead','tbody','th','form','div','blockquote','small','large','center'].contains(tag) && _xo_tmp.getAttribute('_xo') != 1) {
  
  function parseTreeAux(root) {

      _xo_ref = getReferenceNode(root);

      if (root.nodeType == 1) {

	  var tag = root.tagName.toLowerCase();

	  if ( tag == 'img') {
	      alt = root.getAttribute('alt');
	      if (alt != null && alt.trim() != '') {
		  _xo_insertBefore(editor._doc.createTextNode('['+alt+']'),_xo_ref);
	      }
	      Xinha.removeFromParent(root);
	      return;
	  }

	  if ( tag == 'br' ) {
	      return;
	  }

	  clearClass(root);
	  //_xo_tmp=transformTag(root,tag);
	  clearStyle(root);

	  if ( ( Xinha.is_ie && root.scopeName != 'HTML' ) || ['script','style','object','embed','input','textarea','iframe','frame'].contains(tag) ) {
	      Xinha.removeFromParent(root);
	  } else if ( !['body','p','pre','h1','h2','h3','ul','li','a'].contains(tag) && root.getAttribute('_xo') != 1) {
	      _xo_ref.parentNode.insertBefore(editor._doc.createTextNode(' '),_xo_ref); 
	      parseTree(root);
	      Xinha.removeFromParent(root);
	  } else {
	      _xo_ref.parentNode.insertBefore(root,_xo_ref); 
	      parseTree(root);
	  }

      } else {
	  _xo_insertBefore(root,_xo_ref);
      }
  }

  function parseTree (root) {


      var i,next;
      for ( i = root.firstChild; i; i = next ) {
	  next = i.nextSibling;
	  parseTreeAux(i);
      }
  }


  parseTree(this._doc.body);

  this.updateToolbar();
};


Xinha.prototype.forceRedraw = function() {
  this._doc.body.style.visibility = "hidden";
  this._doc.body.style.visibility = "visible";
  // this._doc.body.innerHTML = this.getInnerHTML();
};

// focuses the iframe window.  returns a reference to the editor document.
Xinha.prototype.focusEditor = function()
{
  switch (this._editMode)
  {
    // notice the try { ... } catch block to avoid some rare exceptions in FireFox
    // (perhaps also in other Gecko browsers). Manual focus by user is required in
    // case of an error. Somebody has an idea?
    case "wysiwyg" :
      try
      {
        // We don't want to focus the field unless at least one field has been activated.
        if ( Xinha._someEditorHasBeenActivated )
        {
          this.activateEditor(); // Ensure *this* editor is activated
          this._iframe.contentWindow.focus(); // and focus it
        }
      } catch (ex) {}
    break;
    case "textmode":
      try
      {
        this._textArea.focus();
      } catch (e) {}
    break;
    default:
      alert("ERROR: mode " + this._editMode + " is not defined");
  }
  return this._doc;
};

// takes a snapshot of the current text (for undo)
Xinha.prototype._undoTakeSnapshot = function()
{

  if (this._editMode != 'wysiwyg') {
	return;
  }
  ++this._undoPos;
  if ( this._undoPos >= this.undoSteps )
  {
    // remove the first element
    this._undoQueue.shift();
    --this._undoPos;
  }
	var fan = this.getParentElement();
  // use the fasted method (getInnerHTML);
  var take = true;
  //this.setCC('iframe');
  var txt = this.getInnerHTML();
  //this.findCC('iframe');
  if ( this._undoPos > 0 )
  {
    take = (this._undoQueue[this._undoPos - 1] != txt);
  }
  if ( take )
  {
    this._undoQueue[this._undoPos] = txt;
  }
  else
  {
    this._undoPos--;
  }
};

Xinha.prototype.undo = function()
{
  if ( this._undoPos > 0 )
  {
    var txt = this._undoQueue[--this._undoPos];
    if ( txt ) {
      this.setHTML(txt);
	el=Ext.get(this._doc.body).first('p');
	this.gotoNode(el.dom);
    } else {
      ++this._undoPos;
    }
  }
};

Xinha.prototype.redo = function()
{
  if ( this._undoPos < this._undoQueue.length - 1 )
  {
    var txt = this._undoQueue[++this._undoPos];
    if ( txt ) {
      this.setHTML(txt);
	el=Ext.get(this._doc.body).first('p');
	this.gotoNode(el.dom);
    } else {
      --this._undoPos;
    }
  }
};

Xinha.prototype.disableToolbar = function(except)
{
  if ( this._timerToolbar )
  {
    clearTimeout(this._timerToolbar);
  }
  if ( typeof except == 'undefined' )
  {
    except = [ ];
  }
  else if ( typeof except != 'object' )
  {
    except = [except];
  }

	for ( var key in this.config.toolbar_buttons )	{
		var btn = this.config.toolbar_buttons[key];
		if ( except.contains(key) ) {
		      continue;
		}
		if (btn.setDisabled)	btn.setDisabled(true);
	}
};

Xinha.prototype.enableToolbar = function()
{
  this.updateToolbar(false);
};

if ( !Array.prototype.contains )
{
  Array.prototype.contains = function(needle)
  {
    var haystack = this;
    for ( var i = 0; i < haystack.length; i++ )
    {
      if ( needle == haystack[i] )
      {
        return true;
      }
    }
    return false;
  };
}

if ( !Array.prototype.indexOf )
{
  Array.prototype.indexOf = function(needle)
  {
    var haystack = this;
    for ( var i = 0; i < haystack.length; i++ )
    {
      if ( needle == haystack[i] )
      {
        return i;
      }
    }
    return null;
  };
}



Xinha.prototype.getBlockType = function() {

    blocks = ["pre","h1","h2","h3","h4","h5","h6","body"];

    _xo_fan = this._getFirstAncestor(this.getSelection(), blocks);

    _xo_tag_name = _xo_fan.tagName;

    switch (_xo_tag_name.toLowerCase()) {
	case 'body':
	    return '__PARA__';
	    break;
	case 'pre':
	    return '__PRE__';
	    break;
	case 'h1':
	case 'h2':
	case 'h3':
	case 'h4':
	case 'h5':
	case 'h6':
	    return '__H__';
	    break;
	case 'code':
	    return '__CODE__';
	    break;
    }
    return '';
}

Xinha.prototype._normalizeCmd = function(cmd) {
	switch (cmd) {
		case 'strong':
			return 'bold';
			break;
		case 'em':
			return 'italic';
			break;
		default:
			return cmd;
			break
	}
}

Xinha.prototype._xo_updateToolbar = function(noStatus) {

	  var doc = this._doc;
	  var text = (this._editMode == "textmode");

	var blocks = [];
	for ( var indexBlock in this.config.formatblock ) {
		// prevent iterating over wrong type
		if ( typeof this.config.formatblock[indexBlock] == 'string' ) {
			blocks[blocks.length] = this.config.formatblock[indexBlock];
		}
	}

  _xo_block_type = text ? '__TEXT__' : this.getBlockType();

  if ( _xo_block_type != '__TEXT__' ) {
	  _xo_blocks = ["pre",'a','p','li','ul','img','ol',"h1","h2","h3","h4","h5","h6","body"];
	  _xo_sel = this.getSelection();
	  _xo_rng = this.createRange(_xo_sel);
	  _xo_fan = this._getFirstAncestor(_xo_sel, _xo_blocks);
	  if (typeof _xo_fan == 'object')	{
		_xo_fan_tag_name = _xo_fan.tagName.toLowerCase();
	  }
  }

	for ( var key in this.config.toolbar_buttons )	{
		el = this.config.toolbar_buttons[key];

		cmd = this._normalizeCmd(new String(el.id));
		switch (_xo_block_type + cmd.toString())	{

		case '__PARA__'+"fullscreen" :
		case '__H__'+"fullscreen" :
		case '__TEXT__'+"fullscreen" :
			el.setDisabled(false);
			break;

		case '__PARA__'+"htmlmode" :
		case '__H__'+"htmlmode" :
		case '__TEXT__'+"htmlmode" :
			el.setDisabled(false);
			break;


		case '__TEXT__'+"undo" :
		case '__TEXT__'+"redo" :
			el.setDisabled(true);
			break;
		case '__PARA__'+"undo" :
		case '__H__'+"undo" :
			if (this._undoPos > 0)
				el.setDisabled(false);
			else
				el.setDisabled(true);
			break;

		case '__PARA__'+"redo" :
		case '__H__'+"redo" :
			if (this._undoPos < this._undoQueue.length - 1)
				el.setDisabled(false);
			else
				el.setDisabled(true);
			break;

		case '__PRE__'+"formatblock" :
		case '__PARA__'+"formatblock" :
		case '__H__'+"formatblock" :
		    el.setDisabled(false);
		    _xo_format_blocks = ['p','ul','pre','h1','h2','h3'];
		    var deepestAncestor = this._getFirstAncestor(this.getSelection(), _xo_format_blocks);
		    if ( deepestAncestor ) {
			var tn = deepestAncestor.tagName.toLowerCase();
			if (this.formatblock[tn]) 
			    el.setText(this.formatblock[tn].text);
			else
			    el.setText("Style");
		    }
		    break;


		case "bold":
		case "italic":
		case "underline":
		case "insertunorderedlist":
		case "insertorderedlist":
			el.toggle(doc.queryCommandState(cmd));
			el.show();

	  case '__PRE__' + "createlink":
	  case '__PARA__' + "createlink":
			if (this._xo_link_tip) {
				this._xo_link_tip.hide();
				//delete(Xinha._xo_link_tip);
			}


// && !this.collapsed(_xo_rng)

		if (_xo_fan_tag_name == 'a') {
			var ell,bdLeft,bdRight,_xo_close,tBT,tT,xy,dx,dy,p,dt,w;
	      window._xo_editor = this;
	                this._xo_link_tip = new Ext.Layer({cls:"x-tip", shim: true, constrain:true, shadow:false});
			ell = this._xo_link_tip;
			ell.fxDefaults = {stopFx: true};
	               // maximum custom styling
	               ell.update('<div class="x-tip-tl"><div class="x-tip-tr"><div class="x-tip-tc"></div></div></div><div class="x-tip-ml"><div class="x-tip-mr"><div class="x-tip-mc"><div class="x-tip-close"></div><h3></h3><div class="x-tip-bd-inner"></div><div class="x-clear"></div></div></div></div><div class="x-tip-bl"><div class="x-tip-br"><div class="x-tip-bc"></div></div></div>');
	               ell.tipTitle = ell.child('h3');
	               ell.tipTitle.enableDisplayMode("block");
	               ell.tipBody = ell.child('div.x-tip-mc');
 	               ell.tipBodyText = ell.child('div.x-tip-bd-inner');
	              bdLeft = ell.child('div.x-tip-ml');
	              bdRight = ell.child('div.x-tip-br');
	              _xo_close = ell.child('div.x-tip-close');
	              _xo_close.enableDisplayMode("block");
	              _xo_close.on("click", function(){window._xo_editor._xo_close.setDisplayed(false);window._xo_editor._xo_link_tip.hide();window._xo_editor.focusEditor();});

		tBT = ell.tipBodyText;
		tBT.update(' [&nbsp; <a href="#" onclick="window._xo_editor._createLink();window._xo_editor._xo_link_tip.hide();return false;">change</a> - <a href="' + _xo_fan.href  + '" target="_blank">test link</a> &nbsp;] &nbsp; <button onclick="window._xo_editor.fullwordSelection();window._xo_editor._doc.execCommand(\'unlink\', false, null);window._xo_editor._xo_link_tip.hide();return false;">remove link</button> &nbsp; ');
	        tT = ell.tipTitle;
		tT.update(decodeURIComponent(_xo_fan.href).ellipse(45));
		xy = Ext.get(this._iframe).getXY();
		dx = 14;
		dy = 28;

                var scrollTop=this._getFirstAncestor(this.getSelection(), 'body').scrollTop;
                var scrollLeft=this._getFirstAncestor(this.getSelection(), 'body').scrollLeft;
		xy[0] += (_xo_fan.offsetLeft + dx - scrollLeft);
                xy[1] += (_xo_fan.offsetTop + dy - scrollTop);

		ell.setXY(xy);
		ell.show();



		p=bdLeft.getPadding('l')+bdRight.getPadding('r');
		td = ell.tipBodyText.dom;
		w = Math.max(td.offsetWidth, td.clientWidth);
	      w=235;
//	      ell.dom.style.width = 'auto';
//	      w = tT.dom.offsetWidth+20;

	        ell.setWidth(parseInt(w, 10) + p);
		_xo_close.setDisplayed(true);
		window._xo_editor._xo_close = _xo_close;

		}

		el.toggle(_xo_fan_tag_name=='a');
		el.setDisabled(false);
		break;

	  case '__PARA__' + 'insertimage':
		if (_xo_fan_tag_name == 'img') {
	      window._xo_editor = this;
              this._xo_link_tip = ell = new Ext.Layer({cls:"x-tip", shim: true, constrain:true, shadow:false});
ell.fxDefaults = {stopFx: true};
              // maximum custom styling
              ell.update('<div class="x-tip-tl"><div class="x-tip-tr"><div class="x-tip-tc"></div></div></div><div class="x-tip-ml"><div class="x-tip-mr"><div class="x-tip-mc"><div class="x-tip-close"></div><h3></h3><div class="x-tip-bd-inner"></div><div class="x-clear"></div></div></div></div><div class="x-tip-bl"><div class="x-tip-br"><div class="x-tip-bc"></div></div></div>');
              tipTitle = ell.child('h3');
              tipTitle.enableDisplayMode("block");
              tipBody = ell.child('div.x-tip-bd');
              tipBodyText = ell.child('div.x-tip-bd-inner');
//	      tipTitle.update(_xo_fan.innerHTML);
//		tipTitle.update(_xo_fan.getAttribute('title'));
		var current_alignment=_xo_fan.className.trim();
		if (current_alignment=='') current_alignment='center';
		var alignment_list='left center right'.split(' ');
		var alignment_bar='\[';
		for (var i=0;i<alignment_list.length;i++) {
		        if (i>0 && i< alignment_list.length) {
			       alignment_bar+=' - ';
			}
			if (current_alignment==alignment_list[i]) {
			   alignment_bar += ' <b>' + alignment_list[i] + '</b> ';
			} else {
			   alignment_bar += ' <a href="#" onclick="window._xo_editor.changeImageAlignment(_xo_fan,\''+alignment_list[i]+'\');return false;">' + alignment_list[i] + '</a> '
			}
		}
		alignment_bar += '\]';
		tipTitle.update(alignment_bar);
		tipBodyText.update(' <a href="#" onclick="window._xo_editor._xo_link_tip.hide();window._xo_editor._insertImage();return false;">change</a> - <button onclick="window._xo_editor._xo_link_tip.hide();Xinha.removeFromParent(_xo_fan);window._xo_editor.focusEditor();window._xo_editor.updateToolbar();return false;">remove image</button>');
              bdLeft = ell.child('div.x-tip-ml');
              bdRight = ell.child('div.x-tip-mr');
              _xo_close = ell.child('div.x-tip-close');
              _xo_close.enableDisplayMode("block");
              _xo_close.on("click", function(){window._xo_editor._xo_close.setDisplayed(false);window._xo_editor._xo_link_tip.hide();window._xo_editor.focusEditor();});



		xy = Ext.get(this._iframe).getXY();
		dx = 30;
		dy = _xo_fan.height-10;

                var scrollTop=this._getFirstAncestor(this.getSelection(), 'body').scrollTop;
                var scrollLeft=this._getFirstAncestor(this.getSelection(), 'body').scrollLeft;
		xy[0] += (_xo_fan.offsetLeft + dx - scrollLeft);
                xy[1] += (_xo_fan.offsetTop + dy - scrollTop);

//	        ell.avoidY = xy[1]-18;
		ell.setXY(xy);

		ell.show();

		p=bdLeft.getPadding('l')+bdRight.getPadding('r');
		td = tipBodyText.dom;
		w = Math.max(td.offsetWidth, td.clientWidth, td.scrollWidth);
	        //ell.setWidth(parseInt(w, 12) + p);
		ell.setWidth(200);
		_xo_close.setDisplayed(true);
		window._xo_editor._xo_close = _xo_close;

		}

			el.toggle(_xo_fan_tag_name=='img');
			el.setDisabled(false);
		break;


	  case '__PARA__' + "bold":
	  case '__PRE__' + "bold":
	  case '__PARA__' + "italic":
	  case '__PRE__' + "italic":
	  case '__PARA__' + "highlight":
	  case '__PRE__' + "highlight":
		el.setDisabled(false);
		el.toggle(this.hasStyleClass(cmd.toString()));
		break;


	  case '__PARA__' + "insertunorderedlist":
	  case '__PARA__' + "insertorderedlist":
			el.toggle(doc.queryCommandState(cmd));


	  case '__PARA__' + "formatblock":
	  case '__PARA__' + "inserthorizontalrule":
	  case '__PARA__' + 'removeformat':
			el.setDisabled(false);
		break;

	  case '__CODE__' + "bold":
	  case '__CODE__' + "italic":
	  case '__CODE__' + "underline":
	  case '__CODE__' + "insertunorderedlist":
	  case '__CODE__' + "insertorderedlist":
	  	btn.state("active", false);
	  case '__CODE__' + "createlink":
	  case '__CODE__' + "inserthorizontalrule":
	  case '__CODE__' + 'insertimage':
	  case '__CODE__' + 'removeformat':
		try { btn.state("enabled",false); } catch (ex) {}
		break;



	  case '__PRE__' + "underline":
			el.toggle(doc.queryCommandState(cmd));
			el.setDisabled(false);
		break;
	  case '__PRE__' + "insertunorderedlist":
	  case '__PRE__' + "insertorderedlist":
			el.toggle(false);

	  case '__PRE__' + "inserthorizontalrule":
	  case '__PRE__' + 'insertimage':
	  case '__PRE__' + 'removeformat':
		el.setDisabled(true);
		break;

	  case '__H__' + "bold":
	  case '__H__' + "italic":
	  case '__H__' + "underline":
	  case '__H__' + "insertunorderedlist":
	  case '__H__' + "insertorderedlist":
	  case '__H__' + "createlink":
	  case '__H__' + "inserthorizontalrule":
	  case '__H__' + 'insertimage':
	  case '__H__' + 'removeformat':
		el.toggle(false);
		el.setDisabled(true);
		break;

	  case '__TEXT__' + "bold":
	  case '__TEXT__' + "italic":
	  case '__TEXT__' + "underline":
	  case '__TEXT__' + "formatblock":
	  case '__TEXT__' + "insertunorderedlist":
	  case '__TEXT__' + "insertorderedlist":
	  case '__TEXT__' + "createlink":
	  case '__TEXT__' + "inserthorizontalrule":
	  case '__TEXT__' + 'insertimage':
	  case '__TEXT__' + 'removeformat':
		el.toggle(false);
		el.setDisabled(true);
		break;



	
		default:
			cmd = cmd.replace(/(un)?orderedlist/i, "insert$1orderedlist");
			try
			{
				el.toggle( (!text && doc.queryCommandState(cmd)) );
			} catch (ex) {}
		break;
		}
	}
	//dum(this._xo_toolbar);
}

//AK Change --end

// FIXME : this function needs to be splitted in more functions.
// It is actually to heavy to be understable and very scary to manipulate
// updates enabled/disable/active state of the toolbar elements
Xinha.prototype.updateToolbar = function(noStatus)
{
  var doc = this._doc;
  var text = (this._editMode == "textmode");
  var ancestors = null;
  this._xo_updateToolbar();

};


// moved Xinha.prototype.insertNodeAtSelection() to browser specific file
// moved Xinha.prototype.getParentElement() to browser specific file

// Returns an array with all the ancestor nodes of the selection.
Xinha.prototype.getAllAncestors = function()
{
  var p = this.getParentElement();
  var a = [];
  while ( p && (p.nodeType == 1) && ( p.tagName.toLowerCase() != 'body' ) )
  {
    a.push(p);
    p = p.parentNode;
  }
  a.push(this._doc.body);
  return a;
};

// Returns the deepest ancestor of the selection that is of the current type
Xinha.prototype._getFirstAncestor = function(sel, types)
{
  var prnt = this.activeElement(sel);
  if ( prnt === null )
  {
    // Hmm, I think Xinha.getParentElement() would do the job better?? - James
    try
    {
      prnt = (Xinha.is_ie ? this.createRange(sel).parentElement() : this.createRange(sel).commonAncestorContainer);
    }
    catch(ex)
    {
      return null;
    }
  }

  if ( typeof types == 'string' )
  {
    types = [types];
  }

  while ( prnt )
  {
    if ( prnt.nodeType == 1 )
    {
      if ( types === null )
      {
        return prnt;
      }
      if ( types.contains(prnt.tagName.toLowerCase()) )
      {
        return prnt;
      }
      if ( prnt.tagName.toLowerCase() == 'body' )
      {
        break;
      }
      if ( prnt.tagName.toLowerCase() == 'table' )
      {
        break;
      }
    }
    prnt = prnt.parentNode;
  }

  return null;
};






Xinha.prototype.hasSelectedText = function()
{
  // FIXME: come _on_ mishoo, you can do better than this ;-)
  return this.getSelectedHTML() !== '';
};


// Called when the user clicks the Insert Table button


/***************************************************
 *  Category: EVENT HANDLERS
 ***************************************************/

// the execCommand function (intercepts some commands and replaces them with
// our own implementation)
Xinha.prototype.execCommand = function(cmdID, UI, param)
{

  var editor = this;	// for nested functions
  this.focusEditor();
  cmdID = cmdID.toLowerCase();

/*
  if (Xinha.is_gecko) {
	  try {
	    // useCSS deprecated & replaced by styleWithCSS
	    this._doc.execCommand('useCSS', false, true); //switch useCSS off (true=off)
	  } catch (ex) {
	    this._doc.execCommand('styleWithCSS', false, false); //switch styleWithCSS off     
	  }
  }
*/


  // take undo snapshots
  if ( this._customUndo && this._editMode == 'wysiwyg' && cmdID != 'undo') {
    this._undoTakeSnapshot();
  }



  _xo_btn = this.config.toolbar_buttons[cmdID];
  switch (cmdID)
  {
    case "htmlmode":
      this.setMode();
	this.focusEditor();
      break;
    case "fullscreen":

		//alert(this.getHTML());
		//break;
	        this._fullScreen();

		el = _xo_btn.getEl();
	        if(this._isFullScreen)
	        {
			//el.toggle(true);
			el.removeClass('x-edit-fullscreen');
			el.addClass('x-edit-fullscreen-on');
	        } else {
			el.removeClass('x-edit-fullscreen-on');
			el.addClass('x-edit-fullscreen');
	        }
		break;
	case "inserthorizontalrule":
		this._doc.execCommand("inserthorizontalrule",UI,param);
		break;
	case 'bold':
	case 'italic':
	case 'highlight':
		_xo_btn.toggle(this.toggleStyleClass(cmdID));
		break;
    case "createlink":
      this._createLink();
    break;

    case "undo":
    case "redo":
      if (this._customUndo)
      {
        this[cmdID]();
      }
      else
      {
        this._doc.execCommand(cmdID, UI, param);
      }
	// this.findCC(this._editMode == 'textmode' ? 'textarea':'iframe');
    break;

    case "inserttable":
      this._insertTable();
    break;

    case "insertimage":
      this._insertImage();
    break;


    case "cut":
    case "copy":
    case "paste":
    try { this._doc.execCommand(cmdID, UI, param); } catch (ex) {}
      if ( this.config.killWordOnPaste ) {
        this._wordClean();
      }
    break;
    
	case 'insertunorderedlist':
		if (!this._doc.queryCommandState(cmdID)) {
			this._doc.execCommand("formatblock",false,'p');
			this._doc.execCommand(cmdID,UI,param);
		}
		break;
	case 'formatblock':
		if (this._doc.queryCommandState('insertunorderedlist')) {
			this._doc.execCommand('insertunorderedlist',false,false);
		}
		this._doc.execCommand(cmdID,UI,param);
		break;


  }

  this.updateToolbar();
  return false;
};

/** A generic event handler for things that happen in the IFRAME's document.
 * @todo: this function is *TOO* generic, it needs to be splitted in more specific handlers
 * This function also handles key bindings. */
Xinha.prototype._editorEvent = function(ev)
{
  var editor = this;

  //call events of textarea
  if ( typeof editor._textArea['on'+ev.type] == "function" ) {
    editor._textArea['on'+ev.type]();
  }

  if ( typeof ev.getKey() != 'undefined' ) {

    if (ev.getKey() == ev.SPACE) {
	this._undoTakeSnapshot();
    }

    
    // Handle the core shortcuts
    if ( this.isShortCut( ev ) ) {
      this._shortCuts(ev);
    }


//HERE
	this.onKeyPress(ev);

  }
  
  // update the toolbar state after some time
  if ( editor._timerToolbar )
  {
    clearTimeout(editor._timerToolbar);
  }
  editor._timerToolbar = setTimeout(
    function() {
      editor.updateToolbar(false);
      editor._timerToolbar = null;
    },
    250);
};

// handles ctrl + key shortcuts 
Xinha.prototype._shortCuts = function (ev)
{

  var key = ev.getKey();
  var cmd = null;
  var value = null;
  switch (key) {

    case ev.B: cmd = "bold"; break;
    case ev.I: cmd = "italic"; break;
    case ev.H: cmd = "highlight"; break;

//    case 'l': cmd = ev.shiftKey ? 'insertunorderedlist' : ''; break;

    case ev.K: cmd = ev.shiftKey ? 'unlink' : 'createlink'; break;

    case ev.G: cmd = ev.shiftKey ? 'insertimage' : ''; break;

    case ev.ZERO: cmd = 'formatblock'; value='p'; break;

    case ev.ONE: cmd = 'formatblock'; value='h1'; break;
    case ev.TWO: cmd = 'formatblock'; value='h2'; break;
    case ev.THREE: cmd = 'formatblock'; value='h3'; break;

    case ev.J: cmd = ev.shiftKey ? 'fullscreen' : '';break;


	/*
	// f - find
	// g - find again
    case ev.U: cmd = "underline"; break;
    case ev.S: cmd = "strikethrough"; break;
    case ev.L: cmd = "justifyleft"; break;
    case ev.E: cmd = "justifycenter"; break;
    case ev.R: cmd = "justifyright"; break;
    case ev.J: cmd = "justifyfull"; break;
	*/


    case ev.Z: cmd = "undo"; break;
    case ev.Y: cmd = "redo"; break;
    case ev.V: cmd = "paste"; break;
  }
  if ( cmd ) {
    this.execCommand(cmd, false, value);
    Xinha._stopEvent(ev);
  }
};



// retrieve the HTML
Xinha.prototype.getHTML = function()
{

  var html = '';
  var doc=this._doc;


  switch ( this._editMode )
  {
    case "wysiwyg":
      if ( !this.config.fullPage )
      {
        html = Xinha.getHTML(doc.body, false, this);
      }
      else
      {
        html = this.doctype + "\n" + Xinha.getHTML(doc.documentElement, true, this);
      }
    break;
    case "textmode":
      html = this._textArea.value;
    break;
    default:
      alert("Mode <" + this._editMode + "> not defined!");
      return false;
  }
  return html;
};


Xinha.prototype.outwardHtml = function(html)
{ 

  html = html.replace(/<(\/?)b(\s|>|\/)/ig, "<$1strong$2");
  html = html.replace(/<(\/?)i(\s|>|\/)/ig, "<$1em$2");
  html = html.replace(/<(\/?)strike(\s|>|\/)/ig, "<$1del$2");
  
  // replace window.open to that any clicks won't open a popup in designMode
  html = html.replace("onclick=\"try{if(document.designMode &amp;&amp; document.designMode == 'on') return false;}catch(e){} window.open(", "onclick=\"window.open(");

  // Figure out what our server name is, and how it's referenced
  var serverBase = location.href.replace(/(https?:\/\/[^\/]*)\/.*/, '$1') + '/';

  // IE puts this in can't figure out why
  //  leaving this in the core instead of InternetExplorer 
  //  because it might be something we are doing so could present itself
  //  in other browsers - James 
  html = html.replace(/https?:\/\/null\//g, serverBase);

  // Make semi-absolute links to be truely absolute
  //  we do this just to standardize so that special replacements knows what
  //  to expect
  html = html.replace(/((href|src|background)=[\'\"])\/+/ig, '$1' + serverBase);

  html = this.outwardSpecialReplacements(html);

  html = this.fixRelativeLinks(html);

  if ( this.config.sevenBitClean )
  {
    html = html.replace(/[^ -~\r\n\t]/g, function(c) { return '&#'+c.charCodeAt(0)+';'; });
  }
  
  //prevent execution of JavaScript (Ticket #685)
  html = html.replace(/(<script[^>]*)(freezescript)/gi,"$1javascript");

  // If in fullPage mode, strip the coreCSS
  if(this.config.fullPage)
  {
    html = Xinha.stripCoreCSS(html);
  }
  return this.getStxFromHtml(html);
};

Xinha.prototype.inwardHtml = function(html)
{  
  return this.getHtmlFromStx(html);
};

Xinha.prototype.outwardSpecialReplacements = function(html)
{
  for ( var i in this.config.specialReplacements )
  {
    var from = this.config.specialReplacements[i];
    var to   = i; // why are declaring a new variable here ? Seems to be better to just do : for (var to in config)
    // prevent iterating over wrong type
    if ( typeof from.replace != 'function' || typeof to.replace != 'function' )
    {
      continue;
    } 
    // alert('out : ' + from + '=>' + to);
    var reg = new RegExp(from.replace(Xinha.RE_Specials, '\\$1'), 'g');
    html = html.replace(reg, to.replace(/\$/g, '$$$$'));
    //html = html.replace(from, to);
  }
  return html;
};



Xinha.prototype.fixRelativeLinks = function(html)
{
  if ( typeof this.config.expandRelativeUrl != 'undefined' && this.config.expandRelativeUrl ) 
  var src = html.match(/(src|href)="([^"]*)"/gi);
  var b = document.location.href;
  if ( src )
  {
    var url,url_m,relPath,base_m,absPath
    for ( var i=0;i<src.length;++i )
    {
      url = src[i].match(/(src|href)="([^"]*)"/i);
      url_m = url[2].match( /\.\.\//g );
      if ( url_m )
      {
        relPath = new RegExp( "(.*?)(([^\/]*\/){"+ url_m.length+"})[^\/]*$" );
        base_m = b.match( relPath );
        absPath = url[2].replace(/(\.\.\/)*/,base_m[1]);
        html = html.replace( new RegExp(url[2].replace( Xinha.RE_Specials, '\\$1' ) ),absPath );
      }
    }
  }
  
  if ( typeof this.config.stripSelfNamedAnchors != 'undefined' && this.config.stripSelfNamedAnchors )
  {
    var stripRe = new RegExp(document.location.href.replace(/&/g,'&amp;').replace(Xinha.RE_Specials, '\\$1') + '(#[^\'" ]*)', 'g');
    html = html.replace(stripRe, '$1');
  }

  if ( typeof this.config.stripBaseHref != 'undefined' && this.config.stripBaseHref )
  {
    var baseRe = null;
    if ( typeof this.config.baseHref != 'undefined' && this.config.baseHref !== null )
    {
      baseRe = new RegExp( "((href|src|background)=\")(" + this.config.baseHref.replace( Xinha.RE_Specials, '\\$1' ) + ")", 'g' );
    }
    else
    {
      baseRe = new RegExp( "((href|src|background)=\")(" + document.location.href.replace( /^(https?:\/\/[^\/]*)(.*)/, '$1' ).replace( Xinha.RE_Specials, '\\$1' ) + ")", 'g' );
    }

    html = html.replace(baseRe, '$1');
  }

  return html;
};

// retrieve the HTML (fastest version, but uses innerHTML)
Xinha.prototype.getInnerHTML = function()
{
  if ( !this._doc.body )
  {
    return '';
  }
  var html = "";
  switch ( this._editMode )
  {
    case "wysiwyg":
      if ( !this.config.fullPage ) {
        // return this._doc.body.innerHTML;
        html = this._doc.body.innerHTML;
      } else {
        html = this.doctype + "\n" + this._doc.documentElement.innerHTML;
      }
    break;
    case "textmode" :
      html = this._textArea.value;
    break;
    default:
      alert("Mode <" + this._editMode + "> not defined!");
      return false;
  }

  return html;
};

// completely change the HTML inside
Xinha.prototype.setHTML = function(html)
{
  if ( !this.config.fullPage )
  {
    this._doc.body.innerHTML = html;
  }
  else
  {
    this.setFullHTML(html);
  }
  this._textArea.value = html;
};

// sets the given doctype (useful when config.fullPage is true)
Xinha.prototype.setDoctype = function(doctype)
{
  this.doctype = doctype;
};

/***************************************************
 *  Category: UTILITY FUNCTIONS
 ***************************************************/

// variable used to pass the object to the popup editor window.
Xinha._object = null;

// function that returns a clone of the given object
Xinha.cloneObject = function(obj)
{
  if ( !obj )
  {
    return null;
  }

  var newObj = {};

  // check for array objects
  if ( obj.constructor.toString().match( /\s*function Array\(/ ) )
  {
    newObj = obj.constructor();
  }

  // check for function objects (as usual, IE is fucked up)
  if ( obj.constructor.toString().match( /\s*function Function\(/ ) )
  {
    newObj = obj; // just copy reference to it
  }
  else
  {
    for ( var n in obj )
    {
      var node = obj[n];
      if ( typeof node == 'object' )
      {
        newObj[n] = Xinha.cloneObject(node);
      }
      else
      {
        newObj[n] = node;
      }
    }
  }

  return newObj;
};

// FIXME!!! this should return false for IE < 5.5
Xinha.checkSupportedBrowser = function()
{
  if ( Xinha.is_gecko )
  {
    if ( navigator.productSub < 20021201 )
    {
      alert("You need at least Mozilla-1.3 Alpha.\nSorry, your Gecko is not supported.");
      return false;
    }
    if ( navigator.productSub < 20030210 )
    {
      alert("Mozilla < 1.3 Beta is not supported!\nI'll try, though, but it might not work.");
    }
  }
  return Xinha.is_gecko || Xinha.is_ie;
};

// selection & ranges



// event handling

/** Event Flushing
 *  To try and work around memory leaks in the rather broken
 *  garbage collector in IE, Xinha.flushEvents can be called
 *  onunload, it will remove any event listeners (that were added
 *  through _addEvent(s)) and clear any DOM-0 events.
 */
Xinha._eventFlushers = [];
Xinha.flushEvents = function()
{
  var x = 0;
  // @todo : check if Array.prototype.pop exists for every supported browsers
  var e = Xinha._eventFlushers.pop();
  while ( e )
  {
    try
    {
      if ( e.length == 3 )
      {
        Xinha._removeEvent(e[0], e[1], e[2]);
        x++;
      }
      else if ( e.length == 2 )
      {
        e[0]['on' + e[1]] = null;
        e[0]._xinha_dom0Events[e[1]] = null;
        x++;
      }
    }
    catch(ex)
    {
      // Do Nothing
    }
    e = Xinha._eventFlushers.pop();
  }
  
};



Xinha._addEvent = function(el,evname,func) {
	Ext.EventManager.on(el,evname,func);
	Xinha._eventFlushers.push([el, evname, func]);

}
Xinha._removeEvent = function(el,evname,func) {
	Ext.EventManager.un(el,evname,func);
}
Xinha._stopEvent = function(ev) {
    try {
	ev.stopEvent();
    } catch (ex) {
	// we've got a blur event on the loose
    }
}
Xinha._addEvents = function(el, evs, func)
{
  for ( var i = evs.length; --i >= 0; )
  {
	Xinha._addEvent(el,evs[i],func);
  }
};




Xinha._blockTags = " body form textarea fieldset ul ol dl li div " + "p h1 h2 h3 h4 h5 h6 quote pre table thead " + "tbody tfoot tr td th iframe address blockquote ";
Xinha.isBlockElement = function(el)
{
  return el && el.nodeType == 1 && (Xinha._blockTags.indexOf(" " + el.tagName.toLowerCase() + " ") != -1);
};



Xinha._closingTags = " a abbr acronym address applet b bdo big blockquote button caption center cite code del dfn dir div dl em fieldset font form frameset h1 h2 h3 h4 h5 h6 i iframe ins kbd label legend map menu noframes noscript object ol optgroup pre q s samp script select small span strike strong style sub sup table textarea title tt u ul var ";

Xinha.needsClosingTag = function(el)
{
  return el && el.nodeType == 1 && (Xinha._closingTags.indexOf(" " + el.tagName.toLowerCase() + " ") != -1);
};


// performs HTML encoding of some given string
Xinha.htmlEncode = function(str)
{
  if ( typeof str.replace == 'undefined' )
  {
    str = str.toString();
  }
  // we don't need regexp for that, but.. so be it for now.
  str = str.replace(/&/ig, "&amp;");
  str = str.replace(/</ig, "&lt;");
  str = str.replace(/>/ig, "&gt;");
  str = str.replace(/\xA0/g, "&nbsp;"); // Decimal 160, non-breaking-space
  str = str.replace(/\x22/g, "&quot;");
  // \x22 means '"' -- we use hex reprezentation so that we don't disturb
  // JS compressors (well, at least mine fails.. ;)
  return str;
};

// moved Xinha.getHTML() to getHTML.js 
Xinha.prototype.stripBaseURL = function(string)
{
  if ( this.config.baseHref === null || !this.config.stripBaseHref )
  {
    return string;
  }
  // strip host-part of URL which is added by MSIE to links relative to server root
  var baseurl = this.config.baseHref.replace(/^(https?:\/\/[^\/]+)(.*)$/, '$1');
  var basere = new RegExp(baseurl);
  return string.replace(basere, "");
};



// paths

Xinha.prototype.imgURL = function(file, plugin)
{
  if ( typeof plugin == "undefined" ) {
    return this._editor_url + file;
  } else {
    return this._editor_url + "plugins/" + plugin + "/img/" + file;
  }
};


/**
 * FIX: Internet Explorer returns an item having the _name_ equal to the given
 * id, even if it's not having any id.  This way it can return a different form
 * field even if it's not a textarea.  This workarounds the problem by
 * specifically looking to search only elements having a certain tag name.
 */
Xinha.getElementById = function(tag, id)
{
  var el, i, objs = document.getElementsByTagName(tag);
  for ( i = objs.length; --i >= 0 && (el = objs[i]); )
  {
    if ( el.id == id )
    {
      return el;
    }
  }
  return null;
};




Xinha.stripCoreCSS = function(html)
{
  return html.replace(/<style[^>]+(.|\n)*?<\/style>/i, ''); 
}








/** New language handling functions **/



/** Return a localised string.
 * @param string    English language string. It can also contain variables in the form "Some text with $variable=replaced text$". 
 *                  This replaces $variable in "Some text with $variable" with "replaced text"
 * @param context   Case sensitive context name, eg 'Xinha' (default), 'TableOperations'...
 * @param replace   Replace $variables in String, eg {foo: 'replaceText'} ($foo in string will be replaced)
 */
Xinha._lc = function(string, context, replace)
{
	return string;
};

Xinha.hasDisplayedChildren = function(el)
{
  var children = el.childNodes;
  for ( var i = 0; i < children.length; i++ )
  {
    if ( children[i].tagName )
    {
      if ( children[i].style.display != 'none' )
      {
        return true;
      }
    }
  }
  return false;
};

/**
 * Load a javascript file by inserting it in the HEAD tag and eventually call a function when loaded
 *
 * Note that this method cannot be abstracted into browser specific files
 *  because this method LOADS the browser specific files.  Hopefully it should work for most
 *  browsers as it is.
 *
 * @param {string} U (Url)      Source url of the file to load
 * @param {object} C {Callback} Callback function to launch once ready (optional)
 * @param {object} O (scOpe)    Application scope for the callback function (optional)
 * @param {object} B (Bonus}    Arbitrary object send as a param to the callback function (optional)
 * @public
 * 
 */
 


if ( !Array.prototype.append )
{
  Array.prototype.append  = function(a)
  {
    for ( var i = 0; i < a.length; i++ )
    {
      this.push(a[i]);
    }
    return this;
  };
}

Xinha.makeEditor = function(editor_name, default_config)
{
  if ( typeof default_config == 'function' )
  {
    default_config = default_config();
  }

	return new Xinha(editor_name, Xinha.cloneObject(default_config));
};

Xinha.startEditor = function(editor)
{
    if ( editor.generate )
    {
      editor.generate();
    }
};



Xinha.removeFromParent = function(node)
{

  if ( !node.parentNode ) {
    return;
  }
  var pN = node.parentNode;
	//alert("before: "+pN.innerHTML);
  pN.removeChild(node);
	//alert("after: "+pN.innerHTML);
  return node;
};

Xinha.hasParentNode = function(el)
{
  if ( el.parentNode )
  {
    // When you remove an element from the parent in IE it makes the parent
    // of the element a document fragment.  Moz doesn't.
    if ( el.parentNode.nodeType == 11 )
    {
      return false;
    }
    return true;
  }

  return false;
};

// moved Xinha.getOuterHTML() to browser specific file



/** 
 *  Calculate the top and left pixel position of an element in the DOM.
 *
 *  @param   element HTML Element DOM Node
 *  @returns Object with integer properties top and left
 */
 
Xinha.getElementTopLeft = function(element)
{
  var position = { top:0, left:0 };
  while ( element )
  {
    position.top  += element.offsetTop;
    position.left += element.offsetLeft;
    if ( element.offsetParent && element.offsetParent.tagName.toLowerCase() != 'body' )
    {
      element = element.offsetParent;
    }
    else
    {
      element = null;
    }
  }
  
  return position;
}

Xinha.toFree = [];
Xinha.freeLater = function(obj,prop)
{
  Xinha.toFree.push({o:obj,p:prop});
};

/**
 * Release memory properties from object
 * @param {object} object The object to free memory
 * @param (string} prop   The property to release (optional)
 * @private
 */
Xinha.free = function(obj, prop)
{
  if ( obj && !prop )
  {
    for ( var p in obj )
    {
      Xinha.free(obj, p);
    }
  }
  else if ( obj )
  {
    try { obj[prop] = null; } catch(x) {}
  }
};

/** IE's Garbage Collector is broken very badly.  We will do our best to 
 *   do it's job for it, but we can't be perfect.
 */

Xinha.collectGarbage = function() 
{  
  Xinha.flushEvents();   
  for ( var x = 0; x < Xinha.toFree.length; x++ )
  {
    Xinha.free(Xinha.toFree[x].o, Xinha.toFree[x].p);
    Xinha.toFree[x].o = null;
  }
};


 
Xinha.prototype.isShortCut = function(keyEvent)
{
  if(keyEvent.ctrlKey && !keyEvent.altKey)
  {
    return true;
  }
  
  return false;
}

 


//Xinha.addDom0Event(window,'unload',Xinha.collectGarbageForIE);
//E=Ext.lib.Event;
//E.on(window,'unload',Xinha.collectGarbageForIE);



Xinha.prototype.moveAfterNode = function(node) {
    var rng;
    this.selectNodeContents(node);
    rng = this.createRange(this.getSelection());
    if (Xinha.is_ie) {
	    rng.collapse(false);
	    if (Xinha.is_ie) rng.select();
    } else {
	rng.setEndAfter(node);
	rng.setStartAfter(node);
    }
}



/*
Xinha.prototype.removeStyleClass = function (className) {
	this.fullwordSelection(true);
	this._doc.execCommand(className,false,false);
}

Xinha.prototype.addStyleClass = function (className) {
	this.fullwordSelection();
	this._doc.execCommand(className,false,false);
	//Ext.fly(this.getParentElement()).dom.setAttribute('_xo','1');
}

Xinha.prototype.hasStyleClass = function (className) {
	return this._doc.queryCommandState(className);
}
*/



Xinha.prototype.hasStyleClass = function (className) {
	return (Ext.fly(this.getParentElement()).findParent('font.'+className) != null);
}


Xinha.prototype.allStyleClasses = function (className) {
    var i, result, ancestors;
    result = '';
    ancestors = this.getAllAncestors();
    for (i=0;i<ancestors.length;i++) {
	if (ancestors[i].className != null) result += ' ' + ancestors[i].className;
    }
    return result.split(' ');
}


Xinha.prototype.inheritStyle = function () {
    var i, _xo_styleClasses, _xo_sel, _xo_rng, _xo_node, _xo_el;
    this.fullwordSelection();
    _xo_styleClasses = this.allStyleClasses()
    _xo_sel = this.getSelection();
    if (this.selectionEmpty(_xo_sel)) {
	if (Xinha.is_ie) {
	    _xo_rng = this.createRange(_xo_sel);
	    _xo_rng.text = ' Y ';
	    _xo_rng.moveStart('character',1);
	    _xo_rng.moveEnd('character',-1);
	    _xo_rng.select();
	    this._doc.execCommand('removeformat',false,false);
	    //this.findCC('iframe');
	    _xo_rng.moveStart('character',-2);
	    //_xo_rng.select();
	    _xo_rng.text=' ';
	} else {
	    this.insertAtCursor(' ');
	}
    } else {
	this._doc.execCommand('removeformat',false,false);
    }
    _xo_node = this._doc.createElement('font');
    _xo_el = Ext.fly(_xo_node);
    _xo_el.set({_xo:'1'});
    for (i=0;i<_xo_styleClasses.length;i++) {
        _xo_el.addClass(_xo_styleClasses[i]);
    }
    return _xo_el;
};


Xinha.prototype.surroundHTML = function(startTag, endTag) {
    var html = this.getSelectedHTML();
  // the following also deletes the selection
      this.insertAtCursor(startTag + html + endTag);
};

Xinha.prototype.toggleStyleClass = function (className) {
    var _xo_el, result,_xo_node,_xo_sel,_xo_rng,_xo_split, _xo_innerNode;
    _xo_el = this.inheritStyle();

    if (_xo_el.hasClass(className)) {
	_xo_el.removeClass(className);
	result = false;
    } else { 
	_xo_el.addClass(className);
	result = true;
    }

    _xo_node = _xo_el.dom;
    _xo_sel = this.getSelection();
    _xo_rng = this.createRange(_xo_sel);
    if (!this.selectionEmpty(_xo_sel)) {
	if (_xo_node.className.length) {
	    if (Xinha.is_ie) {
                _xo_innerNode = this._doc.createTextNode(this.cc);
                _xo_node.appendChild(_xo_innerNode);
		_xo_split = _xo_node.outerHTML.split(this.cc);
		this.surroundHTML(_xo_split[0],this.cc+_xo_split[1]);
		this.findCC('iframe');
		_xo_node = this.getParentElement();
	    } else {
		// Gecko
		_xo_rng.surroundContents(_xo_node);
	    }
	    //this.moveAfterNode(_xo_node);
	    this.selectNodeContents(_xo_node);
	    this._xo_garbageCollect(this.getParentElement());
	}
    } else {	
	if (_xo_node.className.length) {
	    _xo_innerNode = this._doc.createTextNode(this.cc+' ');
	    _xo_node.appendChild(_xo_innerNode);
	    this.insertNodeAtSelection(_xo_node);
	    this.findCC('iframe');
	} else {
	    this.insertAtCursor(this.cc);
	    this.findCC('iframe');
	}
    }
    return result;
}




Xinha.prototype._getElement = function(tagName) {
    var p;
    p = this.getParentElement();
    if ( p ) {
      while (p && (p.nodeType != 1 || p.tagName.toLowerCase() != tagName)) {
        p = p.parentNode;
      }
    }
    return p;
};



Xinha.prototype._xo_garbageCollect = function (_xo_node) {
  var sel, rng, i,el;
  if (this._editMode == 'wysiwyg') {
	sel = this.getSelection();
	rng = this.createRange(sel);
	el = Ext.fly(_xo_node);
	if (el != null) {
	        this._aux = el.query('font[_xo]');
	        for (i=0;i<this._aux.length;i++) {
		  if (this._aux[i].innerHTML.length == 0) {
			if (!rng.isPointInRange(this._aux[i],0)) {
				Xinha.removeFromParent(this._aux[i]);
			}
		  }
	        }
	  }
  }
  return true;
}


Xinha.viewportSize = function(scope)
{
  scope = (scope) ? scope : window;
  var x,y;
  if (scope.innerHeight) // all except Explorer
  {
    x = scope.innerWidth;
    y = scope.innerHeight;
  }
  else if (scope.document.documentElement && scope.document.documentElement.clientHeight)
  // Explorer 6 Strict Mode
  {
    x = scope.document.documentElement.clientWidth;
    y = scope.document.documentElement.clientHeight;
  }
  else if (scope.document.body) // other Explorers
  {
    x = scope.document.body.clientWidth;
    y = scope.document.body.clientHeight;
  }
  return {'x':x,'y':y};
};





Xinha.prototype._xo_htmlarea = function() { return this._htmlArea; }
Xinha.prototype._xo_iframe = function() { return this._iframe; }
Xinha.prototype._xo_doc = function() { return this._doc; }
Xinha.prototype._xo_textArea = function() { return this._textArea; }




Xinha.RE_img=/<img[^>]*>/i;
Xinha.prototype.noSpecialContent = function (node) {
    return ((node.innerHTML == null) || (node.innerHTML.match(Xinha.RE_img) == null));
};

Xinha.prototype.changeImageAlignment = function(node,alignment) {
    var el=Ext.fly(node);
    if (alignment=='left') el.setStyle({'display':'block','padding':'15px','margin-left':null,'margin-right':'auto'});
    if (alignment=='center') el.setStyle({'display':'block','padding':'15px','margin-left':'auto','margin-right':'auto'});
    if (alignment=='right') el.setStyle({'display':'block','padding':'15px','margin-left':'auto','margin-right':null});
    el.removeClass(['left','center','right']);
    el.addClass(alignment);
    window._xo_editor._xo_link_tip.hide();
}
