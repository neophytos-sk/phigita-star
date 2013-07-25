/**********************************************************************
 *
 * $Id: kaRouting.js,v 1.1 2007/01/25 08:28:41 lbecchi Exp $
 *
 * purpose: kaTool for routing
 *
 * authors: Andrea Cappugi e Lorenzo Becchi (www.ominiverdi.org)
 *
 * Thanks for inspiring us Toru and Mario. Sugoi!
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
 * kaZoomer
 *
 * class to handle the zoom overlay
 *
 * oKaMap - the ka-Map instance to draw the zoomer on
 *
 *****************************************************************************/
function kaRouting( oKaMap ) {
    kaTool.apply( this, [oKaMap] );
    this.name = 'kaRouting';
    this.canvas = null;
    this.first = null;
    this.sessionid = null;
    this.route = false;
    this.layer = null;
    this.routeid=0;
    
    this.pins = 0;
    this.pin = document.createElement('div');
    var img = document.createElement( 'img' );
	img.src = 'images/tip-red.png';
	img.style.position='absolute';
	img.style.left='-6px';
	img.style.top='-19px';
	this.pin.appendChild(img);
			
			
	
    
    for (var p in kaTool.prototype) {
        if (!kaRouting.prototype[p])
            kaRouting.prototype[p]= kaTool.prototype[p];
    }
};

/**
 * kaRouting.onmousedown( e )
 *
 *
 *
 * e - object, the event object or null (in ie)
 */
kaRouting.prototype.onmousedown = function(e) {
    e = (e)?e:((event)?event:null);
    
    var x = e.pageX || (e.clientX +
          (document.documentElement.scrollLeft || document.body.scrollLeft));
    var y = e.pageY || (e.clientY +
                (document.documentElement.scrollTop || document.body.scrollTop));
    var a = this.adjustPixPosition( x,y );
 
    var p = this.kaMap.pixToGeo( a[0], a[1] );
    
         
	
	if(this.pins>2){
		this.clearPoints();
		return;
	}
	if(this.pins<2)
	    this.drawPoint(p);
    if(this.pins==2) 
		this.routeIt( p );
	
	
};



/**
 * kaRouting.route( p )
 *
 *
 *
 * p - second point
 */
kaRouting.prototype.routeIt = function(p) {
	
   var extent = this.kaMap.getCurrentMap().currentExtents;
   var extent = this.kaMap.getGeoExtents();
   var scale = this.kaMap.getCurrentScale();
   var cMap = this.kaMap.getCurrentMap().name;
   if (this.sessionId)  szSessionIdP="&sessionId="+this.sessionId;
   else szSessionIdP="";
   var params='map='+cMap+'&start='+this.first[0]+'|'+this.first[1]+'&end='+p[0]+'|'+p[1]+'&extent='+extent[0]+'|'+extent[1]+'|'+extent[2]+'|'+extent[3]+szSessionIdP;
//	alert(params);
	this.pins++;
  var url ='tools/kaRouting/kaRouting.php?'+params;
 // WOOpenWin( "prova", url, "" );
	call('tools/kaRouting/kaRouting.php?'+params, this, this.routeResult);
	element = document.getElementById ('msg');
  element.innerHTML = "<h3>Processing search.<br>Please wait...</h3><hr>";
  element.className = "visible";
};


/**
 * kaRouting.routeResult( szResult )
 *
 *
 * szResult - string to eval
 */
kaRouting.prototype.routeResult = function( szResult ) {
	eval( szResult );
 
	if(this.route){
     this.routeid++;	
  	if(!this.layer) 
    {
      this.layer= new routingLayer(this.sessionid,this.routeid);
  		this.kaMap.addMapLayer(this.layer);
    }else
    {
      this.layer.id=this.routeid;
		  this.kaMap.paintLayer(this.layer);
      this.layer.setVisibility( true );
    }
  element = document.getElementById ('msg');
  element.innerHTML = "";
  element.className = "hidden";
	}
};



/**
 * kaRouting.drawPoint(  )
 *
 *
 * szResult - string to eval
 */
kaRouting.prototype.drawPoint = function( p ) {
	if(!this.canvas) this.canvas = myKaMap.createDrawingCanvas( 500 );
	
	if(this.pins==0) {
		this.first = p;
		this.pin2 = this.pin.cloneNode(true);
		this.kaMap.addObjectGeo( this.canvas, p[0], p[1], this.pin2 );
		
	}
	if(this.pins==1) {
		this.second = p;
		this.pin3 = this.pin.cloneNode(true);
		this.kaMap.addObjectGeo( this.canvas, p[0], p[1], this.pin3 );
		
	}
	this.pins++;
	
};

/**
 * kaRouting.drawPoint(  )
 *
 *
 * szResult - string to eval
 */
kaRouting.prototype.clearPoints = function(  ) {
	  this.layer.setVisibility( false );
		this.kaMap.removeObject(this.pin3);
		this.kaMap.removeObject(this.pin2);
		this.pins=0;
	
};
