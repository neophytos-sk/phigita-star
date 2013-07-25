
function StructuredText(editor) 
{
	this.textarea = editor;
}

/*
	isSpace(ch)
	Returns true if ch is a space character (space, enter, tab)
*/
function isSpace(ch) {
	stopchars = " \t\n\r";
	if (stopchars.indexOf(ch) != -1)
		return true;
	if (ch.charCodeAt(0) == 160)
		return true;
	return false;
}

/*
	isStopChar(ch)
	Returns true if ch is a stop character (space, enter, tab, comma, dot etc)
*/
function isStopChar(ch) {
	stopchars = " \t\n\r.,;?";
	if (stopchars.indexOf(ch) != -1)
		return true;
	if (ch.charCodeAt(0) == 160)
		return true;
	return false;
	
	/*if (ch == " " || ch == "\t" || ch == "\n" || ch == "\r" || ch.charCodeAt(0) == 160)
		return true;
	return false;*/
}

/*
	getStxTag(htmlTag)
	Returns the beginning and ending structured text symbol
*/
function getStxTag(htmlTag) {
	
	stxTags_b = new Array();	//stx begin symbols
	stxTags_e = new Array();	//std end symbols

	stxTags_b['strong'] = stxTags_b['b'] = " **";
	stxTags_e['strong'] = stxTags_e['b'] = "**";
	stxTags_b['em'] = stxTags_b['i'] = " *";
	stxTags_e['em'] = stxTags_e['i'] = "*";
	stxTags_b['u'] = " _";
	stxTags_e['u'] = "_";
	stxTags_b['p'] = "\n\n";
	stxTags_e['p'] = "";
	stxTags_b['pre'] = "\n\n::\n\n";
	stxTags_e['pre'] = "";
	stxTags_b['code'] = "\n\n%%\n\n";
	stxTags_e['code'] = "";
	stxTags_b['h6'] = "\n\n%%\n\n";
	stxTags_e['h6'] = "";
	stxTags_b['li'] = "\n\n-";
	stxTags_e['li'] = "";
	stxTags_b['hr'] = "\n\n-----";
	stxTags_e['hr'] = "";
	stxTags_b['h1'] = "\n\n==";
	stxTags_e['h1'] = "==";
	stxTags_b['h2'] = "\n\n===";
	stxTags_e['h2'] = "===";
	stxTags_b['h3'] = "\n\n====";
	stxTags_e['h3'] = "====";
	stxTags_b['br'] = "\n\n";
	stxTags_e['br'] = "";
	stxTags_b['font'] = " ''";
	stxTags_e['font'] = "'' ";
	stxTags_b['span'] = " ''";
	stxTags_e['span'] = "'' ";
	stxTags_b['a'] = ' "';
	stxTags_e['a'] = '":';

	//create object symbol (.begin,.end)
	function symbol () {}
	symbol.begin = "";
	symbol.end = "";
	
	//search for the right tag
	for (var tag in stxTags_b)
		if (tag == htmlTag)
		{
			symbol.begin = stxTags_b[tag];
			symbol.end = stxTags_e[tag];
			return symbol;
		}
	return symbol;
}

function trimString(str) {
	var i,j;
	for (i = 0; i < str.length; i++)
		if (!isSpace(str[i]))
			break;
	for (j = str.length-1; j >= 0; j--)
		if (!isSpace(str[j]))
			break;
	return str.substring(i,j+1);
}


