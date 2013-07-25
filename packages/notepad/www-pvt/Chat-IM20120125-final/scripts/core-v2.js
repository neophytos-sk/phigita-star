var xo = xo || {};
xo.global = this;
xo.debug = true; /* make it false before deployment - code optimization */
xo.idseed = 0;
xo.cache = {};
xo.windowId = 'xo-window';
xo.documentId = 'xo-document';

xo.userAgent = navigator.userAgent.toLowerCase();
var check = function(regex){
    return regex.test(xo.userAgent);
};
docMode = document.documentMode,
    xo.isOpera = check(/opera/),
    xo.isOpera10_5 = xo.isOpera && check(/version\/10\.5/),
    xo.isChrome = check(/\bchrome\b/),
    xo.isWebKit = check(/webkit/),
    xo.isSafari = !xo.isChrome && check(/safari/),
    xo.isSafari2 = xo.isSafari && check(/applewebkit\/4/), // unique to Safari 2
    xo.isSafari3 = xo.isSafari && check(/version\/3/),
    xo.isSafari4 = xo.isSafari && check(/version\/4/),
    xo.isIE = !xo.isOpera && check(/msie/),
    xo.isIE7 = xo.isIE && (check(/msie 7/) || docMode == 7),
    xo.isIE8 = xo.isIE && (check(/msie 8/) && docMode != 7 && docMode != 9 || docMode == 8),
    xo.isIE9 = xo.isIE && (check(/msie 9/) && docMode != 7 && docMode != 8 || docMode == 9),
    xo.isIE6 = xo.isIE && check(/msie 6/),
    xo.isGecko = !xo.isWebKit && check(/gecko/),
    xo.isGecko3 = xo.isGecko && check(/rv:1\.9/),
    xo.isGecko4 = xo.isGecko && check(/rv:2\.0/),
    xo.isFF3_0 = xo.isGecko3 && check(/rv:1\.9\.0/),
    xo.isFF3_5 = xo.isGecko3 && check(/rv:1\.9\.1/),
    xo.isFF3_6 = xo.isGecko3 && check(/rv:1\.9\.2/),
    xo.isWindows = check(/windows|win32/),
    xo.isMac = check(/macintosh|mac os x/),
    xo.isLinux = check(/linux/),
    scrollbarSize = null,
    xo.webKitVersion = xo.isWebKit && (/webkit\/(\d+\.\d+)/.exec(xo.userAgent)),
xo.webKitVersion = xo.webKitVersion ? parseFloat(xo.webKitVersion[1]) : -1;

xo.isSecure = /^https/i.test(xo.global.location.protocol);
xo.isStrict = xo.global.document.compatMode === "CSS1Compat";



xo.isDef = function(val) {
  return val !== undefined;
};

/**
 * Returns true if the passed object is a JavaScript array, otherwise false.
 * @param {Object} The object to test
 * @return {Boolean}
 */
xo.isArray = function(v){
    return v && typeof v.length == 'number' && typeof v.splice == 'function';
};



/**
 * Builds an object structure for the provided namespace path,
 * ensuring that names that already exist are not overwritten. For
 * example:
 * "a.b.c" -> a = {};a.b={};a.b.c={};
 * Used by goog.provide and goog.exportSymbol.
 * @param {string} name name of the object that this file defines.
 * @param {Object} opt_object the object to expose at the end of the path.
 * @param {Object} opt_objectToExportTo The object to add the path to; default
 *     is |goog.global|.
 * @private
 */
xo.exportPath_ = function(name, opt_object, opt_objectToExportTo) {
  var parts = name.split('.');
  var cur = opt_objectToExportTo || xo.global;

  // Internet Explorer exhibits strange behavior when throwing errors from
  // methods externed in this manner.  See the testExportSymbolExceptions in
  // base_test.html for an example.
  if (!(parts[0] in cur) && cur.execScript) {
    cur.execScript('var ' + parts[0]);
  }

  // Certain browsers cannot parse code in the form for((a in b); c;);
  // This pattern is produced by the JSCompiler when it collapses the
  // statement above into the conditional loop below. To prevent this from
  // happening, use a for-loop and reserve the init logic as below.

  // Parentheses added to eliminate strict JS warning in Firefox.
  for (var part; parts.length && (part = parts.shift());) {
    if (!parts.length && xo.isDef(opt_object)) {
      // last part and we have an object; use it
      cur[part] = opt_object;
    } else if (cur[part]) {
      cur = cur[part];
    } else {
      cur = cur[part] = {};
    }
  }
};

