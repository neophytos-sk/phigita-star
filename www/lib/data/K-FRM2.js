/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.BasicForm
 * @extends Ext.util.Observable
 * Supplies the functionality to do "actions" on forms and initialize Ext.form.Field types on existing markup.
 * <br><br>
 * By default, Ext Forms are submitted through Ajax, using {@link Ext.form.Action}.
 * To enable normal browser submission of an Ext Form, use the {@link #standardSubmit} config option.
 * @constructor
 * @param {Mixed} el The form element or its id
 * @param {Object} config Configuration options
 */
Ext.form.BasicForm = function(el, config){
    Ext.apply(this, config);
    /*
     * The Ext.form.Field items in this form.
     * @type MixedCollection
     */
    this.items = new Ext.util.MixedCollection(false, function(o){
        return o.id || (o.id = Ext.id());
    });
    this.addEvents(
        /**
         * @event beforeaction
         * Fires before any action is performed. Return false to cancel the action.
         * @param {Form} this
         * @param {Action} action The {@link Ext.form.Action} to be performed
         */
        'beforeaction',
        /**
         * @event actionfailed
         * Fires when an action fails.
         * @param {Form} this
         * @param {Action} action The {@link Ext.form.Action} that failed
         */
        'actionfailed',
        /**
         * @event actioncomplete
         * Fires when an action is completed.
         * @param {Form} this
         * @param {Action} action The {@link Ext.form.Action} that completed
         */
        'actioncomplete'
    );

    if(el){
        this.initEl(el);
    }
    Ext.form.BasicForm.superclass.constructor.call(this);
};

Ext.extend(Ext.form.BasicForm, Ext.util.Observable, {
    /**
     * @cfg {String} method
     * The request method to use (GET or POST) for form actions if one isn't supplied in the action options.
     */
    /**
     * @cfg {DataReader} reader
     * An Ext.data.DataReader (e.g. {@link Ext.data.XmlReader}) to be used to read data when executing "load" actions.
     * This is optional as there is built-in support for processing JSON.
     */
    /**
     * @cfg {DataReader} errorReader
     * An Ext.data.DataReader (e.g. {@link Ext.data.XmlReader}) to be used to read data when reading validation errors on "submit" actions.
     * This is completely optional as there is built-in support for processing JSON.
     */
    /**
     * @cfg {String} url
     * The URL to use for form actions if one isn't supplied in the action options.
     */
    /**
     * @cfg {Boolean} fileUpload
     * Set to true if this form is a file upload.
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
     */
    /**
     * @cfg {Object} baseParams
     * Parameters to pass with all requests. e.g. baseParams: {id: '123', foo: 'bar'}.
     */
    /**
     * @cfg {Number} timeout Timeout for form actions in seconds (default is 30 seconds).
     */
    timeout: 30,

    // private
    activeAction : null,

    /**
     * @cfg {Boolean} trackResetOnLoad If set to true, form.reset() resets to the last loaded
     * or setValues() data instead of when the form was first created.
     */
    trackResetOnLoad : false,

    /**
     * @cfg {Boolean} standardSubmit If set to true, standard HTML form submits are used instead of XHR (Ajax) style
     * form submissions. (defaults to false)
     */
    /**
     * By default wait messages are displayed with Ext.MessageBox.wait. You can target a specific
     * element by passing it or its id or mask the form itself by passing in true.
     * @type Mixed
     * @property waitMsgTarget
     */

    // private
    initEl : function(el){
        this.el = Ext.get(el);
        this.id = this.el.id || Ext.id();
        if(!this.standardSubmit){
            this.el.on('submit', this.onSubmit, this);
        }
        this.el.addClass('x-form');
    },

    /**
     * Get the HTML form Element
     * @return Ext.Element
     */
    getEl: function(){
        return this.el;
    },

    // private
    onSubmit : function(e){
        e.stopEvent();
    },

    // private
	destroy: function() {
        this.items.each(function(f){
            Ext.destroy(f);
        });
        if(this.el){
			this.el.removeAllListeners();
			this.el.remove();
        }
		this.purgeListeners();
	},

    /**
     * Returns true if client-side validation on the form is successful.
     * @return Boolean
     */
    isValid : function(){
        var valid = true;
        this.items.each(function(f){
           if(!f.validate()){
               valid = false;
           }
        });
        return valid;
    },

    /**
     * Returns true if any fields in this form have changed since their original load.
     * @return Boolean
     */
    isDirty : function(){
        var dirty = false;
        this.items.each(function(f){
           if(f.isDirty()){
               dirty = true;
               return false;
           }
        });
        return dirty;
    },

    /**
     * Performs a predefined action ({@link Ext.form.Action.Submit} or
     * {@link Ext.form.Action.Load}) or a custom extension of {@link Ext.form.Action} 
     * to perform application-specific processing.
     * @param {String/Object} actionName The name of the predefined action type,
     * or instance of {@link Ext.form.Action} to perform.
     * @param {Object} options (optional) The options to pass to the {@link Ext.form.Action}. 
     * All of the config options listed below are supported by both the submit
     * and load actions unless otherwise noted (custom actions could also accept
     * other config options):<ul>
     * <li><b>url</b> : String<p style="margin-left:1em">The url for the action (defaults
     * to the form's url.)</p></li>
     * <li><b>method</b> : String<p style="margin-left:1em">The form method to use (defaults
     * to the form's method, or POST if not defined)</p></li>
     * <li><b>params</b> : String/Object<p style="margin-left:1em">The params to pass
     * (defaults to the form's baseParams, or none if not defined)</p></li>
     * <li><b>headers</b> : Object<p style="margin-left:1em">Request headers to set for the action
     * (defaults to the form's default headers)</p></li>
     * <li><b>success</b> : Function<p style="margin-left:1em">The callback that will
     * be invoked after a successful response.  Note that this is HTTP success
     * (the transaction was sent and received correctly), but the resulting response data
     * can still contain data errors. The function is passed the following parameters:<ul>
     * <li><code>form</code> : Ext.form.BasicForm<div class="sub-desc">The form that requested the action</div></li>
     * <li><code>action</code> : Ext.form.Action<div class="sub-desc">The Action class. The {@link Ext.form.Action#result result}
     * property of this object may be examined to perform custom postprocessing.</div></li>
     * </ul></p></li>
     * <li><b>failure</b> : Function<p style="margin-left:1em">The callback that will
     * be invoked after a failed transaction attempt.  Note that this is HTTP failure,
     * which means a non-successful HTTP code was returned from the server. The function
     * is passed the following parameters:<ul>
     * <li><code>form</code> : Ext.form.BasicForm<div class="sub-desc">The form that requested the action</div></li>
     * <li><code>action</code> : Ext.form.Action<div class="sub-desc">The Action class. If an Ajax
     * error ocurred, the failure type will be in {@link Ext.form.Action#failureType failureType}. The {@link Ext.form.Action#result result}
     * property of this object may be examined to perform custom postprocessing.</div></li>
     * </ul></p></li>
     * <li><b>scope</b> : Object<p style="margin-left:1em">The scope in which to call the
     * callback functions (The <tt>this</tt> reference for the callback functions).</p></li>
     * <li><b>clientValidation</b> : Boolean<p style="margin-left:1em">Submit Action only.
     * Determines whether a Form's fields are validated in a final call to
     * {@link Ext.form.BasicForm#isValid isValid} prior to submission. Set to <tt>false</tt>
     * to prevent this. If undefined, pre-submission field validation is performed.</p></li></ul>
     * @return {BasicForm} this
     */
    doAction : function(action, options){
        if(typeof action == 'string'){
            action = new Ext.form.Action.ACTION_TYPES[action](this, options);
        }
        if(this.fireEvent('beforeaction', this, action) !== false){
            this.beforeAction(action);
            action.run.defer(100, action);
        }
        return this;
    },

    /**
     * Shortcut to do a submit action.
     * @param {Object} options The options to pass to the action (see {@link #doAction} for details)
     * @return {BasicForm} this
     */
    submit : function(options){
        if(this.standardSubmit){
            var v = this.isValid();
            if(v){
                this.el.dom.submit();
            }
            return v;
        }
        this.doAction('submit', options);
        return this;
    },

    /**
     * Shortcut to do a load action.
     * @param {Object} options The options to pass to the action (see {@link #doAction} for details)
     * @return {BasicForm} this
     */
    load : function(options){
        this.doAction('load', options);
        return this;
    },

    /**
     * Persists the values in this form into the passed Ext.data.Record object in a beginEdit/endEdit block.
     * @param {Record} record The record to edit
     * @return {BasicForm} this
     */
    updateRecord : function(record){
        record.beginEdit();
        var fs = record.fields;
        fs.each(function(f){
            var field = this.findField(f.name);
            if(field){
                record.set(f.name, field.getValue());
            }
        }, this);
        record.endEdit();
        return this;
    },

    /**
     * Loads an Ext.data.Record into this form.
     * @param {Record} record The record to load
     * @return {BasicForm} this
     */
    loadRecord : function(record){
        this.setValues(record.data);
        return this;
    },

    // private
    beforeAction : function(action){
        var o = action.options;
        if(o.waitMsg){
            if(this.waitMsgTarget === true){
                this.el.mask(o.waitMsg, 'x-mask-loading');
            }else if(this.waitMsgTarget){
                this.waitMsgTarget = Ext.get(this.waitMsgTarget);
                this.waitMsgTarget.mask(o.waitMsg, 'x-mask-loading');
            }else{
                Ext.MessageBox.wait(o.waitMsg, o.waitTitle || this.waitTitle || 'Please Wait...');
            }
        }
    },

    // private
    afterAction : function(action, success){
        this.activeAction = null;
        var o = action.options;
        if(o.waitMsg){
            if(this.waitMsgTarget === true){
                this.el.unmask();
            }else if(this.waitMsgTarget){
                this.waitMsgTarget.unmask();
            }else{
                Ext.MessageBox.updateProgress(1);
                Ext.MessageBox.hide();
            }
        }
        if(success){
            if(o.reset){
                this.reset();
            }
            Ext.callback(o.success, o.scope, [this, action]);
            this.fireEvent('actioncomplete', this, action);
        }else{
            Ext.callback(o.failure, o.scope, [this, action]);
            this.fireEvent('actionfailed', this, action);
        }
    },

    /**
     * Find a Ext.form.Field in this form by id, dataIndex, name or hiddenName.
     * @param {String} id The value to search for
     * @return Field
     */
    findField : function(id){
        var field = this.items.get(id);
        if(!field){
            this.items.each(function(f){
                if(f.isFormField && (f.dataIndex == id || f.id == id || f.getName() == id)){
                    field = f;
                    return false;
                }
            });
        }
        return field || null;
    },


    /**
     * Mark fields in this form invalid in bulk.
     * @param {Array/Object} errors Either an array in the form [{id:'fieldId', msg:'The message'},...] or an object hash of {id: msg, id2: msg2}
     * @return {BasicForm} this
     */
    markInvalid : function(errors){
        if(Ext.isArray(errors)){
            for(var i = 0, len = errors.length; i < len; i++){
                var fieldError = errors[i];
                var f = this.findField(fieldError.id);
                if(f){
                    f.markInvalid(fieldError.msg);
                }
            }
        }else{
            var field, id;
            for(id in errors){
                if(typeof errors[id] != 'function' && (field = this.findField(id))){
                    field.markInvalid(errors[id]);
                }
            }
        }
        return this;
    },

    /**
     * Set values for fields in this form in bulk.
     * @param {Array/Object} values Either an array in the form:<br><br><code><pre>
[{id:'clientName', value:'Fred. Olsen Lines'},
 {id:'portOfLoading', value:'FXT'},
 {id:'portOfDischarge', value:'OSL'} ]</pre></code><br><br>
     * or an object hash of the form:<br><br><code><pre>
{
    clientName: 'Fred. Olsen Lines',
    portOfLoading: 'FXT',
    portOfDischarge: 'OSL'
}</pre></code><br>
     * @return {BasicForm} this
     */
    setValues : function(values){
        if(Ext.isArray(values)){ // array of objects
            for(var i = 0, len = values.length; i < len; i++){
                var v = values[i];
                var f = this.findField(v.id);
                if(f){
                    f.setValue(v.value);
                    if(this.trackResetOnLoad){
                        f.originalValue = f.getValue();
                    }
                }
            }
        }else{ // object hash
            var field, id;
            for(id in values){
                if(typeof values[id] != 'function' && (field = this.findField(id))){
                    field.setValue(values[id]);
                    if(this.trackResetOnLoad){
                        field.originalValue = field.getValue();
                    }
                }
            }
        }
        return this;
    },

    /**
     * Returns the fields in this form as an object with key/value pairs as they would be submitted using a standard form submit.
     * If multiple fields exist with the same name they are returned as an array.
     * @param {Boolean} asString (optional) false to return the values as an object (defaults to returning as a string)
     * @return {String/Object}
     */
    getValues : function(asString){
        var fs = Ext.lib.Ajax.serializeForm(this.el.dom);
        if(asString === true){
            return fs;
        }
        return Ext.urlDecode(fs);
    },

    /**
     * Clears all invalid messages in this form.
     * @return {BasicForm} this
     */
    clearInvalid : function(){
        this.items.each(function(f){
           f.clearInvalid();
        });
        return this;
    },

    /**
     * Resets this form.
     * @return {BasicForm} this
     */
    reset : function(){
        this.items.each(function(f){
            f.reset();
        });
        return this;
    },

    /**
     * Add Ext.form components to this form.
     * @param {Field} field1
     * @param {Field} field2 (optional)
     * @param {Field} etc (optional)
     * @return {BasicForm} this
     */
    add : function(){
        this.items.addAll(Array.prototype.slice.call(arguments, 0));
        return this;
    },


    /**
     * Removes a field from the items collection (does NOT remove its markup).
     * @param {Field} field
     * @return {BasicForm} this
     */
    remove : function(field){
        this.items.remove(field);
        return this;
    },

    /**
     * Iterates through the {@link Ext.form.Field Field}s which have been {@link #add add}ed to this BasicForm,
     * checks them for an id attribute, and calls {@link Ext.form.Field#applyToMarkup} on the existing dom element with that id.
     * @return {BasicForm} this
     */
    render : function(){
        this.items.each(function(f){
            if(f.isFormField && !f.rendered && document.getElementById(f.id)){ // if the element exists
                f.applyToMarkup(f.id);
            }
        });
        return this;
    },

    /**
     * Calls {@link Ext#apply} for all fields in this form with the passed object.
     * @param {Object} values
     * @return {BasicForm} this
     */
    applyToFields : function(o){
        this.items.each(function(f){
           Ext.apply(f, o);
        });
        return this;
    },

    /**
     * Calls {@link Ext#applyIf} for all field in this form with the passed object.
     * @param {Object} values
     * @return {BasicForm} this
     */
    applyIfToFields : function(o){
        this.items.each(function(f){
           Ext.applyIf(f, o);
        });
        return this;
    }
});

// back compat
Ext.BasicForm = Ext.form.BasicForm;
/**
 * @class Ext.form.VTypes
 * Overrideable validation definitions. The validations provided are basic and intended to be easily customizable and extended.
 * @singleton
 */
Ext.form.VTypes = function(){
    // closure these in so they are only created once.
    var alpha = /^[a-zA-Z_]+$/;
    var alphanum = /^[a-zA-Z0-9_]+$/;
    var email = /^([\w]+)(.[\w]+)*@([\w-]+\.){1,5}([A-Za-z]){2,4}$/;
    var url = /(((https?)|(ftp)):\/\/([\-\w]+\.)+\w{2,3}(\/[%\-\w]+(\.\w{2,})?)*(([\w\-\.\?\\\/+@&#;`~=%!]*)(\.\w{2,})?)*\/?)/i;

    // All these messages and functions are configurable
    return {
        /**
         * The function used to validate email addresses
         * @param {String} value The email address
         */
        'email' : function(v){
            return email.test(v);
        },
        /**
         * The error text to display when the email validation function returns false
         * @type String
         */
        'emailText' : 'This field should be an e-mail address in the format "user@domain.com"',
        /**
         * The keystroke filter mask to be applied on email input
         * @type RegExp
         */
        'emailMask' : /[a-z0-9_\.\-@]/i,

        /**
         * The function used to validate urls
         * @param {String} value The url
         */
        'url' : function(v){
            return url.test(v);
        },
        /**
         * The error text to display when the url validation function returns false
         * @type String
         */
        'urlText' : 'This field should be a URL in the format "http:/'+'/www.domain.com"',
        
        /**
         * The function used to validate alpha values
         * @param {String} value The value
         */
        'alpha' : function(v){
            return alpha.test(v);
        },
        /**
         * The error text to display when the alpha validation function returns false
         * @type String
         */
        'alphaText' : 'This field should only contain letters and _',
        /**
         * The keystroke filter mask to be applied on alpha input
         * @type RegExp
         */
        'alphaMask' : /[a-z_]/i,

        /**
         * The function used to validate alphanumeric values
         * @param {String} value The value
         */
        'alphanum' : function(v){
            return alphanum.test(v);
        },
        /**
         * The error text to display when the alphanumeric validation function returns false
         * @type String
         */
        'alphanumText' : 'This field should only contain letters, numbers and _',
        /**
         * The keystroke filter mask to be applied on alphanumeric input
         * @type RegExp
         */
        'alphanumMask' : /[a-z0-9_]/i
    };
}();


var greekalpha = /^[\u0386\u0388\u0389\u038a\u038c\u038e\u038f\u0390\u0391\u0392\u0393\u0394\u0395\u0396\u0397\u0398\u0399\u039a\u039b\u039c\u039d\u039e\u039f\u03a0\u03a1\u03a3\u03a4\u03a5\u03a6\u03a7\u03a8\u03a9\u03aa\u03ab\u03ac\u03ad\u03ae\u03af\u03b0\u03b1\u03b2\u03b3\u03b4\u03b5\u03b6\u03b7\u03b8\u03b9\u03ba\u03bb\u03bc\u03bd\u03be\u03bf\u03c0\u03c1\u03c2\u03c3\u03c4\u03c5\u03c6\u03c7\u03c8\u03c9\u03ca\u03cb\u03cc\u03cd\u03ce]+$/;
Ext.form.VTypes.greekalpha = function(v){
    return greekalpha.test(v);
}
Ext.form.VTypes.greekalphaText = 'This field should only contain letters and _';
Ext.form.VTypes.greekalphaMask = /[\u0386\u0388\u0389\u038a\u038c\u038e\u038f\u0390\u0391\u0392\u0393\u0394\u0395\u0396\u0397\u0398\u0399\u039a\u039b\u039c\u039d\u039e\u039f\u03a0\u03a1\u03a3\u03a4\u03a5\u03a6\u03a7\u03a8\u03a9\u03aa\u03ab\u03ac\u03ad\u03ae\u03af\u03b0\u03b1\u03b2\u03b3\u03b4\u03b5\u03b6\u03b7\u03b8\u03b9\u03ba\u03bb\u03bc\u03bd\u03be\u03bf\u03c0\u03c1\u03c2\u03c3\u03c4\u03c5\u03c6\u03c7\u03c8\u03c9\u03ca\u03cb\u03cc\u03cd\u03ce]/i ;

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.Field
 * @extends Ext.BoxComponent
 * Base class for form fields that provides default event handling, sizing, value handling and other functionality.
 * @constructor
 * Creates a new Field
 * @param {Object} config Configuration options
 */
Ext.form.Field = Ext.extend(Ext.BoxComponent,  {
    /**
     * @cfg {String} fieldLabel The label text to display next to this field (defaults to '')
     */
    /**
     * @cfg {String} labelStyle A CSS style specification to apply directly to this field's label (defaults to the
     * container's labelStyle value if set, or ''). For example, <code>labelStyle: 'font-weight:bold;'</code>.
     */
    /**
     * @cfg {String} labelSeparator The standard separator to display after the text of each form label (defaults
     * to the value of {@link Ext.layout.FormLayout#labelSeparator}, which is a colon ':' by default).  To display
     * no separator for this field's label specify empty string ''.
     */
    /**
     * @cfg {Boolean} hideLabel True to completely hide the label element (defaults to false)
     */
    /**
     * @cfg {String} clearCls The CSS class used to provide field clearing (defaults to 'x-form-clear-left')
     */
    /**
     * @cfg {String} itemCls An additional CSS class to apply to the wrapper's form item element of this field (defaults 
     * to the container's itemCls value if set, or '').  Since it is applied to the item wrapper, it allows you to write 
     * standard CSS rules that can apply to the field, the label (if specified) or any other element within the markup for 
     * the field. NOTE: this will not have any effect on fields that are not part of a form. Example use:
     * <pre><code>
// Apply a style to the field's label:
&lt;style>
    .required .x-form-item-label {font-weight:bold;color:red;}
&lt;/style>

new Ext.FormPanel({
	height: 100,
	renderTo: document.body,
	items: [{
		xtype: 'textfield',
		fieldLabel: 'Name',
		itemCls: 'required' //this label will be styled
	},{
		xtype: 'textfield',
		fieldLabel: 'Favorite Color'
	}]
});
</code></pre>
     */
    /**
     * @cfg {String} inputType The type attribute for input fields -- e.g. radio, text, password, file (defaults 
     * to "text"). The types "file" and "password" must be used to render those field types currently -- there are 
     * no separate Ext components for those. Note that if you use <tt>inputType:'file'</tt>, {@link #emptyText} 
     * is not supported and should be avoided.
     */
    /**
     * @cfg {Number} tabIndex The tabIndex for this field. Note this only applies to fields that are rendered,
     * not those which are built via applyTo (defaults to undefined).
     */
    /**
     * @cfg {Mixed} value A value to initialize this field with (defaults to undefined).
     */
    /**
     * @cfg {String} name The field's HTML name attribute (defaults to "").
     */
    /**
     * @cfg {String} cls A custom CSS class to apply to the field's underlying element (defaults to "").
     */
    
    /**
     * @cfg {String} invalidClass The CSS class to use when marking a field invalid (defaults to "x-form-invalid")
     */
    invalidClass : "x-form-invalid",
    /**
     * @cfg {String} invalidText The error text to use when marking a field invalid and no message is provided
     * (defaults to "The value in this field is invalid")
     */
    invalidText : "The value in this field is invalid",
    /**
     * @cfg {String} focusClass The CSS class to use when the field receives focus (defaults to "x-form-focus")
     */
    focusClass : "x-form-focus",
    /**
     * @cfg {String/Boolean} validationEvent The event that should initiate field validation. Set to false to disable
      automatic validation (defaults to "keyup").
     */
    validationEvent : "keyup",
    /**
     * @cfg {Boolean} validateOnBlur Whether the field should validate when it loses focus (defaults to true).
     */
    validateOnBlur : true,
    /**
     * @cfg {Number} validationDelay The length of time in milliseconds after user input begins until validation
     * is initiated (defaults to 250)
     */
    validationDelay : 250,
    /**
     * @cfg {String/Object} autoCreate A DomHelper element spec, or true for a default element spec (defaults to
     * {tag: "input", type: "text", size: "20", autocomplete: "off"})
     */
    defaultAutoCreate : {tag: "input", type: "text", size: "20", autocomplete: "off"},
    /**
     * @cfg {String} fieldClass The default CSS class for the field (defaults to "x-form-field")
     */
    fieldClass : "x-form-field",
    /**
     * @cfg {String} msgTarget The location where error text should display.  Should be one of the following values
     * (defaults to 'qtip'):
     *<pre>
Value         Description
-----------   ----------------------------------------------------------------------
qtip          Display a quick tip when the user hovers over the field
title         Display a default browser title attribute popup
under         Add a block div beneath the field containing the error text
side          Add an error icon to the right of the field with a popup on hover
[element id]  Add the error text directly to the innerHTML of the specified element
</pre>
     */
    msgTarget : 'qtip',
    /**
     * @cfg {String} msgFx <b>Experimental</b> The effect used when displaying a validation message under the field
     * (defaults to 'normal').
     */
    msgFx : 'normal',
    /**
     * @cfg {Boolean} readOnly True to mark the field as readOnly in HTML (defaults to false) -- Note: this only
     * sets the element's readOnly DOM attribute.
     */
    readOnly : false,
    /**
     * @cfg {Boolean} disabled True to disable the field (defaults to false).
     */
    disabled : false,
    
    // private
    isFormField : true,
    
    // private
    hasFocus : false,

	// private
	initComponent : function(){
        Ext.form.Field.superclass.initComponent.call(this);
        this.addEvents(
            /**
             * @event focus
             * Fires when this field receives input focus.
             * @param {Ext.form.Field} this
             */
            'focus',
            /**
             * @event blur
             * Fires when this field loses input focus.
             * @param {Ext.form.Field} this
             */
            'blur',
            /**
             * @event specialkey
             * Fires when any key related to navigation (arrows, tab, enter, esc, etc.) is pressed.  You can check
             * {@link Ext.EventObject#getKey} to determine which key was pressed.
             * @param {Ext.form.Field} this
             * @param {Ext.EventObject} e The event object
             */
            'specialkey',
            /**
             * @event change
             * Fires just before the field blurs if the field value has changed.
             * @param {Ext.form.Field} this
             * @param {Mixed} newValue The new value
             * @param {Mixed} oldValue The original value
             */
            'change',
            /**
             * @event invalid
             * Fires after the field has been marked as invalid.
             * @param {Ext.form.Field} this
             * @param {String} msg The validation message
             */
            'invalid',
            /**
             * @event valid
             * Fires after the field has been validated with no errors.
             * @param {Ext.form.Field} this
             */
            'valid'
        );
    },

    /**
     * Returns the name attribute of the field if available
     * @return {String} name The field name
     */
    getName: function(){
         return this.rendered && this.el.dom.name ? this.el.dom.name : (this.hiddenName || '');
    },

    // private
    onRender : function(ct, position){
        Ext.form.Field.superclass.onRender.call(this, ct, position);
        if(!this.el){
            var cfg = this.getAutoCreate();
            if(!cfg.name){
                cfg.name = this.name || this.id;
            }
            if(this.inputType){
                cfg.type = this.inputType;
            }
            this.el = ct.createChild(cfg, position);
        }
        var type = this.el.dom.type;
        if(type){
            if(type == 'password'){
                type = 'text';
            }
            this.el.addClass('x-form-'+type);
        }
        if(this.readOnly){
            this.el.dom.readOnly = true;
        }
        if(this.tabIndex !== undefined){
            this.el.dom.setAttribute('tabIndex', this.tabIndex);
        }

        this.el.addClass([this.fieldClass, this.cls]);
    },

    // private
    initValue : function(){
        if(this.value !== undefined){
            this.setValue(this.value);
        }else if(this.el.dom.value.length > 0 && this.el.dom.value != this.emptyText){
            this.setValue(this.el.dom.value);
        }
        // reference to original value for reset
        this.originalValue = this.getValue();
    },

    /**
     * Returns true if this field has been changed since it was originally loaded and is not disabled.
     */
    isDirty : function() {
        if(this.disabled) {
            return false;
        }
        return String(this.getValue()) !== String(this.originalValue);
    },

    // private
    afterRender : function(){
        Ext.form.Field.superclass.afterRender.call(this);
        this.initEvents();
        this.initValue();
    },

    // private
    fireKey : function(e){
        if(e.isSpecialKey()){
            this.fireEvent("specialkey", this, e);
        }
    },

    /**
     * Resets the current field value to the originally loaded value and clears any validation messages
     */
    reset : function(){
        this.setValue(this.originalValue);
        this.clearInvalid();
    },

    // private
    initEvents : function(){
        this.el.on(Ext.isIE || Ext.isSafari3 ? "keydown" : "keypress", this.fireKey,  this);
        this.el.on("focus", this.onFocus,  this);
        
        // fix weird FF/Win editor issue when changing OS window focus
        var o = this.inEditor && Ext.isWindows && Ext.isGecko ? {buffer:10} : null;
        this.el.on("blur", this.onBlur,  this, o);

        // reference to original value for reset
        this.originalValue = this.getValue();
    },

    // private
    onFocus : function(){
        if(!Ext.isOpera && this.focusClass){ // don't touch in Opera
            this.el.addClass(this.focusClass);
        }
        if(!this.hasFocus){
            this.hasFocus = true;
            this.startValue = this.getValue();
            this.fireEvent("focus", this);
        }
    },

    // private
    beforeBlur : Ext.emptyFn,

    // private
    onBlur : function(){
        this.beforeBlur();
        if(!Ext.isOpera && this.focusClass){ // don't touch in Opera
            this.el.removeClass(this.focusClass);
        }
        this.hasFocus = false;
        if(this.validationEvent !== false && this.validateOnBlur && this.validationEvent != "blur"){
            this.validate();
        }
        var v = this.getValue();
        if(String(v) !== String(this.startValue)){
            this.fireEvent('change', this, v, this.startValue);
        }
        this.fireEvent("blur", this);
    },

    /**
     * Returns whether or not the field value is currently valid
     * @param {Boolean} preventMark True to disable marking the field invalid
     * @return {Boolean} True if the value is valid, else false
     */
    isValid : function(preventMark){
        if(this.disabled){
            return true;
        }
        var restore = this.preventMark;
        this.preventMark = preventMark === true;
        var v = this.validateValue(this.processValue(this.getRawValue()));
        this.preventMark = restore;
        return v;
    },

    /**
     * Validates the field value
     * @return {Boolean} True if the value is valid, else false
     */
    validate : function(){
        if(this.disabled || this.validateValue(this.processValue(this.getRawValue()))){
            this.clearInvalid();
            return true;
        }
        return false;
    },

    // protected - should be overridden by subclasses if necessary to prepare raw values for validation
    processValue : function(value){
        return value;
    },

    // private
    // Subclasses should provide the validation implementation by overriding this
    validateValue : function(value){
        return true;
    },

    /**
     * Mark this field as invalid, using {@link #msgTarget} to determine how to display the error and 
     * applying {@link #invalidClass} to the field's element.
     * @param {String} msg (optional) The validation message (defaults to {@link #invalidText})
     */
    markInvalid : function(msg){
        if(!this.rendered || this.preventMark){ // not rendered
            return;
        }
        this.el.addClass(this.invalidClass);
        msg = msg || this.invalidText;

        switch(this.msgTarget){
            case 'qtip':
                this.el.dom.qtip = msg;
                this.el.dom.qclass = 'x-form-invalid-tip';
                if(Ext.QuickTips){ // fix for floating editors interacting with DND
                    Ext.QuickTips.enable();
                }
                break;
            case 'title':
                this.el.dom.title = msg;
                break;
            case 'under':
                if(!this.errorEl){
                    var elp = this.getErrorCt();
                    if(!elp){ // field has no container el
                        this.el.dom.title = msg;
                        break;
                    }
                    this.errorEl = elp.createChild({cls:'x-form-invalid-msg'});
                    this.errorEl.setWidth(elp.getWidth(true)-20);
                }
                this.errorEl.update(msg);
                Ext.form.Field.msgFx[this.msgFx].show(this.errorEl, this);
                break;
            case 'side':
                if(!this.errorIcon){
                    var elp = this.getErrorCt();
                    if(!elp){ // field has no container el
                        this.el.dom.title = msg;
                        break;
                    }
                    this.errorIcon = elp.createChild({cls:'x-form-invalid-icon'});
                }
                this.alignErrorIcon();
                this.errorIcon.dom.qtip = msg;
                this.errorIcon.dom.qclass = 'x-form-invalid-tip';
                this.errorIcon.show();
                this.on('resize', this.alignErrorIcon, this);
                break;
            default:
                var t = Ext.getDom(this.msgTarget);
                t.innerHTML = msg;
                t.style.display = this.msgDisplay;
                break;
        }
        this.fireEvent('invalid', this, msg);
    },
    
    // private
    getErrorCt : function(){
        return this.el.findParent('.x-form-element', 5, true) || // use form element wrap if available
            this.el.findParent('.x-form-field-wrap', 5, true);   // else direct field wrap
    },

    // private
    alignErrorIcon : function(){
        this.errorIcon.alignTo(this.el, 'tl-tr', [2, 0]);
    },

    /**
     * Clear any invalid styles/messages for this field
     */
    clearInvalid : function(){
        if(!this.rendered || this.preventMark){ // not rendered
            return;
        }
        this.el.removeClass(this.invalidClass);
        switch(this.msgTarget){
            case 'qtip':
                this.el.dom.qtip = '';
                break;
            case 'title':
                this.el.dom.title = '';
                break;
            case 'under':
                if(this.errorEl){
                    Ext.form.Field.msgFx[this.msgFx].hide(this.errorEl, this);
                }
                break;
            case 'side':
                if(this.errorIcon){
                    this.errorIcon.dom.qtip = '';
                    this.errorIcon.hide();
                    this.un('resize', this.alignErrorIcon, this);
                }
                break;
            default:
                var t = Ext.getDom(this.msgTarget);
                t.innerHTML = '';
                t.style.display = 'none';
                break;
        }
        this.fireEvent('valid', this);
    },

    /**
     * Returns the raw data value which may or may not be a valid, defined value.  To return a normalized value see {@link #getValue}.
     * @return {Mixed} value The field value
     */
    getRawValue : function(){
        var v = this.rendered ? this.el.getValue() : Ext.value(this.value, '');
        if(v === this.emptyText){
            v = '';
        }
        return v;
    },

    /**
     * Returns the normalized data value (undefined or emptyText will be returned as '').  To return the raw value see {@link #getRawValue}.
     * @return {Mixed} value The field value
     */
    getValue : function(){
        if(!this.rendered) {
            return this.value;
        }
        var v = this.el.getValue();
        if(v === this.emptyText || v === undefined){
            v = '';
        }
        return v;
    },

    /**
     * Sets the underlying DOM field's value directly, bypassing validation.  To set the value with validation see {@link #setValue}.
     * @param {Mixed} value The value to set
     * @return {Mixed} value The field value that is set
     */
    setRawValue : function(v){
        return this.el.dom.value = (v === null || v === undefined ? '' : v);
    },

    /**
     * Sets a data value into the field and validates it.  To set the value directly without validation see {@link #setRawValue}.
     * @param {Mixed} value The value to set
     */
    setValue : function(v){
        this.value = v;
        if(this.rendered){
            this.el.dom.value = (v === null || v === undefined ? '' : v);
            this.validate();
        }
    },

    // private
    adjustSize : function(w, h){
        var s = Ext.form.Field.superclass.adjustSize.call(this, w, h);
        s.width = this.adjustWidth(this.el.dom.tagName, s.width);
        return s;
    },

    // private
    adjustWidth : function(tag, w){
        tag = tag.toLowerCase();
        if(typeof w == 'number' && !Ext.isSafari){
            if(Ext.isIE && (tag == 'input' || tag == 'textarea')){
                if(tag == 'input' && !Ext.isStrict){
                    return this.inEditor ? w : w - 3;
                }
                if(tag == 'input' && Ext.isStrict){
                    return w - (Ext.isIE6 ? 4 : 1);
                }
                if(tag == 'textarea' && Ext.isStrict){
                    return w-2;
                }
            }else if(Ext.isOpera && Ext.isStrict){
                if(tag == 'input'){
                    return w + 2;
                }
                if(tag == 'textarea'){
                    return w-2;
                }
            }
        }
        return w;
    }

    /**
     * @cfg {Boolean} autoWidth @hide
     */
    /**
     * @cfg {Boolean} autoHeight @hide
     */

    /**
     * @cfg {String} autoEl @hide
     */
});

Ext.form.MessageTargets = {
    'qtip' : {
        mark: function(f){
            this.el.dom.qtip = msg;
            this.el.dom.qclass = 'x-form-invalid-tip';
            if(Ext.QuickTips){ // fix for floating editors interacting with DND
                Ext.QuickTips.enable();
            }
        },
        clear: function(f){
            this.el.dom.qtip = '';
        }
    },
    'title' : {
        mark: function(f){
            this.el.dom.title = msg;
        },
        clear: function(f){
            this.el.dom.title = '';
        }
    },
    'under' : {
        mark: function(f){
            if(!this.errorEl){
                var elp = this.getErrorCt();
                if(!elp){ // field has no container el
                    this.el.dom.title = msg;
                    return;
                }
                this.errorEl = elp.createChild({cls:'x-form-invalid-msg'});
                this.errorEl.setWidth(elp.getWidth(true)-20);
            }
            this.errorEl.update(msg);
            Ext.form.Field.msgFx[this.msgFx].show(this.errorEl, this);
        },
        clear: function(f){
            if(this.errorEl){
                Ext.form.Field.msgFx[this.msgFx].hide(this.errorEl, this);
            }else{
                this.el.dom.title = '';
            }
        }
    },
    'side' : {
        mark: function(f){
            if(!this.errorIcon){
                var elp = this.getErrorCt();
                if(!elp){ // field has no container el
                    this.el.dom.title = msg;
                    return;
                }
                this.errorIcon = elp.createChild({cls:'x-form-invalid-icon'});
            }
            this.alignErrorIcon();
            this.errorIcon.dom.qtip = msg;
            this.errorIcon.dom.qclass = 'x-form-invalid-tip';
            this.errorIcon.show();
            this.on('resize', this.alignErrorIcon, this);
        },
        clear: function(f){
            if(this.errorIcon){
                this.errorIcon.dom.qtip = '';
                this.errorIcon.hide();
                this.un('resize', this.alignErrorIcon, this);
            }else{
                this.el.dom.title = '';
            }
        }
    },
    'around' : {
        mark: function(f){

        },
        clear: function(f){

        }
    }
};


// anything other than normal should be considered experimental
Ext.form.Field.msgFx = {
    normal : {
        show: function(msgEl, f){
            msgEl.setDisplayed('block');
        },

        hide : function(msgEl, f){
            msgEl.setDisplayed(false).update('');
        }
    },

    slide : {
        show: function(msgEl, f){
            msgEl.slideIn('t', {stopFx:true});
        },

        hide : function(msgEl, f){
            msgEl.slideOut('t', {stopFx:true,useDisplay:true});
        }
    },

    slideRight : {
        show: function(msgEl, f){
            msgEl.fixDisplay();
            msgEl.alignTo(f.el, 'tl-tr');
            msgEl.slideIn('l', {stopFx:true});
        },

        hide : function(msgEl, f){
            msgEl.slideOut('l', {stopFx:true,useDisplay:true});
        }
    }
};
Ext.reg('field', Ext.form.Field);

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.TextField
 * @extends Ext.form.Field
 * Basic text field.  Can be used as a direct replacement for traditional text inputs, or as the base
 * class for more sophisticated input controls (like {@link Ext.form.TextArea} and {@link Ext.form.ComboBox}).
 * @constructor
 * Creates a new TextField
 * @param {Object} config Configuration options
 */
Ext.form.TextField = Ext.extend(Ext.form.Field,  {
    /**
     * @cfg {String} vtypeText A custom error message to display in place of the default message provided
     * for the {@link #vtype} currently set for this field (defaults to '').  Only applies if vtype is set, else ignored.
     */
    /**
     * @cfg {Boolean} grow True if this field should automatically grow and shrink to its content
     */
    grow : false,
    /**
     * @cfg {Number} growMin The minimum width to allow when grow = true (defaults to 30)
     */
    growMin : 30,
    /**
     * @cfg {Number} growMax The maximum width to allow when grow = true (defaults to 800)
     */
    growMax : 800,
    /**
     * @cfg {String} vtype A validation type name as defined in {@link Ext.form.VTypes} (defaults to null)
     */
    vtype : null,
    /**
     * @cfg {RegExp} maskRe An input mask regular expression that will be used to filter keystrokes that don't match
     * (defaults to null)
     */
    maskRe : null,
    /**
     * @cfg {Boolean} disableKeyFilter True to disable input keystroke filtering (defaults to false)
     */
    disableKeyFilter : false,
    /**
     * @cfg {Boolean} allowBlank False to validate that the value length > 0 (defaults to true)
     */
    allowBlank : true,
    /**
     * @cfg {Number} minLength Minimum input field length required (defaults to 0)
     */
    minLength : 0,
    /**
     * @cfg {Number} maxLength Maximum input field length allowed (defaults to Number.MAX_VALUE)
     */
    maxLength : Number.MAX_VALUE,
    /**
     * @cfg {String} minLengthText Error text to display if the minimum length validation fails (defaults to
     * "The minimum length for this field is {minLength}")
     */
    minLengthText : "The minimum length for this field is {0}",
    /**
     * @cfg {String} maxLengthText Error text to display if the maximum length validation fails (defaults to
     * "The maximum length for this field is {maxLength}")
     */
    maxLengthText : "The maximum length for this field is {0}",
    /**
     * @cfg {Boolean} selectOnFocus True to automatically select any existing field text when the field receives
     * input focus (defaults to false)
     */
    selectOnFocus : false,
    /**
     * @cfg {String} blankText Error text to display if the allow blank validation fails (defaults to "This field is required")
     */
    blankText : "This field is required",
    /**
     * @cfg {Function} validator A custom validation function to be called during field validation (defaults to null).
     * If available, this function will be called only after the basic validators all return true, and will be passed the
     * current field value and expected to return boolean true if the value is valid or a string error message if invalid.
     */
    validator : null,
    /**
     * @cfg {RegExp} regex A JavaScript RegExp object to be tested against the field value during validation (defaults to null).
     * If available, this regex will be evaluated only after the basic validators all return true, and will be passed the
     * current field value.  If the test fails, the field will be marked invalid using {@link #regexText}.
     */
    regex : null,
    /**
     * @cfg {String} regexText The error text to display if {@link #regex} is used and the test fails during
     * validation (defaults to "")
     */
    regexText : "",
    /**
     * @cfg {String} emptyText The default text to display in an empty field (defaults to null).
     */
    emptyText : null,
    /**
     * @cfg {String} emptyClass The CSS class to apply to an empty field to style the {@link #emptyText} (defaults to
     * 'x-form-empty-field').  This class is automatically added and removed as needed depending on the current field value.
     */
    emptyClass : 'x-form-empty-field',

    /**
     * @cfg {Boolean} enableKeyEvents True to enable the proxying of key events for the HTML input field (defaults to false)
     */

    initComponent : function(){
        Ext.form.TextField.superclass.initComponent.call(this);
        this.addEvents(
            /**
             * @event autosize
             * Fires when the autosize function is triggered.  The field may or may not have actually changed size
             * according to the default logic, but this event provides a hook for the developer to apply additional
             * logic at runtime to resize the field if needed.
             * @param {Ext.form.Field} this This text field
             * @param {Number} width The new field width
             */
            'autosize',

            /**
             * @event keydown
             * Keydown input field event. This event only fires if enableKeyEvents is set to true.
             * @param {Ext.form.TextField} this This text field
             * @param {Ext.EventObject} e
             */
            'keydown',
            /**
             * @event keyup
             * Keyup input field event. This event only fires if enableKeyEvents is set to true.
             * @param {Ext.form.TextField} this This text field
             * @param {Ext.EventObject} e
             */
            'keyup',
            /**
             * @event keypress
             * Keypress input field event. This event only fires if enableKeyEvents is set to true.
             * @param {Ext.form.TextField} this This text field
             * @param {Ext.EventObject} e
             */
            'keypress'
        );
    },

    // private
    initEvents : function(){
        Ext.form.TextField.superclass.initEvents.call(this);
        if(this.validationEvent == 'keyup'){
            this.validationTask = new Ext.util.DelayedTask(this.validate, this);
            this.el.on('keyup', this.filterValidation, this);
        }
        else if(this.validationEvent !== false){
            this.el.on(this.validationEvent, this.validate, this, {buffer: this.validationDelay});
        }
        if(this.selectOnFocus || this.emptyText){
            this.on("focus", this.preFocus, this);
            this.el.on('mousedown', function(){
                if(!this.hasFocus){
                    this.el.on('mouseup', function(e){
                        e.preventDefault();
                    }, this, {single:true});
                }
            }, this);
            if(this.emptyText){
                this.on('blur', this.postBlur, this);
                this.applyEmptyText();
            }
        }
        if(this.maskRe || (this.vtype && this.disableKeyFilter !== true && (this.maskRe = Ext.form.VTypes[this.vtype+'Mask']))){
            this.el.on("keypress", this.filterKeys, this);
        }
        if(this.grow){
            this.el.on("keyup", this.onKeyUpBuffered,  this, {buffer:50});
            this.el.on("click", this.autoSize,  this);
        }

        if(this.enableKeyEvents){
            this.el.on("keyup", this.onKeyUp, this);
            this.el.on("keydown", this.onKeyDown, this);
            this.el.on("keypress", this.onKeyPress, this);
        }
    },

    processValue : function(value){
        if(this.stripCharsRe){
            var newValue = value.replace(this.stripCharsRe, '');
            if(newValue !== value){
                this.setRawValue(newValue);
                return newValue;
            }
        }
        return value;
    },

    filterValidation : function(e){
        if(!e.isNavKeyPress()){
            this.validationTask.delay(this.validationDelay);
        }
    },

    // private
    onKeyUpBuffered : function(e){
        if(!e.isNavKeyPress()){
            this.autoSize();
        }
    },

    // private
    onKeyUp : function(e){
        this.fireEvent('keyup', this, e);
    },

    // private
    onKeyDown : function(e){
        this.fireEvent('keydown', this, e);
    },

    // private
    onKeyPress : function(e){
        this.fireEvent('keypress', this, e);
    },

    /**
     * Resets the current field value to the originally-loaded value and clears any validation messages.
     * Also adds emptyText and emptyClass if the original value was blank.
     */
    reset : function(){
        Ext.form.TextField.superclass.reset.call(this);
        this.applyEmptyText();
    },

    applyEmptyText : function(){
        if(this.rendered && this.emptyText && this.getRawValue().length < 1){
            this.setRawValue(this.emptyText);
            this.el.addClass(this.emptyClass);
        }
    },

    // private
    preFocus : function(){
        if(this.emptyText){
            if(this.el.dom.value == this.emptyText){
                this.setRawValue('');
            }
            this.el.removeClass(this.emptyClass);
        }
        if(this.selectOnFocus){
            this.el.dom.select();
        }
    },

    // private
    postBlur : function(){
        this.applyEmptyText();
    },

    // private
    filterKeys : function(e){
        if(e.ctrlKey){
            return;
        }
        var k = e.getKey();
        if(Ext.isGecko && (e.isNavKeyPress() || k == e.BACKSPACE || (k == e.DELETE && e.button == -1))){
            return;
        }
        var c = e.getCharCode(), cc = String.fromCharCode(c);
        if(!Ext.isGecko && e.isSpecialKey() && !cc){
            return;
        }
        if(!this.maskRe.test(cc)){
            e.stopEvent();
        }
    },

    setValue : function(v){
        if(this.emptyText && this.el && v !== undefined && v !== null && v !== ''){
            this.el.removeClass(this.emptyClass);
        }
        Ext.form.TextField.superclass.setValue.apply(this, arguments);
        this.applyEmptyText();
        this.autoSize();
    },

    /**
     * Validates a value according to the field's validation rules and marks the field as invalid
     * if the validation fails
     * @param {Mixed} value The value to validate
     * @return {Boolean} True if the value is valid, else false
     */
    validateValue : function(value){
        if(value.length < 1 || value === this.emptyText){ // if it's blank
             if(this.allowBlank){
                 this.clearInvalid();
                 return true;
             }else{
                 this.markInvalid(this.blankText);
                 return false;
             }
        }
        if(value.length < this.minLength){
            this.markInvalid(String.format(this.minLengthText, this.minLength));
            return false;
        }
        if(value.length > this.maxLength){
            this.markInvalid(String.format(this.maxLengthText, this.maxLength));
            return false;
        }
        if(this.vtype){
            var vt = Ext.form.VTypes;
            if(!vt[this.vtype](value, this)){
                this.markInvalid(this.vtypeText || vt[this.vtype +'Text']);
                return false;
            }
        }
        if(typeof this.validator == "function"){
            var msg = this.validator(value);
            if(msg !== true){
                this.markInvalid(msg);
                return false;
            }
        }
        if(this.regex && !this.regex.test(value)){
            this.markInvalid(this.regexText);
            return false;
        }
        return true;
    },

    /**
     * Selects text in this field
     * @param {Number} start (optional) The index where the selection should start (defaults to 0)
     * @param {Number} end (optional) The index where the selection should end (defaults to the text length)
     */
    selectText : function(start, end){
        var v = this.getRawValue();
        if(v.length > 0){
            start = start === undefined ? 0 : start;
            end = end === undefined ? v.length : end;
            var d = this.el.dom;
            if(d.setSelectionRange){
                d.setSelectionRange(start, end);
            }else if(d.createTextRange){
                var range = d.createTextRange();
                range.moveStart("character", start);
                range.moveEnd("character", end-v.length);
                range.select();
            }
        }
    },

    /**
     * Automatically grows the field to accomodate the width of the text up to the maximum field width allowed.
     * This only takes effect if grow = true, and fires the {@link #autosize} event.
     */
    autoSize : function(){
        if(!this.grow || !this.rendered){
            return;
        }
        if(!this.metrics){
            this.metrics = Ext.util.TextMetrics.createInstance(this.el);
        }
        var el = this.el;
        var v = el.dom.value;
        var d = document.createElement('div');
        d.appendChild(document.createTextNode(v));
        v = d.innerHTML;
        d = null;
        v += "&#160;";
        var w = Math.min(this.growMax, Math.max(this.metrics.getWidth(v) + /* add extra padding */ 10, this.growMin));
        this.el.setWidth(w);
        this.fireEvent("autosize", this, w);
    }
});
Ext.reg('textfield', Ext.form.TextField);

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.Hidden
 * @extends Ext.form.Field
 * A basic hidden field for storing hidden values in forms that need to be passed in the form submit.
 * @constructor
 * Create a new Hidden field.
 * @param {Object} config Configuration options
 */
Ext.form.Hidden = Ext.extend(Ext.form.Field, {
    // private
    inputType : 'hidden',

    // private
    onRender : function(){
        Ext.form.Hidden.superclass.onRender.apply(this, arguments);
    },

    // private
    initEvents : function(){
        this.originalValue = this.getValue();
    },

    // These are all private overrides
    setSize : Ext.emptyFn,
    setWidth : Ext.emptyFn,
    setHeight : Ext.emptyFn,
    setPosition : Ext.emptyFn,
    setPagePosition : Ext.emptyFn,
    markInvalid : Ext.emptyFn,
    clearInvalid : Ext.emptyFn
});
Ext.reg('hidden', Ext.form.Hidden);
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.TextArea
 * @extends Ext.form.TextField
 * Multiline text field.  Can be used as a direct replacement for traditional textarea fields, plus adds
 * support for auto-sizing.
 * @constructor
 * Creates a new TextArea
 * @param {Object} config Configuration options
 */
Ext.form.TextArea = Ext.extend(Ext.form.TextField,  {
    /**
     * @cfg {Number} growMin The minimum height to allow when grow = true (defaults to 60)
     */
    growMin : 60,
    /**
     * @cfg {Number} growMax The maximum height to allow when grow = true (defaults to 1000)
     */
    growMax: 1000,
    growAppend : '&#160;\n&#160;',
    growPad : 0,

    enterIsSpecial : false,

    /**
     * @cfg {Boolean} preventScrollbars True to prevent scrollbars from appearing regardless of how much text is
     * in the field (equivalent to setting overflow: hidden, defaults to false)
     */
    preventScrollbars: false,
    /**
     * @cfg {String/Object} autoCreate A DomHelper element spec, or true for a default element spec (defaults to
     * {tag: "textarea", style: "width:100px;height:60px;", autocomplete: "off"})
     */

    // private
    onRender : function(ct, position){
        if(!this.el){
            this.defaultAutoCreate = {
                tag: "textarea",
                style:"width:100px;height:60px;",
                autocomplete: "off"
            };
        }
        Ext.form.TextArea.superclass.onRender.call(this, ct, position);
        if(this.grow){
            this.textSizeEl = Ext.DomHelper.append(document.body, {
                tag: "pre", cls: "x-form-grow-sizer"
            });
            if(this.preventScrollbars){
                this.el.setStyle("overflow", "hidden");
            }
            this.el.setHeight(this.growMin);
        }
    },

    onDestroy : function(){
        if(this.textSizeEl){
            Ext.removeNode(this.textSizeEl);
        }
        Ext.form.TextArea.superclass.onDestroy.call(this);
    },

    fireKey : function(e){
        if(e.isSpecialKey() && (this.enterIsSpecial || (e.getKey() != e.ENTER || e.hasModifier()))){
            this.fireEvent("specialkey", this, e);
        }
    },

    // private
    onKeyUp : function(e){
        if(!e.isNavKeyPress() || e.getKey() == e.ENTER){
            this.autoSize();
        }
        Ext.form.TextArea.superclass.onKeyUp.call(this, e);
    },

    /**
     * Automatically grows the field to accomodate the height of the text up to the maximum field height allowed.
     * This only takes effect if grow = true, and fires the {@link #autosize} event if the height changes.
     */
    autoSize : function(){
        if(!this.grow || !this.textSizeEl){
            return;
        }
        var el = this.el;
        var v = el.dom.value;
        var ts = this.textSizeEl;
        ts.innerHTML = '';
        ts.appendChild(document.createTextNode(v));
        v = ts.innerHTML;

        Ext.fly(ts).setWidth(this.el.getWidth());
        if(v.length < 1){
            v = "&#160;&#160;";
        }else{
            if(Ext.isIE){
                v = v.replace(/\n/g, '<p>&#160;</p>');
            }
            v += this.growAppend;
        }
        ts.innerHTML = v;
        var h = Math.min(this.growMax, Math.max(ts.offsetHeight, this.growMin)+this.growPad);
        if(h != this.lastHeight){
            this.lastHeight = h;
            this.el.setHeight(h);
            this.fireEvent("autosize", this, h);
        }
    }
});
Ext.reg('textarea', Ext.form.TextArea);
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.FieldSet
 * @extends Ext.Panel
 * Standard container used for grouping form fields.
 * @constructor
 * @param {Object} config Configuration options
 */
Ext.form.FieldSet = Ext.extend(Ext.Panel, {
    /**
     * @cfg {Mixed} checkboxToggle True to render a checkbox into the fieldset frame just in front of the legend,
     * or a DomHelper config object to create the checkbox.  (defaults to false).
     * The fieldset will be expanded or collapsed when the checkbox is toggled.
     */
    /**
     * @cfg {String} checkboxName The name to assign to the fieldset's checkbox if {@link #checkboxToggle} = true
     * (defaults to '[checkbox id]-checkbox').
     */
    /**
     * @cfg {Number} labelWidth The width of labels. This property cascades to child containers.
     */
    /**
     * @cfg {String} itemCls A css class to apply to the x-form-item of fields. This property cascades to child containers.
     */
    /**
     * @cfg {String} baseCls The base CSS class applied to the fieldset (defaults to 'x-fieldset').
     */
    baseCls:'x-fieldset',
    /**
     * @cfg {String} layout The {@link Ext.Container#layout} to use inside the fieldset (defaults to 'form').
     */
    layout: 'form',

    // private
    onRender : function(ct, position){
        if(!this.el){
            this.el = document.createElement('fieldset');
            this.el.id = this.id;
            if (this.title || this.header || this.checkboxToggle) {
                this.el.appendChild(document.createElement('legend')).className = 'x-fieldset-header';
            }
        }

        Ext.form.FieldSet.superclass.onRender.call(this, ct, position);

        if(this.checkboxToggle){
            var o = typeof this.checkboxToggle == 'object' ?
                    this.checkboxToggle :
                    {tag: 'input', type: 'checkbox', name: this.checkboxName || this.id+'-checkbox'};
            this.checkbox = this.header.insertFirst(o);
            this.checkbox.dom.checked = !this.collapsed;
            this.checkbox.on('click', this.onCheckClick, this);
        }
    },

    // private
    onCollapse : function(doAnim, animArg){
        if(this.checkbox){
            this.checkbox.dom.checked = false;
        }
        this.afterCollapse();

    },

    // private
    onExpand : function(doAnim, animArg){
        if(this.checkbox){
            this.checkbox.dom.checked = true;
        }
        this.afterExpand();
    },

    /* //protected
     * This function is called by the fieldset's checkbox when it is toggled (only applies when
     * checkboxToggle = true).  This method should never be called externally, but can be
     * overridden to provide custom behavior when the checkbox is toggled if needed.
     */
    onCheckClick : function(){
        this[this.checkbox.dom.checked ? 'expand' : 'collapse']();
    }

    /**
     * @cfg {String/Number} activeItem
     * @hide
     */
    /**
     * @cfg {Mixed} applyTo
     * @hide
     */
    /**
     * @cfg {Object/Array} bbar
     * @hide
     */
    /**
     * @cfg {Boolean} bodyBorder
     * @hide
     */
    /**
     * @cfg {Boolean} border
     * @hide
     */
    /**
     * @cfg {Boolean/Number} bufferResize
     * @hide
     */
    /**
     * @cfg {String} buttonAlign
     * @hide
     */
    /**
     * @cfg {Array} buttons
     * @hide
     */
    /**
     * @cfg {Boolean} collapseFirst
     * @hide
     */
    /**
     * @cfg {String} defaultType
     * @hide
     */
    /**
     * @cfg {String} disabledClass
     * @hide
     */
    /**
     * @cfg {String} elements
     * @hide
     */
    /**
     * @cfg {Boolean} floating
     * @hide
     */
    /**
     * @cfg {Boolean} footer
     * @hide
     */
    /**
     * @cfg {Boolean} frame
     * @hide
     */
    /**
     * @cfg {Boolean} header
     * @hide
     */
    /**
     * @cfg {Boolean} headerAsText
     * @hide
     */
    /**
     * @cfg {Boolean} hideCollapseTool
     * @hide
     */
    /**
     * @cfg {String} iconCls
     * @hide
     */
    /**
     * @cfg {Boolean/String} shadow
     * @hide
     */
    /**
     * @cfg {Number} shadowOffset
     * @hide
     */
    /**
     * @cfg {Boolean} shim
     * @hide
     */
    /**
     * @cfg {Object/Array} tbar
     * @hide
     */
    /**
     * @cfg {Boolean} titleCollapse
     * @hide
     */
    /**
     * @cfg {Array} tools
     * @hide
     */
    /**
     * @cfg {String} xtype
     * @hide
     */
    /**
     * @property header
     * @hide
     */
    /**
     * @property footer
     * @hide
     */
    /**
     * @method focus
     * @hide
     */
    /**
     * @method getBottomToolbar
     * @hide
     */
    /**
     * @method getTopToolbar
     * @hide
     */
    /**
     * @method setIconClass
     * @hide
     */
    /**
     * @event activate
     * @hide
     */
    /**
     * @event beforeclose
     * @hide
     */
    /**
     * @event bodyresize
     * @hide
     */
    /**
     * @event close
     * @hide
     */
    /**
     * @event deactivate
     * @hide
     */
});
Ext.reg('fieldset', Ext.form.FieldSet);


/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.Checkbox
 * @extends Ext.form.Field
 * Single checkbox field.  Can be used as a direct replacement for traditional checkbox fields.
 * @constructor
 * Creates a new Checkbox
 * @param {Object} config Configuration options
 */
Ext.form.Checkbox = Ext.extend(Ext.form.Field,  {
    /**
     * @cfg {String} checkedCls The CSS class to use when the control is checked (defaults to 'x-form-check-checked').
     * Note that this class applies to both checkboxes and radio buttons and is added to the control's wrapper element.
     */
    checkedCls: 'x-form-check-checked',
    /**
     * @cfg {String} focusCls The CSS class to use when the control receives input focus (defaults to 'x-form-check-focus').
     * Note that this class applies to both checkboxes and radio buttons and is added to the control's wrapper element.
     */
    focusCls: 'x-form-check-focus',
    /**
     * @cfg {String} overCls The CSS class to use when the control is hovered over (defaults to 'x-form-check-over').
     * Note that this class applies to both checkboxes and radio buttons and is added to the control's wrapper element.
     */
    overCls: 'x-form-check-over',
    /**
     * @cfg {String} mouseDownCls The CSS class to use when the control is being actively clicked (defaults to 'x-form-check-down').
     * Note that this class applies to both checkboxes and radio buttons and is added to the control's wrapper element.
     */
    mouseDownCls: 'x-form-check-down',
    /**
     * @cfg {Number} tabIndex The tabIndex for this field. Note this only applies to fields that are rendered,
     * not those which are built via applyTo (defaults to 0, which allows the browser to manage the tab index).
     */
    tabIndex: 0,
    /**
     * @cfg {Boolean} checked True if the checkbox should render already checked (defaults to false)
     */
    checked: false,
    /**
     * @cfg {String/Object} autoCreate A DomHelper element spec, or true for a default element spec (defaults to
     * {tag: "input", type: "checkbox", autocomplete: "off"}).
     */
    defaultAutoCreate: {tag: 'input', type: 'checkbox', autocomplete: 'off'},
    /**
     * @cfg {String} boxLabel The text that appears beside the checkbox (defaults to '')
     */
    /**
     * @cfg {String} inputValue The value that should go into the generated input element's value attribute
     * (defaults to undefined, with no value attribute)
     */
    /**
     * @cfg {Function} handler A function called when the {@link #checked} value changes (can be used instead of 
     * handling the check event)
     */

    // private
    baseCls: 'x-form-check',

    // private
    initComponent : function(){
        Ext.form.Checkbox.superclass.initComponent.call(this);
        this.addEvents(
            /**
             * @event check
             * Fires when the checkbox is checked or unchecked.
             * @param {Ext.form.Checkbox} this This checkbox
             * @param {Boolean} checked The new checked value
             */
            'check'
        );
    },

    // private
    initEvents : function(){
        Ext.form.Checkbox.superclass.initEvents.call(this);
        this.initCheckEvents();
    },

    // private
    initCheckEvents : function(){
        this.innerWrap.removeAllListeners();
        this.innerWrap.addClassOnOver(this.overCls);
        this.innerWrap.addClassOnClick(this.mouseDownCls);
        this.innerWrap.on('click', this.onClick, this);
        this.innerWrap.on('keyup', this.onKeyUp, this);
    },

    // private
    onRender : function(ct, position){
        Ext.form.Checkbox.superclass.onRender.call(this, ct, position);
        if(this.inputValue !== undefined){
            this.el.dom.value = this.inputValue;
        }
        this.el.addClass('x-hidden');

        this.innerWrap = this.el.wrap({
            tabIndex: this.tabIndex,
            cls: this.baseCls+'-wrap-inner'
        });
        this.wrap = this.innerWrap.wrap({cls: this.baseCls+'-wrap'});

        if(this.boxLabel){
            this.labelEl = this.innerWrap.createChild({
                tag: 'label',
                htmlFor: this.el.id,
                cls: 'x-form-cb-label',
                html: this.boxLabel
            });
        }

        this.imageEl = this.innerWrap.createChild({
            tag: 'img',
            src: Ext.BLANK_IMAGE_URL,
            cls: this.baseCls
        }, this.el);

        if(this.checked){
            this.setValue(true);
        }else{
            this.checked = this.el.dom.checked;
        }
        this.originalValue = this.checked;
    },

    // private
    onDestroy : function(){
        if(this.rendered){
            Ext.destroy(this.imageEl, this.labelEl, this.innerWrap, this.wrap);
        }
        Ext.form.Checkbox.superclass.onDestroy.call(this);
    },

    // private
    onFocus: function(e) {
        Ext.form.Checkbox.superclass.onFocus.call(this, e);
        this.el.addClass(this.focusCls);
    },

    // private
    onBlur: function(e) {
        Ext.form.Checkbox.superclass.onBlur.call(this, e);
        this.el.removeClass(this.focusCls);
    },

    // private
    onResize : function(){
        Ext.form.Checkbox.superclass.onResize.apply(this, arguments);
        if(!this.boxLabel && !this.fieldLabel){
            this.el.alignTo(this.wrap, 'c-c');
        }
    },

    // private
    onKeyUp : function(e){
        if(e.getKey() == Ext.EventObject.SPACE){
            this.onClick(e);
        }
    },

    // private
    onClick : function(e){
        if (!this.disabled && !this.readOnly) {
            this.toggleValue();
        }
        e.stopEvent();
    },

    // private
    onEnable : function(){
        Ext.form.Checkbox.superclass.onEnable.call(this);
        this.initCheckEvents();
    },

    // private
    onDisable : function(){
        Ext.form.Checkbox.superclass.onDisable.call(this);
        this.innerWrap.removeAllListeners();
    },

    toggleValue : function(){
        this.setValue(!this.checked);
    },

    // private
    getResizeEl : function(){
        if(!this.resizeEl){
            this.resizeEl = Ext.isSafari ? this.wrap : (this.wrap.up('.x-form-element', 5) || this.wrap);
        }
        return this.resizeEl;
    },

    // private
    getPositionEl : function(){
        return this.wrap;
    },

    // private
    getActionEl : function(){
        return this.wrap;
    },

    /**
     * Overridden and disabled. The editor element does not support standard valid/invalid marking. @hide
     * @method
     */
    markInvalid : Ext.emptyFn,
    /**
     * Overridden and disabled. The editor element does not support standard valid/invalid marking. @hide
     * @method
     */
    clearInvalid : Ext.emptyFn,

    // private
    initValue : Ext.emptyFn,

    /**
     * Returns the checked state of the checkbox.
     * @return {Boolean} True if checked, else false
     */
    getValue : function(){
        if(this.rendered){
            return this.el.dom.checked;
        }
        return false;
    },

    /**
     * Sets the checked state of the checkbox.
     * @param {Boolean/String} checked True, 'true', '1', or 'on' to check the checkbox, any other value will uncheck it.
     */
    setValue : function(v) {
        var checked = this.checked;
        this.checked = (v === true || v === 'true' || v == '1' || String(v).toLowerCase() == 'on');
        
        if(this.el && this.el.dom){
            this.el.dom.checked = this.checked;
            this.el.dom.defaultChecked = this.checked;
        }
        this.wrap[this.checked? 'addClass' : 'removeClass'](this.checkedCls);
        
        if(checked != this.checked){
            this.fireEvent("check", this, this.checked);
            if(this.handler){
                this.handler.call(this.scope || this, this, this.checked);
            }
        }
    }

    /**
     * @cfg {Mixed} value
     * @hide
     */
    /**
     * @cfg {String} disabledClass
     * @hide
     */
    /**
     * @cfg {String} focusClass
     * @hide
     */
});
Ext.reg('checkbox', Ext.form.Checkbox);

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.CheckboxGroup
 * @extends Ext.form.Field
 * A grouping container for {@link Ext.form.Checkbox} controls.
 * @constructor
 * Creates a new CheckboxGroup
 * @param {Object} config Configuration options
 */
Ext.form.CheckboxGroup = Ext.extend(Ext.form.Field, {
    /**
     * @cfg {String/Number/Array} columns Specifies the number of columns to use when displaying grouped
     * checkbox/radio controls using automatic layout.  This config can take several types of values:
     * <ul><li><b>'auto'</b> : <p class="sub-desc">The controls will be rendered one per column on one row and the width
     * of each column will be evenly distributed based on the width of the overall field container. This is the default.</p></li>
     * <li><b>Number</b> : <p class="sub-desc">If you specific a number (e.g., 3) that number of columns will be 
     * created and the contained controls will be automatically distributed based on the value of {@link #vertical}.</p></li>
     * <li><b>Array</b> : Object<p class="sub-desc">You can also specify an array of column widths, mixing integer
     * (fixed width) and float (percentage width) values as needed (e.g., [100, .25, .75]). Any integer values will
     * be rendered first, then any float values will be calculated as a percentage of the remaining space. Float
     * values do not have to add up to 1 (100%) although if you want the controls to take up the entire field
     * container you should do so.</p></li></ul>
     */
    columns : 'auto',
    /**
     * @cfg {Boolean} vertical True to distribute contained controls across columns, completely filling each column 
     * top to bottom before starting on the next column.  The number of controls in each column will be automatically
     * calculated to keep columns as even as possible.  The default value is false, so that controls will be added
     * to columns one at a time, completely filling each row left to right before starting on the next row.
     */
    vertical : false,
    /**
     * @cfg {Boolean} allowBlank False to validate that at least one item in the group is checked (defaults to true).
     * If no items are selected at validation time, {@link @blankText} will be used as the error text.
     */
    allowBlank : true,
    /**
     * @cfg {String} blankText Error text to display if the {@link #allowBlank} validation fails (defaults to "You must 
     * select at least one item in this group")
     */
    blankText : "You must select at least one item in this group",
    
    // private
    defaultType : 'checkbox',
    
    // private
    groupCls: 'x-form-check-group',
    
    // private
    onRender : function(ct, position){
        if(!this.el){
            var panelCfg = {
                cls: this.groupCls,
                layout: 'column',
                border: false,
                renderTo: ct
            };
            var colCfg = {
                defaultType: this.defaultType,
                layout: 'form',
                border: false,
                defaults: {
                    hideLabel: true,
                    anchor: '100%'
                }
            }
            
            if(this.items[0].items){
                
                // The container has standard ColumnLayout configs, so pass them in directly
                
                Ext.apply(panelCfg, {
                    layoutConfig: {columns: this.items.length},
                    defaults: this.defaults,
                    items: this.items
                })
                for(var i=0, len=this.items.length; i<len; i++){
                    Ext.applyIf(this.items[i], colCfg);
                };
                
            }else{
                
                // The container has field item configs, so we have to generate the column
                // panels first then move the items into the columns as needed.
                
                var numCols, cols = [];
                
                if(typeof this.columns == 'string'){ // 'auto' so create a col per item
                    this.columns = this.items.length;
                }
                if(!Ext.isArray(this.columns)){
                    var cs = [];
                    for(var i=0; i<this.columns; i++){
                        cs.push((100/this.columns)*.01); // distribute by even %
                    }
                    this.columns = cs;
                }
                
                numCols = this.columns.length;
                
                // Generate the column configs with the correct width setting
                for(var i=0; i<numCols; i++){
                    var cc = Ext.apply({items:[]}, colCfg);
                    cc[this.columns[i] <= 1 ? 'columnWidth' : 'width'] = this.columns[i];
                    if(this.defaults){
                        cc.defaults = Ext.apply(cc.defaults || {}, this.defaults)
                    }
                    cols.push(cc);
                };
                
                // Distribute the original items into the columns
                if(this.vertical){
                    var rows = Math.ceil(this.items.length / numCols), ri = 0;
                    for(var i=0, len=this.items.length; i<len; i++){
                        if(i>0 && i%rows==0){
                            ri++;
                        }
                        if(this.items[i].fieldLabel){
                            this.items[i].hideLabel = false;
                        }
                        cols[ri].items.push(this.items[i]);
                    };
                }else{
                    for(var i=0, len=this.items.length; i<len; i++){
                        var ci = i % numCols;
                        if(this.items[i].fieldLabel){
                            this.items[i].hideLabel = false;
                        }
                        cols[ci].items.push(this.items[i]);
                    };
                }
                
                Ext.apply(panelCfg, {
                    layoutConfig: {columns: numCols},
                    items: cols
                });
            }
            
            this.panel = new Ext.Panel(panelCfg);
            this.el = this.panel.getEl();
            
            if(this.forId && this.itemCls){
                var l = this.el.up(this.itemCls).child('label', true);
                if(l){
                    l.setAttribute('htmlFor', this.forId);
                }
            }
            
            var fields = this.panel.findBy(function(c){
                return c.isFormField;
            }, this);
            
            this.items = new Ext.util.MixedCollection();
            this.items.addAll(fields);
        }
        Ext.form.CheckboxGroup.superclass.onRender.call(this, ct, position);
    },
    
    // private
    validateValue : function(value){
        if(!this.allowBlank){
            var blank = true;
            this.items.each(function(f){
                if(f.checked){
                    return blank = false;
                }
            }, this);
            if(blank){
                this.markInvalid(this.blankText);
                return false;
            }
        }
        return true;
    },
    
    // private
    onDisable : function(){
        this.items.each(function(item){
            item.disable();
        })
    },

    // private
    onEnable : function(){
        this.items.each(function(item){
            item.enable();
        })
    },
    
    // private
    onResize : function(w, h){
        this.panel.setSize(w, h);
        this.panel.doLayout();
    },
    
    // inherit docs from Field
    reset : function(){
        Ext.form.CheckboxGroup.superclass.reset.call(this);
        this.items.each(function(c){
            if(c.reset){
                c.reset();
            }
        }, this);
    },
    
    /**
     * @cfg {String} name
     * @hide
     */
    /**
     * @method initValue
     * @hide
     */
    initValue : Ext.emptyFn,
    /**
     * @method getValue
     * @hide
     */
    getValue : Ext.emptyFn,
    /**
     * @method getRawValue
     * @hide
     */
    getRawValue : Ext.emptyFn,
    /**
     * @method setValue
     * @hide
     */
    setValue : Ext.emptyFn,
    /**
     * @method setRawValue
     * @hide
     */
    setRawValue : Ext.emptyFn
    
});

Ext.reg('checkboxgroup', Ext.form.CheckboxGroup);

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.Radio
 * @extends Ext.form.Checkbox
 * Single radio field.  Same as Checkbox, but provided as a convenience for automatically setting the input type.
 * Radio grouping is handled automatically by the browser if you give each radio in a group the same name.
 * @constructor
 * Creates a new Radio
 * @param {Object} config Configuration options
 */
Ext.form.Radio = Ext.extend(Ext.form.Checkbox, {
    // private
    inputType: 'radio',
    // private
    baseCls: 'x-form-radio',
    
    /**
     * If this radio is part of a group, it will return the selected value
     * @return {String}
     */
    getGroupValue : function(){
        var c = this.getParent().child('input[name='+this.el.dom.name+']:checked', true);
        return c ? c.value : null;
    },
    
    // private
    getParent : function(){
        return this.el.up('form') || Ext.getBody();
    },

    // private
    toggleValue : function() {
        if(!this.checked){
            var els = this.getParent().select('input[name='+this.el.dom.name+']');
            els.each(function(el){
                if(el.dom.id == this.id){
                    this.setValue(true);
                }else{
                    Ext.getCmp(el.dom.id).setValue(false);
                }
            }, this);
        }
    },
    
    /**
     * Sets either the checked/unchecked status of this Radio, or, if a string value
     * is passed, checks a sibling Radio of the same name whose value is the value specified.
     * @param value {String/Boolean} Checked value, or the value of the sibling radio button to check.
     */
    setValue : function(v){
        if(typeof v=='boolean') {
            Ext.form.Radio.superclass.setValue.call(this, v);
        }else{
            var r = this.getParent().child('input[name='+this.el.dom.name+'][value='+v+']', true);
            if(r && !r.checked){
                Ext.getCmp(r.id).toggleValue();
            };
        }
    },
    
    /**
     * Overridden and disabled. The editor element does not support standard valid/invalid marking. @hide
     * @method
     */
    markInvalid : Ext.emptyFn,
    /**
     * Overridden and disabled. The editor element does not support standard valid/invalid marking. @hide
     * @method
     */
    clearInvalid : Ext.emptyFn
    
});
Ext.reg('radio', Ext.form.Radio);

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.RadioGroup
 * @extends Ext.form.CheckboxGroup
 * A grouping container for {@link Ext.form.Radio} controls.
 * @constructor
 * Creates a new CheckboxGroup
 * @param {Object} config Configuration options
 */
Ext.form.RadioGroup = Ext.extend(Ext.form.CheckboxGroup, {
    /**
     * @cfg {Boolean} allowBlank True to allow every item in the group to be blank (defaults to false). If allowBlank = 
     * false and no items are selected at validation time, {@link @blankText} will be used as the error text.
     */
    allowBlank : true,
    /**
     * @cfg {String} blankText Error text to display if the {@link #allowBlank} validation fails (defaults to "You must 
     * select one item in this group")
     */
    blankText : "You must select one item in this group",
    
    // private
    defaultType : 'radio',
    
    // private
    groupCls: 'x-form-radio-group'
});

Ext.reg('radiogroup', Ext.form.RadioGroup);

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.Label
 * @extends Ext.BoxComponent
 * Basic Label field.
 * @constructor
 * Creates a new Label
 * @param {Ext.Element/String/Object} config The configuration options.  If an element is passed, it is set as the internal
 * element and its id used as the component id.  If a string is passed, it is assumed to be the id of an existing element
 * and is used as the component id.  Otherwise, it is assumed to be a standard config object and is applied to the component.
 */
Ext.form.Label = Ext.extend(Ext.BoxComponent, {
    /**
     * @cfg {String} text The plain text to display within the label (defaults to ''). If you need to include HTML 
     * tags within the label's innerHTML, use the {@link #html} config instead.
     */
    /**
     * @cfg {String} forId The id of the input element to which this label will be bound via the standard 'htmlFor'
     * attribute. If not specified, the attribute will not be added to the label.
     */
    /**
     * @cfg {String} html An HTML fragment that will be used as the label's innerHTML (defaults to ''). 
     * Note that if {@link #text} is specified it will take precedence and this value will be ignored.
     */

    // private
    onRender : function(ct, position){
        if(!this.el){
            this.el = document.createElement('label');
            this.el.id = this.getId();
            this.el.innerHTML = this.text ? Ext.util.Format.htmlEncode(this.text) : (this.html || '');
            if(this.forId){
                this.el.setAttribute('htmlFor', this.forId);
            }
        }
        Ext.form.Label.superclass.onRender.call(this, ct, position);
    },
    
    /**
     * Updates the label's innerHTML with the specified string.
     * @param {String} text The new label text
     * @param {Boolean} encode (optional) False to skip HTML-encoding the text when rendering it
     * to the label (defaults to true which encodes the value). This might be useful if you want to include 
     * tags in the label's innerHTML rather than rendering them as string literals per the default logic.
     * @return {Label} this
     */
    setText: function(t, encode){
        this.text = t;
        if(this.rendered){
            this.el.dom.innerHTML = encode !== false ? Ext.util.Format.htmlEncode(t) : t;
        }
        return this;
    }
});

Ext.reg('label', Ext.form.Label);
/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.FormPanel
 * @extends Ext.Panel
 * Standard form container.
 * <p><b>Although they are not listed, this class also accepts all the config options required to configure its internal {@link Ext.form.BasicForm}</b></p>
 * <p>The BasicForm is configured using the {@link #initialConfig} of the FormPanel - that is the configuration object passed to the constructor.
 * This means that if you subclass FormPanel, and you wish to configure the BasicForm, you will need to insert any configuration options
 * for the BasicForm into the <tt><b>initialConfig</b></tt> property. Applying BasicForm configuration settings to <b><tt>this</tt></b> will
 * not affect the BasicForm's configuration.</p>
 * <br><br>
 * FormPanel uses a {@link Ext.layout.FormLayout} internally, and that is required for fields and labels to work correctly
 * within the FormPanel's layout.  To nest additional layout styles within a FormPanel, you should nest additional Panels
 * or other containers that can provide additional layout functionality. <b>You should not override FormPanel's layout.</b>
 * <br><br>
 * By default, Ext Forms are submitted through Ajax, using {@link Ext.form.Action}.
 * To enable normal browser submission of the Ext Form contained in this FormPanel,
 * override the Form's onSubmit, and submit methods:<br><br><pre><code>
    var myForm = new Ext.form.FormPanel({
        onSubmit: Ext.emptyFn,
        submit: function() {
            this.getForm().getEl().dom.submit();
        }
    });</code></pre><br>
 * @constructor
 * @param {Object} config Configuration options
 */
Ext.FormPanel = Ext.extend(Ext.Panel, {
	/**
	 * @cfg {String} formId (optional) The id of the FORM tag (defaults to an auto-generated id).
	 */
    /**
     * @cfg {Number} labelWidth The width of labels. This property cascades to child containers and can be overridden
     * on any child container (e.g., a fieldset can specify a different labelWidth for its fields).
     */
    /**
     * @cfg {String} itemCls A css class to apply to the x-form-item of fields. This property cascades to child containers.
     */
    /**
     * @cfg {String} buttonAlign Valid values are "left," "center" and "right" (defaults to "center")
     */
    buttonAlign:'center',

    /**
     * @cfg {Number} minButtonWidth Minimum width of all buttons in pixels (defaults to 75)
     */
    minButtonWidth:75,

    /**
     * @cfg {String} labelAlign Valid values are "left," "top" and "right" (defaults to "left").
     * This property cascades to child containers and can be overridden on any child container 
     * (e.g., a fieldset can specify a different labelAlign for its fields).
     */
    labelAlign:'left',

    /**
     * @cfg {Boolean} monitorValid If true the form monitors its valid state <b>client-side</b> and
     * fires a looping event with that state. This is required to bind buttons to the valid
     * state using the config value formBind:true on the button.
     */
    monitorValid : false,

    /**
     * @cfg {Number} monitorPoll The milliseconds to poll valid state, ignored if monitorValid is not true (defaults to 200)
     */
    monitorPoll : 200,

    /**
     * @cfg {String} layout @hide
     */
    layout: 'form',

    // private
    initComponent :function(){
        this.form = this.createForm();

        this.bodyCfg = {
            tag: 'form',
            cls: this.baseCls + '-body',
            method : this.method || 'POST',
            id : this.formId || Ext.id()
        };
        if(this.fileUpload) {
            this.bodyCfg.enctype = 'multipart/form-data';
        }

        Ext.FormPanel.superclass.initComponent.call(this);

        this.addEvents(
            /**
             * @event clientvalidation
             * If the monitorValid config option is true, this event fires repetitively to notify of valid state
             * @param {Ext.form.FormPanel} this
             * @param {Boolean} valid true if the form has passed client-side validation
             */
            'clientvalidation'
        );

        this.relayEvents(this.form, ['beforeaction', 'actionfailed', 'actioncomplete']);
    },

    // private
    createForm: function(){
        delete this.initialConfig.listeners;
        return new Ext.form.BasicForm(null, this.initialConfig);
    },

    // private
    initFields : function(){
        var f = this.form;
        var formPanel = this;
        var fn = function(c){
            if(c.isFormField){
                f.add(c);
            }else if(c.doLayout && c != formPanel){
                Ext.applyIf(c, {
                    labelAlign: c.ownerCt.labelAlign,
                    labelWidth: c.ownerCt.labelWidth,
                    itemCls: c.ownerCt.itemCls
                });
                if(c.items){
                    c.items.each(fn);
                }
            }
        }
        this.items.each(fn);
    },

    // private
    getLayoutTarget : function(){
        return this.form.el;
    },

    /**
     * Provides access to the {@link Ext.form.BasicForm Form} which this Panel contains.
     * @return {Ext.form.BasicForm} The {@link Ext.form.BasicForm Form} which this Panel contains.
     */
    getForm : function(){
        return this.form;
    },

    // private
    onRender : function(ct, position){
        this.initFields();

        Ext.FormPanel.superclass.onRender.call(this, ct, position);
        this.form.initEl(this.body);
    },
    
    // private
    beforeDestroy: function(){
        Ext.FormPanel.superclass.beforeDestroy.call(this);
        this.stopMonitoring();
        Ext.destroy(this.form);
    },

    // private
    initEvents : function(){
        Ext.FormPanel.superclass.initEvents.call(this);
		this.items.on('remove', this.onRemove, this);
		this.items.on('add', this.onAdd, this);
        if(this.monitorValid){ // initialize after render
            this.startMonitoring();
        }
    },
    
    // private
	onAdd : function(ct, c) {
		if (c.isFormField) {
			this.form.add(c);
		}
	},
	
	// private
	onRemove : function(c) {
		if (c.isFormField) {
			Ext.destroy(c.container.up('.x-form-item'));
			this.form.remove(c);
		}
	},

    /**
     * Starts monitoring of the valid state of this form. Usually this is done by passing the config
     * option "monitorValid"
     */
    startMonitoring : function(){
        if(!this.bound){
            this.bound = true;
            Ext.TaskMgr.start({
                run : this.bindHandler,
                interval : this.monitorPoll || 200,
                scope: this
            });
        }
    },

    /**
     * Stops monitoring of the valid state of this form
     */
    stopMonitoring : function(){
        this.bound = false;
    },

    /**
     * This is a proxy for the underlying BasicForm's {@link Ext.form.BasicForm#load} call.
     * @param {Object} options The options to pass to the action (see {@link Ext.form.BasicForm#doAction} for details)
     */
    load : function(){
        this.form.load.apply(this.form, arguments);  
    },

    // private
    onDisable : function(){
        Ext.FormPanel.superclass.onDisable.call(this);
        if(this.form){
            this.form.items.each(function(){
                 this.disable();
            });
        }
    },

    // private
    onEnable : function(){
        Ext.FormPanel.superclass.onEnable.call(this);
        if(this.form){
            this.form.items.each(function(){
                 this.enable();
            });
        }
    },

    // private
    bindHandler : function(){
        if(!this.bound){
            return false; // stops binding
        }
        var valid = true;
        this.form.items.each(function(f){
            if(!f.isValid(true)){
                valid = false;
                return false;
            }
        });
        if(this.buttons){
            for(var i = 0, len = this.buttons.length; i < len; i++){
                var btn = this.buttons[i];
                if(btn.formBind === true && btn.disabled === valid){
                    btn.setDisabled(!valid);
                }
            }
        }
        this.fireEvent('clientvalidation', this, valid);
    }
});
Ext.reg('form', Ext.FormPanel);

Ext.form.FormPanel = Ext.FormPanel;


/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.Action
 * <p>The subclasses of this class provide actions to perform upon {@link Ext.form.BasicForm Form}s.</p>
 * <p>Instances of this class are only created by a {@link Ext.form.BasicForm Form} when
 * the Form needs to perform an action such as submit or load. The Configuration options
 * listed for this class are set through the Form's action methods: {@link Ext.form.BasicForm#submit submit},
 * {@link Ext.form.BasicForm#load load} and {@link Ext.form.BasicForm#doAction doAction}</p>
 * <p>The instance of Action which performed the action is passed to the success
 * and failure callbacks of the Form's action methods ({@link Ext.form.BasicForm#submit submit},
 * {@link Ext.form.BasicForm#load load} and {@link Ext.form.BasicForm#doAction doAction}),
 * and to the {@link Ext.form.BasicForm#actioncomplete actioncomplete} and
 * {@link Ext.form.BasicForm#actionfailed actionfailed} event handlers.</p>
 */
Ext.form.Action = function(form, options){
    this.form = form;
    this.options = options || {};
};

/**
 * Failure type returned when client side validation of the Form fails
 * thus aborting a submit action.
 * @type {String}
 * @static
 */
Ext.form.Action.CLIENT_INVALID = 'client';
/**
 * Failure type returned when server side validation of the Form fails
 * indicating that field-specific error messages have been returned in the
 * response's <tt style="font-weight:bold">errors</tt> property.
 * @type {String}
 * @static
 */
Ext.form.Action.SERVER_INVALID = 'server';
/**
 * Failure type returned when a communication error happens when attempting
 * to send a request to the remote server.
 * @type {String}
 * @static
 */
Ext.form.Action.CONNECT_FAILURE = 'connect';
/**
 * Failure type returned when no field values are returned in the response's
 * <tt style="font-weight:bold">data</tt> property.
 * @type {String}
 * @static
 */
Ext.form.Action.LOAD_FAILURE = 'load';

Ext.form.Action.prototype = {
/**
 * @cfg {String} url The URL that the Action is to invoke.
 */
/**
 * @cfg {Boolean} reset When set to <tt><b>true</b></tt>, causes the Form to be
 * {@link Ext.form.BasicForm.reset reset} on Action success. If specified, this happens
 * <b>before</b> the {@link #success} callback is called and before the Form's
 * {@link Ext.form.BasicForm.actioncomplete actioncomplete} event fires.
 */
/**
 * @cfg {String} method The HTTP method to use to access the requested URL. Defaults to the
 * {@link Ext.form.BasicForm}'s method, or if that is not specified, the underlying DOM form's method.
 */
/**
 * @cfg {Mixed} params Extra parameter values to pass. These are added to the Form's
 * {@link Ext.form.BasicForm#baseParams} and passed to the specified URL along with the Form's
 * input fields.
 */
/**
 * @cfg {Number} timeout The number of milliseconds to wait for a server response before
 * failing with the {@link #failureType} as {@link #CONNECT_FAILURE}.
 */
/**
 * @cfg {Function} success The function to call when a valid success return packet is recieved.
 * The function is passed the following parameters:<ul class="mdetail-params">
 * <li><b>form</b> : Ext.form.BasicForm<div class="sub-desc">The form that requested the action</div></li>
 * <li><b>action</b> : Ext.form.Action<div class="sub-desc">The Action class. The {@link #result}
 * property of this object may be examined to perform custom postprocessing.</div></li>
 * </ul>
 */
/**
 * @cfg {Function} failure The function to call when a failure packet was recieved, or when an
 * error ocurred in the Ajax communication.
 * The function is passed the following parameters:<ul class="mdetail-params">
 * <li><b>form</b> : Ext.form.BasicForm<div class="sub-desc">The form that requested the action</div></li>
 * <li><b>action</b> : Ext.form.Action<div class="sub-desc">The Action class. If an Ajax
 * error ocurred, the failure type will be in {@link #failureType}. The {@link #result}
 * property of this object may be examined to perform custom postprocessing.</div></li>
 * </ul>
*/
/**
 * @cfg {Object} scope The scope in which to call the callback functions (The <tt>this</tt> reference
 * for the callback functions).
 */
/**
 * @cfg {String} waitMsg The message to be displayed by a call to {@link Ext.MessageBox#wait}
 * during the time the action is being processed.
 */
/**
 * @cfg {String} waitTitle The title to be displayed by a call to {@link Ext.MessageBox#wait}
 * during the time the action is being processed.
 */

/**
 * The type of action this Action instance performs.
 * Currently only "submit" and "load" are supported.
 * @type {String}
 */
    type : 'default',
/**
 * The type of failure detected. See {@link #Ext.form.Action.CLIENT_INVALID CLIENT_INVALID}, {@link #Ext.form.Action.SERVER_INVALID SERVER_INVALID},
 * {@link #Ext.form.Action.CONNECT_FAILURE CONNECT_FAILURE}, {@link #Ext.form.Action.LOAD_FAILURE LOAD_FAILURE}
 * @property failureType
 * @type {String}
 *//**
 * The XMLHttpRequest object used to perform the action.
 * @property response
 * @type {Object}
 *//**
 * The decoded response object containing a boolean <tt style="font-weight:bold">success</tt> property and
 * other, action-specific properties.
 * @property result
 * @type {Object}
 */

    // interface method
    run : function(options){

    },

    // interface method
    success : function(response){

    },

    // interface method
    handleResponse : function(response){

    },

    // default connection failure
    failure : function(response){
        this.response = response;
        this.failureType = Ext.form.Action.CONNECT_FAILURE;
        this.form.afterAction(this, false);
    },

    // private
    processResponse : function(response){
        this.response = response;
        if(!response.responseText){
            return true;
        }
        this.result = this.handleResponse(response);
        return this.result;
    },

    // utility functions used internally
    getUrl : function(appendParams){
        var url = this.options.url || this.form.url || this.form.el.dom.action;
        if(appendParams){
            var p = this.getParams();
            if(p){
                url += (url.indexOf('?') != -1 ? '&' : '?') + p;
            }
        }
        return url;
    },

    // private
    getMethod : function(){
        return (this.options.method || this.form.method || this.form.el.dom.method || 'POST').toUpperCase();
    },

    // private
    getParams : function(){
        var bp = this.form.baseParams;
        var p = this.options.params;
        if(p){
            if(typeof p == "object"){
                p = Ext.urlEncode(Ext.applyIf(p, bp));
            }else if(typeof p == 'string' && bp){
                p += '&' + Ext.urlEncode(bp);
            }
        }else if(bp){
            p = Ext.urlEncode(bp);
        }
        return p;
    },

    // private
    createCallback : function(opts){
		var opts = opts || {};
        return {
            success: this.success,
            failure: this.failure,
            scope: this,
            timeout: (opts.timeout*1000) || (this.form.timeout*1000),
            upload: this.form.fileUpload ? this.success : undefined
        };
    }
};

/**
 * @class Ext.form.Action.Submit
 * @extends Ext.form.Action
 * <p>A class which handles submission of data from {@link Ext.form.BasicForm Form}s
 * and processes the returned response.</p>
 * <p>Instances of this class are only created by a {@link Ext.form.BasicForm Form} when
 * {@link Ext.form.BasicForm#submit submit}ting.</p>
 * <p>A response packet must contain a boolean <tt style="font-weight:bold">success</tt> property, and, optionally
 * an <tt style="font-weight:bold">errors</tt> property. The <tt style="font-weight:bold">errors</tt> property contains error
 * messages for invalid fields.</p>
 * <p>By default, response packets are assumed to be JSON, so a typical response
 * packet may look like this:</p><pre><code>
{
    success: false,
    errors: {
        clientCode: "Client not found",
        portOfLoading: "This field must not be null"
    }
}</code></pre>
 * <p>Other data may be placed into the response for processing by the {@link Ext.form.BasicForm}'s callback
 * or event handler methods. The object decoded from this JSON is available in the {@link #result} property.</p>
 * <p>Alternatively, if an {@link #errorReader} is specified as an {@link Ext.data.XmlReader XmlReader}:</p><pre><code>
    errorReader: new Ext.data.XmlReader({
            record : 'field',
            success: '@success'
        }, [
            'id', 'msg'
        ]
    )
</code></pre>
 * <p>then the results may be sent back in XML format:</p><pre><code>
&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;message success="false"&gt;
&lt;errors&gt;
    &lt;field&gt;
        &lt;id&gt;clientCode&lt;/id&gt;
        &lt;msg&gt;&lt;![CDATA[Code not found. &lt;br /&gt;&lt;i&gt;This is a test validation message from the server &lt;/i&gt;]]&gt;&lt;/msg&gt;
    &lt;/field&gt;
    &lt;field&gt;
        &lt;id&gt;portOfLoading&lt;/id&gt;
        &lt;msg&gt;&lt;![CDATA[Port not found. &lt;br /&gt;&lt;i&gt;This is a test validation message from the server &lt;/i&gt;]]&gt;&lt;/msg&gt;
    &lt;/field&gt;
&lt;/errors&gt;
&lt;/message&gt;
</code></pre>
 * <p>Other elements may be placed into the response XML for processing by the {@link Ext.form.BasicForm}'s callback
 * or event handler methods. The XML document is available in the {@link #errorReader}'s {@link Ext.data.XmlReader#xmlData xmlData} property.</p>
 */
Ext.form.Action.Submit = function(form, options){
    Ext.form.Action.Submit.superclass.constructor.call(this, form, options);
};

Ext.extend(Ext.form.Action.Submit, Ext.form.Action, {
    /**
    * @cfg {Ext.data.DataReader} errorReader <b>Optional. JSON is interpreted with no need for an errorReader.</b>
    * <p>A Reader which reads a single record from the returned data. The DataReader's <b>success</b> property specifies
    * how submission success is determined. The Record's data provides the error messages to apply to any invalid form Fields.</p>.
    */
    /**
    * @cfg {boolean} clientValidation Determines whether a Form's fields are validated
    * in a final call to {@link Ext.form.BasicForm#isValid isValid} prior to submission.
    * Pass <tt>false</tt> in the Form's submit options to prevent this. If not defined, pre-submission field validation
    * is performed.
    */
    type : 'submit',

    // private
    run : function(){
        var o = this.options;
        var method = this.getMethod();
        var isGet = method == 'GET';
        if(o.clientValidation === false || this.form.isValid()){
            Ext.Ajax.request(Ext.apply(this.createCallback(o), {
                form:this.form.el.dom,
                url:this.getUrl(isGet),
                method: method,
                headers: o.headers,
                params:!isGet ? this.getParams() : null,
                isUpload: this.form.fileUpload
            }));
        }else if (o.clientValidation !== false){ // client validation failed
            this.failureType = Ext.form.Action.CLIENT_INVALID;
            this.form.afterAction(this, false);
        }
    },

    // private
    success : function(response){
        var result = this.processResponse(response);
        if(result === true || result.success){
            this.form.afterAction(this, true);
            return;
        }
        if(result.errors){
            this.form.markInvalid(result.errors);
            this.failureType = Ext.form.Action.SERVER_INVALID;
        }
        this.form.afterAction(this, false);
    },

    // private
    handleResponse : function(response){
        if(this.form.errorReader){
            var rs = this.form.errorReader.read(response);
            var errors = [];
            if(rs.records){
                for(var i = 0, len = rs.records.length; i < len; i++) {
                    var r = rs.records[i];
                    errors[i] = r.data;
                }
            }
            if(errors.length < 1){
                errors = null;
            }
            return {
                success : rs.success,
                errors : errors
            };
        }
        return Ext.decode(response.responseText);
    }
});


/**
 * @class Ext.form.Action.Load
 * @extends Ext.form.Action
 * <p>A class which handles loading of data from a server into the Fields of an {@link Ext.form.BasicForm}.</p>
 * <p>Instances of this class are only created by a {@link Ext.form.BasicForm Form} when
 * {@link Ext.form.BasicForm#load load}ing.</p>
 * <p>A response packet <b>must</b> contain a boolean <tt style="font-weight:bold">success</tt> property, and
 * a <tt style="font-weight:bold">data</tt> property. The <tt style="font-weight:bold">data</tt> property
 * contains the values of Fields to load. The individual value object for each Field
 * is passed to the Field's {@link Ext.form.Field#setValue setValue} method.</p>
 * <p>By default, response packets are assumed to be JSON, so a typical response
 * packet may look like this:</p><pre><code>
{
    success: true,
    data: {
        clientName: "Fred. Olsen Lines",
        portOfLoading: "FXT",
        portOfDischarge: "OSL"
    }
}</code></pre>
 * <p>Other data may be placed into the response for processing the {@link Ext.form.BasicForm Form}'s callback
 * or event handler methods. The object decoded from this JSON is available in the {@link #result} property.</p>
 */
Ext.form.Action.Load = function(form, options){
    Ext.form.Action.Load.superclass.constructor.call(this, form, options);
    this.reader = this.form.reader;
};

Ext.extend(Ext.form.Action.Load, Ext.form.Action, {
    // private
    type : 'load',

    // private
    run : function(){
        Ext.Ajax.request(Ext.apply(
                this.createCallback(this.options), {
                    method:this.getMethod(),
                    url:this.getUrl(false),
                    headers: this.options.headers,
                    params:this.getParams()
        }));
    },

    // private
    success : function(response){
        var result = this.processResponse(response);
        if(result === true || !result.success || !result.data){
            this.failureType = Ext.form.Action.LOAD_FAILURE;
            this.form.afterAction(this, false);
            return;
        }
        this.form.clearInvalid();
        this.form.setValues(result.data);
        this.form.afterAction(this, true);
    },

    // private
    handleResponse : function(response){
        if(this.form.reader){
            var rs = this.form.reader.read(response);
            var data = rs.records && rs.records[0] ? rs.records[0].data : null;
            return {
                success : rs.success,
                data : data
            };
        }
        return Ext.decode(response.responseText);
    }
});

Ext.form.Action.ACTION_TYPES = {
    'load' : Ext.form.Action.Load,
    'submit' : Ext.form.Action.Submit
};

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.TriggerField
 * @extends Ext.form.TextField
 * Provides a convenient wrapper for TextFields that adds a clickable trigger button (looks like a combobox by default).
 * The trigger has no default action, so you must assign a function to implement the trigger click handler by
 * overriding {@link #onTriggerClick}. You can create a TriggerField directly, as it renders exactly like a combobox
 * for which you can provide a custom implementation.  For example:
 * <pre><code>
var trigger = new Ext.form.TriggerField();
trigger.onTriggerClick = myTriggerFn;
trigger.applyToMarkup('my-field');
</code></pre>
 *
 * However, in general you will most likely want to use TriggerField as the base class for a reusable component.
 * {@link Ext.form.DateField} and {@link Ext.form.ComboBox} are perfect examples of this.
 * @cfg {String} triggerClass An additional CSS class used to style the trigger button.  The trigger will always get the
 * class 'x-form-trigger' by default and triggerClass will be <b>appended</b> if specified.
 * @constructor
 * Create a new TriggerField.
 * @param {Object} config Configuration options (valid {@Ext.form.TextField} config options will also be applied
 * to the base TextField)
 */
Ext.form.TriggerField = Ext.extend(Ext.form.TextField,  {
    /**
     * @cfg {String} triggerClass A CSS class to apply to the trigger
     */
    /**
     * @cfg {String/Object} autoCreate A DomHelper element spec, or true for a default element spec (defaults to
     * {tag: "input", type: "text", size: "16", autocomplete: "off"})
     */
    defaultAutoCreate : {tag: "input", type: "text", size: "16", autocomplete: "off"},
    /**
     * @cfg {Boolean} hideTrigger True to hide the trigger element and display only the base text field (defaults to false)
     */
    hideTrigger:false,

    /**
     * @hide 
     * @method autoSize
     */
    autoSize: Ext.emptyFn,
    // private
    monitorTab : true,
    // private
    deferHeight : true,
    // private
    mimicing : false,

    // private
    onResize : function(w, h){
        Ext.form.TriggerField.superclass.onResize.call(this, w, h);
        if(typeof w == 'number'){
            this.el.setWidth(this.adjustWidth('input', w - this.trigger.getWidth()));
        }
        this.wrap.setWidth(this.el.getWidth()+this.trigger.getWidth());
    },

    // private
    adjustSize : Ext.BoxComponent.prototype.adjustSize,

    // private
    getResizeEl : function(){
        return this.wrap;
    },

    // private
    getPositionEl : function(){
        return this.wrap;
    },

    // private
    alignErrorIcon : function(){
        if(this.wrap){
            this.errorIcon.alignTo(this.wrap, 'tl-tr', [2, 0]);
        }
    },

    // private
    onRender : function(ct, position){
        Ext.form.TriggerField.superclass.onRender.call(this, ct, position);
        this.wrap = this.el.wrap({cls: "x-form-field-wrap"});
        this.trigger = this.wrap.createChild(this.triggerConfig ||
                {tag: "img", src: Ext.BLANK_IMAGE_URL, cls: "x-form-trigger " + this.triggerClass});
        if(this.hideTrigger){
            this.trigger.setDisplayed(false);
        }
        this.initTrigger();
        if(!this.width){
            this.wrap.setWidth(this.el.getWidth()+this.trigger.getWidth());
        }
    },

    afterRender : function(){
        Ext.form.TriggerField.superclass.afterRender.call(this);
        var y;
        if(Ext.isIE && this.el.getY() != (y = this.trigger.getY())){
            this.el.position();
            this.el.setY(y);
        }
    },

    // private
    initTrigger : function(){
        this.trigger.on("click", this.onTriggerClick, this, {preventDefault:true});
        this.trigger.addClassOnOver('x-form-trigger-over');
        this.trigger.addClassOnClick('x-form-trigger-click');
    },

    // private
    onDestroy : function(){
        if(this.trigger){
            this.trigger.removeAllListeners();
            this.trigger.remove();
        }
        if(this.wrap){
            this.wrap.remove();
        }
        Ext.form.TriggerField.superclass.onDestroy.call(this);
    },

    // private
    onFocus : function(){
        Ext.form.TriggerField.superclass.onFocus.call(this);
        if(!this.mimicing){
            this.wrap.addClass('x-trigger-wrap-focus');
            this.mimicing = true;
            Ext.get(Ext.isIE ? document.body : document).on("mousedown", this.mimicBlur, this, {delay: 10});
            if(this.monitorTab){
                this.el.on("keydown", this.checkTab, this);
            }
        }
    },

    // private
    checkTab : function(e){
        if(e.getKey() == e.TAB){
            this.triggerBlur();
        }
    },

    // private
    onBlur : function(){
        // do nothing
    },

    // private
    mimicBlur : function(e){
        if(!this.wrap.contains(e.target) && this.validateBlur(e)){
            this.triggerBlur();
        }
    },

    // private
    triggerBlur : function(){
        this.mimicing = false;
        Ext.get(Ext.isIE ? document.body : document).un("mousedown", this.mimicBlur, this);
        if(this.monitorTab){
            this.el.un("keydown", this.checkTab, this);
        }
        this.beforeBlur();
        this.wrap.removeClass('x-trigger-wrap-focus');
        Ext.form.TriggerField.superclass.onBlur.call(this);
    },

    beforeBlur : Ext.emptyFn, 

    // private
    // This should be overriden by any subclass that needs to check whether or not the field can be blurred.
    validateBlur : function(e){
        return true;
    },

    // private
    onDisable : function(){
        Ext.form.TriggerField.superclass.onDisable.call(this);
        if(this.wrap){
            this.wrap.addClass(this.disabledClass);
            this.el.removeClass(this.disabledClass);
        }
    },

    // private
    onEnable : function(){
        Ext.form.TriggerField.superclass.onEnable.call(this);
        if(this.wrap){
            this.wrap.removeClass(this.disabledClass);
        }
    },

    // private
    onShow : function(){
        if(this.wrap){
            this.wrap.dom.style.display = '';
            this.wrap.dom.style.visibility = 'visible';
        }
    },

    // private
    onHide : function(){
        this.wrap.dom.style.display = 'none';
    },

    /**
     * The function that should handle the trigger's click event.  This method does nothing by default until overridden
     * by an implementing function.
     * @method
     * @param {EventObject} e
     */
    onTriggerClick : Ext.emptyFn

    /**
     * @cfg {Boolean} grow @hide
     */
    /**
     * @cfg {Number} growMin @hide
     */
    /**
     * @cfg {Number} growMax @hide
     */
});

// TwinTriggerField is not a public class to be used directly.  It is meant as an abstract base class
// to be extended by an implementing class.  For an example of implementing this class, see the custom
// SearchField implementation here: http://extjs.com/deploy/ext/examples/form/custom.html
Ext.form.TwinTriggerField = Ext.extend(Ext.form.TriggerField, {
    initComponent : function(){
        Ext.form.TwinTriggerField.superclass.initComponent.call(this);

        this.triggerConfig = {
            tag:'span', cls:'x-form-twin-triggers', cn:[
            {tag: "img", src: Ext.BLANK_IMAGE_URL, cls: "x-form-trigger " + this.trigger1Class},
            {tag: "img", src: Ext.BLANK_IMAGE_URL, cls: "x-form-trigger " + this.trigger2Class}
        ]};
    },

    getTrigger : function(index){
        return this.triggers[index];
    },

    initTrigger : function(){
        var ts = this.trigger.select('.x-form-trigger', true);
        this.wrap.setStyle('overflow', 'hidden');
        var triggerField = this;
        ts.each(function(t, all, index){
            t.hide = function(){
                var w = triggerField.wrap.getWidth();
                this.dom.style.display = 'none';
                triggerField.el.setWidth(w-triggerField.trigger.getWidth());
            };
            t.show = function(){
                var w = triggerField.wrap.getWidth();
                this.dom.style.display = '';
                triggerField.el.setWidth(w-triggerField.trigger.getWidth());
            };
            var triggerIndex = 'Trigger'+(index+1);

            if(this['hide'+triggerIndex]){
                t.dom.style.display = 'none';
            }
            t.on("click", this['on'+triggerIndex+'Click'], this, {preventDefault:true});
            t.addClassOnOver('x-form-trigger-over');
            t.addClassOnClick('x-form-trigger-click');
        }, this);
        this.triggers = ts.elements;
    },

    onTrigger1Click : Ext.emptyFn,
    onTrigger2Click : Ext.emptyFn
});
Ext.reg('trigger', Ext.form.TriggerField);

Ext.ux.SearchField = Ext.extend(Ext.form.TwinTriggerField, {
    initComponent : function(){
        if(!this.store.baseParams){
			this.store.baseParams = {};
		}
		Ext.ux.SearchField.superclass.initComponent.call(this);
		this.on('specialkey', function(f, e){
            if(e.getKey() == e.ENTER){
                this.onTrigger2Click();
            }
        }, this);
    },

    validationEvent:false,
    validateOnBlur:false,
    trigger1Class:'x-form-clear-trigger',
    trigger2Class:'x-form-search-trigger',
    hideTrigger1:true,
    width:180,
    hasSearch : false,
    paramName : 'query',

    onTrigger1Click : function(){
        if(this.hasSearch){
            this.store.baseParams[this.paramName] = '';
//			this.store.removeAll();
		this.el.dom.value = '';
        	this.store.reload();

            this.triggers[0].hide();
            this.hasSearch = false;
			this.focus();
        }
    },

    onTrigger2Click : function(){
        var v = this.getRawValue();
        if(v.length < 1){
            this.onTrigger1Click();
            return;
        }
		if(v.length < 2){
			Ext.Msg.alert('Invalid Search', 'You must enter a minimum of 2 characters to search the items');
			return;
		}
		this.store.baseParams[this.paramName] = v;
        var o = {start: 0};
        this.store.reload({params:o});
        this.hasSearch = true;
        this.triggers[0].show();
		this.focus();
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
 * @class Ext.form.ComboBox
 * @extends Ext.form.TriggerField
 * A combobox control with support for autocomplete, remote-loading, paging and many other features.
 * @constructor
 * Create a new ComboBox.
 * @param {Object} config Configuration options
 */
Ext.form.ComboBox = Ext.extend(Ext.form.TriggerField, {
    /**
     * @cfg {Mixed} transform The id, DOM node or element of an existing HTML SELECT to convert to a ComboBox.
     * Note that if you specify this and the combo is going to be in a {@link Ext.form.BasicForm} or
     * {@link Ext.form.FormPanel}, you must also set {@link #lazyRender} = true.
     */
    /**
     * @cfg {Boolean} lazyRender True to prevent the ComboBox from rendering until requested (should always be used when
     * rendering into an Ext.Editor, defaults to false).
     */
    /**
     * @cfg {Boolean/Object} autoCreate A DomHelper element spec, or true for a default element spec (defaults to:
     * {tag: "input", type: "text", size: "24", autocomplete: "off"})
     */
    /**
     * @cfg {Ext.data.Store/Array} store The data source to which this combo is bound (defaults to undefined).  This can be
     * any {@link Ext.data.Store} subclass, a 1-dimensional array (e.g., ['Foo','Bar']) or a 2-dimensional array (e.g.,
     * [['f','Foo'],['b','Bar']]).  Arrays will be converted to a {@link Ext.data.SimpleStore} internally.
     * 1-dimensional arrays will automatically be expanded (each array item will be the combo value and text) and
     * for multi-dimensional arrays, the value in index 0 of each item will be assumed to be the combo value, while
     * the value at index 1 is assumed to be the combo text.
     */
    /**
     * @cfg {String} title If supplied, a header element is created containing this text and added into the top of
     * the dropdown list (defaults to undefined, with no header element)
     */

    // private
    defaultAutoCreate : {tag: "input", type: "text", size: "24", autocomplete: "off"},
    /**
     * @cfg {Number} listWidth The width in pixels of the dropdown list (defaults to the width of the ComboBox field)
     */
    /**
     * @cfg {String} displayField The underlying data field name to bind to this ComboBox (defaults to undefined if
     * mode = 'remote' or 'text' if transforming a select)
     */
    /**
     * @cfg {String} valueField The underlying data value name to bind to this ComboBox (defaults to undefined if
     * mode = 'remote' or 'value' if transforming a select) Note: use of a valueField requires the user to make a selection
     * in order for a value to be mapped.
     */
    /**
     * @cfg {String} hiddenName If specified, a hidden form field with this name is dynamically generated to store the
     * field's data value (defaults to the underlying DOM element's name). Required for the combo's value to automatically
     * post during a form submission.  Note that the hidden field's id will also default to this name if {@link #hiddenId}
     * is not specified.  The combo's id and the hidden field's ids should be different, since no two DOM nodes should
     * share the same id, so if the combo and hidden names are the same, you should specify a unique hiddenId.
     */
    /**
     * @cfg {String} hiddenId If {@link #hiddenName} is specified, hiddenId can also be provided to give the hidden field
     * a unique id (defaults to the hiddenName).  The hiddenId and combo {@link #id} should be different, since no two DOM
     * nodes should share the same id.
     */
    /**
     * @cfg {String} listClass CSS class to apply to the dropdown list element (defaults to '')
     */
    listClass: '',
    /**
     * @cfg {String} selectedClass CSS class to apply to the selected item in the dropdown list (defaults to 'x-combo-selected')
     */
    selectedClass: 'x-combo-selected',
    /**
     * @cfg {String} triggerClass An additional CSS class used to style the trigger button.  The trigger will always get the
     * class 'x-form-trigger' and triggerClass will be <b>appended</b> if specified (defaults to 'x-form-arrow-trigger'
     * which displays a downward arrow icon).
     */
    triggerClass : 'x-form-arrow-trigger',
    /**
     * @cfg {Boolean/String} shadow True or "sides" for the default effect, "frame" for 4-way shadow, and "drop" for bottom-right
     */
    shadow:'sides',
    /**
     * @cfg {String} listAlign A valid anchor position value. See {@link Ext.Element#alignTo} for details on supported
     * anchor positions (defaults to 'tl-bl')
     */
    listAlign: 'tl-bl?',
    /**
     * @cfg {Number} maxHeight The maximum height in pixels of the dropdown list before scrollbars are shown (defaults to 300)
     */
    maxHeight: 300,
    /**
     * @cfg {Number} minHeight The minimum height in pixels of the dropdown list when the list is constrained by its
     * distance to the viewport edges (defaults to 90)
     */
    minHeight: 90,
    /**
     * @cfg {String} triggerAction The action to execute when the trigger field is activated.  Use 'all' to run the
     * query specified by the allQuery config option (defaults to 'query')
     */
    triggerAction: 'query',
    /**
     * @cfg {Number} minChars The minimum number of characters the user must type before autocomplete and typeahead activate
     * (defaults to 4 if remote or 0 if local, does not apply if editable = false)
     */
    minChars : 4,
    /**
     * @cfg {Boolean} typeAhead True to populate and autoselect the remainder of the text being typed after a configurable
     * delay ({@link #typeAheadDelay}) if it matches a known value (defaults to false)
     */
    typeAhead: false,
    /**
     * @cfg {Number} queryDelay The length of time in milliseconds to delay between the start of typing and sending the
     * query to filter the dropdown list (defaults to 500 if mode = 'remote' or 10 if mode = 'local')
     */
    queryDelay: 500,
    /**
     * @cfg {Number} pageSize If greater than 0, a paging toolbar is displayed in the footer of the dropdown list and the
     * filter queries will execute with page start and limit parameters.  Only applies when mode = 'remote' (defaults to 0)
     */
    pageSize: 0,
    /**
     * @cfg {Boolean} selectOnFocus True to select any existing text in the field immediately on focus.  Only applies
     * when editable = true (defaults to false)
     */
    selectOnFocus:false,
    /**
     * @cfg {String} queryParam Name of the query as it will be passed on the querystring (defaults to 'query')
     */
    queryParam: 'query',
    /**
     * @cfg {String} loadingText The text to display in the dropdown list while data is loading.  Only applies
     * when mode = 'remote' (defaults to 'Loading...')
     */
    loadingText: 'Loading...',
    /**
     * @cfg {Boolean} resizable True to add a resize handle to the bottom of the dropdown list (defaults to false)
     */
    resizable: false,
    /**
     * @cfg {Number} handleHeight The height in pixels of the dropdown list resize handle if resizable = true (defaults to 8)
     */
    handleHeight : 8,
    /**
     * @cfg {Boolean} editable False to prevent the user from typing text directly into the field, just like a
     * traditional select (defaults to true)
     */
    editable: true,
    /**
     * @cfg {String} allQuery The text query to send to the server to return all records for the list with no filtering (defaults to '')
     */
    allQuery: '',
    /**
     * @cfg {String} mode Set to 'local' if the ComboBox loads local data (defaults to 'remote' which loads from the server)
     */
    mode: 'remote',
    /**
     * @cfg {Number} minListWidth The minimum width of the dropdown list in pixels (defaults to 70, will be ignored if
     * listWidth has a higher value)
     */
    minListWidth : 70,
    /**
     * @cfg {Boolean} forceSelection True to restrict the selected value to one of the values in the list, false to
     * allow the user to set arbitrary text into the field (defaults to false)
     */
    forceSelection:false,
    /**
     * @cfg {Number} typeAheadDelay The length of time in milliseconds to wait until the typeahead text is displayed
     * if typeAhead = true (defaults to 250)
     */
    typeAheadDelay : 250,
    /**
     * @cfg {String} valueNotFoundText When using a name/value combo, if the value passed to setValue is not found in
     * the store, valueNotFoundText will be displayed as the field text if defined (defaults to undefined). If this
     * defaut text is used, it means there is no value set and no validation will occur on this field.
     */

    /**
     * @cfg {Boolean} lazyInit True to not initialize the list for this combo until the field is focused (defaults to true)
     */
    lazyInit : true,

    // private
    initComponent : function(){
        Ext.form.ComboBox.superclass.initComponent.call(this);
        this.addEvents(
            /**
             * @event expand
             * Fires when the dropdown list is expanded
             * @param {Ext.form.ComboBox} combo This combo box
             */
            'expand',
            /**
             * @event collapse
             * Fires when the dropdown list is collapsed
             * @param {Ext.form.ComboBox} combo This combo box
             */
            'collapse',
            /**
             * @event beforeselect
             * Fires before a list item is selected. Return false to cancel the selection.
             * @param {Ext.form.ComboBox} combo This combo box
             * @param {Ext.data.Record} record The data record returned from the underlying store
             * @param {Number} index The index of the selected item in the dropdown list
             */
            'beforeselect',
            /**
             * @event select
             * Fires when a list item is selected
             * @param {Ext.form.ComboBox} combo This combo box
             * @param {Ext.data.Record} record The data record returned from the underlying store
             * @param {Number} index The index of the selected item in the dropdown list
             */
            'select',
            /**
             * @event beforequery
             * Fires before all queries are processed. Return false to cancel the query or set the queryEvent's
             * cancel property to true.
             * @param {Object} queryEvent An object that has these properties:<ul>
             * <li><code>combo</code> : Ext.form.ComboBox <div class="sub-desc">This combo box</div></li>
             * <li><code>query</code> : String <div class="sub-desc">The query</div></li>
             * <li><code>forceAll</code> : Boolean <div class="sub-desc">True to force "all" query</div></li>
             * <li><code>cancel</code> : Boolean <div class="sub-desc">Set to true to cancel the query</div></li>
             * </ul>
             */
            'beforequery'
        );
        if(this.transform){
            this.allowDomMove = false;
            var s = Ext.getDom(this.transform);
            if(!this.hiddenName){
                this.hiddenName = s.name;
            }
            if(!this.store){
                this.mode = 'local';
                var d = [], opts = s.options;
                for(var i = 0, len = opts.length;i < len; i++){
                    var o = opts[i];
                    var value = (Ext.isIE ? o.getAttributeNode('value').specified : o.hasAttribute('value')) ? o.value : o.text;
                    if(o.selected) {
                        this.value = value;
                    }
                    d.push([value, o.text]);
                }
                this.store = new Ext.data.SimpleStore({
                    'id': 0,
                    fields: ['value', 'text'],
                    data : d
                });
                this.valueField = 'value';
                this.displayField = 'text';
            }
            s.name = Ext.id(); // wipe out the name in case somewhere else they have a reference
            if(!this.lazyRender){
                this.target = true;
                this.el = Ext.DomHelper.insertBefore(s, this.autoCreate || this.defaultAutoCreate);
                Ext.removeNode(s); // remove it
                this.render(this.el.parentNode);
            }else{
                Ext.removeNode(s); // remove it
            }
        }
        //auto-configure store from local array data
        else if(Ext.isArray(this.store)){
			if (Ext.isArray(this.store[0])){
				this.store = new Ext.data.SimpleStore({
				    fields: ['value','text'],
				    data: this.store
				});
		        this.valueField = 'value';
			}else{
				this.store = new Ext.data.SimpleStore({
				    fields: ['text'],
				    data: this.store,
				    expandData: true
				});
		        this.valueField = 'text';
			}
			this.displayField = 'text';
			this.mode = 'local';
		}

        this.selectedIndex = -1;
        if(this.mode == 'local'){
            if(this.initialConfig.queryDelay === undefined){
                this.queryDelay = 10;
            }
            if(this.initialConfig.minChars === undefined){
                this.minChars = 0;
            }
        }
    },

    // private
    onRender : function(ct, position){
        Ext.form.ComboBox.superclass.onRender.call(this, ct, position);
        if(this.hiddenName){
            this.hiddenField = this.el.insertSibling({tag:'input', type:'hidden', name: this.hiddenName,
                    id: (this.hiddenId||this.hiddenName)}, 'before', true);

            // prevent input submission
            this.el.dom.removeAttribute('name');
        }
        if(Ext.isGecko){
            this.el.dom.setAttribute('autocomplete', 'off');
        }

        if(!this.lazyInit){
            this.initList();
        }else{
            this.on('focus', this.initList, this, {single: true});
        }

        if(!this.editable){
            this.editable = true;
            this.setEditable(false);
        }
    },

    // private
    initValue : function(){
        Ext.form.ComboBox.superclass.initValue.call(this);
        if(this.hiddenField){
		    this.hiddenField.value =
		        this.hiddenValue !== undefined ? this.hiddenValue :
		        this.value !== undefined ? this.value : '';
        }
    },

    // private
    initList : function(){
        if(!this.list){
            var cls = 'x-combo-list';

            this.list = new Ext.Layer({
                shadow: this.shadow, cls: [cls, this.listClass].join(' '), constrain:false
            });

            var lw = this.listWidth || Math.max(this.wrap.getWidth(), this.minListWidth);
            this.list.setWidth(lw);
            this.list.swallowEvent('mousewheel');
            this.assetHeight = 0;

            if(this.title){
                this.header = this.list.createChild({cls:cls+'-hd', html: this.title});
                this.assetHeight += this.header.getHeight();
            }

            this.innerList = this.list.createChild({cls:cls+'-inner'});
            this.innerList.on('mouseover', this.onViewOver, this);
            this.innerList.on('mousemove', this.onViewMove, this);
            this.innerList.setWidth(lw - this.list.getFrameWidth('lr'));

            if(this.pageSize){
                this.footer = this.list.createChild({cls:cls+'-ft'});
                this.pageTb = new Ext.PagingToolbar({
                    store:this.store,
                    pageSize: this.pageSize,
                    renderTo:this.footer
                });
                this.assetHeight += this.footer.getHeight();
            }

            if(!this.tpl){
                /**
                * @cfg {String/Ext.XTemplate} tpl The template string, or {@link Ext.XTemplate}
                * instance to use to display each item in the dropdown list. Use
                * this to create custom UI layouts for items in the list.
                * <p>
                * If you wish to preserve the default visual look of list items, add the CSS
                * class name <pre>x-combo-list-item</pre> to the template's container element.
                * <p>
                * <b>The template must contain one or more substitution parameters using field
                * names from the Combo's</b> {@link #store Store}. An example of a custom template
                * would be adding an <pre>ext:qtip</pre> attribute which might display other fields
                * from the Store.
                * <p>
                * The dropdown list is displayed in a DataView. See {@link Ext.DataView} for details.
                */
                this.tpl = '<tpl for="."><div class="'+cls+'-item">{' + this.displayField + '}</div></tpl>';
                /**
                 * @cfg {String} itemSelector
                 * <b>This setting is required if a custom XTemplate has been specified in {@link #tpl}
                 * which assigns a class other than <pre>'x-combo-list-item'</pre> to dropdown list items</b>.
                 * A simple CSS selector (e.g. div.some-class or span:first-child) that will be
                 * used to determine what nodes the DataView which handles the dropdown display will
                 * be working with.
                 */
            }

            /**
            * The {@link Ext.DataView DataView} used to display the ComboBox's options.
            * @type Ext.DataView
            */
            this.view = new Ext.DataView({
                applyTo: this.innerList,
                tpl: this.tpl,
                singleSelect: true,
                selectedClass: this.selectedClass,
                itemSelector: this.itemSelector || '.' + cls + '-item'
            });

            this.view.on('click', this.onViewClick, this);

            this.bindStore(this.store, true);

            if(this.resizable){
                this.resizer = new Ext.Resizable(this.list,  {
                   pinned:true, handles:'se'
                });
                this.resizer.on('resize', function(r, w, h){
                    this.maxHeight = h-this.handleHeight-this.list.getFrameWidth('tb')-this.assetHeight;
                    this.listWidth = w;
                    this.innerList.setWidth(w - this.list.getFrameWidth('lr'));
                    this.restrictHeight();
                }, this);
                this[this.pageSize?'footer':'innerList'].setStyle('margin-bottom', this.handleHeight+'px');
            }
        }
    },

    // private
    bindStore : function(store, initial){
        if(this.store && !initial){
            this.store.un('beforeload', this.onBeforeLoad, this);
            this.store.un('load', this.onLoad, this);
            this.store.un('loadexception', this.collapse, this);
            if(!store){
                this.store = null;
                if(this.view){
                    this.view.setStore(null);
                }
            }
        }
        if(store){
            this.store = Ext.StoreMgr.lookup(store);

            this.store.on('beforeload', this.onBeforeLoad, this);
            this.store.on('load', this.onLoad, this);
            this.store.on('loadexception', this.collapse, this);

            if(this.view){
                this.view.setStore(store);
            }
        }
    },

    // private
    initEvents : function(){
        Ext.form.ComboBox.superclass.initEvents.call(this);

        this.keyNav = new Ext.KeyNav(this.el, {
            "up" : function(e){
                this.inKeyMode = true;
                this.selectPrev();
            },

            "down" : function(e){
                if(!this.isExpanded()){
                    this.onTriggerClick();
                }else{
                    this.inKeyMode = true;
                    this.selectNext();
                }
            },

            "enter" : function(e){
                this.onViewClick();
                this.delayedCheck = true;
                this.unsetDelayCheck.defer(10, this);
            },

            "esc" : function(e){
                this.collapse();
            },

            "tab" : function(e){
                this.onViewClick(false);
                return true;
            },

            scope : this,

            doRelay : function(foo, bar, hname){
                if(hname == 'down' || this.scope.isExpanded()){
                   return Ext.KeyNav.prototype.doRelay.apply(this, arguments);
                }
                return true;
            },

            forceKeyDown : true
        });
        this.queryDelay = Math.max(this.queryDelay || 10,
                this.mode == 'local' ? 10 : 250);
        this.dqTask = new Ext.util.DelayedTask(this.initQuery, this);
        if(this.typeAhead){
            this.taTask = new Ext.util.DelayedTask(this.onTypeAhead, this);
        }
        if(this.editable !== false){
            this.el.on("keyup", this.onKeyUp, this);
        }
        if(this.forceSelection){
            this.on('blur', this.doForce, this);
        }
    },

    // private
    onDestroy : function(){
        if(this.view){
            this.view.el.removeAllListeners();
            this.view.el.remove();
            this.view.purgeListeners();
        }
        if(this.list){
            this.list.destroy();
        }
        this.bindStore(null);
        Ext.form.ComboBox.superclass.onDestroy.call(this);
    },

    // private
    unsetDelayCheck : function(){
        delete this.delayedCheck;
    },

    // private
    fireKey : function(e){
        if(e.isNavKeyPress() && !this.isExpanded() && !this.delayedCheck){
            this.fireEvent("specialkey", this, e);
        }
    },

    // private
    onResize: function(w, h){
        Ext.form.ComboBox.superclass.onResize.apply(this, arguments);
        if(this.list && this.listWidth === undefined){
            var lw = Math.max(w, this.minListWidth);
            this.list.setWidth(lw);
            this.innerList.setWidth(lw - this.list.getFrameWidth('lr'));
        }
    },

    // private
    onEnable: function(){
        Ext.form.ComboBox.superclass.onEnable.apply(this, arguments);
        if(this.hiddenField){
            this.hiddenField.disabled = false;
        }
    },

    // private
    onDisable: function(){
        Ext.form.ComboBox.superclass.onDisable.apply(this, arguments);
        if(this.hiddenField){
            this.hiddenField.disabled = true;
        }
    },

    /**
     * Allow or prevent the user from directly editing the field text.  If false is passed,
     * the user will only be able to select from the items defined in the dropdown list.  This method
     * is the runtime equivalent of setting the 'editable' config option at config time.
     * @param {Boolean} value True to allow the user to directly edit the field text
     */
    setEditable : function(value){
        if(value == this.editable){
            return;
        }
        this.editable = value;
        if(!value){
            this.el.dom.setAttribute('readOnly', true);
            this.el.on('mousedown', this.onTriggerClick,  this);
            this.el.addClass('x-combo-noedit');
        }else{
            this.el.dom.setAttribute('readOnly', false);
            this.el.un('mousedown', this.onTriggerClick,  this);
            this.el.removeClass('x-combo-noedit');
        }
    },

    // private
    onBeforeLoad : function(){
        if(!this.hasFocus){
            return;
        }
        this.innerList.update(this.loadingText ?
               '<div class="loading-indicator">'+this.loadingText+'</div>' : '');
        this.restrictHeight();
        this.selectedIndex = -1;
    },

    // private
    onLoad : function(){
        if(!this.hasFocus){
            return;
        }
        if(this.store.getCount() > 0){
            this.expand();
            this.restrictHeight();
            if(this.lastQuery == this.allQuery){
                if(this.editable){
                    this.el.dom.select();
                }
                if(!this.selectByValue(this.value, true)){
                    this.select(0, true);
                }
            }else{
                this.selectNext();
                if(this.typeAhead && this.lastKey != Ext.EventObject.BACKSPACE && this.lastKey != Ext.EventObject.DELETE){
                    this.taTask.delay(this.typeAheadDelay);
                }
            }
        }else{
            this.onEmptyResults();
        }
        //this.el.focus();
    },

    // private
    onTypeAhead : function(){
        if(this.store.getCount() > 0){
            var r = this.store.getAt(0);
            var newValue = r.data[this.displayField];
            var len = newValue.length;
            var selStart = this.getRawValue().length;
            if(selStart != len){
                this.setRawValue(newValue);
                this.selectText(selStart, newValue.length);
            }
        }
    },

    // private
    onSelect : function(record, index){
        if(this.fireEvent('beforeselect', this, record, index) !== false){
            this.setValue(record.data[this.valueField || this.displayField]);
            this.collapse();
            this.fireEvent('select', this, record, index);
        }
    },

    /**
     * Returns the currently selected field value or empty string if no value is set.
     * @return {String} value The selected value
     */
    getValue : function(){
        if(this.valueField){
            return typeof this.value != 'undefined' ? this.value : '';
        }else{
            return Ext.form.ComboBox.superclass.getValue.call(this);
        }
    },

    /**
     * Clears any text/value currently set in the field
     */
    clearValue : function(){
        if(this.hiddenField){
            this.hiddenField.value = '';
        }
        this.setRawValue('');
        this.lastSelectionText = '';
        this.applyEmptyText();
        this.value = '';
    },

    /**
     * Sets the specified value into the field.  If the value finds a match, the corresponding record text
     * will be displayed in the field.  If the value does not match the data value of an existing item,
     * and the valueNotFoundText config option is defined, it will be displayed as the default field text.
     * Otherwise the field will be blank (although the value will still be set).
     * @param {String} value The value to match
     */
    setValue : function(v){
        var text = v;
        if(this.valueField){
            var r = this.findRecord(this.valueField, v);
            if(r){
                text = r.data[this.displayField];
            }else if(this.valueNotFoundText !== undefined){
                text = this.valueNotFoundText;
            }
        }
        this.lastSelectionText = text;
        if(this.hiddenField){
            this.hiddenField.value = v;
        }
        Ext.form.ComboBox.superclass.setValue.call(this, text);
        this.value = v;
    },

    // private
    findRecord : function(prop, value){
        var record;
        if(this.store.getCount() > 0){
            this.store.each(function(r){
                if(r.data[prop] == value){
                    record = r;
                    return false;
                }
            });
        }
        return record;
    },

    // private
    onViewMove : function(e, t){
        this.inKeyMode = false;
    },

    // private
    onViewOver : function(e, t){
        if(this.inKeyMode){ // prevent key nav and mouse over conflicts
            return;
        }
        var item = this.view.findItemFromChild(t);
        if(item){
            var index = this.view.indexOf(item);
            this.select(index, false);
        }
    },

    // private
    onViewClick : function(doFocus){
        var index = this.view.getSelectedIndexes()[0];
        var r = this.store.getAt(index);
        if(r){
            this.onSelect(r, index);
        }
        if(doFocus !== false){
            this.el.focus();
        }
    },

    // private
    restrictHeight : function(){
        this.innerList.dom.style.height = '';
        var inner = this.innerList.dom;
        var pad = this.list.getFrameWidth('tb')+(this.resizable?this.handleHeight:0)+this.assetHeight;
        var h = Math.max(inner.clientHeight, inner.offsetHeight, inner.scrollHeight);
        var ha = this.getPosition()[1]-Ext.getBody().getScroll().top;
        var hb = Ext.lib.Dom.getViewHeight()-ha-this.getSize().height;
        var space = Math.max(ha, hb, this.minHeight || 0)-this.list.shadowOffset-pad-5;
        h = Math.min(h, space, this.maxHeight);

        this.innerList.setHeight(h);
        this.list.beginUpdate();
        this.list.setHeight(h+pad);
        this.list.alignTo(this.wrap, this.listAlign);
        this.list.endUpdate();
    },

    // private
    onEmptyResults : function(){
        this.collapse();
    },

    /**
     * Returns true if the dropdown list is expanded, else false.
     */
    isExpanded : function(){
        return this.list && this.list.isVisible();
    },

    /**
     * Select an item in the dropdown list by its data value. This function does NOT cause the select event to fire.
     * The store must be loaded and the list expanded for this function to work, otherwise use setValue.
     * @param {String} value The data value of the item to select
     * @param {Boolean} scrollIntoView False to prevent the dropdown list from autoscrolling to display the
     * selected item if it is not currently in view (defaults to true)
     * @return {Boolean} True if the value matched an item in the list, else false
     */
    selectByValue : function(v, scrollIntoView){
        if(v !== undefined && v !== null){
            var r = this.findRecord(this.valueField || this.displayField, v);
            if(r){
                this.select(this.store.indexOf(r), scrollIntoView);
                return true;
            }
        }
        return false;
    },

    /**
     * Select an item in the dropdown list by its numeric index in the list. This function does NOT cause the select event to fire.
     * The store must be loaded and the list expanded for this function to work, otherwise use setValue.
     * @param {Number} index The zero-based index of the list item to select
     * @param {Boolean} scrollIntoView False to prevent the dropdown list from autoscrolling to display the
     * selected item if it is not currently in view (defaults to true)
     */
    select : function(index, scrollIntoView){
        this.selectedIndex = index;
        this.view.select(index);
        if(scrollIntoView !== false){
            var el = this.view.getNode(index);
            if(el){
                this.innerList.scrollChildIntoView(el, false);
            }
        }
    },

    // private
    selectNext : function(){
        var ct = this.store.getCount();
        if(ct > 0){
            if(this.selectedIndex == -1){
                this.select(0);
            }else if(this.selectedIndex < ct-1){
                this.select(this.selectedIndex+1);
            }
        }
    },

    // private
    selectPrev : function(){
        var ct = this.store.getCount();
        if(ct > 0){
            if(this.selectedIndex == -1){
                this.select(0);
            }else if(this.selectedIndex != 0){
                this.select(this.selectedIndex-1);
            }
        }
    },

    // private
    onKeyUp : function(e){
        if(this.editable !== false && !e.isSpecialKey()){
            this.lastKey = e.getKey();
            this.dqTask.delay(this.queryDelay);
        }
    },

    // private
    validateBlur : function(){
        return !this.list || !this.list.isVisible();
    },

    // private
    initQuery : function(){
        this.doQuery(this.getRawValue());
    },

    // private
    doForce : function(){
        if(this.el.dom.value.length > 0){
            this.el.dom.value =
                this.lastSelectionText === undefined ? '' : this.lastSelectionText;
            this.applyEmptyText();
        }
    },

    /**
     * Execute a query to filter the dropdown list.  Fires the {@link #beforequery} event prior to performing the
     * query allowing the query action to be canceled if needed.
     * @param {String} query The SQL query to execute
     * @param {Boolean} forceAll True to force the query to execute even if there are currently fewer characters
     * in the field than the minimum specified by the minChars config option.  It also clears any filter previously
     * saved in the current store (defaults to false)
     */
    doQuery : function(q, forceAll){
        if(q === undefined || q === null){
            q = '';
        }
        var qe = {
            query: q,
            forceAll: forceAll,
            combo: this,
            cancel:false
        };
        if(this.fireEvent('beforequery', qe)===false || qe.cancel){
            return false;
        }
        q = qe.query;
        forceAll = qe.forceAll;
        if(forceAll === true || (q.length >= this.minChars)){
            if(this.lastQuery !== q){
                this.lastQuery = q;
                if(this.mode == 'local'){
                    this.selectedIndex = -1;
                    if(forceAll){
                        this.store.clearFilter();
                    }else{
                        this.store.filter(this.displayField, q);
                    }
                    this.onLoad();
                }else{
                    this.store.baseParams[this.queryParam] = q;
                    this.store.load({
                        params: this.getParams(q)
                    });
                    this.expand();
                }
            }else{
                this.selectedIndex = -1;
                this.onLoad();
            }
        }
    },

    // private
    getParams : function(q){
        var p = {};
        //p[this.queryParam] = q;
        if(this.pageSize){
            p.start = 0;
            p.limit = this.pageSize;
        }
        return p;
    },

    /**
     * Hides the dropdown list if it is currently expanded. Fires the {@link #collapse} event on completion.
     */
    collapse : function(){
        if(!this.isExpanded()){
            return;
        }
        this.list.hide();
        Ext.getDoc().un('mousewheel', this.collapseIf, this);
        Ext.getDoc().un('mousedown', this.collapseIf, this);
        this.fireEvent('collapse', this);
    },

    // private
    collapseIf : function(e){
        if(!e.within(this.wrap) && !e.within(this.list)){
            this.collapse();
        }
    },

    /**
     * Expands the dropdown list if it is currently hidden. Fires the {@link #expand} event on completion.
     */
    expand : function(){
        if(this.isExpanded() || !this.hasFocus){
            return;
        }
        this.list.alignTo(this.wrap, this.listAlign);
        this.list.show();
        this.innerList.setOverflow('auto'); // necessary for FF 2.0/Mac
        Ext.getDoc().on('mousewheel', this.collapseIf, this);
        Ext.getDoc().on('mousedown', this.collapseIf, this);
        this.fireEvent('expand', this);
    },

    /**
     * @method onTriggerClick
     * @hide
     */
    // private
    // Implements the default empty TriggerField.onTriggerClick function
    onTriggerClick : function(){
        if(this.disabled){
            return;
        }
        if(this.isExpanded()){
            this.collapse();
            this.el.focus();
        }else {
            this.onFocus({});
            if(this.triggerAction == 'all') {
                this.doQuery(this.allQuery, true);
            } else {
                this.doQuery(this.getRawValue());
            }
            this.el.focus();
        }
    }

    /**
     * @hide
     * @method autoSize
     */
    /**
     * @cfg {Boolean} grow @hide
     */
    /**
     * @cfg {Number} growMin @hide
     */
    /**
     * @cfg {Number} growMax @hide
     */

});
Ext.reg('combo', Ext.form.ComboBox);

Ext.ux.SelectBox = function(config){
	this.searchResetDelay = 1000;
	config = config || {};
	config = Ext.apply(config || {}, {
		editable: false,
		forceSelection: true,
		rowHeight: false,
		lastSearchTerm: false,
        triggerAction: 'all',
        mode: 'local'
    });					

	Ext.ux.SelectBox.superclass.constructor.apply(this, arguments);

	this.lastSelectedIndex = this.selectedIndex || 0;
};

Ext.extend(Ext.ux.SelectBox, Ext.form.ComboBox, {
    lazyInit: false,
	initEvents : function(){
		Ext.ux.SelectBox.superclass.initEvents.apply(this, arguments);
		// you need to use keypress to capture upper/lower case and shift+key, but it doesn't work in IE
		this.el.on('keydown', this.keySearch, this, true);
		this.cshTask = new Ext.util.DelayedTask(this.clearSearchHistory, this);
	},

	keySearch : function(e, target, options) {
		var raw = e.getKey();
		var key = String.fromCharCode(raw);
		var startIndex = 0;

		if( !this.store.getCount() ) {
			return;
		}

		switch(raw) {
			case Ext.EventObject.HOME:
				e.stopEvent();
				this.selectFirst();
				return;

			case Ext.EventObject.END:
				e.stopEvent();
				this.selectLast();
				return;

			case Ext.EventObject.PAGEDOWN:
				this.selectNextPage();
				e.stopEvent();
				return;

			case Ext.EventObject.PAGEUP:
				this.selectPrevPage();
				e.stopEvent();
				return;
		}

		// skip special keys other than the shift key
		if( (e.hasModifier() && !e.shiftKey) || e.isNavKeyPress() || e.isSpecialKey() ) {
			return;
		}
		if( this.lastSearchTerm == key ) {
			startIndex = this.lastSelectedIndex;
		}
		this.search(this.displayField, key, startIndex);
		this.cshTask.delay(this.searchResetDelay);
	},

	onRender : function(ct, position) {
		this.store.on('load', this.calcRowsPerPage, this);
		Ext.ux.SelectBox.superclass.onRender.apply(this, arguments);
		if( this.mode == 'local' ) {
			this.calcRowsPerPage();
		}
	},

	onSelect : function(record, index, skipCollapse){
		if(this.fireEvent('beforeselect', this, record, index) !== false){
			this.setValue(record.data[this.valueField || this.displayField]);
			if( !skipCollapse ) {
				this.collapse();
			}
			this.lastSelectedIndex = index + 1;
			this.fireEvent('select', this, record, index);
		}
	},

	render : function(ct) {
		Ext.ux.SelectBox.superclass.render.apply(this, arguments);
		if( Ext.isSafari ) {
			this.el.swallowEvent('mousedown', true);
		}
		this.el.unselectable();
		this.innerList.unselectable();
		this.trigger.unselectable();
		this.innerList.on('mouseup', function(e, target, options) {
			if( target.id && target.id == this.innerList.id ) {
				return;
			}
			this.onViewClick();
		}, this);

		this.innerList.on('mouseover', function(e, target, options) {
			if( target.id && target.id == this.innerList.id ) {
				return;
			}
			this.lastSelectedIndex = this.view.getSelectedIndexes()[0] + 1;
			this.cshTask.delay(this.searchResetDelay);
		}, this);

		this.trigger.un('click', this.onTriggerClick, this);
		this.trigger.on('mousedown', function(e, target, options) {
			e.preventDefault();
			this.onTriggerClick();
		}, this);

		this.on('collapse', function(e, target, options) {
			Ext.getDoc().un('mouseup', this.collapseIf, this);
		}, this, true);

		this.on('expand', function(e, target, options) {
			Ext.getDoc().on('mouseup', this.collapseIf, this);
		}, this, true);
	},

	clearSearchHistory : function() {
		this.lastSelectedIndex = 0;
		this.lastSearchTerm = false;
	},

	selectFirst : function() {
		this.focusAndSelect(this.store.data.first());
	},

	selectLast : function() {
		this.focusAndSelect(this.store.data.last());
	},

	selectPrevPage : function() {
		if( !this.rowHeight ) {
			return;
		}
		var index = Math.max(this.selectedIndex-this.rowsPerPage, 0);
		this.focusAndSelect(this.store.getAt(index));
	},

	selectNextPage : function() {
		if( !this.rowHeight ) {
			return;
		}
		var index = Math.min(this.selectedIndex+this.rowsPerPage, this.store.getCount() - 1);
		this.focusAndSelect(this.store.getAt(index));
	},

	search : function(field, value, startIndex) {
		field = field || this.displayField;
		this.lastSearchTerm = value;
		var index = this.store.find.apply(this.store, arguments);
		if( index !== -1 ) {
			this.focusAndSelect(index);
		}
	},

	focusAndSelect : function(record) {
		var index = typeof record === 'number' ? record : this.store.indexOf(record);
		this.select(index, this.isExpanded());
		this.onSelect(this.store.getAt(record), index, this.isExpanded());
	},

	calcRowsPerPage : function() {
		if( this.store.getCount() ) {
			this.rowHeight = Ext.fly(this.view.getNode(0)).getHeight();
			this.rowsPerPage = this.maxHeight / this.rowHeight;
		} else {
			this.rowHeight = false;
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
 * @class Ext.form.NumberField
 * @extends Ext.form.TextField
 * Numeric text field that provides automatic keystroke filtering and numeric validation.
 * @constructor
 * Creates a new NumberField
 * @param {Object} config Configuration options
 */
Ext.form.NumberField = Ext.extend(Ext.form.TextField,  {
    /**
     * @cfg {String} fieldClass The default CSS class for the field (defaults to "x-form-field x-form-num-field")
     */
    fieldClass: "x-form-field x-form-num-field",
    /**
     * @cfg {Boolean} allowDecimals False to disallow decimal values (defaults to true)
     */
    allowDecimals : true,
    /**
     * @cfg {String} decimalSeparator Character(s) to allow as the decimal separator (defaults to '.')
     */
    decimalSeparator : ".",
    /**
     * @cfg {Number} decimalPrecision The maximum precision to display after the decimal separator (defaults to 2)
     */
    decimalPrecision : 2,
    /**
     * @cfg {Boolean} allowNegative False to prevent entering a negative sign (defaults to true)
     */
    allowNegative : true,
    /**
     * @cfg {Number} minValue The minimum allowed value (defaults to Number.NEGATIVE_INFINITY)
     */
    minValue : Number.NEGATIVE_INFINITY,
    /**
     * @cfg {Number} maxValue The maximum allowed value (defaults to Number.MAX_VALUE)
     */
    maxValue : Number.MAX_VALUE,
    /**
     * @cfg {String} minText Error text to display if the minimum value validation fails (defaults to "The minimum value for this field is {minValue}")
     */
    minText : "The minimum value for this field is {0}",
    /**
     * @cfg {String} maxText Error text to display if the maximum value validation fails (defaults to "The maximum value for this field is {maxValue}")
     */
    maxText : "The maximum value for this field is {0}",
    /**
     * @cfg {String} nanText Error text to display if the value is not a valid number.  For example, this can happen
     * if a valid character like '.' or '-' is left in the field with no number (defaults to "{value} is not a valid number")
     */
    nanText : "{0} is not a valid number",
    /**
     * @cfg {String} baseChars The base set of characters to evaluate as valid numbers (defaults to '0123456789').
     */
    baseChars : "0123456789",

    // private
    initEvents : function(){
        Ext.form.NumberField.superclass.initEvents.call(this);
        var allowed = this.baseChars+'';
        if(this.allowDecimals){
            allowed += this.decimalSeparator;
        }
        if(this.allowNegative){
            allowed += "-";
        }
        this.stripCharsRe = new RegExp('[^'+allowed+']', 'gi');
        var keyPress = function(e){
            var k = e.getKey();
            if(!Ext.isIE && (e.isSpecialKey() || k == e.BACKSPACE || k == e.DELETE)){
                return;
            }
            var c = e.getCharCode();
            if(allowed.indexOf(String.fromCharCode(c)) === -1){
                e.stopEvent();
            }
        };
        this.el.on("keypress", keyPress, this);
    },

    // private
    validateValue : function(value){
        if(!Ext.form.NumberField.superclass.validateValue.call(this, value)){
            return false;
        }
        if(value.length < 1){ // if it's blank and textfield didn't flag it then it's valid
             return true;
        }
        value = String(value).replace(this.decimalSeparator, ".");
        if(isNaN(value)){
            this.markInvalid(String.format(this.nanText, value));
            return false;
        }
        var num = this.parseValue(value);
        if(num < this.minValue){
            this.markInvalid(String.format(this.minText, this.minValue));
            return false;
        }
        if(num > this.maxValue){
            this.markInvalid(String.format(this.maxText, this.maxValue));
            return false;
        }
        return true;
    },

    getValue : function(){
        return this.fixPrecision(this.parseValue(Ext.form.NumberField.superclass.getValue.call(this)));
    },

    setValue : function(v){
    	v = typeof v == 'number' ? v : parseFloat(String(v).replace(this.decimalSeparator, "."));
        v = isNaN(v) ? '' : String(v).replace(".", this.decimalSeparator);
        Ext.form.NumberField.superclass.setValue.call(this, v);
    },

    // private
    parseValue : function(value){
        value = parseFloat(String(value).replace(this.decimalSeparator, "."));
        return isNaN(value) ? '' : value;
    },

    // private
    fixPrecision : function(value){
        var nan = isNaN(value);
        if(!this.allowDecimals || this.decimalPrecision == -1 || nan || !value){
           return nan ? '' : value;
        }
        return parseFloat(parseFloat(value).toFixed(this.decimalPrecision));
    },

    beforeBlur : function(){
        var v = this.parseValue(this.getRawValue());
        if(v){
            this.setValue(this.fixPrecision(v));
        }
    }
});
Ext.reg('numberfield', Ext.form.NumberField);
/*
 * Ext JS Library 2.2
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
     * valid according to {@link Date#parseDate} (defaults to 'm/d/Y').
     */
    format : "m/d/Y",
    /**
     * @cfg {String} altFormats
     * Multiple date formats separated by "|" to try when parsing a user input value and it doesn't match the defined
     * format (defaults to 'm/d/Y|n/j/Y|n/j/y|m/j/y|n/d/y|m/j/Y|n/d/Y|m-d-y|m-d-Y|m/d|m-d|md|mdy|mdY|d|Y-m-d').
     */
    altFormats : "m/d/Y|n/j/Y|n/j/y|m/j/y|n/d/y|m/j/Y|n/d/Y|m-d-y|m-d-Y|m/d|m-d|md|mdy|mdY|d|Y-m-d",
    /**
     * @cfg {String} disabledDaysText
     * The tooltip to display when the date falls on a disabled day (defaults to 'Disabled')
     */
    disabledDaysText : "Disabled",
    /**
     * @cfg {String} disabledDatesText
     * The tooltip text to display when the date falls on a disabled date (defaults to 'Disabled')
     */
    disabledDatesText : "Disabled",
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
     * @cfg {Boolean} showToday
     * False to hide the footer area of the DatePicker containing the Today button and disable the keyboard
     * handler for spacebar that selects the current date (defaults to true).
     */
    showToday : true,
    /**
     * @cfg {Date/String} minValue
     * The minimum allowed date. Can be either a Javascript date object or a string date in a
     * valid format (defaults to null).
     */
    /**
     * @cfg {Date/String} maxValue
     * The maximum allowed date. Can be either a Javascript date object or a string date in a
     * valid format (defaults to null).
     */
    /**
     * @cfg {Array} disabledDays
     * An array of days to disable, 0 based. For example, [0, 6] disables Sunday and Saturday (defaults to null).
     */
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
     * Note that the format of the dates included in the array should exactly match the {@link #format} config.
     * In order to support regular expressions, if you are using a date format that has "." in it, you will have to
     * escape the dot when restricting dates. For example: ["03\\.08\\.03"].
     */
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
        this.initDisabledDays();
    },

    // private
    initDisabledDays : function(){
        if(this.disabledDates){
            var dd = this.disabledDates;
            var re = "(?:";
            for(var i = 0; i < dd.length; i++){
                re += dd[i];
                if(i != dd.length-1) re += "|";
            }
            this.disabledDatesRE = new RegExp(re + ")");
        }
    },

    /**
     * Replaces any existing disabled dates with new values and refreshes the DatePicker.
     * @param {Array} disabledDates An array of date strings (see the {@link #disabledDates} config
     * for details on supported values) used to disable a pattern of dates.
     */
    setDisabledDates : function(dd){
        this.disabledDates = dd;
        this.initDisabledDays();
        if(this.menu){
            this.menu.picker.setDisabledDates(this.disabledDatesRE);
        }
    },

    /**
     * Replaces any existing disabled days (by index, 0-6) with new values and refreshes the DatePicker.
     * @param {Array} disabledDays An array of disabled day indexes. See the {@link #disabledDays} config
     * for details on supported values.
     */
    setDisabledDays : function(dd){
        this.disabledDays = dd;
        if(this.menu){
            this.menu.picker.setDisabledDays(dd);
        }
    },

    /**
     * Replaces any existing {@link #minValue} with the new value and refreshes the DatePicker.
     * @param {Date} value The minimum date that can be selected
     */
    setMinValue : function(dt){
        this.minValue = (typeof dt == "string" ? this.parseDate(dt) : dt);
        if(this.menu){
            this.menu.picker.setMinDate(this.minValue);
        }
    },

    /**
     * Replaces any existing {@link #maxValue} with the new value and refreshes the DatePicker.
     * @param {Date} value The maximum date that can be selected
     */
    setMaxValue : function(dt){
        this.maxValue = (typeof dt == "string" ? this.parseDate(dt) : dt);
        if(this.menu){
            this.menu.picker.setMaxDate(this.maxValue);
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
     * (the default format used is "m/d/Y").
     * <br />Usage:
     * <pre><code>
//All of these calls set the same date value (May 4, 2006)

//Pass a date object:
var dt = new Date('5/4/2006');
dateField.setValue(dt);

//Pass a date string (default format):
dateField.setValue('05/04/2006');

//Pass a date string (custom format):
dateField.format = 'Y-m-d';
dateField.setValue('2006-05-04');
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

    /**
     * @method onTriggerClick
     * @hide
     */
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
            showToday : this.showToday,
            minText : String.format(this.minText, this.formatDate(this.minValue)),
            maxText : String.format(this.maxText, this.formatDate(this.maxValue))
        });
        this.menu.on(Ext.apply({}, this.menuListeners, {
            scope:this
        }));
        this.menu.picker.setValue(this.getValue() || new Date());
        this.menu.show(this.el, "tl-bl?");
    },

    // private
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
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

/**
 * @class Ext.form.TimeField
 * @extends Ext.form.ComboBox
 * Provides a time input field with a time dropdown and automatic time validation.  Example usage:
 * <pre><code>
new Ext.form.TimeField({
    minValue: '9:00 AM',
    maxValue: '6:00 PM',
    increment: 30
});
</code></pre>
 * @constructor
 * Create a new TimeField
 * @param {Object} config
 */
Ext.form.TimeField = Ext.extend(Ext.form.ComboBox, {
    /**
     * @cfg {Date/String} minValue
     * The minimum allowed time. Can be either a Javascript date object with a valid time value or a string 
     * time in a valid format -- see {@link #format} and {@link #altFormats} (defaults to null).
     */
    minValue : null,
    /**
     * @cfg {Date/String} maxValue
     * The maximum allowed time. Can be either a Javascript date object with a valid time value or a string 
     * time in a valid format -- see {@link #format} and {@link #altFormats} (defaults to null).
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
     * '{value} is not a valid time').
     */
    invalidText : "{0} is not a valid time",
    /**
     * @cfg {String} format
     * The default time format string which can be overriden for localization support.  The format must be
     * valid according to {@link Date#parseDate} (defaults to 'g:i A', e.g., '3:15 PM').  For 24-hour time
     * format try 'H:i' instead.
     */
    format : "g:i A",
    /**
     * @cfg {String} altFormats
     * Multiple date formats separated by "|" to try when parsing a user input value and it doesn't match the defined
     * format (defaults to 'g:ia|g:iA|g:i a|g:i A|h:i|g:i|H:i|ga|ha|gA|h a|g a|g A|gi|hi|gia|hia|g|H').
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
    
    // private - This is the date to use when generating time values in the absence of either minValue
    // or maxValue.  Using the current date causes DST issues on DST boundary dates, so this is an 
    // arbitrary "safe" date that can be any date aside from DST boundary dates.
    initDate: '1/1/2008',

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
                min = new Date(this.initDate).clearTime();
            }
            var max = this.parseDate(this.maxValue);
            if(!max){
                max = new Date(this.initDate).clearTime().add('mi', (24 * 60) - 1);
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

/*
 * Ext JS Library 2.2
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */


Ext.form.FileUploadField = Ext.extend(Ext.form.TextField,  {
    /**
     * @cfg {String} buttonText The button text to display on the upload button (defaults to
     * 'Browse...').  Note that if you supply a value for {@link #buttonCfg}, the buttonCfg.text
     * value will be used instead if available.
     */
    buttonText: 'Browse...',
    /**
     * @cfg {Boolean} buttonOnly True to display the file upload field as a button with no visible
     * text field (defaults to false).  If true, all inherited TextField members will still be available.
     */
    buttonOnly: false,
    /**
     * @cfg {Number} buttonOffset The number of pixels of space reserved between the button and the text field
     * (defaults to 3).  Note that this only applies if {@link #buttonOnly} = false.
     */
    buttonOffset: 3,
    /**
     * @cfg {Object} buttonCfg A standard {@link Ext.Button} config object.
     */

    // private
    readOnly: true,
    
    /**
     * @hide 
     * @method autoSize
     */
    autoSize: Ext.emptyFn,
    
    // private
    initComponent: function(){
        Ext.form.FileUploadField.superclass.initComponent.call(this);
        
        this.addEvents(
            /**
             * @event fileselected
             * Fires when the underlying file input field's value has changed from the user
             * selecting a new file from the system file selection dialog.
             * @param {Ext.form.FileUploadField} this
             * @param {String} value The file value returned by the underlying file input field
             */
            'fileselected'
        );
    },
    
    // private
    onRender : function(ct, position){
        Ext.form.FileUploadField.superclass.onRender.call(this, ct, position);
        
        this.wrap = this.el.wrap({cls:'x-form-field-wrap x-form-file-wrap'});
        this.el.addClass('x-form-file-text');
        this.el.dom.removeAttribute('name');
        
        this.fileInput = this.wrap.createChild({
            id: this.getFileInputId(),
            name: this.name||this.getId(),
            cls: 'x-form-file',
            tag: 'input', 
            type: 'file',
            size: 1
        });
        
        var btnCfg = Ext.applyIf(this.buttonCfg || {}, {
            text: this.buttonText
        });
        this.button = new Ext.Button(Ext.apply(btnCfg, {
            renderTo: this.wrap,
            cls: 'x-form-file-btn' + (btnCfg.iconCls ? ' x-btn-icon' : '')
        }));
        
        if(this.buttonOnly){
            this.el.hide();
            this.wrap.setWidth(this.button.getEl().getWidth());
        }
        
        this.fileInput.on('change', function(){
            var v = this.fileInput.dom.value;
            this.setValue(v);
            this.fireEvent('fileselected', this, v);
        }, this);
    },
    
    // private
    getFileInputId: function(){
        return this.id+'-file';
    },
    
    // private
    onResize : function(w, h){
        Ext.form.FileUploadField.superclass.onResize.call(this, w, h);
        
        this.wrap.setWidth(w);
        
        if(!this.buttonOnly){
            var w = this.wrap.getWidth() - this.button.getEl().getWidth() - this.buttonOffset;
            this.el.setWidth(w);
        }
    },
    
    // private
    preFocus : Ext.emptyFn,
    
    // private
    getResizeEl : function(){
        return this.wrap;
    },

    // private
    getPositionEl : function(){
        return this.wrap;
    },

    // private
    alignErrorIcon : function(){
        this.errorIcon.alignTo(this.wrap, 'tl-tr', [2, 0]);
    }
    
});
Ext.reg('fileuploadfield', Ext.form.FileUploadField);
