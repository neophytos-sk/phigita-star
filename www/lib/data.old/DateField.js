/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.DateField
 * @extends Ext.form.TriggerField
 * Provides a date input field with a {@link Ext.DatePicker} dropdown and automatic date validation.
* @constructor
* Create a new DateField
* @param {Object} config
 */
Ext.form.DateField = Ext.extend(Ext.form.TriggerField,  {
    /**
     * @cfg {String} format
     * The default date format string which can be overriden for localization support.  The format must be
     * valid according to {@link Date#parseDate} (defaults to 'm/d/y').
     */
    format : "m/d/y",
    /**
     * @cfg {String} altFormats
     * Multiple date formats separated by "|" to try when parsing a user input value and it doesn't match the defined
     * format (defaults to 'm/d/Y|m-d-y|m-d-Y|m/d|m-d|d').
     */
    altFormats : "m/d/Y|n/j/Y|n/j/y|m/j/y|n/d/y|m/j/Y|n/d/Y|m-d-y|m-d-Y|m/d|m-d|md|mdy|mdY|d|Y-m-d",
    /**
     * @cfg {Array} disabledDays
     * An array of days to disable, 0 based. For example, [0, 6] disables Sunday and Saturday (defaults to null).
     */
    disabledDays : null,
    /**
     * @cfg {String} disabledDaysText
     * The tooltip to display when the date falls on a disabled day (defaults to 'Disabled')
     */
    disabledDaysText : "Disabled",
    /**
     * @cfg {Array} disabledDates
     * An array of "dates" to disable, as strings. These strings will be used to build a dynamic regular
     * expression so they are very powerful. Some examples:
     * <ul>
     * <li>["03/08/2003", "09/16/2003"] would disable those exact dates</li>
     * <li>["03/08", "09/16"] would disable those days for every year</li>
     * <li>["^03/08"] would only match the beginning (useful if you are using short years)</li>
     * <li>["03/../2006"] would disable every day in March 2006</li>
     * <li>["^03"] would disable every day in every March</li>
     * </ul>
     * In order to support regular expressions, if you are using a date format that has "." in it, you will have to
     * escape the dot when restricting dates. For example: ["03\\.08\\.03"].
     */
    disabledDates : null,
    /**
     * @cfg {String} disabledDatesText
     * The tooltip text to display when the date falls on a disabled date (defaults to 'Disabled')
     */
    disabledDatesText : "Disabled",
    /**
     * @cfg {Date/String} minValue
     * The minimum allowed date. Can be either a Javascript date object or a string date in a
     * valid format (defaults to null).
     */
    minValue : null,
    /**
     * @cfg {Date/String} maxValue
     * The maximum allowed date. Can be either a Javascript date object or a string date in a
     * valid format (defaults to null).
     */
    maxValue : null,
    /**
     * @cfg {String} minText
     * The error text to display when the date in the cell is before minValue (defaults to
     * 'The date in this field must be after {minValue}').
     */
    minText : "The date in this field must be equal to or after {0}",
    /**
     * @cfg {String} maxText
     * The error text to display when the date in the cell is after maxValue (defaults to
     * 'The date in this field must be before {maxValue}').
     */
    maxText : "The date in this field must be equal to or before {0}",
    /**
     * @cfg {String} invalidText
     * The error text to display when the date in the field is invalid (defaults to
     * '{value} is not a valid date - it must be in the format {format}').
     */
    invalidText : "{0} is not a valid date - it must be in the format {1}",
    /**
     * @cfg {String} triggerClass
     * An additional CSS class used to style the trigger button.  The trigger will always get the
     * class 'x-form-trigger' and triggerClass will be <b>appended</b> if specified (defaults to 'x-form-date-trigger'
     * which displays a calendar icon).
     */
    triggerClass : 'x-form-date-trigger',
    /**
     * @cfg {String/Object} autoCreate
     * A DomHelper element spec, or true for a default element spec (defaults to
     * {tag: "input", type: "text", size: "10", autocomplete: "off"})
     */

    // private
    defaultAutoCreate : {tag: "input", type: "text", size: "10", autocomplete: "off"},

    initComponent : function(){
        Ext.form.DateField.superclass.initComponent.call(this);
        if(typeof this.minValue == "string"){
            this.minValue = this.parseDate(this.minValue);
        }
        if(typeof this.maxValue == "string"){
            this.maxValue = this.parseDate(this.maxValue);
        }
        this.ddMatch = null;
        if(this.disabledDates){
            var dd = this.disabledDates;
            var re = "(?:";
            for(var i = 0; i < dd.length; i++){
                re += dd[i];
                if(i != dd.length-1) re += "|";
            }
            this.ddMatch = new RegExp(re + ")");
        }
    },

    // private
    validateValue : function(value){
        value = this.formatDate(value);
        if(!Ext.form.DateField.superclass.validateValue.call(this, value)){
            return false;
        }
        if(value.length < 1){ // if it's blank and textfield didn't flag it then it's valid
             return true;
        }
        var svalue = value;
        value = this.parseDate(value);
        if(!value){
            this.markInvalid(String.format(this.invalidText, svalue, this.format));
            return false;
        }
        var time = value.getTime();
        if(this.minValue && time < this.minValue.getTime()){
            this.markInvalid(String.format(this.minText, this.formatDate(this.minValue)));
            return false;
        }
        if(this.maxValue && time > this.maxValue.getTime()){
            this.markInvalid(String.format(this.maxText, this.formatDate(this.maxValue)));
            return false;
        }
        if(this.disabledDays){
            var day = value.getDay();
            for(var i = 0; i < this.disabledDays.length; i++) {
            	if(day === this.disabledDays[i]){
            	    this.markInvalid(this.disabledDaysText);
                    return false;
            	}
            }
        }
        var fvalue = this.formatDate(value);
        if(this.ddMatch && this.ddMatch.test(fvalue)){
            this.markInvalid(String.format(this.disabledDatesText, fvalue));
            return false;
        }
        return true;
    },

    // private
    // Provides logic to override the default TriggerField.validateBlur which just returns true
    validateBlur : function(){
        return !this.menu || !this.menu.isVisible();
    },

    /**
     * Returns the current date value of the date field.
     * @return {Date} The date value
     */
    getValue : function(){
        return this.parseDate(Ext.form.DateField.superclass.getValue.call(this)) || "";
    },

    /**
     * Sets the value of the date field.  You can pass a date object or any string that can be parsed into a valid
     * date, using DateField.format as the date format, according to the same rules as {@link Date#parseDate}
     * (the default format used is "m/d/y").
     * <br />Usage:
     * <pre><code>
//All of these calls set the same date value (May 4, 2006)

//Pass a date object:
var dt = new Date('5/4/06');
dateField.setValue(dt);

//Pass a date string (default format):
dateField.setValue('5/4/06');

//Pass a date string (custom format):
dateField.format = 'Y-m-d';
dateField.setValue('2006-5-4');
</code></pre>
     * @param {String/Date} date The date or valid date string
     */
    setValue : function(date){
        Ext.form.DateField.superclass.setValue.call(this, this.formatDate(this.parseDate(date)));
    },

    // private
    parseDate : function(value){
        if(!value || Ext.isDate(value)){
            return value;
        }
        var v = Date.parseDate(value, this.format);
        if(!v && this.altFormats){
            if(!this.altFormatsArray){
                this.altFormatsArray = this.altFormats.split("|");
            }
            for(var i = 0, len = this.altFormatsArray.length; i < len && !v; i++){
                v = Date.parseDate(value, this.altFormatsArray[i]);
            }
        }
        return v;
    },

    // private
    onDestroy : function(){
        if(this.menu) {
            this.menu.destroy();
        }
        if(this.wrap){
            this.wrap.remove();
        }
        Ext.form.DateField.superclass.onDestroy.call(this);
    },

    // private
    formatDate : function(date){
        return Ext.isDate(date) ? date.dateFormat(this.format) : date;
    },

    // private
    menuListeners : {
        select: function(m, d){
            this.setValue(d);
        },
        show : function(){ // retain focus styling
            this.onFocus();
        },
        hide : function(){
            this.focus.defer(10, this);
            var ml = this.menuListeners;
            this.menu.un("select", ml.select,  this);
            this.menu.un("show", ml.show,  this);
            this.menu.un("hide", ml.hide,  this);
        }
    },

    // private
    // Implements the default empty TriggerField.onTriggerClick function to display the DatePicker
    onTriggerClick : function(){
        if(this.disabled){
            return;
        }
        if(this.menu == null){
            this.menu = new Ext.menu.DateMenu();
        }
        Ext.apply(this.menu.picker,  {
            minDate : this.minValue,
            maxDate : this.maxValue,
            disabledDatesRE : this.ddMatch,
            disabledDatesText : this.disabledDatesText,
            disabledDays : this.disabledDays,
            disabledDaysText : this.disabledDaysText,
            format : this.format,
            minText : String.format(this.minText, this.formatDate(this.minValue)),
            maxText : String.format(this.maxText, this.formatDate(this.maxValue))
        });
        this.menu.on(Ext.apply({}, this.menuListeners, {
            scope:this
        }));
        this.menu.picker.setValue(this.getValue() || new Date());
        this.menu.show(this.el, "tl-bl?");
    },

    beforeBlur : function(){
        var v = this.parseDate(this.getRawValue());
        if(v){
            this.setValue(v);
        }
    }

    /** 
     * @cfg {Boolean} grow @hide
     */
    /**
     * @cfg {Number} growMin @hide
     */
    /**
     * @cfg {Number} growMax @hide
     */
    /**
     * @hide
     * @method autoSize
     */
});
Ext.reg('datefield', Ext.form.DateField);
/*
 * Ext JS Library 2.0.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.TimeField
 * @extends Ext.form.ComboBox
 * Provides a time input field with a time dropdown and automatic time validation.
* @constructor
* Create a new TimeField
* @param {Object} config
 */
