/*[FILE_START:dhtmlSuite-common.js] */
/************************************************************************************************************
	@fileoverview
	DHTML Suite for Applications.
	Copyright (C) 2006  Alf Magne Kalleland(post@dhtmlgoodies.com)<br>
	<br>
	This library is free software; you can redistribute it and/or<br>
	modify it under the terms of the GNU Lesser General Public<br>
	License as published by the Free Software Foundation; either<br>
	version 2.1 of the License, or (at your option) any later version.<br>
	<br>
	This library is distributed in the hope that it will be useful,<br>
	but WITHOUT ANY WARRANTY; without even the implied warranty of<br>
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU<br>
	Lesser General Public License for more details.<br>
	<br>
	You should have received a copy of the GNU Lesser General Public<br>
	License along with this library; if not, write to the Free Software<br>
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA<br>
	<br>
	<br>
	www.dhtmlgoodies.com<br>
	Alf Magne Kalleland<br>

************************************************************************************************************/


/**
 * 
 * @package DHTMLSuite for applications
 * @copyright Copyright &copy; 2006, www.dhtmlgoodies.com
 * @author Alf Magne Kalleland <post@dhtmlgoodies.com>
 */


/************************************************************************************************************
*
* Global variables
*
************************************************************************************************************/


// {{{ DHTMLSuite.createStandardObjects()
/**
 * Create objects used by all scripts
 *
 * @public
 */


var DHTMLSuite = new Object();

var standardObjectsCreated = false;	// The classes below will check this variable, if it is false, default help objects will be created
DHTMLSuite.eventElements = new Array();	// Array of elements that has been assigned to an event handler.

DHTMLSuite.createStandardObjects = function()
{
	DHTMLSuite.clientInfoObj = new DHTMLSuite.clientInfo();	// Create browser info object
	DHTMLSuite.clientInfoObj.init();	
	if(!DHTMLSuite.configObj){	// If this object isn't allready created, create it.
		DHTMLSuite.configObj = new DHTMLSuite.config();	// Create configuration object.
		DHTMLSuite.configObj.init();
	}
	DHTMLSuite.commonObj = new DHTMLSuite.common();	// Create configuration object.
	DHTMLSuite.variableStorage = new DHTMLSuite.globalVariableStorage();;	// Create configuration object.
	DHTMLSuite.commonObj.init();
	DHTMLSuite.domQueryObj = new DHTMLSuite.domQuery();
	window.onunload = function() { DHTMLSuite.commonObj.__clearGarbage(); }
	
	standardObjectsCreated = true;

	
}

    


/************************************************************************************************************
*	Configuration class used by most of the scripts
*
*	Created:			August, 19th, 2006
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Store global variables/configurations used by the classes below. Example: If you want to  
*		 change the path to the images used by the scripts, change it here. An object of this   
*		 class will always be available to the other classes. The name of this object is 
*		"DHTMLSuite.configObj".	<br><br>
*			
*		If you want to create an object of this class manually, remember to name it "DHTMLSuite.configObj"
*		This object should then be created before any other objects. This is nescessary if you want
*		the other objects to use the values you have put into the object. <br>
* @version				1.0
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/
DHTMLSuite.config = function()
{
	var imagePath;	// Path to images used by the classes. 
	var cssPath;	// Path to CSS files used by the DHTML suite.	

	var defaultCssPath;
	var defaultImagePath;
	

}


DHTMLSuite.config.prototype = {
	// {{{ init()
	/**
	 *
	 * @public
	 */
	init : function()
	{
		this.imagePath = '/images/dhtmlsuite/';	// Path to images		
		this.cssPath = '/css/dhtmlsuite/';	// Path to images	
		
		this.defaultCssPath = this.cssPath;
		this.defaultImagePath = this.imagePath;
			
	}	
	// }}}
	,
	// {{{ setCssPath()
    /**
     * This method will save a new CSS path, i.e. where the css files of the dhtml suite are located.
     *
     * @param string newCssPath = New path to css files
     * @public
     */
    	
	setCssPath : function(newCssPath)
	{
		this.cssPath = newCssPath;
	}
	// }}}
	,
	// {{{ resetCssPath()
    /**
     * Resets css path back to default state
     *
     * @public
     */    	
	resetCssPath : function()
	{
		this.cssPath = this.defaultCssPath;
	}
	// }}}
	,
	// {{{ resetImagePath()
    /**
     * Resets css path back to default state
     *
     * @public
     */    	
	resetImagePath : function()
	{
		this.imagePath = this.defaultImagePath;
	}
	// }}}
	,
	// {{{ setImagePath()
    /**
     * This method will save a new image file path, i.e. where the image files used by the dhtml suite ar located
     *
     * @param string newImagePath = New path to image files
     * @public
     */
	setImagePath : function(newImagePath)
	{
		this.imagePath = newImagePath;
	}
	// }}}
}



DHTMLSuite.globalVariableStorage = function()
{
	var menuBar_highlightedItems;	// Array of highlighted menu bar items
	this.menuBar_highlightedItems = new Array();
	
	var arrayOfDhtmlSuiteObjects;	// Array of objects of class menuItem.
	this.arrayOfDhtmlSuiteObjects = new Array();
	
	var ajaxObjects;
	this.ajaxObjects = new Array();
}

DHTMLSuite.globalVariableStorage.prototype = {
	
}


/************************************************************************************************************
*	A class with general methods used by most of the scripts
*
*	Created:			August, 19th, 2006
*	Purpose of class:	A class containing common method used by one or more of the gui classes below, 
* 						example: loadCSS. 
*						An object("DHTMLSuite.commonObj") of this  class will always be available to the other classes. 
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class A class containing common method used by one or more of the gui classes below, example: loadCSS. An object("DHTMLSuite.commonObj") of this  class will always be available to the other classes. 
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/

DHTMLSuite.common = function()
{
	var loadedCSSFiles;	// Array of loaded CSS files. Prevent same CSS file from being loaded twice.
	var cssCacheStatus;	// Css cache status
	var eventElements;
	var isOkToSelect;	// Boolean variable indicating if it's ok to make text selections
	
	this.okToSelect = true;
	this.cssCacheStatus = true;	// Caching of css files = on(Default)
	this.eventElements = new Array();	
}

DHTMLSuite.common.prototype = {
	
	// {{{ init()
    /**
     * This method initializes the DHTMLSuite_common object.
     *
     * @public
     */
    	
	init : function()
	{
		this.loadedCSSFiles = new Array();
	}	
	// }}}
	,
	// {{{ loadCSS()
    /**
     * This method loads a CSS file(Cascading Style Sheet) dynamically - i.e. an alternative to <link> tag in the document.
     *
     * @param string cssFileName = New path to image files
     * @public
     */
	
	loadCSS : function(cssFileName)
	{
		
		if(!this.loadedCSSFiles[cssFileName]){
			this.loadedCSSFiles[cssFileName] = true;
			var linkTag = document.createElement('LINK');
			if(!this.cssCacheStatus){
				if(cssFileName.indexOf('?')>=0)cssFileName = cssFileName + '&'; else cssFileName = cssFileName + '?';
				cssFileName = cssFileName + 'rand='+ Math.random();	// To prevent caching
			}
			
			linkTag.href = DHTMLSuite.configObj.cssPath + cssFileName;
			linkTag.rel = 'stylesheet';
			linkTag.media = 'screen';
			linkTag.type = 'text/css';
			document.getElementsByTagName('HEAD')[0].appendChild(linkTag);	
			
		}
	}	
	// }}}
	,
	// {{{ getTopPos()
    /**
     * This method will return the top coordinate(pixel) of an object
     *
     * @param Object inputObj = Reference to HTML element
     * @public
     */	
	getTopPos : function(inputObj)
	{		
	  var returnValue = inputObj.offsetTop;
	  while((inputObj = inputObj.offsetParent) != null){
	  	if(inputObj.tagName!='HTML'){
	  		returnValue += (inputObj.offsetTop - inputObj.scrollTop);
	  		if(document.all)returnValue+=inputObj.clientTop;
	  	}
	  } 
	  return returnValue;
	}
	// }}}
	,
	// {{{ __setOkToSelect()
    /**
     * Is it ok to make text selections ?
     *
     * @param Boolean okToSelect 
     * @private
     */		
	__setOkToSelect : function(okToSelect){
		this.okToSelect = okToSelect;
	}
	// }}}
	,
	// {{{ __setOkToSelect()
    /**
     * Returns true if it's ok to make text selections, false otherwise.
     *
     * @return Boolean okToSelect 
     * @private
     */		
	__getOkToSelect : function()
	{
		return this.okToSelect;
	}
	// }}}	
	,	
	// {{{ setCssCacheStatus()
    /**
     * Specify if css files should be cached or not. 
     *
     *	@param Boolean cssCacheStatus = true = cache on, false = cache off
     *
     * @public
     */	
	setCssCacheStatus : function(cssCacheStatus)
	{		
	  this.cssCacheStatus = cssCacheStatus;
	}
	// }}}	
	,
	// {{{ getLeftPos()
    /**
     * This method will return the left coordinate(pixel) of an object
     *
     * @param Object inputObj = Reference to HTML element
     * @public
     */	
	getLeftPos : function(inputObj)
	{	  
	  var returnValue = inputObj.offsetLeft;
	  while((inputObj = inputObj.offsetParent) != null){
	  	if(inputObj.tagName!='HTML'){
	  		returnValue += inputObj.offsetLeft;
	  		if(document.all)returnValue+=inputObj.clientLeft;
	  	}
	  }
	  return returnValue;
	}
	// }}}
	,
	
	// {{{ getCookie()
    /**
     *
     * 	These cookie functions are downloaded from 
	 * 	http://www.mach5.com/support/analyzer/manual/html/General/CookiesJavaScript.htm
	 *
     *  This function returns the value of a cookie
     *
     * @param String name = Name of cookie
     * @param Object inputObj = Reference to HTML element
     * @public
     */	
	getCookie : function(name) { 
	   var start = document.cookie.indexOf(name+"="); 
	   var len = start+name.length+1; 
	   if ((!start) && (name != document.cookie.substring(0,name.length))) return null; 
	   if (start == -1) return null; 
	   var end = document.cookie.indexOf(";",len); 
	   if (end == -1) end = document.cookie.length; 
	   return unescape(document.cookie.substring(len,end)); 
	} 	
	// }}}
	,	
	
	// {{{ setCookie()
    /**
     *
     * 	These cookie functions are downloaded from 
	 * 	http://www.mach5.com/support/analyzer/manual/html/General/CookiesJavaScript.htm
	 *
     *  This function creates a cookie. (This method has been slighhtly modified)
     *
     * @param String name = Name of cookie
     * @param String value = Value of cookie
     * @param Int expires = Timestamp - days
     * @param String path = Path for cookie (Usually left empty)
     * @param String domain = Cookie domain
     * @param Boolean secure = Secure cookie(SSL)
     * 
     * @public
     */	
	setCookie : function(name,value,expires,path,domain,secure) { 
		expires = expires * 60*60*24*1000;
		var today = new Date();
		var expires_date = new Date( today.getTime() + (expires) );
	    var cookieString = name + "=" +escape(value) + 
	       ( (expires) ? ";expires=" + expires_date.toGMTString() : "") + 
	       ( (path) ? ";path=" + path : "") + 
	       ( (domain) ? ";domain=" + domain : "") + 
	       ( (secure) ? ";secure" : ""); 
	    document.cookie = cookieString; 
	}
	// }}}
	,
	// {{{ cancelEvent()
    /**
     *
     *  This function only returns false. It is used to cancel selections and drag
     *
     * 
     * @public
     */	
    	
	cancelEvent : function()
	{
		return false;
	}
	// }}}	
	,
	// {{{ addEvent()
    /**
     *
     *  This function adds an event listener to an element on the page.
     *
     *	@param Object whichObject = Reference to HTML element(Which object to assigne the event)
     *	@param String eventType = Which type of event, example "mousemove" or "mouseup"
     *	@param functionName = Name of function to execute. 
     * 
     * @public
     */	
	addEvent : function(whichObject,eventType,functionName)
	{ 
	  if(whichObject.attachEvent){ 
	    whichObject['e'+eventType+functionName] = functionName; 
	    whichObject[eventType+functionName] = function(){whichObject['e'+eventType+functionName]( window.event );} 
	    whichObject.attachEvent( 'on'+eventType, whichObject[eventType+functionName] ); 
	  } else 
	    whichObject.addEventListener(eventType,functionName,false); 	    
	  this.__addEventElement(whichObject);
	} 
	// }}}	
	,	
	// {{{ removeEvent()
    /**
     *
     *  This function removes an event listener from an element on the page.
     *
     *	@param Object whichObject = Reference to HTML element(Which object to assigne the event)
     *	@param String eventType = Which type of event, example "mousemove" or "mouseup"
     *	@param functionName = Name of function to execute. 
     * 
     * @public
     */		
	removeEvent : function(whichObject,eventType,functionName)
	{ 
	  if(whichObject.detachEvent){ 
	    whichObject.detachEvent('on'+eventType, whichObject[eventType+functionName]); 
	    whichObject[eventType+functionName] = null; 
	  } else 
	    whichObject.removeEventListener(eventType,functionName,false); 
	} 
	// }}}
	,
	// {{{ __clearGarbage()
    /**
     *
     *  This function is used for Internet Explorer in order to clear memory when the page unloads.
     *
     * 
     * @private
     */	
    __clearGarbage : function()
    {
   		/* Example of event which causes memory leakage in IE 
   		
   		DHTMLSuite.commonObj.addEvent(expandRef,"click",function(){ window.refToMyMenuBar[index].__changeMenuBarState(this); })
   		
   		We got a circular reference.
   		
   		*/
   		
    	if(!DHTMLSuite.clientInfoObj.isMSIE)return;
   	
    	for(var no in DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects){
    		DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[no] = false;    			
    	}

    	for(var no=0;no<DHTMLSuite.eventElements.length;no++){
    		DHTMLSuite.eventElements[no].onclick = null;
    		DHTMLSuite.eventElements[no].onmousedown = null;
    		DHTMLSuite.eventElements[no].onmousemove = null;
    		DHTMLSuite.eventElements[no].onmouseout = null;
    		DHTMLSuite.eventElements[no].onmouseover = null;
    		DHTMLSuite.eventElements[no].onmouseup = null;
    		DHTMLSuite.eventElements[no].onfocus = null;
    		DHTMLSuite.eventElements[no].onblur = null;
    		DHTMLSuite.eventElements[no].onkeydown = null;
    		DHTMLSuite.eventElements[no].onkeypress = null;
    		DHTMLSuite.eventElements[no].onkeyup = null;
    		DHTMLSuite.eventElements[no].onselectstart = null;
    		DHTMLSuite.eventElements[no].ondragstart = null;
    		DHTMLSuite.eventElements[no].oncontextmenu = null;
    		DHTMLSuite.eventElements[no].onscroll = null;
    		
    	}
    	window.onunload = null;
    	DHTMLSuite = null;

    }		
    // }}}
    ,
	// {{{ __addEventElement()
    /**
     *
     *  Add element to garbage collection array. The script will loop through this array and remove event handlers onload in ie.
     *
     * 
     * @private
     */	    
    __addEventElement : function(el)
    {
    	DHTMLSuite.eventElements[DHTMLSuite.eventElements.length] = el;    
    }
    // }}}
    ,
	// {{{ getSrcElement()
    /**
     *
     *  Returns a reference to the element which triggered an event.
     *	@param Event e = Event object
     *
     * 
     * @public
     */	       
    getSrcElement : function(e)
    {
    	var el;
		// Dropped on which element
		if (e.target) el = e.target;
			else if (e.srcElement) el = e.srcElement;
			if (el.nodeType == 3) // defeat Safari bug
				el = el.parentNode;
		return el;	
    }	
    // }}}	
    ,
	// {{{ isObjectClicked()
    /**
     *
     *  Returns true if an object is clicked, false otherwise. This method will also return true if you clicked on a sub element
     *	@param Object obj = Reference to HTML element
     *	@param Event e = Event object
     *
     * 
     * @public
     */	      
	isObjectClicked : function(obj,e)
	{
		var src = this.getSrcElement(e);
		var string = src.tagName + '(' + src.className + ')';
		if(src==obj)return true;
		while(src.parentNode && src.tagName.toLowerCase()!='html'){
			src = src.parentNode;
			string = string + ',' + src.tagName + '(' + src.className + ')';
			if(src==obj)return true;			
		}		
		return false;		
	}
}


/************************************************************************************************************
*	Client info class
*
*	Created:			August, 18th, 2006
* 	Update log:
*
************************************************************************************************************/

/**
* @constructor
* @class Purpose of class: Provide browser information to the classes below. Instead of checking for
*		 browser versions and browser types in the classes below, they should check this
*		 easily by referncing properties in the class below. An object("DHTMLSuite.clientInfoObj") of this 
*		 class will always be accessible to the other classes. * @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/


DHTMLSuite.clientInfo = function()
{
	var browser;			// Complete user agent information
	
	var isOpera;			// Is the browser "Opera"
	var isMSIE;				// Is the browser "Internet Explorer"
	var isOldMSIE;			// Is this browser and older version of Internet Explorer ( by older, we refer to version 6.0 or lower)	
	var isFirefox;			// Is the browser "Firefox"
	var navigatorVersion;	// Browser version
}
	
DHTMLSuite.clientInfo.prototype = {
	
	// {{{ init()
    /**
     *
	 *
     *  This method initializes the script
     *
     * 
     * @public
     */	
    	
	init : function()
	{
		this.browser = navigator.userAgent;	
		this.isOpera = (this.browser.toLowerCase().indexOf('opera')>=0)?true:false;
		this.isFirefox = (this.browser.toLowerCase().indexOf('firefox')>=0)?true:false;
		this.isMSIE = (this.browser.toLowerCase().indexOf('msie')>=0)?true:false;
		this.isOldMSIE = (this.browser.toLowerCase().match(/msie [0-6]/gi))?true:false;
		this.isSafari = (this.browser.toLowerCase().indexOf('safari')>=0)?true:false;
		this.navigatorVersion = navigator.appVersion.replace(/.*?MSIE (\d\.\d).*/g,'$1')/1;

	}	
	// }}}		
	,
	// {{{ getBrowserWidth()
    /**
     *
	 *
     *  This method returns the width of the browser window(i.e. inner width)
     *
     * 
     * @public
     */		
	getBrowserWidth : function()
	{
		return document.documentElement.offsetWidth;		
	}
	// }}}
	,
	// {{{ getBrowserHeight()
    /**
     *
	 *
     *  This method returns the height of the browser window(i.e. inner height)
     *
     * 
     * @public
     */		
	getBrowserHeight: function()
	{
		return document.documentElement.offsetHeight;
	}
}



/************************************************************************************************************
*	DOM query class 
*
*	Created:			August, 31th, 2006
*
* 	Update log:
*
************************************************************************************************************/

/**
* @constructor
* @class Purpose of class:	Gives you a set of methods for querying elements on a webpage. When an object
*		 of this class has been created, the method will also be available via the document object.
*		 Example: var elements = document.getElementsByClassName('myClass');
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/

DHTMLSuite.domQuery = function()
{
	// Make methods of this class a member of the document object. 
	document.getElementsByClassName = this.getElementsByClassName;
	document.getElementsByAttribute = this.getElementsByAttribute;
}



	
DHTMLSuite.domQuery.prototype = {
	
	// {{{ getElementsByClassName()
    /**
     *	This method will return an array of all elements of a specific class.
     *
	 *	@param String className = Class to search for
	 *	@param Object inputObj = Optional - Which element to search from(i.e. search only in sub elements of this one) if ommited, search all.
     *	@return Array objects = An array of references to HTML elements on the page. 
     *  @type Array
     *
     * @public
     */	
    	
	getElementsByClassName : function(className,inputObj)
	{
		var returnArray = new Array();
		if(inputObj)
			var allElements = inputObj.getElementsByTagName('*');
		else
			var allElements = document.getElementsByTagName('*');
		for(var no=0;no<allElements.length;no++){
			if(allElements[no].className==className)returnArray[returnArray.length] = allElements[no];	
		}
		return returnArray;
	}	
	// }}}		
	,
	// {{{ getElementsByAttribute()
    /**
     *	This method will return an array of all elements where a specific attribute is set.
     *
	 *	@param String attribute = Attribute to search for
	 *	@param String attributeValue = Optional - only search for elements where the attribute is set to this value
	 *	@param Object inputObj = Optional - Which element to search from(i.e. search only in sub elements of this one) if ommited, search all.
	 *
     *	@return Array objects = An array of references to HTML elements on the page. 
     *	@type Array
     * 
     * @public
     */	    	
	getElementsByAttribute : function(attribute,attributeValue,inputObj)
	{
		var returnArray = new Array();
		if(inputObj)
			var allElements = inputObj.getElementsByTagName('*');
		else
			var allElements = document.getElementsByTagName('*');
		for(var no=0;no<allElements.length;no++){
			var att = allElements[no].getAttribute(attribute);
			if(!attributeValue){
				if(att)returnArray[returnArray.length] = allElements[no];
			}
			else
				if(att==attributeValue)returnArray[returnArray.length] = allElements[no];
		}
		return returnArray;
	}	
	// }}}			

}


/*[FILE_START:dhtmlSuite-tableWidget.js] */
/************************************************************************************************************
*	Table widget page handler class
*
*	Created:			December, 15th, 2006
*	Purpose of class:	Displays paginating below a server sorted table
*
*	CSS used:			
*
* 	Update log:
*
************************************************************************************************************/

/**
* @constructor
* @class Purpose of class:	Make HTML tables sortable<br><br>
*/
DHTMLSuite.tableWidgetPageHandler = function()
{
	var tableRef;					// Reference to object of class DHTMLSuite.tableWidget
	var targetRef;					// Where to insert the pagination.
	
	var txtPrevious;				// Label - "Previous"
	var txtNext;					// Label - "Next"
	
	var txtResultPrefix;			// Prefix : result - default = "Result: "
	var txtResultTo;				// Text label Result: 1 "to" 10 of 51 - default value = "to"
	var txtResultOf;				// Text label Result: 1 to 10 "of" 51 - default value = "of"
	
	var totalNumberOfRows;			// Total number of rows in dataset
	var rowsPerPage;				// Number of rows per page.
	
	var layoutCSS;					// Name of CSS file for the table widget.
	var activePageNumber;			// Active page number
	var mainDivElement;				// Reference to main div for the page handler
	var resultDivElement;			// Reference to div element which is parent for the result
	var pageListDivElement;			// Reference to div element which is parent to pages [1],[2],[3]...[Next]
	
	var objectIndex;				// Index of this widget in the arrayOfDhtmlSuiteObjects array
	
	var linkPagePrefix;				// Text in front of each page link
	var linkPageSuffix;				// Text behind each page link
	
	this.txtPrevious = 'Previous';	// Default label
	this.txtNext = 'Next';			// Default label
	this.txtResultPrefix = 'Result: ';			// Default label
	this.txtResultTo = 'to';			// Default label
	this.txtResultOf = 'of';			// Default label
	
	
	this.tableRef = false;
	this.targetRef = false;
	this.totalNumberOfRows = false;
	this.activePageNumber = 1;
	this.layoutCSS = 'table-widget-page-handler.css';
	
	this.linkPagePrefix = '';
	this.linkPageSuffix = '';
	
	this.objectIndex = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects.length;
	DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[this.objectIndex] = this;
		
	
}

DHTMLSuite.tableWidgetPageHandler.prototype = {
	
	setTableRef : function(tableRef)
	{
		this.tableRef = tableRef;
		this.tableRef.setPageHandler(this);
	}	
	// }}}
	,
	setTargetId : function(targetId)
	{
		if(!document.getElementById(targetId)){
			alert('ERROR IN tableWidgetPageHandler.setTargetId:\nElement with id ' + targetId + ' does not exists');
			return;
		}
		this.targetRef = document.getElementById(targetId);		
	}
	// }}}
	,
	// {{{ setTxtPrevious()
    /**
     *	Set text label (previous page link)
     *
	 *	@param String newText = Text previous page link
     * 
     * @public
     */		
	setTxtPrevious : function(newText)
	{
		this.txtPrevious = newText;
	}
	// }}}
	,
	// {{{ setLinkPagePrefix()
    /**
     *	Set text/characters in front of each page link, example "[" to get page number in brackets
     *
	 *	@param String linkPagePrefix = Character(s) in front of page links
     * 
     * @public
     */		
	setLinkPagePrefix : function(linkPagePrefix)
	{
		this.linkPagePrefix = linkPagePrefix;
	}
	// }}}
	,
	// {{{ setLinkPageSuffix()
    /**
     *	Set text/characters in front of each page link, example "[" to get page number in brackets
     *
	 *	@param String linkPageSuffix = Character(s) in front of page links
     * 
     * @public
     */		
	setLinkPageSuffix : function(linkPageSuffix)
	{
		this.linkPageSuffix = linkPageSuffix;
	}
	
	// }}}
	,
	// {{{ setTxtNext()
    /**
     *	Set text label (next page link)
     *
	 *	@param String newText = Text next page link
     * 
     * @public
     */		
	setTxtNext : function(newText)
	{
		this.txtNext = newText;
	}
	// }}}
	,
	// {{{ setTxtResultOf()
    /**
     *	Set text label ("of" - result)
     *
	 *	@param String txtResultOf = Result of search, the "of" label ( Result: 1 to 10 "of" 51 )
     * 
     * @public
     */		
	setTxtResultOf : function(txtResultOf)
	{
		this.txtResultOf = txtResultOf;
	}
	// }}}
	,
	// {{{ setTxtResultTo()
    /**
     *	Set text label ("to" - result)
     *
	 *	@param String txtResultTo = Result of search, the "to" label ( Result: 1 "to" 10 of 51 )
     * 
     * @public
     */		
	setTxtResultTo : function(txtResultTo)
	{
		this.txtResultTo = txtResultTo;
	}
	// }}}
	,
	// {{{ setTxtResultPrefix()
    /**
     *	Set text label (prefix - result)
     *
	 *	@param String txtResultPrefix = Text next page link
     * 
     * @public
     */		
	setTxtResultPrefix : function(txtResultPrefix)
	{
		this.txtResultPrefix = txtResultPrefix;
	}
	// }}}
	,
	// {{{ setTotalNumberOfRows()
    /**
     *	Specify total number of rows in the entire dataset
     *
	 *	@param Integer totalNumberOfRows = Total number of rows in the entire dataset.
     * 
     * @public
     */		
	setTotalNumberOfRows : function(totalNumberOfRows)
	{
		this.totalNumberOfRows = totalNumberOfRows;
	}
	// }}}
	,
	// {{{ setLayoutCss()
    /**
     * set new CSS file
     *
     * @param String cssFileName - name of new css file(example: drag-drop.css). Has to be set before init is called. 
     *
     * @public
     */	
	setLayoutCss : function(layoutCSS)
	{
		this.layoutCSS = layoutCSS;
	}
	// }}}
	,
	// {{{ init()
    /**
     * Initializes the script
     *
     *
     * @public
     */		
	init : function()
	{
		this.rowsPerPage = this.tableRef.getServersideSortNumberOfRows();
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);
		this.__createMainElements();
		this.__createResultList();
		this.__createPageLinks();
	}
	// }}}
	,
	// {{{ __createMainElements()
    /**
     * Create main div elements for the page handler
     *
     *
     * @private
     */		
	__createMainElements : function()
	{
		if(!this.targetRef){
			alert('Error creating table widget page handler. Remember to specify targetRef');
			return;
		}
		this.mainDivElement = document.createElement('DIV');
		this.mainDivElement.className = 'DHTMLSuite_tableWidgetPageHandler_mainDiv';
		this.targetRef.appendChild(this.mainDivElement);		
		
		this.resultDivElement = document.createElement('DIV');
		this.resultDivElement.className = 'DHTMLSuite_tableWidgetPageHandler_result';
		this.mainDivElement.appendChild(this.resultDivElement);
		
		this.pageListDivElement = document.createElement('DIV');
		this.pageListDivElement.className = 'DHTMLSuite_tableWidgetPageHandler_pageList';
		this.mainDivElement.appendChild(this.pageListDivElement);
	}
	
	,
	// {{{ __createResultList()
    /**
     *
     * 	Create result list div
     *	
	 *
     * 
     * @private
     */  	
	__createResultList : function()
	{
		this.resultDivElement.innerHTML = '';		
		var html = this.txtResultPrefix + (((this.activePageNumber-1) * this.rowsPerPage) + 1) + ' ' + this.txtResultTo + ' ' + Math.min(this.totalNumberOfRows,(this.activePageNumber * this.rowsPerPage)) + ' ' + this.txtResultOf + ' ' + this.totalNumberOfRows;
		this.resultDivElement.innerHTML = html;
	}
	// }}}
	,
	// {{{ __createPageLinks()
    /**
     *
     * 	Create page links
     *	
	 *
     * 
     * @private
     */  	
	__createPageLinks : function()
	{
		var ind = this.objectIndex;
		
		this.pageListDivElement.innerHTML = '';	// Clearing the div element if it allready got content.
		
		var previousLink = document.createElement('A');	// "Previous" link
		previousLink.innerHTML = this.txtPrevious;
		previousLink.href = '#';
		previousLink.id = 'previous';
		previousLink.onclick = function(e){ return DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__navigate(e); }
		this.pageListDivElement.appendChild(previousLink);
		DHTMLSuite.commonObj.__addEventElement(previousLink);
		if(this.activePageNumber==1)previousLink.className = 'previousLinkDisabled'; else previousLink.className = 'previousLink';
		
		var numberOfPages = Math.ceil(this.totalNumberOfRows/this.rowsPerPage);
		for(var no=1;no<=numberOfPages;no++){
			
			var span = document.createElement('SPAN');
			span.innerHTML = this.linkPagePrefix;
			this.pageListDivElement.appendChild(span);	
			
			
			var pageLink = document.createElement('A');
			if(no==this.activePageNumber)pageLink.className='DHTMLSuite_tableWidgetPageHandler_activePage'; else pageLink.className = 'DHTMLSuite_tableWidgetPageHandler_inactivePage';
			pageLink.innerHTML = no;
			pageLink.href= '#';
			pageLink.id = 'pageLink_' + no;
			pageLink.onclick = function(e){ return DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__navigate(e); }
			DHTMLSuite.commonObj.__addEventElement(pageLink);
			this.pageListDivElement.appendChild(pageLink);		
			
			var span = document.createElement('SPAN');
			span.innerHTML = this.linkPageSuffix;
			this.pageListDivElement.appendChild(span);	
							
		}
		
		var nextLink = document.createElement('A');	// "Next" link
		nextLink.innerHTML = this.txtNext;
		nextLink.id = 'next';
		nextLink.href = '#';
		nextLink.onclick = function(e){ return DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__navigate(e); }
		DHTMLSuite.commonObj.__addEventElement(nextLink);
		this.pageListDivElement.appendChild(nextLink);
		if(this.activePageNumber==numberOfPages)nextLink.className = 'nextLinkDisabled'; else nextLink.className = 'nextLink';
		
	}
	// }}}
	,
	// {{{ __navigate()
    /**
     *
     * 	Navigate - click on "next" or "previous" link or click on a page
     *	
     *	@param Event e	= Reference to event object. used to get a reference to the element triggering this action.
	 *
     * 
     * @private
     */  	
	__navigate : function(e)
	{
		if(document.all)e = event;
		var src = DHTMLSuite.commonObj.getSrcElement(e);
		var initActivePageNumber = this.activePageNumber;
		var numberOfPages = Math.ceil(this.totalNumberOfRows/this.rowsPerPage);
		
		if(src.id.indexOf('pageLink_')>=0){
			var pageNo = src.id.replace(/[^0-9]/gi,'')/1;
			this.activePageNumber = pageNo;
			
		}
		if(src.id=='next'){	// next link clicked
			this.activePageNumber++;
			if(this.activePageNumber>numberOfPages)this.activePageNumber = numberOfPages;		
		}
		if(src.id=='previous'){
			this.activePageNumber--;
			if(this.activePageNumber<1)this.activePageNumber=1;
		}
		
		
		
		if(this.activePageNumber!=initActivePageNumber){
			this.tableRef.serversideSortCurrentStartIndex = ((this.activePageNumber-1)*this.rowsPerPage);
			this.tableRef.__getItemsFromServer();
			this.__createResultList();
			this.__createPageLinks();
		}
		return false;
		
	}
	// }}}
	,
	// {{{ __resetActivePageNumber()
    /**
     *
     * 	Reset active page number - called from the tableWidget
	 *
     * 
     * @private
     */   	
	__resetActivePageNumber : function()
	{
		this.activePageNumber = 1;
		this.__createResultList();
		this.__createPageLinks();
	}
}


/************************************************************************************************************
*	Table widget class
*
*	Created:			August, 18th, 2006
*	Purpose of class:	Make HTML tables sortable
*						Apply application look to the table
*						Create one object for each HTML table.
*
*	CSS used:			table-widget.css
*	images used:		arrow_up.gif
* 						arrow_down.gif
*
* 	Update log:
*
************************************************************************************************************/

/**
* @constructor
* @class Purpose of class:	Make HTML tables sortable<br><br>
*						Apply application look to the table<br>
*						Create one object for each HTML table.<br>
*<br>
*	Remember to have both &lt;THEAD> and &lt;TBODY> in your table.
* <br>
*	&lt;DIV><br>
*	&lt;table><br>
*		&lt;thead><br>
*			&lt;tr><br>
*				&lt;td>Header cell&lt;/td><br>
*				&lt;td>Header cell&lt;/td><br>
*			&lt;/tr><br>
*		&lt;/thead><br>
*		&lt;tbody><br>
*			&lt;tr><br>
*				&lt;td>Table data&lt;/td><br>
*				&lt;td>Table data&lt;/td><br>
*			&lt;/tr><br>
*			&lt;tr><br>
*				&lt;td>Table data&lt;/td><br>
*				&lt;td>Table data&lt;/td><br>
*			&lt;/tr><br>
*		&lt;/tbody><br>
*	&lt;/table><br>
*	&lt;/div><br>
*	<br><br>
*	Also remember:	If you put a table inside a non-displayed element, example an inactive tab(the tabView script), remember to create
*	and initialize the table objects before you create the tab objects. In some browsers, that's nescessary in order for the table to
*	display properly. <br>
*	(<a href="../../demos/demo-tablewidget.html" target="_blank">demo 1</a>)
*
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/

DHTMLSuite.tableWidget = function()
{
	var tableWidget_okToSort;				// Variable indicating if it's ok to sort. This variable is "false" when sorting is in progress
	var activeColumn;						// Reference to active column, i.e. column currently beeing sorted	
	var idOfTable;							// Id of table, i.e. the <table> tag
	var tableObj;							// Reference to <table> tag.
	var widthOfTable;						// Width of table	(Used in the CSS)
	var heightOfTable; 						// Height of table	(Used in the CSS)
	var columnSortArray;					// Array of how table columns should be sorted
	var layoutCSS;							// Name of CSS file for the table widget.
	var noCssLayout;						// true or false, indicating if the table should have layout or not, if not, it would be a plain sortable table.
	var serversideSort;						// true or false, true if the widget is sorted on the server.
	var serversideSortAscending;
	var tableCurrentlySortedBy;
	var serversideSortFileName;				// Name of file on server to send request to when table data should be sorted
	var serversideSortNumberOfRows;			// Number of rows to receive from the server
	var serversideSortCurrentStartIndex;	// Index of first row in the dataset, i.e. if you move to next page, this value will be incremented
	var serversideSortExtraSearchCriterias;	// Extra param to send to the server, example: &firstname=Alf&lastname=Kalleland
	var pageHandler;						// Object of class DHTMLSuite.tableWidgetPageHandler
	
	var objectIndex;						// Index of this object in the DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects array
	
	this.serversideSort = false;			// Default value for serversideSort(items are sorted in the client)
	this.serversideSortAscending = true;	// Current sort ( ascending or descending)
	this.tableCurrentlySortedBy = false;
	this.serversideSortFileName = false;
	this.serversideSortCurrentStartIndex=0;
	this.serversideSortExtraSearchCriterias = '';
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	// This line starts all the init methods

	this.objectIndex = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects.length;
	DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[this.objectIndex] = this;
}

DHTMLSuite.tableWidget.prototype = {	
	/**
	* Public method used to initialize the table widget script. First use the set methods to configure the script, then
	* call the init method.
	**/
	// {{{ init()
    /**
     *
     * 	Initializes the table widget object
	 *
     * 
     * @public
     */    	
	init : function()
	{		
		this.tableWidget_okToSort = true;
		this.activeColumn = false;
		if(!this.layoutCSS)this.layoutCSS = 'table-widget.css';
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);
		this.__initTableWidget();
	}
	// }}}	
	,
	// {{{ setLayoutCss()
    /**
     *
     *  This function updates name of CSS file. This method should be called before init().
     *
     * @param String newCssFile = (File name of CSS file, not path)
     * 
     * @public
     */	
	setLayoutCss : function(newCssFile)
	{
		this.layoutCSS = newCSSFile;			
	}
	// }}}	
	,	
	// {{{ setServerSideSort()
    /**
     *
     *  This method is used to specify if you want to your tables to be sorted on the server or not.
     *
     * @param Boolean serversideSort = Sort items on the server? (true = yes, false = no). 
     * 
     * @public
     */	
	setServerSideSort : function(serversideSort)
	{
		this.serversideSort = serversideSort;			
	}
	// }}}	
	,	
	// {{{ setServersideSearchCriterias()
    /**
     *
     *  This method is used to add extra params to the search url sent to the server.
     *
     * @param String serversideSortExtraSearchCriterias = String added to the url, example: "&firstname=John&lastname=Doe". This can be used in the sql query on the server.
     * 
     * @public
     */	
	setServersideSearchCriterias : function(serversideSortExtraSearchCriterias)
	{
		this.serversideSortExtraSearchCriterias = serversideSortExtraSearchCriterias;			
	}
	// }}}	
	,	
	// {{{ getServersideSortNumberOfRows()
    /**
     *
     *  Return numer of rows per page.
     *
     * @return Integer serversideSort = Number of rows
     * 
     * @public
     */	
	getServersideSortNumberOfRows : function(serversideSort)
	{
		return this.serversideSortNumberOfRows;		
	}
	// }}}	
	,		
	// {{{ setServersideSortNumberOfRows()
    /**
     *
     *  Specify how many records to receive from the server ( server side sort )
     *
     * @param Integer serversideSortNumberOfRows = Number of rows
     * 
     * @public
     */	
	setServersideSortNumberOfRows : function(serversideSortNumberOfRows)
	{
		this.serversideSortNumberOfRows = serversideSortNumberOfRows;			
	}
	// }}}	
	,	
	// {{{ setServersideSortFileName()
    /**
     *
     *  This method is used to specify which file to send the ajax request to when data should be sorted. (i.e. sort items on server instead of client).
     *
     * @param String serversideSortFileName = Path to file on server. This file will receive the request, parse it and send back new table data.
     * 
     * @public
     */	
	setServersideSortFileName : function(serversideSortFileName)
	{
		this.serversideSortFileName = serversideSortFileName;			
	}
	// }}}	
	,
	/* Start public methods */

	// {{{ setNoCssLayout()
    /**
     *
     *  No CSS layout
     *
     * 
     * @public
     */	
    setNoCssLayout : function()
	{
		this.noCssLayout = true;		
	}	
	// }}}	
	,	
	// {{{ sortTableByColumn()
    /**
     *
     *  This method sorts a table by a column
     *	You can call this method after the call to init if you want to sort the table by a column when the table is beeing displayed.
     *
     * @param Int columnIndex = Column to sort by (0 = first column)
     * 
     * @public
     */	
	sortTableByColumn : function(columnIndex)
	{
		var tableObj = document.getElementById(this.idOfTable);
		var firstRow = tableObj.rows[0];
		var tds = firstRow.cells;
		if(tds[columnIndex] && this.columnSortArray[columnIndex]){
			this.__sortTable(tds[columnIndex]);
		}	
	}	
	// }}}	
	,		
	// {{{ setTableId()
    /**
     *
     *  Set id of table, i.e. the id of the <table> tag you want to apply the table widget to
     *
     * @param String idOfTable = Id of table
     * 
     * @public
     */	
	setTableId : function(idOfTable)
	{
		this.idOfTable = idOfTable;	
		try{
			this.tableObj = document.getElementById(idOfTable);
		}catch(e){
			
		}	
	}
	// }}}	
	,
	
	
	// {{{ setTableWidth()
    /**
	 *
     *  Set width of table
     *
     * @param Mixed width = (string if percentage width, integer if numeric/pixel width)
     * 
     * @public
     */	
	setTableWidth : function(width)
	{
		this.widthOfTable = width;			
	}
	// }}}	
	,	
	// {{{ setTableHeight()
    /**
	 *
     *  Set height of table
     *
     * @param Mixed height = (string if percentage height, integer if numeric/pixel height)
     * 
     * @public
     */	
	setTableHeight : function(height)
	{
		this.heightOfTable = height;
	}
	// }}}	
	,	
	// {{{ setColumnSort()
    /**
     *
     *  How to sort the table
     *
     * @param Array columnSortArray = How to sort the columns in the table(An array of the items 'N','S' or false)
     * 
     * @public
     */		
	setColumnSort : function(columnSortArray)
	{
		this.columnSortArray = columnSortArray;	
	}
	// }}}	
	,	
	
	// {{{ addNewRow()
    /**
     *  Adds a new row to the table dynamically
     *
     * @param Array cellContent = Array of strings - cell content
     * 
     * @public
     */		
	addNewRow : function(cellContent)
	{
		var tableObj = document.getElementById(this.idOfTable);
		var tbody = tableObj.getElementsByTagName('TBODY')[0];
		
		var row = tbody.insertRow(-1);
		for(var no=0;no<cellContent.length;no++){
			var cell = row.insertCell(-1);
			cell.innerHTML = cellContent[no];
		}
		this.__parseDataRows(tableObj);
		
	}
	// }}}	
	,
	
	
	// {{{ addNewColumn()
    /**
     *  Adds a new row to the table dynamically
     *
     * @param Array columnContent = Array of strings - content of new cells.
     * @param String headerText = Text - column header
     * @param mixed sortMethod = How to sort the new column('N','S' or false)
     * 
     * @public
     */		
	addNewColumn : function(columnContent,headerText,sortMethod)
	{
		this.columnSortArray[this.columnSortArray.length] = sortMethod;
		var tableObj = document.getElementById(this.idOfTable);	// Reference to the <table>
		var tbody = tableObj.getElementsByTagName('TBODY')[0];	// Reference to the <tbody>		
		var thead = tableObj.getElementsByTagName('THEAD')[0];	// Reference to the <tbody>		
		
		var bodyRows = tbody.rows;	// Reference to all the <tr> inside the <tbody> tag
		var headerRows = thead.rows;	// Reference to all <tr> inside <thead>
		
		cellIndexSubtract = 1;	// Firefox have a small cell at the right of each row which means that the new column should not be the last one, but second to last.
		if(DHTMLSuite.clientInfoObj.isMSIE) cellIndexSubtract = 0;	// Browser does not have this cell at the right
		// Add new header cell		
		var headerCell = headerRows[0].insertCell(headerRows[0].cells.length-cellIndexSubtract);
		if(!this.noCssLayout)headerCell.className = 'DHTMLSuite_tableWidget_headerCell';
		headerCell.onselectstart = this.__cancelTableWidgetEvent;
		DHTMLSuite.commonObj.__addEventElement(headerCell);
		headerCell.innerHTML = headerText;
		if(sortMethod){
			this.__parseHeaderCell(headerCell);			
		}else{
			headerCell.style.cursor = 'default';	
		}
		
		// Setting width of header cells. The last cell shouldn't have any right border
		headerRows[0].cells[headerRows[0].cells.length-1].style.borderRightWidth = '0px';
		headerRows[0].cells[headerRows[0].cells.length-2].style.borderRightWidth = '1px';
		
		// Add rows to the table
		
		for(var no=0;no<columnContent.length;no++){
			var dataCell = bodyRows[no].insertCell(bodyRows[no].cells.length-cellIndexSubtract);
			dataCell.innerHTML = columnContent[no];			
		}
		
		this.__parseDataRows(tableObj);
					
	}
	// }}}	
	,
	
	/* START PRIVATE METHODS */
	
	
	setPageHandler : function(ref)
	{
		this.pageHandler = ref;
	}
	// }}}
	,
	
	// {{{ __parseHeaderCell()
    /**
     *  Parses a header cell
     *
     * @param Object inputCell = Reference to <TD>
     * 
     * @private
     */	
	__parseHeaderCell : function(inputCell)
	{
		if(!this.noCssLayout){
			inputCell.onmouseover = this.__highlightTableHeader;
			inputCell.onmouseout =  this.__deHighlightTableHeader;
			inputCell.onmousedown = this.__mousedownTableHeader;		
			inputCell.onmouseup = this.__highlightTableHeader;	
			
		}else{
			inputCell.style.cursor = 'pointer';	// No CSS layout -> just set cursor to pointer/hand.
		}
		
		var refToThis = this;	// It doesn't work with "this" on the line below, so we create a variable refering to "this".	
		inputCell.onclick = function(){ refToThis.__sortTable(this); };	
		DHTMLSuite.commonObj.__addEventElement(inputCell);

		var img = document.createElement('IMG');
		img.src = DHTMLSuite.configObj.imagePath + 'arrow_up.gif';
		inputCell.appendChild(img);	
		img.style.visibility = 'hidden';
	}
	// }}}	
	,
	
	// {{{ __parseDataRows()
    /**
     *  Parses rows in a table, i.e. add events and align cells.
     *
     * @param Object parentObj = Reference to <table>
     * 
     * @private
     */	
	__parseDataRows : function(parentObj)
	{
		// Loop through rows and assign mouseover and mouse out events + right align numeric cells.
		for(var no=1;no<parentObj.rows.length;no++){
			if(!this.noCssLayout){
				parentObj.rows[no].onmouseover = this.__highlightDataRow;
				parentObj.rows[no].onmouseout = this.__deHighlightDataRow;
				DHTMLSuite.commonObj.__addEventElement(parentObj.rows[no]);
			}
			for(var no2=0;no2<this.columnSortArray.length;no2++){	/* Right align numeric cells */
				try{
					if(this.columnSortArray[no2] && this.columnSortArray[no2]=='N')parentObj.rows[no].cells[no2].style.textAlign='right';
				}catch(e){
					alert('Error in __parseDataRows method - row: ' + no + ', column : ' + no2);
				}
			}
		}	
		// Right align header cells for numeric data
		for(var no2=0;no2<this.columnSortArray.length;no2++){	/* Right align numeric cells */
			if(this.columnSortArray[no2] && this.columnSortArray[no2]=='N')parentObj.rows[0].cells[no2].style.textAlign='right';
		}
					
		
	}
	// }}}		
	,
	// {{{ __initTableWidget()
    /**
     *  Initializes the table widget script. This method formats the table and add events to the header cells.
     *
     * 
     * @private
     */	
	__initTableWidget : function()
	{
		
		if(!this.columnSortArray)this.columnSortArray = new Array();
		this.widthOfTable = this.widthOfTable + '';
		this.heightOfTable = this.heightOfTable + '';
		var obj = document.getElementById(this.idOfTable);
		obj.parentNode.className = 'DHTMLSuite_widget_tableDiv';
		
		
		
		if(navigator.userAgent.toLowerCase().indexOf('safari')==-1 && !this.noCssLayout){
			if(!DHTMLSuite.clientInfoObj.isMSIE)
				obj.parentNode.style.overflow='hidden';
			else {
				obj.parentNode.style.overflowX = 'hidden';
				obj.parentNode.style.overflowY = 'scroll';
			}
		}
		
		
		if(!this.noCssLayout){
			if(this.widthOfTable.indexOf('%')>=0){			
				obj.style.width = '100%';
				obj.parentNode.style.width = this.widthOfTable;			
			}else{
				obj.style.width = this.widthOfTable + 'px';
				obj.parentNode.style.width = this.widthOfTable + 'px';
			}		
			if(this.heightOfTable.indexOf('%')>=0){
				obj.parentNode.style.height = this.heightOfTable;				
			}else{
				obj.parentNode.style.height = this.heightOfTable + 'px';
			}
		}
		if(!DHTMLSuite.clientInfoObj.isMSIE){
			this.__addEndCol(obj);
		}else{
			obj.style.cssText = 'width:expression(this.parentNode.clientWidth)';
		}	
		
		obj.cellSpacing = 0;
		obj.cellPadding = 0;
		if(!this.noCssLayout)obj.className='DHTMLSuite_tableWidget';
		var tHead = obj.getElementsByTagName('THEAD')[0];
		var cells = tHead.getElementsByTagName('TD');
		
		var tBody = obj.getElementsByTagName('TBODY')[0];
		tBody.className = 'DHTMLSuite_scrollingContent';
		
		/* Add the last "cosmetic" cell in ie so that the scrollbar gets it's own column */
		if(DHTMLSuite.clientInfoObj.isMSIE && 1==2){	/* DEPRECATED */
			lastCell = tHead.rows[0].insertCell(-1);
			lastCell.innerHTML = '&nbsp;&nbsp;&nbsp;';	
			lastCell.className='DHTMLSuite_tableWidget_MSIESPACER';

		}
				
		for(var no=0;no<cells.length;no++){
			if(!this.noCssLayout)cells[no].className = 'DHTMLSuite_tableWidget_headerCell';
			cells[no].onselectstart = this.__cancelTableWidgetEvent;
			DHTMLSuite.commonObj.__addEventElement(cells[no]);
			if(no==cells.length-1 && !this.noCssLayout){
				cells[no].style.borderRightWidth = '0px';	
			}
			if(this.columnSortArray[no]){
				this.__parseHeaderCell(cells[no]);			
			}else{
				cells[no].style.cursor = 'default';	
			}			
		}
		
		if(!this.noCssLayout){
			var tBody = obj.getElementsByTagName('TBODY')[0];
			if(document.all && navigator.userAgent.indexOf('Opera')<0){
				tBody.className='DHTMLSuite_scrollingContent';
				tBody.style.display='block';			
			}else{
				if(!this.noCssLayout)tBody.className='DHTMLSuite_scrollingContent';
				tBody.style.height = (obj.parentNode.clientHeight-tHead.offsetHeight) + 'px';
				if(navigator.userAgent.indexOf('Opera')>=0){
					obj.parentNode.style.overflow = 'auto';
				}
			}
		}
		
		this.__parseDataRows(obj);
		if(this.serversideSort)this.__autoSetColumnWidth();
		
		var ind = this.objectIndex;
		
		 
		DHTMLSuite.commonObj.addEvent(window,"resize",function() { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__autoSetColumnWidth(); });
		 
		
			
	}	
	// }}}	
	,
	
	// {{{ __addEndCol()
    /**
     *  Adds a small empty cell at the right of the header row. This is done in order to make the table look pretty when the scrollbar appears.
     *
     * @param Object obj = Reference to <table>
     * 
     * @private
     */	
	__addEndCol : function(obj)
	{	
		var rows = obj.getElementsByTagName('TR');
		for(var no=0;no<rows.length;no++){
			var cell = rows[no].insertCell(rows[no].cells.length);
			cell.innerHTML = '<img src="' + DHTMLSuite.configObj.imagePath + 'transparent.gif" width="10" style="visibility:hidden">';
			cell.style.width = '13px';
			cell.width = '13';
			cell.style.overflow='hidden';
		}	
		
	}	
	// }}}
	,
	
	// {{{ __highlightTableHeader()
    /**
     *  Mouse over event: Highlights header cell on mouse over, i.e. applies an orange line at the top.
     *
     * 
     * @private
     */	
	__highlightTableHeader : function()
	{
		// Here, "this" is a reference to the HTML tag triggering this event and not the table widget object
		this.className='DHTMLSuite_tableWigdet_headerCellOver';
		if(document.all){	// I.E fix for "jumping" headings
			var divObj = this.parentNode.parentNode.parentNode.parentNode;
			this.parentNode.style.top = divObj.scrollTop + 'px';	
		}		
	}
	// }}}	
	,
	
	// {{{ __deHighlightTableHeader()
    /**
     *  Mouse out event: Remove the orange line at the top of header cells when the mouse moves away from the cell.
     *
     * 
     * @private
     */	
	__deHighlightTableHeader : function()
	{
		// Here, "this" is a reference to the HTML tag triggering this event and not the table widget object
		this.className='DHTMLSuite_tableWidget_headerCell';		
	}	
	// }}}
	,
	
	// {{{ __mousedownTableHeader()
    /**
     *  Mouse down event header cells. It changes the color of the header from light gray to dark gray.
     * 
     * @private
     */	
	__mousedownTableHeader : function()
	{
		// Here, "this" is a reference to the HTML tag triggering this event and not the table widget object
		this.className='DHTMLSuite_tableWigdet_headerCellDown';
		if(document.all){	// I.E fix for "jumping" headings
			var divObj = this.parentNode.parentNode.parentNode.parentNode;
			this.parentNode.style.top = divObj.scrollTop + 'px';
		}		
	}
	// }}}
	,
	
	// {{{ __sortNumeric()
    /**
     *  Sort the table numerically
	 *	ps! If you know that your tables always contains valid numbers(i.e. digits or decimal numbers like 7 and 7.5), 
	 * 	then you can remove everything except return a/1 - b/1; from this function. By removing these lines, the sort
	 *	process be faster.     
     *
     * @param String a = first number to compare
     * @param String b = second number to compare
     * 
     * @private
     */	
	__sortNumeric : function(a,b){
		// changing commas(,) to periods(.)
		a = a.replace(/,/,'.');
		b = b.replace(/,/,'.');
		// Remove non digit characters - example changing "DHTML12.5" to "12.5"
		a = a.replace(/[^\d\.\/]/g,'');
		b = b.replace(/[^\d\.\/]/g,'');
		// Dealing with fractions(example: changing 4/5 to 0.8)
		if(a.indexOf('/')>=0)a = eval(a);
		if(b.indexOf('/')>=0)b = eval(b);
		return a/1 - b/1;
	}	
	// }}}
	,
	
	// {{{ __sortString()
    /**
     *  Sort the table alphabetically
     *
     * @param String a = first number to compare
     * @param String b = second number to compare
     * 
     * @private
     */	
	__sortString : function(a, b) {
	
	  if ( a.toUpperCase() < b.toUpperCase() ) return -1;
	  if ( a.toUpperCase() > b.toUpperCase() ) return 1;
	  return 0;
	}
	// }}}	
	,
	
	// {{{ __cancelTableWidgetEvent()
    /**
     *  Cancel text selection in the header cells in Internet Explorer
     * 
     * @private
     */	
	__cancelTableWidgetEvent : function()
	{
		return false;
	}
	// }}}
	,
	__parseDataContentFromServer : function(ajaxIndex)
	{
		var content = DHTMLSuite.variableStorage.ajaxObjects[ajaxIndex].response;
		if(content.indexOf('|||')==-1 && content.indexOf('###')==-1){
			alert('Error in data from server\n'+content);
			return;
		}
		
		this.__clearDataRows();	// Clear existing data
		var rows = content.split('|||');	// Create an array of each row
		for(var no=0;no<rows.length;no++){
			var items = rows[no].split('###');
			if(items.length>1)this.__fillDataRow(items);
			
		}	
		this.__parseDataRows(this.tableObj);
	}
	
	// }}}
	,
	// {{{ __clearDataRows()
    /**
     * This method clear all data from the table(except header cells).
     *
     * 
     * @private
     */		
	__clearDataRows : function()
	{
		if(!this.tableObj)this.tableObj = document.getElementById(this.idOfTable);
		while(this.tableObj.rows.length>1){
			this.tableObj.rows[this.tableObj.rows.length-1].parentNode.removeChild(this.tableObj.rows[this.tableObj.rows.length-1]);	
		}
	}
	
	// }}
	,
	// {{{ __fillDataRow()
    /**
     * Adds a new row of data to the table.
     *
     * @param Array data = Array of data
     * 
     * @private
     */		
	__fillDataRow : function(data)
	{
		if(!this.tableObj)this.tableObj = document.getElementById(this.idOfTable);
		var tbody = this.tableObj.getElementsByTagName('TBODY')[0];
		var row = tbody.insertRow(-1);
		for(var no=0;no<data.length;no++){
			var cell = row.insertCell(no);
			cell.innerHTML = data[no];
		}
		
	}
	// }}}
	,
	// {{{ __autoSetColumnWidth()
    /**
     * This method adds width attributes to the table rows
     *
     * 
     * @private
     */			
	__autoSetColumnWidth : function()
	{
		return;
		if(!this.tableObj)this.tableObj = document.getElementById(this.idOfTable);
		var colgroup = this.tableObj.getElementsByTagName('COLGROUP')[0];
		if(!colgroup){

			colgroup = document.createElement('COLGROUP');
			this.tableObj.insertBefore(colgroup,this.tableObj.firstChild);
			
			var noCells = this.tableObj.getElementsByTagName('TR')[0].cells.length;

			for(var no=0;no<noCells;no++){
				var col = document.createElement('COL');
				colgroup.appendChild(col);
			}
		}
		
		var cols = colgroup.getElementsByTagName('COL');
		var cells = this.tableObj.getElementsByTagName('TR')[1].cells;
		
		for(var no=0;no<cells.length;no++){
			if(!cols[no].style.width)cols[no].style.width = cells[no].clientWidth + 'px';
		}
		
	}	
	// }}}
	,
	// {{{ updateTableHeader()
    /**
     * Updates the header of the table,i.e. shows the correct arrow. This is a method you call if you're sorting the table on the server
     *
     *
     * @param Integer columnIndex = Index of column the table is currently sorted by
     * @param String direction = How the table is sorted(ascending or descending)
     * 
     * @public
     */		
	updateTableHeader : function(columnIndex,direction)
	{
		var tableObj = document.getElementById(this.idOfTable);
		var firstRow = tableObj.rows[0];
		var tds = firstRow.cells;
		var tdObj = tds[columnIndex];
		tdObj.setAttribute('direction',direction);
		tdObj.direction = direction;
		var sortBy = tdObj.getAttribute('sortBy');
		if(!sortBy)sortBy = tdObj.sortBy;
		this.tableCurrentlySortedBy = sortBy;
		this.__updateSortArrow(tdObj,direction);		
	}
	// }}}
	,	
	// {{{ __updateSortArrow()
    /**
     * Sort table - This method is called when someone clicks on the header of one of the sortable columns
     *
     * @param Object obj = reference to header cell
     * @param String direction = How the table is sorted(ascending or descending)
     * 
     * @private
     */		
	__updateSortArrow : function(obj,direction)
	{
		var images = obj.getElementsByTagName('IMG');	// Array of the images inside the clicked header cell(i.e. arrow up and down)
		if(direction=='descending'){	// Setting visibility of arrow image based on sort(ascending or descending)
			images[0].src = images[0].src.replace('arrow_up','arrow_down');
			images[0].style.visibility='visible';
		}else{
			images[0].src = images[0].src.replace('arrow_down','arrow_up');
			images[0].style.visibility='visible';
		}		
		if(this.activeColumn && this.activeColumn!=obj){
			var images = this.activeColumn.getElementsByTagName('IMG');
			images[0].style.visibility='hidden';
			this.activeColumn.removeAttribute('direction');			
		}		
		
		this.activeColumn = obj;	// Setting this.activeColumn to the cell trigger this method 

	}
	
	// }}}
	,
	__getItemsFromServer : function()
	{
		var objIndex = this.objectIndex;	
		var url = this.serversideSortFileName + '?sortBy=' + this.tableCurrentlySortedBy + '&numberOfRows=' + this.serversideSortNumberOfRows + '&sortAscending=' + this.serversideSortAscending + '&startIndex=' + this.serversideSortCurrentStartIndex + this.serversideSortExtraSearchCriterias;
		var index = DHTMLSuite.variableStorage.ajaxObjects.length;	
		try{
			DHTMLSuite.variableStorage.ajaxObjects[index] = new sack();
		}catch(e){	// Unable to create ajax object - send alert message and return from sort method.
			alert('Unable to create ajax object. Please make sure that the sack js file is included on your page');	
			return;
		}
		DHTMLSuite.variableStorage.ajaxObjects[index].requestFile = url;	// Specifying which file to get
		DHTMLSuite.variableStorage.ajaxObjects[index].onCompletion = function(){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[objIndex].__parseDataContentFromServer(index); };	// Specify function that will be executed after file has been found
		DHTMLSuite.variableStorage.ajaxObjects[index].runAJAX();		// Execute AJAX function	
	}	
	// }}}
	,
	
	// {{{ __sortTable()
    /**
     * Sort table - This method is called when someone clicks on the header of one of the sortable columns
     *
     * @param Object obj = reference to header cell triggering the sortTable method
     * 
     * @private
     */	
	__sortTable : function(obj)
	{
		// "this" is a reference to the table widget obj
		// "obj" is a reference to the header cell triggering the sortTable method.
		
		// Server side sort ?
		if(this.serversideSort){
			// tableCurrentlySortedBy
					

			if(!this.serversideSortFileName){	// Server side file name defined.
				alert('No server side file defined. Use the setServersideSortFileName to specify where to send the ajax request');
				return;
			}
			var sortBy = obj.getAttribute('sortBy');
			if(!sortBy)sortBy = obj.sortBy;
			if(!sortBy){
				alert('Sort is not defined. Remember to set a sortBy attribute on the header <td> tags');
				return;
			}
			if(sortBy==this.tableCurrentlySortedBy)this.serversideSortAscending = !this.serversideSortAscending;else this.serversideSortAscending = true;
			
			this.tableCurrentlySortedBy = sortBy;
			this.serversideSortCurrentStartIndex =0;
			this.__getItemsFromServer();	
			
			if(this.pageHandler)this.pageHandler.__resetActivePageNumber();		
			this.__updateSortArrow(obj,this.serversideSortAscending?'ascending':'descending');
			
			return;	
		}
		
		
		
		if(!this.tableWidget_okToSort)return;
		this.tableWidget_okToSort = false;
		/* Getting index of current column */

		var indexThis = 0;
		
		var tmpObj = obj;
		while(tmpObj.previousSibling){
			tmpObj = tmpObj.previousSibling;
			if(tmpObj.tagName=='TD')indexThis++;		
		}		
		if(obj.getAttribute('direction') || obj.direction){	// Determine if we should sort ascending or descending
			direction = obj.getAttribute('direction');
			if(navigator.userAgent.indexOf('Opera')>=0)direction = obj.direction;
			if(direction=='ascending'){
				direction = 'descending';
				obj.setAttribute('direction','descending');
				obj.direction = 'descending';	
			}else{
				direction = 'ascending';
				obj.setAttribute('direction','ascending');		
				obj.direction = 'ascending';		
			}
		}else{
			direction = 'ascending';
			obj.setAttribute('direction','ascending');
			obj.direction = 'ascending';
		}		

		this.__updateSortArrow(obj,direction);
				
		var tableObj = obj.parentNode.parentNode.parentNode;
		var tBody = tableObj.getElementsByTagName('TBODY')[0];
		
		var widgetIndex = tableObj.id.replace(/[^\d]/g,'');
		var sortMethod = this.columnSortArray[indexThis]; // N = numeric, S = String
		

		var cellArray = new Array();
		var cellObjArray = new Array();
		for(var no=1;no<tableObj.rows.length;no++){
			var content= tableObj.rows[no].cells[indexThis].innerHTML+'';
			cellArray.push(content);
			cellObjArray.push(tableObj.rows[no].cells[indexThis]);
		}
		// Calling sort methods
		if(sortMethod=='N'){
			cellArray = cellArray.sort(this.__sortNumeric);
		}else{
			cellArray = cellArray.sort(this.__sortString);
		}
		if(direction=='descending'){
			for(var no=cellArray.length;no>=0;no--){
				for(var no2=0;no2<cellObjArray.length;no2++){
					if(cellObjArray[no2].innerHTML == cellArray[no] && !cellObjArray[no2].getAttribute('allreadySorted')){
						cellObjArray[no2].setAttribute('allreadySorted','1');	
						tBody.appendChild(cellObjArray[no2].parentNode);				
					}				
				}			
			}
		}else{
			for(var no=0;no<cellArray.length;no++){
				for(var no2=0;no2<cellObjArray.length;no2++){
					if(cellObjArray[no2].innerHTML == cellArray[no] && !cellObjArray[no2].getAttribute('allreadySorted')){
						cellObjArray[no2].setAttribute('allreadySorted','1');	
						tBody.appendChild(cellObjArray[no2].parentNode);				
					}				
				}			
			}				
		}		
		for(var no2=0;no2<cellObjArray.length;no2++){
			cellObjArray[no2].removeAttribute('allreadySorted');		
		}	
		this.tableWidget_okToSort = true;		
	}	
	// }}}
	,
	
	// {{{ __highlightDataRow()
    /**
     *  Highlight data row on mouse over, i.e. applying css class tableWidget_dataRollOver
     *	To change the layout, look inside table-widget.css
     *
     * 
     * @private
     */	
	__highlightDataRow : function()
	{
		if(navigator.userAgent.indexOf('Opera')>=0)return;
		this.className='DHTMLSuite_tableWidget_dataRollOver';
		if(document.all){	// I.E fix for "jumping" headings
			var divObj = this.parentNode.parentNode.parentNode;
			var tHead = divObj.getElementsByTagName('TR')[0];
			tHead.style.top = divObj.scrollTop + 'px';			
		}	
	}
	// }}}
	,
	// {{{ __deHighlightDataRow()
    /**
     * Reset data row layout when mouse moves away from it.
     * 
     * @private
     */	
	__deHighlightDataRow : function()
	{
		if(navigator.userAgent.indexOf('Opera')>=0)return;
		this.className=null;
		if(document.all){	// I.E fix for "jumping" headings
			var divObj = this.parentNode.parentNode.parentNode;
			var tHead = divObj.getElementsByTagName('TR')[0];
			tHead.style.top = divObj.scrollTop + 'px';
		}			
	}	
	// }}}		
}	

/*[FILE_START:dhtmlSuite-dragDrop.js] */
/************************************************************************************************************
*	Drag and drop class
*
*	Created:			August, 18th, 2006
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	A general drag and drop class. By creating objects of this class, you can make elements
*		 on your web page dragable and also assign actions to element when an item is dropped on it.
*		 A page should only have one object of this class.<br>
*		<br>
*		IMPORTANT when you use this class: Don't assign layout to the dragable element ids
*		Assign it to classes or the tag instead. example: If you make <div id="dragableBox1" class="aBox">
*		dragable, don't assign css to #dragableBox1. Assign it to div or .aBox instead.<br>
*		(<a href="../../demos/demo-drag-drop-1.html" target="_blank">demo 1</a>, <a href="../../demos/demo-drag-drop-2.html" target="_blank">demo 2</a>),
*		<a href="../../demos/demo-drag-drop-3.html" target="_blank">demo 3</a>, <a href="../../demos/demo-drag-drop-4.html" target="_blank">demo 4</a>
*		and <a href="../../demos/demo-drag-drop-4.html" target="_blank">demo 5</a>)
* @version				1.0
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/


DHTMLSuite.dragDrop = function()
{
	var mouse_x;					// mouse x position when drag is started
	var mouse_y;					// mouse y position when drag is started.
	
	var el_x;						// x position of dragable element
	var el_y;						// y position of dragable element
	
	var dragDropTimer;				// Timer - short delay from mouse down to drag init.
	var numericIdToBeDragged;		// numeric reference to element currently being dragged.
	var dragObjCloneArray;			// Array of cloned dragable elements. every
	var dragDropSourcesArray;		// Array of source elements, i.e. dragable elements.
	var dragDropTargetArray;		// Array of target elements, i.e. elements where items could be dropped.
	var currentZIndex;				// Current z index. incremented on each drag so that currently dragged element is always on top.
	var okToStartDrag;				// Variable which is true or false. It would be false for 1/100 seconds after a drag has been started.
									// This is useful when you have nested dragable elements. It prevents the drag process from staring on
									// parent element when you click on dragable sub element.
	var moveBackBySliding;			// Variable indicating if objects should slide into place moved back to their location without any slide animation.
	var dragX_allowed;				// Possible to drag this element along the x-axis?
	var dragY_allowed;				// Possible to drag this element along the y-axis?
	
	var currentEl_allowX;
	var currentEl_allowY;
	var drag_minX;
	var drag_maxX;
	var drag_minY;
	var drag_maxY;
	var dragInProgress;				// Variable which is true when drag is in progress, false otherwise
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	// This line starts all the init methods
	
	this.dragX_allowed = true;
	this.dragY_allowed = true;
	this.currentZIndex = 21000;
	this.dragDropTimer = -1;
	this.dragObjCloneArray = new Array();
	this.numericIdToBeDragged = false;	

	this.okToStartDrag = true;
	this.moveBackBySliding = true;	  
	this.dragInProgress = false;
	
	var objectIndex;
	this.objectIndex = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects.length;
	DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[this.objectIndex] = this;
		
}

DHTMLSuite.dragDrop.prototype = {
	
	// {{{ init()
    /**
     * Initialize the script
     * This method should be called after you have added sources and destinations.
     * 
     * @public
     */	
	init : function()
	{
		this.__initDragDropScript();	

	}
	// }}}	
	,
	// {{{ addSource()
    /**
     * Add dragable element
     *
     * @param String sourceId = Id of source
     * @param boolean slideBackAfterDrop = Slide the item back to it's original location after drop.
     * @param boolean xAxis = Allowed to slide along the x-axis(default = true, i.e. if omitted).
     * @param boolean yAxis = Allowed to slide along the y-axis(default = true, i.e. if omitted).
     * @param String dragOnlyWithinElId = You will only allow this element to be dragged within the boundaries of the element with this id.
     * 
     * @public
     */	
	addSource : function(sourceId,slideBackAfterDrop,xAxis,yAxis,dragOnlyWithinElId)
	{
		if(!this.dragDropSourcesArray)this.dragDropSourcesArray = new Array();
		if(!document.getElementById(sourceId)){
			alert('The source element with id ' + sourceId + ' does not exists. Check your HTML code');
			return;
		}
		if(xAxis!==false)xAxis = true;
		if(yAxis!==false)yAxis = true;
		var obj = document.getElementById(sourceId);
		this.dragDropSourcesArray[this.dragDropSourcesArray.length]  = [obj,slideBackAfterDrop,xAxis,yAxis,dragOnlyWithinElId];		
		obj.setAttribute('dragableElement',this.dragDropSourcesArray.length-1);
		obj.dragableElement = this.dragDropSourcesArray.length-1;
		
	}
	// }}}	
	,
	// {{{ addTarget()
    /**
     * Add drop target
     *
     * @param String targetId = Id of drop target
     * @param String functionToCallOnDrop = name of function to call on drop. 
	 *		Input to this the function specified in functionToCallOnDrop function would be 
	 *		id of dragged element 
	 *		id of the element the item was dropped on.
	 *		mouse x coordinate when item was dropped
	 *		mouse y coordinate when item was dropped     
     * 
     * @public
     */	
	addTarget : function(targetId,functionToCallOnDrop)
	{
		if(!this.dragDropTargetArray)this.dragDropTargetArray = new Array();
		if(!document.getElementById(targetId))alert('The target element with id ' + targetId + ' does not exists.  Check your HTML code');
		var obj = document.getElementById(targetId);
		this.dragDropTargetArray[this.dragDropTargetArray.length]  = [obj,functionToCallOnDrop];		
	}
	// }}}	
	,
	
	// {{{ setSlide()
    /**
     * Activate or deactivate sliding animations.
     *
     * @param boolean slide = Move element back to orig. location in a sliding animation
     * 
     * @public
     */	
	setSlide : function(slide)
	{
		this.moveBackBySliding = slide;	
		
	}
	// }}}	
	,
	
	/* Start private methods */
	
	// {{{ __initDragDropScript()
    /**
     * Initialize drag drop script - this method is called by the init() method.
     * 
     * @private
     */	
	__initDragDropScript : function()
	{
		var ind = this.objectIndex;
		var refToThis = this;
		var startIndex = Math.random() + '';
		startIndex = startIndex.replace('.','')/1;
		
		for(var no=0;no<this.dragDropSourcesArray.length;no++){
			var el = this.dragDropSourcesArray[no][0].cloneNode(true);
			
			eval("el.onmousedown =function(e,index){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[" + ind + "].__initDragDropElement(e," + no + "); }");	
			DHTMLSuite.commonObj.__addEventElement(el);
			var tmpIndex = startIndex + no;
			el.id = 'DHTMLSuite_dragableElement' + tmpIndex;
			el.style.position='absolute';
			el.style.visibility='hidden';
			el.style.display='none';			
			// 2006/12/02 - Changed the line below because of positioning problems.
			document.body.appendChild(el);			
			//this.dragDropSourcesArray[no][0].parentNode.insertBefore(el,this.dragDropSourcesArray[no][0]);
			
			el.style.top = DHTMLSuite.commonObj.getTopPos(this.dragDropSourcesArray[no][0]) + 'px';
			el.style.left = DHTMLSuite.commonObj.getLeftPos(this.dragDropSourcesArray[no][0]) + 'px';
					
			eval("this.dragDropSourcesArray[" + no + "][0].onmousedown =function(e,index){ return DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[" + ind + "].__initDragDropElement(e," + no + "); }");	
			DHTMLSuite.commonObj.__addEventElement(this.dragDropSourcesArray[no][0]);						
			this.dragObjCloneArray[no] = el; 
		}
		
		eval("DHTMLSuite.commonObj.addEvent(document.documentElement,\"mousemove\",function(e){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[" + ind + "].__moveDragableElement(e); } )");
		eval("DHTMLSuite.commonObj.addEvent(document.documentElement,\"mouseup\",function(e){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[" + ind + "].__stop_dragDropElement(e); } );");
		
		if(!document.documentElement.onselectstart)document.documentElement.onselectstart = function() { return DHTMLSuite.commonObj.__getOkToSelect(); };
		document.documentElement.ondragstart = function() { return DHTMLSuite.commonObj.cancelEvent() };		

		
		DHTMLSuite.commonObj.__addEventElement(document.documentElement);
		
	}	
	// }}}	
	,	
	
	// {{{ __initDragDropElement()
    /**
     * Initialize drag process
     *
     * @param Event e = Event object, used to get x and y coordinate of mouse pointer
     * 
     * @private
     */	
	__initDragDropElement : function(e,index)
	{
		var ind = this.objectIndex;
		
		if(!this.okToStartDrag)return false; 
	
		setTimeout('DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[' + ind + '].okToStartDrag = true;',100);
		if(document.all)e = event;

		this.numericIdToBeDragged = index;
		this.numericIdToBeDragged = this.numericIdToBeDragged + '';

		this.dragDropTimer=0;
		DHTMLSuite.commonObj.__setOkToSelect(false);
		this.mouse_x = e.clientX;
		this.mouse_y = e.clientY;
		
		this.currentZIndex = this.currentZIndex + 1;
		
		this.dragObjCloneArray[this.numericIdToBeDragged].style.zIndex = this.currentZIndex;
		
		
	
		this.currentEl_allowX = this.dragDropSourcesArray[this.numericIdToBeDragged][2];
		this.currentEl_allowY = this.dragDropSourcesArray[this.numericIdToBeDragged][3];

		var parentEl = this.dragDropSourcesArray[this.numericIdToBeDragged][4];
		this.drag_minX = false;
		this.drag_minY = false;
		this.drag_maxX = false;
		this.drag_maxY = false;
		if(parentEl){
			var obj = document.getElementById(parentEl);
			if(obj){
				this.drag_minX = DHTMLSuite.commonObj.getLeftPos(obj);
				this.drag_minY = DHTMLSuite.commonObj.getTopPos(obj);
				this.drag_maxX = this.drag_minX + obj.clientWidth;
				this.drag_maxY = this.drag_minY + obj.clientHeight;				
			}		
		}		
		
		
		// Reposition dragable element
		if(this.dragDropSourcesArray[this.numericIdToBeDragged][1]){
			this.dragObjCloneArray[this.numericIdToBeDragged].style.top = DHTMLSuite.commonObj.getTopPos(this.dragDropSourcesArray[this.numericIdToBeDragged][0]) + 'px';
			this.dragObjCloneArray[this.numericIdToBeDragged].style.left = DHTMLSuite.commonObj.getLeftPos(this.dragDropSourcesArray[this.numericIdToBeDragged][0]) + 'px';
		}
		this.el_x = this.dragObjCloneArray[this.numericIdToBeDragged].style.left.replace('px','')/1;
		this.el_y = this.dragObjCloneArray[this.numericIdToBeDragged].style.top.replace('px','')/1;
				
		this.__timerDragDropElement();
				
		return false;
	}	
	// }}}	
	,
	
	// {{{ __timerDragDropElement()
    /**
     * A small delay from mouse down to drag starts 
     * 
     * @private
     */	
	__timerDragDropElement : function()
	{
		var ind = this.objectIndex;
		
		if(this.dragDropTimer>=0 && this.dragDropTimer<5){
			this.dragDropTimer = this.dragDropTimer + 1;
			setTimeout('DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[' + ind + '].__timerDragDropElement()',2);
			return;			
		}
		if(this.dragDropTimer>=5){
			if(this.dragObjCloneArray[this.numericIdToBeDragged].style.display=='none'){
				this.dragDropSourcesArray[this.numericIdToBeDragged][0].style.visibility = 'hidden';
				this.dragObjCloneArray[this.numericIdToBeDragged].style.display = 'block';
				this.dragObjCloneArray[this.numericIdToBeDragged].style.visibility = 'visible';
				this.dragObjCloneArray[this.numericIdToBeDragged].style.top = DHTMLSuite.commonObj.getTopPos(this.dragDropSourcesArray[this.numericIdToBeDragged][0]) + 'px';
				this.dragObjCloneArray[this.numericIdToBeDragged].style.left = DHTMLSuite.commonObj.getLeftPos(this.dragDropSourcesArray[this.numericIdToBeDragged][0]) + 'px';
			}
		}		
	}	
	// }}}	
	,
	// {{{ __moveDragableElement()
    /**
     * Move dragable element according to mouse position when drag is in process.
     *
     * @param Event e = Event object, used to get x and y coordinate of mouse pointer
     * 
     * @private
     */	
	__moveDragableElement : function(e)
	{
		var ind = this.objectIndex;		
		if(document.all)e = event;		
		if(this.dragDropTimer<5)return false;	
		if(this.dragInProgress)return false;
		this.dragInProgress = true;
		var dragObj = this.dragObjCloneArray[this.numericIdToBeDragged];
		
		if(this.currentEl_allowX){			
			
			var leftPos = (e.clientX - this.mouse_x + this.el_x);
			if(this.drag_maxX){
				var tmpMaxX = this.drag_maxX - dragObj.offsetWidth;
				if(leftPos > tmpMaxX)leftPos = tmpMaxX
				if(leftPos < this.drag_minX)leftPos = this.drag_minX;				
			}
			dragObj.style.left = leftPos + 'px'; 
		
		}	
		if(this.currentEl_allowY){
			var topPos = (e.clientY - this.mouse_y + this.el_y);
			if(this.drag_maxY){	
				var tmpMaxY = this.drag_maxY - dragObj.offsetHeight;		
				if(topPos > tmpMaxY)topPos = tmpMaxY;
				if(topPos < this.drag_minY)topPos = this.drag_minY;	
				
			}			
			
			dragObj.style.top = topPos + 'px'; 
		}
		this.dragInProgress = false;
		return false;
	}
	// }}}	
	,
	
	// {{{ __stop_dragDropElement()
    /**
     * Drag process stopped.
     *
     * @param Event e = Event object, used to get x and y coordinate of mouse pointer
     * 
     * @private
     */	
	__stop_dragDropElement : function(e)
	{
		if(this.dragDropTimer<5)return false;
		if(document.all)e = event;
			
		// Dropped on which element
		var dropDestination = DHTMLSuite.commonObj.getSrcElement(e);
		
	
		
		var leftPosMouse = e.clientX + Math.max(document.body.scrollLeft,document.documentElement.scrollLeft);
		var topPosMouse = e.clientY + Math.max(document.body.scrollTop,document.documentElement.scrollTop);
		
		if(!this.dragDropTargetArray)this.dragDropTargetArray = new Array();
		// Loop through drop targets and check if the coordinate of the mouse is over it. If it is, call specified drop function.
		for(var no=0;no<this.dragDropTargetArray.length;no++){
			var leftPosEl = DHTMLSuite.commonObj.getLeftPos(this.dragDropTargetArray[no][0]);
			var topPosEl = DHTMLSuite.commonObj.getTopPos(this.dragDropTargetArray[no][0]);
			var widthEl = this.dragDropTargetArray[no][0].offsetWidth;
			var heightEl = this.dragDropTargetArray[no][0].offsetHeight;
			
			if(leftPosMouse > leftPosEl && leftPosMouse < (leftPosEl + widthEl) && topPosMouse > topPosEl && topPosMouse < (topPosEl + heightEl)){
				if(this.dragDropTargetArray[no][1]){
					try{
						eval(this.dragDropTargetArray[no][1] + '("' + this.dragDropSourcesArray[this.numericIdToBeDragged][0].id + '","' + this.dragDropTargetArray[no][0].id + '",' + e.clientX + ',' + e.clientY + ')');
					}catch(e){
						alert('Unable to execute \n' + this.dragDropTargetArray[no][1] + '("' + this.dragDropSourcesArray[this.numericIdToBeDragged][0].id + '","' + this.dragDropTargetArray[no][0].id + '",' + e.clientX + ',' + e.clientY + ')');
					}
				}
				
				break;
			}			
		}	
		
		if(this.dragDropSourcesArray[this.numericIdToBeDragged][1]){
			this.__slideElementBackIntoItsOriginalPosition(this.numericIdToBeDragged);
		}
		
		// Variable cleanup after drop
		this.dragDropTimer = -1;
		
		DHTMLSuite.commonObj.__setOkToSelect(true);
		this.numericIdToBeDragged = false;
									
	}	
	// }}}	
	,
	
	// {{{ __slideElementBackIntoItsOriginalPosition()
    /**
     * Slide an item back to it's original position
     *
     * @param Integer numId = numeric index of currently dragged element	
     * 
     * @private
     */	
	__slideElementBackIntoItsOriginalPosition : function(numId)
	{
		// Coordinates current element position
		var currentX = this.dragObjCloneArray[numId].style.left.replace('px','')/1;
		var currentY = this.dragObjCloneArray[numId].style.top.replace('px','')/1;
		
		// Coordinates - where it should slide to
		var targetX = DHTMLSuite.commonObj.getLeftPos(this.dragDropSourcesArray[numId][0]);
		var targetY = DHTMLSuite.commonObj.getTopPos(this.dragDropSourcesArray[numId][0]);;
		
		if(this.moveBackBySliding){
			// Call the step by step slide method
			this.__processSlide(numId,currentX,currentY,targetX,targetY);
		}else{
			this.dragObjCloneArray[numId].style.display='none';
			this.dragDropSourcesArray[numId][0].style.visibility = 'visible';			
		}
			
	}
	// }}}	
	,
	
	// {{{ __processSlide()
    /**
     * Move the element step by step in this method
     *
     * @param Int numId = numeric index of currently dragged element
     * @param Int currentX = Elements current X position
     * @param Int currentY = Elements current Y position
     * @param Int targetX = Destination X position, i.e. where the element should slide to
     * @param Int targetY = Destination Y position, i.e. where the element should slide to
     * 
     * @private
     */	
	__processSlide : function(numId,currentX,currentY,targetX,targetY)
	{				
		// Find slide x value
		var slideX = Math.round(Math.abs(Math.max(currentX,targetX) - Math.min(currentX,targetX)) / 10);		
		// Find slide y value
		var slideY = Math.round(Math.abs(Math.max(currentY,targetY) - Math.min(currentY,targetY)) / 10);
		
		if(slideY<3 && Math.abs(slideX)<10)slideY = 3;	// 3 is minimum slide value
		if(slideX<3 && Math.abs(slideY)<10)slideX = 3;	// 3 is minimum slide value
		
		
		if(currentX > targetX) slideX*=-1;	// If current x is larger than target x, make slide value negative<br>
		if(currentY > targetY) slideY*=-1;	// If current y is larger than target x, make slide value negative
		
		// Update currentX and currentY
		currentX = currentX + slideX;	
		currentY = currentY + slideY;

		// If currentX or currentY is close to targetX or targetY, make currentX equal to targetX(or currentY equal to targetY)
		if(Math.max(currentX,targetX) - Math.min(currentX,targetX) < 4)currentX = targetX;
		if(Math.max(currentY,targetY) - Math.min(currentY,targetY) < 4)currentY = targetY;

		// Update CSS position(left and top)
		this.dragObjCloneArray[numId].style.left = currentX + 'px';
		this.dragObjCloneArray[numId].style.top = currentY + 'px';	
		
		// currentX different than targetX or currentY different than targetY, call this function in again in 5 milliseconds
		if(currentX!=targetX || currentY != targetY){
			window.thisRef = this;	// Reference to this dragdrop object
			setTimeout('window.thisRef.__processSlide("' + numId + '",' + currentX + ',' + currentY + ',' + targetX + ',' + targetY + ')',5);
		}else{	// Slide completed. Make absolute positioned element invisible and original element visible
			this.dragObjCloneArray[numId].style.display='none';
			this.dragDropSourcesArray[numId][0].style.visibility = 'visible';
		}		
	}
}

/*[FILE_START:dhtmlSuite-tabView.js] */	
/************************************************************************************************************
*	Tab view class
*
*	Created:			August, 21st, 2006
*
* 	Update log:
*
************************************************************************************************************/

	
var refToTabViewObjects = new Array();	// Reference to objects of this class. 
										// We need this because the script doesn't allways know which object to use

/**
* @constructor
* @class Purpose of class:	Tab view class - transfors plain HTML into tabable layers.<br>
* (See <a target="_blank" href="../../demos/demo-tabs-1.html">demo 1</A> and <a target="_blank" href="../../demos/demo-tabs-2.html">demo 2</A>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/

DHTMLSuite.tabView = function()
{
	var textPadding;				// Tab spacing
	var strictDocType ; 			// Using a strict document type, i.e. <!DOCTYPE>
	var tabView_maxNumberOfTabs;	// Maximum number of tabs - initial value = 6

	var DHTMLSuite_tabObj;		// Reference to div surrounding the tab set
	var activeTabIndex;				// Currently displayed tab(index - 0 = first tab)
	var initActiveTabIndex;			// Initially displayed tab(index - 0 = first tab)
	var ajaxObjects;				// Reference to ajax objects
	var tabView_countTabs;
	var tabViewHeight;
	var tabSetParentId;				// Id of div surrounding the tab set.
	var tabTitles;					// Tab titles
	var width;						// width of tab view
	var height;						// height of tab view
	var layoutCSS;
	var outsideObjectRefIndex;		// Which index of refToTabViewObjects refers to this object.
	var maxNumberOfTabs;
	var dynamicContentObj;	
	var closeButtons;
	
	// Default variable values
	this.textPadding = 3;
	this.strictDocType = true; 	
	this.ajaxObjects = new Array();
	this.tabTitles = new Array();
	this.layoutCSS = 'tab-view.css';
	this.maxNumberOfTabs = 6;
	this.dynamicContentObj = false;
	this.closeButtons = new Array();
		
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	// This line starts all the init methods
	
}

DHTMLSuite.tabView.prototype = {
	// {{{ init()
    /**
     * Initialize the script
     * 
     * @public
     */	
	init : function()
	{
		
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);
		this.outsideObjectRefIndex = refToTabViewObjects.length;
		refToTabViewObjects[this.outsideObjectRefIndex] = this;
		this.dynamicContentObj = new DHTMLSuite.dynamicContent();
		this.__initTabs(false,false);
		
	}
	// }}}	
	,
	// {{{ setMaximumTabs()
    /**
     * Set maximum number of tabs
     * 
     * @param Int maxTabs = Maximum number of tabs
     *
     * @public
     */	
	setMaximumTabs : function(maxTabs)
	{
		this.maxNumberOfTabs = maxTabs;
	}   
    
    // }}}	
    ,
	// {{{ setParentId()
    /**
     * Set padding on tabs
     * 
     * @param String newParentDiv = id of parent div
     *
     * @public
     */	
	setParentId : function(newParentDiv)
	{
		this.tabSetParentId = newParentDiv;
		this.DHTMLSuite_tabObj = document.getElementById(newParentDiv);
	}   
    
    // }}}	
    ,
	// {{{ setWidth()
    /**
     * Set width of tab view
     * 
     * @param String Width of tab view
     *
     * @public
     */	
	setWidth : function(newWidth)
	{
		this.width = newWidth;
	}   
    
    // }}}	
    ,
	// {{{ setHeight()
    /**
     * Set height of tab view on tabs
     * 
     * @param String Height of tab view
     *
     * @public
     */	
	setHeight : function(newHeight)
	{
		this.height = newHeight;
	}   
    // }}}	
    ,	
	// {{{ setIndexActiveTab()
    /**
     * Set index of initially active tab
     * 
     * @param Int indexOfNewActiveTab = Index of active tab(0 = first tab)
     *
     * @public
     */	
	setIndexActiveTab : function(indexOfNewActiveTab)
	{
		this.initActiveTabIndex = indexOfNewActiveTab;
	}   
    
    // }}}	
    ,	
	// {{{ setTabTitles()
    /**
     * Set title of tabs
     * 
     * @param Array titleOfTabs = Title of tabs
     *
     * @public
     */	
	setTabTitles : function(titleOfTabs)
	{
		this.tabTitles = titleOfTabs;
	}    
    
    // }}}	
    ,	
	// {{{ setCloseButtons()
    /**
     * Specify which tabs that should have close buttons
     * 
     * @param Array closeButtons = Array of true or false
     *
     * @public
     */	
	setCloseButtons : function(closeButtons)
	{
		this.closeButtons = closeButtons;
	}    
    
    // }}}	
	,
	// {{{ createNewTab()
    /**
     * 
     * Creates new tab dynamically
     *
     * @param String parentId = Id of tabset
     * @param String tabTitle = Title of new tab
     * @param String tabContent = Content of new tab(Optional)
     * @param String tabContentUrl = Url to content of new tab(Optional) - Ajax is used to get this content
     *
     * @public
     */		
	createNewTab : function(parentId,tabTitle,tabContent,tabContentUrl,closeButton)
	{
		if(this.tabView_countTabs>=this.maxNumberOfTabs)return;	// Maximum number of tabs reached - return
		var div = document.createElement('DIV');	// Create new tab content div.
		div.className = 'DHTMLSuite_aTab';	// Assign new tab to CSS class DHTMLSuite_aTab
		this.DHTMLSuite_tabObj.appendChild(div);			// Appending new tab content div to main tab view div
		var tabId = this.__initTabs(true,tabTitle,closeButton);	// Call the init method in order to create tab header and tab images
		if(tabContent)div.innerHTML = tabContent;	// Static tab content specified, put it into the new div
		if(tabContentUrl){	// Get content from external file	
			this.dynamicContentObj.loadContent('tabView' + parentId +'_' + tabId,tabContentUrl);
		}				
	}	
	// }}}	    
    ,	
 	// {{{ deleteTab()
    /**
     *
     * Delete a tab 
     *
     * @param String tabLabel = Label of tab to delete(Optional)
     * @param Int tabIndex = Index of tab to delete(Optional)
     *
     * @public
     */		
	deleteTab : function(tabLabel,tabIndex)
	{		
		if(tabLabel){	// Delete tab by tab title
			var index = this.getTabIndexByTitle(tabLabel);	// Get index of tab
			if(index!=-1){	// Tab exists if index<>-1
				this.deleteTab(false,index);
			}
			
		}else if(tabIndex>=0){	// Delete tab by tab index.
			if(document.getElementById('tabTab' + this.tabSetParentId + '_' + tabIndex)){
				var obj = document.getElementById('tabTab' + this.tabSetParentId + '_' + tabIndex);
				var id = obj.parentNode.parentNode.id;
				obj.parentNode.removeChild(obj);
				var obj2 = document.getElementById('tabView' + this.tabSetParentId + '_' + tabIndex);
				obj2.parentNode.removeChild(obj2);
				this.__resetTabIds(this.tabSetParentId);
				this.initActiveTabIndex=-1;
				var newIndex = 0;
				if(refToTabViewObjects[this.outsideObjectRefIndex].activeTabIndex==tabIndex)refToTabViewObjects[this.outsideObjectRefIndex].activeTabIndex=-1;
				this.__showTab(this.tabSetParentId,newIndex,this.outsideObjectRefIndex);
			}			
		}		
	}
	// }}}	
	,  	// {{{ addContentToTab()
    /**
     * Add content to a tab dynamically.
     * 
     * @param String tabLabel = Label of tab to delete(Optional)
     * @param String filePath = Path to file you want to show inside the tab.
     *
     * @public
     */		
	addContentToTab : function(tabLabel,filePath)
	{		
		var index = this.getTabIndexByTitle(tabLabel);	// Get index of tab
		if(index!=-1){	// Tab found
			this.dynamicContentObj.loadContent('tabView' + this.tabSetParentId + '_' + index,filePath);		
		}
	}
	// }}}	
	, 
 	// {{{ displayATab()
    /**
     * Display a tab manually
     * 
     * @param String tabTitle = Label of tab to show(Optional)
     * @param Int tabIndex = Index of tab to show(Optional)
     *
     * @public
     */		

	displayATab : function(tabLabel,tabIndex)
	{		
		if(tabLabel){	// Delete tab by tab title
			var index = this.getTabIndexByTitle(tabLabel);	// Get index of tab
			if(index!=-1){	// Tab exists if index<>-1
				this.initActiveTabIndex = index;
			}else return false;
			
		}else{
			this.initActiveTabIndex = tabIndex;
		}

		this.__showTab(this.tabSetParentId,this.initActiveTabIndex,this.outsideObjectRefIndex)
	}	
	// }}}	
	,   
	
	
	// {{{ init()
    /**
     * Set padding on tabs
     * 
     * @private
     */		
	__setPadding : function(obj,padding){
		var span = obj.getElementsByTagName('SPAN')[0];
		span.style.paddingLeft = padding + 'px';	
		span.style.paddingRight = padding + 'px';	
	}	
	// }}}	
	,
	// {{{ __showTab()
    /**
     * Set padding
     * 
     * @param String parentId = id of parent div
     * @param Int tabIndex = Index of tab to show
     * @param Int objectIndex = Index of refToTabViewObjects, reference to the object of this class.
     *
     * @private
     */		
	__showTab : function(parentId,tabIndex,objectIndex)
	{
		var parentId_div = parentId + "_";
		if(!document.getElementById('tabView' + parentId_div + tabIndex)){			
			return;
		}
		
		if(refToTabViewObjects[objectIndex].activeTabIndex>=0){
			if(refToTabViewObjects[objectIndex].activeTabIndex==tabIndex){
				return;
			}	
			var obj = document.getElementById('tabTab'+parentId_div + refToTabViewObjects[objectIndex].activeTabIndex);	
			if(!obj){
				refToTabViewObjects[objectIndex].activeTabIndex = 0;
				var obj = document.getElementById('tabTab'+parentId_div + refToTabViewObjects[objectIndex].activeTabIndex);	
			}
			obj.className='tabInactive';
			obj.style.backgroundImage = 'url(\'' + DHTMLSuite.configObj.imagePath + 'tab_left_inactive.gif' + '\')';
			var imgs = obj.getElementsByTagName('IMG');
			var img = imgs[imgs.length-1];
			img.src = DHTMLSuite.configObj.imagePath + 'tab_right_inactive.gif';
			document.getElementById('tabView' + parentId_div + refToTabViewObjects[objectIndex].activeTabIndex).style.display='none';
		}
		
		var thisObj = document.getElementById('tabTab'+ parentId_div +tabIndex);	
			
		thisObj.className='tabActive';
		thisObj.style.backgroundImage = 'url(\'' + DHTMLSuite.configObj.imagePath + 'tab_left_active.gif' + '\')';
		var imgs = thisObj.getElementsByTagName('IMG');
		var img = imgs[imgs.length-1];		
		img.src = DHTMLSuite.configObj.imagePath + 'tab_right_active.gif';
		
		document.getElementById('tabView' + parentId_div + tabIndex).style.display='block';
		refToTabViewObjects[objectIndex].activeTabIndex = tabIndex;
		

		var parentObj = thisObj.parentNode;
		var aTab = parentObj.getElementsByTagName('DIV')[0];
		countObjects = 0;
		var startPos = 2;
		var previousObjectActive = false;
		while(aTab){
			if(aTab.tagName=='DIV'){
				if(previousObjectActive){
					previousObjectActive = false;
					startPos-=2;
				}
				if(aTab==thisObj){
					startPos-=2;
					previousObjectActive=true;
					refToTabViewObjects[objectIndex].__setPadding(aTab,refToTabViewObjects[objectIndex].textPadding+1);
				}else{
					refToTabViewObjects[objectIndex].__setPadding(aTab,refToTabViewObjects[objectIndex].textPadding);
				}
				
				aTab.style.left = startPos + 'px';
				countObjects++;
				startPos+=2;
			}			
			aTab = aTab.nextSibling;
		}
		
		return;
	}
	// }}}	
	,
	// {{{ tabClick()
    /**
     * Set padding
     * 
     * @param String parentId = id of parent div
     * @param Int tabIndex = Index of tab to show
     *
     * @private
     */	
	__tabClick : function(inputObj,index)
	{
		var idArray = inputObj.id.split('_');	
		var parentId = inputObj.getAttribute('parentRefId');
		if(!parentId)parentId=  inputObj.parentRefId;
		this.__showTab(parentId,idArray[idArray.length-1].replace(/[^0-9]/gi,''),index);
		
	}	
	// }}}
	,
	// {{{ rolloverTab()
    /**
     * Set padding
     * 
     *
     * @private
     */		
	__rolloverTab : function()
	{
		if(this.className.indexOf('tabInactive')>=0){
			this.className='inactiveTabOver';
			this.style.backgroundImage = 'url(\'' + DHTMLSuite.configObj.imagePath + 'tab_left_over.gif' + '\')';
			var imgs = this.getElementsByTagName('IMG');
			var img = imgs[imgs.length-1];
			
			img.src = DHTMLSuite.configObj.imagePath + 'tab_right_over.gif';
		}
		
	}	
	// }}}
	,	
	// {{{ rolloutTab()
    /**
     * 
     *
     * @private
     */			
	__rolloutTab : function()
	{
		if(this.className ==  'inactiveTabOver'){
			this.className='tabInactive';
			this.style.backgroundImage = 'url(\'' + DHTMLSuite.configObj.imagePath + 'tab_left_inactive.gif' + '\')';
			var imgs = this.getElementsByTagName('IMG');
			var img = imgs[imgs.length-1];
			img.src = DHTMLSuite.configObj.imagePath + 'tab_right_inactive.gif';
		}		
	}
	// }}}
	,
	// {{{ __initTabs()
    /**
     * 
     * @param Int additionalTab = Additional tabs to the existing
     * @param String nameOfAdditionalTab = Title of additional tab.
     *
     * @private
     */	
	__initTabs : function(additionalTab,nameOfAdditionalTab,additionalCloseButton)
	{
		this.DHTMLSuite_tabObj.className = ' DHTMLSuite_tabWidget';
		
		window.refToThisTabSet = this;
		if(!additionalTab || additionalTab=='undefined'){			
			this.DHTMLSuite_tabObj = document.getElementById(this.tabSetParentId);
			this.width = this.width + '';
			if(this.width.indexOf('%')<0)this.width= this.width + 'px';
			this.DHTMLSuite_tabObj.style.width = this.width;
						
			this.height = this.height + '';
			if(this.height.length>0){
				if(this.height.indexOf('%')<0)this.height= this.height + 'px';
				this.DHTMLSuite_tabObj.style.height = this.height;
			}
			
			var tabDiv = document.createElement('DIV');		
			var firstDiv = this.DHTMLSuite_tabObj.getElementsByTagName('DIV')[0];	
			
			this.DHTMLSuite_tabObj.insertBefore(tabDiv,firstDiv);	
			tabDiv.className = 'DHTMLSuite_tabContainer';			
			this.tabView_countTabs = 0;
			var tmpTabTitles = this.tabTitles;	// tmpTab titles set to current tab titles - this variable is used in the loop below
												// We don't want to loop through all the tab titles in the object when we add a new one manually.
			
		}else{	// A new tab being created dynamically afterwards.
			var tabDiv = this.DHTMLSuite_tabObj.getElementsByTagName('DIV')[0];
			var firstDiv = this.DHTMLSuite_tabObj.getElementsByTagName('DIV')[1];
			this.initActiveTabIndex = this.tabView_countTabs;		
			var tmpTabTitles = Array(nameOfAdditionalTab);	// tmpTab titles set to only the new tab
		}		
		
		
		
		for(var no=0;no<tmpTabTitles.length;no++){
			var aTab = document.createElement('DIV');
			aTab.id = 'tabTab' + this.tabSetParentId + "_" +  (no + this.tabView_countTabs);
			aTab.onmouseover = this.__rolloverTab;
			aTab.onmouseout = this.__rolloutTab;
			aTab.setAttribute('parentRefId',this.tabSetParentId);
			aTab.parentRefId = this.tabSetParentId;
			var numIndex = window.refToThisTabSet.outsideObjectRefIndex+'';
			aTab.onclick = function() { window.refToThisTabSet.__tabClick(this,numIndex); };
			DHTMLSuite.commonObj.__addEventElement(aTab);
			aTab.className='tabInactive';
			aTab.style.backgroundImage = 'url(\'' + DHTMLSuite.configObj.imagePath + 'tab_left_inactive.gif' + '\')';
			tabDiv.appendChild(aTab);
			var span = document.createElement('SPAN');
			span.innerHTML = tmpTabTitles[no];
			aTab.appendChild(span);

			if(this.closeButtons[no] || additionalCloseButton){
				var closeButton = document.createElement('IMG');
				closeButton.src = DHTMLSuite.configObj.imagePath + 'tab-view-close.gif';
				closeButton.style.position='absolute';
				closeButton.style.top = '4px';
				closeButton.style.right = '2px';
				closeButton.onmouseover = this.__hoverTabViewCloseButton;
				closeButton.onmouseout = this.__mouseOutTabViewCloseButton;
				DHTMLSuite.commonObj.__addEventElement(closeButton);
				span.innerHTML = span.innerHTML + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';	
				
				var deleteTxt = span.innerHTML+'';

				// function() { window.refToThisTabSet.__tabClick(this,numIndex); };
				closeButton.onclick = function(){ refToTabViewObjects[numIndex].deleteTab( this.parentNode.innerHTML) };
				span.appendChild(closeButton);
			}
						
			var img = document.createElement('IMG');
			img.valign = 'bottom';
			img.src = DHTMLSuite.configObj.imagePath + 'tab_right_inactive.gif';
			// IE5.X FIX
			if((DHTMLSuite.clientInfoObj.navigatorVersion && DHTMLSuite.clientInfoObj.navigatorVersion<6) || (DHTMLSuite.clientInfoObj.isMSIE && !this.strictDocType)){
				img.style.styleFloat = 'none';
				img.style.position = 'relative';	
				img.style.top = '4px'
				span.style.paddingTop = '4px';
				aTab.style.cursor = 'hand';
			}	// End IE5.x FIX
			aTab.appendChild(img);
		}

		var tabs = this.DHTMLSuite_tabObj.getElementsByTagName('DIV');
		var divCounter = 0;
		for(var no=0;no<tabs.length;no++){
			if(tabs[no].className=='DHTMLSuite_aTab' && tabs[no].parentNode == this.DHTMLSuite_tabObj){
				if(this.height.length>0){
					if(this.height.indexOf('%')==-1){
						var tmpHeight = (this.height.replace('px','')/1 - 22);
						tabs[no].style.height = tmpHeight + 'px';
					}else
						tabs[no].style.height = this.height;
				}
				tabs[no].style.display='none';
				tabs[no].id = 'tabView' + this.tabSetParentId + "_" + divCounter;
				divCounter++;
			}			
		}	
		this.tabView_countTabs = this.tabView_countTabs + this.tabTitles.length;	
		this.__showTab(this.tabSetParentId,this.initActiveTabIndex,this.outsideObjectRefIndex);

		return this.activeTabIndex;
	}
	// }}}	
	,
	// {{{ __mouseOutTabViewCloseButton()
    /**
     * 
     *
     * @private
     */	
    	
	__mouseOutTabViewCloseButton : function()
	{
		this.src = this.src.replace('close-over.gif','close.gif');	
	}	
	// }}}	
	,	
	// {{{ __hoverTabViewCloseButton()
    /**
     * 
     *
     * @private
     */	
    	
	__hoverTabViewCloseButton : function()
	{
		this.src = this.src.replace('close.gif','close-over.gif');	
	}	
	// }}}	
	,	
	
	// {{{ __showAjaxTabContent()
    /**
     * 
      * @param Int ajaxIndex = Index of Ajax array
      * @param String objId = Id of element where content from Ajax should be displayed
      * @param Int tabId = Id of element where content from Ajax should be displayed
     *
     * @private
     */	
    	
	__showAjaxTabContent : function(ajaxIndex,objId,tabId)
	{
		var obj = document.getElementById('tabView'+objId + '_' + tabId);
		obj.innerHTML = this.ajaxObjects[ajaxIndex].response;		
	}	
	// }}}	
	,
	// {{{ __resetTabIds()
    /**
     * 
     *
     * @private
     */		
	__resetTabIds : function(parentId)
	{
		var tabTitleCounter = 0;
		var tabContentCounter = 0;		
		var divs = this.DHTMLSuite_tabObj.getElementsByTagName('DIV');	

		for(var no=0;no<divs.length;no++){
			if(divs[no].className=='DHTMLSuite_aTab' && divs[no].parentNode==this.DHTMLSuite_tabObj){
				divs[no].id = 'tabView' + parentId + '_' + tabTitleCounter;
				tabTitleCounter++;
			}
			if(divs[no].id.indexOf('tabTab')>=0 && divs[no].parentNode.parentNode==this.DHTMLSuite_tabObj){
				divs[no].id = 'tabTab' + parentId + '_' + tabContentCounter;	
				tabContentCounter++;
			}		
						
		}	
		this.tabView_countTabs = tabContentCounter;
	}
	// }}}	

	,
	// {{{ getTabIndexByTitle()
    /**
     * 
     *
     * @private
     */		
	getTabIndexByTitle : function(tabTitle)
	{
		tabTitle = tabTitle.replace(/(.*?)&nbsp.*$/gi,'$1');
		var divs = this.DHTMLSuite_tabObj.getElementsByTagName('DIV');
		
		for(var no=0;no<divs.length;no++){
			if(divs[no].id.indexOf('tabTab')>=0){
				var span = divs[no].getElementsByTagName('SPAN')[0];	
				var spanTitle = span.innerHTML.replace(/(.*?)&nbsp.*$/gi,'$1');
				if(spanTitle == tabTitle){
					var tmpId = divs[no].id.split('_');					
					return tmpId[tmpId.length-1].replace(/[^0-9]/g,'')/1;
				}		
			}
		}
	
		
		return -1;		
	}
	// }}}				
}

/*[FILE_START:dhtmlSuite-dragDropTree.js] */
/************************************************************************************************************
*	Drag and drop folder tree
*
*	Created:					August, 23rd, 2006
*	
*	Demos of this class:		demo-drag-drop-folder-tree.html				
*			
* 	Update log:
*
************************************************************************************************************/
	
var JSTreeObj;
var treeUlCounter = 0;
var nodeId = 1;
	
/**
* @constructor
* @class Purpose of class:	Transforms an UL,LI list into a folder tree with drag and drop capabilities(See <a target="_blank" href="../../demos/demo-drag-drop-folder-tree.html">demo</A>).
* @version				1.0
* @version 1.0
* 
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/


DHTMLSuite.JSDragDropTree = function()
{
	var idOfTree;
	var folderImage;
	var plusImage;
	var minusImage;
	var maximumDepth;
	var dragNode_source;
	var dragNode_parent;
	var dragNode_sourceNextSib;
	var dragNode_noSiblings;
	
	var dragNode_destination;
	var floatingContainer;
	var dragDropTimer;
	var dropTargetIndicator;
	var insertAsSub;
	var indicator_offsetX;
	var indicator_offsetX_sub;
	var indicator_offsetY;
	var messageMaximumDepthReached;
	var ajaxObjects;
	var layoutCSS;

	/* Initial variable values */
	this.folderImage = 'DHTMLSuite_folder.gif';
	this.plusImage = 'DHTMLSuite_plus.gif';
	this.minusImage = 'DHTMLSuite_minus.gif';
	this.maximumDepth = 6;		
	this.layoutCSS = 'drag-drop-folder-tree.css';
	
	this.floatingContainer = document.createElement('UL');
	this.floatingContainer.style.position = 'absolute';
	this.floatingContainer.style.display='none';
	this.floatingContainer.id = 'floatingContainer';
	this.insertAsSub = false;
	document.body.appendChild(this.floatingContainer);
	this.dragDropTimer = -1;
	this.dragNode_noSiblings = false;
	
	
	if(document.all){
		this.indicator_offsetX = 1;	// Offset position of small black lines indicating where nodes would be dropped.
		this.indicator_offsetX_sub = 3;
		this.indicator_offsetY = 14;
	}else{
		this.indicator_offsetX = 1;	// Offset position of small black lines indicating where nodes would be dropped.
		this.indicator_offsetX_sub = 3;
		this.indicator_offsetY = 5;			
	}
	if(navigator.userAgent.indexOf('Opera')>=0){
		this.indicator_offsetX = 2;	// Offset position of small black lines indicating where nodes would be dropped.
		this.indicator_offsetX_sub = 3;
		this.indicator_offsetY = -7;				
	}

	this.messageMaximumDepthReached = ''; // Use '' if you don't want to display a message 
	this.ajaxObjects = new Array();
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	// This line starts all the init methods
	
}


/* DHTMLSuite.JSDragDropTree class */
DHTMLSuite.JSDragDropTree.prototype = {

	// {{{ init()
    /**
     * Initializes the script
     *
     * @public
     */	
    	
	init : function()
	{
		
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);
		JSTreeObj = this;
		JSTreeObj.__createDropIndicator();
		
		if(!document.documentElement.onselectstart)document.documentElement.onselectstart = function() { return DHTMLSuite.commonObj.__getOkToSelect(); };
		
		document.documentElement.ondragstart = document.documentElement.ondragstart = function() { return DHTMLSuite.commonObj.cancelEvent() };
		DHTMLSuite.commonObj.__addEventElement(document.documentElement);
		var nodeId = 0;
		var DHTMLSuite_tree = document.getElementById(this.idOfTree);
		var menuItems = DHTMLSuite_tree.getElementsByTagName('LI');	// Get an array of all menu items
		for(var no=0;no<menuItems.length;no++){
			// No children var set ?
			var noChildren = false;
			var tmpVar = menuItems[no].getAttribute('noChildren');
			if(!tmpVar)tmpVar = menuItems[no].noChildren;
			if(tmpVar=='true')noChildren=true;
			// No drag var set ?
			var noDrag = false;
			var tmpVar = menuItems[no].getAttribute('noDrag');
			if(!tmpVar)tmpVar = menuItems[no].noDrag;
			if(tmpVar=='true')noDrag=true;
					 
			nodeId++;
			var subItems = menuItems[no].getElementsByTagName('UL');
			var img = document.createElement('IMG');
			img.src = DHTMLSuite.configObj.imagePath + this.plusImage;
			img.onclick = JSTreeObj.showHideNode;
			DHTMLSuite.commonObj.__addEventElement(img);
			if(subItems.length==0)img.style.visibility='hidden';else{
				subItems[0].id = 'tree_ul_' + treeUlCounter;
				treeUlCounter++;
			}
			var aTag = menuItems[no].getElementsByTagName('A')[0];

			if(!noDrag)aTag.onmousedown = JSTreeObj.__initDrag;
			if(!noChildren)aTag.onmousemove = JSTreeObj.__moveDragableNodes;
			DHTMLSuite.commonObj.__addEventElement(aTag);
			menuItems[no].insertBefore(img,aTag);
			menuItems[no].id = 'DHTMLSuite_treeNode' + nodeId;
			var folderImg = document.createElement('IMG');
			if(!noDrag)folderImg.onmousedown = JSTreeObj.__initDrag;
			if(!noChildren)folderImg.onmousemove = JSTreeObj.__moveDragableNodes;
			if(menuItems[no].className){
				folderImg.src = DHTMLSuite.configObj.imagePath + menuItems[no].className;
			}else{
				folderImg.src = DHTMLSuite.configObj.imagePath + this.folderImage;
			}
			DHTMLSuite.commonObj.__addEventElement(folderImg);
			menuItems[no].insertBefore(folderImg,aTag);
		}	
		
	
		initExpandedNodes = DHTMLSuite.commonObj.getCookie('DHTMLSuite_expandedNodes');
		if(initExpandedNodes){
			var nodes = initExpandedNodes.split(',');
			for(var no=0;no<nodes.length;no++){
				if(nodes[no])this.showHideNode(false,nodes[no]);	
			}			
		}			
		
		DHTMLSuite.commonObj.addEvent(document.documentElement,"mousemove",JSTreeObj.__moveDragableNodes);
		DHTMLSuite.commonObj.addEvent(document.documentElement,"mouseup",JSTreeObj.__dropDragableNodes);

	}	
	// }}}		
	,
	// {{{ setLayoutCss()
    /**
     * set new CSS file
     *
     * @param String cssFileName - name of new css file(example: drag-drop.css). Has to be set before init is called. 
     *
     * @public
     */	
	setLayoutCss : function(cssFileName)
	{
		this.layoutCSS = cssFileName;	
	}	
	// }}}	
	,
	// {{{ setFolderImage()
    /**
     * set new folder image file
     *
     * @param String newFolderImage - name of folder image(example: folder.gif). Has to be set before init is called. 
     *
     * @public
     */		
	setFolderImage : function(newFolderImage)
	{
		this.folderImage = newFolderImage;
	}
	// }}}	
	,
	// {{{ setPlusImage()
    /**
     * set new CSS file
     *
     * @param String newPlusImage - name of new [+] image(example: plus.gif). Has to be set before init is called. 
     *
     * @public
     */		
	setPlusImage : function(newPlusImage)
	{
		this.plusImage = newPlusImage;
	}
	// }}}	
	,
	// {{{ setMinusImage()
    /**
     * set new plus imagee
     *
     * @param String newMinusImage - name of new [-] image(example: minus.gif). Has to be set before init is called. 
     *
     * @public
     */		
	setMinusImage : function(newMinusImage)
	{
		this.mlusImage = newMinusImage;
	}
	// }}}	
	,
	// {{{ setMaximumDepth()
    /**
     * set maximum depth of tree. 
     *
     * @param Int maxDepth - new maximum depth of tree. 
     *
     * @public
     */		
	setMaximumDepth : function(maxDepth)
	{
		this.maximumDepth = maxDepth;	
	}
	,setMessageMaximumDepthReached : function(newMessage)
	{
		this.messageMaximumDepthReached = newMessage;
	}
	// }}}	
	,	
	// {{{ setTreeId()
    /**
     * set ID of tree root element
     *
     * @param String idOfTree - Id of UL tag which is root element of the tree. 
     *
     * @public
     */			
	setTreeId : function(idOfTree)
	{
		this.idOfTree = idOfTree;			
	}
	// }}}		
	,
	// {{{ expandAll()
    /**
     * Expand all tree nodes
     *
     *
     * @public
     */		
	expandAll : function()
	{
		var menuItems = document.getElementById(this.idOfTree).getElementsByTagName('LI');
		for(var no=0;no<menuItems.length;no++){
			var subItems = menuItems[no].getElementsByTagName('UL');
			if(subItems.length>0 && subItems[0].style.display!='block'){
				JSTreeObj.showHideNode(false,menuItems[no].id.replace(/[^0-9]/g,''));
			}			
		}
	}
	// }}}		
	,
	// {{{ collapseAll()
    /**
     * Collapse all tree nodes
     *
     *
     * @public
     */		
	collapseAll : function()
	{
		var menuItems = document.getElementById(this.idOfTree).getElementsByTagName('LI');
		for(var no=0;no<menuItems.length;no++){
			var subItems = menuItems[no].getElementsByTagName('UL');
			if(subItems.length>0 && subItems[0].style.display=='block'){
				JSTreeObj.showHideNode(false,menuItems[no].id.replace(/[^0-9]/g,''));
			}			
		}		
	}	
	// }}}	
	,
	// {{{ showHideNode()
    /**
     * Expand a specific node
     *
     * @param boolean e - If you call this method manually, set this argument to false(It's not used)
     * @param string inputId - Id of node to expand/collapse
     *
     * @public
     */	
	showHideNode : function(e,inputId)
	{
		if(inputId){
			if(!document.getElementById('DHTMLSuite_treeNode'+inputId))return;
			thisNode = document.getElementById('DHTMLSuite_treeNode'+inputId).getElementsByTagName('IMG')[0]; 
		}else {
			thisNode = this;
			if(this.tagName=='A')thisNode = this.parentNode.getElementsByTagName('IMG')[0];	
			
		}
		if(thisNode.style.visibility=='hidden')return;		
		var parentNode = thisNode.parentNode;
		inputId = parentNode.id.replace(/[^0-9]/g,'');
		if(thisNode.src.indexOf(JSTreeObj.plusImage)>=0){
			thisNode.src = thisNode.src.replace(JSTreeObj.plusImage,JSTreeObj.minusImage);
			var ul = parentNode.getElementsByTagName('UL')[0];
			ul.style.display='block';
			if(!initExpandedNodes)initExpandedNodes = ',';
			if(initExpandedNodes.indexOf(',' + inputId + ',')<0) initExpandedNodes = initExpandedNodes + inputId + ',';
		}else{
			thisNode.src = thisNode.src.replace(JSTreeObj.minusImage,JSTreeObj.plusImage);
			parentNode.getElementsByTagName('UL')[0].style.display='none';
			initExpandedNodes = initExpandedNodes.replace(',' + inputId,'');
		}	
		DHTMLSuite.commonObj.setCookie('DHTMLSuite_expandedNodes',initExpandedNodes,500);			
		return false;						
	}
	// }}}	
	,
	// {{{ getSaveString()
    /**
     * Return save string 
     * 
     * @param Object initObj - Only for private use inside the method
     * @param String saveString - Only for private use inside the method - you should call this method without arguments.
     *
     * @return String saveString - A string with the format id-parentId,id-parentId,id-parentId
     * @type String
     * @public
     */		
	getSaveString : function(initObj,saveString)
	{
		
		if(!saveString)var saveString = '';
		if(!initObj){
			initObj = document.getElementById(this.idOfTree);

		}
		var lis = initObj.getElementsByTagName('LI');

		if(lis.length>0){
			var li = lis[0];
			while(li){
				if(li.id){
					if(saveString.length>0)saveString = saveString + ',';

					saveString = saveString + li.id.replace(/[^0-9]/gi,'');
					saveString = saveString + '-';
					if(li.parentNode.id!=this.idOfTree)saveString = saveString + li.parentNode.parentNode.id.replace(/[^0-9]/gi,''); else saveString = saveString + '0';
					
					var ul = li.getElementsByTagName('UL');
					if(ul.length>0){
						saveString = this.getSaveString(ul[0],saveString);	
					}	
				}			
				li = li.nextSibling;
			}
		}

		if(initObj.id == this.idOfTree){
			return saveString;						
		}
		return saveString;
	}
	// }}}	
	,	
	// {{{ __initDrag()
    /**
     * Init a drag process
     *
     * @param event e = Event object
     * @private
     */		
	__initDrag : function(e)
	{
		if(document.all)e = event;	
		
		var subs = JSTreeObj.floatingContainer.getElementsByTagName('LI');
		if(subs.length>0){
			if(JSTreeObj.dragNode_sourceNextSib){
				JSTreeObj.dragNode_parent.insertBefore(JSTreeObj.dragNode_source,JSTreeObj.dragNode_sourceNextSib);
			}else{
				JSTreeObj.dragNode_parent.appendChild(JSTreeObj.dragNode_source);
			}					
		}
		
		JSTreeObj.dragNode_source = this.parentNode;
		JSTreeObj.dragNode_parent = this.parentNode.parentNode;
		JSTreeObj.dragNode_sourceNextSib = false;

		
		if(JSTreeObj.dragNode_source.nextSibling)JSTreeObj.dragNode_sourceNextSib = JSTreeObj.dragNode_source.nextSibling;
		JSTreeObj.dragNode_destination = false;
		JSTreeObj.dragDropTimer = 0;
		DHTMLSuite.commonObj.__setOkToSelect(false);
		JSTreeObj.__timerDrag();
		return false;
	}
	// }}}	
	,
	// {{{ __timerDrag()
    /**
     * A small delay before drag is started
     *
     * @private
     */		
	__timerDrag : function()
	{	
		if(this.dragDropTimer>=0 && this.dragDropTimer<10){
			this.dragDropTimer = this.dragDropTimer + 1;
			setTimeout('JSTreeObj.__timerDrag()',20);
			return;
		}
		if(this.dragDropTimer==10)
		{
			JSTreeObj.floatingContainer.style.display='block';
			JSTreeObj.floatingContainer.appendChild(JSTreeObj.dragNode_source);	
		}
	}
	// }}}	
	,
	// {{{ __moveDragableNodes()
    /**
     * Move dragable nodes
     * @param event e - Event object
     *
     * @private
     */		
	__moveDragableNodes : function(e)
	{
		if(JSTreeObj.dragDropTimer<10)return;
		if(document.all)e = event;
		dragDrop_x = e.clientX/1 + 5 + document.body.scrollLeft;
		dragDrop_y = e.clientY/1 + 5 + document.documentElement.scrollTop;	
				
		JSTreeObj.floatingContainer.style.left = dragDrop_x + 'px';
		JSTreeObj.floatingContainer.style.top = dragDrop_y + 'px';
		
		var thisObj = this;
		if(thisObj.tagName=='A' || thisObj.tagName=='IMG')thisObj = thisObj.parentNode;

		JSTreeObj.dragNode_noSiblings = false;
		var tmpVar = thisObj.getAttribute('noSiblings');
		if(!tmpVar)tmpVar = thisObj.noSiblings;
		if(tmpVar=='true')JSTreeObj.dragNode_noSiblings=true;
				
		if(thisObj && thisObj.id)
		{
			JSTreeObj.dragNode_destination = thisObj;
			var img = thisObj.getElementsByTagName('IMG')[1];
			var tmpObj= JSTreeObj.dropTargetIndicator;
			tmpObj.style.display='block';
			
			var eventSourceObj = this;
			if(JSTreeObj.dragNode_noSiblings && eventSourceObj.tagName=='IMG')eventSourceObj = eventSourceObj.nextSibling;
			
			var tmpImg = tmpObj.getElementsByTagName('IMG')[0];
			if(this.tagName=='A' || JSTreeObj.dragNode_noSiblings){
				tmpImg.src = tmpImg.src.replace('ind1','ind2');	
				JSTreeObj.insertAsSub = true;
				tmpObj.style.left = (DHTMLSuite.commonObj.getLeftPos(eventSourceObj) + JSTreeObj.indicator_offsetX_sub) + 'px';
			}else{
				tmpImg.src = tmpImg.src.replace('ind2','ind1');
				JSTreeObj.insertAsSub = false;
				tmpObj.style.left = (DHTMLSuite.commonObj.getLeftPos(eventSourceObj) + JSTreeObj.indicator_offsetX) + 'px';
			}
			
			
			tmpObj.style.top = (DHTMLSuite.commonObj.getTopPos(thisObj) + JSTreeObj.indicator_offsetY) + 'px';
		}
		
		return false;
		
	}
	// }}}	
	,
	// {{{ __dropDragableNodes()
    /**
     * Drag process ended - drop nodes
     *
     * @private
     */		
	__dropDragableNodes:function()
	{
		if(JSTreeObj.dragDropTimer<10){				
			JSTreeObj.dragDropTimer = -1;
			DHTMLSuite.commonObj.__setOkToSelect(true);
			return;
		}
		var showMessage = false;
		if(JSTreeObj.dragNode_destination){	// Check depth
			var countUp = JSTreeObj.__dragDropGetDepth(JSTreeObj.dragNode_destination,'up');
			var countDown = JSTreeObj.__dragDropGetDepth(JSTreeObj.dragNode_source,'down');
			var countLevels = countUp/1 + countDown/1 + (JSTreeObj.insertAsSub?1:0);		
			
			if(countLevels>JSTreeObj.maximumDepth){
				JSTreeObj.dragNode_destination = false;
				showMessage = true; 	// Used later down in this function
			}
		}
		
		
		if(JSTreeObj.dragNode_destination){			
			if(JSTreeObj.insertAsSub){
				var uls = JSTreeObj.dragNode_destination.getElementsByTagName('UL');
				if(uls.length>0){
					ul = uls[0];
					ul.style.display='block';
					
					var lis = ul.getElementsByTagName('LI');

					if(lis.length>0){	// Sub elements exists - drop dragable node before the first one
						ul.insertBefore(JSTreeObj.dragNode_source,lis[0]);	
					}else {	// No sub exists - use the appendChild method - This line should not be executed unless there's something wrong in the HTML, i.e empty <ul>
						ul.appendChild(JSTreeObj.dragNode_source);	
					}
				}else{
					var ul = document.createElement('UL');
					ul.style.display='block';
					JSTreeObj.dragNode_destination.appendChild(ul);
					ul.appendChild(JSTreeObj.dragNode_source);
				}
				var img = JSTreeObj.dragNode_destination.getElementsByTagName('IMG')[0];					
				img.style.visibility='visible';
				img.src = img.src.replace(JSTreeObj.plusImage,JSTreeObj.minusImage);					
				
				
			}else{
				if(JSTreeObj.dragNode_destination.nextSibling){
					var nextSib = JSTreeObj.dragNode_destination.nextSibling;
					nextSib.parentNode.insertBefore(JSTreeObj.dragNode_source,nextSib);
				}else{
					JSTreeObj.dragNode_destination.parentNode.appendChild(JSTreeObj.dragNode_source);
				}
			}	
			/* Clear parent object */
			var tmpObj = JSTreeObj.dragNode_parent;
			var lis = tmpObj.getElementsByTagName('LI');
			if(lis.length==0){
				var img = tmpObj.parentNode.getElementsByTagName('IMG')[0];
				img.style.visibility='hidden';	// Hide [+],[-] icon
				tmpObj.parentNode.removeChild(tmpObj);						
			}
			
		}else{
			// Putting the item back to it's original location
			
			if(JSTreeObj.dragNode_sourceNextSib){
				JSTreeObj.dragNode_parent.insertBefore(JSTreeObj.dragNode_source,JSTreeObj.dragNode_sourceNextSib);
			}else{
				JSTreeObj.dragNode_parent.appendChild(JSTreeObj.dragNode_source);
			}			
				
		}
		JSTreeObj.dropTargetIndicator.style.display='none';		
		JSTreeObj.dragDropTimer = -1;	
		DHTMLSuite.commonObj.__setOkToSelect(true);
		if(showMessage && JSTreeObj.messageMaximumDepthReached)alert(JSTreeObj.messageMaximumDepthReached);
	}
	// }}}	
	,
	// {{{ __createDropIndicator()
    /**
     * Create small black lines indicating where items will be dropped
     *
     * @private
     */		
	__createDropIndicator : function()
	{
		this.dropTargetIndicator = document.createElement('DIV');
		this.dropTargetIndicator.style.zIndex = 240000;
		this.dropTargetIndicator.style.position = 'absolute';
		this.dropTargetIndicator.style.display='none';			
		var img = document.createElement('IMG');
		img.src = DHTMLSuite.configObj.imagePath + 'dragDrop_ind1.gif';
		img.id = 'dragDropIndicatorImage';
		this.dropTargetIndicator.appendChild(img);
		document.body.appendChild(this.dropTargetIndicator);
		
	}
	// }}}	
	,
	// {{{ __dragDropGetDepth()
    /**
     * Count depth of a branch
     *
     * @private
     */		
	__dragDropGetDepth : function(obj,direction,stopAtObject){
		var countLevels = 0;
		if(direction=='up'){
			while(obj.parentNode && obj.parentNode!=stopAtObject){
				obj = obj.parentNode;
				if(obj.tagName=='UL')countLevels = countLevels/1 +1;
			}		
			return countLevels;
		}	
		
		if(direction=='down'){ 
			var subObjects = obj.getElementsByTagName('LI');
			for(var no=0;no<subObjects.length;no++){
				countLevels = Math.max(countLevels,JSTreeObj.__dragDropGetDepth(subObjects[no],"up",obj));
			}
			return countLevels;
		}	
	}	
	// }}}		
	,
	// {{{ __cancelSelectionEvent()
    /**
     * Cancel selection when drag is in process
     *
     * @private
     */		
	__cancelSelectionEvent : function()
	{
		
		if(JSTreeObj.dragDropTimer<10)return true;
		return false;	
	}
	// }}}	

}
	
/*[FILE_START:dhtmlSuite-dynamicContent.js] */	
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


/*[FILE_START:dhtmlSuite-colorHelp.js] */
/************************************************************************************************************
*	Color functions
*
*	Created:			August, 23rd, 2006
*	@class Purpose of class:	This class provides some methods for working with colors.
*			
* 	Update log:
*
************************************************************************************************************/

/**
* @constructor
* @class This class provides some methods for working with colors.
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
**/

DHTMLSuite.colorHelp = function()
{
	
	
}

DHTMLSuite.colorHelp.prototype = {

	// {{{ baseConverter()
    /**
     *	converts numbers from different number systems(example: Decimal to octal)
     * 	
     *	@param mixed numberToConvert - Number to convert
     *	@param int oldBase - Convert from which base(8 = octal, 10 = decimal, 16 = hexadecimal)
     *	@param int newBase - Convert to which base(8 = octal, 10 = decimal, 16 = hexadecimal)
     *	
     *	@return String number in new base.(Example: decimal "16" returns "F" when converted to hexadecimal)
     *	@type String
     *
     * @public
     */	
    	
	baseConverter : function(numberToConvert,oldBase,newBase) {
		numberToConvert = numberToConvert + "";
		numberToConvert = numberToConvert.toUpperCase();
		var listOfCharactersOfCharacters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		var dec = 0;
		for (var i = 0; i <=  numberToConvert.length; i++) {
			dec += (listOfCharacters.indexOf(numberToConvert.charAt(i))) * (Math.pow(oldBase , (numberToConvert.length - i - 1)));
		}
		numberToConvert = "";
		var magnitude = Math.floor((Math.log(dec))/(Math.log(newBase)));
		for (var i = magnitude; i >= 0; i--) {
			var amount = Math.floor(dec/Math.pow(newBase,i));
			numberToConvert = numberToConvert + listOfCharacters.charAt(amount); 
			dec -= amount*(Math.pow(newBase,i));
		}
		if(numberToConvert.length==0)numberToConvertToConvert=0;
		return numberToConvert;
	}
	// }}}	
	,

	// {{{ getHSV()
    /**
     *	Converts a RGB color to HSV
     * 	
     *	@param String rgbColor - Example: #FF12AB or FF12AB
     *	@return Array H,S,B = Hue, Saturation and Brightness
     *	@type Array
     *
     * @public
     */		
	getHSV : function(rgbColor){
		rgbColor = rgbColor.replace('#','');		
		
		red = baseConverter(rgbColor.substr(0,2),16,10);
		green = baseConverter(rgbColor.substr(2,2),16,10);
		blue = baseConverter(rgbColor.substr(4,2),16,10);
		if(red.length==0)red=0;
		if(green.length==0)green=0;
		if(blue.length==0)blue=0;
		red = red/255;
		green = green/255;
		blue = blue/255;
		
		maxValue = Math.max(red,green,blue);
		minValue = Math.min(red,green,blue);
		
		var hue = 0;
		
		if(maxValue==minValue){
			hue = 0;
			saturation=0;
		}else{
			if(red == maxValue){
				hue = (green - blue) / (maxValue-minValue)/1;	
			}else if(green == maxValue){
				hue = 2 + (blue - red)/1 / (maxValue-minValue)/1;	
			}else if(blue == maxValue){
				hue = 4 + (red - green) / (maxValue-minValue)/1;	
			}
			saturation = (maxValue-minValue) / maxValue;
		}
		hue = hue * 60; 
		valueBrightness = maxValue;
		
		if(valueBrightness/1<0.5){
			//saturation = (maxValue - minValue) / (maxValue + minValue);
		}
		if(valueBrightness/1>= 0.5){
			//saturation = (maxValue - minValue) / (2 - maxValue - minValue);
		}	
			
		
		returnArray = [hue,saturation,valueBrightness];
		return returnArray;
	}
	// }}}	
	,
	// {{{ toRgb()
    /**
     *	Converts a RGB color to HSV
     * 	
     *	@param Int hue - Degrees - Position on color wheel. Value between 0 and 359
     *	@param float saturation - Intensity of color(value between 0 and 1)
     *	@param float valueBrightness - Brightness(value between 0 and 1)
     *
     *	@return String RGBColor - example #FF00FF
     *	@type String
     *
     * @public
     */		
	toRgb : function(hue,saturation,valueBrightness){
		Hi = Math.floor(hue / 60);
		if(hue==360)Hi=0;
		f = hue/60 - Hi;
		p = (valueBrightness * (1- saturation)).toPrecision(2);
		q = (valueBrightness * (1 - (f * saturation))).toPrecision(2);
		t = (valueBrightness * (1 - ((1-f)*saturation))).toPrecision(2);
	
		switch(Hi){
			case 0:
				red = valueBrightness;
				green = t;
				blue = p;				
				break;
			case 1: 
				red = q;
				green = valueBrightness;
				blue = p;
				break;
			case 2: 
				red = q;
				green = valueBrightness;
				blue = t;
				break;
			case 3: 
				red = p;
				green = q;;
				blue = valueBrightness;
				break;
			case 4:
				red = t;
				green = p;
				blue = valueBrightness;
				break;
			case 5:
				red = valueBrightness;
				green = p;
				blue = q;
				break;
		}
		
		if(saturation==0){
			red = valueBrightness;
			green = valueBrightness;
			blue = valueBrightness;		
		}
		
		red*=255;
		green*=255;
		blue*=255;
	
		red = Math.round(red);
		green = Math.round(green);
		blue = Math.round(blue);	
		
		red = baseConverter(red,10,16);
		green = baseConverter(green,10,16);
		blue = baseConverter(blue,10,16);
		
		red = red + "";
		green = green + "";
		blue = blue + "";
	
		while(red.length<2){
			red = "0" + red;
		}	
		while(green.length<2){
			green = "0" + green;
		}	
		while(blue.length<2){
			blue = "0" + "" + blue;
		}
		rgbColor = "#" + red + "" + green + "" + blue;
		return rgbColor.toUpperCase();
	}
	// }}}	
	,
	// {{{ findColorByDegrees()
    /**
     *	Returns RGB color from a position on the color wheel
     * 	
     *	@param String rgbColor - Rgb color to calculate degrees from
     *	@param Float degrees - How many degrees to move on the color wheel(clockwise)
     *
     *	@return String RGBColor - new rgb color - example #FF00FF
     *	@type String
     *
     * @public
     */	
	findColorByDegrees : function(rgbColor,degrees){
		rgbColor = rgbColor.replace('#','');
		myArray = this.getHSV(rgbColor);
		myArray[0]+=degrees;
		if(myArray[0]>=360)myArray[0]-=360;
		if(myArray[0]<0)myArray[0]+=360;	
		return toRgb(myArray[0],myArray[1],myArray[2]);
	}
	// }}}	
	,
	// {{{ findColorByBrightness()
    /**
     *	Returns a new rgb color after change of brightness
     * 	
     *	@param String rgbColor - RGB start color
     *	@param Int brightness - Change in brightness (value between -100 and 100)
     *
     *	@return String RGBColor - new rgb color - example #FF00FF
     *	@type String
     *
     * @public
     */		
	findColorByBrightness : function(rgbColor,brightness){
		
		rgbColor = rgbColor.replace('#','');
		myArray = thhis.getHSV(rgbColor);
		
		myArray[2]+=brightness/100;
		if(myArray[2]>1)myArray[2]=1;
		if(myArray[2]<0)myArray[2]=0;	
		
		myArray[1]+=brightness/100;
		if(myArray[1]>1)myArray[1]=1;
		if(myArray[1]<0)myArray[1]=0;		
		
		return toRgb(myArray[0],myArray[1],myArray[2]);			
	}
	// }}}
	,
	// {{{ getRgbFromNumbers()
    /**
     *	Returns a color in RGB format(e.g.: #FFEECC from numeric values of red, green and blue)
     * 	
     *	@param Int red - Amount of red(0-255)
     *	@param Int green - Amount of green(0-255)
     *	@param Int blue - Amount of blue(0-255)
	 *
     *
     *	@return String RGBColor - new rgb color - example #FF00FF
     *	@type String
     *
     * @public
     */	
	getRgbFromNumbers : function(red,green,blue)
	{
		red = this.baseConverter(red,10,16);
		if(red.length==0)red = '0' + red;
		green = this.baseConverter(green,10,16);
		if(green.length==0)green = '0' + green;
		blue = this.baseConverter(blue,10,16);
		if(blue.length==0)blue = '0' + blue;
		return '#' + red + green + blue;
	} 
    
    
	
}


/*[FILE_START:dhtmlSuite-slider.js] */
/************************************************************************************************************
*
*	DHTML slider
*
*	Created:					August, 25th, 2006
*	@class Purpose of class:	Display a slider on a web page.
*		
*	Demos of this class:		demo-slider-1.html
*	
* 	Update log:
*
************************************************************************************************************/

DHTMLSuite.sliderObjects = new Array();	// Array of slider objects. Used in events when "this" refers to the tag trigger the event and not the object.
DHTMLSuite.indexOfCurrentlyActiveSlider = false;	// Index of currently active slider(i.e. index in the DHTMLSuite.sliderObjects array)
DHTMLSuite.slider_generalMouseEventsAdded = false;	// Only assign mouse move and mouseup events once. This variable make sure that happens.


/**
* @constructor
* @class Purpose of class:	Display a DHTML slider on a web page. This slider could either be displayed horizontally or vertically(<a href="../../demos/demo-slider-1.html" target="_blank">demo 1</a> and <a href="../../demos/demo-slider-1.html" target="_blank">demo 2</a>).
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*
**/
DHTMLSuite.slider = function()
{
	var width;							// Width of slider
	var height;							// height of slider
	var targetObj;						// Object where slider will be added.
	var sliderWidth;					// Width of slider image. this is needed in order to position the slider and calculate values correctly.
	var sliderDirection;				// Horizontal or vertical
	var functionToCallOnChange; 		// Function to call when the slider is moved.
	var layoutCss;	
	var sliderMaxValue;					// Maximum value to return from slider
	var sliderMinValue;					// Minimum value to return from slider
	var initialValue;					// Initial value of slider
	var sliderSize;						// Size of sliding area.
	var directionOfPointer;				// Direction of slider pointer;
	var slideInProcessTimer;			// Private variable used to determine if slide is in progress or not.
	var indexThisSlider;				// Index of object in the DHTMLSuite.sliderObjects array
	var numberOfSteps;					// Hardcoded steps
	var stepLinesVisibility;			// Visibility of lines indicating where the slider steps are
	
	var slide_event_pos;					// X position of mouse when slider drag starts
	var slide_start_pos;					// X position of slider when drag starts
	var sliderHandleImg;				// Reference to the small slider handle
	var sliderName;						// A name you can use to identify a slider. Useful if you have more than one slider, but only one onchange event.
	var sliderValueReversed;			// Variable indicating if the value of the slider is reversed(i.e. max at left and min at right)
	this.sliderWidth = 9;				// Initial width of slider.
	this.layoutCss = 'slider.css';		// Default css file
	this.sliderDirection = 'hor';		// Horizontal is default
	this.width = 0;						// Initial widht
	this.height = 0;					// Initial height
	this.sliderMaxValue = 100; 			// Default max value to return from slider
	this.sliderMinValue = 0;			// Default min value to return from slider
	this.initialValue = 0;				// Default initial value of slider
	this.targetObj = false;				// Set target obj to false initially.
	this.directionOfPointer = 'up';		// Default pointer direction for slider handle.
	this.slideInProcessTimer = -1;
	this.sliderName = '';
	this.numberOfSteps = false;
	this.stepLinesVisibility = true;
	this.sliderValueReversed = false;	// Default value of sliderValueReversed, i.e. max at right, min at left or max at top, min at bottom.
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	// This line starts all the init methods
	
	

}

DHTMLSuite.slider.prototype = {
	
	// {{{ init()
    /**
     *	Initializes the script, i.e. creates the slider
     * 	
     *
     * @public
     */			
	
	init : function()	// Initializes the script
	{
		if(!this.targetObj){
			alert('Error! - No target for slider specified');
			return;
		}
		// No width or height specified - try to measure it from the size of parent box
		if(!this.width)this.width = this.targetObj.clientWidth;
		if(!this.height)this.height = this.targetObj.clientHeight;
		if(!this.width)this.width = this.targetObj.offsetWidth;
		if(!this.height)this.height = this.targetObj.offsetHeight;
		this.width = this.width + 'px';
		this.height = this.height + 'px';

		DHTMLSuite.commonObj.loadCSS(this.layoutCss);
		
		
		
		this.__createSlider();
				
		
	}	
	// }}}	
	,
	// {{{ setSliderTarget(divId)
    /**
     *	Specify where to insert the slider
     * 	
     *	@param String targetId - Id of element where the slider will be created inside(There shouldn't be any content inside this div)
     *
     * @public	
     */	
	setSliderTarget : function(targetId)
	{
		this.targetObj = document.getElementById(targetId);		
	}
	// }}}	
	,
	// {{{ setSliderDirection(newDirection)
    /**
     *	Specify where to insert the slider
     * 	
     *	@param String newDirection - New slider direction. Possible valuse: "hor" or "ver"
     *
     * @public	
     */		
	setSliderDirection : function(newDirection)
	{
		newDirection = newDirection + '';
		newDirection = newDirection.toLowerCase();
		if(newDirection!='hor' && newDirection!='ver'){
			alert('Invalid slider direction - possible values: "hor" or "ver"');
			return;
		}
		this.sliderDirection = newDirection;		
	}
	// }}}	
	,
	// {{{ setSliderWidth(newWidth)
    /**
     *	Specify width of slider - if now width is specified, the script will try to measure the height of width of the element where it is inserted.
     * 	
     *	@param String newWidth - Slider width(numeric or percentage) example: 100 or 90%
     *
     * @public	
     */		
	setSliderWidth : function(newWidth)
	{
		newWidth = newWidth + '';
		if(newWidth.indexOf('%')==-1)newWidth = newWidth + 'px';
		this.width = newWidth;	
	}
	// }}}	
	,
	// {{{ setSliderHeight(newHeight)
    /**
     *	Specify height of slider - if now width is specified, the script will try to measure the height of width of the element where it is inserted.
     * 	
     *	@param String newHeight - Slider width(numeric or percentage) example: 100 or 90%
     *
     * @public	
     */		
	setSliderHeight : function(newHeight)
	{
		newHeight = newHeight + '';
		if(newHeight.indexOf('%')==-1)newHeight = newHeight + 'px';
		this.height = height;	
	}
	// }}}	
	,	
	// {{{ setSliderReversed()
    /**
     *	Reverse slider, i.e. max at left instead of right or at bottom instead of top
     * 	
     *
     * @public	
     */		
	setSliderReversed : function()
	{
		this.sliderValueReversed = true;
	}
	// }}}	
	,
	// {{{ setOnChangeEvent(nameOfFunction)
    /**
     *	Specify which function to call when the slider has been moved.
     * 	
     *	@param String nameOfFunction - Name of function to call.
     *
     * @public	
     */	
    setOnChangeEvent : function(nameOfFunction)
    {
    	this.functionToCallOnChange = nameOfFunction;
    	
    }	
	// }}}	
	,		
	// {{{ setSliderMaxValue(newMaxValue)
    /**
     *	Set maximum value of slider
     * 	
     *	@param int newMaxValue - New slider max value
     *
     * @public	
     */	
    setSliderMaxValue : function(newMaxValue)
    {
    	this.sliderMaxValue = newMaxValue;
    	
    }	
	// }}}		
	,		
	// {{{ setSliderMinValue(newMinValue)
    /**
     *	Set minimum value of slider
     * 	
     *	@param int newMinValue - New slider min value
     *
     * @public	
     */	
    setSliderMinValue : function(newMinValue)
    {
    	this.sliderMinValue = newMinValue;
    	
    }	
	// }}}	
	,	
	// {{{ setSliderName(nameOfSlider)
    /**
     *	Specify name of slider.
     * 	
     *	@param String nameOfSlider - Name of function to call.
     *
     * @public	
     */	
    setSliderName : function(nameOfSlider)
    {
    	this.sliderName = nameOfSlider;
    	
    }	
	// }}}	
	,
	// {{{ setLayoutCss(nameOfNewCssFile)
    /**
     *	Specify a new CSS file for the slider(i.e. not using default css file which is slider.css)
     * 	
     *	@param String nameOfNewCssFile - Name of new css file.
     *
     * @public	
     */	
    setLayoutCss : function(nameOfNewCssFile)
    {
    	this.layoutCss = nameOfNewCssFile;
    }
	// }}}
	,
	// {{{ setLayoutCss(nameOfNewCssFile)
    /**
     *	Specify a new CSS file for the slider(i.e. not using default css file which is slider.css)
     * 	
     *	@param String nameOfNewCssFile - Name of new css file.
     *
     * @public	
     */	
    setInitialValue : function(newInitialValue)
    {
    	this.initialValue = newInitialValue;
    }
	// }}}		
	,
	// {{{ setSliderPointerDirection(directionOfPointer)
    /**
     *	In which direction should the slider handle point. 
     * 	
     *	@param String directionOfPointer - In which direction should the slider handle point(possible values: 'up','down','left','right'
     *
     * @public	
     */	
    setSliderPointerDirection : function(directionOfPointer)
    {
    	this.directionOfPointer = directionOfPointer;
    }
	// }}}	
	,	
	// {{{ setSliderValue(newValue)
    /**
     *	Set new position of slider manually
     * 	
     *	@param Int newValue - New value of slider
     *
     * @public	
     */	
    setSliderValue : function(newValue)
    {
    	var position = Math.floor((newValue / this.sliderMaxValue) * this.sliderSize);
    	if(this.sliderDirection=='hor'){
    		this.sliderHandleImg.style.left = position + 'px';	
    	}else{
    		this.sliderHandleImg.style.top = position + 'px';	
    	}
    }
	// }}}	
	,
	// {{{ setNumberOfSliderSteps(numberOfSteps)
    /**
     *	Divide slider into steps, i.e. instead of having a smooth slide.
     * 	
     *	@param Int numberOfSteps - Number of steps
     *
     * @public	
     */	
    setNumberOfSliderSteps : function(numberOfSteps)
    {
    	this.numberOfSteps = numberOfSteps;
    }
	// }}}	
	,
	// {{{ setStepLinesVisible(visible)
    /**
     *	Divide slider into steps. 
     * 	
     *	@param Boolean visible - When using static steps, make lines indicating steps visible or hidden(true = visible(default), false = hidden)
     *
     * @public	
     */	
    setStepLinesVisible : function(visible)
    {
    	this.stepLinesVisibility = visible;
    }
	// }}}	
	,
	// {{{ __createSlider()
    /**
     *	Creates the HTML for the slider dynamically
     * 	
     *
     * @private	
     */		
    __createSlider : function()
    {
    	this.indexThisSlider = DHTMLSuite.sliderObjects.length;
    	DHTMLSuite.sliderObjects[this.indexThisSlider] = this;
    	
    	window.refToThisObject = this;
    	
    	// Creates a parent div for the slider
    	var div = document.createElement('DIV');
    	div.style.width = this.width;
    	div.style.cursor = 'default';
    	div.style.height = this.height;
    	div.style.position = 'relative';
    	div.id = 'sliderNumber' + this.indexThisSlider;	// the numeric part of this id is used inside the __setPositionFromClick method
    	div.onmousedown = this.__setPositionFromClick;
    	DHTMLSuite.commonObj.__addEventElement(div);    	
    	this.targetObj.appendChild(div);
    	
    	var sliderObj = document.createElement('DIV');
    	
    	
    	if(this.sliderDirection=='hor'){	// Horizontal slider.
    		sliderObj.className='DHTMLSuite_slider_horizontal';
    		sliderObj.style.width = div.clientWidth + 'px';
    		this.sliderSize = div.offsetWidth - this.sliderWidth;
    		    		
    		// Creating slider handle image.
    		var sliderHandle = document.createElement('IMG');
    		var srcHandle = 'slider_handle_down.gif';
    		sliderHandle.style.bottom = '2px';
    		if(this.directionOfPointer=='up'){
    			srcHandle = 'slider_handle_up.gif';
    			sliderHandle.style.bottom = '0px';    			
    		}    		
    		sliderHandle.src = DHTMLSuite.configObj.imagePath + srcHandle;
    		div.appendChild(sliderHandle);
    		
    		// Find initial left position of slider
    		var leftPos;
    		if(this.sliderValueReversed){
    			leftPos = Math.round(((this.sliderMaxValue - this.initialValue) / this.sliderMaxValue) * this.sliderSize) -1;
    		}else{
    			leftPos = Math.round((this.initialValue / this.sliderMaxValue) * this.sliderSize);
    		}
			sliderHandle.style.left =  leftPos + 'px';	
    		
    		
    	}else{
    		sliderObj.className='DHTMLSuite_slider_vertical';
    		sliderObj.style.height = div.clientHeight + 'px';
    		this.sliderSize = div.clientHeight - this.sliderWidth;
    		
    		// Creating slider handle image.
    		var sliderHandle = document.createElement('IMG');
    		var srcHandle = 'slider_handle_right.gif';
    		sliderHandle.style.left = '0px';
    		if(this.directionOfPointer=='left'){
    			srcHandle = 'slider_handle_left.gif';
    			sliderHandle.style.left = '0px';    			
    		}    		
    		sliderHandle.src = DHTMLSuite.configObj.imagePath + srcHandle;
    		div.appendChild(sliderHandle);
    		
    		// Find initial left position of slider
    		var topPos;
    		if(!this.sliderValueReversed){
    			topPos = Math.floor(((this.sliderMaxValue - this.initialValue) / this.sliderMaxValue) * this.sliderSize);
    		}else{
    			topPos = Math.floor((this.initialValue / this.sliderMaxValue) * this.sliderSize);
    		}
    		
    		sliderHandle.style.top = topPos + 'px';	
			    		
    		
    	}
    	
    	sliderHandle.id = 'sliderForObject' + this.indexThisSlider;
    	sliderHandle.style.position = 'absolute';
    	sliderHandle.style.zIndex = 5;
    	sliderHandle.onmousedown = this.__initDragHandle;
    	sliderHandle.ondragstart = function() { return DHTMLSuite.commonObj.cancelEvent() };	
    	sliderHandle.onselectstart = function() { return DHTMLSuite.commonObj.cancelEvent() };	
    	DHTMLSuite.commonObj.__addEventElement(sliderHandle);
		this.sliderHandleImg = sliderHandle;
		
		if(!DHTMLSuite.slider_generalMouseEventsAdded){
	    	// Adding onmousemove event to the <html> tag
	    	DHTMLSuite.commonObj.addEvent(document.documentElement,"mousemove",this.__moveSlider);
	    	// Adding onmouseup event to the <html> tag.
	    	DHTMLSuite.commonObj.addEvent(document.documentElement,"mouseup",this.__stopSlideProcess);
    		DHTMLSuite.slider_generalMouseEventsAdded = true;
		}
    	
    	
    	sliderObj.innerHTML = '<span style="cursor:default"></span>';	// In order to get a correct height/width of the div
    	div.appendChild(sliderObj);  			
    	
    	if(this.numberOfSteps && this.stepLinesVisibility){	// Number of steps defined, create graphical lines
    		var stepSize = this.sliderSize / this.numberOfSteps;
    		for(var no=0;no<=this.numberOfSteps;no++){
    			var lineDiv = document.createElement('DIV');
    			lineDiv.style.position = 'absolute';
    			lineDiv.innerHTML = '<span></span>';
    			div.appendChild(lineDiv);
    			if(this.sliderDirection=='hor'){
    				lineDiv.className='DHTMLSuite_smallLines_vertical';
    				lineDiv.style.left = Math.floor((stepSize * no) + (this.sliderWidth/2)) + 'px';
    			}else{
    				lineDiv.className='DHTMLSuite_smallLines_horizontal';
    				lineDiv.style.top = Math.floor((stepSize * no) + (this.sliderWidth/2)) + 'px';
    				lineDiv.style.left = '14px';
    			}	
    			
    		}
    	}
    	
    }
	// }}}	
	,
	// {{{ __initDragHandle()
    /**
     *	Init slider drag
     * 	
     *
     * @private	
     */	
    __initDragHandle : function(e)
    {
    	if(document.all)e = event;
    	var numIndex = this.id.replace(/[^0-9]/gi,'');	// Get index in the DHTMLSuite.sliderObject array. We get this from the id of the slider image(i.e. "this").
    	var sliderObj = DHTMLSuite.sliderObjects[numIndex];
    	DHTMLSuite.indexOfCurrentlyActiveSlider = numIndex;
    	sliderObj.slideInProcessTimer = 0;
    	if(sliderObj.sliderDirection=='hor'){
    		sliderObj.slide_event_pos = e.clientX;	// Get start x position of mouse pointer
    		sliderObj.slide_start_pos = this.style.left.replace('px','')/1;	// Get x position of slider
    	}else{
    		sliderObj.slide_event_pos = e.clientY;	// Get start x position of mouse pointer
    		sliderObj.slide_start_pos = this.style.top.replace('px','')/1;	// Get x position of slider
    	}
    	
    	sliderObj.__timerDragSlider();
    	return false;	// Firefox need this line.
    }
	// }}}	
	,
	// {{{ __setPositionFromClick()
    /**
     *	Set position from click - click on slider - move handle to the mouse pointer
     * 	
     *
     * @private	
     */	
    __setPositionFromClick : function(e)
    {
    	if(document.all)e = event;
		// Tag of element triggering this event. If it's something else than a <div>, return without doing anything, i.e. mouse down on slider handle.
		if (e.target) srcEvent = e.target;
			else if (e.srcElement) srcEvent = e.srcElement;
			if (srcEvent.nodeType == 3) // defeat Safari bug
				srcEvent = srcEvent.parentNode;
		if(srcEvent.tagName!='DIV')return;		
				
    	var numIndex = this.id.replace(/[^0-9]/gi,'');	// Get index in the DHTMLSuite.sliderObject array. We get this from the id of the slider image(i.e. "this").
 		var sliderObj = DHTMLSuite.sliderObjects[numIndex];
 		
     	if(sliderObj.numberOfSteps){
    		modValue = sliderObj.sliderSize / sliderObj.numberOfSteps;	// Find value to calculate modulus by	
    	}	
    	
    	if(sliderObj.sliderDirection=='hor'){
    		var handlePos = (e.clientX - DHTMLSuite.commonObj.getLeftPos(this) - sliderObj.sliderWidth);
    	}else{
    		var handlePos = (e.clientY - DHTMLSuite.commonObj.getTopPos(this) - sliderObj.sliderWidth);
    	}
		if(sliderObj.numberOfSteps){	// Static steps defined
			var mod = handlePos % modValue;	// Calculate modulus
			if(mod>(modValue/2))mod = modValue-mod; else mod*=-1;	// Should we move the slider handle left or right?
			handlePos = handlePos + mod;
		}
		if(handlePos<0)handlePos = 0;	// Don't allow negative values
		if(handlePos > sliderObj.sliderSize)handlePos = sliderObj.sliderSize; // Don't allow values larger the slider size	
    	
   		if(sliderObj.sliderDirection=='hor'){
 			sliderObj.sliderHandleImg.style.left = handlePos + 'px';		
 			if(!sliderObj.sliderValueReversed){
				returnValue = Math.round((handlePos/sliderObj.sliderSize) * (sliderObj.sliderMaxValue - sliderObj.sliderMinValue));
			}else{
				returnValue = Math.round(((sliderObj.sliderSize - handlePos)/sliderObj.sliderSize) * (sliderObj.sliderMaxValue - sliderObj.sliderMinValue));
			}						
 		}else{
 			sliderObj.sliderHandleImg.style.top = handlePos + 'px';	 			
			if(sliderObj.sliderValueReversed){
				returnValue = Math.round((topPos/sliderObj.sliderSize) * (sliderObj.sliderMaxValue - sliderObj.sliderMinValue));
			}else{
				returnValue = Math.round(((sliderObj.sliderSize - handlePos)/sliderObj.sliderSize) * (sliderObj.sliderMaxValue - sliderObj.sliderMinValue));
			}		
 		}	 		
 		returnValue = returnValue + sliderObj.sliderMinValue;
 		if(sliderObj.functionToCallOnChange)eval(sliderObj.functionToCallOnChange + '(' + returnValue + ',"' + sliderObj.sliderName + '")');
 			
    }
	// }}}	
	,
	// {{{ __timerDragSlider()
    /**
     *	A small delay before the drag process starts.
     * 	
     *
     * @private	
     */	
    __timerDragSlider : function()
    {
		if(this.slideInProcessTimer<10 && this.slideInProcessTimer>=0){
			this.slideInProcessTimer = this.slideInProcessTimer +1;
			window.refToThisSlider = this;
			setTimeout('window.refToThisSlider.__timerDragSlider()',5);
		}
		
    }
    // }}}	
	,
	// {{{ __moveSlider()
    /**
     *	Move the slider
     * 	
     *
     * @private	
     */	
    __moveSlider : function(e)
    {
    	if(DHTMLSuite.indexOfCurrentlyActiveSlider===false)return;
    	var sliderObj = DHTMLSuite.sliderObjects[DHTMLSuite.indexOfCurrentlyActiveSlider];
    	if(document.all)e = event;
		if(sliderObj.slideInProcessTimer<10)return;
		
    	var returnValue;
    	
    	// Static steps defined ?
    	if(sliderObj.numberOfSteps){	// Find value to calculate modulus by
    		modValue = sliderObj.sliderSize / sliderObj.numberOfSteps;	
    	}	
    	
    	if(sliderObj.sliderDirection=='hor'){
    		var handlePos = e.clientX - sliderObj.slide_event_pos + sliderObj.slide_start_pos;
    	}else{
    		var handlePos = e.clientY - sliderObj.slide_event_pos + sliderObj.slide_start_pos;
    	}
		if(sliderObj.numberOfSteps){
 			var mod = handlePos % modValue;
 			if(mod>(modValue/2))mod = modValue-mod; else mod*=-1; 				
				handlePos = handlePos + mod;
		}    	
		if(handlePos<0)handlePos = 0;
		if(handlePos > sliderObj.sliderSize)handlePos = sliderObj.sliderSize;		
		
		if(sliderObj.sliderDirection=='hor'){
			sliderObj.sliderHandleImg.style.left = handlePos + 'px';		
			if(!sliderObj.sliderValueReversed){
				returnValue = Math.round((handlePos/sliderObj.sliderSize) * (sliderObj.sliderMaxValue - sliderObj.sliderMinValue));
			}else{
				returnValue = Math.round(((sliderObj.sliderSize - handlePos)/sliderObj.sliderSize) * (sliderObj.sliderMaxValue - sliderObj.sliderMinValue));
			}
		}else{
			sliderObj.sliderHandleImg.style.top = handlePos + 'px';
			if(sliderObj.sliderValueReversed){
				returnValue = Math.round((handlePos/sliderObj.sliderSize) * (sliderObj.sliderMaxValue - sliderObj.sliderMinValue));
			}else{
				returnValue = Math.round(((sliderObj.sliderSize - handlePos)/sliderObj.sliderSize) * (sliderObj.sliderMaxValue - sliderObj.sliderMinValue));
			}
						
		}		
			
		returnValue = returnValue + sliderObj.sliderMinValue;
		
		
		if(sliderObj.functionToCallOnChange)eval(sliderObj.functionToCallOnChange + '(' + returnValue + ',"' + sliderObj.sliderName + '")');
		
    }
    // }}}	
	,
	// {{{ __stopSlideProcess()
    /**
     *	Stop the drag process
     * 	
     *
     * @private	
     */	
    __stopSlideProcess : function(e)
    {
    	if(!DHTMLSuite.indexOfCurrentlyActiveSlider)return;
    	var sliderObj = DHTMLSuite.sliderObjects[DHTMLSuite.indexOfCurrentlyActiveSlider];
    	sliderObj.slideInProcessTimer = -1;	
    }	
}

/*[FILE_START:dhtmlSuite-modalMessage.js] */
/************************************************************************************************************
*	DHTML modal dialog box
*
*	Created:						August, 26th, 2006
*	@class Purpose of class:		Display a modal dialog box on the screen.
*			
*	Css files used by this script:	modal-message.css
*
*	Demos of this class:			demo-modal-message-1.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Display a modal DHTML message on the page. All other page controls will be disabled until the message is closed(<a href="../../demos/demo-modal-message-1.html" target="_blank">demo</a>).
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

DHTMLSuite.modalMessage = function()
{
	var url;								// url of modal message
	var htmlOfModalMessage;					// html of modal message
	
	var divs_transparentDiv;				// Transparent div covering page content
	var divs_content;						// Modal message div.
	var layoutCss;							// Name of css file;
	var width;								// Width of message box
	var height;								// Height of message box
	
	var existingBodyOverFlowStyle;			// Existing body overflow css
	var dynContentObj;						// Reference to dynamic content object
	var cssClassOfMessageBox;				// Alternative css class of message box - in case you want a different appearance on one of them
	var shadowDivVisible;					// Shadow div visible ? 
	var shadowOffset; 						// X and Y offset of shadow(pixels from content box)
	
	this.url = '';							// Default url is blank
	this.htmlOfModalMessage = '';			// Default message is blank
	this.layoutCss = 'modal-message.css';	// Default CSS file
	this.height = 200;						// Default height of modal message
	this.width = 400;						// Default width of modal message
	this.cssClassOfMessageBox = false;		// Default alternative css class for the message box
	this.shadowDivVisible = true;			// Shadow div is visible by default
	this.shadowOffset = 5;					// Default shadow offset.
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	// This line starts all the init methods
	

}

DHTMLSuite.modalMessage.prototype = {
	// {{{ setSource(urlOfSource)
    /**
     *	Set source of the modal dialog box
     * 	
     *
     * @public	
     */		
	setSource : function(urlOfSource)
	{
		this.url = urlOfSource;
		
	}	
	// }}}	
	,
	// {{{ setHtmlContent(newHtmlContent)
    /**
     *	Setting static HTML content for the modal dialog box.
     * 	
     *	@param String newHtmlContent = Static HTML content of box
     *
     * @public	
     */		
	setHtmlContent : function(newHtmlContent)
	{
		this.htmlOfModalMessage = newHtmlContent;
		
	}
	// }}}		
	,
	// {{{ setSize(width,height)
    /**
     *	Set the size of the modal dialog box
     * 	
     *	@param int width = width of box
     *	@param int height = height of box
     *
     * @public	
     */		
	setSize : function(width,height)
	{
		if(width)this.width = width;
		if(height)this.height = height;		
	}
	// }}}		
	,		
	// {{{ setCssClassMessageBox(newCssClass)
    /**
     *	Assign the message box to a new css class.(in case you wants a different appearance on one of them)
     * 	
     *	@param String newCssClass = Name of new css class (Pass false if you want to change back to default)
     *
     * @public	
     */		
	setCssClassMessageBox : function(newCssClass)
	{
		this.cssClassOfMessageBox = newCssClass;
		if(this.divs_content){
			if(this.cssClassOfMessageBox)
				this.divs_content.className=this.cssClassOfMessageBox;
			else
				this.divs_content.className='modalDialog_contentDiv';	
		}
					
	}
	// }}}		
	,	
	// {{{ setShadowOffset(newShadowOffset)
    /**
     *	Specify the size of shadow
     * 	
     *	@param Int newShadowOffset = Offset of shadow div(in pixels from message box - x and y)
     *
     * @public	
     */		
	setShadowOffset : function(newShadowOffset)
	{
		this.shadowOffset = newShadowOffset
					
	}
	// }}}		
	,	
	// {{{ setWaitMessage(newMessage)
    /**
     *	Set a wait message when Ajax is busy inserting content
     * 	
     *	@param String newMessage = New wait message
     *
     * @public	
     */		
	setWaitMessage : function(newMessage)
	{
		if(!this.dynContentObj){
			this.dynContentObj = new DHTMLSuite.dynamicContent();	// Creating dynamic content object if it doesn't already exist.
		}	
		this.dynContentObj.setWaitMessage(newMessage);	// Calling the DHTMLSuite.dynamicContent setWaitMessage
	}
	// }}}		
	,	
	// {{{ setCache()
    /**
     *	Enable or disable cache for the ajax object
     * 	
     *	@param Boolean cacheStatus = false = off, true = on
     *
     * @public	
     */		
	setCache : function(cacheStatus)
	{
		if(!this.dynContentObj){
			this.dynContentObj = new DHTMLSuite.dynamicContent();	// Creating dynamic content object if it doesn't already exist.
		}	
		this.dynContentObj.setCache(cacheStatus);	// Calling the DHTMLSuite_dynamicContent setCache
		
	}
	// }}}		
	,
	// {{{ display()
    /**
     *	Display the modal dialog box
     * 	
     *
     * @public	
     */		
	display : function()
	{
		if(!this.divs_transparentDiv){
			DHTMLSuite.commonObj.loadCSS(this.layoutCss);
			this.__createDivs();
		}	
		
		// Redisplaying divs
		this.divs_transparentDiv.style.display='block';
		this.divs_content.style.display='block';
		this.divs_shadow.style.display='block';		
			
		this.__resizeDivs();
		
		/* Call the __resizeDivs method twice in case the css file has changed. The first execution of this method may not catch these changes */
		window.refToThisModalBoxObj = this;		
		setTimeout('window.refToThisModalBoxObj.__resizeDivs()',150);
		
		this.__insertContent();	// Calling method which inserts content into the message div.
	}
	// }}}		
	,
	// {{{ ()
    /**
     *	Display the modal dialog box
     * 	
     *
     * @public	
     */		
	setShadowDivVisible : function(visible)
	{
		this.shadowDivVisible = visible;
	}
	// }}}	
	,
	// {{{ close()
    /**
     *	Close the modal dialog box
     * 	
     *
     * @public	
     */		
	close : function()
	{
		document.documentElement.style.overflow = '';	// Setting the CSS overflow attribute of the <html> tag back to default.
		/* Hiding divs */
		this.divs_transparentDiv.style.display='none';
		this.divs_content.style.display='none';
		this.divs_shadow.style.display='none';
		
	}
	// }}}	
	,
	// {{{ __createDivs()
    /**
     *	Create the divs for the modal dialog box
     * 	
     *
     * @private	
     */		
	__createDivs : function()
	{
		// Creating transparent div
		this.divs_transparentDiv = document.createElement('DIV');
		this.divs_transparentDiv.className='DHTMLSuite_modalDialog_transparentDivs';
		this.divs_transparentDiv.style.left = '0px';
		this.divs_transparentDiv.style.top = '0px';
		document.body.appendChild(this.divs_transparentDiv);
		// Creating content div
		this.divs_content = document.createElement('DIV');
		this.divs_content.className = 'DHTMLSuite_modalDialog_contentDiv';
		this.divs_content.id = 'DHTMLSuite_modalBox_contentDiv';
		document.body.appendChild(this.divs_content);
		// Creating shadow div
		this.divs_shadow = document.createElement('DIV');
		this.divs_shadow.className = 'DHTMLSuite_modalDialog_contentDiv_shadow';
		document.body.appendChild(this.divs_shadow);

	}
	// }}}	
	,
	// {{{ __resizeDivs()
    /**
     *	Resize the message divs
     * 	
     *
     * @private	
     */	
    __resizeDivs : function()
    {
    	
    	var topOffset = Math.max(document.body.scrollTop,document.documentElement.scrollTop);

		if(this.cssClassOfMessageBox)
			this.divs_content.className=this.cssClassOfMessageBox;
		else
			this.divs_content.className='DHTMLSuite_modalDialog_contentDiv';	
			    	
    	if(!this.divs_transparentDiv)return;
    	document.documentElement.style.overflow = 'hidden';
    	
    	var bodyWidth = document.documentElement.clientWidth;
    	var bodyHeight = document.documentElement.clientHeight;

    	
    	// Setting width and height of content div
      	this.divs_content.style.width = this.width + 'px';
    	this.divs_content.style.height= this.height + 'px';  	
    	
    	// Creating temporary width variables since the actual width of the content div could be larger than this.width and this.height(i.e. padding and border)
    	var tmpWidth = this.divs_content.offsetWidth;	
    	var tmpHeight = this.divs_content.offsetHeight;
    	
    	
    	// Setting width and height of left transparent div
    	this.divs_transparentDiv.style.width = Math.ceil((bodyWidth - tmpWidth) / 2) + 'px';
    	this.divs_transparentDiv.style.height = bodyHeight + 'px';
    	
    	// Setting size extremely large for bottom, left and right side transparent divs.
    	this.divs_transparentDiv.style.height = '4000px';   
    	this.divs_transparentDiv.style.width = '4000px';   
    	
    	
		
    	this.divs_content.style.left = Math.ceil((bodyWidth - tmpWidth) / 2) + 'px';;
    	this.divs_content.style.top = (Math.ceil((bodyHeight - tmpHeight) / 2) +  topOffset) + 'px';
    	
 	
    	this.divs_shadow.style.left = (this.divs_content.style.left.replace('px','')/1 + this.shadowOffset) + 'px';
    	this.divs_shadow.style.top = (this.divs_content.style.top.replace('px','')/1 + this.shadowOffset) + 'px';
    	this.divs_shadow.style.height = tmpHeight + 'px';
    	this.divs_shadow.style.width = tmpWidth + 'px';
    	
    	
    	
    	if(!this.shadowDivVisible)this.divs_shadow.style.display='none';	// Hiding shadow if it has been disabled
    	
    	
    }	
	// }}}	
	,
	// {{{ __insertContent()
    /**
     *	Insert content into the content div
     * 	
     *
     * @private	
     */	
    __insertContent : function()
    {
		if(!this.dynContentObj){// dynamic content object doesn't exists?
			this.dynContentObj = new DHTMLSuite.dynamicContent();	// Create new DHTMLSuite_dynamicContent object.
		}
		if(this.url){	// url specified - load content dynamically
			this.dynContentObj.loadContent('DHTMLSuite_modalBox_contentDiv',this.url);
		}else{	// no url set, put static content inside the message box
			this.divs_content.innerHTML = this.htmlOfModalMessage;	
		}
    }		
}



/*[FILE_START:dhtmlSuite-dynamicTooltip.js] */
/************************************************************************************************************
*	DHTML dynamic tooltip script
*
*	Created:						August, 26th, 2006
*	@class Purpose of class:		Displays tooltips on screen with content from external files.
*			
*	Css files used by this script:	dynamic-tooltip.css
*
*	Demos of this class:			demo-dyn-tooltip-1.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Display a tooltip on screen with content from an external file(AJAX) (<a href="../../demos/demo-dyn-tooltip-1.html" target="_blank">Demo</a>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

DHTMLSuite.dynamicTooltip = function()
{
	var x_offset_tooltip;					// X Offset tooltip
	var y_offset_tooltip;					// Y offset tooltip
	var ajax_tooltipObj;
	var ajax_tooltipObj_iframe;
	var dynContentObj;						// Reference to dynamic content object
	var layoutCss;
	
	/* Offset position of tooltip */
	this.x_offset_tooltip = 5;
	this.y_offset_tooltip = 0;
	this.ajax_tooltipObj = false;
	this.ajax_tooltipObj_iframe = false;
	this.layoutCss = 'dynamic-tooltip.css';
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	// This line starts all the init methods

	
}

DHTMLSuite.dynamicTooltip.prototype = {
	// {{{ displayTooltip(externalFile,inputObj)
    /**
     *	Hides the tooltip - should be called in onmouseout events
     * 	
     *	@param String externalfile - Relative path to external file
     * 	@param Object inputObj - Reference to tag on webpage.(usually "this" in an onmouseover event)
     *
     * @public	
     */	
	displayTooltip : function(externalFile,inputObj)
	{
		DHTMLSuite.commonObj.loadCSS(this.layoutCss);
		if(!this.dynContentObj){
			this.dynContentObj = new DHTMLSuite.dynamicContent();	// Creating dynamic content object if it doesn't already exist.
		}
				
		if(!this.ajax_tooltipObj)	/* Tooltip div not created yet ? */
		{
		
			this.ajax_tooltipObj = document.createElement('DIV');
			this.ajax_tooltipObj.style.position = 'absolute';
			this.ajax_tooltipObj.id = 'DHTMLSuite_ajax_tooltipObj';		
			document.body.appendChild(this.ajax_tooltipObj);
	
			
			var leftDiv = document.createElement('DIV');	/* Create arrow div */
			leftDiv.className='DHTMLSuite_ajax_tooltip_arrow';
			leftDiv.id = 'DHTMLSuite_ajax_tooltip_arrow';
			leftDiv.style.backgroundImage = 'url(\'' +  DHTMLSuite.configObj.imagePath + 'dyn-tooltip-arrow.gif' + '\')';
			this.ajax_tooltipObj.appendChild(leftDiv);
			
			var contentDiv = document.createElement('DIV'); /* Create tooltip content div */
			contentDiv.className = 'DHTMLSuite_ajax_tooltip_content';
			this.ajax_tooltipObj.appendChild(contentDiv);
			contentDiv.id = 'DHTMLSuite_ajax_tooltip_content';
			
			if(DHTMLSuite.clientInfoObj.isMSIE){	/* Create iframe object for MSIE in order to make the tooltip cover select boxes */
				this.ajax_tooltipObj_iframe = document.createElement('<IFRAME frameborder="0">');
				this.ajax_tooltipObj_iframe.style.position = 'absolute';
				this.ajax_tooltipObj_iframe.border='0';
				this.ajax_tooltipObj_iframe.frameborder=0;
				this.ajax_tooltipObj_iframe.style.backgroundColor='#FFF';
				this.ajax_tooltipObj_iframe.src = 'about:blank';
				contentDiv.appendChild(this.ajax_tooltipObj_iframe);
				this.ajax_tooltipObj_iframe.style.left = '0px';
				this.ajax_tooltipObj_iframe.style.top = '0px';
			}
	
				
		}
		// Find position of tooltip
		this.ajax_tooltipObj.style.display='block';
		this.dynContentObj.loadContent('DHTMLSuite_ajax_tooltip_content',externalFile);
		if(DHTMLSuite.clientInfoObj.isMSIE){
			this.ajax_tooltipObj_iframe.style.width = this.ajax_tooltipObj.clientWidth + 'px';
			this.ajax_tooltipObj_iframe.style.height = this.ajax_tooltipObj.clientHeight + 'px';
		}
	
		this.__positionTooltip(inputObj);
	}	
	// }}}	
	,
	// {{{ setLayoutCss(newCssFileName)
    /**
     *	Set new CSS file name
     *
     *	@param String newCssFileName - name of new css file. Should be called before any tooltips are displayed on the screen.	
     *
     * @public	
     */	
	setLayoutCss : function(newCssFileName)
	{
		this.layoutCss = newCssFileName;
	}	
	// }}}		
	,
	// {{{ hideTooltip()
    /**
     *	Hides the tooltip - should be called in onmouseout events
     * 	
     *
     * @public	
     */	
	hideTooltip : function()
	{
		this.ajax_tooltipObj.style.display='none';
	}	
	// }}}	
	,
	// {{{ __positionTooltip()
    /**
     *	Positions the tooltip
     * 	
     *	@param Object inputobject = Reference to element on web page. Used when the script determines where to place the tooltip
     *
     * @private	
     */	
	__positionTooltip : function(inputObj)
	{
		var leftPos = (DHTMLSuite.commonObj.getLeftPos(inputObj) + inputObj.offsetWidth);
		var topPos = DHTMLSuite.commonObj.getTopPos(inputObj);
		var tooltipWidth = document.getElementById('DHTMLSuite_ajax_tooltip_content').offsetWidth +  document.getElementById('DHTMLSuite_ajax_tooltip_arrow').offsetWidth; 
		
		this.ajax_tooltipObj.style.left = leftPos + 'px';
		this.ajax_tooltipObj.style.top = topPos + 'px';		
	}	
	
	
}
/*[FILE_START:dhtmlSuite-infoPanel.js] */
/************************************************************************************************************
*	DHTML dynamic tooltip script
*
*	Created:						September, 26th, 2006
*	@class Purpose of class:		Transforms a regular div into a expandable info pane.
*			
*	Css files used by this script:	info-pane.css
*
*	Demos of this class:			demo-info-pane-1.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Transforms a regular div into a expandable info pane. (<a href="../../demos/demo-info-pane-1.html" target="_blank">Demo</a>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

	
DHTMLSuite.infoPanel = function()
{
	
	var xpPanel_slideActive;			// Slide down/up active?
	var xpPanel_slideSpeed ;			// Speed of slide
	var xpPanel_onlyOneExpandedPane;	// Only one pane expanded at a time ?	
	var savedActivePane;
	var savedActiveSub;
	var xpPanel_currentDirection;	
	var cookieNames;
	var layoutCSS;
	var arrayOfPanes;
	var dynamicContentObj;
	var paneHeights;					// Array of info pane heights.
	
	var currentlyExpandedPane = false;
	this.xpPanel_slideActive = true;	// Slide down/up active?
	this.xpPanel_slideSpeed = 20;	// Speed of slide
	this.xpPanel_onlyOneExpandedPane = false;	// Only one pane expanded at a time ?	
	this.savedActivePane = false;
	this.savedActiveSub = false;
	this.xpPanel_currentDirection = new Array();	
	this.cookieNames = new Array();	
	this.currentlyExpandedPane = false;
	this.layoutCSS = 'info-pane.css';	// Default css file for this widget.
	this.arrayOfPanes = new Array();
	this.paneHeights = new Array();
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	// This line starts all the init methods
	this.dynamicContentObj = new DHTMLSuite.dynamicContent();
			
	
		
		
	
}

	
	
DHTMLSuite.infoPanel.prototype = {	
	// {{{ addPane()
    /**
     *	Define a pane.
     * 	
     *	@param String idOfPane = Id of the element you want to transfor into a info pane
     *  @param String labelOfPane = The label you want to set for this pane
     *  @param Boolean State = Initial state of pane, expanded or collapsed(true = Expanded, false = collapsed)
     *  @param nameOfCookie = Name of cookie for this pane, i.e. saving states
     *  @param Int width = Width of pane(Optional)
     *
     * @public	
     */		
	addPane : function(idOfPane,labelOfPane,state,nameOfCookie,width)
	{
		var index = this.arrayOfPanes.length;
		this.arrayOfPanes[index] = [idOfPane,labelOfPane,state,nameOfCookie,width];
	}
	// }}}	
	,
	// {{{ addContentToPane()
    /**
     *	Replace content inside a pane with content from an external file.
     * 	
     *	@param String idOfPane = Id of the element you want to transfor into a info pane
     *  @param String pathToExternalFile = Relative path to file. The content of this file will be placed inside the info pane.
     *
     * @public	
     */		
	addContentToPane : function(idOfPane,pathToExternalFile)
	{
		var obj = document.getElementById(idOfPane);
		var subDivs = obj.getElementsByTagName('DIV');
		for(var no=0;no<subDivs.length;no++){
			if(subDivs[no].className=='DHTMLSuite_infoPaneContent'){
				window.refToThisPane = this;		
				this.__slidePane(this.xpPanel_slideSpeed,subDivs[no].id);			
				this.dynamicContentObj.loadContent(subDivs[no].id,pathToExternalFile,"window.refToThisPane.__repositionPane('" + idOfPane + "')");					
				if(subDivs[no].parentNode.style.display=='none' || subDivs[no].parentNode.style.height=='0px'){	// Pane is collapsed, expand it
					var topBarObj = DHTMLSuite.domQueryObj.getElementsByClassName('DHTMLSuite_infoPaneTopBar',subDivs[no].parentNode.parentNode);
					this.__showHidePaneContent(topBarObj[0]);
				}	
				return;	
			}		
		}
	}
	// }}}	
	,
	// {{{ addStaticContentToPane()
    /**
     *	Replace content inside a pane with some new static content.
     * 	
     *	@param String idOfPane = Id of the element you want to transfor into a info pane
     *  @param String newContent = New content. (Static html).
     *
     * @public	
     */		
	addStaticContentToPane : function(idOfPane,newContent)
	{
		var obj = document.getElementById(idOfPane);
		var subDivs = obj.getElementsByTagName('DIV');
		for(var no=0;no<subDivs.length;no++){
			if(subDivs[no].className=='DHTMLSuite_infoPaneContent'){			
				window.refToThisPane = this;		
				this.__slidePane(this.xpPanel_slideSpeed,subDivs[no].id);			
				subDivs[no].innerHTML = newContent;						
				if(subDivs[no].parentNode.style.display=='none' || subDivs[no].parentNode.style.height=='0px'){	// Pane is collapsed, expand it
					var topBarObj = DHTMLSuite.domQueryObj.getElementsByClassName('DHTMLSuite_infoPaneTopBar',subDivs[no].parentNode.parentNode);
					this.__showHidePaneContent(topBarObj[0]);
				}	
				this.__repositionPane(idOfPane);
				return;		
			}		
		}
	}
	// }}}	
	,	
	// {{{ init()
    /**
     *	Initializes the script. This method should be called after you have added all your panes.
     * 	
     *	@param Object inputobject = Reference to element on web page.
     *
     * @public	
     */	
	init : function()
	{
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);
		
		for(var no=0;no<this.arrayOfPanes.length;no++){		// Loop through panes	
			var tmpDiv = document.getElementById(this.arrayOfPanes[no][0]);	// Creating reference to pane div.
			tmpDiv.className = 'DHTMLSuite_panel';	// Assigning it to class DHTMLSuite_panel
			var panelTitle = this.arrayOfPanes[no][1];	
			var panelDisplayed = this.arrayOfPanes[no][2];
			var nameOfCookie = this.arrayOfPanes[no][3];
			var widthOfPane = this.arrayOfPanes[no][4];
					
			if(widthOfPane)tmpDiv.style.width = widthOfPane;
			
			var outerContentDiv = document.createElement('DIV');	
			var contentDiv = tmpDiv.getElementsByTagName('DIV')[0];
			contentDiv.className = 'DHTMLSuite_infoPaneContent';
			contentDiv.id = 'infoPaneContent' + no;
			outerContentDiv.appendChild(contentDiv);	
			this.cookieNames[this.cookieNames.length] = nameOfCookie;
			
			outerContentDiv.id = 'paneContent' + no;
			outerContentDiv.className = 'DHTMLSuite_panelContent';
			outerContentDiv.style.backgroundImage = 'url(\'' + DHTMLSuite.configObj.imagePath + 'xp-info-pane-bg_pane_right.gif' + '\')';			
			
			var topBar = document.createElement('DIV');
			topBar.onselectstart = function() { return DHTMLSuite.commonObj.cancelEvent() };
			DHTMLSuite.commonObj.__addEventElement(topBar);
			var span = document.createElement('SPAN');				
			span.innerHTML = panelTitle;
			topBar.appendChild(span);
			topBar.style.backgroundImage = 'url(\'' + DHTMLSuite.configObj.imagePath + 'xp-info-pane-bg_panel_top_right.gif' + '\')';
			window.refToXpPane = this;
			topBar.onclick = function(){ window.refToXpPane.__showHidePaneContent(this) };
			if(document.all)topBar.ondblclick = function(){ window.refToXpPane.__showHidePaneContent(this) };;
			topBar.onmouseover = this.__mouseoverTopbar;	// Adding mouseover effect to heading
			topBar.onmouseout = this.__mouseoutTopbar;	// Adding mouseout effect to heading
			topBar.style.position = 'relative';	// Relative positioning of heading

			var img = document.createElement('IMG');	// Adding arrow image
			img.id = 'showHideButton' + no;
			img.src = DHTMLSuite.configObj.imagePath + 'xp-info-pane-arrow_up.gif';				
			topBar.appendChild(img);
			
			if(nameOfCookie){	// Cookie defined?
				cookieValue =  DHTMLSuite.commonObj.getCookie(nameOfCookie);	
				if(cookieValue)panelDisplayed = cookieValue==1?true:false; // Cookie value exists? -> Expand or collapse pane.
				
			}
			
			if(!panelDisplayed){	// Hide pane initially.
				outerContentDiv.style.height = '0px';
				contentDiv.style.top = 0 - contentDiv.offsetHeight + 'px';
				if(document.all)outerContentDiv.style.display='none';
				img.src = DHTMLSuite.configObj.imagePath + 'xp-info-pane-arrow_down.gif';
			}
							
			topBar.className='DHTMLSuite_infoPaneTopBar';
			topBar.id = 'infoPane_topBar' + no;
			tmpDiv.appendChild(topBar);				
			tmpDiv.appendChild(outerContentDiv);	
		}
	}		
	// }}}			
	,	
	// {{{ __repositionPane()
    /**
     *	Fixes the layout of a pane after content has been added to it dynamically.
     * 	
     *	@param String idOfPane = Id of the pane
     *
     * @private	
     */		
	__repositionPane : function(idOfPane)
	{
		var obj = document.getElementById(idOfPane);
		var subDivs = obj.getElementsByTagName('DIV');
		for(var no=0;no<subDivs.length;no++){
			if(subDivs[no].className=='DHTMLSuite_panelContent'){	
				subDivs[no].style.overflow = 'auto';	
				subDivs[no].style.height = '';		
				var contentDiv = subDivs[no].getElementsByTagName('DIV')[0];				
				var tmpHeight = subDivs[no].clientHeight;
				tmpHeight = subDivs[no].offsetHeight;				
				subDivs[no].style.height = tmpHeight + 'px';
				if(tmpHeight)this.paneHeights[subDivs[no].id] = tmpHeight;
				subDivs[no].style.top = '0px';
				subDivs[no].style.overflow = 'hidden';
				var subSub = subDivs[no].getElementsByTagName('DIV')[0];
				subSub.style.top = '0px';
			}		
		}
	}
	// }}}	
	,	
	// {{{ __showHidePaneContent()
    /**
     *	Expand or collapse a frame
     * 	
     *	@param Object inputobject = Reference to element on web page.
     *	@param String methodWhenFinished = Method to execute when slide is finished(optional)
     *
     * @private	
     */	
	__showHidePaneContent : function(inputObj,methodWhenFinished)
	{
		var img = inputObj.getElementsByTagName('IMG')[0];
		var numericId = img.id.replace(/[^0-9]/g,'');
		var obj = document.getElementById('paneContent' + numericId);
		if(img.src.toLowerCase().indexOf('up')>=0){
			this.currentlyExpandedPane = false;
			img.src = img.src.replace('up','down');
			if(this.xpPanel_slideActive){
				obj.style.display='block';
				this.xpPanel_currentDirection[obj.id] = (this.xpPanel_slideSpeed*-1);
				this.__slidePane((this.xpPanel_slideSpeed*-1), obj.id,methodWhenFinished);
			}else{
				obj.style.display='none';
			}
			if(this.cookieNames[numericId])DHTMLSuite.commonObj.setCookie(this.cookieNames[numericId],'0',100000);
		}else{
			if(inputObj){
				if(this.currentlyExpandedPane && this.xpPanel_onlyOneExpandedPane)this.__showHidePaneContent(this.currentlyExpandedPane);
				this.currentlyExpandedPane = inputObj;	
			}
			img.src = img.src.replace('down','up');
			if(this.xpPanel_slideActive){
				if(document.all){
					obj.style.display='block';
				}
				this.xpPanel_currentDirection[obj.id] = this.xpPanel_slideSpeed;
				this.__slidePane(this.xpPanel_slideSpeed,obj.id,methodWhenFinished);
			}else{
				obj.style.display='block';
				subDiv = obj.getElementsByTagName('DIV')[0];
				obj.style.height = subDiv.offsetHeight + 'px';
			}
			if(this.cookieNames[numericId])DHTMLSuite.commonObj.setCookie(this.cookieNames[numericId],'1',100000);
		}	
		return true;	
	}
	// }}}	
	,	
	// {{{ __slidePane()
    /**
     *	Animating expand/collapse
     * 	
     *	@param Int slideValue = Positive or negative value, positive when expanding, negative when collapsing
     *  @param String id = Id of the pane currently being expanded/collapsed.
     *	@param String methodWhenFinished = Method to execute when slide is finished(optional)
     *
     * @private	
     */		
	__slidePane : function(slideValue,id,methodWhenFinished)
	{
		if(slideValue!=this.xpPanel_currentDirection[id]){
			return false;
		}
		var activePane = document.getElementById(id);
		if(activePane==this.savedActivePane){
			var subDiv = this.savedActiveSub;
		}else{
			var subDiv = activePane.getElementsByTagName('DIV')[0];
		}
		this.savedActivePane = activePane;
		this.savedActiveSub = subDiv;
		
		var height = activePane.offsetHeight;
		var innerHeight = subDiv.offsetHeight;
		if(this.paneHeights[activePane.id])innerHeight = this.paneHeights[activePane.id];
		height+=slideValue;
		if(height<0)height=0;
		if(height>innerHeight)height = innerHeight;
		
		if(document.all){
			activePane.style.filter = 'alpha(opacity=' + Math.round((height / innerHeight)*100) + ')';
		}else{
			var opacity = (height / innerHeight);
			if(opacity==0)opacity=0.01;
			if(opacity==1)opacity = 0.99;
			activePane.style.opacity = opacity;
		}			
		window.refToThisInfoPane = this;
		if(slideValue<0){			
			activePane.style.height = height + 'px';
			subDiv.style.top = height - innerHeight + 'px';
			if(height>0){
				setTimeout('window.refToThisInfoPane.__slidePane(' + slideValue + ',"' + id + '","' + methodWhenFinished + '")',10);
			}else{
				if(document.all)activePane.style.display='none';
				if(methodWhenFinished)eval(methodWhenFinished);
			}
		}else{			
			subDiv.style.top = height - innerHeight + 'px';
			activePane.style.height = height + 'px';
			if(height<innerHeight){				
				setTimeout('window.refToThisInfoPane.__slidePane(' + slideValue + ',"' + id + '","' + methodWhenFinished + '")',10);				
			}else{
				if(methodWhenFinished)eval(methodWhenFinished);
			}		
		}		
	}
	,
	// {{{ __mouseoverTopbar()
    /**
     *	Toolbar mouse over effect.
     * 	
     *
     * @private	
     */			
	__mouseoverTopbar : function()
	{
		var img = this.getElementsByTagName('IMG')[0];
		var src = img.src;
		img.src = img.src.replace('.gif','_over.gif');
		
		var span = this.getElementsByTagName('SPAN')[0];
		span.style.color='#428EFF';		
		
	}
	// }}}	
	,
	// {{{ __mouseoutTopbar()
    /**
     *	Toolbar mouse out effect.
     * 	
     *
     * @private	
     */			
	__mouseoutTopbar : function()
	{
		var img = this.getElementsByTagName('IMG')[0];
		var src = img.src;
		img.src = img.src.replace('_over.gif','.gif');		
		
		var span = this.getElementsByTagName('SPAN')[0];
		span.style.color='';
	}
}
/*[FILE_START:dhtmlSuite-progressBar.js] */
/************************************************************************************************************
*	DHTML progress bar script
*
*	Created:						October, 21st, 2006
*	@class Purpose of class:		Display a progress bar while content loads or dynamic content is created on the server.
*			
*	Css files used by this script:	progress-bar.css
*
*	Demos of this class:			demo-progress-bar.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Creates a progress bar. (<a href="../../demos/demo-progress-bar-1.html" target="_blank">Demo</a>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/


DHTMLSuite.progressBar = function()
{

	var progressBar_steps;
	var div_progressPane;
	var div_progressBar_bg;
	var div_progressBar_outer;
	var div_progressBar_txt;
	
	var progressBarWidth;
	var currentStep;
	var layoutCSS;
	
	this.progressBar_steps = 50;
	this.progressPane = false;
	this.progressBar_bg = false;
	this.progressBar_outer = false;
	this.progressBar_txt = false;
	this.progressBarWidth;
	this.currentStep = 0;	
	this.layoutCSS = 'progress-bar.css';
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	
	
}

DHTMLSuite.progressBar.prototype = {
	// {{{ setSteps()
    /**
     *	Initializes the progress bar script
     *
     *	@param Int numberOfSteps - Number of progress bar steps, example: 50 will show 2%,4%,6%...98%,100%.
     * 	
     *
     * @public	
     */			
	setSteps : function(numberOfSteps)
	{
		this.progressBar_steps = numberOfSteps;		
	}
	
	// }}}	
	,
	// {{{ init()
    /**
     *	Initializes the progress bar script
     *
     * 	
     *
     * @public	
     */		
	init : function()
	{		
		document.body.style.width = '100%';
		document.body.style.height = '100%';
		document.documentElement.style.overflow = 'hidden';
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);
		this.__createProgressBarElements();	
	}	
	// }}}	
	,
	// {{{ moveProgressBar()
    /**
     *	Moves the progress bar
     *
     *	@param Int Steps: Number of steps to move it. (Optional argument, if left empty, set the progress bar to 100% and hide it).
     * 	
     *
     * @public	
     */	
	moveProgressBar : function(steps){
		this.progressBarWidth = this.div_progressBar_bg.clientWidth;
		if(!steps){
			this.div_progressBar_outer.style.width = progressBarWidth + 'px';
			this.div_progressBar_txt.innerHTML = '100%';
			this.__hideProgressBar();
		}else{
			this.currentStep+=steps;
			if(this.currentStep>this.progressBar_steps)this.currentStep = this.progressBar_steps;
			var width = Math.ceil(this.progressBarWidth * (this.currentStep / this.progressBar_steps));
			this.div_progressBar_outer.style.width = width + 'px';
			
			var percent = Math.ceil((this.currentStep / this.progressBar_steps)*100);
			this.div_progressBar_txt.innerHTML = percent + '%';
			if(this.currentStep==this.progressBar_steps){
				this.__hideProgressBar();			
			}
		}	
	}
	// }}}	
	,
	// {{{ __hideProgressBar()
    /**
     *	Hides the progress bar when it's finished
     * 	
     *
     * @private	
     */	
	__hideProgressBar : function()
	{
		document.body.style.width = null;
		document.body.style.height = null;		
		document.documentElement.style.overflow = '';		
		setTimeout('document.getElementById("DHTMLSuite_progressPane").style.display="none"',50);
	}
	// }}}	
	,
	// {{{ __createProgressBarElements()
    /**
     *	Create the divs needed for the progress bar script
     * 	
     *
     * @private	
     */	
	__createProgressBarElements: function()
	{
		this.div_progressPane = document.createElement('DIV');
		this.div_progressPane.id = 'DHTMLSuite_progressPane';
		document.body.appendChild(this.div_progressPane);
		
		this.div_progressBar_bg = document.createElement('DIV');
		this.div_progressBar_bg.id = 'DHTMLSuite_progressBar_bg';
		this.div_progressPane.appendChild(this.div_progressBar_bg);		
		
		this.div_progressBar_outer = document.createElement('DIV');
		this.div_progressBar_outer.id='DHTMLSuite_progressBar_outer';
		this.div_progressBar_bg.appendChild(this.div_progressBar_outer);

		var div = document.createElement('DIV');
		div.id='DHTMLSuite_progressBar';
		this.div_progressBar_outer.appendChild(div);
		
		this.div_progressBar_txt = document.createElement('DIV');
		this.div_progressBar_txt.id='DHTMLSuite_progressBar_txt';
		this.div_progressBar_txt.innerHTML = '0 %';
		this.div_progressBar_bg.appendChild(this.div_progressBar_txt);			
	}		
}

/*[FILE_START:dhtmlSuite-menuModel.js] */
/************************************************************************************************************
*	DHTML menu model item class
*
*	Created:						October, 30th, 2006
*	@class Purpose of class:		Save data about a menu item.
*			
*
*
* 	Update log:
*
************************************************************************************************************/

DHTMLSuite.menuModelItem = function()
{
	var id;					// id of this menu item.
	var itemText;			// Text for this menu item
	var itemIcon;			// Icon for this menu item.
	var url;				// url when click on this menu item
	var parentId;			// id of parent element
	var separator;			// is this menu item a separator
	var jsFunction;			// Js function to call onclick
	var depth;				// Depth of this menu item.
	var hasSubs;			// Does this menu item have sub items.
	var type;				// Menu item type - possible values: "top" or "sub". 
	var helpText;			// Help text for this item - appear when you move your mouse over the item.
	var state;
	var submenuWidth;		// Width of sub menu items.
	var visible;			// Visibility of menu item.
	
	this.state = 'regular';
}

DHTMLSuite.menuModelItem.prototype = {

	setMenuVars : function(id,itemText,itemIcon,url,parentId,helpText,jsFunction,type,submenuWidth)	
	{
		this.id = id;
		this.itemText = itemText;
		this.itemIcon = itemIcon;
		this.url = url;
		this.parentId = parentId;
		this.jsFunction = jsFunction;
		this.separator = false;
		this.depth = false;
		this.hasSubs = false;
		this.helpText = helpText;
		this.submenuWidth = submenuWidth;
		this.visible = true;
		if(!type){
			if(this.parentId)this.type = 'top'; else this.type='sub';
		}else this.type = type;
		

	}
	// }}}	
	,
	// {{{ setState()
    /**
     *	Update the state attribute of a menu item.
     *
     *  @param String newState New state of this item
     * @public	
     */		
	setAsSeparator : function(id,parentId)
	{
		this.id = id;
		this.parentId = parentId;
		this.separator = true;	
		this.visible = true;
		if(this.parentId)this.type = 'top'; else this.type='sub';		
	}
	// }}}	
	,
	// {{{ setState()
    /**
     *	Update the visible attribute of a menu item.
     *
     *  @param Boolean visible true = visible, false = hidden.
     * @public	
     */		
	setVisibility : function(visible)
	{
		this.visible = visible;
	}
	// }}}	
	,
	// {{{ getState()
    /**
     *	Return the state attribute of a menu item.
     *
     * @public	
     */		
	getState : function()
	{
		return this.state;
	}
	// }}}	
	,
	// {{{ setState()
    /**
     *	Update the state attribute of a menu item.
     *
     *  @param String newState New state of this item
     * @public	
     */		
	setState : function(newState)
	{
		this.state = newState;
	}
	// }}}	
	,
	// {{{ setSubMenuWidth()
    /**
     *	Specify width of direct subs of this item.
     *
     *  @param int newWidth Width of sub menu group(direct sub of this item)
     * @public	
     */		
	setSubMenuWidth : function(newWidth)
	{
		this.submenuWidth = newWidth;
	}
	// }}}	
	,
	// {{{ setIcon()
    /**
     *	Specify new menu icon
     *
     *  @param String iconPath Path to new menu icon
     * @public	
     */		
	setIcon : function(iconPath)
	{
		this.itemIcon = iconPath;
	}
	// }}}	
	,
	// {{{ setText()
    /**
     *	Specify new text for the menu item.
     *
     *  @param String newText New text for the menu item.
     * @public	
     */		
	setText : function(newText)
	{
		this.itemText = newText;
	}
}

/************************************************************************************************************
*	DHTML menu model class
*
*	Created:						October, 30th, 2006
*	@class Purpose of class:		Saves menu item data
*			
*
*	Demos of this class:			demo-menu-strip.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Organize menu items for different menu widgets. demos of menus: (<a href="../../demos/demo-menu-strip.html" target="_blank">Demo</a>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/


DHTMLSuite.menuModel = function()
{
	var menuItems;					// Array of menuModelItem objects
	var menuItemsOrder;			// This array is needed in order to preserve the correct order of the array above. the array above is associative
									// And some browsers will loop through that array in different orders than Firefox and IE.
	var submenuType;				// Direction of menu items(one item for each depth)
	var mainMenuGroupWidth;			// Width of menu group - useful if the first group of items are listed below each other
	this.menuItems = new Array();
	this.menuItemsOrder = new Array();
	this.submenuType = new Array();
	this.submenuType[1] = 'top';
	for(var no=2;no<20;no++){
		this.submenuType[no] = 'sub';
	}		
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	
}

DHTMLSuite.menuModel.prototype = {
	// {{{ addItem()
    /**
     *	Add separator (special type of menu item)
     *
 	 *
     *
     *  @param int id of menu item
     *  @param string itemText = text of menu item
     *  @param string itemIcon = file name of menu icon(in front of menu text. Path will be imagePath for the DHTMLSuite + file name)
     *  @param string url = Url of menu item
     *  @param int parent id of menu item     
     *  @param String jsFunction Name of javascript function to execute. It will replace the url param. The function with this name will be called and the element triggering the action will be 
     *					sent as argument. Name of the element which triggered the menu action may also be sent as a second argument. That depends on the widget. The context menu is an example where
     *					the element triggering the context menu is sent as second argument to this function.    
     *
     * @public	
     */			
	addItem : function(id,itemText,itemIcon,url,parentId,helpText,jsFunction,type,submenuWidth)
	{
		if(!id)id = this.__getUniqueId();	// id not present - create it dynamically.
		this.menuItems[id] = new DHTMLSuite.menuModelItem();
		this.menuItems[id].setMenuVars(id,itemText,itemIcon,url,parentId,helpText,jsFunction,type,submenuWidth);
		this.menuItemsOrder[this.menuItemsOrder.length] = id;
		return this.menuItems[id];
	}
	,
	// {{{ addItemsFromMarkup()
    /**
     *	This method creates all the menuModelItem objects by reading it from existing markup on your page.
     *	Example of HTML markup:
     *<br>
		&nbsp;&nbsp;&nbsp;&nbsp;&lt;ul id="menuModel">
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="50000" itemIcon="../images/disk.gif">&lt;a href="#" title="Open the file menu">File&lt;/a>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;ul width="150">
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="500001" jsFunction="saveWork()" itemIcon="../images/disk.gif">&lt;a href="#" title="Save your work">Save&lt;/a>&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="500002">&lt;a href="#">Save As&lt;/a>&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="500004" itemType="separator">&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="500003">&lt;a href="#">Open&lt;/a>&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/ul>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="50001">&lt;a href="#">View&lt;/a>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;ul width="130">
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="500011">&lt;a href="#">Source&lt;/a>&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="500012">&lt;a href="#">Debug info&lt;/a>&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="500013">&lt;a href="#">Layout&lt;/a>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;ul width="150">
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="5000131">&lt;a href="#">CSS&lt;/a>&nbsp;&nbsp;
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="5000132">&lt;a href="#">HTML&lt;/a>&nbsp;&nbsp;
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="5000133">&lt;a href="#">Javascript&lt;/a>&nbsp;&nbsp;
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/ul>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/ul>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="50003" itemType="separator">&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;li id="50002">&lt;a href="#">Tools&lt;/a>&lt;/li>
		<br>&nbsp;&nbsp;&nbsp;&nbsp;&lt;/ul>&nbsp;&nbsp;     
     *
     *  @param String ulId = ID of <UL> tag on your page.
     *
     * @public	
     */		
	addItemsFromMarkup : function(ulId)
	{
		if(!document.getElementById(ulId)){
			alert('<UL> tag with id ' + ulId + ' does not exist');
			return;
		}
		var ulObj = document.getElementById(ulId);
		var liTags = ulObj.getElementsByTagName('LI');		
		for(var no=0;no<liTags.length;no++){	// Walking through all <li> tags in the <ul> tree
			
			var id = liTags[no].id.replace(/[^0-9]/gi,'');	// Get id of item.
			if(!id)id = this.__getUniqueId();
			this.menuItems[id] = new DHTMLSuite.menuModelItem();	// Creating new menuModelItem object
			this.menuItemsOrder[this.menuItemsOrder.length] = id;
			// Get the attributes for this new menu item.	
			
			var parentId = 0;	// Default parent id
			if(liTags[no].parentNode!=ulObj)parentId = liTags[no].parentNode.parentNode.id;	// parent node exists, set parentId equal to id of parent <li>.
						
			/* Checking type */
			var type = liTags[no].getAttribute('itemType');			
			if(!type)type = liTags[no].itemType;
			if(type=='separator'){	// Menu item of type "separator"
				this.menuItems[id].setAsSeparator(id,parentId);
				continue;	
			}
			if(parentId)type='sub'; else type = 'top';						
	
			var aTag = liTags[no].getElementsByTagName('A')[0];	// Get a reference to sub <a> tag
			if(!aTag){
				continue;
			}			
			if(aTag)var itemText = aTag.innerHTML;	// Item text is set to the innerHTML of the <a> tag.
			var itemIcon = liTags[no].getAttribute('itemIcon');	// Item icon is set from the itemIcon attribute of the <li> tag.
			var url = aTag.href;	// url is set to the href attribute of the <a> tag
			if(url=='#' || url.substr(url.length-1,1)=='#')url='';	// # = empty url.
			
			var jsFunction = liTags[no].getAttribute('jsFunction');	// jsFunction is set from the jsFunction attribute of the <li> tag.

			var submenuWidth = false;	// Not set from the <li> tag. 
			var helpText = aTag.getAttribute('title');	
			if(!helpText)helpText = aTag.title;
			
			this.menuItems[id].setMenuVars(id,itemText,itemIcon,url,parentId,helpText,jsFunction,type,submenuWidth);			
		}		
		var subUls = ulObj.getElementsByTagName('UL');
		for(var no=0;no<subUls.length;no++){
			var width = subUls[no].getAttribute('width');
			if(!width)width = subUls[no].width;	
			if(width){
				var id = subUls[no].parentNode.id.replace(/[^0-9]/gi,'');
				this.setSubMenuWidth(id,width);
			}
		}		
		ulObj.style.display='none';
		
	}	
	// }}}	
	,
	// {{{ setSubMenuWidth()
    /**
     *	This method specifies the width of a sub menu group. This is a useful method in order to get a correct width in IE6 and prior.
     *
     *  @param int id = ID of parent menu item
     *  @param String newWidth = Width of sub menu items.
     * @public	
     */		
	setSubMenuWidth : function(id,newWidth)
	{
		this.menuItems[id].setSubMenuWidth(newWidth);
	}	
	,
	// {{{ setMainMenuGroupWidth()
    /**
     *	Add separator (special type of menu item)
     *
     *  @param String newWidth = Size of a menu group
     *  @param int parent id of menu item
     * @public	
     */			
	setMainMenuGroupWidth : function(newWidth)
	{
		this.mainMenuGroupWidth = newWidth;
	}
	,
	// {{{ addSeparator()
    /**
     *	Add separator (special type of menu item)
     *
     *  @param int parent id of menu item
     * @public	
     */		
	addSeparator : function(parentId)
	{
		id = this.__getUniqueId();	// Get unique id
		if(!parentId)parentId = 0;
		this.menuItems[id] = new DHTMLSuite.menuModelItem();
		this.menuItems[id].setAsSeparator(id,parentId);
		this.menuItemsOrder[this.menuItemsOrder.length] = id;
		return this.menuItems[id];
	}	
	,
	// {{{ init()
    /**
     *	Initilizes the menu model. This method should be called when all items has been added to the model.
     *
     *
     * @public	
     */		
	init : function()
	{
		this.__getDepths();	
		this.__setHasSubs();	
		
	}
	// }}}	
	,
	// {{{ setMenuItemVisibility()
    /**
     *	Save visibility of a menu item.
     * 	
     *	@param int id = Id of menu item..
     *	@param Boolean visible = Visibility of menu item.
     *
     * @public	
     */		
	setMenuItemVisibility : function(id,visible)
	{
		this.menuItems[id].setVisibility(visible);		
	}
	// }}}
	,
	// {{{ setSubMenuType()
    /**
     *	Set menu type for a specific menu depth.
     * 	
     *	@param int depth = 1 = Top menu, 2 = Sub level 1...
     *	@param String newType = New menu type(possible values: "top" or "sub")
     *
     * @private	
     */		
	setSubMenuType : function(depth,newType)
	{
		this.submenuType[depth] = newType;	
		
	}
	// }}}		
	,
	// {{{ __getDepths()
    /**
     *	Create variable for the depth of each menu item.
     * 	
     *
     * @private	
     */		
	getItems : function(parentId,returnArray)
	{
		if(!parentId)return this.menuItems;
		if(!returnArray)returnArray = new Array();
		for(var no=0;no<this.menuItemsOrder.length;no++){
			var id = this.menuItemsOrder[no];
			if(!id)continue;
			if(this.menuItems[id].parentId==parentId){
				returnArray[returnArray.length] = this.menuItems[id];
				if(this.menuItems[id].hasSubs)return this.getItems(this.menuItems[id].id,returnArray);
			}
		}
		return returnArray;
		
	}
	// }}}
	,
	// {{{ __getUniqueId()
    /**
     *	Returns a unique id for a menu item. This method is used by the addSeparator function in case an id isn't sent to the method.
     * 	
     *
     * @private	
     */	    	
	__getUniqueId : function()
	{
		var num = Math.random() + '';
		num = num.replace('.','');	
		num = '99' + num;		
		num = num /1;		
		while(this.menuItems[num]){
			num = Math.random() + '';
			num = num.replace('.','');	
			num = num /1;				
		}
		return num;
	}
	// }}}	
	,
	// {{{ __getDepths()
    /**
     *	Create variable for the depth of each menu item.
     * 	
     *
     * @private	
     */	
    __getDepths : function()
    {    	
    	for(var no=0;no<this.menuItemsOrder.length;no++){
    		var id = this.menuItemsOrder[no];
    		if(!id)continue;
    		this.menuItems[id].depth = 1;
    		if(this.menuItems[id].parentId){
    			this.menuItems[id].depth = this.menuItems[this.menuItems[id].parentId].depth+1;    
 	
    		}  
    		this.menuItems[id].type = this.submenuType[this.menuItems[id].depth];	// Save menu direction for this menu item.  		
    	}    	
    }	
    // }}}
    ,	    
    // {{{ __setHasSubs()
    /**
     *	Create variable for the depth of each menu item.
     * 	
     *
     * @private	
     */	
    __setHasSubs : function()
    {    	
    	for(var no=0;no<this.menuItemsOrder.length;no++){
    		var id = this.menuItemsOrder[no];
    		if(!id)continue;    		
    		if(this.menuItems[id].parentId){
    			this.menuItems[this.menuItems[id].parentId].hasSubs = 1;
    			
    		}    		
    	}    	
    }	
    // }}}
    ,
	// {{{ __hasSubs()
    /**
     *	Does a menu item have sub elements ?
     * 	
     *
     * @private	
     */	
	// }}}	
	__hasSubs : function(id)
	{
		for(var no=0;no<this.menuItemsOrder.length;no++){
			var id = this.menuItemsOrder[no];
			if(!id)continue;
			if(this.menuItems[id].parentId==id)return true;		
		}
		return false;	
	}
	// }}}
	,
	// {{{ __deleteChildNodes()
    /**
     *	Deleting child nodes of a specific parent id
     * 	
     *	@param int parentId
     *
     * @private	
     */	
	// }}}		
	__deleteChildNodes : function(parentId,recursive)
	{
		var itemsToDeleteFromOrderArray = new Array();
		for(var prop=0;prop<this.menuItemsOrder.length;prop++){
    		var id = this.menuItemsOrder[prop];
    		if(!id)continue;    
    					
			if(this.menuItems[id].parentId==parentId && parentId){
				this.menuItems[id] = false;
				itemsToDeleteFromOrderArray[itemsToDeleteFromOrderArray.length] = id;				
				this.__deleteChildNodes(id,true);	// Recursive call.
			}	
		}	
		
		if(!recursive){
			for(var prop=0;prop<itemsToDeleteFromOrderArray.length;prop++){
				if(!itemsToDeleteFromOrderArray[prop])continue;
				this.__deleteItemFromItemOrderArray(itemsToDeleteFromOrderArray[prop]);
			}
		}
		this.__setHasSubs();
	}
	// }}}
	,
	// {{{ __deleteANode()
    /**
     *	Deleting a specific node from the menu model
     * 	
     *	@param int id = Id of node to delete.
     *
     * @private	
     */	
	// }}}		
	__deleteANode : function(id)
	{
		this.menuItems[id] = false;	
		this.__deleteItemFromItemOrderArray(id);	
	}
	,
	// {{{ __deleteItemFromItemOrderArray()
    /**
     *	Deleting a specific node from the menuItemsOrder array(The array controlling the order of the menu items).
     * 	
     *	@param int id = Id of node to delete.
     *
     * @private	
     */	
	// }}}		
	__deleteItemFromItemOrderArray : function(id)
	{
		for(var no=0;no<this.menuItemsOrder.length;no++){
			var tmpId = this.menuItemsOrder[no];
			if(!tmpId)continue;		
			if(this.menuItemsOrder[no]==id){
				this.menuItemsOrder.splice(no,1);
				return;
			}
		}
		
	}
	// }}}
	,	
	// {{{ __appendMenuModel()
    /**
     *	Replace the sub items of a menu item with items from a new menuModel.
     * 	
     *	@param menuModel newModel = An object of class menuModel - the items of this menu model will be appended to the existing menu items.
     *	@param Int parentId = Id of parent element of the appended items.
     *
     * @private	
     */	
	// }}}		
	__appendMenuModel : function(newModel,parentId)
	{
		if(!newModel)return;
		var items = newModel.getItems();
		for(var no=0;no<newModel.menuItemsOrder.length;no++){
			var id = newModel.menuItemsOrder[no];
			if(!id)continue;
			if(!items[id].parentId)items[id].parentId = parentId;
			this.menuItems[id] = items[id];	
			for(var no2=0;no2<this.menuItemsOrder.length;no2++){	// Check to see if this item allready exists in the menuItemsOrder array, if it does, remove it. 
				if(!this.menuItemsOrder[no2])continue;
				if(this.menuItemsOrder[no2]==items[id].id){
					this.menuItemsOrder.splice(no2,1);
				}
			}
			this.menuItemsOrder[this.menuItemsOrder.length] = items[id].id;		
		}
		this.__getDepths();		
		this.__setHasSubs();		
	}
	// }}}
}

/*[FILE_START:dhtmlSuite-menuItem.js] */
/************************************************************************************************************
*	DHTML menu item class
*
*	Created:						October, 21st, 2006
*	@class Purpose of class:		Creates the HTML for a single menu item.
*			
*	Css files used by this script:	menu-item.css
*
*	Demos of this class:			demo-menu-strip.html
*
* 	Update log:
*
************************************************************************************************************/

/**
* @constructor
* @class Purpose of class:	Creates the div(s) for a menu item. This class is used by the menuBar class. You can 
*	also create a menu item and add it where you want on your page. the createItem() method will return the div
*	for the item. You can use the appendChild() method to add it to your page. 
*
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/


DHTMLSuite.menuItem = function()
{
	var layoutCSS;	
	var divElement;							// the <div> element created for this menu item
	var expandElement;						// Reference to the arrow div (expand sub items)
	var cssPrefix;							// Css prefix for the menu items.
	var modelItemRef;						// Reference to menuModelItem

	this.layoutCSS = 'menu-item.css';
	this.cssPrefix = 'DHTMLSuite_';
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	
		
	
	var objectIndex;
	this.objectIndex = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects.length;

	
}

DHTMLSuite.menuItem.prototype = 
{
	
	/*
	*	Create a menu item.
	*
	*	@param menuModelItem menuModelItemObj = An object of class menuModelItem
	*/
	createItem : function(menuModelItemObj)
	{
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);	// Load css
		
		DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[this.objectIndex] = this;
			
		this.modelItemRef = menuModelItemObj;
		this.divElement = document.createElement('DIV');	// Create main div
		this.divElement.id = 'DHTMLSuite_menuItem' + menuModelItemObj.id;	// Giving this menu item it's unque id
		this.divElement.className = this.cssPrefix + 'menuItem_' + menuModelItemObj.type + '_regular'; 
		this.divElement.onselectstart = function() { return DHTMLSuite.commonObj.cancelEvent() };
		if(menuModelItemObj.helpText){	// Add "title" attribute to the div tag if helpText is defined
			this.divElement.title = menuModelItemObj.helpText;
		}
		
		// Menu item of type "top"
		if(menuModelItemObj.type=='top'){			
			this.__createMenuElementsOfTypeTop(this.divElement);
		}

		if(menuModelItemObj.type=='sub'){
			this.__createMenuElementsOfTypeSub(this.divElement);
		}
		
		if(menuModelItemObj.separator){
			this.divElement.className = this.cssPrefix + 'menuItem_separator_' + menuModelItemObj.type;
			this.divElement.innerHTML = '<span></span>';
		}else{		
			/* Add events */
			var tmpVar = this.objectIndex/1;
			this.divElement.onclick = function(e) { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[tmpVar].__navigate(e); }
			this.divElement.onmousedown = this.__clickMenuItem;			// on mouse down effect
			this.divElement.onmouseup = this.__rolloverMenuItem;		// on mouse up effect
			this.divElement.onmouseover = this.__rolloverMenuItem;		// mouse over effect
			this.divElement.onmouseout = this.__rolloutMenuItem;		// mouse out effect.
			DHTMLSuite.commonObj.__addEventElement(this.divElement);
		}
		return this.divElement;
	}
	// }}}
	,
	// {{{ setLayoutCss()
    /**
     *	Creates the different parts of a menu item of type "top".
     *
     *  @param String newLayoutCss = Name of css file used for the menu items.
     *
     * @public	
     */		
	setLayoutCss : function(newLayoutCss)
	{
		this.layoutCSS = newLayoutCss;
		
	}
	// }}}
	,
	// {{{ __createMenuElementsOfTypeTop()
    /**
     *	Creates the different parts of a menu item of type "top".
     *
     *  @param menuModelItem menuModelItemObj = Object of type menuModelItemObj
     *  @param Object parentEl = Reference to parent element
     *
     * @private	
     */		
	__createMenuElementsOfTypeTop : function(parentEl){
		if(this.modelItemRef.itemIcon){
			var iconDiv = document.createElement('DIV');
			iconDiv.innerHTML = '<img src="' + this.modelItemRef.itemIcon + '">';
			iconDiv.id = 'menuItemIcon' + this.modelItemRef.id
			parentEl.appendChild(iconDiv);		
		}
		if(this.modelItemRef.itemText){
			var div = document.createElement('DIV');
			div.innerHTML = this.modelItemRef.itemText;	
			div.className = this.cssPrefix + 'menuItem_textContent';
			div.id = 'menuItemText' + this.modelItemRef.id;	
			parentEl.appendChild(div);
		}
		/* Create div for the arrow -> Show sub items */
		var div = document.createElement('DIV');
		div.className = this.cssPrefix + 'menuItem_top_arrowShowSub';
		div.id = 'DHTMLSuite_menuBar_arrow' + this.modelItemRef.id;
		parentEl.appendChild(div);
		this.expandElement = div;
		if(!this.modelItemRef.hasSubs)div.style.display='none';
				
	}
	// }}}
	,	
	
	// {{{ __createMenuElementsOfTypeSub()
    /**
     *	Creates the different parts of a menu item of type "sub".
     *
     *  @param menuModelItem menuModelItemObj = Object of type menuModelItemObj
     *  @param Object parentEl = Reference to parent element
     *
     * @private	
     */		
	__createMenuElementsOfTypeSub : function(parentEl){		
		if(this.modelItemRef.itemIcon){
			parentEl.style.backgroundImage = 'url(\'' + this.modelItemRef.itemIcon + '\')';	
			parentEl.style.backgroundRepeat = 'no-repeat';
			parentEl.style.backgroundPosition = 'left center';	
		}
		if(this.modelItemRef.itemText){
			var div = document.createElement('DIV');
			div.className = 'DHTMLSuite_textContent';
			div.innerHTML = this.modelItemRef.itemText;	
			div.className = this.cssPrefix + 'menuItem_textContent';
			div.id = 'menuItemText' + this.modelItemRef.id;
			parentEl.appendChild(div);
		}
		
		/* Create div for the arrow -> Show sub items */
		var div = document.createElement('DIV');
		div.className = this.cssPrefix + 'menuItem_sub_arrowShowSub';
		parentEl.appendChild(div);		
		div.id = 'DHTMLSuite_menuBar_arrow' + this.modelItemRef.id;
		this.expandElement = div;
		
		if(!this.modelItemRef.hasSubs){
			div.style.display='none';	
		}else{
			div.previousSibling.style.paddingRight = '15px';
		}	
	}
	// }}}
	,
	// {{{ setCssPrefix()
    /**
     *	Set css prefix for the menu item. default is 'DHTMLSuite_'. This is useful in case you want to have different menus on a page with different layout.
     *
     *  @param String cssPrefix = New css prefix. 
     *
     * @public	
     */		
	setCssPrefix : function(cssPrefix)
	{
		this.cssPrefix = cssPrefix;
	}
	// }}}
	,
	// {{{ setMenuIcon()
    /**
     *	Replace menu icon.
     *
     *	@param String newPath - Path to new icon (false if no icon);
     *
     * @public	
     */		
	setIcon : function(newPath)
	{
		this.modelItemRef.setIcon(newPath);
		if(this.modelItemRef.type=='top'){	// Menu item is of type "top"
			var div = document.getElementById('menuItemIcon' + this.modelItemRef.id);	// Get a reference to the div where the icon is located.
			var img = div.getElementsByTagName('IMG')[0];	// Find the image
			if(!img){	// Image doesn't exists ?
				img = document.createElement('IMG');	// Create new image
				div.appendChild(img);
			}
			img.src = newPath;	// Set image path
			if(!newPath)img.parentNode.removeChild(img);	// No newPath defined, remove the image.			
		}
		if(this.modelItemRef.type=='sub'){	// Menu item is of type "sub"
			this.divElement.style.backgroundImage = 'url(\'' + newPath + '\')';		// Set backgroundImage for the main div(i.e. menu item div)	
		}		
	}
	// }}}
	,
	// {{{ setText()
    /**
     *	Replace the text of a menu item
     *
     *	@param String newText - New text for the menu item.
     *
     * @public	
     */		
	setText : function(newText)
	{
		this.modelItemRef.setText(newText);
		document.getElementById('menuItemText' + this.modelItemRef.id).innerHTML = newText;
		
		
	}
	
	// }}}
	,
	// {{{ __clickMenuItem()
    /**
     *	Effect - click on menu item
     *
     *
     * @private	
     */		
	__clickMenuItem : function()
	{
		this.className = this.className.replace('_regular','_click');
		this.className = this.className.replace('_over','_click');
	}
	// }}}	
	,	
	// {{{ __rolloverMenuItem()
    /**
     *	Roll over effect
     *
     *
     * @private	
     */		
	__rolloverMenuItem : function()
	{
		this.className = this.className.replace('_regular','_over');
		this.className = this.className.replace('_click','_over');
	}	
	// }}}
	,	
	// {{{ __rolloutMenuItem()
    /**
     *	Roll out effect
     *
     *
     * @private	
     */		
	__rolloutMenuItem : function()
	{
		this.className = this.className.replace('_over','_regular');
		
	}
	// }}}
	,	
	// {{{ setState()
    /**
     *	Set state of a menu item.
     *
     *	@param String newState = New state for the menu item
     *
     * @public	
     */		
	setState : function(newState)
	{
		this.divElement.className = this.cssPrefix + 'menuItem_' + this.modelItemRef.type + '_' + newState; 		
		this.modelItemRef.setState(newState);
	}
	// }}}
	,
	// {{{ getState()
    /**
     *	Return state of a menu item. 
     *
     *
     * @public	
     */		
	getState : function()
	{
		var state = this.modelItemRef.getState();
		if(!state){
			if(this.divElement.className.indexOf('_over')>=0)state = 'over';	
			if(this.divElement.className.indexOf('_click')>=0)state = 'click';	
			this.modelItemRef.setState(state);		
		}
		return state;
	}	
	// }}}
	,
	// {{{ __setHasSub()
    /**
     *	Update the item, i.e. show/hide the arrow if the element has subs or not. 
     *
     *
     * @private	
     */	
    __setHasSub : function(hasSubs)
    {
    	this.modelItemRef.hasSubs = hasSubs;
    	if(!hasSubs){
    		document.getElementById(this.cssPrefix +'menuBar_arrow' + this.modelItemRef.id).style.display='none';    		
    	}else{
    		document.getElementById(this.cssPrefix +'menuBar_arrow' + this.modelItemRef.id).style.display='block';
    	}    	
    }
    // }}}	
    ,
	// {{{ hide()
    /**
     *	Hide the menu item.
     *
     *
     * @public	
     */	    
    hide : function()
    {
    	this.modelItemRef.setVisibility(false);
    	this.divElement.style.display='none';    	
    }    
    ,
 	// {{{ show()
    /**
     *	Show the menu item.
     *
     *
     * @public	
     */	     
    show : function()
    {
    	this.modelItemRef.setVisibility(true);
    	this.divElement.style.display='block';    	
    }    
	// }}}
	,
	// {{{ __hideGroup()
    /**
     *	Hide the group the menu item is a part of. Example: if we're dealing with menu item 2.1, hide the group for all sub items of 2
     *
     *
     * @private	
     */			
	__hideGroup : function()
	{		
		if(this.modelItemRef.parentId){
			this.divElement.parentNode.style.visibility='hidden';	
			if(DHTMLSuite.clientInfoObj.isMSIE){
				try{
					var tmpId = this.divElement.parentNode.id.replace(/[^0-9]/gi,'');
					document.getElementById('DHTMLSuite_menuBarIframe_' + tmpId).style.visibility = 'hidden';
				}catch(e){
					// IFRAME hasn't been created.
				}	
			}
		}	

	}
	// }}}	
	,
	// {{{ __navigate()
    /**
     *	Navigate after click on a menu item.
     *
     *
     * @private	
     */		
	__navigate : function(e)
	{
		/* Check to see if the expand sub arrow is clicked. if it is, we shouldn't navigate from this click */
		if(document.all)e = event;
		if(e){
			var srcEl = DHTMLSuite.commonObj.getSrcElement(e);
			if(srcEl.id.indexOf('arrow')>=0)return;
		}
		if(this.modelItemRef.state=='disabled')return;
		if(this.modelItemRef.url){
			location.href = this.modelItemRef.url;
		}
		if(this.modelItemRef.jsFunction){
			try{
				eval(this.modelItemRef.jsFunction);
			}catch(e){
				alert('Defined Javascript code for the menu item( ' + this.modelItemRef.jsFunction + ' ) cannot be executed');
			}
		}
	}
}

/*[FILE_START:dhtmlSuite-menuBar.js] */
/************************************************************************************************************
*	DHTML menu bar class
*
*	Created:						October, 21st, 2006
*	@class Purpose of class:		Creates a top bar menu
*			
*	Css files used by this script:	menu-bar.css
*
*	Demos of this class:			demo-menu-bar.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Creates a top bar menu strip. Demos: <br>
*	<ul>
*	<li>(<a href="../../demos/demo-menu-bar-2.html" target="_blank">A menu with a detailed description on how it is created</a>)</li>
*	<li>(<a href="../../demos/demo-menu-bar.html" target="_blank">Demo with lots of menus on the same page</a>)</li>
*	<li>(<a href="../../demos/demo-menu-bar-custom-css.html" target="_blank">Two menus with different layout</a>)</li>
*	<li>(<a href="../../demos/demo-menu-bar-custom-css-file.html" target="_blank">One menu with custom layout/css.</a>)</li>
*	</ul>
*
*	<a href="../images/menu-bar-1.gif" target="_blank">Image describing the classes</a> <br><br>
*
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

DHTMLSuite.menuBar = function()
{
	var menuItemObj;
	var layoutCSS;					// Name of css file
	var menuBarBackgroundImage;		// Name of background image
	var menuItem_objects;			// Array of menu items - html elements.
	var menuBarObj;					// Reference to the main dib
	var menuBarHeight;
	var menuItems;					// Reference to objects of class menuModelItem
	var highlightedItems;			// Array of currently highlighted menu items.
	var menuBarState;				// Menu bar state - true or false - 1 = expand items on mouse over
	var activeSubItemsOnMouseOver;	// Activate sub items on mouse over	(instead of onclick)
	

	var submenuGroups;				// Array of div elements for the sub menus
	var submenuIframes;				// Array of sub menu iframes used to cover select boxes in old IE browsers.
	var createIframesForOldIeBrowsers;	// true if we want the script to create iframes in order to cover select boxes in older ie browsers.
	var targetId;					// Id of element where the menu will be inserted.
	var menuItemCssPrefix;			// Css prefix of menu items.
	var cssPrefix;					// Css prefix for the menu bar
	var menuItemLayoutCss;			// Css path for the menu items of this menu bar
	var globalObjectIndex;			// Global index of this object - used to refer to the object of this class outside
	this.cssPrefix = 'DHTMLSuite_';
	this.menuItemLayoutCss = false;	// false = use default for the menuItem class.
	this.layoutCSS = 'menu-bar.css';
	this.menuBarBackgroundImage = 'menu_strip_bg.jpg';
	this.menuItem_objects = new Array();
	DHTMLSuite.variableStorage.menuBar_highlightedItems = new Array();
	
	this.menuBarState = false;
	
	this.menuBarObj = false;
	this.menuBarHeight = 26;
	this.submenuGroups = new Array();
	this.submenuIframes = new Array();
	this.targetId = false;
	this.activeSubItemsOnMouseOver = false;
	this.menuItemCssPrefix = false;
	this.createIframesForOldIeBrowsers = true;
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	
	
	
}





DHTMLSuite.menuBar.prototype = {	
	
	// {{{ init()
    /**
     *	Initilizes the script
     *
     *
     * @public	
     */					
	init : function()
	{
		
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);	
		this.__createDivs();	// Create general divs
		this.__createMenuItems();	// Create menu items
		this.__setBasicEvents();	// Set basic events.
		window.refToThismenuBar = this;
	}
	// }}}
	,
	// {{{ setTarget()
    /**
     *	Specify where this menu bar will be inserted. the element with this id will be parent of the menu bar.
     *
     *  @param String targetId = Id of element where the menu will be inserted. 
     *
     * @public	
     */		
	setTarget : function(targetId)
	{
		this.targetId = targetId;		
		
	}	
	// }}}	
	,
	// {{{ setLayoutCss()
    /**
     *	Specify the css file for this menu bar
     *
     *  @param String layoutCSS = Name of new css file. 
     *
     * @public	
     */		
	setLayoutCss : function(layoutCSS)
	{
		this.layoutCSS = layoutCSS;		
		
	}	
	// }}}
	,	
	// {{{ setMenuItemLayoutCss()
    /**
     *	Specify the css file for the menu items
     *
     *  @param String layoutCSS = Name of new css file. 
     *
     * @public	
     */		
	setMenuItemLayoutCss : function(layoutCSS)
	{
		this.menuItemLayoutCss = layoutCSS;		
		
	}	
	// }}}
	,	
	// {{{ setCreateIframesForOldIeBrowsers()
    /**
     *	This method specifies if you want to the script to create iframes behind sub menu groups in order to cover eventual select boxes. This
     *	can be needed if you have users with older IE browsers(prior to version 7) and when there's a chance that a sub menu could appear on top
     *	of a select box.
     *
     *  @param Boolean createIframesForOldIeBrowsers = true if you want the script to create iframes to cover select boxes in older ie browsers.
     *
     * @public	
     */		
	setCreateIframesForOldIeBrowsers : function(createIframesForOldIeBrowsers)
	{
		this.createIframesForOldIeBrowsers = createIframesForOldIeBrowsers;		
		
	}	
	// }}}
	,
	// {{{ addMenuItems()
    /**
     *	Add menu items
     *
     *  @param DHTMLSuite.menuModel menuModel Object of class DHTMLSuite.menuModel which holds menu data 	
     *
     * @public	
     */			
	addMenuItems : function(menuItemObj)
	{
		this.menuItemObj = menuItemObj;	
		this.menuItems = menuItemObj.getItems();
	}
	// }}}
	,
	// {{{ setActiveSubItemsOnMouseOver()
    /**
     *	 Specify if sub menus should be activated on mouse over(i.e. no matter what the menuState property is). 	
     *
     *	@param Boolean activateSubOnMouseOver - Specify if sub menus should be activated on mouse over(i.e. no matter what the menuState property is).
     *
     * @public	
     */		
	setActiveSubItemsOnMouseOver : function(activateSubOnMouseOver)
	{
		this.activeSubItemsOnMouseOver = activateSubOnMouseOver;	
	}
	// }}}
	,
	// {{{ setMenuItemState()
    /**
     *	This method changes the state of the menu bar(expanded or collapsed). This method is called when someone clicks on the arrow at the right of menu items.
     * 	
     *	@param Number menuItemId - ID of the menu item we want to switch state for
     * 	@param String state - New state(example: "disabled")
     *
     * @public	
     */			
	setMenuItemState : function(menuItemId,state)
	{
		this.menuItem_objects[menuItemId].setState(state);
	}
	// }}}	
	,
	// {{{ setMenuItemCssPrefix()
    /**
     *	Specify prefix of css classes used for the menu items. Default css prefix is "DHTMLSuite_". If you wish have some custom styling for some of your menus, 
     *	create a separate css file and replace DHTMLSuite_ for the class names with your new prefix.  This is useful if you want to have two menus on the same page
     *	with different stylings.
     * 	
     *	@param String newCssPrefix - New css prefix for menu items.
     *
     * @public	
     */		
	setMenuItemCssPrefix : function(newCssPrefix)
	{
		this.menuItemCssPrefix = newCssPrefix;
	}
	// }}}
	,	
	// {{{ setCssPrefix()
    /**
     *	Specify prefix of css classes used for the menu bar. Default css prefix is "DHTMLSuite_" and that's the prefix of all css classes inside menu-bar.css(the default css file). 
     *	If you want some custom menu bars, create and include your own css files, replace DHTMLSuite_ in the class names with your own prefix and set the new prefix by calling
     *	this method. This is useful if you want to have two menus on the same page with different stylings.
     * 	
     *	@param String newCssPrefix - New css prefix for the menu bar classes.
     *
     * @public	
     */		
	setCssPrefix : function(newCssPrefix)
	{
		this.cssPrefix = newCssPrefix;
	}
	// }}}
	,
	// {{{ replaceSubMenus()
    /**
     *	This method replaces existing sub menu items with a new subset (To replace all menu items, pass 0 as parentId)
     *
     * 	
     *	@param Number parentId - ID of parent element ( 0 if top node) - if set, all sub elements will be deleted and replaced with the new menu model.
     *	@param menuModel newMenuModel - Reference to object of class menuModel
     *
     * @private	
     */		
	replaceMenuItems : function(parentId,newMenuModel)
	{		
		this.hideSubMenus();	// Hide all sub menus
		this.__deleteMenuItems(parentId);	// Delete old menu items.
		this.menuItemObj.__appendMenuModel(newMenuModel,parentId);	// Appending new menu items to the menu model.
		this.__clearAllMenuItems();
		this.__createMenuItems();
	}	

	// }}}	
	,
	// {{{ deleteMenuItems()
    /**
     *	This method deletes menu items from the menu dynamically
     * 	
     *	@param Number parentId - Parent id - parent id of the elements to delete.
     *	@param Boolean includeParent - Should parent element also be deleted, or only sub elements?
     *
     * @public	
     */		
	deleteMenuItems : function(parentId,includeParent)
	{
		this.hideSubMenus();	// Hide all sub menus	
		this.__deleteMenuItems(parentId,includeParent);
		this.__clearAllMenuItems();
		this.__createMenuItems();		
	}
	// }}}	
	,
	// {{{ appendMenuItems()
    /**
     *	This method appends menu items to the menu dynamically
     * 	
     *	@param Number parentId - Parent id - where to append the new items.
     *	@param menuModel newMenuModel - Object of type menuModel. This menuModel will be appended as sub elements of defined parentId
     *
     * @public	
     */		
	appendMenuItems : function(parentId,newMenuModel)
	{
		this.hideSubMenus();	// Hide all sub menus
		this.menuItemObj.__appendMenuModel(newMenuModel,parentId);	// Appending new menu items to the menu model.
		this.__clearAllMenuItems();
		this.__createMenuItems();		
	}	
	// }}}	
	,
	// {{{ hideMenuItem()
    /**
     *	This method doesn't delete menu items. it hides them only.
     * 	
     *	@param Number id - Id of the item you want to hide.
     *
     * @public	
     */		
	hideMenuItem : function(id)
	{
		this.menuItem_objects[id].hide();

	}	
	// }}}	
	,
	// {{{ showMenuItem()
    /**
     *	This method shows a menu item. If the item isn't hidden, nothing is done.
     * 	
     *	@param Number id - Id of the item you want to show
     *
     * @public	
     */		
	showMenuItem : function(id)
	{
		this.menuItem_objects[id].show();
	}	
	// }}}
	,
	// {{{ setText()
    /**
     *	Replace the text for a menu item
     * 	
     *	@param Integer id - Id of menu item.
     *	@param String newText - New text for the menu item.
     *
     * @public	
     */		
	setText : function(id,newText)
	{
		this.menuItem_objects[id].setText(newText);
	}		
	// }}}
	,
	// {{{ setIcon()
    /**
     *	Replace menu icon for a menu item. 
     * 	
     *	@param Integer id - Id of menu item.
     *	@param String newPath - Path to new menu icon. Pass blank or false if you want to clear the menu item.
     *
     * @public	
     */		
	setIcon : function(id,newPath)
	{
		this.menuItem_objects[id].setIcon(newPath);
	}	
	// }}}
	,
	// {{{ __clearAllMenuItems()
    /**
     *	Delete HTML elements for all menu items.
     *
     * @private	
     */			
	__clearAllMenuItems : function()
	{
		for(var prop=0;prop<this.menuItemObj.menuItemsOrder.length;prop++){
			var id = this.menuItemObj.menuItemsOrder[prop];
			if(!id)continue;
			if(this.submenuGroups[id]){
				this.submenuGroups[id].parentNode.removeChild(this.submenuGroups[id]);
				this.submenuGroups[id] = false;	
			}
			if(this.submenuIframes[id]){
				this.submenuIframes[id].parentNode.removeChild(this.submenuIframes[id]);
				this.submenuIframes[id] = false;
			}	
		}
		this.menuBarObj.innerHTML = '';		
	}
	// }}}
	,
	// {{{ __deleteMenuItems()
    /**
     *	This method deletes menu items from the menu, i.e. menu model and the div elements for these items.
     * 	
     *	@param Number parentId - Parent id - where to start the delete process.
     *
     * @private	
     */		
	__deleteMenuItems : function(parentId,includeParent)
	{
		if(includeParent)this.menuItemObj.__deleteANode(parentId);
		if(!this.submenuGroups[parentId])return;	// No sub items exists.		
		this.menuItem_objects[parentId].__setHasSub(false);	// Delete existing sub menu divs.
		this.menuItemObj.__deleteChildNodes(parentId);	// Delete existing child nodes from menu model
		var groupBox = this.submenuGroups[parentId];
		groupBox.parentNode.removeChild(groupBox);	// Delete sub menu group box. 
		if(this.submenuIframes[parentId]){
			this.submenuIframes[parentId].parentNode.removeChild(this.submenuIframes[parentId]);
		}
		this.submenuGroups.splice(parentId,1);
		this.submenuIframes.splice(parentId,1);
	}
	// }}}	
	,
	// {{{ __changeMenuBarState()
    /**
     *	This method changes the state of the menu bar(expanded or collapsed). This method is called when someone clicks on the arrow at the right of menu items.
     * 	
     *	@param Object obj - Reference to element triggering the action
     *
     * @private	
     */		
	__changeMenuBarState : function(){
		var objectIndex = this.getAttribute('objectRef');
		var obj = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[objectIndex];
		var parentId = this.id.replace(/[^0-9]/gi,'');		
		var state = obj.menuItem_objects[parentId].getState();
		if(state=='disabled')return;
		obj.menuBarState = !obj.menuBarState;
		if(!obj.menuBarState)obj.hideSubMenus();else{
			obj.hideSubMenus();
			obj.__expandGroup(parentId);
		}
		
	}
	// }}}		
	,
	// {{{ __createDivs()
    /**
     *	Create the main HTML elements for this menu dynamically
     * 	
     *
     * @private	
     */		
	__createDivs : function()
	{
		window.refTomenuBar = this;	// Reference to menu strip object
		
		this.menuBarObj = document.createElement('DIV');	
		this.menuBarObj.className = this.cssPrefix + 'menuBar_' + this.menuItemObj.submenuType[1];
		
		if(!document.getElementById(this.targetId)){
			alert('No target defined for the menu object');
			return;
		}
		// Appending menu bar object as a sub of defined target element.
		var target = document.getElementById(this.targetId);
		target.appendChild(this.menuBarObj);				
	}
	,
	// {{{ hideSubMenus()
    /**
     *	Deactivate all sub menus ( collapse and set state back to regular )
     *	In case you have a menu inside a scrollable container, call this method in an onscroll event for that element
     *	example document.getElementById('textContent').onscroll = menuBar.__hideSubMenus;
     * 	
     *	@param Event e - this variable is present if this method is called from an event. 
     *
     * @public	
     */		
	hideSubMenus : function(e)
	{
		if(this && this.tagName){	/* Method called from event */
			if(document.all)e = event;
			var srcEl = DHTMLSuite.commonObj.getSrcElement(e);
			if(srcEl.tagName.toLowerCase()=='img')srcEl = srcEl.parentNode;
			if(srcEl.className && srcEl.className.indexOf('arrow')>=0){
				return;
			}
		}
		for(var no=0;no<DHTMLSuite.variableStorage.menuBar_highlightedItems.length;no++){
			DHTMLSuite.variableStorage.menuBar_highlightedItems[no].setState('regular');	// Set state back to regular
			DHTMLSuite.variableStorage.menuBar_highlightedItems[no].__hideGroup();	// Hide eventual sub menus
		}	
		DHTMLSuite.variableStorage.menuBar_highlightedItems = new Array();			
	}
	
	,
	// {{{ __expandGroup()
    /**
     *	Expand a group of sub items.
     * 	@param parentId - Id of parent element
     *
     * @private	
     */			
	__expandGroup : function(parentId)
	{
	
		var groupRef = this.submenuGroups[parentId];
		var subDiv = groupRef.getElementsByTagName('DIV')[0];
		
		var numericId = subDiv.id.replace(/[^0-9]/g,'');
		
		groupRef.style.visibility='visible';	// Show menu group.
		if(this.submenuIframes[parentId])this.submenuIframes[parentId].style.visibility = 'visible';	// Show iframe if it exists.
		DHTMLSuite.variableStorage.menuBar_highlightedItems[DHTMLSuite.variableStorage.menuBar_highlightedItems.length] = this.menuItem_objects[numericId];
		this.__positionSubMenu(parentId);
		
		if(DHTMLSuite.clientInfoObj.isOpera){	/* Opera fix in order to get correct height of sub menu group */
			var subDiv = groupRef.getElementsByTagName('DIV')[0];	/* Find first menu item */
			subDiv.className = subDiv.className.replace('_over','_over');	/* By "touching" the class of the menu item, we are able to fix a layout problem in Opera */
		}
	}
	
	,
	// {{{ __activateMenuElements()
    /**
     *	Traverse up the menu items and highlight them.
     * 	
     *
     * @private	
     */			
	__activateMenuElements : function(inputObj,objectRef,firstIteration)
	{
		
		if(!this.menuBarState && !this.activeSubItemsOnMouseOver)return;	// Menu is not activated and it shouldn't be activated on mouse over.
		var numericId = inputObj.id.replace(/[^0-9]/g,'');	// Get a numeric reference to current menu item.
		
		var state = this.menuItem_objects[numericId].getState();	// Get state of this menu item.
		if(state=='disabled')return;	// This menu item is disabled - return from function without doing anything.		
		
		if(firstIteration && DHTMLSuite.variableStorage.menuBar_highlightedItems.length>0){
			this.hideSubMenus();	// First iteration of this function=> Hide other sub menus. 
		}	
		// What should be the state of this menu item -> If it's the one the mouse is over, state should be "over". If it's a parent element, state should be "active".
		var newState = 'over';
		if(!firstIteration)newState = 'active';	// State should be set to 'over' for the menu item the mouse is currently over.
			
		this.menuItem_objects[numericId].setState(newState);	// Switch state of menu item.
		if(this.submenuGroups[numericId]){	// Sub menu group exists. call the __expandGroup method. 
			this.__expandGroup(numericId);	// Expand sub menu group
		}
		DHTMLSuite.variableStorage.menuBar_highlightedItems[DHTMLSuite.variableStorage.menuBar_highlightedItems.length] = this.menuItem_objects[numericId];	// Save this menu item in the array of highlighted elements.
		if(objectRef.menuItems[numericId].parentId){	// A parent element exists. Call this method over again with parent element as input argument.
			this.__activateMenuElements(objectRef.menuItem_objects[objectRef.menuItems[numericId].parentId].divElement,objectRef,false);
		}
	}
	// }}}	
	,
	// {{{ __createMenuItems()
    /**
     *	Creates the HTML elements for the menu items.
     * 	
     *
     * @private	
     */		
	__createMenuItems : function()
	{
		if(!this.globalObjectIndex)this.globalObjectIndex = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects.length;;
		var index = this.globalObjectIndex;
		DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[index] = this;
	
		// Find first child of the body element. trying to insert the element before first child instead of appending it to the <body> tag, ref: problems in ie
		var firstChild = false;
		var firstChilds = document.getElementsByTagName('DIV');
		if(firstChilds.length>0)firstChild = firstChilds[0]
		
		for(var no=0;no<this.menuItemObj.menuItemsOrder.length;no++){	// Looping through menu items		
			var indexThis = this.menuItemObj.menuItemsOrder[no];				
			if(!this.menuItems[indexThis].id)continue;		
			this.menuItem_objects[this.menuItems[indexThis].id] = new DHTMLSuite.menuItem(); 
			if(this.menuItemCssPrefix)this.menuItem_objects[this.menuItems[indexThis].id].setCssPrefix(this.menuItemCssPrefix);	// Custom css prefix set
			if(this.menuItemLayoutCss)this.menuItem_objects[this.menuItems[indexThis].id].setLayoutCss(this.menuItemLayoutCss);	// Custom css file name
			
			var ref = this.menuItem_objects[this.menuItems[indexThis].id].createItem(this.menuItems[indexThis]); // Create div for this menu item.
		
			// Actiave sub elements when someone moves the mouse over the menu item - exception: not on separators.
			if(!this.menuItems[indexThis].separator)DHTMLSuite.commonObj.addEvent(ref,"mouseover",function(){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[index].__activateMenuElements(this,DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[index],true); });	
			
			if(this.menuItem_objects[this.menuItems[indexThis].id].expandElement){	/* Small arrow at the right of the menu item exists - expand subs */
				var expandRef = this.menuItem_objects[this.menuItems[indexThis].id].expandElement;	/* Creating reference to expand div/arrow div */
				var parentId = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[index].menuItems[indexThis].parentId + '';	// Get parent id.
				var tmpId = expandRef.id.replace(/[^0-9]/gi,'');
				expandRef.setAttribute('objectRef',index);	/* saving the index of this object in the DHTMLSuite.variableStorage array as a property of the tag - We need to do this in order to avoid circular references and thus memory leakage in IE */
				expandRef.objectRef = index;
				expandRef.onclick = this.__changeMenuBarState;
			}
			var target = this.menuBarObj;	// Temporary variable - target of newly created menu item. target can be the main menu object or a sub menu group(see below where target is updated).

			if(this.menuItems[indexThis].depth==1 && this.menuItemObj.submenuType[this.menuItems[indexThis].depth]!='top' && this.menuItemObj.mainMenuGroupWidth){	/* Main menu item group width set */
				var tmpWidth = this.menuItemObj.mainMenuGroupWidth + '';
				if(tmpWidth.indexOf('%')==-1)tmpWidth = tmpWidth + 'px';
				target.style.width = tmpWidth;	
			}
		
			if(this.menuItems[indexThis].depth=='1'){	/* Top level item */
				if(this.menuItemObj.submenuType[this.menuItems[indexThis].depth]=='top'){	/* Type = "top" - menu items side by side */
					ref.style.styleFloat = 'left';				
					ref.style.cssText = 'float:left';						
				}			
			}else{
				if(!this.menuItems[indexThis].depth){
					alert('Error in menu model(depth not defined for a menu item). Remember to call the init() method for the menuModel object.');
					return;
				}
				if(!this.submenuGroups[this.menuItems[indexThis].parentId]){	// Sub menu div doesn't exist - > Create it.
					this.submenuGroups[this.menuItems[indexThis].parentId] = document.createElement('DIV');	
					this.submenuGroups[this.menuItems[indexThis].parentId].style.zIndex = 30000;
					this.submenuGroups[this.menuItems[indexThis].parentId].style.position = 'absolute';
					this.submenuGroups[this.menuItems[indexThis].parentId].id = 'DHTMLSuite_menuBarSubGroup' + this.menuItems[indexThis].parentId;
					this.submenuGroups[this.menuItems[indexThis].parentId].style.visibility = 'hidden';	// Initially hidden.
					this.submenuGroups[this.menuItems[indexThis].parentId].className = this.cssPrefix + 'menuBar_' + this.menuItemObj.submenuType[this.menuItems[indexThis].depth];
					

					if(firstChild){
						firstChild.parentNode.insertBefore(this.submenuGroups[this.menuItems[indexThis].parentId],firstChild);
					}else{
						document.body.appendChild(this.submenuGroups[this.menuItems[indexThis].parentId]);
					}
					
					if(DHTMLSuite.clientInfoObj.isMSIE && this.createIframesForOldIeBrowsers){	// Create iframe object in order to conver select boxes in older IE browsers(windows).
						this.submenuIframes[this.menuItems[indexThis].parentId] = document.createElement('<IFRAME src="about:blank" frameborder=0>');
						this.submenuIframes[this.menuItems[indexThis].parentId].id = 'DHTMLSuite_menuBarIframe_' + this.menuItems[indexThis].parentId;
						this.submenuIframes[this.menuItems[indexThis].parentId].style.position = 'absolute';
						this.submenuIframes[this.menuItems[indexThis].parentId].style.zIndex = 9000;
						this.submenuIframes[this.menuItems[indexThis].parentId].style.visibility = 'hidden';
						if(firstChild){
							firstChild.parentNode.insertBefore(this.submenuIframes[this.menuItems[indexThis].parentId],firstChild);
						}else{
							document.body.appendChild(this.submenuIframes[this.menuItems[indexThis].parentId]);
						}						
					}
				}	
				target = this.submenuGroups[this.menuItems[indexThis].parentId];	// Change target of newly created menu item. It should be appended to the sub menu div("A group box").				
			}			
			target.appendChild(ref); // Append menu item to the document.		
			
			if(this.menuItems[indexThis].visible == false)this.hideMenuItem(this.menuItems[indexThis].id);	// Menu item hidden, call the hideMenuItem method.
			if(this.menuItems[indexThis].state != 'regular')this.menuItem_objects[this.menuItems[indexThis].id].setState(this.menuItems[indexThis].state);	// Menu item hidden, call the hideMenuItem method.

		}	
		

		this.__setSizeOfAllSubMenus();	// Set size of all sub menu groups
		this.__positionAllSubMenus();	// Position all sub menu groups.
		if(DHTMLSuite.clientInfoObj.isOpera)this.__fixLayoutOpera();	// Call a function which fixes some layout issues in Opera.		
	}
	// }}}
	,
	// {{{ __fixLayoutOpera()
    /**
     *	A method used to fix the menu layout in Opera. 
     *
     *
     * @private	
     */		
	__fixLayoutOpera : function()
	{
		for(var no=0;no<this.menuItemObj.menuItemsOrder.length;no++){
			var id = this.menuItemObj.menuItemsOrder[no];
			if(!id)continue;
			this.menuItem_objects[id].divElement.className = this.menuItem_objects[id].divElement.className.replace('_regular','_regular');	// Nothing is done but by "touching" the class of the menu items in Opera, we make them appear correctly
		}		
	}
	
	// }}}	
	,
	// {{{ __setSizeOfAllSubMenus()
    /**
     *	*	Walk through all sub menu groups and call the positioning method for each one of them.
     *
     *
     * @private	
     */		
	__setSizeOfAllSubMenus : function()
	{		
		for(var no=0;no<this.menuItemObj.menuItemsOrder.length;no++){
			var prop = this.menuItemObj.menuItemsOrder[no];
			if(!prop)continue;
			this.__setSizeOfSubMenus(prop);
		}			
	}	
	// }}}	
	,	
	// {{{ __positionAllSubMenus()
    /**
     *	Walk through all sub menu groups and call the positioning method for each one of them.
     *
     *
     * @private	
     */		
	__positionAllSubMenus : function()
	{
		for(var no=0;no<this.menuItemObj.menuItemsOrder.length;no++){
			var prop = this.menuItemObj.menuItemsOrder[no];
			if(!prop)continue;
			if(this.submenuGroups[prop])this.__positionSubMenu(prop);
		}		
	}
	// }}}	
	,
	// {{{ __positionSubMenu(parentId)
    /**
     *	Position a sub menu group
     *
     *	@param parentId  	
     *
     * @private	
     */		
	__positionSubMenu : function(parentId)
	{
		try{
			var shortRef = this.submenuGroups[parentId];	
			
			var depth = this.menuItems[parentId].depth;
			var dir = this.menuItemObj.submenuType[depth];
			if(dir=='top'){			
				shortRef.style.left = DHTMLSuite.commonObj.getLeftPos(this.menuItem_objects[parentId].divElement) + 'px';
				shortRef.style.top = (DHTMLSuite.commonObj.getTopPos(this.menuItem_objects[parentId].divElement) + this.menuItem_objects[parentId].divElement.offsetHeight) + 'px';
			}else{
				shortRef.style.left = (DHTMLSuite.commonObj.getLeftPos(this.menuItem_objects[parentId].divElement) + this.menuItem_objects[parentId].divElement.offsetWidth) + 'px';
				shortRef.style.top = (DHTMLSuite.commonObj.getTopPos(this.menuItem_objects[parentId].divElement)) + 'px';		
			}	
			
			if(DHTMLSuite.clientInfoObj.isMSIE){
				var iframeRef = this.submenuIframes[parentId]
				iframeRef.style.left = shortRef.style.left;
				iframeRef.style.top = shortRef.style.top;
				iframeRef.style.width = shortRef.clientWidth + 'px';
				iframeRef.style.height = shortRef.clientHeight + 'px';
			}									
		}catch(e){
			
		}		
	}
	// }}}	
	,
	// {{{ __setSizeOfSubMenus(parentId)
    /**
     *	Set size of a sub menu group
     *
     *	@param parentId  	
     *
     * @private	
     */		
	__setSizeOfSubMenus : function(parentId)
	{
		try{
			var shortRef = this.submenuGroups[parentId];	
			var subWidth = Math.max(shortRef.offsetWidth,this.menuItem_objects[parentId].divElement.offsetWidth);
			if(this.menuItems[parentId].submenuWidth)subWidth = this.menuItems[parentId].submenuWidth;
			if(subWidth>400)subWidth = 150;	// Hack for IE 6 -> force a small width when width is too large.
			subWidth = subWidth + '';
			if(subWidth.indexOf('%')==-1)subWidth = subWidth + 'px';
			shortRef.style.width = subWidth;	
			if(DHTMLSuite.clientInfoObj.isMSIE){
				this.submenuIframes[parentId].style.width = shortRef.style.width;
				this.submenuIFrames[parentId].style.height = shortRef.style.height;
			}
		}catch(e){
			
		}
		
	}
	// }}}	
	,
	// {{{ __repositionMenu()
    /**
     *	Position menu items.
     * 	
     *
     * @private	
     */		
	__repositionMenu : function(inputObj)
	{
		inputObj.menuBarObj.style.top = document.documentElement.scrollTop + 'px';
		
	}
	
	// }}}	
	,
	// {{{ __menuItemRollOver()
    /**
     *	Position menu items.
     * 	
     *
     * @private	
     */	
	__menuItemRollOver : function(inputObj)
	{
		var numericId = inputObj.id.replace(/[^0-9]/g,'');
		inputObj.className = 'DHTMLSuite_menuBar_menuItem_over_' + this.menuItems[numericId]['depth'];		
	}
	// }}}	
	,	
	// {{{ __menuItemRollOut()
    /**
     *	Position menu items.
     * 	
     *
     * @private	
     */	
	__menuItemRollOut : function(inputObj)
	{		
		var numericId = inputObj.id.replace(/[^0-9]/g,'');
		inputObj.className = 'DHTMLSuite_menuBar_menuItem_' + this.menuItems[numericId]['depth'];		
	}
	// }}}	
	,
	// {{{ __menuNavigate()
    /**
     *	Navigate by click on a menu item
     * 	
     *
     * @private	
     */	
	__menuNavigate : function(inputObj)
	{
		var numericIndex = inputObj.id.replace(/[^0-9]/g,'');
		var url = this.menuItems[numericIndex]['url'];
		if(!url)return;
		//alert(this.menuItems[numericIndex]['url']);
		
	}
	// }}}	
	,
	// {{{ __setBasicEvents()
    /**
     *	Set basic events for the menu widget.
     * 	
     *
     * @private	
     */	
	__setBasicEvents : function()
	{
		DHTMLSuite.commonObj.addEvent(document.documentElement,"click",this.hideSubMenus);		
	}
}

/*[FILE_START:dhtmlSuite-windowWidget-notFinished.js] */
/************************************************************************************************************
*	DHTML window scripts
*
*	Created:						November, 26th, 2006
*	@class Purpose of class:		Store metadata about a window
*			
*	Css files used by this script:	
*
*	Demos of this class:			demo-window.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Save metadata about a window. (<a href="../../demos/demo-window.html" target="_blank">Demo</a>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

DHTMLSuite.windowDataModel = function()
{
	var title;						// Title of window
	var icon;						// Icon of window
	var resizable;					// Window is resizable ?
	var minimizable;				// Window is minimizable ?
	var closable;					// Window is closable
	var xPos;						// Current x position of window
	var yPos;						// Current y position of window
	var width;						// Current width of window
	var height;						// Current height of window
	var zIndex;						// Current z-index of window.
	var cookieName;					// Name of cookie to store x,y,width,height,state,activeTab and zIndex
	var state;						// State of current window(minimized,closed etc.)
	var activeTabId;				// id of active tab
	var tabsVisible;				// Tabs are visible? If not, we will only show a simple window with content and no tabs.
	
	var windowDataModelContent;			// Array of DHTMLSuite.windowDataContent objects.
	
	this.windowDataModelContent = new Array();
	
}

DHTMLSuite.windowDataModel.prototype = {
	
	// {{{ setTitle()
    /**
     *	Specify title of window
     *
     *  @param String newTitle - New title of window content(a tab).
     *
     * @public	
     */			
	setTitle : function(newTitle)
	{
		this.title = newTitle;		
	}
	// }}}
	,
	// {{{ setIcon()
	/**
	*
	*	Specify path to window icon
	*
	*	@param String newIcon - Path to new icon
	*
	*	@public
	*/
	setIcon : function(newIcon)
	{
		this.icon = newIcon;
	}
	// }}}
	,
	// {{{ setResizable()
	/**
	*
	*	Specify if the window should be resizable or not
	*
	*	@param Boolean resizable - true or false, true if the window is resizable, false otherwise.
	*
	*	@public
	*/	
	setResizable : function(resizable)
	{
		this.resizable = resizable;
	}
	// }}}
	,
	// {{{ setMinimizable()
	/**
	*
	*	Specify if the window should be resizable or not
	*
	*	@param Boolean resizable - true or false, true if the window is minimizable, false otherwise.
	*
	*	@public
	*/		
	setMinimizable : function(minimizable)
	{
		this.minimizable = minimizable;		
	}
	// }}}
	,
	// {{{ setClosable()
	/**
	*
	*	Specify if you should be able to close the window(close icon) or not
	*
	*	@param Boolean resizable - Specify if you should be able to close the window(close icon) or not
	*
	*	@public
	*/		
	setClosable : function(closable)
	{
		this.closable = closable;
	}
	// }}}
	,
	// {{{ setCookieName()
	/**
	*
	*	Specify name of cookie for this window(i.e where to store variables such as x and y pos, width and height, state and z-index
	*
	*	@param String cookieName - New cookie name
	*
	*	@public
	*/		
	setCookieName : function(cookieName)
	{
		this.cookieName = cookieName;
	}
	// }}}
	,
	// {{{ setTabTitles()
	/**
	*
	*	Specify title of window tabs. Remember that the tab objects has to be added before you call this method. 
	*	
	*	@param Array newTabTitles - Array of strings. the setTitle method of windowDataContent will be called for each tab in this window
	*
	*	@public
	*/
	setTabTitles : function(newTabTitles)
	{
		for(var no=0;no<newTabTitles.length;no++){
			if(this.windowDataContents[no])this.windowDataContents[no].setTitle(newTabTitles[no]);
		}		
	}
	// }}}
	,
	// {{{ setTabIcons()
	/**
	*
	*	Specify path of window tabs icons. Remember that the tab objects has to be added before you call this method. 
	*	
	*	@param Array newTabIcons - Array of strings. the setIcon method of windowDataContent will be called for each tab in this window
	*
	*	@public
	*/
	setTabIcons : function(newTabIcons)
	{
		for(var no=0;no<newTabIcons.length;no++){
			if(this.windowDataContents[no])this.windowDataContents[no].setIcon(newTabIcons[no]);
		}		
	}
	// }}}
	,
	// {{{ createWindowsFromMarkup()
	/**
	*
	*	Create windows from markup. Window data will be set based on markup on your page.
	*	
	*	@param String elementId - ID of parent element of the windows. Remember that window content divs has to have class name "DHTMLSuite_windowContent"
	*
	*	Example of syntax for the markup
	*
	*	<div id="myWindow" title="This is my window" icon="../images/icon.gif">
	*		<div id="tabOne" class="DHTMLSuite_windowContent" title="first tab">
	*			Content of the first tab
	*		
	*		</div>
	*		<div id="tabTwo" class="DHTMLSuite_windowContent" title="second tab">
	*			Content of the second tab
	*		
	*		</div>
	*		<div id="tabThree" class="DHTMLSuite_windowContent" title="third tab">
	*			Content of the third tab.
	*		
	*		</div>
	*	</div>
	*
	*	@public
	*/
	createWindowsFromMarkup : function(elementId)
	{
		var obj = document.getElementById(elementId);
		if(!obj){	// Object exists.
			alert('Object with id ' + elementId + ' does not exists');
			return;
		}
		obj.style.display='none';	// Hiding the content since the window is created dynamically.
		var divs = obj.getElementsByTagName('DIV');
		for(var no=0;no<divs.length;no++){
			if(divs[no].className=='DHTMLSuite_windowContent'){
				var index = this.windowDataModelContent.length;
				this.windowDataModelContent[index] = new DHTMLSuite.windowDataModelContent();
				this.windowDataModelContent[index].setId(divs[no].id);
				
				
			}	
			
		}
		
	}	
}



/************************************************************************************************************
*	DHTML window scripts
*
*	Created:						November, 26th, 2006
*	@class Purpose of class:		Store metadata about the content of a window or only a tab of a window.
*									THIS WIDGET IS NOT YET FINISHED.
*			
*	Css files used by this script:	
*
*	Demos of this class:			demo-window.html
*
* 	Update log:
*
************************************************************************************************************/

DHTMLSuite.windowDataModelContent = function()
{
	var title;
	var icon;
	var textContent;
	var id;	
	var visible;	
}

DHTMLSuite.windowDataModelContent.prototype = 
{
	// {{{ setTitle()
    /**
     *	Specify title of a tab
     *
     *  @param String newTitle - New title of window content(a tab).
     *
     * @public	
     */		
	setTitle : function(newTitle)
	{
		this.title = newTitle;
	}
	// }}}
	,
	// {{{ setIcon()
	/**
	*	Specify path to window tab icon
	*
	*	@param String newIcon
	*
	*	@public
	*/
	setIcon : function(newIcon)
	{
		this.icon = newIcon;
	}
	// }}}
	,
	// {{{ setId()
	/**
	*	Specify id of window
	*
	*	@param String newId
	*
	*	@public
	*/
	setId : function(newId)
	{
		this.id = newId;
	}
	
	
	
}

/*[FILE_START:dhtmlSuite-paneSplitterModel.js] */
/**
* @constructor
* @class Purpose of class:	Store metadata about panes
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

/************************************************************************************************************
*	Data model for a pane splitter
*
*	Created:						November, 28th, 2006
*	@class Purpose of class:		Data source for the pane splitter
*			
*	Css files used by this script:	
*
*	Demos of this class:			
*
* 	Update log:
*
************************************************************************************************************/


DHTMLSuite.paneSplitterModel = function()
{
	
	var panes;		// Array of paneSplitterPaneModel objects
	
	this.panes = new Array();	
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	
}

DHTMLSuite.paneSplitterModel.prototype = 
{
	// {{{ addPane()
	/**
	*	Add a pane to the paneSplitterModel
	*
	*	@param obj Object of class DHTMLSuite.paneSplitterPaneModel
	*
	*	@public
	*/		
	addPane : function(obj)
	{
		this.panes[this.panes.length] = obj;	
	}
	// }}}
	,
	// {{{ getItems()
	/**
	*	Add a pane to the paneSplitterModel
	*
	*	@return Array of DHTMLSuite.paneSplitterPaneModel objects
	*
	*	@public
	*/		
	getItems : function()
	{
		return this.panes;		
	}
	
	
}


/**
* @constructor
* @class Purpose of class:	Store metadata about a pane
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

/************************************************************************************************************
*	Data model for a pane 
*
*	Created:						November, 28th, 2006
*	@class Purpose of class:		Data source for the pane splitter
*			
*	Css files used by this script:	
*
*	Demos of this class:			
*
* 	Update log:
*
************************************************************************************************************/




DHTMLSuite.paneSplitterPaneModel = function(inputArray)
{
	var id;					// Unique id of pane, in case you want to perform operations on this particular pane.
	var position;			// Position, possible values: "West","East","North","South" and "Center"
	var size;				// Current size of pane(for west and east, the size is equal to width, for south and north, size is equal to height)
	var minSize;			// Minimum size(height or width) of the pane
	var maxSize;			// Maximum size(height or width) of the pane.
	var resizable;			// Boolean - true or false, is the pane resizable
	var visible;			// Boolean - true or false, is the pane visible?
	var scrollbars;			// Boolean - true or false, visibility of scrollbars when content size is bigger than visible area(default = true)
	var contents;			// Array of paneSplitterContentModel objects
	var collapsable;		// Boolean - true or false, is this pane collapsable
	var state;				// State of a pane, possible values, "expanded","collapsed"; (default = expanded)
	this.contents = new Array();
	
	this.scrollbars = true;
	this.resizable = true;
	this.collapsable = true;
	this.state = 'expanded';
	this.visible = true;
	if(inputArray)this.setData(inputArray);
	
}

DHTMLSuite.paneSplitterPaneModel.prototype = 
{
	// {{{ setData()
	/**
	*	One method which makes it possible to set all properties
	*
	*	@param Array associative array of properties
	*			properties: id,position,title,tabTitle,closable,resizable,size,minSize,maxSize,htmlElementId,contentUrl,collapsable,state(expanded or collapsed) and visible
	*
	*	@public
	*/		
	setData : function(inputArray)
	{
		if(inputArray["id"])this.id = inputArray["id"];
		if(inputArray["position"])this.position = inputArray["position"];
		if(inputArray["resizable"]===false || inputArray["resizable"]===true)this.resizable = inputArray["resizable"];
		if(inputArray["size"])this.size = inputArray["size"];
		if(inputArray["minSize"])this.minSize = inputArray["minSize"];
		if(inputArray["maxSize"])this.maxSize = inputArray["maxSize"];
		if(inputArray["visible"]===false || inputArray["visible"]===true)this.visible = inputArray["visible"];	
		if(inputArray["collapsable"]===false || inputArray["collapsable"]===true)this.collapsable = inputArray["collapsable"];	
		if(inputArray["scrollbars"]===false || inputArray["scrollbars"]===true)this.scrollbars = inputArray["scrollbars"];	
		if(inputArray["state"])this.state = inputArray["state"];
	}
	// }}}
	,
	// {{{ setSize()
	/**
	*	Set size of pane
	*
	*	@param Integer newSize = Size of new pane ( for "west" and "east", it would be width, for "north" and "south", it's height.
	*
	*	@public
	*/		
	setSize : function(newSize)
	{
		this.size = newSize;
	}
	// }}}
	,
	// {{{ addContent()
	/**
	*	Add content to a pane.
	*
	*	@param Object contentObj = An object of class DHTMLSuite.paneSplitterContentModel
	*	@param Boolean Success = true if content were added, false otherwise, i.e. if conten allready exists
	*	@public
	*/		
	addContent : function(contentObj)
	{
		// Check if content with this id allready exists. if it does, escape from the function.
		for(var no=0;no<this.contents.length;no++){
			if(this.contents[no].id==contentObj.id)return false;	
		}
		this.contents[this.contents.length] = contentObj;	// Add content to the array of content objects.
		return true;
	}
	// }}}
	,
	// {{{ getContents()
	/**
	*	Return an array of content objects
	*
	*	@return Array of DHTMLSuite.paneSplitterContentModel objects
	*
	*	@public
	*/	
	getContents : function()
	{
		return this.contents;
	}
	// }}}
	,
	// {{{ getCountContent()
	/**
	*	Return number of content objects inside this paneModel
	*
	*	@return Integer Number of DHTMLSuite.paneSplitterContentModel objects
	*
	*	@public
	*/	
	getCountContent : function()
	{
		return this.contents.length;
	}
	// }}}
	,
	// {{{ getPosition()
	/**
	*	Return position of this pane
	*
	*	@return String Position of pane ( lowercase )
	*
	*	@public
	*/		
	getPosition : function()
	{
		return this.position.toLowerCase();
	}
	
	,
	// {{{ __setState()
	/**
	*	Update the state attribute
	*
	*	@param String state = state of pane ( "expanded" or "collapsed" )
	*
	*	@public
	*/		
	__setState : function(state)
	{
		this.state = state;
	}
	// }}
	,
	// {{{ __getState()
	/**
	*	Update the state attribute
	*
	*	@return String state - state of pane
	*	@public
	*/		
	__getState : function(state)
	{
		return this.state;
	}
	,
	// {{{ __deleteContent()
	/**
	*	Delete content from a pane.
	*
	*	@param Integer contentIndex - Content index
	*	@return Integer newContentIndex - Content of new active pane.
	*	@private
	*/		
	__deleteContent : function(contentIndex)
	{
		try{
			this.contents.splice(contentIndex,1);
		}catch(e)
		{
		}
		
				
		var retVal = contentIndex;
		if(this.contents.length>(contentIndex-1))retVal--;
		if(retVal<0 && this.contents.length==0)return false;
		if(retVal<0)retVal=0;		
		return retVal;
	}
	// }}}
	,
	// {{{ __getIndexFromId()
	/**
	*	Return index of content with a specific content id
	*
	*	@param String id - id of content
	*	@return Integer index - Index of content
	*	@private
	*/		
	__getIndexFromId : function(id)
	{
		for(var no=0;no<this.contents.length;no++){
			if(this.contents[no].id==id)return no;
		}
		return false;
		
	}
	// }}}
	,
	// {{{ __setVisible()
	/**
	*	Set pane visibility
	*
	*	@param Boolean visible - true = visible, false = hidden
	*	
	*	@private
	*/		
	__setVisible : function(visible)
	{
		this.visible = visible;
	}
}

/**
* @constructor
* @class Purpose of class:	Store metadata about the content of a pane
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

/************************************************************************************************************
*	Data source for the content of a pane splitter pane
*
*	Created:						November, 28th, 2006
*	@class Purpose of class:		Data source for the pane splitter pane
*			
*	Css files used by this script:	
*
*	Demos of this class:			
*
* 	Update log:
*
************************************************************************************************************/




DHTMLSuite.paneSplitterContentModel = function(inputArray)
{
	var id;					// Unique id of pane, in case you want to perform operations on this particular pane.
	var htmlElementId;		// Id of element on the page - if present, the content of this pane will be set to the content of this element
	var title;				// Title of pane
	var tabTitle;			// If more than one pane is present at this position, what's the tab title of this one.	
	var closable;			// Boolean - true or false, should it be possible to close this pane
	var contentUrl;			// Url to content - used in case you want the script to fetch content from the server. the path is relative to your html page.
	this.closable = true;	// Default value
	var refreshAfterSeconds;

	this.refreshAfterSeconds = 0;
	
	if(inputArray)this.setData(inputArray);	// Input array present, call the setData method.
}

DHTMLSuite.paneSplitterContentModel.prototype = 
{
	// {{{ setData()
	/**
	*	One method which makes it possible to set all properties
	*
	*	@param Array associative array of properties
	*			properties: id,position,title,tabTitle,closable,htmlElementId,contentUrl,refreshAfterSeconds
	*
	*	@public
	*/		
	setData : function(inputArray)
	{
		if(inputArray["id"])this.id = inputArray["id"]; else this.id = inputArray['htmlElementId'];
		if(inputArray["closable"]===false || inputArray["closable"]===true)this.closable = inputArray["closable"];
		if(inputArray["title"])this.title = inputArray["title"];
		if(inputArray["tabTitle"])this.tabTitle = inputArray["tabTitle"];
		if(inputArray["contentUrl"])this.contentUrl = inputArray["contentUrl"];
		if(inputArray["htmlElementId"])this.htmlElementId = inputArray["htmlElementId"];	
		if(inputArray["refreshAfterSeconds"])this.refreshAfterSeconds = inputArray["refreshAfterSeconds"];	
	}
	// }}}
	,
	// {{{ __setIdOfContentElement()
	/**
	* 	 Specify contentId
	*
	*	@param String htmlElementId - Id of content ( HTML Element on the page )
	*
	*	@private
	*/		
	__setIdOfContentElement : function(htmlElementId)
	{
		this.htmlElementId = htmlElementId;
	}
	// }}}
	,
	// {{{ __setRefreshAfterSeconds()
	/**
	* 	 Set reload content value ( seconds )
	*
	*	@param Integer refreshAfterSeconds - Refresh rate in seconds
	*
	*	@private
	*/		
	__setRefreshAfterSeconds : function(refreshAfterSeconds)
	{
		this.refreshAfterSeconds = refreshAfterSeconds;
	}
	// }}}
	,
	// {{{ __setContentUrl()
	/**
	* 	 Specifies external url for content
	*
	*	@param String contentUrl - Url of content
	*
	*	@private
	*/		
	__setContentUrl : function(contentUrl)
	{
		this.contentUrl = contentUrl;
	}
}

/*[FILE_START:dhtmlSuite-paneSplitter.js] */
/************************************************************************************************************
*	DHTML pane splitter pane
*
*	Created:						November, 28th, 2006
*	@class Purpose of class:		Creates a pane for the pane splitter ( This is a private class )
*			
*	Css files used by this script:	pane-splitter.css
*
*	Demos of this class:			demo-pane-splitter.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Creates the content for a pane in the pane splitter widget( This is a private class )
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

DHTMLSuite.paneSplitterPane = function(parentRef)
{
	var divElement;		// Reference to a div element for the content
	var divElementCollapsed;	// Reference to the div element for the content ( collapsed state )
	var divElementCollapsedInner;	// Reference to the div element for the content ( collapsed state )
	var contentDiv;		// Div for the content
	var headerDiv;		// Reference to the header div
	var titleSpan;		// Reference to the <span> tag for the title
	var paneModel;		// An array of paneSplitterPaneView objects
	var resizeDiv;		// Div for the resize handle
	var tabDiv;			// Div for the tabs
	
	var parentRef;		// Reference to paneSplitter object
	
	var divClose;		// Reference to close button
	var divCollapse;	// Reference to collapse button
	var divExpand;		// Reference to expand button
	
	var slideIsInProgress;		// Internal variable used by the script to determine if slide is in progress or not
	var zIndexCounter;			// Incremental value used when setting z-indexes.
	var reloadIntervalHandlers;	// Array of setInterval objects, one for each content of this pane
	
	this.contents = new Array();
	this.reloadIntervalHandlers = new Array();

	this.parentRef = parentRef;
	var activeContentIndex;	// Index of active content(default = 0)
	this.activeContentIndex = 0;
	this.slideIsInProgress = false;
	var objectIndex;			// Index of this object in the variableStorage array
	this.zIndexCounter = 1;
	this.objectIndex = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects.length;
	DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[this.objectIndex] = this;
	
		
	
}
DHTMLSuite.paneSplitterPane.prototype =
{
	
// {{{ addDataSource()
	/**
	*	Add a data source to the pane
	*
	*	@param paneModel - Object of class DHTMLSuite.paneSplitterPaneModel
	*	@public
	*/		
	addDataSource : function(paneModel)
	{
		this.paneModel = paneModel;
	}
	// }}}
	,
	// {{{ addContent()
	/**
	* 	 Add a content model to the pane. 
	*
	*	@param DHTMLSuite.paneSplitterContentModel contentModel - Object of class DHTMLSuite.paneSplitterContentModel
	*	@param Boolean Success - true if content were added, false otherwise (i.e. content already exists)
	*
	*	@public
	*/		
	addContent : function(contentModel)
	{
		var retValue = this.paneModel.addContent(contentModel);
		this.__addContentDivs();
		this.__updateTabContent();
		this.__updateView();
		return retValue
	}
	// }}}	
	,	
	// {{{ showContent()
	/**
	* 	Display content - the content with this id will be activated.(if content id doesn't exists, nothing is done)
	*
	*	@param String id - Id of the content to show
	*
	*	@public
	*/		
	showContent : function(id)
	{
		for(var no=0;no<this.paneModel.contents.length;no++){
			if(this.paneModel.contents[no].id==id){
				this.__updatePaneView(no);				
				return;
			}
		}	
	}
	// }}}
	,
	// {{{ loadContent()
	/**
	* 	loads content into a pane
	*
	*	@param String id - Id of the content object - where new content should be appended
	*	@param String url - url to content
	*	@param Integer refreshAfterSeconds		- Reload url after number of seconds. 0 = no refresh ( also default)
	*	@param internalCall Boolean	- Always false ( true only if this method is called by the script it's self )
	*
	*	@public
	*/		
	loadContent : function(id,url,refreshAfterSeconds,internalCall)
	{
		if(!url)return;
		for(var no=0;no<this.paneModel.contents.length;no++){
			if(this.paneModel.contents[no].id==id){
				if(internalCall && !this.paneModel.contents[no].refreshAfterSeconds)return;	// Refresh rate has been cleared - no reload.
				this.paneModel.contents[no].__setContentUrl(url);
				if(refreshAfterSeconds && !internalCall){
					this.paneModel.contents[no].__setRefreshAfterSeconds(refreshAfterSeconds);					
				}
				if(refreshAfterSeconds)this.__handleContentReload(id,refreshAfterSeconds);
				var dynContent = new DHTMLSuite.dynamicContent();
				dynContent.loadContent(this.paneModel.contents[no].htmlElementId,url);		
				dynContent = false;	
				return;
			}
		}	
	}
	// }}}
	,
	// {{{ reloadContent()
	/**
	* 	Reloads content for a pane ( AJAX )
	*
	*	@param String id - Id of the content object - where new content should be appended
	*
	*	@public
	*/		
	reloadContent : function(id)
	{
		var contentIndex = this.paneModel.__getIndexFromId(id);
		if(contentIndex!==false){
			this.loadContent(id,this.paneModel.contents[contentIndex].contentUrl);	
		}		
	}
	// }}}
	,
	// {{{ setRefreshAfterSeconds()
	/**
	* 	Reloads content into a pane - sets a timeout for a new call to loadContent
	*
	*	@param String id - Id of the content object - id of content
	*	@param Integer refreshAfterSeconds - When to reload content, 0 = no reload of content.
	*
	*	@public
	*/	
	setRefreshAfterSeconds : function(id,refreshAfterSeconds)
	{
		for(var no=0;no<this.paneModel.contents.length;no++){
			if(this.paneModel.contents[no].id==id){
				if(!this.paneModel.contents[no].refreshAfterSeconds){
					this.loadContent(id,this.paneModel.contents[no].contentUrl,refreshAfterSeconds);	
				}
				this.paneModel.contents[no].__setRefreshAfterSeconds(refreshAfterSeconds);	
				this.__handleContentReload(id);			
			}
		}
	}
	// }}}
	,
	// {{{ hidePane()
	/**
	* 	Hides the pane
	*
	*
	*	@public
	*/		
	hidePane : function()
	{
		this.paneModel.__setVisible(false);	// Update the data source property
		this.divElement.style.display='none';
		
	}	
	// }}}
	,
	// {{{ showPane()
	/**
	* 	Make a pane visible
	*
	*
	*	@public
	*/		
	showPane : function()
	{
		this.paneModel.__setVisible(true);	
		this.divElement.style.display='block';	
	}	
	// }}}
	,
	// {{{ __handleContentReload()
	/**
	* 	Reloads content into a pane - sets a timeout for a new call to loadContent
	*
	*	@param String id - Id of the content object - id of content
	*
	*	@private
	*/			
	__handleContentReload : function(id)
	{
		var ind = this.objectIndex;		
		var contentIndex = this.paneModel.__getIndexFromId(id);
		if(contentIndex!==false){
			var contentRef = this.paneModel.contents[contentIndex];
			if(contentRef.refreshAfterSeconds){
				if(this.reloadIntervalHandlers[id])clearInterval(this.reloadIntervalHandlers[id]);
				this.reloadIntervalHandlers[id] = setInterval('DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[' + ind + '].loadContent("' + id + '","' + contentRef.contentUrl + '",' + contentRef.refreshAfterSeconds + ',true)',(contentRef.refreshAfterSeconds*1000));
			}else{
				if(this.reloadIntervalHandlers[id])clearInterval(this.reloadIntervalHandlers[id]);
			}
		}		
	}
	// }}}
	,
	// {{{ __createPane()
	/**
	*	This method creates the div for a pane
	*
	*
	*	@private
	*/		
	__createPane : function()
	{
		this.divElement = document.createElement('DIV');	// Create the div for a pane.
		this.divElement.style.position = 'absolute';
		this.divElement.className = 'DHTMLSuite_pane';
		this.divElement.id = 'DHTMLSuite_pane_' + this.paneModel.getPosition();
		document.body.appendChild(this.divElement);

		this.__createHeaderBar();	// Create the header
		this.__createContentPane();	// Create content pane.
		this.__createTabBar();	// Create content pane.
		this.__createCollapsedPane();	// Create div element ( collapsed state)
		this.__updateView();	// Update the view
		
		this.__addContentDivs();
		this.__setSize();

	}
	// }}}
	,
	// {{{ __createCollapsedPane()
	/**
	*	Creates the div element - collapsed state
	*
	*
	*	@private
	*/		
	__createCollapsedPane : function()
	{
		var ind = this.objectIndex;
		var pos = this.paneModel.getPosition();
		var buttonSuffix = 'Vertical';	// Suffix to the class names for the collapse and expand buttons
		if(pos=='west' || pos=='east')buttonSuffix = 'Horizontal';
		if(pos=='center')buttonSuffix = '';
				
		this.divElementCollapsed = document.createElement('DIV');	
		var obj = this.divElementCollapsed;

		obj.className = 'DHTMLSuite_pane_collapsed_' + pos;
		obj.style.visibility='hidden';
		obj.style.position = 'absolute';
		
		this.divElementCollapsedInner = document.createElement('DIV');
		this.divElementCollapsedInner.className= 'DHTMLSuite_pane_collapsedInner';
		this.divElementCollapsedInner.onmouseover = this.__mouseoverHeaderButton;
		this.divElementCollapsedInner.onmouseout = this.__mouseoutHeaderButton;
		this.divElementCollapsedInner.onclick = function(e){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__slidePane(e); }
		DHTMLSuite.commonObj.__addEventElement(this.divElementCollapsedInner);	
		
		obj.appendChild(this.divElementCollapsedInner);
			
		var buttonDiv = document.createElement('DIV');
		buttonDiv.className='buttonDiv';
		
		this.divElementCollapsedInner.appendChild(buttonDiv);
		// Creating expand button
		this.divExpand = document.createElement('DIV');
		if(pos=='south' || pos=='east')
			this.divExpand.className='collapseButton' + buttonSuffix;			
		else
			this.divExpand.className='expandButton' + buttonSuffix;	
		this.divExpand.onclick = function() { return DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__expand(); } ;
		this.divExpand.onmouseover = this.__mouseoverHeaderButton;
		this.divExpand.onmouseout = this.__mouseoutHeaderButton;		
		DHTMLSuite.commonObj.__addEventElement(this.divExpand);		
		buttonDiv.appendChild(this.divExpand);
			
		document.body.appendChild(obj);	

	}
	// }}}	
	,
	// {{{ __autoSlideInPane()
	/**
	*	Automatically slide in a pane when click outside of the pane. This will happen if the pane is currently in "slide out" mode.
	*
	*
	*	@private
	*/	
	__autoSlideInPane : function(e)
	{
		if(document.all)e = event;
		var state = this.paneModel.__getState();	// Get state of pane
		if(state=='collapsed' && this.divElement.style.visibility!='hidden'){	// Element is collapsed but showing(i.e. temporary expanded)
			if(!DHTMLSuite.commonObj.isObjectClicked(this.divElement,e))this.__slidePane(e,true);	// Slide in pane if element clicked is not the expanded pane			
		}
	}
	// }}}
	,	
	// {{{ __slidePane()
	/**
	*	The purpose of this method is to slide out a pane, but the state of the pane is still collapsed
	*
	*
	*	@private
	*/		
	__slidePane : function(e,forceSlide)
	{
		if(this.slideIsInProgress)return;
		this.zIndexCounter++;
		if(document.all)e = event;	// IE
		var src = DHTMLSuite.commonObj.getSrcElement(e);	// Get a reference to the element triggering the event
		if(src.className.indexOf('collapsed')<0 && !forceSlide)return;	// If a button on the collapsed pane triggered the event->Return from the method without doing anything.
		
		this.slideIsInProgress = true;
		var state = this.paneModel.__getState();	// Get state of pane.
		
		var hideWhenComplete = true;
		if(this.divElement.style.visibility=='hidden'){	// The pane is currently not visible, i.e. not slided out.
			
			this.__setSlideInitPosition();
			this.divElement.style.visibility='visible';
			this.divElement.style.zIndex = 16000 + this.zIndexCounter;
			this.divElementCollapsed.style.zIndex = 16000 + this.zIndexCounter;
		
			var slideTo = this.__getSlideToCoordinates(true);	// Get coordinate, where to slide to
			hideWhenComplete = false;
			var slideSpeed = this.__getSlideSpeed(true);
		}else{
			var slideTo = this.__getSlideToCoordinates(false);	// Get coordinate, where to slide to
			var slideSpeed = this.__getSlideSpeed(false);
		}		
		
		this.__processSlide(slideTo,slideSpeed*this.parentRef.slideSpeed,this.__getCurrentCoordinate(),hideWhenComplete);
		
	}
	// }}}
	,
	// {{{ __setSlideInitPosition()
	/**
	*	Set position of pane before slide.
	*
	*
	*	@private
	*/		
	__setSlideInitPosition : function()
	{
		var browserWidth = DHTMLSuite.clientInfoObj.getBrowserWidth();
		var browserHeight = DHTMLSuite.clientInfoObj.getBrowserHeight();
		var pos = this.paneModel.getPosition();
		switch(pos){
			case "west":
				this.divElement.style.left = (0 - this.paneModel.size)+ 'px';				
				break;	
			case "east":
				this.divElement.style.left = browserWidth + 'px';
				break;
			case "north":
				this.divElement.style.top = (0 - this.paneModel.size)+ 'px';	
				break;
			case "south":
				this.divElement.style.top = browserHeight + 'px';
				break;
		}		
	}
	// }}}
	,
	// {{{ __getCurrentCoordinate()
	/**
	*	Return pixel steps for the slide.
	*
	*	@return Integer currentCoordinate	= Current coordinate for a pane ( top or left)
	*
	*	@private
	*/		
	__getCurrentCoordinate : function()
	{
		var pos = this.paneModel.getPosition();
		switch(pos){
			case "west": return this.divElement.style.left.replace('px','')/1;	
			case "east": return this.divElement.style.left.replace('px','')/1;	
			case "south": return this.divElement.style.top.replace('px','')/1;	
			case "north": return this.divElement.style.top.replace('px','')/1;				
		}		
	}
	// }}}
	,
	// {{{ __getSlideSpeed()
	/**
	*	Return pixel steps for the slide.
	*
	*	@param Boolean slideOut	= true if the element should slide out, false if it should slide back, i.e. be hidden.
	*
	*	@private
	*/	
	__getSlideSpeed : function(slideOut)
	{
		var pos = this.paneModel.getPosition();
		switch(pos){
			case "west": 
			case "north":
				if(slideOut)return 1;else return -1;
				break;
			case "south":
			case "east":
				if(slideOut)return -1;else return 1;	
		}				
	}
	
	// }}} 
	,
	// {{{ __processSlide()
	/**
	*	Slides in our out a pane - this method creates that animation
	*
	*	@param Integer slideTo	- coordinate where to slide to(top or left)	
	*	@param Integer slidePixels	- pixels to slide in each iteration of this method
	*	@param Integer currentPos	- current slide position
	*	@param Boolean hideWhenComplete	- Hide pane when completed ?
	*
	*	@private
	*/	
	__processSlide : function(slideTo,slidePixels,currentPos,hideWhenComplete)
	{
		var pos = this.paneModel.getPosition();
		currentPos = currentPos + slidePixels;
		var repeatSlide = true;	// Repeat one more time ?
		if(slidePixels>0 && currentPos>slideTo){
			currentPos = slideTo;
			repeatSlide = false;
		}
		if(slidePixels<0 && currentPos<slideTo){
			currentPos = slideTo;
			repeatSlide = false;
		}
		
		switch(pos){
			case "west":
			case "east":
				this.divElement.style.left = currentPos + 'px';
				break;
			case "north":
			case "south":
				this.divElement.style.top = currentPos + 'px';	
		}
		
		if(repeatSlide){
			var ind = this.objectIndex;			
			setTimeout('DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[' + ind + '].__processSlide(' + slideTo + ',' + slidePixels + ',' + currentPos + ',' + hideWhenComplete + ')',10);
		}else{
			if(hideWhenComplete){
				this.divElement.style.visibility='hidden';
				this.divElement.style.zIndex = 11000;
				this.divElementCollapsed.style.zIndex = 12000;
			}				
			this.slideIsInProgress = false;
		}
		
		
	}
	// }}}
	,
	// {{{ __getSlideToCoordinates()
	/**
	*	Return target coordinate for the slide, i.e. where to slide to
	*
	*	@param Boolean slideOut	= true if the element should slide out, false if it should slide back, i.e. be hidden.
	*
	*	@private
	*/
	__getSlideToCoordinates : function(slideOut)
	{
		var browserWidth = DHTMLSuite.clientInfoObj.getBrowserWidth();
		var browserHeight = DHTMLSuite.clientInfoObj.getBrowserHeight();		
		var pos = this.paneModel.getPosition();
			
		
		switch(pos){
			case "west":	
				if(slideOut)
					return this.parentRef.paneSizeCollapsed;	// End position is
				else
					return (0 - this.paneModel.size);
			case "east":
				if(slideOut)
					return browserWidth - this.parentRef.paneSizeCollapsed - this.paneModel.size;
				else
					return browserWidth;
			case "north":
				if(slideOut)
					return this.parentRef.paneSizeCollapsed;	// End position is
				else
					return (0 - this.paneModel.size);
			case "south":
				if(slideOut)	
					return browserHeight - this.parentRef.paneSizeCollapsed  - this.paneModel.size;
				else
					return browserHeight;
		}
		
	}
	
	// }}}	
	,
	// {{{ __updateCollapsedSize()
	/**
	*	Automatically figure out the size of the pane when it's collapsed(the height or width of the small bar)
	*
	*
	*	@private
	*/		
	__updateCollapsedSize : function()
	{
		var pos = this.paneModel.getPosition();
		var size;
		if(pos=='west' || pos=='east')size = this.divElementCollapsed.offsetWidth;
		if(pos=='north' || pos=='south')size = this.divElementCollapsed.offsetHeight;
		if(size)this.parentRef.__setPaneSizeCollapsed(size);		
	}
	// }}}
	,
	// {{{ __createHeaderBar()
	/**
	*	Creates the header bar for a pane
	*
	*
	*	@private
	*/	
	__createHeaderBar : function()
	{
		var ind = this.objectIndex;	// Making it into a primitive variable
		var pos = this.paneModel.getPosition();
		var buttonSuffix = 'Vertical';	// Suffix to the class names for the collapse and expand buttons
		if(pos=='west' || pos=='east')buttonSuffix = 'Horizontal';
		if(pos=='center')buttonSuffix = '';
		
		this.headerDiv = document.createElement('DIV');
		this.headerDiv.className = 'DHTMLSuite_paneHeader';
		this.headerDiv.style.position = 'relative';
		
		this.titleSpan = document.createElement('SPAN');
		this.titleSpan.className = 'paneTitle';
		this.headerDiv.appendChild(this.titleSpan);
		
		this.divElement.appendChild(this.headerDiv);	
		
		var buttonDiv = document.createElement('DIV');
		buttonDiv.style.position = 'absolute';
		buttonDiv.style.right = '0px';
		buttonDiv.style.top = '0px';
		buttonDiv.className = 'DHTMLSuite_paneHeader_buttonDiv';
		this.headerDiv.appendChild(buttonDiv);
		
		// Creating close button
		this.divClose = document.createElement('DIV');
		this.divClose.className = 'closeButton';
		this.divClose.onmouseover = this.__mouseoverHeaderButton;
		this.divClose.onmouseout = this.__mouseoutHeaderButton;
		this.divClose.onclick = function() { return DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__close(); } ;
		DHTMLSuite.commonObj.__addEventElement(this.divClose);	
		buttonDiv.appendChild(this.divClose);
		
		// Creating collapse button
		if(pos!='center'){
			this.divCollapse = document.createElement('DIV');
			if(pos=='south' || pos=='east')
				this.divCollapse.className='expandButton' + buttonSuffix;
			else
				this.divCollapse.className='collapseButton' + buttonSuffix;
				
			this.divCollapse.onclick = function() { return DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__collapse(); } ;
			this.divCollapse.onmouseover = this.__mouseoverHeaderButton;
			this.divCollapse.onmouseout = this.__mouseoutHeaderButton;
			this.divCollapse.style.display='none';			
			DHTMLSuite.commonObj.__addEventElement(this.divCollapse);		
			buttonDiv.appendChild(this.divCollapse);
		}

		
		this.headerDiv.onselectstart = DHTMLSuite.commonObj.cancelEvent;
			
	}
	// }}}
	,
	// {{{ __mouseoverHeaderButton()
	/**
	*	Mouse over effect - buttons
	*
	*
	*	@private
	*/		
	__mouseoverHeaderButton : function()
	{
		if(this.className.indexOf('Over')==-1)this.className=this.className + 'Over';
	}
	// }}}
	,
	// {{{ __mouseoutHeaderButton()
	/**
	*	Mouse out effect - buttons
	*
	*
	*	@private
	*/		
	__mouseoutHeaderButton : function()
	{
		this.className=this.className.replace('Over','');
	}
	,
	// {{{ __close()
	/**
	*	Close a pane
	*
	*	@param Event e = Reference to Event object
	*
	*	@private
	*/	
	__close : function(e)
	{
		var id = this.paneModel.contents[this.activeContentIndex].id;
		if(id){
			try{
				document.getElementById(this.paneModel.contents[this.activeContentIndex].htmlElementId).parentNode.removeChild(document.getElementById(this.paneModel.contents[this.activeContentIndex].htmlElementId));
			}catch(e){
			}
		}
		this.activeContentIndex = this.paneModel.__deleteContent(this.activeContentIndex);			
		this.__updatePaneView(this.activeContentIndex);
	}
	// }}}
	,
	// {{{ __deleteContentByIndex()
	/**
	*	Close a pane
	*
	*	@param Integer index of content to delete
	*
	*	@private
	*/		
	__deleteContentByIndex : function(contentIndex)
	{
		if(this.paneModel.getCountContent()==0)return;	// No content to delete
		var htmlElementId = this.paneModel.contents[contentIndex].htmlElementId;
		if(htmlElementId){
			try{
				document.getElementById(htmlElementId).parentNode.removeChild(document.getElementById(htmlElementId));
			}catch(e){
			}
		}
		
		var tmpIndex = this.paneModel.__deleteContent(contentIndex);		
		if(contentIndex==this.activeContentIndex)this.activeContentIndex = tmpIndex;
		if(this.activeContentIndex > contentIndex)this.activeContentIndex--;
		if(tmpIndex===false)this.activeContentIndex=false;
			
		this.__updatePaneView(this.activeContentIndex);		
		
	}
	// }}}
	,
	// {{{ __deleteContentById()
	/**
	*	Close/Delete content
	*
	*	@param String id = Id of content to delete/close
	*
	*	@private
	*/		
	__deleteContentById : function(id)
	{
		var index = this.paneModel.__getIndexFromId(id);
		if(index!==false)this.__deleteContentByIndex(index);		
	}
	// }}}
	,
	// {{{ __collapse()
	/**
	*	Collapse a pane.
	*
	*
	*	@private
	*/		
	__collapse : function()
	{
		this.__updateCollapsedSize();
		this.paneModel.__setState('collapsed');		// Updating the state property
		this.divElementCollapsed.style.visibility='visible';
		this.divElement.style.visibility='hidden';
		this.__updateView();
		this.parentRef.__hideResizeHandle(this.paneModel.getPosition());
		this.parentRef.__positionPanes();	// Calling the positionPanes method of parent object
	}
	,
	// {{{ __expand()
	/**
	*	Expand a pane
	*
	*
	*	@private
	*/		
	__expand : function()
	{
		this.paneModel.__setState('expanded');		// Updating the state property
		this.divElementCollapsed.style.visibility='hidden';
		this.divElement.style.visibility='visible';
		this.__updateView();		
		this.parentRef.__showResizeHandle(this.paneModel.getPosition());
		this.parentRef.__positionPanes();	// Calling the positionPanes method of parent object
	}
	// }}}
	,
	// {{{ __updateHeaderBar()
	/**
	*	This method will automatically update the buttons in the header bare depending on the setings specified for currently displayed content.
	*
	*	@param Integer index - Index of currently displayed content
	*
	*	@private
	*/	
	__updateHeaderBar : function(index)
	{
		if(index===false){	// No content in this pane
			this.divClose.style.display='none';	// Hide close button
			if(this.paneModel.getPosition()!='center')this.divCollapse.style.display='block';else this.divCollapse.style.display='none';	// Make collapse button visible for all panes except center
			this.titleSpan.innerHTML = '';	// Set title bar empty
			return;	// Return from this method.
		}
		this.divClose.style.display='block';
		if(this.divCollapse)this.divCollapse.style.display='block';	// Center panes doesn't have collapse button, that's the reason for the if-statement
		this.titleSpan.innerHTML = this.paneModel.contents[index].title;
		var contentObj = this.paneModel.contents[index];
		if(!contentObj.closable)this.divClose.style.display='none';
		if(!this.paneModel.collapsable){	// Pane is collapsable
			if(this.divCollapse)this.divCollapse.style.display='none';	// Center panes doesn't have collapse button, that's the reason for the if-statement
			this.divExpand.style.display='none';
		}

	}
	// }}}
	,
	// {{{ __showButtons()
	/**
	*	Show the close and resize button - it is done by showing the parent element of these buttons
	*
	*
	*	@private
	*/		
	__showButtons : function()
	{
		var div = this.headerDiv.getElementsByTagName('DIV')[0];
		div.style.visibility='visible';		
		
	}
	// }}}
	,
	// {{{ __hideButtons()
	/**
	*	Hides the close and resize button - it is done by hiding the parent element of these buttons
	*
	*
	*	@private
	*/		
	__hideButtons : function()
	{
		var div = this.headerDiv.getElementsByTagName('DIV')[0];
		div.style.visibility='hidden';
		
	}
	// }}}
	,
	// {{{ __updateView()
	/**
	* 	Hide or shows header div and tab div based on content
	*
	*
	*	@private
	*/		
	__updateView : function()
	{
		if(this.paneModel.getCountContent()>0 && this.activeContentIndex===false)this.activeContentIndex = 0;	// No content existed, but content has been added.
		this.tabDiv.style.display='block';
		this.headerDiv.style.display='block';	
		
		if(this.divElement.style.visibility!='hidden'){
			//this.divElementCollapsed.style.left = this.divElement.style.left;
			//this.divElementCollapsed.style.top = this.divElement.style.top;
		}
		var pos = this.paneModel.getPosition();
		if(pos=='south' || pos=='north')this.divElementCollapsed.style.height = this.parentRef.paneSizeCollapsed;

		if(this.paneModel.getCountContent()<2)this.tabDiv.style.display='none';		
		if(this.activeContentIndex!==false)if(!this.paneModel.contents[this.activeContentIndex].title)this.headerDiv.style.display='none';	// Active content without title, hide header bar.
		
		if(this.paneModel.state=='expanded')this.__showButtons();else this.__hideButtons();
				
		this.__setSize();
	}
	// }}}
	,
	// {{{ __createContentPane()
	/**
	* 	Creates the content pane
	*
	*
	*	@private
	*/		
	__createContentPane : function()
	{
		this.contentDiv = document.createElement('DIV');
		this.contentDiv.className = 'DHTMLSuite_paneContent';
		if(DHTMLSuite.clientInfoObj.isMSIE){
			//this.contentDiv.style.overflow = 'hidden';
			//this.contentDiv.style.overflowY = 'auto';
		}
		if(!this.paneModel.scrollbars)this.contentDiv.style.overflow='hidden';
		this.divElement.appendChild(this.contentDiv);		

	}
	// }}}
	,
	// {{{ __createTabBar()
	/**
	* 	Creates the top bar of a pane
	*
	*
	*	@private
	*/		
	__createTabBar : function()
	{
		this.tabDiv = document.createElement('DIV');
		this.tabDiv.className = 'DHTMLSuite_paneTabs';
		this.divElement.appendChild(this.tabDiv);
		this.__updateTabContent();
	}
	// }}}
	,
	// {{{ __updateTabContent()
	/**
	* 	Reset and repaint the tabs of this pane
	*
	*
	*	@private
	*/			
	__updateTabContent : function()
	{
		this.tabDiv.innerHTML = '';	
		var tableObj = document.createElement('TABLE');
	
		tableObj.style.padding = '0px';
		tableObj.style.margin = '0px';
		tableObj.style.position='relative';
		tableObj.cellPadding = 0;
		tableObj.cellSpacing = 0;
		this.tabDiv.appendChild(tableObj);
		var tbody = document.createElement('TBODY');
		tableObj.appendChild(tbody);
		
		var row = tbody.insertRow(0);
		
		var contents = this.paneModel.getContents();
		var ind = this.objectIndex;
		for(var no=0;no<contents.length;no++){
			var cell = row.insertCell(-1);
		
			var divTag = document.createElement('DIV');
			divTag.className = 'paneSplitterInactiveTab';
			cell.appendChild(divTag);
			
			var aTag = document.createElement('A');
			contents[no].tabTitle = contents[no].tabTitle + '';
			aTag.innerHTML = contents[no].tabTitle.replace(' ','&nbsp;');
			aTag.id = 'paneTabLink' + no;
			aTag.href='#';
			aTag.onclick = function(e) { return DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__tabClick(e); } ;
			divTag.appendChild(aTag);
			DHTMLSuite.commonObj.__addEventElement(aTag);
		
		}	
		
		this.__updateTabView(0);
	}	
	,	
	// {{{ __updateTabView()
	/**
	* 	 Updates the tab view. Sets inactive and active tabs.
	*
	*	@param Integer activeTab - Index of active tab.
	*
	*	@private
	*/		
	__updateTabView : function(activeTab)
	{
		var aTags = this.tabDiv.getElementsByTagName('DIV');
		for(var no=0;no<aTags.length;no++){
			if(no==activeTab)aTags[no].className = 'paneSplitterActiveTab'; else aTags[no].className = 'paneSplitterInactiveTab';			
		}		
	}
	// }}}
	,	
	// {{{ __tabClick()
	/**
	* 	 Click on a tab
	*
	*	@param Event e - Reference to the object triggering the event. Content index is the numeric part of this elements id.
	*
	*	@private
	*/	
	__tabClick : function(e)
	{
		if(document.all)e = event;
		var inputObj = DHTMLSuite.commonObj.getSrcElement(e);
		if(inputObj.tagName!='A')inputObj = inputObj.parentNode;
		this.__updatePaneView(inputObj.id.replace(/[^0-9]/gi,''));
		return false;
	}
	// }}}	
	,
	// {{{ __addContentDivs()
	/**
	* 	Add content div to a pane.
	*
	*
	*	@public
	*/		
	__addContentDivs : function()
	{
		var contents = this.paneModel.getContents();
		for(var no=0;no<contents.length;no++){
			var htmlElementId = this.paneModel.contents[no].htmlElementId;	// Get a reference to content id
			var contentUrl = this.paneModel.contents[no].contentUrl;	// Get a reference to content id
			var refreshAfterSeconds = this.paneModel.contents[no].refreshAfterSeconds;	// Get a reference to content id
			if(htmlElementId){
				try{
					this.contentDiv.appendChild(document.getElementById(htmlElementId));
					document.getElementById(htmlElementId).className = 'DHTMLSuite_paneContentInner';
					document.getElementById(htmlElementId).style.display='none';		
				}catch(e){
				}		
			}
			if(contentUrl){	/* Url present */
				if(!this.paneModel.contents[no].htmlElementId || this.paneModel.contents[no].htmlElementId.indexOf('dynamicCreatedDiv__')==-1){	// Has this content been loaded before ? Might have to figure out a smarter way of checking this.
					var d = new Date();	// Create unique id for a new div
					var divId = 'dynamicCreatedDiv__' + d.getSeconds() + (Math.random()+'').replace('.','');
					this.paneModel.contents[no].__setIdOfContentElement(divId);
					var div = document.createElement('DIV');
					div.id = divId;
					div.className = 'DHTMLSuite_paneContentInner';
					this.contentDiv.appendChild(div);
					div.style.display='none';					
					this.loadContent(this.paneModel.contents[no].id,contentUrl,refreshAfterSeconds);
				}
			}			
		}			
		this.__updatePaneView(this.activeContentIndex);	// Display initial data
	}
	// }}}
	,
	// {{{ __showHideContentDiv()
	/**
	* 	Updates the pane view. New content has been selected. call methods for update of header bars, content divs and tabs.
	*
	*	@param Integer index Index of active content ( false = no content exists)
	*
	*	@private
	*/			
	__updatePaneView : function(index)
	{
		if(!index)index=this.activeContentIndex;
		this.__updateTabContent();
		this.__updateView();
		this.__updateHeaderBar(index);
		this.__showHideContentDiv(index);

		this.__updateTabView(index);
		this.activeContentIndex = index;
	}
	// }}}
	,
	// {{{ __showHideContentDiv()
	/**
	*	Switch between content divs(the inner div inside a pane )
	*
	*	@param Integer index Index of content to show(if false, then do nothing --- because there aren't any content in this pane)
	*
	*	@private
	*/		
	__showHideContentDiv : function(index)
	{
		if(index!==false){	// Still content in this pane			
			var htmlElementId = this.paneModel.contents[this.activeContentIndex].htmlElementId;	
			try{
				document.getElementById(htmlElementId).style.display='none';	
			}catch(e){
				
			}			
			var htmlElementId = this.paneModel.contents[index].htmlElementId;
			if(htmlElementId){
				try{
					document.getElementById(htmlElementId).style.display='block';		
				}catch(e){
				}
			}
		}		
	}
	// }}}	
	,
	// {{{ __setSize()
	/**
	*	Set some size attributes for the panes
	*
	*	@param Boolean recursive
	*
	*	@private
	*/			
	__setSize : function(recursive)
	{
		var pos = this.paneModel.getPosition().toLowerCase();
		if(pos=='west' || pos=='east'){
			this.divElement.style.width = this.paneModel.size + 'px';	
		}
		if(pos=='north' || pos=='south'){
			this.divElement.style.height = this.paneModel.size + 'px';	
			this.divElement.style.width = '100%';
		}
		
		try{
			this.contentDiv.style.height = (this.divElement.clientHeight - this.tabDiv.offsetHeight - this.headerDiv.offsetHeight) + 'px';
		}catch(e){
		}
		
		if(!recursive){
			window.obj = this;
			setTimeout('window.obj.__setSize(true)',100);
		}
		
	}	
	// }}}
	,
	// {{{ __setTopPosition()
	/**
	*	Set new top position for the pane
	*
	*	@param Integer newTop
	*
	*	@private
	*/		
	__setTopPosition : function(newTop)
	{
		this.divElement.style.top = newTop + 'px';
	}
	// }}}
	,
	// {{{ __setLeftPosition()
	/**
	*	Set new left position for the pane
	*
	*	@param Integer newLeft
	*
	*	@private
	*/		
	__setLeftPosition : function(newLeft)
	{
		this.divElement.style.left = newLeft + 'px';
	}
	// }}}
	,
	// {{{ __setWidth()
	/**
	*	Set width for the pane
	*
	*	@param Integer newWidth
	*
	*	@private
	*/		
	__setWidth : function(newWidth)
	{
		if(this.paneModel.getPosition()=='west' || this.paneModel.getPosition()=='east')this.paneModel.setSize(newWidth);
		newWidth = newWidth + '';
		if(newWidth.indexOf('%')==-1)newWidth = Math.max(1,newWidth) + 'px';
		this.divElement.style.width = newWidth;
		

		
	}
	// }}}
	,
	// {{{ __setHeight()
	/**
	*	Set height for the pane
	*
	*	@param Integer newHeight
	*
	*	@private
	*/		
	__setHeight : function(newHeight)
	{
		if(this.paneModel.getPosition()=='north' || this.paneModel.getPosition()=='south')this.paneModel.setSize(newHeight);
		this.divElement.style.height = Math.max(1,newHeight) + 'px';		
		this.__setSize();	// Set size of inner elements.
	}
	
}


/************************************************************************************************************
*	DHTML pane splitter
*
*	Created:						November, 28th, 2006
*	@class Purpose of class:		Creates a pane splitter
*			
*	Css files used by this script:	pane-splitter.css
*
*	Demos of this class:			demo-pane-splitter.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Creates a pane splitter. (<a href="../../demos/demo-pane-splitter.html" target="_blank">Demo</a>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

DHTMLSuite.paneSplitter = function()
{
	var dataModel;				// An object of class DHTMLSuite.paneSplitterModel
	var panes;					// An array of DHTMLSuite.paneSplitterPane objects.
	var panesAssociative;		// An associative array of panes. used to get a quick access to the panes
	var paneContent;			// An array of DHTMLSuite.paneSplitterPaneView objects.
	var layoutCSS;				// Name/Path of css file
	
	var horizontalSplitterSize;	// Height of horizontal splitter
	var horizontalSplitterBorderSize;	// Height of horizontal splitter
	
	var verticalSplitterSize;	// 

	var paneSplitterHandles;				// Associative array of pane splitter handles
	var paneDivsCollapsed;					// Associative array of divs ( collapsed state of pane )
	var paneSplitterHandleOnResize;
	
	var resizeInProgress;					// Variable indicating if resize is in progress
	
	var resizeCounter;						// Internal variable used while resizing (-1 = no resize, 0 = waiting for resize)
	var currentResize;						// Which pane is currently being resized ( string, "west", "east", "north" or "south"
	var currentResize_min;
	var currentResize_max;
	
	var paneSizeCollapsed;					// Size of pane when it's collapsed ( the bar )
	var paneBorderLeftPlusRight;			// Sum of border left and right for panes ( needed in a calculation)
	
	var slideSpeed;							// Slide of pane slide	
	
	this.resizeCounter = -1;
	this.horizontalSplitterSize = 5;
	this.verticalSplitterSize = 5;
	this.paneBorderLeftPlusRight = 2;		// 1 pixel border at the right of panes, 1 pixel to the left
	this.slideSpeed = 10;
	
	this.horizontalSplitterBorderSize = 1;
	this.resizeInProgress = false;
	this.paneSplitterHandleOnResize = false;
	this.paneSizeCollapsed = 26;
	
	this.paneSplitterHandles = new Array();
	this.paneDivsCollapsed = new Array();
	
	this.dataModel = false;		// Initial value
	this.layoutCSS = 'pane-splitter.css';
	this.panes = new Array();
	this.panesAssociative = new Array();
	
	
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();	
	var objectIndex;			// Index of this object in the variableStorage array
	
	this.objectIndex = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects.length;
	DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[this.objectIndex] = this;
		
}

DHTMLSuite.paneSplitter.prototype = 
{
	// {{{ addModel()
	/**
	*	Add datasource for the pane splitter
	*
	*	@param Object newModel - Data source, object of class DHTMLSuite.paneSplitterModel
	*
	*	@public
	*/		
	addModel : function(newModel)
	{
		this.dataModel = newModel;		
	}
	// }}}
	,
	// {{{ setLayoutCss()
	/**
	*	Specify name/path to a css file(default is 'pane-splitter.css')
	*
	*	@param String layoutCSS = Name(or relative path) of new css path
	*	@public
	*/		
	setLayoutCss : function(layoutCSS)
	{
		this.layoutCSS = layoutCSS;
	}
	
	,
	// {{{ setSlideSpeed()
	/**
	*	Set speed of slide animation.
	*
	*	@param Integer slideSpeed = new slide speed ( higher = faster ) - default = 10
	*
	*	@public
	*/		
	setSlideSpeed : function(slideSpeed)
	{
		this.slideSpeed = slideSpeed;
	}
	,
	// {{{ init()
	/**
	*	Initializes the script
	*
	*
	*	@public
	*/		
	init : function()
	{
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);	// Load css.	
		this.__createPanes();	// Create the panes	
		this.__positionPanes();	// Position panes
		this.__createResizeHandles();
		this.__addEvents();
		setTimeout("DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[" + this.objectIndex + "].__positionPanes();",100);
		setTimeout("DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[" + this.objectIndex + "].__positionPanes();",500);
	}
	// }}}
	,
	// {{{ loadContent()
    /**
     *	This method loads content from server and inserts it into the pane with the given id 
     *	If you want the content to be displayed directly, remember to call the showContent method too.
     *
     *	@param String id - id of content object where the element should be inserted
     *	@param String url		- Url of file (the content of this file will be inserted into the define pane)
     *	@param Integer refreshAfterSeconds		- Reload url after number of seconds. 0 = no refresh ( also default)
     *
     * @public	
     */		
    	
	loadContent : function(id,url,refreshAfterSeconds)
	{		
		var ref = this.__getPaneReferenceFromId(id);	// Get a reference to the pane where the content is.
		if(ref){	// Pane found
			ref.loadContent(id,url,refreshAfterSeconds);		// Call the loadContent method of this object. 
		}
	}
	// }}}
	,
	// {{{ reloadContent()
    /**
     *	Reloads ajax content
     *
     *	@param String id - id of content object where the element should be inserted
     *
     * @public	
     */		
	reloadContent : function(id)
	{
		var ref = this.__getPaneReferenceFromId(id);	// Get a reference to the pane where the content is.
		if(ref){	// Pane found
			ref.reloadContent(id);		// Call the loadContent method of this object. 
		}		
	}
	// }}}
	,
	// {{{ setRefreshAfterSeconds()
    /**
     *	Specify a new value for when content should be reloaded. 
     *
     *	@param String id - id of content to add the value to
     *	@param Integer refreshAfterSeconds - Refresh rate of content (0 = no refresh)
     *
     * @public	
     */	
	setRefreshAfterSeconds : function(id,refreshAfterSeconds)
	{
		var ref = this.__getPaneReferenceFromId(id);	// Get a reference to the pane where the content is.
		if(ref){	// Pane found
			ref.setRefreshAfterSeconds(id,refreshAfterSeconds);		// Call the loadContent method of this object. 
		}		
		
	}	
	// }}}
	,
	// {{{ showContent()
    /**
     *	Makes content with a specific id visible 
     *
     *	@param String id - id of content to make visible(remember to have unique id's on each of your content objects)
     *
     * @public	
     */		
	showContent : function(id)
	{
		var ref = this.__getPaneReferenceFromId(id);
		if(ref)ref.showContent(id);
	}	
	// }}}
	,
	// {{{ addContent()
	/**
	*	Add content to a pane
	*
	*	@param String panePosition - Position of pane(west,north,center,east or south)
	*	@param Object contentModel - Object of type DHTMLSuite.paneSplitterContentModel
	*	@return Boolean Success - true if content were added successfully, false otherwise - false means that the pane don't exists or that content with this id allready has been added.
	*	@public
	*/		
	addContent : function(panePosition,contentModel)
	{
		if(this.panesAssociative[panePosition.toLowerCase()]) return this.panesAssociative[panePosition.toLowerCase()].addContent(contentModel); else return false;
		
	}	
	// }}}
	,
	// {{{ deleteContentById()
	/**
	*	Delete content from a pane by index
	*
	*	@param String id - Id of content to delete.
	*
	*	@public
	*/		
	deleteContentById : function(id)
	{
		var ref = this.__getPaneReferenceFromId(id);
		if(ref)ref.__deleteContentById(id);
	}
	// }}}
	,
	// {{{ deleteContentByIndex()
	/**
	*	Delete content from a pane by index
	*
	*	@param String panePosition - Position of pane(west,north,center,east or south)
	*	@param Integer	contentIndex
	*
	*	@public
	*/		
	deleteContentByIndex: function(panePosition,contentIndex)
	{
		if(this.panesAssociative[panePosition]){//Pane exists
			this.panesAssociative[panePosition].__deleteContentByIndex(contentIndex);		
		}		
	}	
	// }}}
	,
	// {{{ hidePane()
	/**
	*	Hide a pane
	*
	*	@param String panePosition - Position of pane(west,north,center,east or south)
	*
	*	@public
	*/	
	hidePane : function(panePosition)
	{
		if(this.panesAssociative[panePosition] && panePosition!='center'){
			this.panesAssociative[panePosition].hidePane();				 // Call method in paneSplitterPane class
			if(this.paneSplitterHandles[panePosition])this.paneSplitterHandles[panePosition].style.display='none'; // Hide resize handle
			this.__positionPanes();										 // Reposition panes 	
		}else return false;
		
	}	
	,
	// {{{ showPane()
	/**
	*	Show a previously hidden pane
	*
	*	@param String panePosition - Position of pane(west,north,center,east or south)
	*
	*	@public
	*/	
	showPane : function(panePosition)
	{
		if(this.panesAssociative[panePosition] && panePosition!='center'){
			this.panesAssociative[panePosition].showPane();					// Call method in paneSplitterPane class
			if(this.paneSplitterHandles[panePosition])this.paneSplitterHandles[panePosition].style.display='block';	// Show resize handle
			this.__positionPanes();											// Reposition panes
		}else return false;			
	}	
	// }}}
	,
	// {{{ __setPaneSizeCollapsed()
	/**
	*	Automatically set size of collapsed pane ( called by a pane - the size is the offsetWidth or offsetHeight of the pane in collapsed state)
	*
	*
	*	@private
	*/		
	__setPaneSizeCollapsed : function(newSize)
	{
		if(newSize>this.paneSizeCollapsed)this.paneSizeCollapsed = newSize;
	}
	// }}}
	,		
	// {{{ __createPanes()
	/**
	*	Creates the panes
	*
	*
	*	@private
	*/			
	__createPanes : function()
	{
		var dataObjects = this.dataModel.getItems();	// An array of data source objects, i.e. panes.
		for(var no=0;no<dataObjects.length;no++){
			var index = this.panes.length;
			this.panes[index] = new DHTMLSuite.paneSplitterPane(this);
			this.panes[index].addDataSource(dataObjects[no]);
			this.panes[index].__createPane();				

			this.panesAssociative[dataObjects[no].position.toLowerCase()] = this.panes[index];	// Save this pane in the associative array			
		}		
	}	
	// }}}
	,
	// {{{ __createResizeHandles()
    /**
     *	Positions the resize handles correctly
     *
     *
     * @private	
     */			
	__createResizeHandles : function()
	{
		var ind = this.objectIndex;
		// Create splitter for the north pane
		if(this.panesAssociative['north'] && this.panesAssociative['north'].paneModel.resizable){
			this.paneSplitterHandles['north'] = document.createElement('DIV');
			var obj = this.paneSplitterHandles['north'];
			obj.className = 'DHTMLSuite_paneSplitter_horizontal';
			obj.style.position = 'absolute';
			obj.style.height = this.horizontalSplitterSize + 'px';
			obj.style.width = '100%';
			obj.style.zIndex = 10000;
			DHTMLSuite.commonObj.addEvent(obj,'mousedown',function() { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__initResizePane('north'); });	
			document.body.appendChild(obj);			
		}
		// Create splitter for the west pane
		if(this.panesAssociative['west'] && this.panesAssociative['west'].paneModel.resizable){
			this.paneSplitterHandles['west'] = document.createElement('DIV');
			var obj = this.paneSplitterHandles['west'];
			obj.className = 'DHTMLSuite_paneSplitter_vertical';
			obj.style.position = 'absolute';
			obj.style.width = this.verticalSplitterSize + 'px';
			obj.style.zIndex = 11000;
			DHTMLSuite.commonObj.addEvent(obj,'mousedown',function() { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__initResizePane('west'); });	
			document.body.appendChild(obj);			
		}
		
		// Create splitter for the east pane
		if(this.panesAssociative['east'] && this.panesAssociative['east'].paneModel.resizable){
			this.paneSplitterHandles['east'] = document.createElement('DIV');
			var obj = this.paneSplitterHandles['east'];
			obj.className = 'DHTMLSuite_paneSplitter_vertical';
			obj.style.position = 'absolute';
			obj.style.width = this.verticalSplitterSize + 'px';
			obj.style.zIndex = 11000;		
			DHTMLSuite.commonObj.addEvent(obj,'mousedown',function() { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__initResizePane('east'); });			
			document.body.appendChild(obj);			
		}
		
		
		// Create splitter for the south pane
		if(this.panesAssociative['south'] && this.panesAssociative['south'].paneModel.resizable){
			this.paneSplitterHandles['south'] = document.createElement('DIV');
			var obj = this.paneSplitterHandles['south'];
			obj.className = 'DHTMLSuite_paneSplitter_horizontal';
			obj.style.position = 'absolute';
			obj.style.height = this.horizontalSplitterSize + 'px';
			obj.style.width = '100%';
			obj.style.zIndex = 10000;
			DHTMLSuite.commonObj.addEvent(obj,'mousedown',function() { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__initResizePane('south'); });	
			document.body.appendChild(obj);			
		}		
		
		// Create onresize handle
		this.paneSplitterHandleOnResize = document.createElement('DIV');
		var obj = this.paneSplitterHandleOnResize;
		obj.className = 'DHTMLSuite_paneSplitter_onResize';	
		obj.style.position = 'absolute';
		obj.style.zIndex = 55000;
		obj.style.display='none';
		document.body.appendChild(obj);
		
	}	
	// }}}
	,
	// {{{ __getPaneReferenceFromId()
    /**
     *	Returns a reference to a pane from content id
     *	
     *	@param String id - id of content
     *
     * @private	
     */		
	__getPaneReferenceFromId : function(id)
	{
		for(var no=0;no<this.panes.length;no++){
			var contents = this.panes[no].paneModel.getContents();
			for(var no2=0;no2<contents.length;no2++){
				if(contents[no2].id==id)return this.panes[no];
			}
		}
		return false;
		
	}
	// }}}
	,
	// {{{ __initResizePane()
    /**
     *	Mouse down on resize handle.
     *	
     *	@param String pos ("west","north","east","south")
     *
     * @private	
     */		
	__initResizePane : function(pos)
	{
		this.currentResize = pos;
		this.currentResize_min = this.__getMinimumPos(pos);
		this.currentResize_max = this.__getMaximumPos(pos);
		
		
		this.paneSplitterHandleOnResize.style.left = this.paneSplitterHandles[pos].style.left; 
		this.paneSplitterHandleOnResize.style.top = this.paneSplitterHandles[pos].style.top; 
		this.paneSplitterHandleOnResize.style.width = this.paneSplitterHandles[pos].offsetWidth + 'px'; 
		this.paneSplitterHandleOnResize.style.height = this.paneSplitterHandles[pos].offsetHeight + 'px'; 
		this.paneSplitterHandleOnResize.style.display='block';
		this.resizeCounter = 0;
		DHTMLSuite.commonObj.__setOkToSelect(false);
		this.__timerResizePane();
	}
	// }}}
	,
	// {{{ __getMinimumPos()
    /**
     *	Returns mininum pos in pixels
     *	
     *	@param String pos ("west","north","east","south")
     *
     * @private	
     */		
	__getMinimumPos : function(pos)
	{
		var browserWidth = DHTMLSuite.clientInfoObj.getBrowserWidth();
		var browserHeight = DHTMLSuite.clientInfoObj.getBrowserHeight();
				
		if(pos=='west' || pos == 'north'){
			return 	this.panesAssociative[pos].paneModel.minSize;
		}else{
			if(pos=='east')return 	browserWidth - this.panesAssociative[pos].paneModel.maxSize;
			if(pos=='south')return 	browserHeight - this.panesAssociative[pos].paneModel.maxSize;
		}
	}
	// }}}
	,	
	// {{{ __getMaximumPos()
    /**
     *	Returns maximum pos in pixels
     *	
     *	@param String pos ("west","north","east","south")
     *
     * @private	
     */				
	__getMaximumPos : function(pos)
	{
		var browserWidth = DHTMLSuite.clientInfoObj.getBrowserWidth();
		var browserHeight = DHTMLSuite.clientInfoObj.getBrowserHeight();
				
		if(pos=='west' || pos == 'north'){
			return 	this.panesAssociative[pos].paneModel.maxSize;
		}else{
			if(pos=='east')return 	browserWidth - this.panesAssociative[pos].paneModel.minSize;
			if(pos=='south')return 	browserHeight - this.panesAssociative[pos].paneModel.minSize;
		}
	}
	// }}}	
	,
	// {{{ __timerResizePane()
    /**
     *	A small delay between mouse down and resize start
     *	
     *
     * @private	
     */		
	__timerResizePane : function()
	{
		if(this.resizeCounter>=0 && this.resizeCounter<5){
			this.resizeCounter++;
			setTimeout('DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[' + this.objectIndex + '].__timerResizePane()',2);

		}		
	}
	// }}}
	,
	// {{{ __resizePane()
    /**
     *	Position the resize handle 
     *
     *
     * @private	
     */		
	__resizePane : function(e)
	{
		if(document.all)e = event;	// Get reference to event object.

		if(DHTMLSuite.clientInfoObj.isMSIE && e.button!=1)this.__endResize();
	
		if(this.resizeCounter==5){	/* Resize in progress */
			if(this.currentResize=='west' || this.currentResize=='east'){
				var leftPos = e.clientX;
				if(leftPos<this.currentResize_min)leftPos = this.currentResize_min;
				if(leftPos>this.currentResize_max)leftPos = this.currentResize_max;
				this.paneSplitterHandleOnResize.style.left = leftPos + 'px';
			}else{
				var topPos = e.clientY;
				if(topPos<this.currentResize_min)topPos = this.currentResize_min;
				if(topPos>this.currentResize_max)topPos = this.currentResize_max;				
				this.paneSplitterHandleOnResize.style.top = topPos + 'px';
			}	
		}		
	}
	// }}}
	,	
	// {{{ __endResize()
    /**
     *	End resizing	(mouse up event )
     *
     *
     * @private	
     */		
	__endResize : function()
	{
		if(this.resizeCounter==5){	// Resize completed 
		var browserWidth = DHTMLSuite.clientInfoObj.getBrowserWidth();
		var browserHeight = DHTMLSuite.clientInfoObj.getBrowserHeight();		
			var obj = this.panesAssociative[this.currentResize];
			switch(this.currentResize){
				case "west": 
					obj.__setWidth(this.paneSplitterHandleOnResize.style.left.replace('px','')/1);
					break;	
				case "north":					
					obj.__setHeight(this.paneSplitterHandleOnResize.style.top.replace('px','')/1);
					break;
				case "east":
					obj.__setWidth(browserWidth - this.paneSplitterHandleOnResize.style.left.replace('px','')/1);
					break;
				case "south":
					obj.__setHeight(browserHeight - this.paneSplitterHandleOnResize.style.top.replace('px','')/1);
					break;				
			}					
			this.__positionPanes();
		}
		
		
		this.paneSplitterHandleOnResize.style.display='none';
		this.resizeCounter = -1;
		DHTMLSuite.commonObj.__setOkToSelect(true);
	}
	// }}}	
	,
	// {{{ __hideResizeHandle()
    /**
     *	Hide resize handle.
     *
     *
     * @private	
     */			
	__hideResizeHandle : function(pos){
		if(this.paneSplitterHandles[pos])this.paneSplitterHandles[pos].style.display='none';
	}
	// }}}
	,
	// {{{ __showResizeHandle()
    /**
     *	Make resize handle visible
     *
     *
     * @private	
     */		
	__showResizeHandle : function(pos){
		if(this.paneSplitterHandles[pos])this.paneSplitterHandles[pos].style.display='block';
	}
	// }}}
	,
	// {{{ __positionResizeHandles()
    /**
     *	Positions the resize handles correctly
     *	This method is called by the __positionPanes method. 
     *
     *
     * @private	
     */		
	__positionResizeHandles : function()
	{
		if(this.paneSplitterHandles['north']){	// Position north splitter handle
			this.paneSplitterHandles['north'].style.top = this.panesAssociative['north'].divElement.style.height.replace('px','')  + 'px';	
		}
		var heightHandler = this.panesAssociative['center'].divElement.offsetHeight+1;	// Initial height
		var topPos=0;
		if(this.panesAssociative['center'])topPos +=this.panesAssociative['center'].divElement.style.top.replace('px','')/1;
		
		if(this.paneSplitterHandles['west']){
			if(this.paneSplitterHandles['east'])heightHandler+=this.horizontalSplitterBorderSize/2;
			this.paneSplitterHandles['west'].style.left = this.panesAssociative['west'].divElement.offsetWidth + 'px';	
			this.paneSplitterHandles['west'].style.height = heightHandler + 'px';
			this.paneSplitterHandles['west'].style.top = topPos + 'px';
		}
		if(this.paneSplitterHandles['east']){
			var leftPos = this.panesAssociative['center'].divElement.style.left.replace('px','')/1 + this.panesAssociative['center'].divElement.offsetWidth;
			this.paneSplitterHandles['east'].style.left = leftPos + 'px';	
			this.paneSplitterHandles['east'].style.height = heightHandler + 'px';
			this.paneSplitterHandles['east'].style.top = topPos + 'px';
		}
		if(this.paneSplitterHandles['south']){			
			var topPos = this.panesAssociative['south'].divElement.style.top.replace('px','')/1;
			topPos = topPos - this.horizontalSplitterSize - this.horizontalSplitterBorderSize;
			this.paneSplitterHandles['south'].style.top = topPos + 'px';	
		}
		this.resizeInProgress = false;		
		
	}
	// }}}
	,
	// {{{ __positionPanes()
    /**
     *	Positions the panes correctly
     *
     *
     * @private	
     */		
	__positionPanes : function()
	{
		if(this.resizeInProgress)return;
		var ind = this.objectIndex;
		this.resizeInProgress = true;
		var browserWidth = DHTMLSuite.clientInfoObj.getBrowserWidth();
		var browserHeight = DHTMLSuite.clientInfoObj.getBrowserHeight();
		
		// Position north pane
		var posTopMiddlePanes = 0;
		if(this.panesAssociative['north'] && this.panesAssociative['north'].paneModel.visible){
			if(this.panesAssociative['north'].paneModel.state=='expanded'){
				posTopMiddlePanes = this.panesAssociative['north'].divElement.offsetHeight;
				if(this.paneSplitterHandles['north'])posTopMiddlePanes+=(this.horizontalSplitterSize + this.horizontalSplitterBorderSize);
				this.panesAssociative['north'].__setHeight(this.panesAssociative['north'].divElement.offsetHeight);
			}else{
				posTopMiddlePanes+=this.paneSizeCollapsed;
			}	
		}
		
		// Set top position of center,west and east pa
		if(this.panesAssociative['center'])this.panesAssociative['center'].__setTopPosition(posTopMiddlePanes);
		if(this.panesAssociative['west'])this.panesAssociative['west'].__setTopPosition(posTopMiddlePanes);
		if(this.panesAssociative['east'])this.panesAssociative['east'].__setTopPosition(posTopMiddlePanes);
		
		if(this.panesAssociative['west'])this.panesAssociative['west'].divElementCollapsed.style.top = posTopMiddlePanes + 'px';
		if(this.panesAssociative['east'])this.panesAssociative['east'].divElementCollapsed.style.top = posTopMiddlePanes + 'px';
		
		// Position center pane
		var posLeftCenterPane = 0;
		if(this.panesAssociative['west']){
			if(this.panesAssociative['west'].paneModel.state=='expanded'){	// West panel is expanded.
				posLeftCenterPane = this.panesAssociative['west'].divElement.offsetWidth;	
				this.panesAssociative['west'].__setLeftPosition(0);	
				posLeftCenterPane+=(this.verticalSplitterSize);		
			}else{	// West panel is not expanded.
				posLeftCenterPane+=this.paneSizeCollapsed  ;
			}	
		}

		this.panesAssociative['center'].__setLeftPosition(posLeftCenterPane);

		// Set size of center pane		
		var sizeCenterPane = browserWidth;
		if(this.panesAssociative['west'] && this.panesAssociative['west'].paneModel.visible){	// Center pane exists and is visible - decrement width of center pane
			if(this.panesAssociative['west'].paneModel.state=='expanded')
				sizeCenterPane -= this.panesAssociative['west'].divElement.offsetWidth;
			else
				sizeCenterPane -= this.paneSizeCollapsed;
		}
		
		if(this.panesAssociative['east'] && this.panesAssociative['east'].paneModel.visible){	// East pane exists and is visible - decrement width of center pane
			 if(this.panesAssociative['east'].paneModel.state=='expanded')
			 	sizeCenterPane -= this.panesAssociative['east'].divElement.offsetWidth;
			 else
			 	sizeCenterPane -= this.paneSizeCollapsed;
			 	
		}
		sizeCenterPane-=this.paneBorderLeftPlusRight;
		if(this.paneSplitterHandles['west'] && this.panesAssociative['west'].paneModel.state=='expanded')sizeCenterPane-=(this.verticalSplitterSize);
		if(this.paneSplitterHandles['east'] && this.panesAssociative['east'].paneModel.state=='expanded')sizeCenterPane-=(this.verticalSplitterSize);
		
		this.panesAssociative['center'].__setWidth(sizeCenterPane);
		
		
		// Position east pane
		var posEastPane = posLeftCenterPane + this.panesAssociative['center'].divElement.offsetWidth;
		if(this.paneSplitterHandles['east'])posEastPane+=(this.verticalSplitterSize);
		if(this.panesAssociative['east']){
			if(this.panesAssociative['east'].paneModel.state=='expanded')this.panesAssociative['east'].__setLeftPosition(posEastPane);
			this.panesAssociative['east'].divElementCollapsed.style.left = (posEastPane - this.verticalSplitterSize) + 'px';
		}
		// Set height of middle panes
		var heightMiddleFrames = browserHeight;
		if(this.panesAssociative['north'] && this.panesAssociative['north'].paneModel.visible){
			if(this.panesAssociative['north'].paneModel.state=='expanded'){
				heightMiddleFrames-= this.panesAssociative['north'].divElement.offsetHeight;	
				heightMiddleFrames-=(this.horizontalSplitterSize + this.horizontalSplitterBorderSize);
			}else
				heightMiddleFrames-= this.paneSizeCollapsed;
			
		}
		if(this.panesAssociative['south'] && this.panesAssociative['south'].paneModel.visible){
			if(this.panesAssociative['south'].paneModel.state=='expanded'){
				heightMiddleFrames-=this.panesAssociative['south'].divElement.offsetHeight;
				if(!this.paneSplitterHandles['south'])heightMiddleFrames+=(this.horizontalSplitterSize + this.horizontalSplitterBorderSize);
			}else
				heightMiddleFrames-=this.paneSizeCollapsed;
		}
		
		if(this.panesAssociative['center'])this.panesAssociative['center'].__setHeight(heightMiddleFrames);
		if(this.panesAssociative['west'])this.panesAssociative['west'].__setHeight(heightMiddleFrames);
		if(this.panesAssociative['east'])this.panesAssociative['east'].__setHeight(heightMiddleFrames);		
		
		// Position south pane
		var posSouth = 0;
		if(this.panesAssociative['north']){	/* Step 1 - get height of north pane */
			if(this.panesAssociative['north'].paneModel.state=='expanded'){
				posSouth = this.panesAssociative['north'].divElement.offsetHeight;	
			}else
				posSouth = this.paneSizeCollapsed;
		}
			
		posSouth += heightMiddleFrames;			

		if(this.paneSplitterHandles['south'] && this.panesAssociative['south'].paneModel.state=='expanded'){
			posSouth+=(this.horizontalSplitterSize + this.horizontalSplitterBorderSize);
		}		
		
		if(this.panesAssociative['south']){
			this.panesAssociative['south'].__setTopPosition(posSouth);
			this.panesAssociative['south'].divElementCollapsed.style.top = posSouth + 'px';
			this.panesAssociative['south'].__setWidth('100%');
		}
		
		if(this.panesAssociative['west']){
			this.panesAssociative['west'].divElementCollapsed.style.height = (heightMiddleFrames) + 'px';
			this.panesAssociative['west'].divElementCollapsedInner.style.height = (heightMiddleFrames -5) + 'px';
		}
		if(this.panesAssociative['east']){
			this.panesAssociative['east'].divElementCollapsed.style.height = heightMiddleFrames + 'px';
			this.panesAssociative['east'].divElementCollapsedInner.style.height = (heightMiddleFrames - 5) + 'px';
		}
		if(this.panesAssociative['south']){
			this.panesAssociative['south'].divElementCollapsed.style.width = browserWidth + 'px';
			this.panesAssociative['south'].divElementCollapsedInner.style.width = (browserWidth - 4) + 'px';
			
			if(this.panesAssociative['south'].paneModel.state=='collapsed' && this.panesAssociative['south'].divElementCollapsed.offsetHeight){	// Increasing the size of the southern pane
				
				var rest = browserHeight -  this.panesAssociative['south'].divElementCollapsed.style.top.replace('px','')/1 - this.panesAssociative['south'].divElementCollapsed.offsetHeight;

				if(rest>0)this.panesAssociative['south'].divElementCollapsed.style.height = (this.panesAssociative['south'].divElementCollapsed.offsetHeight + rest) + 'px';
			}
			
		}
		
		if(this.panesAssociative['north']){
			this.panesAssociative['north'].divElementCollapsed.style.width = browserWidth + 'px';
			this.panesAssociative['north'].divElementCollapsedInner.style.width = (browserWidth - 4) + 'px';
		}
		
	
		
		
		this.__positionResizeHandles();
		setTimeout('DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[' + ind + '].__positionResizeHandles()',50);	// To get the tabs positioned correctly.
	}
	// }}}
	,
	// {{{ __autoSlideInPanes()
    /**
     *	Automatically slide in panes .
     *
     *
     * @private	
     */		
	__autoSlideInPanes : function(e)
	{
		if(document.all)e = event;
		if(this.panesAssociative['south'])this.panesAssociative['south'].__autoSlideInPane(e);	
		if(this.panesAssociative['west'])this.panesAssociative['west'].__autoSlideInPane(e);	
		if(this.panesAssociative['north'])this.panesAssociative['north'].__autoSlideInPane(e);	
		if(this.panesAssociative['east'])this.panesAssociative['east'].__autoSlideInPane(e);	
		
	}
	// }}}
	,	
	// {{{ __addEvents()
    /**
     *	Add basic events for the paneSplitter widget
     *
     *
     * @private	
     */		
	__addEvents : function()
	{
		var ind = this.objectIndex;
		DHTMLSuite.commonObj.addEvent(window,'resize',function() { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__positionPanes(); });
		DHTMLSuite.commonObj.addEvent(document.documentElement,'mouseup',function() { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__endResize(); });
		DHTMLSuite.commonObj.addEvent(document.documentElement,'mousemove',function(e) { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__resizePane(e); });		
		DHTMLSuite.commonObj.addEvent(document.documentElement,'click',function(e) { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__autoSlideInPanes(e); });	
		document.documentElement.onselectstart = function() { return DHTMLSuite.commonObj.__getOkToSelect(); };
		DHTMLSuite.commonObj.__addEventElement(window);
	}
}

/*[FILE_START:dhtmlSuite-listModel.js] */

/************************************************************************************************************
*	listModel
*
*	Created:						December, 14th, 2006
*	@class Purpose of class:		An object storing a collection of values and texts
*			
*	Css files used by this script:	
*
*	Demos of this class:			
*
*	Uses classes:					DHTMLSuite.textEditModel
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	listModel (<a href="../../demos/demo-text-edit.html" target="_blank">Demo</a>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/
DHTMLSuite.listModel = function(inputArray)
{
	var options;
	this.options = new Array();
}



DHTMLSuite.listModel.prototype = 
{
	// {{{ addElement()
    /**
     *	Add a single element to the listModel
     *
     *  @param String value = Value of element
     *  @param String text = Text of element
     *
     *  @public	
     */		
	addElement : function(value,text)
	{
		var index = this.options.length;
		this.options[index] = new Array();
		this.options[index]['value'] = value;
		this.options[index]['text'] = text;
	}
	,
	// {{{ createFromMarkupSelect()
    /**
     *	Create listModel object from Select tag. value and text of option tags becomes value and text in the listModel.
     *	This method hides the select box when done.
     *
     *  @param String elId Id of SELECT tag
     *
     *  @public	
     */		
	createFromMarkupSelect : function(elId)
	{
		var obj = document.getElementById(elId);
		if(obj && obj.tagName.toLowerCase()!='select')obj = false;
		if(!obj){
			alert('Error in listModel.createFromMarkupSelect - cannot create elements from select box with id ' + elId);
			return;
		}	
		for(var no=0;no<obj.options.length;no++){
			var index = this.options.length;
			this.options[index] = new Array();
			this.options[index]['value'] = obj.options[no].value;
			this.options[index]['text'] = obj.options[no].text;
		}	
		obj.style.display='none';	
	}
	,
	// {{{ createFromMarkupUlLi()
    /**
     *	Create listModel object from UL,LI tags. the value is the title of the lis, text is innerHTML, example <LI title="1">Norway</li>
     *	This methods hides the UL object
     *
     *  @param String elId Id of UL tag
     *
     *  @public	
     */		
	createFromMarkupUlLi : function(elId)
	{
		var obj = document.getElementById(elId);
		if(obj && obj.tagName.toLowerCase()!='ul')obj = false;
		if(!obj){
			alert('Error in listModel.createFromMarkupSelect - cannot create elements from select box with id ' + elId);
			return;
		}			
		var lis = obj.getElementsByTagName('LI');
		for(var no=0;no<lis.length;no++){
			var index = this.options.length;
			this.options[index] = new Array();
			this.options[index]['value'] = lis[no].getAttribute('title');
			if(!this.options[index]['value'])this.options[index]['value'] = lis[no].title;
			this.options[index]['text'] = lis[no].innerHTML;			
		}
		obj.style.display='none';
	}
}


/*[FILE_START:dhtmlSuite-textEditModel.js] */
/************************************************************************************************************
*	DHTML Text Edit Model Class
*
*	Created:						December, 14th, 2006
*	@class Purpose of class:		Data model for the textEdit class
*			
*	Css files used by this script:	
*
*	Demos of this class:			
*
*	Uses classes:					DHTMLSuite.listModel
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Data model for the textEdit class. (<a href="../../demos/demo-text-edit.html" target="_blank">Demo</a>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/
DHTMLSuite.textEditModel = function(inputArray)
{
	var labelId;				// Id of label for editable element.
	var targetId;				// Id of editable element.
	var serversideFile;			// If individual serverside file should be used for this option
	var optionObj;				// Reference to object of class DHTMLSuite.listModel
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();
	if(inputArray)this.addElement(inputArray);
}

DHTMLSuite.textEditModel.prototype = 
{
	// {{{ addElement()
    /**
     *	Add item
     *
     *  @param Array inputArray - Associative array of properties, possible keys: labelId,elementId,serverFile,listModel
     *
     *  @public	
     */		
	addElement : function(inputArray)
	{
		if(inputArray['labelId'])this.labelId = inputArray['labelId'];	
		if(inputArray['elementId'])this.elementId = inputArray['elementId'];	
		if(inputArray['serverFile'])this.serverFile = inputArray['serverFile'];	
		if(inputArray['listModel'])this.listModel = inputArray['listModel'];	
	}
}

/*[FILE_START:dhtmlSuite-textEdit.js] */
/************************************************************************************************************
*	DHTML Text Edit Class
*
*	Created:						November, 4th, 2006
*	@class Purpose of class:		Make standard HTML elements editable
*			
*	Css files used by this script:	text-edit.css
*
*	Demos of this class:			demo-text-edit.html
*
*	Uses classes:					DHTMLSuite.textEditModel
*									DHTMLSuite.listModel;
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Make standard HTML elements editable (<a href="../../demos/demo-text-edit.html" target="_blank">Demo</a>)
*							
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/




DHTMLSuite.textEdit = function()
{
	var layoutCSS;			// Name of css file
	var elements;			// Array of editable elements
	var elementsAssociative;	// Associative version of the array above - need two because of conflicts with Prototype library when using for in loops.
	var serversideFile;		// Path to file on the server where changes are sent.
	var objectIndex;
	var inputObjects;		// Array of inputs or select boxes
	
	this.layoutCSS = 'text-edit.css';
	this.elements = new Array();
	this.elementsAssociative = new Array();
	this.inputObjects = new Array();
	
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();

	this.objectIndex = DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects.length;
	DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[this.objectIndex] = this;
		
	
}

DHTMLSuite.textEdit.prototype = 
{	
	// {{{ setLayoutCss()
    /**
     *	Add menu items
     *
     *  @param String cssFileName Name of css file 	
     *
     *  @public	
     */	
	setLayoutCss : function(layoutCSS)
	{
		this.layoutCSS = layoutCSS;
	}
	// }}}
	,
	// {{{ setServersideFile()
    /**
     *	Specify server side file.
     *
     *  @param String serversideFile 	Path to server side file where changes are sent. This file will be called with the following arguments: saveTextEdit=1 and textEditElementId=<elementId> and textEditValue=<value>
     *									This file should return OK when everything went fine with the request
     *				  
     *
     *	@type void
     *  @public	
     */		
	setServersideFile : function(serversideFile)
	{
		this.serversideFile = serversideFile;
	}
	// }}}
	,
	// {{{ addElement()
    /**
     *	Add editable element
     *
     *  @param Array Element description = Associative array, possible keys: labelId,elementId,listModel,serverFile
     *		if serverFile is given, this value will override the serversideFile property of this class for this particular element
     *
     *	@type void
     *  @public	
     */	
	addElement : function(inputArray)
	{
		var index = this.elements.length;
		this.elements[index] = new DHTMLSuite.textEditModel(inputArray);	
		this.elementsAssociative[inputArray['elementId']] = this.elements[index];	
	}
	// }}}	
	,
	// {{{ init()
    /**
     *	Initializes the widget
     *
     *
     * @public	
     */		
	init : function()
	{
		DHTMLSuite.commonObj.loadCSS(this.layoutCSS);	
		
		var index = this.objectIndex;
		
		for(var no=0;no<this.elements.length;no++){
			var obj = this.elements[no];

			var label = document.getElementById(obj.labelId);
			label.setAttribute('elementId',obj.elementId);
			if(!label.getAttribute('elementId'))label.elementId = obj.elementId;
			if(label){
				if(label.className){
					label.setAttribute('origClassname',label.className);
					label.origClassname = label.className;
				}
				label.onclick = function(e){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[index].__clickOnLabel(e); }				
				DHTMLSuite.commonObj.__addEventElement(label);
			}
			
			var el = document.getElementById(obj.elementId);
			DHTMLSuite.commonObj.__addEventElement(el);
			if(el){
				
				el.onclick = function(e) { DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[index].__clickOnElement(e); }
				
				if(obj.listModel){	/* List model exists - create select box */
					this.inputObjects[obj.elementId] = document.createElement('SELECT');
					var selObj = this.inputObjects[obj.elementId];
					selObj.className = 'DHTMLSuite_textEdit_select';
					for(var no2=0;no2<obj.listModel.options.length;no2++){
						selObj.options[selObj.options.length] = new Option(obj.listModel.options[no2].text,obj.listModel.options[no2].value);					
					}
					selObj.id = 'input___' + el.id;
					selObj.onblur = function(e){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[index].__exitEditMode(e); }
					DHTMLSuite.commonObj.__addEventElement(selObj);
					el.parentNode.insertBefore(selObj,el);
					selObj.style.display='none';
				}else{
					this.inputObjects[obj.elementId] = document.createElement('INPUT');
					var input = this.inputObjects[obj.elementId];
					input.onblur = function(e){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[index].__exitEditMode(e); }
					DHTMLSuite.commonObj.__addEventElement(input);
										
					input.className = 'DHTMLSuite_textEdit_input';
					input.id = 'input___' + el.id;
					input.value = el.innerHTML;
					el.parentNode.insertBefore(input,el);
					input.style.display='none';
						
				}				
				
			}				
		}	
			
	}
	// }}}
	,
	// {{{ __setLabelClassName()
    /**
     *	Update the class for the label
     *
     *  @param Event e - Id of element
     *
     * @private	
     */			
	__setLabelClassName : function(obj,state)
	{
		if(state=='active')
			obj.className = 'DHTMLSuite_textEdit_label';	
		else{
			var className = '';
			className = obj.getAttribute('origClassname');
			if(!className)className = obj.origClassname;
			obj.className = className;	
		}
	}
	// }}}
	,
	// {{{ __clickOnLabel()
    /**
     *	Click on label
     *
     *  @param Event e - Id of element
     *
     * @private	
     */		
	__clickOnLabel : function(e)
	{
		if(document.all)e = event;
		var obj = DHTMLSuite.commonObj.getSrcElement(e);	// Reference to element triggering the event.
		this.__setLabelClassName(obj,'active');
		var elementId = obj.getAttribute('elementId');
		this.__clickOnElement(false,document.getElementById(elementId));		
	}	
	// }}}
	,
	// {{{ __clickOnElement()
    /**
     *	Click on editable element
     *
     *  @param Event e - Id of element
     *	@param Object obj - Element triggering the event(this value is empty when the method is fired by an event)
     *
     * @private	
     */			
	__clickOnElement : function(e,obj)
	{
		if(document.all)e = event;
		if(!obj)var obj = DHTMLSuite.commonObj.getSrcElement(e);	// Reference to element triggering the event.
		var id = obj.id;
		var dataSource = this.elementsAssociative[id];		
		if(dataSource.listModel)this.__setSelectBoxValue(id,obj.innerHTML);
		if(dataSource.labelId)this.__setLabelClassName(document.getElementById(dataSource.labelId),'active');
		this.inputObjects[id].style.display='';
		this.inputObjects[id].focus();
		if(!dataSource.listModel)this.inputObjects[id].select();
		obj.style.display='none';		
	}
	// }}}
	,
	// {{{ __setSelectBoxValue()
    /**
     *	Update select box to the value of the element
     *
     *  @param String id - Id of element
     *	@param String value - Value of element
     *
     * @private	
     */		
	__setSelectBoxValue : function(id,value)
	{
		var selObj = this.inputObjects[id];
		for(var no=0;no<selObj.options.length;no++){
			if(selObj.options[no].text==value){
				selObj.selectedIndex = no;
				return;
			}
		}		
	}
	// }}}
	,
	// {{{ __exitEditMode()
    /**
     *	Exit text edit mode
     *
     *  @param Event e - Event
     *
     * @private	
     */		
	__exitEditMode : function(e)
	{
		if(document.all)e = event;
		
		var obj = DHTMLSuite.commonObj.getSrcElement(e);	// Reference to element triggering the event.	
		var elementId = obj.id.replace('input___','');	
		
		var dataSource = this.elementsAssociative[elementId];		
		
		var newValue;
		if(dataSource.listModel){
			 newValue = obj.options[obj.options.selectedIndex].text;
		}else{
			newValue = obj.value;
		}
		if(e.keyCode && e.keyCode==27)newValue = document.getElementById(dataSource.elementId).innerHTML;
		if(newValue && newValue!=document.getElementById(dataSource.elementId).innerHTML)this.__sendRequest(dataSource.elementId,newValue);	// Send ajax request when changes has been made.
		document.getElementById(dataSource.elementId).innerHTML = newValue;
		
		
		document.getElementById(dataSource.elementId).style.display='';
		obj.style.display='none';
		if(dataSource.labelId)this.__setLabelClassName(document.getElementById(dataSource.labelId),'inactive');
	}
	// }}}
	,
	// {{{ __sendRequest()
    /**
     *	Send textEdit changes to the server
     *
     *  @param String elementId - Id of changed element
     *  @param String value - Value of changed element
     *
     * @private	
     */		
	__sendRequest : function(elementId,value)
	{
		var index = DHTMLSuite.variableStorage.ajaxObjects.length;	
		var ind = this.objectIndex;
		try{
			DHTMLSuite.variableStorage.ajaxObjects[index] = new sack();
		}catch(e){	// Unable to create ajax object - send alert message and return from sort method.
			alert('Unable to create ajax object. Please make sure that the sack js file is included on your page');	
			return;
		}
		
		var url;
		if(this.elementsAssociative[elementId].serverFile)url = this.elementsAssociative[elementId].serverFile; else url = this.serversideFile;
		if(url.indexOf('?')>=0)url=url+'&'; else url=url+'?';		
		url = url + 'saveTextEdit=1&textEditElementId=' + elementId + '&textEditValue='+escape(value);

		DHTMLSuite.variableStorage.ajaxObjects[index].requestFile = url;	// Specifying which file to get
		DHTMLSuite.variableStorage.ajaxObjects[index].onCompletion = function(){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__handleServerSideResponse(index,url); };	// Specify function that will be executed after file has been found
		DHTMLSuite.variableStorage.ajaxObjects[index].onError = function(){ DHTMLSuite.variableStorage.arrayOfDhtmlSuiteObjects[ind].__handleAjaxError(ajaxIndex,url); };	// Specify function that will be executed after file has been found
		DHTMLSuite.variableStorage.ajaxObjects[index].runAJAX();		// Execute AJAX function			
	}
	// }}}
	,
	// {{{ __handleServerSideResponse()
    /**
     *	Verify response from ajax.
     *
     *  @param Integer ajaxIndex - Index of used sack() object
     *  @param String url - Failing url
     *
     * @private	
     */		
	__handleServerSideResponse : function(ajaxIndex,url)
	{
		if(DHTMLSuite.variableStorage.ajaxObjects[ajaxIndex].response!='OK'){
			alert('An error occured in the textEdit widget when calling the url\n' + url);	
		}	
		DHTMLSuite.variableStorage.ajaxObjects[ajaxIndex] = null;	
	}
	// }}}
	,
	// {{{ __handleAjaxError()
    /**
     *	Ajax request failed
     *
     *  @param Integer ajaxIndex - Index of used sack() object
     *  @param String url - Failing url
     *
     * @private	
     */		
	__handleAjaxError : function(ajaxIndex,url)
	{
		alert('Error when calling the url:\n' + url);
		DHTMLSuite.variableStorage.ajaxObjects[ajaxIndex] = null;	
	}	
	
}

/*[FILE_START:dhtmlSuite-contextMenu.js] */
/************************************************************************************************************
*	DHTML context menu class
*
*	Created:						November, 4th, 2006
*	@class Purpose of class:		Creates a context menu
*			
*	Css files used by this script:	context-menu.css
*
*	Demos of this class:			demo-context-menu.html
*
* 	Update log:
*
************************************************************************************************************/


/**
* @constructor
* @class Purpose of class:	Creates a context menu. (<a href="../../demos/demo-context-menu.html" target="_blank">Demo</a>)
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

var referenceToDHTMLSuiteContextMenu;


DHTMLSuite.contextMenu = function()
{
	var menuModels;
	var menuItems;	
	var menuObject;			// Reference to context menu div
	var layoutCSS;
	var menuUls;			// Array of <ul> elements
	var width;				// Width of context menu
	var srcElement;			// Reference to the element which triggered the context menu, i.e. the element which caused the context menu to be displayed.
	var indexCurrentlyDisplayedMenuModel;	// Index of currently displayed menu model.
	
	this.menuModels = new Array();
	this.menuObject = false;
	this.layoutCSS = 'context-menu.css';
	this.menuUls = new Array();
	this.width = 100;
	this.srcElement = false;
	this.indexCurrentlyDisplayedMenuModel = false;
	
	if(!standardObjectsCreated)DHTMLSuite.createStandardObjects();
	
}

DHTMLSuite.contextMenu.prototype = 
{
	// {{{ setWidth()
    /**
     *	Set width of context menu
     *
     *  @param Integer newWidth - Width of context menu
     *
     * @public	
     */		
	setWidth : function(newWidth)
	{
		this.width = newWidth;
	}
	// }}}
	,	
	// {{{ setLayoutCss()
    /**
     *	Add menu items
     *
     *  @param String cssFileName Name of css file 	
     *
     * @public	
     */		
	setLayoutCss : function(cssFileName)
	{
		this.layoutCSS = cssFileName;	
	}	
	// }}}	
	,	
	// {{{ attachToElement()
    /**
     *	Add menu items
     *
     *  @param Object HTML Element = Reference to html element
     *  @param String elementId = String id of element(optional). An alternative to HTML Element	
     *
     * @public	
     */		
	attachToElement : function(element,elementId,menuModel)
	{
		window.refToThisContextMenu = this;
		if(!element && elementId)element = document.getElementById(elementId);
		if(!element.id){
			element.id = 'context_menu' + Math.random();
			element.id = element.id.replace('.','');
		}
		this.menuModels[element.id] = menuModel;
		element.oncontextmenu = this.__displayContextMenu;
		element.onmousedown = function() { window.refToThisContextMenu.__setReference(window.refToThisContextMenu); };
		DHTMLSuite.commonObj.__addEventElement(element)
		DHTMLSuite.commonObj.addEvent(document.documentElement,"click",this.__hideContextMenu);		
	}	
	// }}}
	,
	// {{{ __setReference()
    /**
     *	Creates a reference to current context menu object. (Note: This method should be deprecated as only one context menu object is needed)
     *
     *  @param Object context menu object = Reference to context menu object
     *
     * @private	
     */		
	__setReference : function(obj)
	{	
		referenceToDHTMLSuiteContextMenu = obj;	
	}
	,
	// {{{ __displayContextMenu()
    /**
     *	Displays the context menu
     *
     *  @param Event e
     *
     * @private	
     */		
	__displayContextMenu : function(e)
	{
		if(document.all)e = event;		
		var ref = referenceToDHTMLSuiteContextMenu;
		ref.srcElement = DHTMLSuite.commonObj.getSrcElement(e);
		
		if(!ref.indexCurrentlyDisplayedMenuModel || ref.indexCurrentlyDisplayedMenuModel!=this.id){			
			if(!ref.indexCurrentlyDisplayedMenuModel)DHTMLSuite.commonObj.loadCSS(ref.layoutCSS);			
			if(ref.indexCurrentlyDisplayedMenuModel){
				ref.menuObject.innerHTML = '';				
			}else{
				ref.__createDivs();
			}
			ref.menuItems = ref.menuModels[this.id].getItems();			
			ref.__createMenuItems();	
		}
		ref.indexCurrentlyDisplayedMenuModel=this.id;
		
		ref.menuObject.style.left = (e.clientX + Math.max(document.body.scrollLeft,document.documentElement.scrollLeft)) + 'px';
		ref.menuObject.style.top = (e.clientY + Math.max(document.body.scrollTop,document.documentElement.scrollTop)) + 'px';
		ref.menuObject.style.display='block';
		return false;
			
	}
	// }}}
	,
	// {{{ __displayContextMenu()
    /**
     *	Add menu items
     *
     *  @param Event e
     *
     * @private	
     */		
	__hideContextMenu : function()
	{
		var ref = referenceToDHTMLSuiteContextMenu;
		if(!ref)return;
		if(ref.menuObject)ref.menuObject.style.display = 'none';
		
		
	}
	// }}}
	,
	// {{{ __createDivs()
    /**
     *	Creates general divs for the menu
     *
     *
     * @private	
     */		
	__createDivs : function()
	{
		var firstChild = false;
		var firstChilds = document.getElementsByTagName('DIV');
		if(firstChilds.length>0)firstChild = firstChilds[0];
		this.menuObject = document.createElement('DIV');
		this.menuObject.className = 'DHTMLSuite_contextMenu';
		this.menuObject.style.backgroundImage = 'url(\'' + DHTMLSuite.configObj.imagePath + 'context-menu-gradient.gif' + '\')';
		this.menuObject.style.backgroundRepeat = 'repeat-y';
		if(this.width)this.menuObject.style.width = this.width + 'px';
		
		if(firstChild){
			firstChild.parentNode.insertBefore(this.menuObject,firstChild);
		}else{
			document.body.appendChild(this.menuObject);
		}
							
		
	}
	// }}}
	,
	
	// {{{ __mouseOver()
    /**
     *	Display mouse over effect when moving the mouse over a menu item
     *
     *
     * @private	
     */		
	__mouseOver : function()
	{
		this.className = 'DHTMLSuite_item_mouseover';	
		if(!document.all){
			this.style.backgroundPosition = 'left center';
		}
									
	}
	// }}}
	,
	// {{{ __mouseOut()
    /**
     *	Remove mouse over effect when moving the mouse away from a menu item
     *
     *
     * @private	
     */		
	__mouseOut : function()
	{
		this.className = '';
		if(!document.all){
			this.style.backgroundPosition = '1px center';
		}		
	}
	// }}}
	,
	// {{{ __createMenuItems()
    /**
     *	Create menu items
     *
     *
     * @private	
     */		
	__createMenuItems : function()
	{
		window.refToContextMenu = this;	// Reference to menu strip object
		this.menuUls = new Array();
		for(var no in this.menuItems){	// Looping through menu items		
			if(!this.menuUls[0]){	// Create main ul element
				this.menuUls[0] = document.createElement('UL');
				this.menuObject.appendChild(this.menuUls[0]);
			}
			
			if(this.menuItems[no].depth==1){

				if(this.menuItems[no].separator){
					var li = document.createElement('DIV');
					li.className = 'DHTMLSuite_contextMenu_separator';
				}else{				
					var li = document.createElement('LI');
					if(this.menuItems[no].jsFunction){
						this.menuItems[no].url = this.menuItems[no].jsFunction + '(this,referenceToDHTMLSuiteContextMenu.srcElement)';
					}
					if(this.menuItems[no].itemIcon){
						li.style.backgroundImage = 'url(\'' + this.menuItems[no].itemIcon + '\')';
						if(!document.all)li.style.backgroundPosition = '1px center';

					}
					
					if(this.menuItems[no].url){
						var url = this.menuItems[no].url + '';
						li.onclick = function(){ eval(url); };
					}
					
					li.innerHTML = '<a href="#" onclick="return false">' + this.menuItems[no].itemText + '</a>';
					li.onmouseover = this.__mouseOver;
					li.onmouseout = this.__mouseOut;
					DHTMLSuite.commonObj.__addEventElement(li);
				}				
				this.menuUls[0].appendChild(li);			
			}		
		}		
	}	
}

