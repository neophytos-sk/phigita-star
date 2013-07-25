/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.BaseItem
 * @extends Ext.Component
 * The base class for all items that render into menus.  BaseItem provides default rendering, activated state
 * management and base configuration options shared by all menu components.
 * @constructor
 * Creates a new BaseItem
 * @param {Object} config Configuration options
 */
Ext.menu.BaseItem = function(config){
    Ext.menu.BaseItem.superclass.constructor.call(this, config);

    this.addEvents(
        /**
         * @event click
         * Fires when this item is clicked
         * @param {Ext.menu.BaseItem} this
         * @param {Ext.EventObject} e
         */
        'click',
        /**
         * @event activate
         * Fires when this item is activated
         * @param {Ext.menu.BaseItem} this
         */
        'activate',
        /**
         * @event deactivate
         * Fires when this item is deactivated
         * @param {Ext.menu.BaseItem} this
         */
        'deactivate'
    );

    if(this.handler){
        this.on("click", this.handler, this.scope);
    }
};

Ext.extend(Ext.menu.BaseItem, Ext.Component, {
    /**
     * @cfg {Function} handler
     * A function that will handle the click event of this menu item (defaults to undefined)
     */
    /**
     * @cfg {Object} scope
     * The scope in which the handler function will be called.
     */
    /**
     * @cfg {Boolean} canActivate True if this item can be visually activated (defaults to false)
     */
    canActivate : false,
    /**
     * @cfg {String} activeClass The CSS class to use when the item becomes activated (defaults to "x-menu-item-active")
     */
    activeClass : "x-menu-item-active",
    /**
     * @cfg {Boolean} hideOnClick True to hide the containing menu after this item is clicked (defaults to true)
     */
    hideOnClick : true,
    /**
     * @cfg {Number} hideDelay Length of time in milliseconds to wait before hiding after a click (defaults to 100)
     */
    hideDelay : 100,

    // private
    ctype: "Ext.menu.BaseItem",

    // private
    actionMode : "container",

    // private
    render : function(container, parentMenu){
        this.parentMenu = parentMenu;
        Ext.menu.BaseItem.superclass.render.call(this, container);
        this.container.menuItemId = this.id;
    },

    // private
    onRender : function(container, position){
        this.el = Ext.get(this.el);
        container.dom.appendChild(this.el.dom);
    },

    /**
     * Sets the function that will handle click events for this item (equivalent to passing in the {@link #handler}
     * config property).  If an existing handler is already registered, it will be unregistered for you.
     * @param {Function} handler The function that should be called on click
     * @param {Object} scope The scope that should be passed to the handler
     */
    setHandler : function(handler, scope){
        if(this.handler){
            this.un("click", this.handler, this.scope);
        }
        this.on("click", this.handler = handler, this.scope = scope);
    },

    // private
    onClick : function(e){
        if(!this.disabled && this.fireEvent("click", this, e) !== false
                && this.parentMenu.fireEvent("itemclick", this, e) !== false){
            this.handleClick(e);
        }else{
            e.stopEvent();
        }
    },

    // private
    activate : function(){
        if(this.disabled){
            return false;
        }
        var li = this.container;
        li.addClass(this.activeClass);
        this.region = li.getRegion().adjust(2, 2, -2, -2);
        this.fireEvent("activate", this);
        return true;
    },

    // private
    deactivate : function(){
        this.container.removeClass(this.activeClass);
        this.fireEvent("deactivate", this);
    },

    // private
    shouldDeactivate : function(e){
        return !this.region || !this.region.contains(e.getPoint());
    },

    // private
    handleClick : function(e){
        if(this.hideOnClick){
            this.parentMenu.hide.defer(this.hideDelay, this.parentMenu, [true]);
        }
    },

    // private
    expandMenu : function(autoActivate){
        // do nothing
    },

    // private
    hideMenu : function(){
        // do nothing
    }
});
/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.Item
 * @extends Ext.menu.BaseItem
 * A base class for all menu items that require menu-related functionality (like sub-menus) and are not static
 * display items.  Item extends the base functionality of {@link Ext.menu.BaseItem} by adding menu-specific
 * activation and click handling.
 * @constructor
 * Creates a new Item
 * @param {Object} config Configuration options
 */
