/**********************************************************************
 * $Id: routingLayer.js,v 1.1 2007/01/25 08:28:41 lbecchi Exp $
 * 
 *
 * purpose: build a generalized routingLayer class , kaRouting module (Bug 1643)
 *         
 *
 * author:  Andrea Cappugi & Lorenzo Becchi (ominiverdi.org)
 *
 * TODO:
 *   - all
 * 
 **********************************************************************
 *
 * Copyright (c)  2006, ominiverdi.org
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
 *  
 * 
 *
 *****************************************************************************/
function routingLayer(sessionid,id) {
//szName, bVisible, opacity, imageformat, bQueryable,layers,id
	this.sessionid = sessionid;
  this.id=id;
    _layer.apply(this,[{name:'sugoi!',visible:true,opacity:100,imageformat:'PNG',queryable:false}]);
 
 for (var p in _layer.prototype) {
        if (!routingLayer.prototype[p])
            routingLayer.prototype[p]= _layer.prototype[p];
    }
 };


 routingLayer.prototype.setTile = function(img) {
    var l = safeParseInt(img.style.left) + this._map.kaMap.xOrigin;
    var t = safeParseInt(img.style.top) + this._map.kaMap.yOrigin;
    // dynamic imageformat
    var szImageformat = '';
    var image_format = '';
    if (this.imageformat && this.imageformat != '') {
        image_format = this.imageformat;
        szImageformat = '&i='+image_format;
    }
	     
	        
	        
	szForce = '&force=true';
	  
	 var szScale = '&s='+this._map.aScales[this._map.currentScale];
	 var q = '?';
	 if (this._map.kaMap.tileURL.indexOf('?') != -1) {
	       if (this._map.kaMap.tileURL.slice(-1) != '&') {
	                q = '&';
	      } else {
	                q = '';
	       }
	    }
	        
	 var src = this._map.kaMap.server +
	 "/tools/kaRouting/tile_router.php" +
	 q + 'map=' + this._map.name +
	'&t=' + t +
	'&l=' + l +
   szScale + szImageformat+'&id='+this.id;
//	szScale + szForce +  szImageformat;
	        
	    
    if (img.src != src) {
        img.style.visibility = 'hidden';
        img.src = src+"&sessionid="+this.sessionid;
       }
};
