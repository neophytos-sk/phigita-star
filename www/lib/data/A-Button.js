/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */


/**
 * @class Ext.Button
 * @extends Ext.Component
 * Simple Button class
 * @cfg {String} text The button text
 * @cfg {String} icon The path to an image to display in the button (the image will be set as the background-image
 * CSS property of the button by default, so if you want a mixed icon/text button, set cls:"x-btn-text-icon")
 * @cfg {Function} handler A function called when the button is clicked (can be used instead of click event)
 * @cfg {Object} scope The scope of the handler
 * @cfg {Number} minWidth The minimum width for this button (used to give a set of buttons a common width)
 * @cfg {String/Object} tooltip The tooltip for the button - can be a string or QuickTips config object
 * @cfg {Boolean} hidden True to start hidden (defaults to false)
 * @cfg {Boolean} disabled True to start disabled (defaults to false)
 * @cfg {Boolean} pressed True to start pressed (only if enableToggle = true)
 * @cfg {String} toggleGroup The group this toggle button is a member of (only 1 per group can be pressed, only
 * applies if enableToggle = true)
 * @cfg {Boolean/Object} repeat True to repeat fire the click event while the mouse is down. This can also be
  an {@link Ext.util.ClickRepeater} config object (defaults to false).
 * @constructor
 * Create a new button
 * @param {Object} config The config object
 */
