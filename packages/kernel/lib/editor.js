/*
 * kernel/lib/base.js
 * kernel/lib/event.js
 * kernel/lib/DomHelper.js
 *
 */

$ = xo.getDom;


Array.prototype.contains = function(obj) {
  var i = this.length;
  while (i--) {
    if (this[i] === obj) {
      return true;
    }
  }
  return false;
};


function rightTrimSpace(sString) {
    while (sString.substring(sString.length-1, sString.length) == ' ') {
        sString = sString.substring(0,sString.length-1);
    }
    return sString;
};


var Editor = Editor || {};


Editor.getStxTag_ = function(tag) {

    tag = tag.trim();

    var stxTags_b = new Array();    //stx begin symbols
    var stxTags_e = new Array();    //std end symbols

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
    //      for (var tag in stxTags_b)
    if (typeof stxTags_b[tag] !== 'undefined') {
	symbol.begin = stxTags_b[tag];
	symbol.end = stxTags_e[tag];
    }
    return symbol;

};


Editor.getTagName_ = function(node) {
    if (node.tagName.toLowerCase() == 'font')
	if (node.className)
	    return node.className.toLowerCase();
    return  node.tagName.toLowerCase();
};

Editor.HtmlToStx_ = function(node, mode, list, indent,depth) {
    mode = mode || '';
    list = list || '';
    indent = indent || '';
    depth = depth || 0;

    var prefix = '';
    var suffix = '';
    var tag, symbol;
    if (!node) return "";
    

    xo.log('nodeType:'+node.nodeType);
    xo.log('text:'+node.textContent);

    // Node.TEXT_NODE
    if (node.nodeType == 3) {
	if (xo.isIE) {
            return node.toString().trim().replace(/^/gm,indent);
	} else {
            return node.textContent.trim().replace(/^/gm,indent);
	}
    }


    tag = Editor.getTagName_(node);
    symbol = Editor.getStxTag_(tag);

    if (tag == "ul") list = "ul";
    if (tag == "p" || tag == "pre" || tag =="code")
            mode = tag;
        
    if (tag == "br") {
        if (mode == "pre" || mode == "code") {
            symbol.begin = "\n";
            symbol.end = "";
        } else if (mode == "p") {
            symbol.begin = "";
        }
    }
        
    prefix += symbol.begin;
    suffix = symbol.end + suffix;

    
    //if (tag == "p") { prefix += indent; }
    // HERE: if tag changed, the indent level should change as well
    if (tag == "pre" || tag == "code" || tag == "li") { 
        indent += " "; 
        //prefix += indent; 
    } else if (tag == "br") {
        //prefix += indent;
        //if (window['console']) { console.log("mode="+mode+" tag=" + tag); }
    }

    if (tag == "a") {
        suffix += node.getAttribute("href").trim();
    } else if (tag == "img") {
        var alt = xo.decode(node.getAttribute('alt'));
        prefix += alt.filetype.trim() + ':';
        prefix += alt.identifier.trim();
        // prefix += node.getAttribute("filetype").trim() + ':';
        // prefix += node.getAttribute("identifier").trim();
        if (node.className) {
            prefix += ' ' + node.className;
        }
        if (node.getAttribute("title")) {
            prefix += ' | ' + node.getAttribute("title").trim();
        }
    }

    var txt = '';
    for (var j = 0; j < node.childNodes.length; j++) {
        txt += Editor.HtmlToStx_(node.childNodes[j],mode,list,indent,depth+1);
    }

    txt = rightTrimSpace(txt);
    if (txt.length || tag=='img' || tag=='br') {
        txt = prefix + txt + suffix;
    } else if (tag == 'hr') {
	txt = "\n\n-----\n\n";
    }

    if (txt.length) {
	// add space if we are the outer element
	if (depth==1) {
	    return " " + txt + " ";
	} else {
	    return txt;
	}
	// return "\x01" + txt + "\x01";
    } else {
        return '';
    }

};


