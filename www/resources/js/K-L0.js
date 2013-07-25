/*
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.Container
 * @extends Ext.BoxComponent
 * <p>Base class for any {@link Ext.BoxComponent} that can contain other components. This class is intended
 * to be extended and should generally not need to be created directly via the new keyword. {@link Ext.Panel},
 * {@link Ext.Window} and {@link Ext.TabPanel} are the most commonly used Container classes.</p>
 * Containers handle the basic behavior of containing items, namely adding, inserting and removing them.
 * The specific layout logic required to visually render contained items is delegated to any one of the different
 * {@link #layout} classes available.</p>
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
 * <p>Below is an example of adding a newly created GridPanel to a TabPanel. A TabPanel uses {@link Ext.layout.CardLayout}
 * as its layout manager which means all its child items are sized to fit exactly into its client area. The following
 * code requires prior knowledge of how to create GridPanels. See {@link Ext.grid.GridPanel}, {@link Ext.data.Store}
 * and {@link Ext.data.JsonReader} as well as the grid examples in the Ext installation's <tt>examples/grid</tt>
 * directory.</p><pre><code>
//  Create the GridPanel.
myGrid = new Ext.grid.GridPanel({
    store: myStore,
    columns: myColumnModel,
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
     * <p>The default {@link Ext.Component xtype} of child Components to create in this Container when
     * a child item is specified as a raw configuration object, rather than as an instantiated Component.</p>
     * <p>This usually defaults to 'panel', but for {@link Ext.form.FormPanel} and {@link Ext.form.FieldSet},
     * the defaultType is 'textfield'.</p>
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
     * <p>Adds a {@link Ext.Component Component} to this Container. Fires the {@link #beforeadd} event before
     * adding, then fires the {@link #add} event after the component has been added.</p>
     * <p>You will never call the render method of a child Component when using a Container.
     * Child Components are rendered by this Container's {@link #layout} manager when
     * this Container is first rendered.</p>
     * <p>Certain layout managers allow dynamic addition of child components. Those that do
     * include {@link Ext.layout.CardLayout}, {@link Ext.layout.AnchorLayout},
     * {@link Ext.layout.FormLayout}, {@link Ext.layout.TableLayout}.</p>
     * <p>If the Container is already rendered when add is called, you may need to call
     * {@link #doLayout} to refresh the view which causes any unrendered child Components
     * to be rendered. This is required so that you can add multiple child components if needed
     * while only refreshing the layout once.</p>
     * <p>When creating complex UIs, it is important to remember that sizing and positioning
     * of child items is the responsibility of the Container's {@link #layout} manager. If
     * you expect child items to be sized in response to user interactions, you must
     * specify a layout manager which creates and manages the type of layout you have in mind.</p>
     * <p><b>Omitting the {@link #layout} config means that a basic layout manager is
     * used which does nothnig but render child components sequentially into the Container.
     * No sizing or positioning will be performed in this situation.</b></p>
     * @param {Ext.Component/Object} component The Component to add.<br><br>
     * Ext uses lazy rendering, and will only render the added Component should
     * it become necessary, that is: when the Container is layed out either on first render
     * or in response to a {@link #doLayout} call.<br><br>
     * A Component config object may be passed instead of an instantiated Component object.
     * The type of Component created from a config object is determined by the {@link Ext.Component#xtype xtype}
     * config property. If no xtype is configured, the Container's {@link #defaultType}
     * is used.<br><br>
     * For a list of all available xtypes, see {@link Ext.Component}.
     * @return {Ext.Component} component The Component (or config object) that was
     * added with the Container's default config values applied.
     * <p>example:</p><pre><code>
var myNewGrid = new Ext.grid.GridPanel({
    store: myStore,
    colModel: myColModel
});
myTabPanel.add(myNewGrid);
myTabPanel.setActiveTab(myNewGrid);
</code></pre>
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
     * {@link #beforeadd} event before inserting, then fires the {@link #add} event after the
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
     * Removes a component from this container.  Fires the {@link #beforeremove} event before removing, then fires
     * the {@link #remove} event after the component has been removed.
     * @param {Component/String} component The component reference or id to remove.
     * @param {Boolean} autoDestroy (optional) True to automatically invoke the removed Component's {@link Ext.Component#destroy} function.
     * Defaults to the value of this Container's {@link #autoDestroy} config.
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
    beforeDestroy : function(){
        if(this.items){
            Ext.destroy.apply(Ext, this.items.items);
        }
        if(this.monitorResize){
            Ext.EventManager.removeResizeListener(this.doLayout, this);
        }
        if (this.layout && this.layout.destroy) {
            this.layout.destroy();
        }
        Ext.Container.superclass.beforeDestroy.call(this);
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
                        fn.apply(scope || cs[i], args || [cs[i]]);
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
 * Ext JS Library 2.2
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
    },

    destroy : Ext.emptyFn
};
Ext.Container.LAYOUTS['auto'] = Ext.layout.ContainerLayout;
/*
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
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

        var size = Ext.isIE && target.dom != Ext.getBody().dom ? target.getStyleSize() : target.getViewSize();

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
 * Ext JS Library 2.2
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
 * {@link Ext.layout.BorderLayout.SplitRegion} levels.</p>
 * <p><b>The regions of a BorderLayout are fixed at render time and thereafter, no regions may be removed or
 * added.</b></p>
 * <p>Example usage:</p>
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
    },

    destroy: function() {
        var r = ['north', 'south', 'east', 'west'];
        for (var i = 0; i < r.length; i++) {
            var region = this[r[i]];
            if (region && region.split) {
                region.split.destroy(true);
            }
        }
        Ext.layout.BorderLayout.superclass.destroy.call(this);
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
     * the regions dynamically (defaults to false).  When split == true, it is common to specify a minSize
     * and maxSize for the BoxComponent representing the region. These are not native configs of BoxComponent, and
     * are used only by this class.
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
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
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
 * Ext JS Library 2.2
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
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/*
 * These classes are derivatives of the similarly named classes in the YUI Library.
 * The original license:
 * Copyright (c) 2006, Yahoo! Inc. All rights reserved.
 * Code licensed under the BSD License:
 * http://developer.yahoo.net/yui/license.txt
 */

(function() {

var Event=Ext.EventManager;
var Dom=Ext.lib.Dom;

/**
 * @class Ext.dd.DragDrop
 * Defines the interface and base operation of items that that can be
 * dragged or can be drop targets.  It was designed to be extended, overriding
 * the event handlers for startDrag, onDrag, onDragOver and onDragOut.
 * Up to three html elements can be associated with a DragDrop instance:
 * <ul>
 * <li>linked element: the element that is passed into the constructor.
 * This is the element which defines the boundaries for interaction with
 * other DragDrop objects.</li>
 * <li>handle element(s): The drag operation only occurs if the element that
 * was clicked matches a handle element.  By default this is the linked
 * element, but there are times that you will want only a portion of the
 * linked element to initiate the drag operation, and the setHandleElId()
 * method provides a way to define this.</li>
 * <li>drag element: this represents the element that would be moved along
 * with the cursor during a drag operation.  By default, this is the linked
 * element itself as in {@link Ext.dd.DD}.  setDragElId() lets you define
 * a separate element that would be moved, as in {@link Ext.dd.DDProxy}.
 * </li>
 * </ul>
 * This class should not be instantiated until the onload event to ensure that
 * the associated elements are available.
 * The following would define a DragDrop obj that would interact with any
 * other DragDrop obj in the "group1" group:
 * <pre>
 *  dd = new Ext.dd.DragDrop("div1", "group1");
 * </pre>
 * Since none of the event handlers have been implemented, nothing would
 * actually happen if you were to run the code above.  Normally you would
 * override this class or one of the default implementations, but you can
 * also override the methods you want on an instance of the class...
 * <pre>
 *  dd.onDragDrop = function(e, id) {
 *  &nbsp;&nbsp;alert("dd was dropped on " + id);
 *  }
 * </pre>
 * @constructor
 * @param {String} id of the element that is linked to this instance
 * @param {String} sGroup the group of related DragDrop objects
 * @param {object} config an object containing configurable attributes
 *                Valid properties for DragDrop:
 *                    padding, isTarget, maintainOffset, primaryButtonOnly
 */
Ext.dd.DragDrop = function(id, sGroup, config) {
    if(id) {
        this.init(id, sGroup, config);
    }
};

Ext.dd.DragDrop.prototype = {

    /**
     * The id of the element associated with this object.  This is what we
     * refer to as the "linked element" because the size and position of
     * this element is used to determine when the drag and drop objects have
     * interacted.
     * @property id
     * @type String
     */
    id: null,

    /**
     * Configuration attributes passed into the constructor
     * @property config
     * @type object
     */
    config: null,

    /**
     * The id of the element that will be dragged.  By default this is same
     * as the linked element , but could be changed to another element. Ex:
     * Ext.dd.DDProxy
     * @property dragElId
     * @type String
     * @private
     */
    dragElId: null,

    /**
     * The ID of the element that initiates the drag operation.  By default
     * this is the linked element, but could be changed to be a child of this
     * element.  This lets us do things like only starting the drag when the
     * header element within the linked html element is clicked.
     * @property handleElId
     * @type String
     * @private
     */
    handleElId: null,

    /**
     * An object who's property names identify HTML tags to be considered invalid as drag handles.
     * A non-null property value identifies the tag as invalid. Defaults to the 
     * following value which prevents drag operations from being initiated by &lt;a> elements:<pre><code>
{
    A: "A"
}</code></pre>
     * @property invalidHandleTypes
     * @type Object
     */
    invalidHandleTypes: null,

    /**
     * An object who's property names identify the IDs of elements to be considered invalid as drag handles.
     * A non-null property value identifies the ID as invalid. For example, to prevent
     * dragging from being initiated on element ID "foo", use:<pre><code>
{
    foo: true
}</code></pre>
     * @property invalidHandleIds
     * @type Object
     */
    invalidHandleIds: null,

    /**
     * An Array of CSS class names for elements to be considered in valid as drag handles.
     * @property invalidHandleClasses
     * @type Array
     */
    invalidHandleClasses: null,

    /**
     * The linked element's absolute X position at the time the drag was
     * started
     * @property startPageX
     * @type int
     * @private
     */
    startPageX: 0,

    /**
     * The linked element's absolute X position at the time the drag was
     * started
     * @property startPageY
     * @type int
     * @private
     */
    startPageY: 0,

    /**
     * The group defines a logical collection of DragDrop objects that are
     * related.  Instances only get events when interacting with other
     * DragDrop object in the same group.  This lets us define multiple
     * groups using a single DragDrop subclass if we want.
     * @property groups
     * @type object An object in the format {'group1':true, 'group2':true}
     */
    groups: null,

    /**
     * Individual drag/drop instances can be locked.  This will prevent
     * onmousedown start drag.
     * @property locked
     * @type boolean
     * @private
     */
    locked: false,

    /**
     * Lock this instance
     * @method lock
     */
    lock: function() { this.locked = true; },

    /**
     * Unlock this instace
     * @method unlock
     */
    unlock: function() { this.locked = false; },

    /**
     * By default, all insances can be a drop target.  This can be disabled by
     * setting isTarget to false.
     * @property isTarget
     * @type boolean
     */
    isTarget: true,

    /**
     * The padding configured for this drag and drop object for calculating
     * the drop zone intersection with this object.
     * @property padding
     * @type int[] An array containing the 4 padding values: [top, right, bottom, left]
     */
    padding: null,

    /**
     * Cached reference to the linked element
     * @property _domRef
     * @private
     */
    _domRef: null,

    /**
     * Internal typeof flag
     * @property __ygDragDrop
     * @private
     */
    __ygDragDrop: true,

    /**
     * Set to true when horizontal contraints are applied
     * @property constrainX
     * @type boolean
     * @private
     */
    constrainX: false,

    /**
     * Set to true when vertical contraints are applied
     * @property constrainY
     * @type boolean
     * @private
     */
    constrainY: false,

    /**
     * The left constraint
     * @property minX
     * @type int
     * @private
     */
    minX: 0,

    /**
     * The right constraint
     * @property maxX
     * @type int
     * @private
     */
    maxX: 0,

    /**
     * The up constraint
     * @property minY
     * @type int
     * @type int
     * @private
     */
    minY: 0,

    /**
     * The down constraint
     * @property maxY
     * @type int
     * @private
     */
    maxY: 0,

    /**
     * Maintain offsets when we resetconstraints.  Set to true when you want
     * the position of the element relative to its parent to stay the same
     * when the page changes
     *
     * @property maintainOffset
     * @type boolean
     */
    maintainOffset: false,

    /**
     * Array of pixel locations the element will snap to if we specified a
     * horizontal graduation/interval.  This array is generated automatically
     * when you define a tick interval.
     * @property xTicks
     * @type int[]
     */
    xTicks: null,

    /**
     * Array of pixel locations the element will snap to if we specified a
     * vertical graduation/interval.  This array is generated automatically
     * when you define a tick interval.
     * @property yTicks
     * @type int[]
     */
    yTicks: null,

    /**
     * By default the drag and drop instance will only respond to the primary
     * button click (left button for a right-handed mouse).  Set to true to
     * allow drag and drop to start with any mouse click that is propogated
     * by the browser
     * @property primaryButtonOnly
     * @type boolean
     */
    primaryButtonOnly: true,

    /**
     * The availabe property is false until the linked dom element is accessible.
     * @property available
     * @type boolean
     */
    available: false,

    /**
     * By default, drags can only be initiated if the mousedown occurs in the
     * region the linked element is.  This is done in part to work around a
     * bug in some browsers that mis-report the mousedown if the previous
     * mouseup happened outside of the window.  This property is set to true
     * if outer handles are defined.
     *
     * @property hasOuterHandles
     * @type boolean
     * @default false
     */
    hasOuterHandles: false,

    /**
     * Code that executes immediately before the startDrag event
     * @method b4StartDrag
     * @private
     */
    b4StartDrag: function(x, y) { },

    /**
     * Abstract method called after a drag/drop object is clicked
     * and the drag or mousedown time thresholds have beeen met.
     * @method startDrag
     * @param {int} X click location
     * @param {int} Y click location
     */
    startDrag: function(x, y) { /* override this */ },

    /**
     * Code that executes immediately before the onDrag event
     * @method b4Drag
     * @private
     */
    b4Drag: function(e) { },

    /**
     * Abstract method called during the onMouseMove event while dragging an
     * object.
     * @method onDrag
     * @param {Event} e the mousemove event
     */
    onDrag: function(e) { /* override this */ },

    /**
     * Abstract method called when this element fist begins hovering over
     * another DragDrop obj
     * @method onDragEnter
     * @param {Event} e the mousemove event
     * @param {String|DragDrop[]} id In POINT mode, the element
     * id this is hovering over.  In INTERSECT mode, an array of one or more
     * dragdrop items being hovered over.
     */
    onDragEnter: function(e, id) { /* override this */ },

    /**
     * Code that executes immediately before the onDragOver event
     * @method b4DragOver
     * @private
     */
    b4DragOver: function(e) { },

    /**
     * Abstract method called when this element is hovering over another
     * DragDrop obj
     * @method onDragOver
     * @param {Event} e the mousemove event
     * @param {String|DragDrop[]} id In POINT mode, the element
     * id this is hovering over.  In INTERSECT mode, an array of dd items
     * being hovered over.
     */
    onDragOver: function(e, id) { /* override this */ },

    /**
     * Code that executes immediately before the onDragOut event
     * @method b4DragOut
     * @private
     */
    b4DragOut: function(e) { },

    /**
     * Abstract method called when we are no longer hovering over an element
     * @method onDragOut
     * @param {Event} e the mousemove event
     * @param {String|DragDrop[]} id In POINT mode, the element
     * id this was hovering over.  In INTERSECT mode, an array of dd items
     * that the mouse is no longer over.
     */
    onDragOut: function(e, id) { /* override this */ },

    /**
     * Code that executes immediately before the onDragDrop event
     * @method b4DragDrop
     * @private
     */
    b4DragDrop: function(e) { },

    /**
     * Abstract method called when this item is dropped on another DragDrop
     * obj
     * @method onDragDrop
     * @param {Event} e the mouseup event
     * @param {String|DragDrop[]} id In POINT mode, the element
     * id this was dropped on.  In INTERSECT mode, an array of dd items this
     * was dropped on.
     */
    onDragDrop: function(e, id) { /* override this */ },

    /**
     * Abstract method called when this item is dropped on an area with no
     * drop target
     * @method onInvalidDrop
     * @param {Event} e the mouseup event
     */
    onInvalidDrop: function(e) { /* override this */ },

    /**
     * Code that executes immediately before the endDrag event
     * @method b4EndDrag
     * @private
     */
    b4EndDrag: function(e) { },

    /**
     * Fired when we are done dragging the object
     * @method endDrag
     * @param {Event} e the mouseup event
     */
    endDrag: function(e) { /* override this */ },

    /**
     * Code executed immediately before the onMouseDown event
     * @method b4MouseDown
     * @param {Event} e the mousedown event
     * @private
     */
    b4MouseDown: function(e) {  },

    /**
     * Event handler that fires when a drag/drop obj gets a mousedown
     * @method onMouseDown
     * @param {Event} e the mousedown event
     */
    onMouseDown: function(e) { /* override this */ },

    /**
     * Event handler that fires when a drag/drop obj gets a mouseup
     * @method onMouseUp
     * @param {Event} e the mouseup event
     */
    onMouseUp: function(e) { /* override this */ },

    /**
     * Override the onAvailable method to do what is needed after the initial
     * position was determined.
     * @method onAvailable
     */
    onAvailable: function () {
    },

    /**
     * Provides default constraint padding to "constrainTo" elements (defaults to {left: 0, right:0, top:0, bottom:0}).
     * @type Object
     */
    defaultPadding : {left:0, right:0, top:0, bottom:0},

    /**
     * Initializes the drag drop object's constraints to restrict movement to a certain element.
 *
 * Usage:
 <pre><code>
 var dd = new Ext.dd.DDProxy("dragDiv1", "proxytest",
                { dragElId: "existingProxyDiv" });
 dd.startDrag = function(){
     this.constrainTo("parent-id");
 };
 </code></pre>
 * Or you can initalize it using the {@link Ext.Element} object:
 <pre><code>
 Ext.get("dragDiv1").initDDProxy("proxytest", {dragElId: "existingProxyDiv"}, {
     startDrag : function(){
         this.constrainTo("parent-id");
     }
 });
 </code></pre>
     * @param {Mixed} constrainTo The element to constrain to.
     * @param {Object/Number} pad (optional) Pad provides a way to specify "padding" of the constraints,
     * and can be either a number for symmetrical padding (4 would be equal to {left:4, right:4, top:4, bottom:4}) or
     * an object containing the sides to pad. For example: {right:10, bottom:10}
     * @param {Boolean} inContent (optional) Constrain the draggable in the content box of the element (inside padding and borders)
     */
    constrainTo : function(constrainTo, pad, inContent){
        if(typeof pad == "number"){
            pad = {left: pad, right:pad, top:pad, bottom:pad};
        }
        pad = pad || this.defaultPadding;
        var b = Ext.get(this.getEl()).getBox();
        var ce = Ext.get(constrainTo);
        var s = ce.getScroll();
        var c, cd = ce.dom;
        if(cd == document.body){
            c = { x: s.left, y: s.top, width: Ext.lib.Dom.getViewWidth(), height: Ext.lib.Dom.getViewHeight()};
        }else{
            var xy = ce.getXY();
            c = {x : xy[0]+s.left, y: xy[1]+s.top, width: cd.clientWidth, height: cd.clientHeight};
        }


        var topSpace = b.y - c.y;
        var leftSpace = b.x - c.x;

        this.resetConstraints();
        this.setXConstraint(leftSpace - (pad.left||0), // left
                c.width - leftSpace - b.width - (pad.right||0), //right
				this.xTickSize
        );
        this.setYConstraint(topSpace - (pad.top||0), //top
                c.height - topSpace - b.height - (pad.bottom||0), //bottom
				this.yTickSize
        );
    },

    /**
     * Returns a reference to the linked element
     * @method getEl
     * @return {HTMLElement} the html element
     */
    getEl: function() {
        if (!this._domRef) {
            this._domRef = Ext.getDom(this.id);
        }

        return this._domRef;
    },

    /**
     * Returns a reference to the actual element to drag.  By default this is
     * the same as the html element, but it can be assigned to another
     * element. An example of this can be found in Ext.dd.DDProxy
     * @method getDragEl
     * @return {HTMLElement} the html element
     */
    getDragEl: function() {
        return Ext.getDom(this.dragElId);
    },

    /**
     * Sets up the DragDrop object.  Must be called in the constructor of any
     * Ext.dd.DragDrop subclass
     * @method init
     * @param id the id of the linked element
     * @param {String} sGroup the group of related items
     * @param {object} config configuration attributes
     */
    init: function(id, sGroup, config) {
        this.initTarget(id, sGroup, config);
        Event.on(this.id, "mousedown", this.handleMouseDown, this);
        // Event.on(this.id, "selectstart", Event.preventDefault);
    },

    /**
     * Initializes Targeting functionality only... the object does not
     * get a mousedown handler.
     * @method initTarget
     * @param id the id of the linked element
     * @param {String} sGroup the group of related items
     * @param {object} config configuration attributes
     */
    initTarget: function(id, sGroup, config) {

        // configuration attributes
        this.config = config || {};

        // create a local reference to the drag and drop manager
        this.DDM = Ext.dd.DDM;
        // initialize the groups array
        this.groups = {};

        // assume that we have an element reference instead of an id if the
        // parameter is not a string
        if (typeof id !== "string") {
            id = Ext.id(id);
        }

        // set the id
        this.id = id;

        // add to an interaction group
        this.addToGroup((sGroup) ? sGroup : "default");

        // We don't want to register this as the handle with the manager
        // so we just set the id rather than calling the setter.
        this.handleElId = id;

        // the linked element is the element that gets dragged by default
        this.setDragElId(id);

        // by default, clicked anchors will not start drag operations.
        this.invalidHandleTypes = { A: "A" };
        this.invalidHandleIds = {};
        this.invalidHandleClasses = [];

        this.applyConfig();

        this.handleOnAvailable();
    },

    /**
     * Applies the configuration parameters that were passed into the constructor.
     * This is supposed to happen at each level through the inheritance chain.  So
     * a DDProxy implentation will execute apply config on DDProxy, DD, and
     * DragDrop in order to get all of the parameters that are available in
     * each object.
     * @method applyConfig
     */
    applyConfig: function() {

        // configurable properties:
        //    padding, isTarget, maintainOffset, primaryButtonOnly
        this.padding           = this.config.padding || [0, 0, 0, 0];
        this.isTarget          = (this.config.isTarget !== false);
        this.maintainOffset    = (this.config.maintainOffset);
        this.primaryButtonOnly = (this.config.primaryButtonOnly !== false);

    },

    /**
     * Executed when the linked element is available
     * @method handleOnAvailable
     * @private
     */
    handleOnAvailable: function() {
        this.available = true;
        this.resetConstraints();
        this.onAvailable();
    },

     /**
     * Configures the padding for the target zone in px.  Effectively expands
     * (or reduces) the virtual object size for targeting calculations.
     * Supports css-style shorthand; if only one parameter is passed, all sides
     * will have that padding, and if only two are passed, the top and bottom
     * will have the first param, the left and right the second.
     * @method setPadding
     * @param {int} iTop    Top pad
     * @param {int} iRight  Right pad
     * @param {int} iBot    Bot pad
     * @param {int} iLeft   Left pad
     */
    setPadding: function(iTop, iRight, iBot, iLeft) {
        // this.padding = [iLeft, iRight, iTop, iBot];
        if (!iRight && 0 !== iRight) {
            this.padding = [iTop, iTop, iTop, iTop];
        } else if (!iBot && 0 !== iBot) {
            this.padding = [iTop, iRight, iTop, iRight];
        } else {
            this.padding = [iTop, iRight, iBot, iLeft];
        }
    },

    /**
     * Stores the initial placement of the linked element.
     * @method setInitialPosition
     * @param {int} diffX   the X offset, default 0
     * @param {int} diffY   the Y offset, default 0
     */
    setInitPosition: function(diffX, diffY) {
        var el = this.getEl();

        if (!this.DDM.verifyEl(el)) {
            return;
        }

        var dx = diffX || 0;
        var dy = diffY || 0;

        var p = Dom.getXY( el );

        this.initPageX = p[0] - dx;
        this.initPageY = p[1] - dy;

        this.lastPageX = p[0];
        this.lastPageY = p[1];


        this.setStartPosition(p);
    },

    /**
     * Sets the start position of the element.  This is set when the obj
     * is initialized, the reset when a drag is started.
     * @method setStartPosition
     * @param pos current position (from previous lookup)
     * @private
     */
    setStartPosition: function(pos) {
        var p = pos || Dom.getXY( this.getEl() );
        this.deltaSetXY = null;

        this.startPageX = p[0];
        this.startPageY = p[1];
    },

    /**
     * Add this instance to a group of related drag/drop objects.  All
     * instances belong to at least one group, and can belong to as many
     * groups as needed.
     * @method addToGroup
     * @param sGroup {string} the name of the group
     */
    addToGroup: function(sGroup) {
        this.groups[sGroup] = true;
        this.DDM.regDragDrop(this, sGroup);
    },

    /**
     * Remove's this instance from the supplied interaction group
     * @method removeFromGroup
     * @param {string}  sGroup  The group to drop
     */
    removeFromGroup: function(sGroup) {
        if (this.groups[sGroup]) {
            delete this.groups[sGroup];
        }

        this.DDM.removeDDFromGroup(this, sGroup);
    },

    /**
     * Allows you to specify that an element other than the linked element
     * will be moved with the cursor during a drag
     * @method setDragElId
     * @param id {string} the id of the element that will be used to initiate the drag
     */
    setDragElId: function(id) {
        this.dragElId = id;
    },

    /**
     * Allows you to specify a child of the linked element that should be
     * used to initiate the drag operation.  An example of this would be if
     * you have a content div with text and links.  Clicking anywhere in the
     * content area would normally start the drag operation.  Use this method
     * to specify that an element inside of the content div is the element
     * that starts the drag operation.
     * @method setHandleElId
     * @param id {string} the id of the element that will be used to
     * initiate the drag.
     */
    setHandleElId: function(id) {
        if (typeof id !== "string") {
            id = Ext.id(id);
        }
        this.handleElId = id;
        this.DDM.regHandle(this.id, id);
    },

    /**
     * Allows you to set an element outside of the linked element as a drag
     * handle
     * @method setOuterHandleElId
     * @param id the id of the element that will be used to initiate the drag
     */
    setOuterHandleElId: function(id) {
        if (typeof id !== "string") {
            id = Ext.id(id);
        }
        Event.on(id, "mousedown",
                this.handleMouseDown, this);
        this.setHandleElId(id);

        this.hasOuterHandles = true;
    },

    /**
     * Remove all drag and drop hooks for this element
     * @method unreg
     */
    unreg: function() {
        Event.un(this.id, "mousedown",
                this.handleMouseDown);
        this._domRef = null;
        this.DDM._remove(this);
    },

    destroy : function(){
        this.unreg();
    },

    /**
     * Returns true if this instance is locked, or the drag drop mgr is locked
     * (meaning that all drag/drop is disabled on the page.)
     * @method isLocked
     * @return {boolean} true if this obj or all drag/drop is locked, else
     * false
     */
    isLocked: function() {
        return (this.DDM.isLocked() || this.locked);
    },

    /**
     * Fired when this object is clicked
     * @method handleMouseDown
     * @param {Event} e
     * @param {Ext.dd.DragDrop} oDD the clicked dd object (this dd obj)
     * @private
     */
    handleMouseDown: function(e, oDD){
        if (this.primaryButtonOnly && e.button != 0) {
            return;
        }

        if (this.isLocked()) {
            return;
        }

        this.DDM.refreshCache(this.groups);

        var pt = new Ext.lib.Point(Ext.lib.Event.getPageX(e), Ext.lib.Event.getPageY(e));
        if (!this.hasOuterHandles && !this.DDM.isOverTarget(pt, this) )  {
        } else {
            if (this.clickValidator(e)) {

                // set the initial element position
                this.setStartPosition();


                this.b4MouseDown(e);
                this.onMouseDown(e);

                this.DDM.handleMouseDown(e, this);

                this.DDM.stopEvent(e);
            } else {


            }
        }
    },

    clickValidator: function(e) {
        var target = e.getTarget();
        return ( this.isValidHandleChild(target) &&
                    (this.id == this.handleElId ||
                        this.DDM.handleWasClicked(target, this.id)) );
    },

    /**
     * Allows you to specify a tag name that should not start a drag operation
     * when clicked.  This is designed to facilitate embedding links within a
     * drag handle that do something other than start the drag.
     * @method addInvalidHandleType
     * @param {string} tagName the type of element to exclude
     */
    addInvalidHandleType: function(tagName) {
        var type = tagName.toUpperCase();
        this.invalidHandleTypes[type] = type;
    },

    /**
     * Lets you to specify an element id for a child of a drag handle
     * that should not initiate a drag
     * @method addInvalidHandleId
     * @param {string} id the element id of the element you wish to ignore
     */
    addInvalidHandleId: function(id) {
        if (typeof id !== "string") {
            id = Ext.id(id);
        }
        this.invalidHandleIds[id] = id;
    },

    /**
     * Lets you specify a css class of elements that will not initiate a drag
     * @method addInvalidHandleClass
     * @param {string} cssClass the class of the elements you wish to ignore
     */
    addInvalidHandleClass: function(cssClass) {
        this.invalidHandleClasses.push(cssClass);
    },

    /**
     * Unsets an excluded tag name set by addInvalidHandleType
     * @method removeInvalidHandleType
     * @param {string} tagName the type of element to unexclude
     */
    removeInvalidHandleType: function(tagName) {
        var type = tagName.toUpperCase();
        // this.invalidHandleTypes[type] = null;
        delete this.invalidHandleTypes[type];
    },

    /**
     * Unsets an invalid handle id
     * @method removeInvalidHandleId
     * @param {string} id the id of the element to re-enable
     */
    removeInvalidHandleId: function(id) {
        if (typeof id !== "string") {
            id = Ext.id(id);
        }
        delete this.invalidHandleIds[id];
    },

    /**
     * Unsets an invalid css class
     * @method removeInvalidHandleClass
     * @param {string} cssClass the class of the element(s) you wish to
     * re-enable
     */
    removeInvalidHandleClass: function(cssClass) {
        for (var i=0, len=this.invalidHandleClasses.length; i<len; ++i) {
            if (this.invalidHandleClasses[i] == cssClass) {
                delete this.invalidHandleClasses[i];
            }
        }
    },

    /**
     * Checks the tag exclusion list to see if this click should be ignored
     * @method isValidHandleChild
     * @param {HTMLElement} node the HTMLElement to evaluate
     * @return {boolean} true if this is a valid tag type, false if not
     */
    isValidHandleChild: function(node) {

        var valid = true;
        // var n = (node.nodeName == "#text") ? node.parentNode : node;
        var nodeName;
        try {
            nodeName = node.nodeName.toUpperCase();
        } catch(e) {
            nodeName = node.nodeName;
        }
        valid = valid && !this.invalidHandleTypes[nodeName];
        valid = valid && !this.invalidHandleIds[node.id];

        for (var i=0, len=this.invalidHandleClasses.length; valid && i<len; ++i) {
            valid = !Ext.fly(node).hasClass(this.invalidHandleClasses[i]);
        }


        return valid;

    },

    /**
     * Create the array of horizontal tick marks if an interval was specified
     * in setXConstraint().
     * @method setXTicks
     * @private
     */
    setXTicks: function(iStartX, iTickSize) {
        this.xTicks = [];
        this.xTickSize = iTickSize;

        var tickMap = {};

        for (var i = this.initPageX; i >= this.minX; i = i - iTickSize) {
            if (!tickMap[i]) {
                this.xTicks[this.xTicks.length] = i;
                tickMap[i] = true;
            }
        }

        for (i = this.initPageX; i <= this.maxX; i = i + iTickSize) {
            if (!tickMap[i]) {
                this.xTicks[this.xTicks.length] = i;
                tickMap[i] = true;
            }
        }

        this.xTicks.sort(this.DDM.numericSort) ;
    },

    /**
     * Create the array of vertical tick marks if an interval was specified in
     * setYConstraint().
     * @method setYTicks
     * @private
     */
    setYTicks: function(iStartY, iTickSize) {
        this.yTicks = [];
        this.yTickSize = iTickSize;

        var tickMap = {};

        for (var i = this.initPageY; i >= this.minY; i = i - iTickSize) {
            if (!tickMap[i]) {
                this.yTicks[this.yTicks.length] = i;
                tickMap[i] = true;
            }
        }

        for (i = this.initPageY; i <= this.maxY; i = i + iTickSize) {
            if (!tickMap[i]) {
                this.yTicks[this.yTicks.length] = i;
                tickMap[i] = true;
            }
        }

        this.yTicks.sort(this.DDM.numericSort) ;
    },

    /**
     * By default, the element can be dragged any place on the screen.  Use
     * this method to limit the horizontal travel of the element.  Pass in
     * 0,0 for the parameters if you want to lock the drag to the y axis.
     * @method setXConstraint
     * @param {int} iLeft the number of pixels the element can move to the left
     * @param {int} iRight the number of pixels the element can move to the
     * right
     * @param {int} iTickSize optional parameter for specifying that the
     * element
     * should move iTickSize pixels at a time.
     */
    setXConstraint: function(iLeft, iRight, iTickSize) {
        this.leftConstraint = iLeft;
        this.rightConstraint = iRight;

        this.minX = this.initPageX - iLeft;
        this.maxX = this.initPageX + iRight;
        if (iTickSize) { this.setXTicks(this.initPageX, iTickSize); }

        this.constrainX = true;
    },

    /**
     * Clears any constraints applied to this instance.  Also clears ticks
     * since they can't exist independent of a constraint at this time.
     * @method clearConstraints
     */
    clearConstraints: function() {
        this.constrainX = false;
        this.constrainY = false;
        this.clearTicks();
    },

    /**
     * Clears any tick interval defined for this instance
     * @method clearTicks
     */
    clearTicks: function() {
        this.xTicks = null;
        this.yTicks = null;
        this.xTickSize = 0;
        this.yTickSize = 0;
    },

    /**
     * By default, the element can be dragged any place on the screen.  Set
     * this to limit the vertical travel of the element.  Pass in 0,0 for the
     * parameters if you want to lock the drag to the x axis.
     * @method setYConstraint
     * @param {int} iUp the number of pixels the element can move up
     * @param {int} iDown the number of pixels the element can move down
     * @param {int} iTickSize optional parameter for specifying that the
     * element should move iTickSize pixels at a time.
     */
    setYConstraint: function(iUp, iDown, iTickSize) {
        this.topConstraint = iUp;
        this.bottomConstraint = iDown;

        this.minY = this.initPageY - iUp;
        this.maxY = this.initPageY + iDown;
        if (iTickSize) { this.setYTicks(this.initPageY, iTickSize); }

        this.constrainY = true;

    },

    /**
     * resetConstraints must be called if you manually reposition a dd element.
     * @method resetConstraints
     * @param {boolean} maintainOffset
     */
    resetConstraints: function() {


        // Maintain offsets if necessary
        if (this.initPageX || this.initPageX === 0) {
            // figure out how much this thing has moved
            var dx = (this.maintainOffset) ? this.lastPageX - this.initPageX : 0;
            var dy = (this.maintainOffset) ? this.lastPageY - this.initPageY : 0;

            this.setInitPosition(dx, dy);

        // This is the first time we have detected the element's position
        } else {
            this.setInitPosition();
        }

        if (this.constrainX) {
            this.setXConstraint( this.leftConstraint,
                                 this.rightConstraint,
                                 this.xTickSize        );
        }

        if (this.constrainY) {
            this.setYConstraint( this.topConstraint,
                                 this.bottomConstraint,
                                 this.yTickSize         );
        }
    },

    /**
     * Normally the drag element is moved pixel by pixel, but we can specify
     * that it move a number of pixels at a time.  This method resolves the
     * location when we have it set up like this.
     * @method getTick
     * @param {int} val where we want to place the object
     * @param {int[]} tickArray sorted array of valid points
     * @return {int} the closest tick
     * @private
     */
    getTick: function(val, tickArray) {

        if (!tickArray) {
            // If tick interval is not defined, it is effectively 1 pixel,
            // so we return the value passed to us.
            return val;
        } else if (tickArray[0] >= val) {
            // The value is lower than the first tick, so we return the first
            // tick.
            return tickArray[0];
        } else {
            for (var i=0, len=tickArray.length; i<len; ++i) {
                var next = i + 1;
                if (tickArray[next] && tickArray[next] >= val) {
                    var diff1 = val - tickArray[i];
                    var diff2 = tickArray[next] - val;
                    return (diff2 > diff1) ? tickArray[i] : tickArray[next];
                }
            }

            // The value is larger than the last tick, so we return the last
            // tick.
            return tickArray[tickArray.length - 1];
        }
    },

    /**
     * toString method
     * @method toString
     * @return {string} string representation of the dd obj
     */
    toString: function() {
        return ("DragDrop " + this.id);
    }

};

})();
/**
 * The drag and drop utility provides a framework for building drag and drop
 * applications.  In addition to enabling drag and drop for specific elements,
 * the drag and drop elements are tracked by the manager class, and the
 * interactions between the various elements are tracked during the drag and
 * the implementing code is notified about these important moments.
 */

