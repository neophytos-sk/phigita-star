

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
	for (var tag in stxTags_b) {
		if (tag == htmlTag) {
		    symbol.begin = stxTags_b[tag];
		    symbol.end = stxTags_e[tag];
		    return symbol;
		}
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

    var txt = prefix;
    for (var j = 0; j < node.childNodes.length; j++) {
	txt += parseNode(node.childNodes[j],mode,list,indent);
    }
    txt = rightTrimSpace(txt);
    txt += suffix;

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
    prev_indent_level = -1;
    prev_real_indent_level = -1;
    preformatted_p = 0;
    stack_indent_levels = new Array;
//    stack_indent_levels.push(-1);
    stack_close_tags = new Array();
//    stack_close_tags.push('<empty>');
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
		otag = "<p>";
                ctag = '</p>'
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


//		alert('para' + i + ':' + para[i] + ' sct:' + stack_close_tags + ' sil:' + stack_indent_levels + ' level: ' + this_indent_level);
            for (j=stack_indent_levels.length-1; j>=0; j--) {
		indent_level = stack_indent_levels[j];
		if ( this_indent_level < indent_level || (this_indent_level == indent_level && ctag != stack_close_tags[j])) {
		    //include_otag_p = true;
		    stack_indent_levels.pop();
		    result += stack_close_tags.pop();
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
	            result += this.getHtmlFromStxPara(para[i]);
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
      html += (Xinha.is_ie ? ('\n' + indent) : '') + '<?' + root.target + ' ' + root.data + ' ?>';
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
      html = /^script|noscript|style$/i.test(root.parentNode.tagName) ? root.data : Xinha.htmlEncode(root.data);
    break;

    case 8: // Node.COMMENT_NODE
      html = "<!--" + root.data + "-->";
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