Ext.menu.Item = function(config){
    Ext.menu.Item.superclass.constructor.call(this, config);
    if(this.menu){
        this.menu = Ext.menu.MenuMgr.get(this.menu);
    }
};
Ext.extend(Ext.menu.Item, Ext.menu.BaseItem, {
    /**
     * @cfg {String} icon The path to an icon to display in this item (defaults to Ext.BLANK_IMAGE_URL).  If
     * icon is specified {@link #iconCls} should not be.
     */
    /**
     * @cfg {String} iconCls A CSS class that specifies a background image that will be used as the icon for
     * this item (defaults to '').  If iconCls is specified {@link #icon} should not be.
     */
    /**
     * @cfg {String} text The text to display in this item (defaults to '').
     */
    /**
     * @cfg {String} href The href attribute to use for the underlying anchor link (defaults to '#').
     */
    /**
     * @cfg {String} hrefTarget The target attribute to use for the underlying anchor link (defaults to '').
     */
    /**
     * @cfg {String} itemCls The default CSS class to use for menu items (defaults to 'x-menu-item')
     */
    itemCls : "x-menu-item",
    /**
     * @cfg {Boolean} canActivate True if this item can be visually activated (defaults to true)
     */
    canActivate : true,
    /**
     * @cfg {Number} showDelay Length of time in milliseconds to wait before showing this item (defaults to 200)
     */
    showDelay: 200,
    // doc'd in BaseItem
    hideDelay: 200,

    // private
    ctype: "Ext.menu.Item",

    // private
    onRender : function(container, position){
        var el = document.createElement("a");
        el.hideFocus = true;
        el.unselectable = "on";
        el.href = this.href || "#";
        if(this.hrefTarget){
            el.target = this.hrefTarget;
        }
        el.className = this.itemCls + (this.menu ?  " x-menu-item-arrow" : "") + (this.cls ?  " " + this.cls : "");
        el.innerHTML = String.format(
                '<img src="{0}" class="x-menu-item-icon {2}" />{1}',
                this.icon || Ext.BLANK_IMAGE_URL, this.itemText||this.text, this.iconCls || '');
        this.el = el;
        Ext.menu.Item.superclass.onRender.call(this, container, position);
    },

    /**
     * Sets the text to display in this menu item
     * @param {String} text The text to display
     */
    setText : function(text){
        this.text = text;
        if(this.rendered){
            this.el.update(String.format(
                '<img src="{0}" class="x-menu-item-icon {2}">{1}',
                this.icon || Ext.BLANK_IMAGE_URL, this.text, this.iconCls || ''));
            this.parentMenu.autoWidth();
        }
    },

    /**
     * Sets the CSS class to apply to the item's icon element
     * @param {String} cls The CSS class to apply
     */
    setIconClass : function(cls){
        var oldCls = this.iconCls;
        this.iconCls = cls;
        if(this.rendered){
            this.el.child('img.x-menu-item-icon').replaceClass(oldCls, this.iconCls);
        }
    },

    // private
    handleClick : function(e){
        if(!this.href){ // if no link defined, stop the event automatically
            e.stopEvent();
        }
        Ext.menu.Item.superclass.handleClick.apply(this, arguments);
    },

    // private
    activate : function(autoExpand){
        if(Ext.menu.Item.superclass.activate.apply(this, arguments)){
            this.focus();
            if(autoExpand){
                this.expandMenu();
            }
        }
        return true;
    },

    // private
    shouldDeactivate : function(e){
        if(Ext.menu.Item.superclass.shouldDeactivate.call(this, e)){
            if(this.menu && this.menu.isVisible()){
                return !this.menu.getEl().getRegion().contains(e.getPoint());
            }
            return true;
        }
        return false;
    },

    // private
    deactivate : function(){
        Ext.menu.Item.superclass.deactivate.apply(this, arguments);
        this.hideMenu();
    },

    // private
    expandMenu : function(autoActivate){
        if(!this.disabled && this.menu){
            clearTimeout(this.hideTimer);
            delete this.hideTimer;
            if(!this.menu.isVisible() && !this.showTimer){
                this.showTimer = this.deferExpand.defer(this.showDelay, this, [autoActivate]);
            }else if (this.menu.isVisible() && autoActivate){
                this.menu.tryActivate(0, 1);
            }
        }
    },

    // private
    deferExpand : function(autoActivate){
        delete this.showTimer;
        this.menu.show(this.container, this.parentMenu.subMenuAlign || "tl-tr?", this.parentMenu);
        if(autoActivate){
            this.menu.tryActivate(0, 1);
        }
    },

    // private
    hideMenu : function(){
        clearTimeout(this.showTimer);
        delete this.showTimer;
        if(!this.hideTimer && this.menu && this.menu.isVisible()){
            this.hideTimer = this.deferHide.defer(this.hideDelay, this);
        }
    },

    // private
    deferHide : function(){
        delete this.hideTimer;
        this.menu.hide();
    }
});
/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.CheckItem
 * @extends Ext.menu.Item
 * Adds a menu item that contains a checkbox by default, but can also be part of a radio group.
 * @constructor
 * Creates a new CheckItem
 * @param {Object} config Configuration options
 */
