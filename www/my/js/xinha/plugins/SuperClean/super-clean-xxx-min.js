
function SuperClean(editor,args)
{this.editor=editor;var superclean=this;editor._superclean_on=false;editor.config.registerButton('superclean',this._lc("Clean up HTML"),editor.imgURL('ed_superclean.gif','SuperClean'),true,function(e,objname,obj){superclean._superClean(null,obj);});editor.config.addToolbarElement("superclean","killword",0);}
SuperClean._pluginInfo={name:"SuperClean",version:"1.0",developer:"James Sleeman, Niko Sams",developer_url:"http://www.gogo.co.nz/",c_owner:"Gogo Internet Services",license:"htmlArea",sponsor:"Gogo Internet Services",sponsor_url:"http://www.gogo.co.nz/"};SuperClean.prototype._lc=function(string){return Xinha._lc(string,'SuperClean');};SuperClean.prototype._superClean=function(opts,obj)
{var superclean=this;var doOK=function()
{var opts=superclean._dialog.hide();var editor=superclean.editor;if(opts.word_clean)editor._wordClean();var D=editor.getInnerHTML();for(var filter in editor.config.SuperClean.filters)
{if(filter=='tidy'||filter=='word_clean')continue;if(opts[filter])
{D=SuperClean.filterFunctions[filter](D,editor);}}
D=D.replace(/(style|class)="\s*"/gi,'');D=D.replace(/<(font|span)\s*>/gi,'');editor.setHTML(D);if(opts.tidy)
{Xinha._postback(editor.config.SuperClean.tidy_handler,{'content':editor.getInnerHTML()},function(javascriptResponse){eval(javascriptResponse)});}
return true;}
if(this.editor.config.SuperClean.show_dialog)
{var inputs={};this._dialog.show(inputs,doOK);}
else
{var editor=this.editor;var html=editor.getInnerHTML();for(var filter in editor.config.SuperClean.filters)
{if(filter=='tidy')continue;html=SuperClean.filterFunctions[filter](html,editor);}
html=html.replace(/(style|class)="\s*"/gi,'');html=html.replace(/<(font|span)\s*>/gi,'');editor.setHTML(html);if(editor.config.SuperClean.filters.tidy)
{SuperClean.filterFunctions.tidy(html,editor);}}};Xinha.Config.prototype.SuperClean={'tidy_handler':_editor_url+'plugins/SuperClean/tidy.php','filters':{'tidy':Xinha._lc('General tidy up and correction of some problems.','SuperClean'),'word_clean':Xinha._lc('Clean bad HTML from Microsoft Word','SuperClean'),'remove_faces':Xinha._lc('Remove custom typefaces (font "styles").','SuperClean'),'remove_sizes':Xinha._lc('Remove custom font sizes.','SuperClean'),'remove_colors':Xinha._lc('Remove custom text colors.','SuperClean'),'remove_lang':Xinha._lc('Remove lang attributes.','SuperClean'),'remove_fancy_quotes':{label:Xinha._lc('Replace directional quote marks with non-directional quote marks.','SuperClean'),checked:false}},'show_dialog':true};SuperClean.filterFunctions={};SuperClean.filterFunctions.remove_colors=function(D)
{D=D.replace(/color="?[^" >]*"?/gi,'');D=D.replace(/([^-])color:[^;}"']+;?/gi,'$1');return(D);};SuperClean.filterFunctions.remove_sizes=function(D)
{D=D.replace(/size="?[^" >]*"?/gi,'');D=D.replace(/font-size:[^;}"']+;?/gi,'');return(D);};SuperClean.filterFunctions.remove_faces=function(D)
{D=D.replace(/face="?[^" >]*"?/gi,'');D=D.replace(/font-family:[^;}"']+;?/gi,'');return(D);};SuperClean.filterFunctions.remove_lang=function(D)
{D=D.replace(/lang="?[^" >]*"?/gi,'');return(D);};SuperClean.filterFunctions.word_clean=function(html,editor)
{editor.setHTML(html);editor._wordClean();return editor.getInnerHTML();};SuperClean.filterFunctions.remove_fancy_quotes=function(D)
{D=D.replace(new RegExp(String.fromCharCode(8216),"g"),"'");D=D.replace(new RegExp(String.fromCharCode(8217),"g"),"'");D=D.replace(new RegExp(String.fromCharCode(8218),"g"),"'");D=D.replace(new RegExp(String.fromCharCode(8219),"g"),"'");D=D.replace(new RegExp(String.fromCharCode(8220),"g"),"\"");D=D.replace(new RegExp(String.fromCharCode(8221),"g"),"\"");D=D.replace(new RegExp(String.fromCharCode(8222),"g"),"\"");D=D.replace(new RegExp(String.fromCharCode(8223),"g"),"\"");return D;};SuperClean.filterFunctions.tidy=function(html,editor)
{Xinha._postback(editor.config.SuperClean.tidy_handler,{'content':html},function(javascriptResponse){eval(javascriptResponse)});};SuperClean.prototype.onGenerate=function()
{if(this.editor.config.SuperClean.show_dialog&&!this._dialog)
{this._dialog=new SuperClean.Dialog(this);}
if(this.editor.config.tidy_handler)
{this.editor.config.SuperClean.tidy_handler=this.editor.config.tidy_handler;this.editor.config.tidy_handler=null;}
if(!this.editor.config.SuperClean.tidy_handler&&this.editor.config.filters.tidy){this.editor.config.filters.tidy=null;}
var sc=this;for(var filter in this.editor.config.SuperClean.filters)
{if(!SuperClean.filterFunctions[filter])
{var filtDetail=this.editor.config.SuperClean.filters[filter];if(typeof filtDetail.filterFunction!='undefined')
{SuperClean.filterFunctions[filter]=filterFunction;}
else
{Xinha._getback(_editor_url+'plugins/SuperClean/filters/'+filter+'.js',function(func){eval('SuperClean.filterFunctions.'+filter+'='+func+';');sc.onGenerate();});}
return;}}};SuperClean.Dialog=function(SuperClean)
{var lDialog=this;this.Dialog_nxtid=0;this.SuperClean=SuperClean;this.id={};this.ready=false;this.files=false;this.html=false;this.dialog=false;this._prepareDialog();};SuperClean.Dialog.prototype._prepareDialog=function()
{var lDialog=this;var SuperClean=this.SuperClean;if(this.html==false)
{Xinha._getback(_editor_url+'plugins/SuperClean/dialog.html',function(txt){lDialog.html=txt;lDialog._prepareDialog();});return;}
var htmlFilters="";for(var filter in this.SuperClean.editor.config.SuperClean.filters)
{htmlFilters+="    <div>\n";var filtDetail=this.SuperClean.editor.config.SuperClean.filters[filter];if(typeof filtDetail.label=='undefined')
{htmlFilters+="        <input type=\"checkbox\" name=\"["+filter+"]\" id=\"["+filter+"]\" checked />\n";htmlFilters+="        <label for=\"["+filter+"]\">"+this.SuperClean.editor.config.SuperClean.filters[filter]+"</label>\n";}
else
{htmlFilters+="        <input type=\"checkbox\" name=\"["+filter+"]\" id=\"["+filter+"]\" "+(filtDetail.checked?"checked":"")+" />\n";htmlFilters+="        <label for=\"["+filter+"]\">"+filtDetail.label+"</label>\n";}
htmlFilters+="    </div>\n";}
this.html=this.html.replace('<!--filters-->',htmlFilters);var html=this.html;var dialog=this.dialog=new Xinha.Dialog(SuperClean.editor,this.html,'SuperClean');this.ready=true;};SuperClean.Dialog.prototype._lc=SuperClean.prototype._lc;SuperClean.Dialog.prototype.show=function(inputs,ok,cancel)
{if(!this.ready)
{var lDialog=this;window.setTimeout(function(){lDialog.show(inputs,ok,cancel);},100);return;}
var dialog=this.dialog;var lDialog=this;if(ok)
{this.dialog.getElementById('ok').onclick=ok;}
else
{this.dialog.getElementById('ok').onclick=function(){lDialog.hide();};}
if(cancel)
{this.dialog.getElementById('cancel').onclick=cancel;}
else
{this.dialog.getElementById('cancel').onclick=function(){lDialog.hide()};}
this.SuperClean.editor.disableToolbar(['fullscreen','SuperClean']);this.dialog.show(inputs);this.dialog.onresize();};SuperClean.Dialog.prototype.hide=function()
{this.SuperClean.editor.enableToolbar();return this.dialog.hide();};
