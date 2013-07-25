
YAHOO.util.Dom.create=function(tagName){_util={_makeTxtObject:function(txt){return document.createTextNode(txt);},_makeChildren:function(arr,elm){for(var i in arr){_val=arr[i];if(typeof _val=='string'){_val=this._makeTxtObject(_val);}
elm.appendChild(_val);}},_makeStyleObject:function(attrsObj,elm){for(var i in attrsObj){switch(i.toLowerCase()){case'listener':if(attrsObj[i]instanceof Array){var ev=attrsObj[i][0];var func=attrsObj[i][1];var base=attrsObj[i][2];var scope=attrsObj[i][3];YAHOO.util.Event.addListener(elm,ev,func,base,scope);}
break;case'classname':case'class':elm.className=attrsObj[i];break;case'style':var _tmp=attrsObj[i].replace(' ','');_tmp=_tmp.split(';');for(x in _tmp){if(x){var __tmp=_tmp[x].replace(' ','');__tmp=_tmp[x].split(':');if(__tmp[0]&&__tmp[1]){var _attr=__tmp[0].replace(' ','');var _val=_util._trim(__tmp[1]);if(_attr&&_val){if(_attr.indexOf('-')!=-1){_attr=_util._fixStyle(_attr);}
eval('elm.style.'+_attr+' = "'+_val+'";');}}}}
break;default:elm.setAttribute(i,attrsObj[i]);break;}}},_fixStyle:function(str){var _tmp=str.split('-');var _new_style=_tmp[0];for(var i=1;i<_tmp.length;i++){_new_style+=_tmp[i].substring(0,1).toUpperCase()+_tmp[i].substring(1,_tmp[i].length);}
return _new_style;},_trim:function(str){return str.replace(/^\s+/g,'').replace(/\s+$/g,'');}}
tagName=tagName.toLowerCase();elm=document.createElement(tagName);var txt=false;var attrsObj=false;if(!elm){return false;}
for(var i=1;i<arguments.length;i++){txt=arguments[i];if(typeof txt=='string'){_txt=_util._makeTxtObject(txt);elm.appendChild(_txt);}else if(txt instanceof Array){_util._makeChildren(txt,elm);}else if(typeof txt=='object'){_util._makeStyleObject(txt,elm);}}
return elm;}