Ext.form.TimeField = Ext.extend(Ext.form.ComboBox, {
    /**
     * @cfg {Date/String} minValue
     * The minimum allowed time. Can be either a Javascript date object or a string date in a
     * valid format (defaults to null).
     */
    minValue : null,
    /**
     * @cfg {Date/String} maxValue
     * The maximum allowed time. Can be either a Javascript date object or a string date in a
     * valid format (defaults to null).
     */
    maxValue : null,
    /**
     * @cfg {String} minText
     * The error text to display when the date in the cell is before minValue (defaults to
     * 'The time in this field must be equal to or after {0}').
     */
    minText : "The time in this field must be equal to or after {0}",
    /**
     * @cfg {String} maxText
     * The error text to display when the time is after maxValue (defaults to
     * 'The time in this field must be equal to or before {0}').
     */
    maxText : "The time in this field must be equal to or before {0}",
    /**
     * @cfg {String} invalidText
     * The error text to display when the time in the field is invalid (defaults to
     * '{value} is not a valid time - it must be in the format {format}').
     */
    invalidText : "{0} is not a valid time",
    /**
     * @cfg {String} format
     * The default date format string which can be overriden for localization support.  The format must be
     * valid according to {@link Date#parseDate} (defaults to 'm/d/y').
     */
    format : "g:i A",
    /**
     * @cfg {String} altFormats
     * Multiple date formats separated by "|" to try when parsing a user input value and it doesn't match the defined
     * format (defaults to 'm/d/Y|m-d-y|m-d-Y|m/d|m-d|d').
     */
    altFormats : "g:ia|g:iA|g:i a|g:i A|h:i|g:i|H:i|ga|ha|gA|h a|g a|g A|gi|hi|gia|hia|g|H",
    /**
     * @cfg {Number} increment
     * The number of minutes between each time value in the list (defaults to 15).
     */
    increment: 15,

    // private override
    mode: 'local',
    // private override
    triggerAction: 'all',
    // private override
    typeAhead: false,

    // private
    initComponent : function(){
        Ext.form.TimeField.superclass.initComponent.call(this);

        if(typeof this.minValue == "string"){
            this.minValue = this.parseDate(this.minValue);
        }
        if(typeof this.maxValue == "string"){
            this.maxValue = this.parseDate(this.maxValue);
        }

        if(!this.store){
            var min = this.parseDate(this.minValue);
            if(!min){
                min = new Date().clearTime();
            }
            var max = this.parseDate(this.maxValue);
            if(!max){
                max = new Date().clearTime().add('mi', (24 * 60) - 1);
            }
            var times = [];
            while(min <= max){
                times.push([min.dateFormat(this.format)]);
                min = min.add('mi', this.increment);
            }
            this.store = new Ext.data.SimpleStore({
                fields: ['text'],
                data : times
            });
            this.displayField = 'text';
        }
    },

    // inherited docs
    getValue : function(){
        var v = Ext.form.TimeField.superclass.getValue.call(this);
        return this.formatDate(this.parseDate(v)) || '';
    },

    // inherited docs
    setValue : function(value){
        Ext.form.TimeField.superclass.setValue.call(this, this.formatDate(this.parseDate(value)));
    },

    // private overrides
    validateValue : Ext.form.DateField.prototype.validateValue,
    parseDate : Ext.form.DateField.prototype.parseDate,
    formatDate : Ext.form.DateField.prototype.formatDate,

    // private
    beforeBlur : function(){
        var v = this.parseDate(this.getRawValue());
        if(v){
            this.setValue(v.dateFormat(this.format));
        }
    }

    /**
     * @cfg {Boolean} grow @hide
     */
    /**
     * @cfg {Number} growMin @hide
     */
    /**
     * @cfg {Number} growMax @hide
     */
    /**
     * @hide
     * @method autoSize
     */
});
Ext.reg('timefield', Ext.form.TimeField);
// vim: ts=4:sw=4:nu:fdc=4:nospell
/**
 * Ext.ux.form.DateTime Extension Class for Ext 2.x Library
 *
 * @author    Ing. Jozef Sakalos
 * @copyright (c) 2008, Ing. Jozef Sakalos
 * @version $Id: Ext.ux.form.DateTime.js 11 2008-02-22 17:13:52Z jozo $
 *
 * @license Ext.ux.form.DateTime is licensed under the terms of
 * the Open Source LGPL 3.0 license.  Commercial use is permitted to the extent
 * that the code/component(s) do NOT become part of another Open Source or Commercially
 * licensed development library or toolkit without explicit permission.
 * 
 * License details: http://www.gnu.org/licenses/lgpl.html
 */

