/*
 * CodePress - Real Time Syntax Highlighting Editor written in JavaScript - http://codepress.fermads.net/
 * 
 * Copyright (C) 2006 Fernando M.A.d.S. <fermads@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify it under the terms of the 
 * GNU Lesser General Public License as published by the Free Software Foundation.
 * 
 * Read the full licence: http://www.opensource.org/licenses/lgpl-license.php
 */

CodePress = {
	range : null,
	language : null,
	scrolling : false,
	
	// set initial vars and start sh
	initialize : function() {
		if(typeof(editor)=='undefined'&&!arguments[0]) return;
		this.detect();
		chars = '|13|32|191|57|48|187|188|'; // charcodes that trigger syntax highlighting
		cc = '\u2009'; // control char
		if(browser.ff) {
			editor = document.getElementById('ffedt');
			document.designMode = 'on';
			document.addEventListener('keydown', this.keyHandler, true);
			window.addEventListener('scroll', function() { if(!CodePress.scrolling) CodePress.syntaxHighlight('scroll') }, false);
		}
		else if(browser.ie) {
			editor = document.getElementById('ieedt');
			editor.contentEditable = 'true';
			document.attachEvent('onkeydown', this.keyHandler);
			window.attachEvent('onscroll', function() { if(!CodePress.scrolling) CodePress.syntaxHighlight('scroll') });
		}
		else {
			// TODO: textarea without syntax highlighting for non supported browsers
			alert('your browser is not supported at the moment');
			return;
		}
		this.syntaxHighlight('init');
		setTimeout(function() { window.scroll(0,0) },50); // scroll IE to top
	},

	// detect browser, for now IE and FF
	detect : function() {
		browser = { ie:false, ff:false };
		if(navigator.appName.indexOf("Microsoft") != -1) browser.ie = true;
		else if(navigator.appName == "Netscape") browser.ff = true;
	},

	// treat key bindings
	keyHandler : function(evt) {
		evt = (evt) ? evt : (window.event) ? event : null;
	  	if(evt) {
	    	charCode = (evt.charCode) ? evt.charCode : ((evt.keyCode) ? evt.keyCode : ((evt.which) ? evt.which : 0));

			if((charCode==34||charCode==33)&&browser.ie) { // handle page up/down for IE
				parent.codepress.scrollBy(0, (charCode==34) ? 200 : -200); 
				evt.returnValue = false;
			}
		    if((chars.indexOf('|'+charCode+'|')!=-1) && (!evt.ctrlKey && !evt.altKey)) { // syntax highlighting
			 	CodePress.syntaxHighlight('generic');
			}
			else if(charCode==46||charCode==8) { // save to history when delete or backspace pressed
			 	CodePress.actions.history[CodePress.actions.next()] = editor.innerHTML;
			}
			else if((charCode==90||charCode==89) && evt.ctrlKey) { // undo and redo
				(charCode==89||evt.shiftKey) ? CodePress.actions.redo() : CodePress.actions.undo() ;
				evt.returnValue = false;
				if(browser.ff)evt.preventDefault();
			}
			else if(charCode==86 && evt.ctrlKey)  { // paste
				// TODO: pasted text should be parsed and highlighted
			}
		}
	},

	// put cursor back to its original position after every parsing
	findString : function() {
		if(browser.ff) {
			if(self.find(cc))
				window.getSelection().getRangeAt(0).deleteContents();
		}
		else if(browser.ie) {
		    range = self.document.body.createTextRange();
			if(range.findText(cc)){
				range.select();
				range.text = '';
			}
		}
	},
	
	// split big files, highlighting parts of it
	split : function(code,flag) {
		if(flag=='scroll') {
			this.scrolling = true;
			return code;
		}
		else {
			this.scrolling = false;
			mid = code.indexOf(cc);
			if(mid-2000<0) {ini=0;end=4000;}
			else if(mid+2000>code.length) {ini=code.length-4000;end=code.length;}
			else {ini=mid-2000;end=mid+2000;}
			code = code.substring(ini,end);
			if(browser.ff) return code;
			else return code.substring(code.indexOf('<P>'),code.lastIndexOf('</P>')+4);
		}
	},
	
	// syntax highlighting parser
	syntaxHighlight : function(flag) {
		if(browser.ff) {
			if(flag!='init') window.getSelection().getRangeAt(0).insertNode(document.createTextNode(cc));
			o = editor.innerHTML;
			o = o.replace(/<br>/g,'\n');
			o = o.replace(/<.*?>/g,'');
			x = z = this.split(o,flag);
			x = x.replace(/\n/g,'<br>');
		}
		else if(browser.ie) {
			if(flag!='init') document.selection.createRange().text = cc;
			o = editor.innerHTML;
			o = o.replace(/<P>/g,'\n');
			o = o.replace(/<\/P>/g,'\r');
			o = o.replace(/<.*?>/g,'');
			o = o.replace(/&nbsp;/g,'');			
			o = '<PRE><P>'+o+'</P></PRE>';
			o = o.replace(/\n/g,'<P>');
			o = o.replace(/\r/g,'<\/P>');
			o = o.replace(/<P>(<P>)+/,'<P>');
			o = o.replace(/<\/P>(<\/P>)+/,'</P>');
			o = o.replace(/<P><\/P>/g,'<P><BR /><\/P>');
			x = z = this.split(o,flag);
		}

		for(i=0;i<syntax.length;i+=2) 
			x = x.replace(syntax[i],syntax[i+1]);

		editor.innerHTML = this.actions.history[this.actions.next()] = (flag=='scroll') ? x : o.replace(z,x);

		if(flag!='init') this.findString();
	},

	// undo and redo methods
	actions : {
		pos : -1, // actual history position
		history : [], // history vector
		
		undo : function() {
			if(editor.innerHTML.indexOf(cc)==-1){
				if(browser.ff) window.getSelection().getRangeAt(0).insertNode(document.createTextNode(cc));
				else document.selection.createRange().text = cc;
			 	this.history[this.pos] = editor.innerHTML;
			}
			this.pos--;
			if(typeof(this.history[this.pos])=='undefined') this.pos++;
			editor.innerHTML = this.history[this.pos];
			CodePress.findString();
		},
		
		redo : function() {
			this.pos++;
			if(typeof(this.history[this.pos])=='undefined') this.pos--;
			editor.innerHTML = this.history[this.pos];
			CodePress.findString();
		},
		
		next : function() { // get next vector position and clean old ones
			if(this.pos>20) this.history[this.pos-21] = undefined;
			return ++this.pos;
		}
	},	
	
	// transform syntax highlighted code to original code
	getCode : function() {
		code = editor.innerHTML;
		code = code.replace(/<br>/g,'\n');
		code = code.replace(/<\/p>/gi,'\r');
		code = code.replace(/<p>/i,''); // IE first line fix		
		code = code.replace(/<p>/gi,'\n');
		code = code.replace(/&nbsp;/gi,'');
		code = code.replace(/\u2009/g,'');
		code = code.replace(/<.*?>/g,'');
		code = code.replace(/&lt;/g,'<');
		code = code.replace(/&gt;/g,'>');
		code = code.replace(/&amp;/gi,'&');
		return code;
	},

	// put some code inside editor
	setCode : function() {
		if(typeof(arguments[1])=='undefined') {
			language = top.document.getElementById(arguments[0]).lang.toLowerCase();
			code = top.document.getElementById(arguments[0]).value;
		} 
		else {
			language = arguments[0];
			code = arguments[1];
		}
		//document.designMode = 'off';
	   	//head = document.getElementsByTagName('head')[0];
	   	//script = document.createElement('script');
	   	//script.type = 'text/javascript';
	   	//script.src = '/resources/codepress/languages/codepress-'+language+'.js';
		//head.appendChild(script)
		//document.getElementById('cp-lang-style').href = '/resources/codepress/languages/codepress-'+language+'.css';
		code = code.replace(/\u2009/gi,'');
		code = code.replace(/&/gi,'&amp;');		
       	code = code.replace(/</g,'&lt;');
        code = code.replace(/>/g,'&gt;');
		editor.innerHTML = "<pre>"+code+"</pre>";
		this.language = language;
	}
}


