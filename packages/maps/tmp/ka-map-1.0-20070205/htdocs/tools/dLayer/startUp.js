/**********************************************************************
 *
 * $Id: startUp.js,v 1.1 2007/01/26 14:26:26 lbecchi Exp $
 *
 * purpose: start up code to bootstrap initialization of kaMap within
 *          the sample interface.  Examples of using many parts of
 *          the kaMap core api.
 *
 * purpose: This is the sample ka-Map interface.  Feel free to use it 
 *          as the basis for your own applications or just to find out
 *          how ka-Map works.
 *
 * author: Lorenzo Becchi and Andrea Cappugi (www.ominiverdi.org)
 *
 * ka-Explorer interface has been developer for Food and Agriculture 
 * Organization of the United Nations (FAO-UN)
 *
 *
 **********************************************************************
 *
 * Copyright (c) 2006 Food and Agriculture Organization of the United Nations (FAO-UN)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 **********************************************************************/

/******************************************************************************
 *
 * To customize startUp:
 *
 * 1) modify toolbar Layout
 *  act on screen.css file and modify the funcion myMapInitialized().
 *  If you change pan and identifyer images edit switchMode() function too.
 *
 *****************************************************************************/

var myKaMap = myKaNavigator = myKaQuery = myScalebar = null;
var queryParams = null;

/**
 * parse the query string sent to this window into a global array of key = value pairs
 * this function should only be called once
 */
function parseQueryString() {
    queryParams = {};
    var s=window.location.search;
    if (s!='') {
        s=s.substring( 1 );
        var p=s.split('&');
        for (var i=0;i<p.length;i++) {
            var q=p[i].split('=');
            queryParams[q[0]]=q[1];
        }
    }
}

/**
 * get a query value by key.  If the query string hasn't been parsed yet, parse it first.
 * Return an empty string if not found
 */
function getQueryParam(p) {
    if (!queryParams) {
        parseQueryString();
    }
    if (queryParams[p]) {
        return queryParams[p];
    } else {
        return '';
    }
}

function myOnLoad() {
    initDHTMLAPI();

	window.onresize=drawPage;

	myKaMap = new kaMap( 'viewport' );

	var szMap = getQueryParam('map');
    var szExtents = getQueryParam('extents');
    var szCPS = getQueryParam('cps');

    var legendOptions = {};
    legendOptions.visibility = typeof gbLegendVisibilityControl != 'undefined' ? gbLegendVisibilityControl : true;
    legendOptions.opacity = typeof gbLegendOpacityControl != 'undefined' ? gbLegendOpacityControl : true;
    legendOptions.order = typeof gbLegendOrderControl != 'undefined' ? gbLegendOrderControl : true;
    legendOptions.query = typeof gbLegendQueryControl != 'undefined' ? gbLegendQueryControl : true;
    
    var myKaLegend = new kaLegend( myKaMap, 'legend', false, legendOptions);
    var myKaKeymap = new kaKeymap( myKaMap, 'keymap' );
    myKaNavigator = new kaNavigator( myKaMap );
    myKaNavigator.activate();
    myKaQuery = new kaQuery( myKaMap, KAMAP_RECT_QUERY );
    myKaRubberZoom = new kaRubberZoom( myKaMap );
    myKaTracker = new kaMouseTracker(myKaMap);
    myKaTracker.activate();
    
    myDLayer = new dLayer(myKaMap);
    
    myKaMap.registerForEvent( KAMAP_INITIALIZED, null, myInitialized );
    myKaMap.registerForEvent( DLAYER_DLAYERS_CHARGED, null, dLayersCharged );
    myKaMap.registerForEvent( KAMAP_MAP_INITIALIZED, null, myMapInitialized );
    myKaMap.registerForEvent( KAMAP_SCALE_CHANGED, null, myScaleChanged );
    myKaMap.registerForEvent( KAMAP_EXTENTS_CHANGED, null, myExtentChanged );
    myKaMap.registerForEvent( KAMAP_LAYERS_CHANGED, null, myLayersChanged );
    myKaMap.registerForEvent( KAMAP_LAYER_STATUS_CHANGED, null, myLayersChanged );
    myKaMap.registerForEvent( KAMAP_QUERY, null, myQuery );
    myKaMap.registerForEvent( KAMAP_MAP_CLICKED, null, myMapClicked );
    myKaMap.registerForEvent( KAMAP_MOUSE_TRACKER, null, myMouseMoved );;

    myScalebar = new ScaleBar(1);
    myScalebar.divisions = 3;
    myScalebar.subdivisions = 2;
    myScalebar.minWidth = 150;
    myScalebar.maxWidth = 200;
    myScalebar.place('scalebar');

	//toolTip = new kaToolTip( myKaMap );
	
	myKaSearch = new kaSearch( myKaMap );

	drawPage();
    myKaMap.initialize( szMap, szExtents, szCPS );
}

