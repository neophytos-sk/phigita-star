/* Word Status Constants */
var RTSS_UNKNOWN_WORD = 0; // Not yet checked
var RTSS_VALID_WORD   = 1; // Valid word (confirmed by server)
var RTSS_INVALID_WORD = 2; // Invalid word (confirmed by server)
var RTSS_PENDING_WORD = 3; // In queue


/*----------------------------------------------------------------------------\
|                          Global Spell Check Handler                         |
\----------------------------------------------------------------------------*/

var webFXSpellCheckHandler = {
	activeRequest: false,
	words        : new Array(),
	pending      : new Array(),
	activeWord   : null,
	instances    : new Array(),
	serverURI    : '/spell.cgi', // http://me.eae.net/stuff/spellchecker/spell.cgi
	invalidWordBg: 'red',        // url(http://me.eae.net/stuff/spellchecker/images/redline.png) repeat-x bottom
	httpMethod   : 'POST',       // GET or POST
	httpParamSep : ';',          // Use ampersand ('&') for PHP backend (default configuration doesn't support semicolon separator)
	wordsPerReq  : 100
};

/*----------------------------------------------------------------------------\
|                               Static Methods                                |
\----------------------------------------------------------------------------*/

webFXSpellCheckHandler._init = function() {
	var menu, inner, item;

	menu = document.createElement('div');
	menu.id = 'webfxSpellCheckMenu';
	menu.className = 'webfx-spellchecker-menu';
	menu.style.display = 'none';

	inner = document.createElement('div');
	inner.className = 'inner';
	menu.appendChild(inner);

	item = document.createElement('div');
	item.className = 'separator';
	inner.appendChild(item);

	item = document.createElement('a');
	item.href = 'javascript:webFXSpellCheckHandler._ignoreWord();'
	item.appendChild(document.createTextNode('Ignore'));
	inner.appendChild(item);

	document.body.appendChild(menu);
};


webFXSpellCheckHandler._spellCheck = function(word) {
	if (webFXSpellCheckHandler.words[word]) { return webFXSpellCheckHandler.words[word][0]; }
	webFXSpellCheckHandler.words[word] = [RTSS_PENDING_WORD];
	webFXSpellCheckHandler.pending.push(word);
	if (!webFXSpellCheckHandler.activeRequest) { window.setTimeout('webFXSpellCheckHandler._askServer()', 10); }

	return RTSS_PENDING_WORD;
};

webFXSpellCheckHandler._askServer = function() {
	var i, len, uri, arg, word, aMap, xmlHttp;
	var async = true;

	if (webFXSpellCheckHandler.activeRequest) { return; }
	arg = '';
	len = webFXSpellCheckHandler.pending.length;
	if (len) {
		webFXSpellCheckHandler.activeRequest = true;
		aMap = new Array();

		if (len > webFXSpellCheckHandler.wordsPerReq) { len = webFXSpellCheckHandler.wordsPerReq; }
		for (i = 0; i < len; i++) {

			word = webFXSpellCheckHandler.pending.shift();

			arg += ((i)?webFXSpellCheckHandler.httpParamSep:'') + i + '=' + word;
			webFXSpellCheckHandler.words[word] = [RTSS_PENDING_WORD];
			aMap[i] = word;
		}
		if (webFXSpellCheckHandler.httpMethod == 'GET') {
			uri = webFXSpellCheckHandler.serverURI + '?' + arg;
			arg = '';
		}
		else { uri = webFXSpellCheckHandler.serverURI; }

		if (window.XMLHttpRequest) {
			xmlHttp = new XMLHttpRequest();
			xmlHttp.onload = function() {
				webFXSpellCheckHandler._serverResponseHandler(xmlHttp.responseText, aMap);
			};
		}
		else if (window.ActiveXObject) {
			xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
			if (!xmlHttp) { return; }
			xmlHttp.onreadystatechange = function() {
				if (xmlHttp.readyState == 4) {
					webFXSpellCheckHandler._serverResponseHandler(xmlHttp.responseText, aMap);
				}
	  	};
		}
		xmlHttp.open(webFXSpellCheckHandler.httpMethod, uri, async);
  	xmlHttp.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
  	xmlHttp.setRequestHeader("Content-Length", arg.length);
  	xmlHttp.send(arg);
}	};


webFXSpellCheckHandler._serverResponseHandler = function(sData, aMap) {
	var i, flag, len, data, word, suggestions;
	try {
		eval(sData);
	}
	catch (oe) { return; }
	len = data.length;
	for (i = 0; i < len; i++) {
		flag = data[i][0];
		word = aMap[i];
		suggestions = data[i][1];
		if (!webFXSpellCheckHandler.words[word]) {
			return;
		}
		switch (flag) {
			case 0:
				webFXSpellCheckHandler.words[word][0] = RTSS_INVALID_WORD;
				webFXSpellCheckHandler.words[word][1] = suggestions;
				break;
			case 1:
				webFXSpellCheckHandler.words[word][0] = RTSS_VALID_WORD;
				break;
		};
	}
	webFXSpellCheckHandler.activeRequest = false;
	webFXSpellCheckHandler._updateWords();
	if (webFXSpellCheckHandler.pending.length) { webFXSpellCheckHandler._askServer(); }
};


