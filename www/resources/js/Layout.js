/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.SplitBar
 * @extends Ext.util.Observable
 * Creates draggable splitter bar functionality from two elements (element to be dragged and element to be resized).
 * <br><br>
 * Usage:
 * <pre><code>
var split = new Ext.SplitBar("elementToDrag", "elementToSize",
                   Ext.SplitBar.HORIZONTAL, Ext.SplitBar.LEFT);
split.setAdapter(new Ext.SplitBar.AbsoluteLayoutAdapter("container"));
split.minSize = 100;
split.maxSize = 600;
split.animate = true;
split.on('moved', splitterMoved);
</code></pre>
 * @constructor
 * Create a new SplitBar
 * @param {Mixed} dragElement The element to be dragged and act as the SplitBar.
 * @param {Mixed} resizingElement The element to be resized based on where the SplitBar element is dragged
 * @param {Number} orientation (optional) Either Ext.SplitBar.HORIZONTAL or Ext.SplitBar.VERTICAL. (Defaults to HORIZONTAL)
 * @param {Number} placement (optional) Either Ext.SplitBar.LEFT or Ext.SplitBar.RIGHT for horizontal or  
                        Ext.SplitBar.TOP or Ext.SplitBar.BOTTOM for vertical. (By default, this is determined automatically by the initial
                        position of the SplitBar).
 */
Ext.SplitBar = function(dragElement, resizingElement, orientation, placement, existingProxy){
    
    /** @private */
    this.el = Ext.get(dragElement, true);
    this.el.dom.unselectable = "on";
    /** @private */
    this.resizingEl = Ext.get(resizingElement, true);

    /**
     * @private
     * The orientation of the split. Either Ext.SplitBar.HORIZONTAL or Ext.SplitBar.VERTICAL. (Defaults to HORIZONTAL)
     * Note: If this is changed after creating the SplitBar, the placement property must be manually updated
     * @type Number
     */
    this.orientation = orientation || Ext.SplitBar.HORIZONTAL;
    
    /**
     * The minimum size of the resizing element. (Defaults to 0)
     * @type Number
     */
    this.minSize = 0;
    
    /**
     * The maximum size of the resizing element. (Defaults to 2000)
     * @type Number
     */
    this.maxSize = 2000;
    
    /**
     * Whether to animate the transition to the new size
     * @type Boolean
     */
    this.animate = false;
    
    /**
     * Whether to create a transparent shim that overlays the page when dragging, enables dragging across iframes.
     * @type Boolean
     */
    this.useShim = false;
    
    /** @private */
    this.shim = null;
    
    if(!existingProxy){
        /** @private */
        this.proxy = Ext.SplitBar.createProxy(this.orientation);
    }else{
        this.proxy = Ext.get(existingProxy).dom;
    }
    /** @private */
    this.dd = new Ext.dd.DDProxy(this.el.dom.id, "XSplitBars", {dragElId : this.proxy.id});
    
    /** @private */
    this.dd.b4StartDrag = this.onStartProxyDrag.createDelegate(this);
    
    /** @private */
    this.dd.endDrag = this.onEndProxyDrag.createDelegate(this);
    
    /** @private */
    this.dragSpecs = {};
    
    /**
     * @private The adapter to use to positon and resize elements
     */
    this.adapter = new Ext.SplitBar.BasicLayoutAdapter();
    this.adapter.init(this);
    
    if(this.orientation == Ext.SplitBar.HORIZONTAL){
        /** @private */
        this.placement = placement || (this.el.getX() > this.resizingEl.getX() ? Ext.SplitBar.LEFT : Ext.SplitBar.RIGHT);
        this.el.addClass("x-splitbar-h");
    }else{
        /** @private */
        this.placement = placement || (this.el.getY() > this.resizingEl.getY() ? Ext.SplitBar.TOP : Ext.SplitBar.BOTTOM);
        this.el.addClass("x-splitbar-v");
    }
    
    this.addEvents(
        /**
         * @event resize
         * Fires when the splitter is moved (alias for {@link #event-moved})
         * @param {Ext.SplitBar} this
         * @param {Number} newSize the new width or height
         */
        "resize",
        /**
         * @event moved
         * Fires when the splitter is moved
         * @param {Ext.SplitBar} this
         * @param {Number} newSize the new width or height
         */
        "moved",
        /**
         * @event beforeresize
         * Fires before the splitter is dragged
         * @param {Ext.SplitBar} this
         */
        "beforeresize",

        "beforeapply"
    );

    Ext.SplitBar.superclass.constructor.call(this);
};

Ext.extend(Ext.SplitBar, Ext.util.Observable, {
    onStartProxyDrag : function(x, y){
        this.fireEvent("beforeresize", this);
        this.overlay =  Ext.DomHelper.append(document.body,  {cls: "x-drag-overlay", html: "&#160;"}, true);
        this.overlay.unselectable();
        this.overlay.setSize(Ext.lib.Dom.getViewWidth(true), Ext.lib.Dom.getViewHeight(true));
        this.overlay.show();
        Ext.get(this.proxy).setDisplayed("block");
        var size = this.adapter.getElementSize(this);
        this.activeMinSize = this.getMinimumSize();;
        this.activeMaxSize = this.getMaximumSize();;
        var c1 = size - this.activeMinSize;
        var c2 = Math.max(this.activeMaxSize - size, 0);
        if(this.orientation == Ext.SplitBar.HORIZONTAL){
            this.dd.resetConstraints();
            this.dd.setXConstraint(
                this.placement == Ext.SplitBar.LEFT ? c1 : c2, 
                this.placement == Ext.SplitBar.LEFT ? c2 : c1
            );
            this.dd.setYConstraint(0, 0);
        }else{
            this.dd.resetConstraints();
            this.dd.setXConstraint(0, 0);
            this.dd.setYConstraint(
                this.placement == Ext.SplitBar.TOP ? c1 : c2, 
                this.placement == Ext.SplitBar.TOP ? c2 : c1
            );
         }
        this.dragSpecs.startSize = size;
        this.dragSpecs.startPoint = [x, y];
        Ext.dd.DDProxy.prototype.b4StartDrag.call(this.dd, x, y);
    },
    
    /** 
     * @private Called after the drag operation by the DDProxy
     */
    onEndProxyDrag : function(e){
        Ext.get(this.proxy).setDisplayed(false);
        var endPoint = Ext.lib.Event.getXY(e);
        if(this.overlay){
            this.overlay.remove();
            delete this.overlay;
        }
        var newSize;
        if(this.orientation == Ext.SplitBar.HORIZONTAL){
            newSize = this.dragSpecs.startSize + 
                (this.placement == Ext.SplitBar.LEFT ?
                    endPoint[0] - this.dragSpecs.startPoint[0] :
                    this.dragSpecs.startPoint[0] - endPoint[0]
                );
        }else{
            newSize = this.dragSpecs.startSize + 
                (this.placement == Ext.SplitBar.TOP ?
                    endPoint[1] - this.dragSpecs.startPoint[1] :
                    this.dragSpecs.startPoint[1] - endPoint[1]
                );
        }
        newSize = Math.min(Math.max(newSize, this.activeMinSize), this.activeMaxSize);
        if(newSize != this.dragSpecs.startSize){
            if(this.fireEvent('beforeapply', this, newSize) !== false){
                this.adapter.setElementSize(this, newSize);
                this.fireEvent("moved", this, newSize);
                this.fireEvent("resize", this, newSize);
            }
        }
    },
    
    /**
     * Get the adapter this SplitBar uses
     * @return The adapter object
     */
    getAdapter : function(){
        return this.adapter;
    },
    
    /**
     * Set the adapter this SplitBar uses
     * @param {Object} adapter A SplitBar adapter object
     */
    setAdapter : function(adapter){
        this.adapter = adapter;
        this.adapter.init(this);
    },
    
    /**
     * Gets the minimum size for the resizing element
     * @return {Number} The minimum size
     */
    getMinimumSize : function(){
        return this.minSize;
    },
    
    /**
     * Sets the minimum size for the resizing element
     * @param {Number} minSize The minimum size
     */
    setMinimumSize : function(minSize){
        this.minSize = minSize;
    },
    
    /**
     * Gets the maximum size for the resizing element
     * @return {Number} The maximum size
     */
    getMaximumSize : function(){
        return this.maxSize;
    },
    
    /**
     * Sets the maximum size for the resizing element
     * @param {Number} maxSize The maximum size
     */
    setMaximumSize : function(maxSize){
        this.maxSize = maxSize;
    },
    
    /**
     * Sets the initialize size for the resizing element
     * @param {Number} size The initial size
     */
    setCurrentSize : function(size){
        var oldAnimate = this.animate;
        this.animate = false;
        this.adapter.setElementSize(this, size);
        this.animate = oldAnimate;
    },
    
    /**
     * Destroy this splitbar. 
     * @param {Boolean} removeEl True to remove the element
     */
    destroy : function(removeEl){
        if(this.shim){
            this.shim.remove();
        }
        this.dd.unreg();
        Ext.removeNode(this.proxy);
        if(removeEl){
            this.el.remove();
        }
    }
});

/**
 * @private static Create our own proxy element element. So it will be the same same size on all browsers, we won't use borders. Instead we use a background color.
 */
Ext.SplitBar.createProxy = function(dir){
    var proxy = new Ext.Element(document.createElement("div"));
    proxy.unselectable();
    var cls = 'x-splitbar-proxy';
    proxy.addClass(cls + ' ' + (dir == Ext.SplitBar.HORIZONTAL ? cls +'-h' : cls + '-v'));
    document.body.appendChild(proxy.dom);
    return proxy.dom;
};

/** 
 * @class Ext.SplitBar.BasicLayoutAdapter
 * Default Adapter. It assumes the splitter and resizing element are not positioned
 * elements and only gets/sets the width of the element. Generally used for table based layouts.
 */
Ext.SplitBar.BasicLayoutAdapter = function(){
};

Ext.SplitBar.BasicLayoutAdapter.prototype = {
    // do nothing for now
    init : function(s){
    
    },
    /**
     * Called before drag operations to get the current size of the resizing element. 
     * @param {Ext.SplitBar} s The SplitBar using this adapter
     */
     getElementSize : function(s){
        if(s.orientation == Ext.SplitBar.HORIZONTAL){
            return s.resizingEl.getWidth();
        }else{
            return s.resizingEl.getHeight();
        }
    },
    
    /**
     * Called after drag operations to set the size of the resizing element.
     * @param {Ext.SplitBar} s The SplitBar using this adapter
     * @param {Number} newSize The new size to set
     * @param {Function} onComplete A function to be invoked when resizing is complete
     */
    setElementSize : function(s, newSize, onComplete){
        if(s.orientation == Ext.SplitBar.HORIZONTAL){
            if(!s.animate){
                s.resizingEl.setWidth(newSize);
                if(onComplete){
                    onComplete(s, newSize);
                }
            }else{
                s.resizingEl.setWidth(newSize, true, .1, onComplete, 'easeOut');
            }
        }else{
            
            if(!s.animate){
                s.resizingEl.setHeight(newSize);
                if(onComplete){
                    onComplete(s, newSize);
                }
            }else{
                s.resizingEl.setHeight(newSize, true, .1, onComplete, 'easeOut');
            }
        }
    }
};

/** 
 *@class Ext.SplitBar.AbsoluteLayoutAdapter
 * @extends Ext.SplitBar.BasicLayoutAdapter
 * Adapter that  moves the splitter element to align with the resized sizing element. 
 * Used with an absolute positioned SplitBar.
 * @param {Mixed} container The container that wraps around the absolute positioned content. If it's
 * document.body, make sure you assign an id to the body element.
 */
Ext.SplitBar.AbsoluteLayoutAdapter = function(container){
    this.basic = new Ext.SplitBar.BasicLayoutAdapter();
    this.container = Ext.get(container);
};

Ext.SplitBar.AbsoluteLayoutAdapter.prototype = {
    init : function(s){
        this.basic.init(s);
    },
    
    getElementSize : function(s){
        return this.basic.getElementSize(s);
    },
    
    setElementSize : function(s, newSize, onComplete){
        this.basic.setElementSize(s, newSize, this.moveSplitter.createDelegate(this, [s]));
    },
    
    moveSplitter : function(s){
        var yes = Ext.SplitBar;
        switch(s.placement){
            case yes.LEFT:
                s.el.setX(s.resizingEl.getRight());
                break;
            case yes.RIGHT:
                s.el.setStyle("right", (this.container.getWidth() - s.resizingEl.getLeft()) + "px");
                break;
            case yes.TOP:
                s.el.setY(s.resizingEl.getBottom());
                break;
            case yes.BOTTOM:
                s.el.setY(s.resizingEl.getTop() - s.el.getHeight());
                break;
        }
    }
};

