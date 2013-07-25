
Subclass=function(name,base){if(!name)die("Can't create a subclass without a name");var parts=name.split('.');var subclass=window;for(var i=0;i<parts.length;i++){if(!subclass[parts[i]])
subclass[parts[i]]=function(){};subclass=subclass[parts[i]];}
if(base){var baseclass=eval('new '+base+'()');subclass.prototype=baseclass;subclass.prototype.baseclass=base;subclass.prototype.superfunc=Subclass.generate_superfunc();}
subclass.prototype.classname=name;return subclass.prototype;}
Subclass.generate_superfunc=function(){return function(func){var p;for(var b=this.baseclass;b;b=p.baseclass){p=eval(b+'.prototype');if(p[func]&&p[func]!=this[func])
return p[func];}
die("No superfunc function for: "+func+"\n"+"baseclass was: "+this.baseclass+"\n"+"caller was: "+arguments.callee.caller);}}
proto=new Subclass('Wikiwyg');Wikiwyg.VERSION='0.12';Wikiwyg.ua=navigator.userAgent.toLowerCase();Wikiwyg.is_ie=(Wikiwyg.ua.indexOf("msie")!=-1&&Wikiwyg.ua.indexOf("opera")==-1&&Wikiwyg.ua.indexOf("webtv")==-1);Wikiwyg.is_gecko=(Wikiwyg.ua.indexOf('gecko')!=-1&&Wikiwyg.ua.indexOf('safari')==-1);Wikiwyg.is_safari=(Wikiwyg.ua.indexOf('safari')!=-1);Wikiwyg.is_opera=(Wikiwyg.ua.indexOf('opera')!=-1);Wikiwyg.browserIsSupported=(Wikiwyg.is_gecko||Wikiwyg.is_ie);proto.createWikiwygArea=function(div,config){this.set_config(config);this.initializeObject(div,config);};proto.config={javascriptLocation:'/js/wikiwyg/',doubleClickToEdit:false,toolbarClass:'Wikiwyg.Toolbar',modeClasses:['Wikiwyg.Wysiwyg','Wikiwyg.Wikitext']};proto.initializeObject=function(div,config){if(!Wikiwyg.browserIsSupported)return;if(this.enabled)return;this.enabled=true;this.div=div;this.divHeight=this.div.offsetHeight;if(!config)config={};this.mode_objects={};for(var i=0;i<this.config.modeClasses.length;i++){var class_name=this.config.modeClasses[i];var mode_object=eval('new '+class_name+'()');mode_object.wikiwyg=this;mode_object.set_config(config[mode_object.classtype]);mode_object.initializeObject();this.mode_objects[class_name]=mode_object;if(!this.first_mode){this.first_mode=mode_object;}}
if(this.config.toolbarClass){var class_name=this.config.toolbarClass;this.toolbarObject=eval('new '+class_name+'()');this.toolbarObject.wikiwyg=this;this.toolbarObject.set_config(config.toolbar);this.toolbarObject.initializeObject();this.placeToolbar(this.toolbarObject.div);}
for(var i=0;i<this.config.modeClasses.length;i++){var mode_class=this.config.modeClasses[i];var mode_object=this.mode_objects[mode_class];this.insert_div_before(mode_object.div);}
if(this.config.doubleClickToEdit){var self=this;this.div.ondblclick=function(){self.editMode()};}}
proto.placeToolbar=function(div){this.insert_div_before(div);}
proto.set_config=function(user_config){for(var key in this.config)
if(user_config&&user_config[key])
this.config[key]=user_config[key];else if(this[key]!=null)
this.config[key]=this[key];}
proto.insert_div_before=function(div){div.style.display='none';if(!div.iframe_hack){this.div.parentNode.insertBefore(div,this.div);}}
proto.saveChanges=function(){alert('Wikiwyg.prototype.saveChanges not subclassed');}
proto.editMode=function(){this.current_mode=this.first_mode;this.toolbarObject.resetModeSelector();this.current_mode.enableThis();this.current_mode.fromHtml(this.div.innerHTML);}
proto.displayMode=function(){for(var i=0;i<this.config.modeClasses.length;i++){var mode_class=this.config.modeClasses[i];var mode_object=this.mode_objects[mode_class];mode_object.disableThis();}
this.toolbarObject.disableThis();this.div.style.display='block';this.divHeight=this.div.offsetHeight;}
proto.switchMode=function(new_mode_key){var new_mode=this.mode_objects[new_mode_key];var old_mode=this.current_mode;var self=this;new_mode.enableStarted();old_mode.disableStarted();old_mode.toHtml(function(html){self.previous_mode=old_mode;new_mode.fromHtml(html);old_mode.disableThis();new_mode.enableThis();new_mode.enableFinished();old_mode.disableFinished();self.current_mode=new_mode;});}
proto.cancelEdit=function(){this.displayMode();}
proto.fromHtml=function(html){this.div.innerHTML=html;}
Wikiwyg.unique_id_base=0;Wikiwyg.createUniqueId=function(){return'wikiwyg_'+Wikiwyg.unique_id_base++;}
Wikiwyg.liveUpdate=function(method,url,query,callback){var req=new XMLHttpRequest();var data=null;if(method=='GET')
url=url+'?'+query;else
data=query;req.open(method,url);req.onreadystatechange=function(){if(req.readyState==4&&req.status==200)
callback(req.responseText);}
if(method=='POST'){req.setRequestHeader('Content-Type','application/x-www-form-urlencoded');}
req.send(data);}
Wikiwyg.htmlUnescape=function(escaped){return escaped.replace(/&amp;/g,'&').replace(/&lt;/g,'<').replace(/&gt;/g,'>');}
Wikiwyg.showById=function(id){document.getElementById(id).style.visibility='inherit';}
Wikiwyg.hideById=function(id){document.getElementById(id).style.visibility='hidden';}
Wikiwyg.changeLinksMatching=function(attribute,pattern,func){var links=document.getElementsByTagName('a');for(var i=0;i<links.length;i++){var link=links[i];var my_attribute=link.getAttribute(attribute);if(my_attribute&&my_attribute.match(pattern)){link.setAttribute('href','#');link.onclick=func;}}}
Wikiwyg.createElementWithAttrs=function(element,attrs,doc){if(doc==null)
doc=document;return Wikiwyg.create_element_with_attrs(element,attrs,doc);}
Wikiwyg.create_element_with_attrs=function(element,attrs,doc){var elem=doc.createElement(element);for(name in attrs)
elem.setAttribute(name,attrs[name]);return elem;}
die=function(e){throw(e);}
String.prototype.times=function(n){return n?this+this.times(n-1):"";}
proto=new Subclass('Wikiwyg.Base');proto.set_config=function(user_config){for(var key in this.config){if(user_config!=null&&user_config[key]!=null)
this.merge_config(key,user_config[key]);else if(this[key]!=null)
this.merge_config(key,this[key]);else if(this.wikiwyg.config[key]!=null)
this.merge_config(key,this.wikiwyg.config[key]);}}
proto.merge_config=function(key,value){if(value instanceof Array){this.config[key]=value;}
else if(typeof value.test=='function'){this.config[key]=value;}
else if(value instanceof Object){if(!this.config[key])
this.config[key]={};for(var subkey in value){this.config[key][subkey]=value[subkey];}}
else{this.config[key]=value;}}
proto=new Subclass('Wikiwyg.Mode','Wikiwyg.Base');proto.enableThis=function(){this.div.style.display='block';this.display_unsupported_toolbar_buttons('none');this.wikiwyg.toolbarObject.enableThis();this.wikiwyg.div.style.display='none';}
proto.display_unsupported_toolbar_buttons=function(display){if(!this.config)return;var disabled=this.config.disabledToolbarButtons;if(!disabled||disabled.length<1)return;var toolbar_div=this.wikiwyg.toolbarObject.div;var toolbar_buttons=toolbar_div.childNodes;for(var i in disabled){var action=disabled[i];for(var i in toolbar_buttons){var button=toolbar_buttons[i];var src=button.src;if(!src)continue;if(src.match(action)){button.style.display=display;break;}}}}
proto.enableStarted=function(){}
proto.enableFinished=function(){}
proto.disableStarted=function(){}
proto.disableFinished=function(){}
proto.disableThis=function(){this.display_unsupported_toolbar_buttons('inline');this.div.style.display='none';}
proto.process_command=function(command){if(this['do_'+command])
this['do_'+command](command);}
proto.enable_keybindings=function(){if(!this.key_press_function){this.key_press_function=this.get_key_press_function();this.get_keybinding_area().addEventListener('keypress',this.key_press_function,true);}}
proto.get_key_press_function=function(){var self=this;return function(e){if(e.keyCode==9){e.preventDefault();e.stopPropagation();}
if(!e.ctrlKey)return;var key=String.fromCharCode(e.charCode).toLowerCase();var command='';switch(key){case'b':command='bold';break;case'i':command='italic';break;case'u':command='underline';break;case'l':command='link';break;};if(command){e.preventDefault();e.stopPropagation();self.process_command(command);}};}
proto.get_edit_height=function(){var height=parseInt(this.wikiwyg.divHeight*this.config.editHeightAdjustment);var min=this.config.editHeightMinimum;return height<min?min:height;}
proto.setHeightOf=function(elem){elem.height=this.get_edit_height()+'px';}
if(Wikiwyg.is_ie){Wikiwyg.create_element_with_attrs=function(element,attrs,doc){var str='';for(name in attrs)
str+=' '+name+'="'+attrs[name]+'"';return doc.createElement('<'+element+str+'>');}
die=function(e){alert(e);throw(e);}
proto=Wikiwyg.Mode.prototype;proto.enable_keybindings=function(){}}
proto=new Subclass('Wikiwyg.Toolbar','Wikiwyg.Base');proto.classtype='toolbar';proto.config={imagesLocation:'images/',imagesExtension:'.gif',controlLayout:['h3','p','pre','|','bold','italic','underline','|','link','hr','|','ordered','unordered','|','spellcheck'],styleSelector:['label','p','h3','pre'],controlLabels:{bold:'Bold (ctrl-b)',italic:'Italic (ctrl-i)',underline:'Underline (ctrl-u)',hr:'Horizontal Rule',ordered:'Numbered List',unordered:'Bulleted List',spellcheck:'Spell Check',indent:'More Indented',outdent:'Less Indented',label:'[Style]',p:'Normal Text',pre:'Preformatted',h3:'Heading',link:'Create Link',table:'Create Table'}};proto.initializeObject=function(){this.div=Wikiwyg.createElementWithAttrs('div',{'class':'wikiwyg_toolbar',id:'wikiwyg_toolbar'});var config=this.config;for(var i=0;i<config.controlLayout.length;i++){var action=config.controlLayout[i];var label=config.controlLabels[action]
if(action=='save')
this.addControlItem(label,'saveChanges');else if(action=='cancel')
this.addControlItem(label,'cancelEdit');else if(action=='mode_selector')
this.addModeSelector();else if(action=='selector')
this.add_styles();else if(action=='help')
this.add_help_button(action,label);else if(action=='|')
this.add_separator();else if(action=='/')
this.add_break();else
this.add_button(action,label);}}
proto.enableThis=function(){this.div.style.display='block';}
proto.disableThis=function(){this.div.style.display='none';}
proto.make_button=function(type,label){var base=this.config.imagesLocation;var ext=this.config.imagesExtension;return Wikiwyg.createElementWithAttrs('img',{'class':'wikiwyg_button',onmouseup:"this.style.border='1px outset';",onmouseover:"this.style.border='1px outset';",onmouseout:"this.style.borderColor=this.style.backgroundColor;"+"this.style.borderStyle='solid';",onmousedown:"this.style.border='1px inset';",alt:label,title:label,src:base+type+ext});}
proto.add_button=function(type,label){var img=this.make_button(type,label);var self=this;img.onclick=function(){self.wikiwyg.current_mode.process_command(type);};this.div.appendChild(img);}
proto.add_separator=function(){var base=this.config.imagesLocation;var ext=this.config.imagesExtension;this.div.appendChild(Wikiwyg.createElementWithAttrs('img',{'class':'wikiwyg_separator',alt:' | ',title:'',src:base+'separator'+ext}));}
proto.addControlItem=function(text,method){var span=Wikiwyg.createElementWithAttrs('span',{'class':'wikiwyg_control_link'});var link=Wikiwyg.createElementWithAttrs('a',{href:'#'});link.innerHTML=text;span.appendChild(link);var self=this;link.onclick=function(){eval('self.wikiwyg.'+method+'()');return false};this.div.appendChild(span);}
proto.resetModeSelector=function(){if(this.firstModeRadio){var temp=this.firstModeRadio.onclick;this.firstModeRadio.onclick=null;this.firstModeRadio.click();this.firstModeRadio.onclick=temp;}}
proto.addModeSelector=function(){var span=document.createElement('span');var radio_name=Wikiwyg.createUniqueId();for(var i=0;i<this.wikiwyg.config.modeClasses.length;i++){var class_name=this.wikiwyg.config.modeClasses[i];var mode_object=this.wikiwyg.mode_objects[class_name];var radio_id=Wikiwyg.createUniqueId();var checked=i==0?'checked':'';var radio=Wikiwyg.createElementWithAttrs('input',{type:'radio',name:radio_name,id:radio_id,value:mode_object.classname,'checked':checked});if(!this.firstModeRadio)
this.firstModeRadio=radio;var self=this;radio.onclick=function(){self.wikiwyg.switchMode(this.value);};var label=Wikiwyg.createElementWithAttrs('label',{'for':radio_id});label.innerHTML=mode_object.modeDescription;span.appendChild(radio);span.appendChild(label);}
this.div.appendChild(span);}
proto.add_break=function(){this.div.appendChild(document.createElement('br'));}
proto.add_styles=function(){var options=this.config.styleSelector;var labels=this.config.controlLabels;this.styleSelect=Wikiwyg.createElementWithAttrs('select',{'class':'wikiwyg_selector'});for(var i=0;i<options.length;i++){value=options[i];var option=Wikiwyg.createElementWithAttrs('option',{'value':value});option.textContent=labels[value];this.styleSelect.appendChild(option);}
var self=this;this.styleSelect.onchange=function(){self.set_style(this.value)};this.div.appendChild(this.styleSelect);}
proto.set_style=function(style_name){var idx=this.styleSelect.selectedIndex;if(idx!=0)
this.wikiwyg.current_mode.process_command(style_name);this.styleSelect.selectedIndex=0;}
proto=new Subclass('Wikiwyg.Wysiwyg','Wikiwyg.Mode');proto.classtype='wysiwyg';proto.modeDescription='Design Mode';proto.config={useParentStyles:true,useStyleMedia:'wikiwyg',iframeId:null,iframeObject:null,disabledToolbarButtons:[],editHeightMinimum:150,editHeightAdjustment:1.3,clearRegex:null};proto.initializeObject=function(){this.edit_iframe=this.get_edit_iframe();this.div=this.edit_iframe;this.set_design_mode_early();}
proto.set_design_mode_early=function(){}
proto.fromHtml=function(html){this.set_inner_html(html);}
proto.toHtml=function(func){func(this.get_inner_html())}
proto.fix_up_relative_imgs=function(){var base=location.href.replace(/(.*?:\/\/.*?\/).*/,'$1');var imgs=this.get_edit_document().getElementsByTagName('img');for(var ii=0;ii<imgs.length;++ii)
imgs[ii].src=imgs[ii].src.replace(/^\//,base);}
proto.enableThis=function(){this.superfunc('enableThis').call(this);this.edit_iframe.style.border='1px black solid';this.edit_iframe.width='600';this.setHeightOf(this.edit_iframe);this.fix_up_relative_imgs();this.get_edit_document().designMode='on';this.apply_stylesheets();this.enable_keybindings();if(Wikiwyg.is_ie){alert('save your changes when finished');this.clear_inner_html();}else{this.clear_inner_html();}}
proto.clear_inner_html=function(){var inner_html=this.get_inner_html();var clear=this.config.clearRegex;if(clear&&inner_html.match(clear))
this.set_inner_html('');}
proto.get_keybinding_area=function(){return this.get_edit_document();}
proto.get_edit_iframe=function(){var iframe;if(this.config.iframeId){iframe=document.getElementById(this.config.iframeId);iframe.iframe_hack=true;}
else if(this.config.iframeObject){iframe=this.config.iframeObject;iframe.iframe_hack=true;}
else{iframe=document.createElement('iframe');}
return iframe;}
proto.get_edit_window=function(){return this.edit_iframe.contentWindow;}
proto.get_edit_document=function(){return this.get_edit_window().document;}
proto.get_inner_html=function(){return this.get_edit_document().body.innerHTML;}
proto.set_inner_html=function(html){this.get_edit_document().body.innerHTML=html;}
proto.apply_stylesheets=function(styles){var styles=document.styleSheets;var doc=this.get_edit_document();var head=doc.getElementsByTagName("head")[0];if(!head){head=doc.createElement('head');doc.appendChild(head);}
var config=this.config;for(var i=0;i<styles.length;i++){var style=styles[i];if(style.href==location.href)
continue;var media=style.media;var use_parent=((!media.mediaText||media.mediaText=='screen')&&config.useParentStyles);var use_style=(media.mediaText&&(media.mediaText==config.useStyleMedia));if(!use_parent&&!use_style)
continue;var link=Wikiwyg.createElementWithAttrs('link',{href:style.href,type:style.type,media:'screen',rel:'STYLESHEET'},doc);head.appendChild(link);}}
proto.process_command=function(command){if(this['do_'+command])
this['do_'+command](command);if(!Wikiwyg.is_ie)
this.get_edit_window().focus();}
proto.exec_command=function(command,option){this.get_edit_document().execCommand(command,false,option);}
proto.format_command=function(command){this.exec_command('formatblock','<'+command+'>');}
proto.do_bold=proto.exec_command;proto.do_italic=proto.exec_command;proto.do_underline=proto.exec_command;proto.do_strike=function(){this.exec_command('strikethrough');}
proto.do_hr=function(){this.exec_command('inserthorizontalrule');}
proto.do_ordered=function(){this.exec_command('insertorderedlist');}
proto.do_unordered=function(){this.exec_command('insertunorderedlist');}
proto.do_indent=proto.exec_command;proto.do_outdent=proto.exec_command;proto.do_h1=proto.format_command;proto.do_h2=proto.format_command;proto.do_h3=proto.format_command;proto.do_h4=proto.format_command;proto.do_h5=proto.format_command;proto.do_h6=proto.format_command;proto.do_pre=proto.format_command;proto.do_p=proto.format_command;proto.do_spellcheck=function(){SC.buttonPress('wikidiv');}
proto.do_table=function(){var html='<table><tbody>'+'<tr><td>A</td>'+'<td>B</td>'+'<td>C</td></tr>'+'<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>'+'<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>'+'</tbody></table>';if(!Wikiwyg.is_ie)
this.get_edit_window().focus();this.insert_table(html);}
proto.insert_table=function(html){this.exec_command('inserthtml',html);}
proto.do_link=function(){var selection=this.get_link_selection_text();if(!selection)return;var url;var match=selection.match(/(.*?)\b((?:http|https|ftp|irc):\/\/\S+)(.*)/);if(match){if(match[1]||match[3])return null;url=match[2];}
else{url=window.prompt('URL:','');if(!url)return;}
this.exec_command('createlink',url);}
proto.get_selection_text=function(){return this.get_edit_window().getSelection().toString();}
proto.get_link_selection_text=function(){var selection=this.get_selection_text();if(!selection){alert("Please select the text you would like to turn into a link.");return;}
return selection;}
if(Wikiwyg.is_ie){proto.set_design_mode_early=function(wikiwyg){this.get_edit_window().onload=function(){this.get_edit_document().designMode='on';}}
proto.get_edit_window=function(){return this.edit_iframe;}
proto.get_edit_document=function(){return this.edit_iframe.contentWindow.document;}
proto.get_selection_text=function(){var selection=this.get_edit_document().selection;if(selection!=null)
return selection.createRange().htmlText;return'';}
proto.insert_table=function(html){var doc=this.get_edit_document();var range=this.get_edit_document().selection.createRange();if(range.boundingTop==2&&range.boundingLeft==2)
return;range.pasteHTML(html);range.collapse(false);range.select();}
proto.enable_keybindings=function(){}}
proto=new Subclass('Wikiwyg.Wikitext','Wikiwyg.Mode');klass=Wikiwyg.Wikitext;proto.classtype='wikitext';proto.modeDescription='Wiki Mode';proto.config={supportCamelCaseLinks:false,javascriptLocation:null,clearRegex:null,editHeightMinimum:10,editHeightAdjustment:1.3,markupRules:{link:['bound_phrase','\"','\"'],bold:['bound_phrase','**','**'],code:['bound_phrase','\'\'','\'\''],italic:['bound_phrase','*','*'],underline:['bound_phrase','_','_'],p:['start_lines','\n'],pre:['bound_phrase','::',''],h1:['bound_phrase','==','=='],h2:['bound_phrase','==','=='],h3:['bound_phrase','==','=='],ordered:['start_lines','#'],unordered:['start_lines','*'],indent:['start_lines','>'],hr:['line_alone','-----'],table:['line_alone','| A | B | C |\n|   |   |   |\n|   |   |   |']}}
proto.initializeObject=function(){this.initialize_object();}
proto.initialize_object=function(){this.div=document.createElement('div');this.textarea=document.createElement('textarea');this.textarea.setAttribute('id','wikiwyg_wikitext_textarea');this.div.appendChild(this.textarea);this.area=this.textarea;this.clear_inner_text();}
proto.clear_inner_text=function(){var self=this;this.area.onclick=function(){var inner_text=self.area.value;var clear=self.config.clearRegex;if(clear&&inner_text.match(clear))
self.area.value='';}}
proto.enableThis=function(){this.superfunc('enableThis').call(this);this.textarea.style.width='600';this.setHeightOfEditor();this.enable_keybindings();}
proto.setHeightOfEditor=function(){var config=this.config;var adjust=config.editHeightAdjustment;var area=this.textarea;var text=this.textarea.value;var rows=text.split(/\n/).length;var height=parseInt(rows*adjust);if(height<config.editHeightMinimum)
height=config.editHeightMinimum;area.setAttribute('rows',height);}
proto.toWikitext=function(){return this.textarea.value;}
proto.toHtml=function(func){var wikitext=this.textarea.value;this.convertWikitextToHtml(wikitext,func);}
proto.fromHtml=function(html){this.textarea.value='Loading...';var textarea=this.textarea;this.convertHtmlToWikitext(html,function(value){textarea.value=value});}
proto.convertWikitextToHtml=function(wikitext,func){alert('Wikitext changes cannot be converted to HTML\nWikiwyg.Wikitext.convertWikitextToHtml is not implemented here');func(this.copyhtml);}
proto.convertHtmlToWikitext=function(html,func){func(this.convert_html_to_wikitext(html));}
proto.get_keybinding_area=function(){return this.textarea;}
Wikiwyg.Wikitext.phrase_end_re=/[\s\.\:\;\,\!\?\(\)]/;proto.find_left=function(t,selection_start,matcher){var substring=t.substr(selection_start-1,1);var nextstring=t.substr(selection_start-2,1);if(selection_start==0)
return selection_start;if(substring.match(matcher)){if((substring!='.')||(nextstring.match(/\s/)))
return selection_start;}
return this.find_left(t,selection_start-1,matcher);}
proto.find_right=function(t,selection_end,matcher){var substring=t.substr(selection_end,1);var nextstring=t.substr(selection_end+1,1);if(selection_end>=t.length)
return selection_end;if(substring.match(matcher)){if((substring!='.')||(nextstring.match(/\s/)))
return selection_end;}
return this.find_right(t,selection_end+1,matcher);}
proto.get_lines=function(){t=this.area;var selection_start=t.selectionStart;var selection_end=t.selectionEnd;if(selection_start==null||selection_end==null)
return false
var our_text=t.value.replace(/\r/g,'');selection=our_text.substr(selection_start,selection_end-selection_start);selection_start=this.find_right(our_text,selection_start,/[^\r\n]/);selection_end=this.find_left(our_text,selection_end,/[^\r\n]/);this.selection_start=this.find_left(our_text,selection_start,/[\r\n]/);this.selection_end=this.find_right(our_text,selection_end,/[\r\n]/);t.setSelectionRange(selection_start,selection_end);t.focus();this.start=our_text.substr(0,this.selection_start);this.sel=our_text.substr(this.selection_start,this.selection_end-
this.selection_start);this.finish=our_text.substr(this.selection_end,our_text.length);return true;}
proto.alarm_on=function(){var area=this.area;var background=area.style.background;area.style.background='#f88';function alarm_off(){area.style.background=background;}
window.setTimeout(alarm_off,250);area.focus()}
proto.get_words=function(){function is_insane(selection){return selection.match(/\r?\n(\r?\n|\*+ |\#+ |\=+ )/);}
t=this.area;var selection_start=t.selectionStart;var selection_end=t.selectionEnd;if(selection_start==null||selection_end==null)
return false;var our_text=t.value.replace(/\r/g,'');selection=our_text.substr(selection_start,selection_end-selection_start);selection_start=this.find_right(our_text,selection_start,/(\S|\r?\n)/);if(selection_start>selection_end)
selection_start=selection_end;selection_end=this.find_left(our_text,selection_end,/(\S|\r?\n)/);if(selection_end<selection_start)
selection_end=selection_start;if(is_insane(selection)){this.alarm_on();return false;}
this.selection_start=this.find_left(our_text,selection_start,Wikiwyg.Wikitext.phrase_end_re);this.selection_end=this.find_right(our_text,selection_end,Wikiwyg.Wikitext.phrase_end_re);t.setSelectionRange(this.selection_start,this.selection_end);t.focus();this.start=our_text.substr(0,this.selection_start);this.sel=our_text.substr(this.selection_start,this.selection_end-
this.selection_start);this.finish=our_text.substr(this.selection_end,our_text.length);return true;}
proto.markup_is_on=function(start,finish){return(this.sel.match(start)&&this.sel.match(finish));}
proto.clean_selection=function(start,finish){this.sel=this.sel.replace(start,'');this.sel=this.sel.replace(finish,'');}
proto.toggle_same_format=function(start,finish){start=this.clean_regexp(start);finish=this.clean_regexp(finish);var start_re=new RegExp('^'+start);var finish_re=new RegExp(finish+'$');if(this.markup_is_on(start_re,finish_re)){this.clean_selection(start_re,finish_re);return true;}
return false;}
proto.clean_regexp=function(string){string=string.replace(/([\^\$\*\+\.\?\[\]\{\}])/g,'\\$1');return string;}
proto.set_text_and_selection=function(text,start,end){this.area.value=text;this.area.setSelectionRange(start,end);}
proto.add_markup_words=function(markup_start,markup_finish,example){if(this.toggle_same_format(markup_start,markup_finish)){this.selection_end=this.selection_end-
(markup_start.length+markup_finish.length);markup_start='';markup_finish='';}
if(this.sel.length==0){if(example)
this.sel=example;var text=this.start+markup_start+
this.sel+markup_finish+this.finish;var start=this.selection_start+markup_start.length;var end=this.selection_end+markup_start.length+this.sel.length;this.set_text_and_selection(text,start,end);}else{var text=this.start+markup_start+this.sel+
markup_finish+this.finish;var start=this.selection_start;var end=this.selection_end+markup_start.length+
markup_finish.length;this.set_text_and_selection(text,start,end);}
this.area.focus();}
proto.add_markup_lines=function(markup_start){var already_set_re=new RegExp('^'+this.clean_regexp(markup_start),'gm');var other_markup_re=/^(\^+|\=+|\*+|#+|>+|\:\:)/gm;var match;if(!markup_start.length){this.sel=this.sel.replace(other_markup_re,'');this.sel=this.sel.replace(/^\ +/gm,'');}
else if((markup_start=='::')&&this.sel.match(/^\S/m))
this.sel=this.sel.replace(/^/gm,markup_start);else if((!markup_start.match(/[\=\^]/))&&this.sel.match(already_set_re)){this.sel=this.sel.replace(already_set_re,'');if(markup_start!='    ')
this.sel=this.sel.replace(/^ */gm,'');}
else if(match=this.sel.match(other_markup_re))
if(markup_start=='::')
this.sel=this.sel.replace(/^/gm,markup_start);else if(markup_start.match(/[\=\^]/))
this.sel=this.sel.replace(other_markup_re,markup_start);else
this.sel=this.sel.replace(other_markup_re,function(match){return markup_start.times(match.length);});else if(this.sel.length>0)
this.sel=this.sel.replace(/^(.*\S+)/gm,markup_start+' $1');else
this.sel=markup_start+' ';var text=this.start+this.sel+this.finish;var start=this.selection_start;var end=this.selection_start+this.sel.length;this.set_text_and_selection(text,start,end);this.area.focus();}
proto.bound_markup_lines=function(markup_array){var markup_start=markup_array[1];var markup_finish=markup_array[2];var already_start=new RegExp('^'+this.clean_regexp(markup_start),'gm');var already_finish=new RegExp(this.clean_regexp(markup_finish)+'$','gm');var other_start=/^(\^+|\=+|\*+|#+|>+) */gm;var other_finish=/( +(\^+|\=+))?$/gm;var match;if(this.sel.match(already_start)){this.sel=this.sel.replace(already_start,'');this.sel=this.sel.replace(already_finish,'');}
else if(match=this.sel.match(other_start)){this.sel=this.sel.replace(other_start,markup_start);this.sel=this.sel.replace(other_finish,markup_finish);}
else if(this.sel.length>0){this.sel=this.sel.replace(/^(.*\S+)/gm,markup_start+'$1'+markup_finish);}
else
this.sel=markup_start+markup_finish;var text=this.start+this.sel+this.finish;var start=this.selection_start;var end=this.selection_start+this.sel.length;this.set_text_and_selection(text,start,end);this.area.focus();}
proto.markup_bound_line=function(markup_array){var scroll_top=this.area.scrollTop;if(this.get_lines())
this.bound_markup_lines(markup_array);this.area.scrollTop=scroll_top;}
proto.markup_start_line=function(markup_array){var markup_start=markup_array[1];markup_start=markup_start.replace(/ +/,'');var scroll_top=this.area.scrollTop;if(this.get_lines())
this.add_markup_lines(markup_start);this.area.scrollTop=scroll_top;}
proto.markup_start_lines=function(markup_array){var markup_start=markup_array[1];var scroll_top=this.area.scrollTop;if(this.get_lines())
this.add_markup_lines(markup_start);this.area.scrollTop=scroll_top;}
proto.markup_bound_phrase=function(markup_array){var markup_start=markup_array[1];var markup_finish=markup_array[2];var scroll_top=this.area.scrollTop;if(markup_finish=='undefined')
markup_finish=markup_start;if(this.get_words())
this.add_markup_words(markup_start,markup_finish,null);this.area.scrollTop=scroll_top;}
klass.make_do=function(style){return function(){var markup=this.config.markupRules[style];var handler=markup[0];if(!this['markup_'+handler])
die('No handler for markup: "'+handler+'"');this['markup_'+handler](markup);}}
proto.do_link=klass.make_do('link');proto.do_bold=klass.make_do('bold');proto.do_code=klass.make_do('code');proto.do_italic=klass.make_do('italic');proto.do_underline=klass.make_do('underline');proto.do_strike=klass.make_do('strike');proto.do_p=klass.make_do('p');proto.do_pre=klass.make_do('pre');proto.do_h1=klass.make_do('h1');proto.do_h2=klass.make_do('h2');proto.do_h3=klass.make_do('h3');proto.do_h4=klass.make_do('h4');proto.do_h5=klass.make_do('h5');proto.do_h6=klass.make_do('h6');proto.do_ordered=klass.make_do('ordered');proto.do_unordered=klass.make_do('unordered');proto.do_hr=klass.make_do('hr');proto.do_table=klass.make_do('table');proto.do_dent=function(method){var scroll_top=this.area.scrollTop;if(!this.get_lines()){this.area.scrollTop=scroll_top;return;}
if(method(this)){var text=this.start+this.sel+this.finish;var start=this.selection_start;var end=this.selection_start+this.sel.length;this.set_text_and_selection(text,start,end);}
this.area.focus();}
proto.do_indent=function(){this.do_dent(function(that){if(that.sel=='')return false;that.sel=that.sel.replace(/^(([\*\-\#])+(?=\s))/gm,'$2$1');that.sel=that.sel.replace(/^([\>\=])/gm,'$1$1');that.sel=that.sel.replace(/^([^\>\*\-\#\=\r\n])/gm,'> $1');that.sel=that.sel.replace(/^\={7,}/gm,'======');return true;})}
proto.do_outdent=function(){this.do_dent(function(that){if(that.sel=='')return false;that.sel=that.sel.replace(/^([\>\*\-\#\=] ?)/gm,'');return true;})}
proto.markup_line_alone=function(markup_array){var t=this.area;var scroll_top=t.scrollTop;var selection_start=t.selectionStart;var text=t.value;this.selection_start=this.find_right(text,selection_start,/\r?\n/);this.selection_end=this.selection_start;t.setSelectionRange(this.selection_start,this.selection_start);t.focus();var markup=markup_array[1];this.start=t.value.substr(0,this.selection_start);this.finish=t.value.substr(this.selection_end,t.value.length);var text=this.start+'\n'+markup+this.finish;var start=this.selection_start+markup.length+1;var end=this.selection_end+markup.length+1;this.set_text_and_selection(text,start,end);t.scrollTop=scroll_top;}
proto.convert_html_to_wikitext=function(html){this.copyhtml=html;var dom=document.createElement('div');html=html.replace(/<!-=-/g,'<!--').replace(/-=->/g,'-->');dom.innerHTML=html;this.output=[];this.list_type=[];this.indent_level=0;this.walk(dom);this.assert_new_line();return this.join_output(this.output);}
proto.appendOutput=function(string){this.output.push(string);}
proto.join_output=function(output){var list=this.remove_stops(output);list=this.cleanup_output(list);return list.join('');}
proto.cleanup_output=function(list){return list;}
proto.remove_stops=function(list){var clean=[];for(var i=0;i<list.length;i++){if(typeof(list[i])!='string')continue;clean.push(list[i]);}
return clean;}
proto.walk=function(element){if(!element)return;for(var part=element.firstChild;part;part=part.nextSibling){if(part.nodeType==1){this.dispatch_formatter(part);}
else if(part.nodeType==3){if(part.nodeValue.match(/\S/)){var string=part.nodeValue;if(!string.match(/^[\.\,\?\!\)]/)){this.assert_space_or_newline();string=this.trim(string);}
this.appendOutput(this.collapse(string));}}}}
proto.walk_pre=function(element,prefix){if(!element)return;for(var part=element.firstChild;part;part=part.nextSibling){if(part.nodeType==1){this.dispatch_formatter(part);}
else if(part.nodeType==3){if(part.nodeValue.match(/\S/)){var string=part.nodeValue;if(!string.match(/^[\.\,\?\!\)]/)){this.assert_space_or_newline();string=this.trim(string);}
this.appendOutput(prefix+this.collapse(string));}}}}
proto.dispatch_formatter=function(element){var dispatch='format_'+element.nodeName.toLowerCase();if(!this[dispatch])
dispatch='handle_undefined';this[dispatch](element);}
proto.skip=function(){}
proto.pass=function(element){this.walk(element);}
proto.handle_undefined=function(element){this.appendOutput('<'+element.nodeName+'>');this.walk(element);this.appendOutput('</'+element.nodeName+'>');}
proto.handle_undefined=proto.skip;proto.format_abbr=proto.pass;proto.format_acronym=proto.pass;proto.format_address=proto.pass;proto.format_applet=proto.skip;proto.format_area=proto.skip;proto.format_basefont=proto.skip;proto.format_base=proto.skip;proto.format_bgsound=proto.skip;proto.format_big=proto.pass;proto.format_blink=proto.pass;proto.format_body=proto.pass;proto.format_br=proto.skip;proto.format_button=proto.skip;proto.format_caption=proto.pass;proto.format_center=proto.pass;proto.format_cite=proto.pass;proto.format_col=proto.pass;proto.format_colgroup=proto.pass;proto.format_dd=proto.pass;proto.format_dfn=proto.pass;proto.format_dl=proto.pass;proto.format_dt=proto.pass;proto.format_embed=proto.skip;proto.format_field=proto.skip;proto.format_fieldset=proto.skip;proto.format_font=proto.pass;proto.format_form=proto.skip;proto.format_frame=proto.skip;proto.format_frameset=proto.skip;proto.format_head=proto.skip;proto.format_html=proto.pass;proto.format_iframe=proto.pass;proto.format_input=proto.skip;proto.format_ins=proto.pass;proto.format_isindex=proto.skip;proto.format_label=proto.skip;proto.format_legend=proto.skip;proto.format_link=proto.skip;proto.format_map=proto.skip;proto.format_marquee=proto.skip;proto.format_meta=proto.skip;proto.format_multicol=proto.pass;proto.format_nobr=proto.skip;proto.format_noembed=proto.skip;proto.format_noframes=proto.skip;proto.format_nolayer=proto.skip;proto.format_noscript=proto.skip;proto.format_nowrap=proto.skip;proto.format_object=proto.skip;proto.format_optgroup=proto.skip;proto.format_option=proto.skip;proto.format_param=proto.skip;proto.format_select=proto.skip;proto.format_small=proto.pass;proto.format_spacer=proto.skip;proto.format_style=proto.skip;proto.format_sub=proto.pass;proto.format_submit=proto.skip;proto.format_sup=proto.pass;proto.format_tbody=proto.pass;proto.format_textarea=proto.skip;proto.format_tfoot=proto.pass;proto.format_thead=proto.pass;proto.format_wiki=proto.pass;proto.format_img=function(element){var uri=element.getAttribute('src');if(uri){this.assert_space_or_newline();this.appendOutput(uri);}}
proto.format_blockquote=function(element){if(!this.indent_level){this.assert_new_line();this.indent_level++;this.insert_new_line();}
else{this.indent_level++;this.assert_new_line();}
this.walk(element);this.indent_level--;if(!this.indent_level)
this.assert_blank_line();else
this.assert_new_line();}
proto.format_div=function(element){if(this.is_opaque(element)){this.handle_opaque_block(element);return;}
this.walk(element);}
proto.format_span=function(element){if(this.is_opaque(element)){this.handle_opaque_phrase(element);return;}
var style=element.getAttribute('style');if(!style){this.pass(element);return;}
this.assert_space_or_newline();if(style.match(/\bbold\b/))
this.appendOutput(this.config.markupRules.bold[1]);if(style.match(/\bitalic\b/))
this.appendOutput(this.config.markupRules.italic[1]);if(style.match(/\bunderline\b/))
this.appendOutput(this.config.markupRules.underline[1]);if(style.match(/\bline-through\b/))
this.appendOutput(this.config.markupRules.strike[1]);this.no_following_whitespace();this.walk(element);if(style.match(/\bline-through\b/))
this.appendOutput(this.config.markupRules.strike[2]);if(style.match(/\bunderline\b/))
this.appendOutput(this.config.markupRules.underline[2]);if(style.match(/\bitalic\b/))
this.appendOutput(this.config.markupRules.italic[2]);if(style.match(/\bbold\b/))
this.appendOutput(this.config.markupRules.bold[2]);}
klass.make_format=function(style){return function(element){var markup=this.config.markupRules[style];var handler=markup[0];this['handle_'+handler](element,markup);}}
proto.format_b=klass.make_format('bold');proto.format_strong=proto.format_b;proto.format_code=klass.make_format('code');proto.format_kbd=proto.format_code;proto.format_samp=proto.format_code;proto.format_tt=proto.format_code;proto.format_var=proto.format_code;proto.format_i=klass.make_format('italic');proto.format_em=proto.format_i;proto.format_u=klass.make_format('underline');proto.format_strike=klass.make_format('strike');proto.format_del=proto.format_strike;proto.format_s=proto.format_strike;proto.format_hr=klass.make_format('hr');proto.format_h1=klass.make_format('h1');proto.format_h2=klass.make_format('h2');proto.format_h3=klass.make_format('h3');proto.format_h4=klass.make_format('h4');proto.format_h5=klass.make_format('h5');proto.format_h6=klass.make_format('h6');proto.format_p=function(element){this.assert_blank_line();this.walk(element);this.assert_blank_line();}
proto.format_a=function(element){var label=Wikiwyg.htmlUnescape(element.innerHTML);label=label.replace(/<[^>]*?>/g,' ');label=label.replace(/\s+/g,' ');label=label.replace(/^\s+/,'');label=label.replace(/\s+$/,'');this.make_wikitext_link(label,element.getAttribute('href'),element);}
proto.format_table=function(element){this.assert_blank_line();this.walk(element);this.assert_blank_line();}
proto.format_tr=function(element){this.walk(element);this.appendOutput('|');this.insert_new_line();}
proto.format_td=function(element){this.appendOutput('| ');this.walk(element);this.appendOutput(' ');}
proto.format_th=proto.format_td;proto.format_ol=function(element){if(!this.list_type.length)
this.assert_blank_line();else
this.assert_new_line();this.list_type.push('ordered');this.walk(element);this.list_type.pop();if(!this.list_type.length)
this.assert_blank_line();}
proto.format_ul=function(element){if(!this.list_type.length)
this.assert_blank_line();else
this.assert_new_line();this.list_type.push('unordered');this.walk(element);this.list_type.pop();if(!this.list_type.length)
this.assert_blank_line();}
proto.format_li=function(element){var level=this.list_type.length;if(!level)die("List error");var type=this.list_type[level-1];var markup=this.config.markupRules[type];this.appendOutput('\n'+' '.times(2*(level-1))+markup[1]);this.walk(element);this.chomp();this.insert_new_line();}
proto.format_pre=function(element){var level;var prefix;var parentNode=this.parentNode;if(!parentNode){level=1;}else{level=parentNode.list_type.length;if(!level)level=1;}
var markup=this.config.markupRules['pre'];this.appendOutput('::\n');prefix='\n'+' '.times(2*level);this.walk_pre(element,prefix);this.chomp();this.insert_new_line();}
proto.chomp=function(){var string;while(this.output.length){string=this.output.pop();if(typeof(string)!='string'){this.appendOutput(string);return;}
if(!string.match(/^\n>+ $/)&&string.match(/\S/))
break;}
if(string){string=string.replace(/[\r\n\s]+$/,'');this.appendOutput(string);}}
proto.collapse=function(string){return string.replace(/[ \r\n]+/g,' ');}
proto.trim=function(string){return string.replace(/^\s+/,'').replace(/\s+$/,'');}
proto.insert_new_line=function(){var fang='';if(this.indent_level>0)
fang='>'.times(this.indent_level)+' ';if(this.output.length)
this.appendOutput('\n'+fang);else if(fang.length)
this.appendOutput(fang);}
proto.assert_new_line=function(){this.chomp();this.insert_new_line();}
proto.assert_blank_line=function(){this.chomp();this.insert_new_line();this.insert_new_line();}
proto.assert_space_or_newline=function(){var string;if(!this.output.length)return;string=this.output[this.output.length-1];if(!string.whitespace&&!string.match(/\s+$/))
this.appendOutput(' ');}
proto.no_following_whitespace=function(){this.appendOutput({whitespace:'stop'});}
proto.handle_bound_phrase=function(element,markup){this.assert_space_or_newline();this.appendOutput(markup[1]);this.no_following_whitespace();this.walk(element);this.appendOutput(markup[2]);}
proto.handle_bound_line=function(element,markup){this.assert_blank_line();this.appendOutput(markup[1]);this.walk(element);this.appendOutput(markup[2]);this.assert_blank_line();}
proto.handle_start_line=function(element,markup){this.assert_blank_line();this.appendOutput(markup[1]);this.walk(element);this.assert_blank_line();}
proto.handle_start_lines=function(element,markup){var text=element.firstChild.nodeValue;if(!text)return;this.assert_blank_line();text=text.replace(/^/mg,markup[1]);this.appendOutput(text);this.assert_blank_line();}
proto.handle_line_alone=function(element,markup){this.assert_blank_line();this.appendOutput(markup[1]);this.assert_blank_line();}
proto.get_first_comment=function(element){var comment=element.firstChild;if(comment&&(comment.nodeType==8))
return comment;else
return null;}
proto.is_opaque=function(element){var comment=this.get_first_comment(element);if(!comment)return false;var text=comment.data;if(text.match(/^\s*wiki:/))return true;return false;}
proto.handle_opaque_phrase=function(element){var comment=this.get_first_comment(element);if(comment){var text=comment.data;text=text.replace(/^ wiki:\s+/,'');text=text.replace(/\s$/,'');this.assert_space_or_newline();this.appendOutput(text);this.assert_space_or_newline();}}
proto.handle_opaque_block=function(element){var comment=this.get_first_comment(element);if(!comment)return;var text=comment.data;text=text.replace(/^\s*wiki:\s+/,'');this.appendOutput(text);}
proto.make_wikitext_link=function(label,href,element){var before=this.config.markupRules.link[1];var after=this.config.markupRules.link[2];this.assert_space_or_newline();if(!href){this.appendOutput(label);}
else if(href==label){this.appendOutput(href);}
else if(this.href_is_wiki_link(href)){if(this.camel_case_link(label))
this.appendOutput(label);else
this.appendOutput(before+label+after);}
else{this.appendOutput(before+label+after+':'+href);}}
proto.camel_case_link=function(label){if(!this.config.supportCamelCaseLinks)
return false;return label.match(/[a-z][A-Z]/);}
proto.href_is_wiki_link=function(href){if(!this.looks_like_a_url(href))
return true;if(!href.match(/\?/))
return false;var no_arg_input=href.split('?')[0];var no_arg_current=location.href.split('?')[0];return no_arg_input==no_arg_current;}
proto.looks_like_a_url=function(string){return string.match(/^(http|https|ftp|irc|mailto):/);}
if(Wikiwyg.is_ie){proto.setHeightOf=function(){this.textarea.style.height='200px';}
proto.initializeObject=function(){this.initialize_object();this.area.addBehavior(this.config.javascriptLocation+"Selection.htc");}}