// Only load the library once.  Rewriting the manager class would orphan
// existing drag and drop instances.
if (!Ext.dd.DragDropMgr) {

/**
 * @class Ext.dd.DragDropMgr
 * DragDropMgr is a singleton that tracks the element interaction for
 * all DragDrop items in the window.  Generally, you will not call
 * this class directly, but it does have helper methods that could
 * be useful in your DragDrop implementations.
 * @singleton
 */
Ext.dd.DragDropMgr = function() {

    var Event = Ext.EventManager;

    return {

        /**
         * Two dimensional Array of registered DragDrop objects.  The first
         * dimension is the DragDrop item group, the second the DragDrop
         * object.
         * @property ids
         * @type {string: string}
         * @private
         * @static
         */
        ids: {},

        /**
         * Array of element ids defined as drag handles.  Used to determine
         * if the element that generated the mousedown event is actually the
         * handle and not the html element itself.
         * @property handleIds
         * @type {string: string}
         * @private
         * @static
         */
        handleIds: {},

        /**
         * the DragDrop object that is currently being dragged
         * @property dragCurrent
         * @type DragDrop
         * @private
         * @static
         **/
        dragCurrent: null,

        /**
         * the DragDrop object(s) that are being hovered over
         * @property dragOvers
         * @type Array
         * @private
         * @static
         */
        dragOvers: {},

        /**
         * the X distance between the cursor and the object being dragged
         * @property deltaX
         * @type int
         * @private
         * @static
         */
        deltaX: 0,

        /**
         * the Y distance between the cursor and the object being dragged
         * @property deltaY
         * @type int
         * @private
         * @static
         */
        deltaY: 0,

        /**
         * Flag to determine if we should prevent the default behavior of the
         * events we define. By default this is true, but this can be set to
         * false if you need the default behavior (not recommended)
         * @property preventDefault
         * @type boolean
         * @static
         */
        preventDefault: true,

        /**
         * Flag to determine if we should stop the propagation of the events
         * we generate. This is true by default but you may want to set it to
         * false if the html element contains other features that require the
         * mouse click.
         * @property stopPropagation
         * @type boolean
         * @static
         */
        stopPropagation: true,

        /**
         * Internal flag that is set to true when drag and drop has been
         * intialized
         * @property initialized
         * @private
         * @static
         */
        initialized: false,

        /**
         * All drag and drop can be disabled.
         * @property locked
         * @private
         * @static
         */
        locked: false,

        /**
         * Called the first time an element is registered.
         * @method init
         * @private
         * @static
         */
        init: function() {
            this.initialized = true;
        },

        /**
         * In point mode, drag and drop interaction is defined by the
         * location of the cursor during the drag/drop
         * @property POINT
         * @type int
         * @static
         */
        POINT: 0,

        /**
         * In intersect mode, drag and drop interaction is defined by the
         * overlap of two or more drag and drop objects.
         * @property INTERSECT
         * @type int
         * @static
         */
        INTERSECT: 1,

        /**
         * The current drag and drop mode.  Default: POINT
         * @property mode
         * @type int
         * @static
         */
        mode: 0,

        /**
         * Runs method on all drag and drop objects
         * @method _execOnAll
         * @private
         * @static
         */
        _execOnAll: function(sMethod, args) {
            for (var i in this.ids) {
                for (var j in this.ids[i]) {
                    var oDD = this.ids[i][j];
                    if (! this.isTypeOfDD(oDD)) {
                        continue;
                    }
                    oDD[sMethod].apply(oDD, args);
                }
            }
        },

        /**
         * Drag and drop initialization.  Sets up the global event handlers
         * @method _onLoad
         * @private
         * @static
         */
        _onLoad: function() {

            this.init();


            Event.on(document, "mouseup",   this.handleMouseUp, this, true);
            Event.on(document, "mousemove", this.handleMouseMove, this, true);
            Event.on(window,   "unload",    this._onUnload, this, true);
            Event.on(window,   "resize",    this._onResize, this, true);
            // Event.on(window,   "mouseout",    this._test);

        },

        /**
         * Reset constraints on all drag and drop objs
         * @method _onResize
         * @private
         * @static
         */
        _onResize: function(e) {
            this._execOnAll("resetConstraints", []);
        },

        /**
         * Lock all drag and drop functionality
         * @method lock
         * @static
         */
        lock: function() { this.locked = true; },

        /**
         * Unlock all drag and drop functionality
         * @method unlock
         * @static
         */
        unlock: function() { this.locked = false; },

        /**
         * Is drag and drop locked?
         * @method isLocked
         * @return {boolean} True if drag and drop is locked, false otherwise.
         * @static
         */
        isLocked: function() { return this.locked; },

        /**
         * Location cache that is set for all drag drop objects when a drag is
         * initiated, cleared when the drag is finished.
         * @property locationCache
         * @private
         * @static
         */
        locationCache: {},

        /**
         * Set useCache to false if you want to force object the lookup of each
         * drag and drop linked element constantly during a drag.
         * @property useCache
         * @type boolean
         * @static
         */
        useCache: true,

        /**
         * The number of pixels that the mouse needs to move after the
         * mousedown before the drag is initiated.  Default=3;
         * @property clickPixelThresh
         * @type int
         * @static
         */
        clickPixelThresh: 3,

        /**
         * The number of milliseconds after the mousedown event to initiate the
         * drag if we don't get a mouseup event. Default=1000
         * @property clickTimeThresh
         * @type int
         * @static
         */
        clickTimeThresh: 350,

        /**
         * Flag that indicates that either the drag pixel threshold or the
         * mousdown time threshold has been met
         * @property dragThreshMet
         * @type boolean
         * @private
         * @static
         */
        dragThreshMet: false,

        /**
         * Timeout used for the click time threshold
         * @property clickTimeout
         * @type Object
         * @private
         * @static
         */
        clickTimeout: null,

        /**
         * The X position of the mousedown event stored for later use when a
         * drag threshold is met.
         * @property startX
         * @type int
         * @private
         * @static
         */
        startX: 0,

        /**
         * The Y position of the mousedown event stored for later use when a
         * drag threshold is met.
         * @property startY
         * @type int
         * @private
         * @static
         */
        startY: 0,

        /**
         * Each DragDrop instance must be registered with the DragDropMgr.
         * This is executed in DragDrop.init()
         * @method regDragDrop
         * @param {DragDrop} oDD the DragDrop object to register
         * @param {String} sGroup the name of the group this element belongs to
         * @static
         */
        regDragDrop: function(oDD, sGroup) {
            if (!this.initialized) { this.init(); }

            if (!this.ids[sGroup]) {
                this.ids[sGroup] = {};
            }
            this.ids[sGroup][oDD.id] = oDD;
        },

        /**
         * Removes the supplied dd instance from the supplied group. Executed
         * by DragDrop.removeFromGroup, so don't call this function directly.
         * @method removeDDFromGroup
         * @private
         * @static
         */
        removeDDFromGroup: function(oDD, sGroup) {
            if (!this.ids[sGroup]) {
                this.ids[sGroup] = {};
            }

            var obj = this.ids[sGroup];
            if (obj && obj[oDD.id]) {
                delete obj[oDD.id];
            }
        },

        /**
         * Unregisters a drag and drop item.  This is executed in
         * DragDrop.unreg, use that method instead of calling this directly.
         * @method _remove
         * @private
         * @static
         */
        _remove: function(oDD) {
            for (var g in oDD.groups) {
                if (g && this.ids[g][oDD.id]) {
                    delete this.ids[g][oDD.id];
                }
            }
            delete this.handleIds[oDD.id];
        },

        /**
         * Each DragDrop handle element must be registered.  This is done
         * automatically when executing DragDrop.setHandleElId()
         * @method regHandle
         * @param {String} sDDId the DragDrop id this element is a handle for
         * @param {String} sHandleId the id of the element that is the drag
         * handle
         * @static
         */
        regHandle: function(sDDId, sHandleId) {
            if (!this.handleIds[sDDId]) {
                this.handleIds[sDDId] = {};
            }
            this.handleIds[sDDId][sHandleId] = sHandleId;
        },

        /**
         * Utility function to determine if a given element has been
         * registered as a drag drop item.
         * @method isDragDrop
         * @param {String} id the element id to check
         * @return {boolean} true if this element is a DragDrop item,
         * false otherwise
         * @static
         */
        isDragDrop: function(id) {
            return ( this.getDDById(id) ) ? true : false;
        },

        /**
         * Returns the drag and drop instances that are in all groups the
         * passed in instance belongs to.
         * @method getRelated
         * @param {DragDrop} p_oDD the obj to get related data for
         * @param {boolean} bTargetsOnly if true, only return targetable objs
         * @return {DragDrop[]} the related instances
         * @static
         */
        getRelated: function(p_oDD, bTargetsOnly) {
            var oDDs = [];
            for (var i in p_oDD.groups) {
                for (j in this.ids[i]) {
                    var dd = this.ids[i][j];
                    if (! this.isTypeOfDD(dd)) {
                        continue;
                    }
                    if (!bTargetsOnly || dd.isTarget) {
                        oDDs[oDDs.length] = dd;
                    }
                }
            }

            return oDDs;
        },

        /**
         * Returns true if the specified dd target is a legal target for
         * the specifice drag obj
         * @method isLegalTarget
         * @param {DragDrop} the drag obj
         * @param {DragDrop} the target
         * @return {boolean} true if the target is a legal target for the
         * dd obj
         * @static
         */
        isLegalTarget: function (oDD, oTargetDD) {
            var targets = this.getRelated(oDD, true);
            for (var i=0, len=targets.length;i<len;++i) {
                if (targets[i].id == oTargetDD.id) {
                    return true;
                }
            }

            return false;
        },

        /**
         * My goal is to be able to transparently determine if an object is
         * typeof DragDrop, and the exact subclass of DragDrop.  typeof
         * returns "object", oDD.constructor.toString() always returns
         * "DragDrop" and not the name of the subclass.  So for now it just
         * evaluates a well-known variable in DragDrop.
         * @method isTypeOfDD
         * @param {Object} the object to evaluate
         * @return {boolean} true if typeof oDD = DragDrop
         * @static
         */
        isTypeOfDD: function (oDD) {
            return (oDD && oDD.__ygDragDrop);
        },

        /**
         * Utility function to determine if a given element has been
         * registered as a drag drop handle for the given Drag Drop object.
         * @method isHandle
         * @param {String} id the element id to check
         * @return {boolean} true if this element is a DragDrop handle, false
         * otherwise
         * @static
         */
        isHandle: function(sDDId, sHandleId) {
            return ( this.handleIds[sDDId] &&
                            this.handleIds[sDDId][sHandleId] );
        },

        /**
         * Returns the DragDrop instance for a given id
         * @method getDDById
         * @param {String} id the id of the DragDrop object
         * @return {DragDrop} the drag drop object, null if it is not found
         * @static
         */
        getDDById: function(id) {
            for (var i in this.ids) {
                if (this.ids[i][id]) {
                    return this.ids[i][id];
                }
            }
            return null;
        },

        /**
         * Fired after a registered DragDrop object gets the mousedown event.
         * Sets up the events required to track the object being dragged
         * @method handleMouseDown
         * @param {Event} e the event
         * @param oDD the DragDrop object being dragged
         * @private
         * @static
         */
        handleMouseDown: function(e, oDD) {
            if(Ext.QuickTips){
                Ext.QuickTips.disable();
            }
            this.currentTarget = e.getTarget();

            this.dragCurrent = oDD;

            var el = oDD.getEl();

            // track start position
            this.startX = e.getPageX();
            this.startY = e.getPageY();

            this.deltaX = this.startX - el.offsetLeft;
            this.deltaY = this.startY - el.offsetTop;

            this.dragThreshMet = false;

            this.clickTimeout = setTimeout(
                    function() {
                        var DDM = Ext.dd.DDM;
                        DDM.startDrag(DDM.startX, DDM.startY);
                    },
                    this.clickTimeThresh );
        },

        /**
         * Fired when either the drag pixel threshol or the mousedown hold
         * time threshold has been met.
         * @method startDrag
         * @param x {int} the X position of the original mousedown
         * @param y {int} the Y position of the original mousedown
         * @static
         */
        startDrag: function(x, y) {
            clearTimeout(this.clickTimeout);
            if (this.dragCurrent) {
                this.dragCurrent.b4StartDrag(x, y);
                this.dragCurrent.startDrag(x, y);
            }
            this.dragThreshMet = true;
        },

        /**
         * Internal function to handle the mouseup event.  Will be invoked
         * from the context of the document.
         * @method handleMouseUp
         * @param {Event} e the event
         * @private
         * @static
         */
        handleMouseUp: function(e) {

            if(Ext.QuickTips){
                Ext.QuickTips.enable();
            }
            if (! this.dragCurrent) {
                return;
            }

            clearTimeout(this.clickTimeout);

            if (this.dragThreshMet) {
                this.fireEvents(e, true);
            } else {
            }

            this.stopDrag(e);

            this.stopEvent(e);
        },

        /**
         * Utility to stop event propagation and event default, if these
         * features are turned on.
         * @method stopEvent
         * @param {Event} e the event as returned by this.getEvent()
         * @static
         */
        stopEvent: function(e){
            if(this.stopPropagation) {
                e.stopPropagation();
            }

            if (this.preventDefault) {
                e.preventDefault();
            }
        },

        /**
         * Internal function to clean up event handlers after the drag
         * operation is complete
         * @method stopDrag
         * @param {Event} e the event
         * @private
         * @static
         */
        stopDrag: function(e) {
            // Fire the drag end event for the item that was dragged
            if (this.dragCurrent) {
                if (this.dragThreshMet) {
                    this.dragCurrent.b4EndDrag(e);
                    this.dragCurrent.endDrag(e);
                }

                this.dragCurrent.onMouseUp(e);
            }

            this.dragCurrent = null;
            this.dragOvers = {};
        },

        /**
         * Internal function to handle the mousemove event.  Will be invoked
         * from the context of the html element.
         *
         * @TODO figure out what we can do about mouse events lost when the
         * user drags objects beyond the window boundary.  Currently we can
         * detect this in internet explorer by verifying that the mouse is
         * down during the mousemove event.  Firefox doesn't give us the
         * button state on the mousemove event.
         * @method handleMouseMove
         * @param {Event} e the event
         * @private
         * @static
         */
        handleMouseMove: function(e) {
            if (! this.dragCurrent) {
                return true;
            }

            // var button = e.which || e.button;

            // check for IE mouseup outside of page boundary
            if (Ext.isIE && (e.button !== 0 && e.button !== 1 && e.button !== 2)) {
                this.stopEvent(e);
                return this.handleMouseUp(e);
            }

            if (!this.dragThreshMet) {
                var diffX = Math.abs(this.startX - e.getPageX());
                var diffY = Math.abs(this.startY - e.getPageY());
                if (diffX > this.clickPixelThresh ||
                            diffY > this.clickPixelThresh) {
                    this.startDrag(this.startX, this.startY);
                }
            }

            if (this.dragThreshMet) {
                this.dragCurrent.b4Drag(e);
                this.dragCurrent.onDrag(e);
                if(!this.dragCurrent.moveOnly){
                    this.fireEvents(e, false);
                }
            }

            this.stopEvent(e);

            return true;
        },

        /**
         * Iterates over all of the DragDrop elements to find ones we are
         * hovering over or dropping on
         * @method fireEvents
         * @param {Event} e the event
         * @param {boolean} isDrop is this a drop op or a mouseover op?
         * @private
         * @static
         */
        fireEvents: function(e, isDrop) {
            var dc = this.dragCurrent;

            // If the user did the mouse up outside of the window, we could
            // get here even though we have ended the drag.
            if (!dc || dc.isLocked()) {
                return;
            }

            var pt = e.getPoint();

            // cache the previous dragOver array
            var oldOvers = [];

            var outEvts   = [];
            var overEvts  = [];
            var dropEvts  = [];
            var enterEvts = [];

            // Check to see if the object(s) we were hovering over is no longer
            // being hovered over so we can fire the onDragOut event
            for (var i in this.dragOvers) {

                var ddo = this.dragOvers[i];

                if (! this.isTypeOfDD(ddo)) {
                    continue;
                }

                if (! this.isOverTarget(pt, ddo, this.mode)) {
                    outEvts.push( ddo );
                }

                oldOvers[i] = true;
                delete this.dragOvers[i];
            }

            for (var sGroup in dc.groups) {

                if ("string" != typeof sGroup) {
                    continue;
                }

                for (i in this.ids[sGroup]) {
                    var oDD = this.ids[sGroup][i];
                    if (! this.isTypeOfDD(oDD)) {
                        continue;
                    }

                    if (oDD.isTarget && !oDD.isLocked() && oDD != dc) {
                        if (this.isOverTarget(pt, oDD, this.mode)) {
                            // look for drop interactions
                            if (isDrop) {
                                dropEvts.push( oDD );
                            // look for drag enter and drag over interactions
                            } else {

                                // initial drag over: dragEnter fires
                                if (!oldOvers[oDD.id]) {
                                    enterEvts.push( oDD );
                                // subsequent drag overs: dragOver fires
                                } else {
                                    overEvts.push( oDD );
                                }

                                this.dragOvers[oDD.id] = oDD;
                            }
                        }
                    }
                }
            }

            if (this.mode) {
                if (outEvts.length) {
                    dc.b4DragOut(e, outEvts);
                    dc.onDragOut(e, outEvts);
                }

                if (enterEvts.length) {
                    dc.onDragEnter(e, enterEvts);
                }

                if (overEvts.length) {
                    dc.b4DragOver(e, overEvts);
                    dc.onDragOver(e, overEvts);
                }

                if (dropEvts.length) {
                    dc.b4DragDrop(e, dropEvts);
                    dc.onDragDrop(e, dropEvts);
                }

            } else {
                // fire dragout events
                var len = 0;
                for (i=0, len=outEvts.length; i<len; ++i) {
                    dc.b4DragOut(e, outEvts[i].id);
                    dc.onDragOut(e, outEvts[i].id);
                }

                // fire enter events
                for (i=0,len=enterEvts.length; i<len; ++i) {
                    // dc.b4DragEnter(e, oDD.id);
                    dc.onDragEnter(e, enterEvts[i].id);
                }

                // fire over events
                for (i=0,len=overEvts.length; i<len; ++i) {
                    dc.b4DragOver(e, overEvts[i].id);
                    dc.onDragOver(e, overEvts[i].id);
                }

                // fire drop events
                for (i=0, len=dropEvts.length; i<len; ++i) {
                    dc.b4DragDrop(e, dropEvts[i].id);
                    dc.onDragDrop(e, dropEvts[i].id);
                }

            }

            // notify about a drop that did not find a target
            if (isDrop && !dropEvts.length) {
                dc.onInvalidDrop(e);
            }

        },

        /**
         * Helper function for getting the best match from the list of drag
         * and drop objects returned by the drag and drop events when we are
         * in INTERSECT mode.  It returns either the first object that the
         * cursor is over, or the object that has the greatest overlap with
         * the dragged element.
         * @method getBestMatch
         * @param  {DragDrop[]} dds The array of drag and drop objects
         * targeted
         * @return {DragDrop}       The best single match
         * @static
         */
        getBestMatch: function(dds) {
            var winner = null;
            // Return null if the input is not what we expect
            //if (!dds || !dds.length || dds.length == 0) {
               // winner = null;
            // If there is only one item, it wins
            //} else if (dds.length == 1) {

            var len = dds.length;

            if (len == 1) {
                winner = dds[0];
            } else {
                // Loop through the targeted items
                for (var i=0; i<len; ++i) {
                    var dd = dds[i];
                    // If the cursor is over the object, it wins.  If the
                    // cursor is over multiple matches, the first one we come
                    // to wins.
                    if (dd.cursorIsOver) {
                        winner = dd;
                        break;
                    // Otherwise the object with the most overlap wins
                    } else {
                        if (!winner ||
                            winner.overlap.getArea() < dd.overlap.getArea()) {
                            winner = dd;
                        }
                    }
                }
            }

            return winner;
        },

        /**
         * Refreshes the cache of the top-left and bottom-right points of the
         * drag and drop objects in the specified group(s).  This is in the
         * format that is stored in the drag and drop instance, so typical
         * usage is:
         * <code>
         * Ext.dd.DragDropMgr.refreshCache(ddinstance.groups);
         * </code>
         * Alternatively:
         * <code>
         * Ext.dd.DragDropMgr.refreshCache({group1:true, group2:true});
         * </code>
         * @TODO this really should be an indexed array.  Alternatively this
         * method could accept both.
         * @method refreshCache
         * @param {Object} groups an associative array of groups to refresh
         * @static
         */
        refreshCache: function(groups) {
            for (var sGroup in groups) {
                if ("string" != typeof sGroup) {
                    continue;
                }
                for (var i in this.ids[sGroup]) {
                    var oDD = this.ids[sGroup][i];

                    if (this.isTypeOfDD(oDD)) {
                    // if (this.isTypeOfDD(oDD) && oDD.isTarget) {
                        var loc = this.getLocation(oDD);
                        if (loc) {
                            this.locationCache[oDD.id] = loc;
                        } else {
                            delete this.locationCache[oDD.id];
                            // this will unregister the drag and drop object if
                            // the element is not in a usable state
                            // oDD.unreg();
                        }
                    }
                }
            }
        },

        /**
         * This checks to make sure an element exists and is in the DOM.  The
         * main purpose is to handle cases where innerHTML is used to remove
         * drag and drop objects from the DOM.  IE provides an 'unspecified
         * error' when trying to access the offsetParent of such an element
         * @method verifyEl
         * @param {HTMLElement} el the element to check
         * @return {boolean} true if the element looks usable
         * @static
         */
        verifyEl: function(el) {
            if (el) {
                var parent;
                if(Ext.isIE){
                    try{
                        parent = el.offsetParent;
                    }catch(e){}
                }else{
                    parent = el.offsetParent;
                }
                if (parent) {
                    return true;
                }
            }

            return false;
        },

        /**
         * Returns a Region object containing the drag and drop element's position
         * and size, including the padding configured for it
         * @method getLocation
         * @param {DragDrop} oDD the drag and drop object to get the
         *                       location for
         * @return {Ext.lib.Region} a Region object representing the total area
         *                             the element occupies, including any padding
         *                             the instance is configured for.
         * @static
         */
        getLocation: function(oDD) {
            if (! this.isTypeOfDD(oDD)) {
                return null;
            }

            var el = oDD.getEl(), pos, x1, x2, y1, y2, t, r, b, l;

            try {
                pos= Ext.lib.Dom.getXY(el);
            } catch (e) { }

            if (!pos) {
                return null;
            }

            x1 = pos[0];
            x2 = x1 + el.offsetWidth;
            y1 = pos[1];
            y2 = y1 + el.offsetHeight;

            t = y1 - oDD.padding[0];
            r = x2 + oDD.padding[1];
            b = y2 + oDD.padding[2];
            l = x1 - oDD.padding[3];

            return new Ext.lib.Region( t, r, b, l );
        },

        /**
         * Checks the cursor location to see if it over the target
         * @method isOverTarget
         * @param {Ext.lib.Point} pt The point to evaluate
         * @param {DragDrop} oTarget the DragDrop object we are inspecting
         * @return {boolean} true if the mouse is over the target
         * @private
         * @static
         */
        isOverTarget: function(pt, oTarget, intersect) {
            // use cache if available
            var loc = this.locationCache[oTarget.id];
            if (!loc || !this.useCache) {
                loc = this.getLocation(oTarget);
                this.locationCache[oTarget.id] = loc;

            }

            if (!loc) {
                return false;
            }

            oTarget.cursorIsOver = loc.contains( pt );

            // DragDrop is using this as a sanity check for the initial mousedown
            // in this case we are done.  In POINT mode, if the drag obj has no
            // contraints, we are also done. Otherwise we need to evaluate the
            // location of the target as related to the actual location of the
            // dragged element.
            var dc = this.dragCurrent;
            if (!dc || !dc.getTargetCoord ||
                    (!intersect && !dc.constrainX && !dc.constrainY)) {
                return oTarget.cursorIsOver;
            }

            oTarget.overlap = null;

            // Get the current location of the drag element, this is the
            // location of the mouse event less the delta that represents
            // where the original mousedown happened on the element.  We
            // need to consider constraints and ticks as well.
            var pos = dc.getTargetCoord(pt.x, pt.y);

            var el = dc.getDragEl();
            var curRegion = new Ext.lib.Region( pos.y,
                                                   pos.x + el.offsetWidth,
                                                   pos.y + el.offsetHeight,
                                                   pos.x );

            var overlap = curRegion.intersect(loc);

            if (overlap) {
                oTarget.overlap = overlap;
                return (intersect) ? true : oTarget.cursorIsOver;
            } else {
                return false;
            }
        },

        /**
         * unload event handler
         * @method _onUnload
         * @private
         * @static
         */
        _onUnload: function(e, me) {
            Ext.dd.DragDropMgr.unregAll();
        },

        /**
         * Cleans up the drag and drop events and objects.
         * @method unregAll
         * @private
         * @static
         */
        unregAll: function() {

            if (this.dragCurrent) {
                this.stopDrag();
                this.dragCurrent = null;
            }

            this._execOnAll("unreg", []);

            for (var i in this.elementCache) {
                delete this.elementCache[i];
            }

            this.elementCache = {};
            this.ids = {};
        },

        /**
         * A cache of DOM elements
         * @property elementCache
         * @private
         * @static
         */
        elementCache: {},

        /**
         * Get the wrapper for the DOM element specified
         * @method getElWrapper
         * @param {String} id the id of the element to get
         * @return {Ext.dd.DDM.ElementWrapper} the wrapped element
         * @private
         * @deprecated This wrapper isn't that useful
         * @static
         */
        getElWrapper: function(id) {
            var oWrapper = this.elementCache[id];
            if (!oWrapper || !oWrapper.el) {
                oWrapper = this.elementCache[id] =
                    new this.ElementWrapper(Ext.getDom(id));
            }
            return oWrapper;
        },

        /**
         * Returns the actual DOM element
         * @method getElement
         * @param {String} id the id of the elment to get
         * @return {Object} The element
         * @deprecated use Ext.lib.Ext.getDom instead
         * @static
         */
        getElement: function(id) {
            return Ext.getDom(id);
        },

        /**
         * Returns the style property for the DOM element (i.e.,
         * document.getElById(id).style)
         * @method getCss
         * @param {String} id the id of the elment to get
         * @return {Object} The style property of the element
         * @deprecated use Ext.lib.Dom instead
         * @static
         */
        getCss: function(id) {
            var el = Ext.getDom(id);
            return (el) ? el.style : null;
        },

        /**
         * Inner class for cached elements
         * @class DragDropMgr.ElementWrapper
         * @for DragDropMgr
         * @private
         * @deprecated
         */
        ElementWrapper: function(el) {
                /**
                 * The element
                 * @property el
                 */
                this.el = el || null;
                /**
                 * The element id
                 * @property id
                 */
                this.id = this.el && el.id;
                /**
                 * A reference to the style property
                 * @property css
                 */
                this.css = this.el && el.style;
            },

        /**
         * Returns the X position of an html element
         * @method getPosX
         * @param el the element for which to get the position
         * @return {int} the X coordinate
         * @for DragDropMgr
         * @deprecated use Ext.lib.Dom.getX instead
         * @static
         */
        getPosX: function(el) {
            return Ext.lib.Dom.getX(el);
        },

        /**
         * Returns the Y position of an html element
         * @method getPosY
         * @param el the element for which to get the position
         * @return {int} the Y coordinate
         * @deprecated use Ext.lib.Dom.getY instead
         * @static
         */
        getPosY: function(el) {
            return Ext.lib.Dom.getY(el);
        },

        /**
         * Swap two nodes.  In IE, we use the native method, for others we
         * emulate the IE behavior
         * @method swapNode
         * @param n1 the first node to swap
         * @param n2 the other node to swap
         * @static
         */
        swapNode: function(n1, n2) {
            if (n1.swapNode) {
                n1.swapNode(n2);
            } else {
                var p = n2.parentNode;
                var s = n2.nextSibling;

                if (s == n1) {
                    p.insertBefore(n1, n2);
                } else if (n2 == n1.nextSibling) {
                    p.insertBefore(n2, n1);
                } else {
                    n1.parentNode.replaceChild(n2, n1);
                    p.insertBefore(n1, s);
                }
            }
        },

        /**
         * Returns the current scroll position
         * @method getScroll
         * @private
         * @static
         */
        getScroll: function () {
            var t, l, dde=document.documentElement, db=document.body;
            if (dde && (dde.scrollTop || dde.scrollLeft)) {
                t = dde.scrollTop;
                l = dde.scrollLeft;
            } else if (db) {
                t = db.scrollTop;
                l = db.scrollLeft;
            } else {

            }
            return { top: t, left: l };
        },

        /**
         * Returns the specified element style property
         * @method getStyle
         * @param {HTMLElement} el          the element
         * @param {string}      styleProp   the style property
         * @return {string} The value of the style property
         * @deprecated use Ext.lib.Dom.getStyle
         * @static
         */
        getStyle: function(el, styleProp) {
            return Ext.fly(el).getStyle(styleProp);
        },

        /**
         * Gets the scrollTop
         * @method getScrollTop
         * @return {int} the document's scrollTop
         * @static
         */
        getScrollTop: function () { return this.getScroll().top; },

        /**
         * Gets the scrollLeft
         * @method getScrollLeft
         * @return {int} the document's scrollTop
         * @static
         */
        getScrollLeft: function () { return this.getScroll().left; },

        /**
         * Sets the x/y position of an element to the location of the
         * target element.
         * @method moveToEl
         * @param {HTMLElement} moveEl      The element to move
         * @param {HTMLElement} targetEl    The position reference element
         * @static
         */
        moveToEl: function (moveEl, targetEl) {
            var aCoord = Ext.lib.Dom.getXY(targetEl);
            Ext.lib.Dom.setXY(moveEl, aCoord);
        },

        /**
         * Numeric array sort function
         * @method numericSort
         * @static
         */
        numericSort: function(a, b) { return (a - b); },

        /**
         * Internal counter
         * @property _timeoutCount
         * @private
         * @static
         */
        _timeoutCount: 0,

        /**
         * Trying to make the load order less important.  Without this we get
         * an error if this file is loaded before the Event Utility.
         * @method _addListeners
         * @private
         * @static
         */
        _addListeners: function() {
            var DDM = Ext.dd.DDM;
            if ( Ext.lib.Event && document ) {
                DDM._onLoad();
            } else {
                if (DDM._timeoutCount > 2000) {
                } else {
                    setTimeout(DDM._addListeners, 10);
                    if (document && document.body) {
                        DDM._timeoutCount += 1;
                    }
                }
            }
        },

        /**
         * Recursively searches the immediate parent and all child nodes for
         * the handle element in order to determine wheter or not it was
         * clicked.
         * @method handleWasClicked
         * @param node the html element to inspect
         * @static
         */
        handleWasClicked: function(node, id) {
            if (this.isHandle(id, node.id)) {
                return true;
            } else {
                // check to see if this is a text node child of the one we want
                var p = node.parentNode;

                while (p) {
                    if (this.isHandle(id, p.id)) {
                        return true;
                    } else {
                        p = p.parentNode;
                    }
                }
            }

            return false;
        }

    };

}();

// shorter alias, save a few bytes
Ext.dd.DDM = Ext.dd.DragDropMgr;
Ext.dd.DDM._addListeners();

}

