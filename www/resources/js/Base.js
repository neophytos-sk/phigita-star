/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */


Ext = {version: '2.1'};

// for old browsers
window["undefined"] = window["undefined"];

/**
 * @class Ext
 * Ext core utilities and functions.
 * @singleton
 */

/**
 * Copies all the properties of config to obj.
 * @param {Object} obj The receiver of the properties
 * @param {Object} config The source of the properties
 * @param {Object} defaults A different object that will also be applied for default values
 * @return {Object} returns obj
 * @member Ext apply
 */
Ext.apply = function(o, c, defaults){
    if(defaults){
        // no "this" reference for friendly out of scope calls
        Ext.apply(o, defaults);
    }
    if(o && c && typeof c == 'object'){
        for(var p in c){
            o[p] = c[p];
        }
    }
    return o;
};

(function(){
    var idSeed = 0;
    var ua = navigator.userAgent.toLowerCase();

    var isStrict = document.compatMode == "CSS1Compat",
        isOpera = ua.indexOf("opera") > -1,
        isSafari = (/webkit|khtml/).test(ua),
        isSafari3 = isSafari && ua.indexOf('webkit/5') != -1,
        isIE = !isOpera && ua.indexOf("msie") > -1,
        isIE7 = !isOpera && ua.indexOf("msie 7") > -1,
        isGecko = !isSafari && ua.indexOf("gecko") > -1,
        isBorderBox = isIE && !isStrict,
        isWindows = (ua.indexOf("windows") != -1 || ua.indexOf("win32") != -1),
        isMac = (ua.indexOf("macintosh") != -1 || ua.indexOf("mac os x") != -1),
        isAir = (ua.indexOf("adobeair") != -1),
        isLinux = (ua.indexOf("linux") != -1),
        isSecure = window.location.href.toLowerCase().indexOf("https") === 0;

    // remove css image flicker
	if(isIE && !isIE7){
        try{
            document.execCommand("BackgroundImageCache", false, true);
        }catch(e){}
    }

    Ext.apply(Ext, {
        /**
         * True if the browser is in strict mode
         * @type Boolean
         */
        isStrict : isStrict,
        /**
         * True if the page is running over SSL
         * @type Boolean
         */
        isSecure : isSecure,
        /**
         * True when the document is fully initialized and ready for action
         * @type Boolean
         */
        isReady : false,

        /**
         * True to automatically uncache orphaned Ext.Elements periodically (defaults to true)
         * @type Boolean
         */
        enableGarbageCollector : true,

        /**
         * True to automatically purge event listeners after uncaching an element (defaults to false).
         * Note: this only happens if enableGarbageCollector is true.
         * @type Boolean
         */
        enableListenerCollection:false,


        /**
         * URL to a blank file used by Ext when in secure mode for iframe src and onReady src to prevent
         * the IE insecure content warning (defaults to javascript:false).
         * @type String
         */
        SSL_SECURE_URL : "javascript:false",

        /**
         * URL to a 1x1 transparent gif image used by Ext to create inline icons with CSS background images. (Defaults to
         * "http://extjs.com/s.gif" and you should change this to a URL on your server).
         * @type String
         */
        BLANK_IMAGE_URL : "http:/"+"/www.phigita.net/graphics/s.gif",

        /**
        * A reusable empty function
        * @property
         * @type Function
        */
        emptyFn : function(){},

        /**
         * Copies all the properties of config to obj if they don't already exist.
         * @param {Object} obj The receiver of the properties
         * @param {Object} config The source of the properties
         * @return {Object} returns obj
         */
        applyIf : function(o, c){
            if(o && c){
                for(var p in c){
                    if(typeof o[p] == "undefined"){ o[p] = c[p]; }
                }
            }
            return o;
        },

        /**
         * Applies event listeners to elements by selectors when the document is ready.
         * The event name is specified with an @ suffix.
<pre><code>
Ext.addBehaviors({
   // add a listener for click on all anchors in element with id foo
   '#foo a@click' : function(e, t){
       // do something
   },

   // add the same listener to multiple selectors (separated by comma BEFORE the @)
   '#foo a, #bar span.some-class@mouseover' : function(){
       // do something
   }
});
</code></pre>
         * @param {Object} obj The list of behaviors to apply
         */
        addBehaviors : function(o){
            if(!Ext.isReady){
                Ext.onReady(function(){
                    Ext.addBehaviors(o);
                });
                return;
            }
            var cache = {}; // simple cache for applying multiple behaviors to same selector does query multiple times
            for(var b in o){
                var parts = b.split('@');
                if(parts[1]){ // for Object prototype breakers
                    var s = parts[0];
                    if(!cache[s]){
                        cache[s] = Ext.select(s);
                    }
                    cache[s].on(parts[1], o[b]);
                }
            }
            cache = null;
        },

        /**
         * Generates unique ids. If the element already has an id, it is unchanged
         * @param {Mixed} el (optional) The element to generate an id for
         * @param {String} prefix (optional) Id prefix (defaults "ext-gen")
         * @return {String} The generated Id.
         */
        id : function(el, prefix){
            prefix = prefix || "ext-gen";
            el = Ext.getDom(el);
            var id = prefix + (++idSeed);
            return el ? (el.id ? el.id : (el.id = id)) : id;
        },

        /**
         * Extends one class with another class and optionally overrides members with the passed literal. This class
         * also adds the function "override()" to the class that can be used to override
         * members on an instance.
         * * <p>
         * This function also supports a 2-argument call in which the subclass's constructor is
         * not passed as an argument. In this form, the parameters are as follows:</p><p>
         * <div class="mdetail-params"><ul>
         * <li><code>superclass</code>
         * <div class="sub-desc">The class being extended</div></li>
         * <li><code>overrides</code>
         * <div class="sub-desc">A literal with members which are copied into the subclass's
         * prototype, and are therefore shared among all instances of the new class.<p>
         * This may contain a special member named <tt><b>constructor</b></tt>. This is used
         * to define the constructor of the new class, and is returned. If this property is
         * <i>not</i> specified, a constructor is generated and returned which just calls the
         * superclass's constructor passing on its parameters.</p></div></li>
         * </ul></div></p><p>
         * For example, to create a subclass of the Ext GridPanel:
         * <pre><code>
    MyGridPanel = Ext.extend(Ext.grid.GridPanel, {
        constructor: function(config) {
            // Your preprocessing here
        	MyGridPanel.superclass.constructor.apply(this, arguments);
            // Your postprocessing here
        },

        yourMethod: function() {
            // etc.
        }
    });
</code></pre>
         * </p>
         * @param {Function} subclass The class inheriting the functionality
         * @param {Function} superclass The class being extended
         * @param {Object} overrides (optional) A literal with members which are copied into the subclass's
         * prototype, and are therefore shared between all instances of the new class.
         * @return {Function} The subclass constructor.
         * @method extend
         */
        extend : function(){
            // inline overrides
            var io = function(o){
                for(var m in o){
                    this[m] = o[m];
                }
            };
            var oc = Object.prototype.constructor;
            
            return function(sb, sp, overrides){
                if(typeof sp == 'object'){
                    overrides = sp;
                    sp = sb;
                    sb = overrides.constructor != oc ? overrides.constructor : function(){sp.apply(this, arguments);};
                }
                var F = function(){}, sbp, spp = sp.prototype;
                F.prototype = spp;
                sbp = sb.prototype = new F();
                sbp.constructor=sb;
                sb.superclass=spp;
                if(spp.constructor == oc){
                    spp.constructor=sp;
                }
                sb.override = function(o){
                    Ext.override(sb, o);
                };
                sbp.override = io;
                Ext.override(sb, overrides);
                sb.extend = function(o){Ext.extend(sb, o);};
                return sb;
            };
        }(),

        /**
         * Adds a list of functions to the prototype of an existing class, overwriting any existing methods with the same name.
         * Usage:<pre><code>
Ext.override(MyClass, {
    newMethod1: function(){
        // etc.
    },
    newMethod2: function(foo){
        // etc.
    }
});
 </code></pre>
         * @param {Object} origclass The class to override
         * @param {Object} overrides The list of functions to add to origClass.  This should be specified as an object literal
         * containing one or more methods.
         * @method override
         */
        override : function(origclass, overrides){
            if(overrides){
                var p = origclass.prototype;
                for(var method in overrides){
                    p[method] = overrides[method];
                }
            }
        },

        /**
         * Creates namespaces to be used for scoping variables and classes so that they are not global.  Usage:
         * <pre><code>
Ext.namespace('Company', 'Company.data');
Company.Widget = function() { ... }
Company.data.CustomStore = function(config) { ... }
</code></pre>
         * @param {String} namespace1
         * @param {String} namespace2
         * @param {String} etc
         * @method namespace
         */
        namespace : function(){
            var a=arguments, o=null, i, j, d, rt;
            for (i=0; i<a.length; ++i) {
                d=a[i].split(".");
                rt = d[0];
                eval('if (typeof ' + rt + ' == "undefined"){' + rt + ' = {};} o = ' + rt + ';');
                for (j=1; j<d.length; ++j) {
                    o[d[j]]=o[d[j]] || {};
                    o=o[d[j]];
                }
            }
        },

        /**
         * Takes an object and converts it to an encoded URL. e.g. Ext.urlEncode({foo: 1, bar: 2}); would return "foo=1&bar=2".  Optionally, property values can be arrays, instead of keys and the resulting string that's returned will contain a name/value pair for each array value.
         * @param {Object} o
         * @return {String}
         */
        urlEncode : function(o){
            if(!o){
                return "";
            }
            var buf = [];
            for(var key in o){
                var ov = o[key], k = encodeURIComponent(key);
                var type = typeof ov;
                if(type == 'undefined'){
                    buf.push(k, "=&");
                }else if(type != "function" && type != "object"){
                    buf.push(k, "=", encodeURIComponent(ov), "&");
                }else if(Ext.isArray(ov)){
                    if (ov.length) {
	                    for(var i = 0, len = ov.length; i < len; i++) {
	                        buf.push(k, "=", encodeURIComponent(ov[i] === undefined ? '' : ov[i]), "&");
	                    }
	                } else {
	                    buf.push(k, "=&");
	                }
                }
            }
            buf.pop();
            return buf.join("");
        },

        /**
         * Takes an encoded URL and and converts it to an object. e.g. Ext.urlDecode("foo=1&bar=2"); would return {foo: 1, bar: 2} or Ext.urlDecode("foo=1&bar=2&bar=3&bar=4", true); would return {foo: 1, bar: [2, 3, 4]}.
         * @param {String} string
         * @param {Boolean} overwrite (optional) Items of the same name will overwrite previous values instead of creating an an array (Defaults to false).
         * @return {Object} A literal with members
         */
        urlDecode : function(string, overwrite){
            if(!string || !string.length){
                return {};
            }
            var obj = {};
            var pairs = string.split('&');
            var pair, name, value;
            for(var i = 0, len = pairs.length; i < len; i++){
                pair = pairs[i].split('=');
                name = decodeURIComponent(pair[0]);
                value = decodeURIComponent(pair[1]);
                if(overwrite !== true){
                    if(typeof obj[name] == "undefined"){
                        obj[name] = value;
                    }else if(typeof obj[name] == "string"){
                        obj[name] = [obj[name]];
                        obj[name].push(value);
                    }else{
                        obj[name].push(value);
                    }
                }else{
                    obj[name] = value;
                }
            }
            return obj;
        },

        /**
         * Iterates an array calling the passed function with each item, stopping if your function returns false. If the
         * passed array is not really an array, your function is called once with it.
         * The supplied function is called with (Object item, Number index, Array allItems).
         * @param {Array/NodeList/Mixed} array
         * @param {Function} fn
         * @param {Object} scope
         */
        each : function(array, fn, scope){
            if(!Ext.isArray(array)){
                array = [array];
            }
            for(var i = 0, len = array.length; i < len; i++){
                if(fn.call(scope || array[i], array[i], i, array) === false){ return i; };
            }
        },

        // deprecated
        combine : function(){
            var as = arguments, l = as.length, r = [];
            for(var i = 0; i < l; i++){
                var a = as[i];
                if(Ext.isArray(a)){
                    r = r.concat(a);
                }else if(a.length !== undefined && !a.substr){
                    r = r.concat(Array.prototype.slice.call(a, 0));
                }else{
                    r.push(a);
                }
            }
            return r;
        },

        /**
         * Escapes the passed string for use in a regular expression
         * @param {String} str
         * @return {String}
         */
        escapeRe : function(s) {
            return s.replace(/([.*+?^${}()|[\]\/\\])/g, "\\$1");
        },

        // internal
        callback : function(cb, scope, args, delay){
            if(typeof cb == "function"){
                if(delay){
                    cb.defer(delay, scope, args || []);
                }else{
                    cb.apply(scope, args || []);
                }
            }
        },

        /**
         * Return the dom node for the passed string (id), dom node, or Ext.Element
         * @param {Mixed} el
         * @return HTMLElement
         */
        getDom : function(el){
            if(!el || !document){
                return null;
            }
            return el.dom ? el.dom : (typeof el == 'string' ? document.getElementById(el) : el);
        },

        /**
        * Returns the current HTML document object as an {@link Ext.Element}.
        * @return Ext.Element The document
        */
        getDoc : function(){
            return Ext.get(document);
        },

        /**
        * Returns the current document body as an {@link Ext.Element}.
        * @return Ext.Element The document body
        */
        getBody : function(){
            return Ext.get(document.body || document.documentElement);
        },

        /**
        * Shorthand for {@link Ext.ComponentMgr#get}
        * @param {String} id
        * @return Ext.Component
        */
        getCmp : function(id){
            return Ext.ComponentMgr.get(id);
        },

        /**
         * Utility method for validating that a value is numeric, returning the specified default value if it is not.
         * @param {Mixed} value Should be a number, but any type will be handled appropriately
         * @param {Number} defaultValue The value to return if the original value is non-numeric
         * @return {Number} Value, if numeric, else defaultValue
         */
        num : function(v, defaultValue){
            if(typeof v != 'number'){
                return defaultValue;
            }
            return v;
        },

        /**
         * Attempts to destroy any objects passed to it by removing all event listeners, removing them from the
         * DOM (if applicable) and calling their destroy functions (if available).  This method is primarily
         * intended for arguments of type {@link Ext.Element} and {@link Ext.Component}, but any subclass of
         * {@link Ext.util.Observable} can be passed in.  Any number of elements and/or components can be
         * passed into this function in a single call as separate arguments.
         * @param {Mixed} arg1 An {@link Ext.Element} or {@link Ext.Component} to destroy
         * @param {Mixed} arg2 (optional)
         * @param {Mixed} etc... (optional)
         */
        destroy : function(){
            for(var i = 0, a = arguments, len = a.length; i < len; i++) {
                var as = a[i];
                if(as){
		            if(typeof as.destroy == 'function'){
		                as.destroy();
		            }
		            else if(as.dom){
		                as.removeAllListeners();
		                as.remove();
		            }
                }
            }
        },

        /**
         * Removes a DOM node from the document.  The body node will be ignored if passed in.
         * @param {HTMLElement} node The node to remove
         */
        removeNode : isIE ? function(){
            var d;
            return function(n){
                if(n && n.tagName != 'BODY'){
                    d = d || document.createElement('div');
                    d.appendChild(n);
                    d.innerHTML = '';
                }
            }
        }() : function(n){
            if(n && n.parentNode && n.tagName != 'BODY'){
                n.parentNode.removeChild(n);
            }
        },

        // inpired by a similar function in mootools library
        /**
         * Returns the type of object that is passed in. If the object passed in is null or undefined it
         * return false otherwise it returns one of the following values:<ul>
         * <li><b>string</b>: If the object passed is a string</li>
         * <li><b>number</b>: If the object passed is a number</li>
         * <li><b>boolean</b>: If the object passed is a boolean value</li>
         * <li><b>function</b>: If the object passed is a function reference</li>
         * <li><b>object</b>: If the object passed is an object</li>
         * <li><b>array</b>: If the object passed is an array</li>
         * <li><b>regexp</b>: If the object passed is a regular expression</li>
         * <li><b>element</b>: If the object passed is a DOM Element</li>
         * <li><b>nodelist</b>: If the object passed is a DOM NodeList</li>
         * <li><b>textnode</b>: If the object passed is a DOM text node and contains something other than whitespace</li>
         * <li><b>whitespace</b>: If the object passed is a DOM text node and contains only whitespace</li>
         * @param {Mixed} object
         * @return {String}
         */
        type : function(o){
            if(o === undefined || o === null){
                return false;
            }
            if(o.htmlElement){
                return 'element';
            }
            var t = typeof o;
            if(t == 'object' && o.nodeName) {
                switch(o.nodeType) {
                    case 1: return 'element';
                    case 3: return (/\S/).test(o.nodeValue) ? 'textnode' : 'whitespace';
                }
            }
            if(t == 'object' || t == 'function') {
                switch(o.constructor) {
                    case Array: return 'array';
                    case RegExp: return 'regexp';
                }
                if(typeof o.length == 'number' && typeof o.item == 'function') {
                    return 'nodelist';
                }
            }
            return t;
        },

        /**
         * Returns true if the passed value is null, undefined or an empty string (optional).
         * @param {Mixed} value The value to test
         * @param {Boolean} allowBlank (optional) Pass true if an empty string is not considered empty
         * @return {Boolean}
         */
        isEmpty : function(v, allowBlank){
            return v === null || v === undefined || (!allowBlank ? v === '' : false);
        },

        value : function(v, defaultValue, allowBlank){
            return Ext.isEmpty(v, allowBlank) ? defaultValue : v;
        },

        /**
         * Returns true if the passed object is a JavaScript array, otherwise false.
         * @param {Object} The object to test
         * @return {Boolean}
         */
		isArray : function(v){
			return v && typeof v.pop == 'function';
		},

		/**
         * Returns true if the passed object is a JavaScript date object, otherwise false.
         * @param {Object} The object to test
         * @return {Boolean}
         */
		isDate : function(v){
			return v && typeof v.getFullYear == 'function';
		},

        /** @type Boolean */
        isOpera : isOpera,
        /** @type Boolean */
        isSafari : isSafari,
        /** @type Boolean */
        isSafari3 : isSafari3,
        /** @type Boolean */
        isSafari2 : isSafari && !isSafari3,
        /** @type Boolean */
        isIE : isIE,
        /** @type Boolean */
        isIE6 : isIE && !isIE7,
        /** @type Boolean */
        isIE7 : isIE7,
        /** @type Boolean */
        isGecko : isGecko,
        /** @type Boolean */
        isBorderBox : isBorderBox,
        /** @type Boolean */
        isLinux : isLinux,
        /** @type Boolean */
        isWindows : isWindows,
        /** @type Boolean */
        isMac : isMac,
        /** @type Boolean */
        isAir : isAir,

	    /**
	     * By default, Ext intelligently decides whether floating elements should be shimmed. If you are using flash,
	     * you may want to set this to true.
	     * @type Boolean
	     */
        useShims : ((isIE && !isIE7) || (isGecko && isMac))
    });

    // in intellij using keyword "namespace" causes parsing errors
    Ext.ns = Ext.namespace;
})();

