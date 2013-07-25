
var agt=navigator.userAgent.toLowerCase();var is_ie=(agt.indexOf("msie")!=-1);var is_ie5=(agt.indexOf("msie 5")!=-1);var is_opera=(agt.indexOf("opera")!=-1);var is_mac=(agt.indexOf("mac")!=-1);var is_gecko=(agt.indexOf("gecko")!=-1);var is_safari=(agt.indexOf("safari")!=-1);function Supported(){if(is_ie&&!is_opera&&!is_mac){var version=GetFollowingFloat(agt,"msie ");if(version!=null){return(version>=5.5);}}
if(is_gecko&&!is_safari){var version=GetFollowingFloat(agt,"rv:");if(version!=null){return(version>=1.4);}else{var i=agt.indexOf("galeon");version=GetFollowingFloat(agt,"galeon/");if(version!=null){return(version>=1.3);}}}
if(is_safari){var version=GetFollowingFloat(agt,"applewebkit/");if(version!=null){return(version>=124);}}
return false;}
function CheckBrowser(continueUrl){if(!Supported()){var continueParam=escape(continueUrl);var url="http://www.phigita.net/help/browser_requirements.html";url=url+"?continue="+continueParam;top.location=url;}}
function GetFollowingFloat(str,prefix){var i=str.indexOf(prefix);if(i!=-1){var version=parseFloat(str.substring(i+prefix.length));if(!isNaN(version)){return version;}}
return null;}
function CreateXmlHttpReq(handler){var xmlhttp=null;if(is_ie){var control=(is_ie5)?"Microsoft.XMLHTTP":"Msxml2.XMLHTTP";try{xmlhttp=new ActiveXObject(control);xmlhttp.onreadystatechange=handler;}catch(ex){alert("You need to enable active scripting and activeX controls");}}else{xmlhttp=new XMLHttpRequest();xmlhttp.onload=handler;xmlhttp.onerror=handler;}
return xmlhttp;}
function XmlHttpPOST(xmlhttp,url,data){try{xmlhttp.open("POST",url,true);xmlhttp.send(data);}catch(ex){}}
function XmlHttpGET(xmlhttp,url){try{xmlhttp.open("GET",url,true);xmlhttp.send(null);}catch(ex){}}
function trim(value){return value;var temp=value;var obj=/^(\s*)([\W\w]*)(\b\s*$)/;if(obj.test(temp)){temp=temp.replace(obj,'$2');}
return temp;}
function parseResponseHeader(key,header){var lines=header.split("\n");var re=new RegExp("^"+key+":\\s");for(var i in lines){if(re.exec(lines[i])){var returnValue=trim(RegExp.rightContext);return returnValue;}}
return"";}
function delay(gap){var then,now;then=new Date().getTime();now=then;while((now-then)<gap){now=new Date().getTime();}}
