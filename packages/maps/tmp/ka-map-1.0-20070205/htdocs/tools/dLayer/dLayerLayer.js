/**********************************************************************
 * $Id: dLayerLayer.js,v 1.1 2007/01/26 14:26:26 lbecchi Exp $
 * 
 *
 * purpose: tool to create layers on the fly (bug 1646)
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
function dLayerLayer(sessionid,id) {
//szName, bVisible, opacity, imageformat, bQueryable,layers,id
	this.sessionid = sessionid;
  this.id=id;
    _layer.apply(this,[{name:'dLayer',visible:true,opacity:100,imageformat:'PNG',queryable:true}]);
 
 for (var p in _layer.prototype) {
        if (!dLayerLayer.prototype[p])
            dLayerLayer.prototype[p]= _layer.prototype[p];
    }
 };


 dLayerLayer.prototype.setTile = function(img) {
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
	 "/tools/dLayer/dTile.php" +
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
