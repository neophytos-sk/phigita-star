
InternetExplorer._pluginInfo={name:"Internet Explorer",origin:"Xinha Core",version:"$LastChangedRevision: 712 $".replace(/^[^:]*: (.*) \$$/,'$1'),developer:"The Xinha Core Developer Team",developer_url:"$HeadURL: http://svn.xinha.python-hosting.com/trunk/modules/InternetExplorer/InternetExplorer.js $".replace(/^[^:]*: (.*) \$$/,'$1'),sponsor:"",sponsor_url:"",license:"htmlArea"};function InternetExplorer(editor){this.editor=editor;editor.InternetExplorer=this;}
InternetExplorer.prototype.onKeyPress=function(ev)
{if(this.editor.isShortCut(ev))
{switch(this.editor.getKey(ev).toLowerCase())
{case'n':{this.editor.execCommand('formatblock',false,'<p>');Xinha._stopEvent(ev);return true;}
break;case'1':case'2':case'3':case'4':case'5':case'6':{this.editor.execCommand('formatblock',false,'<h'+this.editor.getKey(ev).toLowerCase()+'>');Xinha._stopEvent(ev);return true;}
break;}}
switch(ev.keyCode)
{case 8:case 46:{if(this.handleBackspace())
{Xinha._stopEvent(ev);return true;}}
break;}
return false;}
InternetExplorer.prototype.handleBackspace=function()
{var editor=this.editor;var sel=editor.getSelection();if(sel.type=='Control')
{var elm=editor.activeElement(sel);Xinha.removeFromParent(elm);return true;}
var range=editor.createRange(sel);var r2=range.duplicate();r2.moveStart("character",-1);var a=r2.parentElement();if(a!=range.parentElement()&&(/^a$/i.test(a.tagName)))
{r2.collapse(true);r2.moveEnd("character",1);r2.pasteHTML('');r2.select();return true;}};InternetExplorer.prototype.inwardHtml=function(html)
{html=html.replace(/<(\/?)del(\s|>|\/)/ig,"<$1strike$2");return html;}
Xinha.prototype.insertNodeAtSelection=function(toBeInserted)
{Xinha.notImplemented('insertNodeAtSelection');};Xinha.prototype.getParentElement=function(sel)
{if(typeof sel=='undefined')
{sel=this.getSelection();}
var range=this.createRange(sel);switch(sel.type)
{case"Text":var parent=range.parentElement();while(true)
{var TestRange=range.duplicate();TestRange.moveToElementText(parent);if(TestRange.inRange(range))
{break;}
if((parent.nodeType!=1)||(parent.tagName.toLowerCase()=='body'))
{break;}
parent=parent.parentElement;}
return parent;case"None":return range.parentElement();case"Control":return range.item(0);default:return this._doc.body;}};Xinha.prototype.activeElement=function(sel)
{if((sel===null)||this.selectionEmpty(sel))
{return null;}
if(sel.type.toLowerCase()=="control")
{return sel.createRange().item(0);}
else
{var range=sel.createRange();var p_elm=this.getParentElement(sel);if(p_elm.innerHTML==range.htmlText)
{return p_elm;}
return null;}};Xinha.prototype.selectionEmpty=function(sel)
{if(!sel)
{return true;}
return this.createRange(sel).htmlText==='';};Xinha.prototype.selectNodeContents=function(node,pos)
{this.focusEditor();this.forceRedraw();var range;var collapsed=typeof pos=="undefined"?true:false;if(collapsed&&node.tagName&&node.tagName.toLowerCase().match(/table|img|input|select|textarea/))
{range=this._doc.body.createControlRange();range.add(node);}
else
{range=this._doc.body.createTextRange();range.moveToElementText(node);}
range.select();};Xinha.prototype.insertHTML=function(html)
{var sel=this.getSelection();var range=this.createRange(sel);this.focusEditor();range.pasteHTML(html);};Xinha.prototype.getSelectedHTML=function()
{var sel=this.getSelection();var range=this.createRange(sel);if(range.htmlText)
{return range.htmlText;}
else if(range.length>=1)
{return range.item(0).outerHTML;}
return'';};Xinha.prototype.getSelection=function()
{return this._doc.selection;};Xinha.prototype.createRange=function(sel)
{return sel.createRange();};Xinha.prototype.isKeyEvent=function(event)
{return event.type=="keydown";}
Xinha.prototype.getKey=function(keyEvent)
{return String.fromCharCode(keyEvent.keyCode);}
Xinha.getOuterHTML=function(element)
{return element.outerHTML;};Xinha.prototype.cc=String.fromCharCode(0x2009);Xinha.prototype.setCC=function(target)
{if(target=="textarea")
{var ta=this._textArea;var pos=document.selection.createRange();pos.collapse();pos.text=this.cc;var index=ta.value.indexOf(this.cc);var before=ta.value.substring(0,index);var after=ta.value.substring(index+this.cc.length,ta.value.length);if(after.match(/^[^<]*>/))
{var tagEnd=after.indexOf(">")+1;ta.value=before+after.substring(0,tagEnd)+this.cc+after.substring(tagEnd,after.length);}
else ta.value=before+this.cc+after;}
else
{var sel=this.getSelection();var r=sel.createRange();if(sel.type=='Control')
{var control=r.item(0);control.outerHTML+=this.cc;}
else
{r.collapse();r.text=this.cc;}}};Xinha.prototype.findCC=function(target)
{var findIn=(target=='textarea')?this._textArea:this._doc.body;range=findIn.createTextRange();if(range.findText(escape(this.cc)))
{range.select();range.text='';}
if(range.findText(this.cc))
{range.select();range.text='';}
if(target=='textarea')this._textArea.focus();};
