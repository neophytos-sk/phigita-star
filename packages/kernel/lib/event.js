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
/*    ZERO: 48,
    ONE: 49,
    TWO: 50,
    THREE: 51,
    FOUR: 52,
    FIVE: 53,
    SIX: 54,
    SEVEN: 55,
    EIGHT: 56,
    NINE: 57,
    A: 65,
    B: 66,
    C: 67,
    D: 68,
    E: 69,
    F: 70,
    G: 71,
    H: 72,
    I: 73,
    J: 74,
    K: 75,
    L: 76,
    M: 77,
    N: 78,
    O: 79,
    P: 80,
    Q: 81,
    R: 82,
    S: 83,
    T: 84,
    U: 85,
    V: 86,
    W: 87,
    X: 88,
    Y: 89,
    Z: 90,
    CONTEXT_MENU: 93,
    NUM_ZERO: 96,
    NUM_ONE: 97,
    NUM_TWO: 98,
    NUM_THREE: 99,
    NUM_FOUR: 100,
    NUM_FIVE: 101,
    NUM_SIX: 102,
    NUM_SEVEN: 103,
    NUM_EIGHT: 104,
    NUM_NINE: 105,
    NUM_MULTIPLY: 106,
    NUM_PLUS: 107,
    NUM_MINUS: 109,
    NUM_PERIOD: 110,
    NUM_DIVISION: 111,
    F1: 112,
    F2: 113,
    F3: 114,
    F4: 115,
    F5: 116,
    F6: 117,
    F7: 118,
    F8: 119,
    F9: 120,
    F10: 121,
    F11: 122,
    F12: 123,
    NUM_EQUAL:61,
*/
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

        bind = xo.Event._normalizeEvent(eventName, fn);
        wrap = xo.Event._createListenerWrap(dom, eventName, bind.fn, scope, options);
	xo.bind(dom, bind.eventName, wrap, options.capture || false);

    },

    /**
     * Normalize cross browser event differences
     * @private
     * @param {Object} eventName The event name
     * @param {Object} fn The function to execute
     * @return {Object} The new event name/function
     */
    _normalizeEvent: function(eventName, fn){
        if (/mouseenter|mouseleave/.test(eventName) && !xo.supports.MouseEnterLeave) {
            // if (fn) {
                // fn = xo.Function.createInterceptor(fn, this.contains, this);
            // }
            eventName = eventName == 'mouseenter' ? 'mouseover' : 'mouseout';
        } else if (eventName == 'mousewheel' && !xo.supports.MouseWheel && !xo.isOpera){
            eventName = 'DOMMouseScroll';
        }
        return {
            eventName: eventName,
            fn: fn
        };
    },
    _createListenerWrap : function(dom,eventName,fn,scope,options){
	options = options || {};

        var f, gen;

        return function wrap(e, args) {
	    fn.call(scope || dom, e, this, options);
	};
    }
};


xo.Event.on=xo.Event.addListener;