Editor.HtmlToStx = function(html) {
    var oDiv = document.createElement('div');
    oDiv.innerHTML = html;
    result = Editor.HtmlToStx_(oDiv);

    // HERE: merge styles -- more work is required
    /*
    try {
	result = result.replace(/[*][*][\x01][\x01 ]*[\n]?[\x01 ]*[\x01][*][*]/g,' ').replace(/\n[\x01]+/g,'\n').replace(/[*][\x01][*]/g,'**').replace(/[\x01]+/g,' ').trim();
    } catch(ex) {
	xo.log('HtmlToStx');
	xo.log(ex);
    }
    */
    return result;
};

Editor.StxToHtml = function(text) {
    return text;
};


Editor.hide = function(el) {
    // el.style.visibility="hidden";
    el.style.display="none";
}
Editor.show = function(el) {
    // el.style.visibility="";
    el.style.display="block";
};

Editor.getHTML = function(root) {
    var html = "";
    switch(root.nodeType){
    case 1: // Node.ELEMENT_NODE
    case 11: // Node.DOCUMENT_FRAGMENT_NODE
    case 9: // Node.DOCUMENT_NODE
	// var root_tag = (root.nodeType == 1) ? root.tagName.toLowerCase() : '';
	html = root.innerHTML;
	break;
    case 3: // Node.TEXT_NODE
	// html = /^script|noscript|style$/i.test(root.parentNode.tagName) ? root.data : Xinha.htmlEncode(root.data);
	html = root.data;
	break;
    };
    return html;
};


Editor.getFirstAncestor = function(range,types) {
    var prnt = range.commonAncestorContainer;
    if ( types === null ) {
	return prnt;
    }
    while ( prnt ) {
	if ( prnt.nodeType == 1 ) {
	    if ( types.contains(prnt.tagName.toLowerCase()) ) {
		return prnt;
	    }
	}
	prnt = prnt.parentNode;
    }
    return null;
};

isStopChar = function(ch) {
    var stopchars = " \t\n\r.,;?";
    if (stopchars.indexOf(ch) != -1)
	return true;
    return false;
};

Editor.getSelection = function() {
    return Editor.window.getSelection();
};

Editor.createRange = function(sel) {
    if (sel.createRange) {
	// IE
	return sel.createRange();
    } else {
	// Gecko
	if (typeof sel != 'undefined') {
	    return sel.getRangeAt(0);
	} else {
	    return Editor.document.createRange();
	}
    };
};


Editor.fullwordSelection = function(spaces){

    xo.log('fullwordselection');

   
    var sel = Editor.getSelection();
    var range = Editor.createRange(sel);

    //blocks = ["b","i",'strong','em','u',"span","a"];
    var fan = Editor.getFirstAncestor(range, ['a']);
    if ( fan ) {
	range.selectNode(fan);
	return;
    }

    // xo.log(sel);
    xo.log('sel:'+sel.toString());
    xo.log('range:'+range.toString());
    // xo.log(range);
    if (sel.toString().length == 0) { return }

                
    //avoid the problem with the wrong start container
    if (range.toString() == range.endContainer.nodeValue)
	range.setStart(range.endContainer,0);
        
    // ----- expand to the left -----
    while (range.startOffset && !isStopChar(range.toString().charAt(0))) {
	try { 
	    range.setStart(range.startContainer,range.startOffset-1); 
	} catch (exx) { 
	    xo.log('ex1'+exx);
	    break; 
	}
    } 
    if (isStopChar(range.toString().charAt(0))) {       
	try { range.setStart(range.startContainer,range.startOffset+1); }
	catch (exx) { 
	    xo.log('ex2'+exx);
	};
    }

    //expand left to cover all spaces
    if (spaces == true) {
	while (range.startOffset && !isStopChar(range.toString().charAt(0))) {
	    try { 
		range.setStart(range.startContainer,range.startOffset-1); 
	    } catch (exx) { 
		xo.log('ex3'+exx);
		break; 
	    }
	}
                        
	if (range.startOffset != 0 && !isStopChar(range.toString().charAt(0)))
	    range.setStart(range.startContainer,range.startOffset+1);
    }

    // ----- expand to the right -----
    var s = range.toString();
    while (range.startOffset+s.length < range.endContainer.length && !isStopChar(s[s.length-1])) {
	xo.log('startOffset:'+range.startOffset);
	xo.log('endOffset:'+range.endOffset);
	xo.log('endContainer.length:'+range.endContainer.length);
	xo.log('s.length:'+s.length);

	try { 
	    range.setEnd(range.endContainer,range.endOffset+1);
	} catch (exx) { 
	    xo.log('ex4'+exx);
	    break; 
	}
	s = range.toString();
    }
    if (isStopChar(s[s.length-1]))
	range.setEnd(range.endContainer,range.endOffset-1);
	
    //expand right to cover all spaces
    if (spaces == true) {
	while (range.startOffset + s.length < range.endContainer.length && isStopChar(s[s.length-1])) {
	    try { 
		range.setEnd(range.endContainer,range.endOffset+1); 
	    } catch (exx) { 
		xo.log('ex5'+exx);
		break; 
	    }
	    s = range.toString();
	}
            
	if (range.endOffset != range.endContainer.length && !isStopChar(s[s.length-1]))
	    range.setEnd(range.endContainer,range.endOffset-1);
    }


};


