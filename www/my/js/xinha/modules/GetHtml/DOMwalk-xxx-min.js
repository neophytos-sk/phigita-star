
function GetHtmlImplementation(editor){this.editor=editor;}
GetHtmlImplementation._pluginInfo={name:"GetHtmlImplementation DOMwalk",origin:"Xinha Core",version:"$LastChangedRevision: 694 $".replace(/^[^:]*: (.*) \$$/,'$1'),developer:"The Xinha Core Developer Team",developer_url:"$HeadURL: http://svn.xinha.python-hosting.com/trunk/modules/GetHtml/DOMwalk.js $".replace(/^[^:]*: (.*) \$$/,'$1'),sponsor:"",sponsor_url:"",license:"htmlArea"};Xinha.getHTML=function(root,outputRoot,editor)
{try
{return Xinha.getHTMLWrapper(root,outputRoot,editor);}
catch(ex)
{alert(Xinha._lc('Your Document is not well formed. Check JavaScript console for details.'));return editor._iframe.contentWindow.document.body.innerHTML;}};Xinha.getHTMLWrapper=function(root,outputRoot,editor,indent)
{var html="";if(!indent)
{indent='';}
switch(root.nodeType)
{case 10:case 6:case 12:break;case 2:break;case 4:html+=(Xinha.is_ie?('\n'+indent):'')+'<![CDATA['+root.data+']]>';break;case 5:html+='&'+root.nodeValue+';';break;case 7:html+=(Xinha.is_ie?('\n'+indent):'')+'<?'+root.target+' '+root.data+' ?>';break;case 1:case 11:case 9:var closed;var i;var root_tag=(root.nodeType==1)?root.tagName.toLowerCase():'';if((root_tag=="script"||root_tag=="noscript")&&editor.config.stripScripts)
{break;}
if(outputRoot)
{outputRoot=!(editor.config.htmlRemoveTags&&editor.config.htmlRemoveTags.test(root_tag));}
if(Xinha.is_ie&&root_tag=="head")
{if(outputRoot)
{html+=(Xinha.is_ie?('\n'+indent):'')+"<head>";}
var save_multiline=RegExp.multiline;RegExp.multiline=true;var txt=root.innerHTML.replace(Xinha.RE_tagName,function(str,p1,p2){return p1+p2.toLowerCase();});RegExp.multiline=save_multiline;html+=txt+'\n';if(outputRoot)
{html+=(Xinha.is_ie?('\n'+indent):'')+"</head>";}
break;}
else if(outputRoot)
{closed=(!(root.hasChildNodes()||Xinha.needsClosingTag(root)));html+=(Xinha.is_ie&&Xinha.isBlockElement(root)?('\n'+indent):'')+"<"+root.tagName.toLowerCase();var attrs=root.attributes;for(i=0;i<attrs.length;++i)
{var a=attrs.item(i);if(typeof a.nodeValue!='string')continue;if(!a.specified&&!(root.tagName.toLowerCase().match(/input|option/)&&a.nodeName=='value')&&!(root.tagName.toLowerCase().match(/area/)&&a.nodeName.match(/shape|coords/i)))
{continue;}
var name=a.nodeName.toLowerCase();if(/_moz_editor_bogus_node/.test(name))
{html="";break;}
if(/(_moz)|(contenteditable)|(_msh)/.test(name))
{continue;}
var value;if(name!="style")
{if(typeof root[a.nodeName]!="undefined"&&name!="href"&&name!="src"&&!(/^on/.test(name)))
{value=root[a.nodeName];}
else
{value=a.nodeValue;if(Xinha.is_ie&&(name=="href"||name=="src"))
{value=editor.stripBaseURL(value);}
if(editor.config.only7BitPrintablesInURLs&&(name=="href"||name=="src"))
{value=value.replace(/([^!-~]+)/g,function(match){return escape(match);});}}}
else
{value=root.style.cssText;}
if(/^(_moz)?$/.test(value))
{continue;}
html+=" "+name+'="'+Xinha.htmlEncode(value)+'"';}
if(html!=="")
{if(closed&&root_tag=="p")
{html+=">&nbsp;</p>";}
else if(closed)
{html+=" />";}
else
{html+=">";}}}
var containsBlock=false;if(root_tag=="script"||root_tag=="noscript")
{if(!editor.config.stripScripts)
{if(Xinha.is_ie)
{var innerText="\n"+root.innerHTML.replace(/^[\n\r]*/,'').replace(/\s+$/,'')+'\n'+indent;}
else
{var innerText=(root.hasChildNodes())?root.firstChild.nodeValue:'';}
html+=innerText+'</'+root_tag+'>'+((Xinha.is_ie)?'\n':'');}}
else
{for(i=root.firstChild;i;i=i.nextSibling)
{if(!containsBlock&&i.nodeType==1&&Xinha.isBlockElement(i))
{containsBlock=true;}
html+=Xinha.getHTMLWrapper(i,true,editor,indent+'  ');}
if(outputRoot&&!closed)
{html+=(Xinha.is_ie&&Xinha.isBlockElement(root)&&containsBlock?('\n'+indent):'')+"</"+root.tagName.toLowerCase()+">";}}
break;case 3:html=/^script|noscript|style$/i.test(root.parentNode.tagName)?root.data:Xinha.htmlEncode(root.data);break;case 8:html="<!--"+root.data+"-->";break;}
return html;};
