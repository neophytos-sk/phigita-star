/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.WindowGroup
 * An object that represents a group of {@link Ext.Window} instances and provides z-order management
 * and window activation behavior.
 * @constructor
 */
Ext.WindowGroup = function(){
    var list = {};
    var accessList = [];
    var front = null;

    // private
    var sortWindows = function(d1, d2){
        return (!d1._lastAccess || d1._lastAccess < d2._lastAccess) ? -1 : 1;
    };

    // private
    var orderWindows = function(){
        var a = accessList, len = a.length;
        if(len > 0){
            a.sort(sortWindows);
            var seed = a[0].manager.zseed;
            for(var i = 0; i < len; i++){
                var win = a[i];
                if(win && !win.hidden){
                    win.setZIndex(seed + (i*10));
                }
            }
        }
        activateLast();
    };

    // private
    var setActiveWin = function(win){
        if(win != front){
            if(front){
                front.setActive(false);
            }
            front = win;
            if(win){
                win.setActive(true);
            }
        }
    };

    // private
    var activateLast = function(){
        for(var i = accessList.length-1; i >=0; --i) {
            if(!accessList[i].hidden){
                setActiveWin(accessList[i]);
                return;
            }
        }
        // none to activate
        setActiveWin(null);
    };

    return {
        /**
         * The starting z-index for windows (defaults to 9000)
         * @type Number The z-index value
         */
        zseed : 9000,

        // private
        register : function(win){
            list[win.id] = win;
            accessList.push(win);
            win.on('hide', activateLast);
        },

        // private
        unregister : function(win){
            delete list[win.id];
            win.un('hide', activateLast);
            accessList.remove(win);
        },

        /**
         * Gets a registered window by id.
         * @param {String/Object} id The id of the window or a {@link Ext.Window} instance
         * @return {Ext.Window}
         */
        get : function(id){
            return typeof id == "object" ? id : list[id];
        },

        /**
         * Brings the specified window to the front of any other active windows.
         * @param {String/Object} win The id of the window or a {@link Ext.Window} instance
         * @return {Boolean} True if the dialog was brought to the front, else false
         * if it was already in front
         */
        bringToFront : function(win){
            win = this.get(win);
            if(win != front){
                win._lastAccess = new Date().getTime();
                orderWindows();
                return true;
            }
            return false;
        },

        /**
         * Sends the specified window to the back of other active windows.
         * @param {String/Object} win The id of the window or a {@link Ext.Window} instance
         * @return {Ext.Window} The window
         */
        sendToBack : function(win){
            win = this.get(win);
            win._lastAccess = -(new Date().getTime());
            orderWindows();
            return win;
        },

        /**
         * Hides all windows in the group.
         */
        hideAll : function(){
            for(var id in list){
                if(list[id] && typeof list[id] != "function" && list[id].isVisible()){
                    list[id].hide();
                }
            }
        },

        /**
         * Gets the currently-active window in the group.
         * @return {Ext.Window} The active window
         */
        getActive : function(){
            return front;
        },

        /**
         * Returns zero or more windows in the group using the custom search function passed to this method.
         * The function should accept a single {@link Ext.Window} reference as its only argument and should
         * return true if the window matches the search criteria, otherwise it should return false.
         * @param {Function} fn The search function
         * @param {Object} scope (optional) The scope in which to execute the function (defaults to the window
         * that gets passed to the function if not specified)
         * @return {Array} An array of zero or more matching windows
         */
        getBy : function(fn, scope){
            var r = [];
            for(var i = accessList.length-1; i >=0; --i) {
                var win = accessList[i];
                if(fn.call(scope||win, win) !== false){
                    r.push(win);
                }
            }
            return r;
        },

        /**
         * Executes the specified function once for every window in the group, passing each
         * window as the only parameter. Returning false from the function will stop the iteration.
         * @param {Function} fn The function to execute for each item
         * @param {Object} scope (optional) The scope in which to execute the function
         */
        each : function(fn, scope){
            for(var id in list){
                if(list[id] && typeof list[id] != "function"){
                    if(fn.call(scope || list[id], list[id]) === false){
                        return;
                    }
                }
            }
        }
    };
};


/**
 * @class Ext.WindowMgr
 * @extends Ext.WindowGroup
 * The default global window group that is available automatically.  To have more than one group of windows
 * with separate z-order stacks, create additional instances of {@link Ext.WindowGroup} as needed.
 * @singleton
 */
Ext.WindowMgr = new Ext.WindowGroup();
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.Window
 * @extends Ext.Panel
 * A specialized panel intended for use as an application window.  Windows are floated and draggable by default, and
 * also provide specific behavior like the ability to maximize and restore (with an event for minimizing, since the
 * minimize behavior is application-specific).  Windows can also be linked to a {@link Ext.WindowGroup} or managed
 * by the {@link Ext.WindowManager} to provide grouping, activation, to front/back and other application-specific behavior.
 * @constructor
 * @param {Object} config The config object
 */
