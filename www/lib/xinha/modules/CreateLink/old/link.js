CreateLink._pluginInfo = {
  name          : "CreateLink"
};

function CreateLink(editor) {
}                                                       

Xinha.prototype.linkDialog = function(){

    // define some private variables
    var dialog, showBtn, dialog_form, editor;

    // return a public interface
    return {
       
        showDialog : function(dialog_editor,dialog_link,dialog_param){

	    editor = dialog_editor;
	    link = dialog_link;

	    if (!link) { editor.setCC(); }

            if(!dialog){ 
                dialog = new Ext.BasicDialog("hello-dlg", { 
			title:'Edit Link',
			autoCreate:true,
                        autoTabs:false,
			modal:true,
                        width:500,
                        height:300,
                        shadow:true,
                        minWidth:300,
                        minHeight:50,
                        proxyDrag: true,
			collapsible: false
                });

		dialog_form = new Ext.form.Form({
		  labelWidth: 75,
		  monitorValid: true,
		  monitorPoll:100
		  });
		dialog_form.add(
	          new Ext.form.TextField({
	            fieldLabel: 'Text to display',
	            name: 'f_label',
	            width:225,
	            allowBlank:false,
		    validationDelay:100
	          }),

	          new Ext.form.TextField({
	            fieldLabel: 'To what URL should this link go?',
	            name: 'f_href',
		    vtype:'url',
	            width:225,
	            allowBlank:false,
		    validationDelay:100
	          })
	        );
		_xo_link_form = dialog.body.createChild({tag: "div"});

		//dialog.on('hide', this.hideDialog);


		dialog_form.items.each(this.specialkeyInit, this);
		dialog_form.on('submit',this.ok);
                dialog_form.addButton({text:'Ok',formBind:true}, this.ok, dialog).disable();
                dialog_form.addButton('Cancel', this.hideDialog, dialog);
		dialog_form.render(_xo_link_form.id);


                dialog.addKeyListener(27, this.hideDialog, dialog);


//	dialog.getTabs().addTab('first-tab','test',_xo_tab_html);
//	dialog.getTabs().activate(0);

            }
	    dialog_form.reset();
	    dialog_form.setValues(dialog_param);
	    dialog_form.clearInvalid();
            dialog.show();
	    dialog_form.findField('f_label').focus();

        },

      hideDialog:function(e){
	  if (typeof e != 'undefined' && e.browserEvent != null) Xinha._stopEvent(e.browserEvent);
	  dialog.hide();
	  editor.focusEditor();
	  if (!link) { editor.findCC(); }
      },

      specialkeyInit : function(el,_xo_this,_xo_el_index) {
	  el.on('specialkey',  this.specialkeyHandler, this);
      },

      specialkeyHandler: function(field,e) {
	  if ( e.getKey() == e.RETURN || e.getKey() == e.ENTER ) {
	      if (dialog_form.isValid()) {
		  this.ok();
		  Xinha._stopEvent(e.browserEvent);
	      }
	  }
      },

      ok: function() {

	    param = dialog_form.getValues(false);
	    editor.linkDialog.hideDialog();

	    var a = link;
	    if ( !a ) {
		    editor.insertAtCursor('<a href="' + param.f_href.trim() + '">' + param.f_label.trim() + '</a>'+ (Xinha.is_gecko ? editor.cc : ''));
		    if (Xinha.is_gecko) editor.findCC();
	    } else {
		    a.href = param.f_href.trim();
		    if (!Xinha.is_ie)
			a.childNodes[0].textContent = param.f_label.trim();
		    else
			a.innerText = param.f_label.trim();
		    editor.moveAfterNode(a);
	    }
	    editor.updateToolbar();
	}
    };
}();

Xinha.prototype._createLink = function(link)
{
  var editor = this;
  var outparam = null;
  var sel = editor.getSelection();
  var range = editor.createRange(sel);

  if ( typeof link == "undefined" ) {
	link = this._getElement('a');
  }
  if ( !link ) {
	this.fullwordSelection();
  } else {
      editor.selectNodeContents(link);
      outparam = {
	  f_href   : Xinha.is_ie ? link.href.trim() : link.getAttribute("href"),
	  f_label : Xinha.is_ie ? link.innerText : link.textContent
      };
  }

  this.linkDialog.showDialog(editor,link,outparam);
  return;

};
