var xo = xo || {};
xo.global = this;

xo.isDef = function(val) {
  return val !== undefined;
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


xo.Event = {
    listeners:[],
    unloadListeners:[],
    stopEvent: function(ev) {
	this.stopPropagation(ev);
	this.preventDefault(ev);
    },
    stopPropagation: function(ev) {
	ev = ev.browserEvent || ev;
	if (ev.stopPropagation) {
	    ev.stopPropagation();
	} else {
	    ev.cancelBubble = true;
	}
    },
    preventDefault: function(ev) {
	ev = ev.browserEvent || ev;
	if(ev.preventDefault) {
	    ev.preventDefault();
	} else {
	    ev.returnValue = false;
	}
    },
    addListener: function(el, eventName, fn) {
	el = xo.getDom(el);
	if (!el || !fn) {
	    return false;
	}

	//if ("unload" == eventName) {
	//    unloadListeners[unloadListeners.length] =
	//    [el, eventName, fn];
	//    return true;
	//}

	// prevent unload errors with simple check
	var wrappedFn = function(e) {
	    return typeof xo != 'undefined' ? fn(xo.Event.getEvent(e)) : false;
	};

	var li = [el, eventName, fn, wrappedFn];

	//var index = listeners.length;
	//listeners[index] = li;

	this.doAdd(el, eventName, wrappedFn, false);
	return true;	
    },
    getEvent: function(e) {
	var ev = e || window.event;
	if (!ev) {
	    var c = this.getEvent.caller;
	    while (c) {
		ev = c.arguments[0];
		if (ev && Event == ev.constructor) {
		    break;
		}
		c = c.caller;
	    }
	}
	return ev;
    },
    doAdd: function () {
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
}

xo.Ajax = {
    timeout:{},
    poll:{},
    request : function(method, uri, cb, data, options) {
	return this.asyncRequest(method, uri, cb, data);
    },
    asyncRequest:function(method, uri, callback, postData) {
	var o = this.getConnectionObject();
	if (!o) {
	    return null;
	} else {
	    o.conn.open(method, uri, true);	    
	    this.handleReadyState(o, callback);
	    o.conn.send(postData || null);
	    return o;
	}
    },
    handleReadyState:function(o, callback) {
	var oConn = this;

	if (callback && callback.timeout) {
	    this.timeout[o.tId] = window.setTimeout(function() {
                    oConn.abort(o, callback, true);
                }, callback.timeout);
	}

	this.poll[o.tId] = window.setInterval(
            function() {
		if (o.conn && o.conn.readyState == 4) {
		    window.clearInterval(oConn.poll[o.tId]);
		    delete oConn.poll[o.tId];

		    if (callback && callback.timeout) {
			window.clearTimeout(oConn.timeout[o.tId]);
			delete oConn.timeout[o.tId];
		    }

		    oConn.handleTransactionResponse(o, callback);
		}
	    }
	    , this.pollInterval);
    },
    handleTransactionResponse:function(o, callback, isAbort) {
	if (!callback) {
	    this.releaseObject(o);
	    return;
	}

	var httpStatus, responseObject;

	try {
	    if (o.conn.status !== undefined && o.conn.status != 0) {
		httpStatus = o.conn.status;
	    } else {
		httpStatus = 13030;
	    }
	} catch(e) {
	    httpStatus = 13030;
	}

	if (httpStatus >= 200 && httpStatus < 300) {
	    responseObject = this.createResponseObject(o, callback.argument);
	    if (callback.success) {
		if (!callback.scope) {
		    callback.success(responseObject);
		} else {
		    callback.success.apply(callback.scope, [responseObject]);
		}
	    }
	} else {
	    switch (httpStatus) {
	    case 12002:
	    case 12029:
	    case 12030:
	    case 12031:
	    case 12152:
	    case 13030:
	    responseObject = this.createExceptionObject(o.tId, callback.argument, (isAbort ? isAbort : false));
	    if (callback.failure) {
		if (!callback.scope) {
		    callback.failure(responseObject);
		} else {
		    callback.failure.apply(callback.scope, [responseObject]);
		}
	    }
	    break;
	    default:
	    responseObject = this.createResponseObject(o, callback.argument);
	    if (callback.failure) {
		if (!callback.scope) {
		    callback.failure(responseObject);
		}
		else {
		    callback.failure.apply(callback.scope, [responseObject]);
		}
	    }
	    }
	}

	this.releaseObject(o);
	responseObject = null;
    },
    createResponseObject:function(o, callbackArg) {
	var obj = {};
	var headerObj = {};

	try {
	    var headerStr = o.conn.getAllResponseHeaders();
	    var header = headerStr.split('\n');
	    for (var i = 0; i < header.length; i++) {
		var delimitPos = header[i].indexOf(':');
		if (delimitPos != -1) {
		    headerObj[header[i].substring(0, delimitPos)] = header[i].substring(delimitPos + 2);
		}
	    }
	} catch(e) {
	}

	obj.tId = o.tId;
	obj.status = o.conn.status;
	obj.statusText = o.conn.statusText;
	obj.getResponseHeader = headerObj;
	obj.getAllResponseHeaders = headerStr;
	obj.responseText = o.conn.responseText;
	obj.responseXML = o.conn.responseXML;

	if (typeof callbackArg !== undefined) {
	    obj.argument = callbackArg;
	}

	return obj;
    },

    createExceptionObject:function(tId, callbackArg, isAbort)
    {
	var COMM_CODE = 0;
	var COMM_ERROR = 'communication failure';
	var ABORT_CODE = -1;
	var ABORT_ERROR = 'transaction aborted';

	var obj = {};

	obj.tId = tId;
	if (isAbort) {
	    obj.status = ABORT_CODE;
	    obj.statusText = ABORT_ERROR;
	}
	else {
	    obj.status = COMM_CODE;
	    obj.statusText = COMM_ERROR;
	}

	if (callbackArg) {
	    obj.argument = callbackArg;
	}

	return obj;
    },

    createXhrObject:function(transactionId) {
	var obj,http;
	try {
	    http = new XMLHttpRequest();
	    obj = { conn:http, tId:transactionId };
	} catch(e) {
	    for (var i = 0; i < this.activeX.length; ++i) {
		try {
		    http = new ActiveXObject(this.activeX[i]);
		    obj = { conn:http, tId:transactionId };
		    break;
		} catch(e) {
		}
	    }
	} finally {
	    return obj;
	}
    },
    getConnectionObject:function() {
	var o;
	var tId = this.transactionId;
	
	try {
	    o = this.createXhrObject(tId);
	    if (o) {
		this.transactionId++;
	    }
	} catch(e) {
	} finally {
	    return o;
	}
    },


    abort:function(o, callback, isTimeout) {
	if (this.isCallInProgress(o)) {
	    o.conn.abort();
	    window.clearInterval(this.poll[o.tId]);
	    delete this.poll[o.tId];
	    if (isTimeout) {
		delete this.timeout[o.tId];
	    }

	    this.handleTransactionResponse(o, callback, true);

	    return true;
	} else {
	    return false;
	}
    },
    isCallInProgress:function(o) {
	if (o.conn) {
	    return o.conn.readyState != 4 && o.conn.readyState != 0;
	} else {
	    return false;
	}
    },
    releaseObject:function(o) {
	o.conn = null;
	o = null;
    },

    activeX:[
        'MSXML2.XMLHTTP.3.0',
        'MSXML2.XMLHTTP',
        'Microsoft.XMLHTTP'
        ]

}


xo.exportSymbol("xo",xo);
xo.exportProperty(xo,"global",xo.global);
xo.exportProperty(xo,"emptyFn",xo.emptyFn);
xo.exportProperty(xo,"getDom",xo.getDom);
xo.exportProperty(xo,"decode",xo.decode);
xo.exportSymbol("xo.Ajax",xo.Ajax);
xo.exportProperty(xo.Ajax,"request",xo.Ajax.request);
xo.exportSymbol("xo.Event",xo.Event);
xo.exportProperty(xo.Event,"on",xo.Event.addListener);
xo.exportProperty(xo.Event,"stopEvent",xo.Event.stopEvent);