Ext.Window = Ext.extend(Ext.Panel, {
    /**
     * @cfg {Number} x
     * The X position of the left edge of the Window on initial showing. Defaults to centering the Window within
     * the width of the Window's container {@link Ext.Element Element) (The Element that the Window is rendered to).
     */
    /**
     * @cfg {Number} y
     * The Y position of the top edge of the Window on initial showing. Defaults to centering the Window within
     * the height of the Window's container {@link Ext.Element Element) (The Element that the Window is rendered to).
     */
    /**
     * @cfg {Boolean} modal
     * True to make the window modal and mask everything behind it when displayed, false to display it without
     * restricting access to other UI elements (defaults to false).
     */
    /**
     * @cfg {String/Element} animateTarget
     * Id or element from which the window should animate while opening (defaults to null with no animation).
     */
    /**
     * @cfg {String} resizeHandles
     * A valid {@link Ext.Resizable} handles config string (defaults to 'all').  Only applies when resizable = true.
     */
    /**
     * @cfg {Ext.WindowGroup} manager
     * A reference to the WindowGroup that should manage this window (defaults to {@link Ext.WindowMgr}).
     */
    /**
    * @cfg {String/Number/Button} defaultButton
    * The id / index of a button or a button instance to focus when this window received the focus.
    */
    /**
    * @cfg {Function} onEsc
    * Allows override of the built-in processing for the escape key. Default action
    * is to close the Window (performing whatever action is specified in {@link #closeAction}.
    * To prevent the Window closing when the escape key is pressed, specify this as
    * Ext.emptyFn (See {@link Ext#emptyFn}).
    */
    /**
    * @cfg {String} baseCls
    * The base CSS class to apply to this panel's element (defaults to 'x-window').
    */
    baseCls : 'x-window',
    /**
     * @cfg {Boolean} resizable
     * True to allow user resizing at each edge and corner of the window, false to disable resizing (defaults to true).
     */
    resizable:true,
    /**
     * @cfg {Boolean} draggable
     * True to allow the window to be dragged by the header bar, false to disable dragging (defaults to true).  Note
     * that by default the window will be centered in the viewport, so if dragging is disabled the window may need
     * to be positioned programmatically after render (e.g., myWindow.setPosition(100, 100);).
     */
    draggable:true,
    /**
     * @cfg {Boolean} closable
     * <p>True to display the 'close' tool button and allow the user to close the window, false to
     * hide the button and disallow closing the window (default to true).</p>
     * <p>By default, when close is requested by either clicking the close button in the header
     * or pressing ESC when the Window has focus, the {@link #close} method will be called. This
     * will <i>destroy</i> the Window and its content meaning that it may not be reused.</p>
     * <p>To make closing a Window <i>hide</i> the Window so that it may be reused, set
     * {@link #closeAction} to 'hide'.
     */
    closable : true,
    /**
     * @cfg {Boolean} constrain
     * True to constrain the window to the viewport, false to allow it to fall outside of the viewport
     * (defaults to false).  Optionally the header only can be constrained using {@link #constrainHeader}.
     */
    constrain:false,
    /**
     * @cfg {Boolean} constrainHeader
     * True to constrain the window header to the viewport, allowing the window body to fall outside of the viewport,
     * false to allow the header to fall outside the viewport (defaults to false).  Optionally the entire window
     * can be constrained using {@link #constrain}.
     */
    constrainHeader:false,
    /**
     * @cfg {Boolean} plain
     * True to render the window body with a transparent background so that it will blend into the framing
     * elements, false to add a lighter background color to visually highlight the body element and separate it
     * more distinctly from the surrounding frame (defaults to false).
     */
    plain:false,
    /**
     * @cfg {Boolean} minimizable
     * True to display the 'minimize' tool button and allow the user to minimize the window, false to hide the button
     * and disallow minimizing the window (defaults to false).  Note that this button provides no implementation --
     * the behavior of minimizing a window is implementation-specific, so the minimize event must be handled and a
     * custom minimize behavior implemented for this option to be useful.
     */
    minimizable : false,
    /**
     * @cfg {Boolean} maximizable
     * True to display the 'maximize' tool button and allow the user to maximize the window, false to hide the button
     * and disallow maximizing the window (defaults to false).  Note that when a window is maximized, the tool button
     * will automatically change to a 'restore' button with the appropriate behavior already built-in that will
     * restore the window to its previous size.
     */
    maximizable : false,
    /**
     * @cfg {Number} minHeight
     * The minimum height in pixels allowed for this window (defaults to 100).  Only applies when resizable = true.
     */
    minHeight: 100,
    /**
     * @cfg {Number} minWidth
     * The minimum width in pixels allowed for this window (defaults to 200).  Only applies when resizable = true.
     */
    minWidth: 200,
    /**
     * @cfg {Boolean} expandOnShow
     * True to always expand the window when it is displayed, false to keep it in its current state (which may be
     * collapsed) when displayed (defaults to true).
     */
    expandOnShow: true,
    /**
     * @cfg {String} closeAction
     * The action to take when the close button is clicked.  The default action is 'close' which will actually remove
     * the window from the DOM and destroy it.  The other valid option is 'hide' which will simply hide the window
     * by setting visibility to hidden and applying negative offsets, keeping the window available to be redisplayed
     * via the {@link #show} method.
     */
    closeAction: 'close',
    /**
     * @cfg {String} elements
     * A comma-delimited list of panel elements to initialize when the window is rendered.  Normally, this list will be
     * generated automatically based on the items added to the window at config time, but sometimes it might be useful to
     * make sure a structural element is rendered even if not specified at config time (for example, you may want
     * to add a button or toolbar dynamically after the window has been rendered).  Adding those elements to this
     * list will allocate the required placeholders in the window when it is rendered.  Valid values are<ul>
     * <li><b>header</b> (required)</li>
     * <li><b>tbar</b> (top bar)</li>
     * <li><b>body</b> (required)</li>
     * <li><b>bbar</b> (bottom bar)</li>
     * <li><b>footer</b><li>
     * </ul>
     * Defaults to 'header,body'.
     */
    elements: 'header,body',

    // inherited docs, same default
    collapsible:false,

    // private
    initHidden : true,
    /**
    * @cfg {Boolean} monitorResize @hide
    * This is automatically managed based on the value of constrain and constrainToHeader
    */
    monitorResize : true,
    /** @cfg {Boolean} frame @hide */
    frame:true,
    /** @cfg {Boolean} floating @hide */
    floating:true,

    // private
    initComponent : function(){
        Ext.Window.superclass.initComponent.call(this);
        this.addEvents(
            /**
             * @event activate
             * Fires after the window has been visually activated via {@link setActive}.
             * @param {Ext.Window} this
             */
            /**
             * @event deactivate
             * Fires after the window has been visually deactivated via {@link setActive}.
             * @param {Ext.Window} this
             */
            /**
             * @event resize
             * Fires after the window has been resized.
             * @param {Ext.Window} this
             * @param {Number} width The window's new width
             * @param {Number} height The window's new height
             */
            'resize',
            /**
             * @event maximize
             * Fires after the window has been maximized.
             * @param {Ext.Window} this
             */
            'maximize',
            /**
             * @event minimize
             * Fires after the window has been minimized.
             * @param {Ext.Window} this
             */
            'minimize',
            /**
             * @event restore
             * Fires after the window has been restored to its original size after being maximized.
             * @param {Ext.Window} this
             */
            'restore'
        );
    },

    // private
    getState : function(){
        return Ext.apply(Ext.Window.superclass.getState.call(this) || {}, this.getBox());
    },

    // private
    onRender : function(ct, position){
        Ext.Window.superclass.onRender.call(this, ct, position);

        if(this.plain){
            this.el.addClass('x-window-plain');
        }

        // this element allows the Window to be focused for keyboard events
        this.focusEl = this.el.createChild({
                    tag: "a", href:"#", cls:"x-dlg-focus",
                    tabIndex:"-1", html: "&#160;"});
        this.focusEl.swallowEvent('click', true);

        this.proxy = this.el.createProxy("x-window-proxy");
        this.proxy.enableDisplayMode('block');

        if(this.modal){
            this.mask = this.container.createChild({cls:"ext-el-mask"}, this.el.dom);
            this.mask.enableDisplayMode("block");
            this.mask.hide();
        }
    },

    // private
    initEvents : function(){
        Ext.Window.superclass.initEvents.call(this);
        if(this.animateTarget){
            this.setAnimateTarget(this.animateTarget);
        }

        if(this.resizable){
            this.resizer = new Ext.Resizable(this.el, {
                minWidth: this.minWidth,
                minHeight:this.minHeight,
                handles: this.resizeHandles || "all",
                pinned: true,
                resizeElement : this.resizerAction
            });
            this.resizer.window = this;
            this.resizer.on("beforeresize", this.beforeResize, this);
        }

        if(this.draggable){
            this.header.addClass("x-window-draggable");
        }
        this.initTools();

        this.el.on("mousedown", this.toFront, this);
        this.manager = this.manager || Ext.WindowMgr;
        this.manager.register(this);
        this.hidden = true;
        if(this.maximized){
            this.maximized = false;
            this.maximize();
        }
        if(this.closable){
            var km = this.getKeyMap();
            km.on(27, this.onEsc, this);
            km.disable();
        }
    },

    initDraggable : function(){
        /**
         * If this Window is configured {@link #draggable}, this property will contain
         * an instance of {@link Ext.dd.DD} which handles dragging the Window's DOM Element.
         * @type Ext.dd.DD
         * @property dd
         */
        this.dd = new Ext.Window.DD(this);
    },

   // private
    onEsc : function(){
        this[this.closeAction]();
    },

    // private
    beforeDestroy : function(){
        Ext.destroy(
            this.resizer,
            this.dd,
            this.proxy,
            this.mask
        );
        Ext.Window.superclass.beforeDestroy.call(this);
    },

    // private
    onDestroy : function(){
        if(this.manager){
            this.manager.unregister(this);
        }
        Ext.Window.superclass.onDestroy.call(this);
    },

    // private
    initTools : function(){
        if(this.minimizable){
            this.addTool({
                id: 'minimize',
                handler: this.minimize.createDelegate(this, [])
            });
        }
        if(this.maximizable){
            this.addTool({
                id: 'maximize',
                handler: this.maximize.createDelegate(this, [])
            });
            this.addTool({
                id: 'restore',
                handler: this.restore.createDelegate(this, []),
                hidden:true
            });
            this.header.on('dblclick', this.toggleMaximize, this);
        }
        if(this.closable){
            this.addTool({
                id: 'close',
                handler: this[this.closeAction].createDelegate(this, [])
            });
        }
    },

    // private
    resizerAction : function(){
        var box = this.proxy.getBox();
        this.proxy.hide();
        this.window.handleResize(box);
        return box;
    },

    // private
    beforeResize : function(){
        this.resizer.minHeight = Math.max(this.minHeight, this.getFrameHeight() + 40); // 40 is a magic minimum content size?
        this.resizer.minWidth = Math.max(this.minWidth, this.getFrameWidth() + 40);
        this.resizeBox = this.el.getBox();
    },

    // private
    updateHandles : function(){
        if(Ext.isIE && this.resizer){
            this.resizer.syncHandleHeight();
            this.el.repaint();
        }
    },

    // private
    handleResize : function(box){
        var rz = this.resizeBox;
        if(rz.x != box.x || rz.y != box.y){
            this.updateBox(box);
        }else{
            this.setSize(box);
        }
        this.focus();
        this.updateHandles();
        this.saveState();
        if(this.layout){
            this.doLayout();
        }
        this.fireEvent("resize", this, box.width, box.height);
    },

    /**
     * Focuses the window.  If a defaultButton is set, it will receive focus, otherwise the
     * window itself will receive focus.
     */
    focus : function(){
        var f = this.focusEl, db = this.defaultButton, t = typeof db;
        if(t != 'undefined'){
            if(t == 'number'){
                f = this.buttons[db];
            }else if(t == 'string'){
                f = Ext.getCmp(db);
            }else{
                f = db;
            }
        }
        f.focus.defer(10, f);
    },

    /**
     * Sets the target element from which the window should animate while opening.
     * @param {String/Element} el The target element or id
     */
    setAnimateTarget : function(el){
        el = Ext.get(el);
        this.animateTarget = el;
    },

    // private
    beforeShow : function(){
        delete this.el.lastXY;
        delete this.el.lastLT;
        if(this.x === undefined || this.y === undefined){
            var xy = this.el.getAlignToXY(this.container, 'c-c');
            var pos = this.el.translatePoints(xy[0], xy[1]);
            this.x = this.x === undefined? pos.left : this.x;
            this.y = this.y === undefined? pos.top : this.y;
        }
        this.el.setLeftTop(this.x, this.y);

        if(this.expandOnShow){
            this.expand(false);
        }

        if(this.modal){
            Ext.getBody().addClass("x-body-masked");
            this.mask.setSize(Ext.lib.Dom.getViewWidth(true), Ext.lib.Dom.getViewHeight(true));
            this.mask.show();
        }
    },

    /**
     * Shows the window, rendering it first if necessary, or activates it and brings it to front if hidden.
     * @param {String/Element} animateTarget (optional) The target element or id from which the window should
     * animate while opening (defaults to undefined with no animation)
     * @param {Function} callback (optional) A callback function to call after the window is displayed
     * @param {Object} scope (optional) The scope in which to execute the callback
     */
    show : function(animateTarget, cb, scope){
        if(!this.rendered){
            this.render(Ext.getBody());
        }
        if(this.hidden === false){
            this.toFront();
            return;
        }
        if(this.fireEvent("beforeshow", this) === false){
            return;
        }
        if(cb){
            this.on('show', cb, scope, {single:true});
        }
        this.hidden = false;
        if(animateTarget !== undefined){
            this.setAnimateTarget(animateTarget);
        }
        this.beforeShow();
        if(this.animateTarget){
            this.animShow();
        }else{
            this.afterShow();
        }
    },

    // private
    afterShow : function(){
        this.proxy.hide();
        this.el.setStyle('display', 'block');
        this.el.show();
        if(this.maximized){
            this.fitContainer();
        }
        if(Ext.isMac && Ext.isGecko){ // work around stupid FF 2.0/Mac scroll bar bug
        	this.cascade(this.setAutoScroll);
        }

        if(this.monitorResize || this.modal || this.constrain || this.constrainHeader){
            Ext.EventManager.onWindowResize(this.onWindowResize, this);
        }
        this.doConstrain();
        if(this.layout){
            this.doLayout();
        }
        if(this.keyMap){
            this.keyMap.enable();
        }
        this.toFront();
        this.updateHandles();
        this.fireEvent("show", this);
    },

    // private
    animShow : function(){
        this.proxy.show();
        this.proxy.setBox(this.animateTarget.getBox());
        this.proxy.setOpacity(0);
        var b = this.getBox(false);
        b.callback = this.afterShow;
        b.scope = this;
        b.duration = .25;
        b.easing = 'easeNone';
        b.opacity = .5;
        b.block = true;
        this.el.setStyle('display', 'none');
        this.proxy.shift(b);
    },

    /**
     * Hides the window, setting it to invisible and applying negative offsets.
     * @param {String/Element} animateTarget (optional) The target element or id to which the window should
     * animate while hiding (defaults to null with no animation)
     * @param {Function} callback (optional) A callback function to call after the window is hidden
     * @param {Object} scope (optional) The scope in which to execute the callback
     */
    hide : function(animateTarget, cb, scope){
        if(this.activeGhost){ // drag active?
            this.hide.defer(100, this, [animateTarget, cb, scope]);
            return;
        }
        if(this.hidden || this.fireEvent("beforehide", this) === false){
            return;
        }
        if(cb){
            this.on('hide', cb, scope, {single:true});
        }
        this.hidden = true;
        if(animateTarget !== undefined){
            this.setAnimateTarget(animateTarget);
        }
        if(this.animateTarget){
            this.animHide();
        }else{
            this.el.hide();
            this.afterHide();
        }
    },

    // private
    afterHide : function(){
        this.proxy.hide();
        if(this.monitorResize || this.modal || this.constrain || this.constrainHeader){
            Ext.EventManager.removeResizeListener(this.onWindowResize, this);
        }
        if(this.modal){
            this.mask.hide();
            Ext.getBody().removeClass("x-body-masked");
        }
        if(this.keyMap){
            this.keyMap.disable();
        }
        this.fireEvent("hide", this);
    },

    // private
    animHide : function(){
        this.proxy.setOpacity(.5);
        this.proxy.show();
        var tb = this.getBox(false);
        this.proxy.setBox(tb);
        this.el.hide();
        var b = this.animateTarget.getBox();
        b.callback = this.afterHide;
        b.scope = this;
        b.duration = .25;
        b.easing = 'easeNone';
        b.block = true;
        b.opacity = 0;
        this.proxy.shift(b);
    },

    // private
    onWindowResize : function(){
        if(this.maximized){
            this.fitContainer();
        }
        if(this.modal){
            this.mask.setSize('100%', '100%');
            var force = this.mask.dom.offsetHeight;
            this.mask.setSize(Ext.lib.Dom.getViewWidth(true), Ext.lib.Dom.getViewHeight(true));
        }
        this.doConstrain();
    },

    // private
    doConstrain : function(){
        if(this.constrain || this.constrainHeader){
            var offsets;
            if(this.constrain){
                offsets = {
                    right:this.el.shadowOffset,
                    left:this.el.shadowOffset,
                    bottom:this.el.shadowOffset
                };
            }else {
                var s = this.getSize();
                offsets = {
                    right:-(s.width - 100),
                    bottom:-(s.height - 25)
                };
            }

            var xy = this.el.getConstrainToXY(this.container, true, offsets);
            if(xy){
                this.setPosition(xy[0], xy[1]);
            }
        }
    },

    // private - used for dragging
    ghost : function(cls){
        var ghost = this.createGhost(cls);
        var box = this.getBox(true);
        ghost.setLeftTop(box.x, box.y);
        ghost.setWidth(box.width);
        this.el.hide();
        this.activeGhost = ghost;
        return ghost;
    },

    // private
    unghost : function(show, matchPosition){
        if(show !== false){
            this.el.show();
            this.focus();
	        if(Ext.isMac && Ext.isGecko){ // work around stupid FF 2.0/Mac scroll bar bug
	        	this.cascade(this.setAutoScroll);
	        }
        }
        if(matchPosition !== false){
            this.setPosition(this.activeGhost.getLeft(true), this.activeGhost.getTop(true));
        }
        this.activeGhost.hide();
        this.activeGhost.remove();
        delete this.activeGhost;
    },

    /**
     * Placeholder method for minimizing the window.  By default, this method simply fires the {@link #minimize} event
     * since the behavior of minimizing a window is application-specific.  To implement custom minimize behavior,
     * either the minimize event can be handled or this method can be overridden.
     */
    minimize : function(){
        this.fireEvent('minimize', this);
    },

    /**
     * Closes the window, removes it from the DOM and destroys the window object.  The beforeclose event is fired
     * before the close happens and will cancel the close action if it returns false.
     */
    close : function(){
        if(this.fireEvent("beforeclose", this) !== false){
            this.hide(null, function(){
                this.fireEvent('close', this);
                this.destroy();
            }, this);
        }
    },

    /**
     * Fits the window within its current container and automatically replaces the 'maximize' tool button with
     * the 'restore' tool button.
     */
    maximize : function(){
        if(!this.maximized){
            this.expand(false);
            this.restoreSize = this.getSize();
            this.restorePos = this.getPosition(true);
            if (this.maximizable){
                this.tools.maximize.hide();
                this.tools.restore.show();
            }
            this.maximized = true;
            this.el.disableShadow();

            if(this.dd){
                this.dd.lock();
            }
            if(this.collapsible){
                this.tools.toggle.hide();
            }
            this.el.addClass('x-window-maximized');
            this.container.addClass('x-window-maximized-ct');

            this.setPosition(0, 0);
            this.fitContainer();
            this.fireEvent('maximize', this);
        }
    },

    /**
     * Restores a maximized window back to its original size and position prior to being maximized and also replaces
     * the 'restore' tool button with the 'maximize' tool button.
     */
    restore : function(){
        if(this.maximized){
            this.el.removeClass('x-window-maximized');
            this.tools.restore.hide();
            this.tools.maximize.show();
            this.setPosition(this.restorePos[0], this.restorePos[1]);
            this.setSize(this.restoreSize.width, this.restoreSize.height);
            delete this.restorePos;
            delete this.restoreSize;
            this.maximized = false;
            this.el.enableShadow(true);

            if(this.dd){
                this.dd.unlock();
            }
            if(this.collapsible){
                this.tools.toggle.show();
            }
            this.container.removeClass('x-window-maximized-ct');

            this.doConstrain();
            this.fireEvent('restore', this);
        }
    },

    /**
     * A shortcut method for toggling between {@link #maximize} and {@link #restore} based on the current maximized
     * state of the window.
     */
    toggleMaximize : function(){
        this[this.maximized ? 'restore' : 'maximize']();
    },

    // private
    fitContainer : function(){
        var vs = this.container.getViewSize();
        this.setSize(vs.width, vs.height);
    },

    // private
    // z-index is managed by the WindowManager and may be overwritten at any time
    setZIndex : function(index){
        if(this.modal){
            this.mask.setStyle("z-index", index);
        }
        this.el.setZIndex(++index);
        index += 5;

        if(this.resizer){
            this.resizer.proxy.setStyle("z-index", ++index);
        }

        this.lastZIndex = index;
    },

    /**
     * Aligns the window to the specified element
     * @param {Mixed} element The element to align to.
     * @param {String} position The position to align to (see {@link Ext.Element#alignTo} for more details).
     * @param {Array} offsets (optional) Offset the positioning by [x, y]
     * @return {Ext.Window} this
     */
    alignTo : function(element, position, offsets){
        var xy = this.el.getAlignToXY(element, position, offsets);
        this.setPagePosition(xy[0], xy[1]);
        return this;
    },

    /**
     * Anchors this window to another element and realigns it when the window is resized or scrolled.
     * @param {Mixed} element The element to align to.
     * @param {String} position The position to align to (see {@link Ext.Element#alignTo} for more details)
     * @param {Array} offsets (optional) Offset the positioning by [x, y]
     * @param {Boolean/Number} monitorScroll (optional) true to monitor body scroll and reposition. If this parameter
     * is a number, it is used as the buffer delay (defaults to 50ms).
     * @return {Ext.Window} this
     */
    anchorTo : function(el, alignment, offsets, monitorScroll, _pname){
        var action = function(){
            this.alignTo(el, alignment, offsets);
        };
        Ext.EventManager.onWindowResize(action, this);
        var tm = typeof monitorScroll;
        if(tm != 'undefined'){
            Ext.EventManager.on(window, 'scroll', action, this,
                {buffer: tm == 'number' ? monitorScroll : 50});
        }
        action.call(this);
        this[_pname] = action;
        return this;
    },

    /**
     * Brings this window to the front of any other visible windows
     * @return {Ext.Window} this
     */
    toFront : function(){
        if(this.manager.bringToFront(this)){
            this.focus();
        }
        return this;
    },

    /**
     * Makes this the active window by showing its shadow, or deactivates it by hiding its shadow.  This method also
     * fires the {@link #activate} or {@link #deactivate} event depending on which action occurred.
     * @param {Boolean} active True to activate the window, false to deactivate it (defaults to false)
     */
    setActive : function(active){
        if(active){
            if(!this.maximized){
                this.el.enableShadow(true);
            }
            this.fireEvent('activate', this);
        }else{
            this.el.disableShadow();
            this.fireEvent('deactivate', this);
        }
    },

    /**
     * Sends this window to the back of (lower z-index than) any other visible windows
     * @return {Ext.Window} this
     */
    toBack : function(){
        this.manager.sendToBack(this);
        return this;
    },

    /**
     * Centers this window in the viewport
     * @return {Ext.Window} this
     */
    center : function(){
        var xy = this.el.getAlignToXY(this.container, 'c-c');
        this.setPagePosition(xy[0], xy[1]);
        return this;
    }

    /**
     * @cfg {Boolean} autoWidth @hide
     **/
});
Ext.reg('window', Ext.Window);