Editor.handleKey = function(e,target,options) {


    xo.log(e.keyCode);
    var key = e.keyCode;

    if (key == xo.Event.CTRL) {
	xo.log('ctrl pressed');
    }

    if (e.ctrlKey && key == xo.Event.B ) {
	xo.log('ctrl+b');
	Editor.doCommand('bold');
	xo.Event.stopEvent(e);
    } else if (e.ctrlKey && key == xo.Event.I ) {
	xo.log('ctrl+i');
	Editor.doCommand('italic');
	xo.Event.stopEvent(e);
    } else if (key == xo.Event.TAB) {
	// check that we are in a list and if yes indent
	xo.Event.stopEvent(e);
    } else if (e.ctrlKey && key == xo.Event.K) {
	// createlink
	Editor.doCommand('link');
	xo.Event.stopEvent(e);
    }

    // TODO: this will be right once 
    // we implement handling of up,down,left,right arrows
    Editor.updateToolbar();

};

// Editor.doCommand is not the same as Editor.document.execCommand
Editor.handleCommand = function(e,target,options) {
    Editor.doCommand(options.cmd);
};

Editor.insertAtCursor = function(html) {
    // Gecko
    Editor.document.execCommand('inserthtml',false,html);
    // IE
    // var sel = this.getSelection();
    // var range = this.createRange(sel);
    // this.focusEditor();
    // range.pasteHTML(html);

};

Editor.doCommand = function(cmd) {
    xo.log('cmd:'+ cmd);

    var d = Editor.document;

    d.execCommand("styleWithCSS",false,false);

    switch(cmd) {
    case 'ul':
	d.execCommand("insertunorderedlist",false,null);
	break;
    case 'hr':
	d.execCommand("inserthorizontalrule",false,null);
	break;
    case 'link':
	xo.log('link');
	this.fullwordSelection();
	// set cursor - mark/get cursor location
	//+ (Xinha.is_gecko ? editor.cc : '');
	var param = {f_href:'http://www.phigita.net',f_label:'phigita'};
	Editor.insertAtCursor('<a href="' + param.f_href + '">' + param.f_label + '</a>');
	Editor.window.focus();
	//Editor.document.body.focus();
	break;
    case 'bold':
    case 'italic':
	this.fullwordSelection();
	// cmd is bold, italic, etc
	d.execCommand(cmd,false,null);
	break;
    case 'highlight':
	d.execCommand();
	break;
    case 'toggle_mode':
	Editor.toggleMode();
	break;
    default:
	xo.log('unknown command');
    };
};

