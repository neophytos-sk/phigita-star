
CreateLink._pluginInfo={name:"CreateLink",origin:"Xinha Core",version:"$LastChangedRevision: 694 $".replace(/^[^:]*: (.*) \$$/,'$1'),developer:"The Xinha Core Developer Team",developer_url:"$HeadURL: http://svn.xinha.python-hosting.com/trunk/modules/CreateLink/link.js $".replace(/^[^:]*: (.*) \$$/,'$1'),sponsor:"",sponsor_url:"",license:"htmlArea"};function CreateLink(editor){}
Xinha.prototype._createLink=function(link)
{var editor=this;var outparam=null;if(typeof link=="undefined")
{link=this.getParentElement();if(link)
{while(link&&!/^a$/i.test(link.tagName))
{link=link.parentNode;}}}
if(!link)
{var sel=editor.getSelection();var range=editor.createRange(sel);this.fullwordSelection();var compare=0;if(Xinha.is_ie)
{if(sel.type=="Control")
{compare=range.length;}
else
{compare=range.compareEndPoints("StartToEnd",range);}}
else
{compare=range.compareBoundaryPoints(range.START_TO_END,range);}
if(compare===0)
{alert(Xinha._lc("You need to select some text before creating a link"));return;}
outparam={f_href:'http://',f_label:range.toString(),f_title:'',f_target:'',f_usetarget:editor.config.makeLinkShowsTarget};}
else
{outparam={f_href:Xinha.is_ie?editor.stripBaseURL(link.href):link.getAttribute("href"),f_label:link.childNodes[0].textContent,f_title:link.title,f_target:link.target,f_usetarget:editor.config.makeLinkShowsTarget};}
Dialog(editor.config.URIs.link,function(param)
{if(!param)
{return false;}
var a=link;if(!a)
{try
{var tmp=Xinha.uniq('http://www.example.com/Link');if(param.f_href.indexOf("http://")!=0||param.f_href.length<="http://".length)
{alert("Invalid link");return false;}
editor._doc.execCommand("removeformat",false,false);editor._doc.execCommand('createlink',false,tmp);var anchors=editor._doc.getElementsByTagName('a');for(var i=0;i<anchors.length;i++)
{var anchor=anchors[i];if(anchor.href==tmp)
{if(!a)a=anchor;anchor.href=param.f_href;if(param.f_target)anchor.target=param.f_target;if(param.f_title)anchor.title=param.f_title;}}}catch(ex){}}
else
{var href=param.f_href.trim();editor.selectNodeContents(a);if(href==='')
{editor._doc.execCommand("unlink",false,null);editor.updateToolbar();return false;}
else
{a.href=href;}}
if(!(a&&a.tagName.toLowerCase()=='a'))
{return false;}
a.target=param.f_target.trim();a.title=param.f_title.trim();a.childNodes[0].textContent=param.f_label;editor.selectNodeContents(a);editor.updateToolbar();},outparam);};
