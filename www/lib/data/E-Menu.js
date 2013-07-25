/*
 * Ext JS Library 2.2
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
        /**
         * The parent Menu of this Item.
         * @property parentMenu
         * @type Ext.menu.Menu
         */
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
 * Ext JS Library 2.2
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
     * @cfg {Mixed} menu Either an instance of {@link Ext.menu.Menu} or the config object for an
     * {@link Ext.menu.Menu} which acts as the submenu when this item is activated.
     */
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
        if(this.menu.over){
            this.parentMenu.setActiveItem(this, false);
        }else{
            this.menu.hide();
        }
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
 * Ext JS Library 2.2
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
 * @param {Object/String} config If config is a string, it is used as the text to display, otherwise it
 * is applied as a config object (and should contain a <tt>text</tt> property).
 */
Ext.menu.TextItem = function(cfg){
    if(typeof cfg == 'string'){
        cfg = {text: cfg}
    }
    Ext.menu.TextItem.superclass.constructor.call(this, cfg);
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
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.Menu
 * @extends Ext.util.Observable
 * A menu object.  This is the container to which you add all other menu items.  Menu can also serve as a base class
 * when you want a specialized menu based off of another component (like {@link Ext.menu.DateMenu} for example).
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
     * @cfg {String} defaultAlign The default {@link Ext.Element#alignTo} anchor position value for this menu
     * relative to its element of origin (defaults to "tl-bl?")
     */
    defaultAlign : "tl-bl?",
    /**
     * @cfg {Boolean} allowOtherMenus True to allow multiple menus to be displayed at the same time (defaults to false)
     */
    allowOtherMenus : false,
    /**
     * @cfg {Boolean} ignoreParentClicks True to ignore clicks on any item in this menu that is a parent item (displays
     * a submenu) so that the submenu is not dismissed when clicking the parent item (defaults to false).
     */
    ignoreParentClicks : false,

    // private
    hidden:true,

    // private
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
            if(t.menu && this.ignoreParentClicks){
                t.expandMenu();
            }else{
                t.onClick(e);
                this.fireEvent("click", this, t, e);
            }
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
        this.over = true;
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
        this.over = false;
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
     * <li>Any menu item object based on {@link Ext.menu.BaseItem}</li>
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
     * Adds an existing object based on {@link Ext.menu.BaseItem} to the menu
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
     * Inserts an existing object based on {@link Ext.menu.BaseItem} to the menu at a specified index
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
    	if(this.items){
	        var f;
	        while(f = this.items.first()){
	            this.remove(f);
	        }
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
 * Ext JS Library 2.2
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
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.Adapter
 * @extends Ext.menu.BaseItem
 * A base utility class that adapts a non-menu component so that it can be wrapped by a menu item and added to a menu.
 * It provides basic rendering, activation management and enable/disable logic required to work in menus.
 * @constructor
 * Creates a new Adapter
 * @param {Ext.Component} component The component being adapted to render into a menu
 * @param {Object} config Configuration options
 */
Ext.menu.Adapter = function(component, config){
    Ext.menu.Adapter.superclass.constructor.call(this, config);
    this.component = component;
};
Ext.extend(Ext.menu.Adapter, Ext.menu.BaseItem, {
    // private
    canActivate : true,

    // private
    onRender : function(container, position){
        this.component.render(container);
        this.el = this.component.getEl();
    },

    // private
    activate : function(){
        if(this.disabled){
            return false;
        }
        this.component.focus();
        this.fireEvent("activate", this);
        return true;
    },

    // private
    deactivate : function(){
        this.fireEvent("deactivate", this);
    },

    // private
    disable : function(){
        this.component.disable();
        Ext.menu.Adapter.superclass.disable.call(this);
    },

    // private
    enable : function(){
        this.component.enable();
        Ext.menu.Adapter.superclass.enable.call(this);
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
 * @class Ext.ColorPalette
 * @extends Ext.Component
 * Simple color palette class for choosing colors.  The palette can be rendered to any container.<br />
 * Here's an example of typical usage:
 * <pre><code>
var cp = new Ext.ColorPalette({value:'993300'});  // initial selected color
cp.render('my-div');

cp.on('select', function(palette, selColor){
    // do something with selColor
});
</code></pre>
 * @constructor
 * Create a new ColorPalette
 * @param {Object} config The config object
 */
Ext.ColorPalette = function(config){
    Ext.ColorPalette.superclass.constructor.call(this, config);
    this.addEvents(
        /**
	     * @event select
	     * Fires when a color is selected
	     * @param {ColorPalette} this
	     * @param {String} color The 6-digit color hex code (without the # symbol)
	     */
        'select'
    );

    if(this.handler){
        this.on("select", this.handler, this.scope, true);
    }
};
Ext.extend(Ext.ColorPalette, Ext.Component, {
	/**
	 * @cfg {String} tpl An existing XTemplate instance to be used in place of the default template for rendering the component.
	 */
    /**
     * @cfg {String} itemCls
     * The CSS class to apply to the containing element (defaults to "x-color-palette")
     */
    itemCls : "x-color-palette",
    /**
     * @cfg {String} value
     * The initial color to highlight (should be a valid 6-digit color hex code without the # symbol).  Note that
     * the hex codes are case-sensitive.
     */
    value : null,
    clickEvent:'click',
    // private
    ctype: "Ext.ColorPalette",

    /**
     * @cfg {Boolean} allowReselect If set to true then reselecting a color that is already selected fires the {@link #select} event
     */
    allowReselect : false,

    /**
     * <p>An array of 6-digit color hex code strings (without the # symbol).  This array can contain any number
     * of colors, and each hex code should be unique.  The width of the palette is controlled via CSS by adjusting
     * the width property of the 'x-color-palette' class (or assigning a custom class), so you can balance the number
     * of colors with the width setting until the box is symmetrical.</p>
     * <p>You can override individual colors if needed:</p>
     * <pre><code>
var cp = new Ext.ColorPalette();
cp.colors[0] = "FF0000";  // change the first box to red
</code></pre>

Or you can provide a custom array of your own for complete control:
<pre><code>
var cp = new Ext.ColorPalette();
cp.colors = ["000000", "993300", "333300"];
</code></pre>
     * @type Array
     */
    colors : [
        "000000", "993300", "333300", "003300", "003366", "000080", "333399", "333333",
        "800000", "FF6600", "808000", "008000", "008080", "0000FF", "666699", "808080",
        "FF0000", "FF9900", "99CC00", "339966", "33CCCC", "3366FF", "800080", "969696",
        "FF00FF", "FFCC00", "FFFF00", "00FF00", "00FFFF", "00CCFF", "993366", "C0C0C0",
        "FF99CC", "FFCC99", "FFFF99", "CCFFCC", "CCFFFF", "99CCFF", "CC99FF", "FFFFFF"
    ],

    // private
    onRender : function(container, position){
        var t = this.tpl || new Ext.XTemplate(
            '<tpl for="."><a href="#" class="color-{.}" hidefocus="on"><em><span style="background:#{.}" unselectable="on">&#160;</span></em></a></tpl>'
        );
        var el = document.createElement("div");
        el.className = this.itemCls;
        t.overwrite(el, this.colors);
        container.dom.insertBefore(el, position);
        this.el = Ext.get(el);
        this.el.on(this.clickEvent, this.handleClick,  this, {delegate: "a"});
        if(this.clickEvent != 'click'){
            this.el.on('click', Ext.emptyFn,  this, {delegate: "a", preventDefault:true});
        }
    },

    // private
    afterRender : function(){
        Ext.ColorPalette.superclass.afterRender.call(this);
        if(this.value){
            var s = this.value;
            this.value = null;
            this.select(s);
        }
    },

    // private
    handleClick : function(e, t){
        e.preventDefault();
        if(!this.disabled){
            var c = t.className.match(/(?:^|\s)color-(.{6})(?:\s|$)/)[1];
            this.select(c.toUpperCase());
        }
    },

    /**
     * Selects the specified color in the palette (fires the {@link #select} event)
     * @param {String} color A valid 6-digit color hex code (# will be stripped if included)
     */
    select : function(color){
        color = color.replace("#", "");
        if(color != this.value || this.allowReselect){
            var el = this.el;
            if(this.value){
                el.child("a.color-"+this.value).removeClass("x-color-palette-sel");
            }
            el.child("a.color-"+color).addClass("x-color-palette-sel");
            this.value = color;
            this.fireEvent("select", this, color);
        }
    }

    /**
     * @cfg {String} autoEl @hide
     */
});
Ext.reg('colorpalette', Ext.ColorPalette);
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.ColorItem
 * @extends Ext.menu.Adapter
 * A menu item that wraps the {@link Ext.ColorPalette} component.
 * @constructor
 * Creates a new ColorItem
 * @param {Object} config Configuration options
 */
Ext.menu.ColorItem = function(config){
    Ext.menu.ColorItem.superclass.constructor.call(this, new Ext.ColorPalette(config), config);
    /** The Ext.ColorPalette object @type Ext.ColorPalette */
    this.palette = this.component;
    this.relayEvents(this.palette, ["select"]);
    if(this.selectHandler){
        this.on('select', this.selectHandler, this.scope);
    }
};
Ext.extend(Ext.menu.ColorItem, Ext.menu.Adapter);
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.ColorMenu
 * @extends Ext.menu.Menu
 * A menu containing a {@link Ext.menu.ColorItem} component (which provides a basic color picker).
 * @constructor
 * Creates a new ColorMenu
 * @param {Object} config Configuration options
 */
Ext.menu.ColorMenu = function(config){
    Ext.menu.ColorMenu.superclass.constructor.call(this, config);
    this.plain = true;
    var ci = new Ext.menu.ColorItem(config);
    this.add(ci);
    /**
     * The {@link Ext.ColorPalette} instance for this ColorMenu
     * @type ColorPalette
     */
    this.palette = ci.palette;
    /**
     * @event select
     * @param {ColorPalette} palette
     * @param {String} color
     */
    this.relayEvents(ci, ["select"]);
};
Ext.extend(Ext.menu.ColorMenu, Ext.menu.Menu);
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.menu.DateItem
 * @extends Ext.menu.Adapter
 * A menu item that wraps the {@link Ext.DatePicker} component.
 * @constructor
 * Creates a new DateItem
 * @param {Object} config Configuration options
 */
Ext.menu.DateItem = function(config){
    Ext.menu.DateItem.superclass.constructor.call(this, new Ext.DatePicker(config), config);
    /** The Ext.DatePicker object @type Ext.DatePicker */
    this.picker = this.component;
    this.addEvents('select');
    
    this.picker.on("render", function(picker){
        picker.getEl().swallowEvent("click");
        picker.container.addClass("x-menu-date-item");
    });

    this.picker.on("select", this.onSelect, this);
};

Ext.extend(Ext.menu.DateItem, Ext.menu.Adapter, {
    // private
    onSelect : function(picker, date){
        this.fireEvent("select", this, date, picker);
        Ext.menu.DateItem.superclass.handleClick.call(this);
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
 * @class Ext.menu.DateMenu
 * @extends Ext.menu.Menu
 * A menu containing a {@link Ext.menu.DateItem} component (which provides a date picker).
 * @constructor
 * Creates a new DateMenu
 * @param {Object} config Configuration options
 */
Ext.menu.DateMenu = function(config){
    Ext.menu.DateMenu.superclass.constructor.call(this, config);
    this.plain = true;
    var di = new Ext.menu.DateItem(config);
    this.add(di);
    /**
     * The {@link Ext.DatePicker} instance for this DateMenu
     * @type DatePicker
     */
    this.picker = di.picker;
    /**
     * @event select
     * @param {DatePicker} picker
     * @param {Date} date
     */
    this.relayEvents(di, ["select"]);

    this.on('beforeshow', function(){
        if(this.picker){
            this.picker.hideMonthPicker(true);
        }
    }, this);
};
Ext.extend(Ext.menu.DateMenu, Ext.menu.Menu, {
    cls:'x-date-menu',

    // private
    beforeDestroy : function() {
        this.picker.destroy();
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
 * @class Ext.Toolbar
 * @extends Ext.BoxComponent
 * Basic Toolbar class. Toolbar elements can be created explicitly via their constructors, or implicitly
 * via their xtypes.  Some items also have shortcut strings for creation.  
 * @constructor
 * Creates a new Toolbar
 * @param {Object/Array} config A config object or an array of buttons to add
 */ 
 Ext.Toolbar = function(config){
    if(Ext.isArray(config)){
        config = {buttons:config};
    }
    Ext.Toolbar.superclass.constructor.call(this, config);
};

(function(){

var T = Ext.Toolbar;

Ext.extend(T, Ext.BoxComponent, {

    trackMenus : true,

    // private
    initComponent : function(){
        T.superclass.initComponent.call(this);

        if(this.items){
            this.buttons = this.items;
        }
        /**
         * A MixedCollection of this Toolbar's items
         * @property items
         * @type Ext.util.MixedCollection
         */
        this.items = new Ext.util.MixedCollection(false, function(o){
            return o.itemId || o.id || Ext.id();
        });
    },

    // private
    autoCreate: {
        cls:'x-toolbar x-small-editor',
        html:'<table cellspacing="0"><tr></tr></table>'
    },

    // private
    onRender : function(ct, position){
        this.el = ct.createChild(Ext.apply({ id: this.id },this.autoCreate), position);
        this.tr = this.el.child("tr", true);
    },

    // private
    afterRender : function(){
        T.superclass.afterRender.call(this);
        if(this.buttons){
            this.add.apply(this, this.buttons);
            delete this.buttons;
        }
    },

    /**
     * Adds element(s) to the toolbar -- this function takes a variable number of
     * arguments of mixed type and adds them to the toolbar.
     * @param {Mixed} arg1 The following types of arguments are all valid:<br />
     * <ul>
     * <li>{@link Ext.Toolbar.Button} config: A valid button config object (equivalent to {@link #addButton})</li>
     * <li>HtmlElement: Any standard HTML element (equivalent to {@link #addElement})</li>
     * <li>Field: Any form field (equivalent to {@link #addField})</li>
     * <li>Item: Any subclass of {@link Ext.Toolbar.Item} (equivalent to {@link #addItem})</li>
     * <li>String: Any generic string (gets wrapped in a {@link Ext.Toolbar.TextItem}, equivalent to {@link #addText}).
     * Note that there are a few special strings that are treated differently as explained next.</li>
     * <li>'separator' or '-': Creates a separator element (equivalent to {@link #addSeparator})</li>
     * <li>' ': Creates a spacer element (equivalent to {@link #addSpacer})</li>
     * <li>'->': Creates a fill element (equivalent to {@link #addFill})</li>
     * </ul>
     * @param {Mixed} arg2
     * @param {Mixed} etc.
     */
    add : function(){
        var a = arguments, l = a.length;
        for(var i = 0; i < l; i++){
            var el = a[i];
            if(el.isFormField){ // some kind of form field
                this.addField(el);
            }else if(el.render){ // some kind of Toolbar.Item
                this.addItem(el);
            }else if(typeof el == "string"){ // string
                if(el == "separator" || el == "-"){
                    this.addSeparator();
                }else if(el == " "){
                    this.addSpacer();
                }else if(el == "->"){
                    this.addFill();
                }else{
                    this.addText(el);
                }
            }else if(el.tagName){ // element
                this.addElement(el);
            }else if(typeof el == "object"){ // must be button config?
                if(el.xtype){
                    this.addField(Ext.ComponentMgr.create(el, 'button'));
                }else{
                    this.addButton(el);
                }
            }
        }
    },
    
    /**
     * Adds a separator
     * @return {Ext.Toolbar.Item} The separator item
     */
    addSeparator : function(){
        return this.addItem(new T.Separator());
    },

    /**
     * Adds a spacer element
     * @return {Ext.Toolbar.Spacer} The spacer item
     */
    addSpacer : function(){
        return this.addItem(new T.Spacer());
    },

    /**
     * Adds a fill element that forces subsequent additions to the right side of the toolbar
     * @return {Ext.Toolbar.Fill} The fill item
     */
    addFill : function(){
        return this.addItem(new T.Fill());
    },

    /**
     * Adds any standard HTML element to the toolbar
     * @param {Mixed} el The element or id of the element to add
     * @return {Ext.Toolbar.Item} The element's item
     */
    addElement : function(el){
        return this.addItem(new T.Item(el));
    },
    
    /**
     * Adds any Toolbar.Item or subclass
     * @param {Ext.Toolbar.Item} item
     * @return {Ext.Toolbar.Item} The item
     */
    addItem : function(item){
        var td = this.nextBlock();
        this.initMenuTracking(item);
        item.render(td);
        this.items.add(item);
        return item;
    },
    
    /**
     * Adds a button (or buttons). See {@link Ext.Toolbar.Button} for more info on the config.
     * @param {Object/Array} config A button config or array of configs
     * @return {Ext.Toolbar.Button/Array}
     */
    addButton : function(config){
        if(Ext.isArray(config)){
            var buttons = [];
            for(var i = 0, len = config.length; i < len; i++) {
                buttons.push(this.addButton(config[i]));
            }
            return buttons;
        }
        var b = config;
        if(!(config instanceof T.Button)){
            b = config.split ? 
                new T.SplitButton(config) :
                new T.Button(config);
        }
        var td = this.nextBlock();
        this.initMenuTracking(b);
        b.render(td);
        this.items.add(b);
        return b;
    },

    // private
    initMenuTracking : function(item){
        if(this.trackMenus && item.menu){
            item.on({
                'menutriggerover' : this.onButtonTriggerOver,
                'menushow' : this.onButtonMenuShow,
                'menuhide' : this.onButtonMenuHide,
                scope: this
            })
        }
    },

    /**
     * Adds text to the toolbar
     * @param {String} text The text to add
     * @return {Ext.Toolbar.Item} The element's item
     */
    addText : function(text){
        return this.addItem(new T.TextItem(text));
    },
    
    /**
     * Inserts any {@link Ext.Toolbar.Item}/{@link Ext.Toolbar.Button} at the specified index.
     * @param {Number} index The index where the item is to be inserted
     * @param {Object/Ext.Toolbar.Item/Ext.Toolbar.Button/Array} item The button, or button config object to be
     * inserted, or an array of buttons/configs.
     * @return {Ext.Toolbar.Button/Item}
     */
    insertButton : function(index, item){
        if(Ext.isArray(item)){
            var buttons = [];
            for(var i = 0, len = item.length; i < len; i++) {
               buttons.push(this.insertButton(index + i, item[i]));
            }
            return buttons;
        }
        if (!(item instanceof T.Button)){
           item = new T.Button(item);
        }
        var td = document.createElement("td");
        this.tr.insertBefore(td, this.tr.childNodes[index]);
        this.initMenuTracking(item);
        item.render(td);
        this.items.insert(index, item);
        return item;
    },
    
    /**
     * Adds a new element to the toolbar from the passed {@link Ext.DomHelper} config
     * @param {Object} config
     * @return {Ext.Toolbar.Item} The element's item
     */
    addDom : function(config, returnEl){
        var td = this.nextBlock();
        Ext.DomHelper.overwrite(td, config);
        var ti = new T.Item(td.firstChild);
        ti.render(td);
        this.items.add(ti);
        return ti;
    },

    /**
     * Adds a dynamically rendered Ext.form field (TextField, ComboBox, etc). Note: the field should not have
     * been rendered yet. For a field that has already been rendered, use {@link #addElement}.
     * @param {Ext.form.Field} field
     * @return {Ext.Toolbar.Item}
     */
    addField : function(field){
        var td = this.nextBlock();
        field.render(td);
        var ti = new T.Item(td.firstChild);
        ti.render(td);
        this.items.add(field);
        return ti;
    },

    // private
    nextBlock : function(){
        var td = document.createElement("td");
        this.tr.appendChild(td);
        return td;
    },

    // private
    onDestroy : function(){
        Ext.Toolbar.superclass.onDestroy.call(this);
        if(this.rendered){
            if(this.items){ // rendered?
                Ext.destroy.apply(Ext, this.items.items);
            }
            Ext.Element.uncache(this.tr);
        }
    },

    // private
    onDisable : function(){
        this.items.each(function(item){
             if(item.disable){
                 item.disable();
             }
        });
    },

    // private
    onEnable : function(){
        this.items.each(function(item){
             if(item.enable){
                 item.enable();
             }
        });
    },

    // private
    onButtonTriggerOver : function(btn){
        if(this.activeMenuBtn && this.activeMenuBtn != btn){
            this.activeMenuBtn.hideMenu();
            btn.showMenu();
            this.activeMenuBtn = btn;
        }
    },

    // private
    onButtonMenuShow : function(btn){
        this.activeMenuBtn = btn;
    },

    // private
    onButtonMenuHide : function(btn){
        delete this.activeMenuBtn;
    }

    /**
     * @cfg {String} autoEl @hide
     */
});
Ext.reg('toolbar', Ext.Toolbar);

/**
 * @class Ext.Toolbar.Item
 * The base class that other classes should extend in order to get some basic common toolbar item functionality.
 * @constructor
 * Creates a new Item
 * @param {HTMLElement} el 
 */
T.Item = function(el){
    this.el = Ext.getDom(el);
    this.id = Ext.id(this.el);
    this.hidden = false;
};

T.Item.prototype = {
    
    /**
     * Get this item's HTML Element
     * @return {HTMLElement}
     */
    getEl : function(){
       return this.el;  
    },

    // private
    render : function(td){
        this.td = td;
        td.appendChild(this.el);
    },
    
    /**
     * Removes and destroys this item.
     */
    destroy : function(){
        if(this.td && this.td.parentNode){
            this.td.parentNode.removeChild(this.td);
        }
    },
    
    /**
     * Shows this item.
     */
    show: function(){
        this.hidden = false;
        this.td.style.display = "";
    },
    
    /**
     * Hides this item.
     */
    hide: function(){
        this.hidden = true;
        this.td.style.display = "none";
    },
    
    /**
     * Convenience function for boolean show/hide.
     * @param {Boolean} visible true to show/false to hide
     */
    setVisible: function(visible){
        if(visible) {
            this.show();
        }else{
            this.hide();
        }
    },
    
    /**
     * Try to focus this item
     */
    focus : function(){
        Ext.fly(this.el).focus();
    },
    
    /**
     * Disables this item.
     */
    disable : function(){
        Ext.fly(this.td).addClass("x-item-disabled");
        this.disabled = true;
        this.el.disabled = true;
    },
    
    /**
     * Enables this item.
     */
    enable : function(){
        Ext.fly(this.td).removeClass("x-item-disabled");
        this.disabled = false;
        this.el.disabled = false;
    }
};
Ext.reg('tbitem', T.Item);


/**
 * @class Ext.Toolbar.Separator
 * @extends Ext.Toolbar.Item
 * A simple class that adds a vertical separator bar between toolbar items.  Example usage:
 * <pre><code>
new Ext.Panel({
	tbar : [
		'Item 1',
		{xtype: 'tbseparator'}, // or '-'
		'Item 2'
	]
});
</code></pre>
 * @constructor
 * Creates a new Separator
 */
T.Separator = function(){
    var s = document.createElement("span");
    s.className = "ytb-sep";
    T.Separator.superclass.constructor.call(this, s);
};
Ext.extend(T.Separator, T.Item, {
    enable:Ext.emptyFn,
    disable:Ext.emptyFn,
    focus:Ext.emptyFn
});
Ext.reg('tbseparator', T.Separator);

/**
 * @class Ext.Toolbar.Spacer
 * @extends Ext.Toolbar.Item
 * A simple element that adds extra horizontal space between items in a toolbar.
 * <pre><code>
new Ext.Panel({
	tbar : [
		'Item 1',
		{xtype: 'tbspacer'}, // or ' '
		'Item 2'
	]
});
</code></pre>
 * @constructor
 * Creates a new Spacer
 */
T.Spacer = function(){
    var s = document.createElement("div");
    s.className = "ytb-spacer";
    T.Spacer.superclass.constructor.call(this, s);
};
Ext.extend(T.Spacer, T.Item, {
    enable:Ext.emptyFn,
    disable:Ext.emptyFn,
    focus:Ext.emptyFn
});

Ext.reg('tbspacer', T.Spacer);

/**
 * @class Ext.Toolbar.Fill
 * @extends Ext.Toolbar.Spacer
 * A simple element that adds a greedy (100% width) horizontal space between items in a toolbar.
 * <pre><code>
new Ext.Panel({
	tbar : [
		'Item 1',
		{xtype: 'tbfill'}, // or '->'
		'Item 2'
	]
});
</code></pre>
 * @constructor
 * Creates a new Spacer
 */
T.Fill = Ext.extend(T.Spacer, {
    // private
    render : function(td){
        td.style.width = '100%';
        T.Fill.superclass.render.call(this, td);
    }
});
Ext.reg('tbfill', T.Fill);

/**
 * @class Ext.Toolbar.TextItem
 * @extends Ext.Toolbar.Item
 * A simple class that renders text directly into a toolbar.
 * <pre><code>
new Ext.Panel({
	tbar : [
		{xtype: 'tbtext', text: 'Item 1'} // or simply 'Item 1'
	]
});
</code></pre>
 * @constructor
 * Creates a new TextItem
 * @param {String/Object} text A text string, or a config object containing a <tt>text</tt> property
 */
T.TextItem = function(t){
    var s = document.createElement("span");
    s.className = "ytb-text";
    s.innerHTML = t.text ? t.text : t;
    T.TextItem.superclass.constructor.call(this, s);
};
Ext.extend(T.TextItem, T.Item, {
    enable:Ext.emptyFn,
    disable:Ext.emptyFn,
    focus:Ext.emptyFn
});
Ext.reg('tbtext', T.TextItem);


/**
 * @class Ext.Toolbar.Button
 * @extends Ext.Button
 * A button that renders into a toolbar. Use the <tt>handler</tt> config to specify a callback function
 * to handle the button's click event.
 * <pre><code>
new Ext.Panel({
	tbar : [
		{text: 'OK', handler: okHandler} // tbbutton is the default xtype if not specified
	]
});
</code></pre>
 * @constructor
 * Creates a new Button
 * @param {Object} config A standard {@link Ext.Button} config object
 */
T.Button = Ext.extend(Ext.Button, {
    hideParent : true,

    onDestroy : function(){
        T.Button.superclass.onDestroy.call(this);
        if(this.container){
            this.container.remove();
        }
    }
});
Ext.reg('tbbutton', T.Button);

/**
 * @class Ext.Toolbar.SplitButton
 * @extends Ext.SplitButton
 * A split button that renders into a toolbar.
 * <pre><code>
new Ext.Panel({
	tbar : [
		{
			xtype: 'tbsplit',
		   	text: 'Options',
		   	handler: optionsHandler, // handle a click on the button itself
		   	menu: new Ext.menu.Menu({
		        items: [
		        	// These items will display in a dropdown menu when the split arrow is clicked
			        {text: 'Item 1', handler: item1Handler},
			        {text: 'Item 2', handler: item2Handler}
		        ]
		   	})
		}
	]
});
</code></pre>
 * @constructor
 * Creates a new SplitButton
 * @param {Object} config A standard {@link Ext.SplitButton} config object
 */
T.SplitButton = Ext.extend(Ext.SplitButton, {
    hideParent : true,

    onDestroy : function(){
        T.SplitButton.superclass.onDestroy.call(this);
        if(this.container){
            this.container.remove();
        }
    }
});

Ext.reg('tbsplit', T.SplitButton);
// backwards compat
T.MenuButton = T.SplitButton;

})();

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.PagingToolbar
 * @extends Ext.Toolbar
 * A specialized toolbar that is bound to a {@link Ext.data.Store} and provides automatic paging controls.
 * @constructor
 * Create a new PagingToolbar
 * @param {Object} config The config object
 */
Ext.PagingToolbar = Ext.extend(Ext.Toolbar, {
    /**
     * @cfg {Ext.data.Store} store The {@link Ext.data.Store} the paging toolbar should use as its data source (required).
     */
    /**
     * @cfg {Boolean} displayInfo
     * True to display the displayMsg (defaults to false)
     */
    /**
     * @cfg {Number} pageSize
     * The number of records to display per page (defaults to 20)
     */
    pageSize: 20,
    /**
     * @cfg {String} displayMsg
     * The paging status message to display (defaults to "Displaying {0} - {1} of {2}").  Note that this string is
     * formatted using the braced numbers 0-2 as tokens that are replaced by the values for start, end and total
     * respectively. These tokens should be preserved when overriding this string if showing those values is desired.
     */
    displayMsg : 'Displaying {0} - {1} of {2}',
    /**
     * @cfg {String} emptyMsg
     * The message to display when no records are found (defaults to "No data to display")
     */
    emptyMsg : 'No data to display',
    /**
     * Customizable piece of the default paging text (defaults to "Page")
     * @type String
     */
    beforePageText : "Page",
    /**
     * Customizable piece of the default paging text (defaults to "of {0}"). Note that this string is
     * formatted using {0} as a token that is replaced by the number of total pages. This token should be 
     * preserved when overriding this string if showing the total page count is desired.
     * @type String
     */
    afterPageText : "of {0}",
    /**
     * Customizable piece of the default paging text (defaults to "First Page")
     * @type String
     */
    firstText : "First Page",
    /**
     * Customizable piece of the default paging text (defaults to "Previous Page")
     * @type String
     */
    prevText : "Previous Page",
    /**
     * Customizable piece of the default paging text (defaults to "Next Page")
     * @type String
     */
    nextText : "Next Page",
    /**
     * Customizable piece of the default paging text (defaults to "Last Page")
     * @type String
     */
    lastText : "Last Page",
    /**
     * Customizable piece of the default paging text (defaults to "Refresh")
     * @type String
     */
    refreshText : "Refresh",

    /**
     * Object mapping of parameter names for load calls (defaults to {start: 'start', limit: 'limit'})
     */
    paramNames : {start: 'start', limit: 'limit'},

    initComponent : function(){
        this.addEvents('change', 'beforechange');
        Ext.PagingToolbar.superclass.initComponent.call(this);
        this.cursor = 0;
        this.bind(this.store);
    },

    // private
    onRender : function(ct, position){
        Ext.PagingToolbar.superclass.onRender.call(this, ct, position);
        this.first = this.addButton({
            tooltip: this.firstText,
            iconCls: "x-tbar-page-first",
            disabled: true,
            handler: this.onClick.createDelegate(this, ["first"])
        });
        this.prev = this.addButton({
            tooltip: this.prevText,
            iconCls: "x-tbar-page-prev",
            disabled: true,
            handler: this.onClick.createDelegate(this, ["prev"])
        });
        this.addSeparator();
        this.add(this.beforePageText);
        this.field = Ext.get(this.addDom({
           tag: "input",
           type: "text",
           size: "3",
           value: "1",
           cls: "x-tbar-page-number"
        }).el);
        this.field.on("keydown", this.onPagingKeydown, this);
        this.field.on("focus", function(){this.dom.select();});
        this.afterTextEl = this.addText(String.format(this.afterPageText, 1));
        this.field.setHeight(18);
        this.addSeparator();
        this.next = this.addButton({
            tooltip: this.nextText,
            iconCls: "x-tbar-page-next",
            disabled: true,
            handler: this.onClick.createDelegate(this, ["next"])
        });
        this.last = this.addButton({
            tooltip: this.lastText,
            iconCls: "x-tbar-page-last",
            disabled: true,
            handler: this.onClick.createDelegate(this, ["last"])
        });
        this.addSeparator();
        this.loading = this.addButton({
            tooltip: this.refreshText,
            iconCls: "x-tbar-loading",
            handler: this.onClick.createDelegate(this, ["refresh"])
        });

        if(this.displayInfo){
            this.displayEl = Ext.fly(this.el.dom).createChild({cls:'x-paging-info'});
        }
        if(this.dsLoaded){
            this.onLoad.apply(this, this.dsLoaded);
        }
    },

    // private
    updateInfo : function(){
        if(this.displayEl){
            var count = this.store.getCount();
            var msg = count == 0 ?
                this.emptyMsg :
                String.format(
                    this.displayMsg,
                    this.cursor+1, this.cursor+count, this.store.getTotalCount()
                );
            this.displayEl.update(msg);
        }
    },

    // private
    onLoad : function(store, r, o){
        if(!this.rendered){
            this.dsLoaded = [store, r, o];
            return;
        }
       this.cursor = o.params ? o.params[this.paramNames.start] : 0;
       var d = this.getPageData(), ap = d.activePage, ps = d.pages;

        this.afterTextEl.el.innerHTML = String.format(this.afterPageText, d.pages);
        this.field.dom.value = ap;
        this.first.setDisabled(ap == 1);
        this.prev.setDisabled(ap == 1);
        this.next.setDisabled(ap == ps);
        this.last.setDisabled(ap == ps);
        this.loading.enable();
        this.updateInfo();
        this.fireEvent('change', this, d);
    },

    // private
    getPageData : function(){
        var total = this.store.getTotalCount();
        return {
            total : total,
            activePage : Math.ceil((this.cursor+this.pageSize)/this.pageSize),
            pages :  total < this.pageSize ? 1 : Math.ceil(total/this.pageSize)
        };
    },

    // private
    onLoadError : function(){
        if(!this.rendered){
            return;
        }
        this.loading.enable();
    },

    readPage : function(d){
        var v = this.field.dom.value, pageNum;
        if (!v || isNaN(pageNum = parseInt(v, 10))) {
            this.field.dom.value = d.activePage;
            return false;
        }
        return pageNum;
    },

    // private
    onPagingKeydown : function(e){
        var k = e.getKey(), d = this.getPageData(), pageNum;
        if (k == e.RETURN) {
            e.stopEvent();
            pageNum = this.readPage(d);
            if(pageNum !== false){
                pageNum = Math.min(Math.max(1, pageNum), d.pages) - 1;
                this.doLoad(pageNum * this.pageSize);
            }
        }else if (k == e.HOME || k == e.END){
            e.stopEvent();
            pageNum = k == e.HOME ? 1 : d.pages;
            this.field.dom.value = pageNum;
        }else if (k == e.UP || k == e.PAGEUP || k == e.DOWN || k == e.PAGEDOWN){
            e.stopEvent();
            if(pageNum = this.readPage(d)){
                var increment = e.shiftKey ? 10 : 1;
                if(k == e.DOWN || k == e.PAGEDOWN){
                    increment *= -1;
                }
                pageNum += increment;
                if(pageNum >= 1 & pageNum <= d.pages){
                    this.field.dom.value = pageNum;
                }
            }
        }
    },

    // private
    beforeLoad : function(){
        if(this.rendered && this.loading){
            this.loading.disable();
        }
    },

    doLoad : function(start){
        var o = {}, pn = this.paramNames;
        o[pn.start] = start;
        o[pn.limit] = this.pageSize;
        if(this.fireEvent('beforechange', this, o) !== false){
            this.store.load({params:o});
        }
    },

    /**
     * Change the active page
     * @param {Integer} page The page to display 
     */
    changePage: function(page){
        this.doLoad(((page-1) * this.pageSize).constrain(0, this.store.getTotalCount()));  
    },

    // private
    onClick : function(which){
        var store = this.store;
        switch(which){
            case "first":
                this.doLoad(0);
            break;
            case "prev":
                this.doLoad(Math.max(0, this.cursor-this.pageSize));
            break;
            case "next":
                this.doLoad(this.cursor+this.pageSize);
            break;
            case "last":
                var total = store.getTotalCount();
                var extra = total % this.pageSize;
                var lastStart = extra ? (total - extra) : total-this.pageSize;
                this.doLoad(lastStart);
            break;
            case "refresh":
                this.doLoad(this.cursor);
            break;
        }
    },

    /**
     * Unbinds the paging toolbar from the specified {@link Ext.data.Store}
     * @param {Ext.data.Store} store The data store to unbind
     */
    unbind : function(store){
        store = Ext.StoreMgr.lookup(store);
        store.un("beforeload", this.beforeLoad, this);
        store.un("load", this.onLoad, this);
        store.un("loadexception", this.onLoadError, this);
        this.store = undefined;
    },

    /**
     * Binds the paging toolbar to the specified {@link Ext.data.Store}
     * @param {Ext.data.Store} store The data store to bind
     */
    bind : function(store){
        store = Ext.StoreMgr.lookup(store);
        store.on("beforeload", this.beforeLoad, this);
        store.on("load", this.onLoad, this);
        store.on("loadexception", this.onLoadError, this);
        this.store = store;
    }
});
Ext.reg('paging', Ext.PagingToolbar);
