/******************************************************************************
 * kaKeymap - a simple query tool class
 *
 * copyright DM Solutions Group Inc.
 *
 * $Id: kaKeymap.js,v 1.12 2005/11/04 15:23:14 pspencer Exp $
 *
 ******************************************************************************
 *
 * kaKeymap provides an overview or reference for navigational aid to the user.
 * It works by displaying an image and overlaying a rectangular box that
 * indicates the current extents of the main kaMap view.  To accomplish this,
 * the image is associated with a set of geographic extents that it represents.
 * A keymap image is normally a small image that is representative of the full
 * area of the application's data, but with reduced detail (typically just
 * polygons and lines for countries and political boundaries).
 *
 * The default mode of operation uses MapServer only to get the reference
 * object image and extents from the map file.  Tracking of extents is done
 * purely on the client side.
 *
 * The original kaKeymap code was written by DM Solutions Group.  Lorenzo
 * Becchi contributed the code to make the keymap clickable and draggable.
 * 
 *****************************************************************************/

/******************************************************************************
 * kaKeymap
 *
 * class to handle the keymap
 *
 * oKaMap - the ka-Map instance to draw the keymap for
 * szID - string, the id of a div that will contain the keymap
 *
 *****************************************************************************/
function kaKeymap(oKaMap, szID )
{
    this.kaMap = oKaMap;
    this.domObj = this.kaMap.getRawObject(szID);
    this.domObj.kaKeymap=this;
    this.width=getObjectWidth(szID)+"px";
    this.height=getObjectHeight(szID)+"px";
    this.pxExtent =null;
    this.domExtents = null;
    this.domEvent = null;
    this.aExtents = null;
    this.domImg = null;
    this.imgSrc = null;
    this.imgWidth = null;
    this.imgHeight = null;

    this.cellWidth = null;
    this.cellHeight = null;
    this.initialExtents = null;

    this.domObj.ondblclick= this.onclick;

    if ( this.domObj.captureEvents){
        this.domObj.captureEvents(Event.DBLCLICK);
}
    this.kaMap.registerForEvent( KAMAP_EXTENTS_CHANGED, this, this.update );
    this.kaMap.registerForEvent( KAMAP_MAP_INITIALIZED, this, this.initialize );
}

kaKeymap.prototype.initialize = function(id)
{
 
    this.pxExtent =null;
    this.initialExtents=this.kaMap.getGeoExtents();
    call(this.kaMap.server+'/keymap.php?map='+this.kaMap.currentMap,this,this.draw);
}

kaKeymap.prototype.draw = function( szResult )
{
    eval( szResult );

    this.cellWidth = (this.aExtents[2] - this.aExtents[0]) / this.imgWidth;
    this.cellHeight = (this.aExtents[3] - this.aExtents[1]) / this.imgHeight;
    //clear old keymap
    for(var i = this.domObj.childNodes.length - 1; i >= 0; i--)
    this.domObj.removeChild (this.domObj.childNodes[i]);
    
    //create an image to hold the keymap
    this.domImg = document.createElement( 'img' );
    this.domImg.src = this.imgSrc;
    this.domImg.width = this.imgWidth;
    this.domImg.height = this.imgHeight;
    this.domObj.appendChild( this.domImg );
    //create a div to track the current extents
    this.domExtents = document.createElement( 'div' );

    this.domExtents.id="keymapDomExtents";
    this.domExtents.style.position = 'absolute';
    this.domExtents.style.border = '1px solid red';
    this.domExtents.style.top = "1px";
    this.domExtents.style.left = "1px";
    this.domExtents.style.width = "1px";
    this.domExtents.style.height = "1px";
    this.domExtents.style.backgroundColor = 'transparent';
    this.domExtents.style.visibility = 'hidden';
    this.domObj.appendChild(this.domExtents);

    //create a div to allow click/drag of extents for nav
    this.domEvent = document.createElement( 'div' );
    this.domEvent.kaKeymap=this;

    this.domEvent.onmousedown= this.mousedown;
    this.domEvent.onmouseup= this.mouseup;
    this.domEvent.onmousemove= this.mousemove;
    this.domEvent.onmouseout= this.mouseup;
    if (this.domEvent.captureEvents)
    {
       this.domEvent.captureEvents(Event.MOUSEDOWN);
       this.domEvent.captureEvents(Event.MOUSEUP);
       this.domEvent.captureEvents(Event.MOUSEMOVE);
       this.domEvent.captureEvents(Event.MOUSEOUT);
    }

    this.domEvent.style.position = 'absolute';
    this.domEvent.id = 'keymapDomEvent';
    this.domEvent.style.border = '1px solid red';
    this.domEvent.style.top = "0px";
    this.domEvent.style.left = "0px";
    this.domEvent.style.width = "1px"
    this.domEvent.style.height = "1px"
    this.domEvent.style.backgroundColor = 'white';
    this.domEvent.style.visibility = 'visible';
    this.domEvent.style.opacity=0.01;
    this.domEvent.style.mozOpacity=0.01;
    this.domEvent.style.filter = "Alpha(opacity=1)";
    //this.domEvent.style.zIndex = 100;
    this.domObj.appendChild(this.domEvent);

    //changed use an image insetd divs to drow the cross air
    var d = document.createElement( 'div' );
    d.id="keymapCrossImage"
    d.src = this.kaMap.server+"images/Cross.gif";
    d.style.position='absolute';
    d.style.width = "11px";
    d.style.height = "11px";
    d.style.visibility = 'hidden';	
    this.domExtents.appendChild(d);

    if (this.initialExtents != null)
    {
        this.update( null, this.initialExtents);
    }
}

