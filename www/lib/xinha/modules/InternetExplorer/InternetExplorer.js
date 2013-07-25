

// Internet Explorer

if (Xinha.is_ie) {


Xinha.prototype.textContent = function(node) {
    return node.innerText + node.innerHTML.match(Xinha.RE_img)!=null?'X':'';
};



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


Xinha.prototype.isNormalListItem = function() {

  var blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
  node = this._getFirstAncestor(this.getSelection(),blocks);

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

 
Xinha.prototype.isElementNode = function(_xo_node) {
    if (_xo_node) {
	if (_xo_node.nodeType == 1) {
		return true;
	}
    }
    return false;
}

Xinha.prototype.isEmptyText = function(_xo_text) {
    var _xo_regexp = /(\&nbsp\;|\<[^\>]*\/?\>|[ \t\n\r\s\xAD\xA0])*/g;
    return _xo_text.replace(_xo_regexp,'').length==0;
}

Xinha.prototype.isEmptyNode = function(_xo_node) {
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

Xinha.prototype.collapsed = function(rng) {
	if (rng && rng.compareEndPoints)
		return rng.compareEndPoints("StartToEnd",rng) == 0;
	return false;
}



Xinha.prototype.textToStart = function(_xo_rng) {

    sel = this.getSelection();
    blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
    _xo_node = this._getFirstAncestor(sel,blocks);

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

Xinha.prototype.textToEnd = function(_xo_rng) {

    sel = this.getSelection();
    blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li"];
    _xo_node = this._getFirstAncestor(sel,blocks);

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
  
Xinha.prototype.onKeyPress = function(ev) {
  var sel, rng, _xo_stop_p, _xo_blocks, _xo_fan, _xo_p, _xo_deleted_p, _xo_text_to_start, _xo_text_to_end, _xo_PS, _xo_NS, _xo_regexp, _xo_DF, _xo_fan_tag_name, _xo_fan_NS, _xo_fan_PS, _xo_fan_PN, _xo_list_item_p, empty_prev_p, empty_next_p, empty_current_p, _xo_list_item_p;
  // Shortcuts
  if(this.isShortCut(ev)) {
    switch(ev.getKey()) {
      case ev.N:
        this.execCommand('formatblock', false, '<p>');        
        Xinha._stopEvent(ev);
        return true;
        break;
    }
  }
  
  switch(ev.getKey()) {
    case ev.DELETE: 
	if (ev.browserEvent.which != 0 ) break;
    case ev.BACKSPACE:
		sel = this.getSelection();
		rng = this.createRange(sel);
		
		_xo_stop_p = false;
		_xo_blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
		_xo_fan = this._getFirstAncestor(this.getSelection(),_xo_blocks);
		
		if (!this.collapsed(rng))
		{
			_xo_p = rng.parentElement(); //returns the next outermost html tag that holds both ends
			if (_xo_p.nodeType == 3) //same text node
				_xo_p = false;
			rng.pasteHTML("");			
			_xo_fan = this._getFirstAncestor(this.getSelection(),_xo_blocks);

			_xo_stop_p = true;
			_xo_deleted_p = true;
		}
		else
		{
			if (ev.getKey() == ev.BACKSPACE) //backspace
			{
				rng.moveStart("character",-1);
				rng.pasteHTML("");
				rng.select();
				Xinha._stopEvent(ev);
			}
			if (ev.getKey() == ev.DELETE) //backspace
			{
				rng.moveEnd("character",1);
				rng.pasteHTML("");
				rng.select();
				Xinha._stopEvent(ev);
			}
		}
		
		_xo_regexp = /[ \t\n\r\s\xAD\xA0]/g;
		_xo_PS = _xo_fan.previousSibling;
		_xo_NS = _xo_fan.nextSibling;

				
		if (this.textContent(_xo_fan).replace(_xo_regexp,'').length == 0) {

			_xo_text_to_start = this.textToStart(rng);
			_xo_text_to_end = this.textToEnd(rng);
			
			if ((_xo_text_to_start + _xo_text_to_end).replace(_xo_regexp,'').length == 0) {
				
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
			
			_xo_text_to_start = this.textToStart(rng);
			_xo_text_to_end = this.textToEnd(rng);
			
			if (ev.getKey() == ev.BACKSPACE && _xo_PS && _xo_PS.tagName.toLowerCase() == 'p' && _xo_text_to_start.replace(_xo_regexp,'').length == 0) {

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
			
			
			if (ev.getKey() == ev.DELETE && _xo_NS && _xo_NS.tagName.toLowerCase() == 'p' && _xo_text_to_end.replace(_xo_regexp,'').length == 0) {
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
		//return true;	
		}
	    break;
	case ev.ENTER:
		sel = this.getSelection();
  		rng = this.createRange(sel);
		_xo_stop_p = false;  
		_xo_deleted_p = false;
		_xo_blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
		_xo_fan = this._getFirstAncestor(this.getSelection(),_xo_blocks);
		_xo_fan_tag_name = _xo_fan.tagName.toLowerCase();
		
		if (!this.collapsed(rng)) {
			_xo_p = rng.parentElement(); //returns the next outermost html tag that holds both ends
			if (_xo_p.nodeType == 3) //same text node
				_xo_p = false;
			rng.pasteHTML(""); //rng.deleteContents()
			
			_xo_fan = this._getFirstAncestor(this.getSelection(),_xo_blocks);
			
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

		empty_current_p = this.isEmptyText(_xo_text_to_start + _xo_text_to_end) && this.noSpecialContent(_xo_fan);
		
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
					this._doc.execCommand("insertorderedlist");
				else
					this._doc.execCommand("insertunorderedlist");

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
		
		this.updateToolbar();

		if (_xo_stop_p) Xinha._stopEvent(ev);
		if (_xo_stop_p /*|| _xo_list_item_p*/) return true;
	}
	return false;
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


Xinha.prototype.gotoNode =function (node) {
	var sel, rng;
	this.selectNodeContents(node);
	sel=this.getSelection();
	rng=this.createRange(sel);
	rng.collapse();
	rng.select();
}
Xinha.prototype.fullwordSelection = function (spaces)  {
	var sel = this.getSelection();
	var range = this.createRange(sel);

	_xo_fan = this._getFirstAncestor(sel, ['a']);
	if ( _xo_fan ) {
	    	this.selectNodeContents(_xo_fan);
		return;
	}
	
	if (range.compareEndPoints("StartToEnd",range) == 0) //collapsed -> handled by IE
		return;
		
	//expand to the left
	var p = range.offsetLeft-1; //-1 is for just not to be the same with the offset
	while (!isStopChar(range.text.charAt(0)))
	{
		if (range.offsetLeft == p) //to know that it reached the left end
			break;
		p = range.offsetLeft;
		range.moveStart("character",-1);
	}
	if (isStopChar(range.text.charAt(0)))
		range.moveStart("character",1);
	
	if (spaces) //expand to the left to get all the StopChars
	{
		p = range.offsetLeft-1; //-1 is for just not to be the same with the offset
		do 
		{
			if (range.offsetLeft == p) //to know that it reached the left end
				break;
			p = range.offsetLeft;
			range.moveStart("character",-1);
		} 
		while (isStopChar(range.text.charAt(0)));
		
		if (!isStopChar(range.text.charAt(0)))
			range.moveStart("character",1);
	}
	
	//expand to the right
	p = range.text.length-1; //-1 is for just not to be the same with the length
	while (!isStopChar(range.text.charAt(range.text.length-1)))
	{
		if (range.text.length == p)
			break;
		p = range.text.length;
		range.moveEnd("character",1);
	}
	if (isStopChar(range.text.charAt(range.text.length-1)))
		range.moveEnd("character",-1);
	
	if (spaces)
	{
		p = range.text.length-1;
		do
		{
			if (range.text.length == p)
				break;
			p = range.text.length;
			range.moveEnd("character",1);
		}
		while (isStopChar(range.text.charAt(range.text.length-1)));
		
		if (!isStopChar(range.text.charAt(range.text.length-1)))
			range.moveEnd("character",-1);
	}
	
	range.select();
}

}