// private - custom Window DD implementation
Ext.Window.DD = function(win){
    this.win = win;
    Ext.Window.DD.superclass.constructor.call(this, win.el.id, 'WindowDD-'+win.id);
    this.setHandleElId(win.header.id);
    this.scroll = false;
};

Ext.extend(Ext.Window.DD, Ext.dd.DD, {
    moveOnly:true,
    headerOffsets:[100, 25],
    startDrag : function(){
        var w = this.win;
        this.proxy = w.ghost();
        if(w.constrain !== false){
            var so = w.el.shadowOffset;
            this.constrainTo(w.container, {right: so, left: so, bottom: so});
        }else if(w.constrainHeader !== false){
            var s = this.proxy.getSize();
            this.constrainTo(w.container, {right: -(s.width-this.headerOffsets[0]), bottom: -(s.height-this.headerOffsets[1])});
        }
    },
    b4Drag : Ext.emptyFn,

    onDrag : function(e){
        this.alignElWithMouse(this.proxy, e.getPageX(), e.getPageY());
    },

    endDrag : function(e){
        this.win.unghost();
        this.win.saveState();
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
 * @class Ext.ProgressBar
 * @extends Ext.BoxComponent
 * <p>An updateable progress bar component.  The progress bar supports two different modes: manual and automatic.</p>
 * <p>In manual mode, you are responsible for showing, updating (via {@link #updateProgress}) and clearing the
 * progress bar as needed from your own code.  This method is most appropriate when you want to show progress
 * throughout an operation that has predictable points of interest at which you can update the control.</p>
 * <p>In automatic mode, you simply call {@link #wait} and let the progress bar run indefinitely, only clearing it
 * once the operation is complete.  You can optionally have the progress bar wait for a specific amount of time
 * and then clear itself.  Automatic mode is most appropriate for timed operations or asymchronous operations in
 * which you have no need for indicating intermediate progress.</p>
 * @cfg {Float} value A floating point value between 0 and 1 (e.g., .5, defaults to 0)
 * @cfg {String} text The progress bar text (defaults to '')
 * @cfg {Mixed} textEl The element to render the progress text to (defaults to the progress
 * bar's internal text element)
 * @cfg {String} id The progress bar element's id (defaults to an auto-generated id)
 */
Ext.ProgressBar = Ext.extend(Ext.BoxComponent, {
   /**
    * @cfg {String} baseCls
    * The base CSS class to apply to the progress bar's wrapper element (defaults to 'x-progress')
    */
    baseCls : 'x-progress',

    // private
    waitTimer : null,

    // private
    initComponent : function(){
        Ext.ProgressBar.superclass.initComponent.call(this);
        this.addEvents(
            /**
             * @event update
             * Fires after each update interval
             * @param {Ext.ProgressBar} this
             * @param {Number} The current progress value
             * @param {String} The current progress text
             */
            "update"
        );
    },

    // private
    onRender : function(ct, position){
        Ext.ProgressBar.superclass.onRender.call(this, ct, position);

        var tpl = new Ext.Template(
            '<div class="{cls}-wrap">',
                '<div class="{cls}-inner">',
                    '<div class="{cls}-bar">',
                        '<div class="{cls}-text">',
                            '<div>&#160;</div>',
                        '</div>',
                    '</div>',
                    '<div class="{cls}-text {cls}-text-back">',
                        '<div>&#160;</div>',
                    '</div>',
                '</div>',
            '</div>'
        );

        if(position){
            this.el = tpl.insertBefore(position, {cls: this.baseCls}, true);
        }else{
            this.el = tpl.append(ct, {cls: this.baseCls}, true);
        }
        if(this.id){
            this.el.dom.id = this.id;
        }
        var inner = this.el.dom.firstChild;
        this.progressBar = Ext.get(inner.firstChild);

        if(this.textEl){
            //use an external text el
            this.textEl = Ext.get(this.textEl);
            delete this.textTopEl;
        }else{
            //setup our internal layered text els
            this.textTopEl = Ext.get(this.progressBar.dom.firstChild);
            var textBackEl = Ext.get(inner.childNodes[1]);
            this.textTopEl.setStyle("z-index", 99).addClass('x-hidden');
            this.textEl = new Ext.CompositeElement([this.textTopEl.dom.firstChild, textBackEl.dom.firstChild]);
            this.textEl.setWidth(inner.offsetWidth);
        }
        this.progressBar.setHeight(inner.offsetHeight);
    },
    
    // private
	afterRender : function(){
		Ext.ProgressBar.superclass.afterRender.call(this);
		if(this.value){
			this.updateProgress(this.value, this.text);
		}else{
			this.updateText(this.text);
		}
	},

    /**
     * Updates the progress bar value, and optionally its text.  If the text argument is not specified,
     * any existing text value will be unchanged.  To blank out existing text, pass ''.  Note that even
     * if the progress bar value exceeds 1, it will never automatically reset -- you are responsible for
     * determining when the progress is complete and calling {@link #reset} to clear and/or hide the control.
     * @param {Float} value (optional) A floating point value between 0 and 1 (e.g., .5, defaults to 0)
     * @param {String} text (optional) The string to display in the progress text element (defaults to '')
     * @return {Ext.ProgressBar} this
     */
    updateProgress : function(value, text){
        this.value = value || 0;
        if(text){
            this.updateText(text);
        }
        if(this.rendered){
	        var w = Math.floor(value*this.el.dom.firstChild.offsetWidth);
	        this.progressBar.setWidth(w);
	        if(this.textTopEl){
	            //textTopEl should be the same width as the bar so overflow will clip as the bar moves
	            this.textTopEl.removeClass('x-hidden').setWidth(w);
	        }
        }
        this.fireEvent('update', this, value, text);
        return this;
    },

    /**
     * Initiates an auto-updating progress bar.  A duration can be specified, in which case the progress
     * bar will automatically reset after a fixed amount of time and optionally call a callback function
     * if specified.  If no duration is passed in, then the progress bar will run indefinitely and must
     * be manually cleared by calling {@link #reset}.  The wait method accepts a config object with
     * the following properties:
     * <pre>
Property   Type          Description
---------- ------------  ----------------------------------------------------------------------
duration   Number        The length of time in milliseconds that the progress bar should
                         run before resetting itself (defaults to undefined, in which case it
                         will run indefinitely until reset is called)
interval   Number        The length of time in milliseconds between each progress update
                         (defaults to 1000 ms)
increment  Number        The number of progress update segments to display within the progress
                         bar (defaults to 10).  If the bar reaches the end and is still
                         updating, it will automatically wrap back to the beginning.
text       String        Optional text to display in the progress bar element (defaults to '').
fn         Function      A callback function to execute after the progress bar finishes auto-
                         updating.  The function will be called with no arguments.  This function
                         will be ignored if duration is not specified since in that case the
                         progress bar can only be stopped programmatically, so any required function
                         should be called by the same code after it resets the progress bar.
scope      Object        The scope that is passed to the callback function (only applies when
                         duration and fn are both passed).
</pre>
         *
         * Example usage:
         * <pre><code>
var p = new Ext.ProgressBar({
   renderTo: 'my-el'
});

//Wait for 5 seconds, then update the status el (progress bar will auto-reset)
p.wait({
   interval: 100, //bar will move fast!
   duration: 5000,
   increment: 15,
   text: 'Updating...',
   scope: this,
   fn: function(){
      Ext.fly('status').update('Done!');
   }
});

//Or update indefinitely until some async action completes, then reset manually
p.wait();
myAction.on('complete', function(){
    p.reset();
    Ext.fly('status').update('Done!');
});
</code></pre>
     * @param {Object} config (optional) Configuration options
     * @return {Ext.ProgressBar} this
     */
    wait : function(o){
        if(!this.waitTimer){
            var scope = this;
            o = o || {};
            this.updateText(o.text);
            this.waitTimer = Ext.TaskMgr.start({
                run: function(i){
                    var inc = o.increment || 10;
                    this.updateProgress(((((i+inc)%inc)+1)*(100/inc))*.01);
                },
                interval: o.interval || 1000,
                duration: o.duration,
                onStop: function(){
                    if(o.fn){
                        o.fn.apply(o.scope || this);
                    }
                    this.reset();
                },
                scope: scope
            });
        }
        return this;
    },

    /**
     * Returns true if the progress bar is currently in a {@link #wait} operation
     * @return {Boolean} True if waiting, else false
     */
    isWaiting : function(){
        return this.waitTimer != null;
    },

    /**
     * Updates the progress bar text.  If specified, textEl will be updated, otherwise the progress
     * bar itself will display the updated text.
     * @param {String} text (optional) The string to display in the progress text element (defaults to '')
     * @return {Ext.ProgressBar} this
     */
    updateText : function(text){
        this.text = text || '&#160;';
        if(this.rendered){
            this.textEl.update(this.text);
        }
        return this;
    },
    
    /**
     * Synchronizes the inner bar width to the proper proportion of the total componet width based
     * on the current progress {@link #value}.  This will be called automatically when the ProgressBar
     * is resized by a layout, but if it is rendered auto width, this method can be called from
     * another resize handler to sync the ProgressBar if necessary.
     */
    syncProgressBar : function(){
        if(this.value){
            this.updateProgress(this.value, this.text);
        }
        return this;
    },

    /**
     * Sets the size of the progress bar.
     * @param {Number} width The new width in pixels
     * @param {Number} height The new height in pixels
     * @return {Ext.ProgressBar} this
     */
    setSize : function(w, h){
        Ext.ProgressBar.superclass.setSize.call(this, w, h);
        if(this.textTopEl){
            var inner = this.el.dom.firstChild;
            this.textEl.setSize(inner.offsetWidth, inner.offsetHeight);
        }
        this.syncProgressBar();
        return this;
    },

    /**
     * Resets the progress bar value to 0 and text to empty string.  If hide = true, the progress
     * bar will also be hidden (using the {@link #hideMode} property internally).
     * @param {Boolean} hide (optional) True to hide the progress bar (defaults to false)
     * @return {Ext.ProgressBar} this
     */
    reset : function(hide){
        this.updateProgress(0);
        if(this.textTopEl){
            this.textTopEl.addClass('x-hidden');
        }
        if(this.waitTimer){
            this.waitTimer.onStop = null; //prevent recursion
            Ext.TaskMgr.stop(this.waitTimer);
            this.waitTimer = null;
        }
        if(hide === true){
            this.hide();
        }
        return this;
    }
});
Ext.reg('progress', Ext.ProgressBar);
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.MessageBox
 * <p>Utility class for generating different styles of message boxes.  The alias Ext.Msg can also be used.<p/>
 * <p>Note that the MessageBox is asynchronous.  Unlike a regular JavaScript <code>alert</code> (which will halt
 * browser execution), showing a MessageBox will not cause the code to stop.  For this reason, if you have code
 * that should only run <em>after</em> some user feedback from the MessageBox, you must use a callback function
 * (see the <code>function</code> parameter for {@link #show} for more details).</p>
 * <p>Example usage:</p>
 *<pre><code>
// Basic alert:
Ext.Msg.alert('Status', 'Changes saved successfully.');

// Prompt for user data and process the result using a callback:
Ext.Msg.prompt('Name', 'Please enter your name:', function(btn, text){
    if (btn == 'ok'){
        // process text value and close...
    }
});

// Show a dialog using config options:
Ext.Msg.show({
   title:'Save Changes?',
   msg: 'You are closing a tab that has unsaved changes. Would you like to save your changes?',
   buttons: Ext.Msg.YESNOCANCEL,
   fn: processResult,
   animEl: 'elId',
   icon: Ext.MessageBox.QUESTION
});
</code></pre>
 * @singleton
 */
Ext.MessageBox = function(){
    var dlg, opt, mask, waitTimer;
    var bodyEl, msgEl, textboxEl, textareaEl, progressBar, pp, iconEl, spacerEl;
    var buttons, activeTextEl, bwidth, iconCls = '';

    // private
    var handleButton = function(button){
        if(dlg.isVisible()){
            dlg.hide();
            Ext.callback(opt.fn, opt.scope||window, [button, activeTextEl.dom.value], 1);
        }
    };

    // private
    var handleHide = function(){
        if(opt && opt.cls){
            dlg.el.removeClass(opt.cls);
        }
        progressBar.reset();
    };

    // private
    var handleEsc = function(d, k, e){
        if(opt && opt.closable !== false){
            dlg.hide();
        }
        if(e){
            e.stopEvent();
        }
    };

    // private
    var updateButtons = function(b){
        var width = 0;
        if(!b){
            buttons["ok"].hide();
            buttons["cancel"].hide();
            buttons["yes"].hide();
            buttons["no"].hide();
            return width;
        }
        dlg.footer.dom.style.display = '';
        for(var k in buttons){
            if(typeof buttons[k] != "function"){
                if(b[k]){
                    buttons[k].show();
                    buttons[k].setText(typeof b[k] == "string" ? b[k] : Ext.MessageBox.buttonText[k]);
                    width += buttons[k].el.getWidth()+15;
                }else{
                    buttons[k].hide();
                }
            }
        }
        return width;
    };

    return {
        /**
         * Returns a reference to the underlying {@link Ext.Window} element
         * @return {Ext.Window} The window
         */
        getDialog : function(titleText){
           if(!dlg){
                dlg = new Ext.Window({
                    autoCreate : true,
                    title:titleText,
                    resizable:false,
                    constrain:true,
                    constrainHeader:true,
                    minimizable : false,
                    maximizable : false,
                    stateful: false,
                    modal: true,
                    shim:true,
                    buttonAlign:"center",
                    width:400,
                    height:100,
                    minHeight: 80,
                    plain:true,
                    footer:true,
                    closable:true,
                    close : function(){
                        if(opt && opt.buttons && opt.buttons.no && !opt.buttons.cancel){
                            handleButton("no");
                        }else{
                            handleButton("cancel");
                        }
                    }
                });
                buttons = {};
                var bt = this.buttonText;
                //TODO: refactor this block into a buttons config to pass into the Window constructor
                buttons["ok"] = dlg.addButton(bt["ok"], handleButton.createCallback("ok"));
                buttons["yes"] = dlg.addButton(bt["yes"], handleButton.createCallback("yes"));
                buttons["no"] = dlg.addButton(bt["no"], handleButton.createCallback("no"));
                buttons["cancel"] = dlg.addButton(bt["cancel"], handleButton.createCallback("cancel"));
                buttons["ok"].hideMode = buttons["yes"].hideMode = buttons["no"].hideMode = buttons["cancel"].hideMode = 'offsets';
                dlg.render(document.body);
                dlg.getEl().addClass('x-window-dlg');
                mask = dlg.mask;
                bodyEl = dlg.body.createChild({
                    html:'<div class="ext-mb-icon"></div><div class="ext-mb-content"><span class="ext-mb-text"></span><br /><div class="ext-mb-fix-cursor"><input type="text" class="ext-mb-input" /><textarea class="ext-mb-textarea"></textarea></div></div>'
                });
                iconEl = Ext.get(bodyEl.dom.firstChild);
                var contentEl = bodyEl.dom.childNodes[1];
                msgEl = Ext.get(contentEl.firstChild);
                textboxEl = Ext.get(contentEl.childNodes[2].firstChild);
                textboxEl.enableDisplayMode();
                textboxEl.addKeyListener([10,13], function(){
                    if(dlg.isVisible() && opt && opt.buttons){
                        if(opt.buttons.ok){
                            handleButton("ok");
                        }else if(opt.buttons.yes){
                            handleButton("yes");
                        }
                    }
                });
                textareaEl = Ext.get(contentEl.childNodes[2].childNodes[1]);
                textareaEl.enableDisplayMode();
                progressBar = new Ext.ProgressBar({
                    renderTo:bodyEl
                });
               bodyEl.createChild({cls:'x-clear'});
            }
            return dlg;
        },

        /**
         * Updates the message box body text
         * @param {String} text (optional) Replaces the message box element's innerHTML with the specified string (defaults to
         * the XHTML-compliant non-breaking space character '&amp;#160;')
         * @return {Ext.MessageBox} this
         */
        updateText : function(text){
            if(!dlg.isVisible() && !opt.width){
                dlg.setSize(this.maxWidth, 100); // resize first so content is never clipped from previous shows
            }
            msgEl.update(text || '&#160;');

            var iw = iconCls != '' ? (iconEl.getWidth() + iconEl.getMargins('lr')) : 0;
            var mw = msgEl.getWidth() + msgEl.getMargins('lr');
            var fw = dlg.getFrameWidth('lr');
            var bw = dlg.body.getFrameWidth('lr');
            if (Ext.isIE && iw > 0){
                //3 pixels get subtracted in the icon CSS for an IE margin issue,
                //so we have to add it back here for the overall width to be consistent
                iw += 3;
            }
            var w = Math.max(Math.min(opt.width || iw+mw+fw+bw, this.maxWidth),
                        Math.max(opt.minWidth || this.minWidth, bwidth || 0));

            if(opt.prompt === true){
                activeTextEl.setWidth(w-iw-fw-bw);
            }
            if(opt.progress === true || opt.wait === true){
                progressBar.setSize(w-iw-fw-bw);
            }
            dlg.setSize(w, 'auto').center();
            return this;
        },

        /**
         * Updates a progress-style message box's text and progress bar.  Only relevant on message boxes
         * initiated via {@link Ext.MessageBox#progress} or by calling {@link Ext.MessageBox#show} with progress: true.
         * @param {Number} value Any number between 0 and 1 (e.g., .5, defaults to 0)
         * @param {String} progressText The progress text to display inside the progress bar (defaults to '')
         * @param {String} msg The message box's body text is replaced with the specified string (defaults to undefined
         * so that any existing body text will not get overwritten by default unless a new value is passed in)
         * @return {Ext.MessageBox} this
         */
        updateProgress : function(value, progressText, msg){
            progressBar.updateProgress(value, progressText);
            if(msg){
                this.updateText(msg);
            }
            return this;
        },

        /**
         * Returns true if the message box is currently displayed
         * @return {Boolean} True if the message box is visible, else false
         */
        isVisible : function(){
            return dlg && dlg.isVisible();
        },

        /**
         * Hides the message box if it is displayed
         * @return {Ext.MessageBox} this
         */
        hide : function(){
            if(this.isVisible()){
                dlg.hide();
                handleHide();
            }
            return this;
        },

        /**
         * Displays a new message box, or reinitializes an existing message box, based on the config options
         * passed in. All display functions (e.g. prompt, alert, etc.) on MessageBox call this function internally,
         * although those calls are basic shortcuts and do not support all of the config options allowed here.
         * @param {Object} config The following config options are supported: <ul>
         * <li><b>animEl</b> : String/Element<div class="sub-desc">An id or Element from which the message box should animate as it
         * opens and closes (defaults to undefined)</div></li>
         * <li><b>buttons</b> : Object/Boolean<div class="sub-desc">A button config object (e.g., Ext.MessageBox.OKCANCEL or {ok:'Foo',
         * cancel:'Bar'}), or false to not show any buttons (defaults to false)</div></li>
         * <li><b>closable</b> : Boolean<div class="sub-desc">False to hide the top-right close button (defaults to true). Note that
         * progress and wait dialogs will ignore this property and always hide the close button as they can only
         * be closed programmatically.</div></li>
         * <li><b>cls</b> : String<div class="sub-desc">A custom CSS class to apply to the message box's container element</div></li>
         * <li><b>defaultTextHeight</b> : Number<div class="sub-desc">The default height in pixels of the message box's multiline textarea
         * if displayed (defaults to 75)</div></li>
         * <li><b>fn</b> : Function<div class="sub-desc">A callback function which is called when the dialog is dismissed either
         * by clicking on the configured buttons, or on the dialog close button, or by pressing
         * the return button to enter input.
         * <p>Progress and wait dialogs will ignore this option since they do not respond to user
         * actions and can only be closed programmatically, so any required function should be called
         * by the same code after it closes the dialog. Parameters passed:<ul>
         * <li><b>buttonId</b> : String<div class="sub-desc">The ID of the button pressed, one of:<div class="sub-desc"><ul>
         * <li><tt>ok</tt></li>
         * <li><tt>yes</tt></li>
         * <li><tt>no</tt></li>
         * <li><tt>cancel</tt></li>
         * </ul></div></div></li>
         * <li><b>text</b> : String<div class="sub-desc">Value of the input field if either <tt>{@link #show-option-prompt prompt}</tt>
         * or <tt>{@link #show-option-multiline multiline}</tt> is true</div></li>
         * </p></div></li>
         * <li><b>scope</b> : Object<div class="sub-desc">The scope of the callback function</div></li>
         * <li><b>icon</b> : String<div class="sub-desc">A CSS class that provides a background image to be used as the body icon for the
         * dialog (e.g. Ext.MessageBox.WARNING or 'custom-class') (defaults to '')</div></li>
         * <li><b>iconCls</b> : String<div class="sub-desc">The standard {@link Ext.Window#iconCls} to
         * add an optional header icon (defaults to '')</div></li>
         * <li><b>maxWidth</b> : Number<div class="sub-desc">The maximum width in pixels of the message box (defaults to 600)</div></li>
         * <li><b>minWidth</b> : Number<div class="sub-desc">The minimum width in pixels of the message box (defaults to 100)</div></li>
         * <li><b>modal</b> : Boolean<div class="sub-desc">False to allow user interaction with the page while the message box is
         * displayed (defaults to true)</div></li>
         * <li><b>msg</b> : String<div class="sub-desc">A string that will replace the existing message box body text (defaults to the
         * XHTML-compliant non-breaking space character '&amp;#160;')</div></li>
         * <a id="show-option-multiline"></a><li><b>multiline</b> : Boolean<div class="sub-desc">
         * True to prompt the user to enter multi-line text (defaults to false)</div></li>
         * <li><b>progress</b> : Boolean<div class="sub-desc">True to display a progress bar (defaults to false)</div></li>
         * <li><b>progressText</b> : String<div class="sub-desc">The text to display inside the progress bar if progress = true (defaults to '')</div></li>
         * <a id="show-option-prompt"></a><li><b>prompt</b> : Boolean<div class="sub-desc">True to prompt the user to enter single-line text (defaults to false)</div></li>
         * <li><b>proxyDrag</b> : Boolean<div class="sub-desc">True to display a lightweight proxy while dragging (defaults to false)</div></li>
         * <li><b>title</b> : String<div class="sub-desc">The title text</div></li>
         * <li><b>value</b> : String<div class="sub-desc">The string value to set into the active textbox element if displayed</div></li>
         * <li><b>wait</b> : Boolean<div class="sub-desc">True to display a progress bar (defaults to false)</div></li>
         * <li><b>waitConfig</b> : Object<div class="sub-desc">A {@link Ext.ProgressBar#waitConfig} object (applies only if wait = true)</div></li>
         * <li><b>width</b> : Number<div class="sub-desc">The width of the dialog in pixels</div></li>
         * </ul>
         * Example usage:
         * <pre><code>
Ext.Msg.show({
   title: 'Address',
   msg: 'Please enter your address:',
   width: 300,
   buttons: Ext.MessageBox.OKCANCEL,
   multiline: true,
   fn: saveAddress,
   animEl: 'addAddressBtn',
   icon: Ext.MessageBox.INFO
});
</code></pre>
         * @return {Ext.MessageBox} this
         */
        show : function(options){
            if(this.isVisible()){
                this.hide();
            }
            opt = options;
            var d = this.getDialog(opt.title || "&#160;");

            d.setTitle(opt.title || "&#160;");
            var allowClose = (opt.closable !== false && opt.progress !== true && opt.wait !== true);
            d.tools.close.setDisplayed(allowClose);
            activeTextEl = textboxEl;
            opt.prompt = opt.prompt || (opt.multiline ? true : false);
            if(opt.prompt){
                if(opt.multiline){
                    textboxEl.hide();
                    textareaEl.show();
                    textareaEl.setHeight(typeof opt.multiline == "number" ?
                        opt.multiline : this.defaultTextHeight);
                    activeTextEl = textareaEl;
                }else{
                    textboxEl.show();
                    textareaEl.hide();
                }
            }else{
                textboxEl.hide();
                textareaEl.hide();
            }
            activeTextEl.dom.value = opt.value || "";
            if(opt.prompt){
                d.focusEl = activeTextEl;
            }else{
                var bs = opt.buttons;
                var db = null;
                if(bs && bs.ok){
                    db = buttons["ok"];
                }else if(bs && bs.yes){
                    db = buttons["yes"];
                }
                if (db){
                    d.focusEl = db;
                }
            }
            if(opt.iconCls){
              d.setIconClass(opt.iconCls);
            }
            this.setIcon(opt.icon);
            bwidth = updateButtons(opt.buttons);
            progressBar.setVisible(opt.progress === true || opt.wait === true);
            this.updateProgress(0, opt.progressText);
            this.updateText(opt.msg);
            if(opt.cls){
                d.el.addClass(opt.cls);
            }
            d.proxyDrag = opt.proxyDrag === true;
            d.modal = opt.modal !== false;
            d.mask = opt.modal !== false ? mask : false;
            if(!d.isVisible()){
                // force it to the end of the z-index stack so it gets a cursor in FF
                document.body.appendChild(dlg.el.dom);
                d.setAnimateTarget(opt.animEl);
                d.show(opt.animEl);
            }

            //workaround for window internally enabling keymap in afterShow
            d.on('show', function(){
                if(allowClose === true){
                    d.keyMap.enable();
                }else{
                    d.keyMap.disable();
                }
            }, this, {single:true});

            if(opt.wait === true){
                progressBar.wait(opt.waitConfig);
            }
            return this;
        },

        /**
         * Adds the specified icon to the dialog.  By default, the class 'ext-mb-icon' is applied for default
         * styling, and the class passed in is expected to supply the background image url. Pass in empty string ('')
         * to clear any existing icon.  The following built-in icon classes are supported, but you can also pass
         * in a custom class name:
         * <pre>
Ext.MessageBox.INFO
Ext.MessageBox.WARNING
Ext.MessageBox.QUESTION
Ext.MessageBox.ERROR
         *</pre>
         * @param {String} icon A CSS classname specifying the icon's background image url, or empty string to clear the icon
         * @return {Ext.MessageBox} this
         */
        setIcon : function(icon){
            if(icon && icon != ''){
                iconEl.removeClass('x-hidden');
                iconEl.replaceClass(iconCls, icon);
                iconCls = icon;
            }else{
                iconEl.replaceClass(iconCls, 'x-hidden');
                iconCls = '';
            }
            return this;
        },

        /**
         * Displays a message box with a progress bar.  This message box has no buttons and is not closeable by
         * the user.  You are responsible for updating the progress bar as needed via {@link Ext.MessageBox#updateProgress}
         * and closing the message box when the process is complete.
         * @param {String} title The title bar text
         * @param {String} msg The message box body text
         * @param {String} progressText (optional) The text to display inside the progress bar (defaults to '')
         * @return {Ext.MessageBox} this
         */
        progress : function(title, msg, progressText){
            this.show({
                title : title,
                msg : msg,
                buttons: false,
                progress:true,
                closable:false,
                minWidth: this.minProgressWidth,
                progressText: progressText
            });
            return this;
        },

        /**
         * Displays a message box with an infinitely auto-updating progress bar.  This can be used to block user
         * interaction while waiting for a long-running process to complete that does not have defined intervals.
         * You are responsible for closing the message box when the process is complete.
         * @param {String} msg The message box body text
         * @param {String} title (optional) The title bar text
         * @param {Object} config (optional) A {@link Ext.ProgressBar#waitConfig} object
         * @return {Ext.MessageBox} this
         */
        wait : function(msg, title, config){
            this.show({
                title : title,
                msg : msg,
                buttons: false,
                closable:false,
                wait:true,
                modal:true,
                minWidth: this.minProgressWidth,
                waitConfig: config
            });
            return this;
        },

        /**
         * Displays a standard read-only message box with an OK button (comparable to the basic JavaScript alert prompt).
         * If a callback function is passed it will be called after the user clicks the button, and the
         * id of the button that was clicked will be passed as the only parameter to the callback
         * (could also be the top-right close button).
         * @param {String} title The title bar text
         * @param {String} msg The message box body text
         * @param {Function} fn (optional) The callback function invoked after the message box is closed
         * @param {Object} scope (optional) The scope of the callback function
         * @return {Ext.MessageBox} this
         */
        alert : function(title, msg, fn, scope){
            this.show({
                title : title,
                msg : msg,
                buttons: this.OK,
                fn: fn,
                scope : scope
            });
            return this;
        },

        /**
         * Displays a confirmation message box with Yes and No buttons (comparable to JavaScript's confirm).
         * If a callback function is passed it will be called after the user clicks either button,
         * and the id of the button that was clicked will be passed as the only parameter to the callback
         * (could also be the top-right close button).
         * @param {String} title The title bar text
         * @param {String} msg The message box body text
         * @param {Function} fn (optional) The callback function invoked after the message box is closed
         * @param {Object} scope (optional) The scope of the callback function
         * @return {Ext.MessageBox} this
         */
        confirm : function(title, msg, fn, scope){
            this.show({
                title : title,
                msg : msg,
                buttons: this.YESNO,
                fn: fn,
                scope : scope,
                icon: this.QUESTION
            });
            return this;
        },

        /**
         * Displays a message box with OK and Cancel buttons prompting the user to enter some text (comparable to JavaScript's prompt).
         * The prompt can be a single-line or multi-line textbox.  If a callback function is passed it will be called after the user
         * clicks either button, and the id of the button that was clicked (could also be the top-right
         * close button) and the text that was entered will be passed as the two parameters to the callback.
         * @param {String} title The title bar text
         * @param {String} msg The message box body text
         * @param {Function} fn (optional) The callback function invoked after the message box is closed
         * @param {Object} scope (optional) The scope of the callback function
         * @param {Boolean/Number} multiline (optional) True to create a multiline textbox using the defaultTextHeight
         * property, or the height in pixels to create the textbox (defaults to false / single-line)
         * @param {String} value (optional) Default value of the text input element (defaults to '')
         * @return {Ext.MessageBox} this
         */
        prompt : function(title, msg, fn, scope, multiline, value){
            this.show({
                title : title,
                msg : msg,
                buttons: this.OKCANCEL,
                fn: fn,
                minWidth:250,
                scope : scope,
                prompt:true,
                multiline: multiline,
                value: value
            });
            return this;
        },

        /**
         * Button config that displays a single OK button
         * @type Object
         */
        OK : {ok:true},
        /**
         * Button config that displays a single Cancel button
         * @type Object
         */
        CANCEL : {cancel:true},
        /**
         * Button config that displays OK and Cancel buttons
         * @type Object
         */
        OKCANCEL : {ok:true, cancel:true},
        /**
         * Button config that displays Yes and No buttons
         * @type Object
         */
        YESNO : {yes:true, no:true},
        /**
         * Button config that displays Yes, No and Cancel buttons
         * @type Object
         */
        YESNOCANCEL : {yes:true, no:true, cancel:true},
        /**
         * The CSS class that provides the INFO icon image
         * @type String
         */
        INFO : 'ext-mb-info',
        /**
         * The CSS class that provides the WARNING icon image
         * @type String
         */
        WARNING : 'ext-mb-warning',
        /**
         * The CSS class that provides the QUESTION icon image
         * @type String
         */
        QUESTION : 'ext-mb-question',
        /**
         * The CSS class that provides the ERROR icon image
         * @type String
         */
        ERROR : 'ext-mb-error',

        /**
         * The default height in pixels of the message box's multiline textarea if displayed (defaults to 75)
         * @type Number
         */
        defaultTextHeight : 75,
        /**
         * The maximum width in pixels of the message box (defaults to 600)
         * @type Number
         */
        maxWidth : 600,
        /**
         * The minimum width in pixels of the message box (defaults to 100)
         * @type Number
         */
        minWidth : 100,
        /**
         * The minimum width in pixels of the message box if it is a progress-style dialog.  This is useful
         * for setting a different minimum width than text-only dialogs may need (defaults to 250)
         * @type Number
         */
        minProgressWidth : 250,
        /**
         * An object containing the default button text strings that can be overriden for localized language support.
         * Supported properties are: ok, cancel, yes and no.  Generally you should include a locale-specific
         * resource file for handling language support across the framework.
         * Customize the default text like so: Ext.MessageBox.buttonText.yes = "oui"; //french
         * @type Object
         */
        buttonText : {
            ok : "OK",
            cancel : "Cancel",
            yes : "Yes",
            no : "No"
        }
    };
}();

/**
 * Shorthand for {@link Ext.MessageBox}
 */
Ext.Msg = Ext.MessageBox;
