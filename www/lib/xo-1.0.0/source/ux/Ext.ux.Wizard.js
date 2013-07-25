/**
 * @class Ext.ux.wizard
 * @extends Ext.Window
 * @url http://extjs.com/learn/Extension:Wizard_for_Extjs_1.x
 * http://extjs.com/forum/showthread.php?t=12580
 * In Ext2.0, Although you can extend a built-in card layout into a wizard component should be pretty easy,
 * here's another implemention of my own, which is upgarded from the version runs well at 1.x.
 * @param {Object} config The config object the same as Ext.Window.
 */
Ext.ux.wizard = function(config){
	var _config = Ext.apply({
		renderTo : Ext.getBody(),
		buttons  : [
			{text:'Pervious', handler: this.movePervious, scope: this, hidden:true},
			{text:'Next', handler: this.moveNext, scope: this},
			{text:'Finish', handler: this.finisHanlder, scope: this, hidden:true},
			{text:'Cancel', handler: this.hideHanlder, scope: this}
		]
	}, config||{});

	this.id = 0;

	this.stepPages = [];
	this.loaded_Page_No;
	this.loaded_Page;

	Ext.ux.wizard.superclass.constructor.call(this, _config);
	this.render();

	this.on('show',function(){
		if(!this.loaded_Page_No){
			this.move(1);//first one
		}
	},this);
	this.dlg = this;
};
Ext.extend(Ext.ux.wizard , Ext.Window, {
	/**
	 * Add steps' content to dialog body.
	 * @param {Object} config
	 * An object containing configuration properties for a step.
	 * This may contain any of the following properties:
	 * @cfg {String} title The title of step(be set to Ext.dialog.title)
	 * @cfg {Boolean} goNextConfirm Optional. True if showing a confirm dialog to ask the user before go Next Step.
	 * @cfg {Boolean} goPerviousConfirm Optional. True if showing a confirm dialog to ask the user before go Previous Step.
	 * @cfg {Boolean} autoResetForm Optional. True if reseting form after go Next/Previous Step.
	 * @cfg {Functionfn} The function to add step's content.
	 */
	addStepContent:function(step){
//		just names it for a mention that this is 'Class'.
		var Class_Page = step.fn;
		if(typeof Class_Page != 'function')throw 'argments must be a function.';
//		assign the prototype with id++ for every fn
		Class_Page.prototype = {
			id:this.id++,
			title:step.title||'Step:'+(this.id++),
			goNextConfirm:!!(step.goNextConfirm),
			goPerviousConfirm:!!(step.goPerviousConfirm),
			autoResetForm:!!(step.autoResetForm),
			dlg:this.dlg,
			container:null,

			getDIV:function(){
//				this-->instance
				return this.container;
			},
			notiflyDlg:function(moveDirection){
				return moveDirection=='>'?this.goNextConfirm:this.goPerviousConfirm;
			}
		};
		var incomingPage = new Class_Page();
		var StepPanel = incomingPage.getDIV();
		if( StepPanel){
			StepPanel.setStyle('display','none');
		}
		this.stepPages.push(incomingPage);
	},
	/**
	 * @private
	 */
	move:function(pageNo){
		if( this.loaded_Page && (pageNo!=0) ){
			this.loaded_Page.applyStyles('display:none');
		}

//			get a instance for every page
		var pageInstance = this.stepPages[(pageNo-1)];
		var step = pageInstance.getDIV();//always less one than the length of index
		step.show();
		this.dlg.setTitle(pageInstance.title);
//		auotResetForm check out
		if(pageInstance.autoResetForm){
			step.child('form').dom.reset();
		}
		this.loaded_Page = step;
		this.loaded_Page_No = pageNo;
	},
	/**
	 * @private
	 */
	moveNext:function(btn,e){
		var body = this.dlg.body;
//		goNextConfirm? true if showing a confirm dialog to ask the user
		var pageInstance = this.stepPages[this.loaded_Page_No-1];//pervious page!
		if( pageInstance && pageInstance.notiflyDlg('>')){
			if(!window.confirm('Do you want to go Next Page?'))
				return;
		};
		this.move(this.loaded_Page_No+1);

		var isLastPage = (this.loaded_Page_No)==(this.stepPages.length);
		if(this.dlg.buttons[0].disabled&&!isLastPage){
			this.dlg.buttons[2].hide();
			this.dlg.buttons[0].enable(); //'pervious button'
		}
		if(isLastPage){//arrives at last page
			btn.disable();
			this.dlg.buttons[2].show();//'finish' button
			this.dlg.buttons[3].hide();
		}
		if(this.loaded_Page_No > 0){//first one
			this.dlg.buttons[0].show();
		}
	},
	/**
	 * @private
	 */
	movePervious:function(btn,e){
		var body = this.dlg.body;
//		goNextPervious?
		var pageInstance = this.stepPages[this.loaded_Page_No-1];//pervious page!
		if( pageInstance && pageInstance.notiflyDlg('<')){
			if(!window.confirm('Do you want to go Pervious?'))
				return;
		};
		this.move(this.loaded_Page_No-1);

		var isNo1Page = ((this.loaded_Page_No)==1);
		if(this.dlg.buttons[1].disabled&&!isNo1Page){
			this.dlg.buttons[2].hide();
			this.dlg.buttons[3].show();
			this.dlg.buttons[1].enable();
		}
		if(isNo1Page){//arrives at pervious page
			btn.disable();
			this.dlg.buttons[0].hide();
			this.dlg.buttons[1].enable();//'movefisrt' button
		}
	},
	/**
	 * @override
	 */
	hideHanlder :function(){
		this.hide();
	},
	/**
	 * @override
	 */
	finisHanlder:function(){}
});