Ext.ns('Ext.ux.form');

/**
 * @class Ext.ux.form.DateTime
 * @extends Ext.form.Field
 */
Ext.ux.form.DateTime = Ext.extend(Ext.form.Field, {
    /**
     * @cfg {String/Object} defaultAutoCreate DomHelper element spec
     * Let superclass to create hidden field instead of textbox. Hidden will be submittend to server
     */
     defaultAutoCreate:{tag:'input', type:'hidden'}
    /**
     * @cfg {Number} timeWidth Width of time field in pixels (defaults to 100)
     */
    ,timeWidth:100
    /**
     * @cfg {String} dtSeparator Date - Time separator. Used to split date and time (defaults to ' ' (space))
     */
    ,dtSeparator:' '
    /**
     * @cfg {String} hiddenFormat Format of datetime used to store value in hidden field
     * and submitted to server (defaults to 'Y-m-d H:i:s' that is mysql format)
     */
    ,hiddenFormat:'Y-m-d H:i:s'
    /**
     * @cfg {Boolean} otherToNow Set other field to now() if not explicly filled in (defaults to true)
     */
    ,otherToNow:true
    /**
     * @cfg {Boolean} emptyToNow Set field value to now if on attempt to set empty value.
     * If it is true then setValue() sets value of field to current date and time (defaults to false)
    /**
     * @cfg {String} timePosition Where the time field should be rendered. 'right' is suitable for forms
     * and 'below' is suitable if the field is used as the grid editor (defaults to 'right')
     */
    ,timePosition:'right' // valid values:'below', 'right'
    /**
     * @cfg {String} dateFormat Format of DateField. Can be localized. (defaults to 'm/y/d')
     */
    ,dateFormat:'m/d/y'
    /**
     * @cfg {String} timeFormat Format of TimeField. Can be localized. (defaults to 'g:i A')
     */
    ,timeFormat:'g:i A'
    /**
     * @cfg {Object} dateConfig Config for DateField constructor.
     */
    /**
     * @cfg {Object} timeConfig Config for TimeField constructor.
     */

    // {{{
    /**
     * private
     * creates DateField and TimeField and installs the necessary event handlers
     */
    ,initComponent:function() {
        // call parent initComponent
        Ext.ux.form.DateTime.superclass.initComponent.call(this);

        // create DateField
        var dateConfig = Ext.apply({}, {
             id:this.id + '-date'
            ,format:this.dateFormat || Ext.form.DateField.prototype.format
            ,width:this.timeWidth
            ,selectOnFocus:this.selectOnFocus
            ,listeners:{
                  blur:{scope:this, fn:this.onBlur}
                 ,focus:{scope:this, fn:this.onFocus}
            }
        }, this.dateConfig);
        this.df = new Ext.form.DateField(dateConfig);
        delete(this.dateFormat);

        // create TimeField
        var timeConfig = Ext.apply({}, {
             id:this.id + '-time'
            ,format:this.timeFormat || Ext.form.TimeField.prototype.format
            ,width:this.timeWidth
            ,selectOnFocus:this.selectOnFocus
            ,listeners:{
                  blur:{scope:this, fn:this.onBlur}
                 ,focus:{scope:this, fn:this.onFocus}
            }
        }, this.timeConfig);
        this.tf = new Ext.form.TimeField(timeConfig);
        delete(this.timeFormat);

        // relay events
        this.relayEvents(this.df, ['focus', 'specialkey', 'invalid', 'valid']);
        this.relayEvents(this.tf, ['focus', 'specialkey', 'invalid', 'valid']);

    } // eo function initComponent
    // }}}
    // {{{
    /**
     * private
     * Renders underlying DateField and TimeField and provides a workaround for side error icon bug
     */
    ,onRender:function(ct, position) {
        // don't run more than once
        if(this.isRendered) {
            return;
        }

        // render underlying hidden field
        Ext.ux.form.DateTime.superclass.onRender.call(this, ct, position);

        // render DateField and TimeField
        // create bounding table
        var t;
        if('below' === this.timePosition) {
            t = Ext.DomHelper.append(ct, {tag:'table',style:'border-collapse:collapse',children:[
                 {tag:'tr',children:[{tag:'td', style:'padding-bottom:1px', cls:'ux-datetime-date'}]}
                ,{tag:'tr',children:[{tag:'td', cls:'ux-datetime-time'}]}
            ]}, true);
        }
        else {
            t = Ext.DomHelper.append(ct, {tag:'table',style:'border-collapse:collapse',children:[
                {tag:'tr',children:[
                    {tag:'td',style:'padding-right:4px', cls:'ux-datetime-date'},{tag:'td', cls:'ux-datetime-time'}
                ]}
            ]}, true);
        }

        this.tableEl = t;
        this.wrap = t.wrap({cls:'x-form-field-wrap'});
        this.wrap.on("mousedown", this.onMouseDown, this, {delay:10});

        // render DateField & TimeField
        this.df.render(t.child('td.ux-datetime-date'));
        this.tf.render(t.child('td.ux-datetime-time'));

        // workaround for IE trigger misalignment bug
        if(Ext.isIE && Ext.isStrict) {
            t.select('input').applyStyles({top:0});
        }

        this.on('specialkey', this.onSpecialKey, this);
        this.df.el.swallowEvent(['keydown', 'keypress']);
        this.tf.el.swallowEvent(['keydown', 'keypress']);

        // create icon for side invalid errorIcon
        if('side' === this.msgTarget) {
            var elp = this.el.findParent('.x-form-element', 10, true);
            this.errorIcon = elp.createChild({cls:'x-form-invalid-icon'});

            this.df.errorIcon = this.errorIcon;
            this.tf.errorIcon = this.errorIcon;
        }

        // we're rendered flag
        this.isRendered = true;

    } // eo function onRender
    // }}}
    // {{{
    /**
     * private
     */
    ,adjustSize:Ext.BoxComponent.prototype.adjustSize
    // }}}
    // {{{
    /**
     * private
     */
    ,alignErrorIcon:function() {
        this.errorIcon.alignTo(this.tableEl, 'tl-tr', [2, 0]);
    }
    // }}}
    // {{{
    /**
     * private initializes internal dateValue
     */
    ,initDateValue:function() {
        this.dateValue = this.otherToNow ? new Date() : new Date(1970, 0, 1, 0, 0, 0);
    }
    // }}}
    // {{{
    /**
     * Disable this component.
     * @return {Ext.Component} this
     */
    ,disable:function() {
        if(this.isRendered) {
            this.df.disabled = this.disabled;
            this.df.onDisable();
            this.tf.onDisable();
        }
        this.disabled = true;
        this.df.disabled = true;
        this.tf.disabled = true;
        this.fireEvent("disable", this);
        return this;
    } // eo function disable
    // }}}
    // {{{
    /**
     * Enable this component.
     * @return {Ext.Component} this
     */
    ,enable:function() {
        if(this.rendered){
            this.df.onEnable();
            this.tf.onEnable();
        }
        this.disabled = false;
        this.df.disabled = false;
        this.tf.disabled = false;
        this.fireEvent("enable", this);
        return this;
    } // eo function enable
    // }}}
    // {{{
    /**
     * private Focus date filed
     */
    ,focus:function() {
        this.df.focus();
    } // eo function focus
    // }}}
    // {{{
    /**
     * private
     */
    ,getPositionEl:function() {
        return this.wrap;
    }
    // }}}
    // {{{
    /**
     * private
     */
    ,getResizeEl:function() {
        return this.wrap;
    }
    // }}}
    // {{{
    /**
     * @return {Date/String} Returns value of this field
     */
    ,getValue:function() {
        // create new instance of date
        return this.dateValue ? new Date(this.dateValue) : '';
    } // eo function getValue
    // }}}
    // {{{
    /**
     * @return {Boolean} true = valid, false = invalid
     * private Calls isValid methods of underlying DateField and TimeField and returns the result
     */
    ,isValid:function() {
        return this.df.isValid() && this.tf.isValid();
    } // eo function isValid
    // }}}
    // {{{
    /**
     * Returns true if this component is visible
     * @return {boolean} 
     */
    ,isVisible : function(){
        return this.df.rendered && this.df.getActionEl().isVisible();
    } // eo function isVisible
    // }}}
    // {{{
    /** 
     * private Handles blur event
     */
    ,onBlur:function(f) {
        // called by both DateField and TimeField blur events

        // revert focus to previous field if clicked in between
        if(this.wrapClick) {
            f.focus();
            this.wrapClick = false;
        }

        // update underlying value
        if(f === this.df) {
            this.updateDate();
        }
        else {
            this.updateTime();
        }
        this.updateHidden();

        // fire events later
        (function() {
            if(!this.df.hasFocus && !this.tf.hasFocus) {
                var v = this.getValue();
                if(String(v) !== String(this.startValue)) {
                    this.fireEvent("change", this, v, this.startValue);
                }
                this.hasFocus = false;
                this.fireEvent('blur', this);
            }
        }).defer(100, this);

    } // eo function onBlur
    // }}}
    // {{{
    /**
     * private Handles focus event
     */
    ,onFocus:function() {
        if(!this.hasFocus){
            this.hasFocus = true;
            this.startValue = this.getValue();
            this.fireEvent("focus", this);
        }
    }
    // }}}
    // {{{
    /**
     * private Just to prevent blur event when clicked in the middle of fields
     */
    ,onMouseDown:function(e) {
        this.wrapClick = 'td' === e.target.nodeName.toLowerCase();
    }
    // }}}
    // {{{
    /**
     * private
     * Handles Tab and Shift-Tab events
     */
    ,onSpecialKey:function(t, e) {
        var key = e.getKey();
        if(key == e.TAB) {
            if(t === this.df && !e.shiftKey) {
                e.stopEvent();
                this.tf.focus();
            }
            if(t === this.tf && e.shiftKey) {
                e.stopEvent();
                this.df.focus();
            }
        }
        // otherwise it misbehaves in editor grid
        if(key == e.ENTER) {
            this.updateValue();
        }

    } // eo function onSpecialKey
    // }}}
    // {{{
    /**
     * private Sets the value of DateField
     */
    ,setDate:function(date) {
        this.df.setValue(date);
    } // eo function setDate
    // }}}
    // {{{
    /** 
     * private Sets the value of TimeField
     */
    ,setTime:function(date) {
        this.tf.setValue(date);
    } // eo function setTime
    // }}}
    // {{{
    /**
     * private
     * Sets correct sizes of underlying DateField and TimeField
     * With workarounds for IE bugs
     */
    ,setSize:function(w, h) {
        if(!w) {
            return;
        }
        if('below' == this.timePosition) {
            this.df.setSize(w, h);
            this.tf.setSize(w, h);
            if(Ext.isIE) {
                this.df.el.up('td').setWidth(w);
                this.tf.el.up('td').setWidth(w);
            }
        }
        else {
            this.df.setSize(w - this.timeWidth - 4, h);
            this.tf.setSize(this.timeWidth, h);

            if(Ext.isIE) {
                this.df.el.up('td').setWidth(w - this.timeWidth - 4);
                this.tf.el.up('td').setWidth(this.timeWidth);
            }
        }
    } // eo function setSize
    // }}}
    // {{{
    /**
     * @param {Mixed} val Value to set
     * Sets the value of this field
     */
    ,setValue:function(val) {
        if(!val && true === this.emptyToNow) {
            this.setValue(new Date());
            return;
        }
        else if(!val) {
            this.setDate('');
            this.setTime('');
            this.updateValue();
            return;
        }
        val = val ? val : new Date(1970, 0 ,1, 0, 0, 0);
        var da, time;
        if(val instanceof Date) {
            this.setDate(val);
            this.setTime(val);
            this.dateValue = new Date(val);
        }
        else {
            da = val.split(this.dtSeparator);
            this.setDate(da[0]);
            if(da[1]) {
                this.setTime(da[1]);
            }
        }
        this.updateValue();
    } // eo function setValue
    // }}}
    // {{{
    /**
     * Hide or show this component by boolean
     * @return {Ext.Component} this
     */
    ,setVisible: function(visible){
        if(visible) {
            this.df.show();
            this.tf.show();
        }else{
            this.df.hide();
            this.tf.hide();
        }
        return this;
    } // eo function setVisible
    // }}}
    //{{{
    ,show:function() {
        return this.setVisible(true);
    } // eo function show
    //}}}
    //{{{
    ,hide:function() {
        return this.setVisible(false);
    } // eo function hide
    //}}}
    // {{{
    /**
     * private Updates the date part
     */
    ,updateDate:function() {

        var d = this.df.getValue();
        if(d) {
            if(!(this.dateValue instanceof Date)) {
                this.initDateValue();
                if(!this.tf.getValue()) {
                    this.setTime(this.dateValue);
                }
            }
            this.dateValue.setMonth(0); // because of leap years
            this.dateValue.setFullYear(d.getFullYear());
            this.dateValue.setMonth(d.getMonth());
            this.dateValue.setDate(d.getDate());
        }
        else {
            this.dateValue = '';
            this.setTime('');
        }
    } // eo function updateDate
    // }}}
    // {{{
    /**
     * private
     * Updates the time part
     */
    ,updateTime:function() {
        var t = this.tf.getValue();
        if(t && !(t instanceof Date)) {
            t = Date.parseDate(t, this.tf.format);
        }
        if(t && !this.df.getValue()) {
            this.initDateValue();
            this.setDate(this.dateValue);
        }
        if(this.dateValue instanceof Date) {
            if(t) {
                this.dateValue.setHours(t.getHours());
                this.dateValue.setMinutes(t.getMinutes());
                this.dateValue.setSeconds(t.getSeconds());
            }
            else {
                this.dateValue.setHours(0);
                this.dateValue.setMinutes(0);
                this.dateValue.setSeconds(0);
            }
        }
    } // eo function updateTime
    // }}}
    // {{{
    /**
     * private Updates the underlying hidden field value
     */
    ,updateHidden:function() {
        if(this.isRendered) {
            var value = this.dateValue instanceof Date ? this.dateValue.format(this.hiddenFormat) : '';
            this.el.dom.value = value;
        }
    }
    // }}}
    // {{{
    /**
     * private Updates all of Date, Time and Hidden
     */
    ,updateValue:function() {

        this.updateDate();
        this.updateTime();
        this.updateHidden();

        return;
    } // eo function updateValue
    // }}}
    // {{{
    /**
     * @return {Boolean} true = valid, false = invalid
     * callse validate methods of DateField and TimeField
     */
    ,validate:function() {
        return this.df.validate() && this.tf.validate();
    } // eo function validate
    // }}}
    // {{{
    /**
     * Returns renderer suitable to render this field
     * @param {Object} Column model config
     */
    ,renderer: function(field) {
        var format = field.editor.dateFormat || Ext.ux.form.DateTime.prototype.dateFormat;
        format += ' ' + (field.editor.timeFormat || Ext.ux.form.DateTime.prototype.timeFormat);
        var renderer = function(val) {
            var retval = Ext.util.Format.date(val, format);
            return retval;
        };
        return renderer;
    } // eo function renderer
    // }}}

}); // eo extend

// register xtype
Ext.reg('xdatetime', Ext.ux.form.DateTime);

