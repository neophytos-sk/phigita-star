(function(){
function _b_dsc(obj) { var names = ""; for (var name in obj) names += name + " \n"; return names; } ; function _b_dmp(obj) { var names = ""; for (var name in obj) { try { names += name + ":" + ( (obj[name] == null) ? "nil" : obj[name].toString() ) + " \n"; } catch (e) { names += name + ":ER \n"; } } return names; } ;
var BitlySidebar = (typeof(BitlySidebar) == 'undefined') ? {} : BitlySidebar;
BitlySidebar.vh = "javascript:void(null);";
/*
#if $long_url != ''
*/
BitlySidebar.url = "";
BitlySidebar.share_title = "";
/*
#end if
*/
BitlySidebar.setAttribute = function(e, k, v) {
if (k == "class") {
e.setAttribute("className", v); // set both "class" and "className"
}
return e.setAttribute(k, v);
};
BitlySidebar.createElement = function(e, attrs) {
var el = document.createElement(e);
for (var k in attrs) {
if (k == "text") {
el.appendChild(document.createTextNode(attrs[k]));
} else {
BitlySidebar.setAttribute(el, k, attrs[k]);
}
}
return el;
};
BitlySidebar.remove = function(e) {
e.parentNode.removeChild(e);
};
BitlySidebar.listen = function(elem, evnt, func) {
if (elem.addEventListener) // W3C DOM
elem.addEventListener(evnt,func,false);
else if (elem.attachEvent) { // IE DOM
var r = elem.attachEvent("on"+evnt, func);
return r;
}
};
BitlySidebar.loadScript = function(_src) {
var e = document.createElement('script');
e.setAttribute('language','javascript');
e.setAttribute('type', 'text/javascript');
e.setAttribute('src',_src); document.body.appendChild(e);
};
BitlySidebar.close = function() {
var overlay = document.getElementById('_b_overlay');
if (overlay != undefined) {
BitlySidebar.remove(overlay);
}
if (BitlySidebar.timeout_handle != undefined) {
clearTimeout(BitlySidebar.timeout_handle);
}
};
BitlySidebar.getSelection = function() {
var selection;
if (window.getSelection) {
selection = window.getSelection();
} else if (document.getSelection) {
selection = document.getSelection();
} else if (document.selection) {
selection = document.selection.createRange().text;
}
if (!selection) {
selection = '';
}
return selection;
};
BitlySidebar.drawOverlay = function() {
BitlySidebar.url = (typeof BitlySidebar.url == 'undefined') ? document.URL : BitlySidebar.url; // allow this to be parameterized
BitlySidebar.close();
var overlay = BitlySidebar.createElement('div');
overlay.id = '_b_overlay';
var content = BitlySidebar.createElement('div', {"id": "_b_content"});
// var header = BitlySidebar.createElement('div', {"id":"_b_header"});
// content.appendChild(header);
var closeBtn = BitlySidebar.createElement('a', {"text": "x", "id": "_b_close", "href":BitlySidebar.vh, "title": "Close bit.ly sidebar"});
BitlySidebar.listen(closeBtn, 'click', BitlySidebar.close);
content.appendChild(closeBtn);
var selection = BitlySidebar.getSelection();
var pars = [
["u", BitlySidebar.url],
["s", BitlySidebar.share_title]
];
if (BitlySidebar.url == document.URL || selection != '') {
pars.push(["s", ((selection == '') ? document.title : selection)]); // only do this if there's a selection or we're using the bookmarklet on a landing page
} else if( BitlySidebar.share_title != '' ) {
pars.push(["s", BitlySidebar.share_title]);
}
for (var i=0; i < pars.length; i++) {
pars[i] = pars[i][0]+"="+encodeURIComponent(pars[i][1]);
};
/*
IE appears to be case sensitive to iframes. use caution. Known issues: frameBorder, allowTransparency
*/
var src = "http://bit.ly/a/sidebar?" + pars.join("&");
var iframe = BitlySidebar.createElement('iframe', {"id": "_b_iframe", "src": src, "allowTransparency": "true", "frameBorder" : 0 });
//iframe.style.display="none"
content.appendChild(iframe);
overlay.appendChild(content);
// animate it?
document.body.appendChild(overlay);
};
BitlySidebar.drawOverlay();
})();
