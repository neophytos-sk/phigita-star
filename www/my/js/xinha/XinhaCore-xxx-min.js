
Xinha.version={'Release':'Trunk','Head':'$HeadURL: http://svn.xinha.python-hosting.com/trunk/XinhaCore.js $'.replace(/^[^:]*: (.*) \$$/,'$1'),'Date':'$LastChangedDate: 2007-02-03 02:11:56 +1300 (Sat, 03 Feb 2007) $'.replace(/^[^:]*: ([0-9-]*) ([0-9:]*) ([+0-9]*) \((.*)\) \$/,'$4 $2 $3'),'Revision':'$LastChangedRevision: 711 $'.replace(/^[^:]*: (.*) \$$/,'$1'),'RevisionBy':'$LastChangedBy: ray $'.replace(/^[^:]*: (.*) \$$/,'$1')};if(typeof _editor_url=="string")
{_editor_url=_editor_url.replace(/\x2f*$/,'/');}
else
{alert("WARNING: _editor_url is not set!  You should set this variable to the editor files path; it should preferably be an absolute path, like in '/htmlarea/', but it can be relative if you prefer.  Further we will try to load the editor files correctly but we'll probably fail.");_editor_url='';}
if(typeof _editor_lang=="string")
{_editor_lang=_editor_lang.toLowerCase();}
else
{_editor_lang="en";}
if(typeof _editor_skin!=="string")
{_editor_skin="";}
var __xinhas=[];Xinha.agt=navigator.userAgent.toLowerCase();Xinha.is_ie=((Xinha.agt.indexOf("msie")!=-1)&&(Xinha.agt.indexOf("opera")==-1));Xinha.is_opera=(Xinha.agt.indexOf("opera")!=-1);Xinha.is_mac=(Xinha.agt.indexOf("mac")!=-1);Xinha.is_mac_ie=(Xinha.is_ie&&Xinha.is_mac);Xinha.is_win_ie=(Xinha.is_ie&&!Xinha.is_mac);Xinha.is_gecko=(navigator.product=="Gecko");Xinha.isRunLocally=document.URL.toLowerCase().search(/^file:/)!=-1;if(Xinha.isRunLocally)
{alert('Xinha *must* be installed on a web server. Locally opened files (those that use the "file://" protocol) cannot properly function. Xinha will try to initialize but may not be correctly loaded.');}
function Xinha(textarea,config)
{if(!textarea)
{throw("Tried to create Xinha without textarea specified.");}
if(Xinha.checkSupportedBrowser())
{if(typeof config=="undefined")
{this.config=new Xinha.Config();}
else
{this.config=config;}
this._htmlArea=null;if(typeof textarea!='object')
{textarea=Xinha.getElementById('textarea',textarea);}
this._textArea=textarea;this._textArea.spellcheck=false;this._initial_ta_size={w:textarea.style.width?textarea.style.width:(textarea.offsetWidth?(textarea.offsetWidth+'px'):(textarea.cols+'em')),h:textarea.style.height?textarea.style.height:(textarea.offsetHeight?(textarea.offsetHeight+'px'):(textarea.rows+'em'))};if(this.config.showLoading)
{var loading_message=document.createElement("div");loading_message.id="loading_"+textarea.name;loading_message.className="loading";try
{loading_message.style.width=textarea.offsetWidth+'px';}
catch(ex)
{loading_message.style.width=this._initial_ta_size.w;}
loading_message.style.left=Xinha.findPosX(textarea)+'px';loading_message.style.top=(Xinha.findPosY(textarea)+parseInt(this._initial_ta_size.h,10)/2)+'px';var loading_main=document.createElement("div");loading_main.className="loading_main";loading_main.id="loading_main_"+textarea.name;loading_main.appendChild(document.createTextNode(Xinha._lc("Loading in progress. Please wait !")));var loading_sub=document.createElement("div");loading_sub.className="loading_sub";loading_sub.id="loading_sub_"+textarea.name;loading_sub.appendChild(document.createTextNode(Xinha._lc("Constructing main object")));loading_message.appendChild(loading_main);loading_message.appendChild(loading_sub);document.body.appendChild(loading_message);this.setLoadingMessage("Constructing object");}
this._editMode="wysiwyg";this.plugins={};this._timerToolbar=null;this._timerUndo=null;this._undoQueue=[this.config.undoSteps];this._undoPos=-1;this._customUndo=true;this._mdoc=document;this.doctype='';this.__htmlarea_id_num=__xinhas.length;__xinhas[this.__htmlarea_id_num]=this;this._notifyListeners={};var panels={right:{on:true,container:document.createElement('td'),panels:[]},left:{on:true,container:document.createElement('td'),panels:[]},top:{on:true,container:document.createElement('td'),panels:[]},bottom:{on:true,container:document.createElement('td'),panels:[]}};for(var i in panels)
{if(!panels[i].container){continue;}
panels[i].div=panels[i].container;panels[i].container.className='panels '+i;Xinha.freeLater(panels[i],'container');Xinha.freeLater(panels[i],'div');}
this._panels=panels;Xinha.freeLater(this,'_textArea');}}
Xinha.onload=function(){};Xinha.init=function(){Xinha.onload();};Xinha.RE_tagName=/(<\/|<)\s*([^ \t\n>]+)/ig;Xinha.RE_doctype=/(<!doctype((.|\n)*?)>)\n?/i;Xinha.RE_head=/<head>((.|\n)*?)<\/head>/i;Xinha.RE_body=/<body[^>]*>((.|\n|\r|\t)*?)<\/body>/i;Xinha.RE_Specials=/([\/\^$*+?.()|{}[\]])/g;Xinha.RE_email=/[_a-zA-Z\d\-\.]{3,}@[_a-zA-Z\d\-]{2,}(\.[_a-zA-Z\d\-]{2,})+/i;Xinha.RE_url=/(https?:\/\/)?(([a-z0-9_]+:[a-z0-9_]+@)?[a-z0-9_-]{2,}(\.[a-z0-9_-]{2,}){2,}(:[0-9]+)?(\/\S+)*)/i;Xinha.Config=function()
{var cfg=this;this.version=Xinha.version.Revision;this.width="auto";this.height="auto";this.sizeIncludesBars=true;this.sizeIncludesPanels=true;this.panel_dimensions={left:'200px',right:'200px',top:'100px',bottom:'100px'};this.statusBar=true;this.htmlareaPaste=false;this.mozParaHandler='best';this.getHtmlMethod='DOMwalk';this.undoSteps=20;this.undoTimeout=500;this.changeJustifyWithDirection=false;this.fullPage=false;this.pageStyle="";this.pageStyleSheets=[];this.baseHref=null;this.expandRelativeUrl=true;this.stripBaseHref=true;this.stripSelfNamedAnchors=true;this.only7BitPrintablesInURLs=true;this.sevenBitClean=false;this.specialReplacements={};this.killWordOnPaste=true;this.makeLinkShowsTarget=true;this.charSet=Xinha.is_gecko?document.characterSet:document.charset;this.imgURL="images/";this.popupURL="popups/";this.htmlRemoveTags=null;this.flowToolbars=true;this.showLoading=false;this.stripScripts=true;this.convertUrlsToLinks=true;this.colorPickerCellSize='6px';this.colorPickerGranularity=18;this.colorPickerPosition='bottom,right';this.colorPickerWebSafe=false;this.colorPickerSaveColors=20;this.customSelects={};function cut_copy_paste(e,cmd,obj){e.execCommand(cmd);}
this.debug=true;this.URIs={"blank":"popups/blank.html","link":_editor_url+"modules/CreateLink/link.html","insert_image":_editor_url+"modules/InsertImage/insert_image.html","insert_table":_editor_url+"modules/InsertTable/insert_table.html","select_color":"select_color.html","about":"about.html","help":"editor_help.html"};this.btnList={createlink:["Insert Web Link","link-button-small.gif",false,function(e){e._createLink();}],bold:["Bold","bold-button-small.gif",false,function(e){e.execCommand("bold");}],italic:["Italic","italic-button-small.gif",false,function(e){e.execCommand("italic");}],insertunorderedlist:["Bulleted List","list-button-small.gif",false,function(e){e.execCommand("insertunorderedlist");}],highlight:["Highlight Text","color-button-small.gif",false,function(e){e.execCommand("highlight");}],inserthorizontalrule:["Horizontal Rule","hr.gif",false,function(e){e.execCommand("inserthorizontalrule");}]};for(var i in this.btnList)
{var btn=this.btnList[i];if(typeof btn!='object')
{continue;}
if(typeof btn[1]!='string')
{btn[1][0]=_editor_url+this.imgURL+btn[1][0];}
else
{btn[1]=_editor_url+this.imgURL+btn[1];}
btn[0]=Xinha._lc(btn[0]);}};Xinha.Config.prototype.registerButton=function(id,tooltip,image,textMode,action,context)
{var the_id;if(typeof id=="string")
{the_id=id;}
else if(typeof id=="object")
{the_id=id.id;}
else
{alert("ERROR [Xinha.Config::registerButton]:\ninvalid arguments");return false;}
switch(typeof id)
{case"string":this.btnList[id]=[tooltip,image,textMode,action,context];break;case"object":this.btnList[id.id]=[id.tooltip,id.image,id.textMode,id.action,id.context];break;}};Xinha.prototype.registerPanel=function(side,object)
{if(!side)
{side='right';}
this.setLoadingMessage('Register panel '+side);var panel=this.addPanel(side);if(object)
{object.drawPanelIn(panel);}};Xinha.Config.prototype.registerDropdown=function(object)
{this.customSelects[object.id]=object;};Xinha.Config.prototype.hideSomeButtons=function(remove)
{var toolbar=this.toolbar;for(var i=toolbar.length;--i>=0;)
{var line=toolbar[i];for(var j=line.length;--j>=0;)
{if(remove.indexOf(" "+line[j]+" ")>=0)
{var len=1;if(/separator|space/.test(line[j+1]))
{len=2;}
line.splice(j,len);}}}};Xinha.Config.prototype.addToolbarElement=function(id,where,position)
{var toolbar=this.toolbar;var a,i,j,o,sid;var idIsArray=false;var whereIsArray=false;var whereLength=0;var whereJ=0;var whereI=0;var exists=false;var found=false;if((id&&typeof id=="object")&&(id.constructor==Array))
{idIsArray=true;}
if((where&&typeof where=="object")&&(where.constructor==Array))
{whereIsArray=true;whereLength=where.length;}
if(idIsArray)
{for(i=0;i<id.length;++i)
{if((id[i]!="separator")&&(id[i].indexOf("T[")!==0))
{sid=id[i];}}}
else
{sid=id;}
for(i=0;!exists&&!found&&i<toolbar.length;++i)
{a=toolbar[i];for(j=0;!found&&j<a.length;++j)
{if(a[i]==sid)
{exists=true;break;}
if(whereIsArray)
{for(o=0;o<whereLength;++o)
{if(a[j]==where[o])
{if(o===0)
{found=true;j--;break;}
else
{whereI=i;whereJ=j;whereLength=o;}}}}
else
{if(a[j]==where)
{found=true;break;}}}}
if(!exists)
{if(!found&&whereIsArray)
{if(where.length!=whereLength)
{j=whereJ;a=toolbar[whereI];found=true;}}
if(found)
{if(position===0)
{if(idIsArray)
{a[j]=id[id.length-1];for(i=id.length-1;--i>=0;)
{a.splice(j,0,id[i]);}}
else
{a[j]=id;}}
else
{if(position<0)
{j=j+position+1;}
else if(position>0)
{j=j+position;}
if(idIsArray)
{for(i=id.length;--i>=0;)
{a.splice(j,0,id[i]);}}
else
{a.splice(j,0,id);}}}
else
{toolbar[0].splice(0,0,"separator");if(idIsArray)
{for(i=id.length;--i>=0;)
{toolbar[0].splice(0,0,id[i]);}}
else
{toolbar[0].splice(0,0,id);}}}};Xinha.Config.prototype.removeToolbarElement=Xinha.Config.prototype.hideSomeButtons;Xinha.replaceAll=function(config)
{var tas=document.getElementsByTagName("textarea");for(var i=tas.length;i>0;(new Xinha(tas[--i],config)).generate())
{}};Xinha.replace=function(id,config)
{var ta=Xinha.getElementById("textarea",id);return ta?(new Xinha(ta,config)).generate():null;};Xinha.prototype._createToolbar=function()
{this.setLoadingMessage('Create Toolbar');var editor=this;var toolbar=document.createElement("div");this._toolBar=this._toolbar=toolbar;toolbar.className="toolbar";toolbar.unselectable="1";Xinha.freeLater(this,'_toolBar');Xinha.freeLater(this,'_toolbar');var tb_row=null;var tb_objects={};this._toolbarObjects=tb_objects;this._createToolbar1(editor,toolbar,tb_objects);this._htmlArea.appendChild(toolbar);return toolbar;};Xinha.prototype._setConfig=function(config)
{this.config=config;};Xinha.prototype._addToolbar=function()
{this._createToolbar1(this,this._toolbar,this._toolbarObjects);};Xinha._createToolbarBreakingElement=function()
{var brk=document.createElement('div');brk.style.height='1px';brk.style.width='1px';brk.style.lineHeight='1px';brk.style.fontSize='1px';brk.style.clear='both';return brk;};Xinha.prototype._createToolbar1=function(editor,toolbar,tb_objects)
{var tb_row;if(editor.config.flowToolbars)
{toolbar.appendChild(Xinha._createToolbarBreakingElement());}
function newLine()
{if(typeof tb_row!='undefined'&&tb_row.childNodes.length===0)
{return;}
var table=document.createElement("table");table.border="0px";table.cellSpacing="0px";table.cellPadding="0px";if(editor.config.flowToolbars)
{if(Xinha.is_ie)
{table.style.styleFloat="left";}
else
{table.style.cssFloat="left";}}
toolbar.appendChild(table);var tb_body=document.createElement("tbody");table.appendChild(tb_body);tb_row=document.createElement("tr");tb_body.appendChild(tb_row);table.className='toolbarRow';}
newLine();function setButtonStatus(id,newval)
{var oldval=this[id];var el=this.element;if(oldval!=newval)
{switch(id)
{case"enabled":if(newval)
{Xinha._removeClass(el,"buttonDisabled");el.disabled=false;}
else
{Xinha._addClass(el,"buttonDisabled");el.disabled=true;}
break;case"active":if(newval)
{Xinha._addClass(el,"buttonPressed");}
else
{Xinha._removeClass(el,"buttonPressed");}
break;}
this[id]=newval;}}
function createSelect(txt)
{var options=null;var el=null;var cmd=null;var customSelects=editor.config.customSelects;var context=null;var tooltip="";switch(txt)
{case"fontsize":case"fontname":case"formatblock":options=editor.config[txt];cmd=txt;break;default:cmd=txt;var dropdown=customSelects[cmd];if(typeof dropdown!="undefined")
{options=dropdown.options;context=dropdown.context;if(typeof dropdown.tooltip!="undefined")
{tooltip=dropdown.tooltip;}}
else
{alert("ERROR [createSelect]:\nCan't find the requested dropdown definition");}
break;}
if(options)
{el=document.createElement("select");el.title=tooltip;var obj={name:txt,element:el,enabled:true,text:false,cmd:cmd,state:setButtonStatus,context:context};Xinha.freeLater(obj);tb_objects[txt]=obj;for(var i in options)
{if(typeof(options[i])!='string')
{continue;}
var op=document.createElement("option");op.innerHTML=Xinha._lc(i);op.value=options[i];el.appendChild(op);}
Xinha._addEvent(el,"change",function(){editor._comboSelected(el,txt);});}
return el;}
function createButton(txt)
{var el,btn,obj=null;switch(txt)
{case"separator":if(editor.config.flowToolbars)
{newLine();}
el=document.createElement("div");el.className="separator";break;case"space":el=document.createElement("div");el.className="space";break;case"linebreak":newLine();return false;case"textindicator":el=document.createElement("div");el.appendChild(document.createTextNode("A"));el.className="indicator";el.title=Xinha._lc("Current style");obj={name:txt,element:el,enabled:true,active:false,text:false,cmd:"textindicator",state:setButtonStatus};Xinha.freeLater(obj);tb_objects[txt]=obj;break;default:btn=editor.config.btnList[txt];}
if(!el&&btn)
{el=document.createElement("a");el.style.display='block';el.href='javascript:void(0)';el.style.textDecoration='none';el.title=btn[0];el.className="button";el.style.direction="ltr";obj={name:txt,element:el,enabled:true,active:false,text:btn[2],cmd:btn[3],state:setButtonStatus,context:btn[4]||null};Xinha.freeLater(el);Xinha.freeLater(obj);tb_objects[txt]=obj;el.ondrag=function(){return false;};Xinha._addEvent(el,"mouseout",function(ev)
{if(obj.enabled)
{Xinha._removeClass(el,"buttonActive");if(obj.active)
{Xinha._addClass(el,"buttonPressed");}}});Xinha._addEvent(el,"mousedown",function(ev)
{if(obj.enabled)
{Xinha._addClass(el,"buttonActive");Xinha._removeClass(el,"buttonPressed");Xinha._stopEvent(Xinha.is_ie?window.event:ev);}});Xinha._addEvent(el,"click",function(ev)
{if(obj.enabled)
{Xinha._removeClass(el,"buttonActive");if(Xinha.is_gecko)
{editor.activateEditor();}
obj.cmd(editor,obj.name,obj);Xinha._stopEvent(Xinha.is_ie?window.event:ev);}});var i_contain=Xinha.makeBtnImg(btn[1]);var img=i_contain.firstChild;el.appendChild(i_contain);obj.imgel=img;obj.swapImage=function(newimg)
{if(typeof newimg!='string')
{img.src=newimg[0];img.style.position='relative';img.style.top=newimg[2]?('-'+(18*(newimg[2]+1))+'px'):'-18px';img.style.left=newimg[1]?('-'+(18*(newimg[1]+1))+'px'):'-18px';}
else
{obj.imgel.src=newimg;img.style.top='0px';img.style.left='0px';}};}
else if(!el)
{el=createSelect(txt);}
return el;}
var first=true;for(var i=0;i<this.config.toolbar.length;++i)
{if(!first)
{}
else
{first=false;}
if(this.config.toolbar[i]===null)
{this.config.toolbar[i]=['separator'];}
var group=this.config.toolbar[i];for(var j=0;j<group.length;++j)
{var code=group[j];var tb_cell;if(/^([IT])\[(.*?)\]/.test(code))
{var l7ed=RegExp.$1=="I";var label=RegExp.$2;if(l7ed)
{label=Xinha._lc(label);}
tb_cell=document.createElement("td");tb_row.appendChild(tb_cell);tb_cell.className="label";tb_cell.innerHTML=label;}
else if(typeof code!='function')
{var tb_element=createButton(code);if(tb_element)
{tb_cell=document.createElement("td");tb_cell.className='toolbarElement';tb_row.appendChild(tb_cell);tb_cell.appendChild(tb_element);}
else if(tb_element===null)
{alert("FIXME: Unknown toolbar item: "+code);}}}}
if(editor.config.flowToolbars)
{toolbar.appendChild(Xinha._createToolbarBreakingElement());}
return toolbar;};var use_clone_img=false;Xinha.makeBtnImg=function(imgDef,doc)
{if(!doc)
{doc=document;}
if(!doc._xinhaImgCache)
{doc._xinhaImgCache={};Xinha.freeLater(doc._xinhaImgCache);}
var i_contain=null;if(Xinha.is_ie&&((!doc.compatMode)||(doc.compatMode&&doc.compatMode=="BackCompat")))
{i_contain=doc.createElement('span');}
else
{i_contain=doc.createElement('div');i_contain.style.position='relative';}
i_contain.style.overflow='hidden';i_contain.className='buttonImageContainer';var img=null;if(typeof imgDef=='string')
{if(doc._xinhaImgCache[imgDef])
{img=doc._xinhaImgCache[imgDef].cloneNode();}
else
{img=doc.createElement("img");img.src=imgDef;if(use_clone_img)
{doc._xinhaImgCache[imgDef]=img.cloneNode();}}}
else
{if(doc._xinhaImgCache[imgDef[0]])
{img=doc._xinhaImgCache[imgDef[0]].cloneNode();}
else
{img=doc.createElement("img");img.src=imgDef[0];img.style.position='relative';if(use_clone_img)
{doc._xinhaImgCache[imgDef[0]]=img.cloneNode();}}
img.style.top=imgDef[2]?('-'+(18*(imgDef[2]+1))+'px'):'-18px';img.style.left=imgDef[1]?('-'+(18*(imgDef[1]+1))+'px'):'-18px';}
i_contain.appendChild(img);return i_contain;};Xinha.prototype._createStatusBar=function()
{this.setLoadingMessage('Create StatusBar');var statusbar=document.createElement("div");statusbar.className="statusBar";this._statusBar=statusbar;Xinha.freeLater(this,'_statusBar');var div=document.createElement("span");div.className="statusBarTree";div.innerHTML=Xinha._lc("Path")+": ";this._statusBarTree=div;Xinha.freeLater(this,'_statusBarTree');this._statusBar.appendChild(div);div=document.createElement("span");div.innerHTML=Xinha._lc("You are in TEXT MODE.  Use the [<>] button to switch back to WYSIWYG.");div.style.display="none";this._statusBarTextMode=div;Xinha.freeLater(this,'_statusBarTextMode');this._statusBar.appendChild(div);if(!this.config.statusBar)
{statusbar.style.display="none";}
return statusbar;};Xinha.prototype.generate=function()
{var i;var editor=this;if(Xinha.is_ie)
{if(typeof InternetExplorer=='undefined')
{Xinha.loadPlugin("InternetExplorer",function(){editor.generate();},_editor_url+'modules/InternetExplorer/InternetExplorer.js');return false;}
editor._browserSpecificPlugin=editor.registerPlugin('InternetExplorer');}
else
{if(typeof Gecko=='undefined')
{Xinha.loadPlugin("Gecko",function(){editor.generate();},_editor_url+'modules/Gecko/Gecko.js');return false;}
editor._browserSpecificPlugin=editor.registerPlugin('Gecko');}
this.setLoadingMessage('Generate Xinha object');if(typeof Dialog=='undefined')
{Xinha._loadback(_editor_url+'modules/Dialogs/dialog.js',this.generate,this);return false;}
if(typeof Xinha.Dialog=='undefined')
{Xinha._loadback(_editor_url+'modules/Dialogs/inline-dialog.js',this.generate,this);return false;}
var toolbar=editor.config.toolbar;for(i=toolbar.length;--i>=0;)
{for(var j=toolbar[i].length;--j>=0;)
{switch(toolbar[i][j])
{case"popupeditor":if(typeof FullScreen=="undefined")
{Xinha.loadPlugin("FullScreen",function(){editor.generate();},_editor_url+'modules/FullScreen/full-screen.js');return false;}
editor.registerPlugin('FullScreen');break;case"insertimage":if(typeof InsertImage=='undefined'&&typeof Xinha.prototype._insertImage=='undefined')
{Xinha.loadPlugin("InsertImage",function(){editor.generate();},_editor_url+'modules/InsertImage/insert_image.js');return false;}
else if(typeof InsertImage!='undefined')editor.registerPlugin('InsertImage');break;case"createlink":if(typeof CreateLink=='undefined'&&typeof Xinha.prototype._createLink=='undefined'&&typeof Linker=='undefined')
{Xinha.loadPlugin("CreateLink",function(){editor.generate();},_editor_url+'modules/CreateLink/link.js');return false;}
else if(typeof CreateLink!='undefined')editor.registerPlugin('CreateLink');break;case"inserttable":if(typeof InsertTable=='undefined'&&typeof Xinha.prototype._insertTable=='undefined')
{Xinha.loadPlugin("InsertTable",function(){editor.generate();},_editor_url+'modules/InsertTable/insert_table.js');return false;}
else if(typeof InsertTable!='undefined')editor.registerPlugin('InsertTable');break;case"hilitecolor":case"forecolor":if(typeof ColorPicker=='undefined')
{Xinha.loadPlugin("ColorPicker",function(){editor.generate();},_editor_url+'modules/ColorPicker/ColorPicker.js');return false;}
else if(typeof ColorPicker!='undefined')editor.registerPlugin('ColorPicker');break;}}}
if(Xinha.is_gecko&&(editor.config.mozParaHandler=='best'||editor.config.mozParaHandler=='dirty'))
{switch(this.config.mozParaHandler)
{case'dirty':var ParaHandlerPlugin=_editor_url+'modules/Gecko/paraHandlerDirty.js';break;default:var ParaHandlerPlugin=_editor_url+'modules/Gecko/paraHandlerBest.js';break;}
if(typeof EnterParagraphs=='undefined')
{Xinha.loadPlugin("EnterParagraphs",function(){editor.generate();},ParaHandlerPlugin);return false;}
editor.registerPlugin('EnterParagraphs');}
switch(this.config.getHtmlMethod)
{case'TransformInnerHTML':var getHtmlMethodPlugin=_editor_url+'modules/GetHtml/TransformInnerHTML.js';break;default:var getHtmlMethodPlugin=_editor_url+'modules/GetHtml/DOMwalk.js';break;}
if(typeof GetHtmlImplementation=='undefined')
{Xinha.loadPlugin("GetHtmlImplementation",function(){editor.generate();},getHtmlMethodPlugin);return false;}
else editor.registerPlugin('GetHtmlImplementation');if(_editor_skin!=="")
{var found=false;var head=document.getElementsByTagName("head")[0];var links=document.getElementsByTagName("link");for(i=0;i<links.length;i++)
{if((links[i].rel=="stylesheet")&&(links[i].href==_editor_url+'skins/'+_editor_skin+'/skin.css'))
{found=true;}}
if(!found)
{var link=document.createElement("link");link.type="text/css";link.href=_editor_url+'skins/'+_editor_skin+'/skin.css';link.rel="stylesheet";head.appendChild(link);}}
this._framework={'table':document.createElement('table'),'tbody':document.createElement('tbody'),'tb_row':document.createElement('tr'),'tb_cell':document.createElement('td'),'tp_row':document.createElement('tr'),'tp_cell':this._panels.top.container,'ler_row':document.createElement('tr'),'lp_cell':this._panels.left.container,'ed_cell':document.createElement('td'),'rp_cell':this._panels.right.container,'bp_row':document.createElement('tr'),'bp_cell':this._panels.bottom.container,'sb_row':document.createElement('tr'),'sb_cell':document.createElement('td')};Xinha.freeLater(this._framework);var fw=this._framework;fw.table.border="0";fw.table.cellPadding="0";fw.table.cellSpacing="0";fw.tb_row.style.verticalAlign='top';fw.tp_row.style.verticalAlign='top';fw.ler_row.style.verticalAlign='top';fw.bp_row.style.verticalAlign='top';fw.sb_row.style.verticalAlign='top';fw.ed_cell.style.position='relative';fw.tb_row.appendChild(fw.tb_cell);fw.tb_cell.colSpan=3;fw.tp_row.appendChild(fw.tp_cell);fw.tp_cell.colSpan=3;fw.ler_row.appendChild(fw.lp_cell);fw.ler_row.appendChild(fw.ed_cell);fw.ler_row.appendChild(fw.rp_cell);fw.bp_row.appendChild(fw.bp_cell);fw.bp_cell.colSpan=3;fw.sb_row.appendChild(fw.sb_cell);fw.sb_cell.colSpan=3;fw.tbody.appendChild(fw.tb_row);fw.tbody.appendChild(fw.tp_row);fw.tbody.appendChild(fw.ler_row);fw.tbody.appendChild(fw.bp_row);fw.tbody.appendChild(fw.sb_row);fw.table.appendChild(fw.tbody);var xinha=this._framework.table;this._htmlArea=xinha;Xinha.freeLater(this,'_htmlArea');xinha.className="htmlarea";this._framework.tb_cell.appendChild(this._createToolbar());var iframe=document.createElement("iframe");iframe.src=_editor_url+editor.config.URIs.blank;this._framework.ed_cell.appendChild(iframe);this._iframe=iframe;this._iframe.className='xinha_iframe';Xinha.freeLater(this,'_iframe');var statusbar=this._createStatusBar();this._framework.sb_cell.appendChild(statusbar);var textarea=this._textArea;textarea.parentNode.insertBefore(xinha,textarea);textarea.className='xinha_textarea';Xinha.removeFromParent(textarea);this._framework.ed_cell.appendChild(textarea);if(textarea.form)
{Xinha.prependDom0Event(this._textArea.form,'submit',function()
{var s=editor.outwardHtml(editor.getHTML());alert(s);editor._textArea.value=editor.getStxFromHtml(editor.outwardHtml(editor.getHTML()));return true;});var initialTAContent=textarea.value;Xinha.prependDom0Event(this._textArea.form,'reset',function()
{editor.setHTML(editor.inwardHtml(initialTAContent));editor.updateToolbar();return true;});}
Xinha.prependDom0Event(window,'unload',function()
{textarea.value=editor.outwardHtml(editor.getHTML());return true;});textarea.style.display="none";editor.initSize();editor._iframeLoadDone=false;Xinha._addEvent(this._iframe,'load',function(e)
{if(!editor._iframeLoadDone)
{editor._iframeLoadDone=true;editor.initIframe();}
return true;});};Xinha.prototype.initSize=function()
{this.setLoadingMessage('Init editor size');var editor=this;var width=null;var height=null;switch(this.config.width)
{case'auto':width=this._initial_ta_size.w;break;case'toolbar':width=this._toolBar.offsetWidth+'px';break;default:width=/[^0-9]/.test(this.config.width)?this.config.width:this.config.width+'px';break;}
switch(this.config.height)
{case'auto':height=this._initial_ta_size.h;break;default:height=/[^0-9]/.test(this.config.height)?this.config.height:this.config.height+'px';break;}
this.sizeEditor(width,height,this.config.sizeIncludesBars,this.config.sizeIncludesPanels);this.notifyOn('panel_change',function(){editor.sizeEditor();});};Xinha.prototype.sizeEditor=function(width,height,includingBars,includingPanels)
{this._iframe.style.height='100%';this._textArea.style.height='100%';this._iframe.style.width='';this._textArea.style.width='';if(includingBars!==null)
{this._htmlArea.sizeIncludesToolbars=includingBars;}
if(includingPanels!==null)
{this._htmlArea.sizeIncludesPanels=includingPanels;}
if(width)
{this._htmlArea.style.width=width;if(!this._htmlArea.sizeIncludesPanels)
{var rPanel=this._panels.right;if(rPanel.on&&rPanel.panels.length&&Xinha.hasDisplayedChildren(rPanel.div))
{this._htmlArea.style.width=(this._htmlArea.offsetWidth+parseInt(this.config.panel_dimensions.right,10))+'px';}
var lPanel=this._panels.left;if(lPanel.on&&lPanel.panels.length&&Xinha.hasDisplayedChildren(lPanel.div))
{this._htmlArea.style.width=(this._htmlArea.offsetWidth+parseInt(this.config.panel_dimensions.left,10))+'px';}}}
if(height)
{this._htmlArea.style.height=height;if(!this._htmlArea.sizeIncludesToolbars)
{this._htmlArea.style.height=(this._htmlArea.offsetHeight+this._toolbar.offsetHeight+this._statusBar.offsetHeight)+'px';}
if(!this._htmlArea.sizeIncludesPanels)
{var tPanel=this._panels.top;if(tPanel.on&&tPanel.panels.length&&Xinha.hasDisplayedChildren(tPanel.div))
{this._htmlArea.style.height=(this._htmlArea.offsetHeight+parseInt(this.config.panel_dimensions.top,10))+'px';}
var bPanel=this._panels.bottom;if(bPanel.on&&bPanel.panels.length&&Xinha.hasDisplayedChildren(bPanel.div))
{this._htmlArea.style.height=(this._htmlArea.offsetHeight+parseInt(this.config.panel_dimensions.bottom,10))+'px';}}}
width=this._htmlArea.offsetWidth;height=this._htmlArea.offsetHeight;var panels=this._panels;var editor=this;var col_span=1;function panel_is_alive(pan)
{if(panels[pan].on&&panels[pan].panels.length&&Xinha.hasDisplayedChildren(panels[pan].container))
{panels[pan].container.style.display='';return true;}
else
{panels[pan].container.style.display='none';return false;}}
if(panel_is_alive('left'))
{col_span+=1;}
if(panel_is_alive('right'))
{col_span+=1;}
this._framework.tb_cell.colSpan=col_span;this._framework.tp_cell.colSpan=col_span;this._framework.bp_cell.colSpan=col_span;this._framework.sb_cell.colSpan=col_span;if(!this._framework.tp_row.childNodes.length)
{Xinha.removeFromParent(this._framework.tp_row);}
else
{if(!Xinha.hasParentNode(this._framework.tp_row))
{this._framework.tbody.insertBefore(this._framework.tp_row,this._framework.ler_row);}}
if(!this._framework.bp_row.childNodes.length)
{Xinha.removeFromParent(this._framework.bp_row);}
else
{if(!Xinha.hasParentNode(this._framework.bp_row))
{this._framework.tbody.insertBefore(this._framework.bp_row,this._framework.ler_row.nextSibling);}}
if(!this.config.statusBar)
{Xinha.removeFromParent(this._framework.sb_row);}
else
{if(!Xinha.hasParentNode(this._framework.sb_row))
{this._framework.table.appendChild(this._framework.sb_row);}}
this._framework.lp_cell.style.width=this.config.panel_dimensions.left;this._framework.rp_cell.style.width=this.config.panel_dimensions.right;this._framework.tp_cell.style.height=this.config.panel_dimensions.top;this._framework.bp_cell.style.height=this.config.panel_dimensions.bottom;this._framework.tb_cell.style.height=this._toolBar.offsetHeight+'px';this._framework.sb_cell.style.height=this._statusBar.offsetHeight+'px';var edcellheight=height-this._toolBar.offsetHeight-this._statusBar.offsetHeight;if(panel_is_alive('top'))
{edcellheight-=parseInt(this.config.panel_dimensions.top,10);}
if(panel_is_alive('bottom'))
{edcellheight-=parseInt(this.config.panel_dimensions.bottom,10);}
this._iframe.style.height=edcellheight+'px';var edcellwidth=width;if(panel_is_alive('left'))
{edcellwidth-=parseInt(this.config.panel_dimensions.left,10);}
if(panel_is_alive('right'))
{edcellwidth-=parseInt(this.config.panel_dimensions.right,10);}
this._iframe.style.width=edcellwidth+'px';this._textArea.style.height=this._iframe.style.height;this._textArea.style.width=this._iframe.style.width;this.notifyOf('resize',{width:this._htmlArea.offsetWidth,height:this._htmlArea.offsetHeight});};Xinha.prototype.addPanel=function(side)
{var div=document.createElement('div');div.side=side;if(side=='left'||side=='right')
{div.style.width=this.config.panel_dimensions[side];if(this._iframe)div.style.height=this._iframe.style.height;}
Xinha.addClasses(div,'panel');this._panels[side].panels.push(div);this._panels[side].div.appendChild(div);this.notifyOf('panel_change',{'action':'add','panel':div});return div;};Xinha.prototype.removePanel=function(panel)
{this._panels[panel.side].div.removeChild(panel);var clean=[];for(var i=0;i<this._panels[panel.side].panels.length;i++)
{if(this._panels[panel.side].panels[i]!=panel)
{clean.push(this._panels[panel.side].panels[i]);}}
this._panels[panel.side].panels=clean;this.notifyOf('panel_change',{'action':'remove','panel':panel});};Xinha.prototype.hidePanel=function(panel)
{if(panel&&panel.style.display!='none')
{try{var pos=this.scrollPos(this._iframe.contentWindow);}catch(e){}
panel.style.display='none';this.notifyOf('panel_change',{'action':'hide','panel':panel});try{this._iframe.contentWindow.scrollTo(pos.x,pos.y)}catch(e){}}};Xinha.prototype.showPanel=function(panel)
{if(panel&&panel.style.display=='none')
{try{var pos=this.scrollPos(this._iframe.contentWindow);}catch(e){}
panel.style.display='';this.notifyOf('panel_change',{'action':'show','panel':panel});try{this._iframe.contentWindow.scrollTo(pos.x,pos.y)}catch(e){}}};Xinha.prototype.hidePanels=function(sides)
{if(typeof sides=='undefined')
{sides=['left','right','top','bottom'];}
var reShow=[];for(var i=0;i<sides.length;i++)
{if(this._panels[sides[i]].on)
{reShow.push(sides[i]);this._panels[sides[i]].on=false;}}
this.notifyOf('panel_change',{'action':'multi_hide','sides':sides});};Xinha.prototype.showPanels=function(sides)
{if(typeof sides=='undefined')
{sides=['left','right','top','bottom'];}
var reHide=[];for(var i=0;i<sides.length;i++)
{if(!this._panels[sides[i]].on)
{reHide.push(sides[i]);this._panels[sides[i]].on=true;}}
this.notifyOf('panel_change',{'action':'multi_show','sides':sides});};Xinha.objectProperties=function(obj)
{var props=[];for(var x in obj)
{props[props.length]=x;}
return props;};Xinha.prototype.editorIsActivated=function()
{try
{return Xinha.is_gecko?this._doc.designMode=='on':this._doc.body.contentEditable;}
catch(ex)
{return false;}};Xinha._someEditorHasBeenActivated=false;Xinha._currentlyActiveEditor=false;Xinha.prototype.activateEditor=function()
{if(Xinha._currentlyActiveEditor)
{if(Xinha._currentlyActiveEditor==this)
{return true;}
Xinha._currentlyActiveEditor.deactivateEditor();}
if(Xinha.is_gecko&&this._doc.designMode!='on')
{try
{if(this._iframe.style.display=='none')
{this._iframe.style.display='';this._doc.designMode='on';this._iframe.style.display='none';}
else
{this._doc.designMode='on';}}catch(ex){}}
else if(!Xinha.is_gecko&&this._doc.body.contentEditable!==true)
{this._doc.body.contentEditable=true;}
Xinha._someEditorHasBeenActivated=true;Xinha._currentlyActiveEditor=this;var editor=this;this.enableToolbar();};Xinha.prototype.deactivateEditor=function()
{this.disableToolbar();if(Xinha.is_gecko&&this._doc.designMode!='off')
{try
{this._doc.designMode='off';}catch(ex){}}
else if(!Xinha.is_gecko&&this._doc.body.contentEditable!==false)
{this._doc.body.contentEditable=false;}
if(Xinha._currentlyActiveEditor!=this)
{return;}
Xinha._currentlyActiveEditor=false;};Xinha.prototype.initIframe=function()
{this.setLoadingMessage('Init IFrame');this.disableToolbar();var doc=null;var editor=this;try
{if(editor._iframe.contentDocument)
{this._doc=editor._iframe.contentDocument;}
else
{this._doc=editor._iframe.contentWindow.document;}
doc=this._doc;if(!doc)
{if(Xinha.is_gecko)
{setTimeout(function(){editor.initIframe();},50);return false;}
else
{alert("ERROR: IFRAME can't be initialized.");}}}
catch(ex)
{setTimeout(function(){editor.initIframe();},50);}
Xinha.freeLater(this,'_doc');doc.open("text/html","replace");var html='';if(!editor.config.fullPage)
{html="<html>\n";html+="<head>\n";html+="<meta http-equiv=\"Content-Type\" content=\"text/html; charset="+editor.config.charSet+"\">\n";if(typeof editor.config.baseHref!='undefined'&&editor.config.baseHref!==null)
{html+="<base href=\""+editor.config.baseHref+"\"/>\n";}
html+=Xinha.addCoreCSS();if(editor.config.pageStyle)
{html+="<style type=\"text/css\">\n"+editor.config.pageStyle+"\n</style>";}
if(typeof editor.config.pageStyleSheets!=='undefined')
{for(var i=0;i<editor.config.pageStyleSheets.length;i++)
{if(editor.config.pageStyleSheets[i].length>0)
{html+="<link rel=\"stylesheet\" type=\"text/css\" href=\""+editor.config.pageStyleSheets[i]+"\">";}}}
html+="</head>\n";html+="<body>\n";html+=editor.inwardHtml(editor._textArea.value);html+="</body>\n";html+="</html>";}
else
{html=editor.inwardHtml(editor._textArea.value);if(html.match(Xinha.RE_doctype))
{editor.setDoctype(RegExp.$1);html=html.replace(Xinha.RE_doctype,"");}
var match=html.match(/<link\s+[\s\S]*?["']\s*\/?>/gi);html=html.replace(/<link\s+[\s\S]*?["']\s*\/?>\s*/gi,'');match?html=html.replace(/<\/head>/i,match.join('\n')+"\n</head>"):null;}
doc.write(html);doc.close();this.setEditorEvents();};Xinha.prototype.whenDocReady=function(F)
{var E=this;if(this._doc&&this._doc.body)
{F();}
else
{setTimeout(function(){E.whenDocReady(F);},50);}};Xinha.prototype.setMode=function(mode)
{var html;if(typeof mode=="undefined")
{mode=this._editMode=="textmode"?"wysiwyg":"textmode";}
switch(mode)
{case"textmode":this.setCC("iframe");html=this.outwardHtml(this.getHTML());this.setHTML(html);this.deactivateEditor();this._iframe.style.display='none';this._textArea.style.display='';if(this.config.statusBar)
{this._statusBarTree.style.display="none";this._statusBarTextMode.style.display="";}
this.notifyOf('modechange',{'mode':'text'});this.findCC("textarea");break;case"wysiwyg":this.setCC("textarea");html=this.inwardHtml(this.getHTML());this.deactivateEditor();this.setHTML(html);this._iframe.style.display='';this._textArea.style.display="none";this.activateEditor();if(this.config.statusBar)
{this._statusBarTree.style.display="";this._statusBarTextMode.style.display="none";}
this.notifyOf('modechange',{'mode':'wysiwyg'});this.findCC("iframe");break;default:alert("Mode <"+mode+"> not defined!");return false;}
this._editMode=mode;for(var i in this.plugins)
{var plugin=this.plugins[i].instance;if(plugin&&typeof plugin.onMode=="function")
{plugin.onMode(mode);}}};Xinha.prototype.setFullHTML=function(html)
{var save_multiline=RegExp.multiline;RegExp.multiline=true;if(html.match(Xinha.RE_doctype))
{this.setDoctype(RegExp.$1);html=html.replace(Xinha.RE_doctype,"");}
RegExp.multiline=save_multiline;if(!Xinha.is_ie)
{if(html.match(Xinha.RE_head))
{this._doc.getElementsByTagName("head")[0].innerHTML=RegExp.$1;}
if(html.match(Xinha.RE_body))
{this._doc.getElementsByTagName("body")[0].innerHTML=RegExp.$1;}}
else
{var reac=this.editorIsActivated();if(reac)
{this.deactivateEditor();}
var html_re=/<html>((.|\n)*?)<\/html>/i;html=html.replace(html_re,"$1");this._doc.open("text/html","replace");this._doc.write(html);this._doc.close();if(reac)
{this.activateEditor();}
this.setEditorEvents();return true;}};Xinha.prototype.setEditorEvents=function()
{var editor=this;var doc=this._doc;editor.whenDocReady(function()
{Xinha._addEvents(doc,["mousedown"],function()
{editor.activateEditor();return true;});Xinha._addEvents(doc,["keydown","keypress","mousedown","mouseup","drag"],function(event)
{return editor._editorEvent(Xinha.is_ie?editor._iframe.contentWindow.event:event);});for(var i in editor.plugins)
{var plugin=editor.plugins[i].instance;Xinha.refreshPlugin(plugin);}
if(typeof editor._onGenerate=="function")
{editor._onGenerate();}
Xinha.addDom0Event(window,'resize',function(e){editor.sizeEditor();});editor.removeLoadingMessage();});};Xinha.prototype.registerPlugin=function()
{var plugin=arguments[0];if(plugin===null||typeof plugin=='undefined'||(typeof plugin=='string'&&eval('typeof '+plugin)=='undefined'))
{return false;}
var args=[];for(var i=1;i<arguments.length;++i)
{args.push(arguments[i]);}
return this.registerPlugin2(plugin,args);};Xinha.prototype.registerPlugin2=function(plugin,args)
{if(typeof plugin=="string")
{plugin=eval(plugin);}
if(typeof plugin=="undefined")
{return false;}
var obj=new plugin(this,args);if(obj)
{var clone={};var info=plugin._pluginInfo;for(var i in info)
{clone[i]=info[i];}
clone.instance=obj;clone.args=args;this.plugins[plugin._pluginInfo.name]=clone;return obj;}
else
{alert("Can't register plugin "+plugin.toString()+".");}};Xinha.getPluginDir=function(pluginName)
{return _editor_url+"plugins/"+pluginName;};Xinha.loadPlugin=function(pluginName,callback,plugin_file)
{if(eval('typeof '+pluginName)!='undefined')
{if(callback)
{callback(pluginName);}
return true;}
if(!plugin_file)
{var dir=this.getPluginDir(pluginName);var plugin=pluginName.replace(/([a-z])([A-Z])([a-z])/g,function(str,l1,l2,l3){return l1+"-"+l2.toLowerCase()+l3;}).toLowerCase()+".js";plugin_file=dir+"/"+plugin;}
Xinha._loadback(plugin_file,callback?function(){callback(pluginName);}:null);return false;};Xinha._pluginLoadStatus={};Xinha.loadPlugins=function(plugins,callbackIfNotReady)
{var retVal=true;var nuPlugins=Xinha.cloneObject(plugins);while(nuPlugins.length)
{var p=nuPlugins.pop();if(typeof Xinha._pluginLoadStatus[p]=='undefined')
{Xinha._pluginLoadStatus[p]='loading';Xinha.loadPlugin(p,function(plugin)
{if(eval('typeof '+plugin)!='undefined')
{Xinha._pluginLoadStatus[plugin]='ready';}
else
{Xinha._pluginLoadStatus[plugin]='failed';}});retVal=false;}
else
{switch(Xinha._pluginLoadStatus[p])
{case'failed':case'ready':break;default:retVal=false;break;}}}
if(retVal)
{return true;}
if(callbackIfNotReady)
{setTimeout(function(){if(Xinha.loadPlugins(plugins,callbackIfNotReady)){callbackIfNotReady();}},150);}
return retVal;};Xinha.refreshPlugin=function(plugin)
{if(plugin&&typeof plugin.onGenerate=="function")
{plugin.onGenerate();}
if(plugin&&typeof plugin.onGenerateOnce=="function")
{plugin.onGenerateOnce();plugin.onGenerateOnce=null;}};Xinha.prototype.firePluginEvent=function(methodName)
{var argsArray=[];for(var i=1;i<arguments.length;i++)
{argsArray[i-1]=arguments[i];}
for(var i in this.plugins)
{var plugin=this.plugins[i].instance;if(plugin==this._browserSpecificPlugin)continue;if(plugin&&typeof plugin[methodName]=="function")
{if(plugin[methodName].apply(plugin,argsArray))
{return true;}}}
var plugin=this._browserSpecificPlugin;if(plugin&&typeof plugin[methodName]=="function")
{if(plugin[methodName].apply(plugin,argsArray))
{return true;}}
return false;}
Xinha.loadStyle=function(style,plugin)
{var url=_editor_url||'';if(typeof plugin!="undefined")
{url+="plugins/"+plugin+"/";}
url+=style;if(/^\//.test(style))
{url=style;}
var head=document.getElementsByTagName("head")[0];var link=document.createElement("link");link.rel="stylesheet";link.href=url;head.appendChild(link);};Xinha.loadStyle(typeof _editor_css=="string"?_editor_css:"Xinha.css");Xinha.prototype.debugTree=function()
{var ta=document.createElement("textarea");ta.style.width="100%";ta.style.height="20em";ta.value="";function debug(indent,str)
{for(;--indent>=0;)
{ta.value+=" ";}
ta.value+=str+"\n";}
function _dt(root,level)
{var tag=root.tagName.toLowerCase(),i;var ns=Xinha.is_ie?root.scopeName:root.prefix;debug(level,"- "+tag+" ["+ns+"]");for(i=root.firstChild;i;i=i.nextSibling)
{if(i.nodeType==1)
{_dt(i,level+2);}}}
_dt(this._doc.body,0);document.body.appendChild(ta);};Xinha.getInnerText=function(el)
{var txt='',i;for(i=el.firstChild;i;i=i.nextSibling)
{if(i.nodeType==3)
{txt+=i.data;}
else if(i.nodeType==1)
{txt+=Xinha.getInnerText(i);}}
return txt;};Xinha.prototype._wordClean=function()
{var editor=this;var stats={empty_tags:0,mso_class:0,mso_style:0,mso_xmlel:0,orig_len:this._doc.body.innerHTML.length,T:(new Date()).getTime()};var stats_txt={empty_tags:"Empty tags removed: ",mso_class:"MSO class names removed: ",mso_style:"MSO inline style removed: ",mso_xmlel:"MSO XML elements stripped: "};function showStats()
{var txt="Xinha word cleaner stats: \n\n";for(var i in stats)
{if(stats_txt[i])
{txt+=stats_txt[i]+stats[i]+"\n";}}
txt+="\nInitial document length: "+stats.orig_len+"\n";txt+="Final document length: "+editor._doc.body.innerHTML.length+"\n";txt+="Clean-up took "+(((new Date()).getTime()-stats.T)/1000)+" seconds";alert(txt);}
function clearClass(node)
{var newc=node.className.replace(/(^|\s)mso.*?(\s|$)/ig,' ');if(newc!=node.className)
{node.className=newc;if(!(/\S/.test(node.className)))
{node.removeAttribute("className");++stats.mso_class;}}}
function clearStyle(node)
{var declarations=node.style.cssText.split(/\s*;\s*/);for(var i=declarations.length;--i>=0;)
{if((/^mso|^tab-stops/i.test(declarations[i]))||(/^margin\s*:\s*0..\s+0..\s+0../i.test(declarations[i])))
{++stats.mso_style;declarations.splice(i,1);}}
node.style.cssText=declarations.join("; ");}
var stripTag=null;if(Xinha.is_ie)
{stripTag=function(el)
{el.outerHTML=Xinha.htmlEncode(el.innerText);++stats.mso_xmlel;};}
else
{stripTag=function(el)
{var txt=document.createTextNode(Xinha.getInnerText(el));el.parentNode.insertBefore(txt,el);Xinha.removeFromParent(el);++stats.mso_xmlel;};}
function checkEmpty(el)
{if(/^(span|b|strong|i|em|font|div|p)$/i.test(el.tagName)&&!el.firstChild)
{Xinha.removeFromParent(el);++stats.empty_tags;}}
function parseTree(root)
{var tag=root.tagName.toLowerCase(),i,next;if((Xinha.is_ie&&root.scopeName!='HTML')||(!Xinha.is_ie&&(/:/.test(tag))))
{stripTag(root);return false;}
else
{clearClass(root);clearStyle(root);for(i=root.firstChild;i;i=next)
{next=i.nextSibling;if(i.nodeType==1&&parseTree(i))
{checkEmpty(i);}}}
return true;}
parseTree(this._doc.body);this.updateToolbar();};Xinha.prototype._clearFonts=function()
{var D=this.getInnerHTML();if(confirm(Xinha._lc("Would you like to clear font typefaces?")))
{D=D.replace(/face="[^"]*"/gi,'');D=D.replace(/font-family:[^;}"']+;?/gi,'');}
if(confirm(Xinha._lc("Would you like to clear font sizes?")))
{D=D.replace(/size="[^"]*"/gi,'');D=D.replace(/font-size:[^;}"']+;?/gi,'');}
if(confirm(Xinha._lc("Would you like to clear font colours?")))
{D=D.replace(/color="[^"]*"/gi,'');D=D.replace(/([^-])color:[^;}"']+;?/gi,'$1');}
D=D.replace(/(style|class)="\s*"/gi,'');D=D.replace(/<(font|span)\s*>/gi,'');this.setHTML(D);this.updateToolbar();};Xinha.prototype._splitBlock=function()
{this._doc.execCommand('formatblock',false,'div');};Xinha.prototype.forceRedraw=function()
{this._doc.body.style.visibility="hidden";this._doc.body.style.visibility="visible";};Xinha.prototype.focusEditor=function()
{switch(this._editMode)
{case"wysiwyg":try
{if(Xinha._someEditorHasBeenActivated)
{this.activateEditor();this._iframe.contentWindow.focus();}}catch(ex){}
break;case"textmode":try
{this._textArea.focus();}catch(e){}
break;default:alert("ERROR: mode "+this._editMode+" is not defined");}
return this._doc;};Xinha.prototype._undoTakeSnapshot=function()
{++this._undoPos;if(this._undoPos>=this.config.undoSteps)
{this._undoQueue.shift();--this._undoPos;}
var take=true;var txt=this.getInnerHTML();if(this._undoPos>0)
{take=(this._undoQueue[this._undoPos-1]!=txt);}
if(take)
{this._undoQueue[this._undoPos]=txt;}
else
{this._undoPos--;}};Xinha.prototype.undo=function()
{if(this._undoPos>0)
{var txt=this._undoQueue[--this._undoPos];if(txt)
{this.setHTML(txt);}
else
{++this._undoPos;}}};Xinha.prototype.redo=function()
{if(this._undoPos<this._undoQueue.length-1)
{var txt=this._undoQueue[++this._undoPos];if(txt)
{this.setHTML(txt);}
else
{--this._undoPos;}}};Xinha.prototype.disableToolbar=function(except)
{if(this._timerToolbar)
{clearTimeout(this._timerToolbar);}
if(typeof except=='undefined')
{except=[];}
else if(typeof except!='object')
{except=[except];}
for(var i in this._toolbarObjects)
{var btn=this._toolbarObjects[i];if(except.contains(i))
{continue;}
if(typeof(btn.state)!='function')
{continue;}
btn.state("enabled",false);}};Xinha.prototype.enableToolbar=function()
{this.updateToolbar();};if(!Array.prototype.contains)
{Array.prototype.contains=function(needle)
{var haystack=this;for(var i=0;i<haystack.length;i++)
{if(needle==haystack[i])
{return true;}}
return false;};}
if(!Array.prototype.indexOf)
{Array.prototype.indexOf=function(needle)
{var haystack=this;for(var i=0;i<haystack.length;i++)
{if(needle==haystack[i])
{return i;}}
return null;};}
Xinha.prototype.updateToolbar=function(noStatus)
{var doc=this._doc;var text=(this._editMode=="textmode");var ancestors=null;if(!text)
{ancestors=this.getAllAncestors();if(this.config.statusBar&&!noStatus)
{this._statusBarTree.innerHTML=Xinha._lc("Path")+": ";for(var i=ancestors.length;--i>=0;)
{var el=ancestors[i];if(!el)
{continue;}
var a=document.createElement("a");a.href="javascript:void(0)";a.el=el;a.editor=this;Xinha.addDom0Event(a,'click',function(){this.blur();this.editor.selectNodeContents(this.el);this.editor.updateToolbar(true);return false;});Xinha.addDom0Event(a,'contextmenu',function()
{this.blur();var info="Inline style:\n\n";info+=this.el.style.cssText.split(/;\s*/).join(";\n");alert(info);return false;});var txt=el.tagName.toLowerCase();switch(txt){case"h6":txt="code";break;case"span":txt="highlight";break;case"a":txt="link";break;case"b":txt="bold";break;case"i":txt="italic";break;case"u":txt="underline";break;}
if(typeof el.style!='undefined')a.title=el.style.cssText;if(el.id)
{txt+="#"+el.id;}
if(el.className)
{txt+="."+el.className;}
a.appendChild(document.createTextNode(txt));this._statusBarTree.appendChild(a);if(i!==0)
{this._statusBarTree.appendChild(document.createTextNode(String.fromCharCode(0xbb)));}}}}
for(var cmd in this._toolbarObjects)
{var btn=this._toolbarObjects[cmd];var inContext=true;if(typeof(btn.state)!='function')
{continue;}
if(btn.context&&!text)
{inContext=false;var context=btn.context;var attrs=[];if(/(.*)\[(.*?)\]/.test(context))
{context=RegExp.$1;attrs=RegExp.$2.split(",");}
context=context.toLowerCase();var match=(context=="*");for(var k=0;k<ancestors.length;++k)
{if(!ancestors[k])
{continue;}
if(match||(ancestors[k].tagName.toLowerCase()==context))
{inContext=true;var contextSplit=null;var att=null;var comp=null;var attVal=null;for(var ka=0;ka<attrs.length;++ka)
{contextSplit=attrs[ka].match(/(.*)(==|!=|===|!==|>|>=|<|<=)(.*)/);att=contextSplit[1];comp=contextSplit[2];attVal=contextSplit[3];if(!eval(ancestors[k][att]+comp+attVal))
{inContext=false;break;}}
if(inContext)
{break;}}}}
btn.state("enabled",(!text||btn.text)&&inContext);if(typeof cmd=="function")
{continue;}
var dropdown=this.config.customSelects[cmd];if((!text||btn.text)&&(typeof dropdown!="undefined"))
{dropdown.refresh(this);continue;}
switch(cmd)
{case"formatblock":var blocks=[];for(var indexBlock in this.config.formatblock)
{if(typeof this.config.formatblock[indexBlock]=='string')
{blocks[blocks.length]=this.config.formatblock[indexBlock];}}
var deepestAncestor=this._getFirstAncestor(this.getSelection(),blocks);if(deepestAncestor)
{for(var x=0;x<blocks.length;x++)
{if(blocks[x].toLowerCase()==deepestAncestor.tagName.toLowerCase())
{btn.element.selectedIndex=x;}}}
else
{btn.element.selectedIndex=0;}
break;case"textindicator":if(!text)
{try
{var style=btn.element.style;style.backgroundColor=Xinha._makeColor(doc.queryCommandValue(Xinha.is_ie?"backcolor":"hilitecolor"));if(/transparent/i.test(style.backgroundColor))
{style.backgroundColor=Xinha._makeColor(doc.queryCommandValue("backcolor"));}
style.color=Xinha._makeColor(doc.queryCommandValue("forecolor"));style.fontFamily=doc.queryCommandValue("fontname");style.fontWeight=doc.queryCommandState("bold")?"bold":"normal";style.fontStyle=doc.queryCommandState("italic")?"italic":"normal";}catch(ex){}}
break;case"htmlmode":btn.state("active",text);break;case"highlight":this._doc.execCommand('styleWithCSS',false,false);btn.state("active",doc.queryCommandValue("hilitecolor")!="transparent");this._doc.execCommand('styleWithCSS',false,true);break;case"bold":case"italic":case"underline":case"insertunorderedlist":case"insertorderedlist":btn.state("active",doc.queryCommandState(cmd));var deepestAncestor=this._getFirstAncestor(this._getSelection(),blocks);if(deepestAncestor)
{if(deepestAncestor.tagName.toLowerCase()=="h6")
{try
{btn.state("enabled",false);}catch(ex){}}}
break;default:cmd=cmd.replace(/(un)?orderedlist/i,"insert$1orderedlist");try
{btn.state("active",(!text&&doc.queryCommandState(cmd)));}catch(ex){}
break;}}
if(this._customUndo&&!this._timerUndo)
{this._undoTakeSnapshot();var editor=this;this._timerUndo=setTimeout(function(){editor._timerUndo=null;},this.config.undoTimeout);}
if(0&&Xinha.is_gecko)
{var s=this.getSelection();if(s&&s.isCollapsed&&s.anchorNode&&s.anchorNode.parentNode.tagName.toLowerCase()!='body'&&s.anchorNode.nodeType==3&&s.anchorOffset==s.anchorNode.length&&!(s.anchorNode.parentNode.nextSibling&&s.anchorNode.parentNode.nextSibling.nodeType==3)&&!Xinha.isBlockElement(s.anchorNode.parentNode))
{try
{s.anchorNode.parentNode.parentNode.insertBefore(this._doc.createTextNode('\t'),s.anchorNode.parentNode.nextSibling);}
catch(ex){}}}
for(var indexPlugin in this.plugins)
{var plugin=this.plugins[indexPlugin].instance;if(plugin&&typeof plugin.onUpdateToolbar=="function")
{plugin.onUpdateToolbar();}}};Xinha.prototype.getAllAncestors=function()
{var p=this.getParentElement();var a=[];while(p&&(p.nodeType==1)&&(p.tagName.toLowerCase()!='body'))
{a.push(p);p=p.parentNode;}
a.push(this._doc.body);return a;};Xinha.prototype._getFirstAncestor=function(sel,types)
{var prnt=this.activeElement(sel);if(prnt===null)
{try
{prnt=(Xinha.is_ie?this.createRange(sel).parentElement():this.createRange(sel).commonAncestorContainer);}
catch(ex)
{return null;}}
if(typeof types=='string')
{types=[types];}
while(prnt)
{if(prnt.nodeType==1)
{if(types===null)
{return prnt;}
if(types.contains(prnt.tagName.toLowerCase()))
{return prnt;}
if(prnt.tagName.toLowerCase()=='body')
{break;}
if(prnt.tagName.toLowerCase()=='table')
{break;}}
prnt=prnt.parentNode;}
return null;};Xinha.prototype._getAncestorBlock=function(sel)
{var prnt=(Xinha.is_ie?this.createRange(sel).parentElement:this.createRange(sel).commonAncestorContainer);while(prnt&&(prnt.nodeType==1))
{switch(prnt.tagName.toLowerCase())
{case'div':case'p':case'address':case'blockquote':case'center':case'del':case'ins':case'pre':case'h1':case'h2':case'h3':case'h4':case'h5':case'h6':case'h7':return prnt;case'body':case'noframes':case'dd':case'li':case'th':case'td':case'noscript':return null;default:break;}}
return null;};Xinha.prototype._createImplicitBlock=function(type)
{var sel=this.getSelection();if(Xinha.is_ie)
{sel.empty();}
else
{sel.collapseToStart();}
var rng=this.createRange(sel);};Xinha.prototype.surroundHTML=function(startTag,endTag)
{var html=this.getSelectedHTML();this.insertHTML(startTag+html+endTag);};Xinha.prototype.hasSelectedText=function()
{return this.getSelectedHTML()!=='';};Xinha.prototype._comboSelected=function(el,txt)
{this.focusEditor();var value=el.options[el.selectedIndex].value;switch(txt)
{case"fontname":case"fontsize":this.execCommand(txt,false,value);break;case"formatblock":if(!value)
{this.updateToolbar();break;}
if(!Xinha.is_gecko||value!=='blockquote')
{value="<"+value+">";}
if(value=="<h6>")
{var blocks=["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","body"];var deepestAncestor=this._getFirstAncestor(this._getSelection(),blocks);stx=this.getStxFromHtml(deepestAncestor.innerHTML);deepestAncestor.innerHTML=stx;}
this.execCommand(txt,false,value);break;default:var dropdown=this.config.customSelects[txt];if(typeof dropdown!="undefined")
{dropdown.action(this);}
else
{alert("FIXME: combo box "+txt+" not implemented");}
break;}};Xinha.prototype._colorSelector=function(cmdID)
{var editor=this;if(Xinha.is_gecko)
{try
{editor._doc.execCommand('useCSS',false,false);editor._doc.execCommand('styleWithCSS',false,true);}catch(ex){}}
var btn=editor._toolbarObjects[cmdID].element;var initcolor;if(cmdID=='hilitecolor')
{if(Xinha.is_ie)
{cmdID='backcolor';initcolor=Xinha._colorToRgb(editor._doc.queryCommandValue("backcolor"));}
else
{initcolor=Xinha._colorToRgb(editor._doc.queryCommandValue("hilitecolor"));}}
else
{initcolor=Xinha._colorToRgb(editor._doc.queryCommandValue("forecolor"));}
var cback=function(color){editor._doc.execCommand(cmdID,false,color);};if(Xinha.is_ie)
{var range=editor.createRange(editor.getSelection());cback=function(color)
{range.select();editor._doc.execCommand(cmdID,false,color);};}
var picker=new Xinha.colorPicker({cellsize:editor.config.colorPickerCellSize,callback:cback,granularity:editor.config.colorPickerGranularity,websafe:editor.config.colorPickerWebSafe,savecolors:editor.config.colorPickerSaveColors});picker.open(editor.config.colorPickerPosition,btn,initcolor);};Xinha.prototype.execCommand=function(cmdID,UI,param)
{var editor=this;this.focusEditor();cmdID=cmdID.toLowerCase();if(this.firePluginEvent('onExecCommand',cmdID,UI,param))
{this.updateToolbar();return false;}
switch(cmdID)
{case"htmlmode":this.setMode();break;case"highlight":try
{this._doc.execCommand('styleWithCSS',false,false);this.fullwordSelection();if(this._doc.queryCommandValue("hilitecolor")!="transparent")
this._doc.execCommand("removeformat",UI,param);else{this._doc.execCommand("removeformat",UI,param);this._doc.execCommand("hilitecolor",false,"#dee7ec");}
this._doc.execCommand('styleWithCSS',false,true);}
catch(exx){alert(exx);}
break;case"hilitecolor":case"forecolor":this._colorSelector(cmdID);break;case"createlink":this._createLink();break;case"undo":case"redo":if(this._customUndo)
{this[cmdID]();}
else
{this._doc.execCommand(cmdID,UI,param);}
break;case"inserttable":this._insertTable();break;case"insertimage":this._insertImage();break;case"about":this._popupDialog(editor.config.URIs.about,null,this);break;case"showhelp":this._popupDialog(editor.config.URIs.help,null,this);break;case"killword":this._wordClean();break;case"cut":case"copy":case"paste":this._doc.execCommand(cmdID,UI,param);if(this.config.killWordOnPaste)
{this._wordClean();}
break;case"lefttoright":case"righttoleft":if(this.config.changeJustifyWithDirection)
{this._doc.execCommand((cmdID=="righttoleft")?"justifyright":"justifyleft",UI,param);}
var dir=(cmdID=="righttoleft")?"rtl":"ltr";var el=this.getParentElement();while(el&&!Xinha.isBlockElement(el))
{el=el.parentNode;}
if(el)
{if(el.style.direction==dir)
{el.style.direction="";}
else
{el.style.direction=dir;}}
break;case'justifyleft':case'justifyright':{cmdID.match(/^justify(.*)$/);var ae=this.activeElement(this.getSelection());if(ae&&ae.tagName.toLowerCase()=='img')
{ae.align=ae.align==RegExp.$1?'':RegExp.$1;}
else
{this._doc.execCommand(cmdID,UI,param);}}
break;default:try
{if(cmdID=="bold"||cmdID=="italic"||cmdID=="underline")
{if(this._doc.queryCommandState(cmdID)==false)
{this.fullwordSelection();this._doc.execCommand("unlink",UI,param);this._doc.execCommand("removeformat",UI,param);}
else
{this.fullwordSelection(true);this._doc.execCommand("removeformat",UI,param);break;}}
this._doc.execCommand(cmdID,UI,param);}
catch(ex)
{if(this.config.debug)
{alert(e+"\n\nby execCommand("+cmdID+");");}}
break;}
this.updateToolbar();return false;};Xinha.prototype._editorEvent=function(ev)
{var editor=this;if(typeof editor._textArea['on'+ev.type]=="function")
{editor._textArea['on'+ev.type]();}
if(this.isKeyEvent(ev))
{if(editor.firePluginEvent('onKeyPress',ev))
{return false;}
if(this.isShortCut(ev))
{this._shortCuts(ev);}}
if(editor._timerToolbar)
{clearTimeout(editor._timerToolbar);}
editor._timerToolbar=setTimeout(function()
{editor.updateToolbar();editor._timerToolbar=null;},250);};Xinha.prototype._shortCuts=function(ev)
{var key=this.getKey(ev).toLowerCase();var cmd=null;var value=null;switch(key)
{case'b':cmd="bold";break;case'i':cmd="italic";break;case'u':cmd="underline";break;case'z':cmd="undo";break;case'y':cmd="redo";break;case'v':cmd="paste";break;case'n':cmd="formatblock";value="p";break;case'0':cmd="killword";break;}
if(cmd)
{this.execCommand(cmd,false,value);Xinha._stopEvent(ev);}};Xinha.prototype.convertNode=function(el,newTagName)
{var newel=this._doc.createElement(newTagName);while(el.firstChild)
{newel.appendChild(el.firstChild);}
return newel;};Xinha.prototype.scrollToElement=function(e)
{if(!e)
{e=this.getParentElement();if(!e)return;}
var position=Xinha.getElementTopLeft(e);this._iframe.contentWindow.scrollTo(position.left,position.top);};Xinha.prototype.getHTML=function()
{var html='';switch(this._editMode)
{case"wysiwyg":if(!this.config.fullPage)
{html=Xinha.getHTML(this._doc.body,false,this);}
else
{html=this.doctype+"\n"+Xinha.getHTML(this._doc.documentElement,true,this);}
break;case"textmode":html=this._textArea.value;break;default:alert("Mode <"+this._editMode+"> not defined!");return false;}
return html;};Xinha.prototype.outwardHtml=function(html)
{for(var i in this.plugins)
{var plugin=this.plugins[i].instance;if(plugin&&typeof plugin.outwardHtml=="function")
{html=plugin.outwardHtml(html);}}
html=html.replace(/<(\/?)b(\s|>|\/)/ig,"<$1strong$2");html=html.replace(/<(\/?)i(\s|>|\/)/ig,"<$1em$2");html=html.replace(/<(\/?)strike(\s|>|\/)/ig,"<$1del$2");html=html.replace("onclick=\"try{if(document.designMode &amp;&amp; document.designMode == 'on') return false;}catch(e){} window.open(","onclick=\"window.open(");var serverBase=location.href.replace(/(https?:\/\/[^\/]*)\/.*/,'$1')+'/';html=html.replace(/https?:\/\/null\//g,serverBase);html=html.replace(/((href|src|background)=[\'\"])\/+/ig,'$1'+serverBase);html=this.outwardSpecialReplacements(html);html=this.fixRelativeLinks(html);if(this.config.sevenBitClean)
{html=html.replace(/[^ -~\r\n\t]/g,function(c){return'&#'+c.charCodeAt(0)+';';});}
html=html.replace(/(<script[^>]*)(freezescript)/gi,"$1javascript");if(this.config.fullPage)
{html=Xinha.stripCoreCSS(html);}
return html;};Xinha.prototype.inwardHtml=function(html)
{for(var i in this.plugins)
{var plugin=this.plugins[i].instance;if(plugin&&typeof plugin.inwardHtml=="function")
{html=plugin.inwardHtml(html);}}
html=html.replace(/<(\/?)del(\s|>|\/)/ig,"<$1strike$2");html=html.replace("onclick=\"window.open(","onclick=\"try{if(document.designMode &amp;&amp; document.designMode == 'on') return false;}catch(e){} window.open(");html=this.inwardSpecialReplacements(html);html=html.replace(/(<script[^>]*)(javascript)/gi,"$1freezescript");var nullRE=new RegExp('((href|src|background)=[\'"])/+','gi');html=html.replace(nullRE,'$1'+location.href.replace(/(https?:\/\/[^\/]*)\/.*/,'$1')+'/');html=this.fixRelativeLinks(html);if(this.config.fullPage)
{html=Xinha.addCoreCSS(html);}
return html;};Xinha.prototype.outwardSpecialReplacements=function(html)
{for(var i in this.config.specialReplacements)
{var from=this.config.specialReplacements[i];var to=i;if(typeof from.replace!='function'||typeof to.replace!='function')
{continue;}
var reg=new RegExp(from.replace(Xinha.RE_Specials,'\\$1'),'g');html=html.replace(reg,to.replace(/\$/g,'$$$$'));}
return html;};Xinha.prototype.inwardSpecialReplacements=function(html)
{for(var i in this.config.specialReplacements)
{var from=i;var to=this.config.specialReplacements[i];if(typeof from.replace!='function'||typeof to.replace!='function')
{continue;}
var reg=new RegExp(from.replace(Xinha.RE_Specials,'\\$1'),'g');html=html.replace(reg,to.replace(/\$/g,'$$$$'));}
return html;};Xinha.prototype.fixRelativeLinks=function(html)
{if(typeof this.config.expandRelativeUrl!='undefined'&&this.config.expandRelativeUrl)
var src=html.match(/(src|href)="([^"]*)"/gi);var b=document.location.href;if(src)
{var url,url_m,relPath,base_m,absPath
for(var i=0;i<src.length;++i)
{url=src[i].match(/(src|href)="([^"]*)"/i);url_m=url[2].match(/\.\.\//g);if(url_m)
{relPath=new RegExp("(.*?)(([^\/]*\/){"+url_m.length+"})[^\/]*$");base_m=b.match(relPath);absPath=url[2].replace(/(\.\.\/)*/,base_m[1]);html=html.replace(new RegExp(url[2].replace(Xinha.RE_Specials,'\\$1')),absPath);}}}
if(typeof this.config.stripSelfNamedAnchors!='undefined'&&this.config.stripSelfNamedAnchors)
{var stripRe=new RegExp(document.location.href.replace(/&/g,'&amp;').replace(Xinha.RE_Specials,'\\$1')+'(#[^\'" ]*)','g');html=html.replace(stripRe,'$1');}
if(typeof this.config.stripBaseHref!='undefined'&&this.config.stripBaseHref)
{var baseRe=null;if(typeof this.config.baseHref!='undefined'&&this.config.baseHref!==null)
{baseRe=new RegExp("((href|src|background)=\")("+this.config.baseHref.replace(Xinha.RE_Specials,'\\$1')+")",'g');}
else
{baseRe=new RegExp("((href|src|background)=\")("+document.location.href.replace(/^(https?:\/\/[^\/]*)(.*)/,'$1').replace(Xinha.RE_Specials,'\\$1')+")",'g');}
html=html.replace(baseRe,'$1');}
return html;};Xinha.prototype.getInnerHTML=function()
{if(!this._doc.body)
{return'';}
var html="";switch(this._editMode)
{case"wysiwyg":if(!this.config.fullPage)
{html=this._doc.body.innerHTML;}
else
{html=this.doctype+"\n"+this._doc.documentElement.innerHTML;}
break;case"textmode":html=this._textArea.value;break;default:alert("Mode <"+this._editMode+"> not defined!");return false;}
return html;};Xinha.prototype.setHTML=function(html)
{if(!this.config.fullPage)
{this._doc.body.innerHTML=html;}
else
{this.setFullHTML(html);}
this._textArea.value=html;};Xinha.prototype.setDoctype=function(doctype)
{this.doctype=doctype;};Xinha._object=null;Xinha.cloneObject=function(obj)
{if(!obj)
{return null;}
var newObj={};if(obj.constructor.toString().match(/\s*function Array\(/))
{newObj=obj.constructor();}
if(obj.constructor.toString().match(/\s*function Function\(/))
{newObj=obj;}
else
{for(var n in obj)
{var node=obj[n];if(typeof node=='object')
{newObj[n]=Xinha.cloneObject(node);}
else
{newObj[n]=node;}}}
return newObj;};Xinha.checkSupportedBrowser=function()
{if(Xinha.is_gecko)
{if(navigator.productSub<20021201)
{alert("You need at least Mozilla-1.3 Alpha.\nSorry, your Gecko is not supported.");return false;}
if(navigator.productSub<20030210)
{alert("Mozilla < 1.3 Beta is not supported!\nI'll try, though, but it might not work.");}}
return Xinha.is_gecko||Xinha.is_ie;};Xinha._eventFlushers=[];Xinha.flushEvents=function()
{var x=0;var e=Xinha._eventFlushers.pop();while(e)
{try
{if(e.length==3)
{Xinha._removeEvent(e[0],e[1],e[2]);x++;}
else if(e.length==2)
{e[0]['on'+e[1]]=null;e[0]._xinha_dom0Events[e[1]]=null;x++;}}
catch(ex)
{}
e=Xinha._eventFlushers.pop();}};if(document.addEventListener)
{Xinha._addEvent=function(el,evname,func)
{el.addEventListener(evname,func,true);Xinha._eventFlushers.push([el,evname,func]);};Xinha._removeEvent=function(el,evname,func)
{el.removeEventListener(evname,func,true);};Xinha._stopEvent=function(ev)
{ev.preventDefault();ev.stopPropagation();};}
else if(document.attachEvent)
{Xinha._addEvent=function(el,evname,func)
{el.attachEvent("on"+evname,func);Xinha._eventFlushers.push([el,evname,func]);};Xinha._removeEvent=function(el,evname,func)
{el.detachEvent("on"+evname,func);};Xinha._stopEvent=function(ev)
{try
{ev.cancelBubble=true;ev.returnValue=false;}
catch(ex)
{}};}
else
{Xinha._addEvent=function(el,evname,func)
{alert('_addEvent is not supported');};Xinha._removeEvent=function(el,evname,func)
{alert('_removeEvent is not supported');};Xinha._stopEvent=function(ev)
{alert('_stopEvent is not supported');};}
Xinha._addEvents=function(el,evs,func)
{for(var i=evs.length;--i>=0;)
{Xinha._addEvent(el,evs[i],func);}};Xinha._removeEvents=function(el,evs,func)
{for(var i=evs.length;--i>=0;)
{Xinha._removeEvent(el,evs[i],func);}};Xinha.addDom0Event=function(el,ev,fn)
{Xinha._prepareForDom0Events(el,ev);el._xinha_dom0Events[ev].unshift(fn);};Xinha.prependDom0Event=function(el,ev,fn)
{Xinha._prepareForDom0Events(el,ev);el._xinha_dom0Events[ev].push(fn);};Xinha._prepareForDom0Events=function(el,ev)
{if(typeof el._xinha_dom0Events=='undefined')
{el._xinha_dom0Events={};Xinha.freeLater(el,'_xinha_dom0Events');}
if(typeof el._xinha_dom0Events[ev]=='undefined')
{el._xinha_dom0Events[ev]=[];if(typeof el['on'+ev]=='function')
{el._xinha_dom0Events[ev].push(el['on'+ev]);}
el['on'+ev]=function(event)
{var a=el._xinha_dom0Events[ev];var allOK=true;for(var i=a.length;--i>=0;)
{el._xinha_tempEventHandler=a[i];if(el._xinha_tempEventHandler(event)===false)
{el._xinha_tempEventHandler=null;allOK=false;break;}
el._xinha_tempEventHandler=null;}
return allOK;};Xinha._eventFlushers.push([el,ev]);}};Xinha.prototype.notifyOn=function(ev,fn)
{if(typeof this._notifyListeners[ev]=='undefined')
{this._notifyListeners[ev]=[];Xinha.freeLater(this,'_notifyListeners');}
this._notifyListeners[ev].push(fn);};Xinha.prototype.notifyOf=function(ev,args)
{if(this._notifyListeners[ev])
{for(var i=0;i<this._notifyListeners[ev].length;i++)
{this._notifyListeners[ev][i](ev,args);}}};Xinha._removeClass=function(el,className)
{if(!(el&&el.className))
{return;}
var cls=el.className.split(" ");var ar=[];for(var i=cls.length;i>0;)
{if(cls[--i]!=className)
{ar[ar.length]=cls[i];}}
el.className=ar.join(" ");};Xinha._addClass=function(el,className)
{Xinha._removeClass(el,className);el.className+=" "+className;};Xinha._hasClass=function(el,className)
{if(!(el&&el.className))
{return false;}
var cls=el.className.split(" ");for(var i=cls.length;i>0;)
{if(cls[--i]==className)
{return true;}}
return false;};Xinha._blockTags=" body form textarea fieldset ul ol dl li div "+"p h1 h2 h3 h4 h5 h6 quote pre table thead "+"tbody tfoot tr td th iframe address blockquote ";Xinha.isBlockElement=function(el)
{return el&&el.nodeType==1&&(Xinha._blockTags.indexOf(" "+el.tagName.toLowerCase()+" ")!=-1);};Xinha._paraContainerTags=" body td th caption fieldset div";Xinha.isParaContainer=function(el)
{return el&&el.nodeType==1&&(Xinha._paraContainerTags.indexOf(" "+el.tagName.toLowerCase()+" ")!=-1);};Xinha._closingTags=" a abbr acronym address applet b bdo big blockquote button caption center cite code del dfn dir div dl em fieldset font form frameset h1 h2 h3 h4 h5 h6 i iframe ins kbd label legend map menu noframes noscript object ol optgroup pre q s samp script select small span strike strong style sub sup table textarea title tt u ul var ";Xinha.needsClosingTag=function(el)
{return el&&el.nodeType==1&&(Xinha._closingTags.indexOf(" "+el.tagName.toLowerCase()+" ")!=-1);};Xinha.htmlEncode=function(str)
{if(typeof str.replace=='undefined')
{str=str.toString();}
str=str.replace(/&/ig,"&amp;");str=str.replace(/</ig,"&lt;");str=str.replace(/>/ig,"&gt;");str=str.replace(/\xA0/g,"&nbsp;");str=str.replace(/\x22/g,"&quot;");return str;};Xinha.prototype.stripBaseURL=function(string)
{if(this.config.baseHref===null||!this.config.stripBaseHref)
{return string;}
var baseurl=this.config.baseHref.replace(/^(https?:\/\/[^\/]+)(.*)$/,'$1');var basere=new RegExp(baseurl);return string.replace(basere,"");};String.prototype.trim=function()
{return this.replace(/^\s+/,'').replace(/\s+$/,'');};Xinha._makeColor=function(v)
{if(typeof v!="number")
{return v;}
var r=v&0xFF;var g=(v>>8)&0xFF;var b=(v>>16)&0xFF;return"rgb("+r+","+g+","+b+")";};Xinha._colorToRgb=function(v)
{if(!v)
{return'';}
var r,g,b;function hex(d)
{return(d<16)?("0"+d.toString(16)):d.toString(16);}
if(typeof v=="number")
{r=v&0xFF;g=(v>>8)&0xFF;b=(v>>16)&0xFF;return"#"+hex(r)+hex(g)+hex(b);}
if(v.substr(0,3)=="rgb")
{var re=/rgb\s*\(\s*([0-9]+)\s*,\s*([0-9]+)\s*,\s*([0-9]+)\s*\)/;if(v.match(re))
{r=parseInt(RegExp.$1,10);g=parseInt(RegExp.$2,10);b=parseInt(RegExp.$3,10);return"#"+hex(r)+hex(g)+hex(b);}
return null;}
if(v.substr(0,1)=="#")
{return v;}
return null;};Xinha.prototype._popupDialog=function(url,action,init)
{Dialog(this.popupURL(url),action,init);};Xinha.prototype.imgURL=function(file,plugin)
{if(typeof plugin=="undefined")
{return _editor_url+file;}
else
{return _editor_url+"plugins/"+plugin+"/img/"+file;}};Xinha.prototype.popupURL=function(file)
{var url="";if(file.match(/^plugin:\/\/(.*?)\/(.*)/))
{var plugin=RegExp.$1;var popup=RegExp.$2;if(!(/\.html$/.test(popup)))
{popup+=".html";}
url=_editor_url+"plugins/"+plugin+"/popups/"+popup;}
else if(file.match(/^\/.*?/))
{url=file;}
else
{url=_editor_url+this.config.popupURL+file;}
return url;};Xinha.getElementById=function(tag,id)
{var el,i,objs=document.getElementsByTagName(tag);for(i=objs.length;--i>=0&&(el=objs[i]);)
{if(el.id==id)
{return el;}}
return null;};Xinha.prototype._toggleBorders=function()
{var tables=this._doc.getElementsByTagName('TABLE');if(tables.length!==0)
{if(!this.borders)
{this.borders=true;}
else
{this.borders=false;}
for(var i=0;i<tables.length;i++)
{if(this.borders)
{Xinha._addClass(tables[i],'htmtableborders');}
else
{Xinha._removeClass(tables[i],'htmtableborders');}}}
return true;};Xinha.addCoreCSS=function(html)
{var coreCSS="<style title=\"Xinha Internal CSS\" type=\"text/css\">"
+".htmtableborders, .htmtableborders td, .htmtableborders th {border : 1px dashed lightgrey ! important;}\n"
+"html, body { border: 0px; } \n"
+"body { background-color: #ffffff; } \n"
+"</style>\n";if(html&&/<head>/i.test(html))
{return html.replace(/<head>/i,'<head>'+coreCSS);}
else if(html)
{return coreCSS+html;}
else
{return coreCSS;}}
Xinha.stripCoreCSS=function(html)
{return html.replace(/<style[^>]+title="Xinha Internal CSS"(.|\n)*?<\/style>/i,'');}
Xinha.addClasses=function(el,classes)
{if(el!==null)
{var thiers=el.className.trim().split(' ');var ours=classes.split(' ');for(var x=0;x<ours.length;x++)
{var exists=false;for(var i=0;exists===false&&i<thiers.length;i++)
{if(thiers[i]==ours[x])
{exists=true;}}
if(exists===false)
{thiers[thiers.length]=ours[x];}}
el.className=thiers.join(' ').trim();}};Xinha.removeClasses=function(el,classes)
{var existing=el.className.trim().split();var new_classes=[];var remove=classes.trim().split();for(var i=0;i<existing.length;i++)
{var found=false;for(var x=0;x<remove.length&&!found;x++)
{if(existing[i]==remove[x])
{found=true;}}
if(!found)
{new_classes[new_classes.length]=existing[i];}}
return new_classes.join(' ');};Xinha.addClass=Xinha._addClass;Xinha.removeClass=Xinha._removeClass;Xinha._addClasses=Xinha.addClasses;Xinha._removeClasses=Xinha.removeClasses;Xinha._postback=function(url,data,handler)
{var req=null;req=Xinha.getXMLHTTPRequestObject();var content='';if(typeof data=='string')
{content=data;}
else if(typeof data=="object")
{for(var i in data)
{content+=(content.length?'&':'')+i+'='+encodeURIComponent(data[i]);}}
function callBack()
{if(req.readyState==4)
{if(req.status==200||Xinha.isRunLocally&&req.status==0)
{if(typeof handler=='function')
{handler(req.responseText,req);}}
else
{alert('An error has occurred: '+req.statusText);}}}
req.onreadystatechange=callBack;req.open('POST',url,true);req.setRequestHeader('Content-Type','application/x-www-form-urlencoded; charset=UTF-8');req.send(content);};Xinha._getback=function(url,handler)
{var req=null;req=Xinha.getXMLHTTPRequestObject();function callBack()
{if(req.readyState==4)
{if(req.status==200||Xinha.isRunLocally&&req.status==0)
{handler(req.responseText,req);}
else
{alert('An error has occurred: '+req.statusText);}}}
req.onreadystatechange=callBack;req.open('GET',url,true);req.send(null);};Xinha._geturlcontent=function(url)
{var req=null;req=Xinha.getXMLHTTPRequestObject();req.open('GET',url,false);req.send(null);if(req.status==200||Xinha.isRunLocally&&req.status==0)
{return req.responseText;}
else
{return'';}};if(typeof dump=='undefined')
{function dump(o)
{var s='';for(var prop in o)
{s+=prop+' = '+o[prop]+'\n';}
var x=window.open("","debugger");x.document.write('<pre>'+s+'</pre>');}}
Xinha.arrayContainsArray=function(a1,a2)
{var all_found=true;for(var x=0;x<a2.length;x++)
{var found=false;for(var i=0;i<a1.length;i++)
{if(a1[i]==a2[x])
{found=true;break;}}
if(!found)
{all_found=false;break;}}
return all_found;};Xinha.arrayFilter=function(a1,filterfn)
{var new_a=[];for(var x=0;x<a1.length;x++)
{if(filterfn(a1[x]))
{new_a[new_a.length]=a1[x];}}
return new_a;};Xinha.uniq_count=0;Xinha.uniq=function(prefix)
{return prefix+Xinha.uniq_count++;};Xinha._loadlang=function(context,url)
{var lang;if(typeof _editor_lcbackend=="string")
{url=_editor_lcbackend;url=url.replace(/%lang%/,_editor_lang);url=url.replace(/%context%/,context);}
else if(!url)
{if(context!='Xinha')
{url=_editor_url+"plugins/"+context+"/lang/"+_editor_lang+".js";}
else
{url=_editor_url+"lang/"+_editor_lang+".js";}}
var langData=Xinha._geturlcontent(url);if(langData!=="")
{try
{eval('lang = '+langData);}
catch(ex)
{alert('Error reading Language-File ('+url+'):\n'+Error.toString());lang={};}}
else
{lang={};}
return lang;};Xinha._lc=function(string,context,replace)
{var url,ret;if(typeof context=='object'&&context.url&&context.context)
{url=context.url+_editor_lang+".js";context=context.context;}
var m=null;if(typeof string=='string')m=string.match(/\$(.*?)=(.*?)\$/g);if(m)
{if(!replace)replace={};for(var i=0;i<m.length;i++)
{var n=m[i].match(/\$(.*?)=(.*?)\$/);replace[n[1]]=n[2];string=string.replace(n[0],'$'+n[1]);}}
if(_editor_lang=="en")
{if(typeof string=='object'&&string.string)
{ret=string.string;}
else
{ret=string;}}
else
{if(typeof Xinha._lc_catalog=='undefined')
{Xinha._lc_catalog=[];}
if(typeof context=='undefined')
{context='Xinha';}
if(typeof Xinha._lc_catalog[context]=='undefined')
{Xinha._lc_catalog[context]=Xinha._loadlang(context,url);}
var key;if(typeof string=='object'&&string.key)
{key=string.key;}
else if(typeof string=='object'&&string.string)
{key=string.string;}
else
{key=string;}
if(typeof Xinha._lc_catalog[context][key]=='undefined')
{if(context=='Xinha')
{if(typeof string=='object'&&string.string)
{ret=string.string;}
else
{ret=string;}}
else
{return Xinha._lc(string,'Xinha',replace);}}
else
{ret=Xinha._lc_catalog[context][key];}}
if(typeof string=='object'&&string.replace)
{replace=string.replace;}
if(typeof replace!="undefined")
{for(var i in replace)
{ret=ret.replace('$'+i,replace[i]);}}
return ret;};Xinha.hasDisplayedChildren=function(el)
{var children=el.childNodes;for(var i=0;i<children.length;i++)
{if(children[i].tagName)
{if(children[i].style.display!='none')
{return true;}}}
return false;};Xinha._loadback=function(Url,Callback,Scope,Bonus)
{var T=!Xinha.is_ie?"onload":'onreadystatechange';var S=document.createElement("script");S.type="text/javascript";S.src=Url;if(Callback)
{S[T]=function()
{if(Xinha.is_ie&&(!(/loaded|complete/.test(window.event.srcElement.readyState))))
{return;}
Callback.call(Scope?Scope:this,Bonus);S[T]=null;};}
document.getElementsByTagName("head")[0].appendChild(S);};Xinha.collectionToArray=function(collection)
{var array=[];for(var i=0;i<collection.length;i++)
{array.push(collection.item(i));}
return array;};if(!Array.prototype.append)
{Array.prototype.append=function(a)
{for(var i=0;i<a.length;i++)
{this.push(a[i]);}
return this;};}
Xinha.makeEditors=function(editor_names,default_config,plugin_names)
{if(typeof default_config=='function')
{default_config=default_config();}
var editors={};for(var x=0;x<editor_names.length;x++)
{var editor=new Xinha(editor_names[x],Xinha.cloneObject(default_config));editor.registerPlugins(plugin_names);editors[editor_names[x]]=editor;}
return editors;};Xinha.startEditors=function(editors)
{for(var i in editors)
{if(editors[i].generate)
{editors[i].generate();}}};Xinha.prototype.registerPlugins=function(plugin_names)
{if(plugin_names)
{for(var i=0;i<plugin_names.length;i++)
{this.setLoadingMessage('Register plugin $plugin','Xinha',{'plugin':plugin_names[i]});this.registerPlugin(eval(plugin_names[i]));}}};Xinha.base64_encode=function(input)
{var keyStr="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";var output="";var chr1,chr2,chr3;var enc1,enc2,enc3,enc4;var i=0;do
{chr1=input.charCodeAt(i++);chr2=input.charCodeAt(i++);chr3=input.charCodeAt(i++);enc1=chr1>>2;enc2=((chr1&3)<<4)|(chr2>>4);enc3=((chr2&15)<<2)|(chr3>>6);enc4=chr3&63;if(isNaN(chr2))
{enc3=enc4=64;}
else if(isNaN(chr3))
{enc4=64;}
output=output+keyStr.charAt(enc1)+keyStr.charAt(enc2)+keyStr.charAt(enc3)+keyStr.charAt(enc4);}while(i<input.length);return output;};Xinha.base64_decode=function(input)
{var keyStr="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";var output="";var chr1,chr2,chr3;var enc1,enc2,enc3,enc4;var i=0;input=input.replace(/[^A-Za-z0-9\+\/\=]/g,"");do
{enc1=keyStr.indexOf(input.charAt(i++));enc2=keyStr.indexOf(input.charAt(i++));enc3=keyStr.indexOf(input.charAt(i++));enc4=keyStr.indexOf(input.charAt(i++));chr1=(enc1<<2)|(enc2>>4);chr2=((enc2&15)<<4)|(enc3>>2);chr3=((enc3&3)<<6)|enc4;output=output+String.fromCharCode(chr1);if(enc3!=64)
{output=output+String.fromCharCode(chr2);}
if(enc4!=64)
{output=output+String.fromCharCode(chr3);}}while(i<input.length);return output;};Xinha.removeFromParent=function(el)
{if(!el.parentNode)
{return;}
var pN=el.parentNode;pN.removeChild(el);return el;};Xinha.hasParentNode=function(el)
{if(el.parentNode)
{if(el.parentNode.nodeType==11)
{return false;}
return true;}
return false;};Xinha.viewportSize=function(scope)
{scope=(scope)?scope:window;var x,y;if(scope.innerHeight)
{x=scope.innerWidth;y=scope.innerHeight;}
else if(scope.document.documentElement&&scope.document.documentElement.clientHeight)
{x=scope.document.documentElement.clientWidth;y=scope.document.documentElement.clientHeight;}
else if(scope.document.body)
{x=scope.document.body.clientWidth;y=scope.document.body.clientHeight;}
return{'x':x,'y':y};};Xinha.prototype.scrollPos=function(scope)
{scope=(scope)?scope:window;var x,y;if(scope.pageYOffset)
{x=scope.pageXOffset;y=scope.pageYOffset;}
else if(scope.document.documentElement&&document.documentElement.scrollTop)
{x=scope.document.documentElement.scrollLeft;y=scope.document.documentElement.scrollTop;}
else if(scope.document.body)
{x=scope.document.body.scrollLeft;y=scope.document.body.scrollTop;}
return{'x':x,'y':y};};Xinha.getElementTopLeft=function(element)
{var position={top:0,left:0};while(element)
{position.top+=element.offsetTop;position.left+=element.offsetLeft;if(element.offsetParent&&element.offsetParent.tagName.toLowerCase()!='body')
{element=element.offsetParent;}
else
{element=null;}}
return position;}
Xinha.findPosX=function(obj)
{var curleft=0;if(obj.offsetParent)
{return Xinha.getElementTopLeft(obj).left;}
else if(obj.x)
{curleft+=obj.x;}
return curleft;};Xinha.findPosY=function(obj)
{var curtop=0;if(obj.offsetParent)
{return Xinha.getElementTopLeft(obj).top;}
else if(obj.y)
{curtop+=obj.y;}
return curtop;};Xinha.prototype.setLoadingMessage=function(string,context,replace)
{if(!this.config.showLoading||!document.getElementById("loading_sub_"+this._textArea.name))
{return;}
var elt=document.getElementById("loading_sub_"+this._textArea.name);elt.innerHTML=Xinha._lc(string,context,replace);};Xinha.prototype.removeLoadingMessage=function()
{if(!this.config.showLoading||!document.getElementById("loading_"+this._textArea.name))
{return;}
document.body.removeChild(document.getElementById("loading_"+this._textArea.name));};Xinha.toFree=[];Xinha.freeLater=function(obj,prop)
{Xinha.toFree.push({o:obj,p:prop});};Xinha.free=function(obj,prop)
{if(obj&&!prop)
{for(var p in obj)
{Xinha.free(obj,p);}}
else if(obj)
{try{obj[prop]=null;}catch(x){}}};Xinha.collectGarbageForIE=function()
{Xinha.flushEvents();for(var x=0;x<Xinha.toFree.length;x++)
{Xinha.free(Xinha.toFree[x].o,Xinha.toFree[x].p);Xinha.toFree[x].o=null;}};Xinha.prototype.insertNodeAtSelection=function(toBeInserted){Xinha.notImplemented("insertNodeAtSelection");}
Xinha.prototype.getParentElement=function(sel){Xinha.notImplemented("getParentElement");}
Xinha.prototype.activeElement=function(sel){Xinha.notImplemented("activeElement");}
Xinha.prototype.selectionEmpty=function(sel){Xinha.notImplemented("selectionEmpty");}
Xinha.prototype.selectNodeContents=function(node,pos){Xinha.notImplemented("selectNodeContents");}
Xinha.prototype.insertHTML=function(html){Xinha.notImplemented("insertHTML");}
Xinha.prototype.getSelectedHTML=function(){Xinha.notImplemented("getSelectedHTML");}
Xinha.prototype.getSelection=function(){Xinha.notImplemented("getSelection");}
Xinha.prototype.createRange=function(sel){Xinha.notImplemented("createRange");}
Xinha.prototype.isKeyEvent=function(event){Xinha.notImplemented("isKeyEvent");}
Xinha.prototype.isShortCut=function(keyEvent)
{if(keyEvent.ctrlKey&&!keyEvent.altKey)
{return true;}
return false;}
Xinha.prototype.getKey=function(keyEvent){Xinha.notImplemented("getKey");}
Xinha.getOuterHTML=function(element){Xinha.notImplemented("getOuterHTML");}
Xinha.getXMLHTTPRequestObject=function()
{try
{if(typeof XMLHttpRequest=="function")
{return new XMLHttpRequest();}
else if(typeof ActiveXObject=="function")
{return new ActiveXObject("Microsoft.XMLHTTP");}}
catch(e)
{Xinha.notImplemented('getXMLHTTPRequestObject');}}
Xinha.prototype._activeElement=function(sel){return this.activeElement(sel);}
Xinha.prototype._selectionEmpty=function(sel){return this.selectionEmpty(sel);}
Xinha.prototype._getSelection=function(){return this.getSelection();}
Xinha.prototype._createRange=function(sel){return this.createRange(sel);}
HTMLArea=Xinha;Xinha.init();Xinha.addDom0Event(window,'unload',Xinha.collectGarbageForIE);Xinha.notImplemented=function(methodName)
{throw new Error("Method Not Implemented","Part of Xinha has tried to call the "+methodName+" method which has not been implemented.");}
