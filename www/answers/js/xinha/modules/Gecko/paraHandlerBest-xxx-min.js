
EnterParagraphs._pluginInfo={name:"EnterParagraphs",version:"1.0",developer:"Adam Wright",developer_url:"http://www.hipikat.org/",sponsor:"The University of Western Australia",sponsor_url:"http://www.uwa.edu.au/",license:"htmlArea"};EnterParagraphs.prototype._whiteSpace=/^\s*$/;EnterParagraphs.prototype._pExclusions=/^(address|blockquote|body|dd|div|dl|dt|fieldset|form|h1|h2|h3|h4|h5|h6|hr|li|noscript|ol|p|pre|table|ul)$/i;EnterParagraphs.prototype._pContainers=/^(body|del|div|fieldset|form|ins|map|noscript|object|td|th)$/i;EnterParagraphs.prototype._pBreak=/^(address|pre|blockquote)$/i;EnterParagraphs.prototype._permEmpty=/^(area|base|basefont|br|col|frame|hr|img|input|isindex|link|meta|param)$/i;EnterParagraphs.prototype._elemSolid=/^(applet|br|button|hr|img|input|table)$/i;EnterParagraphs.prototype._pifySibling=/^(address|blockquote|del|div|dl|fieldset|form|h1|h2|h3|h4|h5|h6|hr|ins|map|noscript|object|ol|p|pre|table|ul|)$/i;EnterParagraphs.prototype._pifyForced=/^(ul|ol|dl|table)$/i;EnterParagraphs.prototype._pifyParent=/^(dd|dt|li|td|th|tr)$/i;function EnterParagraphs(editor)
{this.editor=editor;if(Xinha.is_gecko)
{this.onKeyPress=this.__onKeyPress;}}
EnterParagraphs.prototype.name="EnterParagraphs";EnterParagraphs.prototype.insertAdjacentElement=function(ref,pos,el)
{if(pos=='BeforeBegin')
{ref.parentNode.insertBefore(el,ref);}
else if(pos=='AfterEnd')
{ref.nextSibling?ref.parentNode.insertBefore(el,ref.nextSibling):ref.parentNode.appendChild(el);}
else if(pos=='AfterBegin'&&ref.firstChild)
{ref.insertBefore(el,ref.firstChild);}
else if(pos=='BeforeEnd'||pos=='AfterBegin')
{ref.appendChild(el);}};EnterParagraphs.prototype.forEachNodeUnder=function(root,mode,direction,init)
{var start,end;if(root.nodeType==11&&root.firstChild)
{start=root.firstChild;end=root.lastChild;}
else
{start=end=root;}
while(end.lastChild)
{end=end.lastChild;}
return this.forEachNode(start,end,mode,direction,init);};EnterParagraphs.prototype.forEachNode=function(left_node,right_node,mode,direction,init)
{var getSibling=function(elem,direction)
{return(direction=="ltr"?elem.nextSibling:elem.previousSibling);};var getChild=function(elem,direction)
{return(direction=="ltr"?elem.firstChild:elem.lastChild);};var walk,lookup,fnReturnVal;var next_node=init;var done_flag=false;while(walk!=direction=="ltr"?right_node:left_node)
{if(!walk)
{walk=direction=="ltr"?left_node:right_node;}
else
{if(getChild(walk,direction))
{walk=getChild(walk,direction);}
else
{if(getSibling(walk,direction))
{walk=getSibling(walk,direction);}
else
{lookup=walk;while(!getSibling(lookup,direction)&&lookup!=(direction=="ltr"?right_node:left_node))
{lookup=lookup.parentNode;}
walk=(getSibling(lookup,direction)?getSibling(lookup,direction):lookup);}}}
done_flag=(walk==(direction=="ltr"?right_node:left_node));switch(mode)
{case"cullids":fnReturnVal=this._fenCullIds(walk,next_node);break;case"find_fill":fnReturnVal=this._fenEmptySet(walk,next_node,mode,done_flag);break;case"find_cursorpoint":fnReturnVal=this._fenEmptySet(walk,next_node,mode,done_flag);break;}
if(fnReturnVal[0])
{return fnReturnVal[1];}
if(done_flag)
{break;}
if(fnReturnVal[1])
{next_node=fnReturnVal[1];}}
return false;};EnterParagraphs.prototype._fenEmptySet=function(node,next_node,mode,last_flag)
{if(!next_node&&!node.firstChild)
{next_node=node;}
if((node.nodeType==1&&this._elemSolid.test(node.nodeName))||(node.nodeType==3&&!this._whiteSpace.test(node.nodeValue))||(node.nodeType!=1&&node.nodeType!=3))
{switch(mode)
{case"find_fill":return new Array(true,false);break;case"find_cursorpoint":return new Array(true,node);break;}}
if(last_flag)
{return new Array(true,next_node);}
return new Array(false,next_node);};EnterParagraphs.prototype._fenCullIds=function(ep_ref,node,pong)
{if(node.id)
{pong[node.id]?node.id='':pong[node.id]=true;}
return new Array(false,pong);};EnterParagraphs.prototype.processSide=function(rng,search_direction)
{var next=function(element,search_direction)
{return(search_direction=="left"?element.previousSibling:element.nextSibling);};var node=search_direction=="left"?rng.startContainer:rng.endContainer;var offset=search_direction=="left"?rng.startOffset:rng.endOffset;var roam,start=node;while(start.nodeType==1&&!this._permEmpty.test(start.nodeName))
{start=(offset?start.lastChild:start.firstChild);}
while(roam=roam?(next(roam,search_direction)?next(roam,search_direction):roam.parentNode):start)
{if(next(roam,search_direction))
{if(this._pExclusions.test(next(roam,search_direction).nodeName))
{return this.processRng(rng,search_direction,roam,next(roam,search_direction),(search_direction=="left"?'AfterEnd':'BeforeBegin'),true,false);}}
else
{if(this._pContainers.test(roam.parentNode.nodeName))
{return this.processRng(rng,search_direction,roam,roam.parentNode,(search_direction=="left"?'AfterBegin':'BeforeEnd'),true,false);}
else if(this._pExclusions.test(roam.parentNode.nodeName))
{if(this._pBreak.test(roam.parentNode.nodeName))
{return this.processRng(rng,search_direction,roam,roam.parentNode,(search_direction=="left"?'AfterBegin':'BeforeEnd'),false,(search_direction=="left"?true:false));}
else
{return this.processRng(rng,search_direction,(roam=roam.parentNode),(next(roam,search_direction)?next(roam,search_direction):roam.parentNode),(next(roam,search_direction)?(search_direction=="left"?'AfterEnd':'BeforeBegin'):(search_direction=="left"?'AfterBegin':'BeforeEnd')),false,false);}}}}};EnterParagraphs.prototype.processRng=function(rng,search_direction,roam,neighbour,insertion,pWrap,preBr)
{var node=search_direction=="left"?rng.startContainer:rng.endContainer;var offset=search_direction=="left"?rng.startOffset:rng.endOffset;var editor=this.editor;var newRng=editor._doc.createRange();newRng.selectNode(roam);if(search_direction=="left")
{newRng.setEnd(node,offset);rng.setStart(newRng.startContainer,newRng.startOffset);}
else if(search_direction=="right")
{newRng.setStart(node,offset);rng.setEnd(newRng.endContainer,newRng.endOffset);}
var cnt=newRng.cloneContents();this.forEachNodeUnder(cnt,"cullids","ltr",this.takenIds,false,false);var pify,pifyOffset,fill;pify=search_direction=="left"?(newRng.endContainer.nodeType==3?true:false):(newRng.startContainer.nodeType==3?false:true);pifyOffset=pify?newRng.startOffset:newRng.endOffset;pify=pify?newRng.startContainer:newRng.endContainer;if(this._pifyParent.test(pify.nodeName)&&pify.parentNode.childNodes.item(0)==pify)
{while(!this._pifySibling.test(pify.nodeName))
{pify=pify.parentNode;}}
if(cnt.nodeType==11&&!cnt.firstChild)
{if(pify.nodeName!="BODY"||(pify.nodeName=="BODY"&&pifyOffset!=0))
{cnt.appendChild(editor._doc.createElement(pify.nodeName));}}
fill=this.forEachNodeUnder(cnt,"find_fill","ltr",false);if(fill&&this._pifySibling.test(pify.nodeName)&&((pifyOffset==0)||(pifyOffset==1&&this._pifyForced.test(pify.nodeName))))
{roam=editor._doc.createElement('p');roam.innerHTML="&nbsp;";if((search_direction=="left")&&pify.previousSibling)
{return new Array(pify.previousSibling,'AfterEnd',roam);}
else if((search_direction=="right")&&pify.nextSibling)
{return new Array(pify.nextSibling,'BeforeBegin',roam);}
else
{return new Array(pify.parentNode,(search_direction=="left"?'AfterBegin':'BeforeEnd'),roam);}}
if(fill)
{if(fill.nodeType==3)
{fill=editor._doc.createDocumentFragment();}
if((fill.nodeType==1&&!this._elemSolid.test())||fill.nodeType==11)
{var pterminator=editor._doc.createElement('p');pterminator.innerHTML="&nbsp;";fill.appendChild(pterminator);}
else
{var pterminator=editor._doc.createElement('p');pterminator.innerHTML="&nbsp;";fill.parentNode.insertBefore(parentNode,fill);}}
if(fill)
{roam=fill;}
else
{roam=(pWrap||(cnt.nodeType==11&&!cnt.firstChild))?editor._doc.createElement('p'):editor._doc.createDocumentFragment();roam.appendChild(cnt);}
if(preBr)
{roam.appendChild(editor._doc.createElement('br'));}
return new Array(neighbour,insertion,roam);};EnterParagraphs.prototype.isNormalListItem=function(rng)
{var node,listNode;node=rng.startContainer;if((typeof node.nodeName!='undefined')&&(node.nodeName.toLowerCase()=='li'))
{listNode=node;}
else if((typeof node.parentNode!='undefined')&&(typeof node.parentNode.nodeName!='undefined')&&(node.parentNode.nodeName.toLowerCase()=='li'))
{listNode=node.parentNode;}
else
{return false;}
if(!listNode.previousSibling)
{if(rng.startOffset==0)
{return false;}}
return true;};EnterParagraphs.prototype.__onKeyPress=function(ev)
{if(ev.keyCode==13&&!ev.shiftKey&&this.editor._iframe.contentWindow.getSelection)
{return this.handleEnter(ev);}
else if(ev.keyCode==13&&ev.shiftKey&&this.editor._iframe.contentWindow.getSelection)
{var _xo_first_ancestor_node=this.editor._getFirstAncestor(this.editor._getSelection(),"p");if(_xo_first_ancestor_node){Xinha._stopEvent(ev);return true;}}};EnterParagraphs.prototype.handleEnter=function(ev)
{var cursorNode;var sel=this.editor.getSelection();var rng=this.editor.createRange(sel);if(this.isNormalListItem(rng))
{return true;}
var blocks=["p","pre","h1","h2","h3","h4","h5","h6","code","ol","ul","body"];var _xo_first_ancestor_node=this.editor._getFirstAncestor(this.editor._getSelection(),blocks);var _xo_regexp=/(\&nbsp\;|\<br[^\>]*\>|\s)*/g;if(_xo_first_ancestor_node&&_xo_first_ancestor_node.nodeType==Node.ELEMENT_NODE)
{if(_xo_first_ancestor_node.innerHTML.replace(_xo_regexp,"").length==0){Xinha._stopEvent(ev);return true;}}
if(_xo_first_ancestor_node.nextSibling&&_xo_first_ancestor_node.nextSibling.nodeType==Node.ELEMENT_NODE)
{_xo_end_container=rng.endContainer;_xo_end_offset=rng.endOffset;_xo_start_container=rng.startContainer;_xo_start_offset=rng.startOffset;rng.setStart(_xo_end_container,_xo_end_offset);rng.setEndAfter(_xo_first_ancestor_node);_xo_text_to_end=rng.toString();rng.setStart(_xo_start_container,_xo_start_offset);rng.setEnd(_xo_end_container,_xo_end_offset);if(_xo_first_ancestor_node.nextSibling&&_xo_first_ancestor_node.nextSibling.innerHTML.replace(_xo_regexp,"").length==0&&_xo_text_to_end.replace(_xo_regexp,"").length==0){rng.deleteContents();rng.setEnd(_xo_first_ancestor_node.nextSibling,0);rng.setStart(_xo_first_ancestor_node.nextSibling,0);Xinha._stopEvent(ev);return true;}}
if(_xo_first_ancestor_node.previousSibling&&_xo_first_ancestor_node.previousSibling.nodeType==Node.ELEMENT_NODE)
{_xo_start_container=rng.startContainer;_xo_start_offset=rng.startOffset;_xo_end_container=rng.endContainer;_xo_end_offset=rng.endOffset;rng.setStart(_xo_first_ancestor_node,0);rng.setEnd(_xo_start_container,_xo_start_offset);_xo_text_to_start=rng.toString();rng.setStart(_xo_start_container,_xo_start_offset);rng.setEnd(_xo_end_container,_xo_end_offset);if(_xo_first_ancestor_node.previousSibling&&_xo_first_ancestor_node.previousSibling.innerHTML.replace(_xo_regexp,"").length==0&&_xo_text_to_start.replace(_xo_regexp,"").length==0){rng.deleteContents();Xinha._stopEvent(ev);return true;}}
this.takenIds=new Object();var pStart=this.processSide(rng,"left");var pEnd=this.processSide(rng,"right");cursorNode=pEnd[2];sel.removeAllRanges();rng.deleteContents();var holdEnd=this.forEachNodeUnder(cursorNode,"find_cursorpoint","ltr",false,true);if(!holdEnd)
{alert("INTERNAL ERROR - could not find place to put cursor after ENTER");}
if(pStart)
{this.insertAdjacentElement(pStart[0],pStart[1],pStart[2]);}
if(pEnd&&pEnd.nodeType!=1)
{this.insertAdjacentElement(pEnd[0],pEnd[1],pEnd[2]);}
if((holdEnd)&&(this._permEmpty.test(holdEnd.nodeName)))
{var prodigal=0;while(holdEnd.parentNode.childNodes.item(prodigal)!=holdEnd)
{prodigal++;}
sel.collapse(holdEnd.parentNode,prodigal);}
else
{try
{sel.collapse(holdEnd,0);if(holdEnd.nodeType==3)
{holdEnd=holdEnd.parentNode;}
this.editor.scrollToElement(holdEnd);}
catch(e)
{}}
this.editor.updateToolbar();Xinha._stopEvent(ev);return true;};