webFXSpellCheckHandler._updateWords = function() {
	var aNodes, i, n, len, eInstance, ow;
	
	for (n = 0; n < webFXSpellCheckHandler.instances.length; n++) {
		aNodes = webFXSpellCheckHandler.instances[n].elCont.getElementsByTagName('span');
		len = aNodes.length;
		for (i = 0; i < len; i++) {
			if (aNodes[i].childNodes.length != 1) { continue; }
			if (aNodes[i].firstChild.nodeType != 3) { continue; }
			ow = webFXSpellCheckHandler.words[aNodes[i].firstChild.nodeValue];
			if (!ow) { continue; }
			switch (ow[0]) {
				case RTSS_VALID_WORD:
				case RTSS_PENDING_WORD: aNodes[i].style.background = 'none';                               break;
				case RTSS_INVALID_WORD: aNodes[i].style.background = webFXSpellCheckHandler.invalidWordBg; break;
			};
}	}	};

webFXSpellCheckHandler._showSuggestionsMenu = function(e, el, word, instance) {
	var menu, len, item, sep, frame, aSuggestions, doc, x, y, o;

	if (!webFXSpellCheckHandler.words[word]) { return; }

	menu = document.getElementById('webfxSpellCheckMenu');
	len = menu.firstChild.childNodes.length;
	while (len > 2) { menu.firstChild.removeChild(menu.firstChild.firstChild); len--; }
	sep = menu.firstChild.firstChild;

	aSuggestions = webFXSpellCheckHandler.words[word][1];
	len = aSuggestions.length;
	if (len > 10) { len = 10; }
	for (i = 0; i < len; i++) {
		item = document.createElement('a');
		item.href = 'javascript:webFXSpellCheckHandler._replaceWord(' + instance + ', "' + aSuggestions[i] + '");'
		item.appendChild(document.createTextNode(aSuggestions[i]));
		menu.firstChild.insertBefore(item, sep);
	}
	if (len == 0) {
		item = document.createElement('a');
		item.href = 'javascript:void(0);'
		item.appendChild(document.createTextNode('No suggestions'));
		menu.firstChild.insertBefore(item, sep);
	}

	var n;
	for (n = 0; n < webFXSpellCheckHandler.instances.length; n++) {
		if (webFXSpellCheckHandler.instances[n].doc == el.ownerDocument) {
			frame = webFXSpellCheckHandler.instances[n].el;
			doc   = webFXSpellCheckHandler.instances[n].doc;
	}	}

	x = 0; y = 0;
	for (o = frame; o; o = o.offsetParent) {
		x += (o.offsetLeft - o.scrollLeft);
		y += (o.offsetTop - o.scrollTop);
	}

	if (document.all) {
		menu.style.left = x + (e.pageX || e.clientX) + 'px';
		menu.style.top  = y + (e.pageY || e.clientY) + (el.offsetHeight/2) + 'px';
	}
	else {
		menu.style.left = x + ((e.pageX || e.clientX) - document.body.scrollLeft) + 'px';
		menu.style.top  = y + ((e.pageY || e.clientY) - document.body.scrollTop) + (el.offsetHeight/2) + 'px';
	}
	menu.style.display = 'block';

	webFXSpellCheckHandler.activeWord = word;
};


webFXSpellCheckHandler._replaceWord = function(instance, word) {
	var o, sel, r;
	
	o = webFXSpellCheckHandler.instances[instance];
	if (o) {
		o.self.replaceActive(word);
	}
	
	webFXSpellCheckHandler._hideSuggestionsMenu();
};


webFXSpellCheckHandler._ignoreWord = function() {
	var word, i, len, o;
	
	word = webFXSpellCheckHandler.activeWord;
	
	if (word) {
		webFXSpellCheckHandler.words[word][0] = RTSS_VALID_WORD;
		webFXSpellCheckHandler.words[word][1] = [];
		
		len = webFXSpellCheckHandler.instances.length;
		for (i = 0; i < len; i++) {
			o = webFXSpellCheckHandler.instances[i];
			o.self.rescan();
		}
	}
	
	webFXSpellCheckHandler._hideSuggestionsMenu();
};


webFXSpellCheckHandler._hideSuggestionsMenu = function() {
	document.getElementById('webfxSpellCheckMenu').style.display = 'none';
	webFXSpellCheckHandler.activeWord = null;
};