/**
 * @class Ext.dd.DD
 * A DragDrop implementation where the linked element follows the
 * mouse cursor during a drag.
 * @extends Ext.dd.DragDrop
 * @constructor
 * @param {String} id the id of the linked element
 * @param {String} sGroup the group of related DragDrop items
 * @param {object} config an object containing configurable attributes
 *                Valid properties for DD:
 *                    scroll
 */
Ext.dd.DD = function(id, sGroup, config) {
    if (id) {
        this.init(id, sGroup, config);
    }
};

Ext.extend(Ext.dd.DD, Ext.dd.DragDrop, {

    /**
     * When set to true, the utility automatically tries to scroll the browser
     * window when a drag and drop element is dragged near the viewport boundary.
     * Defaults to true.
     * @property scroll
     * @type boolean
     */
    scroll: true,

    /**
     * Sets the pointer offset to the distance between the linked element's top
     * left corner and the location the element was clicked
     * @method autoOffset
     * @param {int} iPageX the X coordinate of the click
     * @param {int} iPageY the Y coordinate of the click
     */
    autoOffset: function(iPageX, iPageY) {
        var x = iPageX - this.startPageX;
        var y = iPageY - this.startPageY;
        this.setDelta(x, y);
    },

    /**
     * Sets the pointer offset.  You can call this directly to force the
     * offset to be in a particular location (e.g., pass in 0,0 to set it
     * to the center of the object)
     * @method setDelta
     * @param {int} iDeltaX the distance from the left
     * @param {int} iDeltaY the distance from the top
     */
    setDelta: function(iDeltaX, iDeltaY) {
        this.deltaX = iDeltaX;
        this.deltaY = iDeltaY;
    },

    /**
     * Sets the drag element to the location of the mousedown or click event,
     * maintaining the cursor location relative to the location on the element
     * that was clicked.  Override this if you want to place the element in a
     * location other than where the cursor is.
     * @method setDragElPos
     * @param {int} iPageX the X coordinate of the mousedown or drag event
     * @param {int} iPageY the Y coordinate of the mousedown or drag event
     */
    setDragElPos: function(iPageX, iPageY) {
        // the first time we do this, we are going to check to make sure
        // the element has css positioning

        var el = this.getDragEl();
        this.alignElWithMouse(el, iPageX, iPageY);
    },

    /**
     * Sets the element to the location of the mousedown or click event,
     * maintaining the cursor location relative to the location on the element
     * that was clicked.  Override this if you want to place the element in a
     * location other than where the cursor is.
     * @method alignElWithMouse
     * @param {HTMLElement} el the element to move
     * @param {int} iPageX the X coordinate of the mousedown or drag event
     * @param {int} iPageY the Y coordinate of the mousedown or drag event
     */
    alignElWithMouse: function(el, iPageX, iPageY) {
        var oCoord = this.getTargetCoord(iPageX, iPageY);
        var fly = el.dom ? el : Ext.fly(el, '_dd');
        if (!this.deltaSetXY) {
            var aCoord = [oCoord.x, oCoord.y];
            fly.setXY(aCoord);
            var newLeft = fly.getLeft(true);
            var newTop  = fly.getTop(true);
            this.deltaSetXY = [ newLeft - oCoord.x, newTop - oCoord.y ];
        } else {
            fly.setLeftTop(oCoord.x + this.deltaSetXY[0], oCoord.y + this.deltaSetXY[1]);
        }

        this.cachePosition(oCoord.x, oCoord.y);
        this.autoScroll(oCoord.x, oCoord.y, el.offsetHeight, el.offsetWidth);
        return oCoord;
    },

    /**
     * Saves the most recent position so that we can reset the constraints and
     * tick marks on-demand.  We need to know this so that we can calculate the
     * number of pixels the element is offset from its original position.
     * @method cachePosition
     * @param iPageX the current x position (optional, this just makes it so we
     * don't have to look it up again)
     * @param iPageY the current y position (optional, this just makes it so we
     * don't have to look it up again)
     */
    cachePosition: function(iPageX, iPageY) {
        if (iPageX) {
            this.lastPageX = iPageX;
            this.lastPageY = iPageY;
        } else {
            var aCoord = Ext.lib.Dom.getXY(this.getEl());
            this.lastPageX = aCoord[0];
            this.lastPageY = aCoord[1];
        }
    },

    /**
     * Auto-scroll the window if the dragged object has been moved beyond the
     * visible window boundary.
     * @method autoScroll
     * @param {int} x the drag element's x position
     * @param {int} y the drag element's y position
     * @param {int} h the height of the drag element
     * @param {int} w the width of the drag element
     * @private
     */
    autoScroll: function(x, y, h, w) {

        if (this.scroll) {
            // The client height
            var clientH = Ext.lib.Dom.getViewHeight();

            // The client width
            var clientW = Ext.lib.Dom.getViewWidth();

            // The amt scrolled down
            var st = this.DDM.getScrollTop();

            // The amt scrolled right
            var sl = this.DDM.getScrollLeft();

            // Location of the bottom of the element
            var bot = h + y;

            // Location of the right of the element
            var right = w + x;

            // The distance from the cursor to the bottom of the visible area,
            // adjusted so that we don't scroll if the cursor is beyond the
            // element drag constraints
            var toBot = (clientH + st - y - this.deltaY);

            // The distance from the cursor to the right of the visible area
            var toRight = (clientW + sl - x - this.deltaX);


            // How close to the edge the cursor must be before we scroll
            // var thresh = (document.all) ? 100 : 40;
            var thresh = 40;

            // How many pixels to scroll per autoscroll op.  This helps to reduce
            // clunky scrolling. IE is more sensitive about this ... it needs this
            // value to be higher.
            var scrAmt = (document.all) ? 80 : 30;

            // Scroll down if we are near the bottom of the visible page and the
            // obj extends below the crease
            if ( bot > clientH && toBot < thresh ) {
                window.scrollTo(sl, st + scrAmt);
            }

            // Scroll up if the window is scrolled down and the top of the object
            // goes above the top border
            if ( y < st && st > 0 && y - st < thresh ) {
                window.scrollTo(sl, st - scrAmt);
            }

            // Scroll right if the obj is beyond the right border and the cursor is
            // near the border.
            if ( right > clientW && toRight < thresh ) {
                window.scrollTo(sl + scrAmt, st);
            }

            // Scroll left if the window has been scrolled to the right and the obj
            // extends past the left border
            if ( x < sl && sl > 0 && x - sl < thresh ) {
                window.scrollTo(sl - scrAmt, st);
            }
        }
    },

    /**
     * Finds the location the element should be placed if we want to move
     * it to where the mouse location less the click offset would place us.
     * @method getTargetCoord
     * @param {int} iPageX the X coordinate of the click
     * @param {int} iPageY the Y coordinate of the click
     * @return an object that contains the coordinates (Object.x and Object.y)
     * @private
     */
    getTargetCoord: function(iPageX, iPageY) {


        var x = iPageX - this.deltaX;
        var y = iPageY - this.deltaY;

        if (this.constrainX) {
            if (x < this.minX) { x = this.minX; }
            if (x > this.maxX) { x = this.maxX; }
        }

        if (this.constrainY) {
            if (y < this.minY) { y = this.minY; }
            if (y > this.maxY) { y = this.maxY; }
        }

        x = this.getTick(x, this.xTicks);
        y = this.getTick(y, this.yTicks);


        return {x:x, y:y};
    },

    /**
     * Sets up config options specific to this class. Overrides
     * Ext.dd.DragDrop, but all versions of this method through the
     * inheritance chain are called
     */
    applyConfig: function() {
        Ext.dd.DD.superclass.applyConfig.call(this);
        this.scroll = (this.config.scroll !== false);
    },

    /**
     * Event that fires prior to the onMouseDown event.  Overrides
     * Ext.dd.DragDrop.
     */
    b4MouseDown: function(e) {
        // this.resetConstraints();
        this.autoOffset(e.getPageX(),
                            e.getPageY());
    },

    /**
     * Event that fires prior to the onDrag event.  Overrides
     * Ext.dd.DragDrop.
     */
    b4Drag: function(e) {
        this.setDragElPos(e.getPageX(),
                            e.getPageY());
    },

    toString: function() {
        return ("DD " + this.id);
    }

    //////////////////////////////////////////////////////////////////////////
    // Debugging ygDragDrop events that can be overridden
    //////////////////////////////////////////////////////////////////////////
    /*
    startDrag: function(x, y) {
    },

    onDrag: function(e) {
    },

    onDragEnter: function(e, id) {
    },

    onDragOver: function(e, id) {
    },

    onDragOut: function(e, id) {
    },

    onDragDrop: function(e, id) {
    },

    endDrag: function(e) {
    }

    */

});
/**
 * @class Ext.dd.DDProxy
 * A DragDrop implementation that inserts an empty, bordered div into
 * the document that follows the cursor during drag operations.  At the time of
 * the click, the frame div is resized to the dimensions of the linked html
 * element, and moved to the exact location of the linked element.
 *
 * References to the "frame" element refer to the single proxy element that
 * was created to be dragged in place of all DDProxy elements on the
 * page.
 *
 * @extends Ext.dd.DD
 * @constructor
 * @param {String} id the id of the linked html element
 * @param {String} sGroup the group of related DragDrop objects
 * @param {object} config an object containing configurable attributes
 *                Valid properties for DDProxy in addition to those in DragDrop:
 *                   resizeFrame, centerFrame, dragElId
 */
Ext.dd.DDProxy = function(id, sGroup, config) {
    if (id) {
        this.init(id, sGroup, config);
        this.initFrame();
    }
};

/**
 * The default drag frame div id
 * @property Ext.dd.DDProxy.dragElId
 * @type String
 * @static
 */
Ext.dd.DDProxy.dragElId = "ygddfdiv";

Ext.extend(Ext.dd.DDProxy, Ext.dd.DD, {

    /**
     * By default we resize the drag frame to be the same size as the element
     * we want to drag (this is to get the frame effect).  We can turn it off
     * if we want a different behavior.
     * @property resizeFrame
     * @type boolean
     */
    resizeFrame: true,

    /**
     * By default the frame is positioned exactly where the drag element is, so
     * we use the cursor offset provided by Ext.dd.DD.  Another option that works only if
     * you do not have constraints on the obj is to have the drag frame centered
     * around the cursor.  Set centerFrame to true for this effect.
     * @property centerFrame
     * @type boolean
     */
    centerFrame: false,

    /**
     * Creates the proxy element if it does not yet exist
     * @method createFrame
     */
    createFrame: function() {
        var self = this;
        var body = document.body;

        if (!body || !body.firstChild) {
            setTimeout( function() { self.createFrame(); }, 50 );
            return;
        }

        var div = this.getDragEl();

        if (!div) {
            div    = document.createElement("div");
            div.id = this.dragElId;
            var s  = div.style;

            s.position   = "absolute";
            s.visibility = "hidden";
            s.cursor     = "move";
            s.border     = "2px solid #aaa";
            s.zIndex     = 999;

            // appendChild can blow up IE if invoked prior to the window load event
            // while rendering a table.  It is possible there are other scenarios
            // that would cause this to happen as well.
            body.insertBefore(div, body.firstChild);
        }
    },

    /**
     * Initialization for the drag frame element.  Must be called in the
     * constructor of all subclasses
     * @method initFrame
     */
    initFrame: function() {
        this.createFrame();
    },

    applyConfig: function() {
        Ext.dd.DDProxy.superclass.applyConfig.call(this);

        this.resizeFrame = (this.config.resizeFrame !== false);
        this.centerFrame = (this.config.centerFrame);
        this.setDragElId(this.config.dragElId || Ext.dd.DDProxy.dragElId);
    },

    /**
     * Resizes the drag frame to the dimensions of the clicked object, positions
     * it over the object, and finally displays it
     * @method showFrame
     * @param {int} iPageX X click position
     * @param {int} iPageY Y click position
     * @private
     */
    showFrame: function(iPageX, iPageY) {
        var el = this.getEl();
        var dragEl = this.getDragEl();
        var s = dragEl.style;

        this._resizeProxy();

        if (this.centerFrame) {
            this.setDelta( Math.round(parseInt(s.width,  10)/2),
                           Math.round(parseInt(s.height, 10)/2) );
        }

        this.setDragElPos(iPageX, iPageY);

        Ext.fly(dragEl).show();
    },

    /**
     * The proxy is automatically resized to the dimensions of the linked
     * element when a drag is initiated, unless resizeFrame is set to false
     * @method _resizeProxy
     * @private
     */
    _resizeProxy: function() {
        if (this.resizeFrame) {
            var el = this.getEl();
            Ext.fly(this.getDragEl()).setSize(el.offsetWidth, el.offsetHeight);
        }
    },

    // overrides Ext.dd.DragDrop
    b4MouseDown: function(e) {
        var x = e.getPageX();
        var y = e.getPageY();
        this.autoOffset(x, y);
        this.setDragElPos(x, y);
    },

    // overrides Ext.dd.DragDrop
    b4StartDrag: function(x, y) {
        // show the drag frame
        this.showFrame(x, y);
    },

    // overrides Ext.dd.DragDrop
    b4EndDrag: function(e) {
        Ext.fly(this.getDragEl()).hide();
    },

    // overrides Ext.dd.DragDrop
    // By default we try to move the element to the last location of the frame.
    // This is so that the default behavior mirrors that of Ext.dd.DD.
    endDrag: function(e) {

        var lel = this.getEl();
        var del = this.getDragEl();

        // Show the drag frame briefly so we can get its position
        del.style.visibility = "";

        this.beforeMove();
        // Hide the linked element before the move to get around a Safari
        // rendering bug.
        lel.style.visibility = "hidden";
        Ext.dd.DDM.moveToEl(lel, del);
        del.style.visibility = "hidden";
        lel.style.visibility = "";

        this.afterDrag();
    },

    beforeMove : function(){

    },

    afterDrag : function(){

    },

    toString: function() {
        return ("DDProxy " + this.id);
    }

});
/**
 * @class Ext.dd.DDTarget
 * A DragDrop implementation that does not move, but can be a drop
 * target.  You would get the same result by simply omitting implementation
 * for the event callbacks, but this way we reduce the processing cost of the
 * event listener and the callbacks.
 * @extends Ext.dd.DragDrop
 * @constructor
 * @param {String} id the id of the element that is a drop target
 * @param {String} sGroup the group of related DragDrop objects
 * @param {object} config an object containing configurable attributes
 *                 Valid properties for DDTarget in addition to those in
 *                 DragDrop:
 *                    none
 */
Ext.dd.DDTarget = function(id, sGroup, config) {
    if (id) {
        this.initTarget(id, sGroup, config);
    }
};

