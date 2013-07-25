xo.DomQuery = xo.DomQuery || {};

xo.DomQuery.byClassName = function(c, a, v){
console.log("c="+c+" a="+a+" v="+v);
    if(!v){
	return c;
    }
    var r = [], ri = -1, cn;
    for(var i = 0, ci; ci = c[i]; i++){
	if(ci.className.split(' ').indexOf(v) != -1){
	    r[++ri] = ci;
	}
    }
    return r;
};

xo.DomQuery.next = function(n){
    while((n = n.nextSibling) && n.nodeType != 1);
    return n;
};

xo.DomQuery.prev = function(n){
    while((n = n.previousSibling) && n.nodeType != 1);
    return n;
};


/////

xo.DomQuery.byTag = function(cs, tagName){
    if(cs.tagName || cs == document){
	cs = [cs];
    }
    if(!tagName){
	return cs;
    }
    var r = [], ri = -1;
    tagName = tagName.toLowerCase();
    for(var i = 0, ci; ci = cs[i]; i++){
	if(ci.nodeType == 1 && ci.tagName.toLowerCase()==tagName){
	    r[++ri] = ci;
	}
    }
    return r;
};

xo.DomQuery.byId = function(cs, attr, id){
    if(cs.tagName || cs == document){
	cs = [cs];
    }
    if(!id){
	return cs;
    }
    var r = [], ri = -1;
    for(var i = 0,ci; ci = cs[i]; i++){
	if(ci && ci.id == id){
	    r[++ri] = ci;
	    return r;
	}
    }
    return r;
};

xo.DomQuery.byAttribute = function(cs, attr, value, op, custom){
    var r = [], ri = -1, st = custom=="{";
    var f = xo.DomQuery.operators[op];
    for(var i = 0, ci; ci = cs[i]; i++){
	var a;
	if(st){
	    // HERE: a = xo.DomQuery.getStyle(ci, attr);
	}
	else if(attr == "class" || attr == "className"){
	    a = ci.className;
	}else if(attr == "for"){
	    a = ci.htmlFor;
	}else if(attr == "href"){
	    a = ci.getAttribute("href", 2);
	}else{
	    a = ci.getAttribute(attr);
	}
	if((f && f(a, value)) || (!f && a)){
	    r[++ri] = ci;
	}
    }
    return r;
};

xo.DomQuery.byPseudo = function(cs, name, value){
    // HERE: return xo.DomQuery.pseudos[name](cs, value);
};

xo.DomQuery.getNodes = function(ns, mode, tagName){
    var result = [], ri = -1, cs;
    if(!ns){
	return result;
    }
    tagName = tagName || "*";
    if(typeof ns.getElementsByTagName != "undefined"){
	ns = [ns];
    }
    if(!mode){
	for(var i = 0, ni; ni = ns[i]; i++){
	    cs = ni.getElementsByTagName(tagName);
	    for(var j = 0, ci; ci = cs[j]; j++){
		result[++ri] = ci;
	    }
	}
    }else if(mode == "/" || mode == ">"){
	var utag = tagName.toUpperCase();
	for(var i = 0, ni, cn; ni = ns[i]; i++){
	    cn = ni.children || ni.childNodes;
	    for(var j = 0, cj; cj = cn[j]; j++){
		if(cj.nodeName == utag || cj.nodeName == tagName  || tagName == '*'){
		    result[++ri] = cj;
		}
	    }
	}
    }else if(mode == "+"){
	var utag = tagName.toUpperCase();
	for(var i = 0, n; n = ns[i]; i++){
	    while((n = n.nextSibling) && n.nodeType != 1);
	    if(n && (n.nodeName == utag || n.nodeName == tagName || tagName == '*')){
		result[++ri] = n;
	    }
	}
    }else if(mode == "~"){
	for(var i = 0, n; n = ns[i]; i++){
	    while((n = n.nextSibling) && (n.nodeType != 1 || (tagName == '*' || n.tagName.toLowerCase()!=tagName)));
	    if(n){
		result[++ri] = n;
	    }
	}
    }
    return result;
};

DQ = xo.DomQuery;
