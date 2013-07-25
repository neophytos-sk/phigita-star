/************************************************************************************************************
*	Ajax dynamic content script
*
*	Created:					August, 23rd, 2006
*
*			
* 	Update log:
*
************************************************************************************************************/

/**
* @constructor
* @class The purpose of this class is to load content of external files into HTML elements on your page(<a href="../../demos/demo-dynamic-content-1.html" target="_blank">demo</a>).
* @version				1.0
* @version 1.0
* 
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/

DHTMLSuite.dynamicContent = function()
{
	var enableCache;	// Cache enabled.
	var jsCache;
	var dynamicContent_ajaxObjects;
	var waitMessage;
	
	this.enableCache = true;
	this.jsCache = new Array();
	this.dynamicContent_ajaxObjects = new Array();
	this.waitMessage = 'Loading content - please wait';
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	// This line starts all the init methods
	var objectIndex;
	
	this.objectIndex = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects.length;
	DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[this.objectIndex] = this;
		
}

DHTMLSuite.dynamicContent.prototype = {

	// {{{ loadContent()
    /**
     * Cancel selection when drag is in process
     *
     * @param String divId = Id of HTML element
     * @param url = Path to content on the server(Local content only)
     * @param String functionToCallOnLoaded = Function to call when ajax is finished. This string will be evaulated, example of string: "fixContent()" (with the quotes).
     * 
     * @public
     */	
	loadContent : function(divId,url,functionToCallOnLoaded)
	{
		var ind = this.objectIndex;
		if(this.enableCache && this.jsCache[url]){
			document.getElementById(divId).innerHTML = this.jsCache[url];
			return;
		}
		var ajaxIndex = 0;
		if(this.waitMessage){
			try{
			document.getElementById(divId).innerHTML = this.waitMessage ;
			}catch(e){
			}
		}
		this.dynamicContent_ajaxObjects[ajaxIndex] = new sack();
		this.dynamicContent_ajaxObjects[ajaxIndex].requestFile = url;	// Specifying which file to get

		
		this.dynamicContent_ajaxObjects[ajaxIndex].onCompletion = function(){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__ajax_showContent(divId,ajaxIndex,url,functionToCallOnLoaded); };	// Specify function that will be executed after file has been found
		this.dynamicContent_ajaxObjects[ajaxIndex].runAJAX();		// Execute AJAX function	
	}
	// }}}		
	,
	// {{{ setWaitMessage()
    /**
     * Specify which message to show when Ajax is busy.
     *
     * @param String newWaitMessage = New wait message (Default = "Loading content - please wait") - use false if you don't want any wait message
     * 
     * @public
     */		
	setWaitMessage : function(newWaitMessage)
	{
		this.waitMessage = newWaitMessage;		
	}
	// }}}
	,
	// {{{ setCache()
    /**
     * Cancel selection when drag is in process
     *
     * @param Boolean enableCache = true if you want to enable cache, false otherwise(default is true). You can also send HTMl code in here, example an &lt;img> tag.
     * 
     * @public
     */		
	setCache : function(enableCache)
	{
		this.enableCache = enableCache;		
	}
	// }}}
	,
	// {{{ __evaluateJs()
    /**
     * Evaluate Javascript in the inserted content
     *
     * @private
     */	
	
	__ajax_showContent :function(divId,ajaxIndex,url,functionToCallOnLoaded)
	{
		var obj = document.getElementById(divId);
		obj.innerHTML = this.dynamicContent_ajaxObjects[ajaxIndex].response;
		
		if(this.enableCache){	// Cache is enabled
			this.jsCache[url] = this.dynamicContent_ajaxObjects[ajaxIndex].response;	// Put content into cache
		}
		
		this.__evaluateJs(obj);	// Call private method which evaluates JS content
		this.__evaluateCss(obj);	// Call private method which evaluates JS content
		if(functionToCallOnLoaded)eval(functionToCallOnLoaded);
		this.dynamicContent_ajaxObjects[ajaxIndex] = null;	// Clear sack object
	}
	// }}}		
	,	
	// {{{ __evaluateJs()
    /**
     * Evaluate Javascript in the inserted content
     *
     * @private
     */	
	__evaluateJs : function(obj)
	{
		var scriptTags = obj.getElementsByTagName('SCRIPT');
		var string = '';
		var jsCode = '';
		for(var no=0;no<scriptTags.length;no++){	
			if(scriptTags[no].src){
		        var head = document.getElementsByTagName("head")[0];
		        var scriptObj = document.createElement("script");
		
		        scriptObj.setAttribute("type", "text/javascript");
		        scriptObj.setAttribute("src", scriptTags[no].src);  	
			}else{
				if(DHTMLSuite.clientInfoObj.isOpera){
					jsCode = jsCode + scriptTags[no].text + '\n';
				}
				else
					jsCode = jsCode + scriptTags[no].innerHTML;	
			}
			
		}

		if(jsCode)this.__installScript(jsCode);
	}
	// }}}
	,
	// {{{ __evaluateJs()
    /**
     *  "Installs" the content of a <script> tag.
     *
     * @private        
     */		
	__installScript : function ( script )
	{		
	    if (!script)
	        return;		
        if (window.execScript){        	
        	window.execScript(script)
        }else if(window.jQuery && jQuery.browser.safari){ // safari detection in jQuery
            window.setTimeout(script,0);
        }else{        	
            window.setTimeout( script, 0 );
        } 
	}	
	// }}}
	,
	// {{{ __evaluateCss()
    /**
     *  Evaluates css
     *
     * @private        
     */	
	__evaluateCss : function(obj)
	{
		var cssTags = obj.getElementsByTagName('STYLE');
		var head = document.getElementsByTagName('HEAD')[0];
		for(var no=0;no<cssTags.length;no++){
			head.appendChild(cssTags[no]);
		}	
	}
	
}