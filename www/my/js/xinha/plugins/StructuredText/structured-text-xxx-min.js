
function StructuredText(editor)
{this.textarea=editor;}
function isSpace(ch){stopchars=" \t\n\r";if(stopchars.indexOf(ch)!=-1)
return true;if(ch.charCodeAt(0)==160)
return true;return false;}
function isStopChar(ch){stopchars=" \t\n\r.,;?";if(stopchars.indexOf(ch)!=-1)
return true;if(ch.charCodeAt(0)==160)
return true;return false;}
function getStxTag(htmlTag){stxTags_b=new Array();stxTags_e=new Array();stxTags_b['strong']=stxTags_b['b']=" **";stxTags_e['strong']=stxTags_e['b']="**";stxTags_b['em']=stxTags_b['i']=" *";stxTags_e['em']=stxTags_e['i']="*";stxTags_b['u']=" _";stxTags_e['u']="_";stxTags_b['p']="\n\n";stxTags_e['p']="";stxTags_b['pre']="\n\n::\n\n";stxTags_e['pre']="";stxTags_b['code']="\n\n%%\n\n";stxTags_e['code']="";stxTags_b['h6']="\n\n%%\n\n";stxTags_e['h6']="";stxTags_b['li']="\n\n-";stxTags_e['li']="";stxTags_b['hr']="\n\n-----";stxTags_e['hr']="";stxTags_b['h1']="\n\n==";stxTags_e['h1']="==";stxTags_b['h2']="\n\n===";stxTags_e['h2']="===";stxTags_b['h3']="\n\n====";stxTags_e['h3']="====";stxTags_b['br']="\n\n";stxTags_e['br']="";stxTags_b['font']=" ''";stxTags_e['font']="'' ";stxTags_b['span']=" ''";stxTags_e['span']="'' ";stxTags_b['a']=' "';stxTags_e['a']='":';function symbol(){}
symbol.begin="";symbol.end="";for(var tag in stxTags_b)
if(tag==htmlTag)
{symbol.begin=stxTags_b[tag];symbol.end=stxTags_e[tag];return symbol;}
return symbol;}
function trimString(str){var i,j;for(i=0;i<str.length;i++)
if(!isSpace(str[i]))
break;for(j=str.length-1;j>=0;j--)
if(!isSpace(str[j]))
break;return str.substring(i,j+1);}
function parseNode(node,mode,list,indent)
{if(!node)
return"";if(node.nodeType==Node.TEXT_NODE)
return node.textContent;var tag=node.tagName.toLowerCase();var symbol=getStxTag(tag);if(tag=="ol")
list="ol";else if(tag=="ul")
list="ul";if(tag=="p"||tag=="pre"||tag=="h6")
mode=tag;if(tag=="li"&&list=="ol")
{symbol.begin="\n\n#";symbol.end="";}
if(tag=="br")
if(mode=="pre"||mode=="h6")
symbol.begin="\n";else if(mode=="p")
symbol.begin="";var text="";text+=symbol.begin;if(tag=="p")
{text+=indent;}
if(tag=="pre"||tag=="h6"||tag=="li")
{indent+=" ";text+=indent;}
else if(tag=="br")
text+=indent;var txt="";for(var i=0;i<node.childNodes.length;i++)
txt+=parseNode(node.childNodes[i],mode,list,indent);if(txt!=""||tag=="br"||tag=="hr")
{if(tag=="ul"||tag=="ol"||tag=="frame")
text+=txt+symbol.end;else
text+=trimString(txt)+symbol.end;if(tag=="a")
{if(!node.getAttribute("href"))
text+="http://www.phigita.net";else
text+=node.getAttribute("href");}}
else
text="";return text;}
HTMLArea.prototype.getStxFromHtml=function(html){var obj=document.createElement('frame');obj.innerHTML=html;result=parseNode(obj,"","","");return result;};HTMLArea.prototype.fullwordSelection=function(spaces){var sel=this._getSelection();if(sel.toString().length>0)
{var range=this._createRange(sel);if(range.toString()==range.endContainer.nodeValue)
range.setStart(range.endContainer,0);while(!isStopChar(range.toString().charAt(0)))
{try{range.setStart(range.startContainer,range.startOffset-1);}
catch(exx){break;}}
if(isStopChar(range.toString().charAt(0)))
{try{range.setStart(range.startContainer,range.startOffset+1);}
catch(exx){};}
if(spaces==true)
{do{try{range.setStart(range.startContainer,range.startOffset-1);}
catch(exx){break;}}while(isStopChar(range.toString().charAt(0)));if(range.startOffset!=0&&!isStopChar(range.toString().charAt(0)))
range.setStart(range.startContainer,range.startOffset+1);}
var s=range.toString();while(!isStopChar(s[s.length-1])){try{range.setEnd(range.endContainer,range.endOffset+1);}
catch(exx){break;}
s=range.toString();}
if(isStopChar(s[s.length-1]))
range.setEnd(range.endContainer,range.endOffset-1);if(spaces==true)
{do{try{range.setEnd(range.endContainer,range.endOffset+1);}
catch(exx){break;}
s=range.toString();}while(isStopChar(s[s.length-1]));if(range.endOffset!=range.endContainer.length&&!isStopChar(s[s.length-1]))
range.setEnd(range.endContainer,range.endOffset-1);}}};StructuredText._pluginInfo={name:"StructuredText",version:"1.0",developer:"Avgoustinos Kadis",developer_url:"http://www.phigita.net/~avgoustinos",c_owner:"Neophytos Demetriou",sponsor:"Phigita.net Inc",sponsor_url:"http://www.phigita.net",license:"htmlArea"};StructuredText.prototype._lc=function(string){return HTMLArea._lc(string,'StructuredText');};
