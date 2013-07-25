/**********************************************************************
 *
 * $Id: dLayer.js,v 1.1 2007/01/26 14:26:26 lbecchi Exp $
 *
 * purpose: tool to create layers on the fly (bug 1646)
 *
 * authors: Andrea Cappugi e Lorenzo Becchi (www.ominiverdi.org)
 *
 *
 * TODO:
 * 
 **********************************************************************
 *
 * Copyright (c) 2006, Ominiverdi.org 
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
 * dLayer
 *
 * to create layers on the fly
 *
 * oKaMap - the ka-Map instance to draw the zoomer on
 *
 *****************************************************************************/
function dLayer( oKaMap ) {
    kaTool.apply( this, [oKaMap] );
    this.name = 'dLayer';
    this.sessionid = null;
    this.layer = null;
 
	this.sldUrl = '';
			
	this.mapLayers = {};
	
    
    for (var p in kaTool.prototype) {
        if (!dLayer.prototype[p])
            dLayer.prototype[p]= kaTool.prototype[p];
    }
};

/******************************************************************************
 * setSldURL
 *
 * require URL to WPS cgi executable
 *     
 *****************************************************************************/
dLayer.prototype.setSldURL=function(url){
 	this.sldUrl= url;	
};

/**
 * dLayer.query( layers )
 *
 *
 *
 * layers -comma separated list of map layers
 */
dLayer.prototype.query = function(layers) {
	
   var extent = this.kaMap.getCurrentMap().currentExtents;
   var extent = this.kaMap.getGeoExtents();
   var scale = this.kaMap.getCurrentScale();
   var cMap = this.kaMap.getCurrentMap().name;
   if (this.sessionId)  szSessionIdP="&sessionId="+this.sessionId;
   else szSessionIdP="";
   var params='map='+cMap+'&name='+this.name+'&layers='+layers+'&extent='+extent[0]+'|'+extent[1]+'|'+extent[2]+'|'+extent[3]+szSessionIdP;
//	alert(params);
   params += "&sldUrl="+this.urlencode(this.sldUrl);
   
  var url ='tools/dLayer/dLayer.php?'+params;
  
	call('tools/dLayer/dLayer.php?'+params, this, this.queryResult);
	
};

/**
 * dLayer.getAllMapLayer( )
 *
 */

dLayer.prototype.getAllMapLayer = function() {
	
   var cMap = this.kaMap.getCurrentMap().name;
  
   var params='map='+cMap;
   
  var url ='tools/dLayer/getMapLayers.php?'+params;
  
	call(url, this, this.addLayers);
	
};

/**
 * dLayer.addLayers( )
 *
 */

var DLAYER_DLAYERS_CHARGED = gnLastEventId++;

dLayer.prototype.addLayers = function(szResult) {
	
   eval( szResult );
   this.mapLayers = layers.split(',');
 	
 	this.kaMap.triggerEvent(DLAYER_DLAYERS_CHARGED);
	
};

/**
 * dLayer.routeResult( szResult )
 *
 *
 * szResult - string to eval
 */
dLayer.prototype.queryResult = function( szResult ) {
	eval( szResult );
 
	if(dResult==true){
	  	if(!this.layer) 
	    {
	      this.layer= new dLayerLayer(this.sessionid,this.name);
	  		this.kaMap.addMapLayer(this.layer);
	    }else
	    {
	      //this.layer.id=this.routeid;
			  this.kaMap.paintLayer(this.layer);
	      this.layer.setVisibility( true );
	    }
	}
 
};

/******************************************************************************
 * urlencode
 *
 * url encode a string
 *     
 *****************************************************************************/
dLayer.prototype.urlencode=function(string){
	encodedHtml = escape(string);
	encodedHtml = encodedHtml.replace("/","%2F");
	encodedHtml = encodedHtml.replace(/\?/g,"%3F");
	encodedHtml = encodedHtml.replace(/=/g,"%3D");
	encodedHtml = encodedHtml.replace(/&/g,"%26");
	encodedHtml = encodedHtml.replace(/@/g,"%40");
	return encodedHtml;
}