kaKeymap.prototype.update = function( eventID, extents )
{
    if (!this.aExtents || !this.domExtents)
    {
        this.initialExtents = extents;
        return;
    }

 if(this.pxExtent)
  { /*evaluate if div position is different from map position*/
	mgcX=(((extents[2]-extents[0])/2)+extents[0]);
	mgcY=(((extents[3]-extents[1])/2)+extents[1]);
	kgc=this.geoCentCoord();
	if((mgcX-kgc[0])== 0 && (mgcY-kgc[1])==0) return;

 }

    var left = (extents[0] - this.aExtents[0]) / this.cellWidth;
    var width = (extents[2] - extents[0]) / this.cellWidth;
    var top = -1 * (extents[3] - this.aExtents[3]) / this.cellHeight;
    var height = (extents[3] - extents[1]) / this.cellHeight;

    this.pxExtent = new Array(left,top,width,height);
    this.domExtents.style.top = parseInt(top+0.5)+"px";
    this.domExtents.style.left = parseInt(left+0.5)+"px";
    this.domEvent.style.top = parseInt(top+0.5)+"px";
    this.domEvent.style.left = parseInt(left+0.5)+"px";

    if (parseInt(width+0.5) < parseInt(this.domExtents.childNodes[0].style.width) ||
        parseInt(height+0.5) < parseInt(this.domExtents.childNodes[0].style.height) )
    {
        d = this.domExtents.childNodes[0];
        this.domExtents.style.width = d.style.width;
        this.domExtents.style.height = d.style.height;
        this.domEvent.style.width = d.style.width;
        this.domEvent.style.height = d.style.height; 
	this.domExtents.style.border = 'none';
	this.domEvent.style.border = 'none';
	this.domExtents.childNodes[0].style.visibility = 'visible';
    }
    else
    {
    this.domExtents.style.width = parseInt(width+0.5) + "px";
    this.domExtents.style.height = parseInt(height+0.5) + "px";
    this.domEvent.style.width = parseInt(width+0.5) + "px";
    this.domEvent.style.height = parseInt(height+0.5) + "px";
     this.domExtents.style.border = '1px solid red';
     this.domEvent.style.border = '1px solid red';
    this.domEvent.style.visibility = 'visible';
    this.domExtents.style.visibility = 'visible';
    this.domExtents.childNodes[0].style.visibility = 'hidden';
     }
}
/*click event on div kaKeymap*/
kaKeymap.prototype.onclick = function(e)
{
    e = (e)?e:((event)?event:null); 
    this.kaKeymap.centerMap(e);
}
/*call aPixPos to calculate geografic position of click and recenter kamap map*/
kaKeymap.prototype.centerMap = function(e)
{
    var pos= this.aPixPos( e.clientX, e.clientY );
    this.kaMap.zoomTo(pos[0],pos[1]);
}
/**
 * kaKeymap_aPixPos( x, y )
 *
 * try to calculate geoposition in kaKeymap
 *
 * x - int, the x page coord
 * y - int, the y page coord
 *
 * returns an array with geo positions
 */