function parseNode(node, mode, list, indent)
{
	if (!node)
		return "";
		
	//return text if text node
	if (node.nodeType == Node.TEXT_NODE)
		return node.textContent;

	//get stx symbol
	var tag = node.tagName.toLowerCase();
	var symbol = getStxTag(tag);

	//list items
	//saves the list type for use in descendant nodes
	if (tag == "ol")
		list = "ol";
	else if (tag == "ul")
		list = "ul";

	if (tag == "p" || tag == "pre" || tag =="h6")
		mode = tag;
	
	//changes symbol for ordered lists <li> --> #
	if (tag == "li" && list == "ol")
	{
		symbol.begin = "\n\n#";
		symbol.end = "";
	}

	//br
	if (tag == "br")
		if (mode == "pre" || mode == "h6")
			symbol.begin = "\n";
		else if (mode == "p")
			symbol.begin = "";
		
	
	//-----producing return text-------//
	
	var text = "";
	text += symbol.begin;
	
	/* indent */
	if (tag == "p") //paragraph has no indent
	{	text += indent; }
	if (tag == "pre" || tag == "h6" || tag == "li") //pre and code have 1 space indent
	{	indent += " "; text += indent; }
	else if (tag == "br") //puts the indent in case of <br>
		text += indent;
	
	//get stx text of child nodes
	var txt = "";
	for (var i = 0; i < node.childNodes.length; i++)
		txt += parseNode(node.childNodes[i],mode,list,indent);
	
	if (txt != "" || tag == "br" || tag == "hr") // to avoid empty tags
	{
		//alert(tag);
		//alert(symbol.end);
		if (tag == "ul" || tag == "ol" || tag == "frame")
			text += txt + symbol.end;
		else
			text += trimString(txt) + symbol.end;
		//links
		if (tag == "a")
		{
			if (!node.getAttribute("href")) // in case of empty link
				text += "http://www.phigita.net";
			else
				text += node.getAttribute("href");
		}
	}
	else
		text = "";
	
	//alert("text : " + text);
	return text;
}


/*
	getStxFromHtml
	Get a string that contains html text and converts it into structured text
*/
HTMLArea.prototype.getStxFromHtml = function(html) {
	var obj = document.createElement('frame');
	//html = html.replace("\n","","gi");
	obj.innerHTML = html;
	result = parseNode(obj,"","","");
	return result;
};




HTMLArea.prototype.fullwordSelection = function (spaces)  {

	var sel = this._getSelection();
	if (sel.toString().length > 0)
	{

		var range = this._createRange(sel);
		//avoid the problem with the wrong start container
		if (range.toString() == range.endContainer.nodeValue)
			range.setStart(range.endContainer,0);
	

		// ----- expand to the left -----
		while (!isStopChar(range.toString().charAt(0))) 
		{
			try { range.setStart(range.startContainer,range.startOffset-1); }
			catch (exx) { break; }
		} 
		if (isStopChar(range.toString().charAt(0)))
		{	
			try { range.setStart(range.startContainer,range.startOffset+1); }
			catch (exx) { };
		}

		if (spaces == true) //expand left to cover all spaces
		{
			do {
				try { range.setStart(range.startContainer,range.startOffset-1); }
				catch (exx) { break; }
			} while (isStopChar(range.toString().charAt(0)));
			
			if (range.startOffset != 0 && !isStopChar(range.toString().charAt(0)))
				range.setStart(range.startContainer,range.startOffset+1);
		}

		// ----- expand to the right -----
		var s = range.toString();
		while (!isStopChar(s[s.length-1])) {
			try { range.setEnd(range.endContainer,range.endOffset+1); }
			catch (exx) { break; }
			s = range.toString();
		}
		if (isStopChar(s[s.length-1]))
			range.setEnd(range.endContainer,range.endOffset-1);
		
		if (spaces == true) //expand right to cover all spaces
		{
			do {
				try { range.setEnd(range.endContainer,range.endOffset+1); }
				catch (exx) { break; }
				s = range.toString();
			} while (isStopChar(s[s.length-1]));
				
		if (range.endOffset != range.endContainer.length && !isStopChar(s[s.length-1]))
			range.setEnd(range.endContainer,range.endOffset-1);
		}
	}
};


StructuredText._pluginInfo = {
	name          : "StructuredText",
	version       : "1.0",
	developer     : "Avgoustinos Kadis",
	developer_url : "http://www.phigita.net/~avgoustinos",
	c_owner       : "Neophytos Demetriou",
	sponsor       : "Phigita.net Inc",
	sponsor_url   : "http://www.phigita.net",
	license       : "htmlArea"
};

StructuredText.prototype._lc = function(string) {
    return HTMLArea._lc(string, 'StructuredText');
};