// Ext.dd.DDTarget.prototype = new Ext.dd.DragDrop();
Ext.extend(Ext.dd.DDTarget, Ext.dd.DragDrop, {
    toString: function() {
        return ("DDTarget " + this.id);
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
 * @class Ext.dd.DragSource
 * @extends Ext.dd.DDProxy
 * A simple class that provides the basic implementation needed to make any element draggable.
 * @constructor
 * @param {Mixed} el The container element
 * @param {Object} config
 */
Ext.dd.DragSource = function(el, config){
    this.el = Ext.get(el);
    if(!this.dragData){
        this.dragData = {};
    }
    
    Ext.apply(this, config);
    
    if(!this.proxy){
        this.proxy = new Ext.dd.StatusProxy();
    }
    Ext.dd.DragSource.superclass.constructor.call(this, this.el.dom, this.ddGroup || this.group, 
          {dragElId : this.proxy.id, resizeFrame: false, isTarget: false, scroll: this.scroll === true});
    
    this.dragging = false;
};

Ext.extend(Ext.dd.DragSource, Ext.dd.DDProxy, {
    /**
     * @cfg {String} ddGroup
     * A named drag drop group to which this object belongs.  If a group is specified, then this object will only
     * interact with other drag drop objects in the same group (defaults to undefined).
     */
    /**
     * @cfg {String} dropAllowed
     * The CSS class returned to the drag source when drop is allowed (defaults to "x-dd-drop-ok").
     */
    dropAllowed : "x-dd-drop-ok",
    /**
     * @cfg {String} dropNotAllowed
     * The CSS class returned to the drag source when drop is not allowed (defaults to "x-dd-drop-nodrop").
     */
    dropNotAllowed : "x-dd-drop-nodrop",

    /**
     * Returns the data object associated with this drag source
     * @return {Object} data An object containing arbitrary data
     */
    getDragData : function(e){
        return this.dragData;
    },

    // private
    onDragEnter : function(e, id){
        var target = Ext.dd.DragDropMgr.getDDById(id);
        this.cachedTarget = target;
        if(this.beforeDragEnter(target, e, id) !== false){
            if(target.isNotifyTarget){
                var status = target.notifyEnter(this, e, this.dragData);
                this.proxy.setStatus(status);
            }else{
                this.proxy.setStatus(this.dropAllowed);
            }
            
            if(this.afterDragEnter){
                /**
                 * An empty function by default, but provided so that you can perform a custom action
                 * when the dragged item enters the drop target by providing an implementation.
                 * @param {Ext.dd.DragDrop} target The drop target
                 * @param {Event} e The event object
                 * @param {String} id The id of the dragged element
                 * @method afterDragEnter
                 */
                this.afterDragEnter(target, e, id);
            }
        }
    },

    /**
     * An empty function by default, but provided so that you can perform a custom action
     * before the dragged item enters the drop target and optionally cancel the onDragEnter.
     * @param {Ext.dd.DragDrop} target The drop target
     * @param {Event} e The event object
     * @param {String} id The id of the dragged element
     * @return {Boolean} isValid True if the drag event is valid, else false to cancel
     */
    beforeDragEnter : function(target, e, id){
        return true;
    },

    // private
    alignElWithMouse: function() {
        Ext.dd.DragSource.superclass.alignElWithMouse.apply(this, arguments);
        this.proxy.sync();
    },

    // private
    onDragOver : function(e, id){
        var target = this.cachedTarget || Ext.dd.DragDropMgr.getDDById(id);
        if(this.beforeDragOver(target, e, id) !== false){
            if(target.isNotifyTarget){
                var status = target.notifyOver(this, e, this.dragData);
                this.proxy.setStatus(status);
            }

            if(this.afterDragOver){
                /**
                 * An empty function by default, but provided so that you can perform a custom action
                 * while the dragged item is over the drop target by providing an implementation.
                 * @param {Ext.dd.DragDrop} target The drop target
                 * @param {Event} e The event object
                 * @param {String} id The id of the dragged element
                 * @method afterDragOver
                 */
                this.afterDragOver(target, e, id);
            }
        }
    },

    /**
     * An empty function by default, but provided so that you can perform a custom action
     * while the dragged item is over the drop target and optionally cancel the onDragOver.
     * @param {Ext.dd.DragDrop} target The drop target
     * @param {Event} e The event object
     * @param {String} id The id of the dragged element
     * @return {Boolean} isValid True if the drag event is valid, else false to cancel
     */
    beforeDragOver : function(target, e, id){
        return true;
    },

    // private
    onDragOut : function(e, id){
        var target = this.cachedTarget || Ext.dd.DragDropMgr.getDDById(id);
        if(this.beforeDragOut(target, e, id) !== false){
            if(target.isNotifyTarget){
                target.notifyOut(this, e, this.dragData);
            }
            this.proxy.reset();
            if(this.afterDragOut){
                /**
                 * An empty function by default, but provided so that you can perform a custom action
                 * after the dragged item is dragged out of the target without dropping.
                 * @param {Ext.dd.DragDrop} target The drop target
                 * @param {Event} e The event object
                 * @param {String} id The id of the dragged element
                 * @method afterDragOut
                 */
                this.afterDragOut(target, e, id);
            }
        }
        this.cachedTarget = null;
    },

    /**
     * An empty function by default, but provided so that you can perform a custom action before the dragged
     * item is dragged out of the target without dropping, and optionally cancel the onDragOut.
     * @param {Ext.dd.DragDrop} target The drop target
     * @param {Event} e The event object
     * @param {String} id The id of the dragged element
     * @return {Boolean} isValid True if the drag event is valid, else false to cancel
     */
    beforeDragOut : function(target, e, id){
        return true;
    },
    
    // private
    onDragDrop : function(e, id){
        var target = this.cachedTarget || Ext.dd.DragDropMgr.getDDById(id);
        if(this.beforeDragDrop(target, e, id) !== false){
            if(target.isNotifyTarget){
                if(target.notifyDrop(this, e, this.dragData)){ // valid drop?
                    this.onValidDrop(target, e, id);
                }else{
                    this.onInvalidDrop(target, e, id);
                }
            }else{
                this.onValidDrop(target, e, id);
            }
            
            if(this.afterDragDrop){
                /**
                 * An empty function by default, but provided so that you can perform a custom action
                 * after a valid drag drop has occurred by providing an implementation.
                 * @param {Ext.dd.DragDrop} target The drop target
                 * @param {Event} e The event object
                 * @param {String} id The id of the dropped element
                 * @method afterDragDrop
                 */
                this.afterDragDrop(target, e, id);
            }
        }
        delete this.cachedTarget;
    },

    /**
     * An empty function by default, but provided so that you can perform a custom action before the dragged
     * item is dropped onto the target and optionally cancel the onDragDrop.
     * @param {Ext.dd.DragDrop} target The drop target
     * @param {Event} e The event object
     * @param {String} id The id of the dragged element
     * @return {Boolean} isValid True if the drag drop event is valid, else false to cancel
     */
    beforeDragDrop : function(target, e, id){
        return true;
    },

    // private
    onValidDrop : function(target, e, id){
        this.hideProxy();
        if(this.afterValidDrop){
            /**
             * An empty function by default, but provided so that you can perform a custom action
             * after a valid drop has occurred by providing an implementation.
             * @param {Object} target The target DD 
             * @param {Event} e The event object
             * @param {String} id The id of the dropped element
             * @method afterInvalidDrop
             */
            this.afterValidDrop(target, e, id);
        }
    },

    // private
    getRepairXY : function(e, data){
        return this.el.getXY();  
    },

    // private
    onInvalidDrop : function(target, e, id){
        this.beforeInvalidDrop(target, e, id);
        if(this.cachedTarget){
            if(this.cachedTarget.isNotifyTarget){
                this.cachedTarget.notifyOut(this, e, this.dragData);
            }
            this.cacheTarget = null;
        }
        this.proxy.repair(this.getRepairXY(e, this.dragData), this.afterRepair, this);

        if(this.afterInvalidDrop){
            /**
             * An empty function by default, but provided so that you can perform a custom action
             * after an invalid drop has occurred by providing an implementation.
             * @param {Event} e The event object
             * @param {String} id The id of the dropped element
             * @method afterInvalidDrop
             */
            this.afterInvalidDrop(e, id);
        }
    },

    // private
    afterRepair : function(){
        if(Ext.enableFx){
            this.el.highlight(this.hlColor || "c3daf9");
        }
        this.dragging = false;
    },

    /**
     * An empty function by default, but provided so that you can perform a custom action after an invalid
     * drop has occurred.
     * @param {Ext.dd.DragDrop} target The drop target
     * @param {Event} e The event object
     * @param {String} id The id of the dragged element
     * @return {Boolean} isValid True if the invalid drop should proceed, else false to cancel
     */
    beforeInvalidDrop : function(target, e, id){
        return true;
    },

    // private
    handleMouseDown : function(e){
        if(this.dragging) {
            return;
        }
        var data = this.getDragData(e);
        if(data && this.onBeforeDrag(data, e) !== false){
            this.dragData = data;
            this.proxy.stop();
            Ext.dd.DragSource.superclass.handleMouseDown.apply(this, arguments);
        } 
    },

    /**
     * An empty function by default, but provided so that you can perform a custom action before the initial
     * drag event begins and optionally cancel it.
     * @param {Object} data An object containing arbitrary data to be shared with drop targets
     * @param {Event} e The event object
     * @return {Boolean} isValid True if the drag event is valid, else false to cancel
     */
    onBeforeDrag : function(data, e){
        return true;
    },

    /**
     * An empty function by default, but provided so that you can perform a custom action once the initial
     * drag event has begun.  The drag cannot be canceled from this function.
     * @param {Number} x The x position of the click on the dragged object
     * @param {Number} y The y position of the click on the dragged object
     */
    onStartDrag : Ext.emptyFn,

    // private override
    startDrag : function(x, y){
        this.proxy.reset();
        this.dragging = true;
        this.proxy.update("");
        this.onInitDrag(x, y);
        this.proxy.show();
    },

    // private
    onInitDrag : function(x, y){
        var clone = this.el.dom.cloneNode(true);
        clone.id = Ext.id(); // prevent duplicate ids
        this.proxy.update(clone);
        this.onStartDrag(x, y);
        return true;
    },

    /**
     * Returns the drag source's underlying {@link Ext.dd.StatusProxy}
     * @return {Ext.dd.StatusProxy} proxy The StatusProxy
     */
    getProxy : function(){
        return this.proxy;  
    },

    /**
     * Hides the drag source's {@link Ext.dd.StatusProxy}
     */
    hideProxy : function(){
        this.proxy.hide();  
        this.proxy.reset(true);
        this.dragging = false;
    },

    // private
    triggerCacheRefresh : function(){
        Ext.dd.DDM.refreshCache(this.groups);
    },

    // private - override to prevent hiding
    b4EndDrag: function(e) {
    },

    // private - override to prevent moving
    endDrag : function(e){
        this.onEndDrag(this.dragData, e);
    },

    // private
    onEndDrag : function(data, e){
    },
    
    // private - pin to cursor
    autoOffset : function(x, y) {
        this.setDelta(-12, -20);
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
 * @class Ext.dd.ScrollManager
 * <p>Provides automatic scrolling of overflow regions in the page during drag operations.</p>
 * <p>The ScrollManager configs will be used as the defaults for any scroll container registered with it,
 * but you can also override most of the configs per scroll container by adding a 
 * <tt>ddScrollConfig</tt> object to the target element that contains these properties: {@link #hthresh},
 * {@link #vthresh}, {@link #increment} and {@link #frequency}.  Example usage:
 * <pre><code>
var el = Ext.get('scroll-ct');
el.ddScrollConfig = {
    vthresh: 50,
    hthresh: -1,
    frequency: 100,
    increment: 200
};
Ext.dd.ScrollManager.register(el);
</code></pre>
 * <b>Note: This class uses "Point Mode" and is untested in "Intersect Mode".</b>
 * @singleton
 */
Ext.dd.ScrollManager = function(){
    var ddm = Ext.dd.DragDropMgr;
    var els = {};
    var dragEl = null;
    var proc = {};
    
    var onStop = function(e){
        dragEl = null;
        clearProc();
    };
    
    var triggerRefresh = function(){
        if(ddm.dragCurrent){
             ddm.refreshCache(ddm.dragCurrent.groups);
        }
    };
    
    var doScroll = function(){
        if(ddm.dragCurrent){
            var dds = Ext.dd.ScrollManager;
            var inc = proc.el.ddScrollConfig ?
                      proc.el.ddScrollConfig.increment : dds.increment;
            if(!dds.animate){
                if(proc.el.scroll(proc.dir, inc)){
                    triggerRefresh();
                }
            }else{
                proc.el.scroll(proc.dir, inc, true, dds.animDuration, triggerRefresh);
            }
        }
    };
    
    var clearProc = function(){
        if(proc.id){
            clearInterval(proc.id);
        }
        proc.id = 0;
        proc.el = null;
        proc.dir = "";
    };
    
    var startProc = function(el, dir){
        clearProc();
        proc.el = el;
        proc.dir = dir;
        var freq = (el.ddScrollConfig && el.ddScrollConfig.frequency) ? 
                el.ddScrollConfig.frequency : Ext.dd.ScrollManager.frequency;
        proc.id = setInterval(doScroll, freq);
    };
    
    var onFire = function(e, isDrop){
        if(isDrop || !ddm.dragCurrent){ return; }
        var dds = Ext.dd.ScrollManager;
        if(!dragEl || dragEl != ddm.dragCurrent){
            dragEl = ddm.dragCurrent;
            // refresh regions on drag start
            dds.refreshCache();
        }
        
        var xy = Ext.lib.Event.getXY(e);
        var pt = new Ext.lib.Point(xy[0], xy[1]);
        for(var id in els){
            var el = els[id], r = el._region;
            var c = el.ddScrollConfig ? el.ddScrollConfig : dds;
            if(r && r.contains(pt) && el.isScrollable()){
                if(r.bottom - pt.y <= c.vthresh){
                    if(proc.el != el){
                        startProc(el, "down");
                    }
                    return;
                }else if(r.right - pt.x <= c.hthresh){
                    if(proc.el != el){
                        startProc(el, "left");
                    }
                    return;
                }else if(pt.y - r.top <= c.vthresh){
                    if(proc.el != el){
                        startProc(el, "up");
                    }
                    return;
                }else if(pt.x - r.left <= c.hthresh){
                    if(proc.el != el){
                        startProc(el, "right");
                    }
                    return;
                }
            }
        }
        clearProc();
    };
    
    ddm.fireEvents = ddm.fireEvents.createSequence(onFire, ddm);
    ddm.stopDrag = ddm.stopDrag.createSequence(onStop, ddm);
    
    return {
        /**
         * Registers new overflow element(s) to auto scroll
         * @param {Mixed/Array} el The id of or the element to be scrolled or an array of either
         */
        register : function(el){
            if(Ext.isArray(el)){
                for(var i = 0, len = el.length; i < len; i++) {
                	this.register(el[i]);
                }
            }else{
                el = Ext.get(el);
                els[el.id] = el;
            }
        },
        
        /**
         * Unregisters overflow element(s) so they are no longer scrolled
         * @param {Mixed/Array} el The id of or the element to be removed or an array of either
         */
        unregister : function(el){
            if(Ext.isArray(el)){
                for(var i = 0, len = el.length; i < len; i++) {
                	this.unregister(el[i]);
                }
            }else{
                el = Ext.get(el);
                delete els[el.id];
            }
        },
        
        /**
         * The number of pixels from the top or bottom edge of a container the pointer needs to be to
         * trigger scrolling (defaults to 25)
         * @type Number
         */
        vthresh : 25,
        /**
         * The number of pixels from the right or left edge of a container the pointer needs to be to
         * trigger scrolling (defaults to 25)
         * @type Number
         */
        hthresh : 25,

        /**
         * The number of pixels to scroll in each scroll increment (defaults to 50)
         * @type Number
         */
        increment : 100,
        
        /**
         * The frequency of scrolls in milliseconds (defaults to 500)
         * @type Number
         */
        frequency : 500,
        
        /**
         * True to animate the scroll (defaults to true)
         * @type Boolean
         */
        animate: true,
        
        /**
         * The animation duration in seconds - 
         * MUST BE less than Ext.dd.ScrollManager.frequency! (defaults to .4)
         * @type Number
         */
        animDuration: .4,
        
        /**
         * Manually trigger a cache refresh.
         */
        refreshCache : function(){
            for(var id in els){
                if(typeof els[id] == 'object'){ // for people extending the object prototype
                    els[id]._region = els[id].getRegion();
                }
            }
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
 * @class Ext.dd.DropTarget
 * @extends Ext.dd.DDTarget
 * A simple class that provides the basic implementation needed to make any element a drop target that can have
 * draggable items dropped onto it.  The drop has no effect until an implementation of notifyDrop is provided.
 * @constructor
 * @param {Mixed} el The container element
 * @param {Object} config
 */
Ext.dd.DropTarget = function(el, config){
    this.el = Ext.get(el);
    
    Ext.apply(this, config);
    
    if(this.containerScroll){
        Ext.dd.ScrollManager.register(this.el);
    }
    
    Ext.dd.DropTarget.superclass.constructor.call(this, this.el.dom, this.ddGroup || this.group, 
          {isTarget: true});

};

Ext.extend(Ext.dd.DropTarget, Ext.dd.DDTarget, {
    /**
     * @cfg {String} ddGroup
     * A named drag drop group to which this object belongs.  If a group is specified, then this object will only
     * interact with other drag drop objects in the same group (defaults to undefined).
     */
    /**
     * @cfg {String} overClass
     * The CSS class applied to the drop target element while the drag source is over it (defaults to "").
     */
    /**
     * @cfg {String} dropAllowed
     * The CSS class returned to the drag source when drop is allowed (defaults to "x-dd-drop-ok").
     */
    dropAllowed : "x-dd-drop-ok",
    /**
     * @cfg {String} dropNotAllowed
     * The CSS class returned to the drag source when drop is not allowed (defaults to "x-dd-drop-nodrop").
     */
    dropNotAllowed : "x-dd-drop-nodrop",

    // private
    isTarget : true,

    // private
    isNotifyTarget : true,

    /**
     * The function a {@link Ext.dd.DragSource} calls once to notify this drop target that the source is now over the
     * target.  This default implementation adds the CSS class specified by overClass (if any) to the drop element
     * and returns the dropAllowed config value.  This method should be overridden if drop validation is required.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop target
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {String} status The CSS class that communicates the drop status back to the source so that the
     * underlying {@link Ext.dd.StatusProxy} can be updated
     */
    notifyEnter : function(dd, e, data){
        if(this.overClass){
            this.el.addClass(this.overClass);
        }
        return this.dropAllowed;
    },

    /**
     * The function a {@link Ext.dd.DragSource} calls continuously while it is being dragged over the target.
     * This method will be called on every mouse movement while the drag source is over the drop target.
     * This default implementation simply returns the dropAllowed config value.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop target
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {String} status The CSS class that communicates the drop status back to the source so that the
     * underlying {@link Ext.dd.StatusProxy} can be updated
     */
    notifyOver : function(dd, e, data){
        return this.dropAllowed;
    },

    /**
     * The function a {@link Ext.dd.DragSource} calls once to notify this drop target that the source has been dragged
     * out of the target without dropping.  This default implementation simply removes the CSS class specified by
     * overClass (if any) from the drop element.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop target
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     */
    notifyOut : function(dd, e, data){
        if(this.overClass){
            this.el.removeClass(this.overClass);
        }
    },

    /**
     * The function a {@link Ext.dd.DragSource} calls once to notify this drop target that the dragged item has
     * been dropped on it.  This method has no default implementation and returns false, so you must provide an
     * implementation that does something to process the drop event and returns true so that the drag source's
     * repair action does not run.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop target
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {Boolean} True if the drop was valid, else false
     */
    notifyDrop : function(dd, e, data){
        return false;
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
 * @class Ext.dd.DropZone
 * @extends Ext.dd.DropTarget
 * This class provides a container DD instance that proxies for multiple child node targets.<br />
 * By default, this class requires that child nodes accepting drop are registered with {@link Ext.dd.Registry}.
 * @constructor
 * @param {Mixed} el The container element
 * @param {Object} config
 */
Ext.dd.DropZone = function(el, config){
    Ext.dd.DropZone.superclass.constructor.call(this, el, config);
};

Ext.extend(Ext.dd.DropZone, Ext.dd.DropTarget, {
    /**
     * Returns a custom data object associated with the DOM node that is the target of the event.  By default
     * this looks up the event target in the {@link Ext.dd.Registry}, although you can override this method to
     * provide your own custom lookup.
     * @param {Event} e The event
     * @return {Object} data The custom data
     */
    getTargetFromEvent : function(e){
        return Ext.dd.Registry.getTargetFromEvent(e);
    },

    /**
     * Called internally when the DropZone determines that a {@link Ext.dd.DragSource} has entered a drop node
     * that it has registered.  This method has no default implementation and should be overridden to provide
     * node-specific processing if necessary.
     * @param {Object} nodeData The custom data associated with the drop node (this is the same value returned from 
     * {@link #getTargetFromEvent} for this node)
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop zone
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     */
    onNodeEnter : function(n, dd, e, data){
        
    },

    /**
     * Called internally while the DropZone determines that a {@link Ext.dd.DragSource} is over a drop node
     * that it has registered.  The default implementation returns this.dropNotAllowed, so it should be
     * overridden to provide the proper feedback.
     * @param {Object} nodeData The custom data associated with the drop node (this is the same value returned from
     * {@link #getTargetFromEvent} for this node)
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop zone
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {String} status The CSS class that communicates the drop status back to the source so that the
     * underlying {@link Ext.dd.StatusProxy} can be updated
     */
    onNodeOver : function(n, dd, e, data){
        return this.dropAllowed;
    },

    /**
     * Called internally when the DropZone determines that a {@link Ext.dd.DragSource} has been dragged out of
     * the drop node without dropping.  This method has no default implementation and should be overridden to provide
     * node-specific processing if necessary.
     * @param {Object} nodeData The custom data associated with the drop node (this is the same value returned from
     * {@link #getTargetFromEvent} for this node)
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop zone
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     */
    onNodeOut : function(n, dd, e, data){
        
    },

    /**
     * Called internally when the DropZone determines that a {@link Ext.dd.DragSource} has been dropped onto
     * the drop node.  The default implementation returns false, so it should be overridden to provide the
     * appropriate processing of the drop event and return true so that the drag source's repair action does not run.
     * @param {Object} nodeData The custom data associated with the drop node (this is the same value returned from
     * {@link #getTargetFromEvent} for this node)
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop zone
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {Boolean} True if the drop was valid, else false
     */
    onNodeDrop : function(n, dd, e, data){
        return false;
    },

    /**
     * Called internally while the DropZone determines that a {@link Ext.dd.DragSource} is being dragged over it,
     * but not over any of its registered drop nodes.  The default implementation returns this.dropNotAllowed, so
     * it should be overridden to provide the proper feedback if necessary.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop zone
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {String} status The CSS class that communicates the drop status back to the source so that the
     * underlying {@link Ext.dd.StatusProxy} can be updated
     */
    onContainerOver : function(dd, e, data){
        return this.dropNotAllowed;
    },

    /**
     * Called internally when the DropZone determines that a {@link Ext.dd.DragSource} has been dropped on it,
     * but not on any of its registered drop nodes.  The default implementation returns false, so it should be
     * overridden to provide the appropriate processing of the drop event if you need the drop zone itself to
     * be able to accept drops.  It should return true when valid so that the drag source's repair action does not run.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop zone
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {Boolean} True if the drop was valid, else false
     */
    onContainerDrop : function(dd, e, data){
        return false;
    },

    /**
     * The function a {@link Ext.dd.DragSource} calls once to notify this drop zone that the source is now over
     * the zone.  The default implementation returns this.dropNotAllowed and expects that only registered drop
     * nodes can process drag drop operations, so if you need the drop zone itself to be able to process drops
     * you should override this method and provide a custom implementation.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop zone
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {String} status The CSS class that communicates the drop status back to the source so that the
     * underlying {@link Ext.dd.StatusProxy} can be updated
     */
    notifyEnter : function(dd, e, data){
        return this.dropNotAllowed;
    },

    /**
     * The function a {@link Ext.dd.DragSource} calls continuously while it is being dragged over the drop zone.
     * This method will be called on every mouse movement while the drag source is over the drop zone.
     * It will call {@link #onNodeOver} while the drag source is over a registered node, and will also automatically
     * delegate to the appropriate node-specific methods as necessary when the drag source enters and exits
     * registered nodes ({@link #onNodeEnter}, {@link #onNodeOut}). If the drag source is not currently over a
     * registered node, it will call {@link #onContainerOver}.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop zone
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {String} status The CSS class that communicates the drop status back to the source so that the
     * underlying {@link Ext.dd.StatusProxy} can be updated
     */
    notifyOver : function(dd, e, data){
        var n = this.getTargetFromEvent(e);
        if(!n){ // not over valid drop target
            if(this.lastOverNode){
                this.onNodeOut(this.lastOverNode, dd, e, data);
                this.lastOverNode = null;
            }
            return this.onContainerOver(dd, e, data);
        }
        if(this.lastOverNode != n){
            if(this.lastOverNode){
                this.onNodeOut(this.lastOverNode, dd, e, data);
            }
            this.onNodeEnter(n, dd, e, data);
            this.lastOverNode = n;
        }
        return this.onNodeOver(n, dd, e, data);
    },

    /**
     * The function a {@link Ext.dd.DragSource} calls once to notify this drop zone that the source has been dragged
     * out of the zone without dropping.  If the drag source is currently over a registered node, the notification
     * will be delegated to {@link #onNodeOut} for node-specific handling, otherwise it will be ignored.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop target
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag zone
     */
    notifyOut : function(dd, e, data){
        if(this.lastOverNode){
            this.onNodeOut(this.lastOverNode, dd, e, data);
            this.lastOverNode = null;
        }
    },

    /**
     * The function a {@link Ext.dd.DragSource} calls once to notify this drop zone that the dragged item has
     * been dropped on it.  The drag zone will look up the target node based on the event passed in, and if there
     * is a node registered for that event, it will delegate to {@link #onNodeDrop} for node-specific handling,
     * otherwise it will call {@link #onContainerDrop}.
     * @param {Ext.dd.DragSource} source The drag source that was dragged over this drop zone
     * @param {Event} e The event
     * @param {Object} data An object containing arbitrary data supplied by the drag source
     * @return {Boolean} True if the drop was valid, else false
     */
    notifyDrop : function(dd, e, data){
        if(this.lastOverNode){
            this.onNodeOut(this.lastOverNode, dd, e, data);
            this.lastOverNode = null;
        }
        var n = this.getTargetFromEvent(e);
        return n ?
            this.onNodeDrop(n, dd, e, data) :
            this.onContainerDrop(dd, e, data);
    },

    // private
    triggerCacheRefresh : function(){
        Ext.dd.DDM.refreshCache(this.groups);
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
 * @class Ext.dd.DragZone
 * @extends Ext.dd.DragSource
 * This class provides a container DD instance that proxies for multiple child node sources.<br />
 * By default, this class requires that draggable child nodes are registered with {@link Ext.dd.Registry}.
 * @constructor
 * @param {Mixed} el The container element
 * @param {Object} config
 */
Ext.dd.DragZone = function(el, config){
    Ext.dd.DragZone.superclass.constructor.call(this, el, config);
    if(this.containerScroll){
        Ext.dd.ScrollManager.register(this.el);
    }
};

Ext.extend(Ext.dd.DragZone, Ext.dd.DragSource, {
    /**
     * @cfg {Boolean} containerScroll True to register this container with the Scrollmanager
     * for auto scrolling during drag operations.
     */
    /**
     * @cfg {String} hlColor The color to use when visually highlighting the drag source in the afterRepair
     * method after a failed drop (defaults to "c3daf9" - light blue)
     */

    /**
     * Called when a mousedown occurs in this container. Looks in {@link Ext.dd.Registry}
     * for a valid target to drag based on the mouse down. Override this method
     * to provide your own lookup logic (e.g. finding a child by class name). Make sure your returned
     * object has a "ddel" attribute (with an HTML Element) for other functions to work.
     * @param {EventObject} e The mouse down event
     * @return {Object} The dragData
     */
    getDragData : function(e){
        return Ext.dd.Registry.getHandleFromEvent(e);
    },
    
    /**
     * Called once drag threshold has been reached to initialize the proxy element. By default, it clones the
     * this.dragData.ddel
     * @param {Number} x The x position of the click on the dragged object
     * @param {Number} y The y position of the click on the dragged object
     * @return {Boolean} true to continue the drag, false to cancel
     */
    onInitDrag : function(x, y){
        this.proxy.update(this.dragData.ddel.cloneNode(true));
        this.onStartDrag(x, y);
        return true;
    },
    
    /**
     * Called after a repair of an invalid drop. By default, highlights this.dragData.ddel 
     */
    afterRepair : function(){
        if(Ext.enableFx){
            Ext.Element.fly(this.dragData.ddel).highlight(this.hlColor || "c3daf9");
        }
        this.dragging = false;
    },

    /**
     * Called before a repair of an invalid drop to get the XY to animate to. By default returns
     * the XY of this.dragData.ddel
     * @param {EventObject} e The mouse up event
     * @return {Array} The xy location (e.g. [100, 200])
     */
    getRepairXY : function(e){
        return Ext.Element.fly(this.dragData.ddel).getXY();  
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
 * @class Ext.dd.StatusProxy
 * A specialized drag proxy that supports a drop status icon, {@link Ext.Layer} styles and auto-repair.  This is the
 * default drag proxy used by all Ext.dd components.
 * @constructor
 * @param {Object} config
 */
Ext.dd.StatusProxy = function(config){
    Ext.apply(this, config);
    this.id = this.id || Ext.id();
    this.el = new Ext.Layer({
        dh: {
            id: this.id, tag: "div", cls: "x-dd-drag-proxy "+this.dropNotAllowed, children: [
                {tag: "div", cls: "x-dd-drop-icon"},
                {tag: "div", cls: "x-dd-drag-ghost"}
            ]
        }, 
        shadow: !config || config.shadow !== false
    });
    this.ghost = Ext.get(this.el.dom.childNodes[1]);
    this.dropStatus = this.dropNotAllowed;
};

Ext.dd.StatusProxy.prototype = {
    /**
     * @cfg {String} dropAllowed
     * The CSS class to apply to the status element when drop is allowed (defaults to "x-dd-drop-ok").
     */
    dropAllowed : "x-dd-drop-ok",
    /**
     * @cfg {String} dropNotAllowed
     * The CSS class to apply to the status element when drop is not allowed (defaults to "x-dd-drop-nodrop").
     */
    dropNotAllowed : "x-dd-drop-nodrop",

    /**
     * Updates the proxy's visual element to indicate the status of whether or not drop is allowed
     * over the current target element.
     * @param {String} cssClass The css class for the new drop status indicator image
     */
    setStatus : function(cssClass){
        cssClass = cssClass || this.dropNotAllowed;
        if(this.dropStatus != cssClass){
            this.el.replaceClass(this.dropStatus, cssClass);
            this.dropStatus = cssClass;
        }
    },

    /**
     * Resets the status indicator to the default dropNotAllowed value
     * @param {Boolean} clearGhost True to also remove all content from the ghost, false to preserve it
     */
    reset : function(clearGhost){
        this.el.dom.className = "x-dd-drag-proxy " + this.dropNotAllowed;
        this.dropStatus = this.dropNotAllowed;
        if(clearGhost){
            this.ghost.update("");
        }
    },

    /**
     * Updates the contents of the ghost element
     * @param {String/HTMLElement} html The html that will replace the current innerHTML of the ghost element, or a
     * DOM node to append as the child of the ghost element (in which case the innerHTML will be cleared first).
     */
    update : function(html){
        if(typeof html == "string"){
            this.ghost.update(html);
        }else{
            this.ghost.update("");
            html.style.margin = "0";
            this.ghost.dom.appendChild(html);
        }
        var el = this.ghost.dom.firstChild; 
        if(el){
            Ext.fly(el).setStyle(Ext.isIE ? 'styleFloat' : 'cssFloat', 'none');
        }
    },

    /**
     * Returns the underlying proxy {@link Ext.Layer}
     * @return {Ext.Layer} el
    */
    getEl : function(){
        return this.el;
    },

    /**
     * Returns the ghost element
     * @return {Ext.Element} el
     */
    getGhost : function(){
        return this.ghost;
    },

    /**
     * Hides the proxy
     * @param {Boolean} clear True to reset the status and clear the ghost contents, false to preserve them
     */
    hide : function(clear){
        this.el.hide();
        if(clear){
            this.reset(true);
        }
    },

    /**
     * Stops the repair animation if it's currently running
     */
    stop : function(){
        if(this.anim && this.anim.isAnimated && this.anim.isAnimated()){
            this.anim.stop();
        }
    },

    /**
     * Displays this proxy
     */
    show : function(){
        this.el.show();
    },

    /**
     * Force the Layer to sync its shadow and shim positions to the element
     */
    sync : function(){
        this.el.sync();
    },

    /**
     * Causes the proxy to return to its position of origin via an animation.  Should be called after an
     * invalid drop operation by the item being dragged.
     * @param {Array} xy The XY position of the element ([x, y])
     * @param {Function} callback The function to call after the repair is complete
     * @param {Object} scope The scope in which to execute the callback
     */
    repair : function(xy, callback, scope){
        this.callback = callback;
        this.scope = scope;
        if(xy && this.animRepair !== false){
            this.el.addClass("x-dd-drag-repair");
            this.el.hideUnders(true);
            this.anim = this.el.shift({
                duration: this.repairDuration || .5,
                easing: 'easeOut',
                xy: xy,
                stopFx: true,
                callback: this.afterRepair,
                scope: this
            });
        }else{
            this.afterRepair();
        }
    },

    // private
    afterRepair : function(){
        this.hide(true);
        if(typeof this.callback == "function"){
            this.callback.call(this.scope || this);
        }
        this.callback = null;
        this.scope = null;
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
 * @class Ext.dd.Registry
 * Provides easy access to all drag drop components that are registered on a page.  Items can be retrieved either
 * directly by DOM node id, or by passing in the drag drop event that occurred and looking up the event target.
 * @singleton
 */
Ext.dd.Registry = function(){
    var elements = {}; 
    var handles = {}; 
    var autoIdSeed = 0;

    var getId = function(el, autogen){
        if(typeof el == "string"){
            return el;
        }
        var id = el.id;
        if(!id && autogen !== false){
            id = "extdd-" + (++autoIdSeed);
            el.id = id;
        }
        return id;
    };
    
    return {
    /**
     * Resgister a drag drop element
     * @param {String/HTMLElement) element The id or DOM node to register
     * @param {Object} data (optional) An custom data object that will be passed between the elements that are involved
     * in drag drop operations.  You can populate this object with any arbitrary properties that your own code
     * knows how to interpret, plus there are some specific properties known to the Registry that should be
     * populated in the data object (if applicable):
     * <pre>
Value      Description<br />
---------  ------------------------------------------<br />
handles    Array of DOM nodes that trigger dragging<br />
           for the element being registered<br />
isHandle   True if the element passed in triggers<br />
           dragging itself, else false
</pre>
     */
        register : function(el, data){
            data = data || {};
            if(typeof el == "string"){
                el = document.getElementById(el);
            }
            data.ddel = el;
            elements[getId(el)] = data;
            if(data.isHandle !== false){
                handles[data.ddel.id] = data;
            }
            if(data.handles){
                var hs = data.handles;
                for(var i = 0, len = hs.length; i < len; i++){
                	handles[getId(hs[i])] = data;
                }
            }
        },

    /**
     * Unregister a drag drop element
     * @param {String/HTMLElement) element The id or DOM node to unregister
     */
        unregister : function(el){
            var id = getId(el, false);
            var data = elements[id];
            if(data){
                delete elements[id];
                if(data.handles){
                    var hs = data.handles;
                    for(var i = 0, len = hs.length; i < len; i++){
                    	delete handles[getId(hs[i], false)];
                    }
                }
            }
        },

    /**
     * Returns the handle registered for a DOM Node by id
     * @param {String/HTMLElement} id The DOM node or id to look up
     * @return {Object} handle The custom handle data
     */
        getHandle : function(id){
            if(typeof id != "string"){ // must be element?
                id = id.id;
            }
            return handles[id];
        },

    /**
     * Returns the handle that is registered for the DOM node that is the target of the event
     * @param {Event} e The event
     * @return {Object} handle The custom handle data
     */
        getHandleFromEvent : function(e){
            var t = Ext.lib.Event.getTarget(e);
            return t ? handles[t.id] : null;
        },

    /**
     * Returns a custom data object that is registered for a DOM node by id
     * @param {String/HTMLElement} id The DOM node or id to look up
     * @return {Object} data The custom data
     */
        getTarget : function(id){
            if(typeof id != "string"){ // must be element?
                id = id.id;
            }
            return elements[id];
        },

    /**
     * Returns a custom data object that is registered for the DOM node that is the target of the event
     * @param {Event} e The event
     * @return {Object} data The custom data
     */
        getTargetFromEvent : function(e){
            var t = Ext.lib.Event.getTarget(e);
            return t ? elements[t.id] || handles[t.id] : null;
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

Ext.dd.DragTracker = function(config){
    Ext.apply(this, config);
    this.addEvents(
        'mousedown',
        'mouseup',
        'mousemove',
        'dragstart',
        'dragend',
        'drag'
    );

    this.dragRegion = new Ext.lib.Region(0,0,0,0);

    if(this.el){
        this.initEl(this.el);
    }
}

Ext.extend(Ext.dd.DragTracker, Ext.util.Observable,  {
    active: false,
    tolerance: 5,
    autoStart: false,

    initEl: function(el){
        this.el = Ext.get(el);
        el.on('mousedown', this.onMouseDown, this,
                this.delegate ? {delegate: this.delegate} : undefined);
    },

    destroy : function(){
        this.el.un('mousedown', this.onMouseDown, this);
    },

    onMouseDown: function(e, target){
        if(this.fireEvent('mousedown', this, e) !== false && this.onBeforeStart(e) !== false){
            this.startXY = this.lastXY = e.getXY();
            this.dragTarget = this.delegate ? target : this.el.dom;
            e.preventDefault();
            var doc = Ext.getDoc();
            doc.on('mouseup', this.onMouseUp, this);
            doc.on('mousemove', this.onMouseMove, this);
            doc.on('selectstart', this.stopSelect, this);
            if(this.autoStart){
                this.timer = this.triggerStart.defer(this.autoStart === true ? 1000 : this.autoStart, this);
            }
        }
    },

    onMouseMove: function(e, target){
        e.preventDefault();
        var xy = e.getXY(), s = this.startXY;
        this.lastXY = xy;
        if(!this.active){
            if(Math.abs(s[0]-xy[0]) > this.tolerance || Math.abs(s[1]-xy[1]) > this.tolerance){
                this.triggerStart();
            }else{
                return;
            }
        }
        this.fireEvent('mousemove', this, e);
        this.onDrag(e);
        this.fireEvent('drag', this, e);
    },

    onMouseUp: function(e){
        var doc = Ext.getDoc();
        doc.un('mousemove', this.onMouseMove, this);
        doc.un('mouseup', this.onMouseUp, this);
        doc.un('selectstart', this.stopSelect, this);
        e.preventDefault();
        this.clearStart();
        this.active = false;
        delete this.elRegion;
        this.fireEvent('mouseup', this, e);
        this.onEnd(e);
        this.fireEvent('dragend', this, e);
    },

    triggerStart: function(isTimer){
        this.clearStart();
        this.active = true;
        this.onStart(this.startXY);
        this.fireEvent('dragstart', this, this.startXY);
    },

    clearStart : function(){
        if(this.timer){
            clearTimeout(this.timer);
            delete this.timer;
        }
    },

    stopSelect : function(e){
        e.stopEvent();
        return false;
    },

    onBeforeStart : function(e){

    },

    onStart : function(xy){

    },

    onDrag : function(e){

    },

    onEnd : function(e){

    },

    getDragTarget : function(){
        return this.dragTarget;
    },

    getDragCt : function(){
        return this.el;
    },

    getXY : function(constrain){
        return constrain ?
               this.constrainModes[constrain].call(this, this.lastXY) : this.lastXY;
    },

    getOffset : function(constrain){
        var xy = this.getXY(constrain);
        var s = this.startXY;
        return [s[0]-xy[0], s[1]-xy[1]];
    },

    constrainModes: {
        'point' : function(xy){

            if(!this.elRegion){
                this.elRegion = this.getDragCt().getRegion();
            }

            var dr = this.dragRegion;

            dr.left = xy[0];
            dr.top = xy[1];
            dr.right = xy[0];
            dr.bottom = xy[1];

            dr.constrainTo(this.elRegion);

            return [dr.left, dr.top];
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
 * @class Ext.tree.TreeDropZone
 * @extends Ext.dd.DropZone
 * @constructor
 * @param {String/HTMLElement/Element} tree The {@link Ext.tree.TreePanel} for which to enable dropping
 * @param {Object} config
 */
if(Ext.dd.DropZone){
    
Ext.tree.TreeDropZone = function(tree, config){
    /**
     * @cfg {Boolean} allowParentInsert
     * Allow inserting a dragged node between an expanded parent node and its first child that will become a
     * sibling of the parent when dropped (defaults to false)
     */
    this.allowParentInsert = false;
    /**
     * @cfg {String} allowContainerDrop
     * True if drops on the tree container (outside of a specific tree node) are allowed (defaults to false)
     */
    this.allowContainerDrop = false;
    /**
     * @cfg {String} appendOnly
     * True if the tree should only allow append drops (use for trees which are sorted, defaults to false)
     */
    this.appendOnly = false;
    Ext.tree.TreeDropZone.superclass.constructor.call(this, tree.innerCt, config);
    /**
    * The TreePanel for this drop zone
    * @type Ext.tree.TreePanel
    * @property
    */
    this.tree = tree;
    /**
    * Arbitrary data that can be associated with this tree and will be included in the event object that gets
    * passed to any nodedragover event handler (defaults to {})
    * @type Ext.tree.TreePanel
    * @property
    */
    this.dragOverData = {};
    // private
    this.lastInsertClass = "x-tree-no-status";
};

Ext.extend(Ext.tree.TreeDropZone, Ext.dd.DropZone, {
    /**
     * @cfg {String} ddGroup
     * A named drag drop group to which this object belongs.  If a group is specified, then this object will only
     * interact with other drag drop objects in the same group (defaults to 'TreeDD').
     */
    ddGroup : "TreeDD",

    /**
     * @cfg {String} expandDelay
     * The delay in milliseconds to wait before expanding a target tree node while dragging a droppable node
     * over the target (defaults to 1000)
     */
    expandDelay : 1000,

    // private
    expandNode : function(node){
        if(node.hasChildNodes() && !node.isExpanded()){
            node.expand(false, null, this.triggerCacheRefresh.createDelegate(this));
        }
    },

    // private
    queueExpand : function(node){
        this.expandProcId = this.expandNode.defer(this.expandDelay, this, [node]);
    },

    // private
    cancelExpand : function(){
        if(this.expandProcId){
            clearTimeout(this.expandProcId);
            this.expandProcId = false;
        }
    },

    // private
    isValidDropPoint : function(n, pt, dd, e, data){
        if(!n || !data){ return false; }
        var targetNode = n.node;
        var dropNode = data.node;
        // default drop rules
        if(!(targetNode && targetNode.isTarget && pt)){
            return false;
        }
        if(pt == "append" && targetNode.allowChildren === false){
            return false;
        }
        if((pt == "above" || pt == "below") && (targetNode.parentNode && targetNode.parentNode.allowChildren === false)){
            return false;
        }
        if(dropNode && (targetNode == dropNode || dropNode.contains(targetNode))){
            return false;
        }
        // reuse the object
        var overEvent = this.dragOverData;
        overEvent.tree = this.tree;
        overEvent.target = targetNode;
        overEvent.data = data;
        overEvent.point = pt;
        overEvent.source = dd;
        overEvent.rawEvent = e;
        overEvent.dropNode = dropNode;
        overEvent.cancel = false;  
        var result = this.tree.fireEvent("nodedragover", overEvent);
        return overEvent.cancel === false && result !== false;
    },

    // private
    getDropPoint : function(e, n, dd){
        var tn = n.node;
        if(tn.isRoot){
            return tn.allowChildren !== false ? "append" : false; // always append for root
        }
        var dragEl = n.ddel;
        var t = Ext.lib.Dom.getY(dragEl), b = t + dragEl.offsetHeight;
        var y = Ext.lib.Event.getPageY(e);
        var noAppend = tn.allowChildren === false || tn.isLeaf();
        if(this.appendOnly || tn.parentNode.allowChildren === false){
            return noAppend ? false : "append";
        }
        var noBelow = false;
        if(!this.allowParentInsert){
            noBelow = tn.hasChildNodes() && tn.isExpanded();
        }
        var q = (b - t) / (noAppend ? 2 : 3);
        if(y >= t && y < (t + q)){
            return "above";
        }else if(!noBelow && (noAppend || y >= b-q && y <= b)){
            return "below";
        }else{
            return "append";
        }
    },

    // private
    onNodeEnter : function(n, dd, e, data){
        this.cancelExpand();
    },

    // private
    onNodeOver : function(n, dd, e, data){
        var pt = this.getDropPoint(e, n, dd);
        var node = n.node;
        
        // auto node expand check
        if(!this.expandProcId && pt == "append" && node.hasChildNodes() && !n.node.isExpanded()){
            this.queueExpand(node);
        }else if(pt != "append"){
            this.cancelExpand();
        }
        
        // set the insert point style on the target node
        var returnCls = this.dropNotAllowed;
        if(this.isValidDropPoint(n, pt, dd, e, data)){
           if(pt){
               var el = n.ddel;
               var cls;
               if(pt == "above"){
                   returnCls = n.node.isFirst() ? "x-tree-drop-ok-above" : "x-tree-drop-ok-between";
                   cls = "x-tree-drag-insert-above";
               }else if(pt == "below"){
                   returnCls = n.node.isLast() ? "x-tree-drop-ok-below" : "x-tree-drop-ok-between";
                   cls = "x-tree-drag-insert-below";
               }else{
                   returnCls = "x-tree-drop-ok-append";
                   cls = "x-tree-drag-append";
               }
               if(this.lastInsertClass != cls){
                   Ext.fly(el).replaceClass(this.lastInsertClass, cls);
                   this.lastInsertClass = cls;
               }
           }
       }
       return returnCls;
    },

    // private
    onNodeOut : function(n, dd, e, data){
        this.cancelExpand();
        this.removeDropIndicators(n);
    },

    // private
    onNodeDrop : function(n, dd, e, data){
        var point = this.getDropPoint(e, n, dd);
        var targetNode = n.node;
        targetNode.ui.startDrop();
        if(!this.isValidDropPoint(n, point, dd, e, data)){
            targetNode.ui.endDrop();
            return false;
        }
        // first try to find the drop node
        var dropNode = data.node || (dd.getTreeNode ? dd.getTreeNode(data, targetNode, point, e) : null);
        var dropEvent = {
            tree : this.tree,
            target: targetNode,
            data: data,
            point: point,
            source: dd,
            rawEvent: e,
            dropNode: dropNode,
            cancel: !dropNode,
            dropStatus: false
        };
        var retval = this.tree.fireEvent("beforenodedrop", dropEvent);
        if(retval === false || dropEvent.cancel === true || !dropEvent.dropNode){
            targetNode.ui.endDrop();
            return dropEvent.dropStatus;
        }
        // allow target changing
        targetNode = dropEvent.target;
        if(point == "append" && !targetNode.isExpanded()){
            targetNode.expand(false, null, function(){
                this.completeDrop(dropEvent);
            }.createDelegate(this));
        }else{
            this.completeDrop(dropEvent);
        }
        return true;
    },

    // private
    completeDrop : function(de){
        var ns = de.dropNode, p = de.point, t = de.target;
        if(!Ext.isArray(ns)){
            ns = [ns];
        }
        var n;
        for(var i = 0, len = ns.length; i < len; i++){
            n = ns[i];
            if(p == "above"){
                t.parentNode.insertBefore(n, t);
            }else if(p == "below"){
                t.parentNode.insertBefore(n, t.nextSibling);
            }else{
                t.appendChild(n);
            }
        }
        n.ui.focus();
        if(Ext.enableFx && this.tree.hlDrop){
            n.ui.highlight();
        }
        t.ui.endDrop();
        this.tree.fireEvent("nodedrop", de);
    },

    // private
    afterNodeMoved : function(dd, data, e, targetNode, dropNode){
        if(Ext.enableFx && this.tree.hlDrop){
            dropNode.ui.focus();
            dropNode.ui.highlight();
        }
        this.tree.fireEvent("nodedrop", this.tree, targetNode, data, dd, e);
    },

    // private
    getTree : function(){
        return this.tree;
    },

    // private
    removeDropIndicators : function(n){
        if(n && n.ddel){
            var el = n.ddel;
            Ext.fly(el).removeClass([
                    "x-tree-drag-insert-above",
                    "x-tree-drag-insert-below",
                    "x-tree-drag-append"]);
            this.lastInsertClass = "_noclass";
        }
    },

    // private
    beforeDragDrop : function(target, e, id){
        this.cancelExpand();
        return true;
    },

    // private
    afterRepair : function(data){
        if(data && Ext.enableFx){
            data.node.ui.highlight();
        }
        this.hideProxy();
    }    
});

}
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.tree.TreeDragZone
 * @extends Ext.dd.DragZone
 * @constructor
 * @param {String/HTMLElement/Element} tree The {@link Ext.tree.TreePanel} for which to enable dragging
 * @param {Object} config
 */
if(Ext.dd.DragZone){
Ext.tree.TreeDragZone = function(tree, config){
    Ext.tree.TreeDragZone.superclass.constructor.call(this, tree.getTreeEl(), config);
    /**
    * The TreePanel for this drag zone
    * @type Ext.tree.TreePanel
    * @property
    */
    this.tree = tree;
};

Ext.extend(Ext.tree.TreeDragZone, Ext.dd.DragZone, {
    /**
     * @cfg {String} ddGroup
     * A named drag drop group to which this object belongs.  If a group is specified, then this object will only
     * interact with other drag drop objects in the same group (defaults to 'TreeDD').
     */
    ddGroup : "TreeDD",

    // private
    onBeforeDrag : function(data, e){
        var n = data.node;
        return n && n.draggable && !n.disabled;
    },

    // private
    onInitDrag : function(e){
        var data = this.dragData;
        this.tree.getSelectionModel().select(data.node);
        this.tree.eventModel.disable();
        this.proxy.update("");
        data.node.ui.appendDDGhost(this.proxy.ghost.dom);
        this.tree.fireEvent("startdrag", this.tree, data.node, e);
    },

    // private
    getRepairXY : function(e, data){
        return data.node.ui.getDDRepairXY();
    },

    // private
    onEndDrag : function(data, e){
        this.tree.eventModel.enable.defer(100, this.tree.eventModel);
        this.tree.fireEvent("enddrag", this.tree, data.node, e);
    },

    // private
    onValidDrop : function(dd, e, id){
        this.tree.fireEvent("dragdrop", this.tree, this.dragData.node, dd, e);
        this.hideProxy();
    },

    // private
    beforeInvalidDrop : function(e, id){
        // this scrolls the original position back into view
        var sm = this.tree.getSelectionModel();
        sm.clearSelections();
        sm.select(this.dragData.node);
    },
    
    // private
    afterRepair : function(){
        if (Ext.enableFx && this.tree.hlDrop) {
            Ext.Element.fly(this.dragData.ddel).highlight(this.hlColor || "c3daf9");
        }
        this.dragging = false;
    }
});
}
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.Resizable
 * @extends Ext.util.Observable
 * <p>Applies drag handles to an element to make it resizable. The drag handles are inserted into the element 
 * and positioned absolute. Some elements, such as a textarea or image, don't support this. To overcome that, you can wrap
 * the textarea in a div and set "resizeChild" to true (or to the id of the element), <b>or</b> set wrap:true in your config and
 * the element will be wrapped for you automatically.</p>
 * <p>Here is the list of valid resize handles:</p>
 * <pre>
Value   Description
------  -------------------
 'n'     north
 's'     south
 'e'     east
 'w'     west
 'nw'    northwest
 'sw'    southwest
 'se'    southeast
 'ne'    northeast
 'all'   all
</pre>
 * <p>Here's an example showing the creation of a typical Resizable:</p>
 * <pre><code>
var resizer = new Ext.Resizable("element-id", {
    handles: 'all',
    minWidth: 200,
    minHeight: 100,
    maxWidth: 500,
    maxHeight: 400,
    pinned: true
});
resizer.on("resize", myHandler);
</code></pre>
 * <p>To hide a particular handle, set its display to none in CSS, or through script:<br>
 * resizer.east.setDisplayed(false);</p>
 * @cfg {Boolean/String/Element} resizeChild True to resize the first child, or id/element to resize (defaults to false)
 * @cfg {Array/String} adjustments String "auto" or an array [width, height] with values to be <b>added</b> to the
 * resize operation's new size (defaults to [0, 0])
 * @cfg {Number} minWidth The minimum width for the element (defaults to 5)
 * @cfg {Number} minHeight The minimum height for the element (defaults to 5)
 * @cfg {Number} maxWidth The maximum width for the element (defaults to 10000)
 * @cfg {Number} maxHeight The maximum height for the element (defaults to 10000)
 * @cfg {Boolean} enabled False to disable resizing (defaults to true)
 * @cfg {Boolean} wrap True to wrap an element with a div if needed (required for textareas and images, defaults to false)
 * @cfg {Number} width The width of the element in pixels (defaults to null)
 * @cfg {Number} height The height of the element in pixels (defaults to null)
 * @cfg {Boolean} animate True to animate the resize (not compatible with dynamic sizing, defaults to false)
 * @cfg {Number} duration Animation duration if animate = true (defaults to .35)
 * @cfg {Boolean} dynamic True to resize the element while dragging instead of using a proxy (defaults to false)
 * @cfg {String} handles String consisting of the resize handles to display (defaults to undefined)
 * @cfg {Boolean} multiDirectional <b>Deprecated</b>.  The old style of adding multi-direction resize handles, deprecated
 * in favor of the handles config option (defaults to false)
 * @cfg {Boolean} disableTrackOver True to disable mouse tracking. This is only applied at config time. (defaults to false)
 * @cfg {String} easing Animation easing if animate = true (defaults to 'easingOutStrong')
 * @cfg {Number} widthIncrement The increment to snap the width resize in pixels (dynamic must be true, defaults to 0)
 * @cfg {Number} heightIncrement The increment to snap the height resize in pixels (dynamic must be true, defaults to 0)
 * @cfg {Boolean} pinned True to ensure that the resize handles are always visible, false to display them only when the
 * user mouses over the resizable borders. This is only applied at config time. (defaults to false)
 * @cfg {Boolean} preserveRatio True to preserve the original ratio between height and width during resize (defaults to false)
 * @cfg {Boolean} transparent True for transparent handles. This is only applied at config time. (defaults to false)
 * @cfg {Number} minX The minimum allowed page X for the element (only used for west resizing, defaults to 0)
 * @cfg {Number} minY The minimum allowed page Y for the element (only used for north resizing, defaults to 0)
 * @cfg {Boolean} draggable Convenience to initialize drag drop (defaults to false)
 * @constructor
 * Create a new resizable component
 * @param {Mixed} el The id or element to resize
 * @param {Object} config configuration options
  */
Ext.Resizable = function(el, config){
    this.el = Ext.get(el);
    
    if(config && config.wrap){
        config.resizeChild = this.el;
        this.el = this.el.wrap(typeof config.wrap == "object" ? config.wrap : {cls:"xresizable-wrap"});
        this.el.id = this.el.dom.id = config.resizeChild.id + "-rzwrap";
        this.el.setStyle("overflow", "hidden");
        this.el.setPositioning(config.resizeChild.getPositioning());
        config.resizeChild.clearPositioning();
        if(!config.width || !config.height){
            var csize = config.resizeChild.getSize();
            this.el.setSize(csize.width, csize.height);
        }
        if(config.pinned && !config.adjustments){
            config.adjustments = "auto";
        }
    }

    /**
     * The proxy Element that is resized in place of the real Element during the resize operation.
     * This may be queried using {@link Ext.Element#getBox} to provide the new area to resize to.
     * Read only.
     * @type Ext.Element.
     * @property proxy
     */
    this.proxy = this.el.createProxy({tag: "div", cls: "x-resizable-proxy", id: this.el.id + "-rzproxy"}, Ext.getBody());
    this.proxy.unselectable();
    this.proxy.enableDisplayMode('block');

    Ext.apply(this, config);
    
    if(this.pinned){
        this.disableTrackOver = true;
        this.el.addClass("x-resizable-pinned");
    }
    // if the element isn't positioned, make it relative
    var position = this.el.getStyle("position");
    if(position != "absolute" && position != "fixed"){
        this.el.setStyle("position", "relative");
    }
    if(!this.handles){ // no handles passed, must be legacy style
        this.handles = 's,e,se';
        if(this.multiDirectional){
            this.handles += ',n,w';
        }
    }
    if(this.handles == "all"){
        this.handles = "n s e w ne nw se sw";
    }
    var hs = this.handles.split(/\s*?[,;]\s*?| /);
    var ps = Ext.Resizable.positions;
    for(var i = 0, len = hs.length; i < len; i++){
        if(hs[i] && ps[hs[i]]){
            var pos = ps[hs[i]];
            this[pos] = new Ext.Resizable.Handle(this, pos, this.disableTrackOver, this.transparent);
        }
    }
    // legacy
    this.corner = this.southeast;
    
    if(this.handles.indexOf("n") != -1 || this.handles.indexOf("w") != -1){
        this.updateBox = true;
    }   
   
    this.activeHandle = null;
    
    if(this.resizeChild){
        if(typeof this.resizeChild == "boolean"){
            this.resizeChild = Ext.get(this.el.dom.firstChild, true);
        }else{
            this.resizeChild = Ext.get(this.resizeChild, true);
        }
    }
    
    if(this.adjustments == "auto"){
        var rc = this.resizeChild;
        var hw = this.west, he = this.east, hn = this.north, hs = this.south;
        if(rc && (hw || hn)){
            rc.position("relative");
            rc.setLeft(hw ? hw.el.getWidth() : 0);
            rc.setTop(hn ? hn.el.getHeight() : 0);
        }
        this.adjustments = [
            (he ? -he.el.getWidth() : 0) + (hw ? -hw.el.getWidth() : 0),
            (hn ? -hn.el.getHeight() : 0) + (hs ? -hs.el.getHeight() : 0) -1 
        ];
    }
    
    if(this.draggable){
        this.dd = this.dynamic ? 
            this.el.initDD(null) : this.el.initDDProxy(null, {dragElId: this.proxy.id});
        this.dd.setHandleElId(this.resizeChild ? this.resizeChild.id : this.el.id);
    }
    
    // public events
    this.addEvents(
        "beforeresize",
        "resize"
    );
    
    if(this.width !== null && this.height !== null){
        this.resizeTo(this.width, this.height);
    }else{
        this.updateChildSize();
    }
    if(Ext.isIE){
        this.el.dom.style.zoom = 1;
    }
    Ext.Resizable.superclass.constructor.call(this);
};

Ext.extend(Ext.Resizable, Ext.util.Observable, {
        resizeChild : false,
        adjustments : [0, 0],
        minWidth : 5,
        minHeight : 5,
        maxWidth : 10000,
        maxHeight : 10000,
        enabled : true,
        animate : false,
        duration : .35,
        dynamic : false,
        handles : false,
        multiDirectional : false,
        disableTrackOver : false,
        easing : 'easeOutStrong',
        widthIncrement : 0,
        heightIncrement : 0,
        pinned : false,
        width : null,
        height : null,
        preserveRatio : false,
        transparent: false,
        minX: 0,
        minY: 0,
        draggable: false,

        /**
         * @cfg {Mixed} constrainTo Constrain the resize to a particular element
         */
        /**
         * @cfg {Ext.lib.Region} resizeRegion Constrain the resize to a particular region
         */

        /**
         * @event beforeresize
         * Fired before resize is allowed. Set enabled to false to cancel resize.
         * @param {Ext.Resizable} this
         * @param {Ext.EventObject} e The mousedown event
         */
        /**
         * @event resize
         * Fired after a resize.
         * @param {Ext.Resizable} this
         * @param {Number} width The new width
         * @param {Number} height The new height
         * @param {Ext.EventObject} e The mouseup event
         */
    
    /**
     * Perform a manual resize
     * @param {Number} width
     * @param {Number} height
     */
    resizeTo : function(width, height){
        this.el.setSize(width, height);
        this.updateChildSize();
        this.fireEvent("resize", this, width, height, null);
    },

    // private
    startSizing : function(e, handle){
        this.fireEvent("beforeresize", this, e);
        if(this.enabled){ // 2nd enabled check in case disabled before beforeresize handler

            if(!this.overlay){
                this.overlay = this.el.createProxy({tag: "div", cls: "x-resizable-overlay", html: "&#160;"}, Ext.getBody());
                this.overlay.unselectable();
                this.overlay.enableDisplayMode("block");
                this.overlay.on("mousemove", this.onMouseMove, this);
                this.overlay.on("mouseup", this.onMouseUp, this);
            }
            this.overlay.setStyle("cursor", handle.el.getStyle("cursor"));

            this.resizing = true;
            this.startBox = this.el.getBox();
            this.startPoint = e.getXY();
            this.offsets = [(this.startBox.x + this.startBox.width) - this.startPoint[0],
                            (this.startBox.y + this.startBox.height) - this.startPoint[1]];

            this.overlay.setSize(Ext.lib.Dom.getViewWidth(true), Ext.lib.Dom.getViewHeight(true));
            this.overlay.show();

            if(this.constrainTo) {
                var ct = Ext.get(this.constrainTo);
                this.resizeRegion = ct.getRegion().adjust(
                    ct.getFrameWidth('t'),
                    ct.getFrameWidth('l'),
                    -ct.getFrameWidth('b'),
                    -ct.getFrameWidth('r')
                );
            }

            this.proxy.setStyle('visibility', 'hidden'); // workaround display none
            this.proxy.show();
            this.proxy.setBox(this.startBox);
            if(!this.dynamic){
                this.proxy.setStyle('visibility', 'visible');
            }
        }
    },

    // private
    onMouseDown : function(handle, e){
        if(this.enabled){
            e.stopEvent();
            this.activeHandle = handle;
            this.startSizing(e, handle);
        }          
    },

    // private
    onMouseUp : function(e){
        var size = this.resizeElement();
        this.resizing = false;
        this.handleOut();
        this.overlay.hide();
        this.proxy.hide();
        this.fireEvent("resize", this, size.width, size.height, e);
    },

    // private
    updateChildSize : function(){
        if(this.resizeChild){
            var el = this.el;
            var child = this.resizeChild;
            var adj = this.adjustments;
            if(el.dom.offsetWidth){
                var b = el.getSize(true);
                child.setSize(b.width+adj[0], b.height+adj[1]);
            }
            // Second call here for IE
            // The first call enables instant resizing and
            // the second call corrects scroll bars if they
            // exist
            if(Ext.isIE){
                setTimeout(function(){
                    if(el.dom.offsetWidth){
                        var b = el.getSize(true);
                        child.setSize(b.width+adj[0], b.height+adj[1]);
                    }
                }, 10);
            }
        }
    },

    // private
    snap : function(value, inc, min){
        if(!inc || !value) return value;
        var newValue = value;
        var m = value % inc;
        if(m > 0){
            if(m > (inc/2)){
                newValue = value + (inc-m);
            }else{
                newValue = value - m;
            }
        }
        return Math.max(min, newValue);
    },

    /**
     * <p>Performs resizing of the associated Element. This method is called internally by this
     * class, and should not be called by user code.</p>
     * <p>If a Resizable is being used to resize an Element which encapsulates a more complex UI
     * component such as a Panel, this method may be overridden by specifying an implementation
     * as a config option to provide appropriate behaviour at the end of the resize operation on
     * mouseup, for example resizing the Panel, and relaying the Panel's content.</p>
     * <p>The new area to be resized to is available by examining the state of the {@link #proxy}
     * Element. Example:
<pre><code>
new Ext.Panel({
    title: 'Resize me',
    x: 100,
    y: 100,
    renderTo: Ext.getBody(),
    floating: true,
    frame: true,
    width: 400,
    height: 200,
    listeners: {
        render: function(p) {
            new Ext.Resizable(p.getEl(), {
                handles: 'all',
                pinned: true,
                transparent: true,
                resizeElement: function() {
                    var box = this.proxy.getBox();
                    p.updateBox(box);
                    if (p.layout) {
                        p.doLayout();
                    }
                    return box;
                }
           });
       }
    }
}).show();
</code></pre>
     */
    resizeElement : function(){
        var box = this.proxy.getBox();
        if(this.updateBox){
            this.el.setBox(box, false, this.animate, this.duration, null, this.easing);
        }else{
            this.el.setSize(box.width, box.height, this.animate, this.duration, null, this.easing);
        }
        this.updateChildSize();
        if(!this.dynamic){
            this.proxy.hide();
        }
        return box;
    },

    // private
    constrain : function(v, diff, m, mx){
        if(v - diff < m){
            diff = v - m;    
        }else if(v - diff > mx){
            diff = mx - v; 
        }
        return diff;                
    },

    // private
    onMouseMove : function(e){
        if(this.enabled){
            try{// try catch so if something goes wrong the user doesn't get hung

            if(this.resizeRegion && !this.resizeRegion.contains(e.getPoint())) {
                return;
            }

            //var curXY = this.startPoint;
            var curSize = this.curSize || this.startBox;
            var x = this.startBox.x, y = this.startBox.y;
            var ox = x, oy = y;
            var w = curSize.width, h = curSize.height;
            var ow = w, oh = h;
            var mw = this.minWidth, mh = this.minHeight;
            var mxw = this.maxWidth, mxh = this.maxHeight;
            var wi = this.widthIncrement;
            var hi = this.heightIncrement;
            
            var eventXY = e.getXY();
            var diffX = -(this.startPoint[0] - Math.max(this.minX, eventXY[0]));
            var diffY = -(this.startPoint[1] - Math.max(this.minY, eventXY[1]));
            
            var pos = this.activeHandle.position;
            
            switch(pos){
                case "east":
                    w += diffX; 
                    w = Math.min(Math.max(mw, w), mxw);
                    break;
                case "south":
                    h += diffY;
                    h = Math.min(Math.max(mh, h), mxh);
                    break;
                case "southeast":
                    w += diffX; 
                    h += diffY;
                    w = Math.min(Math.max(mw, w), mxw);
                    h = Math.min(Math.max(mh, h), mxh);
                    break;
                case "north":
                    diffY = this.constrain(h, diffY, mh, mxh);
                    y += diffY;
                    h -= diffY;
                    break;
                case "west":
                    diffX = this.constrain(w, diffX, mw, mxw);
                    x += diffX;
                    w -= diffX;
                    break;
                case "northeast":
                    w += diffX; 
                    w = Math.min(Math.max(mw, w), mxw);
                    diffY = this.constrain(h, diffY, mh, mxh);
                    y += diffY;
                    h -= diffY;
                    break;
                case "northwest":
                    diffX = this.constrain(w, diffX, mw, mxw);
                    diffY = this.constrain(h, diffY, mh, mxh);
                    y += diffY;
                    h -= diffY;
                    x += diffX;
                    w -= diffX;
                    break;
               case "southwest":
                    diffX = this.constrain(w, diffX, mw, mxw);
                    h += diffY;
                    h = Math.min(Math.max(mh, h), mxh);
                    x += diffX;
                    w -= diffX;
                    break;
            }
            
            var sw = this.snap(w, wi, mw);
            var sh = this.snap(h, hi, mh);
            if(sw != w || sh != h){
                switch(pos){
                    case "northeast":
                        y -= sh - h;
                    break;
                    case "north":
                        y -= sh - h;
                        break;
                    case "southwest":
                        x -= sw - w;
                    break;
                    case "west":
                        x -= sw - w;
                        break;
                    case "northwest":
                        x -= sw - w;
                        y -= sh - h;
                    break;
                }
                w = sw;
                h = sh;
            }
            
            if(this.preserveRatio){
                switch(pos){
                    case "southeast":
                    case "east":
                        h = oh * (w/ow);
                        h = Math.min(Math.max(mh, h), mxh);
                        w = ow * (h/oh);
                       break;
                    case "south":
                        w = ow * (h/oh);
                        w = Math.min(Math.max(mw, w), mxw);
                        h = oh * (w/ow);
                        break;
                    case "northeast":
                        w = ow * (h/oh);
                        w = Math.min(Math.max(mw, w), mxw);
                        h = oh * (w/ow);
                    break;
                    case "north":
                        var tw = w;
                        w = ow * (h/oh);
                        w = Math.min(Math.max(mw, w), mxw);
                        h = oh * (w/ow);
                        x += (tw - w) / 2;
                        break;
                    case "southwest":
                        h = oh * (w/ow);
                        h = Math.min(Math.max(mh, h), mxh);
                        var tw = w;
                        w = ow * (h/oh);
                        x += tw - w;
                        break;
                    case "west":
                        var th = h;
                        h = oh * (w/ow);
                        h = Math.min(Math.max(mh, h), mxh);
                        y += (th - h) / 2;
                        var tw = w;
                        w = ow * (h/oh);
                        x += tw - w;
                       break;
                    case "northwest":
                        var tw = w;
                        var th = h;
                        h = oh * (w/ow);
                        h = Math.min(Math.max(mh, h), mxh);
                        w = ow * (h/oh);
                        y += th - h;
                         x += tw - w;
                       break;
                        
                }
            }
            this.proxy.setBounds(x, y, w, h);
            if(this.dynamic){
                this.resizeElement();
            }
            }catch(e){}
        }
    },

    // private
    handleOver : function(){
        if(this.enabled){
            this.el.addClass("x-resizable-over");
        }
    },

    // private
    handleOut : function(){
        if(!this.resizing){
            this.el.removeClass("x-resizable-over");
        }
    },
    
    /**
     * Returns the element this component is bound to.
     * @return {Ext.Element}
     */
    getEl : function(){
        return this.el;
    },
    
    /**
     * Returns the resizeChild element (or null).
     * @return {Ext.Element}
     */
    getResizeChild : function(){
        return this.resizeChild;
    },
    
    /**
     * Destroys this resizable. If the element was wrapped and 
     * removeEl is not true then the element remains.
     * @param {Boolean} removeEl (optional) true to remove the element from the DOM
     */
    destroy : function(removeEl){
        this.proxy.remove();
        if(this.overlay){
            this.overlay.removeAllListeners();
            this.overlay.remove();
        }
        var ps = Ext.Resizable.positions;
        for(var k in ps){
            if(typeof ps[k] != "function" && this[ps[k]]){
                var h = this[ps[k]];
                h.el.removeAllListeners();
                h.el.remove();
            }
        }
        if(removeEl){
            this.el.update("");
            this.el.remove();
        }
    },

    syncHandleHeight : function(){
        var h = this.el.getHeight(true);
        if(this.west){
            this.west.el.setHeight(h);
        }
        if(this.east){
            this.east.el.setHeight(h);
        }
    }
});

// private
// hash to map config positions to true positions
Ext.Resizable.positions = {
    n: "north", s: "south", e: "east", w: "west", se: "southeast", sw: "southwest", nw: "northwest", ne: "northeast"
};

// private
Ext.Resizable.Handle = function(rz, pos, disableTrackOver, transparent){
    if(!this.tpl){
        // only initialize the template if resizable is used
        var tpl = Ext.DomHelper.createTemplate(
            {tag: "div", cls: "x-resizable-handle x-resizable-handle-{0}"}
        );
        tpl.compile();
        Ext.Resizable.Handle.prototype.tpl = tpl;
    }
    this.position = pos;
    this.rz = rz;
    this.el = this.tpl.append(rz.el.dom, [this.position], true);
    this.el.unselectable();
    if(transparent){
        this.el.setOpacity(0);
    }
    this.el.on("mousedown", this.onMouseDown, this);
    if(!disableTrackOver){
        this.el.on("mouseover", this.onMouseOver, this);
        this.el.on("mouseout", this.onMouseOut, this);
    }
};

// private
Ext.Resizable.Handle.prototype = {
    afterResize : function(rz){
        // do nothing    
    },
    // private
    onMouseDown : function(e){
        this.rz.onMouseDown(this, e);
    },
    // private
    onMouseOver : function(e){
        this.rz.handleOver(this, e);
    },
    // private
    onMouseOut : function(e){
        this.rz.handleOut(this, e);
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
 * @class Ext.Panel
 * @extends Ext.Container
 * Panel is a container that has specific functionality and structural components that make it the perfect building
 * block for application-oriented user interfaces. The Panel contains bottom and top toolbars, along with separate
 * header, footer and body sections.  It also provides built-in expandable and collapsible behavior, along with a
 * variety of prebuilt tool buttons that can be wired up to provide other customized behavior.  Panels can be easily
 * dropped into any Container or layout, and the layout and rendering pipeline is completely managed by the framework.
 * @constructor
 * @param {Object} config The config object
 */
Ext.Panel = Ext.extend(Ext.Container, {
    /**
     * The Panel's header {@link Ext.Element Element}. Read-only.
     * <p>This Element is used to house the {@link #title} and {@link #tools}</p>
     * @type Ext.Element
     * @property header
     */
    /**
     * The Panel's body {@link Ext.Element Element} which may be used to contain HTML content.
     * The content may be specified in the {@link #html} config, or it may be loaded using the
     * {@link autoLoad} config, or through the Panel's {@link #getUpdater Updater}. Read-only.
     * <p>If this is used to load visible HTML elements in either way, then
     * the Panel may not be used as a Layout for hosting nested Panels.</p>
     * <p>If this Panel is intended to be used as the host of a Layout (See {@link #layout}
     * then the body Element must not be loaded or changed - it is under the control
     * of the Panel's Layout.
     * @type Ext.Element
     * @property body
     */
    /**
     * The Panel's footer {@link Ext.Element Element}. Read-only.
     * <p>This Element is used to house the Panel's {@link #buttons}.</p>
     * @type Ext.Element
     * @property footer
     */
    /**
     * @cfg {Mixed} applyTo
     * The id of the node, a DOM node or an existing Element corresponding to a DIV that is already present in
     * the document that specifies some panel-specific structural markup.  When applyTo is used, constituent parts of
     * the panel can be specified by CSS class name within the main element, and the panel will automatically create those
     * components from that markup. Any required components not specified in the markup will be autogenerated if necessary.
     * The following class names are supported (baseCls will be replaced by {@link #baseCls}):
     * <ul><li>baseCls + '-header'</li>
     * <li>baseCls + '-header-text'</li>
     * <li>baseCls + '-bwrap'</li>
     * <li>baseCls + '-tbar'</li>
     * <li>baseCls + '-body'</li>
     * <li>baseCls + '-bbar'</li>
     * <li>baseCls + '-footer'</li></ul>
     * Using this config, a call to render() is not required.  If applyTo is specified, any value passed for
     * {@link #renderTo} will be ignored and the target element's parent node will automatically be used as the panel's container.
     */
    /**
     * @cfg {Object/Array} tbar
     * The top toolbar of the panel. This can be a {@link Ext.Toolbar} object, a toolbar config, or an array of
     * buttons/button configs to be added to the toolbar.  Note that this is not available as a property after render.
     * To access the top toolbar after render, use {@link #getTopToolbar}.
     */
    /**
     * @cfg {Object/Array} bbar
     * The bottom toolbar of the panel. This can be a {@link Ext.Toolbar} object, a toolbar config, or an array of
     * buttons/button configs to be added to the toolbar.  Note that this is not available as a property after render.
     * To access the bottom toolbar after render, use {@link #getBottomToolbar}.
     */
    /**
     * @cfg {Boolean} header
     * True to create the header element explicitly, false to skip creating it.  By default, when header is not
     * specified, if a {@link #title} is set the header will be created automatically, otherwise it will not.  If
     * a title is set but header is explicitly set to false, the header will not be rendered.
     */
    /**
     * @cfg {Boolean} footer
     * True to create the footer element explicitly, false to skip creating it.  By default, when footer is not
     * specified, if one or more buttons have been added to the panel the footer will be created automatically,
     * otherwise it will not.
     */
    /**
     * @cfg {String} title
     * The title text to display in the panel header (defaults to '').  When a title is specified the header
     * element will automatically be created and displayed unless {@link #header} is explicitly set to false.  If
     * you don't want to specify a title at config time, but you may want one later, you must either specify a
     * non-empty title (a blank space ' ' will do) or header:true so that the container element will get created.
     */
    /**
     * @cfg {Array} buttons
     * An array of {@link Ext.Button}s or {@link Ext.Button} configs used to add buttons to the footer of this panel.
     */
    /**
     * @cfg {Object/String/Function} autoLoad
     * A valid url spec according to the Updater {@link Ext.Updater#update} method.
     * If autoLoad is not null, the panel will attempt to load its contents
     * immediately upon render.<p>
     * The URL will become the default URL for this panel's {@link #body} element,
     * so it may be {@link Ext.Element#refresh refresh}ed at any time.</p>
     */
    /**
     * @cfg {Boolean} frame
     * True to render the panel with custom rounded borders, false to render with plain 1px square borders (defaults to false).
     */
    /**
     * @cfg {Boolean} border
     * True to display the borders of the panel's body element, false to hide them (defaults to true).  By default,
     * the border is a 2px wide inset border, but this can be further altered by setting {@link #bodyBorder} to false.
     */
    /**
     * @cfg {Boolean} bodyBorder
     * True to display an interior border on the body element of the panel, false to hide it (defaults to true).
     * This only applies when {@link #border} == true.  If border == true and bodyBorder == false, the border will display
     * as a 1px wide inset border, giving the entire body element an inset appearance.
     */
    /**
     * @cfg {String/Object/Function} bodyStyle
     * Custom CSS styles to be applied to the body element in the format expected by {@link Ext.Element#applyStyles}
     * (defaults to null).
     */
    /**
     * @cfg {String} iconCls
     * A CSS class that will provide a background image to be used as the header icon (defaults to '').  An example
     * custom icon class would be something like: .my-icon { background: url(../images/my-icon.gif) 0 6px no-repeat !important;}
     */
    /**
     * @cfg {Boolean} collapsible
     * True to make the panel collapsible and have the expand/collapse toggle button automatically rendered into
     * the header tool button area, false to keep the panel statically sized with no button (defaults to false).
     */
    /**
     * @cfg {Array} tools
     * An array of tool button configs to be added to the header tool area. When rendered, each tool is
     * stored as an {@link Ext.Element Element} referenced by a public property called <tt><b></b>tools.<i>&lt;tool-type&gt;</i></tt>
     * <p>Each tool config may contain the following properties:
     * <div class="mdetail-params"><ul>
     * <li><b>id</b> : String<div class="sub-desc"><b>Required.</b> The type
     * of tool to create. Values may be<ul>
     * <li><tt>toggle</tt> (Created by default when {@link #collapsible} is <tt>true</tt>)</li>
     * <li><tt>close</tt></li>
     * <li><tt>minimize</tt></li>
     * <li><tt>maximize</tt></li>
     * <li><tt>restore</tt></li>
     * <li><tt>gear</tt></li>
     * <li><tt>pin</tt></li>
     * <li><tt>unpin</tt></li>
     * <li><tt>right</tt></li>
     * <li><tt>left</tt></li>
     * <li><tt>up</tt></li>
     * <li><tt>down</tt></li>
     * <li><tt>refresh</tt></li>
     * <li><tt>minus</tt></li>
     * <li><tt>plus</tt></li>
     * <li><tt>help</tt></li>
     * <li><tt>search</tt></li>
     * <li><tt>save</tt></li>
     * <li><tt>print</tt></li>
     * </ul></div></li>
     * <li><b>handler</b> : Function<div class="sub-desc"><b>Required.</b> The function to
     * call when clicked. Arguments passed are:<ul>
     * <li><b>event</b> : Ext.EventObject<div class="sub-desc">The click event.</div></li>
     * <li><b>toolEl</b> : Ext.Element<div class="sub-desc">The tool Element.</div></li>
     * <li><b>Panel</b> : Ext.Panel<div class="sub-desc">The host Panel</div></li>
     * </ul></div></li>
     * <li><b>scope</b> : Object<div class="sub-desc">The scope in which to call the handler.</div></li>
     * <li><b>qtip</b> : String/Object<div class="sub-desc">A tip string, or
     * a config argument to {@link Ext.QuickTip#register}</div></li>
     * <li><b>hidden</b> : Boolean<div class="sub-desc">True to initially render hidden.</div></li>
     * <li><b>on</b> : Object<div class="sub-desc">A listener config object specifiying
     * event listeners in the format of an argument to {@link #addListener}</div></li>
     * </ul></div>
     * Example usage:
     * <pre><code>
tools:[{
    id:'refresh',
    qtip: 'Refresh form Data',
    // hidden:true,
    handler: function(event, toolEl, panel){
        // refresh logic
    }
}]
</code></pre>
     * Note that apart from the toggle tool which is provided when a panel is
     * collapsible, these tools only provide the visual button. Any required
     * functionality must be provided by adding handlers that implement the
     * necessary behavior.
     */
    /**
     * @cfg {Boolean} hideCollapseTool
     * True to hide the expand/collapse toggle button when {@link #collapsible} = true, false to display it (defaults to false).
     */
    /**
     * @cfg {Boolean} titleCollapse
     * True to allow expanding and collapsing the panel (when {@link #collapsible} = true) by clicking anywhere in the
     * header bar, false to allow it only by clicking to tool button (defaults to false).
     */
    /**
     * @cfg {Boolean} autoScroll
     * True to use overflow:'auto' on the panel's body element and show scroll bars automatically when necessary,
     * false to clip any overflowing content (defaults to false).
     */
    /**
     * @cfg {Boolean} floating
     * True to float the panel (absolute position it with automatic shimming and shadow), false to display it
     * inline where it is rendered (defaults to false).  Note that by default, setting floating to true will cause the
     * panel to display at negative offsets so that it is hidden -- because the panel is absolute positioned, the
     * position must be set explicitly after render (e.g., myPanel.setPosition(100,100);).  Also, when floating a
     * panel you should always assign a fixed width, otherwise it will be auto width and will expand to fill to the
     * right edge of the viewport.
     */
    /**
     * @cfg {Boolean/String} shadow
     * True (or a valid Ext.Shadow {@link Ext.Shadow#mode} value) to display a shadow behind the panel, false to
     * display no shadow (defaults to 'sides').  Note that this option only applies when floating = true.
     */
    /**
     * @cfg {Number} shadowOffset
     * The number of pixels to offset the shadow if displayed (defaults to 4). Note that this option only applies
     * when floating = true.
     */
    /**
     * @cfg {Boolean} shim
     * False to disable the iframe shim in browsers which need one (defaults to true).  Note that this option
     * only applies when floating = true.
     */
    /**
     * @cfg {String/Object} html
     * An HTML fragment, or a {@link Ext.DomHelper DomHelper} specification to use
     * as the panel's body content (defaults to '').
     */
    /**
     * @cfg {String} contentEl
     * The id of an existing HTML node to use as the panel's body content (defaults to '').
     */
    /**
     * @cfg {Object/Array} keys
     * A KeyMap config object (in the format expected by {@link Ext.KeyMap#addBinding} used to assign custom key
     * handling to this panel (defaults to null).
     */
     /**
       * @cfg {Boolean} draggable
       * <p>True to enable dragging of this Panel (defaults to false).</p>
       * <p>For custom drag/drop implementations, an Ext.Panel.DD
       * config could also be passed in this config instead of true. Ext.Panel.DD is an internal,
       * undocumented class which moves a proxy Element around in place of the Panel's element, but
       * provides no other behaviour during dragging or on drop. It is a subclass of
       * {@link Ext.dd.DragSource}, so behaviour may be added by implementing the interface methods
       * of {@link Ext.dd.DragDrop} eg:
       * <pre><code>
new Ext.Panel({
    title: 'Drag me',
    x: 100,
    y: 100,
    renderTo: Ext.getBody(),
    floating: true,
    frame: true,
    width: 400,
    height: 200,
    draggable: {
//      Config option of Ext.Panel.DD class.
//      It's a floating Panel, so do not show a placeholder proxy in the original position.
        insertProxy: false,

//      Called for each mousemove event while dragging the DD object.
        onDrag : function(e){
//          Record the x,y position of the drag proxy so that we can
//          position the Panel at end of drag.
            var pel = this.proxy.getEl();
            this.x = pel.getLeft(true);
            this.y = pel.getTop(true);

//          Keep the Shadow aligned if there is one.
            var s = this.panel.getEl().shadow;
            if (s) {
                s.realign(this.x, this.y, pel.getWidth(), pel.getHeight());
            }
        },

//      Called on the mouseup event.
        endDrag : function(e){
            this.panel.setPosition(this.x, this.y);
        }
    }
}).show();
</code></pre>
     */
    /**
       * @cfg {String} tabTip
       * Adds a tooltip when mousing over the tab of a Ext.Panel which is an item of a Ext.TabPanel. Ext.QuickTips.init()
       * must be called in order for the tips to render.
     */
    /**
     * @cfg {Boolean} disabled
     * Render this panel disabled (default is false). An important note when using the disabled config on panels is
     * that IE will often fail to initialize the disabled mask element correectly if the panel's layout has not yet 
     * completed by the time the Panel is disabled during the render process. If you experience this issue, you may 
     * need to instead use the {@link afterlayout} event to initialize the disabled state:
     * <pre><code>
new Ext.Panel({
    ...
    listeners: {
        'afterlayout': {
            fn: function(p){
                p.disable();
            },
            single: true // important, as many layouts can occur
        }
    }
});
</code></pre>
     */
    

    /**
    * @cfg {String} baseCls
    * The base CSS class to apply to this panel's element (defaults to 'x-panel').
    */
    baseCls : 'x-panel',
    /**
    * @cfg {String} collapsedCls
    * A CSS class to add to the panel's element after it has been collapsed (defaults to 'x-panel-collapsed').
    */
    collapsedCls : 'x-panel-collapsed',
    /**
    * @cfg {Boolean} maskDisabled
    * True to mask the panel when it is disabled, false to not mask it (defaults to true).  Either way, the panel
    * will always tell its contained elements to disable themselves when it is disabled, but masking the panel
    * can provide an additional visual cue that the panel is disabled.
    */
    maskDisabled: true,
    /**
    * @cfg {Boolean} animCollapse
    * True to animate the transition when the panel is collapsed, false to skip the animation (defaults to true
    * if the {@link Ext.Fx} class is available, otherwise false).
    */
    animCollapse: Ext.enableFx,
    /**
    * @cfg {Boolean} headerAsText
    * True to display the panel title in the header, false to hide it (defaults to true).
    */
    headerAsText: true,
    /**
    * @cfg {String} buttonAlign
    * The alignment of any buttons added to this panel.  Valid values are 'right,' 'left' and 'center' (defaults to 'right').
    */
    buttonAlign: 'right',
    /**
     * @cfg {Boolean} collapsed
     * True to render the panel collapsed, false to render it expanded (defaults to false).
     */
    collapsed : false,
    /**
    * @cfg {Boolean} collapseFirst
    * True to make sure the collapse/expand toggle button always renders first (to the left of) any other tools
    * in the panel's title bar, false to render it last (defaults to true).
    */
    collapseFirst: true,
    /**
     * @cfg {Number} minButtonWidth
     * Minimum width in pixels of all buttons in this panel (defaults to 75)
     */
    minButtonWidth:75,
    /**
     * @cfg {String} elements
     * A comma-delimited list of panel elements to initialize when the panel is rendered.  Normally, this list will be
     * generated automatically based on the items added to the panel at config time, but sometimes it might be useful to
     * make sure a structural element is rendered even if not specified at config time (for example, you may want
     * to add a button or toolbar dynamically after the panel has been rendered).  Adding those elements to this
     * list will allocate the required placeholders in the panel when it is rendered.  Valid values are<ul>
     * <li><b>header</b></li>
     * <li><b>tbar</b> (top bar)</li>
     * <li><b>body</b> (required)</li>
     * <li><b>bbar</b> (bottom bar)</li>
     * <li><b>footer</b><li>
     * </ul>
     * Defaults to 'body'.
     */
    elements : 'body',

    // protected - these could be used to customize the behavior of the window,
    // but changing them would not be useful without further mofifications and
    // could lead to unexpected or undesirable results.
    toolTarget : 'header',
    collapseEl : 'bwrap',
    slideAnchor : 't',
    disabledClass: '',

    // private, notify box this class will handle heights
    deferHeight: true,
    // private
    expandDefaults: {
        duration:.25
    },
    // private
    collapseDefaults: {
        duration:.25
    },

    // private
    initComponent : function(){
        Ext.Panel.superclass.initComponent.call(this);

        this.addEvents(
            /**
             * @event bodyresize
             * Fires after the Panel has been resized.
             * @param {Ext.Panel} p the Panel which has been resized.
             * @param {Number} width The Panel's new width.
             * @param {Number} height The Panel's new height.
             */
            'bodyresize',
            /**
             * @event titlechange
             * Fires after the Panel title has been set or changed.
             * @param {Ext.Panel} p the Panel which has had its title changed.
             * @param {String} The new title.
             */
            'titlechange',
            /**
             * @event collapse
             * Fires after the Panel has been collapsed.
             * @param {Ext.Panel} p the Panel that has been collapsed.
             */
            'collapse',
            /**
             * @event expand
             * Fires after the Panel has been expanded.
             * @param {Ext.Panel} p The Panel that has been expanded.
             */
            'expand',
            /**
             * @event beforecollapse
             * Fires before the Panel is collapsed.  A handler can return false to cancel the collapse.
             * @param {Ext.Panel} p the Panel being collapsed.
             * @param {Boolean} animate True if the collapse is animated, else false.
             */
            'beforecollapse',
            /**
             * @event beforeexpand
             * Fires before the Panel is expanded.  A handler can return false to cancel the expand.
             * @param {Ext.Panel} p The Panel being expanded.
             * @param {Boolean} animate True if the expand is animated, else false.
             */
            'beforeexpand',
            /**
             * @event beforeclose
             * Fires before the Panel is closed.  Note that Panels do not directly support being closed, but some
             * Panel subclasses do (like {@link Ext.Window}).  This event only applies to such subclasses.
             * A handler can return false to cancel the close.
             * @param {Ext.Panel} p The Panel being closed.
             */
            'beforeclose',
            /**
             * @event close
             * Fires after the Panel is closed.  Note that Panels do not directly support being closed, but some
             * Panel subclasses do (like {@link Ext.Window}).
             * @param {Ext.Panel} p The Panel that has been closed.
             */
            'close',
            /**
             * @event activate
             * Fires after the Panel has been visually activated.
             * Note that Panels do not directly support being activated, but some Panel subclasses
             * do (like {@link Ext.Window}). Panels which are child Components of a TabPanel fire the
             * activate and deactivate events under the control of the TabPanel.
             * @param {Ext.Panel} p The Panel that has been activated.
             */
            'activate',
            /**
             * @event deactivate
             * Fires after the Panel has been visually deactivated.
             * Note that Panels do not directly support being deactivated, but some Panel subclasses
             * do (like {@link Ext.Window}). Panels which are child Components of a TabPanel fire the
             * activate and deactivate events under the control of the TabPanel.
             * @param {Ext.Panel} p The Panel that has been deactivated.
             */
            'deactivate'
        );

        // shortcuts
        if(this.tbar){
            this.elements += ',tbar';
            if(typeof this.tbar == 'object'){
                this.topToolbar = this.tbar;
            }
            delete this.tbar;
        }
        if(this.bbar){
            this.elements += ',bbar';
            if(typeof this.bbar == 'object'){
                this.bottomToolbar = this.bbar;
            }
            delete this.bbar;
        }

        if(this.header === true){
            this.elements += ',header';
            delete this.header;
        }else if(this.title && this.header !== false){
            this.elements += ',header';
        }

        if(this.footer === true){
            this.elements += ',footer';
            delete this.footer;
        }

        if(this.buttons){
            var btns = this.buttons;
            /**
             * This Panel's Array of buttons as created from the <tt>buttons</tt>
             * config property. Read only.
             * @type Array
             * @property buttons
             */
            this.buttons = [];
            for(var i = 0, len = btns.length; i < len; i++) {
                if(btns[i].render){ // button instance
                    btns[i].ownerCt = this;
                    this.buttons.push(btns[i]);
                }else{
                    this.addButton(btns[i]);
                }
            }
        }
        if(this.autoLoad){
            this.on('render', this.doAutoLoad, this, {delay:10});
        }
    },

    // private
    createElement : function(name, pnode){
        if(this[name]){
            pnode.appendChild(this[name].dom);
            return;
        }

        if(name === 'bwrap' || this.elements.indexOf(name) != -1){
            if(this[name+'Cfg']){
                this[name] = Ext.fly(pnode).createChild(this[name+'Cfg']);
            }else{
                var el = document.createElement('div');
                el.className = this[name+'Cls'];
                this[name] = Ext.get(pnode.appendChild(el));
            }
        }
    },

    // private
    onRender : function(ct, position){
        Ext.Panel.superclass.onRender.call(this, ct, position);

        this.createClasses();

        if(this.el){ // existing markup
            this.el.addClass(this.baseCls);
            this.header = this.el.down('.'+this.headerCls);
            this.bwrap = this.el.down('.'+this.bwrapCls);
            var cp = this.bwrap ? this.bwrap : this.el;
            this.tbar = cp.down('.'+this.tbarCls);
            this.body = cp.down('.'+this.bodyCls);
            this.bbar = cp.down('.'+this.bbarCls);
            this.footer = cp.down('.'+this.footerCls);
            this.fromMarkup = true;
        }else{
            this.el = ct.createChild({
                id: this.id,
                cls: this.baseCls
            }, position);
        }
        var el = this.el, d = el.dom;

        if(this.cls){
            this.el.addClass(this.cls);
        }

        if(this.buttons){
            this.elements += ',footer';
        }

        // This block allows for maximum flexibility and performance when using existing markup

        // framing requires special markup
        if(this.frame){
            el.insertHtml('afterBegin', String.format(Ext.Element.boxMarkup, this.baseCls));

            this.createElement('header', d.firstChild.firstChild.firstChild);
            this.createElement('bwrap', d);

            // append the mid and bottom frame to the bwrap
            var bw = this.bwrap.dom;
            var ml = d.childNodes[1], bl = d.childNodes[2];
            bw.appendChild(ml);
            bw.appendChild(bl);

            var mc = bw.firstChild.firstChild.firstChild;
            this.createElement('tbar', mc);
            this.createElement('body', mc);
            this.createElement('bbar', mc);
            this.createElement('footer', bw.lastChild.firstChild.firstChild);

            if(!this.footer){
                this.bwrap.dom.lastChild.className += ' x-panel-nofooter';
            }
        }else{
            this.createElement('header', d);
            this.createElement('bwrap', d);

            // append the mid and bottom frame to the bwrap
            var bw = this.bwrap.dom;
            this.createElement('tbar', bw);
            this.createElement('body', bw);
            this.createElement('bbar', bw);
            this.createElement('footer', bw);

            if(!this.header){
                this.body.addClass(this.bodyCls + '-noheader');
                if(this.tbar){
                    this.tbar.addClass(this.tbarCls + '-noheader');
                }
            }
        }

        if(this.border === false){
            this.el.addClass(this.baseCls + '-noborder');
            this.body.addClass(this.bodyCls + '-noborder');
            if(this.header){
                this.header.addClass(this.headerCls + '-noborder');
            }
            if(this.footer){
                this.footer.addClass(this.footerCls + '-noborder');
            }
            if(this.tbar){
                this.tbar.addClass(this.tbarCls + '-noborder');
            }
            if(this.bbar){
                this.bbar.addClass(this.bbarCls + '-noborder');
            }
        }

        if(this.bodyBorder === false){
           this.body.addClass(this.bodyCls + '-noborder');
        }

        if(this.bodyStyle){
           this.body.applyStyles(this.bodyStyle);
        }

        this.bwrap.enableDisplayMode('block');

        if(this.header){
            this.header.unselectable();

            // for tools, we need to wrap any existing header markup
            if(this.headerAsText){
                this.header.dom.innerHTML =
                    '<span class="' + this.headerTextCls + '">'+this.header.dom.innerHTML+'</span>';

                if(this.iconCls){
                    this.setIconClass(this.iconCls);
                }
            }
        }

        if(this.floating){
            this.makeFloating(this.floating);
        }

        if(this.collapsible){
            this.tools = this.tools ? this.tools.slice(0) : [];
            if(!this.hideCollapseTool){
                this.tools[this.collapseFirst?'unshift':'push']({
                    id: 'toggle',
                    handler : this.toggleCollapse,
                    scope: this
                });
            }
            if(this.titleCollapse && this.header){
                this.header.on('click', this.toggleCollapse, this);
                this.header.setStyle('cursor', 'pointer');
            }
        }
        if(this.tools){
            var ts = this.tools;
            this.tools = {};
            this.addTool.apply(this, ts);
        }else{
            this.tools = {};
        }

        if(this.buttons && this.buttons.length > 0){
            // tables are required to maintain order and for correct IE layout
            var tb = this.footer.createChild({cls:'x-panel-btns-ct', cn: {
                cls:"x-panel-btns x-panel-btns-"+this.buttonAlign,
                html:'<table cellspacing="0"><tbody><tr></tr></tbody></table><div class="x-clear"></div>'
            }}, null, true);
            var tr = tb.getElementsByTagName('tr')[0];
            for(var i = 0, len = this.buttons.length; i < len; i++) {
                var b = this.buttons[i];
                var td = document.createElement('td');
                td.className = 'x-panel-btn-td';
                b.render(tr.appendChild(td));
            }
        }

        if(this.tbar && this.topToolbar){
            if(Ext.isArray(this.topToolbar)){
                this.topToolbar = new Ext.Toolbar(this.topToolbar);
            }
            this.topToolbar.render(this.tbar);
            this.topToolbar.ownerCt = this;
        }
        if(this.bbar && this.bottomToolbar){
            if(Ext.isArray(this.bottomToolbar)){
                this.bottomToolbar = new Ext.Toolbar(this.bottomToolbar);
            }
            this.bottomToolbar.render(this.bbar);
            this.bottomToolbar.ownerCt = this;
        }
    },

    /**
     * Sets the CSS class that provides the icon image for this panel.  This method will replace any existing
     * icon class if one has already been set.
     * @param {String} cls The new CSS class name
     */
    setIconClass : function(cls){
        var old = this.iconCls;
        this.iconCls = cls;
        if(this.rendered && this.header){
            if(this.frame){
                this.header.addClass('x-panel-icon');
                this.header.replaceClass(old, this.iconCls);
            }else{
                var hd = this.header.dom;
                var img = hd.firstChild && String(hd.firstChild.tagName).toLowerCase() == 'img' ? hd.firstChild : null;
                if(img){
                    Ext.fly(img).replaceClass(old, this.iconCls);
                }else{
                    Ext.DomHelper.insertBefore(hd.firstChild, {
                        tag:'img', src: Ext.BLANK_IMAGE_URL, cls:'x-panel-inline-icon '+this.iconCls
                    });
                 }
            }
        }
    },

    // private
    makeFloating : function(cfg){
        this.floating = true;
        this.el = new Ext.Layer(
            typeof cfg == 'object' ? cfg : {
                shadow: this.shadow !== undefined ? this.shadow : 'sides',
                shadowOffset: this.shadowOffset,
                constrain:false,
                shim: this.shim === false ? false : undefined
            }, this.el
        );
    },

    /**
     * Returns the toolbar from the top (tbar) section of the panel.
     * @return {Ext.Toolbar} The toolbar
     */
    getTopToolbar : function(){
        return this.topToolbar;
    },

    /**
     * Returns the toolbar from the bottom (bbar) section of the panel.
     * @return {Ext.Toolbar} The toolbar
     */
    getBottomToolbar : function(){
        return this.bottomToolbar;
    },

    /**
     * Adds a button to this panel.  Note that this method must be called prior to rendering.  The preferred
     * approach is to add buttons via the {@link #buttons} config.
     * @param {String/Object} config A valid {@link Ext.Button} config.  A string will become the text for a default
     * button config, an object will be treated as a button config object.
     * @param {Function} handler The function to be called on button {@link Ext.Button#click}
     * @param {Object} scope The scope to use for the button handler function
     * @return {Ext.Button} The button that was added
     */
    addButton : function(config, handler, scope){
        var bc = {
            handler: handler,
            scope: scope,
            minWidth: this.minButtonWidth,
            hideParent:true
        };
        if(typeof config == "string"){
            bc.text = config;
        }else{
            Ext.apply(bc, config);
        }
        var btn = new Ext.Button(bc);
        btn.ownerCt = this;
        if(!this.buttons){
            this.buttons = [];
        }
        this.buttons.push(btn);
        return btn;
    },

    // private
    addTool : function(){
        if(!this[this.toolTarget]) { // no where to render tools!
            return;
        }
        if(!this.toolTemplate){
            // initialize the global tool template on first use
            var tt = new Ext.Template(
                 '<div class="x-tool x-tool-{id}">&#160;</div>'
            );
            tt.disableFormats = true;
            tt.compile();
            Ext.Panel.prototype.toolTemplate = tt;
        }
        for(var i = 0, a = arguments, len = a.length; i < len; i++) {
            var tc = a[i], overCls = 'x-tool-'+tc.id+'-over';
            var t = this.toolTemplate.insertFirst((tc.align !== 'left') ? this[this.toolTarget] : this[this.toolTarget].child('span'), tc, true);
            this.tools[tc.id] = t;
            t.enableDisplayMode('block');
            t.on('click', this.createToolHandler(t, tc, overCls, this));
            if(tc.on){
                t.on(tc.on);
            }
            if(tc.hidden){
                t.hide();
            }
            if(tc.qtip){
                if(typeof tc.qtip == 'object'){
                    Ext.QuickTips.register(Ext.apply({
                          target: t.id
                    }, tc.qtip));
                } else {
                    t.dom.qtip = tc.qtip;
                }
            }
            t.addClassOnOver(overCls);
        }
    },

    // private
    onShow : function(){
        if(this.floating){
            return this.el.show();
        }
        Ext.Panel.superclass.onShow.call(this);
    },

    // private
    onHide : function(){
        if(this.floating){
            return this.el.hide();
        }
        Ext.Panel.superclass.onHide.call(this);
    },

    // private
    createToolHandler : function(t, tc, overCls, panel){
        return function(e){
            t.removeClass(overCls);
            e.stopEvent();
            if(tc.handler){
                tc.handler.call(tc.scope || t, e, t, panel);
            }
        };
    },

    // private
    afterRender : function(){
        if(this.fromMarkup && this.height === undefined && !this.autoHeight){
            this.height = this.el.getHeight();
        }
        if(this.floating && !this.hidden && !this.initHidden){
            this.el.show();
        }
        if(this.title){
            this.setTitle(this.title);
        }
        this.setAutoScroll();
        if(this.html){
            this.body.update(typeof this.html == 'object' ?
                             Ext.DomHelper.markup(this.html) :
                             this.html);
            delete this.html;
        }
        if(this.contentEl){
            var ce = Ext.getDom(this.contentEl);
            Ext.fly(ce).removeClass(['x-hidden', 'x-hide-display']);
            this.body.dom.appendChild(ce);
        }
        if(this.collapsed){
            this.collapsed = false;
            this.collapse(false);
        }
        Ext.Panel.superclass.afterRender.call(this); // do sizing calcs last
        this.initEvents();
    },

    // private
    setAutoScroll : function(){
        if(this.rendered && this.autoScroll){
            var el = this.body || this.el;
            if(el){
                el.setOverflow('auto');
            }
        }
    },

    // private
    getKeyMap : function(){
        if(!this.keyMap){
            this.keyMap = new Ext.KeyMap(this.el, this.keys);
        }
        return this.keyMap;
    },

    // private
    initEvents : function(){
        if(this.keys){
            this.getKeyMap();
        }
        if(this.draggable){
            this.initDraggable();
        }
    },

    // private
    initDraggable : function(){
        /**
         * <p>If this Panel is configured {@link #draggable}, this property will contain
         * an instance of {@link Ext.dd.DragSource} which handles dragging the Panel.</p>
         * The developer must provide implementations of the abstract methods of {@link Ext.dd.DragSource}
         * in order to supply behaviour for each stage of the drag/drop process. See {@link #draggable}.
         * @type Ext.dd.DragSource.
         * @property dd
         */
        this.dd = new Ext.Panel.DD(this, typeof this.draggable == 'boolean' ? null : this.draggable);
    },

    // private
    beforeEffect : function(){
        if(this.floating){
            this.el.beforeAction();
        }
        this.el.addClass('x-panel-animated');
    },

    // private
    afterEffect : function(){
        this.syncShadow();
        this.el.removeClass('x-panel-animated');
    },

    // private - wraps up an animation param with internal callbacks
    createEffect : function(a, cb, scope){
        var o = {
            scope:scope,
            block:true
        };
        if(a === true){
            o.callback = cb;
            return o;
        }else if(!a.callback){
            o.callback = cb;
        }else { // wrap it up
            o.callback = function(){
                cb.call(scope);
                Ext.callback(a.callback, a.scope);
            };
        }
        return Ext.applyIf(o, a);
    },

    /**
     * Collapses the panel body so that it becomes hidden.  Fires the {@link #beforecollapse} event which will
     * cancel the collapse action if it returns false.
     * @param {Boolean} animate True to animate the transition, else false (defaults to the value of the
     * {@link #animCollapse} panel config)
     * @return {Ext.Panel} this
     */
    collapse : function(animate){
        if(this.collapsed || this.el.hasFxBlock() || this.fireEvent('beforecollapse', this, animate) === false){
            return;
        }
        var doAnim = animate === true || (animate !== false && this.animCollapse);
        this.beforeEffect();
        this.onCollapse(doAnim, animate);
        return this;
    },

    // private
    onCollapse : function(doAnim, animArg){
        if(doAnim){
            this[this.collapseEl].slideOut(this.slideAnchor,
                    Ext.apply(this.createEffect(animArg||true, this.afterCollapse, this),
                        this.collapseDefaults));
        }else{
            this[this.collapseEl].hide();
            this.afterCollapse();
        }
    },

    // private
    afterCollapse : function(){
        this.collapsed = true;
        this.el.addClass(this.collapsedCls);
        this.afterEffect();
        this.fireEvent('collapse', this);
    },

    /**
     * Expands the panel body so that it becomes visible.  Fires the {@link #beforeexpand} event which will
     * cancel the expand action if it returns false.
     * @param {Boolean} animate True to animate the transition, else false (defaults to the value of the
     * {@link #animCollapse} panel config)
     * @return {Ext.Panel} this
     */
    expand : function(animate){
        if(!this.collapsed || this.el.hasFxBlock() || this.fireEvent('beforeexpand', this, animate) === false){
            return;
        }
        var doAnim = animate === true || (animate !== false && this.animCollapse);
        this.el.removeClass(this.collapsedCls);
        this.beforeEffect();
        this.onExpand(doAnim, animate);
        return this;
    },

    // private
    onExpand : function(doAnim, animArg){
        if(doAnim){
            this[this.collapseEl].slideIn(this.slideAnchor,
                    Ext.apply(this.createEffect(animArg||true, this.afterExpand, this),
                        this.expandDefaults));
        }else{
            this[this.collapseEl].show();
            this.afterExpand();
        }
    },

    // private
    afterExpand : function(){
        this.collapsed = false;
        this.afterEffect();
        this.fireEvent('expand', this);
    },

    /**
     * Shortcut for performing an {@link #expand} or {@link #collapse} based on the current state of the panel.
     * @param {Boolean} animate True to animate the transition, else false (defaults to the value of the
     * {@link #animCollapse} panel config)
     * @return {Ext.Panel} this
     */
    toggleCollapse : function(animate){
        this[this.collapsed ? 'expand' : 'collapse'](animate);
        return this;
    },

    // private
    onDisable : function(){
        if(this.rendered && this.maskDisabled){
            this.el.mask();
        }
        Ext.Panel.superclass.onDisable.call(this);
    },

    // private
    onEnable : function(){
        if(this.rendered && this.maskDisabled){
            this.el.unmask();
        }
        Ext.Panel.superclass.onEnable.call(this);
    },

    // private
    onResize : function(w, h){
        if(w !== undefined || h !== undefined){
            if(!this.collapsed){
                if(typeof w == 'number'){
                    this.body.setWidth(
                            this.adjustBodyWidth(w - this.getFrameWidth()));
                }else if(w == 'auto'){
                    this.body.setWidth(w);
                }

                if(typeof h == 'number'){
                    this.body.setHeight(
                            this.adjustBodyHeight(h - this.getFrameHeight()));
                }else if(h == 'auto'){
                    this.body.setHeight(h);
                }
                
                if(this.disabled && this.el._mask){
                    this.el._mask.setSize(this.el.dom.clientWidth, this.el.getHeight());
                }
            }else{
                this.queuedBodySize = {width: w, height: h};
                if(!this.queuedExpand && this.allowQueuedExpand !== false){
                    this.queuedExpand = true;
                    this.on('expand', function(){
                        delete this.queuedExpand;
                        this.onResize(this.queuedBodySize.width, this.queuedBodySize.height);
                        this.doLayout();
                    }, this, {single:true});
                }
            }
            this.fireEvent('bodyresize', this, w, h);
        }
        this.syncShadow();
    },

    // private
    adjustBodyHeight : function(h){
        return h;
    },

    // private
    adjustBodyWidth : function(w){
        return w;
    },

    // private
    onPosition : function(){
        this.syncShadow();
    },

    /**
     * Returns the width in pixels of the framing elements of this panel (not including the body width).  To
     * retrieve the body width see {@link #getInnerWidth}.
     * @return {Number} The frame width
     */
    getFrameWidth : function(){
        var w = this.el.getFrameWidth('lr');

        if(this.frame){
            var l = this.bwrap.dom.firstChild;
            w += (Ext.fly(l).getFrameWidth('l') + Ext.fly(l.firstChild).getFrameWidth('r'));
            var mc = this.bwrap.dom.firstChild.firstChild.firstChild;
            w += Ext.fly(mc).getFrameWidth('lr');
        }
        return w;
    },

    /**
     * Returns the height in pixels of the framing elements of this panel (including any top and bottom bars and
     * header and footer elements, but not including the body height).  To retrieve the body height see {@link #getInnerHeight}.
     * @return {Number} The frame height
     */
    getFrameHeight : function(){
        var h  = this.el.getFrameWidth('tb');
        h += (this.tbar ? this.tbar.getHeight() : 0) +
             (this.bbar ? this.bbar.getHeight() : 0);

        if(this.frame){
            var hd = this.el.dom.firstChild;
            var ft = this.bwrap.dom.lastChild;
            h += (hd.offsetHeight + ft.offsetHeight);
            var mc = this.bwrap.dom.firstChild.firstChild.firstChild;
            h += Ext.fly(mc).getFrameWidth('tb');
        }else{
            h += (this.header ? this.header.getHeight() : 0) +
                (this.footer ? this.footer.getHeight() : 0);
        }
        return h;
    },

    /**
     * Returns the width in pixels of the body element (not including the width of any framing elements).
     * For the frame width see {@link #getFrameWidth}.
     * @return {Number} The body width
     */
    getInnerWidth : function(){
        return this.getSize().width - this.getFrameWidth();
    },

    /**
     * Returns the height in pixels of the body element (not including the height of any framing elements).
     * For the frame height see {@link #getFrameHeight}.
     * @return {Number} The body height
     */
    getInnerHeight : function(){
        return this.getSize().height - this.getFrameHeight();
    },

    // private
    syncShadow : function(){
        if(this.floating){
            this.el.sync(true);
        }
    },

    // private
    getLayoutTarget : function(){
        return this.body;
    },

    /**
     * Sets the title text for the panel and optionally the icon class.
     * @param {String} title The title text to set
     * @param {String} iconCls (optional) iconCls A user-defined CSS class that provides the icon image for this panel
     */
    setTitle : function(title, iconCls){
        this.title = title;
        if(this.header && this.headerAsText){
            this.header.child('span').update(title);
        }
        if(iconCls){
            this.setIconClass(iconCls);
        }
        this.fireEvent('titlechange', this, title);
        return this;
    },

    /**
     * Get the {@link Ext.Updater} for this panel. Enables you to perform Ajax updates of this panel's body.
     * @return {Ext.Updater} The Updater
     */
    getUpdater : function(){
        return this.body.getUpdater();
    },

     /**
     * Loads this content panel immediately with content returned from an XHR call.
     * @param {Object/String/Function} config A config object containing any of the following options:
<pre><code>
panel.load({
    url: "your-url.php",
    params: {param1: "foo", param2: "bar"}, // or a URL encoded string
    callback: yourFunction,
    scope: yourObject, // optional scope for the callback
    discardUrl: false,
    nocache: false,
    text: "Loading...",
    timeout: 30,
    scripts: false
});
</code></pre>
     * The only required property is url. The optional properties nocache, text and scripts
     * are shorthand for disableCaching, indicatorText and loadScripts and are used to set their
     * associated property on this panel Updater instance.
     * @return {Ext.Panel} this
     */
    load : function(){
        var um = this.body.getUpdater();
        um.update.apply(um, arguments);
        return this;
    },

    // private
    beforeDestroy : function(){
        Ext.Element.uncache(
            this.header,
            this.tbar,
            this.bbar,
            this.footer,
            this.body
        );
        if(this.tools){
            for(var k in this.tools){
                Ext.destroy(this.tools[k]);
            }
        }
        if(this.buttons){
            for(var b in this.buttons){
                Ext.destroy(this.buttons[b]);
            }
        }
        Ext.destroy(
            this.topToolbar,
            this.bottomToolbar
        );
        Ext.Panel.superclass.beforeDestroy.call(this);
    },

    // private
    createClasses : function(){
        this.headerCls = this.baseCls + '-header';
        this.headerTextCls = this.baseCls + '-header-text';
        this.bwrapCls = this.baseCls + '-bwrap';
        this.tbarCls = this.baseCls + '-tbar';
        this.bodyCls = this.baseCls + '-body';
        this.bbarCls = this.baseCls + '-bbar';
        this.footerCls = this.baseCls + '-footer';
    },

    // private
    createGhost : function(cls, useShim, appendTo){
        var el = document.createElement('div');
        el.className = 'x-panel-ghost ' + (cls ? cls : '');
        if(this.header){
            el.appendChild(this.el.dom.firstChild.cloneNode(true));
        }
        Ext.fly(el.appendChild(document.createElement('ul'))).setHeight(this.bwrap.getHeight());
        el.style.width = this.el.dom.offsetWidth + 'px';;
        if(!appendTo){
            this.container.dom.appendChild(el);
        }else{
            Ext.getDom(appendTo).appendChild(el);
        }
        if(useShim !== false && this.el.useShim !== false){
            var layer = new Ext.Layer({shadow:false, useDisplay:true, constrain:false}, el);
            layer.show();
            return layer;
        }else{
            return new Ext.Element(el);
        }
    },

    // private
    doAutoLoad : function(){
        this.body.load(
            typeof this.autoLoad == 'object' ?
                this.autoLoad : {url: this.autoLoad});
    }

/**
 * @cfg {String} autoEl @hide
 */
});
Ext.reg('panel', Ext.Panel);

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/* // Internal developer documentation -- will not show up in API docs
 * @class Ext.dd.PanelProxy
 * A custom drag proxy implementation specific to {@link Ext.Panel}s. This class is primarily used internally
 * for the Panel's drag drop implementation, and should never need to be created directly.
 * @constructor
 * @param panel The {@link Ext.Panel} to proxy for
 * @param config Configuration options
 */
Ext.dd.PanelProxy = function(panel, config){
    this.panel = panel;
    this.id = this.panel.id +'-ddproxy';
    Ext.apply(this, config);
};

Ext.dd.PanelProxy.prototype = {
    /**
     * @cfg {Boolean} insertProxy True to insert a placeholder proxy element while dragging the panel,
      * false to drag with no proxy (defaults to true).
     */
    insertProxy : true,

    // private overrides
    setStatus : Ext.emptyFn,
    reset : Ext.emptyFn,
    update : Ext.emptyFn,
    stop : Ext.emptyFn,
    sync: Ext.emptyFn,

    /**
     * Gets the proxy's element
     * @return {Element} The proxy's element
     */
    getEl : function(){
        return this.ghost;
    },

    /**
     * Gets the proxy's ghost element
     * @return {Element} The proxy's ghost element
     */
    getGhost : function(){
        return this.ghost;
    },

    /**
     * Gets the proxy's element
     * @return {Element} The proxy's element
     */
    getProxy : function(){
        return this.proxy;
    },

    /**
     * Hides the proxy
     */
    hide : function(){
        if(this.ghost){
            if(this.proxy){
                this.proxy.remove();
                delete this.proxy;
            }
            this.panel.el.dom.style.display = '';
            this.ghost.remove();
            delete this.ghost;
        }
    },

    /**
     * Shows the proxy
     */
    show : function(){
        if(!this.ghost){
            this.ghost = this.panel.createGhost(undefined, undefined, Ext.getBody());
            this.ghost.setXY(this.panel.el.getXY())
            if(this.insertProxy){
                this.proxy = this.panel.el.insertSibling({cls:'x-panel-dd-spacer'});
                this.proxy.setSize(this.panel.getSize());
            }
            this.panel.el.dom.style.display = 'none';
        }
    },

    // private
    repair : function(xy, callback, scope){
        this.hide();
        if(typeof callback == "function"){
            callback.call(scope || this);
        }
    },

    /**
     * Moves the proxy to a different position in the DOM.  This is typically called while dragging the Panel
     * to keep the proxy sync'd to the Panel's location.
     * @param {HTMLElement} parentNode The proxy's parent DOM node
     * @param {HTMLElement} before (optional) The sibling node before which the proxy should be inserted (defaults
     * to the parent's last child if not specified)
     */
    moveProxy : function(parentNode, before){
        if(this.proxy){
            parentNode.insertBefore(this.proxy.dom, before);
        }
    }
};

// private - DD implementation for Panels
Ext.Panel.DD = function(panel, cfg){
    this.panel = panel;
    this.dragData = {panel: panel};
    this.proxy = new Ext.dd.PanelProxy(panel, cfg);
    Ext.Panel.DD.superclass.constructor.call(this, panel.el, cfg);
    var h = panel.header;
    if(h){
        this.setHandleElId(h.id);
    }
    (h ? h : this.panel.body).setStyle('cursor', 'move');
    this.scroll = false;
};

Ext.extend(Ext.Panel.DD, Ext.dd.DragSource, {
    showFrame: Ext.emptyFn,
    startDrag: Ext.emptyFn,
    b4StartDrag: function(x, y) {
        this.proxy.show();
    },
    b4MouseDown: function(e) {
        var x = e.getPageX();
        var y = e.getPageY();
        this.autoOffset(x, y);
    },
    onInitDrag : function(x, y){
        this.onStartDrag(x, y);
        return true;
    },
    createFrame : Ext.emptyFn,
    getDragEl : function(e){
        return this.proxy.ghost.dom;
    },
    endDrag : function(e){
        this.proxy.hide();
        this.panel.saveState();
    },

    autoOffset : function(x, y) {
        x -= this.startPageX;
        y -= this.startPageY;
        this.setDelta(x, y);
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
 * @class Ext.TabPanel
 * <p>A basic tab container. TabPanels can be used exactly like a standard {@link Ext.Panel} for layout
 * purposes, but also have special support for containing child Components that are managed using a CardLayout
 * layout manager, and displayed as seperate tabs.</p>
 * <p>There is no actual tab class &mdash; each tab is simply an {@link Ext.BoxComponent Component} such
 * as a {@link Ext.Panel Panel}. However, when rendered in a TabPanel, each child Component can fire
 * additional events that only exist for tabs and are not available from other Component. These are:</p>
 * <ul>
 * <li><b>activate</b>: Fires when this Component becomes the active tab.
 * <div class="mdetail-params">
 *      <strong style="font-weight: normal;">Listeners will be called with the following arguments:</strong>
 *      <ul><li><code>tab</code> : Panel<div class="sub-desc">The tab that was activated</div></li></ul>
 *  </div></li>
 * <li><b>deactivate</b>: Fires when the Component that was the active tab becomes deactivated.
 * <div class="mdetail-params">
 *      <strong style="font-weight: normal;">Listeners will be called with the following arguments:</strong>
 *      <ul><li><code>tab</code> : Panel<div class="sub-desc">The tab that was deactivated</div></li></ul>
 *  </div></li>
 * </ul>
 * <p>To add Components to a TabPanel which are generated dynamically on the server, it is necessary to
 * create a server script to generate the Javascript to create the Component required.</p>
 * For example, to add a GridPanel to a TabPanel where the GridPanel is generated by the server
 * based on certain parameters, you would need to execute an Ajax request to invoke your the script,
 * and process the response object to add it to the TabPanel:</p><pre><code>
Ext.Ajax.request({
    url: 'gen-invoice-grid.php',
    params: {
        startDate = Ext.getCmp('start-date').getValue(),
        endDate = Ext.getCmp('end-date').getValue()
    },
    success: function(xhr) {
        var newComponent = eval(xhr.responseText);
        myTabPanel.add(newComponent);
        myTabPanel.setActiveTab(newComponent);
    },
    failure: function() {
    	Ext.Msg.alert("Grid create failed", "Server communication failure");
    }
});
</code></pre>
 * <p>The server script would need to return an executable Javascript statement which, when processed
 * using <tt>eval()</tt> will return either a config object with an {@link Ext.Component#xtype xtype},
 * or an instantiated Component. For example:</p><pre><code>
{function() {
    function formatDate(value){
        return value ? value.dateFormat('M d, Y') : '';
    };

    var store = new Ext.data.Store({
        url: 'get-invoice-data.php',
        baseParams: {
            startDate: '01/01/2008',
            endDate: '01/31/2008'
        }
        reader: new Ext.data.JsonReader({
            record: 'transaction',
            id: 'id',
            totalRecords: 'total'
        }, [
           'customer',
           'invNo',
           {name: 'date', type: 'date', dateFormat: 'm/d/Y'},
           {name: 'value', type: 'float'}
        ])
    });

    var grid = new Ext.grid.GridPanel({
        title: 'Invoice Report',
        bbar: new Ext.PagingToolbar(store),
        store: store,
        columns: [
            {header: "Customer", width: 250, dataIndex: 'customer', sortable: true},
            {header: "Invoice Number", width: 120, dataIndex: 'invNo', sortable: true},
            {header: "Invoice Date", width: 100, dataIndex: 'date', renderer: formatDate, sortable: true},
            {header: "Value", width: 120, dataIndex: 'value', renderer: 'usMoney', sortable: true}
        ],
    });
    store.load();
    return grid;
})();
</code></pre>
 * <p>Since that code is <i>generated</i> by a server script, the <tt>baseParams</tt> for the Store
 * can be configured into the Store. The metadata to allow generation of the Record layout, and the
 * ColumnModel is also known on the server, so these can be generated into the code.</p>
 * <p>When that code fragment is passed through the <tt>eval</tt> function in the success handler
 * of the Ajax request, the code is executed by the Javascript processor, and the anonymous function
 * runs, and returns the grid.</p>
 * <p>There are several other methods available for creating TabPanels. The output of the following
 * examples should produce exactly the same appearance. The tabs can be created and rendered completely
 * in code, as in this example:</p>
 * <pre><code>
var tabs = new Ext.TabPanel({
    renderTo: Ext.getBody(),
    activeTab: 0,
    items: [{
        title: 'Tab 1',
        html: 'A simple tab'
    },{
        title: 'Tab 2',
        html: 'Another one'
    }]
});
</code></pre>
  * <p>TabPanels can also be rendered from pre-existing markup in a couple of ways.  See the {@link #autoTabs} example for
  * rendering entirely from markup that is already structured correctly as a TabPanel (a container div with
  * one or more nested tab divs with class 'x-tab'). You can also render from markup that is not strictly
  * structured by simply specifying by id which elements should be the container and the tabs. Using this method,
  * tab content can be pulled from different elements within the page by id regardless of page structure.  Note
  * that the tab divs in this example contain the class 'x-hide-display' so that they can be rendered deferred
  * without displaying outside the tabs. You could alternately set {@link #deferredRender} to false to render all
  * content tabs on page load. For example:
  * <pre><code>
var tabs = new Ext.TabPanel({
    renderTo: 'my-tabs',
    activeTab: 0,
    items:[
        {contentEl:'tab1', title:'Tab 1'},
        {contentEl:'tab2', title:'Tab 2'}
    ]
});

// Note that the tabs do not have to be nested within the container (although they can be)
&lt;div id="my-tabs">&lt;/div>
&lt;div id="tab1" class="x-hide-display">A simple tab&lt;/div>
&lt;div id="tab2" class="x-hide-display">Another one&lt;/div>
</code></pre>
 * @extends Ext.Panel
 * @constructor
 * @param {Object} config The configuration options
 */
Ext.TabPanel = Ext.extend(Ext.Panel,  {
    /**
     * @cfg {Boolean} layoutOnTabChange Set to true to do a layout of tab items as tabs are changed.
     */
    /**
     * @cfg {Boolean} monitorResize True to automatically monitor window resize events and rerender the layout on
     * browser resize (defaults to true).
     */
    monitorResize : true,
    /**
     * @cfg {Boolean} deferredRender Internally, the TabPanel uses a {@link Ext.layout.CardLayout} to manage its tabs.
     * This property will be passed on to the layout as its {@link Ext.layout.CardLayout#deferredRender} config value,
     * determining whether or not each tab is rendered only when first accessed (defaults to true).
     */
    deferredRender : true,
    /**
     * @cfg {Number} tabWidth The initial width in pixels of each new tab (defaults to 120).
     */
    tabWidth: 120,
    /**
     * @cfg {Number} minTabWidth The minimum width in pixels for each tab when {@link #resizeTabs} = true (defaults to 30).
     */
    minTabWidth: 30,
    /**
     * @cfg {Boolean} resizeTabs True to automatically resize each tab so that the tabs will completely fill the
     * tab strip (defaults to false).  Setting this to true may cause specific widths that might be set per tab to
     * be overridden in order to fit them all into view (although {@link #minTabWidth} will always be honored).
     */
    resizeTabs:false,
    /**
     * @cfg {Boolean} enableTabScroll True to enable scrolling to tabs that may be invisible due to overflowing the
     * overall TabPanel width. Only available with tabPosition:'top' (defaults to false).
     */
    enableTabScroll: false,
    /**
     * @cfg {Number} scrollIncrement The number of pixels to scroll each time a tab scroll button is pressed (defaults
     * to 100, or if {@link #resizeTabs} = true, the calculated tab width).  Only applies when {@link #enableTabScroll} = true.
     */
    scrollIncrement : 0,
    /**
     * @cfg {Number} scrollRepeatInterval Number of milliseconds between each scroll while a tab scroll button is
     * continuously pressed (defaults to 400).
     */
    scrollRepeatInterval : 400,
    /**
     * @cfg {Float} scrollDuration The number of milliseconds that each scroll animation should last (defaults to .35).
     * Only applies when {@link #animScroll} = true.
     */
    scrollDuration : .35,
    /**
     * @cfg {Boolean} animScroll True to animate tab scrolling so that hidden tabs slide smoothly into view (defaults
     * to true).  Only applies when {@link #enableTabScroll} = true.
     */
    animScroll : true,
    /**
     * @cfg {String} tabPosition The position where the tab strip should be rendered (defaults to 'top').  The only
     * other supported value is 'bottom'.  Note that tab scrolling is only supported for position 'top'.
     */
    tabPosition: 'top',
    /**
     * @cfg {String} baseCls The base CSS class applied to the panel (defaults to 'x-tab-panel').
     */
    baseCls: 'x-tab-panel',
    /**
     * @cfg {Boolean} autoTabs
     * <p>True to query the DOM for any divs with a class of 'x-tab' to be automatically converted
     * to tabs and added to this panel (defaults to false).  Note that the query will be executed within the scope of
     * the container element only (so that multiple tab panels from markup can be supported via this method).</p>
     * <p>This method is only possible when the markup is structured correctly as a container with nested
     * divs containing the class 'x-tab'. To create TabPanels without these limitations, or to pull tab content from
     * other elements on the page, see the example at the top of the class for generating tabs from markup.</p>
     * <p>There are a couple of things to note when using this method:<ul>
     * <li>When using the autoTabs config (as opposed to passing individual tab configs in the TabPanel's
     * {@link #items} collection), you must use {@link #applyTo} to correctly use the specified id as the tab container.
     * The autoTabs method <em>replaces</em> existing content with the TabPanel components.</li>
     * <li>Make sure that you set {@link #deferredRender} to false so that the content elements for each tab will be
     * rendered into the TabPanel immediately upon page load, otherwise they will not be transformed until each tab
     * is activated and will be visible outside the TabPanel.</li>
     * </ul>Example usage:</p>
     * <pre><code>
var tabs = new Ext.TabPanel({
    applyTo: 'my-tabs',
    activeTab: 0,
    deferredRender: false,
    autoTabs: true
});

// This markup will be converted to a TabPanel from the code above
&lt;div id="my-tabs">
    &lt;div class="x-tab" title="Tab 1">A simple tab&lt;/div>
    &lt;div class="x-tab" title="Tab 2">Another one&lt;/div>
&lt;/div>
</code></pre>
     */
    autoTabs : false,
    /**
     * @cfg {String} autoTabSelector The CSS selector used to search for tabs in existing markup when {@link #autoTabs}
     * = true (defaults to 'div.x-tab').  This can be any valid selector supported by {@link Ext.DomQuery#select}.
     * Note that the query will be executed within the scope of this tab panel only (so that multiple tab panels from
     * markup can be supported on a page).
     */
    autoTabSelector:'div.x-tab',
    /**
     * @cfg {String/Number} activeTab A string id or the numeric index of the tab that should be initially
     * activated on render (defaults to none).
     */
    activeTab : null,
    /**
     * @cfg {Number} tabMargin The number of pixels of space to calculate into the sizing and scrolling of tabs. If you
     * change the margin in CSS, you will need to update this value so calculations are correct with either resizeTabs
     * or scrolling tabs. (defaults to 2)
     */
    tabMargin : 2,
    /**
     * @cfg {Boolean} plain True to render the tab strip without a background container image (defaults to false).
     */
    plain: false,
    /**
     * @cfg {Number} wheelIncrement For scrolling tabs, the number of pixels to increment on mouse wheel scrolling (defaults to 20).
     */
    wheelIncrement : 20,

    /*
     * This is a protected property used when concatenating tab ids to the TabPanel id for internal uniqueness.
     * It does not generally need to be changed, but can be if external code also uses an id scheme that can
     * potentially clash with this one.
     */
    idDelimiter : '__',

    // private
    itemCls : 'x-tab-item',

    // private config overrides
    elements: 'body',
    headerAsText: false,
    frame: false,
    hideBorders:true,

    // private
    initComponent : function(){
        this.frame = false;
        Ext.TabPanel.superclass.initComponent.call(this);
        this.addEvents(
            /**
             * @event beforetabchange
             * Fires before the active tab changes. Handlers can return false to cancel the tab change.
             * @param {TabPanel} this
             * @param {Panel} newTab The tab being activated
             * @param {Panel} currentTab The current active tab
             */
            'beforetabchange',
            /**
             * @event tabchange
             * Fires after the active tab has changed.
             * @param {TabPanel} this
             * @param {Panel} tab The new active tab
             */
            'tabchange',
            /**
             * @event contextmenu
             * Fires when the original browser contextmenu event originated from a tab element.
             * @param {TabPanel} this
             * @param {Panel} tab The target tab
             * @param {EventObject} e
             */
            'contextmenu'
        );
        this.setLayout(new Ext.layout.CardLayout({
            deferredRender: this.deferredRender
        }));
        if(this.tabPosition == 'top'){
            this.elements += ',header';
            this.stripTarget = 'header';
        }else {
            this.elements += ',footer';
            this.stripTarget = 'footer';
        }
        if(!this.stack){
            this.stack = Ext.TabPanel.AccessStack();
        }
        this.initItems();
    },

    // private
    render : function(){
        Ext.TabPanel.superclass.render.apply(this, arguments);
        if(this.activeTab !== undefined){
            var item = this.activeTab;
            delete this.activeTab;
            this.setActiveTab(item);
        }
    },

    // private
    onRender : function(ct, position){
        Ext.TabPanel.superclass.onRender.call(this, ct, position);

        if(this.plain){
            var pos = this.tabPosition == 'top' ? 'header' : 'footer';
            this[pos].addClass('x-tab-panel-'+pos+'-plain');
        }

        var st = this[this.stripTarget];

        this.stripWrap = st.createChild({cls:'x-tab-strip-wrap', cn:{
            tag:'ul', cls:'x-tab-strip x-tab-strip-'+this.tabPosition}});

        var beforeEl = (this.tabPosition=='bottom' ? this.stripWrap : null);
        this.stripSpacer = st.createChild({cls:'x-tab-strip-spacer'}, beforeEl);
        this.strip = new Ext.Element(this.stripWrap.dom.firstChild);
        
        this.edge = this.strip.createChild({tag:'li', cls:'x-tab-edge'});
        this.strip.createChild({cls:'x-clear'});

        this.body.addClass('x-tab-panel-body-'+this.tabPosition);

        if(!this.itemTpl){
            var tt = new Ext.Template(
                 '<li class="{cls}" id="{id}"><a class="x-tab-strip-close" onclick="return false;"></a>',
                 '<a class="x-tab-right" href="#" onclick="return false;"><em class="x-tab-left">',
                 '<span class="x-tab-strip-inner"><span class="x-tab-strip-text {iconCls}">{text}</span></span>',
                 '</em></a></li>'
            );
            tt.disableFormats = true;
            tt.compile();
            Ext.TabPanel.prototype.itemTpl = tt;
        }

        this.items.each(this.initTab, this);
    },

    // private
    afterRender : function(){
        Ext.TabPanel.superclass.afterRender.call(this);
        if(this.autoTabs){
            this.readTabs(false);
        }
    },

    // private
    initEvents : function(){
        Ext.TabPanel.superclass.initEvents.call(this);
        this.on('add', this.onAdd, this);
        this.on('remove', this.onRemove, this);

        this.strip.on('mousedown', this.onStripMouseDown, this);
        this.strip.on('contextmenu', this.onStripContextMenu, this);
        if(this.enableTabScroll){
            this.strip.on('mousewheel', this.onWheel, this);
        }
    },

    // private
    findTargets : function(e){
        var item = null;
        var itemEl = e.getTarget('li', this.strip);
        if(itemEl){
            item = this.getComponent(itemEl.id.split(this.idDelimiter)[1]);
            if(item.disabled){
                return {
                    close : null,
                    item : null,
                    el : null
                };
            }
        }
        return {
            close : e.getTarget('.x-tab-strip-close', this.strip),
            item : item,
            el : itemEl
        };
    },

    // private
    onStripMouseDown : function(e){
        if(e.button != 0){
            return;
        }
        e.preventDefault();
        var t = this.findTargets(e);
        if(t.close){
            this.remove(t.item);
            return;
        }
        if(t.item && t.item != this.activeTab){
            this.setActiveTab(t.item);
        }
    },

    // private
    onStripContextMenu : function(e){
        e.preventDefault();
        var t = this.findTargets(e);
        if(t.item){
            this.fireEvent('contextmenu', this, t.item, e);
        }
    },

    /**
     * True to scan the markup in this tab panel for autoTabs using the autoTabSelector
     * @param {Boolean} removeExisting True to remove existing tabs
     */
    readTabs : function(removeExisting){
        if(removeExisting === true){
            this.items.each(function(item){
                this.remove(item);
            }, this);
        }
        var tabs = this.el.query(this.autoTabSelector);
        for(var i = 0, len = tabs.length; i < len; i++){
            var tab = tabs[i];
            var title = tab.getAttribute('title');
            tab.removeAttribute('title');
            this.add({
                title: title,
                el: tab
            });
        }
    },

    // private
    initTab : function(item, index){
        var before = this.strip.dom.childNodes[index];
        var cls = item.closable ? 'x-tab-strip-closable' : '';
        if(item.disabled){
            cls += ' x-item-disabled';
        }
        if(item.iconCls){
            cls += ' x-tab-with-icon';
        }
        if(item.tabCls){
            cls += ' ' + item.tabCls;
        }
        
        var p = {
            id: this.id + this.idDelimiter + item.getItemId(),
            text: item.title,
            cls: cls,
            iconCls: item.iconCls || ''
        };
        var el = before ?
                 this.itemTpl.insertBefore(before, p) :
                 this.itemTpl.append(this.strip, p);

        Ext.fly(el).addClassOnOver('x-tab-strip-over');

        if(item.tabTip){
            Ext.fly(el).child('span.x-tab-strip-text', true).qtip = item.tabTip;
        }
        item.on('disable', this.onItemDisabled, this);
        item.on('enable', this.onItemEnabled, this);
        item.on('titlechange', this.onItemTitleChanged, this);
        item.on('beforeshow', this.onBeforeShowItem, this);
    },

    // private
    onAdd : function(tp, item, index){
        this.initTab(item, index);
        if(this.items.getCount() == 1){
            this.syncSize();
        }
        this.delegateUpdates();
    },

    // private
    onBeforeAdd : function(item){
        var existing = item.events ? (this.items.containsKey(item.getItemId()) ? item : null) : this.items.get(item);
        if(existing){
            this.setActiveTab(item);
            return false;
        }
        Ext.TabPanel.superclass.onBeforeAdd.apply(this, arguments);
        var es = item.elements;
        item.elements = es ? es.replace(',header', '') : es;
        item.border = (item.border === true);
    },

    // private
    onRemove : function(tp, item){
        Ext.removeNode(this.getTabEl(item));
        this.stack.remove(item);
        item.un('disable', this.onItemDisabled, this);
        item.un('enable', this.onItemEnabled, this);
        item.un('titlechange', this.onItemTitleChanged, this);
        item.un('beforeshow', this.onBeforeShowItem, this);
        if(item == this.activeTab){
            var next = this.stack.next();
            if(next){
                this.setActiveTab(next);
            }else{
                this.setActiveTab(0);
            }
        }
        this.delegateUpdates();
    },

    // private
    onBeforeShowItem : function(item){
        if(item != this.activeTab){
            this.setActiveTab(item);
            return false;
        }
    },

    // private
    onItemDisabled : function(item){
        var el = this.getTabEl(item);
        if(el){
            Ext.fly(el).addClass('x-item-disabled');
        }
        this.stack.remove(item);
    },

    // private
    onItemEnabled : function(item){
        var el = this.getTabEl(item);
        if(el){
            Ext.fly(el).removeClass('x-item-disabled');
        }
    },

    // private
    onItemTitleChanged : function(item){
        var el = this.getTabEl(item);
        if(el){
            Ext.fly(el).child('span.x-tab-strip-text', true).innerHTML = item.title;
        }
    },

    /**
     * Gets the DOM element for tab strip item which activates the
     * child panel with the specified ID. Access this to change the visual treatment of the
     * item, for example by changing the CSS class name.
     * @param {Panel} tab The tab
     * @return {HTMLElement} The DOM node
     */
    getTabEl : function(item){
        var itemId = (typeof item === 'number')?this.items.items[item].getItemId() : item.getItemId();
        return document.getElementById(this.id+this.idDelimiter+itemId);
    },

    // private
    onResize : function(){
        Ext.TabPanel.superclass.onResize.apply(this, arguments);
        this.delegateUpdates();
    },

    /**
     * Suspends any internal calculations or scrolling while doing a bulk operation. See {@link #endUpdate}
     */
    beginUpdate : function(){
        this.suspendUpdates = true;
    },

    /**
     * Resumes calculations and scrolling at the end of a bulk operation. See {@link #beginUpdate}
     */
    endUpdate : function(){
        this.suspendUpdates = false;
        this.delegateUpdates();
    },

    /**
     * Hides the tab strip item for the passed tab
     * @param {Number/String/Panel} item The tab index, id or item
     */
    hideTabStripItem : function(item){
        item = this.getComponent(item);
        var el = this.getTabEl(item);
        if(el){
            el.style.display = 'none';
            this.delegateUpdates();
        }
        this.stack.remove(item);
    },

    /**
     * Unhides the tab strip item for the passed tab
     * @param {Number/String/Panel} item The tab index, id or item
     */
    unhideTabStripItem : function(item){
        item = this.getComponent(item);
        var el = this.getTabEl(item);
        if(el){
            el.style.display = '';
            this.delegateUpdates();
        }
    },

    // private
    delegateUpdates : function(){
        if(this.suspendUpdates){
            return;
        }
        if(this.resizeTabs && this.rendered){
            this.autoSizeTabs();
        }
        if(this.enableTabScroll && this.rendered){
            this.autoScrollTabs();
        }
    },

    // private
    autoSizeTabs : function(){
        var count = this.items.length;
        var ce = this.tabPosition != 'bottom' ? 'header' : 'footer';
        var ow = this[ce].dom.offsetWidth;
        var aw = this[ce].dom.clientWidth;

        if(!this.resizeTabs || count < 1 || !aw){ // !aw for display:none
            return;
        }

        var each = Math.max(Math.min(Math.floor((aw-4) / count) - this.tabMargin, this.tabWidth), this.minTabWidth); // -4 for float errors in IE
        this.lastTabWidth = each;
        var lis = this.stripWrap.dom.getElementsByTagName('li');
        for(var i = 0, len = lis.length-1; i < len; i++) { // -1 for the "edge" li
            var li = lis[i];
            var inner = li.childNodes[1].firstChild.firstChild;
            var tw = li.offsetWidth;
            var iw = inner.offsetWidth;
            inner.style.width = (each - (tw-iw)) + 'px';
        }
    },

    // private
    adjustBodyWidth : function(w){
        if(this.header){
            this.header.setWidth(w);
        }
        if(this.footer){
            this.footer.setWidth(w);
        }
        return w;
    },

    /**
     * Sets the specified tab as the active tab. This method fires the {@link #beforetabchange} event which
     * can return false to cancel the tab change.
     * @param {String/Panel} tab The id or tab Panel to activate
     */
    setActiveTab : function(item){
        item = this.getComponent(item);
        if(!item || this.fireEvent('beforetabchange', this, item, this.activeTab) === false){
            return;
        }
        if(!this.rendered){
            this.activeTab = item;
            return;
        }
        if(this.activeTab != item){
            if(this.activeTab){
                var oldEl = this.getTabEl(this.activeTab);
                if(oldEl){
                    Ext.fly(oldEl).removeClass('x-tab-strip-active');
                }
                this.activeTab.fireEvent('deactivate', this.activeTab);
            }
            var el = this.getTabEl(item);
            Ext.fly(el).addClass('x-tab-strip-active');
            this.activeTab = item;
            this.stack.add(item);

            this.layout.setActiveItem(item);
            if(this.layoutOnTabChange && item.doLayout){
                item.doLayout();
            }
            if(this.scrolling){
                this.scrollToTab(item, this.animScroll);
            }

            item.fireEvent('activate', item);
            this.fireEvent('tabchange', this, item);
        }
    },

    /**
     * Gets the currently active tab.
     * @return {Panel} The active tab
     */
    getActiveTab : function(){
        return this.activeTab || null;
    },

    /**
     * Gets the specified tab by id.
     * @param {String} id The tab id
     * @return {Panel} The tab
     */
    getItem : function(item){
        return this.getComponent(item);
    },

    // private
    autoScrollTabs : function(){
        var count = this.items.length;
        var ow = this.header.dom.offsetWidth;
        var tw = this.header.dom.clientWidth;

        var wrap = this.stripWrap;
        var wd = wrap.dom;
        var cw = wd.offsetWidth;
        var pos = this.getScrollPos();
        var l = this.edge.getOffsetsTo(this.stripWrap)[0] + pos;

        if(!this.enableTabScroll || count < 1 || cw < 20){ // 20 to prevent display:none issues
            return;
        }
        if(l <= tw){
            wd.scrollLeft = 0;
            wrap.setWidth(tw);
            if(this.scrolling){
                this.scrolling = false;
                this.header.removeClass('x-tab-scrolling');
                this.scrollLeft.hide();
                this.scrollRight.hide();
                if(Ext.isAir){
                    wd.style.marginLeft = '';
                    wd.style.marginRight = '';
                }
            }
        }else{
            if(!this.scrolling){
                this.header.addClass('x-tab-scrolling');
                if(Ext.isAir){
                    wd.style.marginLeft = '18px';
                    wd.style.marginRight = '18px';
                }
            }
            tw -= wrap.getMargins('lr');
            wrap.setWidth(tw > 20 ? tw : 20);
            if(!this.scrolling){
                if(!this.scrollLeft){
                    this.createScrollers();
                }else{
                    this.scrollLeft.show();
                    this.scrollRight.show();
                }
            }
            this.scrolling = true;
            if(pos > (l-tw)){ // ensure it stays within bounds
                wd.scrollLeft = l-tw;
            }else{ // otherwise, make sure the active tab is still visible
                this.scrollToTab(this.activeTab, false);
            }
            this.updateScrollButtons();
        }
    },

    // private
    createScrollers : function(){
        var h = this.stripWrap.dom.offsetHeight;

        // left
        var sl = this.header.insertFirst({
            cls:'x-tab-scroller-left'
        });
        sl.setHeight(h);
        sl.addClassOnOver('x-tab-scroller-left-over');
        this.leftRepeater = new Ext.util.ClickRepeater(sl, {
            interval : this.scrollRepeatInterval,
            handler: this.onScrollLeft,
            scope: this
        });
        this.scrollLeft = sl;

        // right
        var sr = this.header.insertFirst({
            cls:'x-tab-scroller-right'
        });
        sr.setHeight(h);
        sr.addClassOnOver('x-tab-scroller-right-over');
        this.rightRepeater = new Ext.util.ClickRepeater(sr, {
            interval : this.scrollRepeatInterval,
            handler: this.onScrollRight,
            scope: this
        });
        this.scrollRight = sr;
    },

    // private
    getScrollWidth : function(){
        return this.edge.getOffsetsTo(this.stripWrap)[0] + this.getScrollPos();
    },

    // private
    getScrollPos : function(){
        return parseInt(this.stripWrap.dom.scrollLeft, 10) || 0;
    },

    // private
    getScrollArea : function(){
        return parseInt(this.stripWrap.dom.clientWidth, 10) || 0;
    },

    // private
    getScrollAnim : function(){
        return {duration:this.scrollDuration, callback: this.updateScrollButtons, scope: this};
    },

    // private
    getScrollIncrement : function(){
        return this.scrollIncrement || (this.resizeTabs ? this.lastTabWidth+2 : 100);
    },

    /**
     * Scrolls to a particular tab if tab scrolling is enabled
     * @param {Panel} item The item to scroll to
     * @param {Boolean} animate True to enable animations
     */

    scrollToTab : function(item, animate){
        if(!item){ return; }
        var el = this.getTabEl(item);
        var pos = this.getScrollPos(), area = this.getScrollArea();
        var left = Ext.fly(el).getOffsetsTo(this.stripWrap)[0] + pos;
        var right = left + el.offsetWidth;
        if(left < pos){
            this.scrollTo(left, animate);
        }else if(right > (pos + area)){
            this.scrollTo(right - area, animate);
        }
    },

    // private
    scrollTo : function(pos, animate){
        this.stripWrap.scrollTo('left', pos, animate ? this.getScrollAnim() : false);
        if(!animate){
            this.updateScrollButtons();
        }
    },

    onWheel : function(e){
        var d = e.getWheelDelta()*this.wheelIncrement*-1;
        e.stopEvent();

        var pos = this.getScrollPos();
        var newpos = pos + d;
        var sw = this.getScrollWidth()-this.getScrollArea();

        var s = Math.max(0, Math.min(sw, newpos));
        if(s != pos){
            this.scrollTo(s, false);
        }
    },

    // private
    onScrollRight : function(){
        var sw = this.getScrollWidth()-this.getScrollArea();
        var pos = this.getScrollPos();
        var s = Math.min(sw, pos + this.getScrollIncrement());
        if(s != pos){
            this.scrollTo(s, this.animScroll);
        }
    },

    // private
    onScrollLeft : function(){
        var pos = this.getScrollPos();
        var s = Math.max(0, pos - this.getScrollIncrement());
        if(s != pos){
            this.scrollTo(s, this.animScroll);
        }
    },

    // private
    updateScrollButtons : function(){
        var pos = this.getScrollPos();
        this.scrollLeft[pos == 0 ? 'addClass' : 'removeClass']('x-tab-scroller-left-disabled');
        this.scrollRight[pos >= (this.getScrollWidth()-this.getScrollArea()) ? 'addClass' : 'removeClass']('x-tab-scroller-right-disabled');
    }

    /**
     * @cfg {Boolean} collapsible
     * @hide
     */
    /**
     * @cfg {String} header
     * @hide
     */
    /**
     * @cfg {Boolean} headerAsText
     * @hide
     */
    /**
     * @property header
     * @hide
     */
    /**
     * @property title
     * @hide
     */
    /**
     * @cfg {Array} tools
     * @hide
     */
    /**
     * @cfg {Boolean} hideCollapseTool
     * @hide
     */
    /**
     * @cfg {Boolean} titleCollapse
     * @hide
     */
    /**
     * @cfg {Boolean} collapsed
     * @hide
     */
    /**
     * @cfg {String} layout
     * @hide
     */
    /**
     * @cfg {Object} layoutConfig
     * @hide
     */

});
Ext.reg('tabpanel', Ext.TabPanel);

/**
 * Sets the specified tab as the active tab. This method fires the {@link #beforetabchange} event which
 * can return false to cancel the tab change.
 * @param {String/Panel} tab The id or tab Panel to activate
 * @method activate
 */
Ext.TabPanel.prototype.activate = Ext.TabPanel.prototype.setActiveTab;

// private utility class used by TabPanel
Ext.TabPanel.AccessStack = function(){
    var items = [];
    return {
        add : function(item){
            items.push(item);
            if(items.length > 10){
                items.shift();
            }
        },

        remove : function(item){
            var s = [];
            for(var i = 0, len = items.length; i < len; i++) {
                if(items[i] != item){
                    s.push(items[i]);
                }
            }
            items = s;
        },

        next : function(){
            return items.pop();
        }
    };
};


// Very simple plugin for adding a close context menu to tabs
Ext.ux.TabCloseMenu = function(){
    var tabs, menu, ctxItem;
    this.init = function(tp){
        tabs = tp;
        tabs.on('contextmenu', onContextMenu);
    }

    function onContextMenu(ts, item, e){
        if(!menu){ // create context menu on first right click
            menu = new Ext.menu.Menu([{
                id: tabs.id + '-close',
                text: 'Close Tab',
                handler : function(){
                    tabs.remove(ctxItem);
                }
            },{
                id: tabs.id + '-close-others',
                text: 'Close Other Tabs',
                handler : function(){
                    tabs.items.each(function(item){
                        if(item.closable && item != ctxItem){
                            tabs.remove(item);
                        }
                    });
                }
            }]);
        }
        ctxItem = item;
        var items = menu.items;
        items.get(tabs.id + '-close').setDisabled(!item.closable);
        var disableOthers = true;
        tabs.items.each(function(){
            if(this != item && this.closable){
                disableOthers = false;
                return false;
            }
        });
        items.get(tabs.id + '-close-others').setDisabled(disableOthers);
        menu.showAt(e.getPoint());
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
 * @class Ext.Tip
 * @extends Ext.Panel
 * This is the base class for {@link Ext.QuickTip} and {@link Ext.Tooltip} that provides the basic layout and
 * positioning that all tip-based classes require. This class can be used directly for simple, statically-positioned
 * tips that are displayed programmatically, or it can be extended to provide custom tip implementations.
 * @constructor
 * Create a new Tip
 * @param {Object} config The configuration options
 */
Ext.Tip = Ext.extend(Ext.Panel, {
    /**
     * @cfg {Boolean} closable True to render a close tool button into the tooltip header (defaults to false).
     */
    /**
     * @cfg {Number} width
     * Width in pixels of the tip (defaults to auto).  Width will be ignored if it exceeds the bounds of
     * {@link #minWidth} or {@link #maxWidth}.  The maximum supported value is 500.
     */
    /**
     * @cfg {Number} minWidth The minimum width of the tip in pixels (defaults to 40).
     */
    minWidth : 40,
    /**
     * @cfg {Number} maxWidth The maximum width of the tip in pixels (defaults to 300).  The maximum supported value is 500.
     */
    maxWidth : 300,
    /**
     * @cfg {Boolean/String} shadow True or "sides" for the default effect, "frame" for 4-way shadow, and "drop"
     * for bottom-right shadow (defaults to "sides").
     */
    shadow : "sides",
    /**
     * @cfg {String} defaultAlign <b>Experimental</b>. The default {@link Ext.Element#alignTo} anchor position value
     * for this tip relative to its element of origin (defaults to "tl-bl?").
     */
    defaultAlign : "tl-bl?",
    autoRender: true,
    quickShowInterval : 250,

    // private panel overrides
    frame:true,
    hidden:true,
    baseCls: 'x-tip',
    floating:{shadow:true,shim:true,useDisplay:true,constrain:false},
    autoHeight:true,

    // private
    initComponent : function(){
        Ext.Tip.superclass.initComponent.call(this);
        if(this.closable && !this.title){
            this.elements += ',header';
        }
    },

    // private
    afterRender : function(){
        Ext.Tip.superclass.afterRender.call(this);
        if(this.closable){
            this.addTool({
                id: 'close',
                handler: this.hide,
                scope: this
            });
        }
    },

    /**
     * Shows this tip at the specified XY position.  Example usage:
     * <pre><code>
// Show the tip at x:50 and y:100
tip.showAt([50,100]);
</code></pre>
     * @param {Array} xy An array containing the x and y coordinates
     */
    showAt : function(xy){
        Ext.Tip.superclass.show.call(this);
        if(this.measureWidth !== false && (!this.initialConfig || typeof this.initialConfig.width != 'number')){
            this.doAutoWidth();
        }
        if(this.constrainPosition){
            xy = this.el.adjustForConstraints(xy);
        }
        this.setPagePosition(xy[0], xy[1]);
    },

    // protected
    doAutoWidth : function(){
        var bw = this.body.getTextWidth();
        if(this.title){
            bw = Math.max(bw, this.header.child('span').getTextWidth(this.title));
        }
        bw += this.getFrameWidth() + (this.closable ? 20 : 0) + this.body.getPadding("lr");
        this.setWidth(bw.constrain(this.minWidth, this.maxWidth));
        
        // IE7 repaint bug on initial show
        if(Ext.isIE7 && !this.repainted){
            this.el.repaint();
            this.repainted = true;
        }
    },

    /**
     * <b>Experimental</b>. Shows this tip at a position relative to another element using a standard {@link Ext.Element#alignTo}
     * anchor position value.  Example usage:
     * <pre><code>
// Show the tip at the default position ('tl-br?')
tip.showBy('my-el');

// Show the tip's top-left corner anchored to the element's top-right corner
tip.showBy('my-el', 'tl-tr');
</code></pre>
     * @param {Mixed} el An HTMLElement, Ext.Element or string id of the target element to align to
     * @param {String} position (optional) A valid {@link Ext.Element#alignTo} anchor position (defaults to 'tl-br?' or
     * {@link #defaultAlign} if specified).
     */
    showBy : function(el, pos){
        if(!this.rendered){
            this.render(Ext.getBody());
        }
        this.showAt(this.el.getAlignToXY(el, pos || this.defaultAlign));
    },

    initDraggable : function(){
        this.dd = new Ext.Tip.DD(this, typeof this.draggable == 'boolean' ? null : this.draggable);
        this.header.addClass('x-tip-draggable');
    }
});

// private - custom Tip DD implementation
Ext.Tip.DD = function(tip, config){
    Ext.apply(this, config);
    this.tip = tip;
    Ext.Tip.DD.superclass.constructor.call(this, tip.el.id, 'WindowDD-'+tip.id);
    this.setHandleElId(tip.header.id);
    this.scroll = false;
};

Ext.extend(Ext.Tip.DD, Ext.dd.DD, {
    moveOnly:true,
    scroll:false,
    headerOffsets:[100, 25],
    startDrag : function(){
        this.tip.el.disableShadow();
    },
    endDrag : function(e){
        this.tip.el.enableShadow(true);
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
 * @class Ext.ToolTip
 * @extends Ext.Tip
 * A standard tooltip implementation for providing additional information when hovering over a target element.
 * @constructor
 * Create a new Tooltip
 * @param {Object} config The configuration options
 */
Ext.ToolTip = Ext.extend(Ext.Tip, {
    /**
     * @cfg {Mixed} target The target HTMLElement, Ext.Element or id to associate with this tooltip.
     */
    /**
     * @cfg {Boolean} autoHide True to automatically hide the tooltip after the mouse exits the target element
     * or after the {@link #dismissDelay} has expired if set (defaults to true).  If {@link closable} = true a close
     * tool button will be rendered into the tooltip header.
     */
    /**
     * @cfg {Number} showDelay Delay in milliseconds before the tooltip displays after the mouse enters the
     * target element (defaults to 500)
     */
    showDelay: 500,
    /**
     * @cfg {Number} hideDelay Delay in milliseconds after the mouse exits the target element but before the
     * tooltip actually hides (defaults to 200).  Set to 0 for the tooltip to hide immediately.
     */
    hideDelay: 200,
    /**
     * @cfg {Number} dismissDelay Delay in milliseconds before the tooltip automatically hides (defaults to 5000).
     * To disable automatic hiding, set dismissDelay = 0.
     */
    dismissDelay: 5000,
    /**
     * @cfg {Array} mouseOffset An XY offset from the mouse position where the tooltip should be shown (defaults to [15,18]).
     */
    mouseOffset: [15,18],
    /**
     * @cfg {Boolean} trackMouse True to have the tooltip follow the mouse as it moves over the target element (defaults to false).
     */
    trackMouse : false,
    constrainPosition: true,

    // private
    initComponent: function(){
        Ext.ToolTip.superclass.initComponent.call(this);
        this.lastActive = new Date();
        this.initTarget();
    },

    // private
    initTarget : function(){
        if(this.target){
            this.target = Ext.get(this.target);
            this.target.on('mouseover', this.onTargetOver, this);
            this.target.on('mouseout', this.onTargetOut, this);
            this.target.on('mousemove', this.onMouseMove, this);
        }
    },

    // private
    onMouseMove : function(e){
        this.targetXY = e.getXY();
        if(!this.hidden && this.trackMouse){
            this.setPagePosition(this.getTargetXY());
        }
    },

    // private
    getTargetXY : function(){
        return [this.targetXY[0]+this.mouseOffset[0], this.targetXY[1]+this.mouseOffset[1]];
    },

    // private
    onTargetOver : function(e){
        if(this.disabled || e.within(this.target.dom, true)){
            return;
        }
        this.clearTimer('hide');
        this.targetXY = e.getXY();
        this.delayShow();
    },

    // private
    delayShow : function(){
        if(this.hidden && !this.showTimer){
            if(this.lastActive.getElapsed() < this.quickShowInterval){
                this.show();
            }else{
                this.showTimer = this.show.defer(this.showDelay, this);
            }
        }else if(!this.hidden && this.autoHide !== false){
            this.show();
        }
    },

    // private
    onTargetOut : function(e){
        if(this.disabled || e.within(this.target.dom, true)){
            return;
        }
        this.clearTimer('show');
        if(this.autoHide !== false){
            this.delayHide();
        }
    },

    // private
    delayHide : function(){
        if(!this.hidden && !this.hideTimer){
            this.hideTimer = this.hide.defer(this.hideDelay, this);
        }
    },

    /**
     * Hides this tooltip if visible.
     */
    hide: function(){
        this.clearTimer('dismiss');
        this.lastActive = new Date();
        Ext.ToolTip.superclass.hide.call(this);
    },

    /**
     * Shows this tooltip at the current event target XY position.
     */
    show : function(){
        this.showAt(this.getTargetXY());
    },

    // inherit docs
    showAt : function(xy){
        this.lastActive = new Date();
        this.clearTimers();
        Ext.ToolTip.superclass.showAt.call(this, xy);
        if(this.dismissDelay && this.autoHide !== false){
            this.dismissTimer = this.hide.defer(this.dismissDelay, this);
        }
    },

    // private
    clearTimer : function(name){
        name = name + 'Timer';
        clearTimeout(this[name]);
        delete this[name];
    },

    // private
    clearTimers : function(){
        this.clearTimer('show');
        this.clearTimer('dismiss');
        this.clearTimer('hide');
    },

    // private
    onShow : function(){
        Ext.ToolTip.superclass.onShow.call(this);
        Ext.getDoc().on('mousedown', this.onDocMouseDown, this);
    },

    // private
    onHide : function(){
        Ext.ToolTip.superclass.onHide.call(this);
        Ext.getDoc().un('mousedown', this.onDocMouseDown, this);
    },

    // private
    onDocMouseDown : function(e){
        if(this.autoHide !== false && !e.within(this.el.dom)){
            this.disable();
            this.enable.defer(100, this);
        }
    },

    // private
    onDisable : function(){
        this.clearTimers();
        this.hide();
    },

    // private
    adjustPosition : function(x, y){
        // keep the position from being under the mouse
        var ay = this.targetXY[1], h = this.getSize().height;
        if(this.constrainPosition && y <= ay && (y+h) >= ay){
            y = ay-h-5;
        }
        return {x : x, y: y};
    },

    // private
    onDestroy : function(){
        Ext.ToolTip.superclass.onDestroy.call(this);
        if(this.target){
            this.target.un('mouseover', this.onTargetOver, this);
            this.target.un('mouseout', this.onTargetOut, this);
            this.target.un('mousemove', this.onMouseMove, this);
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
 * @class Ext.QuickTip
 * @extends Ext.ToolTip
 * A specialized tooltip class for tooltips that can be specified in markup and automatically managed by the global
 * {@link Ext.QuickTips} instance.  See the QuickTips class header for additional usage details and examples.
 * @constructor
 * Create a new Tip
 * @param {Object} config The configuration options
 */
Ext.QuickTip = Ext.extend(Ext.ToolTip, {
    /**
     * @cfg {Mixed} target The target HTMLElement, Ext.Element or id to associate with this quicktip (defaults to the document).
     */
    /**
     * @cfg {Boolean} interceptTitles True to automatically use the element's DOM title value if available (defaults to false).
     */
    interceptTitles : false,

    // private
    tagConfig : {
        namespace : "ext",
        attribute : "qtip",
        width : "qwidth",
        target : "target",
        title : "qtitle",
        hide : "hide",
        cls : "qclass",
        align : "qalign"
    },

    // private
    initComponent : function(){
        this.target = this.target || Ext.getDoc();
        this.targets = this.targets || {};
        Ext.QuickTip.superclass.initComponent.call(this);
    },

    /**
     * Configures a new quick tip instance and assigns it to a target element.  The following config values are
     * supported (for example usage, see the {@link Ext.QuickTips} class header):
     * <div class="mdetail-params"><ul>
     * <li>autoHide</li>
     * <li>cls</li>
     * <li>dismissDelay (overrides the singleton value)</li>
     * <li>target (required)</li>
     * <li>text (required)</li>
     * <li>title</li>
     * <li>width</li></ul></div>
     * @param {Object} config The config object
     */
    register : function(config){
        var cs = Ext.isArray(config) ? config : arguments;
        for(var i = 0, len = cs.length; i < len; i++){
            var c = cs[i];
            var target = c.target;
            if(target){
                if(Ext.isArray(target)){
                    for(var j = 0, jlen = target.length; j < jlen; j++){
                        this.targets[Ext.id(target[j])] = c;
                    }
                } else{
                    this.targets[Ext.id(target)] = c;
                }
            }
        }
    },

    /**
     * Removes this quick tip from its element and destroys it.
     * @param {String/HTMLElement/Element} el The element from which the quick tip is to be removed.
     */
    unregister : function(el){
        delete this.targets[Ext.id(el)];
    },

    // private
    onTargetOver : function(e){
        if(this.disabled){
            return;
        }
        this.targetXY = e.getXY();
        var t = e.getTarget();
        if(!t || t.nodeType !== 1 || t == document || t == document.body){
            return;
        }
        if(this.activeTarget && t == this.activeTarget.el){
            this.clearTimer('hide');
            this.show();
            return;
        }
        if(t && this.targets[t.id]){
            this.activeTarget = this.targets[t.id];
            this.activeTarget.el = t;
            this.delayShow();
            return;
        }
        var ttp, et = Ext.fly(t), cfg = this.tagConfig;
        var ns = cfg.namespace;
        if(this.interceptTitles && t.title){
            ttp = t.title;
            t.qtip = ttp;
            t.removeAttribute("title");
            e.preventDefault();
        } else{
            ttp = t.qtip || et.getAttributeNS(ns, cfg.attribute);
        }
        if(ttp){
            var autoHide = et.getAttributeNS(ns, cfg.hide);
            this.activeTarget = {
                el: t,
                text: ttp,
                width: et.getAttributeNS(ns, cfg.width),
                autoHide: autoHide != "user" && autoHide !== 'false',
                title: et.getAttributeNS(ns, cfg.title),
                cls: et.getAttributeNS(ns, cfg.cls),
                align: et.getAttributeNS(ns, cfg.align)
            };
            this.delayShow();
        }
    },

    // private
    onTargetOut : function(e){
        this.clearTimer('show');
        if(this.autoHide !== false){
            this.delayHide();
        }
    },

    // inherit docs
    showAt : function(xy){
        var t = this.activeTarget;
        if(t){
            if(!this.rendered){
                this.render(Ext.getBody());
                this.activeTarget = t;
            }
            if(t.width){
                this.setWidth(t.width);
                this.body.setWidth(this.adjustBodyWidth(t.width - this.getFrameWidth()));
                this.measureWidth = false;
            } else{
                this.measureWidth = true;
            }
            this.setTitle(t.title || '');
            this.body.update(t.text);
            this.autoHide = t.autoHide;
            this.dismissDelay = t.dismissDelay || this.dismissDelay;
            if(this.lastCls){
                this.el.removeClass(this.lastCls);
                delete this.lastCls;
            }
            if(t.cls){
                this.el.addClass(t.cls);
                this.lastCls = t.cls;
            }
            if(t.align){ // TODO: this doesn't seem to work consistently
                xy = this.el.getAlignToXY(t.el, t.align);
                this.constrainPosition = false;
            } else{
                this.constrainPosition = true;
            }
        }
        Ext.QuickTip.superclass.showAt.call(this, xy);
    },

    // inherit docs
    hide: function(){
        delete this.activeTarget;
        Ext.QuickTip.superclass.hide.call(this);
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
 * @class Ext.QuickTips
 * <p>Provides attractive and customizable tooltips for any element. The QuickTips
 * singleton is used to configure and manage tooltips globally for multiple elements
 * in a generic manner.  To create individual tooltips with maximum customizability,
 * you should consider either {@link Ext.Tip} or {@link Ext.ToolTip}.</p>
 * <p>Quicktips can be configured via tag attributes directly in markup, or by
 * registering quick tips programmatically via the {@link #register} method.</p>
 * <p>The singleton's instance of {@link Ext.QuickTip} is available via
 * {@link #getQuickTip}, and supports all the methods, and all the all the
 * configuration properties of Ext.QuickTip. These settings will apply to all
 * tooltips shown by the singleton.</p>
 * <p>Below is the summary of the configuration properties which can be used.
 * For detailed descriptions see {@link #getQuickTip}</p>
 * <p><b>QuickTips singleton configs (all are optional)</b></p>
 * <div class="mdetail-params"><ul><li>dismissDelay</li>
 * <li>hideDelay</li>
 * <li>maxWidth</li>
 * <li>minWidth</li>
 * <li>showDelay</li>
 * <li>trackMouse</li></ul></div>
 * <p><b>Target element configs (optional unless otherwise noted)</b></p>
 * <div class="mdetail-params"><ul><li>autoHide</li>
 * <li>cls</li>
 * <li>dismissDelay (overrides singleton value)</li>
 * <li>target (required)</li>
 * <li>text (required)</li>
 * <li>title</li>
 * <li>width</li></ul></div>
 * <p>Here is an example showing how some of these config options could be used:</p>
 * <pre><code>
// Init the singleton.  Any tag-based quick tips will start working.
Ext.QuickTips.init();

// Apply a set of config properties to the singleton
Ext.apply(Ext.QuickTips.getQuickTip(), {
    maxWidth: 200,
    minWidth: 100,
    showDelay: 50,
    trackMouse: true
});

// Manually register a quick tip for a specific element
q.register({
    target: 'my-div',
    title: 'My Tooltip',
    text: 'This tooltip was added in code',
    width: 100,
    dismissDelay: 20
});
</code></pre>
 * <p>To register a quick tip in markup, you simply add one or more of the valid QuickTip attributes prefixed with
 * the <b>ext:</b> namespace.  The HTML element itself is automatically set as the quick tip target. Here is the summary
 * of supported attributes (optional unless otherwise noted):</p>
 * <ul><li><b>hide</b>: Specifying "user" is equivalent to setting autoHide = false.  Any other value will be the
 * same as autoHide = true.</li>
 * <li><b>qclass</b>: A CSS class to be applied to the quick tip (equivalent to the 'cls' target element config).</li>
 * <li><b>qtip (required)</b>: The quick tip text (equivalent to the 'text' target element config).</li>
 * <li><b>qtitle</b>: The quick tip title (equivalent to the 'title' target element config).</li>
 * <li><b>qwidth</b>: The quick tip width (equivalent to the 'width' target element config).</li></ul>
 * <p>Here is an example of configuring an HTML element to display a tooltip from markup:</p>
 * <pre><code>
// Add a quick tip to an HTML button
&lt;input type="button" value="OK" ext:qtitle="OK Button" ext:qwidth="100"
     ext:qtip="This is a quick tip from markup!">&lt;/input>
</code></pre>
 * @singleton
 */
Ext.QuickTips = function(){
    var tip, locks = [];
    return {
        /**
         * Initialize the global QuickTips instance and prepare any quick tips.
         * @param {Boolean} autoRender True to render the QuickTips container immediately to preload images. (Defaults to true) 
         */
        init : function(autoRender){
		    if(!tip){
		        if(!Ext.isReady){
		            Ext.onReady(function(){
		                Ext.QuickTips.init(autoRender);
		            });
		            return;
		        }
		        tip = new Ext.QuickTip({elements:'header,body'});
		        if(autoRender !== false){
		            tip.render(Ext.getBody());
		        }
		    }
        },

        /**
         * Enable quick tips globally.
         */
        enable : function(){
            if(tip){
                locks.pop();
                if(locks.length < 1){
                    tip.enable();
                }
            }
        },

        /**
         * Disable quick tips globally.
         */
        disable : function(){
            if(tip){
                tip.disable();
            }
            locks.push(1);
        },

        /**
         * Returns true if quick tips are enabled, else false.
         * @return {Boolean}
         */
        isEnabled : function(){
            return tip !== undefined && !tip.disabled;
        },

        /**
         * Gets the global QuickTips instance.
         */
        getQuickTip : function(){
            return tip;
        },

        /**
         * Configures a new quick tip instance and assigns it to a target element.  See
         * {@link Ext.QuickTip#register} for details.
         * @param {Object} config The config object
         */
        register : function(){
            tip.register.apply(tip, arguments);
        },

        /**
         * Removes any registered quick tip from the target element and destroys it.
         * @param {String/HTMLElement/Element} el The element from which the quick tip is to be removed.
         */
        unregister : function(){
            tip.unregister.apply(tip, arguments);
        },

        /**
         * Alias of {@link #register}.
         * @param {Object} config The config object
         */
        tips :function(){
            tip.register.apply(tip, arguments);
        }
    }
}();