Ext.menu.CheckItem = function(config){
    Ext.menu.CheckItem.superclass.constructor.call(this, config);
    this.addEvents(
        /**
         * @event beforecheckchange
         * Fires before the checked value is set, providing an opportunity to cancel if needed
         * @param {Ext.menu.CheckItem} this
         * @param {Boolean} checked The new checked value that will be set
         */
        "beforecheckchange" ,
        /**
         * @event checkchange
         * Fires after the checked value has been set
         * @param {Ext.menu.CheckItem} this
         * @param {Boolean} checked The checked value that was set
         */
        "checkchange"
    );
    /**
     * A function that handles the checkchange event.  The function is undefined by default, but if an implementation
     * is provided, it will be called automatically when the checkchange event fires.
     * @param {Ext.menu.CheckItem} this
     * @param {Boolean} checked The checked value that was set
     * @method checkHandler
     */
    if(this.checkHandler){
        this.on('checkchange', this.checkHandler, this.scope);
    }
    Ext.menu.MenuMgr.registerCheckable(this);
};
Ext.extend(Ext.menu.CheckItem, Ext.menu.Item, {
    /**
     * @cfg {String} group
     * All check items with the same group name will automatically be grouped into a single-select
     * radio button group (defaults to '')
     */
    /**
     * @cfg {String} itemCls The default CSS class to use for check items (defaults to "x-menu-item x-menu-check-item")
     */
    itemCls : "x-menu-item x-menu-check-item",
    /**
     * @cfg {String} groupClass The default CSS class to use for radio group check items (defaults to "x-menu-group-item")
     */
    groupClass : "x-menu-group-item",

    /**
     * @cfg {Boolean} checked True to initialize this checkbox as checked (defaults to false).  Note that
     * if this checkbox is part of a radio group (group = true) only the last item in the group that is
     * initialized with checked = true will be rendered as checked.
     */
    checked: false,

    // private
    ctype: "Ext.menu.CheckItem",

    // private
    onRender : function(c){
        Ext.menu.CheckItem.superclass.onRender.apply(this, arguments);
        if(this.group){
            this.el.addClass(this.groupClass);
        }
        if(this.checked){
            this.checked = false;
            this.setChecked(true, true);
        }
    },

    // private
    destroy : function(){
        Ext.menu.MenuMgr.unregisterCheckable(this);
        Ext.menu.CheckItem.superclass.destroy.apply(this, arguments);
    },

    /**
     * Set the checked state of this item
     * @param {Boolean} checked The new checked value
     * @param {Boolean} suppressEvent (optional) True to prevent the checkchange event from firing (defaults to false)
     */
    setChecked : function(state, suppressEvent){
        if(this.checked != state && this.fireEvent("beforecheckchange", this, state) !== false){
            if(this.container){
                this.container[state ? "addClass" : "removeClass"]("x-menu-item-checked");
            }
            this.checked = state;
            if(suppressEvent !== true){
                this.fireEvent("checkchange", this, state);
            }
        }
    },

    // private
    handleClick : function(e){
       if(!this.disabled && !(this.checked && this.group)){// disable unselect on radio item
           this.setChecked(!this.checked);
       }
       Ext.menu.CheckItem.superclass.handleClick.apply(this, arguments);
    }
});
/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.TextItem
 * @extends Ext.menu.BaseItem
 * Adds a static text string to a menu, usually used as either a heading or group separator.
 * @constructor
 * Creates a new TextItem
 * @param {String} text The text to display
 */
Ext.menu.TextItem = function(text){
    this.text = text;
    Ext.menu.TextItem.superclass.constructor.call(this);
};

Ext.extend(Ext.menu.TextItem, Ext.menu.BaseItem, {
    /**
     * @cfg {String} text The text to display for this item (defaults to '')
     */
    /**
     * @cfg {Boolean} hideOnClick True to hide the containing menu after this item is clicked (defaults to false)
     */
    hideOnClick : false,
    /**
     * @cfg {String} itemCls The default CSS class to use for text items (defaults to "x-menu-text")
     */
    itemCls : "x-menu-text",

    // private
    onRender : function(){
        var s = document.createElement("span");
        s.className = this.itemCls;
        s.innerHTML = this.text;
        this.el = s;
        Ext.menu.TextItem.superclass.onRender.apply(this, arguments);
    }
});
/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.MenuMgr
 * Provides a common registry of all menu items on a page so that they can be easily accessed by id.
 * @singleton
 */