xo.exportSymbol = function(publicPath, object, opt_objectToExportTo) {
    xo.exportPath_(publicPath, object, opt_objectToExportTo);
};

xo.exportProperty = function(object, publicName, symbol) {
  object[publicName] = symbol;
};

xo.emptyFn = function(){};

xo.getDom = function(el){
    if(!el || !document){
	return null;
    }
    return el.dom ? el.dom : (typeof el == 'string' ? document.getElementById(el) : el);
};

xo.decode = function(json){
    return eval("(" + json + ')');
};


xo.apply = function(object, config, defaults) {
    if (defaults) {
	xo.apply(object, defaults);
    }
    if (object && config && typeof config === 'object') {
	var i, j, k;

	for (i in config) {
	    object[i] = config[i];
	}
    }
    return object;
};

xo.applyIf = function(object, config) {
    var property;

    if (object) {
	for (property in config) {
	    if (object[property] === undefined) {
		object[property] = config[property];
	    }
	}
    }

    return object;
};

if (xo.debug) {
    xo.log = function(o) {
	if (window.console && o) {
	    window.console.log(o);
	}
    };

    xo.error = function(o) {
	if (o && o.msg) {
	    xo.log(o.msg);
	}
    };
} else {
    xo.log = xo.emptyFn;
    xo.error = xo.emptyFn;
}

xo.id = function(el, prefix) {
    var me = this;
    el = xo.getDom(el, true) || {};
    if (el === document) {
	el.id = me.documentId;
    }
    else if (el === window) {
	el.id = me.windowId;
    }
    if (!el.id) {
	el.id = (prefix || "xo-gen") + (++xo.idSeed);
    }
    return el.id;
};

xo.get = function(el) {
    // TODO - see Ext.Element.get
    return el;
};


