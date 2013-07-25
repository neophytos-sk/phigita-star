
Gecko._pluginInfo={name:"Gecko",origin:"Xinha Core",version:"$LastChangedRevision: 707 $".replace(/^[^:]*: (.*) \$$/,'$1'),developer:"The Xinha Core Developer Team",developer_url:"$HeadURL: http://svn.xinha.python-hosting.com/trunk/modules/Gecko/Gecko.js $".replace(/^[^:]*: (.*) \$$/,'$1'),sponsor:"",sponsor_url:"",license:"htmlArea"};function Gecko(editor){this.editor=editor;editor.Gecko=this;}
Gecko.prototype.onKeyPress=function(ev)
{var editor=this.editor;var s=editor.getSelection();if(editor.isShortCut(ev))
{switch(editor.getKey(ev).toLowerCase())
{case'z':{if(editor._unLink&&editor._unlinkOnUndo)
{Xinha._stopEvent(ev);editor._unLink();editor.updateToolbar();return true;}}
break;case'a':{sel=editor.getSelection();sel.removeAllRanges();range=editor.createRange();range.selectNodeContents(editor._doc.body);sel.addRange(range);Xinha._stopEvent(ev);return true;}
break;case'v':{if(!editor.config.htmlareaPaste)
{return true;}}
break;}}
switch(editor.getKey(ev))
{case' ':{var autoWrap=function(textNode,tag)
{var rightText=textNode.nextSibling;if(typeof tag=='string')
{tag=editor._doc.createElement(tag);}
var a=textNode.parentNode.insertBefore(tag,rightText);Xinha.removeFromParent(textNode);a.appendChild(textNode);rightText.data=' '+rightText.data;s.collapse(rightText,1);editor._unLink=function()
{var t=a.firstChild;a.removeChild(t);a.parentNode.insertBefore(t,a);Xinha.removeFromParent(a);editor._unLink=null;editor._unlinkOnUndo=false;};editor._unlinkOnUndo=true;return a;};if(editor.config.convertUrlsToLinks&&s&&s.isCollapsed&&s.anchorNode.nodeType==3&&s.anchorNode.data.length>3&&s.anchorNode.data.indexOf('.')>=0)
{var midStart=s.anchorNode.data.substring(0,s.anchorOffset).search(/\S{4,}$/);if(midStart==-1)
{break;}
if(editor._getFirstAncestor(s,'a'))
{break;}
var matchData=s.anchorNode.data.substring(0,s.anchorOffset).replace(/^.*?(\S*)$/,'$1');var mEmail=matchData.match(Xinha.RE_email);if(mEmail)
{var leftTextEmail=s.anchorNode;var rightTextEmail=leftTextEmail.splitText(s.anchorOffset);var midTextEmail=leftTextEmail.splitText(midStart);autoWrap(midTextEmail,'a').href='mailto:'+mEmail[0];break;}
RE_date=/([0-9]+\.)+/;RE_ip=/(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/;var mUrl=matchData.match(Xinha.RE_url);if(mUrl)
{if(RE_date.test(matchData))
{if(!RE_ip.test(matchData))
{break;}}
var leftTextUrl=s.anchorNode;var rightTextUrl=leftTextUrl.splitText(s.anchorOffset);var midTextUrl=leftTextUrl.splitText(midStart);autoWrap(midTextUrl,'a').href=(mUrl[1]?mUrl[1]:'http://')+mUrl[2];break;}}}
break;}
switch(ev.keyCode)
{case 27:{if(editor._unLink)
{editor._unLink();Xinha._stopEvent(ev);}
break;}
break;case 37:{var range=editor._createRange(s);if(range.collapsed)
{var blocks=["a","span"];var l=editor._getFirstAncestor(s,blocks);if(l)
if(range.startOffset==0)
{range.setStartBefore(l);range.setEndBefore(l);Xinha._stopEvent(ev);}}
break;}
case 39:{var range=editor._createRange(s);if(range.collapsed)
{var blocks=["a","span"];var l=editor._getFirstAncestor(s,blocks);if(l)
if(range.startOffset==range.startContainer.length)
{if(l.nextSibling&&l.nextSibling.tagName!="BR")
range.setEnd(l.nextSibling,0);else
range.setEndAfter(l);range.collapse(false);Xinha._stopEvent(ev);}}
break;}
case 8:case 46:{var sel=this.editor.getSelection();var rng=this.editor.createRange(sel);var blocks=["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","body"];var _xo_first_ancestor_node=this.editor._getFirstAncestor(this.editor._getSelection(),blocks);var _xo_regexp=/(\&nbsp\;|\<br[^\>]*\>|\s)*/g;var _xo_merge_paragraphs=false;var _xo_FAN=_xo_first_ancestor_node;var _xo_PS=_xo_FAN.previousSibling;var _xo_NS=_xo_FAN.nextSibling;if(_xo_FAN.nodeType==Node.ELEMENT_NODE)
{if(rng.collapsed)
{if(ev.keyCode==8)
if(rng.startOffset>0)
{if(_xo_FAN.innerHTML.replace(_xo_regexp,"").length<=1)
if(rng.startContainer.textContent[rng.startOffset-1].replace(_xo_regexp,"").length==1)
_xo_merge_paragraphs=true;}
else _xo_merge_paragraphs=true;if(ev.keyCode==46)
if(rng.endOffset<rng.endContainer.length)
{if(_xo_FAN.innerHTML.replace(_xo_regexp,"").length<=1)
if(rng.endContainer.textContent[rng.endOffset].replace(_xo_regexp,"").length==1)
_xo_merge_paragraphs=true;}
else _xo_merge_paragraphs=true;}
else
{if(_xo_FAN.innerHTML.replace(_xo_regexp,"").length-rng.toString().replace(_xo_regexp,"").length==0)
_xo_merge_paragraphs=true;}}
if(_xo_merge_paragraphs)
{if(ev.keyCode==8&&_xo_PS)
if(_xo_PS.tagName=="P")
{rng.selectNodeContents(_xo_FAN);var _xo_DF=rng.extractContents();rng.selectNodeContents(_xo_PS);rng.collapse(false);_xo_PS.appendChild(_xo_DF);Xinha.removeFromParent(_xo_FAN);Xinha._stopEvent(ev);}
if(ev.keyCode==46&&_xo_NS)
if(_xo_NS.tagName=="P")
{rng.selectNodeContents(_xo_NS);var _xo_DF=rng.extractContents();rng.selectNodeContents(_xo_FAN);rng.collapse(false);_xo_FAN.appendChild(_xo_DF);Xinha.removeFromParent(_xo_NS);Xinha._stopEvent(ev);}}
if(!ev.shiftKey&&this.handleBackspace())
{Xinha._stopEvent(ev);}}
default:{editor._unlinkOnUndo=false;if(s.anchorNode&&s.anchorNode.nodeType==3)
{var a=editor._getFirstAncestor(s,'a');if(!a)
{break;}
if(!a._updateAnchTimeout)
{if(s.anchorNode.data.match(Xinha.RE_email)&&a.href.match('mailto:'+s.anchorNode.data.trim()))
{var textNode=s.anchorNode;var fnAnchor=function()
{a.href='mailto:'+textNode.data.trim();a._updateAnchTimeout=setTimeout(fnAnchor,250);};a._updateAnchTimeout=setTimeout(fnAnchor,1000);break;}
var m=s.anchorNode.data.match(Xinha.RE_url);if(m&&a.href.match(s.anchorNode.data.trim()))
{var txtNode=s.anchorNode;var fnUrl=function()
{m=txtNode.data.match(Xinha.RE_url);if(m)
{a.href=(m[1]?m[1]:'http://')+m[2];}
a._updateAnchTimeout=setTimeout(fnUrl,250);};a._updateAnchTimeout=setTimeout(fnUrl,1000);}}}}
break;}
return false;}
Gecko.prototype.handleBackspace=function()
{var editor=this.editor;setTimeout(function()
{var sel=editor.getSelection();var range=editor.createRange(sel);var SC=range.startContainer;var SO=range.startOffset;var EC=range.endContainer;var EO=range.endOffset;var newr=SC.nextSibling;if(SC.nodeType==3)
{SC=SC.parentNode;}
if(!(/\S/.test(SC.tagName)))
{var p=document.createElement("p");while(SC.firstChild)
{p.appendChild(SC.firstChild);}
SC.parentNode.insertBefore(p,SC);Xinha.removeFromParent(SC);var r=range.cloneRange();r.setStartBefore(newr);r.setEndAfter(newr);r.extractContents();sel.removeAllRanges();sel.addRange(r);}},10);};Gecko.prototype.inwardHtml=function(html)
{html=html.replace(/<(\/?)strong(\s|>|\/)/ig,"<$1b$2");html=html.replace(/<(\/?)em(\s|>|\/)/ig,"<$1i$2");html=html.replace(/<(\/?)del(\s|>|\/)/ig,"<$1strike$2");return html;}
Gecko.prototype.outwardHtml=function(html)
{html=html.replace(/<script[\s]*src[\s]*=[\s]*['"]chrome:\/\/.*?["']>[\s]*<\/script>/ig,'');return html;}
Gecko.prototype.onExecCommand=function(cmdID,UI,param)
{try
{this.editor._doc.execCommand('useCSS',false,true);this.editor._doc.execCommand('styleWithCSS',false,false);}catch(ex){}
switch(cmdID)
{case'paste':{alert(Xinha._lc("The Paste button does not work in Mozilla based web browsers (technical security reasons). Press CTRL-V on your keyboard to paste directly."));return true;}}
return false;}
Xinha.prototype.insertNodeAtSelection=function(toBeInserted)
{var sel=this.getSelection();var range=this.createRange(sel);sel.removeAllRanges();range.deleteContents();var node=range.startContainer;var pos=range.startOffset;var selnode=toBeInserted;switch(node.nodeType)
{case 3:if(toBeInserted.nodeType==3)
{node.insertData(pos,toBeInserted.data);range=this.createRange();range.setEnd(node,pos+toBeInserted.length);range.setStart(node,pos+toBeInserted.length);sel.addRange(range);}
else
{node=node.splitText(pos);if(toBeInserted.nodeType==11)
{selnode=selnode.firstChild;}
node.parentNode.insertBefore(toBeInserted,node);this.selectNodeContents(selnode);this.updateToolbar();}
break;case 1:if(toBeInserted.nodeType==11)
{selnode=selnode.firstChild;}
node.insertBefore(toBeInserted,node.childNodes[pos]);this.selectNodeContents(selnode);this.updateToolbar();break;}};Xinha.prototype.getParentElement=function(sel)
{if(typeof sel=='undefined')
{sel=this.getSelection();}
var range=this.createRange(sel);try
{var p=range.commonAncestorContainer;if(!range.collapsed&&range.startContainer==range.endContainer&&range.startOffset-range.endOffset<=1&&range.startContainer.hasChildNodes())
{p=range.startContainer.childNodes[range.startOffset];}
while(p.nodeType==3)
{p=p.parentNode;}
return p;}
catch(ex)
{return null;}};Xinha.prototype.activeElement=function(sel)
{if((sel===null)||this.selectionEmpty(sel))
{return null;}
if(!sel.isCollapsed)
{if(sel.anchorNode.childNodes.length>sel.anchorOffset&&sel.anchorNode.childNodes[sel.anchorOffset].nodeType==1)
{return sel.anchorNode.childNodes[sel.anchorOffset];}
else if(sel.anchorNode.nodeType==1)
{return sel.anchorNode;}
else
{return null;}}
return null;};Xinha.prototype.selectionEmpty=function(sel)
{if(!sel)
{return true;}
if(typeof sel.isCollapsed!='undefined')
{return sel.isCollapsed;}
return true;};Xinha.prototype.selectNodeContents=function(node,pos)
{this.focusEditor();this.forceRedraw();var range;var collapsed=typeof pos=="undefined"?true:false;var sel=this.getSelection();range=this._doc.createRange();if(collapsed&&node.tagName&&node.tagName.toLowerCase().match(/table|img|input|textarea|select/))
{range.selectNode(node);}
else
{range.selectNodeContents(node);}
sel.removeAllRanges();sel.addRange(range);};Xinha.prototype.insertHTML=function(html)
{var sel=this.getSelection();var range=this.createRange(sel);this.focusEditor();var fragment=this._doc.createDocumentFragment();var div=this._doc.createElement("div");div.innerHTML=html;while(div.firstChild)
{fragment.appendChild(div.firstChild);}
var node=this.insertNodeAtSelection(fragment);};Xinha.prototype.getSelectedHTML=function()
{var sel=this.getSelection();var range=this.createRange(sel);return Xinha.getHTML(range.cloneContents(),false,this);};Xinha.prototype.getSelection=function()
{return this._iframe.contentWindow.getSelection();};Xinha.prototype.createRange=function(sel)
{this.activateEditor();if(typeof sel!="undefined")
{try
{return sel.getRangeAt(0);}
catch(ex)
{return this._doc.createRange();}}
else
{return this._doc.createRange();}};Xinha.prototype.isKeyEvent=function(event)
{return event.type=="keypress";}
Xinha.prototype.getKey=function(keyEvent)
{return String.fromCharCode(keyEvent.charCode);}
Xinha.getOuterHTML=function(element)
{return(new XMLSerializer()).serializeToString(element);};Xinha.prototype.cc=String.fromCharCode(173);Xinha.prototype.setCC=function(target)
{if(target=="textarea")
{var ta=this._textArea;var index=ta.selectionStart;var before=ta.value.substring(0,index)
var after=ta.value.substring(index,ta.value.length);if(after.match(/^[^<]*>/))
{var tagEnd=after.indexOf(">")+1;ta.value=before+after.substring(0,tagEnd)+this.cc+after.substring(tagEnd,after.length);}
else ta.value=before+this.cc+after;}
else
{var sel=this.getSelection();sel.getRangeAt(0).insertNode(document.createTextNode(this.cc));}};Xinha.prototype.findCC=function(target)
{var findIn=(target=='textarea')?window:this._iframe.contentWindow;if(findIn.find(this.cc))
{if(target=="textarea")
{var ta=this._textArea;var start=pos=ta.selectionStart;var end=ta.selectionEnd;var scrollTop=ta.scrollTop;ta.value=ta.value.substring(0,start)+ta.value.substring(end,ta.value.length);ta.selectionStart=pos;ta.selectionEnd=pos;ta.scrollTop=scrollTop
ta.focus();}
else
{var sel=this.getSelection();sel.getRangeAt(0).deleteContents();}}};Xinha.prototype._standardToggleBorders=Xinha.prototype._toggleBorders;Xinha.prototype._toggleBorders=function()
{var result=this._standardToggleBorders();var tables=this._doc.getElementsByTagName('TABLE');for(var i=0;i<tables.length;i++)
{tables[i].style.display="none";tables[i].style.display="table";}
return result;}
