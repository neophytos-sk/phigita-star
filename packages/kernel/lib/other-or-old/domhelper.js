//DOM Helper
DH = {};

DH.add = function(pn,tag,attributes) {
  var cn = DH.create(tag);
  pn.appendChild(cn);
  for (i in attributes) {
    cn.setAttribute(i,attributes[i]);
  }
  return cn;
};

DH.create = function(tag) {
  return document.createElement(tag);
};



// build as dom
/** @ignore */
var createDom = function(o, parentNode){
    var el;
    if (xo.isArray(o)) {                       // Allow Arrays of siblings to be inserted
	el = document.createDocumentFragment(); // in one shot using a DocumentFragment
	for(var i = 0, l = o.length; i < l; i++) {
	    createDom(o[i], el);
	}
    } else if (typeof o == "string") {         // Allow a string as a child spec.
	el = document.createTextNode(o);
    } else {
	el = document.createElement(o.tag||'div');
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
	//xo.DomHelper.applyStyles(el, o.style);
	var cn = o.children || o.cn;
	if(cn){
	    createDom(cn, el);
	} else if(o.html){
	    el.innerHTML = o.html;
	}
    }
    if(parentNode){
	parentNode.appendChild(el);
    }
    return el;
};
