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


Xinha.prototype.onKeyPress = function(ev) {
    var editor = this;
    var s = this.getSelection();
    
    // If they've hit enter and shift is not pressed, handle it
  
    if (ev.getKey()==ev.ENTER && !ev.shiftKey && this._iframe.contentWindow.getSelection) {
	return this.handleEnter(ev);
    } else if (ev.getKey()==ev.ENTER && ev.shiftKey) {
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
    if(this.isShortCut(ev)) {
	switch(ev.getKey()) {
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
	}
	break;    
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
    
	case ev.DELETE:
	if (ev.browserEvent.which != 0 ) break;
	case ev.BACKSPACE:
	{
	    //console.log('delete or backspace getKey='+ev.getKey()+' getCharCode='+ev.getCharCode() + 'backspace='+ev.BACKSPACE + ' delete='+ev.DELETE + ' which='+ev.browserEvent.which);	    
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

		p = rng.startContainer;
		while (p.nodeType == 3) p=p.parentNode;
		_xo_start_textContent = this.textContent(p);
		
		p = rng.endContainer;
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

  //console.log('stop_p='+_xo_stop_p+' _xo_list_item_p='+_xo_list_item_p+' empty_prev_p='+empty_prev_p+' empty_current_p='+empty_current_p+' empty_next_p='+empty_next_p);

	if (_xo_stop_p) Xinha._stopEvent(ev);
	if (_xo_stop_p || _xo_list_item_p) return true;

  this.updateToolbar();
return true;




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