/**
 * Orientation constant - Create a vertical SplitBar
 * @static
 * @type Number
 */
Ext.SplitBar.VERTICAL = 1;

/**
 * Orientation constant - Create a horizontal SplitBar
 * @static
 * @type Number
 */
Ext.SplitBar.HORIZONTAL = 2;

/**
 * Placement constant - The resizing element is to the left of the splitter element
 * @static
 * @type Number
 */
Ext.SplitBar.LEFT = 1;

/**
 * Placement constant - The resizing element is to the right of the splitter element
 * @static
 * @type Number
 */
Ext.SplitBar.RIGHT = 2;

/**
 * Placement constant - The resizing element is positioned above the splitter element
 * @static
 * @type Number
 */
Ext.SplitBar.TOP = 3;

/**
 * Placement constant - The resizing element is positioned under splitter element
 * @static
 * @type Number
 */
Ext.SplitBar.BOTTOM = 4;

/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.Container
 * @extends Ext.BoxComponent
 * <p>Base class for any {@link Ext.BoxComponent} that can contain other components.  Containers handle the basic
 * behavior of containing items, namely adding, inserting and removing them.  The specific layout logic required
 * to visually render contained items is delegated to any one of the different {@link #layout} classes available.
 * This class is intended to be extended and should generally not need to be created directly via the new keyword.</p>
 * <p>When either specifying child {@link #items} of a Container, or dynamically adding components to a Container,
 * remember to consider how you wish the Container to arrange those child elements, and whether those child elements
 * need to be sized using one of Ext's built-in layout schemes.</p>
 * <p>By default, Containers use the {@link Ext.layout.ContainerLayout ContainerLayout} scheme. This simply renders
 * child components, appending them one after the other inside the Container, and does not apply any sizing at all.
 * This is a common source of confusion when widgets like GridPanels or TreePanels are added to Containers for
 * which no layout has been specified. If a Container is left to use the ContainerLayout scheme, none of its child
 * components will be resized, or changed in any way when the Container is resized.</p>
 * <p>A very common example of this is where a developer will attempt to add a GridPanel to a TabPanel by wrapping
 * the GridPanel <i>inside</i> a wrapping Panel and add that wrapping Panel to the TabPanel. This misses the point that
 * Ext's inheritance means that a GridPanel <b>is</b> a Component which can be added unadorned into a Container. If
 * that wrapping Panel has no layout configuration, then the GridPanel will not be sized as expected.<p>
 * <p>Below is an example of adding a newly created GridPanel to a TabPanel. This requires prior knowledge of how
 * to create GridPanels. See {@link Ext.grid.GridPanel}, {@link Ext.data.Store} and {@link Ext.data.JsonReader} as
 * well as the grid examples in the Ext installation's <tt>examples/grid</tt> directory.</p><pre><code>
//  Create the GridPanel.
myGrid = new Ext.grid.GridPanel({
    myStore,
    myColumnModel,
    title: 'Results',
});

myTabPanel.add(myGrid);
myTabPanel.setActiveItem(myGrid);
</code></pre>
 */
Ext.Container = Ext.extend(Ext.BoxComponent, {
    /** @cfg {Boolean} monitorResize
     * True to automatically monitor window resize events to handle anything that is sensitive to the current size
     * of the viewport.  This value is typically managed by the chosen {@link #layout} and should not need to be set manually.
     */
    /**
     * @cfg {String} layout
     * The layout type to be used in this container.  If not specified, a default {@link Ext.layout.ContainerLayout}
     * will be created and used.  Valid values are: absolute, accordion, anchor, border, card, column, fit, form and table.
     * Specific config values for the chosen layout type can be specified using {@link #layoutConfig}.
     */
    /**
     * @cfg {Object} layoutConfig
     * This is a config object containing properties specific to the chosen layout (to be used in conjunction with
     * the {@link #layout} config value).  For complete details regarding the valid config options for each layout
     * type, see the layout class corresponding to the type specified:<ul class="mdetail-params">
     * <li>{@link Ext.layout.Absolute}</li>
     * <li>{@link Ext.layout.Accordion}</li>
     * <li>{@link Ext.layout.AnchorLayout}</li>
     * <li>{@link Ext.layout.BorderLayout}</li>
     * <li>{@link Ext.layout.CardLayout}</li>
     * <li>{@link Ext.layout.ColumnLayout}</li>
     * <li>{@link Ext.layout.FitLayout}</li>
     * <li>{@link Ext.layout.FormLayout}</li>
     * <li>{@link Ext.layout.TableLayout}</li></ul>
     */
    /**
     * @cfg {Boolean/Number} bufferResize
     * When set to true (100 milliseconds) or a number of milliseconds, the layout assigned for this container will buffer
     * the frequency it calculates and does a re-layout of components. This is useful for heavy containers or containers
     * with a large quantity of sub-components for which frequent layout calls would be expensive.
     */
    /**
     * @cfg {String/Number} activeItem
     * A string component id or the numeric index of the component that should be initially activated within the
     * container's layout on render.  For example, activeItem: 'item-1' or activeItem: 0 (index 0 = the first
     * item in the container's collection).  activeItem only applies to layout styles that can display
     * items one at a time (like {@link Ext.layout.Accordion}, {@link Ext.layout.CardLayout} and
     * {@link Ext.layout.FitLayout}).  Related to {@link Ext.layout.ContainerLayout#activeItem}.
     */
    /**
     * @cfg {Mixed} items
     * A single item, or an array of child Components to be added to this container.
     * Each item can be any type of object based on {@link Ext.Component}.<br><br>
     * Component config objects may also be specified in order to avoid the overhead
     * of constructing a real Component object if lazy rendering might mean that the
     * added Component will not be rendered immediately. To take advantage of this
     * "lazy instantiation", set the {@link Ext.Component#xtype} config property to
     * the registered type of the Component wanted.<br><br>
     * For a list of all available xtypes, see {@link Ext.Component}.
     * If a single item is being passed, it should be passed directly as an object
     * reference (e.g., items: {...}).  Multiple items should be passed as an array
     * of objects (e.g., items: [{...}, {...}]).
     */
    /**
     * @cfg {Object} defaults
     * A config object that will be applied to all components added to this container either via the {@link #items}
     * config or via the {@link #add} or {@link #insert} methods.  The defaults config can contain any number of
     * name/value property pairs to be added to each item, and should be valid for the types of items
     * being added to the container.  For example, to automatically apply padding to the body of each of a set of
     * contained {@link Ext.Panel} items, you could pass: defaults: {bodyStyle:'padding:15px'}.
     */

    /** @cfg {Boolean} autoDestroy
     * If true the container will automatically destroy any contained component that is removed from it, else
     * destruction must be handled manually (defaults to true).
     */
    autoDestroy: true,
    /** @cfg {Boolean} hideBorders
     * True to hide the borders of each contained component, false to defer to the component's existing
     * border settings (defaults to false).
     */
    /** @cfg {String} defaultType
     * The default type of container represented by this object as registered in {@link Ext.ComponentMgr}
     * (defaults to 'panel').
     */
    defaultType: 'panel',

    // private
    initComponent : function(){
        Ext.Container.superclass.initComponent.call(this);

        this.addEvents(
            /**
             * @event afterlayout
             * Fires when the components in this container are arranged by the associated layout manager.
             * @param {Ext.Container} this
             * @param {ContainerLayout} layout The ContainerLayout implementation for this container
             */
            'afterlayout',
            /**
             * @event beforeadd
             * Fires before any {@link Ext.Component} is added or inserted into the container.
             * A handler can return false to cancel the add.
             * @param {Ext.Container} this
             * @param {Ext.Component} component The component being added
             * @param {Number} index The index at which the component will be added to the container's items collection
             */
            'beforeadd',
            /**
             * @event beforeremove
             * Fires before any {@link Ext.Component} is removed from the container.  A handler can return
             * false to cancel the remove.
             * @param {Ext.Container} this
             * @param {Ext.Component} component The component being removed
             */
            'beforeremove',
            /**
             * @event add
             * Fires after any {@link Ext.Component} is added or inserted into the container.
             * @param {Ext.Container} this
             * @param {Ext.Component} component The component that was added
             * @param {Number} index The index at which the component was added to the container's items collection
             */
            'add',
            /**
             * @event remove
             * Fires after any {@link Ext.Component} is removed from the container.
             * @param {Ext.Container} this
             * @param {Ext.Component} component The component that was removed
             */
            'remove'
        );

        /**
         * The collection of components in this container as a {@link Ext.util.MixedCollection}
         * @type MixedCollection
         * @property items
         */
        var items = this.items;
        if(items){
            delete this.items;
            if(Ext.isArray(items)){
                this.add.apply(this, items);
            }else{
                this.add(items);
            }
        }
    },

    // private
    initItems : function(){
        if(!this.items){
            this.items = new Ext.util.MixedCollection(false, this.getComponentId);
            this.getLayout(); // initialize the layout
        }
    },

    // private
    setLayout : function(layout){
        if(this.layout && this.layout != layout){
            this.layout.setContainer(null);
        }
        this.initItems();
        this.layout = layout;
        layout.setContainer(this);
    },

    // private
    render : function(){
        Ext.Container.superclass.render.apply(this, arguments);
        if(this.layout){
            if(typeof this.layout == 'string'){
                this.layout = new Ext.Container.LAYOUTS[this.layout.toLowerCase()](this.layoutConfig);
            }
            this.setLayout(this.layout);

            if(this.activeItem !== undefined){
                var item = this.activeItem;
                delete this.activeItem;
                this.layout.setActiveItem(item);
                return;
            }
        }
        if(!this.ownerCt){
            this.doLayout();
        }
        if(this.monitorResize === true){
            Ext.EventManager.onWindowResize(this.doLayout, this, [false]);
        }
    },

    // protected - should only be called by layouts
    getLayoutTarget : function(){
        return this.el;
    },

    // private - used as the key lookup function for the items collection
    getComponentId : function(comp){
        return comp.itemId || comp.id;
    },

    /**
     * Adds a component to this container. Fires the beforeadd event before adding,
     * then fires the add event after the component has been added.  If the container is
     * already rendered when add is called, you may need to call {@link #doLayout} to refresh
     * the view.  This is required so that you can add multiple child components if needed
     * while only refreshing the layout once.
     * @param {Ext.Component/Object} component The component to add.<br><br>
     * Ext uses lazy rendering, and will only render the added Component should
     * it become necessary.<br><br>
     * A Component config object may be passed in order to avoid the overhead of
     * constructing a real Component object if lazy rendering might mean that the
     * added Component will not be rendered immediately. To take advantage of this
     * "lazy instantiation", set the {@link Ext.Component#xtype} config property to
     * the registered type of the Component wanted.<br><br>
     * For a list of all available xtypes, see {@link Ext.Component}.
     * @return {Ext.Component} component The Component (or config object) that was
     * added with the Container's default config values applied.
     */
    add : function(comp){
        if(!this.items){
            this.initItems();
        }
        var a = arguments, len = a.length;
        if(len > 1){
            for(var i = 0; i < len; i++) {
                this.add(a[i]);
            }
            return;
        }
        var c = this.lookupComponent(this.applyDefaults(comp));
        var pos = this.items.length;
        if(this.fireEvent('beforeadd', this, c, pos) !== false && this.onBeforeAdd(c) !== false){
            this.items.add(c);
            c.ownerCt = this;
            this.fireEvent('add', this, c, pos);
        }
        return c;
    },

    /**
     * Inserts a Component into this Container at a specified index. Fires the
     * beforeadd event before inserting, then fires the add event after the
     * Component has been inserted.
     * @param {Number} index The index at which the Component will be inserted
     * into the Container's items collection
     * @param {Ext.Component} component The child Component to insert.<br><br>
     * Ext uses lazy rendering, and will only render the inserted Component should
     * it become necessary.<br><br>
     * A Component config object may be passed in order to avoid the overhead of
     * constructing a real Component object if lazy rendering might mean that the
     * inserted Component will not be rendered immediately. To take advantage of
     * this "lazy instantiation", set the {@link Ext.Component#xtype} config
     * property to the registered type of the Component wanted.<br><br>
     * For a list of all available xtypes, see {@link Ext.Component}.
     * @return {Ext.Component} component The Component (or config object) that was
     * inserted with the Container's default config values applied.
     */
    insert : function(index, comp){
        if(!this.items){
            this.initItems();
        }
        var a = arguments, len = a.length;
        if(len > 2){
            for(var i = len-1; i >= 1; --i) {
                this.insert(index, a[i]);
            }
            return;
        }
        var c = this.lookupComponent(this.applyDefaults(comp));

        if(c.ownerCt == this && this.items.indexOf(c) < index){
            --index;
        }

        if(this.fireEvent('beforeadd', this, c, index) !== false && this.onBeforeAdd(c) !== false){
            this.items.insert(index, c);
            c.ownerCt = this;
            this.fireEvent('add', this, c, index);
        }
        return c;
    },

    // private
    applyDefaults : function(c){
        if(this.defaults){
            if(typeof c == 'string'){
                c = Ext.ComponentMgr.get(c);
                Ext.apply(c, this.defaults);
            }else if(!c.events){
                Ext.applyIf(c, this.defaults);
            }else{
                Ext.apply(c, this.defaults);
            }
        }
        return c;
    },

    // private
    onBeforeAdd : function(item){
        if(item.ownerCt){
            item.ownerCt.remove(item, false);
        }
        if(this.hideBorders === true){
            item.border = (item.border === true);
        }
    },

    /**
     * Removes a component from this container.  Fires the beforeremove event before removing, then fires
     * the remove event after the component has been removed.
     * @param {Component/String} component The component reference or id to remove
     * @param {Boolean} autoDestroy (optional) True to automatically invoke the component's {@link Ext.Component#destroy} function
     */
    remove : function(comp, autoDestroy){
        var c = this.getComponent(comp);
        if(c && this.fireEvent('beforeremove', this, c) !== false){
            this.items.remove(c);
            delete c.ownerCt;
            if(autoDestroy === true || (autoDestroy !== false && this.autoDestroy)){
                c.destroy();
            }
            if(this.layout && this.layout.activeItem == c){
                delete this.layout.activeItem;
            }
            this.fireEvent('remove', this, c);
        }
        return c;
    },

    /**
     * Gets a direct child Component by id, or by index.
     * @param {String/Number} id or index of child Component to return.
     * @return Ext.Component
     */
    getComponent : function(comp){
        if(typeof comp == 'object'){
            return comp;
        }
        return this.items.get(comp);
    },

    // private
    lookupComponent : function(comp){
        if(typeof comp == 'string'){
            return Ext.ComponentMgr.get(comp);
        }else if(!comp.events){
            return this.createComponent(comp);
        }
        return comp;
    },

    // private
    createComponent : function(config){
        return Ext.ComponentMgr.create(config, this.defaultType);
    },

    /**
     * Force this container's layout to be recalculated. A call to this function is required after adding a new component
     * to an already rendered container, or possibly after changing sizing/position properties of child components.
     * @param {Boolean} shallow (optional) True to only calc the layout of this component, and let child components auto
     * calc layouts as required (defaults to false, which calls doLayout recursively for each subcontainer)
     */
    doLayout : function(shallow){
        if(this.rendered && this.layout){
            this.layout.layout();
        }
        if(shallow !== false && this.items){
            var cs = this.items.items;
            for(var i = 0, len = cs.length; i < len; i++) {
                var c  = cs[i];
                if(c.doLayout){
                    c.doLayout();
                }
            }
        }
    },

    /**
     * Returns the layout currently in use by the container.  If the container does not currently have a layout
     * set, a default {@link Ext.layout.ContainerLayout} will be created and set as the container's layout.
     * @return {ContainerLayout} layout The container's layout
     */
    getLayout : function(){
        if(!this.layout){
            var layout = new Ext.layout.ContainerLayout(this.layoutConfig);
            this.setLayout(layout);
        }
        return this.layout;
    },

    // private
    onDestroy : function(){
        if(this.items){
            var cs = this.items.items;
            for(var i = 0, len = cs.length; i < len; i++) {
                Ext.destroy(cs[i]);
            }
        }
        if(this.monitorResize){
            Ext.EventManager.removeResizeListener(this.doLayout, this);
        }
        Ext.Container.superclass.onDestroy.call(this);
    },

    /**
     * Bubbles up the component/container heirarchy, calling the specified function with each component. The scope (<i>this</i>) of
     * function call will be the scope provided or the current component. The arguments to the function
     * will be the args provided or the current component. If the function returns false at any point,
     * the bubble is stopped.
     * @param {Function} fn The function to call
     * @param {Object} scope (optional) The scope of the function (defaults to current node)
     * @param {Array} args (optional) The args to call the function with (default to passing the current component)
     */
    bubble : function(fn, scope, args){
        var p = this;
        while(p){
            if(fn.apply(scope || p, args || [p]) === false){
                break;
            }
            p = p.ownerCt;
        }
    },

    /**
     * Cascades down the component/container heirarchy from this component (called first), calling the specified function with
     * each component. The scope (<i>this</i>) of
     * function call will be the scope provided or the current component. The arguments to the function
     * will be the args provided or the current component. If the function returns false at any point,
     * the cascade is stopped on that branch.
     * @param {Function} fn The function to call
     * @param {Object} scope (optional) The scope of the function (defaults to current component)
     * @param {Array} args (optional) The args to call the function with (defaults to passing the current component)
     */
    cascade : function(fn, scope, args){
        if(fn.apply(scope || this, args || [this]) !== false){
            if(this.items){
                var cs = this.items.items;
                for(var i = 0, len = cs.length; i < len; i++){
                    if(cs[i].cascade){
                        cs[i].cascade(fn, scope, args);
                    }else{
                        fn.apply(scope || this, args || [cs[i]]);
                    }
                }
            }
        }
    },

    /**
     * Find a component under this container at any level by id
     * @param {String} id
     * @return Ext.Component
     */
    findById : function(id){
        var m, ct = this;
        this.cascade(function(c){
            if(ct != c && c.id === id){
                m = c;
                return false;
            }
        });
        return m || null;
    },

    /**
     * Find a component under this container at any level by xtype or class
     * @param {String/Class} xtype The xtype string for a component, or the class of the component directly
     * @return {Array} Array of Ext.Components
     */
    findByType : function(xtype){
        return typeof xtype == 'function' ?
            this.findBy(function(c){
                return c.constructor === xtype;
            }) :
            this.findBy(function(c){
                return c.constructor.xtype === xtype;
            });
    },

    /**
     * Find a component under this container at any level by property
     * @param {String} prop
     * @param {String} value
     * @return {Array} Array of Ext.Components
     */
    find : function(prop, value){
        return this.findBy(function(c){
            return c[prop] === value;
        });
    },

    /**
     * Find a component under this container at any level by a custom function. If the passed function returns
     * true, the component will be included in the results. The passed function is called with the arguments (component, this container).
     * @param {Function} fcn
     * @param {Object} scope (optional)
     * @return {Array} Array of Ext.Components
     */
    findBy : function(fn, scope){
        var m = [], ct = this;
        this.cascade(function(c){
            if(ct != c && fn.call(scope || c, c, ct) === true){
                m.push(c);
            }
        });
        return m;
    }
});

Ext.Container.LAYOUTS = {};
Ext.reg('container', Ext.Container);
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.layout.ContainerLayout
 * Every layout is composed of one or more {@link Ext.Container} elements internally, and ContainerLayout provides
 * the basic foundation for all other layout classes in Ext.  It is a non-visual class that simply provides the
 * base logic required for a Container to function as a layout.  This class is intended to be extended and should
 * generally not need to be created directly via the new keyword.
 */
Ext.layout.ContainerLayout = function(config){
    Ext.apply(this, config);
};

Ext.layout.ContainerLayout.prototype = {
    /**
     * @cfg {String} extraCls
     * An optional extra CSS class that will be added to the container (defaults to '').  This can be useful for
     * adding customized styles to the container or any of its children using standard CSS rules.
     */
    /**
     * @cfg {Boolean} renderHidden
     * True to hide each contained item on render (defaults to false).
     */

    /**
     * A reference to the {@link Ext.Component} that is active.  For example,
     * if(myPanel.layout.activeItem.id == 'item-1') { ... }.  activeItem only applies to layout styles that can
     * display items one at a time (like {@link Ext.layout.Accordion}, {@link Ext.layout.CardLayout}
     * and {@link Ext.layout.FitLayout}).  Read-only.  Related to {@link Ext.Container#activeItem}.
     * @type {Ext.Component}
     * @property activeItem
     */

    // private
    monitorResize:false,
    // private
    activeItem : null,

    // private
    layout : function(){
        var target = this.container.getLayoutTarget();
        this.onLayout(this.container, target);
        this.container.fireEvent('afterlayout', this.container, this);
    },

    // private
    onLayout : function(ct, target){
        this.renderAll(ct, target);
    },

    // private
    isValidParent : function(c, target){
		var el = c.getPositionEl ? c.getPositionEl() : c.getEl();
		return el.dom.parentNode == target.dom;
    },

    // private
    renderAll : function(ct, target){
        var items = ct.items.items;
        for(var i = 0, len = items.length; i < len; i++) {
            var c = items[i];
            if(c && (!c.rendered || !this.isValidParent(c, target))){
                this.renderItem(c, i, target);
            }
        }
    },

    // private
    renderItem : function(c, position, target){
        if(c && !c.rendered){
            c.render(target, position);
            if(this.extraCls){
            	var t = c.getPositionEl ? c.getPositionEl() : c;
            	t.addClass(this.extraCls);
            }
            if (this.renderHidden && c != this.activeItem) {
                c.hide();
            }
        }else if(c && !this.isValidParent(c, target)){
            if(this.extraCls){
                c.addClass(this.extraCls);
            }
            if(typeof position == 'number'){
                position = target.dom.childNodes[position];
            }
            target.dom.insertBefore(c.getEl().dom, position || null);
            if (this.renderHidden && c != this.activeItem) {
                c.hide();
            }
        }
    },

    // private
    onResize: function(){
        if(this.container.collapsed){
            return;
        }
        var b = this.container.bufferResize;
        if(b){
            if(!this.resizeTask){
                this.resizeTask = new Ext.util.DelayedTask(this.layout, this);
                this.resizeBuffer = typeof b == 'number' ? b : 100;
            }
            this.resizeTask.delay(this.resizeBuffer);
        }else{
            this.layout();
        }
    },

    // private
    setContainer : function(ct){
        if(this.monitorResize && ct != this.container){
            if(this.container){
                this.container.un('resize', this.onResize, this);
            }
            if(ct){
                ct.on('resize', this.onResize, this);
            }
        }
        this.container = ct;
    },

    // private
    parseMargins : function(v){
        var ms = v.split(' ');
        var len = ms.length;
        if(len == 1){
            ms[1] = ms[0];
            ms[2] = ms[0];
            ms[3] = ms[0];
        }
        if(len == 2){
            ms[2] = ms[0];
            ms[3] = ms[1];
        }
        return {
            top:parseInt(ms[0], 10) || 0,
            right:parseInt(ms[1], 10) || 0,
            bottom:parseInt(ms[2], 10) || 0,
            left:parseInt(ms[3], 10) || 0
        };
    }
};
Ext.Container.LAYOUTS['auto'] = Ext.layout.ContainerLayout;
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.layout.FitLayout
 * @extends Ext.layout.ContainerLayout
 * <p>This is a base class for layouts that contain a single item that automatically expands to fill the layout's
 * container.  This class is intended to be extended or created via the layout:'fit' {@link Ext.Container#layout}
 * config, and should generally not need to be created directly via the new keyword.</p>
 * <p>FitLayout does not have any direct config options (other than inherited ones).  To fit a panel to a container
 * using FitLayout, simply set layout:'fit' on the container and add a single panel to it.  If the container has
 * multiple panels, only the first one will be displayed.  Example usage:</p>
 * <pre><code>
var p = new Ext.Panel({
    title: 'Fit Layout',
    layout:'fit',
    items: {
        title: 'Inner Panel',
        html: '&lt;p&gt;This is the inner panel content&lt;/p&gt;',
        border: false
    }
});
</code></pre>
 */
Ext.layout.FitLayout = Ext.extend(Ext.layout.ContainerLayout, {
    // private
    monitorResize:true,

    // private
    onLayout : function(ct, target){
        Ext.layout.FitLayout.superclass.onLayout.call(this, ct, target);
        if(!this.container.collapsed){
            this.setItemSize(this.activeItem || ct.items.itemAt(0), target.getStyleSize());
        }
    },

    // private
    setItemSize : function(item, size){
        if(item && size.height > 0){ // display none?
            item.setSize(size);
        }
    }
});
Ext.Container.LAYOUTS['fit'] = Ext.layout.FitLayout;
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.layout.CardLayout
 * @extends Ext.layout.FitLayout
 * <p>This layout contains multiple panels, each fit to the container, where only a single panel can be
 * visible at any given time.  This layout style is most commonly used for wizards, tab implementations, etc.
 * This class is intended to be extended or created via the layout:'card' {@link Ext.Container#layout} config,
 * and should generally not need to be created directly via the new keyword.</p>
 * <p>The CardLayout's focal method is {@link #setActiveItem}.  Since only one panel is displayed at a time,
 * the only way to move from one panel to the next is by calling setActiveItem, passing the id or index of
 * the next panel to display.  The layout itself does not provide a mechanism for handling this navigation,
 * so that functionality must be provided by the developer.</p>
 * <p>In the following example, a simplistic wizard setup is demonstrated.  A button bar is added
 * to the footer of the containing panel to provide navigation buttons.  The buttons will be handled by a
 * common navigation routine -- for this example, the implementation of that routine has been ommitted since
 * it can be any type of custom logic.  Note that other uses of a CardLayout (like a tab control) would require a
 * completely different implementation.  For serious implementations, a better approach would be to extend
 * CardLayout to provide the custom functionality needed.  Example usage:</p>
 * <pre><code>
var navHandler = function(direction){
    // This routine could contain business logic required to manage the navigation steps.
    // It would call setActiveItem as needed, manage navigation button state, handle any
    // branching logic that might be required, handle alternate actions like cancellation
    // or finalization, etc.  A complete wizard implementation could get pretty
    // sophisticated depending on the complexity required, and should probably be
    // done as a subclass of CardLayout in a real-world implementation.
};

var card = new Ext.Panel({
    title: 'Example Wizard',
    layout:'card',
    activeItem: 0, // make sure the active item is set on the container config!
    bodyStyle: 'padding:15px',
    defaults: {
        // applied to each contained panel
        border:false
    },
    // just an example of one possible navigation scheme, using buttons
    bbar: [
        {
            id: 'move-prev',
            text: 'Back',
            handler: navHandler.createDelegate(this, [-1]),
            disabled: true
        },
        '->', // greedy spacer so that the buttons are aligned to each side
        {
            id: 'move-next',
            text: 'Next',
            handler: navHandler.createDelegate(this, [1])
        }
    ],
    // the panels (or "cards") within the layout
    items: [{
        id: 'card-0',
        html: '&lt;h1&gt;Welcome to the Wizard!&lt;/h1&gt;&lt;p&gt;Step 1 of 3&lt;/p&gt;'
    },{
        id: 'card-1',
        html: '&lt;p&gt;Step 2 of 3&lt;/p&gt;'
    },{
        id: 'card-2',
        html: '&lt;h1&gt;Congratulations!&lt;/h1&gt;&lt;p&gt;Step 3 of 3 - Complete&lt;/p&gt;'
    }]
});
</code></pre>
 */
Ext.layout.CardLayout = Ext.extend(Ext.layout.FitLayout, {
    /**
     * @cfg {Boolean} deferredRender
     * True to render each contained item at the time it becomes active, false to render all contained items
     * as soon as the layout is rendered (defaults to false).  If there is a significant amount of content or
     * a lot of heavy controls being rendered into panels that are not displayed by default, setting this to
     * true might improve performance.
     */
    deferredRender : false,

    // private
    renderHidden : true,

    /**
     * Sets the active (visible) item in the layout.
     * @param {String/Number} item The string component id or numeric index of the item to activate
     */
    setActiveItem : function(item){
        item = this.container.getComponent(item);
        if(this.activeItem != item){
            if(this.activeItem){
                this.activeItem.hide();
            }
            this.activeItem = item;
            item.show();
            this.layout();
        }
    },

    // private
    renderAll : function(ct, target){
        if(this.deferredRender){
            this.renderItem(this.activeItem, undefined, target);
        }else{
            Ext.layout.CardLayout.superclass.renderAll.call(this, ct, target);
        }
    }
});
Ext.Container.LAYOUTS['card'] = Ext.layout.CardLayout;
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.layout.AnchorLayout
 * @extends Ext.layout.ContainerLayout
 * <p>This is a layout that enables anchoring of contained elements relative to the container's dimensions.  If
 * the container is resized, all anchored items are automatically rerendered according to their anchor rules.
 * This class is intended to be extended or created via the layout:'anchor' {@link Ext.Container#layout} config,
 * and should generally not need to be created directly via the new keyword.</p>
 * <p>AnchorLayout does not have any direct config options (other than inherited ones).  However, the container
 * using the AnchorLayout can supply an anchoring-specific config property of <b>anchorSize</b>.  By default,
 * AnchorLayout will calculate anchor measurements based on the size of the container itself.  However, if
 * anchorSize is specifed, the layout will use it as a virtual container for the purposes of calculating anchor
 * measurements based on it instead, allowing the container to be sized independently of the anchoring logic if necessary.</p>
 * <p>The items added to an AnchorLayout can also supply an anchoring-specific config property of <b>anchor</b> which
 * is a string containing two values: the horizontal anchor value and the vertical anchor value (for example, '100% 50%').
 * This value is what tells the layout how the item should be anchored to the container.  The following types of
 * anchor values are supported:
 * <ul>
 * <li><b>Percentage</b>: Any value between 1 and 100, expressed as a percentage.  The first anchor is the percentage
 * width that the item should take up within the container, and the second is the percentage height.  Example: '100% 50%'
 * would render an item the complete width of the container and 1/2 its height.  If only one anchor value is supplied
 * it is assumed to be the width value and the height will default to auto.</li>
 * <li><b>Offsets</b>: Any positive or negative integer value.  The first anchor is the offset from the right edge of
 * the container, and the second is the offset from the bottom edge.  Example: '-50 -100' would render an item the
 * complete width of the container minus 50 pixels and the complete height minus 100 pixels.  If only one anchor value
 * is supplied it is assumed to be the right offset value and the bottom offset will default to 0.</li>
 * <li><b>Sides</b>: Valid values are 'right' (or 'r') and 'bottom' (or 'b').  Either the container must have a fixed
 * size or an anchorSize config value defined at render time in order for these to have any effect.</li>
 * </ul>
 * <p>Anchor values can also be mixed as needed.  For example, '-50 75%' would render the width offset from the
 * container right edge by 50 pixels and 75% of the container's height.</p>
 */
Ext.layout.AnchorLayout = Ext.extend(Ext.layout.ContainerLayout, {
    // private
    monitorResize:true,

    // private
    getAnchorViewSize : function(ct, target){
        return target.dom == document.body ?
                   target.getViewSize() : target.getStyleSize();
    },

    // private
    onLayout : function(ct, target){
        Ext.layout.AnchorLayout.superclass.onLayout.call(this, ct, target);

        var size = this.getAnchorViewSize(ct, target);

        var w = size.width, h = size.height;

        if(w < 20 || h < 20){
            return;
        }

        // find the container anchoring size
        var aw, ah;
        if(ct.anchorSize){
            if(typeof ct.anchorSize == 'number'){
                aw = ct.anchorSize;
            }else{
                aw = ct.anchorSize.width;
                ah = ct.anchorSize.height;
            }
        }else{
            aw = ct.initialConfig.width;
            ah = ct.initialConfig.height;
        }

        var cs = ct.items.items, len = cs.length, i, c, a, cw, ch;
        for(i = 0; i < len; i++){
            c = cs[i];
            if(c.anchor){
                a = c.anchorSpec;
                if(!a){ // cache all anchor values
                    var vs = c.anchor.split(' ');
                    c.anchorSpec = a = {
                        right: this.parseAnchor(vs[0], c.initialConfig.width, aw),
                        bottom: this.parseAnchor(vs[1], c.initialConfig.height, ah)
                    };
                }
                cw = a.right ? this.adjustWidthAnchor(a.right(w), c) : undefined;
                ch = a.bottom ? this.adjustHeightAnchor(a.bottom(h), c) : undefined;

                if(cw || ch){
                    c.setSize(cw || undefined, ch || undefined);
                }
            }
        }
    },

    // private
    parseAnchor : function(a, start, cstart){
        if(a && a != 'none'){
            var last;
            if(/^(r|right|b|bottom)$/i.test(a)){   // standard anchor
                var diff = cstart - start;
                return function(v){
                    if(v !== last){
                        last = v;
                        return v - diff;
                    }
                }
            }else if(a.indexOf('%') != -1){
                var ratio = parseFloat(a.replace('%', ''))*.01;   // percentage
                return function(v){
                    if(v !== last){
                        last = v;
                        return Math.floor(v*ratio);
                    }
                }
            }else{
                a = parseInt(a, 10);
                if(!isNaN(a)){                            // simple offset adjustment
                    return function(v){
                        if(v !== last){
                            last = v;
                            return v + a;
                        }
                    }
                }
            }
        }
        return false;
    },

    // private
    adjustWidthAnchor : function(value, comp){
        return value;
    },

    // private
    adjustHeightAnchor : function(value, comp){
        return value;
    }
    
    /**
     * @property activeItem
     * @hide
     */
});
Ext.Container.LAYOUTS['anchor'] = Ext.layout.AnchorLayout;
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.layout.ColumnLayout
 * @extends Ext.layout.ContainerLayout
 * <p>This is the layout style of choice for creating structural layouts in a multi-column format where the width of
 * each column can be specified as a percentage or fixed width, but the height is allowed to vary based on the content.
 * This class is intended to be extended or created via the layout:'column' {@link Ext.Container#layout} config,
 * and should generally not need to be created directly via the new keyword.</p>
 * <p>ColumnLayout does not have any direct config options (other than inherited ones), but it does support a
 * specific config property of <b><tt>columnWidth</tt></b> that can be included in the config of any panel added to it.  The
 * layout will use the columnWidth (if present) or width of each panel during layout to determine how to size each panel.
 * If width or columnWidth is not specified for a given panel, its width will default to the panel's width (or auto).</p>
 * <p>The width property is always evaluated as pixels, and must be a number greater than or equal to 1.
 * The columnWidth property is always evaluated as a percentage, and must be a decimal value greater than 0 and
 * less than 1 (e.g., .25).</p>
 * <p>The basic rules for specifying column widths are pretty simple.  The logic makes two passes through the
 * set of contained panels.  During the first layout pass, all panels that either have a fixed width or none
 * specified (auto) are skipped, but their widths are subtracted from the overall container width.  During the second
 * pass, all panels with columnWidths are assigned pixel widths in proportion to their percentages based on
 * the total <b>remaining</b> container width.  In other words, percentage width panels are designed to fill the space
 * left over by all the fixed-width and/or auto-width panels.  Because of this, while you can specify any number of columns
 * with different percentages, the columnWidths must always add up to 1 (or 100%) when added together, otherwise your
 * layout may not render as expected.  Example usage:</p>
 * <pre><code>
// All columns are percentages -- they must add up to 1
var p = new Ext.Panel({
    title: 'Column Layout - Percentage Only',
    layout:'column',
    items: [{
        title: 'Column 1',
        columnWidth: .25 
    },{
        title: 'Column 2',
        columnWidth: .6
    },{
        title: 'Column 3',
        columnWidth: .15
    }]
});

// Mix of width and columnWidth -- all columnWidth values must add up
// to 1. The first column will take up exactly 120px, and the last two
// columns will fill the remaining container width.
var p = new Ext.Panel({
    title: 'Column Layout - Mixed',
    layout:'column',
    items: [{
        title: 'Column 1',
        width: 120
    },{
        title: 'Column 2',
        columnWidth: .8
    },{
        title: 'Column 3',
        columnWidth: .2
    }]
});
</code></pre>
 */
Ext.layout.ColumnLayout = Ext.extend(Ext.layout.ContainerLayout, {
    // private
    monitorResize:true,
    // private
    extraCls: 'x-column',

    scrollOffset : 0,

    // private
    isValidParent : function(c, target){
        return c.getEl().dom.parentNode == this.innerCt.dom;
    },

    // private
    onLayout : function(ct, target){
        var cs = ct.items.items, len = cs.length, c, i;

        if(!this.innerCt){
            target.addClass('x-column-layout-ct');

            // the innerCt prevents wrapping and shuffling while
            // the container is resizing
            this.innerCt = target.createChild({cls:'x-column-inner'});
            this.innerCt.createChild({cls:'x-clear'});
        }
        this.renderAll(ct, this.innerCt);

        var size = target.getViewSize();

        if(size.width < 1 && size.height < 1){ // display none?
            return;
        }

        var w = size.width - target.getPadding('lr') - this.scrollOffset,
            h = size.height - target.getPadding('tb'),
            pw = w;

        this.innerCt.setWidth(w);
        
        // some columns can be percentages while others are fixed
        // so we need to make 2 passes

        for(i = 0; i < len; i++){
            c = cs[i];
            if(!c.columnWidth){
                pw -= (c.getSize().width + c.getEl().getMargins('lr'));
            }
        }

        pw = pw < 0 ? 0 : pw;

        for(i = 0; i < len; i++){
            c = cs[i];
            if(c.columnWidth){
                c.setSize(Math.floor(c.columnWidth*pw) - c.getEl().getMargins('lr'));
            }
        }
    }
    
    /**
     * @property activeItem
     * @hide
     */
});

Ext.Container.LAYOUTS['column'] = Ext.layout.ColumnLayout;
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.layout.BorderLayout
 * @extends Ext.layout.ContainerLayout
 * <p>This is a multi-pane, application-oriented UI layout style that supports multiple nested panels, automatic
 * split bars between regions and built-in expanding and collapsing of regions.
 * This class is intended to be extended or created via the layout:'border' {@link Ext.Container#layout} config,
 * and should generally not need to be created directly via the new keyword.</p>
 * <p>BorderLayout does not have any direct config options (other than inherited ones).  All configs available
 * for customizing the BorderLayout are at the {@link Ext.layout.BorderLayout.Region} and
 * {@link Ext.layout.BorderLayout.SplitRegion} levels.  Example usage:</p>
 * <pre><code>
var border = new Ext.Panel({
    title: 'Border Layout',
    layout:'border',
    items: [{
        title: 'South Panel',
        region: 'south',
        height: 100,
        minSize: 75,
        maxSize: 250,
        margins: '0 5 5 5'
    },{
        title: 'West Panel',
        region:'west',
        margins: '5 0 0 5',
        cmargins: '5 5 0 5',
        width: 200,
        minSize: 100,
        maxSize: 300
    },{
        title: 'Main Content',
        region:'center',
        margins: '5 5 0 0'
    }]
});
</code></pre>
 */
Ext.layout.BorderLayout = Ext.extend(Ext.layout.ContainerLayout, {
    // private
    monitorResize:true,
    // private
    rendered : false,

    // private
    onLayout : function(ct, target){
        var collapsed;
        if(!this.rendered){
            target.position();
            target.addClass('x-border-layout-ct');
            var items = ct.items.items;
            collapsed = [];
            for(var i = 0, len = items.length; i < len; i++) {
                var c = items[i];
                var pos = c.region;
                if(c.collapsed){
                    collapsed.push(c);
                }
                c.collapsed = false;
                if(!c.rendered){
                    c.cls = c.cls ? c.cls +' x-border-panel' : 'x-border-panel';
                    c.render(target, i);
                }
                this[pos] = pos != 'center' && c.split ?
                    new Ext.layout.BorderLayout.SplitRegion(this, c.initialConfig, pos) :
                    new Ext.layout.BorderLayout.Region(this, c.initialConfig, pos);
                this[pos].render(target, c);
            }
            this.rendered = true;
        }

        var size = target.getViewSize();
        if(size.width < 20 || size.height < 20){ // display none?
            if(collapsed){
                this.restoreCollapsed = collapsed;
            }
            return;
        }else if(this.restoreCollapsed){
            collapsed = this.restoreCollapsed;
            delete this.restoreCollapsed;
        }

        var w = size.width, h = size.height;
        var centerW = w, centerH = h, centerY = 0, centerX = 0;

        var n = this.north, s = this.south, west = this.west, e = this.east, c = this.center;
        if(!c){
            throw 'No center region defined in BorderLayout ' + ct.id;
        }

        if(n && n.isVisible()){
            var b = n.getSize();
            var m = n.getMargins();
            b.width = w - (m.left+m.right);
            b.x = m.left;
            b.y = m.top;
            centerY = b.height + b.y + m.bottom;
            centerH -= centerY;
            n.applyLayout(b);
        }
        if(s && s.isVisible()){
            var b = s.getSize();
            var m = s.getMargins();
            b.width = w - (m.left+m.right);
            b.x = m.left;
            var totalHeight = (b.height + m.top + m.bottom);
            b.y = h - totalHeight + m.top;
            centerH -= totalHeight;
            s.applyLayout(b);
        }
        if(west && west.isVisible()){
            var b = west.getSize();
            var m = west.getMargins();
            b.height = centerH - (m.top+m.bottom);
            b.x = m.left;
            b.y = centerY + m.top;
            var totalWidth = (b.width + m.left + m.right);
            centerX += totalWidth;
            centerW -= totalWidth;
            west.applyLayout(b);
        }
        if(e && e.isVisible()){
            var b = e.getSize();
            var m = e.getMargins();
            b.height = centerH - (m.top+m.bottom);
            var totalWidth = (b.width + m.left + m.right);
            b.x = w - totalWidth + m.left;
            b.y = centerY + m.top;
            centerW -= totalWidth;
            e.applyLayout(b);
        }

        var m = c.getMargins();
        var centerBox = {
            x: centerX + m.left,
            y: centerY + m.top,
            width: centerW - (m.left+m.right),
            height: centerH - (m.top+m.bottom)
        };
        c.applyLayout(centerBox);

        if(collapsed){
            for(var i = 0, len = collapsed.length; i < len; i++){
                collapsed[i].collapse(false);
            }
        }

        if(Ext.isIE && Ext.isStrict){ // workaround IE strict repainting issue
            target.repaint();
        }
    }
    
    /**
     * @property activeItem
     * @hide
     */
});

/**
 * @class Ext.layout.BorderLayout.Region
 * This is a region of a BorderLayout that acts as a subcontainer within the layout.  Each region has its own
 * layout that is independent of other regions and the containing BorderLayout, and can be any of the valid
 * Ext layout types.  Region size is managed automatically and cannot be changed by the user -- for resizable
 * regions, see {@link Ext.layout.BorderLayout.SplitRegion}.
 * @constructor
 * Create a new Region.
 * @param {Layout} layout Any valid Ext layout class
 * @param {Object} config The configuration options
 * @param {String} position The region position.  Valid values are: north, south, east, west and center.  Every
 * BorderLayout must have a center region for the primary content -- all other regions are optional.
 */
Ext.layout.BorderLayout.Region = function(layout, config, pos){
    Ext.apply(this, config);
    this.layout = layout;
    this.position = pos;
    this.state = {};
    if(typeof this.margins == 'string'){
        this.margins = this.layout.parseMargins(this.margins);
    }
    this.margins = Ext.applyIf(this.margins || {}, this.defaultMargins);
    if(this.collapsible){
        if(typeof this.cmargins == 'string'){
            this.cmargins = this.layout.parseMargins(this.cmargins);
        }
        if(this.collapseMode == 'mini' && !this.cmargins){
            this.cmargins = {left:0,top:0,right:0,bottom:0};
        }else{
            this.cmargins = Ext.applyIf(this.cmargins || {},
                pos == 'north' || pos == 'south' ? this.defaultNSCMargins : this.defaultEWCMargins);
        }
    }
};

Ext.layout.BorderLayout.Region.prototype = {
    /**
     * @cfg {Boolean} animFloat
     * When a collapsed region's bar is clicked, the region's panel will be displayed as a floated panel that will
     * close again once the user mouses out of that panel (or clicks out if autoHide = false).  Setting animFloat
     * to false will prevent the open and close of these floated panels from being animated (defaults to true).
     */
    /**
     * @cfg {Boolean} autoHide
     * When a collapsed region's bar is clicked, the region's panel will be displayed as a floated panel.  If
     * autoHide is true, the panel will automatically hide after the user mouses out of the panel.  If autoHide
     * is false, the panel will continue to display until the user clicks outside of the panel (defaults to true).
     */
	/**
	 * @cfg {Boolean} collapsed
	 * By default, collapsible regions will be visible when rendered. Set the collapsed config to true to render
	 * the region as collapsed.
	 */
    /**
     * @cfg {String} collapseMode
     * By default, collapsible regions are collapsed by clicking the expand/collapse tool button that renders into
     * the region's title bar.  Optionally, when collapseMode is set to 'mini' the region's split bar will also
     * display a small collapse button in the center of the bar.  In 'mini' mode the region will collapse to a
     * thinner bar than in normal mode.  By default collapseMode is undefined, and the only two supported values
     * are undefined and 'mini'.  Note that if a collapsible region does not have a title bar, then collapseMode
     * must be set to 'mini' in order for the region to be collapsible by the user as the tool button will not
     * be rendered.
     */
    /**
     * @cfg {Object} margins
     * An object containing margins to apply to the region in the format {left: (left margin), top: (top margin),
     * right: (right margin), bottom: (bottom margin)}
     */
    /**
     * @cfg {Object} cmargins
     * An object containing margins to apply to the region's collapsed element in the format {left: (left margin),
     * top: (top margin), right: (right margin), bottom: (bottom margin)}
     */
    /**
     * @cfg {Boolean} collapsible
     * True to allow the user to collapse this region (defaults to false).  If true, an expand/collapse tool button
     * will automatically be rendered into the title bar of the region, otherwise the button will not be shown.
     * Note that a title bar is required to display the toggle button -- if no region title is specified, the
     * region will only be collapsible if {@link #collapseMode} is set to 'mini'.
     */
    collapsible : false,
    /**
     * @cfg {Boolean} split
     * True to display a {@link Ext.SplitBar} between this region and its neighbor, allowing the user to resize
     * the regions dynamically (defaults to false).  When split = true, it is common to specify a {@link #minSize}
     * and {@link #maxSize} for the region.
     */
    split:false,
    /**
     * @cfg {Boolean} floatable
     * True to allow clicking a collapsed region's bar to display the region's panel floated above the layout,
     * false to force the user to fully expand a collapsed region by clicking the expand button to see it again
     * (defaults to true).
     */
    floatable: true,
    /**
     * @cfg {Number} minWidth
     * The minimum allowable width in pixels for this region (defaults to 50)
     */
    minWidth:50,
    /**
     * @cfg {Number} minHeight
     * The minimum allowable height in pixels for this region (defaults to 50)
     */
    minHeight:50,

    // private
    defaultMargins : {left:0,top:0,right:0,bottom:0},
    // private
    defaultNSCMargins : {left:5,top:5,right:5,bottom:5},
    // private
    defaultEWCMargins : {left:5,top:0,right:5,bottom:0},

    /**
     * True if this region is collapsed. Read-only.
     * @type Boolean
     * @property
     */
    isCollapsed : false,

    /**
     * This region's panel.  Read-only.
     * @type Ext.Panel
     * @propery panel
     */
    /**
     * This region's layout.  Read-only.
     * @type Layout
     * @propery layout
     */
    /**
     * This region's layout position (north, south, east, west or center).  Read-only.
     * @type String
     * @property position
     */

    // private
    render : function(ct, p){
        this.panel = p;
        p.el.enableDisplayMode();
        this.targetEl = ct;
        this.el = p.el;

        var gs = p.getState, ps = this.position;
        p.getState = function(){
            return Ext.apply(gs.call(p) || {}, this.state);
        }.createDelegate(this);

        if(ps != 'center'){
            p.allowQueuedExpand = false;
            p.on({
                beforecollapse: this.beforeCollapse,
                collapse: this.onCollapse,
                beforeexpand: this.beforeExpand,
                expand: this.onExpand,
                hide: this.onHide,
                show: this.onShow,
                scope: this
            });
            if(this.collapsible){
                p.collapseEl = 'el';
                p.slideAnchor = this.getSlideAnchor();
            }
            if(p.tools && p.tools.toggle){
                p.tools.toggle.addClass('x-tool-collapse-'+ps);
                p.tools.toggle.addClassOnOver('x-tool-collapse-'+ps+'-over');
            }
        }
    },

    // private
    getCollapsedEl : function(){
        if(!this.collapsedEl){
            if(!this.toolTemplate){
                var tt = new Ext.Template(
                     '<div class="x-tool x-tool-{id}">&#160;</div>'
                );
                tt.disableFormats = true;
                tt.compile();
                Ext.layout.BorderLayout.Region.prototype.toolTemplate = tt;
            }
            this.collapsedEl = this.targetEl.createChild({
                cls: "x-layout-collapsed x-layout-collapsed-"+this.position,
                id: this.panel.id + '-xcollapsed'
            });
            this.collapsedEl.enableDisplayMode('block');

            if(this.collapseMode == 'mini'){
                this.collapsedEl.addClass('x-layout-cmini-'+this.position);
                this.miniCollapsedEl = this.collapsedEl.createChild({
                    cls: "x-layout-mini x-layout-mini-"+this.position, html: "&#160;"
                });
                this.miniCollapsedEl.addClassOnOver('x-layout-mini-over');
                this.collapsedEl.addClassOnOver("x-layout-collapsed-over");
                this.collapsedEl.on('click', this.onExpandClick, this, {stopEvent:true});
            }else {
                var t = this.toolTemplate.append(
                        this.collapsedEl.dom,
                        {id:'expand-'+this.position}, true);
                t.addClassOnOver('x-tool-expand-'+this.position+'-over');
                t.on('click', this.onExpandClick, this, {stopEvent:true});
                
                if(this.floatable !== false){
                   this.collapsedEl.addClassOnOver("x-layout-collapsed-over");
                   this.collapsedEl.on("click", this.collapseClick, this);
                }
            }
        }
        return this.collapsedEl;
    },

    // private
    onExpandClick : function(e){
        if(this.isSlid){
            this.afterSlideIn();
            this.panel.expand(false);
        }else{
            this.panel.expand();
        }
    },

    // private
    onCollapseClick : function(e){
        this.panel.collapse();
    },

    // private
    beforeCollapse : function(p, animate){
        this.lastAnim = animate;
        if(this.splitEl){
            this.splitEl.hide();
        }
        this.getCollapsedEl().show();
        this.panel.el.setStyle('z-index', 100);
        this.isCollapsed = true;
        this.layout.layout();
    },

    // private
    onCollapse : function(animate){
        this.panel.el.setStyle('z-index', 1);
        if(this.lastAnim === false || this.panel.animCollapse === false){
            this.getCollapsedEl().dom.style.visibility = 'visible';
        }else{
            this.getCollapsedEl().slideIn(this.panel.slideAnchor, {duration:.2});
        }
        this.state.collapsed = true;
        this.panel.saveState();
    },

    // private
    beforeExpand : function(animate){
        var c = this.getCollapsedEl();
        this.el.show();
        if(this.position == 'east' || this.position == 'west'){
            this.panel.setSize(undefined, c.getHeight());
        }else{
            this.panel.setSize(c.getWidth(), undefined);
        }
        c.hide();
        c.dom.style.visibility = 'hidden';
        this.panel.el.setStyle('z-index', 100);
    },

    // private
    onExpand : function(){
        this.isCollapsed = false;
        if(this.splitEl){
            this.splitEl.show();
        }
        this.layout.layout();
        this.panel.el.setStyle('z-index', 1);
        this.state.collapsed = false;
        this.panel.saveState();
    },

    // private
    collapseClick : function(e){
        if(this.isSlid){
           e.stopPropagation();
           this.slideIn();
        }else{
           e.stopPropagation();
           this.slideOut();
        }
    },

    // private
    onHide : function(){
        if(this.isCollapsed){
            this.getCollapsedEl().hide();
        }else if(this.splitEl){
            this.splitEl.hide();
        }
    },

    // private
    onShow : function(){
        if(this.isCollapsed){
            this.getCollapsedEl().show();
        }else if(this.splitEl){
            this.splitEl.show();
        }
    },

    /**
     * True if this region is currently visible, else false.
     * @return {Boolean}
     */
    isVisible : function(){
        return !this.panel.hidden;
    },

    /**
     * Returns the current margins for this region.  If the region is collapsed, the cmargins (collapsed
     * margins) value will be returned, otherwise the margins value will be returned.
     * @return {Object} An object containing the element's margins: {left: (left margin), top: (top margin),
     * right: (right margin), bottom: (bottom margin)}
     */
    getMargins : function(){
        return this.isCollapsed && this.cmargins ? this.cmargins : this.margins;
    },

    /**
     * Returns the current size of this region.  If the region is collapsed, the size of the collapsedEl will
     * be returned, otherwise the size of the region's panel will be returned.
     * @return {Object} An object containing the element's size: {width: (element width), height: (element height)}  
     */
    getSize : function(){
        return this.isCollapsed ? this.getCollapsedEl().getSize() : this.panel.getSize();
    },

    /**
     * Sets the specified panel as the container element for this region.
     * @param {Ext.Panel} panel The new panel
     */
    setPanel : function(panel){
        this.panel = panel;
    },

    /**
     * Returns the minimum allowable width for this region.
     * @return {Number} The minimum width
     */
    getMinWidth: function(){
        return this.minWidth;
    },

    /**
     * Returns the minimum allowable height for this region.
     * @return {Number} The minimum height
     */
    getMinHeight: function(){
        return this.minHeight;
    },

    // private
    applyLayoutCollapsed : function(box){
        var ce = this.getCollapsedEl();
        ce.setLeftTop(box.x, box.y);
        ce.setSize(box.width, box.height);
    },

    // private
    applyLayout : function(box){
        if(this.isCollapsed){
            this.applyLayoutCollapsed(box);
        }else{
            this.panel.setPosition(box.x, box.y);
            this.panel.setSize(box.width, box.height);
        }
    },

    // private
    beforeSlide: function(){
        this.panel.beforeEffect();
    },

    // private
    afterSlide : function(){
        this.panel.afterEffect();
    },

    // private
    initAutoHide : function(){
        if(this.autoHide !== false){
            if(!this.autoHideHd){
                var st = new Ext.util.DelayedTask(this.slideIn, this);
                this.autoHideHd = {
                    "mouseout": function(e){
                        if(!e.within(this.el, true)){
                            st.delay(500);
                        }
                    },
                    "mouseover" : function(e){
                        st.cancel();
                    },
                    scope : this
                };
            }
            this.el.on(this.autoHideHd);
        }
    },

    // private
    clearAutoHide : function(){
        if(this.autoHide !== false){
            this.el.un("mouseout", this.autoHideHd.mouseout);
            this.el.un("mouseover", this.autoHideHd.mouseover);
        }
    },

    // private
    clearMonitor : function(){
        Ext.getDoc().un("click", this.slideInIf, this);
    },

    // these names are backwards but not changed for compat
    // private
    slideOut : function(){
        if(this.isSlid || this.el.hasActiveFx()){
            return;
        }
        this.isSlid = true;
        var ts = this.panel.tools;
        if(ts && ts.toggle){
            ts.toggle.hide();
        }
        this.el.show();
        if(this.position == 'east' || this.position == 'west'){
            this.panel.setSize(undefined, this.collapsedEl.getHeight());
        }else{
            this.panel.setSize(this.collapsedEl.getWidth(), undefined);
        }
        this.restoreLT = [this.el.dom.style.left, this.el.dom.style.top];
        this.el.alignTo(this.collapsedEl, this.getCollapseAnchor());
        this.el.setStyle("z-index", 102);
        if(this.animFloat !== false){
            this.beforeSlide();
            this.el.slideIn(this.getSlideAnchor(), {
                callback: function(){
                    this.afterSlide();
                    this.initAutoHide();
                    Ext.getDoc().on("click", this.slideInIf, this);
                },
                scope: this,
                block: true
            });
        }else{
            this.initAutoHide();
             Ext.getDoc().on("click", this.slideInIf, this);
        }
    },

    // private
    afterSlideIn : function(){
        this.clearAutoHide();
        this.isSlid = false;
        this.clearMonitor();
        this.el.setStyle("z-index", "");
        this.el.dom.style.left = this.restoreLT[0];
        this.el.dom.style.top = this.restoreLT[1];

        var ts = this.panel.tools;
        if(ts && ts.toggle){
            ts.toggle.show();
        }
    },

    // private
    slideIn : function(cb){
        if(!this.isSlid || this.el.hasActiveFx()){
            Ext.callback(cb);
            return;
        }
        this.isSlid = false;
        if(this.animFloat !== false){
            this.beforeSlide();
            this.el.slideOut(this.getSlideAnchor(), {
                callback: function(){
                    this.el.hide();
                    this.afterSlide();
                    this.afterSlideIn();
                    Ext.callback(cb);
                },
                scope: this,
                block: true
            });
        }else{
            this.el.hide();
            this.afterSlideIn();
        }
    },

    // private
    slideInIf : function(e){
        if(!e.within(this.el)){
            this.slideIn();
        }
    },

    // private
    anchors : {
        "west" : "left",
        "east" : "right",
        "north" : "top",
        "south" : "bottom"
    },

    // private
    sanchors : {
        "west" : "l",
        "east" : "r",
        "north" : "t",
        "south" : "b"
    },

    // private
    canchors : {
        "west" : "tl-tr",
        "east" : "tr-tl",
        "north" : "tl-bl",
        "south" : "bl-tl"
    },

    // private
    getAnchor : function(){
        return this.anchors[this.position];
    },

    // private
    getCollapseAnchor : function(){
        return this.canchors[this.position];
    },

    // private
    getSlideAnchor : function(){
        return this.sanchors[this.position];
    },

    // private
    getAlignAdj : function(){
        var cm = this.cmargins;
        switch(this.position){
            case "west":
                return [0, 0];
            break;
            case "east":
                return [0, 0];
            break;
            case "north":
                return [0, 0];
            break;
            case "south":
                return [0, 0];
            break;
        }
    },

    // private
    getExpandAdj : function(){
        var c = this.collapsedEl, cm = this.cmargins;
        switch(this.position){
            case "west":
                return [-(cm.right+c.getWidth()+cm.left), 0];
            break;
            case "east":
                return [cm.right+c.getWidth()+cm.left, 0];
            break;
            case "north":
                return [0, -(cm.top+cm.bottom+c.getHeight())];
            break;
            case "south":
                return [0, cm.top+cm.bottom+c.getHeight()];
            break;
        }
    }
};

/**
 * @class Ext.layout.BorderLayout.SplitRegion
 * @extends Ext.layout.BorderLayout.Region
 * This is a specialized type of BorderLayout region that has a built-in {@link Ext.SplitBar} for user resizing of regions.
 * @constructor
 * Create a new SplitRegion.
 * @param {Layout} layout Any valid Ext layout class
 * @param {Object} config The configuration options
 * @param {String} position The region position.  Valid values are: north, south, east, west and center.  Every
 * BorderLayout must have a center region for the primary content -- all other regions are optional.
 */
Ext.layout.BorderLayout.SplitRegion = function(layout, config, pos){
    Ext.layout.BorderLayout.SplitRegion.superclass.constructor.call(this, layout, config, pos);
    // prevent switch
    this.applyLayout = this.applyFns[pos];
};

Ext.extend(Ext.layout.BorderLayout.SplitRegion, Ext.layout.BorderLayout.Region, {
    /**
     * @cfg {String} splitTip
     * The tooltip to display when the user hovers over a non-collapsible region's split bar (defaults to "Drag
     * to resize.").  Only applies if {@link #useSplitTips} = true.
     */
    splitTip : "Drag to resize.",
    /**
     * @cfg {String} collapsibleSplitTip
     * The tooltip to display when the user hovers over a collapsible region's split bar (defaults to "Drag
     * to resize. Double click to hide.").  Only applies if {@link #useSplitTips} = true.
     */
    collapsibleSplitTip : "Drag to resize. Double click to hide.",
    /**
     * @cfg {Boolean} useSplitTips
     * True to display a tooltip when the user hovers over a region's split bar (defaults to false).  The tooltip
     * text will be the value of either {@link #splitTip} or {@link #collapsibleSplitTip} as appropriate.
     */
    useSplitTips : false,

    // private
    splitSettings : {
        north : {
            orientation: Ext.SplitBar.VERTICAL,
            placement: Ext.SplitBar.TOP,
            maxFn : 'getVMaxSize',
            minProp: 'minHeight',
            maxProp: 'maxHeight'
        },
        south : {
            orientation: Ext.SplitBar.VERTICAL,
            placement: Ext.SplitBar.BOTTOM,
            maxFn : 'getVMaxSize',
            minProp: 'minHeight',
            maxProp: 'maxHeight'
        },
        east : {
            orientation: Ext.SplitBar.HORIZONTAL,
            placement: Ext.SplitBar.RIGHT,
            maxFn : 'getHMaxSize',
            minProp: 'minWidth',
            maxProp: 'maxWidth'
        },
        west : {
            orientation: Ext.SplitBar.HORIZONTAL,
            placement: Ext.SplitBar.LEFT,
            maxFn : 'getHMaxSize',
            minProp: 'minWidth',
            maxProp: 'maxWidth'
        }
    },

    // private
    applyFns : {
        west : function(box){
            if(this.isCollapsed){
                return this.applyLayoutCollapsed(box);
            }
            var sd = this.splitEl.dom, s = sd.style;
            this.panel.setPosition(box.x, box.y);
            var sw = sd.offsetWidth;
            s.left = (box.x+box.width-sw)+'px';
            s.top = (box.y)+'px';
            s.height = Math.max(0, box.height)+'px';
            this.panel.setSize(box.width-sw, box.height);
        },
        east : function(box){
            if(this.isCollapsed){
                return this.applyLayoutCollapsed(box);
            }
            var sd = this.splitEl.dom, s = sd.style;
            var sw = sd.offsetWidth;
            this.panel.setPosition(box.x+sw, box.y);
            s.left = (box.x)+'px';
            s.top = (box.y)+'px';
            s.height = Math.max(0, box.height)+'px';
            this.panel.setSize(box.width-sw, box.height);
        },
        north : function(box){
            if(this.isCollapsed){
                return this.applyLayoutCollapsed(box);
            }
            var sd = this.splitEl.dom, s = sd.style;
            var sh = sd.offsetHeight;
            this.panel.setPosition(box.x, box.y);
            s.left = (box.x)+'px';
            s.top = (box.y+box.height-sh)+'px';
            s.width = Math.max(0, box.width)+'px';
            this.panel.setSize(box.width, box.height-sh);
        },
        south : function(box){
            if(this.isCollapsed){
                return this.applyLayoutCollapsed(box);
            }
            var sd = this.splitEl.dom, s = sd.style;
            var sh = sd.offsetHeight;
            this.panel.setPosition(box.x, box.y+sh);
            s.left = (box.x)+'px';
            s.top = (box.y)+'px';
            s.width = Math.max(0, box.width)+'px';
            this.panel.setSize(box.width, box.height-sh);
        }
    },

    // private
    render : function(ct, p){
        Ext.layout.BorderLayout.SplitRegion.superclass.render.call(this, ct, p);

        var ps = this.position;

        this.splitEl = ct.createChild({
            cls: "x-layout-split x-layout-split-"+ps, html: "&#160;",
            id: this.panel.id + '-xsplit'
        });

        if(this.collapseMode == 'mini'){
            this.miniSplitEl = this.splitEl.createChild({
                cls: "x-layout-mini x-layout-mini-"+ps, html: "&#160;"
            });
            this.miniSplitEl.addClassOnOver('x-layout-mini-over');
            this.miniSplitEl.on('click', this.onCollapseClick, this, {stopEvent:true});
        }

        var s = this.splitSettings[ps];

        this.split = new Ext.SplitBar(this.splitEl.dom, p.el, s.orientation);
        this.split.placement = s.placement;
        this.split.getMaximumSize = this[s.maxFn].createDelegate(this);
        this.split.minSize = this.minSize || this[s.minProp];
        this.split.on("beforeapply", this.onSplitMove, this);
        this.split.useShim = this.useShim === true;
        this.maxSize = this.maxSize || this[s.maxProp];

        if(p.hidden){
            this.splitEl.hide();
        }

        if(this.useSplitTips){
            this.splitEl.dom.title = this.collapsible ? this.collapsibleSplitTip : this.splitTip;
        }
        if(this.collapsible){
            this.splitEl.on("dblclick", this.onCollapseClick,  this);
        }
    },

    //docs inherit from superclass
    getSize : function(){
        if(this.isCollapsed){
            return this.collapsedEl.getSize();
        }
        var s = this.panel.getSize();
        if(this.position == 'north' || this.position == 'south'){
            s.height += this.splitEl.dom.offsetHeight;
        }else{
            s.width += this.splitEl.dom.offsetWidth;
        }
        return s;
    },

    // private
    getHMaxSize : function(){
         var cmax = this.maxSize || 10000;
         var center = this.layout.center;
         return Math.min(cmax, (this.el.getWidth()+center.el.getWidth())-center.getMinWidth());
    },

    // private
    getVMaxSize : function(){
        var cmax = this.maxSize || 10000;
        var center = this.layout.center;
        return Math.min(cmax, (this.el.getHeight()+center.el.getHeight())-center.getMinHeight());
    },

    // private
    onSplitMove : function(split, newSize){
        var s = this.panel.getSize();
        this.lastSplitSize = newSize;
        if(this.position == 'north' || this.position == 'south'){
            this.panel.setSize(s.width, newSize);
            this.state.height = newSize;
        }else{
            this.panel.setSize(newSize, s.height);
            this.state.width = newSize;
        }
        this.layout.layout();
        this.panel.saveState();
        return false;
    },

    /**
     * Returns a reference to the split bar in use by this region.
     * @return {Ext.SplitBar} The split bar
     */
    getSplitBar : function(){
        return this.split;
    }
});

Ext.Container.LAYOUTS['border'] = Ext.layout.BorderLayout;
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.layout.Accordion
 * @extends Ext.layout.FitLayout
 * <p>This is a layout that contains multiple panels in an expandable accordion style such that only one
 * panel can be open at any given time.  Each panel has built-in support for expanding and collapsing.
 * This class is intended to be extended or created via the layout:'accordion' {@link Ext.Container#layout}
 * config, and should generally not need to be created directly via the new keyword.</p>
 * <p>Note that when creating a layout via config, the layout-specific config properties must be passed in via
 * the {@link Ext.Container#layoutConfig} object which will then be applied internally to the layout.
 * Example usage:</p>
 * <pre><code>
var accordion = new Ext.Panel({
    title: 'Accordion Layout',
    layout:'accordion',
    defaults: {
        // applied to each contained panel
        bodyStyle: 'padding:15px'
    },
    layoutConfig: {
        // layout-specific configs go here
        titleCollapse: false,
        animate: true,
        activeOnTop: true
    },
    items: [{
        title: 'Panel 1',
        html: '&lt;p&gt;Panel content!&lt;/p&gt;'
    },{
        title: 'Panel 2',
        html: '&lt;p&gt;Panel content!&lt;/p&gt;'
    },{
        title: 'Panel 3',
        html: '&lt;p&gt;Panel content!&lt;/p&gt;'
    }]
});
</code></pre>
 */
Ext.layout.Accordion = Ext.extend(Ext.layout.FitLayout, {
    /**
     * @cfg {Boolean} fill
     * True to adjust the active item's height to fill the available space in the container, false to use the
     * item's current height, or auto height if not explicitly set (defaults to true).
     */
    fill : true,
    /**
     * @cfg {Boolean} autoWidth
     * True to set each contained item's width to 'auto', false to use the item's current width (defaults to true).
     */
    autoWidth : true,
    /**
     * @cfg {Boolean} titleCollapse
     * True to allow expand/collapse of each contained panel by clicking anywhere on the title bar, false to allow
     * expand/collapse only when the toggle tool button is clicked (defaults to true).  When set to false,
     * {@link #hideCollapseTool} should be false also.
     */
    titleCollapse : true,
    /**
     * @cfg {Boolean} hideCollapseTool
     * True to hide the contained panels' collapse/expand toggle buttons, false to display them (defaults to false).
     * When set to true, {@link #titleCollapse} should be true also.
     */
    hideCollapseTool : false,
    /**
     * @cfg {Boolean} collapseFirst
     * True to make sure the collapse/expand toggle button always renders first (to the left of) any other tools
     * in the contained panels' title bars, false to render it last (defaults to false).
     */
    collapseFirst : false,
    /**
     * @cfg {Boolean} animate
     * True to slide the contained panels open and closed during expand/collapse using animation, false to open and
     * close directly with no animation (defaults to false).  Note: to defer to the specific config setting of each
     * contained panel for this property, set this to undefined at the layout level.
     */
    animate : false,
    /**
     * @cfg {Boolean} sequence
     * <b>Experimental</b>. If animate is set to true, this will result in each animation running in sequence.
     */
    sequence : false,
    /**
     * @cfg {Boolean} activeOnTop
     * True to swap the position of each panel as it is expanded so that it becomes the first item in the container,
     * false to keep the panels in the rendered order. <b>This is NOT compatible with "animate:true"</b> (defaults to false).
     */
    activeOnTop : false,

    renderItem : function(c){
        if(this.animate === false){
            c.animCollapse = false;
        }
        c.collapsible = true;
        if(this.autoWidth){
            c.autoWidth = true;
        }
        if(this.titleCollapse){
            c.titleCollapse = true;
        }
        if(this.hideCollapseTool){
            c.hideCollapseTool = true;
        }
        if(this.collapseFirst !== undefined){
            c.collapseFirst = this.collapseFirst;
        }
        if(!this.activeItem && !c.collapsed){
            this.activeItem = c;
        }else if(this.activeItem){
            c.collapsed = true;
        }
        Ext.layout.Accordion.superclass.renderItem.apply(this, arguments);
        c.header.addClass('x-accordion-hd');
        c.on('beforeexpand', this.beforeExpand, this);
    },

    // private
    beforeExpand : function(p, anim){
        var ai = this.activeItem;
        if(ai){
            if(this.sequence){
                delete this.activeItem;
                if (!ai.collapsed){
                    ai.collapse({callback:function(){
                        p.expand(anim || true);
                    }, scope: this});
                    return false;
                }
            }else{
                ai.collapse(this.animate);
            }
        }
        this.activeItem = p;
        if(this.activeOnTop){
            p.el.dom.parentNode.insertBefore(p.el.dom, p.el.dom.parentNode.firstChild);
        }
        this.layout();
    },

    // private
    setItemSize : function(item, size){
        if(this.fill && item){
            var items = this.container.items.items;
            var hh = 0;
            for(var i = 0, len = items.length; i < len; i++){
                var p = items[i];
                if(p != item){
                    hh += (p.getSize().height - p.bwrap.getHeight());
                }
            }
            size.height -= hh;
            item.setSize(size);
        }
    }
});
Ext.Container.LAYOUTS['accordion'] = Ext.layout.Accordion;
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.layout.FormLayout
 * @extends Ext.layout.AnchorLayout
 * <p>This is a layout specifically designed for creating forms.
 * This class can be extended or created via the layout:'form' {@link Ext.Container#layout} config,
 * and should generally not need to be created directly via the new keyword.  However, when used in an application,
 * it will usually be preferrable to use a {@link Ext.form.FormPanel} (which automatically uses FormLayout as its layout
 * class) since it also provides built-in functionality for loading, validating and submitting the form.</p>
 * <p>Note that when creating a layout via config, the layout-specific config properties must be passed in via
 * the {@link Ext.Container#layoutConfig} object which will then be applied internally to the layout.  The container
 * using the FormLayout can also supply the following form-specific config properties which will be applied by the layout:
 * <ul>
 * <li><b>hideLabels</b>: (Boolean) True to hide field labels by default (defaults to false)</li>
 * <li><b>itemCls</b>: (String) A CSS class to add to the div wrapper that contains each field label
 * and field element (the default class is 'x-form-item' and itemCls will be added to that)</li>
 * <li><b>labelAlign</b>: (String) The default label alignment.  The default value is empty string ''
 * for left alignment, but specifying 'top' will align the labels above the fields.</li>
 * <li><b>labelPad</b>: (Number) The default padding in pixels for field labels (defaults to 5).  labelPad only
 * applies if labelWidth is also specified, otherwise it will be ignored.</li>
 * <li><b>labelWidth</b>: (Number) The default width in pixels of field labels (defaults to 100)</li>
 * </ul></p>
 * <p>Any type of components can be added to a FormLayout, but items that inherit from {@link Ext.form.Field}
 * can also supply the following field-specific config properties:
 * <ul>
 * <li><b>clearCls</b>: (String) The CSS class to apply to the special clearing div rendered directly after each
 * form field wrapper (defaults to 'x-form-clear-left')</li>
 * <li><b>fieldLabel</b>: (String) The text to display as the label for this field (defaults to '')</li>
 * <li><b>hideLabel</b>: (Boolean) True to hide the label and separator for this field (defaults to false).</li>
 * <li><b>itemCls</b>: (String) A CSS class to add to the div wrapper that contains this field label
 * and field element (the default class is 'x-form-item' and itemCls will be added to that).  If supplied,
 * itemCls at the field level will override the default itemCls supplied at the container level.</li>
 * <li><b>labelSeparator</b>: (String) The separator to display after the text of the label for this field
 * (defaults to a colon ':' or the layout's value for {@link #labelSeparator}).  To hide the separator use empty string ''.</li>
 * <li><b>labelStyle</b>: (String) A CSS style specification string to add to the field label for this field
 * (defaults to '' or the layout's value for {@link #labelStyle}).</li>
 * </ul>
 * Example usage:</p>
 * <pre><code>
// Required if showing validation messages
Ext.QuickTips.init();

// While you can create a basic Panel with layout:'form', practically
// you should usually use a FormPanel to also get its form functionality
// since it already creates a FormLayout internally.
var form = new Ext.form.FormPanel({
    labelWidth: 75,
    title: 'Form Layout',
    bodyStyle:'padding:15px',
    width: 350,
    labelPad: 10,
    defaultType: 'textfield',
    defaults: {
        // applied to each contained item
        width: 230,
        msgTarget: 'side'
    },
    layoutConfig: {
        // layout-specific configs go here
        labelSeparator: ''
    },
    items: [{
            fieldLabel: 'First Name',
            name: 'first',
            allowBlank: false
        },{
            fieldLabel: 'Last Name',
            name: 'last'
        },{
            fieldLabel: 'Company',
            name: 'company'
        },{
            fieldLabel: 'Email',
            name: 'email',
            vtype:'email'
        }
    ],
    buttons: [{
        text: 'Save'
    },{
        text: 'Cancel'
    }]
});
</code></pre>
 */
Ext.layout.FormLayout = Ext.extend(Ext.layout.AnchorLayout, {
    /**
     * @cfg {String} labelStyle
     * A CSS style specification string to add to each field label in this layout (defaults to '').
     */
    /**
     * @cfg {String} elementStyle
     * A CSS style specification string to add to each field element in this layout (defaults to '').
     */
    /**
     * @cfg {String} labelSeparator
     * The standard separator to display after the text of each form label (defaults to a colon ':').  To turn off
     * separators for all fields in this layout by default specify empty string '' (if the labelSeparator value is
     * explicitly set at the field level, those will still be displayed).
     */
    labelSeparator : ':',

    // private
    getAnchorViewSize : function(ct, target){
        return ct.body.getStyleSize();
    },

    // private
    setContainer : function(ct){
        Ext.layout.FormLayout.superclass.setContainer.call(this, ct);

        if(ct.labelAlign){
            ct.addClass('x-form-label-'+ct.labelAlign);
        }

        if(ct.hideLabels){
            this.labelStyle = "display:none";
            this.elementStyle = "padding-left:0;";
            this.labelAdjust = 0;
        }else{
            this.labelSeparator = ct.labelSeparator || this.labelSeparator;
            ct.labelWidth = ct.labelWidth || 100;
            if(typeof ct.labelWidth == 'number'){
                var pad = (typeof ct.labelPad == 'number' ? ct.labelPad : 5);
                this.labelAdjust = ct.labelWidth+pad;
                this.labelStyle = "width:"+ct.labelWidth+"px;";
                this.elementStyle = "padding-left:"+(ct.labelWidth+pad)+'px';
            }
            if(ct.labelAlign == 'top'){
                this.labelStyle = "width:auto;";
                this.labelAdjust = 0;
                this.elementStyle = "padding-left:0;";
            }
        }

        if(!this.fieldTpl){
            // the default field template used by all form layouts
            var t = new Ext.Template(
                '<div class="x-form-item {5}" tabIndex="-1">',
                    '<label for="{0}" style="{2}" class="x-form-item-label">{1}{4}</label>',
                    '<div class="x-form-element" id="x-form-el-{0}" style="{3}">',
                    '</div><div class="{6}"></div>',
                '</div>'
            );
            t.disableFormats = true;
            t.compile();
            Ext.layout.FormLayout.prototype.fieldTpl = t;
        }
    },

    // private
    renderItem : function(c, position, target){
        if(c && !c.rendered && c.isFormField && c.inputType != 'hidden'){
            var args = [
                   c.id, c.fieldLabel,
                   c.labelStyle||this.labelStyle||'',
                   this.elementStyle||'',
                   typeof c.labelSeparator == 'undefined' ? this.labelSeparator : c.labelSeparator,
                   (c.itemCls||this.container.itemCls||'') + (c.hideLabel ? ' x-hide-label' : ''),
                   c.clearCls || 'x-form-clear-left' 
            ];
            if(typeof position == 'number'){
                position = target.dom.childNodes[position] || null;
            }
            if(position){
                this.fieldTpl.insertBefore(position, args);
            }else{
                this.fieldTpl.append(target, args);
            }
            c.render('x-form-el-'+c.id);
        }else {
            Ext.layout.FormLayout.superclass.renderItem.apply(this, arguments);
        }
    },

    // private
    adjustWidthAnchor : function(value, comp){
        return value - (comp.isFormField  ? (comp.hideLabel ? 0 : this.labelAdjust) : 0);
    },

    // private
    isValidParent : function(c, target){
        return true;
    }

    /**
     * @property activeItem
     * @hide
     */
});

Ext.Container.LAYOUTS['form'] = Ext.layout.FormLayout;
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.layout.TableLayout
 * @extends Ext.layout.ContainerLayout
 * <p>This layout allows you to easily render content into an HTML table.  The total number of columns can be
 * specified, and rowspan and colspan can be used to create complex layouts within the table.
 * This class is intended to be extended or created via the layout:'table' {@link Ext.Container#layout} config,
 * and should generally not need to be created directly via the new keyword.</p>
 * <p>Note that when creating a layout via config, the layout-specific config properties must be passed in via
 * the {@link Ext.Container#layoutConfig} object which will then be applied internally to the layout.  In the
 * case of TableLayout, the only valid layout config property is {@link #columns}.  However, the items added to a
 * TableLayout can supply the following table-specific config properties:</p>
 * <ul>
 * <li><b>rowspan</b> Applied to the table cell containing the item.</li>
 * <li><b>colspan</b> Applied to the table cell containing the item.</li>
 * <li><b>cellId</b> An id applied to the table cell containing the item.</li>
 * <li><b>cellCls</b> A CSS class name added to the table cell containing the item.</li>
 * </ul>
 * <p>The basic concept of building up a TableLayout is conceptually very similar to building up a standard
 * HTML table.  You simply add each panel (or "cell") that you want to include along with any span attributes
 * specified as the special config properties of rowspan and colspan which work exactly like their HTML counterparts.
 * Rather than explicitly creating and nesting rows and columns as you would in HTML, you simply specify the
 * total column count in the layoutConfig and start adding panels in their natural order from left to right,
 * top to bottom.  The layout will automatically figure out, based on the column count, rowspans and colspans,
 * how to position each panel within the table.  Just like with HTML tables, your rowspans and colspans must add
 * up correctly in your overall layout or you'll end up with missing and/or extra cells!  Example usage:</p>
 * <pre><code>
// This code will generate a layout table that is 3 columns by 2 rows
// with some spanning included.  The basic layout will be:
// +--------+-----------------+
// |   A    |   B             |
// |        |--------+--------|
// |        |   C    |   D    |
// +--------+--------+--------+
var table = new Ext.Panel({
    title: 'Table Layout',
    layout:'table',
    defaults: {
        // applied to each contained panel
        bodyStyle:'padding:20px'
    },
    layoutConfig: {
        // The total column count must be specified here
        columns: 3
    },
    items: [{
        html: '&lt;p&gt;Cell A content&lt;/p&gt;',
        rowspan: 2
    },{
        html: '&lt;p&gt;Cell B content&lt;/p&gt;',
        colspan: 2
    },{
        html: '&lt;p&gt;Cell C content&lt;/p&gt;',
        cellCls: 'highlight'
    },{
        html: '&lt;p&gt;Cell D content&lt;/p&gt;'
    }]
});
</code></pre>
 */
Ext.layout.TableLayout = Ext.extend(Ext.layout.ContainerLayout, {
    /**
     * @cfg {Number} columns
     * The total number of columns to create in the table for this layout.  If not specified, all panels added to
      * this layout will be rendered into a single row using a column per panel.
     */

    // private
    monitorResize:false,

    // private
    setContainer : function(ct){
        Ext.layout.TableLayout.superclass.setContainer.call(this, ct);

        this.currentRow = 0;
        this.currentColumn = 0;
        this.cells = [];
    },

    // private
    onLayout : function(ct, target){
        var cs = ct.items.items, len = cs.length, c, i;

        if(!this.table){
            target.addClass('x-table-layout-ct');

            this.table = target.createChild(
                {tag:'table', cls:'x-table-layout', cellspacing: 0, cn: {tag: 'tbody'}}, null, true);

            this.renderAll(ct, target);
        }
    },

    // private
    getRow : function(index){
        var row = this.table.tBodies[0].childNodes[index];
        if(!row){
            row = document.createElement('tr');
            this.table.tBodies[0].appendChild(row);
        }
        return row;
    },

    // private
	getNextCell : function(c){
		var cell = this.getNextNonSpan(this.currentColumn, this.currentRow);
		var curCol = this.currentColumn = cell[0], curRow = this.currentRow = cell[1];
		for(var rowIndex = curRow; rowIndex < curRow + (c.rowspan || 1); rowIndex++){
			if(!this.cells[rowIndex]){
				this.cells[rowIndex] = [];
			}
			for(var colIndex = curCol; colIndex < curCol + (c.colspan || 1); colIndex++){
				this.cells[rowIndex][colIndex] = true;
			}
		}
		var td = document.createElement('td');
		if(c.cellId){
			td.id = c.cellId;
		}
		var cls = 'x-table-layout-cell';
		if(c.cellCls){
			cls += ' ' + c.cellCls;
		}
		td.className = cls;
		if(c.colspan){
			td.colSpan = c.colspan;
		}
		if(c.rowspan){
			td.rowSpan = c.rowspan;
		}
		this.getRow(curRow).appendChild(td);
		return td;
	},
    
    // private
	getNextNonSpan: function(colIndex, rowIndex){
		var cols = this.columns;
		while((cols && colIndex >= cols) || (this.cells[rowIndex] && this.cells[rowIndex][colIndex])) {
			if(cols && colIndex >= cols){
				rowIndex++;
				colIndex = 0;
			}else{
				colIndex++;
			}
		}
		return [colIndex, rowIndex];
	},

    // private
    renderItem : function(c, position, target){
        if(c && !c.rendered){
            c.render(this.getNextCell(c));
        }
    },

    // private
    isValidParent : function(c, target){
        return true;
    }

    /**
     * @property activeItem
     * @hide
     */
});

Ext.Container.LAYOUTS['table'] = Ext.layout.TableLayout;
/*
 * Ext JS Library 2.1
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.Viewport
 * @extends Ext.Container
 * A specialized container representing the viewable application area (the browser viewport).
 * <p> The Viewport renders itself to the document body, and automatically sizes itself to the size of
 * the browser viewport and manages window resizing. There may only be one Viewport created
 * in a page. Inner layouts are available by virtue of the fact that all {@link Ext.Panel Panel}s
 * added to the Viewport, either through its {@link #items}, or through the items, or the {@link #add}
 * method of any of its child Panels may themselves have a layout.</p>
 * <p>The Viewport does not provide scrolling, so child Panels within the Viewport should provide
 * for scrolling if needed using the {@link #autoScroll} config.</p>
 * Example showing a classic application border layout :<pre><code>
new Ext.Viewport({
    layout: 'border',
    defaults: {
        activeItem: 0
    },
    items: [{
        region: 'north',
        html: '&lt;h1 class="x-panel-header">Page Title&lt;/h1>',
        autoHeight: true,
        border: false,
        margins: '0 0 5 0'
    }, {
        region: 'west',
        collapsible: true,
        title: 'Navigation',
        xtype: 'treepanel',
        width: 200,
        autoScroll: true,
        split: true,
        loader: new Ext.tree.TreeLoader(),
        root: new Ext.tree.AsyncTreeNode({
            expanded: true,
            children: [{
                text: 'Menu Option 1',
                leaf: true
            }, {
                text: 'Menu Option 2',
                leaf: true
            }, {
                text: 'Menu Option 3',
                leaf: true
            }]
        }),
        rootVisible: false,
        listeners: {
            click: function(n) {
                Ext.Msg.alert('Navigation Tree Click', 'You clicked: "' + n.attributes.text + '"');
            }
        }
    }, {
        region: 'center',
        xtype: 'tabpanel',
        items: {
            title: 'Default Tab',
            html: 'The first tab\'s content. Others may be added dynamically'
        }
    }, {
        region: 'south',
        title: 'Information',
        collapsible: true,
        html: 'Information goes here',
        split: true,
        height: 100,
        minHeight: 100
    }]
});
</code></pre>
 * @constructor
 * Create a new Viewport
 * @param {Object} config The config object
 */
Ext.Viewport = Ext.extend(Ext.Container, {
	/*
	 * Privatize config options which, if used, would interfere with the
	 * correct operation of the Viewport as the sole manager of the
	 * layout of the document body.
	 */
    /**
     * @cfg {Mixed} applyTo @hide
	 */
    /**
     * @cfg {Boolean} allowDomMove @hide
	 */
    /**
     * @cfg {Boolean} hideParent @hide
	 */
    /**
     * @cfg {Mixed} renderTo @hide
	 */
    /**
     * @cfg {Boolean} hideParent @hide
	 */
    /**
     * @cfg {Number} height @hide
	 */
    /**
     * @cfg {Number} width @hide
	 */
    /**
     * @cfg {Boolean} autoHeight @hide
	 */
    /**
     * @cfg {Boolean} autoWidth @hide
	 */
    /**
     * @cfg {Boolean} deferHeight @hide
	 */
    /**
     * @cfg {Boolean} monitorResize @hide
	 */
    initComponent : function() {
        Ext.Viewport.superclass.initComponent.call(this);
        document.getElementsByTagName('html')[0].className += ' x-viewport';
        this.el = Ext.getBody();
        this.el.setHeight = Ext.emptyFn;
        this.el.setWidth = Ext.emptyFn;
        this.el.setSize = Ext.emptyFn;
        this.el.dom.scroll = 'no';
        this.allowDomMove = false;
        this.autoWidth = true;
        this.autoHeight = true;
        Ext.EventManager.onWindowResize(this.fireResize, this);
        this.renderTo = this.el;
    },

    fireResize : function(w, h){
        this.fireEvent('resize', this, w, h, w, h);
    }
});
Ext.reg('viewport', Ext.Viewport);
