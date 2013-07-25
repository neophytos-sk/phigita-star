/** @const */ var xo = xo || {};

xo.global = this;

/** @define {boolean} DEBUG */
xo.DEBUG = false;

xo.log = function(o) {
    xo.DEBUG && window.console && o && window.console.log(o);
};

xo.error = function(o) {
    xo.DEBUG && window.console && o && window.console.error(o);
};



xo.idseed = 0;
xo.cache = {};
xo.windowId = 'xo-window';
xo.documentId = 'xo-document';
xo.baseCSSPrefix = 'xo-';
xo._navigator = navigator;
xo._screen = screen;
xo._userAgent = xo._navigator.userAgent.toLowerCase();
xo._platform = xo._navigator.platform;
xo._language = xo._navigator.language;
xo._cookieEnabled = xo._navigator.cookieEnabled;


var check = function(regex){
    return regex.test(xo._userAgent);
};
var docMode = document.documentMode;
xo.isOpera = check(/opera/);
xo.isOpera10_5 = xo.isOpera && check(/version\/10\.5/);
xo.isChrome = check(/\bchrome\b/);
xo.isWebKit = check(/webkit/);
xo.isSafari = !xo.isChrome && check(/safari/);
xo.isSafari2 = xo.isSafari && check(/applewebkit\/4/); // unique to Safari 2
xo.isSafari3 = xo.isSafari && check(/version\/3/);
xo.isSafari4 = xo.isSafari && check(/version\/4/);
xo.isIE = !xo.isOpera && check(/msie/);
xo.isIE7 = xo.isIE && (check(/msie 7/) || docMode == 7);
xo.isIE8 = xo.isIE && (check(/msie 8/) && docMode != 7 && docMode != 9 || docMode == 8);
xo.isIE9 = xo.isIE && (check(/msie 9/) && docMode != 7 && docMode != 8 || docMode == 9);
xo.isIE6 = xo.isIE && check(/msie 6/);
xo.isGecko = !xo.isWebKit && check(/gecko/);
xo.isGecko3 = xo.isGecko && check(/rv:1\.9/);
xo.isGecko4 = xo.isGecko && check(/rv:2\.0/);
xo.isFF3_0 = xo.isGecko3 && check(/rv:1\.9\.0/);
xo.isFF3_5 = xo.isGecko3 && check(/rv:1\.9\.1/);
xo.isFF3_6 = xo.isGecko3 && check(/rv:1\.9\.2/);
xo.isWindows = check(/windows|win32/);
xo.isMac = check(/macintosh|mac os x/);
xo.isLinux = check(/linux/);
scrollbarSize = null;
xo.isSecure = /^https/i.test(window.location.protocol);
xo.isStrict = window.document.compatMode === "CSS1Compat";

xo.webKitVersion = xo.isWebKit && (/webkit\/(\d+\.\d+)/.exec(xo._userAgent));
xo.webKitVersion = xo.webKitVersion ? parseFloat(xo.webKitVersion[1]) : -1;



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
	for (var i in config) {
	    object[i] = config[i];
	}
    }
    return object;
};

xo.applyIf = function(object, config) {
    if (object) {
	for (var property in config) {
	    if (object[property] === undefined) {
		object[property] = config[property];
	    }
	}
    }

    return object;
};


xo.id = function(el, prefix) {
    var me = xo.global;
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

xo.async = function(fn) {
    setTimeout(fn,10)
};

/**
 * Optional map of CSS class names to obfuscated names used with
 * xo.getCssName().
 * @type {Object|undefined}
 * @private
 * @see xo.setCssNameMapping
 */
xo.cssNameMapping_;

xo.setCssNameMapping = function(mapping) {
  xo.cssNameMapping_ = mapping;
};

xo.getCssName = function(cssName) {
    return xo.cssNameMapping_[cssName]; // || cssName;
};


xo.bind = function () {
    if (window.addEventListener) {
	return function(el, eventName, fn, capture) {
	    el.addEventListener(eventName, fn, (capture));
	};
    } else if (window.attachEvent) {
	return function(el, eventName, fn, capture) {
	    el.attachEvent("on" + eventName, fn);
	};
    } else {
	return function() {};
    }
}();

var $ = xo.getDom;




/**
 * True when the document is fully initialized and ready for action
 * @type Boolean
 * @member xo
 * @private
 */
xo.isReady = false;

/**
 * @private
 * @member Ext
 */
xo.readyListeners = [];

/**
 * @private
 * @member Ext
 */
xo.triggerReady = function() {
    var listeners = xo.readyListeners,
    i, ln, listener;

    if (!xo.isReady) {
        xo.isReady = true;

        for (i = 0,ln = listeners.length; i < ln; i++) {
            listener = listeners[i];
            listener.fn.call(listener.scope);
        }
        delete xo.readyListeners;
    }
}

/**
 * @private
 * @member Ext
 */
xo.onDocumentReady = function(fn, scope) {
    if (xo.isReady) {
        fn.call(scope);
    }
    else {
        var triggerFn = xo.triggerReady;

        xo.readyListeners.push({
            fn: fn,
            scope: scope
        });

        if (document.readyState.match(/interactive|complete|loaded/) !== null) {
            triggerFn();
        }
        else if (!xo.readyListenerAttached) {
            xo.readyListenerAttached = true;
            window.addEventListener('DOMContentLoaded', triggerFn, false);
        }
    }
}
