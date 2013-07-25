
    addListener : function(el, eventName, fn) {
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

	xo.Event.doAdd(el, eventName, wrappedFn, false);
	return true;
    },
    getEvent : function(e) {
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