/*
onload = function() {
	cpWindow = top.document.getElementById('codepress');
	if(cpWindow!=null) {
		cpWindow.style.border = '1px solid gray';
		cpWindow.style.frameBorder = '0';
	}
	
	top.CodePress = CodePress;
	CodePress.initialize('new');
	
	cpOnload = top.document.getElementById('codepress-onload');
	cpOndemand = top.document.getElementById('codepress-ondemand');
	
	if(cpOnload!=null) {
		cpOnload.style.display = 'none';
		cpOnload.id = 'codepress-loaded';
		CodePress.setCode('codepress-loaded');
	}
	if(cpOndemand!=null) cpOndemand.style.display = 'none';
}
*/
/*
 * CodePress regular expressions for JavaScript syntax highlighting
 */
 
syntax = [ // JavaScript
	/\"(.*?)(\"|<br>|<\/P>)/g,'<s>"$1$2</s>', // strings double quote
	/\'(.*?)(\'|<br>|<\/P>)/g,'<s>\'$1$2</s>', // strings single quote
	/\b(break|continue|do|for|new|this|void|case|default|else|function|return|typeof|while|if|label|switch|var|with|catch|boolean|int|try|false|throws|null|true|goto)\b/g,'<b>$1</b>', // reserved words
	/\b(alert|isNaN|parent|Array|parseFloat|parseInt|blur|clearTimeout|prompt|prototype|close|confirm|length|Date|location|Math|document|element|name|self|elements|setTimeout|navigator|status|String|escape|Number|submit|eval|Object|event|onblur|focus|onerror|onfocus|onclick|top|onload|toString|onunload|unescape|open|valueOf|window|onmouseover)\b/g,'<u>$1</u>', // special words
	/([^:]|^)\/\/(.*?)(<br|<\/P)/g,'$1<i>//$2</i>$3', // comments //
	/\/\*(.*?)\*\//g,'<i>/*$1*/</i>' // comments /* */
];