kaKeymap.prototype.aPixPos = function( x, y )
{
    var obj = this.domObj.offsetParent;
    var offsetLeft = 0;
    var offsetTop = 0;
    while (obj)
    {
        offsetLeft += parseFloat(obj.offsetLeft);
        offsetTop += parseFloat(obj.offsetTop);
        obj = obj.offsetParent;
    }
    var pX = x  - offsetLeft  ;
    var pY = y  -  offsetTop  ;
     pX = parseFloat(this.aExtents[0] + (this.cellWidth *pX)+0.5); 
     pY = parseFloat(this.aExtents[3] - (this.cellHeight *pY)+0.5);
    return [pX,pY];

}

kaKeymap.prototype.mousedown = function(e)
{

     e = (e)?e:((event)?event:null); 
     this.kaKeymap.domEvent.style.top= "0px";
     this.kaKeymap.domEvent.style.left= "0px";
     this.kaKeymap.domEvent.style.width = this.kaKeymap.width;
     this.kaKeymap.domEvent.style.height = this.kaKeymap.height;

    this.kaKeymap.domExtents.init=1;
    this.kaKeymap.domExtents.oX=e.clientX;
    this.kaKeymap.domExtents.oY=e.clientY;
    var amount= 50;
    this.kaKeymap.domExtents.style.backgroundColor = 'pink';
    this.kaKeymap.domExtents.style.opacity=amount/100;

//     this.kaKeymap.domObj.style.mozOpacity = amount/100;
    //Nasty IE effect (or bug?) when you apply a filter
    //to a layer, it clips the layer and we rely on the
    //contents being visible outside the layer bounds
    //for 'railroading' the tiles
    if (this.kaKeymap.kaMap.isIE4)
        this.kaKeymap.domExtents.style.filter = "Alpha(opacity="+amount+")";
}
kaKeymap.prototype.mouseup = function(e)
{

    if(this.kaKeymap.domExtents.init)
    {
        e = (e)?e:((event)?event:null); 
        this.kaKeymap.domExtents.style.backgroundColor = 'transparent';
        this.kaKeymap.domExtents.style.opacity=1;
        if (this.kaKeymap.kaMap.isIE4) 
            this.kaKeymap.domExtents.style.filter = "Alpha(opacity=100)";
        this.kaKeymap.domExtents.init=0;

        cG=this.kaKeymap.geoCentCoord();
        this.kaKeymap.kaMap.zoomTo(cG[0],cG[1]);
    }
}

kaKeymap.prototype.mousemove = function(e)
{
    e = (e)?e:((event)?event:null); 
    if(this.kaKeymap.domExtents.init)
    {
        var xMov=(this.kaKeymap.domExtents.oX-e.clientX);
        var yMov=(this.kaKeymap.domExtents.oY-e.clientY);
        var oX=this.kaKeymap.pxExtent[0];
        var oY=this.kaKeymap.pxExtent[1];
        var nX = oX-xMov;
        var nY = oY-yMov;
        this.kaKeymap.domExtents.oX= e.clientX;
        this.kaKeymap.domExtents.oY= e.clientY;
        this.kaKeymap.pxExtent[0] = nX;
        this.kaKeymap.pxExtent[1] = nY;
        this.kaKeymap.domExtents.style.top = parseInt(nY+0.5) + "px";
        this.kaKeymap.domExtents.style.left = parseInt(nX+0.5) + "px";
    }
}
/**calculate the geografic position of div's center
* Use pxExtent left top width height because the 
div's top left width and heigth (casted to int)
this avoid in calculation error due to ins casting
**/
kaKeymap.prototype.geoCentCoord=function(){ 
       var cpX = this.pxExtent[0] + this.pxExtent[2]/2;
       var cpY = this.pxExtent[1] +  this.pxExtent[3]/2;
       var cX = this.aExtents[0] + (this.cellWidth *cpX); 
       var cY = this.aExtents[3] - (this.cellHeight *cpY); 
       return [cX,cY];
}