Ext.Button = Ext.extend(Ext.Component, {
    /**
     * Read-only. True if this button is hidden
     * @type Boolean
     */
    hidden : false,
    /**
     * Read-only. True if this button is disabled
     * @type Boolean
     */
    disabled : false,
    /**
     * Read-only. True if this button is pressed (only if enableToggle = true)
     * @type Boolean
     */
    pressed : false,
    /**
     * The Button's owner {@link Ext.Panel} (defaults to undefined, and is set automatically when
     * the Button is added to a container).  Read-only.
     * @type Ext.Panel
     * @property ownerCt
     */

    /**
     * @cfg {Number} tabIndex Set a DOM tabIndex for this button (defaults to undefined)
     */

    /**
     * @cfg {Boolean} allowDepress
     * False to not allow a pressed Button to be depressed (defaults to undefined). Only valid when {@link #enableToggle} is true.
     */

    /**
     * @cfg {Boolean} enableToggle
     * True to enable pressed/not pressed toggling (defaults to false)
     */
    enableToggle: false,
    /**
     * @cfg {Function} toggleHandler
     * Function called when a Button with {@link #enableToggle} set to true is clicked. Two arguments are passed:<ul class="mdetail-params">
     * <li><b>button</b> : Ext.Button<div class="sub-desc">this Button object</div></li>
     * <li><b>state</b> : Boolean<div class="sub-desc">The next state if the Button, true means pressed.</div></li>
     * </ul>
     */
    /**
     * @cfg {Mixed} menu
     * Standard menu attribute consisting of a reference to a menu object, a menu id or a menu config blob (defaults to undefined).
     */
    /**
     * @cfg {String} menuAlign
     * The position to align the menu to (see {@link Ext.Element#alignTo} for more details, defaults to 'tl-bl?').
     */
    menuAlign : "tl-bl?",

    /**
     * @cfg {String} iconCls
     * A css class which sets a background image to be used as the icon for this button
     */
    /**
     * @cfg {String} type
     * submit, reset or button - defaults to 'button'
     */
    type : 'button',

    // private
    menuClassTarget: 'tr',

    /**
     * @cfg {String} clickEvent
     * The type of event to map to the button's event handler (defaults to 'click')
     */
    clickEvent : 'click',

    /**
     * @cfg {Boolean} handleMouseEvents
     * False to disable visual cues on mouseover, mouseout and mousedown (defaults to true)
     */
    handleMouseEvents : true,

    /**
     * @cfg {String} tooltipType
     * The type of tooltip to use. Either "qtip" (default) for QuickTips or "title" for title attribute.
     */
    tooltipType : 'qtip',

    buttonSelector : "button:first",

    /**
     * @cfg {Ext.Template} template (Optional)
     * An {@link Ext.Template} with which to create the Button's main element. This Template must
     * contain numeric substitution parameter 0 if it is to display the text property. Changing the template could
     * require code modifications if required elements (e.g. a button) aren't present.
     */
    /**
     * @cfg {String} cls
     * A CSS class string to apply to the button's main element.
     */

    initComponent : function(){
        Ext.Button.superclass.initComponent.call(this);

        this.addEvents(
            /**
             * @event click
             * Fires when this button is clicked
             * @param {Button} this
             * @param {EventObject} e The click event
             */
            "click",
            /**
             * @event toggle
             * Fires when the "pressed" state of this button changes (only if enableToggle = true)
             * @param {Button} this
             * @param {Boolean} pressed
             */
            "toggle",
            /**
             * @event mouseover
             * Fires when the mouse hovers over the button
             * @param {Button} this
             * @param {Event} e The event object
             */
            'mouseover',
            /**
             * @event mouseout
             * Fires when the mouse exits the button
             * @param {Button} this
             * @param {Event} e The event object
             */
            'mouseout',
            /**
             * @event menushow
             * If this button has a menu, this event fires when it is shown
             * @param {Button} this
             * @param {Menu} menu
             */
            'menushow',
            /**
             * @event menuhide
             * If this button has a menu, this event fires when it is hidden
             * @param {Button} this
             * @param {Menu} menu
             */
            'menuhide',
            /**
             * @event menutriggerover
             * If this button has a menu, this event fires when the mouse enters the menu triggering element
             * @param {Button} this
             * @param {Menu} menu
             * @param {EventObject} e
             */
            'menutriggerover',
            /**
             * @event menutriggerout
             * If this button has a menu, this event fires when the mouse leaves the menu triggering element
             * @param {Button} this
             * @param {Menu} menu
             * @param {EventObject} e
             */
            'menutriggerout'
        );
        if(this.menu){
            this.menu = Ext.menu.MenuMgr.get(this.menu);
        }
        if(typeof this.toggleGroup === 'string'){
            this.enableToggle = true;
        }
    },

    // private
    onRender : function(ct, position){
        if(!this.template){
            if(!Ext.Button.buttonTemplate){
                // hideous table template
                Ext.Button.buttonTemplate = new Ext.Template(
                    '<table border="0" cellpadding="0" cellspacing="0" class="x-btn-wrap"><tbody><tr>',
                    '<td class="x-btn-left"><i>&#160;</i></td><td class="x-btn-center"><em unselectable="on"><button class="x-btn-text" type="{1}">{0}</button></em></td><td class="x-btn-right"><i>&#160;</i></td>',
                    "</tr></tbody></table>");
            }
            this.template = Ext.Button.buttonTemplate;
        }
        var btn, targs = [this.text || '&#160;', this.type];

        if(position){
            btn = this.template.insertBefore(position, targs, true);
        }else{
            btn = this.template.append(ct, targs, true);
        }
        var btnEl = btn.child(this.buttonSelector);
        btnEl.on('focus', this.onFocus, this);
        btnEl.on('blur', this.onBlur, this);

        this.initButtonEl(btn, btnEl);

        if(this.menu){
            this.el.child(this.menuClassTarget).addClass("x-btn-with-menu");
        }
        Ext.ButtonToggleMgr.register(this);
    },

    // private
    initButtonEl : function(btn, btnEl){

        this.el = btn;
        btn.addClass("x-btn");

        if(this.icon){
            btnEl.setStyle('background-image', 'url(' +this.icon +')');
        }
        if(this.iconCls){
            btnEl.addClass(this.iconCls);
            if(!this.cls){
                btn.addClass(this.text ? 'x-btn-text-icon' : 'x-btn-icon');
            }
        }
        if(this.tabIndex !== undefined){
            btnEl.dom.tabIndex = this.tabIndex;
        }
        if(this.tooltip){
            if(typeof this.tooltip == 'object'){
                Ext.QuickTips.register(Ext.apply({
                      target: btnEl.id
                }, this.tooltip));
            } else {
                btnEl.dom[this.tooltipType] = this.tooltip;
            }
        }

        if(this.pressed){
            this.el.addClass("x-btn-pressed");
        }

        if(this.handleMouseEvents){
            btn.on("mouseover", this.onMouseOver, this);
            // new functionality for monitoring on the document level
            //btn.on("mouseout", this.onMouseOut, this);
            btn.on("mousedown", this.onMouseDown, this);
        }

        if(this.menu){
            this.menu.on("show", this.onMenuShow, this);
            this.menu.on("hide", this.onMenuHide, this);
        }

        if(this.id){
            this.el.dom.id = this.el.id = this.id;
        }

        if(this.repeat){
            var repeater = new Ext.util.ClickRepeater(btn,
                typeof this.repeat == "object" ? this.repeat : {}
            );
            repeater.on("click", this.onClick,  this);
        }

        btn.on(this.clickEvent, this.onClick, this);
    },

    // private
    afterRender : function(){
        Ext.Button.superclass.afterRender.call(this);
        if(Ext.isIE6){
            this.autoWidth.defer(1, this);
        }else{
            this.autoWidth();
        }
    },

    /**
     * Sets the CSS class that provides a background image to use as the button's icon.  This method also changes
     * the value of the {@link iconCls} config internally.
     * @param {String} cls The CSS class providing the icon image
     */
    setIconClass : function(cls){
        if(this.el){
            this.el.child(this.buttonSelector).replaceClass(this.iconCls, cls);
        }
        this.iconCls = cls;
    },

    // private
    beforeDestroy: function(){
    	if(this.rendered){
	        var btn = this.el.child(this.buttonSelector);
	        if(btn){
	            btn.removeAllListeners();
	        }
	    }
        if(this.menu){
            Ext.destroy(this.menu);
        }
    },

    // private
    onDestroy : function(){
        if(this.rendered){
            Ext.ButtonToggleMgr.unregister(this);
        }
    },

    // private
    autoWidth : function(){
        if(this.el){
            this.el.setWidth("auto");
            if(Ext.isIE7 && Ext.isStrict){
                var ib = this.el.child(this.buttonSelector);
                if(ib && ib.getWidth() > 20){
                    ib.clip();
                    ib.setWidth(Ext.util.TextMetrics.measure(ib, this.text).width+ib.getFrameWidth('lr'));
                }
            }
            if(this.minWidth){
                if(this.el.getWidth() < this.minWidth){
                    this.el.setWidth(this.minWidth);
                }
            }
        }
    },

    /**
     * Assigns this button's click handler
     * @param {Function} handler The function to call when the button is clicked
     * @param {Object} scope (optional) Scope for the function passed in
     */
    setHandler : function(handler, scope){
        this.handler = handler;
        this.scope = scope;
    },

    /**
     * Sets this button's text
     * @param {String} text The button text
     */
    setText : function(text){
        this.text = text;
        if(this.el){
            this.el.child("td.x-btn-center " + this.buttonSelector).update(text);
        }
        this.autoWidth();
    },

    /**
     * Gets the text for this button
     * @return {String} The button text
     */
    getText : function(){
        return this.text;
    },

    /**
     * If a state it passed, it becomes the pressed state otherwise the current state is toggled.
     * @param {Boolean} state (optional) Force a particular state
     */
    toggle : function(state){
        state = state === undefined ? !this.pressed : state;
        if(state != this.pressed){
            if(state){
                this.el.addClass("x-btn-pressed");
                this.pressed = true;
                this.fireEvent("toggle", this, true);
            }else{
                this.el.removeClass("x-btn-pressed");
                this.pressed = false;
                this.fireEvent("toggle", this, false);
            }
            if(this.toggleHandler){
                this.toggleHandler.call(this.scope || this, this, state);
            }
        }
    },

    /**
     * Focus the button
     */
    focus : function(){
        this.el.child(this.buttonSelector).focus();
    },

    // private
    onDisable : function(){
        if(this.el){
            if(!Ext.isIE6 || !this.text){
                this.el.addClass(this.disabledClass);
            }
            this.el.dom.disabled = true;
        }
        this.disabled = true;
    },

    // private
    onEnable : function(){
        if(this.el){
            if(!Ext.isIE6 || !this.text){
                this.el.removeClass(this.disabledClass);
            }
            this.el.dom.disabled = false;
        }
        this.disabled = false;
    },

    /**
     * Show this button's menu (if it has one)
     */
    showMenu : function(){
        if(this.menu){
            this.menu.show(this.el, this.menuAlign);
        }
        return this;
    },

    /**
     * Hide this button's menu (if it has one)
     */
    hideMenu : function(){
        if(this.menu){
            this.menu.hide();
        }
        return this;
    },

    /**
     * Returns true if the button has a menu and it is visible
     * @return {Boolean}
     */
    hasVisibleMenu : function(){
        return this.menu && this.menu.isVisible();
    },

    // private
    onClick : function(e){
        if(e){
            e.preventDefault();
        }
        if(e.button != 0){
            return;
        }
        if(!this.disabled){
            if(this.enableToggle && (this.allowDepress !== false || !this.pressed)){
                this.toggle();
            }
            if(this.menu && !this.menu.isVisible() && !this.ignoreNextClick){
                this.showMenu();
            }
            this.fireEvent("click", this, e);
            if(this.handler){
                //this.el.removeClass("x-btn-over");
                this.handler.call(this.scope || this, this, e);
            }
        }
    },

    // private
    isMenuTriggerOver : function(e, internal){
        return this.menu && !internal;
    },

    // private
    isMenuTriggerOut : function(e, internal){
        return this.menu && !internal;
    },

    // private
    onMouseOver : function(e){
        if(!this.disabled){
            var internal = e.within(this.el,  true);
            if(!internal){
                this.el.addClass("x-btn-over");
                if(!this.monitoringMouseOver){
                    Ext.getDoc().on('mouseover', this.monitorMouseOver, this);
                    this.monitoringMouseOver = true;
                }
                this.fireEvent('mouseover', this, e);
            }
            if(this.isMenuTriggerOver(e, internal)){
                this.fireEvent('menutriggerover', this, this.menu, e);
            }
        }
    },

    // private
    monitorMouseOver : function(e){
        if(e.target != this.el.dom && !e.within(this.el)){
            if(this.monitoringMouseOver){
                Ext.getDoc().un('mouseover', this.monitorMouseOver, this);
                this.monitoringMouseOver = false;
            }
            this.onMouseOut(e);
        }
    },

    // private
    onMouseOut : function(e){
        var internal = e.within(this.el) && e.target != this.el.dom;
        this.el.removeClass("x-btn-over");
        this.fireEvent('mouseout', this, e);
        if(this.isMenuTriggerOut(e, internal)){
            this.fireEvent('menutriggerout', this, this.menu, e);
        }
    },
    // private
    onFocus : function(e){
        if(!this.disabled){
            this.el.addClass("x-btn-focus");
        }
    },
    // private
    onBlur : function(e){
        this.el.removeClass("x-btn-focus");
    },

    // private
    getClickEl : function(e, isUp){
       return this.el;
    },

    // private
    onMouseDown : function(e){
        if(!this.disabled && e.button == 0){
            this.getClickEl(e).addClass("x-btn-click");
            Ext.getDoc().on('mouseup', this.onMouseUp, this);
        }
    },
    // private
    onMouseUp : function(e){
        if(e.button == 0){
            this.getClickEl(e, true).removeClass("x-btn-click");
            Ext.getDoc().un('mouseup', this.onMouseUp, this);
        }
    },
    // private
    onMenuShow : function(e){
        this.ignoreNextClick = 0;
        this.el.addClass("x-btn-menu-active");
        this.fireEvent('menushow', this, this.menu);
    },
    // private
    onMenuHide : function(e){
        this.el.removeClass("x-btn-menu-active");
        this.ignoreNextClick = this.restoreClick.defer(250, this);
        this.fireEvent('menuhide', this, this.menu);
    },

    // private
    restoreClick : function(){
        this.ignoreNextClick = 0;
    }



    /**
     * @cfg {String} autoEl @hide
     */
});
Ext.reg('button', Ext.Button);

