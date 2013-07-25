Ext.override(Ext.form.FormPanel, {
	initComponent: function() {
		this.form = this.createForm();
		this.bodyCfg = {
			tag: 'form',
			cls: 'x-panel-body',
			method: this.method || 'POST',
			id: this.formId || Ext.id()
		};
		if(this.fileUpload) {
			this.bodyCfg.enctype = 'multipart/form-data';
		}
		Ext.FormPanel.superclass.initComponent.call(this);
		this.addEvents(
			'clientvalidation'
		);
		this.relayEvents(this.form, ['beforeaction', 'actionfailed', 'actioncomplete']);
	},
	onRender: function(ct, position){
		this.initFields();
		Ext.FormPanel.superclass.onRender.call(this, ct, position);
		this.form.initEl(this.body);
	}
});