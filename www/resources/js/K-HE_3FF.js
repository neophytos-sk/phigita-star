
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
    html = "<html>\n";
    html += "<head>\n";
    html += "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=" + editor.config.charSet + "\">\n";
    if ( typeof editor.config.baseHref != 'undefined' && editor.config.baseHref !== null )
    {
      html += "<base href=\"" + editor.config.baseHref + "\"/>\n";
    }
    
    html += Xinha.addCoreCSS();

    if ( editor.config.pageStyle )
    {
      html += "<style type=\"text/css\">\n" + editor.config.pageStyle + "\n</style>";
    }

    if ( typeof editor.config.pageStyleSheets !== 'undefined' )
    {
      for ( var i = 0; i < editor.config.pageStyleSheets.length; i++ )
      {
        if ( editor.config.pageStyleSheets[i].length > 0 )
        {
          html += "<link rel=\"stylesheet\" type=\"text/css\" href=\"" + editor.config.pageStyleSheets[i] + "\">";
          //html += "<style> @import url('" + editor.config.pageStyleSheets[i] + "'); </style>\n";
        }
      }
    }

    html += "</head>";
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
  doc.write(html);
  doc.close();


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
      _xo_style = '';

      if ( ['strong','em','b','i','u','span','font'].contains(tag) && _xo_el.style) {
	  _xo_tmp = Ext.fly(_xo_el);
	  if (tag == 'strong' || tag == 'b' || _xo_tmp.getStyle('font-weight') == 'bold') {
	      _xo_style += 'bold ';
	  }
	  if (Xinha.is_ie) {
	      if (_xo_tmp.getStyle('background-color') != 16777215) {
		  _xo_style += 'highlight ';
	      }
	  } else {
	      if (_xo_tmp.getStyle('background-color') != 'transparent') {
		  _xo_style += 'highlight ';
	      }
	  }
	  if (tag == 'em' || tag == 'i' || _xo_tmp.getStyle('font-style') == 'italic') {
	      _xo_style += 'italic ';
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
      
      
      if (_xo_style != '') {
	  _xo_node = editor._doc.createElement('font');
	  _xo_node.setAttribute('_xo',1);
	  _xo_node.setAttribute('class',_xo_style.trim());
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



Xinha.addCoreCSS = function(html)
{
    var coreCSS = 
    "<style type=\"text/css\">"
    + "html, body { border: 0px; } \n"
    + "body { background-color: #ffffff; } \n" 
    + ".bold { font-weight: bold; } \n" 
    + ".italic { font-style: italic; } \n" 
    + ".highlight { background-color:rgb(255,255,204); } \n" 
    +"</style>\n";
    
    if( html && /<head>/i.test(html))
    {
      return html.replace(/<head>/i, '<head>' + coreCSS);      
    }
    else if ( html)
    {
      return coreCSS + html;
    }
    else
    {
      return coreCSS;
    }
}

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

// Gecko Browser
/** Allow Gecko to handle some key events in a special way.
 */
  
if (Xinha.is_gecko) {

    Xinha.prototype.startRange = function(node) {
	var sourceRange=this.createRange()
	sourceRange.selectNodeContents(node);
	sourceRange.collapse(true);
	return sourceRange;
    }

Xinha.prototype.textContent = function(node) {
	if (node == null) return '';
    var extra='';
    if (node.innerHTML != null) {
	extra = node.innerHTML.match(Xinha.RE_img)!=null ? 'X' : '';
    }
    return node.textContent + extra;
};



Xinha.prototype.getSelectedHTML = function() {
  var sel = this.getSelection();
  var range = this.createRange(sel);
  return Xinha.getHTML(range.cloneContents(), false, this);
};


Xinha.prototype.collapsed = function(rng) {
	return rng.collapsed;
};




Xinha.prototype.isEndPos = function() {
	var _xo_sel,_xo_rng,_xo_node,i,LCN,tmpRange;
    _xo_sel = this.getSelection();
    _xo_rng = this.createRange(_xo_sel);
    _xo_node = this.getParentElement();
    if (_xo_node) {
		if (_xo_node.length == 0 || _xo_node.childNodes.length == 0) {
			return true;
		}
	    i=_xo_node.childNodes.length-1;
	    LCN = _xo_node.childNodes[i];

	    if (!LCN) {
		return true;
	    }

	    if (LCN.nodeType == Node.ELEMENT_NODE) {
		    tmpRange = this.createRange();
		    tmpRange.setEndAfter(LCN);
		    tmpRange.setStartAfter(LCN);
	    } else {
		    tmpRange = this.createRange();
		    tmpRange.setEnd(LCN,LCN.length);
		    tmpRange.setStart(LCN,LCN.length);
	    }

	    return 0 == _xo_rng.compareBoundaryPoints(Range.END_TO_END,tmpRange);
    } else {
	return false;
    }
}

Xinha.prototype.isStartPos = function() {
	var _xo_sel,_xo_rng,_xo_node,i,FCN,tmpRange;
    _xo_sel = this.getSelection();
    _xo_rng = this.createRange(_xo_sel);
    _xo_node = this.getParentElement();
    if (_xo_node) {
		if (_xo_node.length == 0 || _xo_node.childNodes.length == 0) {
			return true;
		}
	    i=0;
	    while (_xo_node.childNodes[i] && _xo_node.childNodes[i].length == 0 && i<_xo_node.childNodes.length) {
		i++;
	    }
	    FCN = _xo_node.childNodes[i];
	    if (!FCN) {
		return true;
	    }
	    if (FCN && FCN.nodeType == Node.ELEMENT_NODE) {
		    tmpRange = this.createRange();
		    tmpRange.setStartBefore(FCN);
		    tmpRange.setEndBefore(FCN);
	    } else {
		    tmpRange = this.createRange();
		    tmpRange.setStart(FCN,0);
		    tmpRange.setEnd(FCN,0);
	    }

	    return  0 == _xo_rng.compareBoundaryPoints(Range.START_TO_START,tmpRange);
    } else {
	return false;
    }
}


Xinha.prototype.onKeyPress = function(ev)
{
  var editor = this;
  var s = this.getSelection();

  // If they've hit enter and shift is not pressed, handle it
  
  if (ev.getKey()==ev.ENTER && !ev.shiftKey && this._iframe.contentWindow.getSelection) {
    return this.handleEnter(ev);
  }
  //AK Change (shift+enter not to work inside <p>)
  else if (ev.getKey()==ev.ENTER && ev.shiftKey)
  {
  	var blocks = ["p","body"];
	var _xo_first_ancestor_node = this._getFirstAncestor(this.getSelection(),blocks);
	//dump(_xo_first_ancestor_node);
	//alert(_xo_first_ancestor_node);
	if (_xo_first_ancestor_node) {
		Xinha._stopEvent(ev);
		return true;
	}
  }

  
  // Handle shortcuts
  if(this.isShortCut(ev))
  {
    switch(ev.getKey())
    {
      case ev.Z:
      {
        if(this._unLink && this._unlinkOnUndo)
        {
          Xinha._stopEvent(ev);
          this._unLink();
          this.updateToolbar();
          return true;
        }
      }
      break;
      
      case ev.A:
      {
        // KEY select all
        sel = this.getSelection();
        sel.removeAllRanges();
        range = this.createRange();
        range.selectNodeContents(this._doc.body);
        sel.addRange(range);
        Xinha._stopEvent(ev);
        return true;
      }
      break;
      
      case ev.V:
      {
        // If we are not using htmlareaPaste, don't let Xinha try and be fancy but let the 
        // event be handled normally by the browser (don't stopEvent it)
        if(!this.config.htmlareaPaste)
        {          
          return true;
        }
      }
      break;
    }
  }
  
  // Handle normal characters
  switch(ev.getKey()) {
    // Space, see if the text just typed looks like a URL, or email address
    // and link it appropriatly
    case ev.SPACE:
    {      
	if ( this._customUndo && this._editMode == 'wysiwyg') { this._undoTakeSnapshot(); }


      var autoWrap = function (textNode, tag)
      {
        var rightText = textNode.nextSibling;
        if ( typeof tag == 'string')
        {
          tag = this._doc.createElement(tag);
        }
        var a = textNode.parentNode.insertBefore(tag, rightText);
        Xinha.removeFromParent(textNode);
        a.appendChild(textNode);
        rightText.data = ' ' + rightText.data;
    
        s.collapse(rightText, 1);
    
        this._unLink = function()
        {
          var t = a.firstChild;
          a.removeChild(t);
          a.parentNode.insertBefore(t, a);
          Xinha.removeFromParent(a);
          this._unLink = null;
          this._unlinkOnUndo = false;
        };
        this._unlinkOnUndo = true;
        this._xo_garbageCollect();
        return a;
      };
  


      if ( this.config.convertUrlsToLinks && s && s.isCollapsed && s.anchorNode.nodeType == 3 && s.anchorNode.data.length > 3 && s.anchorNode.data.indexOf('.') >= 0 )
      {
        var midStart = s.anchorNode.data.substring(0,s.anchorOffset).search(/\S{4,}$/);
        if ( midStart == -1 )
        {
          break;
        }

        if ( this._getFirstAncestor(s, 'a') )
        {
          break; // already in an anchor
        }

        var matchData = s.anchorNode.data.substring(0,s.anchorOffset).replace(/^.*?(\S*)$/, '$1');

        var mEmail = matchData.match(Xinha.RE_email);
        if ( mEmail )
        {
          var leftTextEmail  = s.anchorNode;
          var rightTextEmail = leftTextEmail.splitText(s.anchorOffset);
          var midTextEmail   = leftTextEmail.splitText(midStart);

          autoWrap(midTextEmail, 'a').href = 'mailto:' + mEmail[0];
          break;
        }

        RE_date = /([0-9]+\.)+/; //could be date or ip or something else ...
        RE_ip = /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/;
        var mUrl = matchData.match(Xinha.RE_url);
        if ( mUrl )
        {
          if (RE_date.test(matchData))
          {
            if (!RE_ip.test(matchData)) 
            {
              break;
            }
          } 
          var leftTextUrl  = s.anchorNode;
          var rightTextUrl = leftTextUrl.splitText(s.anchorOffset);
          var midTextUrl   = leftTextUrl.splitText(midStart);
          autoWrap(midTextUrl, 'a').href = (mUrl[1] ? mUrl[1] : 'http://') + mUrl[2];
          break;
        }
      }
    }
    break;    
  }
  
	// Handle special keys
  switch ( ev.getKey() )
  {    

    case ev.ESCAPE:
    {
      if ( this._unLink )
      {
        this._unLink();
        Xinha._stopEvent(ev);
      }
      break;
    }
    break;
	//AK Change
	case ev.LEFT: //left
 	{
		var range = this.createRange(s);
		if (range.collapsed) {
			l = this.getParentElement();
			//console.log(l);
			if ( l && l.tagName.toLowerCase() != 'body' ) {
				if (this.isStartPos() && l.parentNode.tagName.toLowerCase() != 'body') {
					if (l.previousSibling) {
					    range.selectNodeContents(l.previousSibling);
					    range.collapse(false);
                                        } else {
					    range.setStartBefore(l);
					    range.setEndBefore(l);
					}
					Xinha._stopEvent(ev);
				}
			}
		}
		break;
	}
	case ev.RIGHT: //right
	{
		var range = this.createRange(s);
		if (range.collapsed) {
			l = this.getParentElement();
			if ( l  && l.tagName.toLowerCase() != 'body' ) {
				if (this.isEndPos() && l.parentNode.tagName.toLowerCase() != 'body') {
					if (l.nextSibling) {
						range.setEnd(l.nextSibling,0);
						range.setStart(l.nextSibling,0);
                                        } else {
						range.setEndAfter(l);
						range.setStartAfter(l);
					}
					Xinha._stopEvent(ev);
				}
			}
		}
		break;
	}
	//AK Change -- end
    
    case ev.BACKSPACE:
    case ev.DELETE:
    {

	sel = this.getSelection();
  	rng = this.createRange(sel);
		
	_xo_stop_p = false;
	_xo_blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
	_xo_fan = this._getFirstAncestor(this.getSelection(),_xo_blocks);


	  if (!rng.collapsed) {
		_xo_p = false;
		if ( rng.endContainer != rng.startContainer) {
			if (ev.getKey() == ev.DELETE) {
				_xo_p = rng.startContainer;
				_xo_collapse_to_start = false;
			} else if (ev.getKey() == ev.BACKSPACE) {
				_xo_p = rng.endContainer;
				_xo_collapse_to_start = true;
			}
			while (_xo_p.nodeType == 3) {
				_xo_p=_xo_p.parentNode;
			}
		}
		rng.deleteContents();

		if (_xo_p) {
			rng.selectNodeContents(_xo_p);
			rng.collapse(_xo_collapse_to_start);
		} 

		_xo_fan = this._getFirstAncestor(this.getSelection(),_xo_blocks);

		_xo_stop_p = true;
		_xo_deleted_p = true;

	  }

	var sourceRange=this.startRange(Ext.get(this._doc.body).first().dom);
	var comparePoint=rng.compareBoundaryPoints(Range.START_TO_END,sourceRange);
	//console.log("comparePoint="+comparePoint);
	if (ev.getKey() == ev.BACKSPACE && 0 == comparePoint) {
	    ev.stopEvent();
	    return false;
	}


		_xo_regexp = /[ \t\n\r\s\xAD\xA0]/g;
		_xo_PS = _xo_fan.previousSibling;
		_xo_NS = _xo_fan.nextSibling;



	if (this.textContent(_xo_fan).replace(_xo_regexp,'').length == 1) {

		p = rng.startContainer
		while (p.nodeType == 3) p=p.parentNode;
		_xo_start_textContent = this.textContent(p);

		p = rng.endContainer
		while (p.nodeType == 3) p=p.parentNode;
		_xo_end_textContent = this.textContent(p);


		_xo_text_to_start = '';
		_xo_text_to_end = '';
		_xo_start_offset = rng.startOffset;
		_xo_end_offset = rng.endOffset;
		if (_xo_start_offset>0 && ev.getKey() == ev.BACKSPACE && rng.collapsed) {
			_xo_start_offset--;
		}
		if (_xo_end_offset < _xo_end_textContent.length && ev.getKey() == ev.DELETE && rng.collapsed) {
			_xo_end_offset++;
		}
		if (_xo_start_textContent.length) {
			_xo_text_to_start = _xo_start_textContent.substr(0,_xo_start_offset);
		}
		if ( _xo_end_textContent.length) {
			_xo_text_to_end = _xo_end_textContent.substring(_xo_end_offset);
		}
		//alert('@parentNodeText: ' + this.textContent(_xo_fan) + '@so: ' + _xo_start_offset + '@eo: ' + _xo_end_offset + ' @startContainerText: ' + _xo_start_textContent + ' @endContainerText: ' + _xo_end_textContent + ' @ts: ' + _xo_text_to_start + ' @te: ' + _xo_text_to_end);

		// if current node after delete/backspace is empty
		if ((_xo_text_to_start + _xo_text_to_end).replace(_xo_regexp,'').length == 0) {

			//alert('@ps: ' + this.textContent(_xo_PS));
			//and previous sibling is empty then remove previous sibling
			if (_xo_PS && this.textContent(_xo_PS).replace(_xo_regexp,'').length == 0) {
				_xo_PS.innerHTML='';
				Xinha.removeFromParent(_xo_PS);
			}
			//and next sibling is empty then remove next sibling
			if (!_xo_NS && _xo_fan.parentNode) {
				_xo_NS = _xo_fan.parentNode.nextSibling;
			}
			if (_xo_NS && this.textContent(_xo_NS).replace(_xo_regexp,'').length == 0) {
				_xo_NS.innerHTML='';
				Xinha.removeFromParent(_xo_NS);
			}
		}
	} else if (_xo_fan.tagName.toLowerCase() == 'p') {
		_xo_start_textContent = '';
                p = rng.startContainer;
                while (p.nodeType == 3) p=p.parentNode;
                _xo_start_textContent = this.textContent(p);

		_xo_end_textContent = '';
                p = rng.endContainer;
                while (p.nodeType == 3) p=p.parentNode;
                _xo_end_textContent = this.textContent(_xo_NS);

		_xo_text_to_start = '';
		_xo_text_to_end = '';
		_xo_start_offset = rng.startOffset;
		_xo_end_offset = rng.endOffset;
                if (_xo_start_textContent.length) {
			rng_clone = rng.cloneRange();
			rng_clone.setStartBefore(_xo_fan);
                        _xo_text_to_start = rng_clone.toString(); // _xo_start_textContent.substr(0,_xo_start_offset);
                }
                if ( _xo_end_textContent.length) {
			rng_clone = rng.cloneRange();
			rng_clone.setEndAfter(_xo_fan);
                        _xo_text_to_end = rng_clone.toString(); // _xo_text_to_end = _xo_end_textContent.substring(_xo_end_offset);
                }

//	alert(_xo_text_to_start +' XXX ' + _xo_text_to_end);
//	alert(_xo_start_textContent +' XXX ' + _xo_end_textContent + ' YYY ' + _xo_start_offset + ' ' + _xo_end_offset);

		if (ev.getKey() == ev.BACKSPACE && _xo_PS && _xo_PS.tagName && _xo_PS.tagName.toLowerCase() == 'p' && _xo_text_to_start.replace(_xo_regexp,'').length == 0) {
                    rng.selectNodeContents(_xo_fan);
                    _xo_DF = rng.extractContents();
                    _xo_PS.innerHTML = _xo_PS.innerHTML.replace(/(^\<br\s*\/?\>|^\&nbsp\;|\<br\s*\/?\>$)/,'');
                    rng.selectNodeContents(_xo_PS);
                    rng.collapse(false);
                    _xo_PS.appendChild(_xo_DF);
                    //_xo_fan.innerHTML = '';
                    Xinha.removeFromParent(_xo_fan);
                    Xinha._stopEvent(ev);
		}

//		alert(_xo_start_offset + ' ' +_xo_end_offset + ' ' + _xo_text_to_end.length + 'collapsed: ' + rng.collapsed);
//		     alert(_xo_NS.innerHTML);

		if (ev.getKey() == ev.DELETE && _xo_NS && _xo_NS.tagName.toLowerCase() == 'p' && _xo_text_to_end.replace(_xo_regexp,'').length == 0) {
			_xo_NS.innerHTML = _xo_NS.innerHTML.replace(/(^\&nbsp\;|^\<br\s*\/?\>|\&nbsp\;$)/,'');
                     rng.selectNodeContents(_xo_NS);
		     _xo_DF = rng.extractContents();
                      _xo_fan.innerHTML = _xo_fan.innerHTML.replace(/(\&nbsp\;$|\<br\s*\/?\>$)/,'');
                     rng.selectNodeContents(_xo_fan);
                     rng.collapse(false);
                     _xo_fan.appendChild(_xo_DF);
		     //_xo_NS.innerHTML = '';
                     Xinha.removeFromParent(_xo_NS);
                    Xinha._stopEvent(ev);
		}		
	}
        this._xo_garbageCollect();
	return true;
    }
    
    default:
    {
        this._unlinkOnUndo = false;

        // Handle the "auto-linking", specifically this bit of code sets up a handler on
        // an self-titled anchor (eg <a href="http://www.gogo.co.nz/">www.gogo.co.nz</a>)
        // when the text content is edited, such that it will update the href on the anchor
        
        if ( s.anchorNode && s.anchorNode.nodeType == 3 )
        {
          // See if we might be changing a link
          var a = this._getFirstAncestor(s, 'a');
          // @todo: we probably need here to inform the setTimeout below that we not changing a link and not start another setTimeout
          if ( !a )
          {
            break; // not an anchor
          } 
          
          if ( !a._updateAnchTimeout )
          {
            if ( s.anchorNode.data.match(Xinha.RE_email) && a.href.match('mailto:' + s.anchorNode.data.trim()) )
            {
              var textNode = s.anchorNode;
              var fnAnchor = function()
              {
                a.href = 'mailto:' + textNode.data.trim();
                // @fixme: why the hell do another timeout is started ?
                //         This lead to never ending timer if we dont remove this line
                //         But when removed, the email is not correctly updated
                //
                // - to fix this we should make fnAnchor check to see if textNode.data has
                //   stopped changing for say 5 seconds and if so we do not make this setTimeout 
                a._updateAnchTimeout = setTimeout(fnAnchor, 250);
              };
              a._updateAnchTimeout = setTimeout(fnAnchor, 1000);
              break;
            }

            var m = s.anchorNode.data.match(Xinha.RE_url);
            if ( m && a.href.match(s.anchorNode.data.trim()) )
            {
              var txtNode = s.anchorNode;
              var fnUrl = function()
              {
                // Sometimes m is undefined becase the url is not an url anymore (was www.url.com and become for example www.url)
                m = txtNode.data.match(Xinha.RE_url);
                if(m)
                {
                  a.href = (m[1] ? m[1] : 'http://') + m[2];
                }
                
                // @fixme: why the hell do another timeout is started ?
                //         This lead to never ending timer if we dont remove this line
                //         But when removed, the url is not correctly updated
                //
                // - to fix this we should make fnUrl check to see if textNode.data has
                //   stopped changing for say 5 seconds and if so we do not make this setTimeout
                a._updateAnchTimeout = setTimeout(fnUrl, 250);
              };
              a._updateAnchTimeout = setTimeout(fnUrl, 1000);
            }
          }        
        }                
    }
    break;
  }

  this._xo_garbageCollect();
  return false; // Let other plugins etc continue from here.
}


Xinha.prototype._inwardHtml = function(html)
{
   // Midas uses b and i internally instead of strong and em
   // Xinha will use strong and em externally (see Xinha.prototype.outwardHtml)   
   html = html.replace(/<(\/?)strong(\s|>|\/)/ig, "<$1b$2");
   html = html.replace(/<(\/?)em(\s|>|\/)/ig, "<$1i$2");    
   
   // Both IE and Gecko use strike internally instead of del (#523)
   // Xinha will present del externally (see Xinha.prototype.outwardHtml
   html = html.replace(/<(\/?)del(\s|>|\/)/ig, "<$1strike$2");
   
   return html;
}

Xinha.prototype._outwardHtml = function(html)
{
  // ticket:56, the "greesemonkey" plugin for Firefox adds this junk,
  // so we strip it out.  Original submitter gave a plugin, but that's
  // a bit much just for this IMHO - james
  html = html.replace(/<script[\s]*src[\s]*=[\s]*['"]chrome:\/\/.*?["']>[\s]*<\/script>/ig, '');

  return html;
}



/*--------------------------------------------------------------------------*/
/*------- IMPLEMENTATION OF THE ABSTRACT "Xinha.prototype" METHODS ---------*/
/*--------------------------------------------------------------------------*/

/** Insert a node at the current selection point. 
 * @param toBeInserted DomNode
 */

Xinha.prototype.insertNodeAtSelection = function(toBeInserted)
{
  var sel = this.getSelection();
  var range = this.createRange(sel);
  // remove the current selection
  sel.removeAllRanges();
  range.deleteContents();
  var node = range.startContainer;
  var pos = range.startOffset;
  var selnode = toBeInserted;
  switch ( node.nodeType )
  {
    case 3: // Node.TEXT_NODE
      // we have to split it at the caret position.
      if ( toBeInserted.nodeType == 3 )
      {
        // do optimized insertion
        node.insertData(pos, toBeInserted.data);
        range = this.createRange();
        range.setEnd(node, pos + toBeInserted.length);
        range.setStart(node, pos + toBeInserted.length);
        sel.addRange(range);
      }
      else
      {
        node = node.splitText(pos);
        if ( toBeInserted.nodeType == 11 /* Node.DOCUMENT_FRAGMENT_NODE */ )
        {
          selnode = selnode.firstChild;
        }
        node.parentNode.insertBefore(toBeInserted, node);
        this.selectNodeContents(selnode);
        this.updateToolbar();
      }
    break;
    case 1: // Node.ELEMENT_NODE
      if ( toBeInserted.nodeType == 11 /* Node.DOCUMENT_FRAGMENT_NODE */ )
      {
        selnode = selnode.firstChild;
      }
      node.insertBefore(toBeInserted, node.childNodes[pos]);
      this.selectNodeContents(selnode);
      this.updateToolbar();
    break;
  }
};
  
/** Get the parent element of the supplied or current selection. 
 *  @param   sel optional selection as returned by getSelection
 *  @returns DomNode
 */
 
Xinha.prototype.getParentElement = function(sel)
{
  if ( typeof sel == 'undefined' )
  {
    sel = this.getSelection();
  }
  range = this.createRange(sel);
  try
  {
    p = range.commonAncestorContainer;
    if ( !range.collapsed && range.startContainer == range.endContainer &&
        range.startOffset - range.endOffset <= 1 && range.startContainer.hasChildNodes() )
    {
      p = range.startContainer.childNodes[range.startOffset];
    }

    while ( p.nodeType == 3 )
    {
      p = p.parentNode;
    }
    return p;
  }
  catch (ex)
  {
    return null;
  }
};

/**
 * Returns the selected element, if any.  That is,
 * the element that you have last selected in the "path"
 * at the bottom of the editor, or a "control" (eg image)
 *
 * @returns null | DomNode
 */

Xinha.prototype.activeElement = function(sel)
{
  if ( ( sel === null ) || this.selectionEmpty(sel) )
  {
    return null;
  }

  // For Mozilla we just see if the selection is not collapsed (something is selected)
  // and that the anchor (start of selection) is an element.  This might not be totally
  // correct, we possibly should do a simlar check to IE?
  if ( !sel.isCollapsed )
  {      
    if ( sel.anchorNode.childNodes.length > sel.anchorOffset && sel.anchorNode.childNodes[sel.anchorOffset].nodeType == 1 )
    {
      return sel.anchorNode.childNodes[sel.anchorOffset];
    }
    else if ( sel.anchorNode.nodeType == 1 )
    {
      return sel.anchorNode;
    }
    else
    {
      return null; // return sel.anchorNode.parentNode;
    }
  }
  return null;
};

/** 
 * Determines if the given selection is empty (collapsed).
 * @param selection Selection object as returned by getSelection
 * @returns true|false
 */
 
Xinha.prototype.selectionEmpty = function(sel)
{
  if ( !sel )
  {
    return true;
  }

  if ( typeof sel.isCollapsed != 'undefined' )
  {      
    return sel.isCollapsed;
  }

  return true;
};


/**
 * Selects the contents of the given node.  If the node is a "control" type element, (image, form input, table)
 * the node itself is selected for manipulation.
 *
 * @param node DomNode 
 * @param pos  Set to a numeric position inside the node to collapse the cursor here if possible. 
 */

Xinha.prototype.selectNodeContents = function(node, pos)
{
  this.focusEditor();
  this.forceRedraw();
  var range;
  var collapsed = typeof pos == "undefined" ? true : false;
  var sel = this.getSelection();
  range = this._xo_doc().createRange();
  // Tables and Images get selected as "objects" rather than the text contents
  if ( collapsed && node.tagName && node.tagName.toLowerCase().match(/table|img|input|textarea|select/) )
  {
    range.selectNode(node);
  }
  else
  {
    range.selectNodeContents(node);
    //(collapsed) && range.collapse(pos);
  }
  sel.removeAllRanges();
  sel.addRange(range);
};
  

/** Get the HTML of the current selection.  HTML returned has not been passed through outwardHTML.
 *
 * @returns string
 */
 
Xinha.prototype.getSelectedHTML = function()
{
  var sel = this.getSelection();
  var range = this.createRange(sel);
  return Xinha.getHTML(range.cloneContents(), false, this);
};
  

/** Get a Selection object of the current selection.  Note that selection objects are browser specific.
 *
 * @returns Selection
 */
 
Xinha.prototype.getSelection = function()
{
  return this._xo_iframe().contentWindow.getSelection();
};
  
/** Create a Range object from the given selection.  Note that range objects are browser specific.
 *
 *  @param sel Selection object (see getSelection)
 *  @returns Range
 */
 
Xinha.prototype.createRange = function(sel)
{
  this.activateEditor();
  if ( typeof sel != "undefined" )
  {
    try
    {
      return sel.getRangeAt(0);
    }
    catch(ex)
    {
      return this._xo_doc().createRange();
    }
  }
  else
  {
    return this._xo_doc().createRange();
  }
};

/** Determine if the given event object is a keydown/press event.
 *
 *  @param event Event 
 *  @returns true|false
 */
 
Xinha.prototype.isKeyEvent = function(event)
{
  return event.type == "keypress";
}



/** Return the HTML string of the given Element, including the Element.
 * 
 * @param element HTML Element DomNode
 * @returns string
 */
 
Xinha.getOuterHTML = function(element)
{
  return (new XMLSerializer()).serializeToString(element);
};

//Control character for retaining edit location when switching modes
Xinha.prototype.cc = String.fromCharCode(173); 

Xinha.prototype.setCC = function ( target )
{
  if ( target == "textarea" )
  {
    var ta = this._xo_textArea();
    var index = ta.selectionStart;
	while (index < ta.value.length && ta.value[index] != ' ') {
		index++;
	}
    var before = ta.value.substring( 0, index )
    var after = ta.value.substring( index, ta.value.length );

	ta.value = before + this.cc + after;
  }
  else
  {
    var sel = this.getSelection();
    sel.getRangeAt(0).insertNode( document.createTextNode( this.cc ) );
  }
};

Xinha.prototype.findCC = function ( target )
{

  var findIn = ( target == 'textarea' ) ? window : this._xo_iframe().contentWindow;
  if( findIn.find( this.cc ) )
  {
    if (target == "textarea")
    {
      var ta = this._xo_textArea();
      var start = pos = ta.selectionStart;
      var end = ta.selectionEnd;
      var scrollTop = ta.scrollTop;
      ta.value = ta.value.substring( 0, start ) + ta.value.substring( end, ta.value.length );
      ta.selectionStart = pos;
      ta.selectionEnd = pos;
      ta.scrollTop = scrollTop
      ta.focus();
    }
    else
    {
      var sel = this.getSelection();
      sel.getRangeAt(0).deleteContents();
    }
  }  
};


Xinha.prototype.insertAtCursor = function(text) { this._xo_doc().execCommand('InsertHTML', false, text); }


// --------------------------------------------------------------------------------------





// "constants"

/**
* Whitespace Regex
*/

Xinha.prototype._whiteSpace = /^\s*$/;

/**
* The pragmatic list of which elements a paragraph may not contain
*/

Xinha.prototype._pExclusions = /^(address|blockquote|body|dd|div|dl|dt|fieldset|form|h1|h2|h3|h4|h5|h6|hr|li|noscript|ol|p|pre|table|ul)$/i;

/**
* elements which may contain a paragraph
*/

Xinha.prototype._pContainers = /^(body|del|div|fieldset|form|ins|map|noscript|object|td|th)$/i;

/**
* Elements which may not contain paragraphs, and would prefer a break to being split
*/

Xinha.prototype._pBreak = /^(address|pre|blockquote)$/i;

/**
* Elements which may not contain children
*/

Xinha.prototype._permEmpty = /^(area|base|basefont|br|col|frame|hr|img|input|isindex|link|meta|param)$/i;

/**
* Elements which count as content, as distinct from whitespace or containers
*/

Xinha.prototype._elemSolid = /^(applet|br|button|hr|img|input|table)$/i;

/**
* Elements which should get a new P, before or after, when enter is pressed at either end
*/

Xinha.prototype._pifySibling = /^(address|blockquote|del|div|dl|fieldset|form|h1|h2|h3|h4|h5|h6|hr|ins|map|noscript|object|ol|p|pre|table|ul|)$/i;
Xinha.prototype._pifyForced = /^(ul|ol|dl|table)$/i;

/**
* Elements which should get a new P, before or after a close parent, when enter is pressed at either end
*/

Xinha.prototype._pifyParent = /^(dd|dt|li|td|th|tr)$/i;

// ---------------------------------------------------------------------

/**
* EnterParagraphs Constructor
*/


// ------------------------------------------------------------------

/**
* name member for debugging
*
* This member is used to identify objects of this class in debugging
* messages.
*/
Xinha.prototype.name = "EnterParagraphs";

/**
* Gecko's a bit lacking in some odd ways...
*/
Xinha.prototype.insertAdjacentElement = function(ref,pos,el)
{
  if ( pos == 'BeforeBegin' )
  {
    ref.parentNode.insertBefore(el,ref);
  }
  else if ( pos == 'AfterEnd' )
  {
    ref.nextSibling ? ref.parentNode.insertBefore(el,ref.nextSibling) : ref.parentNode.appendChild(el);
  }
  else if ( pos == 'AfterBegin' && ref.firstChild )
  {
    ref.insertBefore(el,ref.firstChild);
  }
  else if ( pos == 'BeforeEnd' || pos == 'AfterBegin' )
  {
    ref.appendChild(el);
  }
  
};	// end of insertAdjacentElement()

// ----------------------------------------------------------------

/**
* Passes a global parent node or document fragment to forEachNode
*
* @param root node root node to start search from.
* @param mode string function to apply to each node.
* @param direction string traversal direction "ltr" (left to right) or "rtl" (right_to_left)
* @param init boolean
*/

Xinha.prototype.forEachNodeUnder = function ( root, mode, direction, init )
{
  
  // Identify the first and last nodes to deal with
  var start, end;
  
  // nodeType 11 is DOCUMENT_FRAGMENT_NODE which is a container.
  if ( root.nodeType == 11 && root.firstChild )
  {
    start = root.firstChild;
    end = root.lastChild;
  }
  else
  {
    start = end = root;
  }
  // traverse down the right hand side of the tree getting the last child of the last
  // child in each level until we reach bottom.
  while ( end.lastChild )
  {
    end = end.lastChild;
  }
  
  return this.forEachNode( start, end, mode, direction, init);
  
};	// end of forEachNodeUnder()

// -----------------------------------------------------------------------

/**
* perform a depth first descent in the direction requested.
*
* @param left_node node "start node"
* @param right_node node "end node"
* @param mode string function to apply to each node. cullids or emptyset.
* @param direction string traversal direction "ltr" (left to right) or "rtl" (right_to_left)
* @param init boolean or object.
*/

Xinha.prototype.forEachNode = function (left_node, right_node, mode, direction, init)
{
  
  // returns "Brother" node either left or right.
  var getSibling = function(elem, direction)
	{
    return ( direction == "ltr" ? elem.nextSibling : elem.previousSibling );
	};
  
  var getChild = function(elem, direction)
	{
    return ( direction == "ltr" ? elem.firstChild : elem.lastChild );
	};
  
  var walk, lookup, fnReturnVal;
  
  // FIXME: init is a boolean in the emptyset case and an object in
  // the cullids case. Used inconsistently.
  
  var next_node = init;
  
  // used to flag having reached the last node.
  
  var done_flag = false;
  
  // loop ntil we've hit the last node in the given direction.
  // if we're going left to right that's the right_node and visa-versa.
  
  while ( walk != direction == "ltr" ? right_node : left_node )
  {
    
    // on first entry, walk here is null. So this is how
    // we prime the loop with the first node.
    
    if ( !walk )
    {
      walk = direction == "ltr" ? left_node : right_node;
    }
    else
    {
      
      // is there a child node?
      
      if ( getChild(walk,direction) )
      {
        
        // descend down into the child.
        
        walk = getChild(walk,direction);
        
      }
      else
      {
        
        // is there a sibling node on this level?
        
        if ( getSibling(walk,direction) )
        {
          // move to the sibling.
          walk = getSibling(walk,direction); 
        }
        else
        {
          lookup = walk;
          
          // climb back up the tree until we find a level where we are not the end
          // node on the level (i.e. that we have a sibling in the direction
            // we are searching) or until we reach the end.
          
          while ( !getSibling(lookup,direction) && lookup != (direction == "ltr" ? right_node : left_node) )
          {
            lookup = lookup.parentNode;
          }
          
          // did we find a level with a sibling?
          
          // walk = ( lookup.nextSibling ? lookup.nextSibling : lookup ) ;
          
          walk = ( getSibling(lookup,direction) ? getSibling(lookup,direction) : lookup ) ;
          
        }
      }
      
    }	// end of else walk.
    
    // have we reached the end? either as a result of the top while loop or climbing
    // back out above.
    
    done_flag = (walk==( direction == "ltr" ? right_node : left_node));
    
    // call the requested function on the current node. Functions
    // return an array.
    //
    // Possible functions are _fenCullIds, _fenEmptySet
    //
    // The situation is complicated by the fact that sometimes we want to
    // return the base node and sometimes we do not.
    //
    // next_node can be an object (this.takenIds), a node (text, el, etc) or false.
    
    switch( mode )
    {
      
    case "cullids":
      
      fnReturnVal = this._fenCullIds(walk, next_node );
      break;
      
    case "find_fill":
      
      fnReturnVal = this._fenEmptySet(walk, next_node, mode, done_flag);
      break;
      
    case "find_cursorpoint":
      
      fnReturnVal = this._fenEmptySet(walk, next_node, mode, done_flag);
      break;
      
    }
    
    // If this node wants us to return, return next_node
    
    if ( fnReturnVal[0] )
    {
      return fnReturnVal[1];
    }
    
    // are we done with the loop?
    
    if ( done_flag )
    {
      break;
    }
    
    // Otherwise, pass to the next node
    
    if ( fnReturnVal[1] )
    {
      next_node = fnReturnVal[1];
    }
    
  }	// end of while loop
  
  return false;
  
};	// end of forEachNode()

// -------------------------------------------------------------------

/**
* Find a post-insertion node, only if all nodes are empty, or the first content
*
* @param node node current node beinge examined.
* @param next_node node next node to be examined.
* @param node string "find_fill" or "find_cursorpoint"
* @param last_flag boolean is this the last node?
*/

Xinha.prototype._fenEmptySet = function( node, next_node, mode, last_flag)
{
  
  // Mark this if it's the first base
  
  if ( !next_node && !node.firstChild )
  {
    next_node = node;
  }
  
  // Is it an element node and is it considered content? (br, hr, etc)
  // or is it a text node that is not just whitespace?
  // or is it not an element node and not a text node?
  
  if ( (node.nodeType == 1 && this._elemSolid.test(node.nodeName)) ||
    (node.nodeType == 3 && !this._whiteSpace.test(node.nodeValue)) ||
  (node.nodeType != 1 && node.nodeType != 3) )
  {
    
    switch( mode )
    {
      
    case "find_fill":
      
      // does not return content.
      
      return new Array(true, false );
      break;
      
    case "find_cursorpoint":
      
      // returns content
      
      return new Array(true, node );
      break;
      
    }
    
  }
  
  // In either case (fill or findcursor) we return the base node. The avoids
  // problems in terminal cases (beginning or end of document or container tags)
  
  if ( last_flag )
  {
    return new Array( true, next_node );
  }
  
  return new Array( false, next_node );
  
};	// end of _fenEmptySet()

// ------------------------------------------------------------------------------

/**
* remove duplicate Id's.
*
* @param ep_ref enterparagraphs reference to enterparagraphs object
*/

Xinha.prototype._fenCullIds = function ( ep_ref, node, pong )
{
  
  // Check for an id, blast it if it's in the store, otherwise add it
  
  if ( node.id )
  {
    
    pong[node.id] ? node.id = '' : pong[node.id] = true;
  }
  
  return new Array(false,pong);
  
};

// ---------------------------------------------------------------------------------

/**
* Grabs a range suitable for paragraph stuffing
*
* @param rng Range
* @param search_direction string "left" or "right"
*
* @todo check blank node issue in roaming loop.
*/

Xinha.prototype.processSide = function( rng, search_direction)
{
  
  var next = function(element, search_direction)
	{
    return ( search_direction == "left" ? element.previousSibling : element.nextSibling );
	};
  
  var node = search_direction == "left" ? rng.startContainer : rng.endContainer;
  var offset = search_direction == "left" ? rng.startOffset : rng.endOffset;
  var roam, start = node;
  
  // Never start with an element, because then the first roaming node might
  // be on the exclusion list and we wouldn't know until it was too late
  
  while ( start.nodeType == 1 && !this._permEmpty.test(start.nodeName) )
  {
    start = ( offset ? start.lastChild : start.firstChild );
  }
  
  // Climb the tree, left or right, until our course of action presents itself
  //
  // if roam is NULL try start.
  // if roam is NOT NULL, try next node in our search_direction
  // If that node is NULL, get our parent node.
  //
  // If all the above turns out NULL end the loop.
  //
  // FIXME: gecko (firefox 1.0.3) - enter "test" into an empty document and press enter.
  // sometimes this loop finds a blank text node, sometimes it doesn't.
  
  while ( roam = roam ? ( next(roam,search_direction) ? next(roam,search_direction) : roam.parentNode ) : start )
  {
    
    // next() is an inline function defined above that returns the next node depending
    // on the direction we're searching.
    
    if ( next(roam,search_direction) )
    {
      
      // If the next sibling's on the exclusion list, stop before it
      
      if ( this._pExclusions.test(next(roam,search_direction).nodeName) )
      {
        
        return this.processRng(rng, search_direction, roam, next(roam,search_direction), (search_direction == "left"?'AfterEnd':'BeforeBegin'), true, false);
      }
    }
    else
    {
      
      // If our parent's on the container list, stop inside it
      
      if (this._pContainers.test(roam.parentNode.nodeName))
      {
        
        return this.processRng(rng, search_direction, roam, roam.parentNode, (search_direction == "left"?'AfterBegin':'BeforeEnd'), true, false);
      }
      else if (this._pExclusions.test(roam.parentNode.nodeName))
      {
        
        // chop without wrapping
        
        if (this._pBreak.test(roam.parentNode.nodeName))
        {
          
          return this.processRng(rng, search_direction, roam, roam.parentNode,
            (search_direction == "left"?'AfterBegin':'BeforeEnd'), false, (search_direction == "left" ?true:false));
        }
        else
        {
          
          // the next(roam,search_direction) in this call is redundant since we know it's false
          // because of the "if next(roam,search_direction)" above.
          //
          // the final false prevents this range from being wrapped in <p>'s most likely
          // because it's already wrapped.
          
          return this.processRng(rng,
            search_direction,
            (roam = roam.parentNode),
            (next(roam,search_direction) ? next(roam,search_direction) : roam.parentNode),
            (next(roam,search_direction) ? (search_direction == "left"?'AfterEnd':'BeforeBegin') : (search_direction == "left"?'AfterBegin':'BeforeEnd')),
            false,
            false);
        }
      }
    }
  }
  
};	// end of processSide()


Xinha.prototype.gotoNode = function (node) {
	var sel = this.getSelection();
	var rng = this.createRange(sel);
	rng.setStart(node.childNodes[0],0);
	rng.setEnd(node.childNodes[0],0);
}


// ------------------------------------------------------------------------------

/**
* processRng - process Range.
*
* Neighbour and insertion identify where the new node, roam, needs to enter
* the document; landmarks in our selection will be deleted before insertion
*
* @param rn Range original selected range
* @param search_direction string Direction to search in.
* @param roam node
* @param insertion string may be AfterBegin of BeforeEnd
* @return array
*/


Xinha.prototype.processRng = function(rng, search_direction, roam, neighbour, insertion, pWrap, preBr)
{
  var node = search_direction == "left" ? rng.startContainer : rng.endContainer;
  var offset = search_direction == "left" ? rng.startOffset : rng.endOffset;
  
  // Define the range to cut, and extend the selection range to the same boundary
  
//  var editor = editor;
  var newRng = this.createRange();
  
  newRng.selectNode(roam);
  // extend the range in the given direction.
  
  if ( search_direction == "left")
  {
    newRng.setEnd(node, offset);
    rng.setStart(newRng.startContainer, newRng.startOffset);
  }
  else if ( search_direction == "right" )
  {
    
    newRng.setStart(node, offset);
    rng.setEnd(newRng.endContainer, newRng.endOffset);
  }
  // Clone the range and remove duplicate ids it would otherwise produce
  
  var cnt = newRng.cloneContents();
  
  // in this case "init" is an object not a boolen.
  
  this.forEachNodeUnder( cnt, "cullids", "ltr", this.takenIds, false, false);
  
  // Special case, for inserting paragraphs before some blocks when caret is at
  // their zero offset.
  //
  // Used to "open up space" in front of a list, table. Usefull if the list is at
  // the top of the document. (otherwise you'd have no way of "moving it down").
  
  var pify, pifyOffset, fill;
  pify = search_direction == "left" ? (newRng.endContainer.nodeType == 3 ? true:false) : (newRng.startContainer.nodeType == 3 ? false:true);
  pifyOffset = pify ? newRng.startOffset : newRng.endOffset;
  pify = pify ? newRng.startContainer : newRng.endContainer;
  
  if ( this._pifyParent.test(pify.nodeName) && pify.parentNode.childNodes.item(0) == pify )
  {
    while ( !this._pifySibling.test(pify.nodeName) )
    {
      pify = pify.parentNode;
    }
  }
  
  // NODE TYPE 11 is DOCUMENT_FRAGMENT NODE
  // I do not profess to understand any of this, simply applying a patch that others say is good - ticket:446
  if ( cnt.nodeType == 11 && !cnt.firstChild)
  {	
    if (pify.nodeName != "BODY" || (pify.nodeName == "BODY" && pifyOffset != 0)) 
    { //WKR: prevent body tag in empty doc
      cnt.appendChild(this._doc.createElement(pify.nodeName));
    }
  }
  
  // YmL: Added additional last parameter for fill case to work around logic
  // error in forEachNode()
  
  fill = this.forEachNodeUnder(cnt, "find_fill", "ltr", false );
  
  if ( fill &&
    this._pifySibling.test(pify.nodeName) &&
  ( (pifyOffset == 0) || ( pifyOffset == 1 && this._pifyForced.test(pify.nodeName) ) ) )
  {
    
    roam = this._doc.createElement( 'p' );
    roam.innerHTML = "&nbsp;";
    
    // roam = this._doc.createElement('p');
    // roam.appendChild(this._doc.createElement('br'));
    
    // for these cases, if we are processing the left hand side we want it to halt
    // processing instead of doing the right hand side. (Avoids adding another <p>&nbsp</p>
      // after the list etc.
      
      if ((search_direction == "left" ) && pify.previousSibling)
      {
        
        return new Array(pify.previousSibling, 'AfterEnd', roam);
      }
      else if (( search_direction == "right") && pify.nextSibling)
      {
        
        return new Array(pify.nextSibling, 'BeforeBegin', roam);
      }
      else
      {
        
        return new Array(pify.parentNode, (search_direction == "left"?'AfterBegin':'BeforeEnd'), roam);
      }
      
  }
  
  // If our cloned contents are 'content'-less, shove a break in them
  
  if ( fill )
  {
    
    // Ill-concieved?
    //
    // 3 is a TEXT node and it should be empty.
    //
    
    if ( fill.nodeType == 3 )
    {
      // fill = fill.parentNode;
      
      fill = this._doc.createDocumentFragment();
    }
    
    if ( (fill.nodeType == 1 && !this._elemSolid.test()) || fill.nodeType == 11 )
    {
      
      // FIXME:/CHECKME: When Xinha is switched from WYSIWYG to text mode
      // Xinha.getHTMLWrapper() will strip out the trailing br. Not sure why.
      
      // fill.appendChild(this._doc.createElement('br'));
      
      var pterminator = this._doc.createElement( 'p' );
      pterminator.innerHTML = "&nbsp;";
      
      fill.appendChild( pterminator );
      
    }
    else
    {
      
      // fill.parentNode.insertBefore(this._doc.createElement('br'),fill);
      
      var pterminator = this._doc.createElement( 'p' );
      pterminator.innerHTML = "&nbsp;";
      
      fill.parentNode.insertBefore(parentNode,fill);
      
    }
  }
  
  // YmL: If there was no content replace with fill
  // (previous code did not use fill and we ended up with the
    // <p>test</p><p></p> because Gecko was finding two empty text nodes
    // when traversing on the right hand side of an empty document.
    
    if ( fill )
    {
      
      roam = fill;
    }
    else
    {
      // And stuff a shiny new object with whatever contents we have
      
      roam = (pWrap || (cnt.nodeType == 11 && !cnt.firstChild)) ? this._doc.createElement('p') : this._doc.createDocumentFragment();
      roam.appendChild(cnt);
    }
    
    if (preBr)
    {
		//AK Change
	    roam.appendChild(this._doc.createElement('br'));
		//AK Change --end
    }
    // Return the nearest relative, relative insertion point and fragment to insert
    
    return new Array(neighbour, insertion, roam);
    
};	// end of processRng()

// ----------------------------------------------------------------------------------

/**
* are we an <li> that should be handled by the browser?
*
* there is no good way to "get out of" ordered or unordered lists from Javascript.
* We have to pass the onKeyPress 13 event to the browser so it can take care of
* getting us "out of" the list.
*
* The Gecko engine does a good job of handling all the normal <li> cases except the "press
* enter at the first position" where we want a <p>&nbsp</p> inserted before the list. The
* built-in behavior is to open up a <li> before the current entry (not good).
*
* @param rng Range range.
*/


Xinha.prototype.isNormalListItem = function() {

  var blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
  node = this._getFirstAncestor(this.getSelection(),blocks);

//    node = rng.startContainer;
//	alert(node.nodeName);

    if (( typeof node.nodeName != 'undefined') && ( node.nodeName.toLowerCase() == 'li' )) {
	return true;
    } else if (( typeof node.parentNode != 'undefined' ) && ( typeof node.parentNode.nodeName != 'undefined' ) && ( node.parentNode.nodeName.toLowerCase() == 'li' )) {
	// our parent is a list item.
	return true;
    } else {
	// neither we nor our parent are a list item. this is not a normal
	// li case.
    	return false;
    }
}



// -----------------------------------------------------------------------------------

/**
* Handles the pressing of an unshifted enter for Gecko
*/

Xinha.prototype.isElementNode = function(_xo_node) {
    if (_xo_node) {
	if (_xo_node.nodeType == Node.ELEMENT_NODE) {
		return true;
	}
    }
    return false;
}

Xinha.prototype.isEmptyText = function(_xo_text) {
    _xo_regexp = /(&nbsp;)|(&ensp;)|(&emsp;)|(\<[^\>]*\/?\>)|([ \t\n\r\s\xAD\xA0])/g;
    return _xo_text.replace(_xo_regexp,'').length==0;
}

Xinha.prototype.isEmptyNode = function(_xo_node) {
    if (_xo_node && _xo_node.nodeType == Node.ELEMENT_NODE ) {
	if (this.isEmptyText(this.textContent(_xo_node))) {
	    return true;
	} else {
	    return false;
	}
    } else {
	return true;
    }
}

Xinha.prototype.textToStart = function(_xo_rng) {

    sel = this.getSelection();
    blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
    _xo_node = this._getFirstAncestor(sel,blocks);

    if (this.isElementNode(_xo_node)) {
	rng_clone = _xo_rng.cloneRange();
	rng_clone.collapse(true);
        rng_clone.setStartBefore(_xo_node);
        _xo_text_to_start = rng_clone.toString();
	try { 
	    sel.removeRange(rng_clone);
	} catch (e) {
	    rng_clone.detach();
	}
	return _xo_text_to_start;
    } else {
	return '';
    }
}

Xinha.prototype.textToEnd = function(_xo_rng) {

    sel = this.getSelection();
    blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li"];
    _xo_node = this._getFirstAncestor(sel,blocks);

    if (this.isElementNode(_xo_node)) {
	rng_clone = _xo_rng.cloneRange();
	rng_clone.collapse(false);
        rng_clone.setEndAfter(_xo_node);
        _xo_text_to_end = rng_clone.toString();
	try { 
	    sel.removeRange(rng_clone);
	} catch (e) {
	    rng_clone.detach();
	}
	return _xo_text_to_end;
    } else {
	return '';
    }
}


Xinha.prototype.handleEnter = function(ev)
{
  
  var cursorNode;
  
  // Grab the selection and associated range

  sel = this.getSelection();
  rng = this.createRange(sel);
  _xo_stop_p = false;  
  _xo_deleted_p = false;
  _xo_blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
  _xo_fan = this._getFirstAncestor(this.getSelection(),_xo_blocks);
  _xo_fan_tag_name = _xo_fan.tagName.toLowerCase();
  if (!rng.collapsed) {
	_xo_p = false;
	if ( rng.endContainer != rng.startContainer) {
		_xo_p = rng.endContainer;
		while (_xo_p.nodeType == 3) {
			_xo_p=_xo_p.parentNode;
		}
	}
	rng.deleteContents();
	if (_xo_p) {
		rng.selectNodeContents(_xo_p);
		rng.collapse(true);
	} 

	_xo_fan = this._getFirstAncestor(this.getSelection(),_xo_blocks);

	_xo_stop_p = true;
	_xo_deleted_p = true;
  }


  _xo_fan_NS = _xo_fan.nextSibling;
  _xo_fan_PS = _xo_fan.previousSibling;
  _xo_fan_PN = _xo_fan.parentNode;
  _xo_list_item_p = this.isNormalListItem();

  if (!this.isElementNode(_xo_fan_PS) && this.isElementNode(_xo_fan_PN) )
	_xo_fan_PS = _xo_fan_PN.previousSibling;
  if (!this.isElementNode(_xo_fan_NS) && this.isElementNode(_xo_fan_PN) )
	_xo_fan_NS = _xo_fan_PN.nextSibling;
  if (this.isElementNode(_xo_fan_PS) && _xo_fan_PS.tagName.toLowerCase() == 'ul')
	_xo_fan_PS = _xo_fan_PS.lastChild;
  if (this.isElementNode(_xo_fan_NS) && _xo_fan_NS.tagName.toLowerCase() == 'ul')
	_xo_fan_NS = _xo_fan_NS.firstChild;

	empty_prev_p = this.isEmptyNode(_xo_fan_PS);
	empty_next_p = this.isEmptyNode(_xo_fan_NS);
	_xo_text_to_start = this.textToStart(rng);
	_xo_text_to_end = this.textToEnd(rng);



  empty_current_p = this.isEmptyText(_xo_text_to_start + _xo_text_to_end) && this.noSpecialContent(_xo_fan);

	if (empty_prev_p && this.isElementNode(_xo_fan_PS) && this.isEmptyText(_xo_text_to_start)) {
	    _xo_stop_p = true;
	}
  //alert(_xo_fan_PS.innerHTML + empty_prev_p + ' ' +  this.isElementNode(_xo_fan_PS) + ' ' + this.isEmptyText(_xo_text_to_start));

	while (empty_prev_p && this.isElementNode(_xo_fan_PS) && empty_current_p) {
		Xinha.removeFromParent(_xo_fan_PS);
	    _xo_stop_p = true;

	    _xo_fan_PS = _xo_fan.previousSibling;
	    if (!this.isElementNode(_xo_fan_PS) && this.isElementNode(_xo_fan_PN) )
		_xo_fan_PS = _xo_fan_PN.previousSibling;
	    if (this.isElementNode(_xo_fan_PS) && _xo_fan_PS.tagName.toLowerCase() == 'ul')
		_xo_fan_PS = _xo_fan_PS.lastChild;

	    empty_prev_p = this.isEmptyNode(_xo_fan_PS);
	}

	if (this.isEmptyText(_xo_text_to_end)) {
	    if (!_xo_list_item_p || this.isElementNode(_xo_fan.nextSibling)) {
		if ( empty_next_p && this.isElementNode(_xo_fan_NS)) {
		    if (empty_current_p) { Xinha.removeFromParent(_xo_fan); }
		    rng.setEnd(_xo_fan_NS,0);
		    rng.setStart(_xo_fan_NS,0);
		   _xo_stop_p = true;
	        }
	    } else if (_xo_list_item_p && empty_current_p && !this.isElementNode(_xo_fan.nextSibling)) {
		    rng.setEndAfter(_xo_fan_PN);
		    rng.setStartAfter(_xo_fan_PN);
		    this._doc.execCommand('formatblock',false,'p');
		    if ( empty_next_p && this.isElementNode(_xo_fan_NS)) { Xinha.removeFromParent(_xo_fan_NS); }
		    if (empty_current_p) { Xinha.removeFromParent(_xo_fan); }
		    _xo_stop_p = true;
	    } else {
		if ( empty_next_p && this.isElementNode(_xo_fan_NS)) { Xinha.removeFromParent(_xo_fan_NS); }
	    }
	} 

	if (empty_current_p) {
	    _xo_fan.innerHTML = '&nbsp;';
	    _xo_stop_p = true;
	}

	if (_xo_stop_p) Xinha._stopEvent(ev);
	if (_xo_stop_p || _xo_list_item_p) return true;






  // as far as I can tell this isn't actually used.
  
  this.takenIds = new Object();
  
  // Grab ranges for document re-stuffing, if appropriate
  //
  // pStart and pEnd are arrays consisting of
  // [0] neighbor node
  // [1] insertion type
  // [2] roam
  
  var pStart = this.processSide(rng, "left");
  
  var pEnd = this.processSide(rng, "right");
  
  // used to position the cursor after insertion.
  
  cursorNode = pEnd[2];
  
  // Get rid of everything local to the selection
  
  sel.removeAllRanges();
  rng.deleteContents();
  
  // Grab a node we'll have after insertion, since fragments will be lost
  //
  // we'll use this to position the cursor.
  
  var holdEnd = this.forEachNodeUnder( cursorNode, "find_cursorpoint", "ltr", false, true);
  
  if ( ! holdEnd )
  {
    alert( "INTERNAL ERROR - could not find place to put cursor after ENTER" );
  }
  
  // Insert our carefully chosen document fragments
  
  if ( pStart )
  {
    
    this.insertAdjacentElement(pStart[0], pStart[1], pStart[2]);
  }
  
  if ( pEnd && pEnd.nodeType != 1)
  {
    
    this.insertAdjacentElement(pEnd[0], pEnd[1], pEnd[2]);
  }
  
  // Move the caret in front of the first good text element
  
  if ((holdEnd) && (this._permEmpty.test(holdEnd.nodeName) ))
  {
    
    var prodigal = 0;
    while ( holdEnd.parentNode.childNodes.item(prodigal) != holdEnd )
    {
      prodigal++;
    }
    
    sel.collapse( holdEnd.parentNode, prodigal);
  }
  else
  {
    
    // holdEnd might be false.
    
    try
    {
      sel.collapse(holdEnd, 0);
      
      // interestingly, scrollToElement() scroll so the top if holdEnd is a text node.
      
      if ( holdEnd.nodeType == 3 )
      {
        holdEnd = holdEnd.parentNode;
      }
      
      this.scrollToElement(holdEnd);
    }
    catch (e)
    {
      // we could try to place the cursor at the end of the document.
    }
  }
  
  this.updateToolbar();
  
  Xinha._stopEvent(ev);
  
  return true;
  
};	// end of handleEnter()





Xinha.prototype.fullwordSelection = function (spaces)  {
	
	_xo_sel = this.getSelection();
	_xo_range = this.createRange(_xo_sel);

	//_xo_blocks = ["b","i",'strong','em','u',"span","a"];
	_xo_fan = this._getFirstAncestor(_xo_sel, ['a']);
	if ( _xo_fan ) {
		_xo_range.selectNode(_xo_fan);
		return;
	}

	if (_xo_sel.toString().length > 0) {

		
		//avoid the problem with the wrong start container
		if (_xo_range.toString() == _xo_range.endContainer.nodeValue)
			_xo_range.setStart(_xo_range.endContainer,0);
	
		// ----- expand to the left -----
		while (!isStopChar(_xo_range.toString().charAt(0))) 
		{
			try { _xo_range.setStart(_xo_range.startContainer,_xo_range.startOffset-1); }
			catch (exx) { break; }
		} 
		if (isStopChar(_xo_range.toString().charAt(0)))
		{	
			try { _xo_range.setStart(_xo_range.startContainer,_xo_range.startOffset+1); }
			catch (exx) { };
		}
		
		if (spaces == true) //expand left to cover all spaces
		{
			do {
				try { _xo_range.setStart(_xo_range.startContainer,_xo_range.startOffset-1); }
				catch (exx) { break; }
			} while (isStopChar(_xo_range.toString().charAt(0)));
			
			if (_xo_range.startOffset != 0 && !isStopChar(_xo_range.toString().charAt(0)))
				_xo_range.setStart(_xo_range.startContainer,_xo_range.startOffset+1);
		}

		// ----- expand to the right -----
		_xo_s = _xo_range.toString();
		while (!isStopChar(_xo_s[_xo_s.length-1])) {
			try { _xo_range.setEnd(_xo_range.endContainer,_xo_range.endOffset+1); }
			catch (exx) { break; }
			_xo_s = _xo_range.toString();
		}
		if (isStopChar(_xo_s[_xo_s.length-1]))
			_xo_range.setEnd(_xo_range.endContainer,_xo_range.endOffset-1);
		
		if (spaces == true) //expand right to cover all spaces
		{
			do {
				try { _xo_range.setEnd(_xo_range.endContainer,_xo_range.endOffset+1); }
				catch (exx) { break; }
				_xo_s = _xo_range.toString();
			} while (isStopChar(_xo_s[_xo_s.length-1]));
				
		if (_xo_range.endOffset != _xo_range.endContainer.length && !isStopChar(_xo_s[_xo_s.length-1]))
			_xo_range.setEnd(_xo_range.endContainer,_xo_range.endOffset-1);
		}
	}
};



}



// StructuredText

/*
 *	isSpace(ch)
 *	Returns true if ch is a space character (space, enter, tab)
 */
function isSpace(ch) {
	var stopchars = " \t\n\r";
	if (stopchars.indexOf(ch) != -1)
		return true;
	if (ch.charCodeAt(0) == 160)
		return true;
	return false;
}

/*
 *	isStopChar(ch)
 *	Returns true if ch is a stop character (space, enter, tab, comma, dot etc)
 */
function isStopChar(ch) {
	var stopchars = " \t\n\r.,;?";
	if (stopchars.indexOf(ch) != -1)
		return true;
	if (ch.charCodeAt(0) == 160)
		return true;
	return false;
	
	/*if (ch == " " || ch == "\t" || ch == "\n" || ch == "\r" || ch.charCodeAt(0) == 160)
		return true;
	return false;*/
}


function getTagName(node) {
	if (node.tagName.toLowerCase() == 'font')
		if (node.className)
			return node.className.toLowerCase();
	return	node.tagName.toLowerCase();
}



function getStxTag(htmlTag) {

	var stxTags_b = new Array();	//stx begin symbols
	var stxTags_e = new Array();	//std end symbols

	stxTags_b['bold'] = "**";
	stxTags_e['bold'] = "**";
	stxTags_b['italic'] = "*";
	stxTags_e['italic'] = "*";
	stxTags_b['highlight'] = "''";
	stxTags_e['highlight'] = "''";

	stxTags_b['b'] = "**";
	stxTags_e['b'] = "**";
	stxTags_b['strong'] = "**";
	stxTags_e['strong'] = "**";
	stxTags_b['i'] = "*";
	stxTags_e['i'] = "*";
	stxTags_b['p'] = "\n\n";
	stxTags_e['p'] = "";
	stxTags_b['pre'] = "\n\n::\n\n";
	stxTags_e['pre'] = "";

	stxTags_b['h1'] = "\n\n==";
	stxTags_e['h1'] = "==";
	stxTags_b['h2'] = "\n\n===";
	stxTags_e['h2'] = "===";
	stxTags_b['h3'] = "\n\n====";
	stxTags_e['h3'] = "====";

	stxTags_b['a'] = '"';
	stxTags_e['a'] = '":';
	stxTags_b['img'] = '\n\n{';
	stxTags_e['img'] = '}\n\n';

	stxTags_b['li'] = "\n\n-";
	stxTags_e['li'] = "";



	//create object symbol (.begin,.end)
	function symbol () {}
	symbol.begin = "";
	symbol.end = "";



	//search for the right tag
	//	for (var tag in stxTags_b)
	if (typeof stxTags_b[tag] !== undefined) {
	    symbol.begin = stxTags_b[tag];
	    symbol.end = stxTags_e[tag];
	}
	return symbol;

}

function trimString(str) {
	var i,j;
	for (i = 0; i < str.length; i++)
		if (!isSpace(str.charAt(i)))
			break;
	for (j = str.length-1; j >= 0; j--)
		if (!isSpace(str.charAt(j)))
			break;
	return str.substring(i,j+1);
}


function rightTrimSpace(sString) {
    while (sString.substring(sString.length-1, sString.length) == ' ') {
        sString = sString.substring(0,sString.length-1);
    }
    return sString;
}



function parseNode(node, mode, list, indent) {
    var prefix = '';
    var suffix = '';
	var _xo_style, tag, symbol;
    if (!node) return "";
    

    if (!Xinha.is_ie) {
	if (node.nodeType == Node.TEXT_NODE)
	    return node.textContent.trim();
    } else {
	if (node.nodeType == 3) {
	    return node.toString().trim();
	}
    }

    _xo_style = getTagName(node).split(' ');
    for (var i=0; i<_xo_style.length; i++) {
	tag = _xo_style[i];
	symbol = getStxTag(tag);

	if (tag == "ul") list = "ul";
	if (tag == "p" || tag == "pre" || tag =="code")
	    mode = tag;
	
	if (tag == "br") {
	    if (mode == "pre" || mode == "code") 
		symbol.begin = "\n";
	    else if (mode == "p") 
		symbol.begin = "";
	}
	
	prefix += symbol.begin;
	suffix = symbol.end + suffix;

    }
    
    if (tag == "p") { prefix += indent; }
    
    if (tag == "pre" || tag == "code" || tag == "li") { 
	indent += " "; 
	prefix += indent; 
    } else if (tag == "br") {
	//prefix += indent;
    }

    if (tag == "a") {
	suffix += node.getAttribute("href").trim();
    } else if (tag == "img") {
	prefix += node.getAttribute("filetype").trim() + ':';
	prefix += node.getAttribute("identifier").trim();
	if (node.className) {
	    prefix += ' ' + node.className;
	}
	if (node.getAttribute("title")) {
	    prefix += ' | ' + node.getAttribute("title").trim();
	}
    }

    var txt = '';
    for (var j = 0; j < node.childNodes.length; j++) {
	txt += parseNode(node.childNodes[j],mode,list,indent);
    }
    txt = rightTrimSpace(txt);
    if (txt.length) {
        txt = prefix + txt + suffix;
    }

    if (txt.length) {
	return ' ' + txt + ' ';
    } else {
	return '';
    }

}


/*
	getStxFromHtml
	Get a string that contains html text and converts it into structured text
*/
Xinha.prototype.getStxFromHtml = function(html) {
//alert(html);
//alert(Ext.fly(this._doc.body).query('strong').length);
	var obj = document.createElement('div');
	//html = html.replace("\n","","gi");
	obj.innerHTML = html;
	result = parseNode(obj,"","","");
//alert(result);
	return result.trim();
};



String.prototype.trim = function() {
    return this.replace(/^[\s\xA0]+|[\s\xA0]+$/g,"");
}
String.prototype.ltrim = function() {
    return this.replace(/^[\s\xA0]+/,"");
}
String.prototype.rtrim = function() {
    return this.replace(/[\s\xA0]+$/,"");
}

Xinha.prototype.indent_level = function(para) {
    var lines = para.split(/\r?\n/);
    var minlevel = 0;
    var level = -1;
    for (var i=0; i<lines.length;i++) {
	for (var j=0; j<lines[i].length; j++) {
	    if ( lines[i].charAt(j) != ' ' ) {
		level = j;
		break
	    }
	}
	if ( minlevel < level ) {
	    minlevel = level
	    }
    }
    return minlevel;
}

Xinha.prototype.Special_Text_Handler = function(special_text_handler,special_text){
    return "<pre>"+this.getHtmlFromStxPara(special_text)+"</pre>";
}


Xinha.prototype.getHtmlFromStx = function(stx) {
    var para = stx.split(/\r?\n(\r?\n )*\r?\n/);


    var result,prev_indent_level, prev_real_indent_level, preformatted_p,stack_indent_levels, stack_close_tags,prev_preformatted_p, special_text, special_text_handler,i, this_indent_level, this_fake_indent_level, preformatted_p, tag, otag, ctag,pre_part,j,indent_level;
    result = '';
    prev_indent_level = 0;
    prev_real_indent_level = 0;
    preformatted_p = 0;
    stack_indent_levels = new Array;
    //stack_indent_levels.push(-1);
    stack_close_tags = new Array();
    //stack_close_tags.push('<empty>');
    prev_preformatted_p = 0;
    special_text = '';

    for (var i=0;i<para.length;i++) {
        //para[i] = para[i].replace(/\xAD/,'').rtrim();
	if (para[i].match(/^[ \t\n\r\xAD]*([*o\-\#])?[ \t\n\r\xAD]*$/)) {
	    continue
	}
	this_indent_level = this.indent_level(para[i]);
	this_fake_indent_level = this_indent_level;


	if ( preformatted_p && prev_indent_level < this_indent_level ) {

	    special_text += para[i] + "\n\n";

            prev_preformatted_p = 1;
            continue;

        } else {
	    tag = '';
	    bullet_part = null;
	    bullet_part = para[i].match(/^[ \t\n\xAD]*([*o\-\#])[ \t\n\xAD]+([^\0]*)?$/);
	    if ( bullet_part ) {
		if (!bullet_part[2]) {
			continue
		}
		switch(bullet_part[1]) {
		    case '-':
		    case '*':
		    case 'o': tag='ul';	otag='<ul>'; ctag='</ul>'; break;
		    case '#': tag='ol';	otag='<ol>'; ctag='</ol>'; break;
		}
		para[i]=bullet_part[2];
	    } else {
		tag = '';
		//otag = "<p>";
                //ctag = '</p>';
		otag='';
		ctag='';
	    }
	}

        if ( prev_preformatted_p ) {
            result += this.Special_Text_Handler(special_text_handler,special_text);
            special_text = '';
            prev_preformatted_p = 0;
	}
	
	pre_part = para[i].match(/^(.*)(::|%%|##)[ \t\n\r]*$/);
	if (pre_part) {
	    special_text_handler=pre_part;
	    preformatted_p=1;
	    continue
	}



	    // If the indent level has gone negative. We need to close the tags
		
	    include_otag_p = false;


//console.log('para' + i + ':' + para[i] + ' sct:' + stack_close_tags + ' sil:' + stack_indent_levels + ' level: ' + this_indent_level);
            for (j=stack_indent_levels.length-1; j>=0; j--) {
		indent_level = stack_indent_levels[j];
		if ( this_indent_level < indent_level || (this_indent_level == indent_level && ctag != stack_close_tags[j])) {
		    //include_otag_p = true;
		    result += stack_close_tags.pop();
		    stack_indent_levels.pop();
		} else {
		    break;
		}
	    }

	    if ( this_indent_level > stack_indent_levels[j] || (ctag != stack_close_tags[j])) {
		result += otag;
		stack_indent_levels.push(this_indent_level);
		stack_close_tags.push(ctag);
	    }

	    switch (tag) {
		case 'ul':
		case 'ol':
		case 'dl':
	            result += '<li>' + this.getHtmlFromStxPara(para[i]) + '</li>';
	            break;
 	        default:
	            result += '<p>' + this.getHtmlFromStxPara(para[i]) + '</p>';
	    }


        switch (tag) {
	    case 'ul':
	    case 'ol':
            case 'dl':
	        prev_real_indent_level = 1+this_indent_level+ this.indent_level(para[i]);
	        break;
	    default: 
	        prev_real_indent_level = this_fake_indent_level;
	}

	prev_indent_level = this_indent_level;

//					alert('para ' + i + ':' + para[i]);
//					alert('result:' + result);

    }
   

    if ( prev_preformatted_p ) {
	result += this.Special_Text_Handler(special_text_handler,special_text);
	    prev_preformatted_p = 0;
    }

    for (j=0;j<stack_close_tags.length;j++) {
	ctag = stack_close_tags.pop();
	if ( ctag != '<empty>' ) {
	    result += ctag;
	}
    }

		      //append result [join ${stack_close_tags}]


//    result = result.replace(/\u0005/,'<p style="margin-left: 2em;">');
//	alert(this_indent_level);
//	result += '<p>' + this.getHtmlFromStxPara(para[i]) + '</p>';

	if (result.trim().length == 0) { result += '<p>&nbsp;</p>'; }

    return result;
};

Xinha.prototype.getHtmlFromStxPara = function(para) {
    if (para.match(/^[ \t\n\r]*$/)) {
	return ""
    }

    para = this.getHtmlForStxSymbol(para,"**","[*][*]","\x06bold\x15$1\x16");
    para = this.getHtmlForStxSymbol(para,"\'\'","[\'][\']","\x06highlight\x15$1\x16");
    para = this.getHtmlForStxSymbol(para,"*","[*]","\x06italic\x15$1\x16");


// HERE 
para = para.replace(/\x15([^\x06\x15]+)\x16/g,"\x02\">\x16$1\x16</font>\x16");
para = para.replace(/(^|[^\x15])\x06([^\x02]+)\x02/g,"$1\x06<font class=\"$2");
para = para.replace(/\x15\x06/g,' ');

//para.replace(/(^|[^\x15])\x06([^\x15\x06]\x15\x06)+([^\x15\x16])+/g,'$1<font class="$2">$3</font>');

    para = para.replace(/http:\/\/([^\(\)\[\]\{\}\"<>\s\x06\x16\xAD]*[^\(\)\[\]\{\}\"<>\s\.,\*\':;?!\x06\x16\xAD]|[^\(\)\[\]\{\}\"<>\s\x06\x16\xAD]*\([^\(\)\[\]\{\}\"<>\s\x06\x16\xAD]*\)[^\(\)\[\]\{\}\"<>\s\.,\*\':;?!\x06\x16\xAD]*)/g,"\x05$1\x15");
    para = para.replace(/\"([^\x05\x15\x06\x16]+)\":\x05([^\x05\x15\x06\x16\xAD]+)\x15/g,"\x06<a href=\"http://$2\">$1</a>\x16");
    para = para.replace(/\x05([^\x05\x15\x06\x16\xAD]+)\x15/g,"http://$1");
    para = para.replace(/[\x05\x15\x06\x16]/g,"");

    // document|video|audio|spreadsheet|powerpoint
    para = para.replace(/{(image):([0-9]+)\s*( left| center| right)?\s*}/g,'<img class="$3" src="http://my.phigita.net/media/view/$2?size=240" filetype="$1" identifier="$2" />');
    para = para.replace(/{(image):([0-9]+)\s*( left| center| right)?\s*\|\s*([^\{\}\r\n]*)}/g,'<img class="$3" src="http://my.phigita.net/media/view/$2?size=240" filetype="$1" identifier="$2" title="$4" />');

    para = para.replace(/<img class="\s*(center)"([^\>]+)\/>/g,'<img class="center" style="display:block;padding:15px;margin-left:auto;margin-right:auto;" $2 />');
    para = para.replace(/<img class="\s*(|left)"([^\>]+)\/>/g,'<img class="left" style="display:block;padding:15px;margin-right:auto;" $2 />');
    para = para.replace(/<img class="\s*(right)"([^\>]+)\/>/g,'<img class="right" style="display:block;padding:15px;margin-left:auto;" $2 />');

    return para;
}

Xinha.prototype.getHtmlForStxSymbol = function(para,defaultString,regexstring,newString) {
    var objRegExp = new RegExp(regexstring, "g");
    result = para.replace(objRegExp,"\x05");
    result = result.replace(/\x05([^\x05]+)\x05/g,newString);
    result = result.replace(/\x05/g,defaultString);
    return result;
};










// FullScreen -------------------------------------------------------------------------------------------------------------------------------------------------



/** fullScreen makes an editor take up the full window space (and resizes when the browser is resized)
 *  the principle is the same as the "popupwindow" functionality in the original htmlArea, except
 *  this one doesn't popup a window (it just uses to positioning hackery) so it's much more reliable
 *  and much faster to switch between
 */

Xinha.prototype._fullScreen = function()
{

  var e = this;
  function sizeItUp()
  {
    if(!e._isFullScreen || e._sizing) return false;
    e._sizing = true;
    // Width & Height of window
    var dim = Xinha.viewportSize();

    e.sizeEditor(dim.x + 'px',dim.y + 'px',true,true);
    e._sizing = false;
  }

  function sizeItDown()
  {
    if(e._isFullScreen || e._sizing) return false;
    e._sizing = true;
    e.initSize();
    e._sizing = false;
  }

  /** It's not possible to reliably get scroll events, particularly when we are hiding the scrollbars
   *   so we just reset the scroll ever so often while in fullscreen mode
   */
  function resetScroll()
  {
    if(e._isFullScreen)
    {
      window.scroll(0,0);
      window.setTimeout(resetScroll,150);
    }
  }

  if(typeof this._isFullScreen == 'undefined')
  {
    this._isFullScreen = false;
    if(e.target != e._iframe)
    {
      Xinha._addEvent(window, 'resize', sizeItUp);
    }
  }



	_xo_target = this._editMode == 'textmode' ? 'textarea' : 'iframe';
	e.setCC(_xo_target);


  // Gecko has a bug where if you change position/display on a
  // designMode iframe that designMode dies.
  if(Xinha.is_gecko)
  {
    this.deactivateEditor();
  }

  if(this._isFullScreen)
  {
    // Unmaximize
    this._xo_htmlarea().style.position = '';
    try
    {
      if(Xinha.is_ie)
      {
        var bod = document.getElementsByTagName('html');
      }
      else
      {
        var bod = document.getElementsByTagName('body');
      }
      bod[0].style.overflow='';
    }
    catch(e)
    {
      // Nutthin
    }
    this._isFullScreen = false;
    sizeItDown();

    // Restore all ancestor positions
    var ancestor = this._xo_htmlarea();
    while((ancestor = ancestor.parentNode) && ancestor.style)
    {
      ancestor.style.position = ancestor._xinha_fullScreenOldPosition;
      ancestor._xinha_fullScreenOldPosition = null;
    }

    window.scroll(this._unScroll.x, this._unScroll.y);
  }
  else
  {

    // Get the current Scroll Positions
    this._unScroll =
    {
     x:(window.pageXOffset)?(window.pageXOffset):(document.documentElement)?document.documentElement.scrollLeft:document.body.scrollLeft,
     y:(window.pageYOffset)?(window.pageYOffset):(document.documentElement)?document.documentElement.scrollTop:document.body.scrollTop
    };


    // Make all ancestors position = static
    var ancestor = this._xo_htmlarea();
    while((ancestor = ancestor.parentNode) && ancestor.style)
    {
      ancestor._xinha_fullScreenOldPosition = ancestor.style.position;
      ancestor.style.position = 'static';
    }

    // Maximize
    window.scroll(0,0);
    this._xo_htmlarea().style.position = 'absolute';
    this._xo_htmlarea().style.zIndex   = 999;
    this._xo_htmlarea().style.left     = 0;
    this._xo_htmlarea().style.top      = 0;
    this._isFullScreen = true;
    resetScroll();

    try
    {
      if(Xinha.is_ie)
      {
        var bod = document.getElementsByTagName('html');
      }
      else
      {
        var bod = document.getElementsByTagName('body');
      }
      bod[0].style.overflow='hidden';
    }
    catch(e)
    {
      // Nutthin
    }

    sizeItUp();
  }

  if(Xinha.is_gecko)
  {
    this.activateEditor();
  }
  this.focusEditor();
  e.findCC(_xo_target);
};
// Retrieves the HTML code from the given node.	 This is a replacement for
// getting innerHTML, using standard DOM calls.
// Wrapper catch a Mozilla-Exception with non well formed html source code
Xinha.getHTML = function(root, outputRoot, editor)
{
  try
  {
    return Xinha.getHTMLWrapper(root,outputRoot,editor);
  }
  catch(ex)
  {   
    alert(Xinha._lc('Your Document is not well formed. Check JavaScript console for details.'));
    return editor._iframe.contentWindow.document.body.innerHTML;
  }
};

Xinha.getHTMLWrapper = function(root, outputRoot, editor, indent)
{

  var html = "";
  if ( !indent )
  {
    indent = '';
  }

  switch ( root.nodeType )
  {
    case 10:// Node.DOCUMENT_TYPE_NODE
    case 6: // Node.ENTITY_NODE
    case 12:// Node.NOTATION_NODE
      // this all are for the document type, probably not necessary
    break;

    case 2: // Node.ATTRIBUTE_NODE
      // Never get here, this has to be handled in the ELEMENT case because
      // of IE crapness requring that some attributes are grabbed directly from
      // the attribute (nodeValue doesn't return correct values), see
      //http://groups.google.com/groups?hl=en&lr=&ie=UTF-8&oe=UTF-8&safe=off&selm=3porgu4mc4ofcoa1uqkf7u8kvv064kjjb4%404ax.com
      // for information
    break;

    case 4: // Node.CDATA_SECTION_NODE
      // Mozilla seems to convert CDATA into a comment when going into wysiwyg mode,
      //  don't know about IE
      html += (Xinha.is_ie ? ('\n' + indent) : '') + '<![CDATA[' + root.data + ']]>' ;
    break;

    case 5: // Node.ENTITY_REFERENCE_NODE
      html += '&' + root.nodeValue + ';';
    break;

    case 7: // Node.PROCESSING_INSTRUCTION_NODE
      // PI's don't seem to survive going into the wysiwyg mode, (at least in moz)
      // so this is purely academic
	//       html += (Xinha.is_ie ? ('\n' + indent) : '') + '<?' + root.target + ' ' + root.data + ' ?>';
    break;

    case 1: // Node.ELEMENT_NODE
    case 11: // Node.DOCUMENT_FRAGMENT_NODE
    case 9: // Node.DOCUMENT_NODE
      var closed;
      var i;
      var root_tag = (root.nodeType == 1) ? root.tagName.toLowerCase() : '';
      if ( ( root_tag == "script" || root_tag == "noscript" ) && editor.config.stripScripts )
      {
        break;
      }
      if ( outputRoot )
      {
        outputRoot = !(editor.config.htmlRemoveTags && editor.config.htmlRemoveTags.test(root_tag));
      }
      if ( Xinha.is_ie && root_tag == "head" )
      {
        if ( outputRoot )
        {
          html += (Xinha.is_ie ? ('\n' + indent) : '') + "<head>";
        }
        // lowercasize
        var save_multiline = RegExp.multiline;
        RegExp.multiline = true;
        var txt = root.innerHTML.replace(Xinha.RE_tagName, function(str, p1, p2) { return p1 + p2.toLowerCase(); });
        RegExp.multiline = save_multiline;
        html += txt + '\n';
        if ( outputRoot )
        {
          html += (Xinha.is_ie ? ('\n' + indent) : '') + "</head>";
        }
        break;
      }
      else if ( outputRoot )
      {
        closed = (!(root.hasChildNodes() || Xinha.needsClosingTag(root)));
        html += (Xinha.is_ie && Xinha.isBlockElement(root) ? ('\n' + indent) : '') + "<" + root.tagName.toLowerCase();
        var attrs = root.attributes;
        
        for ( i = 0; i < attrs.length; ++i )
        {
          var a = attrs.item(i);
          if (typeof a.nodeValue != 'string') continue;
          if ( !a.specified 
            // IE claims these are !a.specified even though they are.  Perhaps others too?
            && !(root.tagName.toLowerCase().match(/input|option/) && a.nodeName == 'value')                
            && !(root.tagName.toLowerCase().match(/area/) && a.nodeName.match(/shape|coords/i)) 
          )
          {
            continue;
          }
          var name = a.nodeName.toLowerCase();
          if ( /_moz_editor_bogus_node/.test(name) )
          {
            html = "";
            break;
          }
          if ( /(_moz)|(contenteditable)|(_msh)/.test(name) )
          {
            // avoid certain attributes
            continue;
          }
          var value;
          if ( name != "style" )
          {
            // IE5.5 reports 25 when cellSpacing is
            // 1; other values might be doomed too.
            // For this reason we extract the
            // values directly from the root node.
            // I'm starting to HATE JavaScript
            // development.  Browser differences
            // suck.
            //
            // Using Gecko the values of href and src are converted to absolute links
            // unless we get them using nodeValue()
            if ( typeof root[a.nodeName] != "undefined" && name != "href" && name != "src" && !(/^on/.test(name)) )
            {
              value = root[a.nodeName];
            }
            else
            {
              value = a.nodeValue;
              // IE seems not willing to return the original values - it converts to absolute
              // links using a.nodeValue, a.value, a.stringValue, root.getAttribute("href")
              // So we have to strip the baseurl manually :-/
              if ( Xinha.is_ie && (name == "href" || name == "src") )
              {
                value = editor.stripBaseURL(value);
              }

              // High-ascii (8bit) characters in links seem to cause problems for some sites,
              // while this seems to be consistent with RFC 3986 Section 2.4
              // because these are not "reserved" characters, it does seem to
              // cause links to international resources not to work.  See ticket:167

              // IE always returns high-ascii characters un-encoded in links even if they
              // were supplied as % codes (it unescapes them when we pul the value from the link).

              // Hmmm, very strange if we use encodeURI here, or encodeURIComponent in place
              // of escape below, then the encoding is wrong.  I mean, completely.
              // Nothing like it should be at all.  Using escape seems to work though.
              // It's in both browsers too, so either I'm doing something wrong, or
              // something else is going on?

              if ( editor.config.only7BitPrintablesInURLs && ( name == "href" || name == "src" ) )
              {
                value = value.replace(/([^!-~]+)/g, function(match) { return escape(match); });
              }
            }
          }
          else
          {
            // IE fails to put style in attributes list
            // FIXME: cssText reported by IE is UPPERCASE
            value = root.style.cssText;
          }
          if ( /^(_moz)?$/.test(value) )
          {
            // Mozilla reports some special tags
            // here; we don't need them.
            continue;
          }
          html += " " + name + '="' + Xinha.htmlEncode(value) + '"';
        }
        if ( html !== "" )
        {
          if ( closed && root_tag=="p" )
          {
            //never use <p /> as empty paragraphs won't be visible
            html += ">&nbsp;</p>";
          }
          else if ( closed )
          {
            html += " />";
          }
          else
          {
            html += ">";
          }
        }
      }
      var containsBlock = false;
      if ( root_tag == "script" || root_tag == "noscript" )
      {
        if ( !editor.config.stripScripts )
        {
          if (Xinha.is_ie)
          {
            var innerText = "\n" + root.innerHTML.replace(/^[\n\r]*/,'').replace(/\s+$/,'') + '\n' + indent;
          }
          else
          {
            var innerText = (root.hasChildNodes()) ? root.firstChild.nodeValue : '';
          }
          html += innerText + '</'+root_tag+'>' + ((Xinha.is_ie) ? '\n' : '');
        }
      }
      else
      {
        for ( i = root.firstChild; i; i = i.nextSibling )
        {
          if ( !containsBlock && i.nodeType == 1 && Xinha.isBlockElement(i) )
          {
            containsBlock = true;
          }
          html += Xinha.getHTMLWrapper(i, true, editor, indent + '  ');
        }
        if ( outputRoot && !closed )
        {
          html += (Xinha.is_ie && Xinha.isBlockElement(root) && containsBlock ? ('\n' + indent) : '') + "</" + root.tagName.toLowerCase() + ">";
        }
      }
    break;

    case 3: // Node.TEXT_NODE
      html = /^script|noscript|style$/i.test(root.parentNode.tagName) ? "" : Xinha.htmlEncode(root.data);
    break;

    case 8: // Node.COMMENT_NODE
    break;
  }

  return html;
};

/** @see getHTMLWrapper (search for "value = a.nodeValue;") */


// CreateLink ----------------------------------------------------------------------------------------------------------



Xinha.prototype.linkDialog = function(){

    // define some private variables
    var dialog, showBtn, fp, editor;

    // return a public interface
    return {
       
        showDialog : function(dialog_editor,dialog_link,dialog_param){

	    editor = dialog_editor;
	    link = dialog_link;

	    if (!link) { editor.setCC(); }

            if(!dialog){ 

                dialog = new Ext.Window( { 
		    title:'Edit Link',
		    autoTabs:false,
		    modal:true,
		    width:350,
		    height:175,
		    shadow:true,
		    proxyDrag: true,
		    collapsible: false,
		    resizable: false,
		    draggable: false,
		    keys: [{
			key: 27,
			fn: this.hideDialog
		    }]
                });

		fp = new Ext.FormPanel({
		    labelWidth: 75,
		    monitorValid: true,
		    monitorPoll:100,
		    border:false,
		    bodyBorder:false,
		    buttons: [{
			text: 'Ok',
			formBind:true,
			disabled:true,
			handler:this.ok,
			scope:dialog
		    },{
			text: 'Cancel',
			handler:this.hideDialog
		    }]
		});
		fp.add(
		       new Ext.form.TextField({
			   fieldLabel: 'Text to display',
			   name: 'f_label',
			   width:225,
			   allowBlank:false,
//			   validationDelay:100,
			   listeners:{'specialKey':{fn: this.specialkeyFn,scope: this}}
		       })
		 );

                 fp.add(
			new Ext.form.TextField({
			    fieldLabel: 'To what URL should this link go?',
			    name: 'f_href',
			    vtype:'url',
			    width:225,
			    allowBlank:false,
//			    validationDelay:100,
			    listeners:{'specialKey':{fn: this.specialkeyFn,scope: this}}
			})
	        );


                dialog.add(fp);

		//dialog.on('hide', this.hideDialog);


//	dialog.getTabs().addTab('first-tab','test',_xo_tab_html);
//	dialog.getTabs().activate(0);




        }

	    fp.getForm().reset();
	    fp.getForm().setValues(dialog_param);
	    fp.getForm().clearInvalid();
	    dialog.show();
	    fp.getForm().findField('f_label').focus(true,10);

        },

      hideDialog:function(e){
	  if (typeof e != 'undefined' && e.browserEvent != null) Xinha._stopEvent(e.browserEvent);
	  dialog.hide();
	  editor.focusEditor();
	  if (!link) { editor.findCC(); }
      },

      specialkeyFn: function(field,e) {
	  if ( e.getKey() == e.RETURN || e.getKey() == e.ENTER ) {
	      if (fp.getForm().isValid()) {
		  this.ok();
		  Xinha._stopEvent(e.browserEvent);
	      }
	  }
      },

      ok: function() {

	    param = fp.getForm().getValues(false);
	    editor.linkDialog.hideDialog();

	    var a = link;
	    if ( !a ) {
		    editor.insertAtCursor('<a href="' + param.f_href.trim() + '">' + param.f_label.trim() + '</a>'+ (Xinha.is_gecko ? editor.cc : ''));
		    if (Xinha.is_gecko) editor.findCC();
	    } else {
		    a.href = param.f_href.trim();
		    if (!Xinha.is_ie)
			a.childNodes[0].textContent = param.f_label.trim();
		    else
			a.innerText = param.f_label.trim();
		    editor.moveAfterNode(a);
	    }
	    editor.updateToolbar();
	}
    };
}();

Xinha.prototype._createLink = function(link)
{
  var editor = this;
  var outparam = null;
  var sel = editor.getSelection();
  var range = editor.createRange(sel);

  if ( typeof link == "undefined" ) {
	link = this._getElement('a');
  }
  if ( !link ) {
	this.fullwordSelection();
  } else {
      editor.selectNodeContents(link);
      outparam = {
	  f_href   : Xinha.is_ie ? link.href.trim() : link.getAttribute("href"),
	  f_label : Xinha.is_ie ? link.innerText : link.textContent
      };
  }

  this.linkDialog.showDialog(editor,link,outparam);
  return;

};

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
		proxy:editor.config.URIs.insert_image_proxy,
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
	proxy:config.proxy,
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