Ext.ns("Ext", "Ext.util", "Ext.grid", "Ext.dd", "Ext.tree", "Ext.data",
                "Ext.form", "Ext.menu", "Ext.state", "Ext.lib", "Ext.layout", "Ext.app", "Ext.ux");


/**
 * @class Function
 * These functions are available on every Function object (any JavaScript function).
 */
Ext.apply(Function.prototype, {
     /**
     * Creates a callback that passes arguments[0], arguments[1], arguments[2], ...
     * Call directly on any function. Example: <code>myFunction.createCallback(arg1, arg2)</code>
     * Will create a function that is bound to those 2 args. <b>If a specific scope is required in the
     * callback, use {@link #createDelegate} instead.</b> The function returned by createCallback always
     * executes in the window scope.
     * <p>This method is required when you want to pass arguments to a callback function.  If no arguments
     * are needed, you can simply pass a reference to the function as a callback (e.g., callback: myFn).  
     * However, if you tried to pass a function with arguments (e.g., callback: myFn(arg1, arg2)) the function
     * would simply execute immediately when the code is parsed. Example usage:
     * <pre><code>
var sayHi = function(name){
    alert('Hi, ' + name);
}

// clicking the button alerts "Hi, Fred"
new Ext.Button({
    text: 'Say Hi',
    renderTo: Ext.getBody(),
    handler: sayHi.createCallback('Fred')
});
</code></pre>
     * @return {Function} The new function
    */
    createCallback : function(/*args...*/){
        // make args available, in function below
        var args = arguments;
        var method = this;
        return function() {
            return method.apply(window, args);
        };
    },

    /**
     * Creates a delegate (callback) that sets the scope to obj.
     * Call directly on any function. Example: <code>this.myFunction.createDelegate(this, [arg1, arg2])</code>
     * Will create a function that is automatically scoped to obj so that the <tt>this</tt> variable inside the
     * callback points to obj. Example usage:
     * <pre><code>
var sayHi = function(name){
    // Note this use of "this.text" here.  This function expects to
    // execute within a scope that contains a text property.  In this
    // example, the "this" variable is pointing to the btn object that
    // was passed in createDelegate below.
    alert('Hi, ' + name + '. You clicked the "' + this.text + '" button.');
}

var btn = new Ext.Button({
    text: 'Say Hi',
    renderTo: Ext.getBody()
});

// This callback will execute in the scope of the
// button instance. Clicking the button alerts 
// "Hi, Fred. You clicked the "Say Hi" button."
btn.on('click', sayHi.createDelegate(btn, ['Fred']));
</code></pre>
     * @param {Object} obj (optional) The object for which the scope is set
     * @param {Array} args (optional) Overrides arguments for the call. (Defaults to the arguments passed by the caller)
     * @param {Boolean/Number} appendArgs (optional) if True args are appended to call args instead of overriding,
     *                                             if a number the args are inserted at the specified position
     * @return {Function} The new function
     */
    createDelegate : function(obj, args, appendArgs){
        var method = this;
        return function() {
            var callArgs = args || arguments;
            if(appendArgs === true){
                callArgs = Array.prototype.slice.call(arguments, 0);
                callArgs = callArgs.concat(args);
            }else if(typeof appendArgs == "number"){
                callArgs = Array.prototype.slice.call(arguments, 0); // copy arguments first
                var applyArgs = [appendArgs, 0].concat(args); // create method call params
                Array.prototype.splice.apply(callArgs, applyArgs); // splice them in
            }
            return method.apply(obj || window, callArgs);
        };
    },

    /**
     * Calls this function after the number of millseconds specified, optionally in a specific scope. Example usage:
     * <pre><code>
var sayHi = function(name){
    alert('Hi, ' + name);
}

// executes immediately:
sayHi('Fred');

// executes after 2 seconds:
sayHi.defer(2000, this, ['Fred']);

// this syntax is sometimes useful for deferring 
// execution of an anonymous function:
(function(){
    alert('Anonymous');
}).defer(100);
</code></pre>
     * @param {Number} millis The number of milliseconds for the setTimeout call (if 0 the function is executed immediately)
     * @param {Object} obj (optional) The object for which the scope is set
     * @param {Array} args (optional) Overrides arguments for the call. (Defaults to the arguments passed by the caller)
     * @param {Boolean/Number} appendArgs (optional) if True args are appended to call args instead of overriding,
     *                                             if a number the args are inserted at the specified position
     * @return {Number} The timeout id that can be used with clearTimeout
     */
    defer : function(millis, obj, args, appendArgs){
        var fn = this.createDelegate(obj, args, appendArgs);
        if(millis){
            return setTimeout(fn, millis);
        }
        fn();
        return 0;
    },
    
    /**
     * Create a combined function call sequence of the original function + the passed function.
     * The resulting function returns the results of the original function.
     * The passed fcn is called with the parameters of the original function. Example usage:
     * <pre><code>
var sayHi = function(name){
    alert('Hi, ' + name);
}

sayHi('Fred'); // alerts "Hi, Fred"

var sayGoodbye = sayHi.createSequence(function(name){
    alert('Bye, ' + name);
});

sayGoodbye('Fred'); // both alerts show
</code></pre>
     * @param {Function} fcn The function to sequence
     * @param {Object} scope (optional) The scope of the passed fcn (Defaults to scope of original function or window)
     * @return {Function} The new function
     */
    createSequence : function(fcn, scope){
        if(typeof fcn != "function"){
            return this;
        }
        var method = this;
        return function() {
            var retval = method.apply(this || window, arguments);
            fcn.apply(scope || this || window, arguments);
            return retval;
        };
    },

    /**
     * Creates an interceptor function. The passed fcn is called before the original one. If it returns false, 
     * the original one is not called. The resulting function returns the results of the original function.
     * The passed fcn is called with the parameters of the original function. Example usage:
     * <pre><code>
var sayHi = function(name){
    alert('Hi, ' + name);
}

sayHi('Fred'); // alerts "Hi, Fred"

// create a new function that validates input without
// directly modifying the original function:
var sayHiToFriend = sayHi.createInterceptor(function(name){
    return name == 'Brian';
});

sayHiToFriend('Fred');  // no alert
sayHiToFriend('Brian'); // alerts "Hi, Brian"
</code></pre>
     * @param {Function} fcn The function to call before the original
     * @param {Object} scope (optional) The scope of the passed fcn (Defaults to scope of original function or window)
     * @return {Function} The new function
     */
    createInterceptor : function(fcn, scope){
        if(typeof fcn != "function"){
            return this;
        }
        var method = this;
        return function() {
            fcn.target = this;
            fcn.method = method;
            if(fcn.apply(scope || this || window, arguments) === false){
                return;
            }
            return method.apply(this || window, arguments);
        };
    }
});

/**
 * @class String
 * These functions are available as static methods on the JavaScript String object.
 */
