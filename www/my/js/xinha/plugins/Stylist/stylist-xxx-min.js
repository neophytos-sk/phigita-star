
HTMLArea.Config.prototype.css_style={};HTMLArea.Config.prototype.stylistLoadStylesheet=function(url,altnames)
{if(!altnames)altnames={};var newStyles=HTMLArea.ripStylesFromCSSFile(url);for(var i in newStyles)
{if(altnames[i])
{this.css_style[i]=altnames[i];}
else
{this.css_style[i]=newStyles[i];}}
this.pageStyleSheets[this.pageStyleSheets.length]=url;};HTMLArea.Config.prototype.stylistLoadStyles=function(styles,altnames)
{if(!altnames)altnames={};var newStyles=HTMLArea.ripStylesFromCSSString(styles);for(var i in newStyles)
{if(altnames[i])
{this.css_style[i]=altnames[i];}
else
{this.css_style[i]=newStyles[i];}}
this.pageStyle+=styles;};HTMLArea.prototype._fillStylist=function()
{if(!this._stylist)return false;this._stylist.innerHTML='<h1>'+HTMLArea._lc('Styles','Stylist')+'</h1>';var may_apply=true;var sel=this._getSelection();var active_elem=this._activeElement(sel);for(var x in this.config.css_style)
{var tag=null;var className=x.trim();var applicable=true;var apply_to=active_elem;if(applicable&&/[^a-zA-Z0-9_.-]/.test(className))
{applicable=false;}
if(className.indexOf('.')<0)
{applicable=false;}
if(applicable&&(className.indexOf('.')>0))
{tag=className.substring(0,className.indexOf('.')).toLowerCase();className=className.substring(className.indexOf('.'),className.length);if(active_elem!=null&&active_elem.tagName.toLowerCase()==tag)
{applicable=true;apply_to=active_elem;}
else
{if(this._getFirstAncestor(this._getSelection(),[tag])!=null)
{applicable=true;apply_to=this._getFirstAncestor(this._getSelection(),[tag]);}
else
{if((tag=='div'||tag=='span'||tag=='p'||(tag.substr(0,1)=='h'&&tag.length==2&&tag!='hr')))
{if(!this._selectionEmpty(this._getSelection()))
{applicable=true;apply_to='new';}
else
{apply_to=this._getFirstAncestor(sel,['p','h1','h2','h3','h4','h5','h6','h7']);if(apply_to!=null)
{applicable=true;}}}
else
{applicable=false;}}}}
if(applicable)
{className=className.substring(className.indexOf('.'),className.length);className=className.replace('.',' ');if(apply_to==null)
{if(this._selectionEmpty(this._getSelection()))
{apply_to=this._getFirstAncestor(this._getSelection(),null);}
else
{apply_to='new';tag='span';}}}
var applied=(this._ancestorsWithClasses(sel,tag,className).length>0?true:false);var applied_to=this._ancestorsWithClasses(sel,tag,className);if(applicable)
{var anch=document.createElement('a');anch._stylist_className=className.trim();anch._stylist_applied=applied;anch._stylist_appliedTo=applied_to;anch._stylist_applyTo=apply_to;anch._stylist_applyTag=tag;anch.innerHTML=this.config.css_style[x];anch.href='javascript:void(0)';var editor=this;anch.onclick=function()
{if(this._stylist_applied==true)
{editor._stylistRemoveClasses(this._stylist_className,this._stylist_appliedTo);}
else
{editor._stylistAddClasses(this._stylist_applyTo,this._stylist_applyTag,this._stylist_className);}
return false;}
anch.style.display='block';anch.style.paddingLeft='3px';anch.style.paddingTop='1px';anch.style.paddingBottom='1px';anch.style.textDecoration='none';if(applied)
{anch.style.background='Highlight';anch.style.color='HighlightText';}
this._stylist.appendChild(anch);}}};HTMLArea.prototype._stylistAddClasses=function(el,tag,classes)
{if(el=='new')
{this.insertHTML('<'+tag+' class="'+classes+'">'+this.getSelectedHTML()+'</'+tag+'>');}
else
{if(tag!=null&&el.tagName.toLowerCase()!=tag)
{var new_el=this.switchElementTag(el,tag);if(typeof el._stylist_usedToBe!='undefined')
{new_el._stylist_usedToBe=el._stylist_usedToBe;new_el._stylist_usedToBe[new_el._stylist_usedToBe.length]={'tagName':el.tagName,'className':el.getAttribute('class')};}
else
{new_el._stylist_usedToBe=[{'tagName':el.tagName,'className':el.getAttribute('class')}];}
HTMLArea.addClasses(new_el,classes);}
else
{HTMLArea._addClasses(el,classes);}}
this.focusEditor();this.updateToolbar();};HTMLArea.prototype._stylistRemoveClasses=function(classes,from)
{for(var x=0;x<from.length;x++)
{this._stylistRemoveClassesFull(from[x],classes);}
this.focusEditor();this.updateToolbar();};HTMLArea.prototype._stylistRemoveClassesFull=function(el,classes)
{if(el!=null)
{var thiers=el.className.trim().split(' ');var new_thiers=[];var ours=classes.split(' ');for(var x=0;x<thiers.length;x++)
{var exists=false;for(var i=0;exists==false&&i<ours.length;i++)
{if(ours[i]==thiers[x])
{exists=true;}}
if(exists==false)
{new_thiers[new_thiers.length]=thiers[x];}}
if(new_thiers.length==0&&el._stylist_usedToBe&&el._stylist_usedToBe.length>0&&el._stylist_usedToBe[el._stylist_usedToBe.length-1].className!=null)
{var last_el=el._stylist_usedToBe[el._stylist_usedToBe.length-1];var last_classes=HTMLArea.arrayFilter(last_el.className.trim().split(' '),function(c){if(c==null||c.trim()==''){return false;}return true;});if((new_thiers.length==0)||(HTMLArea.arrayContainsArray(new_thiers,last_classes)&&HTMLArea.arrayContainsArray(last_classes,new_thiers)))
{el=this.switchElementTag(el,last_el.tagName);new_thiers=last_classes;}
else
{el._stylist_usedToBe=[];}}
if(new_thiers.length>0||el.tagName.toLowerCase()!='span'||(el.id&&el.id!=''))
{el.className=new_thiers.join(' ').trim();}
else
{var prnt=el.parentNode;var childs=el.childNodes;for(var x=0;x<childs.length;x++)
{prnt.insertBefore(childs[x],el);}
prnt.removeChild(el);}}};HTMLArea.prototype.switchElementTag=function(el,tag)
{var prnt=el.parentNode;var new_el=this._doc.createElement(tag);if(HTMLArea.is_ie||el.hasAttribute('id'))new_el.setAttribute('id',el.getAttribute('id'));if(HTMLArea.is_ie||el.hasAttribute('style'))new_el.setAttribute('style',el.getAttribute('style'));var childs=el.childNodes;for(var x=0;x<childs.length;x++)
{new_el.appendChild(childs[x].cloneNode(true));}
prnt.insertBefore(new_el,el);new_el._stylist_usedToBe=[el.tagName];prnt.removeChild(el);this.selectNodeContents(new_el);return new_el;};HTMLArea.prototype._getAncestorsClassNames=function(sel)
{var prnt=this._activeElement(sel);if(prnt==null)
{prnt=(HTMLArea.is_ie?this._createRange(sel).parentElement():this._createRange(sel).commonAncestorContainer);}
var classNames=[];while(prnt)
{if(prnt.nodeType==1)
{var classes=prnt.className.trim().split(' ');for(var x=0;x<classes.length;x++)
{classNames[classNames.length]=classes[x];}
if(prnt.tagName.toLowerCase()=='body')break;if(prnt.tagName.toLowerCase()=='table')break;}
prnt=prnt.parentNode;}
return classNames;};HTMLArea.prototype._ancestorsWithClasses=function(sel,tag,classes)
{var ancestors=[];var prnt=this._activeElement(sel);if(prnt==null)
{try
{prnt=(HTMLArea.is_ie?this._createRange(sel).parentElement():this._createRange(sel).commonAncestorContainer);}
catch(e)
{return ancestors;}}
var search_classes=classes.trim().split(' ');while(prnt)
{if(prnt.nodeType==1&&prnt.className)
{if(tag==null||prnt.tagName.toLowerCase()==tag)
{var classes=prnt.className.trim().split(' ');var found_all=true;for(var i=0;i<search_classes.length;i++)
{var found_class=false;for(var x=0;x<classes.length;x++)
{if(search_classes[i]==classes[x])
{found_class=true;break;}}
if(!found_class)
{found_all=false;break;}}
if(found_all)ancestors[ancestors.length]=prnt;}
if(prnt.tagName.toLowerCase()=='body')break;if(prnt.tagName.toLowerCase()=='table')break;}
prnt=prnt.parentNode;}
return ancestors;};HTMLArea.ripStylesFromCSSFile=function(URL)
{var css=HTMLArea._geturlcontent(URL);return HTMLArea.ripStylesFromCSSString(css);};HTMLArea.ripStylesFromCSSString=function(css)
{RE_comment=/\/\*(.|\r|\n)*?\*\//g;RE_rule=/\{(.|\r|\n)*?\}/g;css=css.replace(RE_comment,'');css=css.replace(RE_rule,',');css=css.split(',');var selectors={};for(var x=0;x<css.length;x++)
{if(css[x].trim())
{selectors[css[x].trim()]=css[x].trim();}}
return selectors;};function Stylist(editor,args)
{this.editor=editor;editor._stylist=null;editor._stylist=editor.addPanel('right');HTMLArea.addClass(editor._stylist,'stylist');var stylist=this;editor.notifyOn('modechange',function(e,args)
{switch(args.mode)
{case'text':{editor.hidePanel(editor._stylist);break;}
case'wysiwyg':{editor.showPanel(editor._stylist);break;}}});}
Stylist._pluginInfo={name:"Stylist",version:"1.0",developer:"James Sleeman",developer_url:"http://www.gogo.co.nz/",c_owner:"Gogo Internet Services",license:"htmlArea",sponsor:"Gogo Internet Services",sponsor_url:"http://www.gogo.co.nz/"};Stylist.prototype.onGenerateOnce=function()
{var editor=this.editor;if(typeof editor.config.css_style=='undefined'||HTMLArea.objectProperties(editor.config.css_style).length==0)
{editor.removePanel(editor._stylist);editor._stylist=null;}};Stylist.prototype.onUpdateToolbar=function()
{if(this.editor._stylist)
{if(this._timeoutID)
{window.clearTimeout(this._timeoutID);}
var e=this.editor;this._timeoutID=window.setTimeout(function(){e._fillStylist();},250);}};