xo.Event = {
    BACKSPACE:8,
    TAB: 9,
    ENTER:13,
    SHIFT:16,
    CTRL:17,
    ALT:18,
    CAPS_LOCK:20,
    ESC:27,
    SPACE:32,
    PAGE_UP:33,
    PAGE_DOWN:34,
    END:35,
    HOME:36,
    LEFT:37,
    UP:38,
    RIGHT:39,
    DOWN:40,
    INSERT:45,
    DELETE:46,
    /** Key constant @type Number */
    ZERO: 48,
    /** Key constant @type Number */
    ONE: 49,
    /** Key constant @type Number */
    TWO: 50,
    /** Key constant @type Number */
    THREE: 51,
    /** Key constant @type Number */
    FOUR: 52,
    /** Key constant @type Number */
    FIVE: 53,
    /** Key constant @type Number */
    SIX: 54,
    /** Key constant @type Number */
    SEVEN: 55,
    /** Key constant @type Number */
    EIGHT: 56,
    /** Key constant @type Number */
    NINE: 57,
    /** Key constant @type Number */
    A: 65,
    /** Key constant @type Number */
    B: 66,
    /** Key constant @type Number */
    C: 67,
    /** Key constant @type Number */
    D: 68,
    /** Key constant @type Number */
    E: 69,
    /** Key constant @type Number */
    F: 70,
    /** Key constant @type Number */
    G: 71,
    /** Key constant @type Number */
    H: 72,
    /** Key constant @type Number */
    I: 73,
    /** Key constant @type Number */
    J: 74,
    /** Key constant @type Number */
    K: 75,
    /** Key constant @type Number */
    L: 76,
    /** Key constant @type Number */
    M: 77,
    /** Key constant @type Number */
    N: 78,
    /** Key constant @type Number */
    O: 79,
    /** Key constant @type Number */
    P: 80,
    /** Key constant @type Number */
    Q: 81,
    /** Key constant @type Number */
    R: 82,
    /** Key constant @type Number */
    S: 83,
    /** Key constant @type Number */
    T: 84,
    /** Key constant @type Number */
    U: 85,
    /** Key constant @type Number */
    V: 86,
    /** Key constant @type Number */
    W: 87,
    /** Key constant @type Number */
    X: 88,
    /** Key constant @type Number */
    Y: 89,
    /** Key constant @type Number */
    Z: 90,
    /** Key constant @type Number */
    CONTEXT_MENU: 93,
    /** Key constant @type Number */
    NUM_ZERO: 96,
    /** Key constant @type Number */
    NUM_ONE: 97,
    /** Key constant @type Number */
    NUM_TWO: 98,
    /** Key constant @type Number */
    NUM_THREE: 99,
    /** Key constant @type Number */
    NUM_FOUR: 100,
    /** Key constant @type Number */
    NUM_FIVE: 101,
    /** Key constant @type Number */
    NUM_SIX: 102,
    /** Key constant @type Number */
    NUM_SEVEN: 103,
    /** Key constant @type Number */
    NUM_EIGHT: 104,
    /** Key constant @type Number */
    NUM_NINE: 105,
    /** Key constant @type Number */
    NUM_MULTIPLY: 106,
    /** Key constant @type Number */
    NUM_PLUS: 107,
    /** Key constant @type Number */
    NUM_MINUS: 109,
    /** Key constant @type Number */
    NUM_PERIOD: 110,
    /** Key constant @type Number */
    NUM_DIVISION: 111,
    /** Key constant @type Number */
    F1: 112,
    /** Key constant @type Number */
    F2: 113,
    /** Key constant @type Number */
    F3: 114,
    /** Key constant @type Number */
    F4: 115,
    /** Key constant @type Number */
    F5: 116,
    /** Key constant @type Number */
    F6: 117,
    /** Key constant @type Number */
    F7: 118,
    /** Key constant @type Number */
    F8: 119,
    /** Key constant @type Number */
    F9: 120,
    /** Key constant @type Number */
    F10: 121,
    /** Key constant @type Number */
    F11: 122,
    /** Key constant @type Number */
    F12: 123,
    NUM_EQUAL:61,

    listeners:[],
    unloadListeners:[],
    stopEvent : function(ev) {
	xo.Event.stopPropagation(ev);
	xo.Event.preventDefault(ev);
    },
    stopPropagation : function(ev) {
	ev = ev.browserEvent || ev;
	if (ev.stopPropagation) {
	    ev.stopPropagation();
	} else {
	    ev.cancelBubble = true;
	}
    },
    preventDefault : function(ev) {
	ev = ev.browserEvent || ev;
	if(ev.preventDefault) {
	    ev.preventDefault();
	} else {
	    ev.returnValue = false;
	}
    },

    addListener: function(element, eventName, fn, scope, options){

        var dom = xo.getDom(element),
            bind,
            wrap;

        //<debug>
        if (!dom){
            xo.error({
                sourceClass: 'xo.EventManager',
                sourceMethod: 'addListener',
                targetElement: element,
                eventName: eventName,
                msg: 'Error adding "' + eventName + '\" listener for nonexistent element "' + element + '"'
            });
        }
        if (!fn) {
            xo.error({
                sourceClass: 'xo.EventManager',
                sourceMethod: 'addListener',
                targetElement: element,
                eventName: eventName,
                msg: 'Error adding "' + eventName + '\" listener. The handler function is undefined.'
            });
        }
        //</debug>

        // create the wrapper function
        options = options || {};

        bind = xo.Event.normalizeEvent(eventName, fn);
        wrap = xo.Event.createListenerWrap(dom, eventName, bind.fn, scope, options);
	xo.Event.doAdd(dom, bind.eventName, wrap, options.capture || false);

    },

    /**
     * Normalize cross browser event differences
     * @private
     * @param {Object} eventName The event name
     * @param {Object} fn The function to execute
     * @return {Object} The new event name/function
     */
    normalizeEvent: function(eventName, fn){
        if (/mouseenter|mouseleave/.test(eventName) && !xo.supports.MouseEnterLeave) {
            if (fn) {
                // fn = xo.Function.createInterceptor(fn, this.contains, this);
            }
            eventName = eventName == 'mouseenter' ? 'mouseover' : 'mouseout';
        } else if (eventName == 'mousewheel' && !xo.supports.MouseWheel && !xo.isOpera){
            eventName = 'DOMMouseScroll';
        }
        return {
            eventName: eventName,
            fn: fn
        };
    },
    createListenerWrap : function(dom,eventName,fn,scope,options){
	options = options || {};

        var f, gen;

        return function wrap(e, args) {
	    fn.call(scope || dom, e, this, options);
	};
    },
    doAdd : function () {
	if (window.addEventListener) {
	    return function(el, eventName, fn, capture) {
		el.addEventListener(eventName, fn, (capture));
	    };
	} else if (window.attachEvent) {
	    return function(el, eventName, fn, capture) {
		el.attachEvent("on" + eventName, fn);
	    };
	} else {
	    return function() {
	    };
	}
    }()
};


