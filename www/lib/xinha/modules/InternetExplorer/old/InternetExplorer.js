                                                    
InternetExplorer._pluginInfo = {
  name          : "Internet Explorer"
};

function InternetExplorer(editor) {
  this.editor = editor;  
  editor.InternetExplorer = this; // So we can do my_editor.InternetExplorer.doSomethingIESpecific();
}
 


InternetExplorer.prototype.isNormalListItem = function() {

  var blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
  node = this.editor._getFirstAncestor(this.editor.getSelection(),blocks);

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

 
InternetExplorer.prototype.isElementNode = function(_xo_node) {
    if (_xo_node) {
	if (_xo_node.nodeType == 1) {
		return true;
	}
    }
    return false;
}

InternetExplorer.prototype.isEmptyText = function(_xo_text) {
    var _xo_regexp = /(\&nbsp\;|\<[^\>]*\/?\>|[ \t\n\r\s\xAD\xA0])*/g;
    return _xo_text.replace(_xo_regexp,'').length==0;
}

InternetExplorer.prototype.isEmptyNode = function(_xo_node) {
    if (_xo_node && _xo_node.nodeType == 1) {
	if (this.isEmptyText(_xo_node.innerHTML)) {
	    return true;
	} else {
	    return false;
	}
    } else {
	return true;
    }
}

InternetExplorer.prototype.collapsed = function(rng) {
	if (rng && rng.compareEndPoints)
		return rng.compareEndPoints("StartToEnd",rng) == 0;
	return false;
}

Xinha.prototype.collapsed = InternetExplorer.prototype.collapsed;

InternetExplorer.prototype.textToStart = function(_xo_rng) {

    sel = this.editor.getSelection();
    blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
    _xo_node = this.editor._getFirstAncestor(sel,blocks);

    if (this.isElementNode(_xo_node)) {
		rng_clone = _xo_rng.duplicate();
		rng_clone.moveToElementText(_xo_node);
		rng_clone.setEndPoint("EndToStart",_xo_rng);
		_xo_text_to_start = rng_clone.text;
		return _xo_text_to_start;
    } else {
		return '';
    }
}

InternetExplorer.prototype.textToEnd = function(_xo_rng) {

    sel = this.editor.getSelection();
    blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li"];
    _xo_node = this.editor._getFirstAncestor(sel,blocks);

    if (this.isElementNode(_xo_node)) {
		rng_clone = _xo_rng.duplicate();
		rng_clone.moveToElementText(_xo_node);
		rng_clone.setEndPoint("StartToEnd",_xo_rng);
		_xo_text_to_end = rng_clone.text;
		return _xo_text_to_end;
    } else {
		return '';
    }
}

//AK Change --end
  
InternetExplorer.prototype.onKeyPress = function(ev) {
  // Shortcuts
  if(this.editor.isShortCut(ev)) {
    switch(this.editor.getKey(ev).toLowerCase()) {
      case 'n':
        this.editor.execCommand('formatblock', false, '<p>');        
        Xinha._stopEvent(ev);
        return true;
        break;
    }
  }
  
  switch(ev.keyCode) {
    case 8: // KEY backspace
    case 46: // KEY delete
		sel = this.editor.getSelection();
		rng = this.editor.createRange(sel);
		
		_xo_stop_p = false;
		_xo_blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
		_xo_fan = this.editor._getFirstAncestor(this.editor.getSelection(),_xo_blocks);
		
		if (!this.collapsed(rng))
		{
			_xo_p = rng.parentElement(); //returns the next outermost html tag that holds both ends
			if (_xo_p.nodeType == 3) //same text node
				_xo_p = false;
			rng.pasteHTML("");			
			_xo_fan = this.editor._getFirstAncestor(this.editor.getSelection(),_xo_blocks);

			_xo_stop_p = true;
			_xo_deleted_p = true;
		}
		else
		{
			if (ev.keyCode == 8) //backspace
			{
				rng.moveStart("character",-1);
				rng.pasteHTML("");
				rng.select();
			}
			if (ev.keyCode == 46) //backspace
			{
				rng.moveEnd("character",1);
				rng.pasteHTML("");
				rng.select();
			}
		}
		
		_xo_regexp = /[ \t\n\r\s\xAD\xA0]/g;
		_xo_PS = _xo_fan.previousSibling;
		_xo_NS = _xo_fan.nextSibling;

				
		if (_xo_fan.innerText.replace(_xo_regexp,'').length == 0) {

			_xo_text_to_start = this.textToStart(rng);
			_xo_text_to_end = this.textToEnd(rng);
			
			if ((_xo_text_to_start + _xo_text_to_end).replace(_xo_regexp,'').length == 0) {
				
				if (_xo_PS && _xo_PS.innerText.replace(_xo_regexp,'').length == 0) {
					_xo_PS.innerHTML='';
					Xinha.removeFromParent(_xo_PS);
				}
				//and next sibling is empty then remove next sibling
				if (!_xo_NS && _xo_fan.parentNode) {
					_xo_NS = _xo_fan.parentNode.nextSibling;
				}
				if (_xo_NS && _xo_NS.innerText.replace(_xo_regexp,'').length == 0) {
					_xo_NS.innerHTML='';
					Xinha.removeFromParent(_xo_NS);
				}
			}
		} else if (_xo_fan.tagName.toLowerCase() == 'p') {
			
			_xo_text_to_start = this.textToStart(rng);
			_xo_text_to_end = this.textToEnd(rng);
			
			if (ev.keyCode == 8 && _xo_PS && _xo_PS.tagName.toLowerCase() == 'p' && _xo_text_to_start.replace(_xo_regexp,'').length == 0) {
				_xo_DF = _xo_fan.innerHTML;
				_xo_PS.innerHTML = _xo_PS.innerHTML.replace(/(^\<br\s*\/?\>|^\&nbsp\;|\<br\s*\/?\>$)/,'');
				rng.moveToElementText(_xo_PS);
				rng.moveEnd("character",-1); //gia na mpei mesa stin paragrafo
				rng.collapse(false);
				rng.select();
				var rng_clone = rng.duplicate();
				
				rng.pasteHTML(_xo_DF);
				
				rng_clone.collapse();
				rng_clone.select();
				
				Xinha.removeFromParent(_xo_fan);
				Xinha._stopEvent(ev);
			}
			
			
			if (ev.keyCode == 46 && _xo_NS && _xo_NS.tagName.toLowerCase() == 'p' && _xo_text_to_end.replace(_xo_regexp,'').length == 0) {
				_xo_NS.innerHTML = _xo_NS.innerHTML.replace(/(^\&nbsp\;|^\<br\s*\/?\>|\&nbsp\;$)/,'');
				_xo_DF = _xo_NS.innerHTML;
				_xo_fan.innerHTML = _xo_fan.innerHTML.replace(/(\&nbsp\;$|\<br\s*\/?\>$)/,'');
				rng.moveToElementText(_xo_fan);
				rng.moveEnd("character",-1); //gia na mpei mesa stin paragrafo
				rng.collapse(false);
				rng.select();
				var rng_clone = rng.duplicate();
				
				rng.pasteHTML(_xo_DF);
				
				rng_clone.collapse();
				rng_clone.select();
				
				Xinha.removeFromParent(_xo_NS);
				Xinha._stopEvent(ev);
			}
		return true;	
		}
	    break;
	case 13:
		sel = this.editor.getSelection();
  		rng = this.editor.createRange(sel);
		_xo_stop_p = false;  
		_xo_deleted_p = false;
		_xo_blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
		_xo_fan = this.editor._getFirstAncestor(this.editor.getSelection(),_xo_blocks);
		_xo_fan_tag_name = _xo_fan.tagName.toLowerCase();
		
		if (!this.collapsed(rng)) {
			_xo_p = rng.parentElement(); //returns the next outermost html tag that holds both ends
			if (_xo_p.nodeType == 3) //same text node
				_xo_p = false;
			rng.pasteHTML(""); //rng.deleteContents()
			
			_xo_fan = this.editor._getFirstAncestor(this.editor.getSelection(),_xo_blocks);
			
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
		if (this.isElementNode(_xo_fan_PS) && _xo_fan_PS.tagName.toLowerCase() == 'ol')
			_xo_fan_PS = _xo_fan_PS.lastChild;
		if (this.isElementNode(_xo_fan_NS) && _xo_fan_NS.tagName.toLowerCase() == 'ol')
			_xo_fan_NS = _xo_fan_NS.firstChild;
			
		empty_prev_p = this.isEmptyNode(_xo_fan_PS);
		empty_next_p = this.isEmptyNode(_xo_fan_NS);
		_xo_text_to_start = this.textToStart(rng);
		_xo_text_to_end = this.textToEnd(rng);

		empty_current_p = this.isEmptyText(_xo_text_to_start + _xo_text_to_end);
		
		if (empty_prev_p && this.isElementNode(_xo_fan_PS) && this.isEmptyText(_xo_text_to_start)) {
			if (empty_current_p) { Xinha.removeFromParent(_xo_fan_PS); }
			_xo_stop_p = true;
		}
		
		if (this.isEmptyText(_xo_text_to_end)) {
			if (!_xo_list_item_p || this.isElementNode(_xo_fan.nextSibling)) {
			if ( empty_next_p && this.isElementNode(_xo_fan_NS)) {
				if (empty_current_p) { Xinha.removeFromParent(_xo_fan); }
				rng.moveToElementText(_xo_fan_NS);
				rng.collapse();
				rng.select();

				_xo_stop_p = true;
				}
			} else if (_xo_list_item_p && empty_current_p && !this.isElementNode(_xo_fan.nextSibling)) {
				rng.moveToElementText(_xo_fan_PN);
				rng.collapse(false);
				rng.select();
				if (_xo_fan_PN.tagName.toLowerCase() == "ol")
					this.editor._doc.execCommand("insertorderedlist");
				else
					this.editor._doc.execCommand("insertunorderedlist");

				if ( empty_next_p && this.isElementNode(_xo_fan_NS)) { Xinha.removeFromParent(_xo_fan_NS); }
				if (empty_current_p) { Xinha.removeFromParent(_xo_fan); }
				_xo_stop_p = true;
			} else {
			if ( empty_next_p && this.isElementNode(_xo_fan_NS)) { Xinha.removeFromParent(_xo_fan_NS); }
			}
		} 
		
		if (empty_current_p) {
			_xo_stop_p = true;
		}
		
		this.editor.updateToolbar();

		if (_xo_stop_p) Xinha._stopEvent(ev);
		if (_xo_stop_p /*|| _xo_list_item_p*/) return true;
	}
	return false;
};

/** When backspace is hit, the IE onKeyPress will execute this method.
 *  It preserves links when you backspace over them and apparently 
 *  deletes control elements (tables, images, form fields) in a better
 *  way.
 *
 *  @returns true|false True when backspace has been handled specially
 *   false otherwise (should pass through). 
 */

InternetExplorer.prototype.handleBackspace = function()
{
  var editor = this.editor;
  var sel = editor.getSelection();
  if ( sel.type == 'Control' )
  {
    var elm = editor.activeElement(sel);
    Xinha.removeFromParent(elm);
    return true;
  }

  // This bit of code preseves links when you backspace over the
  // endpoint of the link in IE.  Without it, if you have something like
  //    link_here |
  // where | is the cursor, and backspace over the last e, then the link
  // will de-link, which is a bit tedious
  var range = editor.createRange(sel);
  var r2 = range.duplicate();
  r2.moveStart("character", -1);
  var a = r2.parentElement();
  // @fixme: why using again a regex to test a single string ???
  if ( a != range.parentElement() && ( /^a$/i.test(a.tagName) ) )
  {
    r2.collapse(true);
    r2.moveEnd("character", 1);
    r2.pasteHTML('');
    r2.select();
    return true;
  }
};

InternetExplorer.prototype.inwardHtml = function(html)
{
   // Both IE and Gecko use strike internally instead of del (#523)
   // Xinha will present del externally (see Xinha.prototype.outwardHtml
   html = html.replace(/<(\/?)del(\s|>|\/)/ig, "<$1strike$2");
   
   return html;
};

/*--------------------------------------------------------------------------*/
/*------- IMPLEMENTATION OF THE ABSTRACT "Xinha.prototype" METHODS ---------*/
/*--------------------------------------------------------------------------*/

/** Insert a node at the current selection point. 
 * @param toBeInserted DomNode
 */

Xinha.prototype.insertNodeAtSelection = function(toBeInserted)
{
	this.insertAtCursor(toBeInserted.outerHTML);
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
  var range = this.createRange(sel);
  switch ( sel.type )
  {
    case "Text":
      // try to circumvent a bug in IE:
      // the parent returned is not always the real parent element
      var parent = range.parentElement();
      while ( true )
      {
        var TestRange = range.duplicate();
        TestRange.moveToElementText(parent);
        if ( TestRange.inRange(range) )
        {
          break;
        }
        if ( ( parent.nodeType != 1 ) || ( parent.tagName.toLowerCase() == 'body' ) )
        {
          break;
        }
        parent = parent.parentElement;
      }
      return parent;
    case "None":
      // It seems that even for selection of type "None",
      // there _is_ a parent element and it's value is not
      // only correct, but very important to us.  MSIE is
      // certainly the buggiest browser in the world and I
      // wonder, God, how can Earth stand it?
      return range.parentElement();
    case "Control":
      return range.item(0);
    default:
      return this._doc.body;
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

  if ( sel.type.toLowerCase() == "control" )
  {
    return sel.createRange().item(0);
  }
  else
  {
    // If it's not a control, then we need to see if
    // the selection is the _entire_ text of a parent node
    // (this happens when a node is clicked in the tree)
    var range = sel.createRange();
    var p_elm = this.getParentElement(sel);
    if ( p_elm.innerHTML == range.htmlText )
    {
      return p_elm;
    }
    return null;
  }
};

/** 
 * Determines if the given selection is empty (collapsed).
 * @param selection Selection object as returned by getSelection
 * @returns true|false
 */
 
Xinha.prototype.selectionEmpty = function(sel)
{
  if ( !sel ) {
    return true;
  }

  return this.createRange(sel).htmlText === '';
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
  // Tables and Images get selected as "objects" rather than the text contents
  if ( collapsed && node.tagName && node.tagName.toLowerCase().match(/table|img|input|select|textarea/) )
  {
    range = this._doc.body.createControlRange();
    range.add(node);
  }
  else
  {
    range = this._doc.body.createTextRange();
    range.moveToElementText(node);
    //(collapsed) && range.collapse(pos);
  }
  range.select();
};
  
/** Insert HTML at the current position, deleting the selection if any. 
 *  
 *  @param html string
 */
 
Xinha.prototype.insertAtCursor = function(html)
{
  var sel = this.getSelection();
  var range = this.createRange(sel);
  this.focusEditor();
  range.pasteHTML(html);
};


/** Get the HTML of the current selection.  HTML returned has not been passed through outwardHTML.
 *
 * @returns string
 */
 
Xinha.prototype.getSelectedHTML = function()
{
  var sel = this.getSelection();
  var range = this.createRange(sel);
  
  // Need to be careful of control ranges which won't have htmlText
  if( range.htmlText )
  {
    return range.htmlText;
  }
  else if(range.length >= 1)
  {
    return range.item(0).outerHTML;
  }
  
  return '';
};
  
/** Get a Selection object of the current selection.  Note that selection objects are browser specific.
 *
 * @returns Selection
 */
 
Xinha.prototype.getSelection = function()
{
  return this._doc.selection;
};

/** Create a Range object from the given selection.  Note that range objects are browser specific.
 *
 *  @param sel Selection object (see getSelection)
 *  @returns Range
 */
 
Xinha.prototype.createRange = function(sel)
{
  return sel.createRange();
};

/** Determine if the given event object is a keydown/press event.
 *
 *  @param event Event 
 *  @returns true|false
 */
 
Xinha.prototype.isKeyEvent = function(event)
{
  return event.type == "keydown";
};

/** Return the character (as a string) of a keyEvent  - ie, press the 'a' key and
 *  this method will return 'a', press SHIFT-a and it will return 'A'.
 * 
 *  @param   keyEvent
 *  @returns string
 */
                                   
Xinha.prototype.getKey = function(keyEvent)
{
  return String.fromCharCode(keyEvent.keyCode);
};


/** Return the HTML string of the given Element, including the Element.
 * 
 * @param element HTML Element DomNode
 * @returns string
 */
 
Xinha.getOuterHTML = function(element)
{
  return element.outerHTML;
};

// Control character for retaining edit location when switching modes
Xinha.prototype.cc = String.fromCharCode(0x2009);

Xinha.prototype.setCC = function ( target )
{
  if ( target == "textarea" )
  {
    var ta = this._textArea;
    var pos = document.selection.createRange();
    pos.collapse();
    pos.text = this.cc;
    var index = ta.value.indexOf( this.cc );
    while (index < ta.value.length && ta.value[index] != ' ') {
	index++;
    }
    var before = ta.value.substring( 0, index );
    var after  = ta.value.substring( index + this.cc.length , ta.value.length );
    ta.value = before + this.cc + after;
  }
  else
  {
    var sel = this.getSelection();
    var r = sel.createRange(); 
    if ( sel.type == 'Control' )
    {
      var control = r.item(0);
      control.outerHTML += this.cc;
    }
    else
    {
      r.collapse();
      r.text = this.cc;
    }
  }
};

Xinha.prototype.findCC = function ( target )
{
  var findIn = ( target == 'textarea' ) ? this._textArea : this._doc.body;
  range = findIn.createTextRange();
  // in case the cursor is inside a link automatically created from a url
  // the cc also appears in the url and we have to strip it out additionally 
  if( range.findText( escape(this.cc) ) )
  {
    range.select();
    range.text = '';
  }
  if( range.findText( this.cc ) )
  {
    range.select();
    range.text = '';
  }
  if ( target == 'textarea' ) this._textArea.focus();
};