/**
 * event handler for KAMAP_INITIALIZED.
 *
 * at this point, ka-Map! knows what map files are available and we have
 * access to them.
 */
function myInitialized() {
    //myMapInitialized( null, myKaMap.getCurrentMap().name );
    
    myDLayer.getAllMapLayer();
}

/**
 * event handler for KAMAP_MAP_INITIALIZED
 *
 * the scales are put into a select ... this will be used for zooming
 */
function myMapInitialized( eventID, mapName ) {
    //get list of maps and populate the maps select box
    var aMaps = myKaMap.getMaps();
    // Update map selection list if one is available
    var oSelect = document.forms[0].maps;
    if (oSelect)
    {
        var j = 0;
        var opt = new Option( 'select a map', '', true, true );
        oSelect[j++] = opt;
        for(var i in aMaps) {
          oSelect[j++] = new Option(aMaps[i].title,aMaps[i].name,false,false);
		  //set title of the map
		  var mapTitle = getRawObject('mapTitle');
		  if((mapTitle) && aMaps[i].name == mapName)mapTitle.innerHTML = aMaps[i].title;
        }

        //make sure the map is selected ...
        var oSelect = document.forms[0].maps;
        if (oSelect.options[oSelect.selectedIndex].value != mapName) {
            for(var i = 0; i < oSelect.options.length; i++ ) {
                if (oSelect.options[i].value == mapName) {
                    oSelect.options[i].selected = true;	
                    break;
                }
           }
        }
    } 


	//update the scales select
    var currentMap = myKaMap.getCurrentMap();
    var scales = currentMap.getScales();
    var currentScale=myKaMap.getCurrentScale();
    
	oSelect = document.forms[0].scales;
	if(oSelect){
		while( oSelect.options[0] ) oSelect.options[0] = null;
	    j=0;
	    for(var i in scales)
	    {
	        oSelect.options[j++] = new Option("1:"+scales[i],scales[i],false,false);
	    }
	}
    

    
    //Activate query button
    //switchMode('toolPan');
    
    //Activate service box
    //switchService('toolMapinfo');
    
    
	
	/* handle request for layer visibility */
	var layers = getQueryParam('layers');
	if (layers != '') {
		var map = myKaMap.getCurrentMap();
		//turn off all layers
		var allLayers = map.getAllLayers();
		for (var i=0; i<allLayers.length; i++) {
			allLayers[i].setVisibility(false);
		}
		aLayers = layers.split(',');
		for (var i=0;i<aLayers.length; i++) {
			map.setLayerVisibility (unescape(aLayers[i]), true);
		}
	}
	
	//set current scale in the interface
	myKaMap.triggerEvent( KAMAP_SCALE_CHANGED, myKaMap.getCurrentScale() );
}

/**
 * handle the extents changing by updating a link in the interface that links
 * to the current view
 */
function myExtentChanged( eventID, extents ) {
	updateLinkToView();
}

function myMouseMoved( eventID, position) {
    var geopos = document.getElementById('geoPosition');
    if(geopos) geopos.innerHTML = 'x: ' + roundIt(position.x,2) + '<BR>y: ' + roundIt(position.y,2);
}

function myLayersChanged(eventID, map) {
	updateLinkToView();
}

function updateLinkToView()  {
	var port = (window.location.port)? window.location.port : 80;
	var url = window.location.protocol+'/'+'/'+window.location.host +':'+ port +''+window.location.pathname+'?';
	var extents = myKaMap.getGeoExtents();
	var cx = (extents[2] + extents[0])/2;
	var cy = (extents[3] + extents[1])/2;
	var cpsURL = 'cps='+cx+','+cy+','+myKaMap.getCurrentScale();
	var mapURL = 'map=' + myKaMap.currentMap;
    var theMap = myKaMap.getCurrentMap();
	var aLayers = theMap.getLayers();
	var layersURL = 'layers=';
	var sep = '';
	for (var i=0;i<aLayers.length;i++) {
		layersURL += sep + aLayers[i].name;
		sep = ',';
	}

	var link = getRawObject('linkToView');
	if(link) link.href = url + mapURL + '&' + cpsURL + '&' + layersURL;
	
	var linkContent = getRawObject('linkContent');
	if(linkContent) linkContent.value = myUrlEncode('This is a link:\n-------\n'+ url + mapURL + '&' + cpsURL + '&' + layersURL +'\n-------\n\nRemember to copy the entire link string.');


	//this should stay in an independant function
	var geoExtent = getRawObject('geoExtent');
	
	if(geoExtent) {
		geoExtent.innerHTML = 'minx: ' + roundIt(extents[0],2) +'<br>' +
							'miny: ' + roundIt(extents[1],2) +'<br>' +
							'maxx: ' + roundIt(extents[2],2) +'<br>' +
							'maxy: ' + roundIt(extents[3],2) +'<br>';
	}
}


