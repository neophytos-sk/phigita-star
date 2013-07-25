/*
 * Ext JS Library 2.0.2
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
 * Ext JS Library 2.0.2
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
     * @param {Boolean} asString (optional) false to return the the values as an object (defaults to returning as a string)
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
     * Looks at the fields in this form, checks them for an id attribute,
     * and calls applyTo on the existing dom element with that id.
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
 * Ext JS Library 2.0.2
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
     * @cfg {String} itemCls An additional CSS class to apply to the wrapper element of this field (defaults to the container's itemCls
     * value if set, or '').  Since it is applied to the wrapper, it allows you to write standard CSS rules that can apply to
     * the field, the label (if specified) or any other element within the markup for the field.  Example use:
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

    /**
     * @cfg {String} inputType The type attribute for input fields -- e.g. radio, text, password (defaults to "text").
     */

    /**
     * @cfg {Number} tabIndex The tabIndex for this field. Note this only applies to fields that are rendered,
     * not those which are built via applyTo (defaults to undefined).
	 */

    // private
    isFormField : true,

    // private
    hasFocus : false,

    /**
     * @cfg {Mixed} value A value to initialize this field with.
     */
    
    /**
     * @cfg {String} name The field's HTML name attribute.
     */
    /**
     * @cfg {String} cls A CSS class to apply to the field's underlying element.
     */

	// private ??
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
        this.initValue();
    },

    // private
    initValue : function(){
        if(this.value !== undefined){
            this.setValue(this.value);
        }else if(this.el.dom.value.length > 0){
            this.setValue(this.el.dom.value);
        }
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
        this.el.on(Ext.isIE ? "keydown" : "keypress", this.fireKey,  this);
        this.el.on("focus", this.onFocus,  this);
        this.el.on("blur", this.onBlur,  this);

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

    processValue : function(value){
        return value;
    },

    // private
    // Subclasses should provide the validation implementation by overriding this
    validateValue : function(value){
        return true;
    },

    /**
     * Mark this field as invalid
     * @param {String} msg The validation message
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
                    var elp = this.el.findParent('.x-form-element', 5, true);
                    this.errorEl = elp.createChild({cls:'x-form-invalid-msg'});
                    this.errorEl.setWidth(elp.getWidth(true)-20);
                }
                this.errorEl.update(msg);
                Ext.form.Field.msgFx[this.msgFx].show(this.errorEl, this);
                break;
            case 'side':
                if(!this.errorIcon){
                    var elp = this.el.findParent('.x-form-element', 5, true);
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

    adjustSize : function(w, h){
        var s = Ext.form.Field.superclass.adjustSize.call(this, w, h);
        s.width = this.adjustWidth(this.el.dom.tagName, s.width);
        return s;
    },

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
                if(tag = 'textarea' && Ext.isStrict){
                    return w-2;
                }
            }else if(Ext.isOpera && Ext.isStrict){
                if(tag == 'input'){
                    return w + 2;
                }
                if(tag = 'textarea'){
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
 * Ext JS Library 2.0.2
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
            'autosize'
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
            if(this.emptyText){
                this.on('blur', this.postBlur, this);
                this.applyEmptyText();
            }
        }
        if(this.maskRe || (this.vtype && this.disableKeyFilter !== true && (this.maskRe = Ext.form.VTypes[this.vtype+'Mask']))){
            this.el.on("keypress", this.filterKeys, this);
        }
        if(this.grow){
            this.el.on("keyup", this.onKeyUp,  this, {buffer:50});
            this.el.on("click", this.autoSize,  this);
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
    onKeyUp : function(e){
        if(!e.isNavKeyPress()){
            this.autoSize();
        }
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
        var k = e.getKey();
        if(!Ext.isIE && (e.isNavKeyPress() || k == e.BACKSPACE || (k == e.DELETE && e.button == -1))){
            return;
        }
        var c = e.getCharCode(), cc = String.fromCharCode(c);
        if(Ext.isIE && (e.isSpecialKey() || !cc)){
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
     * This only takes effect if grow = true, and fires the autosize event.
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
 * Ext JS Library 2.0.2
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
    },

    /**
     * Automatically grows the field to accomodate the height of the text up to the maximum field height allowed.
     * This only takes effect if grow = true, and fires the autosize event if the height changes.
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
 * Ext JS Library 2.0.2
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
 * Ext JS Library 2.0.2
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
     * @cfg {Number} labelWidth The width of labels. This property cascades to child containers.
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
     * This property cascades to child containers if not set.
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
            if(c.doLayout && c != formPanel){
                Ext.applyIf(c, {
                    labelAlign: c.ownerCt.labelAlign,
                    labelWidth: c.ownerCt.labelWidth,
                    itemCls: c.ownerCt.itemCls
                });
                if(c.items){
                    c.items.each(fn);
                }
            }else if(c.isFormField){
                f.add(c);
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
        var o = {
            tag: 'form',
            method : this.method || 'POST',
            id : this.formId || Ext.id()
        };
        if(this.fileUpload) {
            o.enctype = 'multipart/form-data';
        }
        this.form.initEl(this.body.createChild(o));
    },
    
    // private
    beforeDestroy: function(){
        Ext.FormPanel.superclass.beforeDestroy.call(this);
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