CodePress.initialize();


/*
 * CodePress regular expressions for Java syntax highlighting
 */
 
syntax = [ // Java
	/\"(.*?)(\"|<br>|<\/P>)/g,'<s>"$1$2</s>', // strings double quote
	/\'(.*?)(\'|<br>|<\/P>)/g,'<s>\'$1$2</s>', // strings single quote
	/\b(abstract|continue|for|new|switch|assert|default|goto|package|synchronized|boolean|do|if|private|this|break|double|implements|protected|throw|byte|else|import|public|throws|case|enum|instanceof|return|transient|catch|extends|int|short|try|char|final|interface|static|void|class|finally|long|strictfp|volatile|const|float|native|super|while)\b/g,'<b>$1</b>', // reserved words
	/([^:]|^)\/\/(.*?)(<br|<\/P)/g,'$1<i>//$2</i>$3', // comments //	
	/\/\*(.*?)\*\//g,'<i>/*$1*/</i>' // comments /* */
];

CodePress.initialize();


/*
 * CodePress regular expressions for SQL syntax highlighting
 * By Merlin Moncure
 */
 
syntax = [ // SQL
	/\'(.*?)(\')/g,'<s>\'$1$2</s>', // strings single quote
	/\b(add|after|aggregate|alias|all|and|as|authorization|between|by|cascade|cache|cache|called|case|check|column|comment|constraint|createdb|createuser|cycle|database|default|deferrable|deferred|diagnostics|distinct|domain|each|else|elseif|elsif|encrypted|except|exception|for|foreign|from|from|full|function|get|group|having|if|immediate|immutable|in|increment|initially|increment|index|inherits|inner|input|intersect|into|invoker|is|join|key|language|left|limit|local|loop|match|maxvalue|minvalue|natural|nextval|no|nocreatedb|nocreateuser|not|null|of|offset|oids|on|only|operator|or|order|outer|owner|partial|password|perform|plpgsql|primary|record|references|replace|restrict|return|returns|right|row|rule|schema|security|sequence|session|sql|stable|statistics|table|temp|temporary|then|time|to|transaction|trigger|type|unencrypted|union|unique|user|using|valid|value|values|view|volatile|when|where|with|without|zone)\b/gi,'<b>$1</b>', // reserved words
	/\b(bigint|bigserial|bit|boolean|box|bytea|char|character|cidr|circle|date|decimal|double|float4|float8|inet|int2|int4|int8|integer|interval|line|lseg|macaddr|money|numeric|oid|path|point|polygon|precision|real|refcursor|serial|serial4|serial8|smallint|text|timestamp|varbit|varchar)\b/gi,'<u>$1</u>', // types
	/\b(abort|alter|analyze|begin|checkpoint|close|cluster|comment|commit|copy|create|deallocate|declare|delete|drop|end|execute|explain|fetch|grant|insert|listen|load|lock|move|notify|prepare|reindex|reset|restart|revoke|rollback|select|set|show|start|truncate|unlisten|update)\b/gi,'<a>$1</a>', // commands
	/([^:]|^)\-\-(.*?)(<br|<\/P)/g,'$1<i>--$2</i>$3', // comments //	
];