Ext.menu.MenuMgr = function(){
   var menus, active, groups = {}, attached = false, lastShow = new Date();

   // private - called when first menu is created
   function init(){
       menus = {};
       active = new Ext.util.MixedCollection();
       Ext.getDoc().addKeyListener(27, function(){
           if(active.length > 0){
               hideAll();
           }
       });
   }

   // private
   function hideAll(){
       if(active && active.length > 0){
           var c = active.clone();
           c.each(function(m){
               m.hide();
           });
       }
   }

   // private
   function onHide(m){
       active.remove(m);
       if(active.length < 1){
           Ext.getDoc().un("mousedown", onMouseDown);
           attached = false;
       }
   }

   // private
   function onShow(m){
       var last = active.last();
       lastShow = new Date();
       active.add(m);
       if(!attached){
           Ext.getDoc().on("mousedown", onMouseDown);
           attached = true;
       }
       if(m.parentMenu){
          m.getEl().setZIndex(parseInt(m.parentMenu.getEl().getStyle("z-index"), 10) + 3);
          m.parentMenu.activeChild = m;
       }else if(last && last.isVisible()){
          m.getEl().setZIndex(parseInt(last.getEl().getStyle("z-index"), 10) + 3);
       }
   }

   // private
   function onBeforeHide(m){
       if(m.activeChild){
           m.activeChild.hide();
       }
       if(m.autoHideTimer){
           clearTimeout(m.autoHideTimer);
           delete m.autoHideTimer;
       }
   }

   // private
   function onBeforeShow(m){
       var pm = m.parentMenu;
       if(!pm && !m.allowOtherMenus){
           hideAll();
       }else if(pm && pm.activeChild){
           pm.activeChild.hide();
       }
   }

   // private
   function onMouseDown(e){
       if(lastShow.getElapsed() > 50 && active.length > 0 && !e.getTarget(".x-menu")){
           hideAll();
       }
   }

   // private
   function onBeforeCheck(mi, state){
       if(state){
           var g = groups[mi.group];
           for(var i = 0, l = g.length; i < l; i++){
               if(g[i] != mi){
                   g[i].setChecked(false);
               }
           }
       }
   }

   return {

       /**
        * Hides all menus that are currently visible
        */
       hideAll : function(){
            hideAll();  
       },

       // private
       register : function(menu){
           if(!menus){
               init();
           }
           menus[menu.id] = menu;
           menu.on("beforehide", onBeforeHide);
           menu.on("hide", onHide);
           menu.on("beforeshow", onBeforeShow);
           menu.on("show", onShow);
           var g = menu.group;
           if(g && menu.events["checkchange"]){
               if(!groups[g]){
                   groups[g] = [];
               }
               groups[g].push(menu);
               menu.on("checkchange", onCheck);
           }
       },

        /**
         * Returns a {@link Ext.menu.Menu} object
         * @param {String/Object} menu The string menu id, an existing menu object reference, or a Menu config that will
         * be used to generate and return a new Menu instance.
         * @return {Ext.menu.Menu} The specified menu, or null if none are found
         */
       get : function(menu){
           if(typeof menu == "string"){ // menu id
               if(!menus){  // not initialized, no menus to return
                   return null;
               }
               return menus[menu];
           }else if(menu.events){  // menu instance
               return menu;
           }else if(typeof menu.length == 'number'){ // array of menu items?
               return new Ext.menu.Menu({items:menu});
           }else{ // otherwise, must be a config
               return new Ext.menu.Menu(menu);
           }
       },

       // private
       unregister : function(menu){
           delete menus[menu.id];
           menu.un("beforehide", onBeforeHide);
           menu.un("hide", onHide);
           menu.un("beforeshow", onBeforeShow);
           menu.un("show", onShow);
           var g = menu.group;
           if(g && menu.events["checkchange"]){
               groups[g].remove(menu);
               menu.un("checkchange", onCheck);
           }
       },

       // private
       registerCheckable : function(menuItem){
           var g = menuItem.group;
           if(g){
               if(!groups[g]){
                   groups[g] = [];
               }
               groups[g].push(menuItem);
               menuItem.on("beforecheckchange", onBeforeCheck);
           }
       },

       // private
       unregisterCheckable : function(menuItem){
           var g = menuItem.group;
           if(g){
               groups[g].remove(menuItem);
               menuItem.un("beforecheckchange", onBeforeCheck);
           }
       },

       getCheckedItem : function(groupId){
           var g = groups[groupId];
           if(g){
               for(var i = 0, l = g.length; i < l; i++){
                   if(g[i].checked){
                       return g[i];
                   }
               }
           }
           return null;
       },

       setCheckedItem : function(groupId, itemId){
           var g = groups[groupId];
           if(g){
               for(var i = 0, l = g.length; i < l; i++){
                   if(g[i].id == itemId){
                       g[i].setChecked(true);
                   }
               }
           }
           return null;
       }
   };
}();

