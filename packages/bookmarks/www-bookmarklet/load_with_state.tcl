set signed_user_id [::xo::session::signed_value "_T" [ad_conn user_id]]
set js "var _T=[::util::jsquotevalue ${signed_user_id}];"
append js {
(function(){
function _b_dsc(obj) { var names = ""; for (var name in obj) names += name + " \n"; return names; } ; function _b_dmp(obj) { var names = ""; for (var name in obj) { try { names += name + ":" + ( (obj[name] == null) ? "nil" : obj[name].toString() ) + " \n"; } catch (e) { names += name + ":ER \n"; } } return names; } ;
var _reMark = (typeof(_reMark) == 'undefined') ? {} : _reMark;
_reMark.vh = "javascript:void(null);";


var _long_url = document.location.href;
if (_long_url.indexOf("#") == -1 && document.location.hash ) {
_long_url = _long_url + document.location.hash;
}

// _reMark.url = document.URL
_reMark.url = _long_url;
_reMark.share_title = document.title;
_reMark._T = _T;

_reMark.setAttribute = function(e, k, v) {
if (k == "class") {
e.setAttribute("className", v); // set both "class" and "className"
}
return e.setAttribute(k, v);
};
_reMark.createElement = function(e, attrs) {
var el = document.createElement(e);
for (var k in attrs) {
if (k == "text") {
el.appendChild(document.createTextNode(attrs[k]));
} else {
_reMark.setAttribute(el, k, attrs[k]);
}
}
return el;
};
_reMark.remove = function(e) {
e.parentNode.removeChild(e);
};
_reMark.listen = function(elem, evnt, func) {
if (elem.addEventListener) // W3C DOM
elem.addEventListener(evnt,func,false);
else if (elem.attachEvent) { // IE DOM
var r = elem.attachEvent("on"+evnt, func);
return r;
}
};
_reMark.loadScript = function(_src) {
var e = document.createElement('script');
e.setAttribute('language','javascript');
e.setAttribute('type', 'text/javascript');
e.setAttribute('src',_src); document.body.appendChild(e);
};
_reMark.loadCss = function(u) {
var e = document.createElement('link');
e.setAttribute('type', 'text/css');
e.setAttribute('href', u);
e.setAttribute('rel', 'stylesheet');
e.setAttribute('media', 'screen');
try {
document.getElementsByTagName('head')[0].appendChild(e);
} catch(z) {
document.body.appendChild(e);
}
};
_reMark.close = function() {
var overlay = document.getElementById('_b_overlay');
if (overlay != undefined) {
_reMark.remove(overlay);
}
if (_reMark.timeout_handle != undefined) {
clearTimeout(_reMark.timeout_handle);
}
};
_reMark.getSelection = function() {
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
_reMark.drawOverlay = function() {
_reMark.url = (typeof _reMark.url == 'undefined') ? document.URL : _reMark.url; // allow this to be parameterized
_reMark.close();
var overlay = _reMark.createElement('div');
overlay.id = '_b_overlay';
var content = _reMark.createElement('div', {"id": "_b_content"});
// var header = _reMark.createElement('div', {"id":"_b_header"});
// content.appendChild(header);
var closeBtn = _reMark.createElement('a', {"text": "x", "id": "_b_close", "href":_reMark.vh, "title": "Close sidebar"});
_reMark.listen(closeBtn, 'click', _reMark.close);
content.appendChild(closeBtn);
var selection = _reMark.getSelection();
var pars = [
["u", _reMark.url],
["t", _reMark.share_title],
["_T",_reMark._T]
];
if (selection != '') {
pars.push(["s", selection]); // only do this if there's a selection or we're using the bookmarklet on a landing page
}
for (var i=0; i < pars.length; i++) {
pars[i] = pars[i][0]+"="+encodeURIComponent(pars[i][1]);
};
/*
IE appears to be case sensitive to iframes. use caution. Known issues: frameBorder, allowTransparency
*/
var src = "http://my.phigita.net/bookmarks/sidebar?" + pars.join("&");

//var src = "http://localhost:8090/my/bookmarks/sidebar?" + pars.join("&");
var iframe = _reMark.createElement('iframe', {"id": "_b_iframe", "src": src, "allowTransparency": "true", "frameBorder" : 0 });
//iframe.style.display="none"
content.appendChild(iframe);
overlay.appendChild(content);
// animate it?
document.body.appendChild(overlay);
};
_reMark.loadCss('http://www.phigita.net/bookmarklet/sidebar.css');
_reMark.drawOverlay();
window['_reMark']=_reMark;
})();
}
doc_return 200 text/javascript ${js}