Ext.applyIf(String, {

    /**
     * Escapes the passed string for ' and \
     * @param {String} string The string to escape
     * @return {String} The escaped string
     * @static
     */
    escape : function(string) {
        return string.replace(/('|\\)/g, "\\$1");
    },

    /**
     * Pads the left side of a string with a specified character.  This is especially useful
     * for normalizing number and date strings.  Example usage:
     * <pre><code>
var s = String.leftPad('123', 5, '0');
// s now contains the string: '00123'
</code></pre>
     * @param {String} string The original string
     * @param {Number} size The total length of the output string
     * @param {String} char (optional) The character with which to pad the original string (defaults to empty string " ")
     * @return {String} The padded string
     * @static
     */
    leftPad : function (val, size, ch) {
        var result = new String(val);
        if(!ch) {
            ch = " ";
        }
        while (result.length < size) {
            result = ch + result;
        }
        return result.toString();
    },

    /**
     * Allows you to define a tokenized string and pass an arbitrary number of arguments to replace the tokens.  Each
     * token must be unique, and must increment in the format {0}, {1}, etc.  Example usage:
     * <pre><code>
var cls = 'my-class', text = 'Some text';
var s = String.format('&lt;div class="{0}">{1}&lt;/div>', cls, text);
// s now contains the string: '&lt;div class="my-class">Some text&lt;/div>'
</code></pre>
     * @param {String} string The tokenized string to be formatted
     * @param {String} value1 The value to replace token {0}
     * @param {String} value2 Etc...
     * @return {String} The formatted string
     * @static
     */
    format : function(format){
        var args = Array.prototype.slice.call(arguments, 1);
        return format.replace(/\{(\d+)\}/g, function(m, i){
            return args[i];
        });
    }
});

/**
 * Utility function that allows you to easily switch a string between two alternating values.  The passed value
 * is compared to the current string, and if they are equal, the other value that was passed in is returned.  If
 * they are already different, the first value passed in is returned.  Note that this method returns the new value
 * but does not change the current string.
 * <pre><code>
// alternate sort directions
sort = sort.toggle('ASC', 'DESC');

// instead of conditional logic:
sort = (sort == 'ASC' ? 'DESC' : 'ASC');
</code></pre>
 * @param {String} value The value to compare to the current string
 * @param {String} other The new value to use if the string already equals the first value passed in
 * @return {String} The new value
 */
String.prototype.toggle = function(value, other){
    return this == value ? other : value;
};

/**
 * Trims whitespace from either end of a string, leaving spaces within the string intact.  Example:
 * <pre><code>
var s = '  foo bar  ';
alert('-' + s + '-');         //alerts "- foo bar -"
alert('-' + s.trim() + '-');  //alerts "-foo bar-"
</code></pre>
 * @return {String} The trimmed string
 */
String.prototype.trim = function(){
    var re = /^\s+|\s+$/g;
    return function(){ return this.replace(re, ""); };
}();
/**
 * @class Number
 */
Ext.applyIf(Number.prototype, {
    /**
     * Checks whether or not the current number is within a desired range.  If the number is already within the
     * range it is returned, otherwise the min or max value is returned depending on which side of the range is
     * exceeded.  Note that this method returns the constrained value but does not change the current number.
     * @param {Number} min The minimum number in the range
     * @param {Number} max The maximum number in the range
     * @return {Number} The constrained value if outside the range, otherwise the current value
     */
    constrain : function(min, max){
        return Math.min(Math.max(this, min), max);
    }
});
/**
 * @class Array
 */
Ext.applyIf(Array.prototype, {
    /**
     * Checks whether or not the specified object exists in the array.
     * @param {Object} o The object to check for
     * @return {Number} The index of o in the array (or -1 if it is not found)
     */
    indexOf : function(o){
       for (var i = 0, len = this.length; i < len; i++){
 	      if(this[i] == o) return i;
       }
 	   return -1;
    },

    /**
     * Removes the specified object from the array.  If the object is not found nothing happens.
     * @param {Object} o The object to remove
     * @return {Array} this array
     */
    remove : function(o){
       var index = this.indexOf(o);
       if(index != -1){
           this.splice(index, 1);
       }
       return this;
    }
});

/**
 Returns the number of milliseconds between this date and date
 @param {Date} date (optional) Defaults to now
 @return {Number} The diff in milliseconds
 @member Date getElapsed
 */
Date.prototype.getElapsed = function(date) {
	return Math.abs((date || new Date()).getTime()-this.getTime());
};

/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.util.Format
 * Reusable data formatting functions
 * @singleton
 */
Ext.util.Format = function(){
    var trimRe = /^\s+|\s+$/g;
    return {
        /**
         * Truncate a string and add an ellipsis ('...') to the end if it exceeds the specified length
         * @param {String} value The string to truncate
         * @param {Number} length The maximum length to allow before truncating
         * @return {String} The converted text
         */
        ellipsis : function(value, len){
            if(value && value.length > len){
                return value.substr(0, len-3)+"...";
            }
            return value;
        },

        /**
         * Checks a reference and converts it to empty string if it is undefined
         * @param {Mixed} value Reference to check
         * @return {Mixed} Empty string if converted, otherwise the original value
         */
        undef : function(value){
            return value !== undefined ? value : "";
        },

        /**
         * Checks a reference and converts it to the default value if it's empty
         * @param {Mixed} value Reference to check
         * @param {String} defaultValue The value to insert of it's undefined (defaults to "")
         * @return {String}
         */
        defaultValue : function(value, defaultValue){
            return value !== undefined && value !== '' ? value : defaultValue;
        },

        /**
         * Convert certain characters (&, <, >, and ') to their HTML character equivalents for literal display in web pages.
         * @param {String} value The string to encode
         * @return {String} The encoded text
         */
        htmlEncode : function(value){
            return !value ? value : String(value).replace(/&/g, "&amp;").replace(/>/g, "&gt;").replace(/</g, "&lt;").replace(/"/g, "&quot;");
        },

        /**
         * Convert certain characters (&, <, >, and ') from their HTML character equivalents.
         * @param {String} value The string to decode
         * @return {String} The decoded text
         */
        htmlDecode : function(value){
            return !value ? value : String(value).replace(/&amp;/g, "&").replace(/&gt;/g, ">").replace(/&lt;/g, "<").replace(/&quot;/g, '"');
        },

        /**
         * Trims any whitespace from either side of a string
         * @param {String} value The text to trim
         * @return {String} The trimmed text
         */
        trim : function(value){
            return String(value).replace(trimRe, "");
        },

        /**
         * Returns a substring from within an original string
         * @param {String} value The original text
         * @param {Number} start The start index of the substring
         * @param {Number} length The length of the substring
         * @return {String} The substring
         */
        substr : function(value, start, length){
            return String(value).substr(start, length);
        },

        /**
         * Converts a string to all lower case letters
         * @param {String} value The text to convert
         * @return {String} The converted text
         */
        lowercase : function(value){
            return String(value).toLowerCase();
        },

        /**
         * Converts a string to all upper case letters
         * @param {String} value The text to convert
         * @return {String} The converted text
         */
        uppercase : function(value){
            return String(value).toUpperCase();
        },

        /**
         * Converts the first character only of a string to upper case
         * @param {String} value The text to convert
         * @return {String} The converted text
         */
        capitalize : function(value){
            return !value ? value : value.charAt(0).toUpperCase() + value.substr(1).toLowerCase();
        },

        // private
        call : function(value, fn){
            if(arguments.length > 2){
                var args = Array.prototype.slice.call(arguments, 2);
                args.unshift(value);
                return eval(fn).apply(window, args);
            }else{
                return eval(fn).call(window, value);
            }
        },

        /**
         * Format a number as US currency
         * @param {Number/String} value The numeric value to format
         * @return {String} The formatted currency string
         */
        usMoney : function(v){
            v = (Math.round((v-0)*100))/100;
            v = (v == Math.floor(v)) ? v + ".00" : ((v*10 == Math.floor(v*10)) ? v + "0" : v);
            v = String(v);
            var ps = v.split('.');
            var whole = ps[0];
            var sub = ps[1] ? '.'+ ps[1] : '.00';
            var r = /(\d+)(\d{3})/;
            while (r.test(whole)) {
                whole = whole.replace(r, '$1' + ',' + '$2');
            }
            v = whole + sub;
            if(v.charAt(0) == '-'){
                return '-$' + v.substr(1);
            }
            return "$" +  v;
        },

        /**
         * Parse a value into a formatted date using the specified format pattern.
         * @param {Mixed} value The value to format
         * @param {String} format (optional) Any valid date format string (defaults to 'm/d/Y')
         * @return {String} The formatted date string
         */
        date : function(v, format){
            if(!v){
                return "";
            }
            if(!Ext.isDate(v)){
                v = new Date(Date.parse(v));
            }
            return v.dateFormat(format || "m/d/Y");
        },

        /**
         * Returns a date rendering function that can be reused to apply a date format multiple times efficiently
         * @param {String} format Any valid date format string
         * @return {Function} The date formatting function
         */
        dateRenderer : function(format){
            return function(v){
                return Ext.util.Format.date(v, format);
            };
        },

        // private
        stripTagsRE : /<\/?[^>]+>/gi,
        
        /**
         * Strips all HTML tags
         * @param {Mixed} value The text from which to strip tags
         * @return {String} The stripped text
         */
        stripTags : function(v){
            return !v ? v : String(v).replace(this.stripTagsRE, "");
        },

        stripScriptsRe : /(?:<script.*?>)((\n|\r|.)*?)(?:<\/script>)/ig,

        /**
         * Strips all script tags
         * @param {Mixed} value The text from which to strip script tags
         * @return {String} The stripped text
         */
        stripScripts : function(v){
            return !v ? v : String(v).replace(this.stripScriptsRe, "");
        },

        /**
         * Simple format for a file size (xxx bytes, xxx KB, xxx MB)
         * @param {Number/String} size The numeric value to format
         * @return {String} The formatted file size
         */
        fileSize : function(size){
            if(size < 1024) {
                return size + " bytes";
            } else if(size < 1048576) {
                return (Math.round(((size*10) / 1024))/10) + " KB";
            } else {
                return (Math.round(((size*10) / 1048576))/10) + " MB";
            }
        },

        math : function(){
            var fns = {};
            return function(v, a){
                if(!fns[a]){
                    fns[a] = new Function('v', 'return v ' + a + ';');
                }
                return fns[a](v);
            }
        }()
    };
}();
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.DomHelper
 * Utility class for working with DOM and/or Templates. It transparently supports using HTML fragments or DOM.<br>
 * This is an example, where an unordered list with 5 children items is appended to an existing element with id 'my-div':<br>
 <pre><code>
var dh = Ext.DomHelper;
var list = dh.append('my-div', {
    id: 'my-ul', tag: 'ul', cls: 'my-list', children: [
        {tag: 'li', id: 'item0', html: 'List Item 0'},
        {tag: 'li', id: 'item1', html: 'List Item 1'},
        {tag: 'li', id: 'item2', html: 'List Item 2'},
        {tag: 'li', id: 'item3', html: 'List Item 3'},
        {tag: 'li', id: 'item4', html: 'List Item 4'}
    ]
});
 </code></pre>
 * <p>Element creation specification parameters in this class may also be passed as an Array of
 * specification objects. This can be used to insert multiple sibling nodes into an existing
 * container very efficiently. For example, to add more list items to the example above:<pre><code>
dh.append('my-ul', [
    {tag: 'li', id: 'item5', html: 'List Item 5'},
    {tag: 'li', id: 'item6', html: 'List Item 6'} ]);
</code></pre></p>
 * <p>Element creation specification parameters may also be strings. If {@link useDom} is false, then the string is used
 * as innerHTML. If {@link useDom} is true, a string specification results in the creation of a text node.</p>
 * For more information and examples, see <a href="http://www.jackslocum.com/blog/2006/10/06/domhelper-create-elements-using-dom-html-fragments-or-templates/">the original blog post</a>.
 * @singleton
 */
Ext.DomHelper = function(){
    var tempTableEl = null;
    var emptyTags = /^(?:br|frame|hr|img|input|link|meta|range|spacer|wbr|area|param|col)$/i;
    var tableRe = /^table|tbody|tr|td$/i;

    // build as innerHTML where available
    var createHtml = function(o){
        if(typeof o == 'string'){
            return o;
        }
        var b = "";
        if (Ext.isArray(o)) {
            for (var i = 0, l = o.length; i < l; i++) {
                b += createHtml(o[i]);
            }
            return b;
        }
        if(!o.tag){
            o.tag = "div";
        }
        b += "<" + o.tag;
        for(var attr in o){
            if(attr == "tag" || attr == "children" || attr == "cn" || attr == "html" || typeof o[attr] == "function") continue;
            if(attr == "style"){
                var s = o["style"];
                if(typeof s == "function"){
                    s = s.call();
                }
                if(typeof s == "string"){
                    b += ' style="' + s + '"';
                }else if(typeof s == "object"){
                    b += ' style="';
                    for(var key in s){
                        if(typeof s[key] != "function"){
                            b += key + ":" + s[key] + ";";
                        }
                    }
                    b += '"';
                }
            }else{
                if(attr == "cls"){
                    b += ' class="' + o["cls"] + '"';
                }else if(attr == "htmlFor"){
                    b += ' for="' + o["htmlFor"] + '"';
                }else{
                    b += " " + attr + '="' + o[attr] + '"';
                }
            }
        }
        if(emptyTags.test(o.tag)){
            b += "/>";
        }else{
            b += ">";
            var cn = o.children || o.cn;
            if(cn){
                b += createHtml(cn);
            } else if(o.html){
                b += o.html;
            }
            b += "</" + o.tag + ">";
        }
        return b;
    };

    // build as dom
    /** @ignore */
    var createDom = function(o, parentNode){
        var el;
        if (Ext.isArray(o)) {                       // Allow Arrays of siblings to be inserted
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
            Ext.DomHelper.applyStyles(el, o.style);
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

    var ieTable = function(depth, s, h, e){
        tempTableEl.innerHTML = [s, h, e].join('');
        var i = -1, el = tempTableEl;
        while(++i < depth){
            el = el.firstChild;
        }
        return el;
    };

    // kill repeat to save bytes
    var ts = '<table>',
        te = '</table>',
        tbs = ts+'<tbody>',
        tbe = '</tbody>'+te,
        trs = tbs + '<tr>',
        tre = '</tr>'+tbe;

    /**
     * @ignore
     * Nasty code for IE's broken table implementation
     */
    var insertIntoTable = function(tag, where, el, html){
        if(!tempTableEl){
            tempTableEl = document.createElement('div');
        }
        var node;
        var before = null;
        if(tag == 'td'){
            if(where == 'afterbegin' || where == 'beforeend'){ // INTO a TD
                return;
            }
            if(where == 'beforebegin'){
                before = el;
                el = el.parentNode;
            } else{
                before = el.nextSibling;
                el = el.parentNode;
            }
            node = ieTable(4, trs, html, tre);
        }
        else if(tag == 'tr'){
            if(where == 'beforebegin'){
                before = el;
                el = el.parentNode;
                node = ieTable(3, tbs, html, tbe);
            } else if(where == 'afterend'){
                before = el.nextSibling;
                el = el.parentNode;
                node = ieTable(3, tbs, html, tbe);
            } else{ // INTO a TR
                if(where == 'afterbegin'){
                    before = el.firstChild;
                }
                node = ieTable(4, trs, html, tre);
            }
        } else if(tag == 'tbody'){
            if(where == 'beforebegin'){
                before = el;
                el = el.parentNode;
                node = ieTable(2, ts, html, te);
            } else if(where == 'afterend'){
                before = el.nextSibling;
                el = el.parentNode;
                node = ieTable(2, ts, html, te);
            } else{
                if(where == 'afterbegin'){
                    before = el.firstChild;
                }
                node = ieTable(3, tbs, html, tbe);
            }
        } else{ // TABLE
            if(where == 'beforebegin' || where == 'afterend'){ // OUTSIDE the table
                return;
            }
            if(where == 'afterbegin'){
                before = el.firstChild;
            }
            node = ieTable(2, ts, html, te);
        }
        el.insertBefore(node, before);
        return node;
    };


    return {
    /** True to force the use of DOM instead of html fragments @type Boolean */
    useDom : false,

    /**
     * Returns the markup for the passed Element(s) config.
     * @param {Object} o The DOM object spec (and children)
     * @return {String}
     */
    markup : function(o){
        return createHtml(o);
    },

    /**
     * Applies a style specification to an element.
     * @param {String/HTMLElement} el The element to apply styles to
     * @param {String/Object/Function} styles A style specification string eg "width:100px", or object in the form {width:"100px"}, or
     * a function which returns such a specification.
     */
    applyStyles : function(el, styles){
        if(styles){
           el = Ext.fly(el);
           if(typeof styles == "string"){
               var re = /\s?([a-z\-]*)\:\s?([^;]*);?/gi;
               var matches;
               while ((matches = re.exec(styles)) != null){
                   el.setStyle(matches[1], matches[2]);
               }
           }else if (typeof styles == "object"){
               for (var style in styles){
                  el.setStyle(style, styles[style]);
               }
           }else if (typeof styles == "function"){
                Ext.DomHelper.applyStyles(el, styles.call());
           }
        }
    },

    /**
     * Inserts an HTML fragment into the DOM.
     * @param {String} where Where to insert the html in relation to el - beforeBegin, afterBegin, beforeEnd, afterEnd.
     * @param {HTMLElement} el The context element
     * @param {String} html The HTML fragmenet
     * @return {HTMLElement} The new node
     */
    insertHtml : function(where, el, html){
        where = where.toLowerCase();
        if(el.insertAdjacentHTML){
            if(tableRe.test(el.tagName)){
                var rs;
                if(rs = insertIntoTable(el.tagName.toLowerCase(), where, el, html)){
                    return rs;
                }
            }
            switch(where){
                case "beforebegin":
                    el.insertAdjacentHTML('BeforeBegin', html);
                    return el.previousSibling;
                case "afterbegin":
                    el.insertAdjacentHTML('AfterBegin', html);
                    return el.firstChild;
                case "beforeend":
                    el.insertAdjacentHTML('BeforeEnd', html);
                    return el.lastChild;
                case "afterend":
                    el.insertAdjacentHTML('AfterEnd', html);
                    return el.nextSibling;
            }
            throw 'Illegal insertion point -> "' + where + '"';
        }
        var range = el.ownerDocument.createRange();
        var frag;
        switch(where){
             case "beforebegin":
                range.setStartBefore(el);
                frag = range.createContextualFragment(html);
                el.parentNode.insertBefore(frag, el);
                return el.previousSibling;
             case "afterbegin":
                if(el.firstChild){
                    range.setStartBefore(el.firstChild);
                    frag = range.createContextualFragment(html);
                    el.insertBefore(frag, el.firstChild);
                    return el.firstChild;
                }else{
                    el.innerHTML = html;
                    return el.firstChild;
                }
            case "beforeend":
                if(el.lastChild){
                    range.setStartAfter(el.lastChild);
                    frag = range.createContextualFragment(html);
                    el.appendChild(frag);
                    return el.lastChild;
                }else{
                    el.innerHTML = html;
                    return el.lastChild;
                }
            case "afterend":
                range.setStartAfter(el);
                frag = range.createContextualFragment(html);
                el.parentNode.insertBefore(frag, el.nextSibling);
                return el.nextSibling;
            }
            throw 'Illegal insertion point -> "' + where + '"';
    },

    /**
     * Creates new DOM element(s) and inserts them before el.
     * @param {Mixed} el The context element
     * @param {Object/String} o The DOM object spec (and children) or raw HTML blob
     * @param {Boolean} returnElement (optional) true to return a Ext.Element
     * @return {HTMLElement/Ext.Element} The new node
     */
    insertBefore : function(el, o, returnElement){
        return this.doInsert(el, o, returnElement, "beforeBegin");
    },

    /**
     * Creates new DOM element(s) and inserts them after el.
     * @param {Mixed} el The context element
     * @param {Object} o The DOM object spec (and children)
     * @param {Boolean} returnElement (optional) true to return a Ext.Element
     * @return {HTMLElement/Ext.Element} The new node
     */
    insertAfter : function(el, o, returnElement){
        return this.doInsert(el, o, returnElement, "afterEnd", "nextSibling");
    },

    /**
     * Creates new DOM element(s) and inserts them as the first child of el.
     * @param {Mixed} el The context element
     * @param {Object/String} o The DOM object spec (and children) or raw HTML blob
     * @param {Boolean} returnElement (optional) true to return a Ext.Element
     * @return {HTMLElement/Ext.Element} The new node
     */
    insertFirst : function(el, o, returnElement){
        return this.doInsert(el, o, returnElement, "afterBegin", "firstChild");
    },

    // private
    doInsert : function(el, o, returnElement, pos, sibling){
        el = Ext.getDom(el);
        var newNode;
        if(this.useDom){
            newNode = createDom(o, null);
            (sibling === "firstChild" ? el : el.parentNode).insertBefore(newNode, sibling ? el[sibling] : el);
        }else{
            var html = createHtml(o);
            newNode = this.insertHtml(pos, el, html);
        }
        return returnElement ? Ext.get(newNode, true) : newNode;
    },

    /**
     * Creates new DOM element(s) and appends them to el.
     * @param {Mixed} el The context element
     * @param {Object/String} o The DOM object spec (and children) or raw HTML blob
     * @param {Boolean} returnElement (optional) true to return a Ext.Element
     * @return {HTMLElement/Ext.Element} The new node
     */
    append : function(el, o, returnElement){
        el = Ext.getDom(el);
        var newNode;
        if(this.useDom){
            newNode = createDom(o, null);
            el.appendChild(newNode);
        }else{
            var html = createHtml(o);
            newNode = this.insertHtml("beforeEnd", el, html);
        }
        return returnElement ? Ext.get(newNode, true) : newNode;
    },

    /**
     * Creates new DOM element(s) and overwrites the contents of el with them.
     * @param {Mixed} el The context element
     * @param {Object/String} o The DOM object spec (and children) or raw HTML blob
     * @param {Boolean} returnElement (optional) true to return a Ext.Element
     * @return {HTMLElement/Ext.Element} The new node
     */
    overwrite : function(el, o, returnElement){
        el = Ext.getDom(el);
        el.innerHTML = createHtml(o);
        return returnElement ? Ext.get(el.firstChild, true) : el.firstChild;
    },

    /**
     * Creates a new Ext.Template from the DOM object spec.
     * @param {Object} o The DOM object spec (and children)
     * @return {Ext.Template} The new template
     */
    createTemplate : function(o){
        var html = createHtml(o);
        return new Ext.Template(html);
    }
    };
}();

/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
* @class Ext.Template
* Represents an HTML fragment template. Templates can be precompiled for greater performance.
* For a list of available format functions, see {@link Ext.util.Format}.<br />
* Usage:
<pre><code>
var t = new Ext.Template(
    '&lt;div name="{id}"&gt;',
        '&lt;span class="{cls}"&gt;{name:trim} {value:ellipsis(10)}&lt;/span&gt;',
    '&lt;/div&gt;'
);
t.append('some-element', {id: 'myid', cls: 'myclass', name: 'foo', value: 'bar'});
</code></pre>
* For more information see this blog post with examples: <a href="http://www.jackslocum.com/blog/2006/10/06/domhelper-create-elements-using-dom-html-fragments-or-templates/">DomHelper - Create Elements using DOM, HTML fragments and Templates</a>.
* @constructor
* @param {String/Array} html The HTML fragment or an array of fragments to join("") or multiple arguments to join("")
*/
Ext.Template = function(html){
    var a = arguments;
    if(Ext.isArray(html)){
        html = html.join("");
    }else if(a.length > 1){
        var buf = [];
        for(var i = 0, len = a.length; i < len; i++){
            if(typeof a[i] == 'object'){
                Ext.apply(this, a[i]);
            }else{
                buf[buf.length] = a[i];
            }
        }
        html = buf.join('');
    }
    /**@private*/
    this.html = html;
    if(this.compiled){
        this.compile();
    }
};
Ext.Template.prototype = {
    /**
     * Returns an HTML fragment of this template with the specified values applied.
     * @param {Object/Array} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @return {String} The HTML fragment
     */
    applyTemplate : function(values){
        if(this.compiled){
            return this.compiled(values);
        }
        var useF = this.disableFormats !== true;
        var fm = Ext.util.Format, tpl = this;
        var fn = function(m, name, format, args){
            if(format && useF){
                if(format.substr(0, 5) == "this."){
                    return tpl.call(format.substr(5), values[name], values);
                }else{
                    if(args){
                        // quoted values are required for strings in compiled templates,
                        // but for non compiled we need to strip them
                        // quoted reversed for jsmin
                        var re = /^\s*['"](.*)["']\s*$/;
                        args = args.split(',');
                        for(var i = 0, len = args.length; i < len; i++){
                            args[i] = args[i].replace(re, "$1");
                        }
                        args = [values[name]].concat(args);
                    }else{
                        args = [values[name]];
                    }
                    return fm[format].apply(fm, args);
                }
            }else{
                return values[name] !== undefined ? values[name] : "";
            }
        };
        return this.html.replace(this.re, fn);
    },

    /**
     * Sets the HTML used as the template and optionally compiles it.
     * @param {String} html
     * @param {Boolean} compile (optional) True to compile the template (defaults to undefined)
     * @return {Ext.Template} this
     */
    set : function(html, compile){
        this.html = html;
        this.compiled = null;
        if(compile){
            this.compile();
        }
        return this;
    },

    /**
     * True to disable format functions (defaults to false)
     * @type Boolean
     */
    disableFormats : false,

    /**
    * The regular expression used to match template variables
    * @type RegExp
    * @property
    */
    re : /\{([\w-]+)(?:\:([\w\.]*)(?:\((.*?)?\))?)?\}/g,

    /**
     * Compiles the template into an internal function, eliminating the RegEx overhead.
     * @return {Ext.Template} this
     */
    compile : function(){
        var fm = Ext.util.Format;
        var useF = this.disableFormats !== true;
        var sep = Ext.isGecko ? "+" : ",";
        var fn = function(m, name, format, args){
            if(format && useF){
                args = args ? ',' + args : "";
                if(format.substr(0, 5) != "this."){
                    format = "fm." + format + '(';
                }else{
                    format = 'this.call("'+ format.substr(5) + '", ';
                    args = ", values";
                }
            }else{
                args= ''; format = "(values['" + name + "'] == undefined ? '' : ";
            }
            return "'"+ sep + format + "values['" + name + "']" + args + ")"+sep+"'";
        };
        var body;
        // branched to use + in gecko and [].join() in others
        if(Ext.isGecko){
            body = "this.compiled = function(values){ return '" +
                   this.html.replace(/\\/g, '\\\\').replace(/(\r\n|\n)/g, '\\n').replace(/'/g, "\\'").replace(this.re, fn) +
                    "';};";
        }else{
            body = ["this.compiled = function(values){ return ['"];
            body.push(this.html.replace(/\\/g, '\\\\').replace(/(\r\n|\n)/g, '\\n').replace(/'/g, "\\'").replace(this.re, fn));
            body.push("'].join('');};");
            body = body.join('');
        }
        eval(body);
        return this;
    },

    // private function used to call members
    call : function(fnName, value, allValues){
        return this[fnName](value, allValues);
    },

    /**
     * Applies the supplied values to the template and inserts the new node(s) as the first child of el.
     * @param {Mixed} el The context element
     * @param {Object/Array} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @param {Boolean} returnElement (optional) true to return a Ext.Element (defaults to undefined)
     * @return {HTMLElement/Ext.Element} The new node or Element
     */
    insertFirst: function(el, values, returnElement){
        return this.doInsert('afterBegin', el, values, returnElement);
    },

    /**
     * Applies the supplied values to the template and inserts the new node(s) before el.
     * @param {Mixed} el The context element
     * @param {Object/Array} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @param {Boolean} returnElement (optional) true to return a Ext.Element (defaults to undefined)
     * @return {HTMLElement/Ext.Element} The new node or Element
     */
    insertBefore: function(el, values, returnElement){
        return this.doInsert('beforeBegin', el, values, returnElement);
    },

    /**
     * Applies the supplied values to the template and inserts the new node(s) after el.
     * @param {Mixed} el The context element
     * @param {Object/Array} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @param {Boolean} returnElement (optional) true to return a Ext.Element (defaults to undefined)
     * @return {HTMLElement/Ext.Element} The new node or Element
     */
    insertAfter : function(el, values, returnElement){
        return this.doInsert('afterEnd', el, values, returnElement);
    },

    /**
     * Applies the supplied values to the template and appends the new node(s) to el.
     * @param {Mixed} el The context element
     * @param {Object/Array} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @param {Boolean} returnElement (optional) true to return a Ext.Element (defaults to undefined)
     * @return {HTMLElement/Ext.Element} The new node or Element
     */
    append : function(el, values, returnElement){
        return this.doInsert('beforeEnd', el, values, returnElement);
    },

    doInsert : function(where, el, values, returnEl){
        el = Ext.getDom(el);
        var newNode = Ext.DomHelper.insertHtml(where, el, this.applyTemplate(values));
        return returnEl ? Ext.get(newNode, true) : newNode;
    },

    /**
     * Applies the supplied values to the template and overwrites the content of el with the new node(s).
     * @param {Mixed} el The context element
     * @param {Object/Array} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @param {Boolean} returnElement (optional) true to return a Ext.Element (defaults to undefined)
     * @return {HTMLElement/Ext.Element} The new node or Element
     */
    overwrite : function(el, values, returnElement){
        el = Ext.getDom(el);
        el.innerHTML = this.applyTemplate(values);
        return returnElement ? Ext.get(el.firstChild, true) : el.firstChild;
    }
};
/**
 * Alias for {@link #applyTemplate}
 * Returns an HTML fragment of this template with the specified values applied.
 * @param {Object/Array} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
 * @return {String} The HTML fragment
 * @member Ext.Template
 * @method apply
 */
Ext.Template.prototype.apply = Ext.Template.prototype.applyTemplate;

// backwards compat
Ext.DomHelper.Template = Ext.Template;

/**
 * Creates a template from the passed element's value (<i>display:none</i> textarea, preferred) or innerHTML.
 * @param {String/HTMLElement} el A DOM element or its id
 * @param {Object} config A configuration object
 * @return {Ext.Template} The created template
 * @static
 */
Ext.Template.from = function(el, config){
    el = Ext.getDom(el);
    return new Ext.Template(el.value || el.innerHTML, config || '');
};
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
* @class Ext.XTemplate
* @extends Ext.Template
* <p>A template class that supports advanced functionality like autofilling arrays, conditional processing with
* basic comparison operators, sub-templates, basic math function support, special built-in template variables,
* inline code execution and more.  XTemplate also provides the templating mechanism built into {@link Ext.DataView}.</p>
* <p>XTemplate supports many special tags and built-in operators that aren't defined as part of the API, but are
* supported in the templates that can be created.  The following examples demonstrate all of the supported features.
* This is the data object used for reference in each code example:</p>
* <pre><code>
var data = {
    name: 'Jack Slocum',
    title: 'Lead Developer',
    company: 'Ext JS, LLC',
    email: 'jack@extjs.com',
    address: '4 Red Bulls Drive',
    city: 'Cleveland',
    state: 'Ohio',
    zip: '44102',
    drinks: ['Red Bull', 'Coffee', 'Water'],
    kids: [{
        name: 'Sara Grace',
        age:3
    },{
        name: 'Zachary',
        age:2
    },{
        name: 'John James',
        age:0
    }]
};
</code></pre>
* <p><b>Auto filling of arrays and scope switching</b><br/>Using the <tt>tpl</tt> tag and the <tt>for</tt> operator,
* you can switch to the scope of the object specified by <tt>for</tt> and access its members to populate the template.
* If the variable in <tt>for</tt> is an array, it will auto-fill, repeating the template block inside the <tt>tpl</tt>
* tag for each item in the array:</p>
* <pre><code>
var tpl = new Ext.XTemplate(
    '&lt;p>Name: {name}&lt;/p>',
    '&lt;p>Title: {title}&lt;/p>',
    '&lt;p>Company: {company}&lt;/p>',
    '&lt;p>Kids: ',
    '&lt;tpl for="kids">',
        '&lt;p>{name}&lt;/p>',
    '&lt;/tpl>&lt;/p>'
);
tpl.overwrite(panel.body, data);
</code></pre>
* <p><b>Access to parent object from within sub-template scope</b><br/>When processing a sub-template, for example while
* looping through a child array, you can access the parent object's members via the <tt>parent</tt> object:</p>
* <pre><code>
var tpl = new Ext.XTemplate(
    '&lt;p>Name: {name}&lt;/p>',
    '&lt;p>Kids: ',
    '&lt;tpl for="kids">',
        '&lt;tpl if="age &amp;gt; 1">',  // <-- Note that the &gt; is encoded
            '&lt;p>{name}&lt;/p>',
            '&lt;p>Dad: {parent.name}&lt;/p>',
        '&lt;/tpl>',
    '&lt;/tpl>&lt;/p>'
);
tpl.overwrite(panel.body, data);
</code></pre>
* <p><b>Array item index and basic math support</b> <br/>While processing an array, the special variable <tt>{#}</tt>
* will provide the current array index + 1 (starts at 1, not 0). Templates also support the basic math operators
* + - * and / that can be applied directly on numeric data values:</p>
* <pre><code>
var tpl = new Ext.XTemplate(
    '&lt;p>Name: {name}&lt;/p>',
    '&lt;p>Kids: ',
    '&lt;tpl for="kids">',
        '&lt;tpl if="age &amp;gt; 1">',  // <-- Note that the &gt; is encoded
            '&lt;p>{#}: {name}&lt;/p>',  // <-- Auto-number each item
            '&lt;p>In 5 Years: {age+5}&lt;/p>',  // <-- Basic math
            '&lt;p>Dad: {parent.name}&lt;/p>',
        '&lt;/tpl>',
    '&lt;/tpl>&lt;/p>'
);
tpl.overwrite(panel.body, data);
</code></pre>
* <p><b>Auto-rendering of flat arrays</b> <br/>Flat arrays that contain values (and not objects) can be auto-rendered
* using the special <tt>{.}</tt> variable inside a loop.  This variable will represent the value of
* the array at the current index:</p>
* <pre><code>
var tpl = new Ext.XTemplate(
    '&lt;p>{name}\'s favorite beverages:&lt;/p>',
    '&lt;tpl for="drinks">',
       '&lt;div> - {.}&lt;/div>',
    '&lt;/tpl>'
);
tpl.overwrite(panel.body, data);
</code></pre>
* <p><b>Basic conditional logic</b> <br/>Using the <tt>tpl</tt> tag and the <tt>if</tt>
* operator you can provide conditional checks for deciding whether or not to render specific parts of the template.
* Note that there is no <tt>else</tt> operator &mdash; if needed, you should use two opposite <tt>if</tt> statements.
* Properly-encoded attributes are required as seen in the following example:</p>
* <pre><code>
var tpl = new Ext.XTemplate(
    '&lt;p>Name: {name}&lt;/p>',
    '&lt;p>Kids: ',
    '&lt;tpl for="kids">',
        '&lt;tpl if="age &amp;gt; 1">',  // <-- Note that the &gt; is encoded
            '&lt;p>{name}&lt;/p>',
        '&lt;/tpl>',
    '&lt;/tpl>&lt;/p>'
);
tpl.overwrite(panel.body, data);
</code></pre>
* <p><b>Ability to execute arbitrary inline code</b> <br/>In an XTemplate, anything between {[ ... ]}  is considered
* code to be executed in the scope of the template. There are some special variables available in that code:
* <ul>
* <li><b><tt>values</tt></b>: The values in the current scope. If you are using scope changing sub-templates, you
* can change what <tt>values</tt> is.</li>
* <li><b><tt>parent</tt></b>: The scope (values) of the ancestor template.</li>
* <li><b><tt>xindex</tt></b>: If you are in a looping template, the index of the loop you are in (1-based).</li>
* <li><b><tt>xcount</tt></b>: If you are in a looping template, the total length of the array you are looping.</li>
* <li><b><tt>fm</tt></b>: An alias for <tt>Ext.util.Format</tt>.</li>
* </ul>
* This example demonstrates basic row striping using an inline code block and the <tt>xindex</tt> variable:</p>
* <pre><code>
var tpl = new Ext.XTemplate(
    '&lt;p>Name: {name}&lt;/p>',
    '&lt;p>Company: {[values.company.toUpperCase() + ', ' + values.title]}&lt;/p>',
    '&lt;p>Kids: ',
    '&lt;tpl for="kids">',
       '&lt;div class="{[xindex % 2 === 0 ? "even" : "odd"]}">',
        '{name}',
        '&lt;/div>',
    '&lt;/tpl>&lt;/p>'
);
tpl.overwrite(panel.body, data);
</code></pre>
* <p><b>Template member functions</b> <br/>One or more member functions can be defined directly on the config
* object passed into the XTemplate constructor for more complex processing:</p>
* <pre><code>
var tpl = new Ext.XTemplate(
    '&lt;p>Name: {name}&lt;/p>',
    '&lt;p>Kids: ',
    '&lt;tpl for="kids">',
        '&lt;tpl if="this.isGirl(name)">',
            '&lt;p>Girl: {name} - {age}&lt;/p>',
        '&lt;/tpl>',
        '&lt;tpl if="this.isGirl(name) == false">',
            '&lt;p>Boy: {name} - {age}&lt;/p>',
        '&lt;/tpl>',
        '&lt;tpl if="this.isBaby(age)">',
            '&lt;p>{name} is a baby!&lt;/p>',
        '&lt;/tpl>',
    '&lt;/tpl>&lt;/p>', {
     isGirl: function(name){
         return name == 'Sara Grace';
     },
     isBaby: function(age){
        return age < 1;
     }
});
tpl.overwrite(panel.body, data);
</code></pre>
* @constructor
* @param {String/Array/Object} parts The HTML fragment or an array of fragments to join(""), or multiple arguments
* to join("") that can also include a config object
*/
Ext.XTemplate = function(){
    Ext.XTemplate.superclass.constructor.apply(this, arguments);
    var s = this.html;

    s = ['<tpl>', s, '</tpl>'].join('');

    var re = /<tpl\b[^>]*>((?:(?=([^<]+))\2|<(?!tpl\b[^>]*>))*?)<\/tpl>/;

    var nameRe = /^<tpl\b[^>]*?for="(.*?)"/;
    var ifRe = /^<tpl\b[^>]*?if="(.*?)"/;
    var execRe = /^<tpl\b[^>]*?exec="(.*?)"/;
    var m, id = 0;
    var tpls = [];

    while(m = s.match(re)){
       var m2 = m[0].match(nameRe);
       var m3 = m[0].match(ifRe);
       var m4 = m[0].match(execRe);
       var exp = null, fn = null, exec = null;
       var name = m2 && m2[1] ? m2[1] : '';
       if(m3){
           exp = m3 && m3[1] ? m3[1] : null;
           if(exp){
               fn = new Function('values', 'parent', 'xindex', 'xcount', 'with(values){ return '+(Ext.util.Format.htmlDecode(exp))+'; }');
           }
       }
       if(m4){
           exp = m4 && m4[1] ? m4[1] : null;
           if(exp){
               exec = new Function('values', 'parent', 'xindex', 'xcount', 'with(values){ '+(Ext.util.Format.htmlDecode(exp))+'; }');
           }
       }
       if(name){
           switch(name){
               case '.': name = new Function('values', 'parent', 'with(values){ return values; }'); break;
               case '..': name = new Function('values', 'parent', 'with(values){ return parent; }'); break;
               default: name = new Function('values', 'parent', 'with(values){ return '+name+'; }');
           }
       }
       tpls.push({
            id: id,
            target: name,
            exec: exec,
            test: fn,
            body: m[1]||''
        });
       s = s.replace(m[0], '{xtpl'+ id + '}');
       ++id;
    }
    for(var i = tpls.length-1; i >= 0; --i){
        this.compileTpl(tpls[i]);
    }
    this.master = tpls[tpls.length-1];
    this.tpls = tpls;
};
Ext.extend(Ext.XTemplate, Ext.Template, {
    // private
    re : /\{([\w-\.\#]+)(?:\:([\w\.]*)(?:\((.*?)?\))?)?(\s?[\+\-\*\\]\s?[\d\.\+\-\*\\\(\)]+)?\}/g,
    // private
    codeRe : /\{\[((?:\\\]|.|\n)*?)\]\}/g,

    // private
    applySubTemplate : function(id, values, parent, xindex, xcount){
        var t = this.tpls[id];
        if(t.test && !t.test.call(this, values, parent, xindex, xcount)){
            return '';
        }
        if(t.exec && t.exec.call(this, values, parent, xindex, xcount)){
            return '';
        }
        var vs = t.target ? t.target.call(this, values, parent) : values;
        parent = t.target ? values : parent;
        if(t.target && Ext.isArray(vs)){
            var buf = [];
            for(var i = 0, len = vs.length; i < len; i++){
                buf[buf.length] = t.compiled.call(this, vs[i], parent, i+1, len);
            }
            return buf.join('');
        }
        return t.compiled.call(this, vs, parent, xindex, xcount);
    },

    // private
    compileTpl : function(tpl){
        var fm = Ext.util.Format;
        var useF = this.disableFormats !== true;
        var sep = Ext.isGecko ? "+" : ",";
        var fn = function(m, name, format, args, math){
            if(name.substr(0, 4) == 'xtpl'){
                return "'"+ sep +'this.applySubTemplate('+name.substr(4)+', values, parent, xindex, xcount)'+sep+"'";
            }
            var v;
            if(name === '.'){
                v = 'values';
            }else if(name === '#'){
                v = 'xindex';
            }else if(name.indexOf('.') != -1){
                v = name;
            }else{
                v = "values['" + name + "']";
            }
            if(math){
                v = '(' + v + math + ')';
            }
            if(format && useF){
                args = args ? ',' + args : "";
                if(format.substr(0, 5) != "this."){
                    format = "fm." + format + '(';
                }else{
                    format = 'this.call("'+ format.substr(5) + '", ';
                    args = ", values";
                }
            }else{
                args= ''; format = "("+v+" === undefined ? '' : ";
            }
            return "'"+ sep + format + v + args + ")"+sep+"'";
        };
        var codeFn = function(m, code){
            return "'"+ sep +'('+code+')'+sep+"'";
        };

        var body;
        // branched to use + in gecko and [].join() in others
        if(Ext.isGecko){
            body = "tpl.compiled = function(values, parent, xindex, xcount){ return '" +
                   tpl.body.replace(/(\r\n|\n)/g, '\\n').replace(/'/g, "\\'").replace(this.re, fn).replace(this.codeRe, codeFn) +
                    "';};";
        }else{
            body = ["tpl.compiled = function(values, parent, xindex, xcount){ return ['"];
            body.push(tpl.body.replace(/(\r\n|\n)/g, '\\n').replace(/'/g, "\\'").replace(this.re, fn).replace(this.codeRe, codeFn));
            body.push("'].join('');};");
            body = body.join('');
        }
        eval(body);
        return this;
    },

    /**
     * Returns an HTML fragment of this template with the specified values applied.
     * @param {Object} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @return {String} The HTML fragment
     */
    applyTemplate : function(values){
        return this.master.compiled.call(this, values, {}, 1, 1);
    },

    /**
     * Compile the template to a function for optimized performance.  Recommended if the template will be used frequently.
     * @return {Function} The compiled function
     */
    compile : function(){return this;}

    /**
     * @property re
     * @hide
     */
    /**
     * @property disableFormats
     * @hide
     */
    /**
     * @method set
     * @hide
     */

});
/**
 * Alias for {@link #applyTemplate}
 * Returns an HTML fragment of this template with the specified values applied.
 * @param {Object/Array} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
 * @return {String} The HTML fragment
 * @member Ext.XTemplate
 * @method apply
 */
Ext.XTemplate.prototype.apply = Ext.XTemplate.prototype.applyTemplate;

/**
 * Creates a template from the passed element's value (<i>display:none</i> textarea, preferred) or innerHTML.
 * @param {String/HTMLElement} el A DOM element or its id
 * @return {Ext.Template} The created template
 * @static
 */
Ext.XTemplate.from = function(el){
    el = Ext.getDom(el);
    return new Ext.XTemplate(el.value || el.innerHTML);
};
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/*
 * This is code is also distributed under MIT license for use
 * with jQuery and prototype JavaScript libraries.
 */
/**
 * @class Ext.DomQuery
Provides high performance selector/xpath processing by compiling queries into reusable functions. New pseudo classes and matchers can be plugged. It works on HTML and XML documents (if a content node is passed in).
<p>
DomQuery supports most of the <a href="http://www.w3.org/TR/2005/WD-css3-selectors-20051215/#selectors">CSS3 selectors spec</a>, along with some custom selectors and basic XPath.</p>

<p>
All selectors, attribute filters and pseudos below can be combined infinitely in any order. For example "div.foo:nth-child(odd)[@foo=bar].bar:first" would be a perfectly valid selector. Node filters are processed in the order in which they appear, which allows you to optimize your queries for your document structure.
</p>
<h4>Element Selectors:</h4>
<ul class="list">
    <li> <b>*</b> any element</li>
    <li> <b>E</b> an element with the tag E</li>
    <li> <b>E F</b> All descendent elements of E that have the tag F</li>
    <li> <b>E > F</b> or <b>E/F</b> all direct children elements of E that have the tag F</li>
    <li> <b>E + F</b> all elements with the tag F that are immediately preceded by an element with the tag E</li>
    <li> <b>E ~ F</b> all elements with the tag F that are preceded by a sibling element with the tag E</li>
</ul>
<h4>Attribute Selectors:</h4>
<p>The use of @ and quotes are optional. For example, div[@foo='bar'] is also a valid attribute selector.</p>
<ul class="list">
    <li> <b>E[foo]</b> has an attribute "foo"</li>
    <li> <b>E[foo=bar]</b> has an attribute "foo" that equals "bar"</li>
    <li> <b>E[foo^=bar]</b> has an attribute "foo" that starts with "bar"</li>
    <li> <b>E[foo$=bar]</b> has an attribute "foo" that ends with "bar"</li>
    <li> <b>E[foo*=bar]</b> has an attribute "foo" that contains the substring "bar"</li>
    <li> <b>E[foo%=2]</b> has an attribute "foo" that is evenly divisible by 2</li>
    <li> <b>E[foo!=bar]</b> has an attribute "foo" that does not equal "bar"</li>
</ul>
<h4>Pseudo Classes:</h4>
<ul class="list">
    <li> <b>E:first-child</b> E is the first child of its parent</li>
    <li> <b>E:last-child</b> E is the last child of its parent</li>
    <li> <b>E:nth-child(<i>n</i>)</b> E is the <i>n</i>th child of its parent (1 based as per the spec)</li>
    <li> <b>E:nth-child(odd)</b> E is an odd child of its parent</li>
    <li> <b>E:nth-child(even)</b> E is an even child of its parent</li>
    <li> <b>E:only-child</b> E is the only child of its parent</li>
    <li> <b>E:checked</b> E is an element that is has a checked attribute that is true (e.g. a radio or checkbox) </li>
    <li> <b>E:first</b> the first E in the resultset</li>
    <li> <b>E:last</b> the last E in the resultset</li>
    <li> <b>E:nth(<i>n</i>)</b> the <i>n</i>th E in the resultset (1 based)</li>
    <li> <b>E:odd</b> shortcut for :nth-child(odd)</li>
    <li> <b>E:even</b> shortcut for :nth-child(even)</li>
    <li> <b>E:contains(foo)</b> E's innerHTML contains the substring "foo"</li>
    <li> <b>E:nodeValue(foo)</b> E contains a textNode with a nodeValue that equals "foo"</li>
    <li> <b>E:not(S)</b> an E element that does not match simple selector S</li>
    <li> <b>E:has(S)</b> an E element that has a descendent that matches simple selector S</li>
    <li> <b>E:next(S)</b> an E element whose next sibling matches simple selector S</li>
    <li> <b>E:prev(S)</b> an E element whose previous sibling matches simple selector S</li>
</ul>
<h4>CSS Value Selectors:</h4>
<ul class="list">
    <li> <b>E{display=none}</b> css value "display" that equals "none"</li>
    <li> <b>E{display^=none}</b> css value "display" that starts with "none"</li>
    <li> <b>E{display$=none}</b> css value "display" that ends with "none"</li>
    <li> <b>E{display*=none}</b> css value "display" that contains the substring "none"</li>
    <li> <b>E{display%=2}</b> css value "display" that is evenly divisible by 2</li>
    <li> <b>E{display!=none}</b> css value "display" that does not equal "none"</li>
</ul>
 * @singleton
 */
Ext.DomQuery = function(){
    var cache = {}, simpleCache = {}, valueCache = {};
    var nonSpace = /\S/;
    var trimRe = /^\s+|\s+$/g;
    var tplRe = /\{(\d+)\}/g;
    var modeRe = /^(\s?[\/>+~]\s?|\s|$)/;
    var tagTokenRe = /^(#)?([\w-\*]+)/;
    var nthRe = /(\d*)n\+?(\d*)/, nthRe2 = /\D/;

    function child(p, index){
        var i = 0;
        var n = p.firstChild;
        while(n){
            if(n.nodeType == 1){
               if(++i == index){
                   return n;
               }
            }
            n = n.nextSibling;
        }
        return null;
    };

    function next(n){
        while((n = n.nextSibling) && n.nodeType != 1);
        return n;
    };

    function prev(n){
        while((n = n.previousSibling) && n.nodeType != 1);
        return n;
    };

    function children(d){
        var n = d.firstChild, ni = -1;
 	    while(n){
 	        var nx = n.nextSibling;
 	        if(n.nodeType == 3 && !nonSpace.test(n.nodeValue)){
 	            d.removeChild(n);
 	        }else{
 	            n.nodeIndex = ++ni;
 	        }
 	        n = nx;
 	    }
 	    return this;
 	};

    function byClassName(c, a, v){
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

    function attrValue(n, attr){
        if(!n.tagName && typeof n.length != "undefined"){
            n = n[0];
        }
        if(!n){
            return null;
        }
        if(attr == "for"){
            return n.htmlFor;
        }
        if(attr == "class" || attr == "className"){
            return n.className;
        }
        return n.getAttribute(attr) || n[attr];

    };

    function getNodes(ns, mode, tagName){
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

    function concat(a, b){
        if(b.slice){
            return a.concat(b);
        }
        for(var i = 0, l = b.length; i < l; i++){
            a[a.length] = b[i];
        }
        return a;
    }

    function byTag(cs, tagName){
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

    function byId(cs, attr, id){
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

    function byAttribute(cs, attr, value, op, custom){
        var r = [], ri = -1, st = custom=="{";
        var f = Ext.DomQuery.operators[op];
        for(var i = 0, ci; ci = cs[i]; i++){
            var a;
            if(st){
                a = Ext.DomQuery.getStyle(ci, attr);
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

    function byPseudo(cs, name, value){
        return Ext.DomQuery.pseudos[name](cs, value);
    };

    // This is for IE MSXML which does not support expandos.
    // IE runs the same speed using setAttribute, however FF slows way down
    // and Safari completely fails so they need to continue to use expandos.
    var isIE = window.ActiveXObject ? true : false;

    // this eval is stop the compressor from
    // renaming the variable to something shorter
    eval("var batch = 30803;");

    var key = 30803;

    function nodupIEXml(cs){
        var d = ++key;
        cs[0].setAttribute("_nodup", d);
        var r = [cs[0]];
        for(var i = 1, len = cs.length; i < len; i++){
            var c = cs[i];
            if(!c.getAttribute("_nodup") != d){
                c.setAttribute("_nodup", d);
                r[r.length] = c;
            }
        }
        for(var i = 0, len = cs.length; i < len; i++){
            cs[i].removeAttribute("_nodup");
        }
        return r;
    }

    function nodup(cs){
        if(!cs){
            return [];
        }
        var len = cs.length, c, i, r = cs, cj, ri = -1;
        if(!len || typeof cs.nodeType != "undefined" || len == 1){
            return cs;
        }
        if(isIE && typeof cs[0].selectSingleNode != "undefined"){
            return nodupIEXml(cs);
        }
        var d = ++key;
        cs[0]._nodup = d;
        for(i = 1; c = cs[i]; i++){
            if(c._nodup != d){
                c._nodup = d;
            }else{
                r = [];
                for(var j = 0; j < i; j++){
                    r[++ri] = cs[j];
                }
                for(j = i+1; cj = cs[j]; j++){
                    if(cj._nodup != d){
                        cj._nodup = d;
                        r[++ri] = cj;
                    }
                }
                return r;
            }
        }
        return r;
    }

    function quickDiffIEXml(c1, c2){
        var d = ++key;
        for(var i = 0, len = c1.length; i < len; i++){
            c1[i].setAttribute("_qdiff", d);
        }
        var r = [];
        for(var i = 0, len = c2.length; i < len; i++){
            if(c2[i].getAttribute("_qdiff") != d){
                r[r.length] = c2[i];
            }
        }
        for(var i = 0, len = c1.length; i < len; i++){
           c1[i].removeAttribute("_qdiff");
        }
        return r;
    }

    function quickDiff(c1, c2){
        var len1 = c1.length;
        if(!len1){
            return c2;
        }
        if(isIE && c1[0].selectSingleNode){
            return quickDiffIEXml(c1, c2);
        }
        var d = ++key;
        for(var i = 0; i < len1; i++){
            c1[i]._qdiff = d;
        }
        var r = [];
        for(var i = 0, len = c2.length; i < len; i++){
            if(c2[i]._qdiff != d){
                r[r.length] = c2[i];
            }
        }
        return r;
    }

    function quickId(ns, mode, root, id){
        if(ns == root){
           var d = root.ownerDocument || root;
           return d.getElementById(id);
        }
        ns = getNodes(ns, mode, "*");
        return byId(ns, null, id);
    }

    return {
        getStyle : function(el, name){
            return Ext.fly(el).getStyle(name);
        },
        /**
         * Compiles a selector/xpath query into a reusable function. The returned function
         * takes one parameter "root" (optional), which is the context node from where the query should start.
         * @param {String} selector The selector/xpath query
         * @param {String} type (optional) Either "select" (the default) or "simple" for a simple selector match
         * @return {Function}
         */
        compile : function(path, type){
            type = type || "select";

            var fn = ["var f = function(root){\n var mode; ++batch; var n = root || document;\n"];
            var q = path, mode, lq;
            var tk = Ext.DomQuery.matchers;
            var tklen = tk.length;
            var mm;

            // accept leading mode switch
            var lmode = q.match(modeRe);
            if(lmode && lmode[1]){
                fn[fn.length] = 'mode="'+lmode[1].replace(trimRe, "")+'";';
                q = q.replace(lmode[1], "");
            }
            // strip leading slashes
            while(path.substr(0, 1)=="/"){
                path = path.substr(1);
            }

            while(q && lq != q){
                lq = q;
                var tm = q.match(tagTokenRe);
                if(type == "select"){
                    if(tm){
                        if(tm[1] == "#"){
                            fn[fn.length] = 'n = quickId(n, mode, root, "'+tm[2]+'");';
                        }else{
                            fn[fn.length] = 'n = getNodes(n, mode, "'+tm[2]+'");';
                        }
                        q = q.replace(tm[0], "");
                    }else if(q.substr(0, 1) != '@'){
                        fn[fn.length] = 'n = getNodes(n, mode, "*");';
                    }
                }else{
                    if(tm){
                        if(tm[1] == "#"){
                            fn[fn.length] = 'n = byId(n, null, "'+tm[2]+'");';
                        }else{
                            fn[fn.length] = 'n = byTag(n, "'+tm[2]+'");';
                        }
                        q = q.replace(tm[0], "");
                    }
                }
                while(!(mm = q.match(modeRe))){
                    var matched = false;
                    for(var j = 0; j < tklen; j++){
                        var t = tk[j];
                        var m = q.match(t.re);
                        if(m){
                            fn[fn.length] = t.select.replace(tplRe, function(x, i){
                                                    return m[i];
                                                });
                            q = q.replace(m[0], "");
                            matched = true;
                            break;
                        }
                    }
                    // prevent infinite loop on bad selector
                    if(!matched){
                        throw 'Error parsing selector, parsing failed at "' + q + '"';
                    }
                }
                if(mm[1]){
                    fn[fn.length] = 'mode="'+mm[1].replace(trimRe, "")+'";';
                    q = q.replace(mm[1], "");
                }
            }
            fn[fn.length] = "return nodup(n);\n}";
            eval(fn.join(""));
            return f;
        },

        /**
         * Selects a group of elements.
         * @param {String} selector The selector/xpath query (can be a comma separated list of selectors)
         * @param {Node} root (optional) The start of the query (defaults to document).
         * @return {Array}
         */
        select : function(path, root, type){
            if(!root || root == document){
                root = document;
            }
            if(typeof root == "string"){
                root = document.getElementById(root);
            }
            var paths = path.split(",");
            var results = [];
            for(var i = 0, len = paths.length; i < len; i++){
                var p = paths[i].replace(trimRe, "");
                if(!cache[p]){
                    cache[p] = Ext.DomQuery.compile(p);
                    if(!cache[p]){
                        throw p + " is not a valid selector";
                    }
                }
                var result = cache[p](root);
                if(result && result != document){
                    results = results.concat(result);
                }
            }
            if(paths.length > 1){
                return nodup(results);
            }
            return results;
        },

        /**
         * Selects a single element.
         * @param {String} selector The selector/xpath query
         * @param {Node} root (optional) The start of the query (defaults to document).
         * @return {Element}
         */
        selectNode : function(path, root){
            return Ext.DomQuery.select(path, root)[0];
        },

        /**
         * Selects the value of a node, optionally replacing null with the defaultValue.
         * @param {String} selector The selector/xpath query
         * @param {Node} root (optional) The start of the query (defaults to document).
         * @param {String} defaultValue
         * @return {String}
         */
        selectValue : function(path, root, defaultValue){
            path = path.replace(trimRe, "");
            if(!valueCache[path]){
                valueCache[path] = Ext.DomQuery.compile(path, "select");
            }
            var n = valueCache[path](root);
            n = n[0] ? n[0] : n;
            var v = (n && n.firstChild ? n.firstChild.nodeValue : null);
            return ((v === null||v === undefined||v==='') ? defaultValue : v);
        },

        /**
         * Selects the value of a node, parsing integers and floats. Returns the defaultValue, or 0 if none is specified.
         * @param {String} selector The selector/xpath query
         * @param {Node} root (optional) The start of the query (defaults to document).
         * @param {Number} defaultValue
         * @return {Number}
         */
        selectNumber : function(path, root, defaultValue){
            var v = Ext.DomQuery.selectValue(path, root, defaultValue || 0);
            return parseFloat(v);
        },

        /**
         * Returns true if the passed element(s) match the passed simple selector (e.g. div.some-class or span:first-child)
         * @param {String/HTMLElement/Array} el An element id, element or array of elements
         * @param {String} selector The simple selector to test
         * @return {Boolean}
         */
        is : function(el, ss){
            if(typeof el == "string"){
                el = document.getElementById(el);
            }
            var isArray = Ext.isArray(el);
            var result = Ext.DomQuery.filter(isArray ? el : [el], ss);
            return isArray ? (result.length == el.length) : (result.length > 0);
        },

        /**
         * Filters an array of elements to only include matches of a simple selector (e.g. div.some-class or span:first-child)
         * @param {Array} el An array of elements to filter
         * @param {String} selector The simple selector to test
         * @param {Boolean} nonMatches If true, it returns the elements that DON'T match
         * the selector instead of the ones that match
         * @return {Array}
         */
        filter : function(els, ss, nonMatches){
            ss = ss.replace(trimRe, "");
            if(!simpleCache[ss]){
                simpleCache[ss] = Ext.DomQuery.compile(ss, "simple");
            }
            var result = simpleCache[ss](els);
            return nonMatches ? quickDiff(result, els) : result;
        },

        /**
         * Collection of matching regular expressions and code snippets.
         */
        matchers : [{
                re: /^\.([\w-]+)/,
                select: 'n = byClassName(n, null, " {1} ");'
            }, {
                re: /^\:([\w-]+)(?:\(((?:[^\s>\/]*|.*?))\))?/,
                select: 'n = byPseudo(n, "{1}", "{2}");'
            },{
                re: /^(?:([\[\{])(?:@)?([\w-]+)\s?(?:(=|.=)\s?['"]?(.*?)["']?)?[\]\}])/,
                select: 'n = byAttribute(n, "{2}", "{4}", "{3}", "{1}");'
            }, {
                re: /^#([\w-]+)/,
                select: 'n = byId(n, null, "{1}");'
            },{
                re: /^@([\w-]+)/,
                select: 'return {firstChild:{nodeValue:attrValue(n, "{1}")}};'
            }
        ],

        /**
         * Collection of operator comparison functions. The default operators are =, !=, ^=, $=, *=, %=, |= and ~=.
         * New operators can be added as long as the match the format <i>c</i>= where <i>c</i> is any character other than space, &gt; &lt;.
         */
        operators : {
            "=" : function(a, v){
                return a == v;
            },
            "!=" : function(a, v){
                return a != v;
            },
            "^=" : function(a, v){
                return a && a.substr(0, v.length) == v;
            },
            "$=" : function(a, v){
                return a && a.substr(a.length-v.length) == v;
            },
            "*=" : function(a, v){
                return a && a.indexOf(v) !== -1;
            },
            "%=" : function(a, v){
                return (a % v) == 0;
            },
            "|=" : function(a, v){
                return a && (a == v || a.substr(0, v.length+1) == v+'-');
            },
            "~=" : function(a, v){
                return a && (' '+a+' ').indexOf(' '+v+' ') != -1;
            }
        },

        /**
         * Collection of "pseudo class" processors. Each processor is passed the current nodeset (array)
         * and the argument (if any) supplied in the selector.
         */
        pseudos : {
            "first-child" : function(c){
                var r = [], ri = -1, n;
                for(var i = 0, ci; ci = n = c[i]; i++){
                    while((n = n.previousSibling) && n.nodeType != 1);
                    if(!n){
                        r[++ri] = ci;
                    }
                }
                return r;
            },

            "last-child" : function(c){
                var r = [], ri = -1, n;
                for(var i = 0, ci; ci = n = c[i]; i++){
                    while((n = n.nextSibling) && n.nodeType != 1);
                    if(!n){
                        r[++ri] = ci;
                    }
                }
                return r;
            },

            "nth-child" : function(c, a) {
                var r = [], ri = -1;
                var m = nthRe.exec(a == "even" && "2n" || a == "odd" && "2n+1" || !nthRe2.test(a) && "n+" + a || a);
                var f = (m[1] || 1) - 0, l = m[2] - 0;
                for(var i = 0, n; n = c[i]; i++){
                    var pn = n.parentNode;
                    if (batch != pn._batch) {
                        var j = 0;
                        for(var cn = pn.firstChild; cn; cn = cn.nextSibling){
                            if(cn.nodeType == 1){
                               cn.nodeIndex = ++j;
                            }
                        }
                        pn._batch = batch;
                    }
                    if (f == 1) {
                        if (l == 0 || n.nodeIndex == l){
                            r[++ri] = n;
                        }
                    } else if ((n.nodeIndex + l) % f == 0){
                        r[++ri] = n;
                    }
                }

                return r;
            },

            "only-child" : function(c){
                var r = [], ri = -1;;
                for(var i = 0, ci; ci = c[i]; i++){
                    if(!prev(ci) && !next(ci)){
                        r[++ri] = ci;
                    }
                }
                return r;
            },

            "empty" : function(c){
                var r = [], ri = -1;
                for(var i = 0, ci; ci = c[i]; i++){
                    var cns = ci.childNodes, j = 0, cn, empty = true;
                    while(cn = cns[j]){
                        ++j;
                        if(cn.nodeType == 1 || cn.nodeType == 3){
                            empty = false;
                            break;
                        }
                    }
                    if(empty){
                        r[++ri] = ci;
                    }
                }
                return r;
            },

            "contains" : function(c, v){
                var r = [], ri = -1;
                for(var i = 0, ci; ci = c[i]; i++){
                    if((ci.textContent||ci.innerText||'').indexOf(v) != -1){
                        r[++ri] = ci;
                    }
                }
                return r;
            },

            "nodeValue" : function(c, v){
                var r = [], ri = -1;
                for(var i = 0, ci; ci = c[i]; i++){
                    if(ci.firstChild && ci.firstChild.nodeValue == v){
                        r[++ri] = ci;
                    }
                }
                return r;
            },

            "checked" : function(c){
                var r = [], ri = -1;
                for(var i = 0, ci; ci = c[i]; i++){
                    if(ci.checked == true){
                        r[++ri] = ci;
                    }
                }
                return r;
            },

            "not" : function(c, ss){
                return Ext.DomQuery.filter(c, ss, true);
            },

            "any" : function(c, selectors){
                var ss = selectors.split('|');
                var r = [], ri = -1, s;
                for(var i = 0, ci; ci = c[i]; i++){
                    for(var j = 0; s = ss[j]; j++){
                        if(Ext.DomQuery.is(ci, s)){
                            r[++ri] = ci;
                            break;
                        }
                    }
                }
                return r;
            },

            "odd" : function(c){
                return this["nth-child"](c, "odd");
            },

            "even" : function(c){
                return this["nth-child"](c, "even");
            },

            "nth" : function(c, a){
                return c[a-1] || [];
            },

            "first" : function(c){
                return c[0] || [];
            },

            "last" : function(c){
                return c[c.length-1] || [];
            },

            "has" : function(c, ss){
                var s = Ext.DomQuery.select;
                var r = [], ri = -1;
                for(var i = 0, ci; ci = c[i]; i++){
                    if(s(ss, ci).length > 0){
                        r[++ri] = ci;
                    }
                }
                return r;
            },

            "next" : function(c, ss){
                var is = Ext.DomQuery.is;
                var r = [], ri = -1;
                for(var i = 0, ci; ci = c[i]; i++){
                    var n = next(ci);
                    if(n && is(n, ss)){
                        r[++ri] = ci;
                    }
                }
                return r;
            },

            "prev" : function(c, ss){
                var is = Ext.DomQuery.is;
                var r = [], ri = -1;
                for(var i = 0, ci; ci = c[i]; i++){
                    var n = prev(ci);
                    if(n && is(n, ss)){
                        r[++ri] = ci;
                    }
                }
                return r;
            }
        }
    };
}();

/**
 * Selects an array of DOM nodes by CSS/XPath selector. Shorthand of {@link Ext.DomQuery#select}
 * @param {String} path The selector/xpath query
 * @param {Node} root (optional) The start of the query (defaults to document).
 * @return {Array}
 * @member Ext
 * @method query
 */
Ext.query = Ext.DomQuery.select;

/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.util.Observable
 * Abstract base class that provides a common interface for publishing events. Subclasses are expected to
 * to have a property "events" with all the events defined.<br>
 * For example:
 * <pre><code>
 Employee = function(name){
    this.name = name;
    this.addEvents({
        "fired" : true,
        "quit" : true
    });
 }
 Ext.extend(Employee, Ext.util.Observable);
</code></pre>
 */
Ext.util.Observable = function(){
    /**
     * @cfg {Object} listeners A config object containing one or more event handlers to be added to this
     * object during initialization.  This should be a valid listeners config object as specified in the
     * {@link #addListener} example for attaching multiple handlers at once.
     */
    if(this.listeners){
        this.on(this.listeners);
        delete this.listeners;
    }
};
Ext.util.Observable.prototype = {
    /**
     * Fires the specified event with the passed parameters (minus the event name).
     * @param {String} eventName
     * @param {Object...} args Variable number of parameters are passed to handlers
     * @return {Boolean} returns false if any of the handlers return false otherwise it returns true
     */
    fireEvent : function(){
        if(this.eventsSuspended !== true){
            var ce = this.events[arguments[0].toLowerCase()];
            if(typeof ce == "object"){
                return ce.fire.apply(ce, Array.prototype.slice.call(arguments, 1));
            }
        }
        return true;
    },

    // private
    filterOptRe : /^(?:scope|delay|buffer|single)$/,

    /**
     * Appends an event handler to this component
     * @param {String}   eventName The type of event to listen for
     * @param {Function} handler The method the event invokes
     * @param {Object}   scope (optional) The scope in which to execute the handler
     * function. The handler function's "this" context.
     * @param {Object}   options (optional) An object containing handler configuration
     * properties. This may contain any of the following properties:<ul>
     * <li><b>scope</b> : Object<p class="sub-desc">The scope in which to execute the handler function. The handler function's "this" context.</p></li>
     * <li><b>delay</b> : Number<p class="sub-desc">The number of milliseconds to delay the invocation of the handler after the event fires.</p></li>
     * <li><b>single</b> : Boolean<p class="sub-desc">True to add a handler to handle just the next firing of the event, and then remove itself.</p></li>
     * <li><b>buffer</b> : Number<p class="sub-desc">Causes the handler to be scheduled to run in an {@link Ext.util.DelayedTask} delayed
     * by the specified number of milliseconds. If the event fires again within that time, the original
     * handler is <em>not</em> invoked, but the new handler is scheduled in its place.</p></li>
     * </ul><br>
     * <p>
     * <b>Combining Options</b><br>
     * Using the options argument, it is possible to combine different types of listeners:<br>
     * <br>
     * A normalized, delayed, one-time listener that auto stops the event and passes a custom argument (forumId)
     * <pre><code>
el.on('click', this.onClick, this, {
    single: true,
    delay: 100,
    forumId: 4
});</code></pre>
     * <p>
     * <b>Attaching multiple handlers in 1 call</b><br>
      * The method also allows for a single argument to be passed which is a config object containing properties
     * which specify multiple handlers.
     * <p>
     * <pre><code>
foo.on({
    'click' : {
        fn: this.onClick,
        scope: this,
        delay: 100
    },
    'mouseover' : {
        fn: this.onMouseOver,
        scope: this
    },
    'mouseout' : {
        fn: this.onMouseOut,
        scope: this
    }
});</code></pre>
     * <p>
     * Or a shorthand syntax:<br>
     * <pre><code>
foo.on({
    'click' : this.onClick,
    'mouseover' : this.onMouseOver,
    'mouseout' : this.onMouseOut,
     scope: this
});</code></pre>
     */
    addListener : function(eventName, fn, scope, o){
        if(typeof eventName == "object"){
            o = eventName;
            for(var e in o){
                if(this.filterOptRe.test(e)){
                    continue;
                }
                if(typeof o[e] == "function"){
                    // shared options
                    this.addListener(e, o[e], o.scope,  o);
                }else{
                    // individual options
                    this.addListener(e, o[e].fn, o[e].scope, o[e]);
                }
            }
            return;
        }
        o = (!o || typeof o == "boolean") ? {} : o;
        eventName = eventName.toLowerCase();
        var ce = this.events[eventName] || true;
        if(typeof ce == "boolean"){
            ce = new Ext.util.Event(this, eventName);
            this.events[eventName] = ce;
        }
        ce.addListener(fn, scope, o);
    },

    /**
     * Removes a listener
     * @param {String}   eventName     The type of event to listen for
     * @param {Function} handler        The handler to remove
     * @param {Object}   scope  (optional) The scope (this object) for the handler
     */
    removeListener : function(eventName, fn, scope){
        var ce = this.events[eventName.toLowerCase()];
        if(typeof ce == "object"){
            ce.removeListener(fn, scope);
        }
    },

    /**
     * Removes all listeners for this object
     */
    purgeListeners : function(){
        for(var evt in this.events){
            if(typeof this.events[evt] == "object"){
                 this.events[evt].clearListeners();
            }
        }
    },

    /**
     * Relays selected events from this Observable to a different Observable
     * @param {Object} o The Observable to relay events to
     * @param {Array} events Array of event names to relay
     */
    relayEvents : function(o, events){
        var createHandler = function(ename){
            return function(){
                return this.fireEvent.apply(this, Ext.combine(ename, Array.prototype.slice.call(arguments, 0)));
            };
        };
        for(var i = 0, len = events.length; i < len; i++){
            var ename = events[i];
            if(!this.events[ename]){ this.events[ename] = true; };
            o.on(ename, createHandler(ename), this);
        }
    },

    /**
     * Used to define events on this Observable
     * @param {Object} object The object with the events defined
     */
    addEvents : function(o){
        if(!this.events){
            this.events = {};
        }
        if(typeof o == 'string'){
            for(var i = 0, a = arguments, v; v = a[i]; i++){
                if(!this.events[a[i]]){
                    this.events[a[i]] = true;
                }
            }
        }else{
            Ext.applyIf(this.events, o);
        }
    },

    /**
     * Checks to see if this object has any listeners for a specified event
     * @param {String} eventName The name of the event to check for
     * @return {Boolean} True if the event is being listened for, else false
     */
    hasListener : function(eventName){
        var e = this.events[eventName];
        return typeof e == "object" && e.listeners.length > 0;
    },

    /**
     * Suspend the firing of all events. (see {@link #resumeEvents})
     */
    suspendEvents : function(){
        this.eventsSuspended = true;
    },

    /**
     * Resume firing events. (see {@link #suspendEvents})
     */
    resumeEvents : function(){
        this.eventsSuspended = false;
    },

    // these are considered experimental
    // allows for easier interceptor and sequences, including cancelling and overwriting the return value of the call
    // private
    getMethodEvent : function(method){
        if(!this.methodEvents){
            this.methodEvents = {};
        }
        var e = this.methodEvents[method];
        if(!e){
            e = {};
            this.methodEvents[method] = e;

            e.originalFn = this[method];
            e.methodName = method;
            e.before = [];
            e.after = [];


            var returnValue, v, cancel;
            var obj = this;

            var makeCall = function(fn, scope, args){
                if((v = fn.apply(scope || obj, args)) !== undefined){
                    if(typeof v === 'object'){
                        if(v.returnValue !== undefined){
                            returnValue = v.returnValue;
                        }else{
                            returnValue = v;
                        }
                        if(v.cancel === true){
                            cancel = true;
                        }
                    }else if(v === false){
                        cancel = true;
                    }else {
                        returnValue = v;
                    }
                }
            }

            this[method] = function(){
                returnValue = v = undefined; cancel = false;
                var args = Array.prototype.slice.call(arguments, 0);
                for(var i = 0, len = e.before.length; i < len; i++){
                    makeCall(e.before[i].fn, e.before[i].scope, args);
                    if(cancel){
                        return returnValue;
                    }
                }

                if((v = e.originalFn.apply(obj, args)) !== undefined){
                    returnValue = v;
                }

                for(var i = 0, len = e.after.length; i < len; i++){
                    makeCall(e.after[i].fn, e.after[i].scope, args);
                    if(cancel){
                        return returnValue;
                    }
                }
                return returnValue;
            };
        }
        return e;
    },

    // adds an "interceptor" called before the original method
    beforeMethod : function(method, fn, scope){
        var e = this.getMethodEvent(method);
        e.before.push({fn: fn, scope: scope});
    },

    // adds a "sequence" called after the original method
    afterMethod : function(method, fn, scope){
        var e = this.getMethodEvent(method);
        e.after.push({fn: fn, scope: scope});
    },

    removeMethodListener : function(method, fn, scope){
        var e = this.getMethodEvent(method);
        for(var i = 0, len = e.before.length; i < len; i++){
            if(e.before[i].fn == fn && e.before[i].scope == scope){
                e.before.splice(i, 1);
                return;
            }
        }
        for(var i = 0, len = e.after.length; i < len; i++){
            if(e.after[i].fn == fn && e.after[i].scope == scope){
                e.after.splice(i, 1);
                return;
            }
        }
    }
};
/**
 * Appends an event handler to this element (shorthand for addListener)
 * @param {String}   eventName     The type of event to listen for
 * @param {Function} handler        The method the event invokes
 * @param {Object}   scope (optional) The scope in which to execute the handler
 * function. The handler function's "this" context.
 * @param {Object}   options  (optional)
 * @method
 */
Ext.util.Observable.prototype.on = Ext.util.Observable.prototype.addListener;
/**
 * Removes a listener (shorthand for removeListener)
 * @param {String}   eventName     The type of event to listen for
 * @param {Function} handler        The handler to remove
 * @param {Object}   scope  (optional) The scope (this object) for the handler
 * @method
 */
Ext.util.Observable.prototype.un = Ext.util.Observable.prototype.removeListener;

/**
 * Starts capture on the specified Observable. All events will be passed
 * to the supplied function with the event name + standard signature of the event
 * <b>before</b> the event is fired. If the supplied function returns false,
 * the event will not fire.
 * @param {Observable} o The Observable to capture
 * @param {Function} fn The function to call
 * @param {Object} scope (optional) The scope (this object) for the fn
 * @static
 */
Ext.util.Observable.capture = function(o, fn, scope){
    o.fireEvent = o.fireEvent.createInterceptor(fn, scope);
};

/**
 * Removes <b>all</b> added captures from the Observable.
 * @param {Observable} o The Observable to release
 * @static
 */
Ext.util.Observable.releaseCapture = function(o){
    o.fireEvent = Ext.util.Observable.prototype.fireEvent;
};

(function(){

    var createBuffered = function(h, o, scope){
        var task = new Ext.util.DelayedTask();
        return function(){
            task.delay(o.buffer, h, scope, Array.prototype.slice.call(arguments, 0));
        };
    };

    var createSingle = function(h, e, fn, scope){
        return function(){
            e.removeListener(fn, scope);
            return h.apply(scope, arguments);
        };
    };

    var createDelayed = function(h, o, scope){
        return function(){
            var args = Array.prototype.slice.call(arguments, 0);
            setTimeout(function(){
                h.apply(scope, args);
            }, o.delay || 10);
        };
    };

    Ext.util.Event = function(obj, name){
        this.name = name;
        this.obj = obj;
        this.listeners = [];
    };

    Ext.util.Event.prototype = {
        addListener : function(fn, scope, options){
            scope = scope || this.obj;
            if(!this.isListening(fn, scope)){
                var l = this.createListener(fn, scope, options);
                if(!this.firing){
                    this.listeners.push(l);
                }else{ // if we are currently firing this event, don't disturb the listener loop
                    this.listeners = this.listeners.slice(0);
                    this.listeners.push(l);
                }
            }
        },

        createListener : function(fn, scope, o){
            o = o || {};
            scope = scope || this.obj;
            var l = {fn: fn, scope: scope, options: o};
            var h = fn;
            if(o.delay){
                h = createDelayed(h, o, scope);
            }
            if(o.single){
                h = createSingle(h, this, fn, scope);
            }
            if(o.buffer){
                h = createBuffered(h, o, scope);
            }
            l.fireFn = h;
            return l;
        },

        findListener : function(fn, scope){
            scope = scope || this.obj;
            var ls = this.listeners;
            for(var i = 0, len = ls.length; i < len; i++){
                var l = ls[i];
                if(l.fn == fn && l.scope == scope){
                    return i;
                }
            }
            return -1;
        },

        isListening : function(fn, scope){
            return this.findListener(fn, scope) != -1;
        },

        removeListener : function(fn, scope){
            var index;
            if((index = this.findListener(fn, scope)) != -1){
                if(!this.firing){
                    this.listeners.splice(index, 1);
                }else{
                    this.listeners = this.listeners.slice(0);
                    this.listeners.splice(index, 1);
                }
                return true;
            }
            return false;
        },

        clearListeners : function(){
            this.listeners = [];
        },

        fire : function(){
            var ls = this.listeners, scope, len = ls.length;
            if(len > 0){
                this.firing = true;
                var args = Array.prototype.slice.call(arguments, 0);
                for(var i = 0; i < len; i++){
                    var l = ls[i];
                    if(l.fireFn.apply(l.scope||this.obj||window, arguments) === false){
                        this.firing = false;
                        return false;
                    }
                }
                this.firing = false;
            }
            return true;
        }
    };
})();
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

(function() {
    var libFlyweight;

    Ext.lib.Dom = {
        getViewWidth : function(full) {
            return full ? this.getDocumentWidth() : this.getViewportWidth();
        },

        getViewHeight : function(full) {
            return full ? this.getDocumentHeight() : this.getViewportHeight();
        },

        getDocumentHeight: function() {
            var scrollHeight = (document.compatMode != "CSS1Compat") ? document.body.scrollHeight : document.documentElement.scrollHeight;
            return Math.max(scrollHeight, this.getViewportHeight());
        },

        getDocumentWidth: function() {
            var scrollWidth = (document.compatMode != "CSS1Compat") ? document.body.scrollWidth : document.documentElement.scrollWidth;
            return Math.max(scrollWidth, this.getViewportWidth());
        },

        getViewportHeight: function(){
            if(Ext.isIE){
                return Ext.isStrict ? document.documentElement.clientHeight :
                         document.body.clientHeight;
            }else{
                return self.innerHeight;
            }
        },

        getViewportWidth: function() {
            if(Ext.isIE){
                return Ext.isStrict ? document.documentElement.clientWidth :
                         document.body.clientWidth;
            }else{
                return self.innerWidth;
            }
        },

        isAncestor : function(p, c) {
            p = Ext.getDom(p);
            c = Ext.getDom(c);
            if (!p || !c) {
                return false;
            }

            if (p.contains && !Ext.isSafari) {
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
        },

        getRegion : function(el) {
            return Ext.lib.Region.getRegion(el);
        },

        getY : function(el) {
            return this.getXY(el)[1];
        },

        getX : function(el) {
            return this.getXY(el)[0];
        },


        getXY : function(el) {
            var p, pe, b, scroll, bd = (document.body || document.documentElement);
            el = Ext.getDom(el);

            if(el == bd){
                return [0, 0];
            }

            if (el.getBoundingClientRect) {
                b = el.getBoundingClientRect();
                scroll = fly(document).getScroll();
                return [b.left + scroll.left, b.top + scroll.top];
            }
            var x = 0, y = 0;

            p = el;

            var hasAbsolute = fly(el).getStyle("position") == "absolute";

            while (p) {

                x += p.offsetLeft;
                y += p.offsetTop;

                if (!hasAbsolute && fly(p).getStyle("position") == "absolute") {
                    hasAbsolute = true;
                }

                if (Ext.isGecko) {
                    pe = fly(p);

                    var bt = parseInt(pe.getStyle("borderTopWidth"), 10) || 0;
                    var bl = parseInt(pe.getStyle("borderLeftWidth"), 10) || 0;


                    x += bl;
                    y += bt;


                    if (p != el && pe.getStyle('overflow') != 'visible') {
                        x += bl;
                        y += bt;
                    }
                }
                p = p.offsetParent;
            }

            if (Ext.isSafari && hasAbsolute) {
                x -= bd.offsetLeft;
                y -= bd.offsetTop;
            }

            if (Ext.isGecko && !hasAbsolute) {
                var dbd = fly(bd);
                x += parseInt(dbd.getStyle("borderLeftWidth"), 10) || 0;
                y += parseInt(dbd.getStyle("borderTopWidth"), 10) || 0;
            }

            p = el.parentNode;
            while (p && p != bd) {
                if (!Ext.isOpera || (p.tagName != 'TR' && fly(p).getStyle("display") != "inline")) {
                    x -= p.scrollLeft;
                    y -= p.scrollTop;
                }
                p = p.parentNode;
            }
            return [x, y];
        },

        setXY : function(el, xy) {
            el = Ext.fly(el, '_setXY');
            el.position();
            var pts = el.translatePoints(xy);
            if (xy[0] !== false) {
                el.dom.style.left = pts.left + "px";
            }
            if (xy[1] !== false) {
                el.dom.style.top = pts.top + "px";
            }
        },

        setX : function(el, x) {
            this.setXY(el, [x, false]);
        },

        setY : function(el, y) {
            this.setXY(el, [false, y]);
        }
    };

/*
 * Portions of this file are based on pieces of Yahoo User Interface Library
 * Copyright (c) 2007, Yahoo! Inc. All rights reserved.
 * YUI licensed under the BSD License:
 * http://developer.yahoo.net/yui/license.txt
 */
    Ext.lib.Event = function() {
        var loadComplete = false;
        var listeners = [];
        var unloadListeners = [];
        var retryCount = 0;
        var onAvailStack = [];
        var counter = 0;
        var lastError = null;

        return {
            POLL_RETRYS: 200,
            POLL_INTERVAL: 20,
            EL: 0,
            TYPE: 1,
            FN: 2,
            WFN: 3,
            OBJ: 3,
            ADJ_SCOPE: 4,
            _interval: null,

            startInterval: function() {
                if (!this._interval) {
                    var self = this;
                    var callback = function() {
                        self._tryPreloadAttach();
                    };
                    this._interval = setInterval(callback, this.POLL_INTERVAL);

                }
            },

            onAvailable: function(p_id, p_fn, p_obj, p_override) {
                onAvailStack.push({ id:         p_id,
                    fn:         p_fn,
                    obj:        p_obj,
                    override:   p_override,
                    checkReady: false    });

                retryCount = this.POLL_RETRYS;
                this.startInterval();
            },


            addListener: function(el, eventName, fn) {
                el = Ext.getDom(el);
                if (!el || !fn) {
                    return false;
                }

                if ("unload" == eventName) {
                    unloadListeners[unloadListeners.length] =
                    [el, eventName, fn];
                    return true;
                }

                // prevent unload errors with simple check
                var wrappedFn = function(e) {
                    return typeof Ext != 'undefined' ? fn(Ext.lib.Event.getEvent(e)) : false;
                };

                var li = [el, eventName, fn, wrappedFn];

                var index = listeners.length;
                listeners[index] = li;

                this.doAdd(el, eventName, wrappedFn, false);
                return true;

            },


            removeListener: function(el, eventName, fn) {
                var i, len;

                el = Ext.getDom(el);

                if(!fn) {
                    return this.purgeElement(el, false, eventName);
                }


                if ("unload" == eventName) {

                    for (i = 0,len = unloadListeners.length; i < len; i++) {
                        var li = unloadListeners[i];
                        if (li &&
                            li[0] == el &&
                            li[1] == eventName &&
                            li[2] == fn) {
                            unloadListeners.splice(i, 1);
                            return true;
                        }
                    }

                    return false;
                }

                var cacheItem = null;


                var index = arguments[3];

                if ("undefined" == typeof index) {
                    index = this._getCacheIndex(el, eventName, fn);
                }

                if (index >= 0) {
                    cacheItem = listeners[index];
                }

                if (!el || !cacheItem) {
                    return false;
                }

                this.doRemove(el, eventName, cacheItem[this.WFN], false);

                delete listeners[index][this.WFN];
                delete listeners[index][this.FN];
                listeners.splice(index, 1);

                return true;

            },


            getTarget: function(ev, resolveTextNode) {
                ev = ev.browserEvent || ev;
                var t = ev.target || ev.srcElement;
                return this.resolveTextNode(t);
            },


            resolveTextNode: function(node) {
                if (Ext.isSafari && node && 3 == node.nodeType) {
                    return node.parentNode;
                } else {
                    return node;
                }
            },


            getPageX: function(ev) {
                ev = ev.browserEvent || ev;
                var x = ev.pageX;
                if (!x && 0 !== x) {
                    x = ev.clientX || 0;

                    if (Ext.isIE) {
                        x += this.getScroll()[1];
                    }
                }

                return x;
            },


            getPageY: function(ev) {
                ev = ev.browserEvent || ev;
                var y = ev.pageY;
                if (!y && 0 !== y) {
                    y = ev.clientY || 0;

                    if (Ext.isIE) {
                        y += this.getScroll()[0];
                    }
                }


                return y;
            },


            getXY: function(ev) {
                ev = ev.browserEvent || ev;
                return [this.getPageX(ev), this.getPageY(ev)];
            },


            getRelatedTarget: function(ev) {
                ev = ev.browserEvent || ev;
                var t = ev.relatedTarget;
                if (!t) {
                    if (ev.type == "mouseout") {
                        t = ev.toElement;
                    } else if (ev.type == "mouseover") {
                        t = ev.fromElement;
                    }
                }

                return this.resolveTextNode(t);
            },


            getTime: function(ev) {
                ev = ev.browserEvent || ev;
                if (!ev.time) {
                    var t = new Date().getTime();
                    try {
                        ev.time = t;
                    } catch(ex) {
                        this.lastError = ex;
                        return t;
                    }
                }

                return ev.time;
            },


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


            getCharCode: function(ev) {
                ev = ev.browserEvent || ev;
                return ev.charCode || ev.keyCode || 0;
            },


            _getCacheIndex: function(el, eventName, fn) {
                for (var i = 0,len = listeners.length; i < len; ++i) {
                    var li = listeners[i];
                    if (li &&
                        li[this.FN] == fn &&
                        li[this.EL] == el &&
                        li[this.TYPE] == eventName) {
                        return i;
                    }
                }

                return -1;
            },


            elCache: {},


            getEl: function(id) {
                return document.getElementById(id);
            },


            clearCache: function() {
            },


            _load: function(e) {
                loadComplete = true;
                var EU = Ext.lib.Event;


                if (Ext.isIE) {
                    EU.doRemove(window, "load", EU._load);
                }
            },


            _tryPreloadAttach: function() {

                if (this.locked) {
                    return false;
                }

                this.locked = true;


                var tryAgain = !loadComplete;
                if (!tryAgain) {
                    tryAgain = (retryCount > 0);
                }


                var notAvail = [];
                for (var i = 0,len = onAvailStack.length; i < len; ++i) {
                    var item = onAvailStack[i];
                    if (item) {
                        var el = this.getEl(item.id);

                        if (el) {
                            if (!item.checkReady ||
                                loadComplete ||
                                el.nextSibling ||
                                (document && document.body)) {

                                var scope = el;
                                if (item.override) {
                                    if (item.override === true) {
                                        scope = item.obj;
                                    } else {
                                        scope = item.override;
                                    }
                                }
                                item.fn.call(scope, item.obj);
                                onAvailStack[i] = null;
                            }
                        } else {
                            notAvail.push(item);
                        }
                    }
                }

                retryCount = (notAvail.length === 0) ? 0 : retryCount - 1;

                if (tryAgain) {

                    this.startInterval();
                } else {
                    clearInterval(this._interval);
                    this._interval = null;
                }

                this.locked = false;

                return true;

            },


            purgeElement: function(el, recurse, eventName) {
                var elListeners = this.getListeners(el, eventName);
                if (elListeners) {
                    for (var i = 0,len = elListeners.length; i < len; ++i) {
                        var l = elListeners[i];
                        this.removeListener(el, l.type, l.fn);
                    }
                }

                if (recurse && el && el.childNodes) {
                    for (i = 0,len = el.childNodes.length; i < len; ++i) {
                        this.purgeElement(el.childNodes[i], recurse, eventName);
                    }
                }
            },


            getListeners: function(el, eventName) {
                var results = [], searchLists;
                if (!eventName) {
                    searchLists = [listeners, unloadListeners];
                } else if (eventName == "unload") {
                    searchLists = [unloadListeners];
                } else {
                    searchLists = [listeners];
                }

                for (var j = 0; j < searchLists.length; ++j) {
                    var searchList = searchLists[j];
                    if (searchList && searchList.length > 0) {
                        for (var i = 0,len = searchList.length; i < len; ++i) {
                            var l = searchList[i];
                            if (l && l[this.EL] === el &&
                                (!eventName || eventName === l[this.TYPE])) {
                                results.push({
                                    type:   l[this.TYPE],
                                    fn:     l[this.FN],
                                    obj:    l[this.OBJ],
                                    adjust: l[this.ADJ_SCOPE],
                                    index:  i
                                });
                            }
                        }
                    }
                }

                return (results.length) ? results : null;
            },


            _unload: function(e) {

                var EU = Ext.lib.Event, i, j, l, len, index;

                for (i = 0,len = unloadListeners.length; i < len; ++i) {
                    l = unloadListeners[i];
                    if (l) {
                        var scope = window;
                        if (l[EU.ADJ_SCOPE]) {
                            if (l[EU.ADJ_SCOPE] === true) {
                                scope = l[EU.OBJ];
                            } else {
                                scope = l[EU.ADJ_SCOPE];
                            }
                        }
                        l[EU.FN].call(scope, EU.getEvent(e), l[EU.OBJ]);
                        unloadListeners[i] = null;
                        l = null;
                        scope = null;
                    }
                }

                unloadListeners = null;

                if (listeners && listeners.length > 0) {
                    j = listeners.length;
                    while (j) {
                        index = j - 1;
                        l = listeners[index];
                        if (l) {
                            EU.removeListener(l[EU.EL], l[EU.TYPE],
                                    l[EU.FN], index);
                        }
                        j = j - 1;
                    }
                    l = null;

                    EU.clearCache();
                }

                EU.doRemove(window, "unload", EU._unload);

            },


            getScroll: function() {
                var dd = document.documentElement, db = document.body;
                if (dd && (dd.scrollTop || dd.scrollLeft)) {
                    return [dd.scrollTop, dd.scrollLeft];
                } else if (db) {
                    return [db.scrollTop, db.scrollLeft];
                } else {
                    return [0, 0];
                }
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
            }(),


            doRemove: function() {
                if (window.removeEventListener) {
                    return function (el, eventName, fn, capture) {
                        el.removeEventListener(eventName, fn, (capture));
                    };
                } else if (window.detachEvent) {
                    return function (el, eventName, fn) {
                        el.detachEvent("on" + eventName, fn);
                    };
                } else {
                    return function() {
                    };
                }
            }()
        };

    }();

    var E = Ext.lib.Event;
    E.on = E.addListener;
    E.un = E.removeListener;
    if(document && document.body) {
        E._load();
    } else {
        E.doAdd(window, "load", E._load);
    }
    E.doAdd(window, "unload", E._unload);
    E._tryPreloadAttach();

    Ext.lib.Ajax = {
        request : function(method, uri, cb, data, options) {
            if(options){
                var hs = options.headers;
                if(hs){
                    for(var h in hs){
                        if(hs.hasOwnProperty(h)){
                            this.initHeader(h, hs[h], false);
                        }
                    }
                }
                if(options.xmlData){
                    if (!hs || !hs['Content-Type']){
                        this.initHeader('Content-Type', 'text/xml', false);
                    }
                    method = (method ? method : (options.method ? options.method : 'POST'));
                    data = options.xmlData;
                }else if(options.jsonData){
                    if (!hs || !hs['Content-Type']){
                        this.initHeader('Content-Type', 'application/json', false);
                    }
                    method = (method ? method : (options.method ? options.method : 'POST'));
                    data = typeof options.jsonData == 'object' ? Ext.encode(options.jsonData) : options.jsonData;
                }
            }

            return this.asyncRequest(method, uri, cb, data);
        },

        serializeForm : function(form) {
            if(typeof form == 'string') {
                form = (document.getElementById(form) || document.forms[form]);
            }

            var el, name, val, disabled, data = '', hasSubmit = false;
            for (var i = 0; i < form.elements.length; i++) {
                el = form.elements[i];
                disabled = form.elements[i].disabled;
                name = form.elements[i].name;
                val = form.elements[i].value;

                if (!disabled && name){
                    switch (el.type)
                            {
                        case 'select-one':
                        case 'select-multiple':
                            for (var j = 0; j < el.options.length; j++) {
                                if (el.options[j].selected) {
                                    if (Ext.isIE) {
                                        data += encodeURIComponent(name) + '=' + encodeURIComponent(el.options[j].attributes['value'].specified ? el.options[j].value : el.options[j].text) + '&';
                                    }
                                    else {
                                        data += encodeURIComponent(name) + '=' + encodeURIComponent(el.options[j].hasAttribute('value') ? el.options[j].value : el.options[j].text) + '&';
                                    }
                                }
                            }
                            break;
                        case 'radio':
                        case 'checkbox':
                            if (el.checked) {
                                data += encodeURIComponent(name) + '=' + encodeURIComponent(val) + '&';
                            }
                            break;
                        case 'file':

                        case undefined:

                        case 'reset':

                        case 'button':

                            break;
                        case 'submit':
                            if(hasSubmit == false) {
                                data += encodeURIComponent(name) + '=' + encodeURIComponent(val) + '&';
                                hasSubmit = true;
                            }
                            break;
                        default:
                            data += encodeURIComponent(name) + '=' + encodeURIComponent(val) + '&';
                            break;
                    }
                }
            }
            data = data.substr(0, data.length - 1);
            return data;
        },

        headers:{},

        hasHeaders:false,

        useDefaultHeader:true,

        defaultPostHeader:'application/x-www-form-urlencoded',

        useDefaultXhrHeader:true,

        defaultXhrHeader:'XMLHttpRequest',

        hasDefaultHeaders:true,

        defaultHeaders:{},

        poll:{},

        timeout:{},

        pollInterval:50,

        transactionId:0,

        setProgId:function(id)
        {
            this.activeX.unshift(id);
        },

        setDefaultPostHeader:function(b)
        {
            this.useDefaultHeader = b;
        },

        setDefaultXhrHeader:function(b)
        {
            this.useDefaultXhrHeader = b;
        },

        setPollingInterval:function(i)
        {
            if (typeof i == 'number' && isFinite(i)) {
                this.pollInterval = i;
            }
        },

        createXhrObject:function(transactionId)
        {
            var obj,http;
            try
            {

                http = new XMLHttpRequest();

                obj = { conn:http, tId:transactionId };
            }
            catch(e)
            {
                for (var i = 0; i < this.activeX.length; ++i) {
                    try
                    {

                        http = new ActiveXObject(this.activeX[i]);

                        obj = { conn:http, tId:transactionId };
                        break;
                    }
                    catch(e) {
                    }
                }
            }
            finally
            {
                return obj;
            }
        },

        getConnectionObject:function()
        {
            var o;
            var tId = this.transactionId;

            try
            {
                o = this.createXhrObject(tId);
                if (o) {
                    this.transactionId++;
                }
            }
            catch(e) {
            }
            finally
            {
                return o;
            }
        },

        asyncRequest:function(method, uri, callback, postData)
        {
            var o = this.getConnectionObject();

            if (!o) {
                return null;
            }
            else {
                o.conn.open(method, uri, true);

                if (this.useDefaultXhrHeader) {
                    if (!this.defaultHeaders['X-Requested-With']) {
                        this.initHeader('X-Requested-With', this.defaultXhrHeader, true);
                    }
                }

                if(postData && this.useDefaultHeader && (!this.hasHeaders || !this.headers['Content-Type'])){
                    this.initHeader('Content-Type', this.defaultPostHeader);
                }

                 if (this.hasDefaultHeaders || this.hasHeaders) {
                    this.setHeader(o);
                }

                this.handleReadyState(o, callback);
                o.conn.send(postData || null);

                return o;
            }
        },

        handleReadyState:function(o, callback)
        {
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

        handleTransactionResponse:function(o, callback, isAbort)
        {

            if (!callback) {
                this.releaseObject(o);
                return;
            }

            var httpStatus, responseObject;

            try
            {
                if (o.conn.status !== undefined && o.conn.status != 0) {
                    httpStatus = o.conn.status;
                }
                else {
                    httpStatus = 13030;
                }
            }
            catch(e) {


                httpStatus = 13030;
            }

            if (httpStatus >= 200 && httpStatus < 300) {
                responseObject = this.createResponseObject(o, callback.argument);
                if (callback.success) {
                    if (!callback.scope) {
                        callback.success(responseObject);
                    }
                    else {


                        callback.success.apply(callback.scope, [responseObject]);
                    }
                }
            }
            else {
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
                            }
                            else {
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

        createResponseObject:function(o, callbackArg)
        {
            var obj = {};
            var headerObj = {};

            try
            {
                var headerStr = o.conn.getAllResponseHeaders();
                var header = headerStr.split('\n');
                for (var i = 0; i < header.length; i++) {
                    var delimitPos = header[i].indexOf(':');
                    if (delimitPos != -1) {
                        headerObj[header[i].substring(0, delimitPos)] = header[i].substring(delimitPos + 2);
                    }
                }
            }
            catch(e) {
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

        initHeader:function(label, value, isDefault)
        {
            var headerObj = (isDefault) ? this.defaultHeaders : this.headers;

            if (headerObj[label] === undefined) {
                headerObj[label] = value;
            }
            else {


                headerObj[label] = value + "," + headerObj[label];
            }

            if (isDefault) {
                this.hasDefaultHeaders = true;
            }
            else {
                this.hasHeaders = true;
            }
        },


        setHeader:function(o)
        {
            if (this.hasDefaultHeaders) {
                for (var prop in this.defaultHeaders) {
                    if (this.defaultHeaders.hasOwnProperty(prop)) {
                        o.conn.setRequestHeader(prop, this.defaultHeaders[prop]);
                    }
                }
            }

            if (this.hasHeaders) {
                for (var prop in this.headers) {
                    if (this.headers.hasOwnProperty(prop)) {
                        o.conn.setRequestHeader(prop, this.headers[prop]);
                    }
                }
                this.headers = {};
                this.hasHeaders = false;
            }
        },

        resetDefaultHeaders:function() {
            delete this.defaultHeaders;
            this.defaultHeaders = {};
            this.hasDefaultHeaders = false;
        },

        abort:function(o, callback, isTimeout)
        {
            if (this.isCallInProgress(o)) {
                o.conn.abort();
                window.clearInterval(this.poll[o.tId]);
                delete this.poll[o.tId];
                if (isTimeout) {
                    delete this.timeout[o.tId];
                }

                this.handleTransactionResponse(o, callback, true);

                return true;
            }
            else {
                return false;
            }
        },


        isCallInProgress:function(o)
        {


            if (o.conn) {
                return o.conn.readyState != 4 && o.conn.readyState != 0;
            }
            else {

                return false;
            }
        },


        releaseObject:function(o)
        {

            o.conn = null;

            o = null;
        },

        activeX:[
        'MSXML2.XMLHTTP.3.0',
        'MSXML2.XMLHTTP',
        'Microsoft.XMLHTTP'
        ]


    };


    Ext.lib.Region = function(t, r, b, l) {
        this.top = t;
        this[1] = t;
        this.right = r;
        this.bottom = b;
        this.left = l;
        this[0] = l;
    };

    Ext.lib.Region.prototype = {
        contains : function(region) {
            return ( region.left >= this.left &&
                     region.right <= this.right &&
                     region.top >= this.top &&
                     region.bottom <= this.bottom    );

        },

        getArea : function() {
            return ( (this.bottom - this.top) * (this.right - this.left) );
        },

        intersect : function(region) {
            var t = Math.max(this.top, region.top);
            var r = Math.min(this.right, region.right);
            var b = Math.min(this.bottom, region.bottom);
            var l = Math.max(this.left, region.left);

            if (b >= t && r >= l) {
                return new Ext.lib.Region(t, r, b, l);
            } else {
                return null;
            }
        },
        union : function(region) {
            var t = Math.min(this.top, region.top);
            var r = Math.max(this.right, region.right);
            var b = Math.max(this.bottom, region.bottom);
            var l = Math.min(this.left, region.left);

            return new Ext.lib.Region(t, r, b, l);
        },

        constrainTo : function(r) {
            this.top = this.top.constrain(r.top, r.bottom);
            this.bottom = this.bottom.constrain(r.top, r.bottom);
            this.left = this.left.constrain(r.left, r.right);
            this.right = this.right.constrain(r.left, r.right);
            return this;
        },

        adjust : function(t, l, b, r) {
            this.top += t;
            this.left += l;
            this.right += r;
            this.bottom += b;
            return this;
        }
    };

    Ext.lib.Region.getRegion = function(el) {
        var p = Ext.lib.Dom.getXY(el);

        var t = p[1];
        var r = p[0] + el.offsetWidth;
        var b = p[1] + el.offsetHeight;
        var l = p[0];

        return new Ext.lib.Region(t, r, b, l);
    };

    Ext.lib.Point = function(x, y) {
        if (Ext.isArray(x)) {
            y = x[1];
            x = x[0];
        }
        this.x = this.right = this.left = this[0] = x;
        this.y = this.top = this.bottom = this[1] = y;
    };

    Ext.lib.Point.prototype = new Ext.lib.Region();


    Ext.lib.Anim = {
        scroll : function(el, args, duration, easing, cb, scope) {
            return this.run(el, args, duration, easing, cb, scope, Ext.lib.Scroll);
        },

        motion : function(el, args, duration, easing, cb, scope) {
            return this.run(el, args, duration, easing, cb, scope, Ext.lib.Motion);
        },

        color : function(el, args, duration, easing, cb, scope) {
            return this.run(el, args, duration, easing, cb, scope, Ext.lib.ColorAnim);
        },

        run : function(el, args, duration, easing, cb, scope, type) {
            type = type || Ext.lib.AnimBase;
            if (typeof easing == "string") {
                easing = Ext.lib.Easing[easing];
            }
            var anim = new type(el, args, duration, easing);
            anim.animateX(function() {
                Ext.callback(cb, scope);
            });
            return anim;
        }
    };


    function fly(el) {
        if (!libFlyweight) {
            libFlyweight = new Ext.Element.Flyweight();
        }
        libFlyweight.dom = el;
        return libFlyweight;
    }


    if(Ext.isIE) {
        function fnCleanUp() {
            var p = Function.prototype;
            delete p.createSequence;
            delete p.defer;
            delete p.createDelegate;
            delete p.createCallback;
            delete p.createInterceptor;

            window.detachEvent("onunload", fnCleanUp);
        }
        window.attachEvent("onunload", fnCleanUp);
    }

    Ext.lib.AnimBase = function(el, attributes, duration, method) {
        if (el) {
            this.init(el, attributes, duration, method);
        }
    };

    Ext.lib.AnimBase.prototype = {

        toString: function() {
            var el = this.getEl();
            var id = el.id || el.tagName;
            return ("Anim " + id);
        },

        patterns: {
            noNegatives:        /width|height|opacity|padding/i,
            offsetAttribute:  /^((width|height)|(top|left))$/,
            defaultUnit:        /width|height|top$|bottom$|left$|right$/i,
            offsetUnit:         /\d+(em|%|en|ex|pt|in|cm|mm|pc)$/i
        },


        doMethod: function(attr, start, end) {
            return this.method(this.currentFrame, start, end - start, this.totalFrames);
        },


        setAttribute: function(attr, val, unit) {
            if (this.patterns.noNegatives.test(attr)) {
                val = (val > 0) ? val : 0;
            }

            Ext.fly(this.getEl(), '_anim').setStyle(attr, val + unit);
        },


        getAttribute: function(attr) {
            var el = this.getEl();
            var val = fly(el).getStyle(attr);

            if (val !== 'auto' && !this.patterns.offsetUnit.test(val)) {
                return parseFloat(val);
            }

            var a = this.patterns.offsetAttribute.exec(attr) || [];
            var pos = !!( a[3] );
            var box = !!( a[2] );


            if (box || (fly(el).getStyle('position') == 'absolute' && pos)) {
                val = el['offset' + a[0].charAt(0).toUpperCase() + a[0].substr(1)];
            } else {
                val = 0;
            }

            return val;
        },


        getDefaultUnit: function(attr) {
            if (this.patterns.defaultUnit.test(attr)) {
                return 'px';
            }

            return '';
        },

        animateX : function(callback, scope) {
            var f = function() {
                this.onComplete.removeListener(f);
                if (typeof callback == "function") {
                    callback.call(scope || this, this);
                }
            };
            this.onComplete.addListener(f, this);
            this.animate();
        },


        setRuntimeAttribute: function(attr) {
            var start;
            var end;
            var attributes = this.attributes;

            this.runtimeAttributes[attr] = {};

            var isset = function(prop) {
                return (typeof prop !== 'undefined');
            };

            if (!isset(attributes[attr]['to']) && !isset(attributes[attr]['by'])) {
                return false;
            }

            start = ( isset(attributes[attr]['from']) ) ? attributes[attr]['from'] : this.getAttribute(attr);


            if (isset(attributes[attr]['to'])) {
                end = attributes[attr]['to'];
            } else if (isset(attributes[attr]['by'])) {
                if (start.constructor == Array) {
                    end = [];
                    for (var i = 0, len = start.length; i < len; ++i) {
                        end[i] = start[i] + attributes[attr]['by'][i];
                    }
                } else {
                    end = start + attributes[attr]['by'];
                }
            }

            this.runtimeAttributes[attr].start = start;
            this.runtimeAttributes[attr].end = end;


            this.runtimeAttributes[attr].unit = ( isset(attributes[attr].unit) ) ? attributes[attr]['unit'] : this.getDefaultUnit(attr);
        },


        init: function(el, attributes, duration, method) {

            var isAnimated = false;


            var startTime = null;


            var actualFrames = 0;


            el = Ext.getDom(el);


            this.attributes = attributes || {};


            this.duration = duration || 1;


            this.method = method || Ext.lib.Easing.easeNone;


            this.useSeconds = true;


            this.currentFrame = 0;


            this.totalFrames = Ext.lib.AnimMgr.fps;


            this.getEl = function() {
                return el;
            };


            this.isAnimated = function() {
                return isAnimated;
            };


            this.getStartTime = function() {
                return startTime;
            };

            this.runtimeAttributes = {};


            this.animate = function() {
                if (this.isAnimated()) {
                    return false;
                }

                this.currentFrame = 0;

                this.totalFrames = ( this.useSeconds ) ? Math.ceil(Ext.lib.AnimMgr.fps * this.duration) : this.duration;

                Ext.lib.AnimMgr.registerElement(this);
            };


            this.stop = function(finish) {
                if (finish) {
                    this.currentFrame = this.totalFrames;
                    this._onTween.fire();
                }
                Ext.lib.AnimMgr.stop(this);
            };

            var onStart = function() {
                this.onStart.fire();

                this.runtimeAttributes = {};
                for (var attr in this.attributes) {
                    this.setRuntimeAttribute(attr);
                }

                isAnimated = true;
                actualFrames = 0;
                startTime = new Date();
            };


            var onTween = function() {
                var data = {
                    duration: new Date() - this.getStartTime(),
                    currentFrame: this.currentFrame
                };

                data.toString = function() {
                    return (
                            'duration: ' + data.duration +
                            ', currentFrame: ' + data.currentFrame
                            );
                };

                this.onTween.fire(data);

                var runtimeAttributes = this.runtimeAttributes;

                for (var attr in runtimeAttributes) {
                    this.setAttribute(attr, this.doMethod(attr, runtimeAttributes[attr].start, runtimeAttributes[attr].end), runtimeAttributes[attr].unit);
                }

                actualFrames += 1;
            };

            var onComplete = function() {
                var actual_duration = (new Date() - startTime) / 1000 ;

                var data = {
                    duration: actual_duration,
                    frames: actualFrames,
                    fps: actualFrames / actual_duration
                };

                data.toString = function() {
                    return (
                            'duration: ' + data.duration +
                            ', frames: ' + data.frames +
                            ', fps: ' + data.fps
                            );
                };

                isAnimated = false;
                actualFrames = 0;
                this.onComplete.fire(data);
            };


            this._onStart = new Ext.util.Event(this);
            this.onStart = new Ext.util.Event(this);
            this.onTween = new Ext.util.Event(this);
            this._onTween = new Ext.util.Event(this);
            this.onComplete = new Ext.util.Event(this);
            this._onComplete = new Ext.util.Event(this);
            this._onStart.addListener(onStart);
            this._onTween.addListener(onTween);
            this._onComplete.addListener(onComplete);
        }
    };


    Ext.lib.AnimMgr = new function() {

        var thread = null;


        var queue = [];


        var tweenCount = 0;


        this.fps = 1000;


        this.delay = 1;


        this.registerElement = function(tween) {
            queue[queue.length] = tween;
            tweenCount += 1;
            tween._onStart.fire();
            this.start();
        };


        this.unRegister = function(tween, index) {
            tween._onComplete.fire();
            index = index || getIndex(tween);
            if (index != -1) {
                queue.splice(index, 1);
            }

            tweenCount -= 1;
            if (tweenCount <= 0) {
                this.stop();
            }
        };


        this.start = function() {
            if (thread === null) {
                thread = setInterval(this.run, this.delay);
            }
        };


        this.stop = function(tween) {
            if (!tween) {
                clearInterval(thread);

                for (var i = 0, len = queue.length; i < len; ++i) {
                    if (queue[0].isAnimated()) {
                        this.unRegister(queue[0], 0);
                    }
                }

                queue = [];
                thread = null;
                tweenCount = 0;
            }
            else {
                this.unRegister(tween);
            }
        };


        this.run = function() {
            for (var i = 0, len = queue.length; i < len; ++i) {
                var tween = queue[i];
                if (!tween || !tween.isAnimated()) {
                    continue;
                }

                if (tween.currentFrame < tween.totalFrames || tween.totalFrames === null)
                {
                    tween.currentFrame += 1;

                    if (tween.useSeconds) {
                        correctFrame(tween);
                    }
                    tween._onTween.fire();
                }
                else {
                    Ext.lib.AnimMgr.stop(tween, i);
                }
            }
        };

        var getIndex = function(anim) {
            for (var i = 0, len = queue.length; i < len; ++i) {
                if (queue[i] == anim) {
                    return i;
                }
            }
            return -1;
        };


        var correctFrame = function(tween) {
            var frames = tween.totalFrames;
            var frame = tween.currentFrame;
            var expected = (tween.currentFrame * tween.duration * 1000 / tween.totalFrames);
            var elapsed = (new Date() - tween.getStartTime());
            var tweak = 0;

            if (elapsed < tween.duration * 1000) {
                tweak = Math.round((elapsed / expected - 1) * tween.currentFrame);
            } else {
                tweak = frames - (frame + 1);
            }
            if (tweak > 0 && isFinite(tweak)) {
                if (tween.currentFrame + tweak >= frames) {
                    tweak = frames - (frame + 1);
                }

                tween.currentFrame += tweak;
            }
        };
    };

    Ext.lib.Bezier = new function() {

        this.getPosition = function(points, t) {
            var n = points.length;
            var tmp = [];

            for (var i = 0; i < n; ++i) {
                tmp[i] = [points[i][0], points[i][1]];
            }

            for (var j = 1; j < n; ++j) {
                for (i = 0; i < n - j; ++i) {
                    tmp[i][0] = (1 - t) * tmp[i][0] + t * tmp[parseInt(i + 1, 10)][0];
                    tmp[i][1] = (1 - t) * tmp[i][1] + t * tmp[parseInt(i + 1, 10)][1];
                }
            }

            return [ tmp[0][0], tmp[0][1] ];

        };
    };
    (function() {

        Ext.lib.ColorAnim = function(el, attributes, duration, method) {
            Ext.lib.ColorAnim.superclass.constructor.call(this, el, attributes, duration, method);
        };

        Ext.extend(Ext.lib.ColorAnim, Ext.lib.AnimBase);


        var Y = Ext.lib;
        var superclass = Y.ColorAnim.superclass;
        var proto = Y.ColorAnim.prototype;

        proto.toString = function() {
            var el = this.getEl();
            var id = el.id || el.tagName;
            return ("ColorAnim " + id);
        };

        proto.patterns.color = /color$/i;
        proto.patterns.rgb = /^rgb\(([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\)$/i;
        proto.patterns.hex = /^#?([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})$/i;
        proto.patterns.hex3 = /^#?([0-9A-F]{1})([0-9A-F]{1})([0-9A-F]{1})$/i;
        proto.patterns.transparent = /^transparent|rgba\(0, 0, 0, 0\)$/;


        proto.parseColor = function(s) {
            if (s.length == 3) {
                return s;
            }

            var c = this.patterns.hex.exec(s);
            if (c && c.length == 4) {
                return [ parseInt(c[1], 16), parseInt(c[2], 16), parseInt(c[3], 16) ];
            }

            c = this.patterns.rgb.exec(s);
            if (c && c.length == 4) {
                return [ parseInt(c[1], 10), parseInt(c[2], 10), parseInt(c[3], 10) ];
            }

            c = this.patterns.hex3.exec(s);
            if (c && c.length == 4) {
                return [ parseInt(c[1] + c[1], 16), parseInt(c[2] + c[2], 16), parseInt(c[3] + c[3], 16) ];
            }

            return null;
        };

        proto.getAttribute = function(attr) {
            var el = this.getEl();
            if (this.patterns.color.test(attr)) {
                var val = fly(el).getStyle(attr);

                if (this.patterns.transparent.test(val)) {
                    var parent = el.parentNode;
                    val = fly(parent).getStyle(attr);

                    while (parent && this.patterns.transparent.test(val)) {
                        parent = parent.parentNode;
                        val = fly(parent).getStyle(attr);
                        if (parent.tagName.toUpperCase() == 'HTML') {
                            val = '#fff';
                        }
                    }
                }
            } else {
                val = superclass.getAttribute.call(this, attr);
            }

            return val;
        };

        proto.doMethod = function(attr, start, end) {
            var val;

            if (this.patterns.color.test(attr)) {
                val = [];
                for (var i = 0, len = start.length; i < len; ++i) {
                    val[i] = superclass.doMethod.call(this, attr, start[i], end[i]);
                }

                val = 'rgb(' + Math.floor(val[0]) + ',' + Math.floor(val[1]) + ',' + Math.floor(val[2]) + ')';
            }
            else {
                val = superclass.doMethod.call(this, attr, start, end);
            }

            return val;
        };

        proto.setRuntimeAttribute = function(attr) {
            superclass.setRuntimeAttribute.call(this, attr);

            if (this.patterns.color.test(attr)) {
                var attributes = this.attributes;
                var start = this.parseColor(this.runtimeAttributes[attr].start);
                var end = this.parseColor(this.runtimeAttributes[attr].end);

                if (typeof attributes[attr]['to'] === 'undefined' && typeof attributes[attr]['by'] !== 'undefined') {
                    end = this.parseColor(attributes[attr].by);

                    for (var i = 0, len = start.length; i < len; ++i) {
                        end[i] = start[i] + end[i];
                    }
                }

                this.runtimeAttributes[attr].start = start;
                this.runtimeAttributes[attr].end = end;
            }
        };
    })();


    Ext.lib.Easing = {


        easeNone: function (t, b, c, d) {
            return c * t / d + b;
        },


        easeIn: function (t, b, c, d) {
            return c * (t /= d) * t + b;
        },


        easeOut: function (t, b, c, d) {
            return -c * (t /= d) * (t - 2) + b;
        },


        easeBoth: function (t, b, c, d) {
            if ((t /= d / 2) < 1) {
                return c / 2 * t * t + b;
            }

            return -c / 2 * ((--t) * (t - 2) - 1) + b;
        },


        easeInStrong: function (t, b, c, d) {
            return c * (t /= d) * t * t * t + b;
        },


        easeOutStrong: function (t, b, c, d) {
            return -c * ((t = t / d - 1) * t * t * t - 1) + b;
        },


        easeBothStrong: function (t, b, c, d) {
            if ((t /= d / 2) < 1) {
                return c / 2 * t * t * t * t + b;
            }

            return -c / 2 * ((t -= 2) * t * t * t - 2) + b;
        },



        elasticIn: function (t, b, c, d, a, p) {
            if (t == 0) {
                return b;
            }
            if ((t /= d) == 1) {
                return b + c;
            }
            if (!p) {
                p = d * .3;
            }

            if (!a || a < Math.abs(c)) {
                a = c;
                var s = p / 4;
            }
            else {
                var s = p / (2 * Math.PI) * Math.asin(c / a);
            }

            return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
        },


        elasticOut: function (t, b, c, d, a, p) {
            if (t == 0) {
                return b;
            }
            if ((t /= d) == 1) {
                return b + c;
            }
            if (!p) {
                p = d * .3;
            }

            if (!a || a < Math.abs(c)) {
                a = c;
                var s = p / 4;
            }
            else {
                var s = p / (2 * Math.PI) * Math.asin(c / a);
            }

            return a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b;
        },


        elasticBoth: function (t, b, c, d, a, p) {
            if (t == 0) {
                return b;
            }

            if ((t /= d / 2) == 2) {
                return b + c;
            }

            if (!p) {
                p = d * (.3 * 1.5);
            }

            if (!a || a < Math.abs(c)) {
                a = c;
                var s = p / 4;
            }
            else {
                var s = p / (2 * Math.PI) * Math.asin(c / a);
            }

            if (t < 1) {
                return -.5 * (a * Math.pow(2, 10 * (t -= 1)) *
                              Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
            }
            return a * Math.pow(2, -10 * (t -= 1)) *
                   Math.sin((t * d - s) * (2 * Math.PI) / p) * .5 + c + b;
        },



        backIn: function (t, b, c, d, s) {
            if (typeof s == 'undefined') {
                s = 1.70158;
            }
            return c * (t /= d) * t * ((s + 1) * t - s) + b;
        },


        backOut: function (t, b, c, d, s) {
            if (typeof s == 'undefined') {
                s = 1.70158;
            }
            return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
        },


        backBoth: function (t, b, c, d, s) {
            if (typeof s == 'undefined') {
                s = 1.70158;
            }

            if ((t /= d / 2 ) < 1) {
                return c / 2 * (t * t * (((s *= (1.525)) + 1) * t - s)) + b;
            }
            return c / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2) + b;
        },


        bounceIn: function (t, b, c, d) {
            return c - Ext.lib.Easing.bounceOut(d - t, 0, c, d) + b;
        },


        bounceOut: function (t, b, c, d) {
            if ((t /= d) < (1 / 2.75)) {
                return c * (7.5625 * t * t) + b;
            } else if (t < (2 / 2.75)) {
                return c * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + b;
            } else if (t < (2.5 / 2.75)) {
                return c * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + b;
            }
            return c * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + b;
        },


        bounceBoth: function (t, b, c, d) {
            if (t < d / 2) {
                return Ext.lib.Easing.bounceIn(t * 2, 0, c, d) * .5 + b;
            }
            return Ext.lib.Easing.bounceOut(t * 2 - d, 0, c, d) * .5 + c * .5 + b;
        }
    };

    (function() {
        Ext.lib.Motion = function(el, attributes, duration, method) {
            if (el) {
                Ext.lib.Motion.superclass.constructor.call(this, el, attributes, duration, method);
            }
        };

        Ext.extend(Ext.lib.Motion, Ext.lib.ColorAnim);


        var Y = Ext.lib;
        var superclass = Y.Motion.superclass;
        var proto = Y.Motion.prototype;

        proto.toString = function() {
            var el = this.getEl();
            var id = el.id || el.tagName;
            return ("Motion " + id);
        };

        proto.patterns.points = /^points$/i;

        proto.setAttribute = function(attr, val, unit) {
            if (this.patterns.points.test(attr)) {
                unit = unit || 'px';
                superclass.setAttribute.call(this, 'left', val[0], unit);
                superclass.setAttribute.call(this, 'top', val[1], unit);
            } else {
                superclass.setAttribute.call(this, attr, val, unit);
            }
        };

        proto.getAttribute = function(attr) {
            if (this.patterns.points.test(attr)) {
                var val = [
                        superclass.getAttribute.call(this, 'left'),
                        superclass.getAttribute.call(this, 'top')
                        ];
            } else {
                val = superclass.getAttribute.call(this, attr);
            }

            return val;
        };

        proto.doMethod = function(attr, start, end) {
            var val = null;

            if (this.patterns.points.test(attr)) {
                var t = this.method(this.currentFrame, 0, 100, this.totalFrames) / 100;
                val = Y.Bezier.getPosition(this.runtimeAttributes[attr], t);
            } else {
                val = superclass.doMethod.call(this, attr, start, end);
            }
            return val;
        };

        proto.setRuntimeAttribute = function(attr) {
            if (this.patterns.points.test(attr)) {
                var el = this.getEl();
                var attributes = this.attributes;
                var start;
                var control = attributes['points']['control'] || [];
                var end;
                var i, len;

                if (control.length > 0 && !Ext.isArray(control[0])) {
                    control = [control];
                } else {
                    var tmp = [];
                    for (i = 0,len = control.length; i < len; ++i) {
                        tmp[i] = control[i];
                    }
                    control = tmp;
                }

                Ext.fly(el, '_anim').position();

                if (isset(attributes['points']['from'])) {
                    Ext.lib.Dom.setXY(el, attributes['points']['from']);
                }
                else {
                    Ext.lib.Dom.setXY(el, Ext.lib.Dom.getXY(el));
                }

                start = this.getAttribute('points');


                if (isset(attributes['points']['to'])) {
                    end = translateValues.call(this, attributes['points']['to'], start);

                    var pageXY = Ext.lib.Dom.getXY(this.getEl());
                    for (i = 0,len = control.length; i < len; ++i) {
                        control[i] = translateValues.call(this, control[i], start);
                    }


                } else if (isset(attributes['points']['by'])) {
                    end = [ start[0] + attributes['points']['by'][0], start[1] + attributes['points']['by'][1] ];

                    for (i = 0,len = control.length; i < len; ++i) {
                        control[i] = [ start[0] + control[i][0], start[1] + control[i][1] ];
                    }
                }

                this.runtimeAttributes[attr] = [start];

                if (control.length > 0) {
                    this.runtimeAttributes[attr] = this.runtimeAttributes[attr].concat(control);
                }

                this.runtimeAttributes[attr][this.runtimeAttributes[attr].length] = end;
            }
            else {
                superclass.setRuntimeAttribute.call(this, attr);
            }
        };

        var translateValues = function(val, start) {
            var pageXY = Ext.lib.Dom.getXY(this.getEl());
            val = [ val[0] - pageXY[0] + start[0], val[1] - pageXY[1] + start[1] ];

            return val;
        };

        var isset = function(prop) {
            return (typeof prop !== 'undefined');
        };
    })();


    (function() {
        Ext.lib.Scroll = function(el, attributes, duration, method) {
            if (el) {
                Ext.lib.Scroll.superclass.constructor.call(this, el, attributes, duration, method);
            }
        };

        Ext.extend(Ext.lib.Scroll, Ext.lib.ColorAnim);


        var Y = Ext.lib;
        var superclass = Y.Scroll.superclass;
        var proto = Y.Scroll.prototype;

        proto.toString = function() {
            var el = this.getEl();
            var id = el.id || el.tagName;
            return ("Scroll " + id);
        };

        proto.doMethod = function(attr, start, end) {
            var val = null;

            if (attr == 'scroll') {
                val = [
                        this.method(this.currentFrame, start[0], end[0] - start[0], this.totalFrames),
                        this.method(this.currentFrame, start[1], end[1] - start[1], this.totalFrames)
                        ];

            } else {
                val = superclass.doMethod.call(this, attr, start, end);
            }
            return val;
        };

        proto.getAttribute = function(attr) {
            var val = null;
            var el = this.getEl();

            if (attr == 'scroll') {
                val = [ el.scrollLeft, el.scrollTop ];
            } else {
                val = superclass.getAttribute.call(this, attr);
            }

            return val;
        };

        proto.setAttribute = function(attr, val, unit) {
            var el = this.getEl();

            if (attr == 'scroll') {
                el.scrollLeft = val[0];
                el.scrollTop = val[1];
            } else {
                superclass.setAttribute.call(this, attr, val, unit);
            }
        };
    })();


})();
