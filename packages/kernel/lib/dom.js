xo.Dom = {}

// regex cache
var patterns = {
    camelRe: /(-[a-z])/gi
};

/*
  xo.Dom.getXY = function (el) {
  if (!el) {
  xo.log("getXY: undefined el");
  return;
  }
  var curleft = curtop = 0;
  if (el.offsetParent) {
  curleft = el.offsetLeft
  curtop = el.offsetTop
  while (el = el.offsetParent) {
  curleft += el.offsetLeft
  curtop += el.offsetTop
  }
  }
  return [curleft,curtop];
  }
*/

var camelReplaceFn = function(m, a) {
    return a.charAt(1).toUpperCase();
}

var toCamel = function(property) {
    
    if (propertyCache[property]) { // already converted
        return propertyCache[property];
    }
    
    property = property.replace(patterns.camelRe, camelReplaceFn);
    
    propertyCache[property] = property;
    return property;
    //return property.replace(/-([a-z])/gi, function(m0, m1) {return m1.toUpperCase()}) // cant use function as 2nd arg yet due to safari bug
};

   // branching at load instead of runtime
    if (document.defaultView && document.defaultView.getComputedStyle) { // W3C DOM method
        xo.Dom.getStyle = function(el, property) {
            var value = null;
            
            var computed = document.defaultView.getComputedStyle(el, '');
            if (computed) { // test computed before touching for safari
                value = computed[toCamel(property)];
            }
            
            return el.style[property] || value;
        };
    } else if (document.documentElement.currentStyle && xo.isIE) { // IE method
        xo.Dom.getStyle = function(el, property) {                         
            switch( toCamel(property) ) {
                case 'opacity' :// IE opacity uses filter
                    var val = 100;
                    try { // will error if no DXImageTransform
                        val = el.filters['DXImageTransform.Microsoft.Alpha'].opacity;

                    } catch(e) {
                        try { // make sure its in the document
                            val = el.filters('alpha').opacity;
                        } catch(e) {
                            // xo.log('getStyle: IE filter failed');
                        }
                    }
                    return val / 100;
                    break;
                default: 
                    // test currentStyle before touching
                    var value = el.currentStyle ? el.currentStyle[property] : null;
                    return ( el.style[property] || value );
            }
        };
    } else { // default to inline only
        xo.Dom.getStyle = function(el, property) { return el.style[property]; };
    }



xo.Dom.getScroll = function() {
    var dd = document.documentElement, db = document.body;
    if (dd && (dd["scrollTop"] || dd["scrollLeft"])) {
	// xo.log("scrollTop:" + dd.scrollTop);
	// xo.log("scrollLeft:" + dd.scrollLeft);
        return [dd["scrollTop"], dd["scrollLeft"]];
    } else if (db) {
        return [db["scrollTop"], db["scrollLeft"]];
    } else {
        return [0, 0];
    }
}

    
xo.Dom.getXY = function(el) {
    var p, pe, b, scroll, bd = (document.body || document.documentElement);
    el = xo.getDom(el);

    if(el == bd){
        return [0, 0];
    }

    if (el.getBoundingClientRect) {
        b = el.getBoundingClientRect();
        scroll = xo.Dom.getScroll();
	// scroll[1] is left
	// scroll[0] is top
        return [b["left"] + scroll[1], b["top"] + scroll[0]];
    }
    var x = 0, y = 0;

    p = el;

    var hasAbsolute = xo.Dom.getStyle(el,"position") == "absolute";
    
    while (p) {
        
        x += p.offsetLeft;
        y += p.offsetTop;
        
        if (!hasAbsolute &&  xo.Dom.getStyle(el,"position") == "absolute") {
            hasAbsolute = true;
        }
        
        if (xo.isGecko) {
            
            var bt = parseInt(xo.Dom.getStyle(p,"borderTopWidth"), 10) || 0;
            var bl = parseInt(xo.Dom.getStyle(p,"borderLeftWidth"), 10) || 0;
            
            
            x += bl;
            y += bt;
            
            
            if (p != el && xo.Dom.getStyle(p,'overflow') != 'visible') {
                x += bl;
                y += bt;
            }
        }
        p = p.offsetParent;
    }
    
    if (xo.isSafari && hasAbsolute) {
        x -= bd.offsetLeft;
        y -= bd.offsetTop;
    }
    
    if (xo.isGecko && !hasAbsolute) {
        x += parseInt(xo.Dom.getStyle(bd,"borderLeftWidth"), 10) || 0;
        y += parseInt(xo.Dom.getStyle(bd,"borderTopWidth"), 10) || 0;
    }
    
    p = el.parentNode;
    while (p && p != bd) {
        if (!xo.isOpera || (p.tagName != 'TR' && xo.Dom.getStyle(bd,"display") != "inline")) {
            x -= p.scrollLeft;
            y -= p.scrollTop;
        }
        p = p.parentNode;
    }
    return [x, y];
};


xo.Dom.setStyle = function(el, property, val) {
    el.style[property] = val;
};

if (xo.isIE) {
    xo.Dom.setStyle = function(el, property, val) {
        switch (property) {
        case 'opacity':
            if ( typeof el.style.filter == 'string' ) { // in case not appended
                el.style.filter = 'alpha(opacity=' + val * 100 + ')';
                
                if (!el.currentStyle || !el.currentStyle.hasLayout) {
                    el.style.zoom = 1; // when no layout or cant tell
                }
            }
            break;
        default:
            el.style[property] = val;
        }
    };
}