/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.Menu
 * @extends Ext.util.Observable
 * A menu object.  This is the container to which you add all other menu items.  Menu can also serve a as a base class
 * when you want a specialzed menu based off of another component (like {@link Ext.menu.DateMenu} for example).
 * @constructor
 * Creates a new Menu
 * @param {Object} config Configuration options
 */
Ext.menu.Menu = function(config){
    if(Ext.isArray(config)){
        config = {items:config};
    }
    Ext.apply(this, config);
    this.id = this.id || Ext.id();
    this.addEvents(
        /**
         * @event beforeshow
         * Fires before this menu is displayed
         * @param {Ext.menu.Menu} this
         */
        'beforeshow',
        /**
         * @event beforehide
         * Fires before this menu is hidden
         * @param {Ext.menu.Menu} this
         */
        'beforehide',
        /**
         * @event show
         * Fires after this menu is displayed
         * @param {Ext.menu.Menu} this
         */
        'show',
        /**
         * @event hide
         * Fires after this menu is hidden
         * @param {Ext.menu.Menu} this
         */
        'hide',
        /**
         * @event click
         * Fires when this menu is clicked (or when the enter key is pressed while it is active)
         * @param {Ext.menu.Menu} this
         * @param {Ext.menu.Item} menuItem The menu item that was clicked
         * @param {Ext.EventObject} e
         */
        'click',
        /**
         * @event mouseover
         * Fires when the mouse is hovering over this menu
         * @param {Ext.menu.Menu} this
         * @param {Ext.EventObject} e
         * @param {Ext.menu.Item} menuItem The menu item that was clicked
         */
        'mouseover',
        /**
         * @event mouseout
         * Fires when the mouse exits this menu
         * @param {Ext.menu.Menu} this
         * @param {Ext.EventObject} e
         * @param {Ext.menu.Item} menuItem The menu item that was clicked
         */
        'mouseout',
        /**
         * @event itemclick
         * Fires when a menu item contained in this menu is clicked
         * @param {Ext.menu.BaseItem} baseItem The BaseItem that was clicked
         * @param {Ext.EventObject} e
         */
        'itemclick'
    );
    Ext.menu.MenuMgr.register(this);
    Ext.menu.Menu.superclass.constructor.call(this);
    var mis = this.items;
    /**
     * A MixedCollection of this Menu's items
     * @property items
     * @type Ext.util.MixedCollection
     */

    this.items = new Ext.util.MixedCollection();
    if(mis){
        this.add.apply(this, mis);
    }
};