function sendLinkToView(email,body) {
	
	var mySubject = myUrlEncode('Authomatic ka-Map mail');
	var myBody = myUrlEncode(body);
		
	location.replace( 'mailto:' + email + '?subject=' + mySubject + '&body=' + body);
}



/**
 * called when kaMap tells us the scale has changed
 */
function myScaleChanged( eventID, scale ) {


	var oSelect = document.forms[0].scales;
	if(oSelect){
	    for (var i=0; i<oSelect.options.length; i++)
	    {
	        if (oSelect.options[i].value == scale)
	        {
	            oSelect.options[i].selected = true;
	        }
	    }
    }
    myScalebar.update(scale);
   
    /*
    if (scale >= 1000000) {
        scale = scale / 1000000;
        scale = scale + " Million";
    }
    var outString = 'current scale 1:'+ scale;
    getRawObject('scale').innerHTML = outString;
    */
}




/**
 * called when the user changes scales.  This will cause the map to zoom to
 * the new scale and trigger a bunch of events, including:
 * KAMAP_SCALE_CHANGED
 * KAMAP_EXTENTS_CHANGED
 */
function mySetScale( scale ) {
    myKaMap.zoomToScale( scale );
}

/**
 * called when the map selection changes due to the user selecting a new map.
 * By calling myKaMap.selectMap, this triggers the KAMAP_MAP_INITIALIZED event
 * after the new map is initialized which, in turn, causes myMapInitialized
 * to be called
 */
function mySetMap( name ) {
    myKaMap.selectMap( name );
    
    getRawObject('dLegend').innerHTML='';
    myDLayer.getAllMapLayer();
    
}


function myQuery( eventID, queryType, coords ) {
    var szLayers = '';
    var layers = myKaMap.getCurrentMap().getQueryableLayers();
    if(layers.length==0) {
     alert("No queryable layers at this scale and extent");
     return;
    }
    for (var i=0;i<layers.length;i++) {
        szLayers = szLayers + "," + layers[i].name;
    }


    var extent = myKaMap.getGeoExtents();
    var scale = myKaMap.getCurrentScale();
    var cMap = myKaMap.getCurrentMap().name;
	var params='map='+cMap+'&q_type='+queryType+'&scale='+scale+'&groups='+szLayers+'&coords='+coords+'&extent='+extent[0]+'|'+extent[1]+'|'+extent[2]+'|'+extent[3];
		
	getRawObject('queryOut').innerHTML = '<h3>Processing query. <br> please wait...</h3><hr>';
		
	call('map_query_float.php?'+params,this, myQueryOutput);
	
//    alert( "Map: " + cMap + " | Scale: " + scale + " | Extent: " + extent + " | QUERY: " + queryType + " " + coords + " on layers " + szLayers );
}

function myQueryOutput (szText){
	getRawObject('queryOut').innerHTML=szText;
}


function myMapClicked( eventID, coords ) {
    //alert( 'myMapClicked('+coords+')');
	//myKaMap.zoomTo(coords[0],coords[1]);
}

function myZoomIn() {
    myKaMap.zoomIn();
}

function myZoomOut() {
    myKaMap.zoomOut();
}

function myPrint(output_type) {
    var szLayers = '';
    var szOpacitys = '';
    
    var layers = myKaMap.getCurrentMap().getLayers();
    for (var i=0;i<layers.length;i++) {
        szLayers = szLayers + "," + layers[i].name;
        szOpacitys = szOpacitys + "," + layers[i].opacity;
    }

    var extent = myKaMap.getGeoExtents();
    var scale = myKaMap.getCurrentScale();
    var cMap = myKaMap.getCurrentMap().name;
    
    var img_width = '600';// pixel dimension. max_img_width set inside print_map.php
    
    //output_type
	var params='output_type='+output_type+'&map='+cMap+"&opacitys="+szOpacitys+'&scale='+scale+'&img_width='+img_width+'&groups='+szLayers+'&extent='+extent[0]+'|'+extent[1]+'|'+extent[2]+'|'+extent[3];
 	
 	//create and download the output file
 	location.href='tools/print/print_map.php?'+params;
 	
 	//or open it in a new window
    //WOOpenWin( 'Print', '../tools/print/print_map.php?'+params, 'resizable=yes,scrollbars=yes,width=600,height=400' );

}



