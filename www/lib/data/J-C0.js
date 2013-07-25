/*
 * Ext JS Library 2.2
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
     * Relays selected events from the specified Observable as if the events were fired by <tt><b>this</b></tt>.
     * @param {Object} o The Observable whose events this object is to relay.
     * @param {Array} events Array of event names to relay.
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
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.util.MixedCollection
 * @extends Ext.util.Observable
 * A Collection class that maintains both numeric indexes and keys and exposes events.
 * @constructor
 * @param {Boolean} allowFunctions True if the addAll function should add function references to the
 * collection (defaults to false)
 * @param {Function} keyFn A function that can accept an item of the type(s) stored in this MixedCollection
 * and return the key value for that item.  This is used when available to look up the key on items that
 * were passed without an explicit key parameter to a MixedCollection method.  Passing this parameter is
 * equivalent to providing an implementation for the {@link #getKey} method.
 */
Ext.util.MixedCollection = function(allowFunctions, keyFn){
    this.items = [];
    this.map = {};
    this.keys = [];
    this.length = 0;
    this.addEvents(
        /**
         * @event clear
         * Fires when the collection is cleared.
         */
        "clear",
        /**
         * @event add
         * Fires when an item is added to the collection.
         * @param {Number} index The index at which the item was added.
         * @param {Object} o The item added.
         * @param {String} key The key associated with the added item.
         */
        "add",
        /**
         * @event replace
         * Fires when an item is replaced in the collection.
         * @param {String} key he key associated with the new added.
         * @param {Object} old The item being replaced.
         * @param {Object} new The new item.
         */
        "replace",
        /**
         * @event remove
         * Fires when an item is removed from the collection.
         * @param {Object} o The item being removed.
         * @param {String} key (optional) The key associated with the removed item.
         */
        "remove",
        "sort"
    );
    this.allowFunctions = allowFunctions === true;
    if(keyFn){
        this.getKey = keyFn;
    }
    Ext.util.MixedCollection.superclass.constructor.call(this);
};

Ext.extend(Ext.util.MixedCollection, Ext.util.Observable, {
    allowFunctions : false,

/**
 * Adds an item to the collection. Fires the {@link #add} event when complete.
 * @param {String} key <p>The key to associate with the item, or the new item.</p>
 * <p>If you supplied a {@link #getKey} implementation for this MixedCollection, or if the key
 * of your stored items is in a property called <tt><b>id</b></tt>, then the MixedCollection
 * will be able to <i>derive</i> the key for the new item. In this case just pass the new item in
 * this parameter.</p>
 * @param {Object} o The item to add.
 * @return {Object} The item added.
 */
    add : function(key, o){
        if(arguments.length == 1){
            o = arguments[0];
            key = this.getKey(o);
        }
        if(typeof key == "undefined" || key === null){
            this.length++;
            this.items.push(o);
            this.keys.push(null);
        }else{
            var old = this.map[key];
            if(old){
                return this.replace(key, o);
            }
            this.length++;
            this.items.push(o);
            this.map[key] = o;
            this.keys.push(key);
        }
        this.fireEvent("add", this.length-1, o, key);
        return o;
    },

/**
  * MixedCollection has a generic way to fetch keys if you implement getKey.  The default implementation
  * simply returns <tt style="font-weight:bold;">item.id</tt> but you can provide your own implementation
  * to return a different value as in the following examples:
<pre><code>
// normal way
var mc = new Ext.util.MixedCollection();
mc.add(someEl.dom.id, someEl);
mc.add(otherEl.dom.id, otherEl);
//and so on

// using getKey
var mc = new Ext.util.MixedCollection();
mc.getKey = function(el){
   return el.dom.id;
};
mc.add(someEl);
mc.add(otherEl);

// or via the constructor
var mc = new Ext.util.MixedCollection(false, function(el){
   return el.dom.id;
});
mc.add(someEl);
mc.add(otherEl);
</code></pre>
 * @param {Object} item The item for which to find the key.
 * @return {Object} The key for the passed item.
 */
    getKey : function(o){
         return o.id;
    },

/**
 * Replaces an item in the collection. Fires the {@link #replace} event when complete.
 * @param {String} key <p>The key associated with the item to replace, or the replacement item.</p>
 * <p>If you supplied a {@link #getKey} implementation for this MixedCollection, or if the key
 * of your stored items is in a property called <tt><b>id</b></tt>, then the MixedCollection
 * will be able to <i>derive</i> the key of the replacement item. If you want to replace an item
 * with one having the same key value, then just pass the replacement item in this parameter.</p>
 * @param o {Object} o (optional) If the first parameter passed was a key, the item to associate
 * with that key.
 * @return {Object}  The new item.
 */
    replace : function(key, o){
        if(arguments.length == 1){
            o = arguments[0];
            key = this.getKey(o);
        }
        var old = this.item(key);
        if(typeof key == "undefined" || key === null || typeof old == "undefined"){
             return this.add(key, o);
        }
        var index = this.indexOfKey(key);
        this.items[index] = o;
        this.map[key] = o;
        this.fireEvent("replace", key, old, o);
        return o;
    },

/**
 * Adds all elements of an Array or an Object to the collection.
 * @param {Object/Array} objs An Object containing properties which will be added to the collection, or
 * an Array of values, each of which are added to the collection.
 */
    addAll : function(objs){
        if(arguments.length > 1 || Ext.isArray(objs)){
            var args = arguments.length > 1 ? arguments : objs;
            for(var i = 0, len = args.length; i < len; i++){
                this.add(args[i]);
            }
        }else{
            for(var key in objs){
                if(this.allowFunctions || typeof objs[key] != "function"){
                    this.add(key, objs[key]);
                }
            }
        }
    },

/**
 * Executes the specified function once for every item in the collection, passing the following arguments:
 * <div class="mdetail-params"><ul>
 * <li><b>item</b> : Mixed<p class="sub-desc">The collection item</p></li>
 * <li><b>index</b> : Number<p class="sub-desc">The item's index</p></li>
 * <li><b>length</b> : Number<p class="sub-desc">The total number of items in the collection</p></li>
 * </ul></div>
 * The function should return a boolean value. Returning false from the function will stop the iteration.
 * @param {Function} fn The function to execute for each item.
 * @param {Object} scope (optional) The scope in which to execute the function.
 */
    each : function(fn, scope){
        var items = [].concat(this.items); // each safe for removal
        for(var i = 0, len = items.length; i < len; i++){
            if(fn.call(scope || items[i], items[i], i, len) === false){
                break;
            }
        }
    },

/**
 * Executes the specified function once for every key in the collection, passing each
 * key, and its associated item as the first two parameters.
 * @param {Function} fn The function to execute for each item.
 * @param {Object} scope (optional) The scope in which to execute the function.
 */
    eachKey : function(fn, scope){
        for(var i = 0, len = this.keys.length; i < len; i++){
            fn.call(scope || window, this.keys[i], this.items[i], i, len);
        }
    },

    /**
     * Returns the first item in the collection which elicits a true return value from the
     * passed selection function.
     * @param {Function} fn The selection function to execute for each item.
     * @param {Object} scope (optional) The scope in which to execute the function.
     * @return {Object} The first item in the collection which returned true from the selection function.
     */
    find : function(fn, scope){
        for(var i = 0, len = this.items.length; i < len; i++){
            if(fn.call(scope || window, this.items[i], this.keys[i])){
                return this.items[i];
            }
        }
        return null;
    },

/**
 * Inserts an item at the specified index in the collection. Fires the {@link #add} event when complete.
 * @param {Number} index The index to insert the item at.
 * @param {String} key The key to associate with the new item, or the item itself.
 * @param {Object} o (optional) If the second parameter was a key, the new item.
 * @return {Object} The item inserted.
 */
    insert : function(index, key, o){
        if(arguments.length == 2){
            o = arguments[1];
            key = this.getKey(o);
        }
        if(index >= this.length){
            return this.add(key, o);
        }
        this.length++;
        this.items.splice(index, 0, o);
        if(typeof key != "undefined" && key != null){
            this.map[key] = o;
        }
        this.keys.splice(index, 0, key);
        this.fireEvent("add", index, o, key);
        return o;
    },

/**
 * Remove an item from the collection.
 * @param {Object} o The item to remove.
 * @return {Object} The item removed or false if no item was removed.
 */
    remove : function(o){
        return this.removeAt(this.indexOf(o));
    },

/**
 * Remove an item from a specified index in the collection. Fires the {@link #remove} event when complete.
 * @param {Number} index The index within the collection of the item to remove.
 * @return {Object} The item removed or false if no item was removed.
 */
    removeAt : function(index){
        if(index < this.length && index >= 0){
            this.length--;
            var o = this.items[index];
            this.items.splice(index, 1);
            var key = this.keys[index];
            if(typeof key != "undefined"){
                delete this.map[key];
            }
            this.keys.splice(index, 1);
            this.fireEvent("remove", o, key);
            return o;
        }
        return false;
    },

/**
 * Removed an item associated with the passed key fom the collection.
 * @param {String} key The key of the item to remove.
 * @return {Object} The item removed or false if no item was removed.
 */
    removeKey : function(key){
        return this.removeAt(this.indexOfKey(key));
    },

/**
 * Returns the number of items in the collection.
 * @return {Number} the number of items in the collection.
 */
    getCount : function(){
        return this.length;
    },

/**
 * Returns index within the collection of the passed Object.
 * @param {Object} o The item to find the index of.
 * @return {Number} index of the item.
 */
    indexOf : function(o){
        return this.items.indexOf(o);
    },

/**
 * Returns index within the collection of the passed key.
 * @param {String} key The key to find the index of.
 * @return {Number} index of the key.
 */
    indexOfKey : function(key){
        return this.keys.indexOf(key);
    },

/**
 * Returns the item associated with the passed key OR index. Key has priority over index.  This is the equivalent
 * of calling {@link #key} first, then if nothing matched calling {@link #itemAt}.
 * @param {String/Number} key The key or index of the item.
 * @return {Object} The item associated with the passed key.
 */
    item : function(key){
        var item = typeof this.map[key] != "undefined" ? this.map[key] : this.items[key];
        return typeof item != 'function' || this.allowFunctions ? item : null; // for prototype!
    },

/**
 * Returns the item at the specified index.
 * @param {Number} index The index of the item.
 * @return {Object} The item at the specified index.
 */
    itemAt : function(index){
        return this.items[index];
    },

/**
 * Returns the item associated with the passed key.
 * @param {String/Number} key The key of the item.
 * @return {Object} The item associated with the passed key.
 */
    key : function(key){
        return this.map[key];
    },

/**
 * Returns true if the collection contains the passed Object as an item.
 * @param {Object} o  The Object to look for in the collection.
 * @return {Boolean} True if the collection contains the Object as an item.
 */
    contains : function(o){
        return this.indexOf(o) != -1;
    },

/**
 * Returns true if the collection contains the passed Object as a key.
 * @param {String} key The key to look for in the collection.
 * @return {Boolean} True if the collection contains the Object as a key.
 */
    containsKey : function(key){
        return typeof this.map[key] != "undefined";
    },

/**
 * Removes all items from the collection.  Fires the {@link #clear} event when complete.
 */
    clear : function(){
        this.length = 0;
        this.items = [];
        this.keys = [];
        this.map = {};
        this.fireEvent("clear");
    },

/**
 * Returns the first item in the collection.
 * @return {Object} the first item in the collection..
 */
    first : function(){
        return this.items[0];
    },

/**
 * Returns the last item in the collection.
 * @return {Object} the last item in the collection..
 */
    last : function(){
        return this.items[this.length-1];
    },

    // private
    _sort : function(property, dir, fn){
        var dsc = String(dir).toUpperCase() == "DESC" ? -1 : 1;
        fn = fn || function(a, b){
            return a-b;
        };
        var c = [], k = this.keys, items = this.items;
        for(var i = 0, len = items.length; i < len; i++){
            c[c.length] = {key: k[i], value: items[i], index: i};
        }
        c.sort(function(a, b){
            var v = fn(a[property], b[property]) * dsc;
            if(v == 0){
                v = (a.index < b.index ? -1 : 1);
            }
            return v;
        });
        for(var i = 0, len = c.length; i < len; i++){
            items[i] = c[i].value;
            k[i] = c[i].key;
        }
        this.fireEvent("sort", this);
    },

    /**
     * Sorts this collection with the passed comparison function
     * @param {String} direction (optional) "ASC" or "DESC"
     * @param {Function} fn (optional) comparison function
     */
    sort : function(dir, fn){
        this._sort("value", dir, fn);
    },

    /**
     * Sorts this collection by keys
     * @param {String} direction (optional) "ASC" or "DESC"
     * @param {Function} fn (optional) a comparison function (defaults to case insensitive string)
     */
    keySort : function(dir, fn){
        this._sort("key", dir, fn || function(a, b){
            return String(a).toUpperCase()-String(b).toUpperCase();
        });
    },

    /**
     * Returns a range of items in this collection
     * @param {Number} startIndex (optional) defaults to 0
     * @param {Number} endIndex (optional) default to the last item
     * @return {Array} An array of items
     */
    getRange : function(start, end){
        var items = this.items;
        if(items.length < 1){
            return [];
        }
        start = start || 0;
        end = Math.min(typeof end == "undefined" ? this.length-1 : end, this.length-1);
        var r = [];
        if(start <= end){
            for(var i = start; i <= end; i++) {
        	    r[r.length] = items[i];
            }
        }else{
            for(var i = start; i >= end; i--) {
        	    r[r.length] = items[i];
            }
        }
        return r;
    },

    /**
     * Filter the <i>objects</i> in this collection by a specific property.
     * Returns a new collection that has been filtered.
     * @param {String} property A property on your objects
     * @param {String/RegExp} value Either string that the property values
     * should start with or a RegExp to test against the property
     * @param {Boolean} anyMatch (optional) True to match any part of the string, not just the beginning
     * @param {Boolean} caseSensitive (optional) True for case sensitive comparison (defaults to False).
     * @return {MixedCollection} The new filtered collection
     */
    filter : function(property, value, anyMatch, caseSensitive){
        if(Ext.isEmpty(value, false)){
            return this.clone();
        }
        value = this.createValueMatcher(value, anyMatch, caseSensitive);
        return this.filterBy(function(o){
            return o && value.test(o[property]);
        });
	},

    /**
     * Filter by a function. Returns a <i>new</i> collection that has been filtered.
     * The passed function will be called with each object in the collection.
     * If the function returns true, the value is included otherwise it is filtered.
     * @param {Function} fn The function to be called, it will receive the args o (the object), k (the key)
     * @param {Object} scope (optional) The scope of the function (defaults to this)
     * @return {MixedCollection} The new filtered collection
     */
    filterBy : function(fn, scope){
        var r = new Ext.util.MixedCollection();
        r.getKey = this.getKey;
        var k = this.keys, it = this.items;
        for(var i = 0, len = it.length; i < len; i++){
            if(fn.call(scope||this, it[i], k[i])){
				r.add(k[i], it[i]);
			}
        }
        return r;
    },

    /**
     * Finds the index of the first matching object in this collection by a specific property/value.
     * @param {String} property The name of a property on your objects.
     * @param {String/RegExp} value A string that the property values
     * should start with or a RegExp to test against the property.
     * @param {Number} start (optional) The index to start searching at (defaults to 0).
     * @param {Boolean} anyMatch (optional) True to match any part of the string, not just the beginning.
     * @param {Boolean} caseSensitive (optional) True for case sensitive comparison.
     * @return {Number} The matched index or -1
     */
    findIndex : function(property, value, start, anyMatch, caseSensitive){
        if(Ext.isEmpty(value, false)){
            return -1;
        }
        value = this.createValueMatcher(value, anyMatch, caseSensitive);
        return this.findIndexBy(function(o){
            return o && value.test(o[property]);
        }, null, start);
	},

    /**
     * Find the index of the first matching object in this collection by a function.
     * If the function returns <i>true</i> it is considered a match.
     * @param {Function} fn The function to be called, it will receive the args o (the object), k (the key).
     * @param {Object} scope (optional) The scope of the function (defaults to this).
     * @param {Number} start (optional) The index to start searching at (defaults to 0).
     * @return {Number} The matched index or -1
     */
    findIndexBy : function(fn, scope, start){
        var k = this.keys, it = this.items;
        for(var i = (start||0), len = it.length; i < len; i++){
            if(fn.call(scope||this, it[i], k[i])){
				return i;
            }
        }
        if(typeof start == 'number' && start > 0){
            for(var i = 0; i < start; i++){
                if(fn.call(scope||this, it[i], k[i])){
                    return i;
                }
            }
        }
        return -1;
    },

    // private
    createValueMatcher : function(value, anyMatch, caseSensitive){
        if(!value.exec){ // not a regex
            value = String(value);
            value = new RegExp((anyMatch === true ? '' : '^') + Ext.escapeRe(value), caseSensitive ? '' : 'i');
        }
        return value;
    },

    /**
     * Creates a duplicate of this collection
     * @return {MixedCollection}
     */
    clone : function(){
        var r = new Ext.util.MixedCollection();
        var k = this.keys, it = this.items;
        for(var i = 0, len = it.length; i < len; i++){
            r.add(k[i], it[i]);
        }
        r.getKey = this.getKey;
        return r;
    }
});
/**
 * Returns the item associated with the passed key or index.
 * @method
 * @param {String/Number} key The key or index of the item.
 * @return {Object} The item associated with the passed key.
 */
Ext.util.MixedCollection.prototype.get = Ext.util.MixedCollection.prototype.item;
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.util.TaskRunner
 * Provides the ability to execute one or more arbitrary tasks in a multithreaded manner.  Generally, you can use
 * the singleton {@link Ext.TaskMgr} instead, but if needed, you can create separate instances of TaskRunner.  Any
 * number of separate tasks can be started at any time and will run independently of each other.  Example usage:
 * <pre><code>
// Start a simple clock task that updates a div once per second
var task = {
    run: function(){
        Ext.fly('clock').update(new Date().format('g:i:s A'));
    },
    interval: 1000 //1 second
}
var runner = new Ext.util.TaskRunner();
runner.start(task);
</code></pre>
 * @constructor
 * @param {Number} interval (optional) The minimum precision in milliseconds supported by this TaskRunner instance
 * (defaults to 10)
 */
Ext.util.TaskRunner = function(interval){
    interval = interval || 10;
    var tasks = [], removeQueue = [];
    var id = 0;
    var running = false;

    // private
    var stopThread = function(){
        running = false;
        clearInterval(id);
        id = 0;
    };

    // private
    var startThread = function(){
        if(!running){
            running = true;
            id = setInterval(runTasks, interval);
        }
    };

    // private
    var removeTask = function(t){
        removeQueue.push(t);
        if(t.onStop){
            t.onStop.apply(t.scope || t);
        }
    };

    // private
    var runTasks = function(){
        if(removeQueue.length > 0){
            for(var i = 0, len = removeQueue.length; i < len; i++){
                tasks.remove(removeQueue[i]);
            }
            removeQueue = [];
            if(tasks.length < 1){
                stopThread();
                return;
            }
        }
        var now = new Date().getTime();
        for(var i = 0, len = tasks.length; i < len; ++i){
            var t = tasks[i];
            var itime = now - t.taskRunTime;
            if(t.interval <= itime){
                var rt = t.run.apply(t.scope || t, t.args || [++t.taskRunCount]);
                t.taskRunTime = now;
                if(rt === false || t.taskRunCount === t.repeat){
                    removeTask(t);
                    return;
                }
            }
            if(t.duration && t.duration <= (now - t.taskStartTime)){
                removeTask(t);
            }
        }
    };

    /**
     * Starts a new task.
     * @param {Object} task A config object that supports the following properties:<ul>
     * <li><code>run</code> : Function<div class="sub-desc">The function to execute each time the task is run. The
     * function will be called at each interval and passed the <code>args</code> argument if specified.  If a
     * particular scope is required, be sure to specify it using the <code>scope</scope> argument.</div></li>
     * <li><code>interval</code> : Number<div class="sub-desc">The frequency in milliseconds with which the task
     * should be executed.</div></li>
     * <li><code>args</code> : Array<div class="sub-desc">(optional) An array of arguments to be passed to the function
     * specified by <code>run</code>.</div></li>
     * <li><code>scope</code> : Object<div class="sub-desc">(optional) The scope in which to execute the
     * <code>run</code> function.</div></li>
     * <li><code>duration</code> : Number<div class="sub-desc">(optional) The length of time in milliseconds to execute
     * the task before stopping automatically (defaults to indefinite).</div></li>
     * <li><code>repeat</code> : Number<div class="sub-desc">(optional) The number of times to execute the task before
     * stopping automatically (defaults to indefinite).</div></li>
     * </ul>
     * @return {Object} The task
     */
    this.start = function(task){
        tasks.push(task);
        task.taskStartTime = new Date().getTime();
        task.taskRunTime = 0;
        task.taskRunCount = 0;
        startThread();
        return task;
    };

    /**
     * Stops an existing running task.
     * @param {Object} task The task to stop
     * @return {Object} The task
     */
    this.stop = function(task){
        removeTask(task);
        return task;
    };

    /**
     * Stops all tasks that are currently running.
     */
    this.stopAll = function(){
        stopThread();
        for(var i = 0, len = tasks.length; i < len; i++){
            if(tasks[i].onStop){
                tasks[i].onStop();
            }
        }
        tasks = [];
        removeQueue = [];
    };
};

/**
 * @class Ext.TaskMgr
 * A static {@link Ext.util.TaskRunner} instance that can be used to start and stop arbitrary tasks.  See
 * {@link Ext.util.TaskRunner} for supported methods and task config properties.
 * <pre><code>
// Start a simple clock task that updates a div once per second
var task = {
    run: function(){
        Ext.fly('clock').update(new Date().format('g:i:s A'));
    },
    interval: 1000 //1 second
}
Ext.TaskMgr.start(task);
</code></pre>
 * @singleton
 */
Ext.TaskMgr = new Ext.util.TaskRunner();
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.util.DelayedTask
 * Provides a convenient method of performing setTimeout where a new
 * timeout cancels the old timeout. An example would be performing validation on a keypress.
 * You can use this class to buffer
 * the keypress events for a certain number of milliseconds, and perform only if they stop
 * for that amount of time.
 * @constructor The parameters to this constructor serve as defaults and are not required.
 * @param {Function} fn (optional) The default function to timeout
 * @param {Object} scope (optional) The default scope of that timeout
 * @param {Array} args (optional) The default Array of arguments
 */
