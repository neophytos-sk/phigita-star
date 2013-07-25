

// CreateLink ----------------------------------------------------------------------------------------------------------



Xinha.prototype.linkDialog = function(){

    // define some private variables
    var dialog, showBtn, fp, editor;

    // return a public interface
    return {
       
        showDialog : function(dialog_editor,dialog_link,dialog_param){

	    editor = dialog_editor;
	    link = dialog_link;

	    if (!link) { editor.setCC(); }

            if(!dialog){ 

                dialog = new Ext.Window( { 
		    title:'Edit Link',
		    autoTabs:false,
		    modal:true,
		    width:350,
		    height:175,
		    shadow:true,
		    proxyDrag: true,
		    collapsible: false,
		    resizable: false,
		    draggable: false,
		    keys: [{
			key: 27,
			fn: this.hideDialog
		    }]
                });

		fp = new Ext.FormPanel({
		    labelWidth: 75,
		    monitorValid: true,
		    monitorPoll:100,
		    border:false,
		    bodyBorder:false,
		    buttons: [{
			text: 'Ok',
			formBind:true,
			disabled:true,
			handler:this.ok,
			scope:dialog
		    },{
			text: 'Cancel',
			handler:this.hideDialog
		    }]
		});
		fp.add(
		       new Ext.form.TextField({
			   fieldLabel: 'Text to display',
			   name: 'f_label',
			   width:225,
			   allowBlank:false,
//			   validationDelay:100,
			   listeners:{'specialKey':{fn: this.specialkeyFn,scope: this}}
		       })
		 );

                 fp.add(
			new Ext.form.TextField({
			    fieldLabel: 'To what URL should this link go?',
			    name: 'f_href',
			    vtype:'url',
			    width:225,
			    allowBlank:false,
//			    validationDelay:100,
			    listeners:{'specialKey':{fn: this.specialkeyFn,scope: this}}
			})
	        );


                dialog.add(fp);

		//dialog.on('hide', this.hideDialog);


//	dialog.getTabs().addTab('first-tab','test',_xo_tab_html);
//	dialog.getTabs().activate(0);




        }

	    fp.getForm().reset();
	    fp.getForm().setValues(dialog_param);
	    fp.getForm().clearInvalid();
	    dialog.show();
	    fp.getForm().findField('f_label').focus(true,10);

        },

      hideDialog:function(e){
	if (typeof e != 'undefined' && e.browserEvent != null) Xinha._stopEvent(e);
	  dialog.hide();
	  editor.focusEditor();
	  if (!link) { editor.findCC(); }
      },

      specialkeyFn: function(field,e) {
	  if ( e.getKey() == e.RETURN || e.getKey() == e.ENTER ) {
	      if (fp.getForm().isValid()) {
		  e.stopEvent();
		  this.ok();
	      }
	  }
      },

      ok: function() {

	    param = fp.getForm().getValues(false);
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

