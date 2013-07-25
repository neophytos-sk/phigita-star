Gecko._pluginInfo = {
  name          : "Gecko"
};

function Gecko(editor) {
  this.editor = editor;  
  editor.Gecko = this;
}

/** Allow Gecko to handle some key events in a special way.
 */
  

Gecko.prototype.collapsed = function(rng) {
	return rng.collapsed;
}

Xinha.prototype.collapsed = Gecko.prototype.collapsed;

Xinha.prototype.isEndPos = function() {
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

Xinha.prototype.isStartPosDebug = function() {
    _xo_sel = this.getSelection();
    _xo_rng = this.createRange(_xo_sel);
    _xo_node = this.getParentElement();
    if (_xo_node) {
		if (_xo_node.length == 0 || _xo_node.childNodes.length == 0) {
			return 'CH'+_xo_node.childNodes.length+'t'+typeof _xo_node.childNodes + 'l' + _xo_node.childNodes.length;
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
	    return  'i'+i+'NT'+LCN.nodeType+'L'+LCN.length+'CH'+_xo_node.childNodes.length+'SS' + _xo_rng.compareBoundaryPoints(Range.START_TO_START,tmpRange) + 'EE' + _xo_rng.compareBoundaryPoints(Range.END_TO_END,tmpRange) + 'SE' + _xo_rng.compareBoundaryPoints(Range.START_TO_END,tmpRange) + 'ES' + _xo_rng.compareBoundaryPoints(Range.END_TO_START,tmpRange);
    } else {
	return _xo_node;
    }
}

Gecko.prototype.onKeyPress = function(ev)
{
  var editor = this.editor;
  var s = editor.getSelection();
  
  // Handle shortcuts
  if(editor.isShortCut(ev))
  {
    switch(editor.getKey(ev).toLowerCase())
    {
      case 'z':
      {
        if(editor._unLink && editor._unlinkOnUndo)
        {
          Xinha._stopEvent(ev);
          editor._unLink();
          editor.updateToolbar();
          return true;
        }
      }
      break;
      
      case 'a':
      {
        // KEY select all
        sel = editor.getSelection();
        sel.removeAllRanges();
        range = editor.createRange();
        range.selectNodeContents(editor._doc.body);
        sel.addRange(range);
        Xinha._stopEvent(ev);
        return true;
      }
      break;
      
      case 'v':
      {
        // If we are not using htmlareaPaste, don't let Xinha try and be fancy but let the 
        // event be handled normally by the browser (don't stopEvent it)
        if(!editor.config.htmlareaPaste)
        {          
          return true;
        }
      }
      break;
    }
  }
  
  // Handle normal characters
  switch(editor.getKey(ev)) {
    // Space, see if the text just typed looks like a URL, or email address
    // and link it appropriatly
    case ' ':
    {      
	if ( editor._customUndo && editor._editMode == 'wysiwyg') { editor._undoTakeSnapshot(); }


      var autoWrap = function (textNode, tag)
      {
        var rightText = textNode.nextSibling;
        if ( typeof tag == 'string')
        {
          tag = editor._doc.createElement(tag);
        }
        var a = textNode.parentNode.insertBefore(tag, rightText);
        Xinha.removeFromParent(textNode);
        a.appendChild(textNode);
        rightText.data = ' ' + rightText.data;
    
        s.collapse(rightText, 1);
    
        editor._unLink = function()
        {
          var t = a.firstChild;
          a.removeChild(t);
          a.parentNode.insertBefore(t, a);
          Xinha.removeFromParent(a);
          editor._unLink = null;
          editor._unlinkOnUndo = false;
        };
        editor._unlinkOnUndo = true;
        editor._xo_garbageCollect();
        return a;
      };
  


      if ( editor.config.convertUrlsToLinks && s && s.isCollapsed && s.anchorNode.nodeType == 3 && s.anchorNode.data.length > 3 && s.anchorNode.data.indexOf('.') >= 0 )
      {
        var midStart = s.anchorNode.data.substring(0,s.anchorOffset).search(/\S{4,}$/);
        if ( midStart == -1 )
        {
          break;
        }

        if ( editor._getFirstAncestor(s, 'a') )
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
  switch ( ev.keyCode )
  {    

    case 27: // ESCAPE
    {
      if ( editor._unLink )
      {
        editor._unLink();
        Xinha._stopEvent(ev);
      }
      break;
    }
    break;
	//AK Change
	case 37: //left
	{
		var range = editor.createRange(s);
		if (range.collapsed) {
			l = editor.getParentElement();
			if ( l && l.tagName.toLowerCase() != 'body' ) {
				if (editor.isStartPos() && l.parentNode.tagName.toLowerCase() != 'body') {
					range.setStartBefore(l);
					range.setEndBefore(l);
					Xinha._stopEvent(ev);
				}
			}
		}
		break;
	}
	case 39: //right
	{
		var range = editor.createRange(s);
		if (range.collapsed) {
			l = editor.getParentElement();
			if ( l  && l.tagName.toLowerCase() != 'body' ) {
				if (editor.isEndPos() && l.parentNode.tagName.toLowerCase() != 'body') {
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
    
    case 8: // KEY backspace
    case 46: // KEY delete
    {

	sel = this.editor.getSelection();
  	rng = this.editor.createRange(sel);
		
	_xo_stop_p = false;
	_xo_blocks = ["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","li","body"];
	_xo_fan = this.editor._getFirstAncestor(this.editor.getSelection(),_xo_blocks);


	  if (!rng.collapsed) {
		_xo_p = false;
		if ( rng.endContainer != rng.startContainer) {
			if (ev.keyCode == 46) {
				_xo_p = rng.startContainer;
				_xo_collapse_to_start = false;
			} else if (ev.keyCode == 8) {
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

		_xo_fan = this.editor._getFirstAncestor(this.editor.getSelection(),_xo_blocks);

		_xo_stop_p = true;
		_xo_deleted_p = true;

	  }

		_xo_regexp = /[ \t\n\r\s\xAD\xA0]/g;
		_xo_PS = _xo_fan.previousSibling;
		_xo_NS = _xo_fan.nextSibling;



	if (_xo_fan.textContent.replace(_xo_regexp,'').length == 1) {

		p = rng.startContainer
		while (p.nodeType == 3) p=p.parentNode;
		_xo_start_textContent = p.textContent;

		p = rng.endContainer
		while (p.nodeType == 3) p=p.parentNode;
		_xo_end_textContent = p.textContent;


		_xo_text_to_start = '';
		_xo_text_to_end = '';
		_xo_start_offset = rng.startOffset;
		_xo_end_offset = rng.endOffset;
		if (_xo_start_offset>0 && ev.keyCode == 8 && rng.collapsed) {
			_xo_start_offset--;
		}
		if (_xo_end_offset < _xo_end_textContent.length && ev.keyCode == 46 && rng.collapsed) {
			_xo_end_offset++;
		}
		if (_xo_start_textContent.length) {
			_xo_text_to_start = _xo_start_textContent.substr(0,_xo_start_offset);
		}
		if ( _xo_end_textContent.length) {
			_xo_text_to_end = _xo_end_textContent.substring(_xo_end_offset);
		}
		//alert('@parentNodeText: ' + _xo_fan.textContent + '@so: ' + _xo_start_offset + '@eo: ' + _xo_end_offset + ' @startContainerText: ' + _xo_start_textContent + ' @endContainerText: ' + _xo_end_textContent + ' @ts: ' + _xo_text_to_start + ' @te: ' + _xo_text_to_end);

		// if current node after delete/backspace is empty
		if ((_xo_text_to_start + _xo_text_to_end).replace(_xo_regexp,'').length == 0) {

			//alert('@ps: ' + _xo_PS.textContent);
			//and previous sibling is empty then remove previous sibling
			if (_xo_PS && _xo_PS.textContent.replace(_xo_regexp,'').length == 0) {
				_xo_PS.innerHTML='';
				Xinha.removeFromParent(_xo_PS);
			}
			//and next sibling is empty then remove next sibling
			if (!_xo_NS && _xo_fan.parentNode) {
				_xo_NS = _xo_fan.parentNode.nextSibling;
			}
			if (_xo_NS && _xo_NS.textContent.replace(_xo_regexp,'').length == 0) {
				_xo_NS.innerHTML='';
				Xinha.removeFromParent(_xo_NS);
			}
		}
	} else if (_xo_fan.tagName.toLowerCase() == 'p') {
		_xo_start_textContent = '';
                p = rng.startContainer;
                while (p.nodeType == 3) p=p.parentNode;
                _xo_start_textContent = p.textContent;

		_xo_end_textContent = '';
                p = rng.endContainer;
                while (p.nodeType == 3) p=p.parentNode;
                _xo_end_textContent = p.textContent;

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

		if (ev.keyCode == 8 && _xo_PS && _xo_PS.tagName.toLowerCase() == 'p' && _xo_text_to_start.replace(_xo_regexp,'').length == 0) {
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

		if (ev.keyCode == 46 && _xo_NS && _xo_NS.tagName.toLowerCase() == 'p' && _xo_text_to_end.replace(_xo_regexp,'').length == 0) {
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
        editor._xo_garbageCollect();
	return true;
    }
    
    default:
    {
        editor._unlinkOnUndo = false;

        // Handle the "auto-linking", specifically this bit of code sets up a handler on
        // an self-titled anchor (eg <a href="http://www.gogo.co.nz/">www.gogo.co.nz</a>)
        // when the text content is edited, such that it will update the href on the anchor
        
        if ( s.anchorNode && s.anchorNode.nodeType == 3 )
        {
          // See if we might be changing a link
          var a = editor._getFirstAncestor(s, 'a');
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

  editor._xo_garbageCollect();
  return false; // Let other plugins etc continue from here.
}


Gecko.prototype.inwardHtml = function(html)
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

Gecko.prototype.outwardHtml = function(html)
{
  // ticket:56, the "greesemonkey" plugin for Firefox adds this junk,
  // so we strip it out.  Original submitter gave a plugin, but that's
  // a bit much just for this IMHO - james
  html = html.replace(/<script[\s]*src[\s]*=[\s]*['"]chrome:\/\/.*?["']>[\s]*<\/script>/ig, '');

  return html;
}

Gecko.prototype.onExecCommand = function(cmdID, UI, param)
{   
  try
  {
    // useCSS deprecated & replaced by styleWithCSS
    this.editor._doc.execCommand('useCSS', false, true); //switch useCSS off (true=off)
    this.editor._doc.execCommand('styleWithCSS', false, false); //switch styleWithCSS off     
  } catch (ex) {}
    
  switch(cmdID)
  {
    case 'paste':
    {
      alert(Xinha._lc("The Paste button does not work in Mozilla based web browsers (technical security reasons). Press CTRL-V on your keyboard to paste directly."));
      return true; // Indicate paste is done, stop command being issued to browser by Xinha.prototype.execCommand
    }
  }
  
  return false;
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

/** Return the character (as a string) of a keyEvent  - ie, press the 'a' key and
 *  this method will return 'a', press SHIFT-a and it will return 'A'.
 * 
 *  @param   keyEvent
 *  @returns string
 */
                                   
Xinha.prototype.getKey = function(keyEvent)
{
  return String.fromCharCode(keyEvent.charCode);
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