/**
 * drawPage - calculate sizes of the various divs to make the app full screen.
 */
function drawPage() {
   
   
    myKaMap.resize();
}

function showContent(url) {
	var content = getRawObject('content');
	var viewport = getRawObject('viewport');
	content.style.top = parseInt(viewport.style.top) + 10 + "px";
	content.style.display = "block";
	call(url,this, setContent);
}

function setContent(szContent){
	var contentText = getRawObject('contentText');
	contentText.innerHTML = szContent;
}
function hideContent() {
	var content = getRawObject('content');
	var viewport = getRawObject('viewport');
	content.style.display = "none";
	//content.style.top = parseInt(viewport.style.top) + parseInt(viewport.style.height) + "px";
}

/**
 * getFullExtent
 * ...
 */
function getFullExtent() {
    var exStr = myKaMap.getCurrentMap().defaultExtents.toString();
    var ex = myKaMap.getCurrentMap().defaultExtents;
    myKaMap.zoomToExtents(ex[0],ex[1],ex[2],ex[3]);
}




/*
 *  applyPNGFilter(o)
 *
 *  Applies the PNG Filter Hack for IE browsers when showing 24bit PNG's
 *
 *  var o = object (this png element in the page)
 *
 * The filter is applied using a nifty feature of IE that allows javascript to
 * be executed as part of a CSS style rule - this ensures that the hack only
 * gets applied on IE browsers :)
 */
function applyPNGFilter(o) {
    var t="images/a_pixel.gif";
    if( o.src != t ) {
        var s=o.src;
        o.src = t;
        o.runtimeStyle.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+s+"',sizingMethod='scale')";
    }
}

//functions to open popup

function WOFocusWin( nn ) {
	eval( "if( this."+name+") this."+name+".moveTo(50,50); this."+name+".focus();" );
}

function WOOpenWin( name, url, ctrl ) {
    eval( "this."+name+"=window.open('"+url+"','"+name+"','"+ctrl+"');" );

    /*IE needs a delay to move forward the popup*/
    // window.setTimeout( "WOFocusWin(nome);", 300 );
}

function WinOpener() {
    this.openWin=WOOpenWin;
	this.focusWin=WOFocusWin;
}


//URL SYNTAX ENCODING
function myUrlEncode(string) {
  encodedHtml = escape(string);
  encodedHtml = encodedHtml.replace("/","%2F");
  encodedHtml = encodedHtml.replace(/\?/g,"%3F");
  encodedHtml = encodedHtml.replace(/=/g,"%3D");
  encodedHtml = encodedHtml.replace(/&/g,"%26");
  encodedHtml = encodedHtml.replace(/@/g,"%40");
  return encodedHtml;
};
  
function myUrlDecode(sz){
	return unescape(sz).replace(/\+/g," ");
};

//MATH FUNCTIONs
function roundIt(number,decimals){
	var base10 = 10;
	for(var i=0;i<decimals-1;i++)
		base10 = base10 *10;
	 
	return Math.round(number * base10)/base10;
}


//DYNAMIC LAYERS FUNCTIONS
var dLayers = [];
function dLayerChanged(){
	var checkboxBase = this.checkboxBase;
	//cheackbox names have to start with 'checkboxBase'
	for(i=0;i<document.getElementsByTagName('input').length;i++){
		var input = document.getElementsByTagName('input')[i];
		if((input) && input.type=='checkbox' && input.name.substring(0,checkboxBase.length)==checkboxBase){
			var name = input.name.substring(checkboxBase.length,input.name.length);
			dLayers.push(name);
		}
	}
	dLayerQuery();
}

function dLayerQuery(){
	myDLayer.query(dLayers.join(','));
	dLayers = [];
}

function dLayersCharged(){
var dLegend = getRawObject('dLegend');
   
   for (i=0;i<myDLayer.mapLayers.length;i++){
   		var div = document.createElement('div');
   		var checkbox = document.createElement('input');
   		checkbox.type = 'checkbox';
   		checkbox.name = 'dLayer_'+myDLayer.mapLayers[i];
   		checkbox.checkboxBase = 'dLayer_';
   		checkbox.onclick =dLayerChanged;
   		div.appendChild(checkbox);
   		var span = document.createElement('span');
   		span.innerHTML = myDLayer.mapLayers[i];
   		div.appendChild(span);
   		dLegend.appendChild(div);
   }
}