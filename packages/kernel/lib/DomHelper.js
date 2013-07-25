
xo.DomHelper = xo.DomHelper || {};

xo.DomHelper.applyStyles = function(el, styles){
    if(styles){
        if(typeof styles == "string"){
            var re = /\s?([a-z\-]*)\:\s?([^;]*);?/gi;
            var matches;
            while ((matches = re.exec(styles)) != null){
                xo.Dom.setStyle(el,matches[1], matches[2]);
            }
        }else if (typeof styles == "object"){
            for (var style in styles){
                xo.Dom.setStyle(el,style, styles[style]);
            }
        }else if (typeof styles == "function"){
            xo.DomHelper.applyStyles(el, styles.call());
        }
    }
}

xo.DomHelper.createDom = function(o, parentNode){
    var el;
    if (xo.isArray(o)) {                       // Allow Arrays of siblings to be inserted
	el = document.createDocumentFragment(); // in one shot using a DocumentFragment
	for(var i = 0, l = o.length; i < l; i++) {
	    xo.DomHelper.createDom(o[i], el);
	}
    } else if (typeof o == "string") {         // Allow a string as a child spec.
	el = document.createTextNode(o);
    } else {
	el = document.createElement(o['tag']||'div');
	var useSet = !!el.setAttribute; // In IE some elements don't have setAttribute
	for(var attr in o){
	    if(attr == "tag" || attr == "children" || attr == "cn" || attr == "html" || attr == "style" || typeof o[attr] == "function") continue;
	    if(attr=="cls"){
		el.className = o["cls"];
	    }else{
		if(useSet) el.setAttribute(attr, o[attr]);
		else el[attr] = o[attr];
	    }
	}
	xo.DomHelper.applyStyles(el, o['style']);
	var cn = o['children'] || o['cn'];
	if(cn){
	    xo.DomHelper.createDom(cn, el);
	} else if(o['html']){
	    el.innerHTML = o['html'];
	}
    }
    if(parentNode){
	parentNode.appendChild(el);
    }
    return el;
};

xo.DomHelper.insertBefore = function(el,o,returnElement) {
    return xo.DomHelper.doInsert_(el,o,returnElement,"beforeBegin");
};

xo.DomHelper.doInsert_ = function(el,o,returnElement,pos,sibling) {
    el = xo.getDom(el);
    var newNode = xo.DomHelper.createDom(o,null);
    (sibling === "firstchild" ? el : el.parentNode).insertBefore(newNode,sibling ? el[sibling] : el);
    return returnElement ? xo.get(newNode,true) : newNode;
};


xo.DomHelper.insertAfter = function(el, o, returnElement){
    return xo.DomHelper.doInsert_(el, o, returnElement, "afterEnd", "nextSibling");
};

xo.DomHelper.insertFirst = function(el, o, returnElement){
    return xo.DomHelper.doInsert_(el, o, returnElement, "afterBegin", "firstChild");
};

xo.DomHelper.moveAfter = function(el,o) {
    el.parentNode.insertBefore(o,el.nextSibling);
    return o;
};

xo.DomHelper.moveLast = function(el,o) {
    el.insertBefore(o,el.lastChild.nextSibling);
};

xo.DomHelper.remove = function(el) {
    el.parentNode.removeChild(el);
};

xo.DomHelper.hasClass = function(el,className) {
    return className && (' '+el.className+' ').indexOf(' '+className+' ') != -1;
};

xo.DomHelper.addClass = function(el,className){
    if(!el || !className){
	return;
    }
    if(xo.isArray(className)){
	for(var i = 0, len = className.length; i < len; i++) {
	    xo.DomHelper.addClass(el,className[i]);
	}
    }else{
	if(className && !xo.DomHelper.hasClass(el,className)){
	    el.className = el.className + " " + className;
	}
    }
};

xo.DomHelper.removeClass = function(el,className){
    if(!el || !className || !el.className){
	return;
    }
    if(xo.isArray(className)){
	for(var i = 0, len = className.length; i < len; i++) {
	    xo.DomHelper.removeClass(el,className[i]);
	}
    }else{
	if(xo.DomHelper.hasClass(el,className)){
	    if (!el.classReCache) {
		el.classReCache = {};
	    }
	    var re = el.classReCache[className];
	    if (!re) {
		re = new RegExp('(?:^|\\s+)' + className + '(?:\\s+|$)', "g");
		el.classReCache[className] = re;
	    }
	    el.className = el.className.replace(re, " ");
	}
    }
};


DH = xo.DomHelper;