Editor.makeToolbar = function(iframeEl) {
    var toolbarEl = xo.DomHelper.insertBefore(iframeEl, {
	    'tag':'div',
	    'width':400,
	    'height':20,
	    'id':'mytoolbar',
	    'cn':[{
		    'id':'tb_bold',
		    'tag':'button',
		    'html':'B'
		},{
		    'id':'tb_italic',
		    'tag':'button',
		    'html':'I'
		},{
		    'id':'tb_highlight',
		    'tag':'button',
		    'html':'Highlight'
		},{
		    'id':'tb_link',
		    'tag':'button',
		    'html':'Link'
		},{
		    'id':'tb_hr',
		    'tag':'button',
		    'html':'HR'
		},{
		    'id':'tb_ul',
		    'tag':'button',
		    'html':'UL',
		    'cmd':'ul'
		},{
		    'id':'tb_toggle_mode',
		    'tag':'button',
		    'html':'view source'
		}]
	});

    xo.Event.on('tb_bold','click',Editor.handleCommand,this,{cmd:'bold'});
    xo.Event.on('tb_italic','click',Editor.handleCommand,this,{cmd:'italic'});
    xo.Event.on('tb_highlight','click',Editor.handleCommand,this,{cmd:'highlight'});
    xo.Event.on('tb_link','click',Editor.handleCommand,this,{cmd:'link'});
    xo.Event.on('tb_hr','click',Editor.handleCommand,this,{cmd:'hr'});
    xo.Event.on('tb_ul','click',Editor.handleCommand,this,{cmd:'ul'});
    xo.Event.on('tb_toggle_mode','click',Editor.handleCommand,this,{cmd:'toggle_mode'});
};

Editor.updateToolbar = function(){

    var sel = Editor.getSelection();
    var range = Editor.createRange(sel);

    var fan = Editor.getFirstAncestor(range,['a']);
    if (fan) {
	xo.log('show link tooltip');
    }
};

// TODO: replace id with config
Editor.init = function(id){

    xo.log('ua:'+xo.userAgent);
    // xo.log('gecko:'+xo.isGecko);
    xo.log('strict:'+xo.isStrict);
    //xo.log('secure:'+xo.isSecure);


    var textareaEl = $(id);

    if (!textareaEl) {
	return;
    }

    Editor.hide(textareaEl);

    var iframeEl = xo.DomHelper.insertBefore(textareaEl, {
	    'tag':'iframe',
	    'width':400,
	    'height':200,
	    'id':'myeditor'
	});

    Editor.makeToolbar(iframeEl);

    var doc = iframeEl.contentWindow.document;
    doc.designMode = "on";
    /* IE6 */
    doc = iframeEl.contentWindow.document;

    var emptyDoc = ''
    emptyDoc += '<!DOCTYPE HTML>';
    emptyDoc += '<html><head></head>';
    emptyDoc += '<body>';
    emptyDoc += '</body>';
    emptyDoc += '</html>';

    doc.open("text/html","replace");
    doc.write(emptyDoc);
    doc.close();

    /* setup some context variables */
    Editor.iframeEl=iframeEl;
    Editor.textareaEl=textareaEl;
    Editor.window=iframeEl.contentWindow;
    Editor.document=doc;
    Editor.setMode(Editor.HTML);

    xo.Event.on(Editor.document,'keydown',Editor.handleKey);

    Editor.window.focus();


};

Editor.TEXT = 0;
Editor.HTML = 1;

Editor.toggleMode = function() {
    xo.log('current mode:'+Editor.mode);
    if (Editor.mode == Editor.TEXT) {
	Editor.setMode(Editor.HTML);
    } else {
	Editor.setMode(Editor.TEXT);
    }
};

Editor.setMode = function(mode) {
    if (mode == Editor.TEXT) {
	Editor.textareaEl.value= Editor.HtmlToStx(Editor.document.body.innerHTML);
	Editor.hide(Editor.iframeEl);
	Editor.show(Editor.textareaEl);
	$('tb_toggle_mode').innerHTML = 'toggle mode (text->design)';
    } else if (mode == Editor.HTML) {
	Editor.document.body.innerHTML = Editor.StxToHtml(Editor.textareaEl.value);
	Editor.hide(Editor.textareaEl);
	Editor.show(Editor.iframeEl);
	$('tb_toggle_mode').innerHTML = 'toggle mode (design->text)';
    }
    Editor.mode = mode;
    xo.log('new mode:'+mode);
}

xo.exportSymbol("Editor",Editor);
xo.exportProperty(Editor,"init",Editor.init);