Ext.extend(Ext.menu.Menu, Ext.util.Observable, {
    /**
     * @cfg {Object} defaults
     * A config object that will be applied to all items added to this container either via the {@link #items}
     * config or via the {@link #add} method.  The defaults config can contain any number of
     * name/value property pairs to be added to each item, and should be valid for the types of items
     * being added to the menu.
     */
    /**
     * @cfg {Mixed} items
     * An array of items to be added to this menu.  See {@link #add} for a list of valid item types.
     */
    /**
     * @cfg {Number} minWidth The minimum width of the menu in pixels (defaults to 120)
     */
    minWidth : 120,
    /**
     * @cfg {Boolean/String} shadow True or "sides" for the default effect, "frame" for 4-way shadow, and "drop"
     * for bottom-right shadow (defaults to "sides")
     */
    shadow : "sides",
    /**
     * @cfg {String} subMenuAlign The {@link Ext.Element#alignTo} anchor position value to use for submenus of
     * this menu (defaults to "tl-tr?")
     */
    subMenuAlign : "tl-tr?",
    /**
     * @cfg {String} defaultAlign The default {@link Ext.Element#alignTo) anchor position value for this menu
     * relative to its element of origin (defaults to "tl-bl?")
     */
    defaultAlign : "tl-bl?",
    /**
     * @cfg {Boolean} allowOtherMenus True to allow multiple menus to be displayed at the same time (defaults to false)
     */
    allowOtherMenus : false,

    hidden:true,

    createEl : function(){
        return new Ext.Layer({
            cls: "x-menu",
            shadow:this.shadow,
            constrain: false,
            parentEl: this.parentEl || document.body,
            zindex:15000
        });
    },

    // private
    render : function(){
        if(this.el){
            return;
        }
        var el = this.el = this.createEl();

        if(!this.keyNav){
            this.keyNav = new Ext.menu.MenuNav(this);
        }
        if(this.plain){
            el.addClass("x-menu-plain");
        }
        if(this.cls){
            el.addClass(this.cls);
        }
        // generic focus element
        this.focusEl = el.createChild({
            tag: "a", cls: "x-menu-focus", href: "#", onclick: "return false;", tabIndex:"-1"
        });
        var ul = el.createChild({tag: "ul", cls: "x-menu-list"});
        ul.on("click", this.onClick, this);
        ul.on("mouseover", this.onMouseOver, this);
        ul.on("mouseout", this.onMouseOut, this);
        this.items.each(function(item){
            var li = document.createElement("li");
            li.className = "x-menu-list-item";
            ul.dom.appendChild(li);
            item.render(li, this);
        }, this);
        this.ul = ul;
        this.autoWidth();
    },

    // private
    autoWidth : function(){
        var el = this.el, ul = this.ul;
        if(!el){
            return;
        }
        var w = this.width;
        if(w){
            el.setWidth(w);
        }else if(Ext.isIE){
            el.setWidth(this.minWidth);
            var t = el.dom.offsetWidth; // force recalc
            el.setWidth(ul.getWidth()+el.getFrameWidth("lr"));
        }
    },

    // private
    delayAutoWidth : function(){
        if(this.el){
            if(!this.awTask){
                this.awTask = new Ext.util.DelayedTask(this.autoWidth, this);
            }
            this.awTask.delay(20);
        }
    },

    // private
    findTargetItem : function(e){
        var t = e.getTarget(".x-menu-list-item", this.ul,  true);
        if(t && t.menuItemId){
            return this.items.get(t.menuItemId);
        }
    },

    // private
    onClick : function(e){
        var t;
        if(t = this.findTargetItem(e)){
            t.onClick(e);
            this.fireEvent("click", this, t, e);
        }
    },

    // private
    setActiveItem : function(item, autoExpand){
        if(item != this.activeItem){
            if(this.activeItem){
                this.activeItem.deactivate();
            }
            this.activeItem = item;
            item.activate(autoExpand);
        }else if(autoExpand){
            item.expandMenu();
        }
    },

    // private
    tryActivate : function(start, step){
        var items = this.items;
        for(var i = start, len = items.length; i >= 0 && i < len; i+= step){
            var item = items.get(i);
            if(!item.disabled && item.canActivate){
                this.setActiveItem(item, false);
                return item;
            }
        }
        return false;
    },

    // private
    onMouseOver : function(e){
        var t;
        if(t = this.findTargetItem(e)){
            if(t.canActivate && !t.disabled){
                this.setActiveItem(t, true);
            }
        }
        this.fireEvent("mouseover", this, e, t);
    },

    // private
    onMouseOut : function(e){
        var t;
        if(t = this.findTargetItem(e)){
            if(t == this.activeItem && t.shouldDeactivate(e)){
                this.activeItem.deactivate();
                delete this.activeItem;
            }
        }
        this.fireEvent("mouseout", this, e, t);
    },

    /**
     * Read-only.  Returns true if the menu is currently displayed, else false.
     * @type Boolean
     */
    isVisible : function(){
        return this.el && !this.hidden;
    },

    /**
     * Displays this menu relative to another element
     * @param {Mixed} element The element to align to
     * @param {String} position (optional) The {@link Ext.Element#alignTo} anchor position to use in aligning to
     * the element (defaults to this.defaultAlign)
     * @param {Ext.menu.Menu} parentMenu (optional) This menu's parent menu, if applicable (defaults to undefined)
     */
    show : function(el, pos, parentMenu){
        this.parentMenu = parentMenu;
        if(!this.el){
            this.render();
        }
        this.fireEvent("beforeshow", this);
        this.showAt(this.el.getAlignToXY(el, pos || this.defaultAlign), parentMenu, false);
    },

    /**
     * Displays this menu at a specific xy position
     * @param {Array} xyPosition Contains X & Y [x, y] values for the position at which to show the menu (coordinates are page-based)
     * @param {Ext.menu.Menu} parentMenu (optional) This menu's parent menu, if applicable (defaults to undefined)
     */
    showAt : function(xy, parentMenu, /* private: */_e){
        this.parentMenu = parentMenu;
        if(!this.el){
            this.render();
        }
        if(_e !== false){
            this.fireEvent("beforeshow", this);
            xy = this.el.adjustForConstraints(xy);
        }
        this.el.setXY(xy);
        this.el.show();
        this.hidden = false;
        this.focus();
        this.fireEvent("show", this);
    },

    

    focus : function(){
        if(!this.hidden){
            this.doFocus.defer(50, this);
        }
    },

    doFocus : function(){
        if(!this.hidden){
            this.focusEl.focus();
        }
    },

    /**
     * Hides this menu and optionally all parent menus
     * @param {Boolean} deep (optional) True to hide all parent menus recursively, if any (defaults to false)
     */
    hide : function(deep){
        if(this.el && this.isVisible()){
            this.fireEvent("beforehide", this);
            if(this.activeItem){
                this.activeItem.deactivate();
                this.activeItem = null;
            }
            this.el.hide();
            this.hidden = true;
            this.fireEvent("hide", this);
        }
        if(deep === true && this.parentMenu){
            this.parentMenu.hide(true);
        }
    },

    /**
     * Addds one or more items of any type supported by the Menu class, or that can be converted into menu items.
     * Any of the following are valid:
     * <ul>
     * <li>Any menu item object based on {@link Ext.menu.Item}</li>
     * <li>An HTMLElement object which will be converted to a menu item</li>
     * <li>A menu item config object that will be created as a new menu item</li>
     * <li>A string, which can either be '-' or 'separator' to add a menu separator, otherwise
     * it will be converted into a {@link Ext.menu.TextItem} and added</li>
     * </ul>
     * Usage:
     * <pre><code>
// Create the menu
var menu = new Ext.menu.Menu();

// Create a menu item to add by reference
var menuItem = new Ext.menu.Item({ text: 'New Item!' });

// Add a bunch of items at once using different methods.
// Only the last item added will be returned.
var item = menu.add(
    menuItem,                // add existing item by ref
    'Dynamic Item',          // new TextItem
    '-',                     // new separator
    { text: 'Config Item' }  // new item by config
);
</code></pre>
     * @param {Mixed} args One or more menu items, menu item configs or other objects that can be converted to menu items
     * @return {Ext.menu.Item} The menu item that was added, or the last one if multiple items were added
     */
    add : function(){
        var a = arguments, l = a.length, item;
        for(var i = 0; i < l; i++){
            var el = a[i];
            if(el.render){ // some kind of Item
                item = this.addItem(el);
            }else if(typeof el == "string"){ // string
                if(el == "separator" || el == "-"){
                    item = this.addSeparator();
                }else{
                    item = this.addText(el);
                }
            }else if(el.tagName || el.el){ // element
                item = this.addElement(el);
            }else if(typeof el == "object"){ // must be menu item config?
                Ext.applyIf(el, this.defaults);
                item = this.addMenuItem(el);
            }
        }
        return item;
    },

    /**
     * Returns this menu's underlying {@link Ext.Element} object
     * @return {Ext.Element} The element
     */
    getEl : function(){
        if(!this.el){
            this.render();
        }
        return this.el;
    },

    /**
     * Adds a separator bar to the menu
     * @return {Ext.menu.Item} The menu item that was added
     */
    addSeparator : function(){
        return this.addItem(new Ext.menu.Separator());
    },

    /**
     * Adds an {@link Ext.Element} object to the menu
     * @param {Mixed} el The element or DOM node to add, or its id
     * @return {Ext.menu.Item} The menu item that was added
     */
    addElement : function(el){
        return this.addItem(new Ext.menu.BaseItem(el));
    },

    /**
     * Adds an existing object based on {@link Ext.menu.Item} to the menu
     * @param {Ext.menu.Item} item The menu item to add
     * @return {Ext.menu.Item} The menu item that was added
     */
    addItem : function(item){
        this.items.add(item);
        if(this.ul){
            var li = document.createElement("li");
            li.className = "x-menu-list-item";
            this.ul.dom.appendChild(li);
            item.render(li, this);
            this.delayAutoWidth();
        }
        return item;
    },

    /**
     * Creates a new {@link Ext.menu.Item} based an the supplied config object and adds it to the menu
     * @param {Object} config A MenuItem config object
     * @return {Ext.menu.Item} The menu item that was added
     */
    addMenuItem : function(config){
        if(!(config instanceof Ext.menu.Item)){
            if(typeof config.checked == "boolean"){ // must be check menu item config?
                config = new Ext.menu.CheckItem(config);
            }else{
                config = new Ext.menu.Item(config);
            }
        }
        return this.addItem(config);
    },

    /**
     * Creates a new {@link Ext.menu.TextItem} with the supplied text and adds it to the menu
     * @param {String} text The text to display in the menu item
     * @return {Ext.menu.Item} The menu item that was added
     */
    addText : function(text){
        return this.addItem(new Ext.menu.TextItem(text));
    },

    /**
     * Inserts an existing object based on {@link Ext.menu.Item} to the menu at a specified index
     * @param {Number} index The index in the menu's list of current items where the new item should be inserted
     * @param {Ext.menu.Item} item The menu item to add
     * @return {Ext.menu.Item} The menu item that was added
     */
    insert : function(index, item){
        this.items.insert(index, item);
        if(this.ul){
            var li = document.createElement("li");
            li.className = "x-menu-list-item";
            this.ul.dom.insertBefore(li, this.ul.dom.childNodes[index]);
            item.render(li, this);
            this.delayAutoWidth();
        }
        return item;
    },

    /**
     * Removes an {@link Ext.menu.Item} from the menu and destroys the object
     * @param {Ext.menu.Item} item The menu item to remove
     */
    remove : function(item){
        this.items.removeKey(item.id);
        item.destroy();
    },

    /**
     * Removes and destroys all items in the menu
     */
    removeAll : function(){
        var f;
        while(f = this.items.first()){
            this.remove(f);
        }
    },

    /**
     * Destroys the menu by  unregistering it from {@link Ext.menu.MenuMgr}, purging event listeners,
     * removing all of the menus items, then destroying the underlying {@link Ext.Element}
     */
    destroy : function(){
        this.beforeDestroy();
        Ext.menu.MenuMgr.unregister(this);
        if (this.keyNav) {
        	this.keyNav.disable();	
        }
        this.removeAll();
        if (this.ul) {
        	this.ul.removeAllListeners();	
        }
        if (this.el) {
        	this.el.destroy();	
        }
    },

	// private
    beforeDestroy : Ext.emptyFn

});

