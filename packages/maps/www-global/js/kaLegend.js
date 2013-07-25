/******************************************************************************
 * kaLegend - a structured legend that supports grouped layers, visibility, 
 *            expand/collapse, and queryability
 *
 * copyright DM Solutions Group Inc.
 *
 * $Id: kaLegend.js,v 1.13 2005/11/29 20:05:36 pspencer Exp $
 *
 ******************************************************************************
 *
 * To use kaLegend:
 * 
 * 1) add a script tag to your page:
 * 
 * <script type="text/javascript" src="kaLegend.js"></script>
 *
 * 2) add a <div> element to your page to contain the legend.  The div must
 *    have a unique id:
 *
 * <div id="legend"></div>
 * 
 * 3) create a new instance of kaLegend and pass it the id of the div:
 * 
 * myKaLegend = new kaLegend( 'legend' );
 *
 * and that's it :)
 *
 * NOTE: if you use "static" legends, you need to use an <img> object with an
 * id in your page instead of a div.
 *
 * TODO:
 *
 * - drag and drop layer re-ordering would be nice, see script.alicio.us
 * 
 *****************************************************************************/

/******************************************************************************
 * kaLegend
 * 
 * internal class to handle the legend.
 * 
 * oKaMap - the ka-Map object to attach to.
 * szID - string, the id of a div that will contain the legend
 * bStatic - boolean, true to use static legends, false to use dynamic legends
 *
 *****************************************************************************/
function kaLegend(oKaMap, szID, bStatic)
{
    this.kaMap = oKaMap;
    this.domObj = this.kaMap.getRawObject(szID);
    this.type = (bStatic)?'static':'dynamic';
    this.expanders = [];
    this.queryCBs = [];
    
    this.urlBase = this.kaMap.server;
    this.urlBase += (this.urlBase!=''&&this.urlBase.substring(-1)!='/')?'':'/';

    
    this.showQueryCBs = true;    
    
    if (this.type == 'static')
    {
        this.domObj.src = this.kaMap.aPixel.src;
    }
    else
    {
        this.domObj.innerHTML = '&nbsp;';
    }
    
    this.kaMap.registerForEvent( KAMAP_SCALE_CHANGED, this, this.update );
    this.kaMap.registerForEvent( KAMAP_MAP_INITIALIZED, this, this.update );
    this.kaMap.registerForEvent( KAMAP_LAYERS_CHANGED, this, this.draw );
}
    
kaLegend.prototype.update = function(eventID)
{
    var url = '';
    if (this.type == 'static')
    {
        this.domObj.src = 'legend.php?map=' + 
                          this.kaMap.currentMap + 
                          '&scale='+this.kaMap.getCurrentScale();
    }
    else
    {
        if (eventID == KAMAP_MAP_INITIALIZED)
        {
            while(this.domObj.childNodes.length > 0)
                this.domObj.removeChild(this.domObj.childNodes[0]);
            this.draw();
        }
        else if (eventID == KAMAP_SCALE_CHANGED)
        {
            var oMap = this.kaMap.getCurrentMap();
            var aLayers = oMap.getLayers();
            var s = this.kaMap.getCurrentScale();
            for (var i in aLayers)
            {
                var oLayer = aLayers[i];
                var oImg = this.kaMap.getRawObject( 'legendImg_' + oLayer.name);
                if (oImg)
                {
                    oImg.src = 'legend.php?map=' + 
                               this.kaMap.currentMap + '&scale=' + s + '&g=' + 
                               oLayer.name;
                }
            }
        }
    }
}

/**
 * legend.draw( szContents )
 *
 * render the contents of a legend template into a div
 */
kaLegend.prototype.draw = function()
{
    var oMap = this.kaMap.getCurrentMap();
    
    this.expanders = [];
    this.queryCBs = [];
    
    if (this.domObj.childNodes.length == 0)
        this.domObj.appendChild(this.createHeaderHTML());
    
    var aLayers = oMap.getLayers();
    for (var i=0;i<aLayers.length;i++)
    {
        if (aLayers[i].kaLegendObj == null)
        {
            this.createLayerHTML( aLayers[i] );
        }
        else
        {
            this.domObj.removeChild( aLayers[i].kaLegendObj );
        }
    }
    
    for (var i = 0; i<aLayers.length; i++)
    {
        this.domObj.appendChild( aLayers[i].kaLegendObj );
    }
    
    if (this.kaMap.isIE4)
    {
        for(var i=0; i<this.queryCBs.length; i++)
        {
            this.queryCBs[i].checked = this.queryCBs[i].oLayer.visible;
        }
    }
    return;
}

kaLegend.prototype.createHeaderHTML = function()
{
    var d, t, tb, tr, td, img;
    
    d = document.createElement( 'div' );
    d.className = 'kaLegendTitle';
    
    t = document.createElement( 'table' );
    
    t.setAttribute('width','100%');
    t.setAttribute('cellPadding', "0");
    t.setAttribute('cellSpacing', "0");
    t.setAttribute('border', "0");
    
    tb = document.createElement( "tbody" );
    
    tr = document.createElement( 'tr' );
    td = document.createElement( 'td' );
    td.appendChild(document.createTextNode( 'Layers' ));
    tr.appendChild( td );
    
    td = document.createElement( 'td' );
    td.align = 'right';
    img = document.createElement( 'img' );
    img.src = 'images/expand.png';
    img.alt = 'expand all';
    img.title = 'expand all';
    img.kaLegend = this;
    img.onclick = kaLegend_expandAll;
    td.appendChild( img );
    
    img = document.createElement( 'img' );
    img.src = 'images/collapse.png';
    img.alt = 'collapse all';
    img.title = 'collapse all';
    img.kaLegend = this;
    img.onclick = kaLegend_collapseAll;
    td.appendChild( img );
    
    tr.appendChild( td );
    tb.appendChild(tr);
    t.appendChild(tb);
    d.appendChild(t);
    return d;
}

