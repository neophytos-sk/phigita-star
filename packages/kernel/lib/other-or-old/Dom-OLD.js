xo.Dom.getViewWidth = function(full) {
    return full ? this.getDocumentWidth() : this.getViewportWidth();
};

xo.Dom.getViewHeight = function(full) {
    return full ? this.getDocumentHeight() : this.getViewportHeight();
};

xo.Dom.getDocumentHeight = function() {
    var scrollHeight = (document.compatMode != "CSS1Compat") ? document.body.scrollHeight : document.documentElement.scrollHeight;
    return Math.max(scrollHeight, this.getViewportHeight());
};

xo.Dom.getDocumentWidth: function() {
    var scrollWidth = (document.compatMode != "CSS1Compat") ? document.body.scrollWidth : document.documentElement.scrollWidth;
    return Math.max(scrollWidth, this.getViewportWidth());
};

xo.Dom.getViewportHeight = function(){
    if(xo.isIE){
	return xo.isStrict ? document.documentElement.clientHeight :
	document.body.clientHeight;
    }else{
	return self.innerHeight;
    }
};

xo.Dom.getViewportWidth = function() {
    if(xo.isIE){
	return xo.isStrict ? document.documentElement.clientWidth :
	document.body.clientWidth;
    }else{
	return self.innerWidth;
    }
};

xo.Dom.isAncestor = function(p, c) {
    p = xo.getDom(p);
    c = xo.getDom(c);
    if (!p || !c) {
	return false;
    }
    
    if (p.contains && !xo.isSafari) {
	return p.contains(c);
    } else if (p.compareDocumentPosition) {
	return !!(p.compareDocumentPosition(c) & 16);
    } else {
	var parent = c.parentNode;
	while (parent) {
	    if (parent == p) {
		return true;
	    }
	    else if (!parent.tagName || parent.tagName.toUpperCase() == "HTML") {
		return false;
	    }
	    parent = parent.parentNode;
	}
	return false;
    }
};



var view = document.defaultView;
xo.Dom.getStyle = function(){
    return view && view.getComputedStyle ?
    function(dom,prop) {
	var el = dom, v, cs, camel;
	if(prop == 'float'){
	    prop = "cssFloat";
	}
	if(v = el.style[prop]){
	    return v;
	}
	if(cs = view.getComputedStyle(el, "")){
	    if(!(camel = propCache[prop])){
		camel = propCache[prop] = prop.replace(camelRe, camelFn);
	    }
	    return cs[camel];
	}
	return null;
    } :
    function(dom,prop) {
	var el = dom, v, cs, camel;
	if(prop == 'opacity'){
	    if(typeof el.style.filter == 'string'){
		var m = el.style.filter.match(/alpha\(opacity=(.*)\)/i);
		if(m){
		    var fv = parseFloat(m[1]);
		    if(!isNaN(fv)){
			return fv ? fv / 100 : 0;
		    }
		}
	    }
	    return 1;
	}else if(prop == 'float'){
	    prop = "styleFloat";
	}
	if(!(camel = propCache[prop])){
	    camel = propCache[prop] = prop.replace(camelRe, camelFn);
	}
	if(v = el.style[camel]){
	    return v;
	}
	if(cs = el.currentStyle){
	    return cs[camel];
	}
	return null;
    };
}();


xo.Dom.getScroll = function() {
    var dd = document.documentElement, db = document.body;
    if (dd && (dd.scrollTop || dd.scrollLeft)) {
	return [dd.scrollTop, dd.scrollLeft];
    } else if (db) {
	return [db.scrollTop, db.scrollLeft];
    } else {
	return [0, 0];
    }
};


xo.Dom.getRegion = function(el) {
    // return Region.getRegion(el);
};

xo.Dom.getY = function(el) {
    return this.getXY(el)[1];
};

xo.Dom.getX = function(el) {
    return this.getXY(el)[0];
};


xo.Dom.getXY = function(el) {
    var p, pe, b, scroll, bd = (document.body || document.documentElement);
    el = xo.getDom(el);
    
    if(el == bd){
	return [0, 0];
    }
    
    if (el.getBoundingClientRect) {
	b = el.getBoundingClientRect();
	scroll = xo.Dom.getScroll();
	return [b.left + scroll.left, b.top + scroll.top];
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

xo.Dom.translatePoints = function(dom, x, y){
    if(typeof x == 'object' || xo.isArray(x)){
	y = x[1]; x = x[0];
    }
    var p = xo.Dom.getStyle('position');
    var o = xo.Dom.getXY();

    var l = parseInt(xo.Dom.getStyle('left'), 10);
    var t = parseInt(xo.Dom.getStyle('top'), 10);

    if(isNaN(l)){
	l = (p == "relative") ? 0 : dom.offsetLeft;
    }
    if(isNaN(t)){
	t = (p == "relative") ? 0 : dom.offsetTop;
    }

    return {left: (x - o[0] + l), top: (y - o[1] + t)};
};


xo.Dom.setXY : function(el, xy) {
    // el = fly(el, '_setXY');
    // TODO: 
    // * initialize positioning of this element
    // * make the element positioned relative if
    //   it is not already positioned
    // el.position();

    var pts = xo.Dom.translatePoints(el,xy);
    if (xy[0] !== false) {
	el.dom.style.left = pts.left + "px";
    }
    if (xy[1] !== false) {
	el.dom.style.top = pts.top + "px";
    }
};

    
xo.Dom.setX : function(el, x) {
    this.setXY(el, [x, false]);
};

xo.Dom.setY : function(el, y) {
    this.setXY(el, [false, y]);
};