CodePress.initialize();


/*
 * CodePress regular expressions for PHP syntax highlighting
 */

syntax = [ // PHP
	/(&lt;[^!\?]*?&gt;)/g,'<b>$1</b>', // all tags
	/(&lt;style.*?&gt;)(.*?)(&lt;\/style&gt;)/g,'<em>$1</em><em>$2</em><em>$3</em>', // style tags
	/(&lt;script.*?&gt;)(.*?)(&lt;\/script&gt;)/g,'<ins>$1</ins><ins>$2</ins><ins>$3</ins>', // script tags
	/\"(.*?)(\"|<br>|<\/P>)/g,'<s>"$1$2</s>', // strings double quote
	/\'(.*?)(\'|<br>|<\/P>)/g,'<s>\'$1$2</s>', // strings single quote
	/(&lt;\?)/g,'<strong>$1', // <?.*
	/(\?&gt;)/g,'$1</strong>', // .*?>
	/(&lt;\?php|&lt;\?=|&lt;\?|\?&gt;)/g,'<cite>$1</cite>', // php tags		
	/(\$[\w\.]*)/g,'<a>$1</a>', // vars
	/\b(false|true|and|or|xor|__FILE__|exception|__LINE__|array|as|break|case|class|const|continue|declare|default|die|do|echo|else|elseif|empty|enddeclare|endfor|endforeach|endif|endswitch|endwhile|eval|exit|extends|for|foreach|function|global|if|include|include_once|isset|list|new|print|require|require_once|return|static|switch|unset|use|while|__FUNCTION__|__CLASS__|__METHOD__|final|php_user_filter|interface|implements|extends|public|private|protected|abstract|clone|try|catch|throw|this)\b/g,'<u>$1</u>', // reserved words
	/([^:])\/\/(.*?)(<br|<\/P)/g,'$1<i>//$2</i>$3', // php comments //
	/\/\*(.*?)\*\//g,'<i>/*$1*/</i>', // php comments /* */
	/(&lt;!--.*?--&gt.)/g,'<big>$1</big>' // html comments 
];

CodePress.initialize();


/*
 * CodePress regular expressions for CSS syntax highlighting
 */

syntax = [ // CSS
	/(.*?){(.*?)}/g,'<b>$1</b>{<u>$2</u>}', // tags, ids, classes, values
	/([\w-]*?):([^\/])/g,'<a>$1</a>:$2', // keys
	/\((.*?)\)/g,'(<s>$1</s>)', // parameters
	/\/\*(.*?)\*\//g,'<i>/*$1*/</i>', // comments
];

CodePress.initialize();


/*
 * CodePress regular expressions for Perl syntax highlighting
 * By J. Nick Koston
 */