Ext.util.DelayedTask = function(fn, scope, args){
    var id = null, d, t;

    var call = function(){
        var now = new Date().getTime();
        if(now - t >= d){
            clearInterval(id);
            id = null;
            fn.apply(scope, args || []);
        }
    };
    /**
     * Cancels any pending timeout and queues a new one
     * @param {Number} delay The milliseconds to delay
     * @param {Function} newFn (optional) Overrides function passed to constructor
     * @param {Object} newScope (optional) Overrides scope passed to constructor
     * @param {Array} newArgs (optional) Overrides args passed to constructor
     */
    this.delay = function(delay, newFn, newScope, newArgs){
        if(id && delay != d){
            this.cancel();
        }
        d = delay;
        t = new Date().getTime();
        fn = newFn || fn;
        scope = newScope || scope;
        args = newArgs || args;
        if(!id){
            id = setInterval(call, d);
        }
    };

    /**
     * Cancel the last queued timeout
     */
    this.cancel = function(){
        if(id){
            clearInterval(id);
            id = null;
        }
    };
};
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.KeyMap
 * Handles mapping keys to actions for an element. One key map can be used for multiple actions.
 * The constructor accepts the same config object as defined by {@link #addBinding}.
 * If you bind a callback function to a KeyMap, anytime the KeyMap handles an expected key
 * combination it will call the function with this signature (if the match is a multi-key
 * combination the callback will still be called only once): (String key, Ext.EventObject e)
 * A KeyMap can also handle a string representation of keys.<br />
 * Usage:
 <pre><code>
// map one key by key code
var map = new Ext.KeyMap("my-element", {
    key: 13, // or Ext.EventObject.ENTER
    fn: myHandler,
    scope: myObject
});

// map multiple keys to one action by string
var map = new Ext.KeyMap("my-element", {
    key: "a\r\n\t",
    fn: myHandler,
    scope: myObject
});

// map multiple keys to multiple actions by strings and array of codes
var map = new Ext.KeyMap("my-element", [
    {
        key: [10,13],
        fn: function(){ alert("Return was pressed"); }
    }, {
        key: "abc",
        fn: function(){ alert('a, b or c was pressed'); }
    }, {
        key: "\t",
        ctrl:true,
        shift:true,
        fn: function(){ alert('Control + shift + tab was pressed.'); }
    }
]);
</code></pre>
 * <b>Note: A KeyMap starts enabled</b>
 * @constructor
 * @param {Mixed} el The element to bind to
 * @param {Object} config The config (see {@link #addBinding})
 * @param {String} eventName (optional) The event to bind to (defaults to "keydown")
 */
Ext.KeyMap = function(el, config, eventName){
    this.el  = Ext.get(el);
    this.eventName = eventName || "keydown";
    this.bindings = [];
    if(config){
        this.addBinding(config);
    }
    this.enable();
};

Ext.KeyMap.prototype = {
    /**
     * True to stop the event from bubbling and prevent the default browser action if the
     * key was handled by the KeyMap (defaults to false)
     * @type Boolean
     */
    stopEvent : false,

    /**
     * Add a new binding to this KeyMap. The following config object properties are supported:
     * <pre>
Property    Type             Description
----------  ---------------  ----------------------------------------------------------------------
key         String/Array     A single keycode or an array of keycodes to handle
shift       Boolean          True to handle key only when shift is pressed (defaults to false)
ctrl        Boolean          True to handle key only when ctrl is pressed (defaults to false)
alt         Boolean          True to handle key only when alt is pressed (defaults to false)
handler     Function         The function to call when KeyMap finds the expected key combination
fn          Function         Alias of handler (for backwards-compatibility)
scope       Object           The scope of the callback function
stopEvent   Boolean          True to stop the event 
</pre>
     *
     * Usage:
     * <pre><code>
// Create a KeyMap
var map = new Ext.KeyMap(document, {
    key: Ext.EventObject.ENTER,
    fn: handleKey,
    scope: this
});

//Add a new binding to the existing KeyMap later
map.addBinding({
    key: 'abc',
    shift: true,
    fn: handleKey,
    scope: this
});
</code></pre>
     * @param {Object/Array} config A single KeyMap config or an array of configs
     */
	addBinding : function(config){
        if(Ext.isArray(config)){
            for(var i = 0, len = config.length; i < len; i++){
                this.addBinding(config[i]);
            }
            return;
        }
        var keyCode = config.key,
            shift = config.shift,
            ctrl = config.ctrl,
            alt = config.alt,
            fn = config.fn || config.handler,
            scope = config.scope;
	
	if (config.stopEvent) {
	    this.stopEvent = config.stopEvent;    
	}	

        if(typeof keyCode == "string"){
            var ks = [];
            var keyString = keyCode.toUpperCase();
            for(var j = 0, len = keyString.length; j < len; j++){
                ks.push(keyString.charCodeAt(j));
            }
            keyCode = ks;
        }
        var keyArray = Ext.isArray(keyCode);
        
        var handler = function(e){
            if((!shift || e.shiftKey) && (!ctrl || e.ctrlKey) &&  (!alt || e.altKey)){
                var k = e.getKey();
                if(keyArray){
                    for(var i = 0, len = keyCode.length; i < len; i++){
                        if(keyCode[i] == k){
                          if(this.stopEvent){
                              e.stopEvent();
                          }
                          fn.call(scope || window, k, e);
                          return;
                        }
                    }
                }else{
                    if(k == keyCode){
                        if(this.stopEvent){
                           e.stopEvent();
                        }
                        fn.call(scope || window, k, e);
                    }
                }
            }
        };
        this.bindings.push(handler);
	},

    /**
     * Shorthand for adding a single key listener
     * @param {Number/Array/Object} key Either the numeric key code, array of key codes or an object with the
     * following options:
     * {key: (number or array), shift: (true/false), ctrl: (true/false), alt: (true/false)}
     * @param {Function} fn The function to call
     * @param {Object} scope (optional) The scope of the function
     */
    on : function(key, fn, scope){
        var keyCode, shift, ctrl, alt;
        if(typeof key == "object" && !Ext.isArray(key)){
            keyCode = key.key;
            shift = key.shift;
            ctrl = key.ctrl;
            alt = key.alt;
        }else{
            keyCode = key;
        }
        this.addBinding({
            key: keyCode,
            shift: shift,
            ctrl: ctrl,
            alt: alt,
            fn: fn,
            scope: scope
        })
    },

    // private
    handleKeyDown : function(e){
	    if(this.enabled){ //just in case
    	    var b = this.bindings;
    	    for(var i = 0, len = b.length; i < len; i++){
    	        b[i].call(this, e);
    	    }
	    }
	},

	/**
	 * Returns true if this KeyMap is enabled
	 * @return {Boolean}
	 */
	isEnabled : function(){
	    return this.enabled;
	},

	/**
	 * Enables this KeyMap
	 */
	enable: function(){
		if(!this.enabled){
		    this.el.on(this.eventName, this.handleKeyDown, this);
		    this.enabled = true;
		}
	},

	/**
	 * Disable this KeyMap
	 */
	disable: function(){
		if(this.enabled){
		    this.el.removeListener(this.eventName, this.handleKeyDown, this);
		    this.enabled = false;
		}
	}
};
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.KeyNav
 * <p>Provides a convenient wrapper for normalized keyboard navigation.  KeyNav allows you to bind
 * navigation keys to function calls that will get called when the keys are pressed, providing an easy
 * way to implement custom navigation schemes for any UI component.</p>
 * <p>The following are all of the possible keys that can be implemented: enter, left, right, up, down, tab, esc,
 * pageUp, pageDown, del, home, end.  Usage:</p>
 <pre><code>
var nav = new Ext.KeyNav("my-element", {
    "left" : function(e){
        this.moveLeft(e.ctrlKey);
    },
    "right" : function(e){
        this.moveRight(e.ctrlKey);
    },
    "enter" : function(e){
        this.save();
    },
    scope : this
});
</code></pre>
 * @constructor
 * @param {Mixed} el The element to bind to
 * @param {Object} config The config
 */
Ext.KeyNav = function(el, config){
    this.el = Ext.get(el);
    Ext.apply(this, config);
    if(!this.disabled){
        this.disabled = true;
        this.enable();
    }
};

Ext.KeyNav.prototype = {
    /**
     * @cfg {Boolean} disabled
     * True to disable this KeyNav instance (defaults to false)
     */
    disabled : false,
    /**
     * @cfg {String} defaultEventAction
     * The method to call on the {@link Ext.EventObject} after this KeyNav intercepts a key.  Valid values are
     * {@link Ext.EventObject#stopEvent}, {@link Ext.EventObject#preventDefault} and
     * {@link Ext.EventObject#stopPropagation} (defaults to 'stopEvent')
     */
    defaultEventAction: "stopEvent",
    /**
     * @cfg {Boolean} forceKeyDown
     * Handle the keydown event instead of keypress (defaults to false).  KeyNav automatically does this for IE since
     * IE does not propagate special keys on keypress, but setting this to true will force other browsers to also
     * handle keydown instead of keypress.
     */
    forceKeyDown : false,

    // private
    prepareEvent : function(e){
        var k = e.getKey();
        var h = this.keyToHandler[k];
        //if(h && this[h]){
        //    e.stopPropagation();
        //}
        if(Ext.isSafari2 && h && k >= 37 && k <= 40){
            e.stopEvent();
        }
    },

    // private
    relay : function(e){
        var k = e.getKey();
        var h = this.keyToHandler[k];
        if(h && this[h]){
            if(this.doRelay(e, this[h], h) !== true){
                e[this.defaultEventAction]();
            }
        }
    },

    // private
    doRelay : function(e, h, hname){
        return h.call(this.scope || this, e);
    },

    // possible handlers
    enter : false,
    left : false,
    right : false,
    up : false,
    down : false,
    tab : false,
    esc : false,
    pageUp : false,
    pageDown : false,
    del : false,
    home : false,
    end : false,

    // quick lookup hash
    keyToHandler : {
        37 : "left",
        39 : "right",
        38 : "up",
        40 : "down",
        33 : "pageUp",
        34 : "pageDown",
        46 : "del",
        36 : "home",
        35 : "end",
        13 : "enter",
        27 : "esc",
        9  : "tab"
    },

	/**
	 * Enable this KeyNav
	 */
	enable: function(){
		if(this.disabled){
            if(this.forceKeyDown || Ext.isIE || Ext.isSafari3 || Ext.isAir){
                this.el.on("keydown", this.relay,  this);
            }else{
                this.el.on("keydown", this.prepareEvent,  this);
                this.el.on("keypress", this.relay,  this);
            }
		    this.disabled = false;
		}
	},

	/**
	 * Disable this KeyNav
	 */
	disable: function(){
		if(!this.disabled){
		    if(this.forceKeyDown || Ext.isIE || Ext.isSafari3 || Ext.isAir){
                this.el.un("keydown", this.relay);
            }else{
                this.el.un("keydown", this.prepareEvent);
                this.el.un("keypress", this.relay);
            }
		    this.disabled = true;
		}
	}
};
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 @class Ext.util.ClickRepeater
 @extends Ext.util.Observable

 A wrapper class which can be applied to any element. Fires a "click" event while the
 mouse is pressed. The interval between firings may be specified in the config but
 defaults to 20 milliseconds.

 Optionally, a CSS class may be applied to the element during the time it is pressed.

 @cfg {Mixed} el The element to act as a button.
 @cfg {Number} delay The initial delay before the repeating event begins firing.
 Similar to an autorepeat key delay.
 @cfg {Number} interval The interval between firings of the "click" event. Default 20 ms.
 @cfg {String} pressClass A CSS class name to be applied to the element while pressed.
 @cfg {Boolean} accelerate True if autorepeating should start slowly and accelerate.
           "interval" and "delay" are ignored.
 @cfg {Boolean} preventDefault True to prevent the default click event
 @cfg {Boolean} stopDefault True to stop the default click event

 @history
    2007-02-02 jvs Original code contributed by Nige "Animal" White
    2007-02-02 jvs Renamed to ClickRepeater
    2007-02-03 jvs Modifications for FF Mac and Safari

 @constructor
 @param {Mixed} el The element to listen on
 @param {Object} config
 */
Ext.util.ClickRepeater = function(el, config)
{
    this.el = Ext.get(el);
    this.el.unselectable();

    Ext.apply(this, config);

    this.addEvents(
    /**
     * @event mousedown
     * Fires when the mouse button is depressed.
     * @param {Ext.util.ClickRepeater} this
     */
        "mousedown",
    /**
     * @event click
     * Fires on a specified interval during the time the element is pressed.
     * @param {Ext.util.ClickRepeater} this
     */
        "click",
    /**
     * @event mouseup
     * Fires when the mouse key is released.
     * @param {Ext.util.ClickRepeater} this
     */
        "mouseup"
    );

    this.el.on("mousedown", this.handleMouseDown, this);
    if(this.preventDefault || this.stopDefault){
        this.el.on("click", function(e){
            if(this.preventDefault){
                e.preventDefault();
            }
            if(this.stopDefault){
                e.stopEvent();
            }
        }, this);
    }

    // allow inline handler
    if(this.handler){
        this.on("click", this.handler,  this.scope || this);
    }

    Ext.util.ClickRepeater.superclass.constructor.call(this);
};

Ext.extend(Ext.util.ClickRepeater, Ext.util.Observable, {
    interval : 20,
    delay: 250,
    preventDefault : true,
    stopDefault : false,
    timer : 0,

    // private
    handleMouseDown : function(){
        clearTimeout(this.timer);
        this.el.blur();
        if(this.pressClass){
            this.el.addClass(this.pressClass);
        }
        this.mousedownTime = new Date();

        Ext.getDoc().on("mouseup", this.handleMouseUp, this);
        this.el.on("mouseout", this.handleMouseOut, this);

        this.fireEvent("mousedown", this);
        this.fireEvent("click", this);

//      Do not honor delay or interval if acceleration wanted.
        if (this.accelerate) {
            this.delay = 400;
	    }
        this.timer = this.click.defer(this.delay || this.interval, this);
    },

    // private
    click : function(){
        this.fireEvent("click", this);
        this.timer = this.click.defer(this.accelerate ?
            this.easeOutExpo(this.mousedownTime.getElapsed(),
                400,
                -390,
                12000) :
            this.interval, this);
    },

    easeOutExpo : function (t, b, c, d) {
        return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
    },

    // private
    handleMouseOut : function(){
        clearTimeout(this.timer);
        if(this.pressClass){
            this.el.removeClass(this.pressClass);
        }
        this.el.on("mouseover", this.handleMouseReturn, this);
    },

    // private
    handleMouseReturn : function(){
        this.el.un("mouseover", this.handleMouseReturn, this);
        if(this.pressClass){
            this.el.addClass(this.pressClass);
        }
        this.click();
    },

    // private
    handleMouseUp : function(){
        clearTimeout(this.timer);
        this.el.un("mouseover", this.handleMouseReturn, this);
        this.el.un("mouseout", this.handleMouseOut, this);
        Ext.getDoc().un("mouseup", this.handleMouseUp, this);
        this.el.removeClass(this.pressClass);
        this.fireEvent("mouseup", this);
    }
});
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Date
 *
 * The date parsing and format syntax is a subset of
 * <a href="http://www.php.net/date">PHP's date() function</a>, and the formats that are
 * supported will provide results equivalent to their PHP versions.
 *
 * The following is a list of all currently supported formats:
 *<pre>
Format  Description                                                               Example returned values
------  -----------------------------------------------------------------------   -----------------------
  d     Day of the month, 2 digits with leading zeros                             01 to 31
  D     A short textual representation of the day of the week                     Mon to Sun
  j     Day of the month without leading zeros                                    1 to 31
  l     A full textual representation of the day of the week                      Sunday to Saturday
  N     ISO-8601 numeric representation of the day of the week                    1 (for Monday) through 7 (for Sunday)
  S     English ordinal suffix for the day of the month, 2 characters             st, nd, rd or th. Works well with j
  w     Numeric representation of the day of the week                             0 (for Sunday) to 6 (for Saturday)
  z     The day of the year (starting from 0)                                     0 to 364 (365 in leap years)
  W     ISO-8601 week number of year, weeks starting on Monday                    01 to 53
  F     A full textual representation of a month, such as January or March        January to December
  m     Numeric representation of a month, with leading zeros                     01 to 12
  M     A short textual representation of a month                                 Jan to Dec
  n     Numeric representation of a month, without leading zeros                  1 to 12
  t     Number of days in the given month                                         28 to 31
  L     Whether it's a leap year                                                  1 if it is a leap year, 0 otherwise.
  o     ISO-8601 year number (identical to (Y), but if the ISO week number (W)    Examples: 1998 or 2004
        belongs to the previous or next year, that year is used instead)
  Y     A full numeric representation of a year, 4 digits                         Examples: 1999 or 2003
  y     A two digit representation of a year                                      Examples: 99 or 03
  a     Lowercase Ante meridiem and Post meridiem                                 am or pm
  A     Uppercase Ante meridiem and Post meridiem                                 AM or PM
  g     12-hour format of an hour without leading zeros                           1 to 12
  G     24-hour format of an hour without leading zeros                           0 to 23
  h     12-hour format of an hour with leading zeros                              01 to 12
  H     24-hour format of an hour with leading zeros                              00 to 23
  i     Minutes, with leading zeros                                               00 to 59
  s     Seconds, with leading zeros                                               00 to 59
  u     Milliseconds, with leading zeroes (arbitrary number of digits allowed)    Examples:
                                                                                  001 (i.e. 1ms) or
                                                                                  100 (i.e. 100ms) or
                                                                                  999 (i.e. 999ms) or
                                                                                  999876543210 (i.e. 999.876543210ms)
  O     Difference to Greenwich time (GMT) in hours and minutes                   Example: +1030
  P     Difference to Greenwich time (GMT) with colon between hours and minutes   Example: -08:00
  T     Timezone abbreviation of the machine running the code                     Examples: EST, MDT, PDT ...
  Z     Timezone offset in seconds (negative if west of UTC, positive if east)    -43200 to 50400
  c     ISO 8601 date (note: milliseconds, if present, must be specified with     Examples:
        at least 1 digit. There is no limit to how many digits the millisecond    2007-04-17T15:19:21+08:00 or
        value may contain. see http://www.w3.org/TR/NOTE-datetime for more info)  2008-03-16T16:18:22Z or
                                                                                  2009-02-15T17:17:23.9+01:00 or
                                                                                  2010-01-14T18:16:24,999876543-07:00
  U     Seconds since the Unix Epoch (January 1 1970 00:00:00 GMT)                1193432466 or -2138434463
</pre>
 *
 * Example usage (note that you must escape format specifiers with '\\' to render them as character literals):
 * <pre><code>
// Sample date:
// 'Wed Jan 10 2007 15:05:01 GMT-0600 (Central Standard Time)'

var dt = new Date('1/10/2007 03:05:01 PM GMT-0600');
document.write(dt.format('Y-m-d'));                           // 2007-01-10
document.write(dt.format('F j, Y, g:i a'));                   // January 10, 2007, 3:05 pm
document.write(dt.format('l, \\t\\he jS \\of F Y h:i:s A'));  // Wednesday, the 10th of January 2007 03:05:01 PM
 </code></pre>
 *
 * Here are some standard date/time patterns that you might find helpful.  They
 * are not part of the source of Date.js, but to use them you can simply copy this
 * block of code into any script that is included after Date.js and they will also become
 * globally available on the Date object.  Feel free to add or remove patterns as needed in your code.
 * <pre><code>
Date.patterns = {
    ISO8601Long:"Y-m-d H:i:s",
    ISO8601Short:"Y-m-d",
    ShortDate: "n/j/Y",
    LongDate: "l, F d, Y",
    FullDateTime: "l, F d, Y g:i:s A",
    MonthDay: "F d",
    ShortTime: "g:i A",
    LongTime: "g:i:s A",
    SortableDateTime: "Y-m-d\\TH:i:s",
    UniversalSortableDateTime: "Y-m-d H:i:sO",
    YearMonth: "F, Y"
};
</code></pre>
 *
 * Example usage:
 * <pre><code>
var dt = new Date();
document.write(dt.format(Date.patterns.ShortDate));
 </code></pre>
 */

/*
 * Most of the date-formatting functions below are the excellent work of Baron Schwartz.
 * (see http://www.xaprb.com/blog/2005/12/12/javascript-closures-for-runtime-efficiency/)
 * They generate precompiled functions from format patterns instead of parsing and
 * processing each pattern every time a date is formatted. These functions are available
 * on every Date object.
 */

(function() {
// private
Date.formatCodeToRegex = function(character, currentGroup) {
    // Note: currentGroup - position in regex result array (see notes for Date.parseCodes below)
    var p = Date.parseCodes[character];

    if (p) {
      p = Ext.type(p) == 'function'? p() : p;
      Date.parseCodes[character] = p; // reassign function result to prevent repeated execution
    }

    return p? Ext.applyIf({
      c: p.c? String.format(p.c, currentGroup || "{0}") : p.c
    }, p) : {
        g:0,
        c:null,
        s:Ext.escapeRe(character) // treat unrecognised characters as literals
    }
}

// private shorthand for Date.formatCodeToRegex since we'll be using it fairly often
var $f = Date.formatCodeToRegex;

Ext.apply(Date, {
    // private
    parseFunctions: {count:0},
    parseRegexes: [],
    formatFunctions: {count:0},
    daysInMonth : [31,28,31,30,31,30,31,31,30,31,30,31],
    y2kYear : 50,

    /**
     * Date interval constant
     * @static
     * @type String
     */
    MILLI : "ms",

    /**
     * Date interval constant
     * @static
     * @type String
     */
    SECOND : "s",

    /**
     * Date interval constant
     * @static
     * @type String
     */
    MINUTE : "mi",

    /** Date interval constant
     * @static
     * @type String
     */
    HOUR : "h",

    /**
     * Date interval constant
     * @static
     * @type String
     */
    DAY : "d",

    /**
     * Date interval constant
     * @static
     * @type String
     */
    MONTH : "mo",

    /**
     * Date interval constant
     * @static
     * @type String
     */
    YEAR : "y",

    /**
     * An array of textual day names.
     * Override these values for international dates.
     * Example:
     *<pre><code>
    Date.dayNames = [
      'SundayInYourLang',
      'MondayInYourLang',
      ...
    ];
    </code></pre>
     * @type Array
     * @static
     */
    dayNames : [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"
    ],

    /**
     * An array of textual month names.
     * Override these values for international dates.
     * Example:
     *<pre><code>
    Date.monthNames = [
      'JanInYourLang',
      'FebInYourLang',
      ...
    ];
    </code></pre>
     * @type Array
     * @static
     */
    monthNames : [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ],

    /**
     * An object hash of zero-based javascript month numbers (with short month names as keys. note: keys are case-sensitive).
     * Override these values for international dates.
     * Example:
     *<pre><code>
    Date.monthNumbers = {
      'ShortJanNameInYourLang':0,
      'ShortFebNameInYourLang':1,
      ...
    };
    </code></pre>
     * @type Object
     * @static
     */
    monthNumbers : {
        Jan:0,
        Feb:1,
        Mar:2,
        Apr:3,
        May:4,
        Jun:5,
        Jul:6,
        Aug:7,
        Sep:8,
        Oct:9,
        Nov:10,
        Dec:11
    },

    /**
     * Get the short month name for the given month number.
     * Override this function for international dates.
     * @param {Number} month A zero-based javascript month number.
     * @return {String} The short month name.
     * @static
     */
    getShortMonthName : function(month) {
        return Date.monthNames[month].substring(0, 3);
    },

    /**
     * Get the short day name for the given day number.
     * Override this function for international dates.
     * @param {Number} day A zero-based javascript day number.
     * @return {String} The short day name.
     * @static
     */
    getShortDayName : function(day) {
        return Date.dayNames[day].substring(0, 3);
    },

    /**
     * Get the zero-based javascript month number for the given short/full month name.
     * Override this function for international dates.
     * @param {String} name The short/full month name.
     * @return {Number} The zero-based javascript month number.
     * @static
     */
    getMonthNumber : function(name) {
        // handle camel casing for english month names (since the keys for the Date.monthNumbers hash are case sensitive)
        return Date.monthNumbers[name.substring(0, 1).toUpperCase() + name.substring(1, 3).toLowerCase()];
    },

    /**
     * The base format-code to formatting-function hashmap used by the {@link #format} method.
     * Formatting functions are strings (or functions which return strings) which
     * will return the appropriate value when evaluated in the context of the Date object
     * from which the {@link #format} method is called.
     * Add to / override these mappings for custom date formatting.
     * Note: Date.format() treats characters as literals if an appropriate mapping cannot be found.
     * Example:
    <pre><code>
    Date.formatCodes.x = "String.leftPad(this.getDate(), 2, '0')";
    (new Date()).format("X"); // returns the current day of the month
    </code></pre>
     * @type Object
     * @static
     */
    formatCodes : {
        d: "String.leftPad(this.getDate(), 2, '0')",
        D: "Date.getShortDayName(this.getDay())", // get localised short day name
        j: "this.getDate()",
        l: "Date.dayNames[this.getDay()]",
        N: "(this.getDay() ? this.getDay() : 7)",
        S: "this.getSuffix()",
        w: "this.getDay()",
        z: "this.getDayOfYear()",
        W: "String.leftPad(this.getWeekOfYear(), 2, '0')",
        F: "Date.monthNames[this.getMonth()]",
        m: "String.leftPad(this.getMonth() + 1, 2, '0')",
        M: "Date.getShortMonthName(this.getMonth())", // get localised short month name
        n: "(this.getMonth() + 1)",
        t: "this.getDaysInMonth()",
        L: "(this.isLeapYear() ? 1 : 0)",
        o: "(this.getFullYear() + (this.getWeekOfYear() == 1 && this.getMonth() > 0 ? +1 : (this.getWeekOfYear() >= 52 && this.getMonth() < 11 ? -1 : 0)))",
        Y: "this.getFullYear()",
        y: "('' + this.getFullYear()).substring(2, 4)",
        a: "(this.getHours() < 12 ? 'am' : 'pm')",
        A: "(this.getHours() < 12 ? 'AM' : 'PM')",
        g: "((this.getHours() % 12) ? this.getHours() % 12 : 12)",
        G: "this.getHours()",
        h: "String.leftPad((this.getHours() % 12) ? this.getHours() % 12 : 12, 2, '0')",
        H: "String.leftPad(this.getHours(), 2, '0')",
        i: "String.leftPad(this.getMinutes(), 2, '0')",
        s: "String.leftPad(this.getSeconds(), 2, '0')",
        u: "String.leftPad(this.getMilliseconds(), 3, '0')",
        O: "this.getGMTOffset()",
        P: "this.getGMTOffset(true)",
        T: "this.getTimezone()",
        Z: "(this.getTimezoneOffset() * -60)",
        c: function() { // ISO-8601 -- GMT format
            for (var c = "Y-m-dTH:i:sP", code = [], i = 0, l = c.length; i < l; ++i) {
                var e = c.charAt(i);
                code.push(e == "T" ? "'T'" : Date.getFormatCode(e)); // treat T as a character literal
            }
            return code.join(" + ");
        },
        /*
        c: function() { // ISO-8601 -- UTC format
            return [
              "this.getUTCFullYear()", "'-'",
              "String.leftPad(this.getUTCMonth() + 1, 2, '0')", "'-'",
              "String.leftPad(this.getUTCDate(), 2, '0')",
              "'T'",
              "String.leftPad(this.getUTCHours(), 2, '0')", "':'",
              "String.leftPad(this.getUTCMinutes(), 2, '0')", "':'",
              "String.leftPad(this.getUTCSeconds(), 2, '0')",
              "'Z'"
            ].join(" + ");
        },
        */
        U: "Math.round(this.getTime() / 1000)"
    },

    /**
     * Parses the passed string using the specified format. Note that this function expects dates in normal calendar
     * format, meaning that months are 1-based (1 = January) and not zero-based like in JavaScript dates.  Any part of
     * the date format that is not specified will default to the current date value for that part.  Time parts can also
     * be specified, but default to 0.  Keep in mind that the input date string must precisely match the specified format
     * string or the parse operation will fail.
     * Example Usage:
     *<pre><code>
    //dt = Fri May 25 2007 (current date)
    var dt = new Date();

    //dt = Thu May 25 2006 (today's month/day in 2006)
    dt = Date.parseDate("2006", "Y");

    //dt = Sun Jan 15 2006 (all date parts specified)
    dt = Date.parseDate("2006-01-15", "Y-m-d");

    //dt = Sun Jan 15 2006 15:20:01 GMT-0600 (CST)
    dt = Date.parseDate("2006-01-15 3:20:01 PM", "Y-m-d h:i:s A" );
    </code></pre>
     * @param {String} input The unparsed date as a string.
     * @param {String} format The format the date is in.
     * @return {Date} The parsed date.
     * @static
     */
    parseDate : function(input, format) {
        var p = Date.parseFunctions;
        if (p[format] == null) {
            Date.createParser(format);
        }
        var func = p[format];
        return Date[func](input);
    },

    // private
    getFormatCode : function(character) {
        var f = Date.formatCodes[character];

        if (f) {
          f = Ext.type(f) == 'function'? f() : f;
          Date.formatCodes[character] = f; // reassign function result to prevent repeated execution
        }

        // note: unknown characters are treated as literals
        return f || ("'" + String.escape(character) + "'");
    },

    // private
    createNewFormat : function(format) {
        var funcName = "format" + Date.formatFunctions.count++;
        Date.formatFunctions[format] = funcName;
        var code = "Date.prototype." + funcName + " = function(){return ";
        var special = false;
        var ch = '';
        for (var i = 0; i < format.length; ++i) {
            ch = format.charAt(i);
            if (!special && ch == "\\") {
                special = true;
            }
            else if (special) {
                special = false;
                code += "'" + String.escape(ch) + "' + ";
            }
            else {
                code += Date.getFormatCode(ch) + " + ";
            }
        }
        eval(code.substring(0, code.length - 3) + ";}");
    },

    // private
    createParser : function(format) {
        var funcName = "parse" + Date.parseFunctions.count++;
        var regexNum = Date.parseRegexes.length;
        var currentGroup = 1;
        Date.parseFunctions[format] = funcName;

        var code = "Date." + funcName + " = function(input){\n"
            + "var y, m, d, h = 0, i = 0, s = 0, ms = 0, o, z, u, v;\n"
            + "input = String(input);\n"
            + "d = new Date();\n"
            + "y = d.getFullYear();\n"
            + "m = d.getMonth();\n"
            + "d = d.getDate();\n"
            + "var results = input.match(Date.parseRegexes[" + regexNum + "]);\n"
            + "if (results && results.length > 0) {";
        var regex = "";

        var special = false;
        var ch = '';
        for (var i = 0; i < format.length; ++i) {
            ch = format.charAt(i);
            if (!special && ch == "\\") {
                special = true;
            }
            else if (special) {
                special = false;
                regex += String.escape(ch);
            }
            else {
                var obj = Date.formatCodeToRegex(ch, currentGroup);
                currentGroup += obj.g;
                regex += obj.s;
                if (obj.g && obj.c) {
                    code += obj.c;
                }
            }
        }

        code += "if (u){\n"
            + "v = new Date(u * 1000);\n" // give top priority to UNIX time
            + "}else if (y >= 0 && m >= 0 && d > 0 && h >= 0 && i >= 0 && s >= 0 && ms >= 0){\n"
            + "v = new Date(y, m, d, h, i, s, ms);\n"
            + "}else if (y >= 0 && m >= 0 && d > 0 && h >= 0 && i >= 0 && s >= 0){\n"
            + "v = new Date(y, m, d, h, i, s);\n"
            + "}else if (y >= 0 && m >= 0 && d > 0 && h >= 0 && i >= 0){\n"
            + "v = new Date(y, m, d, h, i);\n"
            + "}else if (y >= 0 && m >= 0 && d > 0 && h >= 0){\n"
            + "v = new Date(y, m, d, h);\n"
            + "}else if (y >= 0 && m >= 0 && d > 0){\n"
            + "v = new Date(y, m, d);\n"
            + "}else if (y >= 0 && m >= 0){\n"
            + "v = new Date(y, m);\n"
            + "}else if (y >= 0){\n"
            + "v = new Date(y);\n"
            + "}\n}\nreturn (v && (z || o))?" // favour UTC offset over GMT offset
            +     " (Ext.type(z) == 'number' ? v.add(Date.SECOND, -v.getTimezoneOffset() * 60 - z) :" // reset to UTC, then add offset
            +         " v.add(Date.MINUTE, -v.getTimezoneOffset() + (sn == '+'? -1 : 1) * (hr * 60 + mn))) : v;\n" // reset to GMT, then add offset
            + "}";

        Date.parseRegexes[regexNum] = new RegExp("^" + regex + "$", "i");
        eval(code);
    },

    // private
    parseCodes : {
        /*
         * Notes:
         * g = {Number} calculation group (0 or 1. only group 1 contributes to date calculations.)
         * c = {String} calculation method (required for group 1. null for group 0. {0} = currentGroup - position in regex result array)
         * s = {String} regex pattern. all matches are stored in results[], and are accessible by the calculation mapped to 'c'
         */
        d: {
            g:1,
            c:"d = parseInt(results[{0}], 10);\n",
            s:"(\\d{2})" // day of month with leading zeroes (01 - 31)
        },
        j: {
            g:1,
            c:"d = parseInt(results[{0}], 10);\n",
            s:"(\\d{1,2})" // day of month without leading zeroes (1 - 31)
        },
        D: function() {
            for (var a = [], i = 0; i < 7; a.push(Date.getShortDayName(i)), ++i); // get localised short day names
            return {
                g:0,
                c:null,
                s:"(?:" + a.join("|") +")"
            }
        },
        l: function() {
            return {
                g:0,
                c:null,
                s:"(?:" + Date.dayNames.join("|") + ")"
            }
        },
        N: {
            g:0,
            c:null,
            s:"[1-7]" // ISO-8601 day number (1 (monday) - 7 (sunday))
        },
        S: {
            g:0,
            c:null,
            s:"(?:st|nd|rd|th)"
        },
        w: {
            g:0,
            c:null,
            s:"[0-6]" // javascript day number (0 (sunday) - 6 (saturday))
        },
        z: {
            g:0,
            c:null,
            s:"(?:\\d{1,3}" // day of the year (0 - 364 (365 in leap years))
        },
        W: {
            g:0,
            c:null,
            s:"(?:\\d{2})" // ISO-8601 week number (with leading zero)
        },
        F: function() {
            return {
                g:1,
                c:"m = parseInt(Date.getMonthNumber(results[{0}]), 10);\n", // get localised month number
                s:"(" + Date.monthNames.join("|") + ")"
            }
        },
        M: function() {
            for (var a = [], i = 0; i < 12; a.push(Date.getShortMonthName(i)), ++i); // get localised short month names
            return Ext.applyIf({
                s:"(" + a.join("|") + ")"
            }, $f("F"));
        },
        m: {
            g:1,
            c:"m = parseInt(results[{0}], 10) - 1;\n",
            s:"(\\d{2})" // month number with leading zeros (01 - 12)
        },
        n: {
            g:1,
            c:"m = parseInt(results[{0}], 10) - 1;\n",
            s:"(\\d{1,2})" // month number without leading zeros (1 - 12)
        },
        t: {
            g:0,
            c:null,
            s:"(?:\\d{2})" // no. of days in the month (28 - 31)
        },
        L: {
            g:0,
            c:null,
            s:"(?:1|0)"
        },
        o: function() {
            return $f("Y");
        },
        Y: {
            g:1,
            c:"y = parseInt(results[{0}], 10);\n",
            s:"(\\d{4})" // 4-digit year
        },
        y: {
            g:1,
            c:"var ty = parseInt(results[{0}], 10);\n"
                + "y = ty > Date.y2kYear ? 1900 + ty : 2000 + ty;\n", // 2-digit year
            s:"(\\d{1,2})"
        },
        a: {
            g:1,
            c:"if (results[{0}] == 'am') {\n"
                + "if (h == 12) { h = 0; }\n"
                + "} else { if (h < 12) { h += 12; }}",
            s:"(am|pm)"
        },
        A: {
            g:1,
            c:"if (results[{0}] == 'AM') {\n"
                + "if (h == 12) { h = 0; }\n"
                + "} else { if (h < 12) { h += 12; }}",
            s:"(AM|PM)"
        },
        g: function() {
            return $f("G");
        },
        G: {
            g:1,
            c:"h = parseInt(results[{0}], 10);\n",
            s:"(\\d{1,2})" // 24-hr format of an hour without leading zeroes (0 - 23)
        },
        h: function() {
            return $f("H");
        },
        H: {
            g:1,
            c:"h = parseInt(results[{0}], 10);\n",
            s:"(\\d{2})" //  24-hr format of an hour with leading zeroes (00 - 23)
        },
        i: {
            g:1,
            c:"i = parseInt(results[{0}], 10);\n",
            s:"(\\d{2})" // minutes with leading zeros (00 - 59)
        },
        s: {
            g:1,
            c:"s = parseInt(results[{0}], 10);\n",
            s:"(\\d{2})" // seconds with leading zeros (00 - 59)
        },
        u: {
            g:1,
            c:"ms = results[{0}]; ms = parseInt(ms, 10)/Math.pow(10, ms.length - 3);\n",
            s:"(\\d+)" // milliseconds with leading zeroes (arbitrary number of digits allowed) e.g. 001, 100, 999, 999876543210
        },
        O: {
            g:1,
            c:[
                "o = results[{0}];",
                "var sn = o.substring(0,1);", // get + / - sign
                "var hr = o.substring(1,3)*1 + Math.floor(o.substring(3,5) / 60);", // get hours (performs minutes-to-hour conversion also, just in case)
                "var mn = o.substring(3,5) % 60;", // get minutes
                "o = ((-12 <= (hr*60 + mn)/60) && ((hr*60 + mn)/60 <= 14))? (sn + String.leftPad(hr, 2, '0') + String.leftPad(mn, 2, '0')) : null;\n" // -12hrs <= GMT offset <= 14hrs
            ].join("\n"),
            s: "([+\-]\\d{4})" // GMT offset in hrs and mins
        },
        P: {
            g:1,
            c:[
                "o = results[{0}];",
                "var sn = o.substring(0,1);", // get + / - sign
                "var hr = o.substring(1,3)*1 + Math.floor(o.substring(4,6) / 60);", // get hours (performs minutes-to-hour conversion also, just in case)
                "var mn = o.substring(4,6) % 60;", // get minutes
                "o = ((-12 <= (hr*60 + mn)/60) && ((hr*60 + mn)/60 <= 14))? (sn + String.leftPad(hr, 2, '0') + String.leftPad(mn, 2, '0')) : null;\n" // -12hrs <= GMT offset <= 14hrs
            ].join("\n"),
            s: "([+\-]\\d{2}:\\d{2})" // GMT offset in hrs and mins (with colon separator)
        },
        T: {
            g:0,
            c:null,
            s:"[A-Z]{1,4}" // timezone abbrev. may be between 1 - 4 chars
        },
        Z: {
            g:1,
            c:"z = results[{0}] * 1;\n" // -43200 <= UTC offset <= 50400
                  + "z = (-43200 <= z && z <= 50400)? z : null;\n",
            s:"([+\-]?\\d{1,5})" // leading '+' sign is optional for UTC offset
        },
        c: function() {
            var calc = [];
            var arr = [
                $f("Y", 1), // year
                $f("m", 2), // month
                $f("d", 3), // day
                $f("h", 4), // hour
                $f("i", 5), // minute
                $f("s", 6), // second
                {c:"ms = (results[7] || '.0').substring(1); ms = parseInt(ms, 10)/Math.pow(10, ms.length - 3);\n"}, // millisecond decimal fraction (with leading zeroes + arbitrary no. of digits)
                {c:"if(results[9] == 'Z'){\no = 0;\n}else{\n" + $f("P", 9).c + "\n}"} // allow both "Z" (i.e. UTC) and "+08:00" (i.e. GMT) time zone delimiters
            ];
            for (var i = 0, l = arr.length; i < l; ++i) {
                calc.push(arr[i].c);
            }

            return {
                g:1,
                c:calc.join(""),
                s:arr[0].s + "-" + arr[1].s + "-" + arr[2].s + "T" + arr[3].s + ":" + arr[4].s + ":" + arr[5].s
                      + "((\.|,)\\d+)?" // ",998465" or ".998465" millisecond decimal fraction
                      + "(" + $f("P", null).s + "|Z)" // "Z" (UTC) or "GMT+08:00" (GMT offset)
            }
        },
        U: {
            g:1,
            c:"u = parseInt(results[{0}], 10);\n",
            s:"(-?\\d+)" // leading minus sign indicates seconds before UNIX epoch
        }
    }
});

}());

Ext.override(Date, {
    // private
    dateFormat : function(format) {
        if (Date.formatFunctions[format] == null) {
            Date.createNewFormat(format);
        }
        var func = Date.formatFunctions[format];
        return this[func]();
    },

    /**
     * Get the timezone abbreviation of the current date (equivalent to the format specifier 'T').
     *
     * Note: The date string returned by the javascript Date object's toString() method varies
     * between browsers (e.g. FF vs IE) and system region settings (e.g. IE in Asia vs IE in America).
     * For a given date string e.g. "Thu Oct 25 2007 22:55:35 GMT+0800 (Malay Peninsula Standard Time)",
     * getTimezone() first tries to get the timezone abbreviation from between a pair of parentheses
     * (which may or may not be present), failing which it proceeds to get the timezone abbreviation
     * from the GMT offset portion of the date string.
     * @return {String} The abbreviated timezone name (e.g. 'CST', 'PDT', 'EDT', 'MPST' ...).
     */
    getTimezone : function() {
        // the following list shows the differences between date strings from different browsers on a WinXP SP2 machine from an Asian locale:
        //
        // Opera  : "Thu, 25 Oct 2007 22:53:45 GMT+0800" -- shortest (weirdest) date string of the lot
        // Safari : "Thu Oct 25 2007 22:55:35 GMT+0800 (Malay Peninsula Standard Time)" -- value in parentheses always gives the correct timezone (same as FF)
        // FF     : "Thu Oct 25 2007 22:55:35 GMT+0800 (Malay Peninsula Standard Time)" -- value in parentheses always gives the correct timezone
        // IE     : "Thu Oct 25 22:54:35 UTC+0800 2007" -- (Asian system setting) look for 3-4 letter timezone abbrev
        // IE     : "Thu Oct 25 17:06:37 PDT 2007" -- (American system setting) look for 3-4 letter timezone abbrev
        //
        // this crazy regex attempts to guess the correct timezone abbreviation despite these differences.
        // step 1: (?:\((.*)\) -- find timezone in parentheses
        // step 2: ([A-Z]{1,4})(?:[\-+][0-9]{4})?(?: -?\d+)?) -- if nothing was found in step 1, find timezone from timezone offset portion of date string
        // step 3: remove all non uppercase characters found in step 1 and 2
        return this.toString().replace(/^.* (?:\((.*)\)|([A-Z]{1,4})(?:[\-+][0-9]{4})?(?: -?\d+)?)$/, "$1$2").replace(/[^A-Z]/g, "");
    },

    /**
     * Get the offset from GMT of the current date (equivalent to the format specifier 'O').
     * @param {Boolean} colon true to separate the hours and minutes with a colon (defaults to false).
     * @return {String} The 4-character offset string prefixed with + or - (e.g. '-0600').
     */
    getGMTOffset : function(colon) {
        return (this.getTimezoneOffset() > 0 ? "-" : "+")
            + String.leftPad(Math.abs(Math.floor(this.getTimezoneOffset() / 60)), 2, "0")
            + (colon ? ":" : "")
            + String.leftPad(Math.abs(this.getTimezoneOffset() % 60), 2, "0");
    },

    /**
     * Get the numeric day number of the year, adjusted for leap year.
     * @return {Number} 0 to 364 (365 in leap years).
     */
    getDayOfYear : function() {
        var num = 0;
        Date.daysInMonth[1] = this.isLeapYear() ? 29 : 28;
        for (var i = 0; i < this.getMonth(); ++i) {
            num += Date.daysInMonth[i];
        }
        return num + this.getDate() - 1;
    },

    /**
     * Get the numeric ISO-8601 week number of the year.
     * (equivalent to the format specifier 'W', but without a leading zero).
     * @return {Number} 1 to 53
     */
    getWeekOfYear : function() {
        // adapted from http://www.merlyn.demon.co.uk/weekcalc.htm
        var ms1d = 864e5; // milliseconds in a day
        var ms7d = 7 * ms1d; // milliseconds in a week
        var DC3 = Date.UTC(this.getFullYear(), this.getMonth(), this.getDate() + 3) / ms1d; // an Absolute Day Number
        var AWN = Math.floor(DC3 / 7); // an Absolute Week Number
        var Wyr = new Date(AWN * ms7d).getUTCFullYear();
        return AWN - Math.floor(Date.UTC(Wyr, 0, 7) / ms7d) + 1;
    },

    /**
     * Whether or not the current date is in a leap year.
     * @return {Boolean} True if the current date is in a leap year, else false.
     */
    isLeapYear : function() {
        var year = this.getFullYear();
        return !!((year & 3) == 0 && (year % 100 || (year % 400 == 0 && year)));
    },

    /**
     * Get the first day of the current month, adjusted for leap year.  The returned value
     * is the numeric day index within the week (0-6) which can be used in conjunction with
     * the {@link #monthNames} array to retrieve the textual day name.
     * Example:
     *<pre><code>
    var dt = new Date('1/10/2007');
    document.write(Date.dayNames[dt.getFirstDayOfMonth()]); //output: 'Monday'
    </code></pre>
     * @return {Number} The day number (0-6).
     */
    getFirstDayOfMonth : function() {
        var day = (this.getDay() - (this.getDate() - 1)) % 7;
        return (day < 0) ? (day + 7) : day;
    },

    /**
     * Get the last day of the current month, adjusted for leap year.  The returned value
     * is the numeric day index within the week (0-6) which can be used in conjunction with
     * the {@link #monthNames} array to retrieve the textual day name.
     * Example:
     *<pre><code>
    var dt = new Date('1/10/2007');
    document.write(Date.dayNames[dt.getLastDayOfMonth()]); //output: 'Wednesday'
    </code></pre>
     * @return {Number} The day number (0-6).
     */
    getLastDayOfMonth : function() {
        var day = (this.getDay() + (Date.daysInMonth[this.getMonth()] - this.getDate())) % 7;
        return (day < 0) ? (day + 7) : day;
    },


    /**
     * Get the date of the first day of the month in which this date resides.
     * @return {Date}
     */
    getFirstDateOfMonth : function() {
        return new Date(this.getFullYear(), this.getMonth(), 1);
    },

    /**
     * Get the date of the last day of the month in which this date resides.
     * @return {Date}
     */
    getLastDateOfMonth : function() {
        return new Date(this.getFullYear(), this.getMonth(), this.getDaysInMonth());
    },

    /**
     * Get the number of days in the current month, adjusted for leap year.
     * @return {Number} The number of days in the month.
     */
    getDaysInMonth : function() {
        Date.daysInMonth[1] = this.isLeapYear() ? 29 : 28;
        return Date.daysInMonth[this.getMonth()];
    },

    /**
     * Get the English ordinal suffix of the current day (equivalent to the format specifier 'S').
     * @return {String} 'st, 'nd', 'rd' or 'th'.
     */
    getSuffix : function() {
        switch (this.getDate()) {
            case 1:
            case 21:
            case 31:
                return "st";
            case 2:
            case 22:
                return "nd";
            case 3:
            case 23:
                return "rd";
            default:
                return "th";
        }
    },

    /**
     * Creates and returns a new Date instance with the exact same date value as the called instance.
     * Dates are copied and passed by reference, so if a copied date variable is modified later, the original
     * variable will also be changed.  When the intention is to create a new variable that will not
     * modify the original instance, you should create a clone.
     *
     * Example of correctly cloning a date:
     * <pre><code>
    //wrong way:
    var orig = new Date('10/1/2006');
    var copy = orig;
    copy.setDate(5);
    document.write(orig);  //returns 'Thu Oct 05 2006'!

    //correct way:
    var orig = new Date('10/1/2006');
    var copy = orig.clone();
    copy.setDate(5);
    document.write(orig);  //returns 'Thu Oct 01 2006'
    </code></pre>
     * @return {Date} The new Date instance.
     */
    clone : function() {
        return new Date(this.getTime());
    },

    /**
     * Clears any time information from this date.
     @param {Boolean} clone true to create a clone of this date, clear the time and return it (defaults to false).
     @return {Date} this or the clone.
     */
    clearTime : function(clone){
        if(clone){
            return this.clone().clearTime();
        }
        this.setHours(0);
        this.setMinutes(0);
        this.setSeconds(0);
        this.setMilliseconds(0);
        return this;
    },

    /**
     * Provides a convenient method of performing basic date arithmetic.  This method
     * does not modify the Date instance being called - it creates and returns
     * a new Date instance containing the resulting date value.
     *
     * Examples:
     * <pre><code>
    //Basic usage:
    var dt = new Date('10/29/2006').add(Date.DAY, 5);
    document.write(dt); //returns 'Fri Oct 06 2006 00:00:00'

    //Negative values will subtract correctly:
    var dt2 = new Date('10/1/2006').add(Date.DAY, -5);
    document.write(dt2); //returns 'Tue Sep 26 2006 00:00:00'

    //You can even chain several calls together in one line!
    var dt3 = new Date('10/1/2006').add(Date.DAY, 5).add(Date.HOUR, 8).add(Date.MINUTE, -30);
    document.write(dt3); //returns 'Fri Oct 06 2006 07:30:00'
     </code></pre>
     *
     * @param {String} interval   A valid date interval enum value.
     * @param {Number} value      The amount to add to the current date.
     * @return {Date} The new Date instance.
     */
    add : function(interval, value){
        var d = this.clone();
        if (!interval || value === 0) return d;

        switch(interval.toLowerCase()){
            case Date.MILLI:
                d.setMilliseconds(this.getMilliseconds() + value);
                break;
            case Date.SECOND:
                d.setSeconds(this.getSeconds() + value);
                break;
            case Date.MINUTE:
                d.setMinutes(this.getMinutes() + value);
                break;
            case Date.HOUR:
                d.setHours(this.getHours() + value);
                break;
            case Date.DAY:
                d.setDate(this.getDate() + value);
                break;
            case Date.MONTH:
                var day = this.getDate();
                if(day > 28){
                    day = Math.min(day, this.getFirstDateOfMonth().add('mo', value).getLastDateOfMonth().getDate());
                }
                d.setDate(day);
                d.setMonth(this.getMonth() + value);
                break;
            case Date.YEAR:
                d.setFullYear(this.getFullYear() + value);
                break;
        }
        return d;
    },

    /**
     * Checks if this date falls on or between the given start and end dates.
     * @param {Date} start Start date
     * @param {Date} end End date
     * @return {Boolean} true if this date falls on or between the given start and end dates.
     */
    between : function(start, end){
        var t = this.getTime();
        return start.getTime() <= t && t <= end.getTime();
    }
});


/**
 * Formats a date given the supplied format string.
 * @param {String} format The format string.
 * @return {String} The formatted date.
 * @method format
 */
Date.prototype.format = Date.prototype.dateFormat;


// private
// safari setMonth is broken
if(Ext.isSafari){
    Date.brokenSetMonth = Date.prototype.setMonth;
    Date.prototype.setMonth = function(num){
        if(num <= -1){
            var n = Math.ceil(-num);
            var back_year = Math.ceil(n/12);
            var month = (n % 12) ? 12 - n % 12 : 0 ;
            this.setFullYear(this.getFullYear() - back_year);
            return Date.brokenSetMonth.call(this, month);
        } else {
            return Date.brokenSetMonth.apply(this, arguments);
        }
    };
}
/*
 * Ext JS Library 2.2
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
            return !value ? value : String(value).replace(/&gt;/g, ">").replace(/&lt;/g, "<").replace(/&quot;/g, '"').replace(/&amp;/g, "&");
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
         * @param {String/Date} value The value to format (Strings must conform to the format expected by the javascript Date object's <a href="http://www.w3schools.com/jsref/jsref_parse.asp">parse()</a> method)
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
        }(),

        nl2br : function(v){
            return v === undefined || v === null ? '' : v.replace(/\n/g, '<br/>');
        }
    };
}();
/*
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
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
    '&lt;p>Company: {[values.company.toUpperCase() + ", " + values.title]}&lt;/p>',
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
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.data.Connection
 * @extends Ext.util.Observable
 * <p>The class encapsulates a connection to the page's originating domain, allowing requests to be made
 * either to a configured URL, or to a URL specified at request time.</p>
 * <p>Requests made by this class are asynchronous, and will return immediately. No data from
 * the server will be available to the statement immediately following the {@link #request} call.
 * To process returned data, use a {@link #request-option-success callback} in the request options object,
 * or an {@link #requestcomplete event listener}.</p>
 * <p>{@link #request-option-isUpload File uploads} are not performed using normal "Ajax" techniques, that
 * is they are <b>not</b> performed using XMLHttpRequests. Instead the form is submitted in the standard
 * manner with the DOM <tt>&lt;form></tt> element temporarily modified to have its
 * <a href="http://www.w3.org/TR/REC-html40/present/frames.html#adef-target">target</a> set to refer
 * to a dynamically generated, hidden <tt>&lt;iframe></tt> which is inserted into the document
 * but removed after the return data has been gathered.</p>
 * <p>The server response is parsed by the browser to create the document for the IFRAME. If the
 * server is using JSON to send the return object, then the
 * <a href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.17">Content-Type</a> header
 * must be set to "text/html" in order to tell the browser to insert the text unchanged into the document body.</p>
 * <p>The response text is retrieved from the document, and a fake XMLHttpRequest object
 * is created containing a <tt>responseText</tt> property in order to conform to the
 * requirements of event handlers and callbacks.</p>
 * <p>Be aware that file upload packets are sent with the content type <a href="http://www.faqs.org/rfcs/rfc2388.html">multipart/form</a>
 * and some server technologies (notably JEE) may require some custom processing in order to
 * retrieve parameter names and parameter values from the packet content.</p>
 * @constructor
 * @param {Object} config a configuration object.
 */
Ext.data.Connection = function(config){
    Ext.apply(this, config);
    this.addEvents(
        /**
         * @event beforerequest
         * Fires before a network request is made to retrieve a data object.
         * @param {Connection} conn This Connection object.
         * @param {Object} options The options config object passed to the {@link #request} method.
         */
        "beforerequest",
        /**
         * @event requestcomplete
         * Fires if the request was successfully completed.
         * @param {Connection} conn This Connection object.
         * @param {Object} response The XHR object containing the response data.
         * See <a href="http://www.w3.org/TR/XMLHttpRequest/">The XMLHttpRequest Object</a>
         * for details.
         * @param {Object} options The options config object passed to the {@link #request} method.
         */
        "requestcomplete",
        /**
         * @event requestexception
         * Fires if an error HTTP status was returned from the server.
         * See <a href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html">HTTP Status Code Definitions</a>
         * for details of HTTP status codes.
         * @param {Connection} conn This Connection object.
         * @param {Object} response The XHR object containing the response data.
         * See <a href="http://www.w3.org/TR/XMLHttpRequest/">The XMLHttpRequest Object</a>
         * for details.
         * @param {Object} options The options config object passed to the {@link #request} method.
         */
        "requestexception"
    );
    Ext.data.Connection.superclass.constructor.call(this);
};

Ext.extend(Ext.data.Connection, Ext.util.Observable, {
    /**
     * @cfg {String} url (Optional) The default URL to be used for requests to the server. (defaults to undefined)
     */
    /**
     * @cfg {Object} extraParams (Optional) An object containing properties which are used as
     * extra parameters to each request made by this object. (defaults to undefined)
     */
    /**
     * @cfg {Object} defaultHeaders (Optional) An object containing request headers which are added
     *  to each request made by this object. (defaults to undefined)
     */
    /**
     * @cfg {String} method (Optional) The default HTTP method to be used for requests.
     * (defaults to undefined; if not set, but {@link #request} params are present, POST will be used;
     * otherwise, GET will be used.)
     */
    /**
     * @cfg {Number} timeout (Optional) The timeout in milliseconds to be used for requests. (defaults to 30000)
     */
    timeout : 30000,
    /**
     * @cfg {Boolean} autoAbort (Optional) Whether this request should abort any pending requests. (defaults to false)
     * @type Boolean
     */
    autoAbort:false,

    /**
     * @cfg {Boolean} disableCaching (Optional) True to add a unique cache-buster param to GET requests. (defaults to true)
     * @type Boolean
     */
    disableCaching: true,
    
    /**
     * @cfg {String} disableCachingParam (Optional) Change the parameter which is sent went disabling caching
     * through a cache buster. Defaults to '_dc'
     * @type String
     */
    disableCachingParam: '_dc',
    

    /**
     * <p>Sends an HTTP request to a remote server.</p>
     * <p><b>Important:</b> Ajax server requests are asynchronous, and this call will
     * return before the response has been received. Process any returned data
     * in a callback function.</p>
     * <p>To execute a callback function in the correct scope, use the <tt>scope</tt> option.</p>
     * @param {Object} options An object which may contain the following properties:<ul>
     * <li><b>url</b> : String/Function (Optional)<div class="sub-desc">The URL to
     * which to send the request, or a function to call which returns a URL string. The scope of the
     * function is specified by the <tt>scope</tt> option. Defaults to configured URL.</div></li>
     * <li><b>params</b> : Object/String/Function (Optional)<div class="sub-desc">
     * An object containing properties which are used as parameters to the
     * request, a url encoded string or a function to call to get either. The scope of the function
     * is specified by the <tt>scope</tt> option.</div></li>
     * <li><b>method</b> : String (Optional)<div class="sub-desc">The HTTP method to use
     * for the request. Defaults to the configured method, or if no method was configured,
     * "GET" if no parameters are being sent, and "POST" if parameters are being sent.  Note that
     * the method name is case-sensitive and should be all caps.</div></li>
     * <li><b>callback</b> : Function (Optional)<div class="sub-desc">The
     * function to be called upon receipt of the HTTP response. The callback is
     * called regardless of success or failure and is passed the following
     * parameters:<ul>
     * <li><b>options</b> : Object<div class="sub-desc">The parameter to the request call.</div></li>
     * <li><b>success</b> : Boolean<div class="sub-desc">True if the request succeeded.</div></li>
     * <li><b>response</b> : Object<div class="sub-desc">The XMLHttpRequest object containing the response data. 
     * See <a href="http://www.w3.org/TR/XMLHttpRequest/">http://www.w3.org/TR/XMLHttpRequest/</a> for details about 
     * accessing elements of the response.</div></li>
     * </ul></div></li>
     * <a id="request-option-success"></a><li><b>success</b> : Function (Optional)<div class="sub-desc">The function
     * to be called upon success of the request. The callback is passed the following
     * parameters:<ul>
     * <li><b>response</b> : Object<div class="sub-desc">The XMLHttpRequest object containing the response data.</div></li>
     * <li><b>options</b> : Object<div class="sub-desc">The parameter to the request call.</div></li>
     * </ul></div></li>
     * <li><b>failure</b> : Function (Optional)<div class="sub-desc">The function
     * to be called upon failure of the request. The callback is passed the
     * following parameters:<ul>
     * <li><b>response</b> : Object<div class="sub-desc">The XMLHttpRequest object containing the response data.</div></li>
     * <li><b>options</b> : Object<div class="sub-desc">The parameter to the request call.</div></li>
     * </ul></div></li>
     * <li><b>scope</b> : Object (Optional)<div class="sub-desc">The scope in
     * which to execute the callbacks: The "this" object for the callback function. If the <tt>url</tt>, or <tt>params</tt> options were
     * specified as functions from which to draw values, then this also serves as the scope for those function calls.
     * Defaults to the browser window.</div></li>
     * <li><b>form</b> : Element/HTMLElement/String (Optional)<div class="sub-desc">The <tt>&lt;form&gt;</tt>
     * Element or the id of the <tt>&lt;form&gt;</tt> to pull parameters from.</div></li>
     * <a id="request-option-isUpload"></a><li><b>isUpload</b> : Boolean (Optional)<div class="sub-desc">True if the form object is a
     * file upload (will usually be automatically detected).
     * <p>File uploads are not performed using normal "Ajax" techniques, that is they are <b>not</b>
     * performed using XMLHttpRequests. Instead the form is submitted in the standard manner with the
     * DOM <tt>&lt;form></tt> element temporarily modified to have its
     * <a href="http://www.w3.org/TR/REC-html40/present/frames.html#adef-target">target</a> set to refer
     * to a dynamically generated, hidden <tt>&lt;iframe></tt> which is inserted into the document
     * but removed after the return data has been gathered.</p>
     * <p>The server response is parsed by the browser to create the document for the IFRAME. If the
     * server is using JSON to send the return object, then the
     * <a href="http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.17">Content-Type</a> header
     * must be set to "text/html" in order to tell the browser to insert the text unchanged into the document body.</p>
     * <p>The response text is retrieved from the document, and a fake XMLHttpRequest object
     * is created containing a <tt>responseText</tt> property in order to conform to the
     * requirements of event handlers and callbacks.</p>
     * <p>Be aware that file upload packets are sent with the content type <a href="http://www.faqs.org/rfcs/rfc2388.html">multipart/form</a>
     * and some server technologies (notably JEE) may require some custom processing in order to
     * retrieve parameter names and parameter values from the packet content.</p>
     * </div></li>
     * <li><b>headers</b> : Object (Optional)<div class="sub-desc">Request
     * headers to set for the request.</div></li>
     * <li><b>xmlData</b> : Object (Optional)<div class="sub-desc">XML document
     * to use for the post. Note: This will be used instead of params for the post
     * data. Any params will be appended to the URL.</div></li>
     * <li><b>jsonData</b> : Object/String (Optional)<div class="sub-desc">JSON
     * data to use as the post. Note: This will be used instead of params for the post
     * data. Any params will be appended to the URL.</div></li>
     * <li><b>disableCaching</b> : Boolean (Optional)<div class="sub-desc">True
     * to add a unique cache-buster param to GET requests.</div></li>
     * </ul></p>
     * <p>The options object may also contain any other property which might be needed to perform
     * postprocessing in a callback because it is passed to callback functions.</p>
     * @return {Number} transactionId The id of the server transaction. This may be used
     * to cancel the request.
     */
    request : function(o){
        if(this.fireEvent("beforerequest", this, o) !== false){
            var p = o.params;

            if(typeof p == "function"){
                p = p.call(o.scope||window, o);
            }
            if(typeof p == "object"){
                p = Ext.urlEncode(p);
            }
            if(this.extraParams){
                var extras = Ext.urlEncode(this.extraParams);
                p = p ? (p + '&' + extras) : extras;
            }

            var url = o.url || this.url;
            if(typeof url == 'function'){
                url = url.call(o.scope||window, o);
            }

            if(o.form){
                var form = Ext.getDom(o.form);
                url = url || form.action;

                var enctype = form.getAttribute("enctype");
                if(o.isUpload || (enctype && enctype.toLowerCase() == 'multipart/form-data')){
                    return this.doFormUpload(o, p, url);
                }
                var f = Ext.lib.Ajax.serializeForm(form);
                p = p ? (p + '&' + f) : f;
            }

            var hs = o.headers;
            if(this.defaultHeaders){
                hs = Ext.apply(hs || {}, this.defaultHeaders);
                if(!o.headers){
                    o.headers = hs;
                }
            }

            var cb = {
                success: this.handleResponse,
                failure: this.handleFailure,
                scope: this,
                argument: {options: o},
                timeout : o.timeout || this.timeout
            };

            var method = o.method||this.method||((p || o.xmlData || o.jsonData) ? "POST" : "GET");

            if(method == 'GET' && (this.disableCaching && o.disableCaching !== false) || o.disableCaching === true){
                var dcp = o.disableCachingParam || this.disableCachingParam;
                url += (url.indexOf('?') != -1 ? '&' : '?') + dcp + '=' + (new Date().getTime());
            }

            if(typeof o.autoAbort == 'boolean'){ // options gets top priority
                if(o.autoAbort){
                    this.abort();
                }
            }else if(this.autoAbort !== false){
                this.abort();
            }
            if((method == 'GET' || o.xmlData || o.jsonData) && p){
                url += (url.indexOf('?') != -1 ? '&' : '?') + p;
                p = '';
            }
            this.transId = Ext.lib.Ajax.request(method, url, cb, p, o);
            return this.transId;
        }else{
            Ext.callback(o.callback, o.scope, [o, null, null]);
            return null;
        }
    },

    /**
     * Determine whether this object has a request outstanding.
     * @param {Number} transactionId (Optional) defaults to the last transaction
     * @return {Boolean} True if there is an outstanding request.
     */
    isLoading : function(transId){
        if(transId){
            return Ext.lib.Ajax.isCallInProgress(transId);
        }else{
            return this.transId ? true : false;
        }
    },

    /**
     * Aborts any outstanding request.
     * @param {Number} transactionId (Optional) defaults to the last transaction
     */
    abort : function(transId){
        if(transId || this.isLoading()){
            Ext.lib.Ajax.abort(transId || this.transId);
        }
    },

    // private
    handleResponse : function(response){
        this.transId = false;
        var options = response.argument.options;
        response.argument = options ? options.argument : null;
        this.fireEvent("requestcomplete", this, response, options);
        Ext.callback(options.success, options.scope, [response, options]);
        Ext.callback(options.callback, options.scope, [options, true, response]);
    },

    // private
    handleFailure : function(response, e){
        this.transId = false;
        var options = response.argument.options;
        response.argument = options ? options.argument : null;
        this.fireEvent("requestexception", this, response, options, e);
        Ext.callback(options.failure, options.scope, [response, options]);
        Ext.callback(options.callback, options.scope, [options, false, response]);
    },

    // private
    doFormUpload : function(o, ps, url){
        var id = Ext.id();
        var frame = document.createElement('iframe');
        frame.id = id;
        frame.name = id;
        frame.className = 'x-hidden';
        if(Ext.isIE){
            frame.src = Ext.SSL_SECURE_URL;
        }
        document.body.appendChild(frame);

        if(Ext.isIE){
           document.frames[id].name = id;
        }

        var form = Ext.getDom(o.form);
        form.target = id;
        form.method = 'POST';
        form.enctype = form.encoding = 'multipart/form-data';
        if(url){
            form.action = url;
        }

        var hiddens, hd;
        if(ps){ // add dynamic params
            hiddens = [];
            ps = Ext.urlDecode(ps, false);
            for(var k in ps){
                if(ps.hasOwnProperty(k)){
                    hd = document.createElement('input');
                    hd.type = 'hidden';
                    hd.name = k;
                    hd.value = ps[k];
                    form.appendChild(hd);
                    hiddens.push(hd);
                }
            }
        }

        function cb(){
            var r = {  // bogus response object
                responseText : '',
                responseXML : null
            };

            r.argument = o ? o.argument : null;

            try { //
                var doc;
                if(Ext.isIE){
                    doc = frame.contentWindow.document;
                }else {
                    doc = (frame.contentDocument || window.frames[id].document);
                }
                if(doc && doc.body){
                    r.responseText = doc.body.innerHTML;
                }
                if(doc && doc.XMLDocument){
                    r.responseXML = doc.XMLDocument;
                }else {
                    r.responseXML = doc;
                }
            }
            catch(e) {
                // ignore
            }

            Ext.EventManager.removeListener(frame, 'load', cb, this);

            this.fireEvent("requestcomplete", this, r, o);

            Ext.callback(o.success, o.scope, [r, o]);
            Ext.callback(o.callback, o.scope, [o, true, r]);

            setTimeout(function(){Ext.removeNode(frame);}, 100);
        }

        Ext.EventManager.on(frame, 'load', cb, this);
        form.submit();

        if(hiddens){ // remove dynamic params
            for(var i = 0, len = hiddens.length; i < len; i++){
                Ext.removeNode(hiddens[i]);
            }
        }
    }
});

/**
 * @class Ext.Ajax
 * @extends Ext.data.Connection
 * Global Ajax request class.  Provides a simple way to make Ajax requests with maximum flexibility.  Example usage:
 * <pre><code>
// Basic request
Ext.Ajax.request({
   url: 'foo.php',
   success: someFn,
   failure: otherFn,
   headers: {
       'my-header': 'foo'
   },
   params: { foo: 'bar' }
});

// Simple ajax form submission
Ext.Ajax.request({
    form: 'some-form',
    params: 'foo=bar'
});

// Default headers to pass in every request
Ext.Ajax.defaultHeaders = {
    'Powered-By': 'Ext'
};

// Global Ajax events can be handled on every request!
Ext.Ajax.on('beforerequest', this.showSpinner, this);
</code></pre>
 * @singleton
 */
Ext.Ajax = new Ext.data.Connection({
    /**
     * @cfg {String} url @hide
     */
    /**
     * @cfg {Object} extraParams @hide
     */
    /**
     * @cfg {Object} defaultHeaders @hide
     */
    /**
     * @cfg {String} method (Optional) @hide
     */
    /**
     * @cfg {Number} timeout (Optional) @hide
     */
    /**
     * @cfg {Boolean} autoAbort (Optional) @hide
     */

    /**
     * @cfg {Boolean} disableCaching (Optional) @hide
     */

    /**
     * @property  disableCaching
     * True to add a unique cache-buster param to GET requests. (defaults to true)
     * @type Boolean
     */
    /**
     * @property  url
     * The default URL to be used for requests to the server. (defaults to undefined)
     * @type String
     */
    /**
     * @property  extraParams
     * An object containing properties which are used as
     * extra parameters to each request made by this object. (defaults to undefined)
     * @type Object
     */
    /**
     * @property  defaultHeaders
     * An object containing request headers which are added to each request made by this object. (defaults to undefined)
     * @type Object
     */
    /**
     * @property  method
     * The default HTTP method to be used for requests. Note that this is case-sensitive and should be all caps (defaults
     * to undefined; if not set but parms are present will use "POST," otherwise "GET.")
     * @type String
     */
    /**
     * @property  timeout
     * The timeout in milliseconds to be used for requests. (defaults to 30000)
     * @type Number
     */

    /**
     * @property  autoAbort
     * Whether a new request should abort any pending requests. (defaults to false)
     * @type Boolean
     */
    autoAbort : false,

    /**
     * Serialize the passed form into a url encoded string
     * @param {String/HTMLElement} form
     * @return {String}
     */
    serializeForm : function(form){
        return Ext.lib.Ajax.serializeForm(form);
    }
});
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.EventManager
 * Registers event handlers that want to receive a normalized EventObject instead of the standard browser event and provides
 * several useful events directly.
 * See {@link Ext.EventObject} for more details on normalized event objects.
 * @singleton
 */
Ext.EventManager = function(){
    var docReadyEvent, docReadyProcId, docReadyState = false;
    var resizeEvent, resizeTask, textEvent, textSize;
    var E = Ext.lib.Event;
    var D = Ext.lib.Dom;
    // fix parser confusion
    var xname = 'Ex' + 't';

    var elHash = {};

    var addListener = function(el, ename, fn, wrap, scope){
        var id = Ext.id(el);
        if(!elHash[id]){
            elHash[id] = {};
        }
        var es = elHash[id];
        if(!es[ename]){
            es[ename] = [];
        }
        var ls = es[ename];
        ls.push({
            id: id,
            ename: ename,
            fn: fn,
            wrap: wrap,
            scope: scope
        });

         E.on(el, ename, wrap);

        if(ename == "mousewheel" && el.addEventListener){ // workaround for jQuery
            el.addEventListener("DOMMouseScroll", wrap, false);
            E.on(window, 'unload', function(){
                el.removeEventListener("DOMMouseScroll", wrap, false);
            });
        }
        if(ename == "mousedown" && el == document){ // fix stopped mousedowns on the document
            Ext.EventManager.stoppedMouseDownEvent.addListener(wrap);
        }
    }

    var removeListener = function(el, ename, fn, scope){
        el = Ext.getDom(el);
        var id = Ext.id(el), es = elHash[id], wrap;
        if(es){
            var ls = es[ename], l;
            if(ls){
                for(var i = 0, len = ls.length; i < len; i++){
                    l = ls[i];
                    if(l.fn == fn && (!scope || l.scope == scope)){
                        wrap = l.wrap;
                        E.un(el, ename, wrap);
                        ls.splice(i, 1);
                        break;
                    }
                }
            }
        }
        if(ename == "mousewheel" && el.addEventListener && wrap){
            el.removeEventListener("DOMMouseScroll", wrap, false);
        }
        if(ename == "mousedown" && el == document && wrap){ // fix stopped mousedowns on the document
            Ext.EventManager.stoppedMouseDownEvent.removeListener(wrap);
        }
    }

    var removeAll = function(el){
        el = Ext.getDom(el);
        var id = Ext.id(el), es = elHash[id], ls;
        if(es){
            for(var ename in es){
                if(es.hasOwnProperty(ename)){
                    ls = es[ename];
                    for(var i = 0, len = ls.length; i < len; i++){
                        E.un(el, ename, ls[i].wrap);
                        ls[i] = null;
                    }
                }
                es[ename] = null;
            }
            delete elHash[id];
        }
    }

     var fireDocReady = function(){
        if(!docReadyState){
            docReadyState = Ext.isReady = true;
            if(Ext.isGecko || Ext.isOpera) {
                document.removeEventListener("DOMContentLoaded", fireDocReady, false);
            }
        }
        if(docReadyProcId){
            clearInterval(docReadyProcId);
            docReadyProcId = null;
        }
        if(docReadyEvent){
            docReadyEvent.fire();
            docReadyEvent.clearListeners();
       }
    };

    var initDocReady = function(){
        docReadyEvent = new Ext.util.Event();

        if(Ext.isReady){
            return;
        }

        // no matter what, make sure it fires on load
        E.on(window, 'load', fireDocReady);

        if(Ext.isGecko || Ext.isOpera) {
            document.addEventListener('DOMContentLoaded', fireDocReady, false);
        }
        else if(Ext.isIE){
            docReadyProcId = setInterval(function(){
                try{
                    // throws errors until DOM is ready
                    Ext.isReady || (document.documentElement.doScroll('left'));
                }catch(e){
                    return;
                }
                fireDocReady();  // no errors, fire
            }, 5);

			document.onreadystatechange = function(){
				if(document.readyState == 'complete'){
					document.onreadystatechange = null;
					fireDocReady();
				}
            };
        }
        else if(Ext.isSafari){
            docReadyProcId = setInterval(function(){
                var rs = document.readyState;
                if(rs == 'complete') {
                    fireDocReady();
                 }
            }, 10);
        }
    };

    var createBuffered = function(h, o){
        var task = new Ext.util.DelayedTask(h);
        return function(e){
            // create new event object impl so new events don't wipe out properties
            e = new Ext.EventObjectImpl(e);
            task.delay(o.buffer, h, null, [e]);
        };
    };

    var createSingle = function(h, el, ename, fn, scope){
        return function(e){
            Ext.EventManager.removeListener(el, ename, fn, scope);
            h(e);
        };
    };

    var createDelayed = function(h, o){
        return function(e){
            // create new event object impl so new events don't wipe out properties
            e = new Ext.EventObjectImpl(e);
            setTimeout(function(){
                h(e);
            }, o.delay || 10);
        };
    };

    var listen = function(element, ename, opt, fn, scope){
        var o = (!opt || typeof opt == "boolean") ? {} : opt;
        fn = fn || o.fn; scope = scope || o.scope;
        var el = Ext.getDom(element);
        if(!el){
            throw "Error listening for \"" + ename + '\". Element "' + element + '" doesn\'t exist.';
        }
        var h = function(e){
            // prevent errors while unload occurring
            if(!window[xname]){
                return;
            }
            e = Ext.EventObject.setEvent(e);
            var t;
            if(o.delegate){
                t = e.getTarget(o.delegate, el);
                if(!t){
                    return;
                }
            }else{
                t = e.target;
            }
            if(o.stopEvent === true){
                e.stopEvent();
            }
            if(o.preventDefault === true){
               e.preventDefault();
            }
            if(o.stopPropagation === true){
                e.stopPropagation();
            }

            if(o.normalized === false){
                e = e.browserEvent;
            }

            fn.call(scope || el, e, t, o);
        };
        if(o.delay){
            h = createDelayed(h, o);
        }
        if(o.single){
            h = createSingle(h, el, ename, fn, scope);
        }
        if(o.buffer){
            h = createBuffered(h, o);
        }

        addListener(el, ename, fn, h, scope);
        return h;
    };

    var propRe = /^(?:scope|delay|buffer|single|stopEvent|preventDefault|stopPropagation|normalized|args|delegate)$/;
    var pub = {

    /**
     * Appends an event handler to an element.  The shorthand version {@link #on} is equivalent.  Typically you will
     * use {@link Ext.Element#addListener} directly on an Element in favor of calling this version.
     * @param {String/HTMLElement} el The html element or id to assign the event handler to
     * @param {String} eventName The type of event to listen for
     * @param {Function} handler The handler function the event invokes This function is passed
     * the following parameters:<ul>
     * <li>evt : EventObject<div class="sub-desc">The {@link Ext.EventObject EventObject} describing the event.</div></li>
     * <li>t : Element<div class="sub-desc">The {@link Ext.Element Element} which was the target of the event.
     * Note that this may be filtered by using the <tt>delegate</tt> option.</div></li>
     * <li>o : Object<div class="sub-desc">The options object from the addListener call.</div></li>
     * </ul>
     * @param {Object} scope (optional) The scope in which to execute the handler
     * function (the handler function's "this" context)
     * @param {Object} options (optional) An object containing handler configuration properties.
     * This may contain any of the following properties:<ul>
     * <li>scope {Object} : The scope in which to execute the handler function. The handler function's "this" context.</li>
     * <li>delegate {String} : A simple selector to filter the target or look for a descendant of the target</li>
     * <li>stopEvent {Boolean} : True to stop the event. That is stop propagation, and prevent the default action.</li>
     * <li>preventDefault {Boolean} : True to prevent the default action</li>
     * <li>stopPropagation {Boolean} : True to prevent event propagation</li>
     * <li>normalized {Boolean} : False to pass a browser event to the handler function instead of an Ext.EventObject</li>
     * <li>delay {Number} : The number of milliseconds to delay the invocation of the handler after te event fires.</li>
     * <li>single {Boolean} : True to add a handler to handle just the next firing of the event, and then remove itself.</li>
     * <li>buffer {Number} : Causes the handler to be scheduled to run in an {@link Ext.util.DelayedTask} delayed
     * by the specified number of milliseconds. If the event fires again within that time, the original
     * handler is <em>not</em> invoked, but the new handler is scheduled in its place.</li>
     * </ul><br>
     * <p>See {@link Ext.Element#addListener} for examples of how to use these options.</p>
     */
        addListener : function(element, eventName, fn, scope, options){
            if(typeof eventName == "object"){
                var o = eventName;
                for(var e in o){
                    if(propRe.test(e)){
                        continue;
                    }
                    if(typeof o[e] == "function"){
                        // shared options
                        listen(element, e, o, o[e], o.scope);
                    }else{
                        // individual options
                        listen(element, e, o[e]);
                    }
                }
                return;
            }
            return listen(element, eventName, options, fn, scope);
        },

        /**
         * Removes an event handler from an element.  The shorthand version {@link #un} is equivalent.  Typically
         * you will use {@link Ext.Element#removeListener} directly on an Element in favor of calling this version.
         * @param {String/HTMLElement} el The id or html element from which to remove the event
         * @param {String} eventName The type of event
         * @param {Function} fn The handler function to remove
         */
        removeListener : function(element, eventName, fn, scope){
            return removeListener(element, eventName, fn, scope);
        },

        /**
         * Removes all event handers from an element.  Typically you will use {@link Ext.Element#removeAllListeners}
         * directly on an Element in favor of calling this version.
         * @param {String/HTMLElement} el The id or html element from which to remove the event
         */
        removeAll : function(element){
            return removeAll(element);
        },

        /**
         * Fires when the document is ready (before onload and before images are loaded). Can be
         * accessed shorthanded as Ext.onReady().
         * @param {Function} fn The method the event invokes
         * @param {Object} scope (optional) An object that becomes the scope of the handler
         * @param {boolean} options (optional) An object containing standard {@link #addListener} options
         */
         onDocumentReady : function(fn, scope, options){
			if(!docReadyEvent){
                initDocReady();
			}
			if(docReadyState || Ext.isReady){ // if it already fired
				options || (options = {});
				fn.defer(options.delay||0, scope);
			}else{
				docReadyEvent.addListener(fn, scope, options);
			}
        },

        /**
         * Fires when the window is resized and provides resize event buffering (50 milliseconds), passes new viewport width and height to handlers.
         * @param {Function} fn        The method the event invokes
         * @param {Object}   scope    An object that becomes the scope of the handler
         * @param {boolean}  options
         */
        onWindowResize : function(fn, scope, options){
            if(!resizeEvent){
                resizeEvent = new Ext.util.Event();
                resizeTask = new Ext.util.DelayedTask(function(){
                    resizeEvent.fire(D.getViewWidth(), D.getViewHeight());
                });
                E.on(window, "resize", this.fireWindowResize, this);
            }
            resizeEvent.addListener(fn, scope, options);
        },

        // exposed only to allow manual firing
        fireWindowResize : function(){
            if(resizeEvent){
                if((Ext.isIE||Ext.isAir) && resizeTask){
                    resizeTask.delay(50);
                }else{
                    resizeEvent.fire(D.getViewWidth(), D.getViewHeight());
                }
            }
        },

        /**
         * Fires when the user changes the active text size. Handler gets called with 2 params, the old size and the new size.
         * @param {Function} fn        The method the event invokes
         * @param {Object}   scope    An object that becomes the scope of the handler
         * @param {boolean}  options
         */
        onTextResize : function(fn, scope, options){
            if(!textEvent){
                textEvent = new Ext.util.Event();
                var textEl = new Ext.Element(document.createElement('div'));
                textEl.dom.className = 'x-text-resize';
                textEl.dom.innerHTML = 'X';
                textEl.appendTo(document.body);
                textSize = textEl.dom.offsetHeight;
                setInterval(function(){
                    if(textEl.dom.offsetHeight != textSize){
                        textEvent.fire(textSize, textSize = textEl.dom.offsetHeight);
                    }
                }, this.textResizeInterval);
            }
            textEvent.addListener(fn, scope, options);
        },

        /**
         * Removes the passed window resize listener.
         * @param {Function} fn        The method the event invokes
         * @param {Object}   scope    The scope of handler
         */
        removeResizeListener : function(fn, scope){
            if(resizeEvent){
                resizeEvent.removeListener(fn, scope);
            }
        },

        // private
        fireResize : function(){
            if(resizeEvent){
                resizeEvent.fire(D.getViewWidth(), D.getViewHeight());
            }
        },
        /**
         * Url used for onDocumentReady with using SSL (defaults to Ext.SSL_SECURE_URL)
         */
        ieDeferSrc : false,
        /**
         * The frequency, in milliseconds, to check for text resize events (defaults to 50)
         */
        textResizeInterval : 50
    };
     /**
     * Appends an event handler to an element.  Shorthand for {@link #addListener}.
     * @param {String/HTMLElement} el The html element or id to assign the event handler to
     * @param {String} eventName The type of event to listen for
     * @param {Function} handler The handler function the event invokes
     * @param {Object} scope (optional) The scope in which to execute the handler
     * function (the handler function's "this" context)
     * @param {Object} options (optional) An object containing standard {@link #addListener} options
     * @member Ext.EventManager
     * @method on
     */
    pub.on = pub.addListener;
    /**
     * Removes an event handler from an element.  Shorthand for {@link #removeListener}.
     * @param {String/HTMLElement} el The id or html element from which to remove the event
     * @param {String} eventName The type of event
     * @param {Function} fn The handler function to remove
     * @return {Boolean} True if a listener was actually removed, else false
     * @member Ext.EventManager
     * @method un
     */
    pub.un = pub.removeListener;

    pub.stoppedMouseDownEvent = new Ext.util.Event();
    return pub;
}();
/**
  * Fires when the document is ready (before onload and before images are loaded).  Shorthand of {@link Ext.EventManager#onDocumentReady}.
  * @param {Function} fn        The method the event invokes
  * @param {Object}   scope    An  object that becomes the scope of the handler
  * @param {boolean}  override If true, the obj passed in becomes
  *                             the execution scope of the listener
  * @member Ext
  * @method onReady
 */
Ext.onReady = Ext.EventManager.onDocumentReady;


// Initialize doc classes
(function(){
    var initExtCss = function(){
        // find the body element
        var bd = document.body || document.getElementsByTagName('body')[0];
        if(!bd){ return false; }
        var cls = [' ',
                Ext.isIE ? "ext-ie " + (Ext.isIE6 ? 'ext-ie6' : 'ext-ie7')
                : Ext.isGecko ? "ext-gecko " + (Ext.isGecko2 ? 'ext-gecko2' : 'ext-gecko3')
                : Ext.isOpera ? "ext-opera"
                : Ext.isSafari ? "ext-safari" : ""];

        if(Ext.isMac){
            cls.push("ext-mac");
        }
        if(Ext.isLinux){
            cls.push("ext-linux");
        }
        if(Ext.isBorderBox){
            cls.push('ext-border-box');
        }
        if(Ext.isStrict){ // add to the parent to allow for selectors like ".ext-strict .ext-ie"
            var p = bd.parentNode;
            if(p){
                p.className += ' ext-strict';
            }
        }
        bd.className += cls.join(' ');
        return true;
    }

    if(!initExtCss()){
        Ext.onReady(initExtCss);
    }
})();

/**
 * @class Ext.EventObject
 * EventObject exposes the Yahoo! UI Event functionality directly on the object
 * passed to your event handler. It exists mostly for convenience. It also fixes the annoying null checks automatically to cleanup your code
 * Example:
 * <pre><code>
 function handleClick(e){ // e is not a standard event object, it is a Ext.EventObject
    e.preventDefault();
    var target = e.getTarget();
    ...
 }
 var myDiv = Ext.get("myDiv");
 myDiv.on("click", handleClick);
 //or
 Ext.EventManager.on("myDiv", 'click', handleClick);
 Ext.EventManager.addListener("myDiv", 'click', handleClick);
 </code></pre>
 * @singleton
 */
Ext.EventObject = function(){

    var E = Ext.lib.Event;

    // safari keypress events for special keys return bad keycodes
    var safariKeys = {
        3 : 13, // enter
        63234 : 37, // left
        63235 : 39, // right
        63232 : 38, // up
        63233 : 40, // down
        63276 : 33, // page up
        63277 : 34, // page down
        63272 : 46, // delete
        63273 : 36, // home
        63275 : 35  // end
    };

    // normalize button clicks
    var btnMap = Ext.isIE ? {1:0,4:1,2:2} :
                (Ext.isSafari ? {1:0,2:1,3:2} : {0:0,1:1,2:2});

    Ext.EventObjectImpl = function(e){
        if(e){
            this.setEvent(e.browserEvent || e);
        }
    };

    Ext.EventObjectImpl.prototype = {
        /** The normal browser event */
        browserEvent : null,
        /** The button pressed in a mouse event */
        button : -1,
        /** True if the shift key was down during the event */
        shiftKey : false,
        /** True if the control key was down during the event */
        ctrlKey : false,
        /** True if the alt key was down during the event */
        altKey : false,

        /** Key constant @type Number */
        BACKSPACE: 8,
        /** Key constant @type Number */
        TAB: 9,
        /** Key constant @type Number */
        NUM_CENTER: 12,
        /** Key constant @type Number */
        ENTER: 13,
        /** Key constant @type Number */
        RETURN: 13,
        /** Key constant @type Number */
        SHIFT: 16,
        /** Key constant @type Number */
        CTRL: 17,
        CONTROL : 17, // legacy
        /** Key constant @type Number */
        ALT: 18,
        /** Key constant @type Number */
        PAUSE: 19,
        /** Key constant @type Number */
        CAPS_LOCK: 20,
        /** Key constant @type Number */
        ESC: 27,
        /** Key constant @type Number */
        SPACE: 32,
        /** Key constant @type Number */
        PAGE_UP: 33,
        PAGEUP : 33, // legacy
        /** Key constant @type Number */
        PAGE_DOWN: 34,
        PAGEDOWN : 34, // legacy
        /** Key constant @type Number */
        END: 35,
        /** Key constant @type Number */
        HOME: 36,
        /** Key constant @type Number */
        LEFT: 37,
        /** Key constant @type Number */
        UP: 38,
        /** Key constant @type Number */
        RIGHT: 39,
        /** Key constant @type Number */
        DOWN: 40,
        /** Key constant @type Number */
        PRINT_SCREEN: 44,
        /** Key constant @type Number */
        INSERT: 45,
        /** Key constant @type Number */
        DELETE: 46,
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

           /** @private */
        setEvent : function(e){
            if(e == this || (e && e.browserEvent)){ // already wrapped
                return e;
            }
            this.browserEvent = e;
            if(e){
                // normalize buttons
                this.button = e.button ? btnMap[e.button] : (e.which ? e.which-1 : -1);
                if(e.type == 'click' && this.button == -1){
                    this.button = 0;
                }
                this.type = e.type;
                this.shiftKey = e.shiftKey;
                // mac metaKey behaves like ctrlKey
                this.ctrlKey = e.ctrlKey || e.metaKey;
                this.altKey = e.altKey;
                // in getKey these will be normalized for the mac
                this.keyCode = e.keyCode;
                this.charCode = e.charCode;
                // cache the target for the delayed and or buffered events
                this.target = E.getTarget(e);
                // same for XY
                this.xy = E.getXY(e);
            }else{
                this.button = -1;
                this.shiftKey = false;
                this.ctrlKey = false;
                this.altKey = false;
                this.keyCode = 0;
                this.charCode = 0;
                this.target = null;
                this.xy = [0, 0];
            }
            return this;
        },

        /**
         * Stop the event (preventDefault and stopPropagation)
         */
        stopEvent : function(){
            if(this.browserEvent){
                if(this.browserEvent.type == 'mousedown'){
                    Ext.EventManager.stoppedMouseDownEvent.fire(this);
                }
                E.stopEvent(this.browserEvent);
            }
        },

        /**
         * Prevents the browsers default handling of the event.
         */
        preventDefault : function(){
            if(this.browserEvent){
                E.preventDefault(this.browserEvent);
            }
        },

        /** @private */
        isNavKeyPress : function(){
            var k = this.keyCode;
            k = Ext.isSafari ? (safariKeys[k] || k) : k;
            return (k >= 33 && k <= 40) || k == this.RETURN || k == this.TAB || k == this.ESC;
        },

        isSpecialKey : function(){
            var k = this.keyCode;
            return (this.type == 'keypress' && this.ctrlKey) || k == 9 || k == 13  || k == 40 || k == 27 ||
            (k == 16) || (k == 17) ||
            (k >= 18 && k <= 20) ||
            (k >= 33 && k <= 35) ||
            (k >= 36 && k <= 39) ||
            (k >= 44 && k <= 45);
        },

        /**
         * Cancels bubbling of the event.
         */
        stopPropagation : function(){
            if(this.browserEvent){
                if(this.browserEvent.type == 'mousedown'){
                    Ext.EventManager.stoppedMouseDownEvent.fire(this);
                }
                E.stopPropagation(this.browserEvent);
            }
        },

        /**
         * Gets the character code for the event.
         * @return {Number}
         */
        getCharCode : function(){
            return this.charCode || this.keyCode;
        },

        /**
         * Returns a normalized keyCode for the event.
         * @return {Number} The key code
         */
        getKey : function(){
            var k = this.keyCode || this.charCode;
            return Ext.isSafari ? (safariKeys[k] || k) : k;
        },

        /**
         * Gets the x coordinate of the event.
         * @return {Number}
         */
        getPageX : function(){
            return this.xy[0];
        },

        /**
         * Gets the y coordinate of the event.
         * @return {Number}
         */
        getPageY : function(){
            return this.xy[1];
        },

        /**
         * Gets the time of the event.
         * @return {Number}
         */
        getTime : function(){
            if(this.browserEvent){
                return E.getTime(this.browserEvent);
            }
            return null;
        },

        /**
         * Gets the page coordinates of the event.
         * @return {Array} The xy values like [x, y]
         */
        getXY : function(){
            return this.xy;
        },

        /**
         * Gets the target for the event.
         * @param {String} selector (optional) A simple selector to filter the target or look for an ancestor of the target
         * @param {Number/Mixed} maxDepth (optional) The max depth to
                search as a number or element (defaults to 10 || document.body)
         * @param {Boolean} returnEl (optional) True to return a Ext.Element object instead of DOM node
         * @return {HTMLelement}
         */
        getTarget : function(selector, maxDepth, returnEl){
            return selector ? Ext.fly(this.target).findParent(selector, maxDepth, returnEl) : (returnEl ? Ext.get(this.target) : this.target);
        },

        /**
         * Gets the related target.
         * @return {HTMLElement}
         */
        getRelatedTarget : function(){
            if(this.browserEvent){
                return E.getRelatedTarget(this.browserEvent);
            }
            return null;
        },

        /**
         * Normalizes mouse wheel delta across browsers
         * @return {Number} The delta
         */
        getWheelDelta : function(){
            var e = this.browserEvent;
            var delta = 0;
            if(e.wheelDelta){ /* IE/Opera. */
                delta = e.wheelDelta/120;
            }else if(e.detail){ /* Mozilla case. */
                delta = -e.detail/3;
            }
            return delta;
        },

        /**
         * Returns true if the control, meta, shift or alt key was pressed during this event.
         * @return {Boolean}
         */
        hasModifier : function(){
            return ((this.ctrlKey || this.altKey) || this.shiftKey) ? true : false;
        },

        /**
         * Returns true if the target of this event is a child of el.  If the target is el, it returns false.
         * Example usage:<pre><code>
// Handle click on any child of an element
Ext.getBody().on('click', function(e){
    if(e.within('some-el')){
        alert('Clicked on a child of some-el!');
    }
});

// Handle click directly on an element, ignoring clicks on child nodes
Ext.getBody().on('click', function(e,t){
    if((t.id == 'some-el') && !e.within(t, true)){
        alert('Clicked directly on some-el!');
    }
});
</code></pre>
         * @param {Mixed} el The id, DOM element or Ext.Element to check
         * @param {Boolean} related (optional) true to test if the related target is within el instead of the target
         * @return {Boolean}
         */
        within : function(el, related){
            var t = this[related ? "getRelatedTarget" : "getTarget"]();
            return t && Ext.fly(el).contains(t);
        },

        getPoint : function(){
            return new Ext.lib.Point(this.xy[0], this.xy[1]);
        }
    };

    return new Ext.EventObjectImpl();
}();
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.Element
 * Represents an Element in the DOM.<br><br>
 * Usage:<br>
<pre><code>
// by id
var el = Ext.get("my-div");

// by DOM element reference
var el = Ext.get(myDivElement);
</code></pre>
 * <b>Animations</b><br />
 * Many of the functions for manipulating an element have an optional "animate" parameter. The animate parameter
 * should either be a boolean (true) or an object literal with animation options. Note that the supported Element animation
 * options are a subset of the {@link Ext.Fx} animation options specific to Fx effects.  The Element animation options are:
<pre>
Option    Default   Description
--------- --------  ---------------------------------------------
duration  .35       The duration of the animation in seconds
easing    easeOut   The easing method
callback  none      A function to execute when the anim completes
scope     this      The scope (this) of the callback function
</pre>
* Also, the Anim object being used for the animation will be set on your options object as "anim", which allows you to stop or
* manipulate the animation. Here's an example:
<pre><code>
var el = Ext.get("my-div");

// no animation
el.setWidth(100);

// default animation
el.setWidth(100, true);

// animation with some options set
el.setWidth(100, {
    duration: 1,
    callback: this.foo,
    scope: this
});

// using the "anim" property to get the Anim object
var opt = {
    duration: 1,
    callback: this.foo,
    scope: this
};
el.setWidth(100, opt);
...
if(opt.anim.isAnimated()){
    opt.anim.stop();
}
</code></pre>
* <b> Composite (Collections of) Elements</b><br />
 * For working with collections of Elements, see {@link Ext.CompositeElement}
 * @constructor Create a new Element directly.
 * @param {String/HTMLElement} element
 * @param {Boolean} forceNew (optional) By default the constructor checks to see if there is already an instance of this element in the cache and if there is it returns the same instance. This will skip that check (useful for extending this class).
 */
(function(){
var D = Ext.lib.Dom;
var E = Ext.lib.Event;
var A = Ext.lib.Anim;

// local style camelizing for speed
var propCache = {};
var camelRe = /(-[a-z])/gi;
var camelFn = function(m, a){ return a.charAt(1).toUpperCase(); };
var view = document.defaultView;

Ext.Element = function(element, forceNew){
    var dom = typeof element == "string" ?
            document.getElementById(element) : element;
    if(!dom){ // invalid id/element
        return null;
    }
    var id = dom.id;
    if(forceNew !== true && id && Ext.Element.cache[id]){ // element object already exists
        return Ext.Element.cache[id];
    }

    /**
     * The DOM element
     * @type HTMLElement
     */
    this.dom = dom;

    /**
     * The DOM element ID
     * @type String
     */
    this.id = id || Ext.id(dom);
};

var El = Ext.Element;

El.prototype = {
    /**
     * The element's default display mode  (defaults to "")
     * @type String
     */
    originalDisplay : "",

    visibilityMode : 1,
    /**
     * The default unit to append to CSS values where a unit isn't provided (defaults to px).
     * @type String
     */
    defaultUnit : "px",
    /**
     * Sets the element's visibility mode. When setVisible() is called it
     * will use this to determine whether to set the visibility or the display property.
     * @param visMode Element.VISIBILITY or Element.DISPLAY
     * @return {Ext.Element} this
     */
    setVisibilityMode : function(visMode){
        this.visibilityMode = visMode;
        return this;
    },
    /**
     * Convenience method for setVisibilityMode(Element.DISPLAY)
     * @param {String} display (optional) What to set display to when visible
     * @return {Ext.Element} this
     */
    enableDisplayMode : function(display){
        this.setVisibilityMode(El.DISPLAY);
        if(typeof display != "undefined") this.originalDisplay = display;
        return this;
    },

    /**
     * Looks at this node and then at parent nodes for a match of the passed simple selector (e.g. div.some-class or span:first-child)
     * @param {String} selector The simple selector to test
     * @param {Number/Mixed} maxDepth (optional) The max depth to
            search as a number or element (defaults to 10 || document.body)
     * @param {Boolean} returnEl (optional) True to return a Ext.Element object instead of DOM node
     * @return {HTMLElement} The matching DOM node (or null if no match was found)
     */
    findParent : function(simpleSelector, maxDepth, returnEl){
        var p = this.dom, b = document.body, depth = 0, dq = Ext.DomQuery, stopEl;
        maxDepth = maxDepth || 50;
        if(typeof maxDepth != "number"){
            stopEl = Ext.getDom(maxDepth);
            maxDepth = 10;
        }
        while(p && p.nodeType == 1 && depth < maxDepth && p != b && p != stopEl){
            if(dq.is(p, simpleSelector)){
                return returnEl ? Ext.get(p) : p;
            }
            depth++;
            p = p.parentNode;
        }
        return null;
    },


    /**
     * Looks at parent nodes for a match of the passed simple selector (e.g. div.some-class or span:first-child)
     * @param {String} selector The simple selector to test
     * @param {Number/Mixed} maxDepth (optional) The max depth to
            search as a number or element (defaults to 10 || document.body)
     * @param {Boolean} returnEl (optional) True to return a Ext.Element object instead of DOM node
     * @return {HTMLElement} The matching DOM node (or null if no match was found)
     */
    findParentNode : function(simpleSelector, maxDepth, returnEl){
        var p = Ext.fly(this.dom.parentNode, '_internal');
        return p ? p.findParent(simpleSelector, maxDepth, returnEl) : null;
    },

    /**
     * Walks up the dom looking for a parent node that matches the passed simple selector (e.g. div.some-class or span:first-child).
     * This is a shortcut for findParentNode() that always returns an Ext.Element.
     * @param {String} selector The simple selector to test
     * @param {Number/Mixed} maxDepth (optional) The max depth to
            search as a number or element (defaults to 10 || document.body)
     * @return {Ext.Element} The matching DOM node (or null if no match was found)
     */
    up : function(simpleSelector, maxDepth){
        return this.findParentNode(simpleSelector, maxDepth, true);
    },



    /**
     * Returns true if this element matches the passed simple selector (e.g. div.some-class or span:first-child)
     * @param {String} selector The simple selector to test
     * @return {Boolean} True if this element matches the selector, else false
     */
    is : function(simpleSelector){
        return Ext.DomQuery.is(this.dom, simpleSelector);
    },

    /**
     * Perform animation on this element.
     * @param {Object} args The animation control args
     * @param {Float} duration (optional) How long the animation lasts in seconds (defaults to .35)
     * @param {Function} onComplete (optional) Function to call when animation completes
     * @param {String} easing (optional) Easing method to use (defaults to 'easeOut')
     * @param {String} animType (optional) 'run' is the default. Can also be 'color', 'motion', or 'scroll'
     * @return {Ext.Element} this
     */
    animate : function(args, duration, onComplete, easing, animType){
        this.anim(args, {duration: duration, callback: onComplete, easing: easing}, animType);
        return this;
    },

    /*
     * @private Internal animation call
     */
    anim : function(args, opt, animType, defaultDur, defaultEase, cb){
        animType = animType || 'run';
        opt = opt || {};
        var anim = Ext.lib.Anim[animType](
            this.dom, args,
            (opt.duration || defaultDur) || .35,
            (opt.easing || defaultEase) || 'easeOut',
            function(){
                Ext.callback(cb, this);
                Ext.callback(opt.callback, opt.scope || this, [this, opt]);
            },
            this
        );
        opt.anim = anim;
        return anim;
    },

    // private legacy anim prep
    preanim : function(a, i){
        return !a[i] ? false : (typeof a[i] == "object" ? a[i]: {duration: a[i+1], callback: a[i+2], easing: a[i+3]});
    },

    /**
     * Removes worthless text nodes
     * @param {Boolean} forceReclean (optional) By default the element
     * keeps track if it has been cleaned already so
     * you can call this over and over. However, if you update the element and
     * need to force a reclean, you can pass true.
     */
    clean : function(forceReclean){
        if(this.isCleaned && forceReclean !== true){
            return this;
        }
        var ns = /\S/;
        var d = this.dom, n = d.firstChild, ni = -1;
 	    while(n){
 	        var nx = n.nextSibling;
 	        if(n.nodeType == 3 && !ns.test(n.nodeValue)){
 	            d.removeChild(n);
 	        }else{
 	            n.nodeIndex = ++ni;
 	        }
 	        n = nx;
 	    }
 	    this.isCleaned = true;
 	    return this;
 	},

    /**
     * Scrolls this element into view within the passed container.
     * @param {Mixed} container (optional) The container element to scroll (defaults to document.body).  Should be a 
     * string (id), dom node, or Ext.Element.
     * @param {Boolean} hscroll (optional) False to disable horizontal scroll (defaults to true)
     * @return {Ext.Element} this
     */
    scrollIntoView : function(container, hscroll){
        var c = Ext.getDom(container) || Ext.getBody().dom;
        var el = this.dom;

        var o = this.getOffsetsTo(c),
            l = o[0] + c.scrollLeft,
            t = o[1] + c.scrollTop,
            b = t+el.offsetHeight,
            r = l+el.offsetWidth;

        var ch = c.clientHeight;
        var ct = parseInt(c.scrollTop, 10);
        var cl = parseInt(c.scrollLeft, 10);
        var cb = ct + ch;
        var cr = cl + c.clientWidth;

        if(el.offsetHeight > ch || t < ct){
        	c.scrollTop = t;
        }else if(b > cb){
            c.scrollTop = b-ch;
        }
        c.scrollTop = c.scrollTop; // corrects IE, other browsers will ignore

        if(hscroll !== false){
			if(el.offsetWidth > c.clientWidth || l < cl){
                c.scrollLeft = l;
            }else if(r > cr){
                c.scrollLeft = r-c.clientWidth;
            }
            c.scrollLeft = c.scrollLeft;
        }
        return this;
    },

    // private
    scrollChildIntoView : function(child, hscroll){
        Ext.fly(child, '_scrollChildIntoView').scrollIntoView(this, hscroll);
    },

    /**
     * Measures the element's content height and updates height to match. Note: this function uses setTimeout so
     * the new height may not be available immediately.
     * @param {Boolean} animate (optional) Animate the transition (defaults to false)
     * @param {Float} duration (optional) Length of the animation in seconds (defaults to .35)
     * @param {Function} onComplete (optional) Function to call when animation completes
     * @param {String} easing (optional) Easing method to use (defaults to easeOut)
     * @return {Ext.Element} this
     */
    autoHeight : function(animate, duration, onComplete, easing){
        var oldHeight = this.getHeight();
        this.clip();
        this.setHeight(1); // force clipping
        setTimeout(function(){
            var height = parseInt(this.dom.scrollHeight, 10); // parseInt for Safari
            if(!animate){
                this.setHeight(height);
                this.unclip();
                if(typeof onComplete == "function"){
                    onComplete();
                }
            }else{
                this.setHeight(oldHeight); // restore original height
                this.setHeight(height, animate, duration, function(){
                    this.unclip();
                    if(typeof onComplete == "function") onComplete();
                }.createDelegate(this), easing);
            }
        }.createDelegate(this), 0);
        return this;
    },

    /**
     * Returns true if this element is an ancestor of the passed element
     * @param {HTMLElement/String} el The element to check
     * @return {Boolean} True if this element is an ancestor of el, else false
     */
    contains : function(el){
        if(!el){return false;}
        return D.isAncestor(this.dom, el.dom ? el.dom : el);
    },

    /**
     * Checks whether the element is currently visible using both visibility and display properties.
     * @param {Boolean} deep (optional) True to walk the dom and see if parent elements are hidden (defaults to false)
     * @return {Boolean} True if the element is currently visible, else false
     */
    isVisible : function(deep) {
        var vis = !(this.getStyle("visibility") == "hidden" || this.getStyle("display") == "none");
        if(deep !== true || !vis){
            return vis;
        }
        var p = this.dom.parentNode;
        while(p && p.tagName.toLowerCase() != "body"){
            if(!Ext.fly(p, '_isVisible').isVisible()){
                return false;
            }
            p = p.parentNode;
        }
        return true;
    },

    /**
     * Creates a {@link Ext.CompositeElement} for child nodes based on the passed CSS selector (the selector should not contain an id).
     * @param {String} selector The CSS selector
     * @param {Boolean} unique (optional) True to create a unique Ext.Element for each child (defaults to false, which creates a single shared flyweight object)
     * @return {CompositeElement/CompositeElementLite} The composite element
     */
    select : function(selector, unique){
        return El.select(selector, unique, this.dom);
    },

    /**
     * Selects child nodes based on the passed CSS selector (the selector should not contain an id).
     * @param {String} selector The CSS selector
     * @return {Array} An array of the matched nodes
     */
    query : function(selector){
        return Ext.DomQuery.select(selector, this.dom);
    },

    /**
     * Selects a single child at any depth below this element based on the passed CSS selector (the selector should not contain an id).
     * @param {String} selector The CSS selector
     * @param {Boolean} returnDom (optional) True to return the DOM node instead of Ext.Element (defaults to false)
     * @return {HTMLElement/Ext.Element} The child Ext.Element (or DOM node if returnDom = true)
     */
    child : function(selector, returnDom){
        var n = Ext.DomQuery.selectNode(selector, this.dom);
        return returnDom ? n : Ext.get(n);
    },

    /**
     * Selects a single *direct* child based on the passed CSS selector (the selector should not contain an id).
     * @param {String} selector The CSS selector
     * @param {Boolean} returnDom (optional) True to return the DOM node instead of Ext.Element (defaults to false)
     * @return {HTMLElement/Ext.Element} The child Ext.Element (or DOM node if returnDom = true)
     */
    down : function(selector, returnDom){
        var n = Ext.DomQuery.selectNode(" > " + selector, this.dom);
        return returnDom ? n : Ext.get(n);
    },

    /**
     * Initializes a {@link Ext.dd.DD} drag drop object for this element.
     * @param {String} group The group the DD object is member of
     * @param {Object} config The DD config object
     * @param {Object} overrides An object containing methods to override/implement on the DD object
     * @return {Ext.dd.DD} The DD object
     */
    initDD : function(group, config, overrides){
        var dd = new Ext.dd.DD(Ext.id(this.dom), group, config);
        return Ext.apply(dd, overrides);
    },

    /**
     * Initializes a {@link Ext.dd.DDProxy} object for this element.
     * @param {String} group The group the DDProxy object is member of
     * @param {Object} config The DDProxy config object
     * @param {Object} overrides An object containing methods to override/implement on the DDProxy object
     * @return {Ext.dd.DDProxy} The DDProxy object
     */
    initDDProxy : function(group, config, overrides){
        var dd = new Ext.dd.DDProxy(Ext.id(this.dom), group, config);
        return Ext.apply(dd, overrides);
    },

    /**
     * Initializes a {@link Ext.dd.DDTarget} object for this element.
     * @param {String} group The group the DDTarget object is member of
     * @param {Object} config The DDTarget config object
     * @param {Object} overrides An object containing methods to override/implement on the DDTarget object
     * @return {Ext.dd.DDTarget} The DDTarget object
     */
    initDDTarget : function(group, config, overrides){
        var dd = new Ext.dd.DDTarget(Ext.id(this.dom), group, config);
        return Ext.apply(dd, overrides);
    },

    /**
     * Sets the visibility of the element (see details). If the visibilityMode is set to Element.DISPLAY, it will use
     * the display property to hide the element, otherwise it uses visibility. The default is to hide and show using the visibility property.
     * @param {Boolean} visible Whether the element is visible
     * @param {Boolean/Object} animate (optional) True for the default animation, or a standard Element animation config object
     * @return {Ext.Element} this
     */
     setVisible : function(visible, animate){
        if(!animate || !A){
            if(this.visibilityMode == El.DISPLAY){
                this.setDisplayed(visible);
            }else{
                this.fixDisplay();
                this.dom.style.visibility = visible ? "visible" : "hidden";
            }
        }else{
            // closure for composites
            var dom = this.dom;
            var visMode = this.visibilityMode;
            if(visible){
                this.setOpacity(.01);
                this.setVisible(true);
            }
            this.anim({opacity: { to: (visible?1:0) }},
                  this.preanim(arguments, 1),
                  null, .35, 'easeIn', function(){
                     if(!visible){
                         if(visMode == El.DISPLAY){
                             dom.style.display = "none";
                         }else{
                             dom.style.visibility = "hidden";
                         }
                         Ext.get(dom).setOpacity(1);
                     }
                 });
        }
        return this;
    },

    /**
     * Returns true if display is not "none"
     * @return {Boolean}
     */
    isDisplayed : function() {
        return this.getStyle("display") != "none";
    },

    /**
     * Toggles the element's visibility or display, depending on visibility mode.
     * @param {Boolean/Object} animate (optional) True for the default animation, or a standard Element animation config object
     * @return {Ext.Element} this
     */
    toggle : function(animate){
        this.setVisible(!this.isVisible(), this.preanim(arguments, 0));
        return this;
    },

    /**
     * Sets the CSS display property. Uses originalDisplay if the specified value is a boolean true.
     * @param {Mixed} value Boolean value to display the element using its default display, or a string to set the display directly.
     * @return {Ext.Element} this
     */
    setDisplayed : function(value) {
        if(typeof value == "boolean"){
           value = value ? this.originalDisplay : "none";
        }
        this.setStyle("display", value);
        return this;
    },

    /**
     * Tries to focus the element. Any exceptions are caught and ignored.
     * @return {Ext.Element} this
     */
    focus : function() {
        try{
            this.dom.focus();
        }catch(e){}
        return this;
    },

    /**
     * Tries to blur the element. Any exceptions are caught and ignored.
     * @return {Ext.Element} this
     */
    blur : function() {
        try{
            this.dom.blur();
        }catch(e){}
        return this;
    },

    /**
     * Adds one or more CSS classes to the element. Duplicate classes are automatically filtered out.
     * @param {String/Array} className The CSS class to add, or an array of classes
     * @return {Ext.Element} this
     */
    addClass : function(className){
        if(Ext.isArray(className)){
            for(var i = 0, len = className.length; i < len; i++) {
            	this.addClass(className[i]);
            }
        }else{
            if(className && !this.hasClass(className)){
                this.dom.className = this.dom.className + " " + className;
            }
        }
        return this;
    },

    /**
     * Adds one or more CSS classes to this element and removes the same class(es) from all siblings.
     * @param {String/Array} className The CSS class to add, or an array of classes
     * @return {Ext.Element} this
     */
    radioClass : function(className){
        var siblings = this.dom.parentNode.childNodes;
        for(var i = 0; i < siblings.length; i++) {
        	var s = siblings[i];
        	if(s.nodeType == 1){
        	    Ext.get(s).removeClass(className);
        	}
        }
        this.addClass(className);
        return this;
    },

    /**
     * Removes one or more CSS classes from the element.
     * @param {String/Array} className The CSS class to remove, or an array of classes
     * @return {Ext.Element} this
     */
    removeClass : function(className){
        if(!className || !this.dom.className){
            return this;
        }
        if(Ext.isArray(className)){
            for(var i = 0, len = className.length; i < len; i++) {
            	this.removeClass(className[i]);
            }
        }else{
            if(this.hasClass(className)){
                var re = this.classReCache[className];
                if (!re) {
                   re = new RegExp('(?:^|\\s+)' + className + '(?:\\s+|$)', "g");
                   this.classReCache[className] = re;
                }
                this.dom.className =
                    this.dom.className.replace(re, " ");
            }
        }
        return this;
    },

    // private
    classReCache: {},

    /**
     * Toggles the specified CSS class on this element (removes it if it already exists, otherwise adds it).
     * @param {String} className The CSS class to toggle
     * @return {Ext.Element} this
     */
    toggleClass : function(className){
        if(this.hasClass(className)){
            this.removeClass(className);
        }else{
            this.addClass(className);
        }
        return this;
    },

    /**
     * Checks if the specified CSS class exists on this element's DOM node.
     * @param {String} className The CSS class to check for
     * @return {Boolean} True if the class exists, else false
     */
    hasClass : function(className){
        return className && (' '+this.dom.className+' ').indexOf(' '+className+' ') != -1;
    },

    /**
     * Replaces a CSS class on the element with another.  If the old name does not exist, the new name will simply be added.
     * @param {String} oldClassName The CSS class to replace
     * @param {String} newClassName The replacement CSS class
     * @return {Ext.Element} this
     */
    replaceClass : function(oldClassName, newClassName){
        this.removeClass(oldClassName);
        this.addClass(newClassName);
        return this;
    },

    /**
     * Returns an object with properties matching the styles requested.
     * For example, el.getStyles('color', 'font-size', 'width') might return
     * {'color': '#FFFFFF', 'font-size': '13px', 'width': '100px'}.
     * @param {String} style1 A style name
     * @param {String} style2 A style name
     * @param {String} etc.
     * @return {Object} The style object
     */
    getStyles : function(){
        var a = arguments, len = a.length, r = {};
        for(var i = 0; i < len; i++){
            r[a[i]] = this.getStyle(a[i]);
        }
        return r;
    },

    /**
     * Normalizes currentStyle and computedStyle.
     * @param {String} property The style property whose value is returned.
     * @return {String} The current value of the style property for this element.
     */
    getStyle : function(){
        return view && view.getComputedStyle ?
            function(prop){
                var el = this.dom, v, cs, camel;
                if(prop == 'float'){
                    prop = "cssFloat";
                }
                if(v = el.style[prop]){
                    return v;
                }
                if(cs = view.getComputedStyle(el, "")){
                    if(!(camel = propCache[prop])){
                        camel = propCache[prop] = prop.replace(camelRe, camelFn);
                    }
                    return cs[camel];
                }
                return null;
            } :
            function(prop){
                var el = this.dom, v, cs, camel;
                if(prop == 'opacity'){
                    if(typeof el.style.filter == 'string'){
                        var m = el.style.filter.match(/alpha\(opacity=(.*)\)/i);
                        if(m){
                            var fv = parseFloat(m[1]);
                            if(!isNaN(fv)){
                                return fv ? fv / 100 : 0;
                            }
                        }
                    }
                    return 1;
                }else if(prop == 'float'){
                    prop = "styleFloat";
                }
                if(!(camel = propCache[prop])){
                    camel = propCache[prop] = prop.replace(camelRe, camelFn);
                }
                if(v = el.style[camel]){
                    return v;
                }
                if(cs = el.currentStyle){
                    return cs[camel];
                }
                return null;
            };
    }(),

    /**
     * Wrapper for setting style properties, also takes single object parameter of multiple styles.
     * @param {String/Object} property The style property to be set, or an object of multiple styles.
     * @param {String} value (optional) The value to apply to the given property, or null if an object was passed.
     * @return {Ext.Element} this
     */
    setStyle : function(prop, value){
        if(typeof prop == "string"){
            var camel;
            if(!(camel = propCache[prop])){
                camel = propCache[prop] = prop.replace(camelRe, camelFn);
            }
            if(camel == 'opacity') {
                this.setOpacity(value);
            }else{
                this.dom.style[camel] = value;
            }
        }else{
            for(var style in prop){
                if(typeof prop[style] != "function"){
                   this.setStyle(style, prop[style]);
                }
            }
        }
        return this;
    },

    /**
     * More flexible version of {@link #setStyle} for setting style properties.
     * @param {String/Object/Function} styles A style specification string, e.g. "width:100px", or object in the form {width:"100px"}, or
     * a function which returns such a specification.
     * @return {Ext.Element} this
     */
    applyStyles : function(style){
        Ext.DomHelper.applyStyles(this.dom, style);
        return this;
    },

    /**
      * Gets the current X position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
      * @return {Number} The X position of the element
      */
    getX : function(){
        return D.getX(this.dom);
    },

    /**
      * Gets the current Y position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
      * @return {Number} The Y position of the element
      */
    getY : function(){
        return D.getY(this.dom);
    },

    /**
      * Gets the current position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
      * @return {Array} The XY position of the element
      */
    getXY : function(){
        return D.getXY(this.dom);
    },

    /**
      * Returns the offsets of this element from the passed element. Both element must be part of the DOM tree and not have display:none to have page coordinates.
      * @param {Mixed} element The element to get the offsets from.
      * @return {Array} The XY page offsets (e.g. [100, -200])
      */
    getOffsetsTo : function(el){
        var o = this.getXY();
        var e = Ext.fly(el, '_internal').getXY();
        return [o[0]-e[0],o[1]-e[1]];
    },

    /**
     * Sets the X position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
     * @param {Number} The X position of the element
     * @param {Boolean/Object} animate (optional) True for the default animation, or a standard Element animation config object
     * @return {Ext.Element} this
     */
    setX : function(x, animate){
        if(!animate || !A){
            D.setX(this.dom, x);
        }else{
            this.setXY([x, this.getY()], this.preanim(arguments, 1));
        }
        return this;
    },

    /**
     * Sets the Y position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
     * @param {Number} The Y position of the element
     * @param {Boolean/Object} animate (optional) True for the default animation, or a standard Element animation config object
     * @return {Ext.Element} this
     */
    setY : function(y, animate){
        if(!animate || !A){
            D.setY(this.dom, y);
        }else{
            this.setXY([this.getX(), y], this.preanim(arguments, 1));
        }
        return this;
    },

    /**
     * Sets the element's left position directly using CSS style (instead of {@link #setX}).
     * @param {String} left The left CSS property value
     * @return {Ext.Element} this
     */
    setLeft : function(left){
        this.setStyle("left", this.addUnits(left));
        return this;
    },

    /**
     * Sets the element's top position directly using CSS style (instead of {@link #setY}).
     * @param {String} top The top CSS property value
     * @return {Ext.Element} this
     */
    setTop : function(top){
        this.setStyle("top", this.addUnits(top));
        return this;
    },

    /**
     * Sets the element's CSS right style.
     * @param {String} right The right CSS property value
     * @return {Ext.Element} this
     */
    setRight : function(right){
        this.setStyle("right", this.addUnits(right));
        return this;
    },

    /**
     * Sets the element's CSS bottom style.
     * @param {String} bottom The bottom CSS property value
     * @return {Ext.Element} this
     */
    setBottom : function(bottom){
        this.setStyle("bottom", this.addUnits(bottom));
        return this;
    },

    /**
     * Sets the position of the element in page coordinates, regardless of how the element is positioned.
     * The element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
     * @param {Array} pos Contains X & Y [x, y] values for new position (coordinates are page-based)
     * @param {Boolean/Object} animate (optional) True for the default animation, or a standard Element animation config object
     * @return {Ext.Element} this
     */
    setXY : function(pos, animate){
        if(!animate || !A){
            D.setXY(this.dom, pos);
        }else{
            this.anim({points: {to: pos}}, this.preanim(arguments, 1), 'motion');
        }
        return this;
    },

    /**
     * Sets the position of the element in page coordinates, regardless of how the element is positioned.
     * The element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
     * @param {Number} x X value for new position (coordinates are page-based)
     * @param {Number} y Y value for new position (coordinates are page-based)
     * @param {Boolean/Object} animate (optional) True for the default animation, or a standard Element animation config object
     * @return {Ext.Element} this
     */
    setLocation : function(x, y, animate){
        this.setXY([x, y], this.preanim(arguments, 2));
        return this;
    },

    /**
     * Sets the position of the element in page coordinates, regardless of how the element is positioned.
     * The element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
     * @param {Number} x X value for new position (coordinates are page-based)
     * @param {Number} y Y value for new position (coordinates are page-based)
     * @param {Boolean/Object} animate (optional) True for the default animation, or a standard Element animation config object
     * @return {Ext.Element} this
     */
    moveTo : function(x, y, animate){
        this.setXY([x, y], this.preanim(arguments, 2));
        return this;
    },

    /**
     * Returns the region of the given element.
     * The element must be part of the DOM tree to have a region (display:none or elements not appended return false).
     * @return {Region} A Ext.lib.Region containing "top, left, bottom, right" member data.
     */
    getRegion : function(){
        return D.getRegion(this.dom);
    },

    /**
     * Returns the offset height of the element
     * @param {Boolean} contentHeight (optional) true to get the height minus borders and padding
     * @return {Number} The element's height
     */
    getHeight : function(contentHeight){
        var h = this.dom.offsetHeight || 0;
        h = contentHeight !== true ? h : h-this.getBorderWidth("tb")-this.getPadding("tb");
        return h < 0 ? 0 : h;
    },

    /**
     * Returns the offset width of the element
     * @param {Boolean} contentWidth (optional) true to get the width minus borders and padding
     * @return {Number} The element's width
     */
    getWidth : function(contentWidth){
        var w = this.dom.offsetWidth || 0;
        w = contentWidth !== true ? w : w-this.getBorderWidth("lr")-this.getPadding("lr");
        return w < 0 ? 0 : w;
    },

    /**
     * Returns either the offsetHeight or the height of this element based on CSS height adjusted by padding or borders
     * when needed to simulate offsetHeight when offsets aren't available. This may not work on display:none elements
     * if a height has not been set using CSS.
     * @return {Number}
     */
    getComputedHeight : function(){
        var h = Math.max(this.dom.offsetHeight, this.dom.clientHeight);
        if(!h){
            h = parseInt(this.getStyle('height'), 10) || 0;
            if(!this.isBorderBox()){
                h += this.getFrameWidth('tb');
            }
        }
        return h;
    },

    /**
     * Returns either the offsetWidth or the width of this element based on CSS width adjusted by padding or borders
     * when needed to simulate offsetWidth when offsets aren't available. This may not work on display:none elements
     * if a width has not been set using CSS.
     * @return {Number}
     */
    getComputedWidth : function(){
        var w = Math.max(this.dom.offsetWidth, this.dom.clientWidth);
        if(!w){
            w = parseInt(this.getStyle('width'), 10) || 0;
            if(!this.isBorderBox()){
                w += this.getFrameWidth('lr');
            }
        }
        return w;
    },

    /**
     * Returns the size of the element.
     * @param {Boolean} contentSize (optional) true to get the width/size minus borders and padding
     * @return {Object} An object containing the element's size {width: (element width), height: (element height)}
     */
    getSize : function(contentSize){
        return {width: this.getWidth(contentSize), height: this.getHeight(contentSize)};
    },

    getStyleSize : function(){
        var w, h, d = this.dom, s = d.style;
        if(s.width && s.width != 'auto'){
            w = parseInt(s.width, 10);
            if(Ext.isBorderBox){
               w -= this.getFrameWidth('lr');
            }
        }
        if(s.height && s.height != 'auto'){
            h = parseInt(s.height, 10);
            if(Ext.isBorderBox){
               h -= this.getFrameWidth('tb');
            }
        }
        return {width: w || this.getWidth(true), height: h || this.getHeight(true)};

    },

    /**
     * Returns the width and height of the viewport.
     * @return {Object} An object containing the viewport's size {width: (viewport width), height: (viewport height)}
     */
    getViewSize : function(){
        var d = this.dom, doc = document, aw = 0, ah = 0;
        if(d == doc || d == doc.body){
            return {width : D.getViewWidth(), height: D.getViewHeight()};
        }else{
            return {
                width : d.clientWidth,
                height: d.clientHeight
            };
        }
    },

    /**
     * Returns the value of the "value" attribute
     * @param {Boolean} asNumber true to parse the value as a number
     * @return {String/Number}
     */
    getValue : function(asNumber){
        return asNumber ? parseInt(this.dom.value, 10) : this.dom.value;
    },

    // private
    adjustWidth : function(width){
        if(typeof width == "number"){
            if(this.autoBoxAdjust && !this.isBorderBox()){
               width -= (this.getBorderWidth("lr") + this.getPadding("lr"));
            }
            if(width < 0){
                width = 0;
            }
        }
        return width;
    },

    // private
    adjustHeight : function(height){
        if(typeof height == "number"){
           if(this.autoBoxAdjust && !this.isBorderBox()){
               height -= (this.getBorderWidth("tb") + this.getPadding("tb"));
           }
           if(height < 0){
               height = 0;
           }
        }
        return height;
    },

    /**
     * Set the width of the element
     * @param {Number} width The new width
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
    setWidth : function(width, animate){
        width = this.adjustWidth(width);
        if(!animate || !A){
            this.dom.style.width = this.addUnits(width);
        }else{
            this.anim({width: {to: width}}, this.preanim(arguments, 1));
        }
        return this;
    },

    /**
     * Set the height of the element
     * @param {Number} height The new height
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
     setHeight : function(height, animate){
        height = this.adjustHeight(height);
        if(!animate || !A){
            this.dom.style.height = this.addUnits(height);
        }else{
            this.anim({height: {to: height}}, this.preanim(arguments, 1));
        }
        return this;
    },

    /**
     * Set the size of the element. If animation is true, both width an height will be animated concurrently.
     * @param {Number} width The new width
     * @param {Number} height The new height
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
     setSize : function(width, height, animate){
        if(typeof width == "object"){ // in case of object from getSize()
            height = width.height; width = width.width;
        }
        width = this.adjustWidth(width); height = this.adjustHeight(height);
        if(!animate || !A){
            this.dom.style.width = this.addUnits(width);
            this.dom.style.height = this.addUnits(height);
        }else{
            this.anim({width: {to: width}, height: {to: height}}, this.preanim(arguments, 2));
        }
        return this;
    },

    /**
     * Sets the element's position and size in one shot. If animation is true then width, height, x and y will be animated concurrently.
     * @param {Number} x X value for new position (coordinates are page-based)
     * @param {Number} y Y value for new position (coordinates are page-based)
     * @param {Number} width The new width
     * @param {Number} height The new height
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
    setBounds : function(x, y, width, height, animate){
        if(!animate || !A){
            this.setSize(width, height);
            this.setLocation(x, y);
        }else{
            width = this.adjustWidth(width); height = this.adjustHeight(height);
            this.anim({points: {to: [x, y]}, width: {to: width}, height: {to: height}},
                          this.preanim(arguments, 4), 'motion');
        }
        return this;
    },

    /**
     * Sets the element's position and size the specified region. If animation is true then width, height, x and y will be animated concurrently.
     * @param {Ext.lib.Region} region The region to fill
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
    setRegion : function(region, animate){
        this.setBounds(region.left, region.top, region.right-region.left, region.bottom-region.top, this.preanim(arguments, 1));
        return this;
    },

    /**
     * Appends an event handler to this element.  The shorthand version {@link #on} is equivalent.
     * @param {String} eventName The type of event to handle
     * @param {Function} fn The handler function the event invokes. This function is passed
     * the following parameters:<ul>
     * <li>evt : EventObject<div class="sub-desc">The {@link Ext.EventObject EventObject} describing the event.</div></li>
     * <li>t : Element<div class="sub-desc">The {@link Ext.Element Element} which was the target of the event.
     * Note that this may be filtered by using the <tt>delegate</tt> option.</div></li>
     * <li>o : Object<div class="sub-desc">The options object from the addListener call.</div></li>
     * </ul>
     * @param {Object} scope (optional) The scope (The <tt>this</tt> reference) of the handler function. Defaults
     * to this Element.
     * @param {Object} options (optional) An object containing handler configuration properties.
     * This may contain any of the following properties:<ul>
     * <li>scope {Object} : The scope in which to execute the handler function. The handler function's "this" context.</li>
     * <li>delegate {String} : A simple selector to filter the target or look for a descendant of the target</li>
     * <li>stopEvent {Boolean} : True to stop the event. That is stop propagation, and prevent the default action.</li>
     * <li>preventDefault {Boolean} : True to prevent the default action</li>
     * <li>stopPropagation {Boolean} : True to prevent event propagation</li>
     * <li>normalized {Boolean} : False to pass a browser event to the handler function instead of an Ext.EventObject</li>
     * <li>delay {Number} : The number of milliseconds to delay the invocation of the handler after te event fires.</li>
     * <li>single {Boolean} : True to add a handler to handle just the next firing of the event, and then remove itself.</li>
     * <li>buffer {Number} : Causes the handler to be scheduled to run in an {@link Ext.util.DelayedTask} delayed
     * by the specified number of milliseconds. If the event fires again within that time, the original
     * handler is <em>not</em> invoked, but the new handler is scheduled in its place.</li>
     * </ul><br>
     * <p>
     * <b>Combining Options</b><br>
     * In the following examples, the shorthand form {@link #on} is used rather than the more verbose
     * addListener.  The two are equivalent.  Using the options argument, it is possible to combine different
     * types of listeners:<br>
     * <br>
     * A normalized, delayed, one-time listener that auto stops the event and adds a custom argument (forumId) to the
     * options object. The options object is available as the third parameter in the handler function.<div style="margin: 5px 20px 20px;">
     * Code:<pre><code>
el.on('click', this.onClick, this, {
    single: true,
    delay: 100,
    stopEvent : true,
    forumId: 4
});</code></pre></p>
     * <p>
     * <b>Attaching multiple handlers in 1 call</b><br>
      * The method also allows for a single argument to be passed which is a config object containing properties
     * which specify multiple handlers.</p>
     * <p>
     * Code:<pre><code></p>
el.on({
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
     * Code:<pre><code></p>
el.on({
    'click' : this.onClick,
    'mouseover' : this.onMouseOver,
    'mouseout' : this.onMouseOut,
    scope: this
});</code></pre>
     */
    addListener : function(eventName, fn, scope, options){
        Ext.EventManager.on(this.dom,  eventName, fn, scope || this, options);
    },

    /**
     * Removes an event handler from this element.  The shorthand version {@link #un} is equivalent.  Example:
     * <pre><code>
el.removeListener('click', this.handlerFn);
// or
el.un('click', this.handlerFn);
</code></pre>
     * @param {String} eventName the type of event to remove
     * @param {Function} fn the method the event invokes
     * @param {Object} scope (optional) The scope (The <tt>this</tt> reference) of the handler function. Defaults
     * to this Element.
     * @return {Ext.Element} this
     */
    removeListener : function(eventName, fn, scope){
        Ext.EventManager.removeListener(this.dom,  eventName, fn, scope || this);
        return this;
    },

    /**
     * Removes all previous added listeners from this element
     * @return {Ext.Element} this
     */
    removeAllListeners : function(){
        Ext.EventManager.removeAll(this.dom);
        return this;
    },

    /**
     * Create an event handler on this element such that when the event fires and is handled by this element,
     * it will be relayed to another object (i.e., fired again as if it originated from that object instead).
     * @param {String} eventName The type of event to relay
     * @param {Object} object Any object that extends {@link Ext.util.Observable} that will provide the context
     * for firing the relayed event
     */
    relayEvent : function(eventName, observable){
        this.on(eventName, function(e){
            observable.fireEvent(eventName, e);
        });
    },

    /**
     * Set the opacity of the element
     * @param {Float} opacity The new opacity. 0 = transparent, .5 = 50% visibile, 1 = fully visible, etc
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
     setOpacity : function(opacity, animate){
        if(!animate || !A){
            var s = this.dom.style;
            if(Ext.isIE){
                s.zoom = 1;
                s.filter = (s.filter || '').replace(/alpha\([^\)]*\)/gi,"") +
                           (opacity == 1 ? "" : " alpha(opacity=" + opacity * 100 + ")");
            }else{
                s.opacity = opacity;
            }
        }else{
            this.anim({opacity: {to: opacity}}, this.preanim(arguments, 1), null, .35, 'easeIn');
        }
        return this;
    },

    /**
     * Gets the left X coordinate
     * @param {Boolean} local True to get the local css position instead of page coordinate
     * @return {Number}
     */
    getLeft : function(local){
        if(!local){
            return this.getX();
        }else{
            return parseInt(this.getStyle("left"), 10) || 0;
        }
    },

    /**
     * Gets the right X coordinate of the element (element X position + element width)
     * @param {Boolean} local True to get the local css position instead of page coordinate
     * @return {Number}
     */
    getRight : function(local){
        if(!local){
            return this.getX() + this.getWidth();
        }else{
            return (this.getLeft(true) + this.getWidth()) || 0;
        }
    },

    /**
     * Gets the top Y coordinate
     * @param {Boolean} local True to get the local css position instead of page coordinate
     * @return {Number}
     */
    getTop : function(local) {
        if(!local){
            return this.getY();
        }else{
            return parseInt(this.getStyle("top"), 10) || 0;
        }
    },

    /**
     * Gets the bottom Y coordinate of the element (element Y position + element height)
     * @param {Boolean} local True to get the local css position instead of page coordinate
     * @return {Number}
     */
    getBottom : function(local){
        if(!local){
            return this.getY() + this.getHeight();
        }else{
            return (this.getTop(true) + this.getHeight()) || 0;
        }
    },

    /**
    * Initializes positioning on this element. If a desired position is not passed, it will make the
    * the element positioned relative IF it is not already positioned.
    * @param {String} pos (optional) Positioning to use "relative", "absolute" or "fixed"
    * @param {Number} zIndex (optional) The zIndex to apply
    * @param {Number} x (optional) Set the page X position
    * @param {Number} y (optional) Set the page Y position
    */
    position : function(pos, zIndex, x, y){
        if(!pos){
           if(this.getStyle('position') == 'static'){
               this.setStyle('position', 'relative');
           }
        }else{
            this.setStyle("position", pos);
        }
        if(zIndex){
            this.setStyle("z-index", zIndex);
        }
        if(x !== undefined && y !== undefined){
            this.setXY([x, y]);
        }else if(x !== undefined){
            this.setX(x);
        }else if(y !== undefined){
            this.setY(y);
        }
    },

    /**
    * Clear positioning back to the default when the document was loaded
    * @param {String} value (optional) The value to use for the left,right,top,bottom, defaults to '' (empty string). You could use 'auto'.
    * @return {Ext.Element} this
     */
    clearPositioning : function(value){
        value = value ||'';
        this.setStyle({
            "left": value,
            "right": value,
            "top": value,
            "bottom": value,
            "z-index": "",
            "position" : "static"
        });
        return this;
    },

    /**
    * Gets an object with all CSS positioning properties. Useful along with setPostioning to get
    * snapshot before performing an update and then restoring the element.
    * @return {Object}
    */
    getPositioning : function(){
        var l = this.getStyle("left");
        var t = this.getStyle("top");
        return {
            "position" : this.getStyle("position"),
            "left" : l,
            "right" : l ? "" : this.getStyle("right"),
            "top" : t,
            "bottom" : t ? "" : this.getStyle("bottom"),
            "z-index" : this.getStyle("z-index")
        };
    },

    /**
     * Gets the width of the border(s) for the specified side(s)
     * @param {String} side Can be t, l, r, b or any combination of those to add multiple values. For example,
     * passing lr would get the border (l)eft width + the border (r)ight width.
     * @return {Number} The width of the sides passed added together
     */
    getBorderWidth : function(side){
        return this.addStyles(side, El.borders);
    },

    /**
     * Gets the width of the padding(s) for the specified side(s)
     * @param {String} side Can be t, l, r, b or any combination of those to add multiple values. For example,
     * passing lr would get the padding (l)eft + the padding (r)ight.
     * @return {Number} The padding of the sides passed added together
     */
    getPadding : function(side){
        return this.addStyles(side, El.paddings);
    },

    /**
    * Set positioning with an object returned by getPositioning().
    * @param {Object} posCfg
    * @return {Ext.Element} this
     */
    setPositioning : function(pc){
        this.applyStyles(pc);
        if(pc.right == "auto"){
            this.dom.style.right = "";
        }
        if(pc.bottom == "auto"){
            this.dom.style.bottom = "";
        }
        return this;
    },

    // private
    fixDisplay : function(){
        if(this.getStyle("display") == "none"){
            this.setStyle("visibility", "hidden");
            this.setStyle("display", this.originalDisplay); // first try reverting to default
            if(this.getStyle("display") == "none"){ // if that fails, default to block
                this.setStyle("display", "block");
            }
        }
    },

    // private
	setOverflow : function(v){
    	if(v=='auto' && Ext.isMac && Ext.isGecko2){ // work around stupid FF 2.0/Mac scroll bar bug
    		this.dom.style.overflow = 'hidden';
        	(function(){this.dom.style.overflow = 'auto';}).defer(1, this);
    	}else{
    		this.dom.style.overflow = v;
    	}
	},

    /**
     * Quick set left and top adding default units
     * @param {String} left The left CSS property value
     * @param {String} top The top CSS property value
     * @return {Ext.Element} this
     */
     setLeftTop : function(left, top){
        this.dom.style.left = this.addUnits(left);
        this.dom.style.top = this.addUnits(top);
        return this;
    },

    /**
     * Move this element relative to its current position.
     * @param {String} direction Possible values are: "l" (or "left"), "r" (or "right"), "t" (or "top", or "up"), "b" (or "bottom", or "down").
     * @param {Number} distance How far to move the element in pixels
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
     move : function(direction, distance, animate){
        var xy = this.getXY();
        direction = direction.toLowerCase();
        switch(direction){
            case "l":
            case "left":
                this.moveTo(xy[0]-distance, xy[1], this.preanim(arguments, 2));
                break;
           case "r":
           case "right":
                this.moveTo(xy[0]+distance, xy[1], this.preanim(arguments, 2));
                break;
           case "t":
           case "top":
           case "up":
                this.moveTo(xy[0], xy[1]-distance, this.preanim(arguments, 2));
                break;
           case "b":
           case "bottom":
           case "down":
                this.moveTo(xy[0], xy[1]+distance, this.preanim(arguments, 2));
                break;
        }
        return this;
    },

    /**
     *  Store the current overflow setting and clip overflow on the element - use {@link #unclip} to remove
     * @return {Ext.Element} this
     */
    clip : function(){
        if(!this.isClipped){
           this.isClipped = true;
           this.originalClip = {
               "o": this.getStyle("overflow"),
               "x": this.getStyle("overflow-x"),
               "y": this.getStyle("overflow-y")
           };
           this.setStyle("overflow", "hidden");
           this.setStyle("overflow-x", "hidden");
           this.setStyle("overflow-y", "hidden");
        }
        return this;
    },

    /**
     *  Return clipping (overflow) to original clipping before clip() was called
     * @return {Ext.Element} this
     */
    unclip : function(){
        if(this.isClipped){
            this.isClipped = false;
            var o = this.originalClip;
            if(o.o){this.setStyle("overflow", o.o);}
            if(o.x){this.setStyle("overflow-x", o.x);}
            if(o.y){this.setStyle("overflow-y", o.y);}
        }
        return this;
    },


    /**
     * Gets the x,y coordinates specified by the anchor position on the element.
     * @param {String} anchor (optional) The specified anchor position (defaults to "c").  See {@link #alignTo}
     * for details on supported anchor positions.
     * @param {Boolean} local (optional) True to get the local (element top/left-relative) anchor position instead
     * of page coordinates
     * @param {Object} size (optional) An object containing the size to use for calculating anchor position
     * {width: (target width), height: (target height)} (defaults to the element's current size)
     * @return {Array} [x, y] An array containing the element's x and y coordinates
     */
    getAnchorXY : function(anchor, local, s){
        //Passing a different size is useful for pre-calculating anchors,
        //especially for anchored animations that change the el size.

        var w, h, vp = false;
        if(!s){
            var d = this.dom;
            if(d == document.body || d == document){
                vp = true;
                w = D.getViewWidth(); h = D.getViewHeight();
            }else{
                w = this.getWidth(); h = this.getHeight();
            }
        }else{
            w = s.width;  h = s.height;
        }
        var x = 0, y = 0, r = Math.round;
        switch((anchor || "tl").toLowerCase()){
            case "c":
                x = r(w*.5);
                y = r(h*.5);
            break;
            case "t":
                x = r(w*.5);
                y = 0;
            break;
            case "l":
                x = 0;
                y = r(h*.5);
            break;
            case "r":
                x = w;
                y = r(h*.5);
            break;
            case "b":
                x = r(w*.5);
                y = h;
            break;
            case "tl":
                x = 0;
                y = 0;
            break;
            case "bl":
                x = 0;
                y = h;
            break;
            case "br":
                x = w;
                y = h;
            break;
            case "tr":
                x = w;
                y = 0;
            break;
        }
        if(local === true){
            return [x, y];
        }
        if(vp){
            var sc = this.getScroll();
            return [x + sc.left, y + sc.top];
        }
        //Add the element's offset xy
        var o = this.getXY();
        return [x+o[0], y+o[1]];
    },

    /**
     * Gets the x,y coordinates to align this element with another element. See {@link #alignTo} for more info on the
     * supported position values.
     * @param {Mixed} element The element to align to.
     * @param {String} position The position to align to.
     * @param {Array} offsets (optional) Offset the positioning by [x, y]
     * @return {Array} [x, y]
     */
    getAlignToXY : function(el, p, o){
        el = Ext.get(el);
        if(!el || !el.dom){
            throw "Element.alignToXY with an element that doesn't exist";
        }
        var d = this.dom;
        var c = false; //constrain to viewport
        var p1 = "", p2 = "";
        o = o || [0,0];

        if(!p){
            p = "tl-bl";
        }else if(p == "?"){
            p = "tl-bl?";
        }else if(p.indexOf("-") == -1){
            p = "tl-" + p;
        }
        p = p.toLowerCase();
        var m = p.match(/^([a-z]+)-([a-z]+)(\?)?$/);
        if(!m){
           throw "Element.alignTo with an invalid alignment " + p;
        }
        p1 = m[1]; p2 = m[2]; c = !!m[3];

        //Subtract the aligned el's internal xy from the target's offset xy
        //plus custom offset to get the aligned el's new offset xy
        var a1 = this.getAnchorXY(p1, true);
        var a2 = el.getAnchorXY(p2, false);

        var x = a2[0] - a1[0] + o[0];
        var y = a2[1] - a1[1] + o[1];

        if(c){
            //constrain the aligned el to viewport if necessary
            var w = this.getWidth(), h = this.getHeight(), r = el.getRegion();
            // 5px of margin for ie
            var dw = D.getViewWidth()-5, dh = D.getViewHeight()-5;

            //If we are at a viewport boundary and the aligned el is anchored on a target border that is
            //perpendicular to the vp border, allow the aligned el to slide on that border,
            //otherwise swap the aligned el to the opposite border of the target.
            var p1y = p1.charAt(0), p1x = p1.charAt(p1.length-1);
           var p2y = p2.charAt(0), p2x = p2.charAt(p2.length-1);
           var swapY = ((p1y=="t" && p2y=="b") || (p1y=="b" && p2y=="t"));
           var swapX = ((p1x=="r" && p2x=="l") || (p1x=="l" && p2x=="r"));

           var doc = document;
           var scrollX = (doc.documentElement.scrollLeft || doc.body.scrollLeft || 0)+5;
           var scrollY = (doc.documentElement.scrollTop || doc.body.scrollTop || 0)+5;

           if((x+w) > dw + scrollX){
                x = swapX ? r.left-w : dw+scrollX-w;
            }
           if(x < scrollX){
               x = swapX ? r.right : scrollX;
           }
           if((y+h) > dh + scrollY){
                y = swapY ? r.top-h : dh+scrollY-h;
            }
           if (y < scrollY){
               y = swapY ? r.bottom : scrollY;
           }
        }
        return [x,y];
    },

    // private
    getConstrainToXY : function(){
        var os = {top:0, left:0, bottom:0, right: 0};

        return function(el, local, offsets, proposedXY){
            el = Ext.get(el);
            offsets = offsets ? Ext.applyIf(offsets, os) : os;

            var vw, vh, vx = 0, vy = 0;
            if(el.dom == document.body || el.dom == document){
                vw = Ext.lib.Dom.getViewWidth();
                vh = Ext.lib.Dom.getViewHeight();
            }else{
                vw = el.dom.clientWidth;
                vh = el.dom.clientHeight;
                if(!local){
                    var vxy = el.getXY();
                    vx = vxy[0];
                    vy = vxy[1];
                }
            }

            var s = el.getScroll();

            vx += offsets.left + s.left;
            vy += offsets.top + s.top;

            vw -= offsets.right;
            vh -= offsets.bottom;

            var vr = vx+vw;
            var vb = vy+vh;

            var xy = proposedXY || (!local ? this.getXY() : [this.getLeft(true), this.getTop(true)]);
            var x = xy[0], y = xy[1];
            var w = this.dom.offsetWidth, h = this.dom.offsetHeight;

            // only move it if it needs it
            var moved = false;

            // first validate right/bottom
            if((x + w) > vr){
                x = vr - w;
                moved = true;
            }
            if((y + h) > vb){
                y = vb - h;
                moved = true;
            }
            // then make sure top/left isn't negative
            if(x < vx){
                x = vx;
                moved = true;
            }
            if(y < vy){
                y = vy;
                moved = true;
            }
            return moved ? [x, y] : false;
        };
    }(),

    // private
    adjustForConstraints : function(xy, parent, offsets){
        return this.getConstrainToXY(parent || document, false, offsets, xy) ||  xy;
    },

    /**
     * Aligns this element with another element relative to the specified anchor points. If the other element is the
     * document it aligns it to the viewport.
     * The position parameter is optional, and can be specified in any one of the following formats:
     * <ul>
     *   <li><b>Blank</b>: Defaults to aligning the element's top-left corner to the target's bottom-left corner ("tl-bl").</li>
     *   <li><b>One anchor (deprecated)</b>: The passed anchor position is used as the target element's anchor point.
     *       The element being aligned will position its top-left corner (tl) to that point.  <i>This method has been
     *       deprecated in favor of the newer two anchor syntax below</i>.</li>
     *   <li><b>Two anchors</b>: If two values from the table below are passed separated by a dash, the first value is used as the
     *       element's anchor point, and the second value is used as the target's anchor point.</li>
     * </ul>
     * In addition to the anchor points, the position parameter also supports the "?" character.  If "?" is passed at the end of
     * the position string, the element will attempt to align as specified, but the position will be adjusted to constrain to
     * the viewport if necessary.  Note that the element being aligned might be swapped to align to a different position than
     * that specified in order to enforce the viewport constraints.
     * Following are all of the supported anchor positions:
<pre>
Value  Description
-----  -----------------------------
tl     The top left corner (default)
t      The center of the top edge
tr     The top right corner
l      The center of the left edge
c      In the center of the element
r      The center of the right edge
bl     The bottom left corner
b      The center of the bottom edge
br     The bottom right corner
</pre>
Example Usage:
<pre><code>
// align el to other-el using the default positioning ("tl-bl", non-constrained)
el.alignTo("other-el");

// align the top left corner of el with the top right corner of other-el (constrained to viewport)
el.alignTo("other-el", "tr?");

// align the bottom right corner of el with the center left edge of other-el
el.alignTo("other-el", "br-l?");

// align the center of el with the bottom left corner of other-el and
// adjust the x position by -6 pixels (and the y position by 0)
el.alignTo("other-el", "c-bl", [-6, 0]);
</code></pre>
     * @param {Mixed} element The element to align to.
     * @param {String} position The position to align to.
     * @param {Array} offsets (optional) Offset the positioning by [x, y]
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
    alignTo : function(element, position, offsets, animate){
        var xy = this.getAlignToXY(element, position, offsets);
        this.setXY(xy, this.preanim(arguments, 3));
        return this;
    },

    /**
     * Anchors an element to another element and realigns it when the window is resized.
     * @param {Mixed} element The element to align to.
     * @param {String} position The position to align to.
     * @param {Array} offsets (optional) Offset the positioning by [x, y]
     * @param {Boolean/Object} animate (optional) True for the default animation or a standard Element animation config object
     * @param {Boolean/Number} monitorScroll (optional) True to monitor body scroll and reposition. If this parameter
     * is a number, it is used as the buffer delay (defaults to 50ms).
     * @param {Function} callback The function to call after the animation finishes
     * @return {Ext.Element} this
     */
    anchorTo : function(el, alignment, offsets, animate, monitorScroll, callback){
        var action = function(){
            this.alignTo(el, alignment, offsets, animate);
            Ext.callback(callback, this);
        };
        Ext.EventManager.onWindowResize(action, this);
        var tm = typeof monitorScroll;
        if(tm != 'undefined'){
            Ext.EventManager.on(window, 'scroll', action, this,
                {buffer: tm == 'number' ? monitorScroll : 50});
        }
        action.call(this); // align immediately
        return this;
    },
    /**
     * Clears any opacity settings from this element. Required in some cases for IE.
     * @return {Ext.Element} this
     */
    clearOpacity : function(){
        if (window.ActiveXObject) {
            if(typeof this.dom.style.filter == 'string' && (/alpha/i).test(this.dom.style.filter)){
                this.dom.style.filter = "";
            }
        } else {
            this.dom.style.opacity = "";
            this.dom.style["-moz-opacity"] = "";
            this.dom.style["-khtml-opacity"] = "";
        }
        return this;
    },

    /**
     * Hide this element - Uses display mode to determine whether to use "display" or "visibility". See {@link #setVisible}.
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
    hide : function(animate){
        this.setVisible(false, this.preanim(arguments, 0));
        return this;
    },

    /**
    * Show this element - Uses display mode to determine whether to use "display" or "visibility". See {@link #setVisible}.
    * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
    show : function(animate){
        this.setVisible(true, this.preanim(arguments, 0));
        return this;
    },

    /**
     * @private Test if size has a unit, otherwise appends the default
     */
    addUnits : function(size){
        return Ext.Element.addUnits(size, this.defaultUnit);
    },

    /**
    * Update the innerHTML of this element, optionally searching for and processing scripts
    * @param {String} html The new HTML
    * @param {Boolean} loadScripts (optional) True to look for and process scripts (defaults to false)
    * @param {Function} callback (optional) For async script loading you can be notified when the update completes
    * @return {Ext.Element} this
     */
    update : function(html, loadScripts, callback){
        if(typeof html == "undefined"){
            html = "";
        }
        if(loadScripts !== true){
            this.dom.innerHTML = html;
            if(typeof callback == "function"){
                callback();
            }
            return this;
        }
        var id = Ext.id();
        var dom = this.dom;

        html += '<span id="' + id + '"></span>';

        E.onAvailable(id, function(){
            var hd = document.getElementsByTagName("head")[0];
            var re = /(?:<script([^>]*)?>)((\n|\r|.)*?)(?:<\/script>)/ig;
            var srcRe = /\ssrc=([\'\"])(.*?)\1/i;
            var typeRe = /\stype=([\'\"])(.*?)\1/i;

            var match;
            while(match = re.exec(html)){
                var attrs = match[1];
                var srcMatch = attrs ? attrs.match(srcRe) : false;
                if(srcMatch && srcMatch[2]){
                   var s = document.createElement("script");
                   s.src = srcMatch[2];
                   var typeMatch = attrs.match(typeRe);
                   if(typeMatch && typeMatch[2]){
                       s.type = typeMatch[2];
                   }
                   hd.appendChild(s);
                }else if(match[2] && match[2].length > 0){
                    if(window.execScript) {
                       window.execScript(match[2]);
                    } else {
                       window.eval(match[2]);
                    }
                }
            }
            var el = document.getElementById(id);
            if(el){Ext.removeNode(el);}
            if(typeof callback == "function"){
                callback();
            }
        });
        dom.innerHTML = html.replace(/(?:<script.*?>)((\n|\r|.)*?)(?:<\/script>)/ig, "");
        return this;
    },

    /**
     * Direct access to the Updater {@link Ext.Updater#update} method. The method takes the same object
     * parameter as {@link Ext.Updater#update}
     * @return {Ext.Element} this
     */
    load : function(){
        var um = this.getUpdater();
        um.update.apply(um, arguments);
        return this;
    },

    /**
    * Gets this element's Updater
    * @return {Ext.Updater} The Updater
    */
    getUpdater : function(){
        if(!this.updateManager){
            this.updateManager = new Ext.Updater(this);
        }
        return this.updateManager;
    },

    /**
     * Disables text selection for this element (normalized across browsers)
     * @return {Ext.Element} this
     */
    unselectable : function(){
        this.dom.unselectable = "on";
        this.swallowEvent("selectstart", true);
        this.applyStyles("-moz-user-select:none;-khtml-user-select:none;");
        this.addClass("x-unselectable");
        return this;
    },

    /**
    * Calculates the x, y to center this element on the screen
    * @return {Array} The x, y values [x, y]
    */
    getCenterXY : function(){
        return this.getAlignToXY(document, 'c-c');
    },

    /**
    * Centers the Element in either the viewport, or another Element.
    * @param {Mixed} centerIn (optional) The element in which to center the element.
    */
    center : function(centerIn){
        this.alignTo(centerIn || document, 'c-c');
        return this;
    },

    /**
     * Tests various css rules/browsers to determine if this element uses a border box
     * @return {Boolean}
     */
    isBorderBox : function(){
        return noBoxAdjust[this.dom.tagName.toLowerCase()] || Ext.isBorderBox;
    },

    /**
     * Return a box {x, y, width, height} that can be used to set another elements
     * size/location to match this element.
     * @param {Boolean} contentBox (optional) If true a box for the content of the element is returned.
     * @param {Boolean} local (optional) If true the element's left and top are returned instead of page x/y.
     * @return {Object} box An object in the format {x, y, width, height}
     */
    getBox : function(contentBox, local){
        var xy;
        if(!local){
            xy = this.getXY();
        }else{
            var left = parseInt(this.getStyle("left"), 10) || 0;
            var top = parseInt(this.getStyle("top"), 10) || 0;
            xy = [left, top];
        }
        var el = this.dom, w = el.offsetWidth, h = el.offsetHeight, bx;
        if(!contentBox){
            bx = {x: xy[0], y: xy[1], 0: xy[0], 1: xy[1], width: w, height: h};
        }else{
            var l = this.getBorderWidth("l")+this.getPadding("l");
            var r = this.getBorderWidth("r")+this.getPadding("r");
            var t = this.getBorderWidth("t")+this.getPadding("t");
            var b = this.getBorderWidth("b")+this.getPadding("b");
            bx = {x: xy[0]+l, y: xy[1]+t, 0: xy[0]+l, 1: xy[1]+t, width: w-(l+r), height: h-(t+b)};
        }
        bx.right = bx.x + bx.width;
        bx.bottom = bx.y + bx.height;
        return bx;
    },

    /**
     * Returns the sum width of the padding and borders for the passed "sides". See getBorderWidth()
     for more information about the sides.
     * @param {String} sides
     * @return {Number}
     */
    getFrameWidth : function(sides, onlyContentBox){
        return onlyContentBox && Ext.isBorderBox ? 0 : (this.getPadding(sides) + this.getBorderWidth(sides));
    },

    /**
     * Sets the element's box. Use getBox() on another element to get a box obj. If animate is true then width, height, x and y will be animated concurrently.
     * @param {Object} box The box to fill {x, y, width, height}
     * @param {Boolean} adjust (optional) Whether to adjust for box-model issues automatically
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Ext.Element} this
     */
    setBox : function(box, adjust, animate){
        var w = box.width, h = box.height;
        if((adjust && !this.autoBoxAdjust) && !this.isBorderBox()){
           w -= (this.getBorderWidth("lr") + this.getPadding("lr"));
           h -= (this.getBorderWidth("tb") + this.getPadding("tb"));
        }
        this.setBounds(box.x, box.y, w, h, this.preanim(arguments, 2));
        return this;
    },

    /**
     * Forces the browser to repaint this element
     * @return {Ext.Element} this
     */
     repaint : function(){
        var dom = this.dom;
        this.addClass("x-repaint");
        setTimeout(function(){
            Ext.get(dom).removeClass("x-repaint");
        }, 1);
        return this;
    },

    /**
     * Returns an object with properties top, left, right and bottom representing the margins of this element unless sides is passed,
     * then it returns the calculated width of the sides (see getPadding)
     * @param {String} sides (optional) Any combination of l, r, t, b to get the sum of those sides
     * @return {Object/Number}
     */
    getMargins : function(side){
        if(!side){
            return {
                top: parseInt(this.getStyle("margin-top"), 10) || 0,
                left: parseInt(this.getStyle("margin-left"), 10) || 0,
                bottom: parseInt(this.getStyle("margin-bottom"), 10) || 0,
                right: parseInt(this.getStyle("margin-right"), 10) || 0
            };
        }else{
            return this.addStyles(side, El.margins);
         }
    },

    // private
    addStyles : function(sides, styles){
        var val = 0, v, w;
        for(var i = 0, len = sides.length; i < len; i++){
            v = this.getStyle(styles[sides.charAt(i)]);
            if(v){
                 w = parseInt(v, 10);
                 if(w){ val += (w >= 0 ? w : -1 * w); }
            }
        }
        return val;
    },

    /**
     * Creates a proxy element of this element
     * @param {String/Object} config The class name of the proxy element or a DomHelper config object
     * @param {String/HTMLElement} renderTo (optional) The element or element id to render the proxy to (defaults to document.body)
     * @param {Boolean} matchBox (optional) True to align and size the proxy to this element now (defaults to false)
     * @return {Ext.Element} The new proxy element
     */
    createProxy : function(config, renderTo, matchBox){
        config = typeof config == "object" ?
            config : {tag : "div", cls: config};

        var proxy;
        if(renderTo){
            proxy = Ext.DomHelper.append(renderTo, config, true);
        }else {
            proxy = Ext.DomHelper.insertBefore(this.dom, config, true);
        }
        if(matchBox){
           proxy.setBox(this.getBox());
        }
        return proxy;
    },

    /**
     * Puts a mask over this element to disable user interaction. Requires core.css.
     * This method can only be applied to elements which accept child nodes.
     * @param {String} msg (optional) A message to display in the mask
     * @param {String} msgCls (optional) A css class to apply to the msg element
     * @return {Element} The mask element
     */
    mask : function(msg, msgCls){
        if(this.getStyle("position") == "static"){
            this.setStyle("position", "relative");
        }
        if(this._maskMsg){
            this._maskMsg.remove();
        }
        if(this._mask){
            this._mask.remove();
        }

        this._mask = Ext.DomHelper.append(this.dom, {cls:"ext-el-mask"}, true);

        this.addClass("x-masked");
        this._mask.setDisplayed(true);
        if(typeof msg == 'string'){
            this._maskMsg = Ext.DomHelper.append(this.dom, {cls:"ext-el-mask-msg", cn:{tag:'div'}}, true);
            var mm = this._maskMsg;
            mm.dom.className = msgCls ? "ext-el-mask-msg " + msgCls : "ext-el-mask-msg";
            mm.dom.firstChild.innerHTML = msg;
            mm.setDisplayed(true);
            mm.center(this);
        }
        if(Ext.isIE && !(Ext.isIE7 && Ext.isStrict) && this.getStyle('height') == 'auto'){ // ie will not expand full height automatically
            this._mask.setSize(this.dom.clientWidth, this.getHeight());
        }
        return this._mask;
    },

    /**
     * Removes a previously applied mask.
     */
    unmask : function(){
        if(this._mask){
            if(this._maskMsg){
                this._maskMsg.remove();
                delete this._maskMsg;
            }
            this._mask.remove();
            delete this._mask;
        }
        this.removeClass("x-masked");
    },

    /**
     * Returns true if this element is masked
     * @return {Boolean}
     */
    isMasked : function(){
        return this._mask && this._mask.isVisible();
    },

    /**
     * Creates an iframe shim for this element to keep selects and other windowed objects from
     * showing through.
     * @return {Ext.Element} The new shim element
     */
    createShim : function(){
        var el = document.createElement('iframe');
        el.frameBorder = '0';
        el.className = 'ext-shim';
        if(Ext.isIE && Ext.isSecure){
            el.src = Ext.SSL_SECURE_URL;
        }
        var shim = Ext.get(this.dom.parentNode.insertBefore(el, this.dom));
        shim.autoBoxAdjust = false;
        return shim;
    },

    /**
     * Removes this element from the DOM and deletes it from the cache
     */
    remove : function(){
        Ext.removeNode(this.dom);
        delete El.cache[this.dom.id];
    },

    /**
     * Sets up event handlers to call the passed functions when the mouse is over this element. Automatically
     * filters child element mouse events.
     * @param {Function} overFn
     * @param {Function} outFn
     * @param {Object} scope (optional)
     * @return {Ext.Element} this
     */
    hover : function(overFn, outFn, scope){
        var preOverFn = function(e){
            if(!e.within(this, true)){
                overFn.apply(scope || this, arguments);
            }
        };
        var preOutFn = function(e){
            if(!e.within(this, true)){
                outFn.apply(scope || this, arguments);
            }
        };
        this.on("mouseover", preOverFn, this.dom);
        this.on("mouseout", preOutFn, this.dom);
        return this;
    },

    /**
     * Sets up event handlers to add and remove a css class when the mouse is over this element
     * @param {String} className
     * @return {Ext.Element} this
     */
    addClassOnOver : function(className){
        this.hover(
            function(){
                Ext.fly(this, '_internal').addClass(className);
            },
            function(){
                Ext.fly(this, '_internal').removeClass(className);
            }
        );
        return this;
    },

    /**
     * Sets up event handlers to add and remove a css class when this element has the focus
     * @param {String} className
     * @return {Ext.Element} this
     */
    addClassOnFocus : function(className){
        this.on("focus", function(){
            Ext.fly(this, '_internal').addClass(className);
        }, this.dom);
        this.on("blur", function(){
            Ext.fly(this, '_internal').removeClass(className);
        }, this.dom);
        return this;
    },
    /**
     * Sets up event handlers to add and remove a css class when the mouse is down and then up on this element (a click effect)
     * @param {String} className
     * @return {Ext.Element} this
     */
    addClassOnClick : function(className){
        var dom = this.dom;
        this.on("mousedown", function(){
            Ext.fly(dom, '_internal').addClass(className);
            var d = Ext.getDoc();
            var fn = function(){
                Ext.fly(dom, '_internal').removeClass(className);
                d.removeListener("mouseup", fn);
            };
            d.on("mouseup", fn);
        });
        return this;
    },

    /**
     * Stops the specified event from bubbling and optionally prevents the default action
     * @param {String} eventName
     * @param {Boolean} preventDefault (optional) true to prevent the default action too
     * @return {Ext.Element} this
     */
    swallowEvent : function(eventName, preventDefault){
        var fn = function(e){
            e.stopPropagation();
            if(preventDefault){
                e.preventDefault();
            }
        };
        if(Ext.isArray(eventName)){
            for(var i = 0, len = eventName.length; i < len; i++){
                 this.on(eventName[i], fn);
            }
            return this;
        }
        this.on(eventName, fn);
        return this;
    },

    /**
     * Gets the parent node for this element, optionally chaining up trying to match a selector
     * @param {String} selector (optional) Find a parent node that matches the passed simple selector
     * @param {Boolean} returnDom (optional) True to return a raw dom node instead of an Ext.Element
     * @return {Ext.Element/HTMLElement} The parent node or null
	 */
    parent : function(selector, returnDom){
        return this.matchNode('parentNode', 'parentNode', selector, returnDom);
    },

     /**
     * Gets the next sibling, skipping text nodes
     * @param {String} selector (optional) Find the next sibling that matches the passed simple selector
     * @param {Boolean} returnDom (optional) True to return a raw dom node instead of an Ext.Element
     * @return {Ext.Element/HTMLElement} The next sibling or null
	 */
    next : function(selector, returnDom){
        return this.matchNode('nextSibling', 'nextSibling', selector, returnDom);
    },

    /**
     * Gets the previous sibling, skipping text nodes
     * @param {String} selector (optional) Find the previous sibling that matches the passed simple selector
     * @param {Boolean} returnDom (optional) True to return a raw dom node instead of an Ext.Element
     * @return {Ext.Element/HTMLElement} The previous sibling or null
	 */
    prev : function(selector, returnDom){
        return this.matchNode('previousSibling', 'previousSibling', selector, returnDom);
    },


    /**
     * Gets the first child, skipping text nodes
     * @param {String} selector (optional) Find the next sibling that matches the passed simple selector
     * @param {Boolean} returnDom (optional) True to return a raw dom node instead of an Ext.Element
     * @return {Ext.Element/HTMLElement} The first child or null
	 */
    first : function(selector, returnDom){
        return this.matchNode('nextSibling', 'firstChild', selector, returnDom);
    },

    /**
     * Gets the last child, skipping text nodes
     * @param {String} selector (optional) Find the previous sibling that matches the passed simple selector
     * @param {Boolean} returnDom (optional) True to return a raw dom node instead of an Ext.Element
     * @return {Ext.Element/HTMLElement} The last child or null
	 */
    last : function(selector, returnDom){
        return this.matchNode('previousSibling', 'lastChild', selector, returnDom);
    },

    matchNode : function(dir, start, selector, returnDom){
        var n = this.dom[start];
        while(n){
            if(n.nodeType == 1 && (!selector || Ext.DomQuery.is(n, selector))){
                return !returnDom ? Ext.get(n) : n;
            }
            n = n[dir];
        }
        return null;
    },

    /**
     * Appends the passed element(s) to this element
     * @param {String/HTMLElement/Array/Element/CompositeElement} el
     * @return {Ext.Element} this
     */
    appendChild: function(el){
        el = Ext.get(el);
        el.appendTo(this);
        return this;
    },

    /**
     * Creates the passed DomHelper config and appends it to this element or optionally inserts it before the passed child element.
     * @param {Object} config DomHelper element config object.  If no tag is specified (e.g., {tag:'input'}) then a div will be
     * automatically generated with the specified attributes.
     * @param {HTMLElement} insertBefore (optional) a child element of this element
     * @param {Boolean} returnDom (optional) true to return the dom node instead of creating an Element
     * @return {Ext.Element} The new child element
     */
    createChild: function(config, insertBefore, returnDom){
        config = config || {tag:'div'};
        if(insertBefore){
            return Ext.DomHelper.insertBefore(insertBefore, config, returnDom !== true);
        }
        return Ext.DomHelper[!this.dom.firstChild ? 'overwrite' : 'append'](this.dom, config,  returnDom !== true);
    },

    /**
     * Appends this element to the passed element
     * @param {Mixed} el The new parent element
     * @return {Ext.Element} this
     */
    appendTo: function(el){
        el = Ext.getDom(el);
        el.appendChild(this.dom);
        return this;
    },

    /**
     * Inserts this element before the passed element in the DOM
     * @param {Mixed} el The element before which this element will be inserted
     * @return {Ext.Element} this
     */
    insertBefore: function(el){
        el = Ext.getDom(el);
        el.parentNode.insertBefore(this.dom, el);
        return this;
    },

    /**
     * Inserts this element after the passed element in the DOM
     * @param {Mixed} el The element to insert after
     * @return {Ext.Element} this
     */
    insertAfter: function(el){
        el = Ext.getDom(el);
        el.parentNode.insertBefore(this.dom, el.nextSibling);
        return this;
    },

    /**
     * Inserts (or creates) an element (or DomHelper config) as the first child of this element
     * @param {Mixed/Object} el The id or element to insert or a DomHelper config to create and insert
     * @return {Ext.Element} The new child
     */
    insertFirst: function(el, returnDom){
        el = el || {};
        if(typeof el == 'object' && !el.nodeType && !el.dom){ // dh config
            return this.createChild(el, this.dom.firstChild, returnDom);
        }else{
            el = Ext.getDom(el);
            this.dom.insertBefore(el, this.dom.firstChild);
            return !returnDom ? Ext.get(el) : el;
        }
    },

    /**
     * Inserts (or creates) the passed element (or DomHelper config) as a sibling of this element
     * @param {Mixed/Object/Array} el The id, element to insert or a DomHelper config to create and insert *or* an array of any of those.
     * @param {String} where (optional) 'before' or 'after' defaults to before
     * @param {Boolean} returnDom (optional) True to return the raw DOM element instead of Ext.Element
     * @return {Ext.Element} the inserted Element
     */
    insertSibling: function(el, where, returnDom){
        var rt;
        if(Ext.isArray(el)){
            for(var i = 0, len = el.length; i < len; i++){
                rt = this.insertSibling(el[i], where, returnDom);
            }
            return rt;
        }
        where = where ? where.toLowerCase() : 'before';
        el = el || {};
        var refNode = where == 'before' ? this.dom : this.dom.nextSibling;

        if(typeof el == 'object' && !el.nodeType && !el.dom){ // dh config
            if(where == 'after' && !this.dom.nextSibling){
                rt = Ext.DomHelper.append(this.dom.parentNode, el, !returnDom);
            }else{
                rt = Ext.DomHelper[where == 'after' ? 'insertAfter' : 'insertBefore'](this.dom, el, !returnDom);
            }

        }else{
            rt = this.dom.parentNode.insertBefore(Ext.getDom(el), refNode);
            if(!returnDom){
                rt = Ext.get(rt);
            }
        }
        return rt;
    },

    /**
     * Creates and wraps this element with another element
     * @param {Object} config (optional) DomHelper element config object for the wrapper element or null for an empty div
     * @param {Boolean} returnDom (optional) True to return the raw DOM element instead of Ext.Element
     * @return {HTMLElement/Element} The newly created wrapper element
     */
    wrap: function(config, returnDom){
        if(!config){
            config = {tag: "div"};
        }
        var newEl = Ext.DomHelper.insertBefore(this.dom, config, !returnDom);
        newEl.dom ? newEl.dom.appendChild(this.dom) : newEl.appendChild(this.dom);
        return newEl;
    },

    /**
     * Replaces the passed element with this element
     * @param {Mixed} el The element to replace
     * @return {Ext.Element} this
     */
    replace: function(el){
        el = Ext.get(el);
        this.insertBefore(el);
        el.remove();
        return this;
    },

    /**
     * Replaces this element with the passed element
     * @param {Mixed/Object} el The new element or a DomHelper config of an element to create
     * @return {Ext.Element} this
     */
    replaceWith: function(el){
        if(typeof el == 'object' && !el.nodeType && !el.dom){ // dh config
            el = this.insertSibling(el, 'before');
        }else{
            el = Ext.getDom(el);
            this.dom.parentNode.insertBefore(el, this.dom);
        }
        El.uncache(this.id);
        this.dom.parentNode.removeChild(this.dom);
        this.dom = el;
        this.id = Ext.id(el);
        El.cache[this.id] = this;
        return this;
    },

    /**
     * Inserts an html fragment into this element
     * @param {String} where Where to insert the html in relation to this element - beforeBegin, afterBegin, beforeEnd, afterEnd.
     * @param {String} html The HTML fragment
     * @param {Boolean} returnEl (optional) True to return an Ext.Element (defaults to false)
     * @return {HTMLElement/Ext.Element} The inserted node (or nearest related if more than 1 inserted)
     */
    insertHtml : function(where, html, returnEl){
        var el = Ext.DomHelper.insertHtml(where, this.dom, html);
        return returnEl ? Ext.get(el) : el;
    },

    /**
     * Sets the passed attributes as attributes of this element (a style attribute can be a string, object or function)
     * @param {Object} o The object with the attributes
     * @param {Boolean} useSet (optional) false to override the default setAttribute to use expandos.
     * @return {Ext.Element} this
     */
    set : function(o, useSet){
        var el = this.dom;
        useSet = typeof useSet == 'undefined' ? (el.setAttribute ? true : false) : useSet;
        for(var attr in o){
            if(attr == "style" || typeof o[attr] == "function") continue;
            if(attr=="cls"){
                el.className = o["cls"];
            }else if(o.hasOwnProperty(attr)){
                if(useSet) el.setAttribute(attr, o[attr]);
                else el[attr] = o[attr];
            }
        }
        if(o.style){
            Ext.DomHelper.applyStyles(el, o.style);
        }
        return this;
    },

    /**
     * Convenience method for constructing a KeyMap
     * @param {Number/Array/Object/String} key Either a string with the keys to listen for, the numeric key code, array of key codes or an object with the following options:
     *                                  {key: (number or array), shift: (true/false), ctrl: (true/false), alt: (true/false)}
     * @param {Function} fn The function to call
     * @param {Object} scope (optional) The scope of the function
     * @return {Ext.KeyMap} The KeyMap created
     */
    addKeyListener : function(key, fn, scope){
        var config;
        if(typeof key != "object" || Ext.isArray(key)){
            config = {
                key: key,
                fn: fn,
                scope: scope
            };
        }else{
            config = {
                key : key.key,
                shift : key.shift,
                ctrl : key.ctrl,
                alt : key.alt,
                fn: fn,
                scope: scope
            };
        }
        return new Ext.KeyMap(this, config);
    },

    /**
     * Creates a KeyMap for this element
     * @param {Object} config The KeyMap config. See {@link Ext.KeyMap} for more details
     * @return {Ext.KeyMap} The KeyMap created
     */
    addKeyMap : function(config){
        return new Ext.KeyMap(this, config);
    },

    /**
     * Returns true if this element is scrollable.
     * @return {Boolean}
     */
     isScrollable : function(){
        var dom = this.dom;
        return dom.scrollHeight > dom.clientHeight || dom.scrollWidth > dom.clientWidth;
    },

    /**
     * Scrolls this element the specified scroll point. It does NOT do bounds checking so if you scroll to a weird value it will try to do it. For auto bounds checking, use scroll().
     * @param {String} side Either "left" for scrollLeft values or "top" for scrollTop values.
     * @param {Number} value The new scroll value
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Element} this
     */
    scrollTo : function(side, value, animate){
        var prop = side.toLowerCase() == "left" ? "scrollLeft" : "scrollTop";
        if(!animate || !A){
            this.dom[prop] = value;
        }else{
            var to = prop == "scrollLeft" ? [value, this.dom.scrollTop] : [this.dom.scrollLeft, value];
            this.anim({scroll: {"to": to}}, this.preanim(arguments, 2), 'scroll');
        }
        return this;
    },

    /**
     * Scrolls this element the specified direction. Does bounds checking to make sure the scroll is
     * within this element's scrollable range.
     * @param {String} direction Possible values are: "l" (or "left"), "r" (or "right"), "t" (or "top", or "up"), "b" (or "bottom", or "down").
     * @param {Number} distance How far to scroll the element in pixels
     * @param {Boolean/Object} animate (optional) true for the default animation or a standard Element animation config object
     * @return {Boolean} Returns true if a scroll was triggered or false if the element
     * was scrolled as far as it could go.
     */
     scroll : function(direction, distance, animate){
         if(!this.isScrollable()){
             return;
         }
         var el = this.dom;
         var l = el.scrollLeft, t = el.scrollTop;
         var w = el.scrollWidth, h = el.scrollHeight;
         var cw = el.clientWidth, ch = el.clientHeight;
         direction = direction.toLowerCase();
         var scrolled = false;
         var a = this.preanim(arguments, 2);
         switch(direction){
             case "l":
             case "left":
                 if(w - l > cw){
                     var v = Math.min(l + distance, w-cw);
                     this.scrollTo("left", v, a);
                     scrolled = true;
                 }
                 break;
            case "r":
            case "right":
                 if(l > 0){
                     var v = Math.max(l - distance, 0);
                     this.scrollTo("left", v, a);
                     scrolled = true;
                 }
                 break;
            case "t":
            case "top":
            case "up":
                 if(t > 0){
                     var v = Math.max(t - distance, 0);
                     this.scrollTo("top", v, a);
                     scrolled = true;
                 }
                 break;
            case "b":
            case "bottom":
            case "down":
                 if(h - t > ch){
                     var v = Math.min(t + distance, h-ch);
                     this.scrollTo("top", v, a);
                     scrolled = true;
                 }
                 break;
         }
         return scrolled;
    },

    /**
     * Translates the passed page coordinates into left/top css values for this element
     * @param {Number/Array} x The page x or an array containing [x, y]
     * @param {Number} y (optional) The page y, required if x is not an array
     * @return {Object} An object with left and top properties. e.g. {left: (value), top: (value)}
     */
    translatePoints : function(x, y){
        if(typeof x == 'object' || Ext.isArray(x)){
            y = x[1]; x = x[0];
        }
        var p = this.getStyle('position');
        var o = this.getXY();

        var l = parseInt(this.getStyle('left'), 10);
        var t = parseInt(this.getStyle('top'), 10);

        if(isNaN(l)){
            l = (p == "relative") ? 0 : this.dom.offsetLeft;
        }
        if(isNaN(t)){
            t = (p == "relative") ? 0 : this.dom.offsetTop;
        }

        return {left: (x - o[0] + l), top: (y - o[1] + t)};
    },

    /**
     * Returns the current scroll position of the element.
     * @return {Object} An object containing the scroll position in the format {left: (scrollLeft), top: (scrollTop)}
     */
    getScroll : function(){
        var d = this.dom, doc = document;
        if(d == doc || d == doc.body){
            var l, t;
            if(Ext.isIE && Ext.isStrict){
                l = doc.documentElement.scrollLeft || (doc.body.scrollLeft || 0);
                t = doc.documentElement.scrollTop || (doc.body.scrollTop || 0);
            }else{
                l = window.pageXOffset || (doc.body.scrollLeft || 0);
                t = window.pageYOffset || (doc.body.scrollTop || 0);
            }
            return {left: l, top: t};
        }else{
            return {left: d.scrollLeft, top: d.scrollTop};
        }
    },

    /**
     * Return the CSS color for the specified CSS attribute. rgb, 3 digit (like #fff) and valid values
     * are convert to standard 6 digit hex color.
     * @param {String} attr The css attribute
     * @param {String} defaultValue The default value to use when a valid color isn't found
     * @param {String} prefix (optional) defaults to #. Use an empty string when working with
     * color anims.
     */
    getColor : function(attr, defaultValue, prefix){
        var v = this.getStyle(attr);
        if(!v || v == "transparent" || v == "inherit") {
            return defaultValue;
        }
        var color = typeof prefix == "undefined" ? "#" : prefix;
        if(v.substr(0, 4) == "rgb("){
            var rvs = v.slice(4, v.length -1).split(",");
            for(var i = 0; i < 3; i++){
                var h = parseInt(rvs[i]);
                var s = h.toString(16);
                if(h < 16){
                    s = "0" + s;
                }
                color += s;
            }
        } else {
            if(v.substr(0, 1) == "#"){
                if(v.length == 4) {
                    for(var i = 1; i < 4; i++){
                        var c = v.charAt(i);
                        color +=  c + c;
                    }
                }else if(v.length == 7){
                    color += v.substr(1);
                }
            }
        }
        return(color.length > 5 ? color.toLowerCase() : defaultValue);
    },

    /**
     * Wraps the specified element with a special markup/CSS block that renders by default as a gray container with a
     * gradient background, rounded corners and a 4-way shadow.  Example usage:
     * <pre><code>
// Basic box wrap
Ext.get("foo").boxWrap();

// You can also add a custom class and use CSS inheritance rules to customize the box look.
// 'x-box-blue' is a built-in alternative -- look at the related CSS definitions as an example
// for how to create a custom box wrap style.
Ext.get("foo").boxWrap().addClass("x-box-blue");
</pre></code>
     * @param {String} class (optional) A base CSS class to apply to the containing wrapper element (defaults to 'x-box').
     * Note that there are a number of CSS rules that are dependent on this name to make the overall effect work,
     * so if you supply an alternate base class, make sure you also supply all of the necessary rules.
     * @return {Ext.Element} this
     */
    boxWrap : function(cls){
        cls = cls || 'x-box';
        var el = Ext.get(this.insertHtml('beforeBegin', String.format('<div class="{0}">'+El.boxMarkup+'</div>', cls)));
        el.child('.'+cls+'-mc').dom.appendChild(this.dom);
        return el;
    },

    /**
     * Returns the value of a namespaced attribute from the element's underlying DOM node.
     * @param {String} namespace The namespace in which to look for the attribute
     * @param {String} name The attribute name
     * @return {String} The attribute value
     */
    getAttributeNS : Ext.isIE ? function(ns, name){
        var d = this.dom;
        var type = typeof d[ns+":"+name];
        if(type != 'undefined' && type != 'unknown'){
            return d[ns+":"+name];
        }
        return d[name];
    } : function(ns, name){
        var d = this.dom;
        return d.getAttributeNS(ns, name) || d.getAttribute(ns+":"+name) || d.getAttribute(name) || d[name];
    },

    /**
     * Returns the width in pixels of the passed text, or the width of the text in this Element.
     * @param {String} text The text to measure. Defaults to the innerHTML of the element.
     * @param {Number} min (Optional) The minumum value to return.
     * @param {Number} max (Optional) The maximum value to return.
     * @return {Number} The text width in pixels.
     */
    getTextWidth : function(text, min, max){
        return (Ext.util.TextMetrics.measure(this.dom, Ext.value(text, this.dom.innerHTML, true)).width).constrain(min || 0, max || 1000000);
    }
};

var ep = El.prototype;

/**
 * Appends an event handler (shorthand for {@link #addListener}).
 * @param {String} eventName The type of event to handle
 * @param {Function} fn The handler function the event invokes
 * @param {Object} scope (optional) The scope (this element) of the handler function
 * @param {Object} options (optional) An object containing standard {@link #addListener} options
 * @member Ext.Element
 * @method on
 */
ep.on = ep.addListener;
    // backwards compat
ep.mon = ep.addListener;

ep.getUpdateManager = ep.getUpdater;

/**
 * Removes an event handler from this element (shorthand for {@link #removeListener}).
 * @param {String} eventName the type of event to remove
 * @param {Function} fn the method the event invokes
 * @return {Ext.Element} this
 * @member Ext.Element
 * @method un
 */
ep.un = ep.removeListener;

/**
 * true to automatically adjust width and height settings for box-model issues (default to true)
 */
ep.autoBoxAdjust = true;

// private
El.unitPattern = /\d+(px|em|%|en|ex|pt|in|cm|mm|pc)$/i;

// private
El.addUnits = function(v, defaultUnit){
    if(v === "" || v == "auto"){
        return v;
    }
    if(v === undefined){
        return '';
    }
    if(typeof v == "number" || !El.unitPattern.test(v)){
        return v + (defaultUnit || 'px');
    }
    return v;
};

// special markup used throughout Ext when box wrapping elements
El.boxMarkup = '<div class="{0}-tl"><div class="{0}-tr"><div class="{0}-tc"></div></div></div><div class="{0}-ml"><div class="{0}-mr"><div class="{0}-mc"></div></div></div><div class="{0}-bl"><div class="{0}-br"><div class="{0}-bc"></div></div></div>';
/**
 * Visibility mode constant - Use visibility to hide element
 * @static
 * @type Number
 */
El.VISIBILITY = 1;
/**
 * Visibility mode constant - Use display to hide element
 * @static
 * @type Number
 */
El.DISPLAY = 2;

El.borders = {l: "border-left-width", r: "border-right-width", t: "border-top-width", b: "border-bottom-width"};
El.paddings = {l: "padding-left", r: "padding-right", t: "padding-top", b: "padding-bottom"};
El.margins = {l: "margin-left", r: "margin-right", t: "margin-top", b: "margin-bottom"};



/**
 * @private
 */
El.cache = {};

var docEl;

/**
 * Static method to retrieve Ext.Element objects.
 * <p><b>This method does not retrieve {@link Ext.Component Component}s.</b> This method
 * retrieves Ext.Element objects which encapsulate DOM elements. To retrieve a Component by
 * its ID, use {@link Ext.ComponentMgr#get}.</p>
 * <p>Uses simple caching to consistently return the same object.
 * Automatically fixes if an object was recreated with the same id via AJAX or DOM.</p>
 * @param {Mixed} el The id of the node, a DOM Node or an existing Element.
 * @return {Element} The {@link Ext.Element Element} object (or null if no matching element was found)
 * @static
 */
El.get = function(el){
    var ex, elm, id;
    if(!el){ return null; }
    if(typeof el == "string"){ // element id
        if(!(elm = document.getElementById(el))){
            return null;
        }
        if(ex = El.cache[el]){
            ex.dom = elm;
        }else{
            ex = El.cache[el] = new El(elm);
        }
        return ex;
    }else if(el.tagName){ // dom element
        if(!(id = el.id)){
            id = Ext.id(el);
        }
        if(ex = El.cache[id]){
            ex.dom = el;
        }else{
            ex = El.cache[id] = new El(el);
        }
        return ex;
    }else if(el instanceof El){
        if(el != docEl){
            el.dom = document.getElementById(el.id) || el.dom; // refresh dom element in case no longer valid,
                                                          // catch case where it hasn't been appended
            El.cache[el.id] = el; // in case it was created directly with Element(), let's cache it
        }
        return el;
    }else if(el.isComposite){
        return el;
    }else if(Ext.isArray(el)){
        return El.select(el);
    }else if(el == document){
        // create a bogus element object representing the document object
        if(!docEl){
            var f = function(){};
            f.prototype = El.prototype;
            docEl = new f();
            docEl.dom = document;
        }
        return docEl;
    }
    return null;
};

// private
El.uncache = function(el){
    for(var i = 0, a = arguments, len = a.length; i < len; i++) {
        if(a[i]){
            delete El.cache[a[i].id || a[i]];
        }
    }
};

// private
// Garbage collection - uncache elements/purge listeners on orphaned elements
// so we don't hold a reference and cause the browser to retain them
El.garbageCollect = function(){
    if(!Ext.enableGarbageCollector){
        clearInterval(El.collectorThread);
        return;
    }
    for(var eid in El.cache){
        var el = El.cache[eid], d = el.dom;
        // -------------------------------------------------------
        // Determining what is garbage:
        // -------------------------------------------------------
        // !d
        // dom node is null, definitely garbage
        // -------------------------------------------------------
        // !d.parentNode
        // no parentNode == direct orphan, definitely garbage
        // -------------------------------------------------------
        // !d.offsetParent && !document.getElementById(eid)
        // display none elements have no offsetParent so we will
        // also try to look it up by it's id. However, check
        // offsetParent first so we don't do unneeded lookups.
        // This enables collection of elements that are not orphans
        // directly, but somewhere up the line they have an orphan
        // parent.
        // -------------------------------------------------------
        if(!d || !d.parentNode || (!d.offsetParent && !document.getElementById(eid))){
            delete El.cache[eid];
            if(d && Ext.enableListenerCollection){
                Ext.EventManager.removeAll(d);
            }
        }
    }
}
El.collectorThreadId = setInterval(El.garbageCollect, 30000);

var flyFn = function(){};
flyFn.prototype = El.prototype;
var _cls = new flyFn();

// dom is optional
El.Flyweight = function(dom){
    this.dom = dom;
};

El.Flyweight.prototype = _cls;
El.Flyweight.prototype.isFlyweight = true;

El._flyweights = {};
/**
 * Gets the globally shared flyweight Element, with the passed node as the active element. Do not store a reference to this element -
 * the dom node can be overwritten by other code.
 * @param {String/HTMLElement} el The dom node or id
 * @param {String} named (optional) Allows for creation of named reusable flyweights to
 *                                  prevent conflicts (e.g. internally Ext uses "_internal")
 * @static
 * @return {Element} The shared Element object (or null if no matching element was found)
 */
El.fly = function(el, named){
    named = named || '_global';
    el = Ext.getDom(el);
    if(!el){
        return null;
    }
    if(!El._flyweights[named]){
        El._flyweights[named] = new El.Flyweight();
    }
    El._flyweights[named].dom = el;
    return El._flyweights[named];
};

/**
 * Static method to retrieve Element objects. Uses simple caching to consistently return the same object.
 * Automatically fixes if an object was recreated with the same id via AJAX or DOM.
 * Shorthand of {@link Ext.Element#get}
 * @param {Mixed} el The id of the node, a DOM Node or an existing Element.
 * @return {Element} The Element object
 * @member Ext
 * @method get
 */
Ext.get = El.get;
/**
 * Gets the globally shared flyweight Element, with the passed node as the active element. Do not store a reference to this element -
 * the dom node can be overwritten by other code.
 * Shorthand of {@link Ext.Element#fly}
 * @param {String/HTMLElement} el The dom node or id
 * @param {String} named (optional) Allows for creation of named reusable flyweights to
 *                                  prevent conflicts (e.g. internally Ext uses "_internal")
 * @static
 * @return {Element} The shared Element object
 * @member Ext
 * @method fly
 */
Ext.fly = El.fly;

// speedy lookup for elements never to box adjust
var noBoxAdjust = Ext.isStrict ? {
    select:1
} : {
    input:1, select:1, textarea:1
};
if(Ext.isIE || Ext.isGecko){
    noBoxAdjust['button'] = 1;
}


Ext.EventManager.on(window, 'unload', function(){
    delete El.cache;
    delete El._flyweights;
});
})();
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.CompositeElement
 * Standard composite class. Creates a Ext.Element for every element in the collection.
 * <br><br>
 * <b>NOTE: Although they are not listed, this class supports all of the set/update methods of Ext.Element. All Ext.Element
 * actions will be performed on all the elements in this collection.</b>
 * <br><br>
 * All methods return <i>this</i> and can be chained.
 <pre><code>
 var els = Ext.select("#some-el div.some-class", true);
 // or select directly from an existing element
 var el = Ext.get('some-el');
 el.select('div.some-class', true);

 els.setWidth(100); // all elements become 100 width
 els.hide(true); // all elements fade out and hide
 // or
 els.setWidth(100).hide(true);
 </code></pre>
 */
Ext.CompositeElement = function(els){
    this.elements = [];
    this.addElements(els);
};
Ext.CompositeElement.prototype = {
    isComposite: true,
    addElements : function(els){
        if(!els) return this;
        if(typeof els == "string"){
            els = Ext.Element.selectorFunction(els);
        }
        var yels = this.elements;
        var index = yels.length-1;
        for(var i = 0, len = els.length; i < len; i++) {
        	yels[++index] = Ext.get(els[i]);
        }
        return this;
    },

    /**
    * Clears this composite and adds the elements returned by the passed selector.
    * @param {String/Array} els A string CSS selector, an array of elements or an element
    * @return {CompositeElement} this
    */
    fill : function(els){
        this.elements = [];
        this.add(els);
        return this;
    },

    /**
    * Filters this composite to only elements that match the passed selector.
    * @param {String} selector A string CSS selector
    * @return {CompositeElement} this
    */
    filter : function(selector){
        var els = [];
        this.each(function(el){
            if(el.is(selector)){
                els[els.length] = el.dom;
            }
        });
        this.fill(els);
        return this;
    },

    invoke : function(fn, args){
        var els = this.elements;
        for(var i = 0, len = els.length; i < len; i++) {
        	Ext.Element.prototype[fn].apply(els[i], args);
        }
        return this;
    },
    /**
    * Adds elements to this composite.
    * @param {String/Array} els A string CSS selector, an array of elements or an element
    * @return {CompositeElement} this
    */
    add : function(els){
        if(typeof els == "string"){
            this.addElements(Ext.Element.selectorFunction(els));
        }else if(els.length !== undefined){
            this.addElements(els);
        }else{
            this.addElements([els]);
        }
        return this;
    },
    /**
    * Calls the passed function passing (el, this, index) for each element in this composite.
    * @param {Function} fn The function to call
    * @param {Object} scope (optional) The <i>this</i> object (defaults to the element)
    * @return {CompositeElement} this
    */
    each : function(fn, scope){
        var els = this.elements;
        for(var i = 0, len = els.length; i < len; i++){
            if(fn.call(scope || els[i], els[i], this, i) === false) {
                break;
            }
        }
        return this;
    },

    /**
     * Returns the Element object at the specified index
     * @param {Number} index
     * @return {Ext.Element}
     */
    item : function(index){
        return this.elements[index] || null;
    },

    /**
     * Returns the first Element
     * @return {Ext.Element}
     */
    first : function(){
        return this.item(0);
    },

    /**
     * Returns the last Element
     * @return {Ext.Element}
     */
    last : function(){
        return this.item(this.elements.length-1);
    },

    /**
     * Returns the number of elements in this composite
     * @return Number
     */
    getCount : function(){
        return this.elements.length;
    },

    /**
     * Returns true if this composite contains the passed element
     * @param el {Mixed} The id of an element, or an Ext.Element, or an HtmlElement to find within the composite collection.
     * @return Boolean
     */
    contains : function(el){
        return this.indexOf(el) !== -1;
    },

    /**
     * Find the index of the passed element within the composite collection.
     * @param el {Mixed} The id of an element, or an Ext.Element, or an HtmlElement to find within the composite collection.
     * @return Number The index of the passed Ext.Element in the composite collection, or -1 if not found.
     */
    indexOf : function(el){
        return this.elements.indexOf(Ext.get(el));
    },


    /**
    * Removes the specified element(s).
    * @param {Mixed} el The id of an element, the Element itself, the index of the element in this composite
    * or an array of any of those.
    * @param {Boolean} removeDom (optional) True to also remove the element from the document
    * @return {CompositeElement} this
    */
    removeElement : function(el, removeDom){
        if(Ext.isArray(el)){
            for(var i = 0, len = el.length; i < len; i++){
                this.removeElement(el[i]);
            }
            return this;
        }
        var index = typeof el == 'number' ? el : this.indexOf(el);
        if(index !== -1 && this.elements[index]){
            if(removeDom){
                var d = this.elements[index];
                if(d.dom){
                    d.remove();
                }else{
                    Ext.removeNode(d);
                }
            }
            this.elements.splice(index, 1);
        }
        return this;
    },

    /**
    * Replaces the specified element with the passed element.
    * @param {Mixed} el The id of an element, the Element itself, the index of the element in this composite
    * to replace.
    * @param {Mixed} replacement The id of an element or the Element itself.
    * @param {Boolean} domReplace (Optional) True to remove and replace the element in the document too.
    * @return {CompositeElement} this
    */
    replaceElement : function(el, replacement, domReplace){
        var index = typeof el == 'number' ? el : this.indexOf(el);
        if(index !== -1){
            if(domReplace){
                this.elements[index].replaceWith(replacement);
            }else{
                this.elements.splice(index, 1, Ext.get(replacement))
            }
        }
        return this;
    },

    /**
     * Removes all elements.
     */
    clear : function(){
        this.elements = [];
    }
};
(function(){
Ext.CompositeElement.createCall = function(proto, fnName){
    if(!proto[fnName]){
        proto[fnName] = function(){
            return this.invoke(fnName, arguments);
        };
    }
};
for(var fnName in Ext.Element.prototype){
    if(typeof Ext.Element.prototype[fnName] == "function"){
        Ext.CompositeElement.createCall(Ext.CompositeElement.prototype, fnName);
    }
};
})();

/**
 * @class Ext.CompositeElementLite
 * @extends Ext.CompositeElement
 * Flyweight composite class. Reuses the same Ext.Element for element operations.
 <pre><code>
 var els = Ext.select("#some-el div.some-class");
 // or select directly from an existing element
 var el = Ext.get('some-el');
 el.select('div.some-class');

 els.setWidth(100); // all elements become 100 width
 els.hide(true); // all elements fade out and hide
 // or
 els.setWidth(100).hide(true);
 </code></pre><br><br>
 * <b>NOTE: Although they are not listed, this class supports all of the set/update methods of Ext.Element. All Ext.Element
 * actions will be performed on all the elements in this collection.</b>
 */
Ext.CompositeElementLite = function(els){
    Ext.CompositeElementLite.superclass.constructor.call(this, els);
    this.el = new Ext.Element.Flyweight();
};
Ext.extend(Ext.CompositeElementLite, Ext.CompositeElement, {
    addElements : function(els){
        if(els){
            if(Ext.isArray(els)){
                this.elements = this.elements.concat(els);
            }else{
                var yels = this.elements;
                var index = yels.length-1;
                for(var i = 0, len = els.length; i < len; i++) {
                    yels[++index] = els[i];
                }
            }
        }
        return this;
    },
    invoke : function(fn, args){
        var els = this.elements;
        var el = this.el;
        for(var i = 0, len = els.length; i < len; i++) {
            el.dom = els[i];
        	Ext.Element.prototype[fn].apply(el, args);
        }
        return this;
    },
    /**
     * Returns a flyweight Element of the dom element object at the specified index
     * @param {Number} index
     * @return {Ext.Element}
     */
    item : function(index){
        if(!this.elements[index]){
            return null;
        }
        this.el.dom = this.elements[index];
        return this.el;
    },

    // fixes scope with flyweight
    addListener : function(eventName, handler, scope, opt){
        var els = this.elements;
        for(var i = 0, len = els.length; i < len; i++) {
            Ext.EventManager.on(els[i], eventName, handler, scope || els[i], opt);
        }
        return this;
    },

    /**
    * Calls the passed function passing (el, this, index) for each element in this composite. <b>The element
    * passed is the flyweight (shared) Ext.Element instance, so if you require a
    * a reference to the dom node, use el.dom.</b>
    * @param {Function} fn The function to call
    * @param {Object} scope (optional) The <i>this</i> object (defaults to the element)
    * @return {CompositeElement} this
    */
    each : function(fn, scope){
        var els = this.elements;
        var el = this.el;
        for(var i = 0, len = els.length; i < len; i++){
            el.dom = els[i];
        	if(fn.call(scope || el, el, this, i) === false){
                break;
            }
        }
        return this;
    },

    indexOf : function(el){
        return this.elements.indexOf(Ext.getDom(el));
    },

    replaceElement : function(el, replacement, domReplace){
        var index = typeof el == 'number' ? el : this.indexOf(el);
        if(index !== -1){
            replacement = Ext.getDom(replacement);
            if(domReplace){
                var d = this.elements[index];
                d.parentNode.insertBefore(replacement, d);
                Ext.removeNode(d);
            }
            this.elements.splice(index, 1, replacement);
        }
        return this;
    }
});
Ext.CompositeElementLite.prototype.on = Ext.CompositeElementLite.prototype.addListener;
if(Ext.DomQuery){
    Ext.Element.selectorFunction = Ext.DomQuery.select;
}

Ext.Element.select = function(selector, unique, root){
    var els;
    if(typeof selector == "string"){
        els = Ext.Element.selectorFunction(selector, root);
    }else if(selector.length !== undefined){
        els = selector;
    }else{
        throw "Invalid selector";
    }
    if(unique === true){
        return new Ext.CompositeElement(els);
    }else{
        return new Ext.CompositeElementLite(els);
    }
};
/**
 * Selects elements based on the passed CSS selector to enable working on them as 1.
 * @param {String/Array} selector The CSS selector or an array of elements
 * @param {Boolean} unique (optional) true to create a unique Ext.Element for each element (defaults to a shared flyweight object)
 * @param {HTMLElement/String} root (optional) The root element of the query or id of the root
 * @return {CompositeElementLite/CompositeElement}
 * @member Ext
 * @method select
 */
Ext.select = Ext.Element.select;
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.Updater
 * @extends Ext.util.Observable
 * Provides AJAX-style update capabilities for Element objects.  Updater can be used to {@link #update} an Element once,
 * or you can use {@link #startAutoRefresh} to set up an auto-updating Element on a specific interval.<br><br>
 * Usage:<br>
 * <pre><code>
 * // Get it from a Ext.Element object
 * var el = Ext.get("foo");
 * var mgr = el.getUpdater();
 * mgr.update({
        url: "http://myserver.com/index.php",
        params: {
            param1: "foo",
            param2: "bar"
        }
 * });
 * ...
 * mgr.formUpdate("myFormId", "http://myserver.com/index.php");
 * <br>
 * // or directly (returns the same Updater instance)
 * var mgr = new Ext.Updater("myElementId");
 * mgr.startAutoRefresh(60, "http://myserver.com/index.php");
 * mgr.on("update", myFcnNeedsToKnow);
 * <br>
 * // short handed call directly from the element object
 * Ext.get("foo").load({
        url: "bar.php",
        scripts: true,
        params: "param1=foo&amp;param2=bar",
        text: "Loading Foo..."
 * });
 * </code></pre>
 * @constructor
 * Create new Updater directly.
 * @param {Mixed} el The element to update
 * @param {Boolean} forceNew (optional) By default the constructor checks to see if the passed element already
 * has an Updater and if it does it returns the same instance. This will skip that check (useful for extending this class).
 */
Ext.Updater = Ext.extend(Ext.util.Observable, {
    constructor: function(el, forceNew){
        el = Ext.get(el);
        if(!forceNew && el.updateManager){
            return el.updateManager;
        }
        /**
         * The Element object
         * @type Ext.Element
         */
        this.el = el;
        /**
         * Cached url to use for refreshes. Overwritten every time update() is called unless "discardUrl" param is set to true.
         * @type String
         */
        this.defaultUrl = null;

        this.addEvents(
            /**
             * @event beforeupdate
             * Fired before an update is made, return false from your handler and the update is cancelled.
             * @param {Ext.Element} el
             * @param {String/Object/Function} url
             * @param {String/Object} params
             */
            "beforeupdate",
            /**
             * @event update
             * Fired after successful update is made.
             * @param {Ext.Element} el
             * @param {Object} oResponseObject The response Object
             */
            "update",
            /**
             * @event failure
             * Fired on update failure.
             * @param {Ext.Element} el
             * @param {Object} oResponseObject The response Object
             */
            "failure"
        );
        var d = Ext.Updater.defaults;
        /**
         * Blank page URL to use with SSL file uploads (defaults to {@link Ext.Updater.defaults#sslBlankUrl}).
         * @type String
         */
        this.sslBlankUrl = d.sslBlankUrl;
        /**
         * Whether to append unique parameter on get request to disable caching (defaults to {@link Ext.Updater.defaults#disableCaching}).
         * @type Boolean
         */
        this.disableCaching = d.disableCaching;
        /**
         * Text for loading indicator (defaults to {@link Ext.Updater.defaults#indicatorText}).
         * @type String
         */
        this.indicatorText = d.indicatorText;
        /**
         * Whether to show indicatorText when loading (defaults to {@link Ext.Updater.defaults#showLoadIndicator}).
         * @type String
         */
        this.showLoadIndicator = d.showLoadIndicator;
        /**
         * Timeout for requests or form posts in seconds (defaults to {@link Ext.Updater.defaults#timeout}).
         * @type Number
         */
        this.timeout = d.timeout;
        /**
         * True to process scripts in the output (defaults to {@link Ext.Updater.defaults#loadScripts}).
         * @type Boolean
         */
        this.loadScripts = d.loadScripts;
        /**
         * Transaction object of the current executing transaction, or null if there is no active transaction.
         */
        this.transaction = null;
        /**
         * Delegate for refresh() prebound to "this", use myUpdater.refreshDelegate.createCallback(arg1, arg2) to bind arguments
         * @type Function
         */
        this.refreshDelegate = this.refresh.createDelegate(this);
        /**
         * Delegate for update() prebound to "this", use myUpdater.updateDelegate.createCallback(arg1, arg2) to bind arguments
         * @type Function
         */
        this.updateDelegate = this.update.createDelegate(this);
        /**
         * Delegate for formUpdate() prebound to "this", use myUpdater.formUpdateDelegate.createCallback(arg1, arg2) to bind arguments
         * @type Function
         */
        this.formUpdateDelegate = this.formUpdate.createDelegate(this);

        if(!this.renderer){
         /**
          * The renderer for this Updater (defaults to {@link Ext.Updater.BasicRenderer}).
          */
        this.renderer = this.getDefaultRenderer();
        }
        Ext.Updater.superclass.constructor.call(this);
    },
    /**
     * This is an overrideable method which returns a reference to a default
     * renderer class if none is specified when creating the Ext.Updater.
     * Defaults to {@link Ext.Updater.BasicRenderer}
     */
    getDefaultRenderer: function() {
        return new Ext.Updater.BasicRenderer();
    },
    /**
     * Get the Element this Updater is bound to
     * @return {Ext.Element} The element
     */
    getEl : function(){
        return this.el;
    },

    /**
     * Performs an <b>asynchronous</b> request, updating this element with the response.
     * If params are specified it uses POST, otherwise it uses GET.<br><br>
     * <b>Note:</b> Due to the asynchronous nature of remote server requests, the Element
     * will not have been fully updated when the function returns. To post-process the returned
     * data, use the callback option, or an <b><tt>update</tt></b> event handler.
     * @param {Object} options A config object containing any of the following options:<ul>
     * <li>url : <b>String/Function</b><p class="sub-desc">The URL to request or a function which
     * <i>returns</i> the URL (defaults to the value of {@link Ext.Ajax#url} if not specified).</p></li>
     * <li>method : <b>String</b><p class="sub-desc">The HTTP method to
     * use. Defaults to POST if the <tt>params</tt> argument is present, otherwise GET.</p></li>
     * <li>params : <b>String/Object/Function</b><p class="sub-desc">The
     * parameters to pass to the server (defaults to none). These may be specified as a url-encoded
     * string, or as an object containing properties which represent parameters,
     * or as a function, which returns such an object.</p></li>
     * <li>scripts : <b>Boolean</b><p class="sub-desc">If <tt>true</tt>
     * any &lt;script&gt; tags embedded in the response text will be extracted
     * and executed (defaults to {@link Ext.Updater.defaults#loadScripts}). If this option is specified,
     * the callback will be called <i>after</i> the execution of the scripts.</p></li>
     * <li>callback : <b>Function</b><p class="sub-desc">A function to
     * be called when the response from the server arrives. The following
     * parameters are passed:<ul>
     * <li><b>el</b> : Ext.Element<p class="sub-desc">The Element being updated.</p></li>
     * <li><b>success</b> : Boolean<p class="sub-desc">True for success, false for failure.</p></li>
     * <li><b>response</b> : XMLHttpRequest<p class="sub-desc">The XMLHttpRequest which processed the update.</p></li>
     * <li><b>options</b> : Object<p class="sub-desc">The config object passed to the update call.</p></li></ul>
     * </p></li>
     * <li>scope : <b>Object</b><p class="sub-desc">The scope in which
     * to execute the callback (The callback's <tt>this</tt> reference.) If the
     * <tt>params</tt> argument is a function, this scope is used for that function also.</p></li>
     * <li>discardUrl : <b>Boolean</b><p class="sub-desc">By default, the URL of this request becomes
     * the default URL for this Updater object, and will be subsequently used in {@link #refresh}
     * calls.  To bypass this behavior, pass <tt>discardUrl:true</tt> (defaults to false).</p></li>
     * <li>timeout : <b>Number</b><p class="sub-desc">The number of seconds to wait for a response before
     * timing out (defaults to {@link Ext.Updater.defaults#timeout}).</p></li>
     * <li>text : <b>String</b><p class="sub-desc">The text to use as the innerHTML of the
     * {@link Ext.Updater.defaults#indicatorText} div (defaults to 'Loading...').  To replace the entire div, not
     * just the text, override {@link Ext.Updater.defaults#indicatorText} directly.</p></li>
     * <li>nocache : <b>Boolean</b><p class="sub-desc">Only needed for GET
     * requests, this option causes an extra, auto-generated parameter to be appended to the request
     * to defeat caching (defaults to {@link Ext.Updater.defaults#disableCaching}).</p></li></ul>
     * <p>
     * For example:
<pre><code>
um.update({
    url: "your-url.php",
    params: {param1: "foo", param2: "bar"}, // or a URL encoded string
    callback: yourFunction,
    scope: yourObject, //(optional scope)
    discardUrl: true,
    nocache: true,
    text: "Loading...",
    timeout: 60,
    scripts: false // Save time by avoiding RegExp execution.
});
</code></pre>
     */
    update : function(url, params, callback, discardUrl){
        if(this.fireEvent("beforeupdate", this.el, url, params) !== false){
            var cfg, callerScope;
            if(typeof url == "object"){ // must be config object
                cfg = url;
                url = cfg.url;
                params = params || cfg.params;
                callback = callback || cfg.callback;
                discardUrl = discardUrl || cfg.discardUrl;
                callerScope = cfg.scope;
                if(typeof cfg.nocache != "undefined"){this.disableCaching = cfg.nocache;};
                if(typeof cfg.text != "undefined"){this.indicatorText = '<div class="loading-indicator">'+cfg.text+"</div>";};
                if(typeof cfg.scripts != "undefined"){this.loadScripts = cfg.scripts;};
                if(typeof cfg.timeout != "undefined"){this.timeout = cfg.timeout;};
            }
            this.showLoading();

            if(!discardUrl){
                this.defaultUrl = url;
            }
            if(typeof url == "function"){
                url = url.call(this);
            }

            var o = Ext.apply({}, {
                url : url,
                params: (typeof params == "function" && callerScope) ? params.createDelegate(callerScope) : params,
                success: this.processSuccess,
                failure: this.processFailure,
                scope: this,
                callback: undefined,
                timeout: (this.timeout*1000),
                disableCaching: this.disableCaching,
                argument: {
                    "options": cfg,
                    "url": url,
                    "form": null,
                    "callback": callback,
                    "scope": callerScope || window,
                    "params": params
                }
            }, cfg);

            this.transaction = Ext.Ajax.request(o);
        }
    },

    /**
     * Performs an async form post, updating this element with the response. If the form has the attribute
     * enctype="multipart/form-data", it assumes it's a file upload.
     * Uses this.sslBlankUrl for SSL file uploads to prevent IE security warning.
     * @param {String/HTMLElement} form The form Id or form element
     * @param {String} url (optional) The url to pass the form to. If omitted the action attribute on the form will be used.
     * @param {Boolean} reset (optional) Whether to try to reset the form after the update
     * @param {Function} callback (optional) Callback when transaction is complete. The following
     * parameters are passed:<ul>
     * <li><b>el</b> : Ext.Element<p class="sub-desc">The Element being updated.</p></li>
     * <li><b>success</b> : Boolean<p class="sub-desc">True for success, false for failure.</p></li>
     * <li><b>response</b> : XMLHttpRequest<p class="sub-desc">The XMLHttpRequest which processed the update.</p></li></ul>
     */
    formUpdate : function(form, url, reset, callback){
        if(this.fireEvent("beforeupdate", this.el, form, url) !== false){
            if(typeof url == "function"){
                url = url.call(this);
            }
            form = Ext.getDom(form)
            this.transaction = Ext.Ajax.request({
                form: form,
                url:url,
                success: this.processSuccess,
                failure: this.processFailure,
                scope: this,
                timeout: (this.timeout*1000),
                argument: {
                    "url": url,
                    "form": form,
                    "callback": callback,
                    "reset": reset
                }
            });
            this.showLoading.defer(1, this);
        }
    },

    /**
     * Refresh the element with the last used url or defaultUrl. If there is no url, it returns immediately
     * @param {Function} callback (optional) Callback when transaction is complete - called with signature (oElement, bSuccess)
     */
    refresh : function(callback){
        if(this.defaultUrl == null){
            return;
        }
        this.update(this.defaultUrl, null, callback, true);
    },

    /**
     * Set this element to auto refresh.  Can be canceled by calling {@link #stopAutoRefresh}.
     * @param {Number} interval How often to update (in seconds).
     * @param {String/Object/Function} url (optional) The url for this request, a config object in the same format
     * supported by {@link #load}, or a function to call to get the url (defaults to the last used url).  Note that while
     * the url used in a load call can be reused by this method, other load config options will not be reused and must be
     * sepcified as part of a config object passed as this paramter if needed.
     * @param {String/Object} params (optional) The parameters to pass as either a url encoded string
     * "&param1=1&param2=2" or as an object {param1: 1, param2: 2}
     * @param {Function} callback (optional) Callback when transaction is complete - called with signature (oElement, bSuccess)
     * @param {Boolean} refreshNow (optional) Whether to execute the refresh now, or wait the interval
     */
    startAutoRefresh : function(interval, url, params, callback, refreshNow){
        if(refreshNow){
            this.update(url || this.defaultUrl, params, callback, true);
        }
        if(this.autoRefreshProcId){
            clearInterval(this.autoRefreshProcId);
        }
        this.autoRefreshProcId = setInterval(this.update.createDelegate(this, [url || this.defaultUrl, params, callback, true]), interval*1000);
    },

    /**
     * Stop auto refresh on this element.
     */
     stopAutoRefresh : function(){
        if(this.autoRefreshProcId){
            clearInterval(this.autoRefreshProcId);
            delete this.autoRefreshProcId;
        }
    },

    /**
     * Returns true if the Updater is currently set to auto refresh its content (see {@link #startAutoRefresh}), otherwise false.
     */
    isAutoRefreshing : function(){
       return this.autoRefreshProcId ? true : false;
    },

    /**
     * Display the element's "loading" state. By default, the element is updated with {@link #indicatorText}. This
     * method may be overridden to perform a custom action while this Updater is actively updating its contents.
     */
    showLoading : function(){
        if(this.showLoadIndicator){
            this.el.update(this.indicatorText);
        }
    },

    // private
    processSuccess : function(response){
        this.transaction = null;
        if(response.argument.form && response.argument.reset){
            try{ // put in try/catch since some older FF releases had problems with this
                response.argument.form.reset();
            }catch(e){}
        }
        if(this.loadScripts){
            this.renderer.render(this.el, response, this,
                this.updateComplete.createDelegate(this, [response]));
        }else{
            this.renderer.render(this.el, response, this);
            this.updateComplete(response);
        }
    },

    // private
    updateComplete : function(response){
        this.fireEvent("update", this.el, response);
        if(typeof response.argument.callback == "function"){
            response.argument.callback.call(response.argument.scope, this.el, true, response, response.argument.options);
        }
    },

    // private
    processFailure : function(response){
        this.transaction = null;
        this.fireEvent("failure", this.el, response);
        if(typeof response.argument.callback == "function"){
            response.argument.callback.call(response.argument.scope, this.el, false, response, response.argument.options);
        }
    },

    /**
     * Sets the content renderer for this Updater. See {@link Ext.Updater.BasicRenderer#render} for more details.
     * @param {Object} renderer The object implementing the render() method
     */
    setRenderer : function(renderer){
        this.renderer = renderer;
    },

    /**
     * Returns the content renderer for this Updater. See {@link Ext.Updater.BasicRenderer#render} for more details.
     * @return {Object}
     */
    getRenderer : function(){
       return this.renderer;
    },

    /**
     * Sets the default URL used for updates.
     * @param {String/Function} defaultUrl The url or a function to call to get the url
     */
    setDefaultUrl : function(defaultUrl){
        this.defaultUrl = defaultUrl;
    },

    /**
     * Aborts the currently executing transaction, if any.
     */
    abort : function(){
        if(this.transaction){
            Ext.Ajax.abort(this.transaction);
        }
    },

    /**
     * Returns true if an update is in progress, otherwise false.
     * @return {Boolean}
     */
    isUpdating : function(){
        if(this.transaction){
            return Ext.Ajax.isLoading(this.transaction);
        }
        return false;
    }
});

/**
 * @class Ext.Updater.defaults
 * The defaults collection enables customizing the default properties of Updater
 */
   Ext.Updater.defaults = {
       /**
         * Timeout for requests or form posts in seconds (defaults to 30 seconds).
         * @type Number
         */
         timeout : 30,
         /**
         * True to process scripts by default (defaults to false).
         * @type Boolean
         */
        loadScripts : false,
        /**
        * Blank page URL to use with SSL file uploads (defaults to {@link Ext#SSL_SECURE_URL} if set, or "javascript:false").
        * @type String
        */
        sslBlankUrl : (Ext.SSL_SECURE_URL || "javascript:false"),
        /**
         * True to append a unique parameter to GET requests to disable caching (defaults to false).
         * @type Boolean
         */
        disableCaching : false,
        /**
         * Whether or not to show {@link #indicatorText} during loading (defaults to true).
         * @type Boolean
         */
        showLoadIndicator : true,
        /**
         * Text for loading indicator (defaults to '&lt;div class="loading-indicator"&gt;Loading...&lt;/div&gt;').
         * @type String
         */
        indicatorText : '<div class="loading-indicator">Loading...</div>'
   };

/**
 * Static convenience method. <b>This method is deprecated in favor of el.load({url:'foo.php', ...})</b>.
 * Usage:
 * <pre><code>Ext.Updater.updateElement("my-div", "stuff.php");</code></pre>
 * @param {Mixed} el The element to update
 * @param {String} url The url
 * @param {String/Object} params (optional) Url encoded param string or an object of name/value pairs
 * @param {Object} options (optional) A config object with any of the Updater properties you want to set - for
 * example: {disableCaching:true, indicatorText: "Loading data..."}
 * @static
 * @deprecated
 * @member Ext.Updater
 */
Ext.Updater.updateElement = function(el, url, params, options){
    var um = Ext.get(el).getUpdater();
    Ext.apply(um, options);
    um.update(url, params, options ? options.callback : null);
};
/**
 * @class Ext.Updater.BasicRenderer
 * Default Content renderer. Updates the elements innerHTML with the responseText.
 */
Ext.Updater.BasicRenderer = function(){};

Ext.Updater.BasicRenderer.prototype = {
    /**
     * This is called when the transaction is completed and it's time to update the element - The BasicRenderer
     * updates the elements innerHTML with the responseText - To perform a custom render (i.e. XML or JSON processing),
     * create an object with a "render(el, response)" method and pass it to setRenderer on the Updater.
     * @param {Ext.Element} el The element being rendered
     * @param {Object} response The XMLHttpRequest object
     * @param {Updater} updateManager The calling update manager
     * @param {Function} callback A callback that will need to be called if loadScripts is true on the Updater
     */
     render : function(el, response, updateManager, callback){
        el.update(response.responseText, updateManager.loadScripts, callback);
    }
};

Ext.UpdateManager = Ext.Updater;

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.util.TextMetrics
 * Provides precise pixel measurements for blocks of text so that you can determine exactly how high and
 * wide, in pixels, a given block of text will be.
 * @singleton
 */
Ext.util.TextMetrics = function(){
    var shared;
    return {
        /**
         * Measures the size of the specified text
         * @param {String/HTMLElement} el The element, dom node or id from which to copy existing CSS styles
         * that can affect the size of the rendered text
         * @param {String} text The text to measure
         * @param {Number} fixedWidth (optional) If the text will be multiline, you have to set a fixed width
         * in order to accurately measure the text height
         * @return {Object} An object containing the text's size {width: (width), height: (height)}
         */
        measure : function(el, text, fixedWidth){
            if(!shared){
                shared = Ext.util.TextMetrics.Instance(el, fixedWidth);
            }
            shared.bind(el);
            shared.setFixedWidth(fixedWidth || 'auto');
            return shared.getSize(text);
        },

        /**
         * Return a unique TextMetrics instance that can be bound directly to an element and reused.  This reduces
         * the overhead of multiple calls to initialize the style properties on each measurement.
         * @param {String/HTMLElement} el The element, dom node or id that the instance will be bound to
         * @param {Number} fixedWidth (optional) If the text will be multiline, you have to set a fixed width
         * in order to accurately measure the text height
         * @return {Ext.util.TextMetrics.Instance} instance The new instance
         */
        createInstance : function(el, fixedWidth){
            return Ext.util.TextMetrics.Instance(el, fixedWidth);
        }
    };
}();

Ext.util.TextMetrics.Instance = function(bindTo, fixedWidth){
    var ml = new Ext.Element(document.createElement('div'));
    document.body.appendChild(ml.dom);
    ml.position('absolute');
    ml.setLeftTop(-1000, -1000);
    ml.hide();

    if(fixedWidth){
        ml.setWidth(fixedWidth);
    }

    var instance = {
        /**
         * Returns the size of the specified text based on the internal element's style and width properties
         * @param {String} text The text to measure
         * @return {Object} An object containing the text's size {width: (width), height: (height)}
         */
        getSize : function(text){
            ml.update(text);
            var s = ml.getSize();
            ml.update('');
            return s;
        },

        /**
         * Binds this TextMetrics instance to an element from which to copy existing CSS styles
         * that can affect the size of the rendered text
         * @param {String/HTMLElement} el The element, dom node or id
         */
        bind : function(el){
            ml.setStyle(
                Ext.fly(el).getStyles('font-size','font-style', 'font-weight', 'font-family','line-height', 'text-transform', 'letter-spacing')
            );
        },

        /**
         * Sets a fixed width on the internal measurement element.  If the text will be multiline, you have
         * to set a fixed width in order to accurately measure the text height.
         * @param {Number} width The width to set on the element
         */
        setFixedWidth : function(width){
            ml.setWidth(width);
        },

        /**
         * Returns the measured width of the specified text
         * @param {String} text The text to measure
         * @return {Number} width The width in pixels
         */
        getWidth : function(text){
            ml.dom.style.width = 'auto';
            return this.getSize(text).width;
        },

        /**
         * Returns the measured height of the specified text.  For multiline text, be sure to call
         * {@link #setFixedWidth} if necessary.
         * @param {String} text The text to measure
         * @return {Number} height The height in pixels
         */
        getHeight : function(text){
            return this.getSize(text).height;
        }
    };

    instance.bind(bindTo);

    return instance;
};

// backwards compat
Ext.Element.measureText = Ext.util.TextMetrics.measure;
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */


//Notifies Element that fx methods are available
Ext.enableFx = true;

/**
 * @class Ext.Fx
 * <p>A class to provide basic animation and visual effects support.  <b>Note:</b> This class is automatically applied
 * to the {@link Ext.Element} interface when included, so all effects calls should be performed via Element.
 * Conversely, since the effects are not actually defined in Element, Ext.Fx <b>must</b> be included in order for the 
 * Element effects to work.</p><br/>
 *
 * <p>It is important to note that although the Fx methods and many non-Fx Element methods support "method chaining" in that
 * they return the Element object itself as the method return value, it is not always possible to mix the two in a single
 * method chain.  The Fx methods use an internal effects queue so that each effect can be properly timed and sequenced.
 * Non-Fx methods, on the other hand, have no such internal queueing and will always execute immediately.  For this reason,
 * while it may be possible to mix certain Fx and non-Fx method calls in a single chain, it may not always provide the
 * expected results and should be done with care.</p><br/>
 *
 * <p>Motion effects support 8-way anchoring, meaning that you can choose one of 8 different anchor points on the Element
 * that will serve as either the start or end point of the animation.  Following are all of the supported anchor positions:</p>
<pre>
Value  Description
-----  -----------------------------
tl     The top left corner
t      The center of the top edge
tr     The top right corner
l      The center of the left edge
r      The center of the right edge
bl     The bottom left corner
b      The center of the bottom edge
br     The bottom right corner
</pre>
 * <b>Although some Fx methods accept specific custom config parameters, the ones shown in the Config Options section
 * below are common options that can be passed to any Fx method.</b>
 * 
 * @cfg {Function} callback A function called when the effect is finished.  Note that effects are queued internally by the
 * Fx class, so do not need to use the callback parameter to specify another effect -- effects can simply be chained together
 * and called in sequence (e.g., el.slideIn().highlight();).  The callback is intended for any additional code that should
 * run once a particular effect has completed. The Element being operated upon is passed as the first parameter.
 * @cfg {Object} scope The scope of the effect function
 * @cfg {String} easing A valid Easing value for the effect
 * @cfg {String} afterCls A css class to apply after the effect
 * @cfg {Number} duration The length of time (in seconds) that the effect should last
 * @cfg {Boolean} remove Whether the Element should be removed from the DOM and destroyed after the effect finishes
 * @cfg {Boolean} useDisplay Whether to use the <i>display</i> CSS property instead of <i>visibility</i> when hiding Elements (only applies to 
 * effects that end with the element being visually hidden, ignored otherwise)
 * @cfg {String/Object/Function} afterStyle A style specification string, e.g. "width:100px", or an object in the form {width:"100px"}, or
 * a function which returns such a specification that will be applied to the Element after the effect finishes
 * @cfg {Boolean} block Whether the effect should block other effects from queueing while it runs
 * @cfg {Boolean} concurrent Whether to allow subsequently-queued effects to run at the same time as the current effect, or to ensure that they run in sequence
 * @cfg {Boolean} stopFx Whether subsequent effects should be stopped and removed after the current effect finishes
 */
Ext.Fx = {
	/**
	 * Slides the element into view.  An anchor point can be optionally passed to set the point of
	 * origin for the slide effect.  This function automatically handles wrapping the element with
	 * a fixed-size container if needed.  See the Fx class overview for valid anchor point options.
	 * Usage:
	 *<pre><code>
// default: slide the element in from the top
el.slideIn();

// custom: slide the element in from the right with a 2-second duration
el.slideIn('r', { duration: 2 });

// common config options shown with default values
el.slideIn('t', {
    easing: 'easeOut',
    duration: .5
});
</code></pre>
	 * @param {String} anchor (optional) One of the valid Fx anchor positions (defaults to top: 't')
	 * @param {Object} options (optional) Object literal with any of the Fx config options
	 * @return {Ext.Element} The Element
	 */
    slideIn : function(anchor, o){
        var el = this.getFxEl();
        o = o || {};

        el.queueFx(o, function(){

            anchor = anchor || "t";

            // fix display to visibility
            this.fixDisplay();

            // restore values after effect
            var r = this.getFxRestore();
            var b = this.getBox();
            // fixed size for slide
            this.setSize(b);

            // wrap if needed
            var wrap = this.fxWrap(r.pos, o, "hidden");

            var st = this.dom.style;
            st.visibility = "visible";
            st.position = "absolute";

            // clear out temp styles after slide and unwrap
            var after = function(){
                el.fxUnwrap(wrap, r.pos, o);
                st.width = r.width;
                st.height = r.height;
                el.afterFx(o);
            };
            // time to calc the positions
            var a, pt = {to: [b.x, b.y]}, bw = {to: b.width}, bh = {to: b.height};

            switch(anchor.toLowerCase()){
                case "t":
                    wrap.setSize(b.width, 0);
                    st.left = st.bottom = "0";
                    a = {height: bh};
                break;
                case "l":
                    wrap.setSize(0, b.height);
                    st.right = st.top = "0";
                    a = {width: bw};
                break;
                case "r":
                    wrap.setSize(0, b.height);
                    wrap.setX(b.right);
                    st.left = st.top = "0";
                    a = {width: bw, points: pt};
                break;
                case "b":
                    wrap.setSize(b.width, 0);
                    wrap.setY(b.bottom);
                    st.left = st.top = "0";
                    a = {height: bh, points: pt};
                break;
                case "tl":
                    wrap.setSize(0, 0);
                    st.right = st.bottom = "0";
                    a = {width: bw, height: bh};
                break;
                case "bl":
                    wrap.setSize(0, 0);
                    wrap.setY(b.y+b.height);
                    st.right = st.top = "0";
                    a = {width: bw, height: bh, points: pt};
                break;
                case "br":
                    wrap.setSize(0, 0);
                    wrap.setXY([b.right, b.bottom]);
                    st.left = st.top = "0";
                    a = {width: bw, height: bh, points: pt};
                break;
                case "tr":
                    wrap.setSize(0, 0);
                    wrap.setX(b.x+b.width);
                    st.left = st.bottom = "0";
                    a = {width: bw, height: bh, points: pt};
                break;
            }
            this.dom.style.visibility = "visible";
            wrap.show();

            arguments.callee.anim = wrap.fxanim(a,
                o,
                'motion',
                .5,
                'easeOut', after);
        });
        return this;
    },
    
	/**
	 * Slides the element out of view.  An anchor point can be optionally passed to set the end point
	 * for the slide effect.  When the effect is completed, the element will be hidden (visibility = 
	 * 'hidden') but block elements will still take up space in the document.  The element must be removed
	 * from the DOM using the 'remove' config option if desired.  This function automatically handles 
	 * wrapping the element with a fixed-size container if needed.  See the Fx class overview for valid anchor point options.
	 * Usage:
	 *<pre><code>
// default: slide the element out to the top
el.slideOut();

// custom: slide the element out to the right with a 2-second duration
el.slideOut('r', { duration: 2 });

// common config options shown with default values
el.slideOut('t', {
    easing: 'easeOut',
    duration: .5,
    remove: false,
    useDisplay: false
});
</code></pre>
	 * @param {String} anchor (optional) One of the valid Fx anchor positions (defaults to top: 't')
	 * @param {Object} options (optional) Object literal with any of the Fx config options
	 * @return {Ext.Element} The Element
	 */
    slideOut : function(anchor, o){
        var el = this.getFxEl();
        o = o || {};

        el.queueFx(o, function(){

            anchor = anchor || "t";

            // restore values after effect
            var r = this.getFxRestore();
            
            var b = this.getBox();
            // fixed size for slide
            this.setSize(b);

            // wrap if needed
            var wrap = this.fxWrap(r.pos, o, "visible");

            var st = this.dom.style;
            st.visibility = "visible";
            st.position = "absolute";

            wrap.setSize(b);

            var after = function(){
                if(o.useDisplay){
                    el.setDisplayed(false);
                }else{
                    el.hide();
                }

                el.fxUnwrap(wrap, r.pos, o);

                st.width = r.width;
                st.height = r.height;

                el.afterFx(o);
            };

            var a, zero = {to: 0};
            switch(anchor.toLowerCase()){
                case "t":
                    st.left = st.bottom = "0";
                    a = {height: zero};
                break;
                case "l":
                    st.right = st.top = "0";
                    a = {width: zero};
                break;
                case "r":
                    st.left = st.top = "0";
                    a = {width: zero, points: {to:[b.right, b.y]}};
                break;
                case "b":
                    st.left = st.top = "0";
                    a = {height: zero, points: {to:[b.x, b.bottom]}};
                break;
                case "tl":
                    st.right = st.bottom = "0";
                    a = {width: zero, height: zero};
                break;
                case "bl":
                    st.right = st.top = "0";
                    a = {width: zero, height: zero, points: {to:[b.x, b.bottom]}};
                break;
                case "br":
                    st.left = st.top = "0";
                    a = {width: zero, height: zero, points: {to:[b.x+b.width, b.bottom]}};
                break;
                case "tr":
                    st.left = st.bottom = "0";
                    a = {width: zero, height: zero, points: {to:[b.right, b.y]}};
                break;
            }

            arguments.callee.anim = wrap.fxanim(a,
                o,
                'motion',
                .5,
                "easeOut", after);
        });
        return this;
    },

	/**
	 * Fades the element out while slowly expanding it in all directions.  When the effect is completed, the 
	 * element will be hidden (visibility = 'hidden') but block elements will still take up space in the document. 
	 * The element must be removed from the DOM using the 'remove' config option if desired.
	 * Usage:
	 *<pre><code>
// default
el.puff();

// common config options shown with default values
el.puff({
    easing: 'easeOut',
    duration: .5,
    remove: false,
    useDisplay: false
});
</code></pre>
	 * @param {Object} options (optional) Object literal with any of the Fx config options
	 * @return {Ext.Element} The Element
	 */
    puff : function(o){
        var el = this.getFxEl();
        o = o || {};

        el.queueFx(o, function(){
            this.clearOpacity();
            this.show();

            // restore values after effect
            var r = this.getFxRestore();
            var st = this.dom.style;

            var after = function(){
                if(o.useDisplay){
                    el.setDisplayed(false);
                }else{
                    el.hide();
                }

                el.clearOpacity();

                el.setPositioning(r.pos);
                st.width = r.width;
                st.height = r.height;
                st.fontSize = '';
                el.afterFx(o);
            };

            var width = this.getWidth();
            var height = this.getHeight();

            arguments.callee.anim = this.fxanim({
                    width : {to: this.adjustWidth(width * 2)},
                    height : {to: this.adjustHeight(height * 2)},
                    points : {by: [-(width * .5), -(height * .5)]},
                    opacity : {to: 0},
                    fontSize: {to:200, unit: "%"}
                },
                o,
                'motion',
                .5,
                "easeOut", after);
        });
        return this;
    },

	/**
	 * Blinks the element as if it was clicked and then collapses on its center (similar to switching off a television).
	 * When the effect is completed, the element will be hidden (visibility = 'hidden') but block elements will still 
	 * take up space in the document. The element must be removed from the DOM using the 'remove' config option if desired.
	 * Usage:
	 *<pre><code>
// default
el.switchOff();

// all config options shown with default values
el.switchOff({
    easing: 'easeIn',
    duration: .3,
    remove: false,
    useDisplay: false
});
</code></pre>
	 * @param {Object} options (optional) Object literal with any of the Fx config options
	 * @return {Ext.Element} The Element
	 */
    switchOff : function(o){
        var el = this.getFxEl();
        o = o || {};

        el.queueFx(o, function(){
            this.clearOpacity();
            this.clip();

            // restore values after effect
            var r = this.getFxRestore();
            var st = this.dom.style;

            var after = function(){
                if(o.useDisplay){
                    el.setDisplayed(false);
                }else{
                    el.hide();
                }

                el.clearOpacity();
                el.setPositioning(r.pos);
                st.width = r.width;
                st.height = r.height;

                el.afterFx(o);
            };

            this.fxanim({opacity:{to:0.3}}, null, null, .1, null, function(){
                this.clearOpacity();
                (function(){
                    this.fxanim({
                        height:{to:1},
                        points:{by:[0, this.getHeight() * .5]}
                    }, o, 'motion', 0.3, 'easeIn', after);
                }).defer(100, this);
            });
        });
        return this;
    },

    /**
     * Highlights the Element by setting a color (applies to the background-color by default, but can be
     * changed using the "attr" config option) and then fading back to the original color. If no original
     * color is available, you should provide the "endColor" config option which will be cleared after the animation.
     * Usage:
<pre><code>
// default: highlight background to yellow
el.highlight();

// custom: highlight foreground text to blue for 2 seconds
el.highlight("0000ff", { attr: 'color', duration: 2 });

// common config options shown with default values
el.highlight("ffff9c", {
    attr: "background-color", //can be any valid CSS property (attribute) that supports a color value
    endColor: (current color) or "ffffff",
    easing: 'easeIn',
    duration: 1
});
</code></pre>
     * @param {String} color (optional) The highlight color. Should be a 6 char hex color without the leading # (defaults to yellow: 'ffff9c')
     * @param {Object} options (optional) Object literal with any of the Fx config options
     * @return {Ext.Element} The Element
     */	
    highlight : function(color, o){
        var el = this.getFxEl();
        o = o || {};

        el.queueFx(o, function(){
            color = color || "ffff9c";
            var attr = o.attr || "backgroundColor";

            this.clearOpacity();
            this.show();

            var origColor = this.getColor(attr);
            var restoreColor = this.dom.style[attr];
            var endColor = (o.endColor || origColor) || "ffffff";

            var after = function(){
                el.dom.style[attr] = restoreColor;
                el.afterFx(o);
            };

            var a = {};
            a[attr] = {from: color, to: endColor};
            arguments.callee.anim = this.fxanim(a,
                o,
                'color',
                1,
                'easeIn', after);
        });
        return this;
    },

   /**
    * Shows a ripple of exploding, attenuating borders to draw attention to an Element.
    * Usage:
<pre><code>
// default: a single light blue ripple
el.frame();

// custom: 3 red ripples lasting 3 seconds total
el.frame("ff0000", 3, { duration: 3 });

// common config options shown with default values
el.frame("C3DAF9", 1, {
    duration: 1 //duration of entire animation (not each individual ripple)
    // Note: Easing is not configurable and will be ignored if included
});
</code></pre>
    * @param {String} color (optional) The color of the border.  Should be a 6 char hex color without the leading # (defaults to light blue: 'C3DAF9').
    * @param {Number} count (optional) The number of ripples to display (defaults to 1)
    * @param {Object} options (optional) Object literal with any of the Fx config options
    * @return {Ext.Element} The Element
    */
    frame : function(color, count, o){
        var el = this.getFxEl();
        o = o || {};

        el.queueFx(o, function(){
            color = color || "#C3DAF9";
            if(color.length == 6){
                color = "#" + color;
            }
            count = count || 1;
            var duration = o.duration || 1;
            this.show();

            var b = this.getBox();
            var animFn = function(){
                var proxy = Ext.getBody().createChild({
                     style:{
                        visbility:"hidden",
                        position:"absolute",
                        "z-index":"35000", // yee haw
                        border:"0px solid " + color
                     }
                  });
                var scale = Ext.isBorderBox ? 2 : 1;
                proxy.animate({
                    top:{from:b.y, to:b.y - 20},
                    left:{from:b.x, to:b.x - 20},
                    borderWidth:{from:0, to:10},
                    opacity:{from:1, to:0},
                    height:{from:b.height, to:(b.height + (20*scale))},
                    width:{from:b.width, to:(b.width + (20*scale))}
                }, duration, function(){
                    proxy.remove();
                    if(--count > 0){
                         animFn();
                    }else{
                        el.afterFx(o);
                    }
                });
            };
            animFn.call(this);
        });
        return this;
    },

   /**
    * Creates a pause before any subsequent queued effects begin.  If there are
    * no effects queued after the pause it will have no effect.
    * Usage:
<pre><code>
el.pause(1);
</code></pre>
    * @param {Number} seconds The length of time to pause (in seconds)
    * @return {Ext.Element} The Element
    */
    pause : function(seconds){
        var el = this.getFxEl();
        var o = {};

        el.queueFx(o, function(){
            setTimeout(function(){
                el.afterFx(o);
            }, seconds * 1000);
        });
        return this;
    },

   /**
    * Fade an element in (from transparent to opaque).  The ending opacity can be specified
    * using the "endOpacity" config option.
    * Usage:
<pre><code>
// default: fade in from opacity 0 to 100%
el.fadeIn();

// custom: fade in from opacity 0 to 75% over 2 seconds
el.fadeIn({ endOpacity: .75, duration: 2});

// common config options shown with default values
el.fadeIn({
    endOpacity: 1, //can be any value between 0 and 1 (e.g. .5)
    easing: 'easeOut',
    duration: .5
});
</code></pre>
    * @param {Object} options (optional) Object literal with any of the Fx config options
    * @return {Ext.Element} The Element
    */
    fadeIn : function(o){
        var el = this.getFxEl();
        o = o || {};
        el.queueFx(o, function(){
            this.setOpacity(0);
            this.fixDisplay();
            this.dom.style.visibility = 'visible';
            var to = o.endOpacity || 1;
            arguments.callee.anim = this.fxanim({opacity:{to:to}},
                o, null, .5, "easeOut", function(){
                if(to == 1){
                    this.clearOpacity();
                }
                el.afterFx(o);
            });
        });
        return this;
    },

   /**
    * Fade an element out (from opaque to transparent).  The ending opacity can be specified
    * using the "endOpacity" config option.  Note that IE may require useDisplay:true in order
    * to redisplay correctly.
    * Usage:
<pre><code>
// default: fade out from the element's current opacity to 0
el.fadeOut();

// custom: fade out from the element's current opacity to 25% over 2 seconds
el.fadeOut({ endOpacity: .25, duration: 2});

// common config options shown with default values
el.fadeOut({
    endOpacity: 0, //can be any value between 0 and 1 (e.g. .5)
    easing: 'easeOut',
    duration: .5,
    remove: false,
    useDisplay: false
});
</code></pre>
    * @param {Object} options (optional) Object literal with any of the Fx config options
    * @return {Ext.Element} The Element
    */
    fadeOut : function(o){
        var el = this.getFxEl();
        o = o || {};
        el.queueFx(o, function(){
            arguments.callee.anim = this.fxanim({opacity:{to:o.endOpacity || 0}},
                o, null, .5, "easeOut", function(){
                if(this.visibilityMode == Ext.Element.DISPLAY || o.useDisplay){
                     this.dom.style.display = "none";
                }else{
                     this.dom.style.visibility = "hidden";
                }
                this.clearOpacity();
                el.afterFx(o);
            });
        });
        return this;
    },

   /**
    * Animates the transition of an element's dimensions from a starting height/width
    * to an ending height/width.
    * Usage:
<pre><code>
// change height and width to 100x100 pixels
el.scale(100, 100);

// common config options shown with default values.  The height and width will default to
// the element's existing values if passed as null.
el.scale(
    [element's width],
    [element's height], {
	    easing: 'easeOut',
	    duration: .35
	}
);
</code></pre>
    * @param {Number} width  The new width (pass undefined to keep the original width)
    * @param {Number} height  The new height (pass undefined to keep the original height)
    * @param {Object} options (optional) Object literal with any of the Fx config options
    * @return {Ext.Element} The Element
    */
    scale : function(w, h, o){
        this.shift(Ext.apply({}, o, {
            width: w,
            height: h
        }));
        return this;
    },

   /**
    * Animates the transition of any combination of an element's dimensions, xy position and/or opacity.
    * Any of these properties not specified in the config object will not be changed.  This effect 
    * requires that at least one new dimension, position or opacity setting must be passed in on
    * the config object in order for the function to have any effect.
    * Usage:
<pre><code>
// slide the element horizontally to x position 200 while changing the height and opacity
el.shift({ x: 200, height: 50, opacity: .8 });

// common config options shown with default values.
el.shift({
    width: [element's width],
    height: [element's height],
    x: [element's x position],
    y: [element's y position],
    opacity: [element's opacity],
    easing: 'easeOut',
    duration: .35
});
</code></pre>
    * @param {Object} options  Object literal with any of the Fx config options
    * @return {Ext.Element} The Element
    */
    shift : function(o){
        var el = this.getFxEl();
        o = o || {};
        el.queueFx(o, function(){
            var a = {}, w = o.width, h = o.height, x = o.x, y = o.y,  op = o.opacity;
            if(w !== undefined){
                a.width = {to: this.adjustWidth(w)};
            }
            if(h !== undefined){
                a.height = {to: this.adjustHeight(h)};
            }
            if(o.left !== undefined){
                a.left = {to: o.left};
            }
            if(o.top !== undefined){
                a.top = {to: o.top};
            }
            if(o.right !== undefined){
                a.right = {to: o.right};
            }
            if(o.bottom !== undefined){
                a.bottom = {to: o.bottom};
            }
            if(x !== undefined || y !== undefined){
                a.points = {to: [
                    x !== undefined ? x : this.getX(),
                    y !== undefined ? y : this.getY()
                ]};
            }
            if(op !== undefined){
                a.opacity = {to: op};
            }
            if(o.xy !== undefined){
                a.points = {to: o.xy};
            }
            arguments.callee.anim = this.fxanim(a,
                o, 'motion', .35, "easeOut", function(){
                el.afterFx(o);
            });
        });
        return this;
    },

	/**
	 * Slides the element while fading it out of view.  An anchor point can be optionally passed to set the 
	 * ending point of the effect.
	 * Usage:
	 *<pre><code>
// default: slide the element downward while fading out
el.ghost();

// custom: slide the element out to the right with a 2-second duration
el.ghost('r', { duration: 2 });

// common config options shown with default values
el.ghost('b', {
    easing: 'easeOut',
    duration: .5,
    remove: false,
    useDisplay: false
});
</code></pre>
	 * @param {String} anchor (optional) One of the valid Fx anchor positions (defaults to bottom: 'b')
	 * @param {Object} options (optional) Object literal with any of the Fx config options
	 * @return {Ext.Element} The Element
	 */
    ghost : function(anchor, o){
        var el = this.getFxEl();
        o = o || {};

        el.queueFx(o, function(){
            anchor = anchor || "b";

            // restore values after effect
            var r = this.getFxRestore();
            var w = this.getWidth(),
                h = this.getHeight();

            var st = this.dom.style;

            var after = function(){
                if(o.useDisplay){
                    el.setDisplayed(false);
                }else{
                    el.hide();
                }

                el.clearOpacity();
                el.setPositioning(r.pos);
                st.width = r.width;
                st.height = r.height;

                el.afterFx(o);
            };

            var a = {opacity: {to: 0}, points: {}}, pt = a.points;
            switch(anchor.toLowerCase()){
                case "t":
                    pt.by = [0, -h];
                break;
                case "l":
                    pt.by = [-w, 0];
                break;
                case "r":
                    pt.by = [w, 0];
                break;
                case "b":
                    pt.by = [0, h];
                break;
                case "tl":
                    pt.by = [-w, -h];
                break;
                case "bl":
                    pt.by = [-w, h];
                break;
                case "br":
                    pt.by = [w, h];
                break;
                case "tr":
                    pt.by = [w, -h];
                break;
            }

            arguments.callee.anim = this.fxanim(a,
                o,
                'motion',
                .5,
                "easeOut", after);
        });
        return this;
    },

	/**
	 * Ensures that all effects queued after syncFx is called on the element are
	 * run concurrently.  This is the opposite of {@link #sequenceFx}.
	 * @return {Ext.Element} The Element
	 */
    syncFx : function(){
        this.fxDefaults = Ext.apply(this.fxDefaults || {}, {
            block : false,
            concurrent : true,
            stopFx : false
        });
        return this;
    },

	/**
	 * Ensures that all effects queued after sequenceFx is called on the element are
	 * run in sequence.  This is the opposite of {@link #syncFx}.
	 * @return {Ext.Element} The Element
	 */
    sequenceFx : function(){
        this.fxDefaults = Ext.apply(this.fxDefaults || {}, {
            block : false,
            concurrent : false,
            stopFx : false
        });
        return this;
    },

	/* @private */
    nextFx : function(){
        var ef = this.fxQueue[0];
        if(ef){
            ef.call(this);
        }
    },

	/**
	 * Returns true if the element has any effects actively running or queued, else returns false.
	 * @return {Boolean} True if element has active effects, else false
	 */
    hasActiveFx : function(){
        return this.fxQueue && this.fxQueue[0];
    },

	/**
	 * Stops any running effects and clears the element's internal effects queue if it contains
	 * any additional effects that haven't started yet.
	 * @return {Ext.Element} The Element
	 */
    stopFx : function(){
        if(this.hasActiveFx()){
            var cur = this.fxQueue[0];
            if(cur && cur.anim && cur.anim.isAnimated()){
                this.fxQueue = [cur]; // clear out others
                cur.anim.stop(true);
            }
        }
        return this;
    },

	/* @private */
    beforeFx : function(o){
        if(this.hasActiveFx() && !o.concurrent){
           if(o.stopFx){
               this.stopFx();
               return true;
           }
           return false;
        }
        return true;
    },

	/**
	 * Returns true if the element is currently blocking so that no other effect can be queued
	 * until this effect is finished, else returns false if blocking is not set.  This is commonly
	 * used to ensure that an effect initiated by a user action runs to completion prior to the
	 * same effect being restarted (e.g., firing only one effect even if the user clicks several times).
	 * @return {Boolean} True if blocking, else false
	 */
    hasFxBlock : function(){
        var q = this.fxQueue;
        return q && q[0] && q[0].block;
    },

	/* @private */
    queueFx : function(o, fn){
        if(!this.fxQueue){
            this.fxQueue = [];
        }
        if(!this.hasFxBlock()){
            Ext.applyIf(o, this.fxDefaults);
            if(!o.concurrent){
                var run = this.beforeFx(o);
                fn.block = o.block;
                this.fxQueue.push(fn);
                if(run){
                    this.nextFx();
                }
            }else{
                fn.call(this);
            }
        }
        return this;
    },

	/* @private */
    fxWrap : function(pos, o, vis){
        var wrap;
        if(!o.wrap || !(wrap = Ext.get(o.wrap))){
            var wrapXY;
            if(o.fixPosition){
                wrapXY = this.getXY();
            }
            var div = document.createElement("div");
            div.style.visibility = vis;
            wrap = Ext.get(this.dom.parentNode.insertBefore(div, this.dom));
            wrap.setPositioning(pos);
            if(wrap.getStyle("position") == "static"){
                wrap.position("relative");
            }
            this.clearPositioning('auto');
            wrap.clip();
            wrap.dom.appendChild(this.dom);
            if(wrapXY){
                wrap.setXY(wrapXY);
            }
        }
        return wrap;
    },

	/* @private */
    fxUnwrap : function(wrap, pos, o){
        this.clearPositioning();
        this.setPositioning(pos);
        if(!o.wrap){
            wrap.dom.parentNode.insertBefore(this.dom, wrap.dom);
            wrap.remove();
        }
    },

	/* @private */
    getFxRestore : function(){
        var st = this.dom.style;
        return {pos: this.getPositioning(), width: st.width, height : st.height};
    },

	/* @private */
    afterFx : function(o){
        if(o.afterStyle){
            this.applyStyles(o.afterStyle);
        }
        if(o.afterCls){
            this.addClass(o.afterCls);
        }
        if(o.remove === true){
            this.remove();
        }
        Ext.callback(o.callback, o.scope, [this]);
        if(!o.concurrent){
            this.fxQueue.shift();
            this.nextFx();
        }
    },

	/* @private */
    getFxEl : function(){ // support for composite element fx
        return Ext.get(this.dom);
    },

	/* @private */
    fxanim : function(args, opt, animType, defaultDur, defaultEase, cb){
        animType = animType || 'run';
        opt = opt || {};
        var anim = Ext.lib.Anim[animType](
            this.dom, args,
            (opt.duration || defaultDur) || .35,
            (opt.easing || defaultEase) || 'easeOut',
            function(){
                Ext.callback(cb, this);
            },
            this
        );
        opt.anim = anim;
        return anim;
    }
};

// backwords compat
Ext.Fx.resize = Ext.Fx.scale;

//When included, Ext.Fx is automatically applied to Element so that all basic
//effects are available directly via the Element API
Ext.apply(Ext.Element.prototype, Ext.Fx);