// Private utility class used by Button
Ext.ButtonToggleMgr = function(){
   var groups = {};

   function toggleGroup(btn, state){
       if(state){
           var g = groups[btn.toggleGroup];
           for(var i = 0, l = g.length; i < l; i++){
               if(g[i] != btn){
                   g[i].toggle(false);
               }
           }
       }
   }

   return {
       register : function(btn){
           if(!btn.toggleGroup){
               return;
           }
           var g = groups[btn.toggleGroup];
           if(!g){
               g = groups[btn.toggleGroup] = [];
           }
           g.push(btn);
           btn.on("toggle", toggleGroup);
       },

       unregister : function(btn){
           if(!btn.toggleGroup){
               return;
           }
           var g = groups[btn.toggleGroup];
           if(g){
               g.remove(btn);
               btn.un("toggle", toggleGroup);
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
 * @class Ext.SplitButton
 * @extends Ext.Button
 * A split button that provides a built-in dropdown arrow that can fire an event separately from the default
 * click event of the button.  Typically this would be used to display a dropdown menu that provides additional
 * options to the primary button action, but any custom handler can provide the arrowclick implementation.  Example usage:
 * <pre><code>
// display a dropdown menu:
new Ext.SplitButton({
	renderTo: 'button-ct', // the container id
   	text: 'Options',
   	handler: optionsHandler, // handle a click on the button itself
   	menu: new Ext.menu.Menu({
        items: [
        	// these items will render as dropdown menu items when the arrow is clicked:
	        {text: 'Item 1', handler: item1Handler},
	        {text: 'Item 2', handler: item2Handler}
        ]
   	})
});

// Instead of showing a menu, you provide any type of custom
// functionality you want when the dropdown arrow is clicked:
new Ext.SplitButton({
	renderTo: 'button-ct',
   	text: 'Options',
   	handler: optionsHandler,
   	arrowHandler: myCustomHandler
});
</code></pre>
 * @cfg {Function} arrowHandler A function called when the arrow button is clicked (can be used instead of click event)
 * @cfg {String} arrowTooltip The title attribute of the arrow
 * @constructor
 * Create a new menu button
 * @param {Object} config The config object
 */
Ext.SplitButton = Ext.extend(Ext.Button, {
	// private
    arrowSelector : 'button:last',

    // private
    initComponent : function(){
        Ext.SplitButton.superclass.initComponent.call(this);
        /**
         * @event arrowclick
         * Fires when this button's arrow is clicked
         * @param {MenuButton} this
         * @param {EventObject} e The click event
         */
        this.addEvents("arrowclick");
    },

    // private
    onRender : function(ct, position){
        // this is one sweet looking template!
        var tpl = new Ext.Template(
            '<table cellspacing="0" class="x-btn-menu-wrap x-btn"><tr><td>',
            '<table cellspacing="0" class="x-btn-wrap x-btn-menu-text-wrap"><tbody>',
            '<tr><td class="x-btn-left"><i>&#160;</i></td><td class="x-btn-center"><button class="x-btn-text" type="{1}">{0}</button></td></tr>',
            "</tbody></table></td><td>",
            '<table cellspacing="0" class="x-btn-wrap x-btn-menu-arrow-wrap"><tbody>',
            '<tr><td class="x-btn-center"><button class="x-btn-menu-arrow-el" type="button">&#160;</button></td><td class="x-btn-right"><i>&#160;</i></td></tr>',
            "</tbody></table></td></tr></table>"
        );
        var btn, targs = [this.text || '&#160;', this.type];
        if(position){
            btn = tpl.insertBefore(position, targs, true);
        }else{
            btn = tpl.append(ct, targs, true);
        }
        var btnEl = btn.child(this.buttonSelector);

        this.initButtonEl(btn, btnEl);
        this.arrowBtnTable = btn.child("table:last");
        if(this.arrowTooltip){
            btn.child(this.arrowSelector).dom[this.tooltipType] = this.arrowTooltip;
        }
    },

    // private
    autoWidth : function(){
        if(this.el){
            var tbl = this.el.child("table:first");
            var tbl2 = this.el.child("table:last");
            this.el.setWidth("auto");
            tbl.setWidth("auto");
            if(Ext.isIE7 && Ext.isStrict){
                var ib = this.el.child(this.buttonSelector);
                if(ib && ib.getWidth() > 20){
                    ib.clip();
                    ib.setWidth(Ext.util.TextMetrics.measure(ib, this.text).width+ib.getFrameWidth('lr'));
                }
            }
            if(this.minWidth){
                if((tbl.getWidth()+tbl2.getWidth()) < this.minWidth){
                    tbl.setWidth(this.minWidth-tbl2.getWidth());
                }
            }
            this.el.setWidth(tbl.getWidth()+tbl2.getWidth());
        } 
    },

    /**
     * Sets this button's arrow click handler.
     * @param {Function} handler The function to call when the arrow is clicked
     * @param {Object} scope (optional) Scope for the function passed above
     */
    setArrowHandler : function(handler, scope){
        this.arrowHandler = handler;
        this.scope = scope;  
    },

    // private
    onClick : function(e){
        e.preventDefault();
        if(!this.disabled){
            if(e.getTarget(".x-btn-menu-arrow-wrap")){
                if(this.menu && !this.menu.isVisible() && !this.ignoreNextClick){
                    this.showMenu();
                }
                this.fireEvent("arrowclick", this, e);
                if(this.arrowHandler){
                    this.arrowHandler.call(this.scope || this, this, e);
                }
            }else{
                if(this.enableToggle){
                    this.toggle();
                }
                this.fireEvent("click", this, e);
                if(this.handler){
                    this.handler.call(this.scope || this, this, e);
                }
            }
        }
    },

    // private
    getClickEl : function(e, isUp){
        if(!isUp){
            return (this.lastClickEl = e.getTarget("table", 10, true));
        }
        return this.lastClickEl;
    },

    // private
    onDisable : function(){
        if(this.el){
            if(!Ext.isIE6){
                this.el.addClass("x-item-disabled");
            }
            this.el.child(this.buttonSelector).dom.disabled = true;
            this.el.child(this.arrowSelector).dom.disabled = true;
        }
        this.disabled = true;
    },

    // private
    onEnable : function(){
        if(this.el){
            if(!Ext.isIE6){
                this.el.removeClass("x-item-disabled");
            }
            this.el.child(this.buttonSelector).dom.disabled = false;
            this.el.child(this.arrowSelector).dom.disabled = false;
        }
        this.disabled = false;
    },

    // private
    isMenuTriggerOver : function(e){
        return this.menu && e.within(this.arrowBtnTable) && !e.within(this.arrowBtnTable, true);
    },

    // private
    isMenuTriggerOut : function(e, internal){
        return this.menu && !e.within(this.arrowBtnTable);
    },

    // private
    onDestroy : function(){
        Ext.destroy(this.arrowBtnTable);
        Ext.SplitButton.superclass.onDestroy.call(this);
    }
});

// backwards compat
Ext.MenuButton = Ext.SplitButton;


Ext.reg('splitbutton', Ext.SplitButton);
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.CycleButton
 * @extends Ext.SplitButton
 * A specialized SplitButton that contains a menu of {@link Ext.menu.CheckItem} elements.  The button automatically
 * cycles through each menu item on click, raising the button's {@link #change} event (or calling the button's
 * {@link #changeHandler} function, if supplied) for the active menu item. Clicking on the arrow section of the
 * button displays the dropdown menu just like a normal SplitButton.  Example usage:
 * <pre><code>
var btn = new Ext.CycleButton({
    showText: true,
    prependText: 'View as ',
    items: [{
        text:'text only',
        iconCls:'view-text',
        checked:true
    },{
        text:'HTML',
        iconCls:'view-html'
    }],
    changeHandler:function(btn, item){
        Ext.Msg.alert('Change View', item.text);
    }
});
</code></pre>
 * @constructor
 * Create a new split button
 * @param {Object} config The config object
 */
Ext.CycleButton = Ext.extend(Ext.SplitButton, {
    /**
     * @cfg {Array} items An array of {@link Ext.menu.CheckItem} <b>config</b> objects to be used when creating the
     * button's menu items (e.g., {text:'Foo', iconCls:'foo-icon'})
     */
    /**
     * @cfg {Boolean} showText True to display the active item's text as the button text (defaults to false)
     */
    /**
     * @cfg {String} prependText A static string to prepend before the active item's text when displayed as the
     * button's text (only applies when showText = true, defaults to '')
     */
    /**
     * @cfg {Function} changeHandler A callback function that will be invoked each time the active menu
     * item in the button's menu has changed.  If this callback is not supplied, the SplitButton will instead
     * fire the {@link #change} event on active item change.  The changeHandler function will be called with the
     * following argument list: (SplitButton this, Ext.menu.CheckItem item)
     */
	/**
	 * @cfg {String} forceIcon A css class which sets an image to be used as the static icon for this button.  This
	 * icon will always be displayed regardless of which item is selected in the dropdown list.  This overrides the 
	 * default behavior of changing the button's icon to match the selected item's icon on change.
	 */

    // private
    getItemText : function(item){
        if(item && this.showText === true){
            var text = '';
            if(this.prependText){
                text += this.prependText;
            }
            text += item.text;
            return text;
        }
        return undefined;
    },

    /**
     * Sets the button's active menu item.
     * @param {Ext.menu.CheckItem} item The item to activate
     * @param {Boolean} suppressEvent True to prevent the button's change event from firing (defaults to false)
     */
    setActiveItem : function(item, suppressEvent){
        if(typeof item != 'object'){
            item = this.menu.items.get(item);
        }
        if(item){
            if(!this.rendered){
                this.text = this.getItemText(item);
                this.iconCls = item.iconCls;
            }else{
                var t = this.getItemText(item);
                if(t){
                    this.setText(t);
                }
                this.setIconClass(item.iconCls);
            }
            this.activeItem = item;
            if(!item.checked){
                item.setChecked(true, true);
            }
            if(this.forceIcon){
                this.setIconClass(this.forceIcon);
            }
            if(!suppressEvent){
                this.fireEvent('change', this, item);
            }
        }
    },

    /**
     * Gets the currently active menu item.
     * @return {Ext.menu.CheckItem} The active item
     */
    getActiveItem : function(){
        return this.activeItem;
    },

    // private
    initComponent : function(){
        this.addEvents(
            /**
             * @event change
             * Fires after the button's active menu item has changed.  Note that if a {@link #changeHandler} function
             * is set on this CycleButton, it will be called instead on active item change and this change event will
             * not be fired.
             * @param {Ext.CycleButton} this
             * @param {Ext.menu.CheckItem} item The menu item that was selected
             */
            "change"
        );

        if(this.changeHandler){
            this.on('change', this.changeHandler, this.scope||this);
            delete this.changeHandler;
        }

        this.itemCount = this.items.length;

        this.menu = {cls:'x-cycle-menu', items:[]};
        var checked;
        for(var i = 0, len = this.itemCount; i < len; i++){
            var item = this.items[i];
            item.group = item.group || this.id;
            item.itemIndex = i;
            item.checkHandler = this.checkHandler;
            item.scope = this;
            item.checked = item.checked || false;
            this.menu.items.push(item);
            if(item.checked){
                checked = item;
            }
        }
        this.setActiveItem(checked, true);
        Ext.CycleButton.superclass.initComponent.call(this);

        this.on('click', this.toggleSelected, this);
    },

    // private
    checkHandler : function(item, pressed){
        if(pressed){
            this.setActiveItem(item);
        }
    },

    /**
     * This is normally called internally on button click, but can be called externally to advance the button's
     * active item programmatically to the next one in the menu.  If the current item is the last one in the menu
     * the active item will be set to the first item in the menu.
     */
    toggleSelected : function(){
        this.menu.render();
		
		var nextIdx, checkItem;
		for (var i = 1; i < this.itemCount; i++) {
			nextIdx = (this.activeItem.itemIndex + i) % this.itemCount;
			// check the potential item
			checkItem = this.menu.items.itemAt(nextIdx);
			// if its not disabled then check it.
			if (!checkItem.disabled) {
				checkItem.setChecked(true);
				break;
			}
		}
    }
});
Ext.reg('cycle', Ext.CycleButton);
