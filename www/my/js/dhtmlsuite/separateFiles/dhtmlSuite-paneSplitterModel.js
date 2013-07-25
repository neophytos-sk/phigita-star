/**
* @constructor
* @class Purpose of class:	Store metadata about panes
* @version 1.0
* @author	Alf Magne Kalleland(www.dhtmlgoodies.com)
*/

/************************************************************************************************************
*	DHTML context menu class
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
*	DHTML context menu class
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