xo.Event.on=xo.Event.addListener;

xo.DomHelper = xo.DomHelper || {};

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
	//xo.DomHelper.applyStyles(el, o.style);
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


xo.DomQuery = xo.DomQuery || {};

xo.DomQuery.byClassName = function(c, a, v){
    if(!v){
	return c;
    }
    var r = [], ri = -1, cn;
    for(var i = 0, ci; ci = c[i]; i++){
	if((' '+ci.className+' ').indexOf(v) != -1){
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

xo.isDate = function(v){
    return v && typeof v.getFullYear == 'function';
};


xo.util = {};

xo.util.JSON = new (function(){
    var useHasOwn = !!{}.hasOwnProperty;

    // crashes Safari in some instances
    //var validRE = /^("(\\.|[^"\\\n\r])*?"|[,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t])+?$/;

    var pad = function(n) {
        return n < 10 ? "0" + n : n;
    };

    var m = {
        "\b": '\\b',
        "\t": '\\t',
        "\n": '\\n',
        "\f": '\\f',
        "\r": '\\r',
        '"' : '\\"',
        "\\": '\\\\'
    };

    var encodeString = function(s){
        if (/["\\\x00-\x1f]/.test(s)) {
            return '"' + s.replace(/([\x00-\x1f\\"])/g, function(a, b) {
                var c = m[b];
                if(c){
                    return c;
                }
                c = b.charCodeAt();
                return "\\u00" +
                    Math.floor(c / 16).toString(16) +
                    (c % 16).toString(16);
            }) + '"';
        }
        return '"' + s + '"';
    };

    var encodeArray = function(o){
        var a = ["["], b, i, l = o.length, v;
            for (i = 0; i < l; i += 1) {
                v = o[i];
                switch (typeof v) {
                    case "undefined":
                    case "function":
                    case "unknown":
                        break;
                    default:
                        if (b) {
                            a.push(',');
                        }
                        a.push(v === null ? "null" : xo.util.JSON.encode(v));
                        b = true;
                }
            }
            a.push("]");
            return a.join("");
    };

    this.encodeDate = function(o){
        return '"' + o.getFullYear() + "-" +
                pad(o.getMonth() + 1) + "-" +
                pad(o.getDate()) + "T" +
                pad(o.getHours()) + ":" +
                pad(o.getMinutes()) + ":" +
                pad(o.getSeconds()) + '"';
    };

    this.encode = function(o){
        if(typeof o == "undefined" || o === null){
            return "null";
        }else if(xo.isArray(o)){
            return encodeArray(o);
        }else if(xo.isDate(o)){
            return xo.util.JSON.encodeDate(o);
        }else if(typeof o == "string"){
            return encodeString(o);
        }else if(typeof o == "number"){
            return isFinite(o) ? String(o) : "null";
        }else if(typeof o == "boolean"){
            return String(o);
        }else {
            var a = ["{"], b, i, v;
            for (i in o) {
                if(!useHasOwn || o.hasOwnProperty(i)) {
                    v = o[i];
                    switch (typeof v) {
                    case "undefined":
                    case "function":
                    case "unknown":
                        break;
                    default:
                        if(b){
                            a.push(',');
                        }
                        a.push(this.encode(i), ":",
                                v === null ? "null" : this.encode(v));
                        b = true;
                    }
                }
            }
            a.push("}");
            return a.join("");
        }
    };

})();
xo.encode = xo.util.JSON.encode;