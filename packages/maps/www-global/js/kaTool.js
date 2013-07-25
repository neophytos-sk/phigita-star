/*
 * kaTool API
 *
 * an API for building tools that work with kaMap
 *
 * To create a new tool, you need to have included this file first.  Next
 * create a function to instantiate your new tool.  All object construction
 * functions must include a parameter that references the kaMap object on which
 * they operate
 *
 * The object construction function must call the kaTool constructor using the
 * following syntax:
 *
 * kaTool.apply( this, [oKaMap] );
 *
 * where oKaMap is the name of the parameter to the constructor function.
 *
 * You should then set the tool's name (this.name) and overload any functions
 * for mouse handling etc
 */

//globally 
var kaCurrentTool = null;

function kaTool( oKaMap )
{
    this.kaMap = oKaMap;
    this.kaMap.registerTool( this );
    this.name = 'kaTool';
}

kaTool.prototype.activate = function()
{
    this.kaMap.activateTool( this );
    document.kaCurrentTool = this;
}

kaTool.prototype.deactivate = function()
{
    this.kaMap.deactivateTool( this );
    document.kaCurrentTool = null;
}

kaTool.prototype.onmousemove = function(e)
{
    return false;
}

kaTool.prototype.onmousedown = function(e)
{
    return false;
}

kaTool.prototype.onmouseup = function(e)
{
    return false;
}

kaTool.prototype.ondblclick = function(e)
{
    return false;
}

kaTool.prototype.onmousewheel = function(e)
{
    e = (e)?e:((event)?event:null);
    var wheelDelta = e.wheelDelta ? e.wheelDelta : e.detail*-1;
    if (wheelDelta > 0)
        this.kaMap.zoomIn();
    else
        this.kaMap.zoomOut();
}

/**
 * kaTool.adjustPixPosition( x, y )
 *
 * adjust a page-relative pixel position into a kaMap relative
 * pixel position
 *
 * x - int, the x page coord
 * y - int, the y page coord
 *
 * returns an array with the adjusted pixel positions
 */
kaTool.prototype.adjustPixPosition = function( x, y )
{
    var obj = this.kaMap.domObj;
    var offsetLeft = 0;
    var offsetTop = 0;
    while (obj)
    {
        offsetLeft += parseInt(obj.offsetLeft);
        offsetTop += parseInt(obj.offsetTop);
        obj = obj.offsetParent;
    }
    
    var pX = parseInt(this.kaMap.theInsideLayer.style.left) + 
             offsetLeft - this.kaMap.xOrigin - x;
    var pY = parseInt(this.kaMap.theInsideLayer.style.top) + 
             offsetTop - this.kaMap.yOrigin - y;
             
    return [pX,pY];
}

/*
 * key press events are directed to the HTMLDocument rather than the
 * div on which we really wanted them to happen.  So we set the document
 * keypress handler to this function and redirect it to the kaMap core
 * keypress handler, which will eventually reach the onkeypress handler
 * of our current tool ... which by default is the keyboard navigation.
 *
 * To get the keyboard events in the first place, add the following when you
 * want the keypress events to be captured
 *
 * if (isIE4) document.onkeydown = kaTool_redirect_onkeypress;
 * document.onkeypress = kaTool_redirect_onkeypress;
 */
function kaTool_redirect_onkeypress(e)
{
    if (document.kaCurrentTool)
        document.kaCurrentTool.onkeypress(e);
}

kaTool.prototype.onkeypress = function(e)
{
    e = (e)?e:((event)?event:null);
    if(e)
    {
        var charCode=(e.charCode)?e.charCode:e.keyCode;
        var b=true;
        var nStep = 16;
        switch(charCode)
        {
          case 38://up
            this.kaMap.moveBy(0,nStep);
            this.kaMap.triggerEvent( KAMAP_EXTENTS_CHANGED, this.kaMap.getGeoExtents() );
            break;
          case 40:
            this.kaMap.moveBy(0,-nStep);
            this.kaMap.triggerEvent( KAMAP_EXTENTS_CHANGED, this.kaMap.getGeoExtents() );
            break;
          case 37:
            this.kaMap.moveBy(nStep,0);
            this.kaMap.triggerEvent( KAMAP_EXTENTS_CHANGED, this.kaMap.getGeoExtents() );
            break;
          case 39:
            this.kaMap.moveBy(-nStep,0);
            this.kaMap.triggerEvent( KAMAP_EXTENTS_CHANGED, this.kaMap.getGeoExtents() );
            break;
          case 33:
            this.kaMap.slideBy(0, this.kaMap.viewportHeight/2);
            break;
          case 34:
            this.kaMap.slideBy(0,-this.kaMap.viewportHeight/2);
            break;
          case 36:
            this.kaMap.slideBy(this.kaMap.viewportWidth/2,0);
            break;
          case 35:
            this.kaMap.slideBy(-this.kaMap.viewportWidth/2,0);
            break;
          case 43:
            this.kaMap.zoomIn();
            break;
         case 45:
            this.kaMap.zoomOut();
            break;
          default:
            b=false;
        }
        if (b)
        {
            return this.cancelEvent(e);
        }
        return true;
    }
}

