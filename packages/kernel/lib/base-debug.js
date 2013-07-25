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
	xo.log(xo.encode(o));
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



// TODO: api_key needs to be generated by JS mechanism in 20-xo/00-utils/30-JS-procs.tcl
// Then www/log.tcl would verify each log request before logging the error.
xo['api_key']= 'aebc-asdf-efas-eads';

// see errorception: http://www.youtube.com/watch?v=Eidlz-3CxcM
window.onerror_DISABLE = function myErrorHandler(errorMsg, url, line) {

    var err = {
	'api_key':xo['api_key'],
	'msg':errorMsg,
	'url':url,
	'line':line,
	'referrer' : document.referrer,
	'user_agent' : navigator.userAgent,
	'platform' : navigator.platform,
	'language' : navigator.language,
	'cookie_enabled' : navigator.cookieEnabled,
	'screen_width' : screen.width,
	'screen_height' : screen.height
    };
    xo.error(err);

    if (window.XMLHttpRequest) {
	var xhr = new XMLHttpRequest();
	var scripturl = "http://localhost:8090/log";
	xhr.open("POST", scripturl);
	xhr.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
	var log = '';
	for (i in err) 
	    log += i + '=' + encodeURIComponent(err[i]) + '&';
	xhr.send(log);
  }


    // prevent the firing of the default event handler
    return true;
};


