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