// MenuNav is a private utility class used internally by the Menu
Ext.menu.MenuNav = function(menu){
    Ext.menu.MenuNav.superclass.constructor.call(this, menu.el);
    this.scope = this.menu = menu;
};

Ext.extend(Ext.menu.MenuNav, Ext.KeyNav, {
    doRelay : function(e, h){
        var k = e.getKey();
        if(!this.menu.activeItem && e.isNavKeyPress() && k != e.SPACE && k != e.RETURN){
            this.menu.tryActivate(0, 1);
            return false;
        }
        return h.call(this.scope || this, e, this.menu);
    },

    up : function(e, m){
        if(!m.tryActivate(m.items.indexOf(m.activeItem)-1, -1)){
            m.tryActivate(m.items.length-1, -1);
        }
    },

    down : function(e, m){
        if(!m.tryActivate(m.items.indexOf(m.activeItem)+1, 1)){
            m.tryActivate(0, 1);
        }
    },

    right : function(e, m){
        if(m.activeItem){
            m.activeItem.expandMenu(true);
        }
    },

    left : function(e, m){
        m.hide();
        if(m.parentMenu && m.parentMenu.activeItem){
            m.parentMenu.activeItem.activate();
        }
    },

    enter : function(e, m){
        if(m.activeItem){
            e.stopPropagation();
            m.activeItem.onClick(e);
            m.fireEvent("click", this, m.activeItem);
            return true;
        }
    }
});
/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.Separator
 * @extends Ext.menu.BaseItem
 * Adds a separator bar to a menu, used to divide logical groups of menu items. Generally you will
 * add one of these by using "-" in you call to add() or in your items config rather than creating one directly.
 * @constructor
 * @param {Object} config Configuration options
 */
Ext.menu.Separator = function(config){
    Ext.menu.Separator.superclass.constructor.call(this, config);
};

Ext.extend(Ext.menu.Separator, Ext.menu.BaseItem, {
    /**
     * @cfg {String} itemCls The default CSS class to use for separators (defaults to "x-menu-sep")
     */
    itemCls : "x-menu-sep",
    /**
     * @cfg {Boolean} hideOnClick True to hide the containing menu after this item is clicked (defaults to false)
     */
    hideOnClick : false,

    // private
    onRender : function(li){
        var s = document.createElement("span");
        s.className = this.itemCls;
        s.innerHTML = "&#160;";
        this.el = s;
        li.addClass("x-menu-sep-li");
        Ext.menu.Separator.superclass.onRender.apply(this, arguments);
    }
});