syntax = [ // Perl
	/\"(.*?)(\"|<br>|<\/P>)/g,'<s>"$1$2</s>', // strings double quote
	/\'(.*?)(\'|<br>|<\/P>)/g,'<s>\'$1$2</s>', // strings single quote
    /([\$\@\%]+)([\w\.]*)/g,'<a>$1$2</a>', // vars
    /(sub\s+)([\w\.]*)/g,'$1<em>$2</em>', // functions
    /\b(abs|accept|alarm|atan2|bind|binmode|bless|caller|chdir|chmod|chomp|chop|chown|chr|chroot|close|closedir|connect|continue|cos|crypt|dbmclose|dbmopen|defined|delete|die|do|dump|each|else|elsif|endgrent|endhostent|endnetent|endprotoent|endpwent|eof|eval|exec|exists|exit|fcntl|fileno|find|flock|for|foreach|fork|format|formlinegetc|getgrent|getgrgid|getgrnam|gethostbyaddr|gethostbyname|gethostent|getlogin|getnetbyaddr|getnetbyname|getnetent|getpeername|getpgrp|getppid|getpriority|getprotobyname|getprotobynumber|getprotoent|getpwent|getpwnam|getpwuid|getservbyaddr|getservbyname|getservbyport|getservent|getsockname|getsockopt|glob|gmtime|goto|grep|hex|hostname|if|import|index|int|ioctl|join|keys|kill|last|lc|lcfirst|length|link|listen|LoadExternals|local|localtime|log|lstat|map|mkdir|msgctl|msgget|msgrcv|msgsnd|my|next|no|oct|open|opendir|ordpack|package|pipe|pop|pos|print|printf|push|pwd|qq|quotemeta|qw|rand|read|readdir|readlink|recv|redo|ref|rename|require|reset|return|reverse|rewinddir|rindex|rmdir|scalar|seek|seekdir|select|semctl|semget|semop|send|setgrent|sethostent|setnetent|setpgrp|setpriority|setprotoent|setpwent|setservent|setsockopt|shift|shmctl|shmget|shmread|shmwrite|shutdown|sin|sleep|socket|socketpair|sort|splice|split|sprintf|sqrt|srand|stat|stty|study|sub|substr|symlink|syscall|sysopen|sysread|system|syswritetell|telldir|tie|tied|time|times|tr|truncate|uc|ucfirst|umask|undef|unless|unlink|until|unpack|unshift|untie|use|utime|values|vec|waitpid|wantarray|warn|while|write)\b/g,'<b>$1</b>', // reserved words
    /([\(\){}])/g,'<u>$1</u>', // special chars
    /#(.*?)(<br>|<\/P>)/g,'<i>#$1</i>$2', // comments
];

CodePress.initialize();


/*
 * CodePress regular expressions for HTML syntax highlighting
 */

syntax = [ // HTML
	/(&lt;[^!]*?&gt;)/g,'<b>$1</b>', // all tags
	/(&lt;a .*?&gt;|&lt;\/a&gt;)/g,'<a>$1</a>', // links
	/(&lt;img .*?&gt;)/g,'<big>$1</big>', // images
	/(&lt;\/?(button|textarea|form|input|select|option|label).*?&gt;)/g,'<u>$1</u>', // forms
	/(&lt;style.*?&gt;)(.*?)(&lt;\/style&gt;)/g,'<em>$1</em><em>$2</em><em>$3</em>', // style tags
	/(&lt;script.*?&gt;)(.*?)(&lt;\/script&gt;)/g,'<strong>$1</strong><tt>$2</tt><strong>$3</strong>', // script tags
	/=(".*?")/g,'=<s>$1</s>', // atributes double quote
	/=('.*?')/g,'=<s>$1</s>', // atributes single quote
	/(&lt;!--.*?--&gt.)/g,'<ins>$1</ins>', // comments 
	/\b(alert|window|document|break|continue|do|for|new|this|void|case|default|else|function|return|typeof|while|if|label|switch|var|with|catch|boolean|int|try|false|throws|null|true|goto)\b/g,'<i>$1</i>', // script reserved words
	/([^:]|^)\/\/(.*?)(<br|<\/P)/g,'$1<cite>//$2</cite>$3', // script comments //
	/\/\*(.*?)\*\//g,'<cite>/*$1*/</cite>' // script comments /* */
	
	
];

CodePress.initialize();