kaLegend.prototype.createLayerHTML = function( oLayer )
{
    var d, t, tb, tr, td, expander, cb, img, name;
    
    d = document.createElement( 'div' );
    d.id = 'group_' + oLayer.name;
    d.className = "kaLegendLayer";
    
    name = oLayer.name;
    if (name == '__base__')
    {
        name = 'Base';
    }
    
    t = document.createElement('table');
    t.setAttribute('width','100%');
    t.setAttribute('cellPadding', "0");
    t.setAttribute('cellSpacing', "0");
    t.setAttribute('border', "0");

    tb = document.createElement( 'tbody' );
    tr = document.createElement('tr');
    td = document.createElement('td');
    td.setAttribute( "width", "9");
    
    expander = document.createElement( 'img' );
    expander.src = 'images/collapse.png';
    expander.layerName = oLayer.name;
    expander.id = 'expander_'+oLayer.name;
    expander.onclick = kaLegend_expander;
    expander.expanded = true;
    
    this.expanders.push( expander );
    
    td.appendChild( expander );
    
    tr.appendChild(td);
    
    // layer visibility checkboxes
    // TODO: convert to images
    td = document.createElement('td');
    td.width = '22';
    if (oLayer.name != '__base__')
    {
        cb = document.createElement( 'input' );
        cb.type = 'checkbox';
        cb.name = 'layerVisCB';
        cb.value = oLayer.name;
        cb.checked = oLayer.visible;
        cb.kaLegend = this;
        cb.oLayer = oLayer;
        cb.onclick = kaLegend_toggleLayerVisibility;
        this.queryCBs.push(cb);
        td.appendChild( cb );
    }
    else
    {
        td.innerHTML = '&nbsp;';
    }
    tr.appendChild(td);
    
    //layer queryable images
    td = document.createElement('td');
    td.width = '14';
    
    img = document.createElement( 'img' );
    img.width = '14';
    img.height = '14';
    
    if (oLayer.queryable)
    {
        if (oLayer.isQueryable())
        {
            img.src = 'images/icon_query_on.png';
        }
        else
        {
            img.src = 'images/icon_query_off.png';
        }
        img.onmouseover = kaLegend_queryOnMouseOver;
        img.onmouseout = kaLegend_queryOnMouseOut;
        img.onclick = kaLegend_queryOnClick;
        img.oLayer = oLayer;
    }
    else
    {
        img.src = 'images/icon_query_x.png';
    }
    
    td.appendChild( img );
    tr.appendChild(td);
    
    td = document.createElement( 'td' );
    td.innerHTML = name;
    tr.appendChild(td);
    tb.appendChild(tr);
    t.appendChild( tb );
    d.appendChild(t);
    
    img = document.createElement( 'img' );
    img.id = 'legendImg_' + oLayer.name;
    img.src = this.urlBase +  'legend.php?map='+this.kaMap.currentMap+'&scale='+this.kaMap.getCurrentScale()+'&g='+oLayer.name;
    
    expander.expandable = img;
    oLayer.kaLegendObj = d;
}

function kaLegend_toggleLayerQueryable()
{
    this.kaLegend.kaMap.setLayerQueryable( this.value, this.checked );
}

function kaLegend_queryOnMouseOver()
{
    if (this.oLayer.queryable)
    {
        this.src = 'images/icon_query_over.png';
    }
}

function kaLegend_queryOnMouseOut()
{
    if (this.oLayer.queryable)
    {
        if (this.oLayer.isQueryable())
        {
            this.src = 'images/icon_query_on.png';
        }
        else
        {
            this.src = 'images/icon_query_off.png';
        }
    }
}

function kaLegend_queryOnClick()
{
    if (this.oLayer.queryable)
    {
        if (this.oLayer.isQueryable())
        {
            this.oLayer.setQueryable( false );
            this.src = 'images/icon_query_off.png';
       }
        else
        {
            this.oLayer.setQueryable( true );
            this.src = 'images/icon_query_on.png';
        }
    }
}

function kaLegend_toggleLayerVisibility()
{
    
    this.kaLegend.kaMap.setLayerVisibility( this.value, this.checked );
}

function kaLegend_expander()
{
    this.expanded = !this.expanded;
    
    this.src = (this.expanded)?'images/collapse.png':'images/expand.png';
    this.expandable.style.display = (this.expanded)?'block':'none';
}

function kaLegend_expandAll()
{
    var kaLeg = this.kaLegend;
    for (var i=0; i<kaLeg.expanders.length; i++)
    {
        kaLeg.expanders[i].expanded = false;
        kaLegend_expander.apply( kaLeg.expanders[i] );
    }
}

function kaLegend_collapseAll()
{
    var kaLeg = this.kaLegend;
    for (var i=0; i<kaLeg.expanders.length; i++)
    {
        kaLeg.expanders[i].expanded = true;
        kaLegend_expander.apply( kaLeg.expanders[i] );
    }
}