kaTool.prototype.onmouseover = function(e)
{
    return false;
}
kaTool.prototype.onmouseout = function(e)
{
    if (this.kaMap.isIE4) document.onkeydown = null;
    document.onkeypress = null;
    return false;
}

kaTool.prototype.cancelEvent = function(e)
{
    e = (e)?e:((event)?event:null);
    e.cancelBubble = true;
    e.returnValue = false;
    if (e.stopPropogation) e.stopPropogation();
    if (e.preventDefault) e.preventDefault();
    return false;
}

function kaNavigator( oKaMap )
{
    kaTool.apply( this, [oKaMap] );
    this.name = 'kaNavigator';
    this.cursor = 'move';

    this.activeImage = this.kaMap.server + 'va-images/button_pan_3.png';
    this.disabledImage = this.kaMap.server + 'va-images/button_pan_2.png';
    
    this.lastx = null;
    this.lasty = null;
    this.bMouseDown = false;
    
    for (var p in kaTool.prototype)
    {
        if (!kaNavigator.prototype[p])
            kaNavigator.prototype[p]= kaTool.prototype[p];
    }
}

kaNavigator.prototype.onmouseout = function(e)
{
    e = (e)?e:((event)?event:null);
    if (!e.target) e.target = e.srcElement;

    if (!this.kaMap) return;
    if (!this.kaMap.domObj) return;
    if (!this.kaMap.domObj.id) return;
    if (!e.target.id) return;
    if (e.target.id == this.kaMap.domObj.id)
    {
        this.bMouseDown = false;
        return kaTool.prototype.onmouseout.apply(this, [e]);
    }
}

kaNavigator.prototype.onmousemove = function(e)
{
    e = (e)?e:((event)?event:null);
    
    if (!this.bMouseDown)
    {
        return false;
    }
    
    if (!this.kaMap.layersHidden)
        this.kaMap.hideLayers();

    var newTop = safeParseInt(this.kaMap.theInsideLayer.style.top);
    var newLeft = safeParseInt(this.kaMap.theInsideLayer.style.left);

    newTop = newTop - this.lasty + e.clientY;
    newLeft = newLeft - this.lastx + e.clientX;

    this.kaMap.theInsideLayer.style.top=newTop + 'px';
    this.kaMap.theInsideLayer.style.left=newLeft + 'px';

    this.kaMap.checkWrap.apply(this.kaMap, []);

    this.lastx=e.clientX;
    this.lasty=e.clientY;
    return false;
}

kaNavigator.prototype.onmousedown = function(e)
{
    e = (e)?e:((event)?event:null);
    if (e.button==2)
    {
        return this.cancelEvent(e);
    }
    else
    {
        if (this.kaMap.isIE4) document.onkeydown = kaTool_redirect_onkeypress;
        document.onkeypress = kaTool_redirect_onkeypress;
        
        this.bMouseDown=true;
        this.lastx=e.clientX;
        this.lasty=e.clientY;
        
        e.cancelBubble = true;
        e.returnValue = false;
        if (e.stopPropogation) e.stopPropogation();
        if (e.preventDefault) e.preventDefault();
        return false;
    }
}

kaNavigator.prototype.onmouseup = function(e)
{
    e = (e)?e:((event)?event:null);
    this.bMouseDown=false;
    /* unnecessary according to Steve Lime */
    //this.lastx=null;
    //this.lasty=null;
    this.kaMap.showLayers();
    this.kaMap.triggerEvent(KAMAP_EXTENTS_CHANGED, this.kaMap.getGeoExtents());
    return false;
}

kaNavigator.prototype.ondblclick = function(e)
{
    e = (e)?e:((event)?event:null);

    var aPixPos = this.adjustPixPosition( e.clientX, e.clientY );
    
    var vpX = this.kaMap.viewportWidth/2;
    var vpY = this.kaMap.viewportHeight/2;
    
    var dx = parseInt(this.kaMap.theInsideLayer.style.left) - this.kaMap.xOrigin - vpX - aPixPos[0];
    var dy = parseInt(this.kaMap.theInsideLayer.style.top) - this.kaMap.yOrigin - vpY - aPixPos[1];

    this.kaMap.slideBy(-dx, -dy);
}


