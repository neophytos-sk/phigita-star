
InsertImage._pluginInfo={name:"InsertImage",origin:"Xinha Core",version:"$LastChangedRevision: 694 $".replace(/^[^:]*: (.*) \$$/,'$1'),developer:"The Xinha Core Developer Team",developer_url:"$HeadURL: http://svn.xinha.python-hosting.com/trunk/modules/InsertImage/insert_image.js $".replace(/^[^:]*: (.*) \$$/,'$1'),sponsor:"",sponsor_url:"",license:"htmlArea"};function InsertImage(editor){}
Xinha.prototype._insertImage=function(image)
{var editor=this;var outparam=null;if(typeof image=="undefined")
{image=this.getParentElement();if(image&&image.tagName.toLowerCase()!='img')
{image=null;}}
if(image)
{outparam={f_base:editor.config.baseHref,f_url:Xinha.is_ie?editor.stripBaseURL(image.src):image.getAttribute("src"),f_alt:image.alt,f_border:image.border,f_align:image.align,f_vert:image.vspace,f_horiz:image.hspace,f_width:image.width,f_height:image.height};}
Dialog(editor.config.URIs.insert_image,function(param)
{if(!param)
{return false;}
var img=image;if(!img)
{if(Xinha.is_ie)
{var sel=editor.getSelection();var range=editor.createRange(sel);editor._doc.execCommand("insertimage",false,param.f_url);img=range.parentElement();if(img.tagName.toLowerCase()!="img")
{img=img.previousSibling;}}
else
{img=document.createElement('img');img.src=param.f_url;editor.insertNodeAtSelection(img);if(!img.tagName)
{img=range.startContainer.firstChild;}}}
else
{img.src=param.f_url;}
for(var field in param)
{var value=param[field];switch(field)
{case"f_alt":if(value)
img.alt=value
else
img.removeAttribute("alt");break;case"f_border":if(value)
img.border=parseInt(value||"0")
else
img.removeAttribute("border");break;case"f_align":if(value)
img.align=value
else
img.removeAttribute("align");break;case"f_vert":if(value)
img.vspace=parseInt(value||"0")
else
img.removeAttribute("vspace");break;case"f_horiz":if(value)
img.hspace=parseInt(value||"0")
else
img.removeAttribute("hspace");break;case"f_width":if(value)
img.width=parseInt(value||"0");else
img.removeAttribute("width");break;case"f_height":if(value)
img.height=parseInt(value||"0");else
img.removeAttribute("height");break;}}},outparam);};
