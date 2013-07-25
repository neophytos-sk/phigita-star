/*
 * Ext JS Library 2.1
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
     * @return {Ext.ToolbarItem}
     */
    addField : function(field){
        var td = this.nextBlock();
        field.render(td);
        var ti = new T.Item(td.firstChild);
        ti.render(td);
        this.items.add(ti);
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
			        {text: 'Item 2', handler: item2Handler},
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
 * Ext JS Library 2.1
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
            if(pageNum = this.readPage(d)){
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
        this.store.load({params:o});
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
