/******************************************************************************
 * kaScalebar
 *
 * internal class to handle the scalebar
 *
 * oKaMap - the ka-Map instance to draw the scalebar for
 * szID - string, the id of a div that will contain the scalebar
 *
 *****************************************************************************/
function kaScalebar(oKaMap, szID /*, szWidth, szHeight */)
{
    this.kaMap = oKaMap;
    this.domObj = this.kaMap.getRawObject(szID);
    
    if (arguments.length > 2)
    {
        szWidth = arguments[2];
    }
    else
    {
        szWidth = this.kaMap.getObjectWidth(szID);
    }
    if (arguments.length > 3)
    {
        szHeight = arguments[3];
    }
    else
    {
        szHeight = this.kaMap.getObjectHeight(szID);
    }
      
      
    
    //create an image to hold the scalebar
    this.domImg = this.domObj;
    
    /*
    document.createElement( 'img' );
    this.domImg.width = szWidth;
    this.domImg.height = szHeight;
    this.domImg.style.width = szWidth + 'px';
    this.domImg.style.height = szHeight + 'px';
    this.domImg.src = this.kaMap.aPixel.src;
    this.domObj.appendChild( this.domImg );
    */
    
    //prototypes
    this.update = kaScalebar_update;
    
    this.kaMap.registerForEvent( KAMAP_SCALE_CHANGED, this, this.update );
    this.kaMap.registerForEvent( KAMAP_MAP_INITIALIZED, this, this.update );
}

function kaScalebar_update()
{
    var scale = this.kaMap.getCurrentScale();
    this.domImg.src = this.kaMap.server + '/scalebar.php?map='+
                      this.kaMap.currentMap+'&scale='+scale;
}
